#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")


*2. 三角矩阵法。*

当第一层土壤足够薄，可认为$T_1 = T_s$，此时土壤热通量不能再采用$kappa / delta(z)$的形式，采用符号F0来进行代替。

$ F_0 = f(T_1) = Q_a - epsilon sigma T_s^4 - (rho c_p (e_"surf" - e) ) / (gamma r_v) - (rho c_p (T_1 - T_a)) / r_H $

F0求$T_s$的偏导，可得：

$
  pdv(F_0, T_s) = -4 epsilon sigma T_s^3 - (rho c_p pdv(e_"surf", T_s) ) / (gamma r_v) - (rho c_p) / r_H
$ <eq_pdv_F0-T_s>

// == 土壤热通量

对于第一层土壤，根据连续性原理，可得：

#let kappa-coef() = {
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
  T_i^(n+1) - T_(i+1)^(n+1) & = (T_i^(n+1) - T_i^(n) + T_i^(n)) - (T_(i+1)^(n+1) - T_(i+1)^(n) + T_(i+1)^(n)) \
                            & = delta(T_i^n) - delta(T_(i+1)^n) + T_i^n - T_(i+1)^n
$

$
  (c_(v,i) delta(z_i)) / delta(t) delta(T_i^n) = F_0(T_i^(n)) + pdv(F_0(T_i^n), T_i) delta(T_i^n) -
  #kappa-coef() ( delta(T_i^n) - delta(T_(i+1)^n) + T_i^n - T_(i+1)^n )
$

$
  ((c_(v,i) delta(z_i)) / delta(t) - pdv(F_0(T_i^n), T_i) - #kappa-coef() ) delta(T_i^n)
  - #kappa-coef() delta(T_(i+1)^n) = \
  F_0(T_i^(n)) - #kappa-coef() (T_i^n - T_(i+1)^n)
$ <eq_Tsoil_solve>

之后，可以用三角矩阵的方式进行求解。

$ a_i delta(T_(i-1)^n) + b_i delta(T_i^n) + c_i delta(T_(i+1)^n) = d_i $

将式#[@eq_Tsoil_solve]带入，可得：
$a_i = 0$，$b_i = (c_(v,i) delta(z_i)) / delta(t) - pdv(F_0(T_i^n), T_i) - #kappa-coef()$,
$c_i = #kappa-coef()$，$d_i = F_0(T_i^(n)) - #kappa-coef() (T_i^n - T_(i+1)^n)$。
上述公式推导针对的土壤第一层（$i=1$），其他层的系数，详见Bonan 2019, Table 7.1。
