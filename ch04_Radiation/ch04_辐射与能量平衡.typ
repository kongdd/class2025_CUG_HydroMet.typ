#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, size: 12pt, footer: "CUG水文气象学2025", header: "第4章 辐射与能量平衡")

#counter(heading).update(3)
#let delta(x) = $Delta #x$
#show math.equation: set text(11.5pt)

// =
// =
// =
= 4 辐射与能量平衡

== 4.1 辐射的基本定理

黑体（Blackbody）：是一个理想化的物体，它能够吸收照射到它上面的所有电磁辐射，无论频率或入射角如何。在热力学平衡中，黑体的辐射仅取决于温度。

#figure(
  image("Figures/黑体-02.png", width: 45%),
  caption: [
    辐射进入带有一个极小孔径的空腔，并在内壁上反射。\ 辐射无法逃逸，能量全部用于加热腔壁。
  ],
) <fig_>

=== 4.1.1 普朗克定律 (Planck's Law)

#figure(
  image("Figures/定律-普朗克.png", width: 80%),
  caption: [
    普朗克定律。
  ],
) <fig_>

普朗克定律描述了在热平衡状态下，*单色波的辐射强度与波长与温度之间的关系*，其光谱辐射通量密度 $I_lambda$为：

$ I_lambda (T) = (2 h c^2) / lambda^5 1 / (e^((h c) / (lambda k T)) - 1) $

- $I_lambda$: 波长 $lambda$ 处的辐射强度 ($W m^(-2) "sr"^(-1) m^(-1)$)
- $lambda$: 波长 ($m$)
- $T$: 绝对温度 ($K$)
- $h$: 普朗克常数 ($6.626 times 10^(-34) J s$)
- $c$: 光速 ($2.998 times 10^8 m s^(-1)$)
- $k$: 玻尔兹曼常数 ($1.381 times 10^(-23) J K^(-1)$)


=== 4.1.2 维恩位移定律 (Wien's Displacement Law)

维恩位移定律指出，黑体辐射光谱的*峰值波长 $lambda_"max"$ 与其绝对温度 $T$*：

$ lambda_"max" = b / T $

其中 $b$ 为维恩位移常数，约为 $2897.8 mu m dot K$。该定律表明，物体温度越高，其辐射能量最强的波长越短（向蓝光方向移动）。
- 太阳表面温度约为 6000 K，辐射峰值在 0.48 $mu m$ (可见光波段)。
- 地球表面温度约为 300 K，辐射峰值在 9.66 $mu m$ (热红外波段)。

#box-blue[
  根据维恩位移定律，太阳的高温使其辐射能量集中在可见光波段（0.4-0.7 $mu m$），因此人眼能看到明亮的阳光。而地球温度较低，其辐射能量主要集中在热红外波段（8-14 $mu m$），这是人眼无法感知的。
  遥感卫星（如Landsat, MODIS）设计了专门的热红外波段传感器，用于探测地表温度、森林火灾等，就是利用了这一原理。
]

#figure(
  image("Figures/电磁波.png", width: 70%),
  caption: [
    不同波长的电磁波。
  ],
) <fig_>

=== 4.1.3 斯提芬-波尔茨曼定律 (Stefan-Boltzmann Law)

斯提芬-波尔茨曼定律描述了黑体单位表面积向整个半球空间发射的总辐射功率 $E$ 与其温度 $T$ 的四次方成正比。它是对普朗克定律在全波段上的积分：

$ E = integral_0^infinity pi I_lambda (T) dif lambda = sigma T^4 $

其中 $sigma$ 为斯提芬-波尔茨曼常数：
$ sigma = (2 pi^5 k^4) / (15 c^2 h^3) approx 5.67 times 10^(-8) W m^(-2) K^(-4) $

对于非黑体（灰体），其辐射能力小于同温度下的黑体，用发射率 $epsilon$ ($0 < epsilon < 1$) 修正：
$ E = epsilon sigma T^4 $

#beamer-block()[
  *教学案例：人体的辐射热交换*

  以一个成年人为例，假设：
  - 皮肤温度 $T_"skin" approx 33 degree C = 306 K$
  - 环境温度 $T_"env" approx 20 degree C = 293 K$
  - 皮肤在热红外波段的发射率 $epsilon approx 0.98$（接近黑体）
  - 体表面积 $A approx 1.8 m^2$

  根据斯提芬-波尔茨曼定律：

  - *人体向外辐射*：$P_"out" = epsilon sigma A T_"skin"^4 = 0.98 times 5.67 times 10^(-8) times 1.8 times 306^4 approx 900 W$
  - *人体吸收环境辐射*：$P_"in" = epsilon sigma A T_"env"^4 = 0.98 times 5.67 times 10^(-8) times 1.8 times 293^4 approx 770 W$
  - *净辐射散热*：$P_"net" = P_"out" - P_"in" approx 130 W$

  因此，在室温环境中，人体通过辐射的**净散热**约为 130W。这也解释了为什么在相同气温下，室内和室外的体感温度会不同（地面、墙壁的温度影响辐射热交换）。
]

#box-blue[
  *关于空气辐射：*这里的"环境温度"指的是周围固体表面（墙壁、地面、家具等）的平均辐射温度（Mean Radiant Temperature, MRT），而非空气温度。因为干燥空气（N₂、O₂）在热红外波段几乎是透明的（$tau approx 1, epsilon approx 0$），室内短距离下空气辐射贡献可忽略。

  在户外大气尺度，由于路径长（数公里），水蒸气和CO₂等温室气体的累积辐射效应显著，大气向下长波辐射成为地表能量平衡的重要组成部分。
]

#box-blue[
  *辐射传热与对流/传导的区别：*
  辐射传热与对流、传导传热的机制不同。辐射以电磁波形式传播，速度为光速（瞬时到达），不需要介质（可在真空中传播），辐射能量直接在表面间交换，无需考虑传输阻力。
  // 因此在室内短距离环境中，空气对热红外几乎透明（$tau approx 1$），
]

#v(-0.4em)
#figure(
  caption: [
    能量传递的几种方式
  ],
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    rows: (0.7cm, 0.8cm),
    align: (horizon, left, left, left),
    // stroke: 0.5pt,
    [*特征*], [*辐射*], [*对流*], [*热传导*],
    [*物理机制*], [电磁波传播], [流体宏观运动], [分子碰撞/振动],
    [*传热公式*],
    [$Q = epsilon sigma A (T_1^4 - T_2^4)$],
    [$H = (rho c_p Delta T) / r_H$],
    [$G = (kappa Delta T) / (Delta z)$],

    [*传输介质*], [无需介质（真空）], [流体（液/气）], [固/液/气],
    [*"阻力"概念*], [无传统阻力], [空气动力学阻力 $r_H$], [热阻 $Delta z \/ kappa$],
    [*温度依赖*], [$T^4$ 非线性], [线性 $Delta T$], [线性 $Delta T$],
    [*传播速度*], [光速（瞬时）], [取决于流速], [缓慢扩散],
  ),
) <table_energy_transfer>
#v(-0.4em)

#v(0.5em)
*重要说明：* 虽然热传导的经典形式是 $G = (kappa Delta T) / (Delta z)$（傅里叶定律），但在陆面模式中，为了统一表达，对流和热传导**都可以**表示为"梯度/阻力"的形式：
- 对流：$H = (rho c_p Delta T) / r_H$，其中$r_H$为空气动力学阻力，单位$"s" thin "m"^(-1)$。
- 热传导：$G = (kappa Delta T) / (Delta z)$，其中$kappa$ 为热传导系数，单位$W thin m^(-1) K^(-1)$。热传导也可以写成类似对流的形式$G = (C_v Delta T) / r_"soil"$（其中 $C_v = rho c_p$ 为体积热容，$r_"soil" =delta(z)/kappa$）。


=== 4.1.4 基尔霍夫定律 (Kirchhoff's Law)

基尔霍夫定律指出，在热平衡状态下，物体对某一波长的发射率 $epsilon_lambda$ 等于其对该波长的吸收率 $alpha_lambda$：

$ epsilon_lambda (T) = alpha_lambda (T) $

*辐射能量守恒：*

对于任何物体，入射辐射会被吸收、反射和透射，根据能量守恒原理：

$ alpha_lambda + rho_lambda + tau_lambda = 1 $

其中，$alpha_lambda$为吸收率（Absorptivity），$rho_lambda$为反射率（Reflectivity），$tau_lambda$为透射率（Transmissivity）。

*对于不透明物体*（如大多数地表材料），$tau_lambda = 0$，$alpha_lambda + rho_lambda = 1$。
结合基尔霍夫定律 $epsilon_lambda = alpha_lambda$，可得：$epsilon_lambda + rho_lambda = 1$。这意味着：
- 好的吸收体也是好的发射体（高 $alpha$ → 高 $epsilon$）；
- 黑体的吸收率和发射率均为 1（$alpha = epsilon = 1, rho = 0$）；
- 对于不透明物体，高反射率意味着低发射率（如雪），低反射率意味着高发射率（如沥青）。

  // #figure(
  #image("Figures/发射率-02.png", width: 100%)
//   caption: [],
// ) <fig_>

#beamer-block()[
  *案例1：保温瓶（热水瓶）的内胆为何是银白色的？*

  保温瓶内胆镀银，使其表面在*可见光*和*热红外*波段都具有极高的反射率。

  特别是在热红外波段（长波），高反射率意味着极低的吸收率（$alpha approx 0$）。根据基尔霍夫定律 $epsilon = alpha$，这也意味着极低的发射率 $epsilon$。
  *结果：*银色内壁既难以吸收外界辐射，也难以向外辐射热量（长波），从而极大地减少了辐射热交换，达到保温效果。

  *案例2：雪的"黑白"二象性*。

  雪在*可见光*波段看起来是白色的（高反射率 $rho approx 0.8-0.9$），即低吸收率。根据基尔霍夫定律，可见光波段的发射率也很低。

  但在*热红外*波段（长波），雪的性质却完全相反：吸收率很高（$alpha approx 0.98-0.99$），根据 $epsilon = alpha$，发射率也很高，雪在热红外波段接近"黑体"。*结果：*在晴朗的夜晚，雪面能非常有效地向外辐射长波能量，通过辐射冷却迅速降温，往往比周围气温更低，容易形成逆温层。
]

== 4.2 太阳辐射

#box-red([
  - 辐射能$delta(F)$：辐射的总能量，$J$；
  - 辐射通量：单位时间通过的辐射能，$W$；
  - 辐射通量密度$F$：单位时间、单位面积通过的辐射能，$W m^(-2)$；
  - 辐射强度$I$：单位时间、单位面积、单位立体角，通过的辐射能，$W m^(-2) "sr"^(-1)$。
])

#v(-0.7em)
#figure(
  image("Figures/日地距离-01.png", width: 60%),
  caption: [
    相同立体角$omega$，距离分别为$d$和$d_0$的两个截面。
  ],
) <fig_>

$ F = delta(F) / delta(t) delta(S) $
$ I = delta(F) / (delta(t) delta(S) delta(omega) ), F = I delta(omega) $

对于太阳，相同立体角$omega$，距离分别为$d$和$d_0$的两个截面，他们的辐射强度如下：

$
  S / S_0 = (d / d_0)^2 \
  I / I_0 = S_0 / S = (d_0 / d)^2 \
  I = I_0 (d_0 / d)^2 = I_0 / rho^2, (rho = d / d_0)
$

其中，$I_0$为太阳辐射常数（1370 $W m^(-2)$），$I$为地表某一位置大气层顶天文太阳辐射（$"Rs"_"toa"$， solar radiation at top of atmosphere）。

对于地球而言，单位时间、单位面积接收到的辐射能F：
$ F / F_0 = I / I_0 = (d_0 / d)^2 $
$ F = F_0 (d_0 / d)^2 = F_0 / rho^2 $

其中$d$为日地距离，$d_0$为日地平均距离，$I$为地球接收的太阳辐射强度，$F_0$为太阳辐射常数（1370 $W m^(-2)$）。

== 4.3 能量平衡
#v(-0.8em)
=== 4.3.1 地表能量平衡

#figure(
  image("Figures/能量平衡-地表01.png", width: 60%),
  caption: [
    辐射平衡（左侧）与能量平衡（右侧）。
  ],
) <fig_>

水文学研究中两个主要的公式—水量平衡与能量平衡。能量平衡公式如下：

$ R_n - G = lambda E + H $ <eq_energy>

其中，$R_n$是净辐射，$G$是土壤热通量，$lambda E$是蒸发潜热通量，$H$是感热通量。

基于蒸散发的基本原理，可知：

$ lambda E = (lambda rho delta(q)) / r_v = (rho c_p delta(e)) / (gamma r_v) $
$ H = (rho c_p delta(T)) / r_H $

其中，$R_n$为净辐射，MJ；$lambda$为汽化潜热，2.5 MJ / kg；$gamma$为湿度计常数；$rho$为空气密度，$"kg"\/m^3$；$r_v$, $r_H$分别是水汽和热量的传导阻力。


*类似于浓度扩散、以及达西定律，$lambda E$、$H$和$G$公式形式皆是梯度×扩散效率系数的形式。*土壤热通量的表达形式如下：

$ G = kappa / delta(z) (T_s - T_1) $

- $kappa$: 热传导系数，$"W"\/m^2\/K$
- $T_s$：地表温度
- $T_1$：第一层土壤的温度
- $delta(z)$: 第一层土壤的厚度

#beamer-block([这里需要注意，公式1中所有变量都是通量的概念。])

=== 4.3.2 大气能量平衡

#figure(
  image("Figures/能量平衡-大气02.png", width: 80%),
  caption: [
    大气能量平衡示意图。
  ],
) <fig_>

#v(-1em)
#figure(
  image("Figures/能量平衡-大气.png", width: 80%),
  caption: [
    大气能量平衡示意图2。
  ],
) <fig_>

#mitex(
  `$$
\begin{align*}
  Rns &= 45, \\
  Rl_{in} &= 88, Rl_{out} = 104 \\
  Rn &= 45 + 88 - 104 = 29 \\
  Rn &= H + \lambda E
\end{align*}
$$`,
)

== 4.4 地表净辐射

地表净辐射，主要包括长波净辐射和短波净辐射。

$ R_n = "Rns" + "Rnl" = (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 $ <eq_Rn>

- $R_s$: 入射短波辐射；
- $"Rln"$：入射长波辐射；
- $T_s$: 地表温度；
- $alpha$: 地表反射率；
- $epsilon$: 地表辐射率；
- $sigma$: 斯特藩-玻尔兹曼常数(Stefan-Boltzmann constant)，$σ=5.67×10^(-8) W (m^(-2) K^(-4)）$。

#beamer-block([上式的推导，涉及辐射的三个基本定律。])

#figure(
  image("Figures/albedo_V2.png", width: 70%),
  caption: [典型下面反射率。],
) <fig_albedo>


=== 4.5 地表能量平衡求解

辐射会加热地表和空气；地表温度升高则向外长波辐射增加，使Rn减少。二者相互作用，最终会达到均衡。

联立式#[@eq_energy]和#[@eq_Rn]，可得：

$
  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p delta(e)) / (gamma r_v) + (rho c_p delta(T)) / r_H \
  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p (e_"surf" - e) ) / (gamma r_v) + (rho c_p (T_s - T_a)) / r_H
$

把变量移到左边，令$Q_a = (1 - alpha) R_s + epsilon"Rln"$，得到：

$
  Q_a = epsilon sigma T_s^4 + kappa / delta(z) (T_s - T_1) + (rho c_p (e_"surf" - e) ) / (gamma r_v) + (rho c_p (T_s - T_a)) / r_H
$

$
  f(T_s) = Q_a - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) - (rho c_p (e_"surf" - e) ) / (gamma r_v) - (rho c_p (T_s - T_a)) / r_H = 0
$

*牛顿梯度降：*

土壤表面温度为$T_s$（skin temperature），注意表皮温度与第一层土壤的平均温度有所不同。牛顿梯度降迭代过程中，土壤温度按照如下公式进行更新。

$ T_(s, "next") = T_s - f(T_s) / pdv(f, T_s) $
