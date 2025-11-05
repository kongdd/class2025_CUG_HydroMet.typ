#import "typst/lib.typ": *

#show: (doc) => template(doc, 
  size: 11.5pt,
  footer: "CUG水文气象学2024",
  header: "坡面与河道汇流")
#counter(heading).update(5)
#set par(leading: 1.24em)
#let delta(x) = $Delta #x$

= 坡面与河道汇流

== 曼宁公式

#mitex(`$$
V = \frac{R_h^{2/3}}{n}S^{1/2}, R_h = A/P
$$`)

#mitex(`$$
Q = V A = \frac{A^{5/3}}{n P^{2/3}} S^{1/2}
$$`) <eq_manning_q>

== 运动波方程

=== 圣维南方程推导

该方程由法国科学家圣维南在1871年提出。

- $I$：入流$m^3\/s$，$Q(x, t)$
- $O$: 出流$m^3\/s$，$Q(x + delta(x), t)$
- $A(x, t)$: 河道过水断面平均面积$m^2$
- $W_1$: $t_1$时刻河道的水储量$m^3$，$A(x, t) delta(x)$
- $W_2$: $t_2$时刻河道的水储量$m^3$，$A(x, t + delta(t)) delta(x)$
- $W_"part"$: 区间径流对应的水量，$m^3$

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


=== 数值求解

以河道汇流为例，展示求解过程。这里需要结合曼宁公式与圣维南方程。

将式#[@eq_manning_q]，进行变形，A写到公式左侧，A可以写成$alpha Q ^ beta$的形式：

$
  A^(5/3) = Q (n P^(2/3)) / sqrt(S) \
  A = ((n P^(2/3)) / sqrt(S) )^(3/5) Q ^ (3/5)  = alpha Q ^ beta
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

== 特征河长



== 马斯京根（Muskingum）

$
  W &= K [X I + (1 - X) O] \ 
    &= K [O + X (I - O)]
$

X反映的楔形度，值域在0\~0.5。

根据连续性原理，可以写出：

$ (I - O) delta(t) = delta(W) $

$
  [(I_1 + I_2) / 2 - (O_1 + O_2) / 2]delta(t)  = K { [O_2 + X (I_2 - O_2)] - [O_1 + X (I_1 - O_1)] } \
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



== `n`段特征河长

#figure(
  image("images/河道汇流/n段特征河长.png", width: 60%),
  caption: [n段特征河长示意图。图件来自芮孝芳(2002,水科学进展)]
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
  W = sum_(j=1)^(n) W_j =& sum_(j=1)^(n) K / n [O + (I - O) / delta(x) (delta(x) - j l)] \
   =& K [ O + (I - O) - (I - O)(n + 1) l / (2 delta(x))] \
  //  =& K [ O + (I - O)[1 - (n + 1) l / (2 delta(x))] \
   =& K [ O + (I - O)[1 - (delta(x) + l) / (2 delta(x))] \
$

回顾，Muskingum的槽蓄方程：

$
  W &= K [X I + (1 - X) O] \ 
    &= K [O + X (I - O)]
$

联立，上述两个公式，可得：

$ X = 1 / 2 - l / (2 delta(x)) $
