#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

#set par(leading: 1.24em, spacing: 1.14em)

#let FA = $"FA"$
#let BF = $"BF"$

#let wm = $"WM"$
#let WM = $"WM"$
#let WMM = $"WMM"$


#let SM = $"SM"$
#let mm = $max$
#let EX = $"EX"$
#let AU = $"AU"$
#let FR = $"FR"$
#let PE = $"PE"$
#let RS = $"RS"$
#let RI = $"RI"$
#let RG = $"RG"$

#let Alpha = $bold(alpha)$
#let delta(x) = $Delta #x$

= 1 *混合产流*

$ Alpha_f = 1 - (1 - f / f_MM )^BF, f_MM =overline(f)(1 + BF) $

$
  FA = cases(
    overline(f) delta(t) & P >= overline(f) (BF + 1) delta(t),
    integral_0^P (1 - Alpha_f) d f = overline(f) delta(t) [1 - (1 - P/f_MM)^(BF + 1)] quad & P < overline(f) (BF + 1) delta(t)
  )
$


// $
//   Alpha = 1 - (1 - (FA + a) / WMM )^B
// $

- `FA`: 下渗量


= 2 *新安江模型主要原理*

== 2.1 蓄水容量曲线—产流过程

#include "Figure1_蓄水曲线.typ"

#box-blue[
  #set par(leading: 0.6em, spacing: 0.5em)
  涨水过程中，所有格点的土壤含水层、蓄水量均匀上涨。对于某一点$P(alpha, W)$，饱和部分的比例$alpha$，
  未饱和部分比例为$1 - alpha$。
]


#let WMM = $"WM"_max$

$ Alpha = 1 - (1 - wm / WMM)^b $

$
  W_max = integral_0^WMM (1 - Alpha) thin d"WM"
  = -WMM/(b+1) (1 - wm/WMM)^(b+1) |_0^WMM
  = WMM / (1 + b)
$ <eq_WM>

其中，$wm$为流域所有网格中最大土壤含水量；$Alpha$为包气带蓄水容量$≤wm$的比例。
$Alpha_0$为蓄满的比例，$a$为最大土壤含水量。
// #box-blue[
//   右侧为未饱和的部分。
//   左侧是已经饱和的部分。
// ]

$ Alpha_0 = 1 - (1 - a / WMM)^b $

$
  W = integral_0^a (1 - Alpha ) thin d"WM" = WM [1 - (1 - a / WMM)^(b + 1)]
$ <eq_w>

$ WM (1 - a / WMM)^(b + 1) = WM - W $

写成$a$的形式：
$
  (1 - a / WMM)^(b + 1) = 1 - W / WM ==> 1 - a/WMM = (1 - W / WM)^(1/(b+1)) ==> \
  a = WMM [1 - (1 - W / WM)^(1/(b+1))]
$

*积分过程*：

$
  R = integral_a^(a + "PE") Alpha thin d"WM'"
  = integral_a^(a + "PE") [1 - (1 - wm / WMM)^b] thin d"WM'" \
  = "PE" - integral_a^(a + "PE") (1 - wm / WMM)^b thin d"WM'" \
  = "PE" + WMM/(b+1) (1 - wm/WMM)^(b+1) |_a^(a+"PE") \
  = "PE" + WMM/(b + 1) [(1 - (a + "PE")/WMM)^(b+1) - (1 - a/WMM)^(b+1)] \
  = "PE" + WM [(1 - (a + "PE")/WMM)^(b+1) - (1 - a/WMM)^(b+1)] \
  = "PE" + WM (1 - (a + "PE")/WMM)^(b+1) + W - WM
$

#pagebreak()
== 2.2 自由水曲线—三水源划分

#box-red[
  新安江模型将土壤层的蓄水分为两种：
  - *张力水*（或称“土壤含水量”），土壤中被毛管力吸附的水分，低于田间持水量，不直接产流
  - *自由水*，超过田间持水量的重力水，可自由下渗或形成径流，可产流（地表/地下），#Blue[仅存在于已蓄满（产流）区域]
]

// !=== 2.2.1 核心概念引入：张力水 vs 自由水
#h(2em)
蓄水容量超出的部分产生径流$R$，$R$进入自由水库$S$。模型引入*自由水蓄水库*（Free Water Storage, $S$）来分配$S$。

1. *溢出* $->$ 地表径流$"RS"$ ($S > S_"M"$ 时)，速度快。
2. *侧流* $->$ 壤中流$"RI"$ ($K_"I" times S$)，速度中等。
3. *下渗* $->$ 地下径流$"RG"$ ($K_"G" times S$)，速度最慢。

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    inset: 8pt,
    align: horizon,
    table.header([*对比项*], [*张力水 $W$*], [*自由水 $S$*]),
    [*别名*], [束缚水、毛管水], [重力水],
    [*作用力*], [毛管力、吸附力], [重力],
    [*运动特性*], [不能自由流动], [可自由移动],
    [*消耗方式*], [蒸发、蒸腾], [下渗、侧流、地表径流],
    [*对应参数*], [田间持水量 FC], [饱和含水量 $theta_s$ - FC],
    [*水文功能*], [蓄存（产流前提）], [输送（径流来源）],
    [*概化方式*], [蓄水容量曲线], [自由水曲线],
  ),
  caption: [张力水与自由水物理意义对比],
) <tbl:tension_vs_free>

#figure(
  caption: [
    自由水曲线变量说明。
  ],
  table(
    columns: 5,
    // (2.0cm, 1.9cm, 1.55cm),
    rows: (0.8cm, 0.8cm),
    align: (horizon),
    [变量], [说明], [单位], [], [],
    [$Alpha$], [百分位数], [$Alpha in [0, 1]$], [], [],
    [$SM$], [产流范围内最大一点的自由水蓄量], [mm], [], [],
    [$SM_max$], [流域范围内最大一点的自由水蓄量], [mm], [], [],
    [$S$], [流域平均自由水容量], [mm], [], [],
    [$S_max$], [流域平均自由水容量最大值], [mm], [], [],
    [$FR$], [产流面积], [$FR in [0, 1]$], [], [],
    [$R$], [蓄水容量产流量], [mm], [], [],
  ),
) <table_>

// #pagebreak()
=== 2.2.1 径流分割

#include "Figure1_自由水曲线.typ"

#box-red()[
  #Blue[*基本原则：*]

  1. *张力水未蓄满之前，不会有自由水*。因此，蓄满出流量$R$，无法分配到全流域，只能在产流区域分配。

  2. *不能假设产流区域与全流域的自由水蓄水曲线一致。*（虽然都是抛物线的形式，但是形状参数有所不同）。
]

$ Alpha = 1 - (1 - SM / SM_max)^EX $

$ S_max = SM_max / (1 + EX) $

1. 最初$S=0$。随着降雨的增加，部分网格张力水蓄满，产生自由水$R_0$，对应的产流面积为$FR_1$。令#Blue[$AU = R_0 / FR_1$]，$AU$代表了前期产流面积上的自由水蓄量。

#let int = $integral$

$
  bold(RS_1) = int_(0)^(AU) Alpha thin d"SM" = int_(0)^(AU) [1 - (1 - SM / SM_max)^EX] thin d"SM" \
  = AU - SM_max / (EX + 1) [1 - (1 - AU / SM_max)^(EX + 1)] \
  = AU - S_max [1 - (1 - AU / SM_max)^(EX + 1)]
$

*蓄水容量SM*

$
  S_1 & = AU times FR_1 - RS_1 \
      & = AU times FR_1 - AU + S_max [1 - (1 - AU / SM_max)^(EX + 1)] \
      & = S_max [1 - (1 - AU / SM_max)^(EX + 1)] - AU (1 - FR_1)
$ <eq_SM>

#box-red()[
  *若认为在产流面积FR1与产流面积FR上，自由水分布一致。*在产流面积FR1上，
  $
    S_1 = AU - RS_1 = S_max [1 - (1 - AU / SM_max)^(EX + 1)] \
    1 - S_1/SM_max = (1 - AU / SM_max)^(EX + 1) \
  $

  - $S_1$代表的是产流面积上的平均自由水蓄量，全流域平均则为$S_1 times FR_1$。

  - 后续产流面积发生变化时，$S_1$的水量平铺到$FR$上，$S_1$变为$S_1' = S_1 times FR_1 / FR$。

  $ AU = SM_max [1 - (1 - (S_1 ')/SM_max)^(1/(EX + 1))] $

  但上述推导存在一个前提：*产流面积FR1与产流面积FR上，自由水分布一致*。

  #Blue[但这个假设是否一定成立呢？]
]

2. 考虑到下一时刻$FR$发生变化，$S_1$的水量平铺到$FR$上，采用式#[@eq_SM]，逆向求解下一时刻的AU'（非线性解法）。

3. 根据$S_1$反推AU'，然后加上自由水的新增量R，超过蓄水容量的部分为$RS$。

$ RS = int_(AU')^(AU' + R/FR) Alpha thin d"SM" $
$ Delta"S" = R - RS $

4. 之后，$S$更新为$S_1 + delta("S")$，同时壤中流和地下径流出流。

$ S = S_1 + Delta"S" $

$
  RI = K_I times S \
  RG = K_G times S \
$

$ S = S(1 - K_I - K_G) $

=== 2.2.2 书上错在哪里？

#box-red()[
  不能假设：产流区域与全流域的自由水蓄水曲线一致。
]

#pagebreak()

= 3 *汇流方法*

== 3.1 线性水库

$ dv(S, t) = I - Q = (I_1 + I_2) / 2 - (Q_1 + Q_2) / 2 $

$
  Q = S / K, Delta S = S_2 - S_1 = K(Q_2 - Q_1)
$

因此，

$
  K(Q_2 - Q_1) / (Delta t) = (I_1 + I_2) / 2 - (Q_1 + Q_2) / 2 \
  2K(Q_2 - Q_1) = Delta t [(I_1 + I_2) - (Q_1 + Q_2) ] \
  (2K + delta(t)) Q_2 = (2K - delta(t)) Q_1 + delta(t) (I_1 + I_2) \
  Q_2 = (2K - delta(t))/ (2K + delta(t)) Q_1 + delta(t) / (2K + delta(t)) (I_1 + I_2) \
$

$
  Q_2 = C_s Q_1 + (1 - C_S) (I_1 + I_2) / 2, C_s = (2K - delta(t))/ (2K + delta(t))
$

== 3.2 滞后线性水库

1. 水流像“快递”一样，从产流点到出口需要固定时间 τ ，途中不堆积、不变形。

2. 出口处有一个“理想水库”，其出流与蓄水量成正比：$Q = S / K$

$ dv(S, t) = I(t) - Q(t) $

$ K dv(Q(t), t) + Q(t) = I(t) $

产流 R(t) 先经过滞时 τ → 变成 R(t−τ)，R(t−τ) 再进入线性水库 → 输出 Q(t)

$ K dv(Q(t), t) + Q(t) = R(t - tau) $

$ K (Q_i - Q_{i-1}) / delta(t) + Q_i = R_{i-L} $

$
  Q_i = underbrace(frac(K, K + Delta t), c_s) Q_{i-1} +
  underbrace(frac(Delta t, K + Delta t), 1 - c_s) R_{i - L}
$

$ Q_i = c_s Q_{i-1} + (1 - c_s) R_{i - L} $

== 3.3 单位线

2参数gamma分布，作为单位线：

#let uh = $bold("uh")$
$
  bold(uh)(tau) = 1 / (Gamma(a) theta^a) tau^(a - 1) e^(- tau/theta)
$

$a$是形状参数，默认为2.5；$theta$是时间参数，1h。

众数：$(a - 1) theta$，方差：$a theta^2$

$
  q(t) = integral_0^{tau_max} uh(tau) thin R(t - tau) thin d tau
$

#let q = $gamma$
#let tmax = "tmax"

*uh从1开始*
$
  Q_1 & = r_1 uh_1 \
  Q_2 & = r_2 uh_1 + r_1 uh_2 \
  Q_3 & = r_3 uh_1 + r_2 uh_2 + r_1 uh_3 \
  Q_4 & = r_4 uh_1 + r_3 uh_2 +r_2 uh_3 + r_1 uh_4 \
  Q_t & = r_t uh_1 + r_{t-1} uh_2 + ... + r_{t - tmax + 1} uh_{tmax}
$

*uh从0开始*
$
  Q_1 & = r_1 uh_0 \
  Q_2 & = r_2 uh_0 + r_1 uh_1 \
  Q_3 & = r_3 uh_0 + r_2 uh_1 + r_1 uh_2 \
  Q_4 & = r_4 uh_0 + r_3 uh_2 +r_2 uh_2 + r_1 uh_3 \
  Q_t & = r_t uh_0 + r_{t-1} uh_1 + ... + r_{t - tmax + 1} uh_{tmax-1} + r_{t - tmax} uh_{tmax}
$
