#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

#set par(
  leading: 1.24em,
  spacing: 1.14em,
  first-line-indent: (amount: 2em, all: true),
)

#let Blue(it) = {
  text(fill: blue)[*#it*]
}

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

// != 1 *混合产流*

// $ Alpha_f = 1 - (1 - f / f_MM )^BF, f_MM =overline(f)(1 + BF) $

// $
//   FA = cases(
//     overline(f) delta(t) & P >= overline(f) (BF + 1) delta(t),
//     integral_0^P (1 - Alpha_f) d f = overline(f) delta(t) [1 - (1 - P/f_MM)^(BF + 1)] quad & P < overline(f) (BF + 1) delta(t)
//   )
// $

// $
//   Alpha = 1 - (1 - (FA + a) / WMM )^B
// $

// - `FA`: 下渗量

// = L1
// = L1
// = L1
// = L1
// = L1
// = L1
= 7 *新安江模型主要原理*

== 7.1 蓄水容量曲线—产流过程

#include "Figures/Figure1_蓄水曲线.typ"

#let WMM = $"WM"_max$

新安江模型为集总式模型，假设流域内各格点的降雨均匀分布。虽然是集总式模型，但通过蓄水容量曲线，可以表征流域内不同区域的蓄水能力的空间差异。

// 设$WMM$为流域最大蓄水容量，$W$为当前蓄水量，$a$为当前蓄水深度，则流域平均蓄水容量可由蓄水容量曲线表示。
// 且在涨水过程中，假设各格点的土壤蓄水量均匀增加。设$wm$为蓄水容量阈值，$WMM$为流域最大蓄水容量，则蓄水容量不超过$wm$的面积比例$Alpha$可由蓄水容量曲线表示：

涨水过程中，假设各格点的土壤蓄水量均匀增加。设$wm$为蓄水容量阈值，$WMM$为流域最大蓄水容量，
则蓄水容量不超过$wm$的面积比例$Alpha$可由蓄水容量曲线表示：

$ Alpha = 1 - (1 - wm / WMM)^b $

当蓄水深度达到$wm$时，饱和与未饱和面积比例分别为$Alpha$和$1 - Alpha$。
对未饱和面积比例积分，可得流域平均蓄水容量$W_max$：

$
  W_max = integral_0^WMM (1 - Alpha) thin d"WM"
  = -WMM/(b+1) (1 - wm/WMM)^(b+1) |_0^WMM
  = WMM / (1 + b)
$ <eq_WM>

设$a$为当前蓄水深度，$Alpha_0$为当前饱和面积比例，则：
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

产流量$R$可通过下式积分进行求解：

$
  R = integral_a^(a + "PE") Alpha thin d"WM'"
  = integral_a^(a + "PE") [1 - (1 - wm / WMM)^b] thin d"WM'" \
  = "PE" - integral_a^(a + "PE") (1 - wm / WMM)^b thin d"WM'" \
  = "PE" + WMM/(b+1) (1 - wm/WMM)^(b+1) |_a^(a+"PE") \
  = "PE" + WMM/(b + 1) [(1 - (a + "PE")/WMM)^(b+1) - (1 - a/WMM)^(b+1)] \
  = "PE" + WM [(1 - (a + "PE")/WMM)^(b+1) - (1 - a/WMM)^(b+1)] \
  = "PE" + WM (1 - (a + "PE")/WMM)^(b+1) + W - WM
$

当$"PE" >= 0$时，根据水量平衡，下一时刻的土壤蓄水量为：

$
  W_(t+1) = W_t + "PE" - R = cases(
    WM [1 - (1 - (a + "PE") / WMM)^(b+1)] & a + "PE" < WMM,
    WM & a + "PE" >= WMM
  )
$

