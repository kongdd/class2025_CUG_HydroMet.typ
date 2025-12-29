#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")


= 1 分布式汇流方法

== 1.1 曼宁公式

#mitex(
  `$$
V = \frac{R_h^{2/3}}{n}S^{1/2}, R_h = A/P
$$`,
)

#mitex(
  `$$
Q = V A = \frac{A^{5/3}}{n P^{2/3}} S^{1/2}
$$`,
) <eq_manning_q>

== 1.2 运动波方程

=== 1.2.1 圣维南方程推导

该方程由法国科学家圣维南在1871年提出。

- $I$：入流$m^3\/s$，$Q(x, t)$
- $O$: 出流$m^3\/s$，$Q(x + delta(x), t)$
- $A(x, t)$: 河道过水断面平均面积$m^2$
- $W_1$: $t_1$时刻河道的水储量$m^3$，$A(x, t) delta(x)$
- $W_2$: $t_2$时刻河道的水储量$m^3$，$A(x, t + delta(t)) delta(x)$
- $W_"part"$: 区间径流对应的水量，$m^3$

#beamer-block[
  对于一个微小距离$delta(x)$，$W = A times Delta X$；对于一个固定点$x$，两个时刻$t + delta(t)$，蓄水量变化为$[A(x, t + delta(t)) - A(x, t)] delta(x)$。
]

根据连续性原理

$
  (I - O) delta(t) + q = W_2 - W_1 \
  [Q(x, t) - Q(x + delta(x), t)] delta(t) + W_"part" = [A(x, t + delta(t)) - A(x, t)] delta(x) \
  [ Q(x + delta(x), t) - Q(x, t)] / delta(x) + [A(x, t + delta(t)) - A(x, t)] / delta(t) = W_"part" / (delta(x) delta(t))
$

令$q = W_"part" / (delta(x) delta(t))$，可得
$
  pdv(Q, x) + pdv(A, t) = q
$

对于河道汇流，q是区间径流对应的流量Q除以汇流长度$delta(x)$；

对于坡面，q是下渗速率$m^3\/s$除以坡面长度$delta(x)$。


=== 1.2.2 数值求解

以河道汇流为例，展示求解过程。这里需要结合曼宁公式与圣维南方程。

将式#[@eq_manning_q]，进行变形，A写到公式左侧，A可以写成$alpha Q^beta$的形式：

$
  A^(5/3) = Q (n P^(2/3)) / sqrt(S) \
  A = ((n P^(2/3)) / sqrt(S) )^(3/5) Q^(3/5) = alpha Q^beta
$ <eq_A>

其中，$beta$ = 0.6，$alpha = ((n P^(2/3)) / sqrt(S) )^(3/5)$。

将式#[@eq_A]，带入圣维南方程可得：

$
  pdv(A, t) = alpha beta Q^(beta - 1) pdv(Q, t)
$

$
  pdv(Q, x) + alpha beta Q^(beta - 1) pdv(Q, t) = q
$

上式在求解过程中，x为两个相邻河道断面的距离，t的求解的时间步长，Q是需要求解的变量。已知上断面的入流量，求解下断面的出流量。后续可采用数学偏微分的方法进行求解，详见Chow 1971 章节9。

= 2 集总式汇流方法

== 2.1 线性水库

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


== 2.2 单位线

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
