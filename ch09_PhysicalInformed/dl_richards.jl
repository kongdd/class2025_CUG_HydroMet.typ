include("src/richards.jl")
include("src/gof.jl")

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

h_true = simulate_batch(nn, p_nn_zero, st, vg, dz, h0, times, rain_values; cache)

# 添加噪声
h_obs = deepcopy(h_true)
obs_mask = trues(length(times), n_layers)

for i in 2:length(times)
  h_obs[i] .+= 0.5 * randn(n_layers)
  obs_mask[i, 6:8] .= false
end

# 训练
println("训练模型...")
callback, cache_train = create_callback(nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask)

# 创建优化函数 - 修复参数签名
function make_loss(nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask, cache_train)
  function loss_fn(p, _)  # Optimization.jl 需要 (p, _) 签名
    try
      return loss_batch(p, nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask; cache=cache_train)
    catch e
      @warn "Loss computation failed: $e"
      return 1e10
    end
  end
  return loss_fn
end

loss_fn = make_loss(nn, st, vg, dz, h0, times, rain_values, h_obs, obs_mask, cache_train)

opt_fn = OptimizationFunction(
  loss_fn,
  Optimization.AutoZygote()  # 使用Zygote自动微分
)

opt_prob = OptimizationProblem(opt_fn, ComponentArray(ps))

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

r2 = r_squared(h_pred, h_obs, obs_mask)
println("\nR² = $(round(r2, digits=4))")
