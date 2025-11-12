using DifferentialEquations, DiffEqFlux, Lux, Optimization, OptimizationOptimisers
using ComponentArrays, Random, LinearAlgebra, StaticArrays

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

# 优化的Richards方程
function create_richards_ode(nn, st, cache::RichardsCache)
  function ode!(du, u, p, t)
    vg, dz, rain_interp, p_nn = p
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
    prob = ODEProblem(ode_fn, current_h, tspan,
      (vg, dz, rain_interp, p_nn))
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

# 向量化损失函数
function loss_batch(p_nn, nn, st, vg, dz, h0, times, rain_values,
  h_obs, obs_mask; cache=nothing)
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

# 主程序
Random.seed!(123)

# 配置
n_layers = 10
depth = 100.0
dz = depth / n_layers
vg = VanGenuchten(0.045, 0.43, 0.145, 2.68, 29.7)

# 更简单的网络结构 - 减少参数
nn = Lux.Chain(
  Lux.Dense(n_layers + 2 => 16, tanh),
  Lux.Dense(16 => n_layers; use_bias=false)  # 无偏置减少参数
)

rng = Random.default_rng()
ps, st = Lux.setup(rng, nn)

# 使用更少的参数初始化
p_nn = ComponentArray(ps) .* 0.1  # 小初始值

# 数据
times = Float64[0, 1, 2, 4, 8, 12, 24]
rain_values = Float64[2, 1.5, 0.5, 0, 0, 0.1, 0]
h0 = fill(-50.0, n_layers)

# 生成观测 - 使用缓存
println("生成数据...")
cache = RichardsCache(n_layers)
p_nn_zero = ComponentArray(ps) .* 0
h_true = simulate_batch(nn, p_nn_zero, st, vg, dz, h0, times, rain_values;
  cache=cache)

# 添加噪声
h_obs = deepcopy(h_true)
obs_mask = trues(length(times), n_layers)

for i in 2:length(times)
  h_obs[i] .+= 0.5 * randn(n_layers)
  obs_mask[i, 6:8] .= false
end

# 训练
println("训练模型...")
callback, cache_train = create_callback(nn, st, vg, dz, h0, times, rain_values,
  h_obs, obs_mask)

opt_fn = OptimizationFunction(
  (p, _) -> loss_batch(p, nn, st, vg, dz, h0, times, rain_values,
    h_obs, obs_mask; cache=cache_train),
  Optimization.AutoZygote()  # 使用Zygote自动微分
)

opt_prob = OptimizationProblem(opt_fn, p_nn)

# AdamW with weight decay
opt_sol = solve(opt_prob, AdamW(0.01, (0.9, 0.999), 1e-4),
  callback=callback, maxiters=100)

println("\n最终损失: $(round(opt_sol.objective, digits=6))")

# 评估
h_pred = simulate_batch(nn, opt_sol.u, st, vg, dz, h0, times, rain_values;
  cache=cache)

# 简洁输出
println("\n预测结果 (压力水头 cm):")
println("时间(h) | 层1    | 层5    | 层10")
println("--------|--------|--------|--------")
for (i, t) in enumerate(times)
  @printf("%7.1f | %6.2f | %6.2f | %6.2f\n",
    t, h_pred[i][1], h_pred[i][5], h_pred[i][10])
end

# 计算R²
function r_squared(pred, obs, mask)
  y_pred = Float64[]
  y_true = Float64[]
  for i in 1:length(pred)
    for j in 1:length(pred[i])
      if mask[i, j]
        push!(y_pred, pred[i][j])
        push!(y_true, obs[i][j])
      end
    end
  end

  ss_res = sum((y_true .- y_pred) .^ 2)
  ss_tot = sum((y_true .- mean(y_true)) .^ 2)
  return 1 - ss_res / ss_tot
end

r2 = r_squared(h_pred, h_obs, obs_mask)
println("\nR² = $(round(r2, digits=4))")
