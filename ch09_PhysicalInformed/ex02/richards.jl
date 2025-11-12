"""
土壤水运动模型 - Lux.jl + Enzyme.jl 实现
基于Richards方程的简化形式,支持自动微分
"""

using Lux
using Random
using Enzyme
using ComponentArrays
using Optimization
using OptimizationOptimisers
using Statistics
using Plots

# ============================================================================
# 1. 土壤水力参数模型 (van Genuchten-Mualem)
# ============================================================================

"""van Genuchten 水分特征曲线"""
function van_genuchten_theta(h, θs, θr, α, n)
  m = 1 - 1 / n
  if h >= 0
    return θs
  else
    θ = θr + (θs - θr) / (1 + abs(α * h)^n)^m
    return θ
  end
end

"""van Genuchten 水力传导度"""
function van_genuchten_K(h, Ks, θs, θr, α, n)
  m = 1 - 1 / n
  if h >= 0
    return Ks
  else
    Se = ((1 + abs(α * h)^n)^(-m))
    K = Ks * Se^0.5 * (1 - (1 - Se^(1 / m))^m)^2
    return K
  end
end

# ============================================================================
# 2. Richards方程求解器 (简化的一维垂直流动)
# ============================================================================

"""
一维Richards方程求解 (隐式差分格式)
∂θ/∂t = ∂/∂z[K(h)(∂h/∂z + 1)]
"""
struct RichardsModel1D
  nz::Int           # 土层数
  dz::Float64       # 空间步长 (m)
  dt::Float64       # 时间步长 (s)
end

function solve_richards_step(model::RichardsModel1D, h_old, params, infiltration)
  (; nz, dz, dt) = model
  (; θs, θr, α, n, Ks) = params

  h_new = copy(h_old)

  # 简化的Picard迭代
  for iter in 1:5
    θ = [van_genuchten_theta(h_new[i], θs, θr, α, n) for i in 1:nz]
    K = [van_genuchten_K(h_new[i], Ks, θs, θr, α, n) for i in 1:nz]

    # 边界条件:上边界为入渗通量,下边界为自由排水
    for i in 2:nz-1
      K_up = (K[i-1] + K[i]) / 2
      K_down = (K[i] + K[i+1]) / 2

      flux_up = -K_up * ((h_new[i] - h_new[i-1]) / dz + 1)
      flux_down = -K_down * ((h_new[i+1] - h_new[i]) / dz + 1)

      dθ_dt = (flux_up - flux_down) / dz

      # 水分容量
      C = (θ[i] - van_genuchten_theta(h_old[i], θs, θr, α, n)) /
          (h_new[i] - h_old[i] + 1e-6)

      h_new[i] = h_old[i] + dt * dθ_dt / (C + 1e-6)
    end

    # 上边界 (入渗)
    K_surf = K[1]
    flux_in = min(infiltration, Ks)  # 限制最大入渗率
    h_new[1] = h_new[2] - (flux_in / K_surf - 1) * dz

    # 下边界 (自由排水)
    h_new[nz] = h_new[nz-1] - dz
  end

  return h_new
end

# ============================================================================
# 3. 混合物理-神经网络模型 (Lux)
# ============================================================================

"""
物理信息神经网络修正项
用于修正Richards方程在深层土壤的偏差
"""
function create_correction_network()
  return Chain(
    Dense(3 => 16, tanh),    # 输入: h, z, θ
    Dense(16 => 16, tanh),
    Dense(16 => 1)           # 输出: 修正通量
  )
end

"""
完整的混合模型
"""
struct HybridSoilWaterModel
  richards::RichardsModel1D
  correction_net::Lux.AbstractLuxLayer
end

function (model::HybridSoilWaterModel)(x, params, st)
  # x: (h_old, infiltration, z_coords)
  h_old, infiltration, z_coords = x

  # 物理模型预测
  soil_params = (
    θs=params.physics.θs,
    θr=params.physics.θr,
    α=params.physics.α,
    n=params.physics.n,
    Ks=params.physics.Ks
  )

  h_physics = solve_richards_step(model.richards, h_old, soil_params, infiltration)

  # 神经网络修正 (针对每一层)
  θ_physics = [van_genuchten_theta(h_physics[i], soil_params.θs, soil_params.θr,
    soil_params.α, soil_params.n)
               for i in 1:model.richards.nz]

  corrections = zeros(model.richards.nz)
  for i in 1:model.richards.nz
    nn_input = [h_physics[i], z_coords[i], θ_physics[i]]
    corr, st = model.correction_net(nn_input, params.neural, st)
    corrections[i] = corr[1]
  end

  # 混合输出
  h_hybrid = h_physics .+ corrections .* 0.01  # 小幅修正

  return h_hybrid, st
end

# ============================================================================
# 4. 训练设置
# ============================================================================

function create_hybrid_model()
  # Richards模型设置
  nz = 20           # 20层土壤
  depth = 2.0       # 总深度2米
  dz = depth / nz
  dt = 3600.0       # 时间步长1小时

  richards = RichardsModel1D(nz, dz, dt)
  correction_net = create_correction_network()

  return HybridSoilWaterModel(richards, correction_net)
end

function initialize_parameters(model::HybridSoilWaterModel, rng::AbstractRNG)
  # 神经网络参数
  z_dummy = randn(rng, Float32, 3)
  params_neural, state = Lux.setup(rng, model.correction_net)

  # 物理参数 (可学习或固定)
  params_physics = (
    θs=0.45,    # 饱和含水量
    θr=0.05,    # 残余含水量
    α=2.0,      # van Genuchten参数
    n=1.5,      # van Genuchten参数
    Ks=1e-5     # 饱和导水率 (m/s)
  )

  params = ComponentArray(
    neural=params_neural,
    physics=params_physics
  )

  return params, state
end

"""损失函数: 与观测含水量的均方误差"""
function loss_function(model, params, state, data)
  h_init, infiltration, z_coords, θ_obs = data

  h_pred, state = model((h_init, infiltration, z_coords), params, state)

  # 计算预测含水量
  θ_pred = [van_genuchten_theta(h_pred[i], params.physics.θs, params.physics.θr,
    params.physics.α, params.physics.n)
            for i in 1:length(h_pred)]

  # MSE损失
  loss = mean((θ_pred .- θ_obs) .^ 2)

  # 物理约束: 含水量应在合理范围内
  constraint = sum(max.(0, θ_pred .- params.physics.θs) .^ 2) +
               sum(max.(0, params.physics.θr .- θ_pred) .^ 2)

  return loss + 0.1 * constraint, state
end

# ============================================================================
# 5. 示例: 生成模拟数据并训练
# ============================================================================

function generate_synthetic_data(nz, nsteps=10)
  """生成合成观测数据"""
  depth = 2.0
  dz = depth / nz
  z_coords = [i * dz for i in 1:nz]

  # 初始压力水头 (较干)
  h_init = [-2.0 - i * 0.1 for i in 1:nz]

  # 降雨入渗率序列
  infiltration_series = [5e-6 * (1 + 0.5 * sin(2π * t / nsteps)) for t in 1:nsteps]

  # 使用"真实"物理模型生成观测
  true_params = (θs=0.45, θr=0.05, α=2.0, n=1.5, Ks=1e-5)
  richards_true = RichardsModel1D(nz, dz, 3600.0)

  θ_obs_series = []
  h_current = copy(h_init)

  for infiltration in infiltration_series
    h_current = solve_richards_step(richards_true, h_current, true_params, infiltration)
    θ_obs = [van_genuchten_theta(h_current[i], true_params.θs, true_params.θr,
      true_params.α, true_params.n) for i in 1:nz]
    push!(θ_obs_series, θ_obs)
  end

  return h_init, z_coords, infiltration_series, θ_obs_series
end

function main()
  println("=== 土壤水运动模拟: Lux + Enzyme ===\n")

  # 初始化
  rng = Random.default_rng()
  Random.seed!(rng, 123)

  model = create_hybrid_model()
  params, state = initialize_parameters(model, rng)

  println("模型结构:")
  println("  - 土层数: ", model.richards.nz)
  println("  - 空间步长: ", model.richards.dz, " m")
  println("  - 时间步长: ", model.richards.dt, " s")
  println("  - 神经网络参数数: ", Lux.parameterlength(model.correction_net))

  # 生成训练数据
  println("\n生成合成观测数据...")
  h_init, z_coords, infiltration_series, θ_obs_series = generate_synthetic_data(model.richards.nz)

  # 测试前向传播
  println("\n测试前向传播...")
  h_pred, state = model((h_init, infiltration_series[1], z_coords), params, state)
  println("  预测压力水头范围: [", minimum(h_pred), ", ", maximum(h_pred), "]")

  # 测试损失计算
  println("\n测试损失函数...")
  data = (h_init, infiltration_series[1], z_coords, θ_obs_series[1])
  loss_val, state = loss_function(model, params, state, data)
  println("  初始损失: ", loss_val)

  println("\n✓ 模型构建成功!")
  println("\n提示: 可以使用Optimization.jl进行训练")
  println("     或使用Enzyme.jl计算梯度进行自定义优化")

  return model, params, state, (h_init, z_coords, infiltration_series, θ_obs_series)
end

# 运行示例
model, params, state, data = main()
