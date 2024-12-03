#import "config.typ": *
#counter(heading).update(3)
#let delta(x) = $Delta #x$
#show math.equation: set text(11.5pt)

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "辐射与能量平衡")

= 辐射与能量平衡

== 能量平衡

水文学研究中两个主要的公式：水量平衡与能量平衡。能量平衡公式如下：

$ R_n - G = lambda E + H $ <eq_energy>

其中，$R_n$是净辐射，$G$是土壤热通量，$lambda E$是蒸发潜热通量，$H$是感热通量。

基于蒸散发的基本原理，可知：

$ lambda E = (lambda rho delta(q)) / r_v = (rho c_p delta(e)) / (gamma r_v) $
$ H = (rho c_p delta(T)) / r_H $

- $R_n$: 净辐射，MJ
- $lambda$: 汽化潜热，2.5 MJ / kg
- $gamma$：湿度计常数
- $rho$: 空气密度，$"kg"\/m^3$
- $r_v$, $r_H$：分别是水汽和热量的传导阻力。

*类似于浓度扩散、以及达西定律，$lambda E$、$H$和$G$公式形式皆是梯度×扩散效率系数的形式。*土壤热通量的表达形式如下：

$ G = kappa / delta(z) (T_s - T_1) $

- $kappa$: 热传导系数，$"W"\/m^2\/K$
- $T_s$：地表温度
- $T_1$：第一层土壤的温度
- $delta(z)$: 第一层土壤的厚度

#beamer_block([这里需要注意，公式1中所有变量都是通量的概念。])

== 地表净辐射

地表净辐射，主要包括长波净辐射和短波净辐射。

$ R_n = "Rns" + "Rnl" = (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 $ <eq_Rn>

- $R_s$: 入射短波辐射；
- $"Rln"$：入射长波辐射；
- $T_s$: 地表温度；
- $alpha$: 地表反射率；
- $epsilon$: 地表辐射率；
- $sigma$: 斯特藩-玻尔兹曼常数(Stefan-Boltzmann constant)，$σ=5.67×10^(-8) W (m^(-2) K^(-4)）$。

#beamer_block([上式的推导，涉及辐射的三个基本定律。])

*公式的应用：*

辐射会加热地表和空气；地表温度升高则向外长波辐射增加，使Rn减少。二者相互作用，最终会达到均衡。


联立式#[@eq_energy]和#[@eq_Rn]，可得：

$
  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p delta(e)) / (gamma r_v) + (rho c_p delta(T)) / r_H \

  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p (e_"surf" - e) ) / (gamma r_v) + (rho c_p (T_s - T_a)) / r_H
$

把变量移到左边，令$Q_a = (1 - alpha) R_s + epsilon"Rln"$，得到：

$ Q_a = epsilon sigma T_s^4 + kappa / delta(z) (T_s - T_1) + (rho c_p (e_"surf" - e) ) / (gamma r_v) + (rho c_p (T_s - T_a)) / r_H $

$ f(T_s) = Q_a - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) - (rho c_p (e_"surf" - e) ) / (gamma r_v) - (rho c_p (T_s - T_a)) / r_H = 0 $


#highlight()[两种求解方法：]

*1. 牛顿梯度降。*

土壤有一个表皮温度T_s（skin temperature），表皮温度与第一层土壤的平均温度，有所不同。

$ T_(s, "next") = T_s - f(T_s) / pdv(f, T_s) $

*2. 三角矩阵法。*

当第一层土壤足够薄，可认为$T_1 = T_s$，此时土壤热通量不能再采用$kappa / delta(z)$的形式，采用符号F0来进行代替。

$ F_0 = f(T_1) = Q_a - epsilon sigma T_s^4 - (rho c_p (e_"surf" - e) ) / (gamma r_v) - (rho c_p (T_1 - T_a)) / r_H $

F0求$T_1$的偏导，可得：

$
  pdv(F_0, T_s) = -4 epsilon sigma T_s^3 - (rho c_p pdv(e_"surf", T_1) ) / (gamma r_v) - (rho c_p) / r_H
$ <eq_pdv_F0-T_s>

// == 土壤热通量

对于第一层土壤，根据连续性原理，可得：

#let kappa-coef()={
  let p = $i+1/2$
  $kappa_#p / delta(z_#p)$
}

$
  c_(v,i) delta(z_i) / delta(t) (T_i^(n+1) - T_i^(n)) =F_0(T_i^(n+1)) - #kappa-coef() (T_i^(n+1) - T_(i+1)^(n+1))
$ <eq_Ts1>

其中，下标$i$表示第i层土壤，上标$n$表示第n个时间步。

*该公式是求解土壤温度的关键。* 主要难点在于不知道$n+1$时刻的状态，包括$F_0(T_i^(n+1))$、$T_i^(n+1)$和$T_(i+1)^(n+1)$。

根据微积分法则，$F_0(T_i^(n+1))$可通过如下公式进行替换，以消减一个未知变量：
$ F_0(T_i^(n+1)) = F_0(T_i^(n)) + pdv(F_0(T_i^n), T_i) (T_i^(n+1) - T_i^(n)) $ <eq_F0>

其中，$pdv(F_0(T_i^n), T_i)$可通过式#[@eq_pdv_F0-T_s]判定。

将式#[@eq_F0]得到的$F_0(T_i^(n+1))$，重新代入#[@eq_Ts1]，可得：

$
  c_(v,i) delta(z_i) / delta(t) (T_i^(n+1) - T_i^(n)) = \
    F_0(T_i^(n)) + pdv(F_0(T_i^n), T_i) (T_i^(n+1) - T_i^(n)) - #kappa-coef() (T_i^(n+1) - T_(i+1)^(n+1)) 
$

令$delta(T_i^n) = T_i^(n+1) - T_i^(n)$，

$
  T_i^(n+1) - T_(i+1)^(n+1) &= (T_i^(n+1) - T_i^(n) + T_i^(n)) -  (T_(i+1)^(n+1) - T_(i+1)^(n) + T_(i+1)^(n)) \
    &= delta(T_i^n) - delta(T_(i+1)^n) + T_i^n - T_(i+1)^n
$

$
  (c_(v,i) delta(z_i)) / delta(t) delta(T_i^n) = F_0(T_i^(n)) + pdv(F_0(T_i^n), T_i) delta(T_i^n) - 
    #kappa-coef() ( delta(T_i^n) - delta(T_(i+1)^n) + T_i^n - T_(i+1)^n )
$

$
  ((c_(v,i) delta(z_i)) / delta(t) - pdv(F_0(T_i^n), T_i) - #kappa-coef() )  delta(T_i^n) 
    - #kappa-coef() delta(T_(i+1)^n) = \ 
    F_0(T_i^(n)) - #kappa-coef() (T_i^n - T_(i+1)^n)
$ <eq_Tsoil_solve>

之后，可以用三角矩阵的方式进行求解。

$ a_i delta(T_(i-1)^n) + b_i delta(T_i^n) + c_i delta(T_(i+1)^n) = d_i $

将式#[@eq_Tsoil_solve]带入，可得：
$a_i = 0$，$b_i = (c_(v,i) delta(z_i)) / delta(t) - pdv(F_0(T_i^n), T_i) - #kappa-coef() $, 
$c_i = #kappa-coef()$，$d_i = F_0(T_i^(n)) - #kappa-coef() (T_i^n - T_(i+1)^n)$。
上述公式推导针对的土壤第一层（$i=1$），其他层的系数，详见Bonan 2019, Table 7.1。
