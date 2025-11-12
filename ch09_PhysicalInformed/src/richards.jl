using DifferentialEquations, DiffEqFlux, Lux, Optimization, OptimizationOptimisers
using ComponentArrays, Random, LinearAlgebra, StaticArrays, SciMLStructures


# Van Genuchten参数化 - 使用不可变结构提高性能
struct VanGenuchten{T}
  θr::T
  θs::T
  α::T
  n::T
  m::T
  Ks::T
  # 预计算常用值
  Δθ::T  # θs - θr
  αn::T  # α * n
  mn::T  # m * n
end

function VanGenuchten(θr::T, θs::T, α::T, n::T, Ks::T) where T
  m = one(T) - one(T) / n
  VanGenuchten(θr, θs, α, n, m, Ks, θs - θr, α * n, m * n)
end

# 优化的水力函数 - 避免重复计算
@inline function hydraulic_props(h::T, vg::VanGenuchten{T}) where T
  if h >= zero(T)
    return vg.θs, vg.Ks, T(1e-6)
  end

  ah = abs(vg.α * h)
  ahn = ah^vg.n
  denom = one(T) + ahn
  denom_m = denom^vg.m

  # θ
  θ = vg.θr + vg.Δθ / denom_m

  # Se
  Se = (θ - vg.θr) / vg.Δθ

  # K - 使用Se避免重复计算
  tmp = one(T) - ahn^(one(T) - one(T) / vg.n) / denom_m
  K = vg.Ks * sqrt(Se) * tmp^2

  # C
  C = vg.Δθ * vg.mn * ahn^(one(T) - one(T) / vg.n) / (denom * denom_m)

  return θ, K, C
end

# 优化的降水插值 - 二分查找
struct RainInterp{T}
  times::Vector{T}
  values::Vector{T}
end

@inline function (r::RainInterp)(t)
  n = length(r.times)
  t <= r.times[1] && return r.values[1]
  t >= r.times[n] && return r.values[n]

  # 二分查找
  i = searchsortedlast(r.times, t)
  α = (t - r.times[i]) / (r.times[i+1] - r.times[i])
  return r.values[i] + α * (r.values[i+1] - r.values[i])
end

# 预分配内存的ODE求解器
mutable struct RichardsCache{T}
  K_vals::Vector{T}
  C_vals::Vector{T}
  K_half::Vector{T}
  q::Vector{T}
  nn_input::Vector{T}
end

function RichardsCache(n_layers::Int, T=Float64)
  RichardsCache(
    zeros(T, n_layers),
    zeros(T, n_layers),
    zeros(T, n_layers + 1),
    zeros(T, n_layers + 1),
    zeros(T, n_layers + 2)
  )
end

# 优化的Richards方程 - 使用符合SciMLStructures的参数结构
function create_richards_ode(nn, st, cache::RichardsCache, vg, dz, rain_interp)
  function ode!(du, u, p_nn, t)  # p_nn 是唯一的可调参数
    n_layers = length(u)

    # 获取降水
    rain = rain_interp(t)

    # 批量计算水力性质
    @inbounds for i in 1:n_layers
      _, cache.K_vals[i], cache.C_vals[i] = hydraulic_props(u[i], vg)
    end

    # 界面导水率 - 调和平均
    cache.K_half[1] = cache.K_vals[1]
    @inbounds for i in 2:n_layers
      cache.K_half[i] = 2.0 / (1.0 / cache.K_vals[i-1] + 1.0 / cache.K_vals[i])
    end
    cache.K_half[n_layers+1] = cache.K_vals[n_layers]

    # 通量计算
    cache.q[1] = rain
    inv_dz = 1.0 / dz
    @inbounds for i in 2:n_layers
      cache.q[i] = -cache.K_half[i] * ((u[i] - u[i-1]) * inv_dz + 1.0)
    end
    cache.q[n_layers+1] = -cache.K_half[n_layers+1]

    # Richards方程
    @inbounds for i in 1:n_layers
      du[i] = -(cache.q[i+1] - cache.q[i]) * inv_dz / cache.C_vals[i]
    end

    # 神经网络修正 - 重用缓存
    @inbounds for i in 1:n_layers
      cache.nn_input[i] = u[i]
    end
    cache.nn_input[n_layers+1] = t
    cache.nn_input[n_layers+2] = rain

    nn_out, _ = nn(cache.nn_input, p_nn, st)
    @inbounds for i in 1:n_layers
      du[i] += nn_out[i]
    end

    nothing
  end
  return ode!
end

# 批量模拟 - 避免重复创建问题
function simulate_batch(nn, p_nn, st, vg, dz, h0, times, rain_values;
  cache=nothing, solver=Tsit5())
  n_layers = length(h0)
  if isnothing(cache)
    cache = RichardsCache(n_layers)
  end

  rain_interp = RainInterp(times, rain_values)
  ode_fn = create_richards_ode(nn, st, cache)

  h_all = Vector{Vector{Float64}}(undef, length(times))
  h_all[1] = copy(h0)
  current_h = copy(h0)

  # 重用ODE问题
  for i in 1:(length(times)-1)
    tspan = (times[i], times[i+1])
    prob = ODEProblem(ode_fn, current_h, tspan, (vg, dz, rain_interp, p_nn))
    sol = solve(prob, solver,
      save_everystep=false,
      saveat=[times[i+1]],
      abstol=1e-6,
      reltol=1e-4)

    if sol.retcode == ReturnCode.Success
      current_h = sol.u[end]
      h_all[i+1] = copy(current_h)
    else
      h_all[i+1] = copy(current_h)
    end
  end

  return h_all
end

# 向量化损失函数 - 确保参数是Tunable
function loss_batch(p_nn, nn, st, vg, dz, h0, times, rain_values,
  h_obs, obs_mask; cache=nothing)

  # 使用 Lux.apply 并传递正确的参数
  h_pred = simulate_batch(nn, p_nn, st, vg, dz, h0, times, rain_values;
    cache=cache)

  # 向量化计算
  loss = 0.0
  n_obs = 0

  @inbounds for i in 1:length(h_obs)
    for j in 1:length(h_obs[i])
      if obs_mask[i, j]
        diff = h_pred[i][j] - h_obs[i][j]
        loss += diff * diff
        n_obs += 1
      end
    end
  end
  return n_obs > 0 ? loss / n_obs : Inf
end


# 使用callback监控训练
function create_callback(nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask)
  cache = RichardsCache(length(h0))
  iter = Ref(0)

  function callback(p, l)
    iter[] += 1
    if iter[] % 10 == 0
      println("Iter $(iter[]): Loss = $(round(l, digits=6))")
    end
    return false
  end

  return callback, cache
end
