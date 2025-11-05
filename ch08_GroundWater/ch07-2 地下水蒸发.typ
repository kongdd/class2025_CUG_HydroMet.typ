#import "./typst/lib.typ": *

#show: doc => template(
  doc,
  size: 12pt,
  footer: "CUG水文气象学2025",
  header: "地下水蒸发",
)
#show math.equation: rm-bracket

#counter(heading).update(7)
#let delta(x) = $Delta #x$

#set par(
  leading: 1em,
  spacing: 1.24em,
  justify: true,
)

// #par(leading: 1.2em)
//
// =
// =
// =
// =
// =
// =
// = 7 地下水蒸发

== 7.1 基本概念

#v(1.0em)

#h(2em)
#Blue[井孔之内]，*水井的总水头$H_b$*包括两部分：①气压B；②地下水水位h。

$ alpha = -delta(h) / delta(B), delta(h) = -alpha delta(B) $

$ delta(H_b) = delta(B) + delta(h) = (1 - alpha) Delta B $

// #h(2em)
#box-blue[
  气压系数$alpha = -delta(h) / delta(B)$，指的是单位气压变化，引起的地下水水位变化量。
]

#h(2em)
#Blue[井孔之外]，地表质量负荷的变化$Δ L$由地层骨架$B$和地下水体$S$共同承担，总水头$H_a$：

$ delta(H_a) = beta (delta(B) + delta(S)) $

#box-blue[
  负荷系数$beta = delta(H_a) / delta(B)$，指的是单位气压变化，引起的地下水水位变化量。
]

一般情况下，井孔内水体的水头与井孔外水体水头相等，$delta(H_b) = delta(H_a)$，也即是：

$
  (1 - alpha) delta(B) = beta (delta(B) + delta(S)) \
  delta(S) = ((1 - alpha) delta(B)) / beta - delta(B) = 1/beta (1 - alpha - beta) delta(B)
$

#h(2em)
#Blue[*根据水量平衡*]，

$ delta(S) = P - "ET" - R_s - delta(R_g), (R_s = Phi P) $

其中，$Phi$为径流系数；$R_g$是地下水的侧向流动通量散度（流入量-流出量）。


== 7.2 井水位的气压响应模式

=== 7.2.1 承压井

#h(2em)
对于承压井，气压变化时（_这里指的是地下水界面_），#Blue[井孔范围外的压力负荷由地层骨架和承压水体共同承担]；*井孔范围内的压力负荷全部由井水承担*，因此井孔范围内、外的水体之间出现了一个压力差（#Blue[井内压力较大]）。

- 有些承压观测井周围地层骨架弹性好，井水位的变化迅速，压力差迅速消失，称为 “*承压井水位快速响应型*”；

- 有些承压观测井井孔容积较大，井壁的渗透性较差，气压变化造成的井孔范围内、外水体间的水头差不能迅速消失，井水位的变化需要一个时间过程，称为 “*井孔容量或井壁影响型*”；（#Blue[*井内最先响应*]，变为0，#underline[需要进一步学习Furbish 1991]）


=== 7.2.2 非承压井

#h(2em)
对非承压观测井，当气压变化时，由于包气带内土壤空气可压缩的原因，#Blue[井孔范围外水头变化缓慢]；*井孔内水头、水位变化迅速。*
随着时间的推移，井孔内外水头慢慢一致，井水位又恢复到气压变化前的水平，此种响应称为 “*非承压井水位滞后响应型*”。

