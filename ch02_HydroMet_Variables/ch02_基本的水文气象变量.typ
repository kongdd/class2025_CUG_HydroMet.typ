#import "@local/modern-cug-report:0.1.3": *
#show: (doc) => template(doc, 
  size: 13pt,
  footer: "CUG水文气象学2025",
  header: "第2章 基本的水文气象变量")
#counter(heading).update(2)

#let delta(x) = $Delta #x$

#set par(leading: 1.0em, spacing: 1.2em)
#show list: it => {
  v(-0.2em)
  it
  v(-0.2em)
}

= 1 物理基础

== 1.1 空气的组成

#figure(
  image("Figures/大气的成分.png", width: 100%),
  caption: [
    近地表大气组成成分。
  ]
) <fig_ch2_air_component>

#v(-0.5em)
#figure(
  image("Figures/大气的比湿.png", width: 80%),
  caption: [
    大气饱和比湿$q_"sat"$随温度与气压变化， $q$水汽质量与空气质量之比$m_v / (m_d + m_v)$。
  ]
) <fig_ch2_q>

#box-red[
  为何近地表与高空饱和比湿$q_"sat"$不同？为何温度会对$q_"sat"$有影响？
]


== 1.2 气压

#v(0.3em)

*气压*：气体对某一点施加的流体静力压强，来源是大气层中空气的重力，即为单位面积上的大气压力。单位：帕斯卡，简称帕（Pa, 1 N/m2）。

在海平面的平均气压约为1013.25 hPa（76cm水银柱），这个值也被称为*1标准大气压*（简称$1"atm"$）。

$
  P = F / A = (m g) / A = ((m_d + m_v) g) / A
$

- $m_d$: 干空气的质量
- $m_v$: 水汽的质量

通常所说的气压$p$，包含了干空气的气压和水汽的气压。
#box-blue[水汽的气压一般用符号$e$表示；干空气的气压为：$p - e$。]

=== 1.2.1 饱和水汽压

*饱和水汽压*：指一定体积空气，在某一温度条件下#Blue[*所能容纳的最大水汽量*]所对应的水汽压，用$e_s$表示。饱和水汽压随温度升高而升高。公式形式为：

$ e_s (T_a) = 0.618 exp ( (17.27 T_a) / (T_a + 237.3)) $

$ Delta = (4098 e_s (T_a) ) / (T_a + 237.3)^2 $

其中，$e_s (T_a)$为饱和水汽压，kPa；$T_a$为空气温度，℃；$Delta$为饱和水汽压的斜率。

#figure(
  image("Figures/Figure1_es_slope.pdf", width: 90%),
  caption: [
    饱和水汽压$e_s (T_a)$与饱和水汽压梯度$Delta$随气温变化。
  ]
) <fig_>



== 1.3 理想气体状态方程

根据大量的科学实验总结出，一切气体在压强不太大，温度不太低（远离绝对零度）的条件下，一定质量气体的压强和体积的乘积除以其绝对温度等于常数，即:

$
  (P_1 V_1) / T_1 = (P_2 V_2) / T_2 = ... = (P_2 V_2) / T_2 = (P V) / T = "常量"
$

$ P V = n R^* T = m R^(*)/M T $
$ P = rho R T $

- P: 压强，单位$"Pa"$；
- V: 体积，单位$m^3$；
- n: 气体的摩尔数，单位$"mol"$；M: 气体的摩尔质量，单位$"kg/mol"$；
- $R^*$: 理想气体常数，单位$J\/("mol" K)$；
- $R$: 比气体常数，$R = R^* \/ M$, 单位$J\/("kg" K)$；
- T: 温度，单位$K$；
- m: 气体的质量，单位$"kg"$；
- $rho$: 气体的密度，单位$"kg"\/m^3$。

根据高中化学，标准状态下(273K, 1atm) ，1mol气体的体积为22.4L，带入上述公式，可得：

#mitex(`$$
\begin{align*}
R^* &= \frac{p V}{n T} \\
&= \frac{1.013 × 10^5 Pa × 22.4× 10^{-3} m^3 }{1mol × 273K} \\
&= 8.31 Pa·m^3 / (mol·K) = 8.31 J / (mol·K)
\end{align*}
$$`)

=== 1.3.1 干空气与湿空气

干空气与水汽的相对分子质量，分别用符号$R_d$和$R_v$来表示（下标$\_d$表示dry，$\_v$表示water）。

根据高中化学可知，$M_d = 28.97 g\/"mol", M_v = 18 g\/"mol"$。带入上述公式，可得

- 对于干空气，$R_d = R^* / M_d = 8.314 / 28.97 = 0.287 thin (J ·g^{-1}K^{-1})$
  
- 对于水汽，$R_v = R^* / M_v = 8.314 / 18 = 0.4615 thin (J ·g^{-1}K^{-1})$

$ R_d / R_v = M_v / M_d = epsilon approx 0.622 $

#mitex(`$$
  \frac{R_v}{R_d} = \frac{1}{\epsilon} ≈ 1.608
$$`)

= 2 基本的气象变量

== 2.1 水汽含量与湿度

- 混合比（mix ratio, $w$）：
  $ w = m_v \/ m_d $

- 比湿（specific humidity, $q$）：
  $ q = m_v / (m_d + m_v) $

- 绝对湿度（水汽密度，X, $rho_v$）

  $ rho_v = X = e / (R_v T) = (epsilon e) / (R_d T) $

- 相对湿度（relative humidity, RH）

  $ "RH" = e / e_s $


#beamer-block[
  *小试牛刀：*已知$e$, $P$，求$q$

  #mitex(`$$
  \begin{align*}
\rho_v &= \frac{e}{R_v T} = \frac{\epsilon e}{R_d T}, (R_v = \frac{R_d}{\epsilon}) \\
\rho_d &= \frac{P - e}{R_d T} \\
\end{align*}
  $$`)
]

详细推导见：https://cug-hydro.github.io/HydroTools.R/articles/vapour_press.html。

#mitex(`$$
\begin{align*}
q &= \frac{\rho_v}{\rho_d + \rho_v} \\
  &= \frac{\epsilon e}{p - e + \epsilon e} = \frac{\epsilon e}{p - (1 - \epsilon)e}
\end{align*}
$$`)

=== 2.1.1 水汽压与水汽密度的转换

// 对于干空气和水汽，二者的比气体常数分别采用$R_d$和$R_v$进行表示，二者的比值采用$epsilon$表示。

对于空气和水汽，分别代入理想气体状态方程，可以得到：

$ e = rho_v R_v T $

$ P = rho R T approx rho R_d T $

二者相除可以得到：

$ rho_v = rho e/P R_d / R_v = epsilon rho e /P $ <eq_rho_v>

#beamer-block()[
  混合空气的相对分子质量$M_"mix" approx$干空气的相对分子质量$M_d$。
  $x_d$, $x_v$分别是干空气和水汽的比例。
  #mitex(
    `$$
  M_{mix} = x_a M_a + x_v M_v = (1-x_v) M_a + x_v M_v \\
  = 28.97 - 10.95 x_v
  $$`,
  )
]

== 2.2 感热与潜热基础

#v(-1.0em)
=== 2.2.1 气化潜热

#showybox(
  frame: (
    // title-color: red.darken(30%),
    border-color: blue.darken(10%),
    body-color: blue.lighten(95%),
  ),
  // title: [*比热容*]
)[
  
  *气化潜热* $lambda$：单位质量的液体，气化所需要吸收的热量，$"MJ"\/"kg"$。
  $ lambda = 2.5 "MJ" "kg"^(-1) $

]

根据气化潜热$lambda$的定义，可以得到潜热$"LE"$：

$ "LE" = lambda delta(m_v) = lambda delta(rho_v) V $ <eq_le>

其中，$delta(m_v)$是蒸发导致的水汽质量的变化，$"LE"$是蒸发所需的能量，$rho_v$水汽的密度。

=== 2.2.2 比热容

#showybox(
  frame: (
    // title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(95%),
  ),
  // title: [*比热容*]
)[
  *比热容* $c_p$：单位质量的物质升高1℃所需要的能量，$J \/ ("kg" ℃)$。
  
  根据比热容$c_p$的定义，可以得到温度变化引起的感热$H$：
  $ H = c_p rho V delta(T) $ <eq_h>
]

其中，$rho$: 空气密度，$V$: 空气体积。

#beamer-block([
  *小试牛刀：*
  
  1. $R_n = 100 W m^(-2)$，能量全部转换为潜热，1天的总能量为多少？对应的蒸发量是多少mm？#highlight()[考察点：汽化潜热]
    
    #nonum([$
      "LE" = 100 W m^(-2) times 86400 s = 8.64 "MJ" \
      E = "LE"/lambda = (8.64 "MJ") / (2.5 "MJ" "kg"^(-1)) = 3.456 "kg" \
    $])
  
  2. $1m^3$的空气，温度升高1℃，需要吸收多少能量？#highlight()[考察点：比热容]
    
    空气的比热容$c_p = 1103 J \/ ("kg" ℃)$，空气的密度$rho = 1.2 "kg" \/ m^3$。
    
    #nonum([$
      m = rho V = 1.2 times 1 = 1.2 "kg" \
      H = 1103 J \/ ("kg" ℃) times 1.2"kg" times 1℃ = 1323.6 J
    $])
])

== 2.3 三种温度

干球温度、湿球温度、露点温度


= 3 基本的水文变量
