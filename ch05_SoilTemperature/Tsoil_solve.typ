#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")


== 5.2 数值求解——复杂版 三角矩阵

#highlight()[如何求解土壤温度随时间的变化？] 主要用的是1个核心公式，式@eq_heat。

=== 5.2.1 差分方法

// 式#[@eq_heat]的差分方法有三种：

*显式差分* （explicit），又称向前差分，空间偏微分求解用的是历史时刻。

$ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v ( (T_(i-1)^(n) - 2T_i^n + T_(i+1)^n) / delta(z^2) ) $

令$M = kappa / c_v delta(t) / delta(z^2)$，可以直接得到下一时刻的温度：

$ M T_(i-1)^n + (1 - 2M) T_i^n + M T_(i+1)^n = T_i^(n+1) $

#beamer-block([这种方法的优点是简单，但是需要满足稳定性条件$M≤1/2$，稳定性相对较差。])

*隐式差分*（implicit），又称向后差分，空间偏微分求解用的是未来时刻。

$ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v ( (T_(i-1)^(n+1) - 2T_i^(n+1) + T_(i+1)^(n+1)) / delta(z^2) ) $

$ -M T_(i-1)^(n+1) + (1+2M) T_(i)^(n+1) - M T_(i+1)^(n+1) = T_i^n $

#beamer-block([稳定性条件$M>0$，稳定性相对较好。])

// 第一个时刻，$i=1$，
// $ c_v (T_i^(n+1) - T_i^(n)) / delta(t) = -( F_0 - kappa / delta(z) (T_i^(n+1) - T_(i+1)^(n+1))) / delta(z) ) $

*中间差分*（Cran-Nicolson），空间偏微分求解用的是历史和未来时刻。

$
  (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v (
    (T_(i-1)^(n) - 2T_i^n + T_(i+1)^n) / (2 delta(z^2)) +
    (T_(i-1)^(n+1) - 2T_i^(n+1) + T_(i+1)^(n+1)) / (2 delta(z^2))
  )
$



=== 5.2.2 求解过程

*(a) 隐式差分为例，展示求解过程。*

#let kappa-coef(i) = {
  // let p = $i+1/2$
  $kappa_#i / delta(z_#i)$
}

// #let cal_F(i) = {
//   // let i = $i+1$
//   $ - #kappa-coef(#i+1/2) (T_i^(n+1) - T_(i+1)^(n+1)) $
// }
// $ #cal_F(i) $

$
  F_i^n = - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \
  F_(i-1)^n = - #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) \
$

$ c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = -(F_(i-1)^n - F_i^n) $ <eq_5_11>

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \
$ <eq_5_12>

$
  - #kappa-coef($i-1/2$) T_(i-1)^(n+1) + (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$)) T_i^(n+1) - #kappa-coef($i+1/2$) T_(i+1)^(n+1) = c_(v, i) delta(z_i) T_i^n / delta(t)
$

其中，$delta(z_i) = z_(i-1) - z_i$。上式可以写成矩阵形式：

$ a_i T_(i-1)^(n+1) + b_i T_i^(n+1) + c_i T_(i+1)^(n+1) = d_i $

之后便可利用三角阵的方式进行求解。

#figure(
  image("Figures/三角阵求解.png", width: 70%),
  caption: [三角阵求解。],
) <fig_>

#highlight()[TODO: 补充公式推导过程。]

*边界条件*

对于第一层：

- 已知通量：土壤热通量$F_0$（也是能量平衡中的$G$），带入式#[@eq_5_11]：

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = -F_0 - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \
$

$
  (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i+1/2$) ) T_i^(n+1)
  - #kappa-coef($i+1/2$) T_(i+1)^(n+1) = -F_0 + c_(v, i) delta(z_i) T_i^n / delta(t)
$

- 已知状态：土壤温度$T_0^(n+1)$，带入式#[@eq_5_12]：

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(0)^(n+1) - T_(i)^(n+1)) - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \
$

$
  (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$)) T_i^(n+1) - #kappa-coef($i+1/2$) T_(i+1)^(n+1) = c_(v, i) delta(z_i) T_i^n / delta(t) + #kappa-coef($i-1/2$) T_(0)^(n+1)
$

对于第N层，认为$F_N = 0$，，带入式#[@eq_5_11]：

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) - F_N
$

$
  - #kappa-coef($i-1/2$) T_(i-1)^(n+1) + (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) ) T_i^(n+1) = -F_N + c_(v, i) delta(z_i) T_i^n / delta(t)
$


*(b) 另一种解法，根据变化量$delta(T_i^n)$ （本科生跳过）*

定义$delta(T_i^n) = T_i^(n+1) - T_i^(n)$。

$
  T_(i-1)^(n+1) & = (T_(i-1)^(n+1) - T_(i-1)^(n)) + T_(i-1)^(n) = delta(T_(i-1)^n) + T_(i-1)^(n) \
    T_(i)^(n+1) & = (T_(i)^(n+1) - T_(i)^(n)) + T_(i)^(n) = delta(T_(i)^n) + T_(i)^(n) \
  T_(i+1)^(n+1) & = (T_(i+1)^(n+1) - T_(i+1)^(n)) + T_(i+1)^(n) = delta(T_(i+1)^n) + T_(i+1)^(n)
$

式#[@eq_5_12]可以写成：

$
  c_(v, i) delta(z_i) delta(T_i^n) / delta(t) =
  #kappa-coef($i-1/2$) [ delta(T_(i-1)^n) + T_(i-1)^(n) -(delta(T_(i)^n) + T_(i)^(n) ) ] \
  - #kappa-coef($i+1/2$) [ delta(T_(i)^n) + T_(i)^(n) -(delta(T_(i+1)^n) + T_(i+1)^(n) ) ]
$

$
  - #kappa-coef($i-1/2$) delta(T_(i-1)^n) +
  (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$)) delta(T_(i)^n)
  -#kappa-coef($i+1/2$) delta(T_(i+1)^n) = \
  #kappa-coef($i-1/2$) (T_(i-1)^(n) - T_(i)^(n)) - #kappa-coef($i+1/2$) (T_(i)^(n) - T_(i+1)^(n))
$

*边界条件*

对于第一层：

- 已知通量：土壤热通量$F_0$（也是能量平衡中的$G$），带入式#[@eq_5_11]：

$
  c_(v, i) delta(z_i) delta(T_i^n) / delta(t) = -F_0 -
  #kappa-coef($i+1/2$) [ delta(T_(i)^n) + T_(i)^(n) -(delta(T_(i+1)^n) + T_(i+1)^(n) ) ] \
$

$
  (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i+1/2$) ) delta(T_i^n)
  - #kappa-coef($i+1/2$) delta(T_(i+1)^n) = -F_0 - #kappa-coef($i+1/2$) (T_(i)^(n) - T_(i+1)^(n))
$


- 已知状态：土壤温度$T_0^(n+1)$，带入式#[@eq_5_12]：

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(0)^(n+1) - T_(i)^(n+1)) - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \
$

$
  c_(v, i) delta(z_i) delta(T_i^n) / delta(t) =
  #kappa-coef($i-1/2$) (T_(0)^(n+1) - (delta(T_(i)^n) + T_(i)^(n) ) )
  -#kappa-coef($i+1/2$) [ delta(T_(i)^n) + T_(i)^(n) -(delta(T_(i+1)^n) + T_(i+1)^(n) ) ]
$

$
  ( c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$) )delta(T_i^n)
  - #kappa-coef($i+1/2$) delta(T_i^(n+1)) = \
  #kappa-coef($i-1/2$) (T_(0)^(n+1) - T_(i)^(n)) - #kappa-coef($i+1/2$) (T_i^(n) - T_(i+1)^(n))
$



// 对于第N层，认为$F_N = 0$，，带入式#[@eq_5_11]：

// $
//    c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) - F_N
// $

// $
//   - #kappa-coef($i-1/2$) T_(i-1)^(n+1) + (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) ) T_i^(n+1) = -F_N + c_(v, i) delta(z_i) T_i^n / delta(t)
// $
