// #import "../typst/lib.typ": *
#import "@local/modern-cug-report:0.1.3": *
#counter(heading).update(2)
#let delta(x) = $Delta #x$

#set par(spacing: 1.2em, leading: 1em)
#show: doc => template(
  doc,
  size-config: (
    math: (
      text: 12pt, // 插入正文的公式
      block: 12pt, // 单独一行的公式
    ),
  ),
  pagenum: true,
  footer: "CUG水文气象学2025",
  header: "第三章 蒸散发的基本原理",
)

// =
// =
= 3 蒸散发的基本原理

== 3.1 蒸散发数据观测

中科院禹城综合试验站（简称禹城站）是黄河下游灌区冬小麦夏玉米农田生态
系统的典型试验站。冬小麦夏玉米农田生态系统是黄淮海平原最大的生态系统类型。

#figure(
  image("Figures/FluxMet_禹城_daily.svg", width: 100%),
  caption: [
    禹城站基本的通量与气象变量观测。

    $"GPP"$: 总光合速率，单位$"gC"\/m^2\/d$；
    $"LE"$: 潜热通量，单位$W\/m^2$；
    $T_a$：空气温度，单位℃；
    $R_s$：短波辐射，单位$W\/m^2$；
    $R_n$：净辐射，单位$W\/m^2$；
    $"Prcp"$: 降水，单位$"mm"$；
    $"VPD"$: 饱和水气压差，单位$"kPa"$；
    $"SM_1"$: 5cm土壤湿度，单位$%$；
    $"SM_2"$: 10cm土壤湿度，单位$%$；
  ],
) <fig1_yuchen>

#figure(
  image("Figures/FluxMet_禹城_hourly_heatmap.png", width: 100%),
  caption: [
    禹城站2003年，实际蒸散发ET, 相对湿度RH, 气温Tair，净辐射Rn，短波辐射Rs日内变化。横坐标为儒若日(day of year)，纵坐标为小时。
  ],
) <fig1_yuchen_2003>

== 3.2 蒸散发理论

#v(-0.8em)
=== 3.2.1 气象基础
#v(-0.8em)

==== 3.2.1.1 理想气体状态方程

$ P V = n R^* T = m R^(*)/M T $
$ P = rho R T $

- P: 压强，单位$"Pa"$；
- V: 体积，单位$m^3$；
- n: 气体的摩尔数，单位$"mol"$；M: 气体的摩尔质量，单位$"kg/mol"$；
- $R^*$: 理想气体常数，单位$J\/("mol" K)$；$R$: 比气体常数，单位$J\/("kg" K)$；
- T: 温度，单位$K$；
- m: 气体的质量，单位$"kg"$；
- $rho$: 气体的密度，单位$"kg"\/m^3$。


==== 3.2.1.2 水汽压与水汽密度的转换

对于干空气和水汽，二者的比气体常数分别采用$R_d$和$R_v$进行表示，二者的比值采用$epsilon$表示。

$ R_d / R_v = M_v / M_d = epsilon approx 0.622 $

对于空气和水汽，分别代入理想气体状态方程，可以得到：

$ e = rho_v R_v T $

$ P = rho R T approx rho R_d T $

二者相除可以得到：

$ rho_v = rho e/P R_d / R_v = epsilon rho e /P $ <eq_rho_v>

=== 3.2.2 物理基础

==== 3.2.2.1 气化潜热


#showybox(
  frame: (
    // title-color: red.darken(30%),
    border-color: blue.darken(10%),
    body-color: blue.lighten(95%),
  ),
  // title: [*比热容*]
)[

  *气化潜热* $lambda$：单位质量的液体，气化所需要吸收的热量，$"MJ"\/"kg"$。
  $ lambda = 2.5 "MJ" "kg"^(-1) $

]

根据气化潜热$lambda$的定义，可以得到潜热$"LE"$：

$ "LE" = lambda delta(m_v) = lambda delta(rho_v) V $ <eq_le>

其中，$delta(m_v)$是蒸发导致的水汽质量的变化，$"LE"$是蒸发所需的能量，$rho_v$水汽的密度。

==== 3.2.2.2 比热容

#showybox(
  frame: (
    // title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(95%),
  ),
  // title: [*比热容*]
)[
  *比热容* $c_p$：单位质量的物质升高1℃所需要的能量，$J \/ ("kg" ℃)$。

  根据比热容$c_p$的定义，可以得到温度变化引起的感热$H$：
  $ H = c_p rho V delta(T) $ <eq_h>
]

其中，$rho$: 空气密度，$V$: 空气体积。

#beamer-block([
  *小试牛刀：*

  1. $R_n = 100 W m^(-2)$，能量全部转换为潜热，1天的总能量为多少？对应的蒸发量是多少mm？#highlight()[考察点：汽化潜热]

    #nonum([$
      "LE" = 100 W m^(-2) times 86400 s = 8.64 "MJ" \
      E = "LE"/lambda = (8.64 "MJ") / (2.5 "MJ" "kg"^(-1)) = 3.456 "kg" \
    $])

  2. $1m^3$的空气，温度升高1℃，需要吸收多少能量？#highlight()[考察点：比热容]

    空气的比热容$c_p = 1103 J \/ ("kg" ℃)$，空气的密度$rho = 1.2 "kg" \/ m^3$。

    #nonum([$
      m = rho V = 1.2 times 1 = 1.2 "kg" \
      H = 1103 J \/ ("kg" ℃) times 1.2"kg" times 1℃ = 1323.6 J
    $])

])


=== 3.2.3 湿度计常数

湿度计常数，通过如下公式推导得到：
$ R_n = "LE" + H $

上式忽略了土壤热通量$G$，主要是因为土壤热通量$G$在长时间尺度仅占10%左右。当$R_n = 0$的情景下，感热与潜热相加等于0，二者相互转换。

#box-blue()[
  #set par(spacing: 1.2em, leading: 1em)

  一个*密闭系统*中，有充足的水，水的上方是空气。
  1. 初始状态，水和空气采用一个薄板完全分离，空气的初始状态为$(T, e_a)$，此时的温度即为*干球温度*。
  2. 之后抽开挡板，水和空气开始相互接触。水面蒸发，空气水汽含量增加；同时，蒸发吸热（从液态$->$气态），空气温度降低。
  3. 最终，稳定状态下，充分供水、蒸发降温所能达到的最低温度称为#Blue[湿度温度]。
]


$
  H + lambda E = 0 \
  lambda (m'_v - m_v) + m_a c_p (T' - T) = 0
$

感热与潜热发生在同一个密闭体积中，因此V相同。假定是单位体积：

$ lambda (rho'_v - rho_v) + rho_a c_p (T - T') = 0 $ <eq_wet_bulb_balance>

$
  lambda E' = lambda (rho'_v - rho_v), quad & "水汽含量升高", & lambda E > 0 \
              H' = rho_a c_p (T' - T), quad & "温度下降",     &        H < 0
$

其中：
$lambda$为汽化潜热，$m_"v"$为蒸发的水量，$m_"a"$为空气质量，$c_p$为空气比热容。$lambda E'$和$H'$分别表示密闭容器的潜热与感热通量。

令$Delta rho_v = rho'_v - rho_v, Delta T = T' - T$。式#[@eq_wet_bulb_balance]可写作：

$ lambda Delta rho_v = - rho_a c_p Delta T $

由 $rho_v = epsilon rho_a e / P ==> Delta rho_v = epsilon rho_a (Delta e) / P$，带入：

$
  lambda epsilon (Delta e) / P = - c_p Delta T \
  Delta e = - gamma Delta T, gamma = (c_p P) / (epsilon lambda)
$

其中，$gamma$是湿度计常数，单位$"Pa"\/℃$。


=== 3.2.4 干球温度与湿球温度

- *湿球温度*：百叶箱中避光情景下（$R_n=0$），湿布包裹，充分供水，蒸发降温得到的最低温度。

#v(-0.8em)

#figure(
  image("Figures/湿球温度计算.png", width: 70%),
  caption: [
    干球温度与湿球温度示意图。
  ],
) <fig_Tdry_Twet>

*(a) $R_n = 0$*

*在一个密闭体积中*（#Blue[注意必须是密闭的容器！]这是与后续通量过程的核心区别）。

从干球温度到湿度温度。图解法：

如图#[@fig_Tdry_Twet]，从$X -> Y$过程，温度降低，水汽压升高。

$lambda E + H = 0$，$X -> Y$，令$delta(e) = "es"(T') - e, delta(T) = T' - T$，可以得到：

$
  lambda E [X -> Y] = lambda delta(rho_v) V
  = lambda epsilon rho delta(e) / P V, (rho_v = epsilon rho e / P) \
$
$ H[X -> Y] = c_p rho V delta(T) $

代入能量平衡公式：

$
  lambda E [X -> Y] + H[X -> Y] = 0 \
  lambda epsilon rho delta(e) / P V + c_p rho V delta(T) = 0 \
  lambda epsilon delta(e) / P + c_p delta(T) = 0
$
$ delta(e) = -gamma delta(T), (gamma = (c_p P) / (epsilon lambda) ) $

其中，$delta(e)$和$delta(T)$分别表示$X->Y$过程中，水汽压和温度的变化。

- $delta(e) = "es"(T') - e$, 如图#[@fig_Tdry_Twet]，从$X->Y$水汽压变大，是一个蒸发的过程；

- $delta(T) = T' - T$，是一个降温的过程。

根据该情景，可以推出湿球温度的理论值。
// #box-red[根据该情景，可以推出湿球温度的理论值。]

*(b) $R_n > 0$，且充分供水*

若充分供水，空气中的水汽压可达到饱和，意味着初始状态和结束状态，都处于饱和水汽压曲线上，正如从$Y->A$过程（图#[@fig_Tdry_Twet]）。

$
  lambda E [Y -> A] = lambda delta(rho_v) V
  = & lambda epsilon rho delta(e) / P V, (delta(e) = "es"(T_A) - "es"(T_Y)) \
  = & lambda epsilon rho abs("OA") / P V
  // c_p rho V delta(T)
$

$
  H[Y -> A] = & H[Y -> X] = -lambda E [Y -> X] \
            = & lambda E [X -> Y] \
            = & lambda epsilon rho ("es"(T') - e) / P V = lambda epsilon rho abs("OX") / P V
$

因此，

$
  Delta = abs("OA") / abs("OY"), gamma = abs("YB") / abs("BX") = abs("OX") / abs("OY") \
  (lambda E [Y -> A]) / H[Y -> A] = abs("OA") / abs("OX") = Delta / gamma
$

联立方程，即可解出$lambda E$和$H$：

$
  R_n = lambda E + H, quad (lambda E ) / H = Delta / gamma
$

$ lambda = (Delta R_n) / (Delta + gamma), quad H = (gamma R_n) / (Delta + gamma) $

*(c) $R_n > 0$，供水不充分*

如图#[@fig_Tdry_Twet]，从$X -> A$过程，初始状态水汽压不饱和。
#box-red([
  求解的过程，将该过程划分为两段：$X -> Y$ 和$Y -> A$两段，分别写出两段的感热与潜热，之后相加即可得到，在此不再赘述。
])

// #pagebreak()

== 3.3 通量

#beamer-block([“百花丛中过，片叶不沾身”——通量])

#showybox(
  frame: (
    // title-color: red.darken(30%),
    border-color: blue.darken(10%),
    body-color: blue.lighten(95%),
  ),
  // title: [*比热容*]
)[
  若能量全部转换为感热，1天的总能量为多少？对应的温度升高是多少℃？

  #nonum([$
    H = 100 W m^(-2) times 86400 s = 8.64 "MJ" \
    delta(T) = H / (c_p rho V) = (8.64 "MJ") / (1103 J \/ ("kg" ℃) times 1.2 "kg") = 6528 ℃
  $])

  $delta(T)$按10℃算，$1 m^3$空气，升温所需要的能量：

  #nonum([$
    "Energy"_H =1103 J \/ ("kg" ℃) times 1.2"kg" times 10℃ = 13,236 J
  $])

  蒸发过程，认为初始状态$q = 0$，最终状态$q = 4%$（常温状态下的饱和比湿），蒸发过程耗能为：

  #nonum([$
    "Energy"_E = 2.5 "MJ" \/ ("kg") times 1.2"kg" times 4% = 0.12 "MJ"
  $])
]

*为何会出现这种现象？* #highlight([主要是因为干净的空气是个“小透明”])，拦截辐射的能力较弱。正常情况下，Rn=100 $W\/m^2$，升温幅度在10℃左右（图@fig1_yuchen），空气升温所耗的能量$E_H$仅占总能量的0.15%。

*那能量都去哪里了？*

#beamer-block([大部分能量是穿过，而非截留。])

#figure(
  image("Figures/通量-水汽.png", width: 70%),
  caption: [
    水汽通量。图件源自#[@monteith2013] Figure 3.4。
  ],
) <fig_flux_le>

=== 3.3.1 潜热通量

*(a) 比湿的形式：*

$ E = -D pdv(rho_v, z) = -D rho pdv(q, z) $ <eq_E_flux>

- D是水汽的扩散系数，单位$m^2\/s$；$E$的单位是$"kg"\/(m^2 dot s)$，$lambda E$的单位为$W\/m^2$。

#box-blue[扩散像墨水滴在水里扩散，墨水不是“每秒走几米”，而是“1秒钟扩散了多大一片面积”。所以单位是m²/s。]

在积分过程中，认为大气的状态达到均衡，认为E是常数。从地表$z_1$到参考高度$z_2$进行积分，可以得到：

#v(-0.6em)
$ integral_(z_1)^(z_2) E d z = integral_(z_1)^(z_2) -D rho d q $
#v(-0.4em)
$
  lambda E & = - lambda D rho (integral_(z_1)^(z_2) d q) / (integral_(z_1)^(z_2) d z)
             = lambda rho (q(z_1) - q(z_2)) / ((z_2 - z_1) / D)
             = lambda (rho delta(q)) / r_v, (r_v = (z_2 - z_1) / D)
$

上式，定义了水汽传递阻力$r_v$ ($s\/m$)，导度$g_v$等于阻力的倒数（$g_v = 1/r_v$, $m\/s$），$delta(q) = q(z_1) - q(z_2)$。蒸发的水汽通常来源于湿润的地表。一般而言，$q(z_1) > q(z_2)$。

#v(-0.4em)
#box-blue[
  $integral_(z_1)^(z_2) d q = q(z_2) - q(z_1)$成立的前提是函数 $q(z)$ 在积分区间 $[z_1, z_2]$上是连续的。也即是$q$的导数存在。该式是牛顿-莱布尼茨公式的应用。
]

#v(-0.4em)
#block(fill: yellow.lighten(80%), inset: 10pt, radius: 4pt)[
  #set par(spacing: 1.15em)
  *为何要进行积分？*
  之所以要从地表 $z_1$ 到参考高度 $z_2$ 进行积分，主要是为了将微观的微分方程转化为宏观可测量的公式，并引出“阻力”的概念。

  - *1. 从“梯度”到“差值” (Measurability):*
    式#[@eq_E_flux]描述的是某一点的通量与该点水汽梯度$pdv(q, z)$的关系。
    在实际观测中，我们很难测量某一具体点的“梯度”。我们容易测量的是两个高度上的数值（例如：地表 $z_1$ 的湿度和 2米高处 $z_2$ 的湿度）。
    积分的作用，就是把“梯度的微分关系”变成“两点间的差值关系”$q(z_1) - q(z_2)$，让我们能用观测数据来计算通量。

  - *2. 定义“阻力” (Physics Concept - Resistance):*
    通过积分，我们将复杂的扩散系数 $D$ 和路径长度 $z_2 - z_1$ 整合到了一个项中。
    这就导出了类似欧姆定律的形式：通量 = 势差 / 阻力。
    即 $r_v = (z_2 - z_1) / D$。这样我们就定义了水汽传递阻力 (Aerodynamic Resistance)，这使得物理意义更加直观：通量受驱动力（湿度差）和阻力（空气动力学阻力）控制。

  - *3. 常通量层的假设 (Assumption):*
    注意文中提到“认为 $E$ 是常数”。只有假设在这段垂直距离内水汽通量 $E$ 不随高度变化，我们才能把 $E$ 从积分号里提出来，从而解出 $E$ 的表达式。
]


*(b) 水汽压的形式：*

$
  lambda E & = -lambda D pdv(rho_v, z)
             = -lambda D ( epsilon rho) / P pdv(e, z), (rho_v = (epsilon rho)/ P e ) \
           & = -(D rho c_p) / gamma pdv(e, z), (gamma = (c_p P) / (epsilon lambda) )
$

$
  lambda E & = -(D rho c_p) / gamma (integral_(z_1)^(z_2) d e ) / (integral_(z_1)^(z_2) d z ) \
           & = -(D rho c_p) / gamma (e(z_2) - e(z_1)) / (z_2 - z_1)
             = (rho c_p delta(e)) / (gamma r_v), (r_v = (z_2 - z_1) / (D) )
$

=== 3.3.2 感热通量

#figure(
  image("Figures/通量-热量.png", width: 60%),
  caption: [
    感热通量。图件源自#[@monteith2013] Figure 3.3。
  ],
) <fig_flux_le>

$ H = -k pdv(rho c_p T, z) = - k rho c_p pdv(T, z) $

$ integral_(z_1)^(z_2) H d z = integral_(z_1)^(z_2) - k rho c_p d T $

$
  H = & - k rho c_p (integral_(z_1)^(z_2) d T ) / (integral_(z_1)^(z_2) d z)
        = & k rho c_p (T(z_1) - T(z_2)) / (z_2 - z_1)
            = & (rho c_p delta(T)) / r_H, (r_H = (z_2 - z_1) / k)
$

// - $kappa$：热传导系数，单位$W\/(m K)$；
- $k$：热扩散系数，单位$m^2\/ s$，；
- $H$: 感热通量，单位$W\/m^2$；
- $c_p$: 比热容，单位$J\/("kg" K)$；
- $rho$: 空气密度，单位$"kg"\/m^3$；
- $r_H$: 热量的传递阻力，单位$s\/m$；

#beamer-block([$rho c_p$的作用是把$Delta T$转化为能量的单位。])

=== 3.3.3 修正湿度计常数

考虑水汽和热量的传递阻力后，如图#[@fig_Tdry_Twet]，感热与潜热的公式变形为：

$ lambda E = lambda (epsilon rho delta(e)) / (P r_v) , H = (rho c_p delta(T)) / r_H $

$lambda E + H = 0$ 可得，
$
  lambda epsilon delta(e) / (P r_v) = - c_p delta(T) / r_H
  delta(e) / ( r_v) = - (c_p P) / (lambda epsilon) r_v / r_H delta(T)
$

令$gamma^* = (c_p P) / (lambda epsilon) r_v / r_H = gamma r_v / r_H$。$gamma^*$被称为修正湿度计常数。

*已知$delta(rho_v) = epsilon rho delta(e) / P, gamma = (c_p P) / (lambda epsilon)$，可得$lambda E$的5种形式：*
$
  
    lambda E = lambda delta(rho_v) / r_v
    = cases(
      lambda rho delta(q) / r_v,
      lambda (epsilon rho delta(e)) / (P r_v)
      = (rho c_p delta(e)) / (gamma r_v) = (rho c_p delta(e)) / (gamma^* r_H)
    )
$ <eq_LE_final>

== 3.4 潜在蒸散发

#h(2em)
与上一章节不同，#Blue[对于通量而言，没有初始状态与最终状态的区别。]
Penman公式的推导，它研究的是稳定状态下的感热与潜热通量。
稳定状态下（也即是均衡状态下），空气温度和水汽压（$T_a$, $e_a$）已知；湿表面温度$T_w$不知，但可以确定的是湿表面的水汽压为饱和水汽压$e_s (T_w)$。对应的感热、潜热通量为：

$
  lambda E & = rho c_p (e_s (T_w) - e_a) / (gamma^* r_H) \
         H & = rho c_p (T_w - T_a) / r_H
$

#pagebreak()
#v(-0.9em)
=== 3.4.1 水面蒸发 (Penman 1948)

#figure(
  image("Figures/Penman1948_示意图.png", width: 62%),
  caption: [Penman 1948水面蒸发示意图。
    点W为空气所处的状态，点X为$R_n = 0$情况下湿表面所处的点，点Y为$R_n > 0$情况下湿表面所处的点。
  ],
) <fig_penman1948>

#figure(
  caption: [
    蒸发过程的几种不同情景。
  ],
  table(
    columns: (1.25cm, 1.9cm, 1.68cm, 1.55cm, 3.4cm, 3.3cm, 3.7cm),
    // (2.0cm, 1.9cm, 1.55cm),
    rows: (0.8cm, 0.8cm),
    align: (horizon, horizon, horizon, horizon, left + horizon, horizon),
    [*情景*], [*过程*], [*蒸发面*], [*空气*], [#align(center)[*条件*]], [*案例*], [*蒸发公式*],
    [a], [$X -> W$], [$X$], [$W$], [$R_n = 0, e"饱和"$], [湿球温度], [式#[@eq_LE_final]],
    [b], [$Y -> X$], [$Y$], [$X$], [$R_n > 0, e"饱和"$], [湖面、海面蒸发], [均衡蒸发 式#[@eq_PE0_eq]],
    [c], [$Y -> W$], [$Y$], [$W$], [$R_n > 0, e"未饱和"$], [蒸发皿蒸发], [Penman1948 式#[@ch3_eq37]],
  ),
) <table_>

#let es = $e_s$
#let LE = $lambda E$


*（a）情景1*：空气干燥，且$R_n = 0$。

#box-blue[点$W$为空气所处的状态，点$X$为蒸发面（湿表面）所处的状态。]

$
  lambda E [X -> W] = -H[X -> W] = (rho c_p D) / r_H, (D = T_W - T_X) \
$

点$X$是斜率为$-gamma$且过点W的直线与饱和水汽压曲线的交点。只有$[T_w, e_s (T_w)]$处于点X，才能保持$R_n = 0$。

若空气状态P饱和水汽压曲线，且在湿润面$X$的左侧，则对于空气而言$lambda E > 0, H > 0 ==> R_n > 0$；若在右侧，则反之。


*（b）情景2*：空气饱和，且$R_n > 0$，$X -> Y$的过程。

为了便于利用几何关系，这里采用点$V$表示蒸发面状态，点$X$表示空气状态（图#[@fig_penman1948]）。点V的温度与空气温度相同，但水汽压为饱和。空气处于点$X$，蒸发面处于点$V$。

$lambda E[V -> X]$表征的是蒸发面在V，空气在X的情况下，蒸发面到空气的潜热通量。

$ R_n = lambda E[V -> X] + H[V -> X] $

$
  lambda E[V -> X] & = rho c_p (e_s (T_V) - e_s (T_X)) / (gamma^* r_H)
                     = rho c_p Delta (T_V - T_X) / (gamma^* r_H)
$

$ H[V -> X] & = rho c_p (T_V - T_X) / r_H $

因此，可以解出通量：
$ lambda E[V -> X] = (Delta R_n) / (Delta + gamma^*) $ <eq_PE0_eq>
$ H[V -> X] = (gamma^* R_n) / (Delta + gamma^*) $

#box-red[*结论*：若空气中的水汽达到饱和，净辐射驱动下$lambda E = (Delta R_n) / (Delta + gamma^*)$]

*（c）情景3*：蒸发面充分供水，但空气不饱和，则是$W -> Y$过程：

$ lambda E [W -> Y] = (Delta R_n) / (Delta + gamma^*) + (rho c_p D) / r_H $ <ch3_eq37>

$
  H [W -> Y] = & R_n - lambda E [W -> Z] \
             = & (gamma^* R_n) / (Delta + gamma^*) - (rho c_p D) / r_H
$ <ch3_eq38>

*另一种推导方法：暴力求解*

跳过图#[@fig_Tdry_Twet]和#[@fig_penman1948]的几何过程，针对$W -> Y$（图#[@fig_penman1948]，湿表面到空气的热量与水汽交互）的过程，采用暴力求解。

下标$""_w$和$""_a$分别代表湿表面和空气。空气指的是参考高度处的空气，一般为2m。

$ H = R_n - lambda E = rho c_p (T_w - T_a) \/ r_H $ <ch3_2_h>

$
  lambda E = lambda epsilon rho (e_w - e_a) / (P r_v)
  &= rho c_p (e_w - e_a) / (gamma^* r_H) = rho c_p ("es"(T_w) - e_a) / (gamma^* r_H)
$ <ch3_eq40>

其中，认为水面的水汽压为饱和$e_w = "es"(T_w)$，
$
  e_w - e_a = "es"(T_w) - e_a = "es"(T_w) - "es"(T_a) + "es"(T_a) - e_a \ = "es"(T_w) - "es"(T_a) + "VPD"
$

$
  lambda E = rho c_p ("es"(T_w) - "es"(T_a) + "VPD") / (gamma^* r_H) \
  = rho c_p (Delta (T_w - T_a) + "VPD") / (gamma^* r_H)
$ <ch3_2_le>

求出#[@ch3_2_h]中的$T_w - T_a$，代入#[@ch3_2_le]，可以得到：

$
  lambda E = (Delta R_n) / (Delta + gamma^*) + (rho c_p "VPD" \/ r_H) / (Delta + gamma^*)
$ <ch3_pm_le>

$
  H = (gamma^* R_n) / (Delta + gamma^*) - (rho c_p "VPD" \/ r_H) / (Delta + gamma^*)
$ <ch3_pm_h>

#box-red([为何#[@ch3_eq37]和#[@ch3_pm_le]的结果不同？
  #nonum([$
    lambda E = (Delta R_n) / (Delta + gamma^*) + rho c_p D \/ r_H
  $])
  *其实他们是等价的，因为$"VPD" = D (Delta + gamma^*)$。*可借助图#[@fig_penman1948]的几何关系，推导得出。
])

=== 3.4.2 叶片与冠层蒸发 (Monteith 1965)

#figure(
  image("Figures/叶片蒸发.png", width: 65%),
  caption: [
    叶片蒸腾阻力示意图。图件源自#[@monteith2013] Figure 13.4。
  ],
) <fig_monteith>

*湿表面发生了转移*：$"叶片内部"[T_l, es(T_l)] --> "叶片表面"[T_o, e_o] --> "空气"[T_a, es(T_a)]$。研究上述过程，套用的是潜热通量公式：$LE = (rho c_p delta(e)) / (gamma r_v)$。


稳定状态下，$LE["L" -> "O"] = LE["O" -> "A"]$。其中L、O、A分别代表叶片内部、叶片表面和空气。也即是：

$
  (es(T_l) - e_o) / r_s = (e_o - e) / r_v = (es(T_l) - e) / (r_v + r_s)
$ <eq_ET_leaf>


根据式#[@eq_ET_leaf]，我们可以看到，
相比于水面蒸发，叶片蒸发在水汽传导阻力中多了气孔阻力$r_s$。$H$的表达形式不变，$lambda E$的表达形式变为：

$
  lambda E & = lambda epsilon rho (e_w - e_a) / (P (r_v + r_s) ) =
             rho c_p (e_w - e_a) / (gamma (r_v + r_s) ),
             gamma = (c_p P) / (lambda epsilon)
$ <ch3_eq45>

重新联立公式#[@ch3_2_h]，可以得到：

$ gamma^* = gamma (r_v + r_s) / r_H $

$
  lambda E & = (Delta R_n + rho c_p "VPD" \/ r_H) / (Delta + gamma^*) \
           & = (Delta R_n + rho c_p "VPD" \/ r_H) / (Delta + gamma ( 1 + r_s/r_H))
$ <ch3_monteith1965>

#beamer-block([
  这里认为$r_H approx r_v$。根据辐射理论 #[@monteith2013] ，$r_v = (kappa / D)^0.67 r_H approx 0.93 r_H$。
  D是水汽的分子扩散系数，单位$m^2\/s$。$kappa$是空气的热扩散系数，单位$m^2\/s$。
])

=== 3.4.3 参考作物蒸发 (FAO98)

// #beamer-block([
一种假想的参考作物（供水条件良好的草地），高度为0.12m，固定的冠层阻力为70 $s\/m$，反射率为0.23。

A hypothetical reference crop with an assumed crop height of 0.12 m, a fixed surface resistance of 70 $s\/m$ and an albedo of 0.23.
// ])

#figure(
  image("Figures/参考作物_FAO98_Figure9.png", width: 70%),
  caption: [
    参考作物蒸发示意图。图件源自FAO No. 56, Figure 9。
  ],
) <fig_fao98>

== 3.5 实际蒸散发

#figure(
  image("Figures/根区土壤水分布.png", width: 70%),
  caption: [根区土壤水分布。],
) <fig_>

//! === 3.5.1 植被蒸腾与植被光合

== 3.6 地表能量平衡

#beamer-block()[
  地表能量平衡公式 $R_n - G = H + lambda E$ 解释了不同下垫面的温度差异。

  - *城市（热岛效应）：* 不透水面多（水泥、沥青），土壤水分少，$lambda E$（蒸发潜热）很小。大部分净辐射 $R_n$ 转化为感热 $H$ 加热空气，导致城市温度显著高于郊区。
  - *绿洲（绿洲效应）：* 植被丰富，水分充足，$lambda E$ 很大（甚至可能超过 $R_n$，此时 $H$ 为负值，即从空气吸热）。大量能量用于蒸腾，使得绿洲表面温度低于周围沙漠。
]

#figure(
  image("Figures/感热潜热-变化.png", width: 70%),
  caption: [
    感热通量与潜热通量分配比例Bowen系数随温度变化示意图。
  ],
) <fig_bowen>

#pagebreak()

== 3.7 蒸散发与土壤水、地下水之间的关系

=== 3.7.1 蒸散发与土壤水之间的关系

1. 无论是土壤蒸发还是植被蒸腾，都与土壤水分有关。
2. 土壤水限制植被蒸腾和土壤蒸发；蒸散发抽取土壤水。二者相互影响，相互限制。

#figure(
  image("Figures/Figure1_土壤水临界值.png", width: 90%),
  caption: [
    （a）蒸散三阶段示意图；
    （b）蒸散不同阶段土壤湿度变化速度$d theta\/"dt"$示意图。
    其中$theta_f$为土壤田间持水量；
    $theta_c$和$theta_w$为蒸散三阶段转折点。Ksat为土壤饱和水力传导系数。
    // （b）基于土壤湿度变化速率的临界值$theta_c$检测。
  ],
) <fig_SM_trs>

=== 3.7.2 案例

#figure(
  image("Figures/ET_signal_GW.png", width: 70%),
  caption: [蒸散发与地下水的交互。\ 数据来源：
    https://waterdata.usgs.gov/monitoring-location/302416087505501。],
)

#figure(
  image("Figures/ET_signal_SM.png", width: 70%),
  caption: [蒸散发与土壤水的交互。],
)

#bibliography("References.bib", title: "参考文献", style: "gb-7714-2015-author-date")
