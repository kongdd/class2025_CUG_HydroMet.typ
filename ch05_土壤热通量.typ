
#import "config.typ": *
#counter(heading).update(4)
#let delta(x) = $Delta #x$
#show math.equation: set text(11.5pt)

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "辐射与能量平衡")

= 土壤热通量

== 基本公式

#figure(
  image("images/土壤热通量/土壤热通量_连续性原理.png", width: 100%),
  caption: [
    （a）土壤通量与土壤温度连续性原理示意图；（b）土壤分层说明。
    $z_i$代表的是每一层土壤的中间位置；$z_(i+1/2)$代表的是每层土壤的下边界。$z$与$F$均是向下为负。
  ]
) <fig_Tsoil_cont>

*热通量公式：*

$ F = - kappa pdv(T, z) $

- $kappa$: 热传导系数，$"W"\/m\/K$；
- $F$: 土壤热通量，$"W"\/m^2$；
- 负号代表土壤热通量向下为负。

*连续性原理：*

$ rho c_v^\* delta(x) delta(y) delta(z) delta(T) =  -(F_"in" - F_"out") delta(x) delta(y) delta(t) $

$ c_v delta(T) / delta(t) = - delta(F) / delta(z), c_v = rho c_v^\* $

其中，$c_v$是体积热容量（volumetric heat capacity，$J m^(-3)s^(-1)$)。写成偏微分形式，则是：

$ c_v pdv(T, t) = - pdv(F, z) = kappa pdv(T, z, 2) $ <eq_heat>

#pagebreak()

== 数值求解——复杂版 三角矩阵

大气系气象观测站，土壤温度过程如下图。

#highlight()[如何求解土壤温度随时间的变化？] 主要用的是一个1个核心公式，式@eq_heat。

=== 差分方法

式#[@eq_heat]的差分方法有三种：

*显式差分* （explicit），又称向前差分，空间偏微分求解用的是历史时刻。

  $ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v ( (T_(i-1)^(n) - 2T_i^n + T_(i+1)^n) / delta(z^2) ) $

  令$M = kappa / c_v delta(t) / delta(z^2)$，可以直接得到下一时刻的温度：

  $ M T_(i-1)^n + (1 - 2M) T_i^n + M T_(i+1)^n = T_i^(n+1) $

  #beamer_block([这种方法的优点是简单，但是需要满足稳定性条件$M≤1/2$，稳定性相对较差。])

*隐式差分*（implicit），又称向后差分，空间偏微分求解用的是未来时刻。

$ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v ( (T_(i-1)^(n+1) - 2T_i^(n+1) + T_(i+1)^(n+1)) / delta(z^2) ) $

$ -M T_(i-1)^(n+1) + (1+2M) T_(i)^(n+1) - M T_(i+1)^(n+1) = T_i^n $

#beamer_block([稳定性条件$M>0$，稳定性相对较好。])

// 第一个时刻，$i=1$，
// $ c_v (T_i^(n+1) - T_i^(n)) / delta(t) = -( F_0 - kappa / delta(z) (T_i^(n+1) - T_(i+1)^(n+1))) / delta(z) ) $

*中间差分*（Cran-Nicolson），空间偏微分求解用的是历史和未来时刻。

$ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v (  
  (T_(i-1)^(n) - 2T_i^n + T_(i+1)^n) / (2 delta(z^2)) + 
  (T_(i-1)^(n+1) - 2T_i^(n+1) + T_(i+1)^(n+1)) / (2 delta(z^2))
) $

=== 求解过程


== 数值求解——简易版 偏微分方程



