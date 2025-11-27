#import "@local/modern-cug-report:0.1.3": *
#show: (doc) => template(doc, 
  size: 12.5pt,
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

= 引言 // <!-- omit in toc -->

#box-red[
  1. 夏天干燥还是冬天干燥？
  2. 沿海地区与内陆地区水汽含量差别多大？
]

// #v(0.6em)
#figure(
  image("Figures/Figure2_武汉_杭州_RH.png", width: 100%),
  caption: [
    杭州与武汉2019年逐日相对湿度$"RH"$。
  ]
) <fig_>

#v(-0.6em)
#figure(
  image("Figures/Figure2_武汉_杭州_q.png", width: 100%),
  caption: [
    杭州与武汉2019年逐日比湿$q$。
  ],
) <fig_>


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

== 3.1 基本单元：流域
#v(-0.5em)
=== 3.1.1 流域

分水线所形成的闭合区域，分水线一般为提防、山脊等高地。

// #figure(
//   image("Figures/孤山流域.png", width: 90%),
//   caption: [
//     孤山流域子流域编号、河网等级、与河网结构。
//   ]
// ) <fig_>

#figure(
  image("../ch01_StudyCases/Figures/流域提取.png", width: 100%),
  caption: [
    流域与流域提取方法。
  ],
) <fig_>

=== 3.1.2 流域面积

哪些区域的降水会从该出水口流出？是影响流量、洪峰大小的重要因素。

- 水文站：代表的其控制面积（流域）上的水资源量；
- 气象站：代表的是气象站周围的气象要素。

#figure(
  image("../ch01_StudyCases/Figures/水文站控制_01.png", width: 60%),
  caption: [
    水文站控制流域面积示意图。
  ],
) <fig_>

#figure(
  image("../ch01_StudyCases/Figures/湖北三市_中小流域.png", width: 90%),
  caption: [
    湖北三市典型中小流域。
  ],
) <fig_>

=== 3.1.3 汇流时间

降雨洪水从流域最远处汇集到出口的时间，反映流域水文响应速度。

#v(-0.8em)
#figure(
  image("../ch01_StudyCases/Figures/降雨径流滞后_gg.layers.png", height: 6.5cm),
  caption: [
    降雨径流滞后时间。
  ],
) <fig_>
// #v(-0.8em)
// #figure(
//   image("../ch01_StudyCases/Figures/降雨径流滞后时间.png", width: 80%),
//   caption: [
//     湖北省典型中小河流降雨径流滞后时间。
//   ],
// ) <fig_>


== 3.2 径流与流量

=== 3.2.1 径流

*径流*（Runoff）：降水扣除蒸发、下渗等损失后，沿地面或地下汇入河槽，并沿河槽流动的水流。

径流的组成：
- *地表径流*：降水直接沿地面流入河道的水流
- *壤中流*：降水下渗后在土壤中侧向流动汇入河道的水流
- *地下径流*：降水深层渗透后，在地下水层中流动汇入河道的水流

=== 3.2.2 流量

*流量* $Q$：单位时间内通过河流某一过水断面的水量，单位：$m^3 "/" s$。

$ Q = A v $

- $A$：过水断面面积（$m^2$）
- $v$：断面平均流速（$m "/" s$）

*径流深* $R$：流域在一段时间内产生的径流总量平铺在整个流域面积上的水层厚度，单位：$"mm"$。

$ R = Q t / (F times 1000) $

- $Q$：流量（$m^3 "/" s$）
- $t$：时间（$s$）
- $F$：流域面积（$k m^2$）

#beamer-block()[
  *小试牛刀：*某流域面积$F = 1000 k m^2$，某次洪水过程平均流量$Q = 500 m^3 "/" s$，洪水持续时间$t = 24 h$，求径流深$R$。

  #nonum([$
    R = (Q t) / (F times 1000) = (500 times 24 times 3600) / (1000 times 10^6) times 1000 = 43.2 "mm"
  $])
]

=== 3.2.3 径流系数

*径流系数* $alpha$：一定时段内径流深与降水量之比，反映降水转化为径流的比例。

$ alpha = R / P $

- $R$：径流深（$"mm"$）
- $P$：降水量（$"mm"$）

径流系数受流域下垫面特征、降水强度、前期土壤含水量等因素影响。一般范围：
- 森林流域：$0.3 ~ 0.5$
- 城市流域：$0.6 ~ 0.9$
- 裸露山地：$0.7 ~ 0.9$


== 3.3 降水

*降水*（Precipitation）：大气中的水汽凝结后以液态或固态形式降落到地面的水，包括雨、雪、冰雹等。

=== 3.3.1 降水量

*降水量* $P$：一定时段内降落到地面的降水，假定未经蒸发、渗透、流失，在水平面上积累的深度，单位：$"mm"$。

测量仪器：雨量筒、自动雨量计

降水量的时间尺度：
- 日降水量：08:00至次日08:00的累计降水量（中国标准）
- 月降水量：当月所有日降水量之和
- 年降水量：当年所有日降水量之和

=== 3.3.2 降水强度

*降水强度* $i$：单位时间内的降水量，单位：$"mm" "/" h$。

根据降水强度分类（24小时降水量）：
- 小雨：$P < 10 "mm"$
- 中雨：$10 "mm" <= P < 25 "mm"$
- 大雨：$25 "mm" <= P < 50 "mm"$
- 暴雨：$50 "mm" <= P < 100 "mm"$
- 大暴雨：$100 "mm" <= P < 250 "mm"$
- 特大暴雨：$P >= 250 "mm"$

=== 3.3.3 面雨量

*面雨量*：流域或区域范围内的平均降水量，单位：$"mm"$。

常用计算方法：
- *算术平均法*：适用于雨量站分布均匀、地形平坦的流域
  $ overline(P) = 1 / n sum_(i=1)^n P_i $

- *泰森多边形法*：考虑雨量站代表面积的加权平均
  $ overline(P) = sum_(i=1)^n f_i P_i $
  其中，$f_i = A_i / A$为第$i$站的面积权重

- *等雨量线法*：根据等雨量线图计算，精度最高但工作量大


== 3.4 蒸散发

*蒸散发*（Evapotranspiration, ET）：水分以水汽形式从地表和植物体表面散失到大气中的过程，包括蒸发和散发。

=== 3.4.1 蒸发与散发

- *蒸发*（Evaporation, E）：水分从土壤、水体等非生物表面转化为水汽的物理过程
- *散发*（Transpiration, T）：植物通过叶片气孔将水分以水汽形式释放到大气的生理过程

$ "ET" = E + T $

=== 3.4.2 潜在蒸散发与实际蒸散发

- *潜在蒸散发* $"ET"_0$：充分供水条件下，参考作物（如草地）的蒸散发量，仅取决于气象条件

- *实际蒸散发* $"ET"_a$：实际发生的蒸散发量，受水分供应限制

$ "ET"_a <= "ET"_0 $

=== 3.4.3 蒸散发的计算

常用方法：
1. *Penman-Monteith公式*（FAO-56推荐）：

  $ "ET"_0 = (0.408 Delta (R_n - G) + gamma (900 / (T + 273)) u_2 (e_s - e_a)) / (Delta + gamma (1 + 0.34 u_2)) $

  - $R_n$：净辐射（$"MJ" m^(-2) "day"^(-1)$）
  - $G$：土壤热通量（$"MJ" m^(-2) "day"^(-1)$）
  - $T$：平均气温（℃）
  - $u_2$：2m高度风速（$m "/" s$）
  - $e_s$：饱和水汽压（$"kPa"$）
  - $e_a$：实际水汽压（$"kPa"$）
  - $Delta$：饱和水汽压曲线斜率（$"kPa" ℃^(-1)$）
  - $gamma$：干湿表常数（$"kPa" ℃^(-1)$）

2. *水面蒸发器*：20cm或E-601蒸发器测定水面蒸发量


== 3.5 土壤含水量

*土壤含水量*（Soil Moisture, SM）：土壤中所含水分的数量，是联系降水、蒸散发、径流的关键变量。

=== 3.5.1 表示方法

- *质量含水率* $theta_m$：土壤水分质量与干土质量之比
  $ theta_m = m_w / m_s times 100% $

- *体积含水率* $theta_v$：土壤水分体积与土壤总体积之比
  $ theta_v = V_w / V times 100% $

二者关系：
$ theta_v = theta_m times rho_s / rho_w $

其中，$rho_s$为土壤容重（$g "/" c m^3$），$rho_w$为水的密度（$g "/" c m^3$）。

=== 3.5.2 田间持水量与凋萎系数

- *田间持水量* $theta_"fc"$：充分灌溉后，重力水排出，毛管水保持稳定时的土壤含水量

- *凋萎系数* $theta_"wp"$：植物开始永久凋萎时的土壤含水量

- *有效含水量*：
  $ theta_"eff" = theta_v - theta_"wp" $

=== 3.5.3 测量方法

1. *烘干法*：标准方法，取样后105℃烘干至恒重
2. *TDR法*：时域反射法，基于土壤介电常数
3. *FDR法*：频域反射法
4. *中子法*：利用中子减速原理
5. *遥感法*：微波遥感反演
