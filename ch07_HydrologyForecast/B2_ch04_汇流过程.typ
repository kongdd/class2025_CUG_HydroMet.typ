#import "@local/modern-cug-report:0.1.3": *

#show: doc => template(doc, size: 11.5pt, footer: "CUG水文气象学2024", header: "坡面与河道汇流")
#counter(heading).update(3)
#set par(leading: 1.24em)
#let delta(x) = $Delta #x$

// != 坡面与河道汇流

// !== 2.1 特征河长

== 1 滞后线性水库

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


== 2 马斯京根（Muskingum）

$
  W & = K [X I + (1 - X) O] \
    & = K [O + X (I - O)]
$

X反映的楔形度，值域在0\~0.5。

根据连续性原理，可以写出：

$ (I - O) delta(t) = delta(W) $

$
  [(I_1 + I_2) / 2 - (O_1 + O_2) / 2]delta(t) = K { [O_2 + X (I_2 - O_2)] - [O_1 + X (I_1 - O_1)] } \
  [(I_1 + I_2 - O_1) - O_2]delta(t) = 2K [(1 - X)O_2 + X I_2 - O_1 - X (I_1 - O_1) ] \
  2K [1 - X] O_2 + O_2delta(t) = (I_1 + I_2 - O_1)delta(t) + 2K [O_1 + X (I_1 - O_1) - X I_2] \
  O_2 = ((I_1 + I_2 - O_1)delta(t) + 2K [O_1 + X (I_1 - O_1) - X I_2])/ (delta(t) + 2K [1 - X]) \
  O_2 = [(delta(t) + 2K X)I_1 + (delta(t) - 2K X)I_2 + (-delta(t) + 2K - 2K X) O_1] / (delta(t) + 2K [1 - X])
$

整理得：
$
  O_2 = C_0 I_2 + C_1 I_1 + C_2 O_1 \
$

$
  C_0 = (delta(t) - 2K X) / (delta(t) + 2K [1 - X]),
  C_1 = (delta(t) + 2K X) / (delta(t) + 2K [1 - X]),
  C_2 = (-delta(t) + 2K - 2K X) / (delta(t) + 2K [1 - X])
$
上式即为马斯京根公式。



== 3 `n`段特征河长

#figure(
  image("Figures/n段特征河长.png", width: 60%),
  caption: [n段特征河长示意图。图件来自芮孝芳(2002,水科学进展)],
) <fig_>

// *特征河长*
$ W = K O $

- $delta(x)$: 河段长；
- $K$: 洪水波在河段内的传播时间；
- $l$: 特征河长

因此，河道可以划分为n个特征河长，$n = delta(x) / l$；在特征河长中的洪水传播时间为$K_j = K / n = K l / delta(x)$。

假设在河段长$delta(x)$内流量沿程呈线性变化,
则其中第j个特征河长下断面的流量$O_j$可写为：

$ O_j = O + (I - O) / delta(x) (n -j)l, n = delta(x) / l $

$ O_j = O + (I - O) / delta(x) (delta(x) - j l) $

根据特征河长的定义：

$
  W_j = K_j O_j
  = K / n [O + (I - O) / delta(x) (delta(x) - j l)]
$

总槽蓄量为n个特征河长的叠加：

$
  W = sum_(j=1)^(n) W_j = & sum_(j=1)^(n) K / n [O + (I - O) / delta(x) (delta(x) - j l)] \
                        = & K [ O + (I - O) - (I - O)(n + 1) l / (2 delta(x))] \
  //  =& K [ O + (I - O)[1 - (n + 1) l / (2 delta(x))] \
                        = & K [ O + (I - O)[1 - (delta(x) + l) / (2 delta(x))] \
$

回顾，Muskingum的槽蓄方程：

$
  W & = K [X I + (1 - X) O] \
    & = K [O + X (I - O)]
$

联立，上述两个公式，可得：

$ X = 1 / 2 - l / (2 delta(x)) $
