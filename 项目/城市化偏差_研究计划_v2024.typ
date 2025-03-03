// #import "@preview/modern-cug-report:0.1.0": *
#import "../typst/lib.typ": *
#counter(heading).update(0)
#show: (doc) => template(doc, 
  size: 13pt,
  footer: "",
  header: "项目研究计划")
#show math.equation: set text(12pt)
// #show: p-indent
// #set par(
//   leading: 1em,
//   spacing: 1.24em, 
// )
#let delta(x) = $Delta #x$

// = 研究计划
= 研究背景

// === 观测频次偏差
// === 城市化偏差
#v(0.3em)

#figure(
  image("../images/土壤热通量/ls9_地表温度.jpg", width: 70%),
  caption: [
    基于Landsat 9卫星的武汉市2023年夏季平均地表温度。\
    https://code.earthengine.google.com/15e4ea013ba99ec9ed67145be670c0d8。\
    #v(0.3em)
  ]
) <fig_ls9_Tsoil>


*如何精准识别城市热岛效应，是矫正城市化偏差的关键。*

在城市热岛研究中，受限于有限的气象观测站点，无法得出精细化的结果。武汉市为例，能够公开获取的气象观测站只有6个站点。难以剥离出城市、水体、植被绿化对城市空气温度的影响。

遥感地温数据为城市热岛研究提供了新的机遇。通过遥感手段，可获取30m分辨率的地温数据。如图 #[@fig_ls9_Tsoil] 所示，基于Landsat 9卫星的武汉市地温数据，可清楚看到城市不透水界面、江河湖泊对地表温度的影响，长江武汉段7条大桥也清晰显现。

#p-full[*如何基于地温数据反演城市热岛效应？*]


城市与郊区，由于下垫面不同，比热容、反射率、吸收率不同，导致地表吸收辐射的效率、以及升温的速率，存在明显差异，因此无法直接通过地表温度的对比分离城市热岛效应。#highlight()[但如若是相同下垫面、相同辐射输入驱动下，地表温度不同，可归结于城市热岛效应对空气温度和空气湿度的影响。]

基于上述假设，针对城市与郊区相同类型的下垫面（如草地、森林），可构建地表通量模型，从地温数据中分离出30m空间分辨率的城市热岛效应。基于分离出的城市热岛效应，可识别城市热岛的衰减曲线，包括城市热岛强度、城市热岛影响范围。基于城市热岛衰减曲线，最终矫正城市化偏差。

= 研究内容

1. *观测频次偏差。*构建地表通量模型，刻画地温和气温之间的关系。借助地表通量模型，以气候态辐射通量为输入，分离感热、潜热、土壤热通量，*量化气温的日内变化理论曲线*，评估不同观测频次（如日内最高最低气温观测、日内4次观测、逐小时观测）对日平均气温的影响。

  #beamer-block([
    这方面具有非常好的基础。潜热方面（蒸散发），多年持续攻坚，发展了多个蒸散发模型；土壤热通量方面，刚写通模型，简单的方法实现了较高的精度。
  ])

2. *城市化偏差。* 如何精准识别城市热岛效应，是矫正城市化偏差的关键。针对城市与郊区相同类型的下垫面（如草地、森林），可构建地表通量模型，从地温数据中分离出30m空间分辨率的城市热岛效应。基于分离出的城市热岛效应，可识别城市热岛的衰减曲线，包括城市热岛强度、城市热岛影响范围。基于城市热岛衰减曲线，最终矫正城市化偏差。

  #beamer-block([
    观测频次偏差和城市化偏差，可共用相同的模型——地表通量模型。因此，模型研发，可一举两得。
  ])
// 城市化偏差，也即是城市不透水界面对气温的影响，以及不透水界面的聚集引起的城市热岛效应。
// 精细化城市热岛效应。

= 研究方案

== 地表通量模型

基于能量平衡公式和净辐射公式，可知：

$ cases(
    R_n - G = lambda E + H,
    R_n = R"ns" + R"nl" = (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4
) $

代入$G$, $H$, $lambda E$的表达式，可得：

$
  // (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p delta(e)) / (gamma r_v) + (rho c_p delta(T)) / r_H \
  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p (e_"surf" - e) ) / (gamma (r_v + r_c)) + (rho c_p (T_s - T_a)) / r_H
$ <eq_Rn_balance>

- $T_s$：地表温度，℃； $T_1$：第一层土壤的温度，℃；$T_a$：空气温度，℃；
- $e_"surf"$：蒸发面的水汽压，kPa；$e$：空气水汽压，kPa；
- $kappa$: 热传导系数，$"W"\/m^2\/K$；$rho$: 空气密度，$"kg"\/m^3$；
- $R_n$: 净辐射，MJ；$"Rln"$为入射长波辐射，MJ；
- $lambda$: 汽化潜热，2.5 MJ / kg； $gamma$：湿度计常数，kPa / K
- $r_v$, $r_H$：分别是大气边界层对水汽和热量的传导阻力，$s\/m$；$r_c$是冠层的水汽传导阻力；
- $delta(z)$: 第一层土壤的厚度，m。

根据Monin–Obukhov相似理论，可采用相同的函数来描述热量和水汽的垂直梯度分布，认为$r_v = r_H = r_a$，其中$r_a$为空气动力学阻力。
并将式#[@eq_Rn_balance]中的变量移到左边，令$Q_a = (1 - alpha) R_s + epsilon"Rln"$，可得到：

$ Q_a = epsilon sigma T_s^4 + kappa / delta(z) (T_s - T_1) + (rho c_p (e_"surf" - e) ) / (gamma (r_a + r_c)) + (rho c_p (T_s - T_a)) / r_a $ <eq_3.3>

上式为构建$T_s$和$T_a$之间的关系，提供了理论基础。但该式1个方程，3个未知量（$T_s$, $T_1$, $T_a$）。求解存在如下难点：

#p-full[
（1）地表温度$T_s$和第一层土壤温度$T_1$存在相互影响关系，$T_s$与$T_1$决定了进入第一层土壤的热通量，热通量反过来又影响该层的土壤温度。为解决该问题，$T_s$和$T_a$在求解过程中，需要和土壤热通量进行联立求解。

（2）$r_a$是一个Obukhov长度的复杂函数，需要和感热、潜热循环迭代进行求解。
具体变量与函数说明请参阅#cite(<bonan2019climate>, form: "prose")章节6.6。
]

#mitex(`$$
\[
\frac{1}{r_a} = g_{ac}(z) = \rho_m k^2 u(z) 
\left[ \ln\!\left(\frac{z - d}{z_{0m}}\right) - \psi_m(\zeta) + \psi_m\!\left(\frac{z_{0m}}{L_{MO}}\right) \right]^{-1} \\
\left[ \ln\!\left(\frac{z - d}{z_{0c}}\right) - \psi_c(\zeta) + \psi_c\!\left(\frac{z_{0c}}{L_{MO}}\right) \right]^{-1}
\]
$$`)

式#[@eq_3.3]，存在两种求解方法：牛顿梯度降和三角矩阵法。

=== 牛顿梯度降

// #p-full[*1. 牛顿梯度降* ]


$ f(T_s) = Q_a - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) - (rho c_p (e_"surf" - e) ) / (gamma r_v) - (rho c_p (T_s - T_a)) / r_H = 0 $

土壤有一个表皮温度$T_s$（skin temperature），表皮温度与第一层土壤的平均温度，有所不同。牛顿梯度降迭代过程中，土壤温度按照如下公式进行更新。

$ T_(s, "next") = T_s - f(T_s) / pdv(f, T_s) $

=== 三角矩阵法

// #p-full[*2. 三角矩阵法* ]

当第一层土壤足够薄，可认为$T_1 = T_s$，此时土壤热通量不能再采用$kappa / delta(z)$的形式，采用符号F0来进行代替。

$ F_0 = f(T_1) = Q_a - epsilon sigma T_s^4 - (rho c_p (e_"surf" - e) ) / (gamma r_v) - (rho c_p (T_1 - T_a)) / r_H $

F0求$T_s$的偏导，可得：

$
  pdv(F_0, T_s) = -4 epsilon sigma T_s^3 - (rho c_p pdv(e_"surf", T_s) ) / (gamma r_v) - (rho c_p) / r_H
$ <eq_pdv_F0-T_s>

// == 土壤热通量

对于第一层土壤，根据连续性原理，可得：

#let kappa-coef()={
  let p = $i+1/2$
  $kappa_#p / delta(z_#p)$
}

$
  c_(v,i) delta(z_i) / delta(t) (T_i^(n+1) - T_i^(n)) =F_0(T_i^(n+1)) - #kappa-coef() (T_i^(n+1) - T_(i+1)^(n+1))
$ <eq_Ts1>

其中，下标$i$表示第i层土壤，上标$n$表示第n个时间步。

*该公式是求解土壤温度的关键。* 主要难点在于不知道$n+1$时刻的状态，包括$F_0(T_i^(n+1))$、$T_i^(n+1)$和$T_(i+1)^(n+1)$。

根据微积分法则，$F_0(T_i^(n+1))$可通过如下公式进行替换，以消减一个未知变量：
$ F_0(T_i^(n+1)) = F_0(T_i^(n)) + pdv(F_0(T_i^n), T_i) (T_i^(n+1) - T_i^(n)) $ <eq_F0>

其中，$pdv(F_0(T_i^n), T_i)$可通过式#[@eq_pdv_F0-T_s]判定。

将式#[@eq_F0]得到的$F_0(T_i^(n+1))$，重新代入#[@eq_Ts1]，可得：

$
  c_(v,i) delta(z_i) / delta(t) (T_i^(n+1) - T_i^(n)) = \
    F_0(T_i^(n)) + pdv(F_0(T_i^n), T_i) (T_i^(n+1) - T_i^(n)) - #kappa-coef() (T_i^(n+1) - T_(i+1)^(n+1)) 
$

令$delta(T_i^n) = T_i^(n+1) - T_i^(n)$，

$
  T_i^(n+1) - T_(i+1)^(n+1) &= (T_i^(n+1) - T_i^(n) + T_i^(n)) -  (T_(i+1)^(n+1) - T_(i+1)^(n) + T_(i+1)^(n)) \
    &= delta(T_i^n) - delta(T_(i+1)^n) + T_i^n - T_(i+1)^n
$

$
  (c_(v,i) delta(z_i)) / delta(t) delta(T_i^n) = F_0(T_i^(n)) + pdv(F_0(T_i^n), T_i) delta(T_i^n) - 
    #kappa-coef() ( delta(T_i^n) - delta(T_(i+1)^n) + T_i^n - T_(i+1)^n )
$

$
  ((c_(v,i) delta(z_i)) / delta(t) - pdv(F_0(T_i^n), T_i) - #kappa-coef() )  delta(T_i^n) 
    - #kappa-coef() delta(T_(i+1)^n) = \ 
    F_0(T_i^(n)) - #kappa-coef() (T_i^n - T_(i+1)^n)
$ <eq_Tsoil_solve>

之后，可以用三角矩阵的方式进行求解。

$ a_i delta(T_(i-1)^n) + b_i delta(T_i^n) + c_i delta(T_(i+1)^n) = d_i $

将式#[@eq_Tsoil_solve]带入，可得：
$a_i = 0$，$b_i = (c_(v,i) delta(z_i)) / delta(t) - pdv(F_0(T_i^n), T_i) - #kappa-coef() $, 
$c_i = #kappa-coef()$，$d_i = F_0(T_i^(n)) - #kappa-coef() (T_i^n - T_(i+1)^n)$。
上述公式推导针对的土壤第一层（$i=1$），其他层的系数，详见#cite(<bonan2019climate>, form: "prose"), Table 7.1。

#p-full[*该方案求解过程中，核心代码过程：*]

```jl
Ts = θ_surf
# Emitted longwave radiation (W/m2) and temperature derivative (W/m2/K)
LWout = ϵ * σ * Ts^4 # 向外的部分
d_LWout = 4 * ϵ * σ * Ts^3

H = cpₐ * (θ_surf - θ) * g_ac # gH = g_ac
d_H = cpₐ * g_ac

es, d_es = satvap(θ_surf - K0) # ! bug may here
LE = λ / Pa * (es - e) * gw * β_soil # miss a ϵ here
d_LE = λ / Pa * d_es * gw * β_soil

# Net energy flux into soil (W/m2) and temperature derivative (W/m2/K)
f0 = Qa - LWout - H - LE
df0 = -d_LWout - d_H - d_LE

# solve Tsoil_next
Tsoil_next, G_soil, G_snow = soil_temperature_delta(soil, df0, f0, snow_water)

# Update surface fluxes for the change in surface temperature
dtsrf = Tsoil_next[1] - Tsoil[1]
LWout += d_LWout * dtsrf
H += d_H * dtsrf
LE += d_LE * dtsrf
Rn = Qa - LWout

# Surface vapor pressure is diagnosed from evaporative flux
ET = LE / λ # Evapotranspiration, [W m-2 / (J mol-1)] to [mol H2O m-2 s-1]
flux.e_surf = (e / Pa + ET / g_ac) * Pa  # CLM5 Tech Note 2020, Eq 5.100
```

// #pagebreak()

= 总结
#v(0.2em)
#p-full[研究思路可归结为如下两点：]

#box-blue[
1. 发展地表通量模型，厘清空气温度日内变化理论曲线，*修正观测频次误差*。

2. 城市与郊区，相同下垫面、相同辐射输入驱动下，地表温度不同，可归结于城市热岛效应对空气温度和空气湿度的影响。基于该假设，借助地表通量模型，可分离高精度城市热岛效应，识别城市热岛的衰减曲线，最终*修正城市化偏差*。
]

= 后续攻坚方向

#beamer-block([总体原则：采用简单的方法，做出结果；采用复杂的方法，提升精度。])

#box-red([
  1. 目前写完的地表通量模型采用气温驱动。应修改模型结构，改为地表温度驱动，输出空气温度。
  
  2. 攻坚边界层理论，研究边界层对城市热岛的影响。考虑三维复杂城市结构，对城市热岛的影响。

  3. 攻坚单柱模式（Single Column Model ）
    - https://github.com/NCAR/ccpp-scm
    - https://github.com/CliMA/SingleColumnModels.jl
    - https://github.com/CliMA/SurfaceFluxes.jl
])


// === 城市化偏差
// === 观测频次偏差
// *1. 构建地表通量模型，刻画地温和气温之间的关系。*
// *2. 通过地表通量模型，研究城市化偏差对地温的影响。*
// 是否能构建模型将地温数据反演为气温数据？

// #figure(
//   image("../images/土壤热通量/Figure3_城市化影响机理图.svg", width: 70%),
//   caption: [城市与水体对于热浪联合响应示意图（改自（Cosgrove et al., 2019））。]
// ) <fig_urban_water>


#bibliography("../References.bib", title: [参考文献#v(1.3em)], style:"gb-7714-2015-author-date")
