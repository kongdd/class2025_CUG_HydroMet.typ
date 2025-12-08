// #import "./typst/lib.typ": *
// #import "@preview/modern-cug-report:0.3.0": *
#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, size: 12.5pt, footer: "CUG水文气象学2025", header: "第五章 土壤热通量")

#counter(heading).update(4)
#let delta(x) = $Delta #x$
// #show math.equation: set text(11pt)

#let kappa-coef(i) = {
  // let p = $i+1/2$
  $kappa_#i / delta(z_#i)$
}

// =
// =
// =
// =
= 5 土壤热通量

#figure(
  image("Figures/了解温度吗.png", width: 70%),
  caption: [
    真的了解温度吗？
  ],
) <fig_>

#beamer-block()[本章理论主要参考#cite(<bonan2019climate>, form: "prose") chapter 5。]

#box-blue([
  *本章学习目标*

  1. 理解土壤热通量的物理意义——热量在土壤中如何传递
  2. 掌握热传导方程的基本形式及其推导过程
  3. 了解土壤热参数（热传导系数$kappa$、热容量$c_v$）的物理意义
  4. 学会使用数值方法求解土壤温度的时空演变
  5. 能够使用Julia编程实现简单的土壤温度模拟
])

#box-green([
  *应用案例*

  - *城市热岛效应*：城市地表（水泥、沥青）与自然地表热参数差异巨大，导致温度差异
  - *农业气象*：土壤温度影响种子萌发、根系生长、养分吸收
  - *冻土研究*：全球变暖背景下，多年冻土的消融释放大量温室气体
  - *建筑节能*：地源热泵利用土壤恒温特性进行供暖和制冷
  - *考古勘探*：利用地表温度异常探测地下遗址
])

#box-red([
  *为何要研究土壤热通量？*

  日内尺度，土壤温度$T_s$变化剧烈，根据玻尔兹曼定律，$T_s$变化会引起地表净辐射$R_n$的变化，影响地表能量平衡和水量平衡。

  1. 若想准确模拟陆表能量平衡（$lambda H$和$lambda E$）和水量平衡（$E$）过程，需要清楚土壤温度是如何变化的。

  2. 厘清土壤温度与空气温度之间的关系，可应用于城市热岛研究，边界层研究，例如城市、水体对周边区域空气温度的影响。基于式#[@eq_5.2]，已知土壤温度，可求解空气温度。
])

如下图所示，表层的土壤温度变化非常剧烈，地表的土壤温度TS_0日内变化幅度甚至超过了空气温度，在空气温度为30℃时，地表温度甚至可以达到50℃。与之形成鲜明对比，深层土壤温度变化非常缓慢，40cm以下的土壤温度几乎看不到日内波动，80cm以下的土壤温度在图中几乎是一条直线。

#box-green([
  *生活中的土壤温度体验*

  - *夏天赤脚走在沙滩上*：中午沙子烫脚（表层$T_s > 50°C$），但挖下去10cm就会凉爽很多
  - *地窖储藏*：古人利用地下温度恒定的特点储存蔬菜水果，夏凉冬暖
  - *地铁隧道*：地下铁路冬天不需要供暖，因为深层土壤温度接近年均温（武汉约16-17°C）
  - *农谚*："清明前后，种瓜点豆"——此时地温适宜种子萌发
])

#figure(
  image("Figures/Figure_CUG_Tsoil_202306.svg", width: 100%),
  caption: [中国地质大学（武汉）大气系气象观测站2023年6月逐小时土壤温度。

    其中黑线为空气温度。
  ],
) <fig_CUG_Tsoil>


基于能量平衡公式和净辐射公式，可知：

$
  cases(
    R_n - G = lambda E + H,
    R_n = R"ns" + R"nl" = (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4
  )
$

代入$G$, $H$, $lambda E$的公式，可得：

$
  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p delta(e)) / (gamma r_v) + (rho c_p delta(T)) / r_H \
  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p (e_"surf" - e) ) / (gamma r_v) + (rho c_p (T_s - T_a)) / r_H
$ <eq_5.2>

- $kappa$: 热传导系数，$"W"\/m^2\/K$
- $R_n$: 净辐射，MJ
- $lambda$: 汽化潜热，2.5 MJ / kg
- $gamma$：湿度计常数，kPa / K
- $rho$: 空气密度，$"kg"\/m^3$
- $r_v$, $r_H$：分别是水汽和热量的传导阻力，$s\/m$。
- $T_s$：地表温度，℃
- $T_a$：空气温度，℃
- $e_"surf"$：蒸发面的水汽压，kPa
- $e$：空气水汽压，kPa
- $T_1$：第一层土壤的温度，℃
- $delta(z)$: 第一层土壤的厚度，m



== 5.1 基本原理

土壤热通量的研究基于两个核心物理定律：*傅里叶热传导定律*和*能量守恒定律*。

#box-blue([
  *类比理解*：热量在土壤中的传递类似于水在坡面上的流动

  - 水从*高处*流向*低处*，热量从*高温*传向*低温*
  - 坡度越陡（温度梯度越大），水流越快（热通量越大）
  - 土壤质地影响传热速度，就像土壤质地影响渗水速度
])

#figure(
  image("Figures/土壤热通量_连续性原理.png", width: 100%),
  caption: [
    （a）土壤通量与土壤温度连续性原理示意图；（b）土壤分层说明。
    $z_i$代表的是每一层土壤的中间位置；$z_(i+1/2)$代表的是每层土壤的下边界。$z$与$F$均是向下为负。
  ],
) <fig_Tsoil_cont>

// #pagebreak()

*热通量公式：*

$ F = - kappa pdv(T, z) $

- $kappa$: 热传导系数，$"W"\/m\/K$；
- $F$: 土壤热通量，$"W"\/m^2$；
- 负号代表土壤热通量向下为负。

*连续性原理：*

$ rho c_v^\* delta(x) delta(y) delta(z) delta(T) = -(F_"in" - F_"out") delta(x) delta(y) delta(t) $

$ c_v delta(T) / delta(t) = - delta(F) / delta(z), c_v = rho c_v^\* $ <eq_5.5>

其中，$c_v$是体积热容量（volumetric heat capacity，$J m^(-3)s^(-1)$)，是比热容与密度的乘积。式#[@eq_5.5]写成偏微分形式，则是：

$ c_v pdv(T, t) = - pdv(F, z) = kappa pdv(T, z, 2) $ <eq_heat>


#figure(
  image("Figures/土壤热通量-土壤结构.png", width: 54%),
  caption: [
    每层的土壤状态与土壤热通量。
  ],
) <fig_Tsoil_cont>


#figure(
  caption: [土壤热通量参数。数据源于de Vries (1963)。],
  table(
    columns: (3.2cm, 5.5cm, 5.4cm),
    // inset: 10pt,
    align: (left, center, center),
    table.header(
      [*Type*], [Thermal conductivity ($kappa$) \ $W m^(-1) K^(-1)$], [Heat capacity ($c_v$) \ $"MJ" m^(-3) K^(-1)$]
    ),
    [Quartz], [8.80], [2.12],
    [Clay minerals], [2.92], [2.44],
    [Organic matter], [0.25], [2.50],
    [Liquid water], [0.57], [4.19],
    [Ice], [2.18], [1.88],
    [Air], [0.025], [0.0012],
  ),
)

// #pagebreak()

== 5.2 数值求解——复杂版 三角矩阵

#highlight()[如何求解土壤温度随时间的变化？] 主要用的是1个核心公式，式@eq_heat。

== 5.3 数值求解——简易版 偏微分方程

=== 5.3.1 偏微分基础

解决诸如此类问题：

$
  (d u) / (d t) = f(u, p, t)
$

- u：要求解的状态变量；
- p：参数；
- t：时间。

*5行代码求解偏微分方程：*
```julia
using DifferentialEquations

f(u, p, t) = 1.01 * u
u0 = 1 / 2
tspan = (0.0, 1.0)
prob = ODEProblem(f, u0, tspan)
sol = solve(prob, Tsit5(), reltol = 1e-8, abstol = 1e-8)
```

绘图展示结果：

```julia
using Plots
plot(sol, linewidth = 5, title = "Solution to the linear ODE with a thick line",
    xaxis = "Time (t)", yaxis = "u(t) (in μm)",
    label = "My Thick Line!") # legend=false
plot!(sol.t, t -> 0.5 * exp(1.01t), lw = 3, ls = :dash, label = "True Solution!")
```

#figure(
  image("Figures/ex_ODE_01.png", width: 70%),
  caption: [
    ODE求解示例1。
  ],
) <fig_>

#bibliography("References.bib", title: "参考文献", style: "gb-7714-2015-author-date")
