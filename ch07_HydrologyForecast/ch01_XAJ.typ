#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

#set par(leading: 1.24em, spacing: 1.14em)

#let FA = $"FA"$
#let BF = $"BF"$

#let wm = $"WM"$
#let WM = $"WM"$
#let WMM = $"WMM"$


#let SM = "SM"
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

== 2.2 自由水曲线—三水源划分


#box-red[
  新安江模型将土壤层的蓄水分为两种：
  - *张力水*（或称“土壤含水量”），土壤中被毛管力吸附的水分，低于田间持水量，不直接产流
  - *自由水*，超过田间持水量的重力水，可自由下渗或形成径流，可产流（地表/地下），#Blue[仅存在于已蓄满（产流）区域]
]

// === 2.2.1 核心概念引入：张力水 vs 自由水
模型引入*自由水蓄水库*（Free Water Storage, $S$）来分配水源。

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
  ),
  caption: [张力水与自由水物理意义对比],
) <tbl:tension_vs_free>


$R$ 进入自由水库 $S$，面临三个去向：
1. *溢出* $->$ 地表径流$"RS"$ ($S > S_"M"$ 时)，速度快。
2. *侧流* $->$ 壤中流$"RI"$ ($K_"I" times S$)，速度中等。
3. *下渗* $->$ 地下径流$"RG"$ ($K_"G" times S$)，速度最慢。

// #pagebreak()
=== 2.2.2 径流分割

#include "Figure1_自由水曲线.typ"

对自由水蓄量进行径流分割。#Blue[注意这里建模时$Alpha$指的是产流面积上的比例，后续在计算$RS$时要乘以产流面积$FR$]。因为只有产流区域才有自由水蓄量。

$ Alpha = 1 - (1 - S / S_max)^EX $

$ SM_max = S_max / (1 + EX) $


#let int = $integral$

$
  bold(R_1) = int_(0)^(AU) Alpha thin d S = int_(0)^(AU) [1 - (1 - S / S_max)^EX] thin d S \
  = AU - S_max / (EX + 1) [1 - (1 - AU / S_max)^(EX + 1)] \
  = AU - SM_max [1 - (1 - AU / S_max)^(EX + 1)]
$

*（a）若FR = 1*

#v(-0.8em)

$ bold(SM_1) = AU - R_1 = SM_max [1 - (1 - AU / S_max)^(EX + 1)] $

$ bold(AU) = S_max [1 - (1 - SM_1 / S_max)^(1/(EX + 1))] $ <eq_au_raw>

*（b）考虑FR不为1*


$
                  SM_1 & = AU times FR_1 - R_1 \
  SM_1 ' = SM_1 / FR_1 & = AU - R_1/ FR_1 \
                       & = AU - AU/FR_1 + SM_max/FR_1 [1 - (1 - AU / S_max)^(EX + 1)]
$

同理我们可得：

$
  SM' = AU - AU/FR + SM_max/FR [1 - (1 - AU / S_max)^(EX + 1)]
$

其中SM_1代表的是全流域的自由水蓄量；SM_1'代表的是产流区域的自由水蓄量。

求解AU，需要用到一个非线性的解法：

$ SM' = SM_1 ' times FR_1 / FR $

根据SM'可以得到AU，然后加上自由水的新增量R，在$RS = int_(AU)^(AU + R) Alpha thin d S$中积分，得到$RS$，与$SM'$的增加量：

$
  SM'_"next" times FR & = SM' times FR + R - RS \
           SM'_"next" & = SM' + (R - RS) / FR \
$

其中$R$和$RS$是通过蓄水容量曲线，推导过来的，是全流域的径流。

$ S = S_1 FR_1 / FR + (R - RS) / FR $

$
  RI = K_I times S times FR \
  RG = K_G times S times FR \
$

$ S = S(1 - K_I - K_G) $

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
