#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "5.1 ODE求解")

= 1 常微分方程（ODE）入门案例

在学习复杂的土壤热传输方程之前，我们需要先通过几个简单的生活案例来理解常微分方程（ODE）求解的基本思想。

这些案例的代码实现见 `ex01_ODE_intro.jl`。

== 1.1 案例 1：指数增长 (Exponential Growth)

这是最简单的 ODE，描述的是变化率与当前总量成正比的现象。

=== 1.1.1 物理背景
- *细菌繁殖*：细菌数量越多，繁殖出来的新细菌也越多。
- *银行复利*：本金越多，产生的利息也越多（假设利息不断滚入本金）。
- *放射性衰变*：(指数衰减) 剩下的原子核越少，衰变的数量也越少。

=== 1.1.2 数学模型
方程形式：
$ (d u)/(d t) = alpha dot u $

- $u(t)$：时刻 $t$ 的状态变量（如细菌数量）。
- $alpha$：增长率 (Growth Rate)。
  - $alpha > 0$：指数增长。
  - $alpha < 0$：指数衰减。

*解析解*：
$ u(t) = u_0 dot e^(alpha t) $

=== 1.1.3 代码实现点
在 Julia 中，我们需要定义一个函数 `f(du, u, p, t)` 来描述 $dv(u, t)$：

```julia
using OrdinaryDiffEq
using Plots
gr(framestyle=:box)

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
```

#figure(
  image("Figures/ex_ODE_intro_1.png", width: 70%),
  caption: [
    细菌繁殖示例。
  ],
) <fig_>

== 1.2 案例 2：阻尼振动 (Damped Oscillation)

这是一个二阶 ODE，描述物体在回复力和阻力作用下的往复运动。

=== 1.2.1 物理背景
- *弹簧振子*：拉开弹簧后松手，物体通过平衡位置来回震动，但幅度越来越小（受空气阻力等影响）。
- *钟摆*：类似原理。
- *汽车减震器*：利用阻尼迅速消耗振动能量。

=== 1.2.2 数学模型（推导过程）

这个方程来源于*牛顿第二定律* $F = m a$。

物体受到两个力：
1. *弹簧弹力*（胡克定律）：$F_"spring" = -k x$ （方向与位移相反）
2. *阻力*（与速度成正比）：$F_"drag" = -c v$ （方向与运动相反）

由 $m a = F_"total"$ 得：
$ m (d^2 x)/(d t^2) = -k x - c (d x)/(d t) $

移项并除以质量 $m$：
$ (d^2 x)/(d t^2) + c/m (d x)/(d t) + k/m x = 0 $

定义新参数以便于分析：
- 阻尼系数 $gamma equiv c \/ (2m)$
- 固有频率 $omega_0 equiv sqrt(k \/ m)$

代入即得*标准形式*：
$ (d^2 x)/(d t^2) + 2 gamma (d x)/(d t) + omega_0^2 x = 0 $

- $x(t)$：位移。
- $gamma$：阻尼系数 (Damping coefficient)。
- $omega_0$：固有频率。

*降阶技巧*：
数值求解器通常处理一阶 ODE 组。我们需要引入速度 $v = dv(x, t)$ 作为一个新的状态变量，将其转化为两个一阶方程：
1. $(d x)/(d t) = v$
2. $(d v)/(d t) = -2 gamma v - omega_0^2 x$

=== 1.2.3 代码实现点
状态变量是一个向量 `u = [x, v]`：
```julia
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
```

#figure(
  image("Figures/ex_ODE_intro_2.png", width: 70%),
  caption: [
    弹簧弹力ODE求解。
  ],
) <fig_>


== 1.3 案例 3：牛顿冷却定律 (Newton's Law of Cooling)

这个案例最接近我们要学的土壤温度问题，它描述了物体与环境的热交换。

=== 1.3.1 物理背景
- *热咖啡冷却*：一杯热咖啡放在室温下，温差越大，降温越快；随着温差减小，降温速度变慢。
- *物体散热*：正如第一节课所讲，感热通量 $H prop (T_s - T_a)$，热量传递的快慢取决于温差。

=== 1.3.2 数学模型
方程形式：
$ (d T)/(d t) = -k (T - T_"env") $

- $T(t)$：物体温度。
- $T_"env"$：环境温度（恒定）。
- $k$：冷却系数（取决于物体热容和表面散热能力）。

冷却系数 $k$ 的典型取值范围（单位：1/min）：
- 陶瓷杯中的咖啡：$0.02 - 0.05$（保温性较好）
- 玻璃杯中的咖啡：$0.05 - 0.1$（散热较快）
- 金属表面的散热片：$0.2 - 0.5$（极快）


*物理意义*：
温度的变化率 ($d T\/d t$) 与 温差 ($T - T_"env"$) 成正比。负号表示热量从高温流向低温。

=== 1.3.3 代码实现点
模拟一杯 80°C 的咖啡在 25°C 房间中的冷却过程：
```julia
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
```

#figure(
  image("Figures/ex_ODE_intro_3.png", width: 70%),
  caption: [
    牛顿冷却定律——咖啡冷却示例。
  ],
) <fig_>

== 1.4 总结

通过这三个案例，我们看到了 ODE 求解的通用模式：
1. *定义状态*：是标量（温度）还是向量（位置+速度）？
2. *描述变化率*：编写 `du = f(u, p, t)` 函数。
3. *设定初值*：$t=0$ 时系统处于什么状态？
4. *调用求解器*：`solve(prob)`。

接下来的土壤热传导方程，本质上就是把土壤分成了很多层（例如 100 层），每一层都遵循类似的能量平衡方程，形成了一个这就叫*离散化*的大型 ODE 系统。
