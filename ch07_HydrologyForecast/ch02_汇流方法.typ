#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

= 2 *汇流方法*

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

== 2.2 滞后线性水库

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

== 2.3 单位线

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
