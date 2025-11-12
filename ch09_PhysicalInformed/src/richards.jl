using DifferentialEquations, DiffEqFlux, Lux, Optimization, OptimizationOptimisers
using ComponentArrays, Random, LinearAlgebra, StaticArrays, Zygote, Enzyme
using SciMLSensitivity, SciMLStructures # 必须显式导入以使用 InterpolatingAdjoint
using Parameters

# Van Genuchten参数化 - 使用不可变结构提高性能
@with_kw struct VanGenuchten{T}
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
@with_kw mutable struct Soil{T}
  dz::Vector{T}
  K::Vector{T}
  C::Vector{T}
  K_half::Vector{T}
  q::Vector{T}
  nn_input::Vector{T}
end

function Soil(dz::Vector{T}) where {T<:Real}
  n_layers::Int = length(dz)
  Soil(
    dz,
    zeros(T, n_layers),
    zeros(T, n_layers),
    zeros(T, n_layers + 1),
    zeros(T, n_layers + 1),
    zeros(T, n_layers + 2)
  )
end

# 优化的Richards方程 - 使用符合SciMLStructures的参数结构
function create_richards_ode(nn, st, soil::Soil, vg, rain_interp)

  function ode!(du, u, p_nn, t)  # p_nn 是唯一的可调参数
    (; K, C, K_half, q, nn_input, dz) = soil
    n_layers = length(u)

    # 获取降水
    rain = rain_interp(t)

    # 批量计算水力性质
    @inbounds for i in 1:n_layers
      _, K[i], C[i] = hydraulic_props(u[i], vg)
    end

    # 界面导水率 - 调和平均
    K_half[1] = K[1]
    @inbounds for i in 2:n_layers
      K_half[i] = 2.0 / (1.0 / K[i-1] + 1.0 / K[i])
    end
    K_half[n_layers+1] = K[n_layers]
    # 通量计算
    q[1] = rain
    inv_dz = 1.0 / dz
    @inbounds for i in 2:n_layers
      q[i] = -K_half[i] * ((u[i] - u[i-1]) * inv_dz + 1.0)
    end
    q[n_layers+1] = -K_half[n_layers+1]

    # Richards方程
    @inbounds for i in 1:n_layers
      du[i] = -(q[i+1] - q[i]) * inv_dz / C[i]
    end

    # 神经网络修正 - 重用缓存
    @inbounds for i in 1:n_layers
      soil.nn_input[i] = u[i]
    end
    nn_input[n_layers+1] = t
    nn_input[n_layers+2] = rain

    nn_out, _ = nn(nn_input, p_nn, st)
    @inbounds for i in 1:n_layers
      du[i] += nn_out[i]
    end
    nothing
  end
  return ode!
end


# 批量模拟 - 使用Zygote.Buffer避免mutation错误
function simulate_batch(nn, p_nn, st, vg, dz, h0, times, rain_values;
  soil=nothing, solver=Tsit5())
  isnothing(soil) && (soil = Soil(dz))

  rain_interp = RainInterp(times, rain_values)
  ode_fn = create_richards_ode(nn, st, soil, vg, rain_interp)

  # 使用Zygote.Buffer - 可微分的可变数组
  h_all = Zygote.Buffer(Vector{Vector{Float64}}(undef, length(times)))
  h_all[1] = h0
  current_h = h0

  # 逐步求解
  for i in 1:(length(times)-1)
    tspan = (times[i], times[i+1])
    prob = ODEProblem(ode_fn, current_h, tspan, p_nn)
    sol = solve(prob, solver,
      save_everystep=false,
      saveat=[times[i+1]],
      abstol=1e-6,
      reltol=1e-4,
      # 显式指定 sensealg 以避免 AD 失败警告
      # 选项 1（推荐）：使用 ZygoteVJP
      # sensealg=InterpolatingAdjoint(autojacvec=ZygoteVJP()),
      sensealg=InterpolatingAdjoint(autojacvec=EnzymeVJP()),
      # 选项 2（如果上面失败）：使用 ForwardDiff（对小系统更稳定）
      # sensealg=InterpolatingAdjoint(autojacvec=false),
      # 选项 3（如果都失败）：使用 QuadratureAdjoint
      # sensealg=QuadratureAdjoint(autojacvec=ZygoteVJP()),
      verbose=false)  # 关闭警告

    current_h = sol.retcode == ReturnCode.Success ? sol.u[end] : current_h
    h_all[i+1] = current_h
  end

  return copy(h_all)  # 转换为普通数组
end

# 向量化损失函数 - 确保参数是Tunable
function loss_batch(p_nn, nn, st, vg, dz, h0, times, rain_values,
  h_obs, obs_mask; soil=nothing)

  # 使用 Lux.apply 并传递正确的参数
  h_pred = simulate_batch(nn, p_nn, st, vg, dz, h0, times, rain_values;
    soil=soil)

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

# 创建优化函数 - 修复参数签名
function make_loss(nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask, soil_train)
  function loss_fn(p, _)  # Optimization.jl 需要 (p, _) 签名
    try
      return loss_batch(p, nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask; soil=soil_train)
    catch e
      @warn "Loss computation failed: $e"
      return 1e10
    end
  end
  return loss_fn
end

# 使用callback监控训练
function create_callback(nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask)
  soil = Soil(length(h0))
  iter = Ref(0)

  function callback(p, l)
    iter[] += 1
    # if iter[] % 10 == 0
    println("Iter $(iter[]): Loss = $(round(l, digits=6))")
    # end
    return false
  end

  return callback, soil
end
