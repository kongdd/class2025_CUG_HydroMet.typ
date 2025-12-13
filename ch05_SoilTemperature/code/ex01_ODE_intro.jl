using OrdinaryDiffEq
using Plots
gr(framestyle=:box)

## 例1：最简单的ODE - 指数增长
# 问题：du/dt = α * u
# 物理意义：细菌繁殖、放射性衰变、银行利息
# 解析解：u(t) = u₀ * exp(α * t)

function exp_growth!(du, u, p, t)
  α = p[1]  # 增长率
  du[1] = α * u[1]
end

# 初始条件和参数
u0 = [1.0]        # 初始值
α = 0.5           # 增长率
tspan = (0.0, 5.0) # 时间范围

# 求解
prob1 = ODEProblem(exp_growth!, u0, tspan, [α])
sol1 = solve(prob1)

# 绘图
p1 = plot(sol1, label="Numerical", lw=2)
plot!(p1, t -> exp(α * t), 0, 5, label="Analytical", ls=:dash, lw=2)
title!(p1, "Exponential Growth: du/dt = αu")
xlabel!(p1, "Time t")
ylabel!(p1, "u(t)")

savefig("Figures/ex_ODE_intro_1.png")

## 例2：阻尼振动 - 二阶ODE
# 问题：d²x/dt² + 2γ dx/dt + ω₀² x = 0
# 物理意义：弹簧振子、钟摆、地震波
# 转换为一阶：令 v = dx/dt
#   dx/dt = v
#   dv/dt = -2γv - ω₀²x
function damped_oscillator!(du, u, p, t)
  γ, ω₀ = p
  x, v = u
  du[1] = v                    # dx/dt = v
  du[2] = -2γ * v - ω₀^2 * x  # dv/dt
end

# 参数设置
γ = 0.2   # 阻尼系数
ω₀ = 2.0  # 固有频率
u0_osc = [1.0, 0.0]  # 初始位置=1, 初始速度=0
tspan_osc = (0.0, 15.0)

# 求解
prob2 = ODEProblem(damped_oscillator!, u0_osc, tspan_osc, [γ, ω₀])
sol2 = solve(prob2)

# 绘图
p2 = plot(sol2, idxs=1, label="Position x(t)", lw=2)
plot!(p2, sol2, idxs=2, label="Velocity v(t)", lw=2, ls=:dash)
title!(p2, "Damped Oscillation")
xlabel!(p2, "Time t")
savefig("Figures/ex_ODE_intro_2.png")

## 例3：热传导方程的简化版本
# 问题：dT/dt = -k * (T - T_env)  牛顿冷却定律
# 物理意义：热咖啡冷却、铁块降温
# 解析解：T(t) = T_env + (T₀ - T_env) * exp(-k * t)

function newton_cooling!(du, u, p, t)
  k, T_env = p
  du[1] = -k * (u[1] - T_env)
end

# 参数：热咖啡从80°C冷却到室温25°C
T0 = 80.0     # 初始温度
T_env = 25.0  # 环境温度
k = 0.1       # 冷却系数

prob3 = ODEProblem(newton_cooling!, [T0], (0.0, 50.0), [k, T_env])
sol3 = solve(prob3)

# 绘图
p3 = plot(sol3, label="Coffee Temp", lw=2, color=:red)
hline!(p3, [T_env], label="Room Temp", ls=:dash, color=:blue)
title!(p3, "Newton Cooling Law")
xlabel!(p3, "Time (min)")
ylabel!(p3, "Temperature (C)")
savefig("Figures/ex_ODE_intro_3.png")

# 组合显示
plot(p1, p2, p3, layout=(1, 3), size=(1200, 350))
savefig("Figures/ex_ODE_intro.png")

println("ODE examples done! Saved to Figures/ex_ODE_intro.png")
