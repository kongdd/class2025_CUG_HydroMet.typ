using DifferentialEquations, Lux, Random

# 引入原始文件的结构定义
include("dl_richards.jl")

println("=== 测试 create_richards_ode ===\n")

# 1. 设置基本参数
n_layers = 5  # 简化为5层
dz = 20.0     # 层厚度 (cm)
vg = VanGenuchten(0.045, 0.43, 0.145, 2.68, 29.7)  # Van Genuchten 参数

# 2. 创建简单的神经网络
println("创建神经网络...")
nn = Lux.Chain(
    Lux.Dense(n_layers + 2 => 8, tanh),
    Lux.Dense(8 => n_layers)
)

rng = Random.default_rng()
ps, st = Lux.setup(rng, nn)

println("✓ 神经网络创建成功")
println("  输入维度: $(n_layers + 2)")
println("  输出维度: $(n_layers)")

# 3. 创建缓存
println("\n创建缓存...")
cache = Soil(n_layers)
println("✓ 缓存创建成功")

# 4. 创建降水数据（简单的常数降水）
println("\n创建降水数据...")
times = Float64[0, 1, 2, 3]
rain_values = Float64[1.0, 0.5, 0.2, 0.0]
rain_interp = RainInterp(times, rain_values)

# 测试插值
println("✓ 降水插值创建成功")
println("  t=0.0: rain = $(rain_interp(0.0)) cm/h")
println("  t=0.5: rain = $(rain_interp(0.5)) cm/h")
println("  t=1.0: rain = $(rain_interp(1.0)) cm/h")

# 5. 创建 ODE 函数
println("\n创建 Richards ODE 函数...")
ode_fn = create_richards_ode(nn, st, cache)
println("✓ ODE 函数创建成功")

# 6. 测试 ODE 函数能否运行
println("\n测试 ODE 函数...")
h0 = fill(-50.0, n_layers)  # 初始压力水头 (cm)
du = zeros(n_layers)
t = 0.0
p = (vg, dz, rain_interp, ps)

try
    ode_fn(du, h0, p, t)
    println("✓ ODE 函数计算成功")
    println("  du/dt 前3层: ", round.(du[1:min(3, n_layers)], digits=4))
catch e
    println("✗ ODE 函数计算失败: $e")
    return
end

# 7. 测试完整的 ODE 求解
println("\n测试完整 ODE 求解...")
tspan = (0.0, 1.0)
prob = ODEProblem(ode_fn, h0, tspan, p)

try
    sol = solve(prob, Tsit5(),
                saveat=[0.0, 0.5, 1.0],
                abstol=1e-6,
                reltol=1e-4)

    if sol.retcode == ReturnCode.Success
        println("✓ ODE 求解成功")
        println("  初始状态 h(0): ", round.(sol.u[1][1:3], digits=2), " cm")
        println("  终态状态 h(1): ", round.(sol.u[end][1:3], digits=2), " cm")
    else
        println("✗ ODE 求解失败，返回码: $(sol.retcode)")
    end
catch e
    println("✗ ODE 求解出错: $e")
    rethrow(e)
end

println("\n=== 测试完成 ===")
