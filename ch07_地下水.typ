#import "config.typ": *

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "地下水运动")

#show math.equation: format_eq
#counter(heading).update(6)
#let delta(x) = $Delta #x$

= 地下水运动

#beamer-block()[
  该部分模型编写主要参考了Fan et al. (2007)#[@fan_incorporating_2007]的工作。
]

#figure(
  image("images/Figure_Soil_K.svg", width: 60%),
  caption: [(a)地下水储水$S_g$，侧视图；(b) 俯视图；(c)正八边形网格，边长$w = delta(x) sqrt(0.5 tan(pi\/8))$; 
    (d) 导水系数（Transmissivity，$m^2\/s$）。
    图件源自Fan et al., 2007。在地下水侧向交互时，采用的是正八边形网格，每个方向的$Q_n$通过的剖面面积和距离都相同。
    ]
) <fig2_T>

== 均衡水位

$ "dS"_g / "dt" = delta(x) delta(y) R + sum_i^8 Q_n - Q_r $

- $"S"_g$: 地下水水储量
- $R$: 土壤对地下水的补给量
- $Q_r$: 地下水与河道的交互
- $Q_n$: 侧向交互的流量，来源于周围的8个网格。

均衡状态，$"dS"_g / "dt" = 0$，即：

$ delta(x) delta(y) R  = - sum_i^8 Q_n + Q_r $

网格划分为两种类型：坡道网格和河道网格。

*对于坡道*，不考虑地下水与河道的交互，即忽略$Q_r$：

$ delta(x) delta(y) R  = - sum_i^8 Q_n $

*对于河道*，河道与地下水的交互更强，可不考虑土壤与地下水的交互$R$：

$ sum_i^8 Q_n = Q_r $

== 侧向流

$ Q_n = w d K ((h_n - h) / l), T = K d $

- $d$: 每一层土壤的深度
- $T$: 导水系数
- $K$: 水力传导系数
- $l$：两个网格中心的距离

导水系数$T$是两个相邻网格是通过加权得到的：

// $ 1 / K = 1/K_1 + 1/K_2 $

=== 四向

*经纬度网格$delta(y)$的矫正：*

  南北方向：$ Q_n = K A delta(h) / l  = K delta(x) d delta(h) / delta(y)$

  东西方向：$ Q_n = K A delta(h) / l  = K delta(y) d delta(h) / delta(x)$

  $delta(y)$随lat变化而变化，需要进行矫正。若赤道为1，则矫正后的$delta(hat(y)) = delta(y) / cos("lat")$。
  因此，对于南北向，矫正因子$cos("lat")$直接相乘；对于东西向，矫正因子则为$1 / cos("lat")$，详情见下表代码：

```julia
q = 0
# 南北向
q = q + (kcell[i, j + 1] + kcell[i, j]) *    # north
    (head[i, j + 1] - head[i, j]) * cos(d2r * (xlat[i, j] + 0.5 * dxy))      
q = q + (kcell[i, j - 1] + kcell[i, j]) *    # south
    (head[i, j - 1] - head[i, j]) * cos(d2r * (xlat[i, j] - 0.5 * dxy))
# 东西向
q = q + (kcell[i - 1, j] + kcell[i, j]) *    # west
    (head[i - 1, j] - head[i, j]) / cos(d2r * xlat[i, j])
q = q + (kcell[i + 1, j] + kcell[i, j]) *    # east
    (head[i + 1, j] - head[i, j]) / cos(d2r * xlat[i, j])
qlat[i, j] = 0.5 * q * deltat / area[i, j]   # m3 to m
```
其中，0.5用于求$K_i$与$K_j$的平均值。

=== 八向

#beamer-block()[模型中，在计算距离的时候，用的正常网格；但计算过水截面面积时，用的是正八边形网格。]


== 导水系数

=== 垂向导水系数

*浅层土壤的导水系数$T_1$*（1.5m以上，图@fig2_T d ）

  - 1.5m以上，K是已知的（图@fig2_T d ，因此这部分的K可以通过以下公式计算：

    #mitex(`$$
    T_1 = \sum K_m \Delta z_m
    $$`)

    下标m代表土壤层，$Delta z_m$代表土壤层的厚度，$K_m$代表土壤层的水力传导系数。

*深层土壤的导水系数$T_2$*（1.5m以下）

- 1.5m以下，认为K随深度z'指数变化：
  #mitex(`$$
  K = K_{0} e^{\frac{-z'}{f}} \\
  $$`)
  $K_0$: 1.5m处的水力传导系数；$z'$: 1.5m以下土壤深度，$z' = z - 1.5m$。

#showybox(
  // shadow: (color: yellow.lighten(55%), offset: 3pt),
  // body-color: red.lighten(95%)
  frame: (
    title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(95%)
  ),
)[
  其中，$ f = a / {1 + b beta}$ for $beta <= 0.16$；f = 5m for $beta > 0.16$，$beta$为坡度。
  Fan et al. (2007)@fan_incorporating_2007 的结果中，对于土壤，a = 120m, b = 150。对于基岩，a = 20m, b = 125。
  网上只有埋深浅于1.5m的基岩数据（http://www.soilinfo.psu.edu/index.cgi?soil_data&conus&data_cov&dtb&methods）。
]
  #highlight()[TODO: 根据上述公式可以得出 f的空间分布图，类似Fan 2007, Fig. 8c。]

  模型对$e^{-z'/f}$的最小值进行了限制，即：
  $
  "factor" = e^{-z'/f}, "factor" = "clamp"("factor", 0.1, 1.0)
  $

**(1) h < 1.5m**，

  #mitex(`$$
  T2 = \int_0^\infty K dz' = \int_0^\infty K_{sat} e^{\frac{-z'}{f}} dz' = K_0 f  
  $$`)
  
**(2) h > 1.5m**
  #mitex(`$$
  T2 = \int_d^\infty K dz' = \int_d^\infty K_{sat} e^{\frac{-z'}{f}} dz' = K_0 f e^{\frac{-d}{f}}  
  $$`)
    
  - $d$: $z - h - 1.5$（图@fig2_T d）。
  - $z$: 地表高程，文章中向下为正
  - $h$: 地下水头（潜水层中的水位深度）

```julia
# Transmissivity: T = d K, [m2/s]
function cal_trans(wtd::FT, f::FT) where {FT<:Real}
  f < 1e-6 && return FT(0)
  if wtd < -1.5
    T = f * klat * exp((wtd + 1.5) / f)
  else
    d1 = 1.5 + wtd             # deepth of unsaturated soil
    T = klat * d1 + klat * f
  end
  return T
end
```

=== 侧向导水系数

土壤质地：soiltextures，`[nlon, nlat, 2]`，对与第三维，分别存放的是深层（z <= -0.3）与浅层数据（z > -0.3）。
$Q_n$主要指的是地下水的交互，因此采用的是深层的土壤质地。

```julia
nsoil = soiltxt[i, j, 1]
Klat[i, j] = K0(nsoil) * Klat_factor[nsoil]
```
Klat_factor取值详见下表。

#figure(
  caption: [土壤类型、$K$、与$K"lat"_"factor"$值。表格出自Fan et al. (2007) Table 2。],
  table(
    columns: (1.5cm, 4cm, 3cm, 2cm),
    // inset: 10pt,
    align: horizon,
    table.header(
      [*编号*], [*土壤类型*], [*$K$*], [*$K"lat"_"factor"$*],
    ),
    [1], "sand", [15.2064], [2],
    [1], [sand], [15.2064], [2], 
    [2], [loamy sand], [13.5043], [3], 
    [3], [sandy loam], [2.9981], [4], 
    [4], [silt loam], [0.6221], [10], 
    [5], [loam], [0.6048], [12], 
    [6], [sandy clay loam], [0.5443], [14], 
    [7], [silty clay loam], [0.1210], [20], 
    [8], [clay loam], [0.2160], [24], 
    [9], [sandy clay], [0.1901], [28], 
    [10], [silty clay], [0.0864], [40], 
    [11], [clay], [0.1123], [48], 
    [12], [peat], [0.6912], [2]
  )
)


== 地下水与河道的交互

=== $z_"wt" > z_{"river", "surf"}$ （Gaining River）

*地下水补给河道*

#mitex(`$$
Q_{rf} = (h - \bar z_r) \frac{\bar K_{rb}}{\bar b_{rb}} \bar{w}_r \sum{L_r}
$$`) <eq_>

#mitex(`$$
RC = \frac{\bar K_{rb}}{\bar b_{rb}} \bar{w}_r \sum{L_r}
$$`)

// $ "RC" = w l K / delta(z) $
$ q = "RC" (h - z_{"river"}) $ // [m s-1]

#mitex(`$$
R_{rf} = q \Delta t / area_{i,j} % [m]
$$`)

- $"RC"$: 河道水力传导率（river hydraulic conductance），$m^2\/s$
- $K$: 水力传导系数, $m\/s$
- $h$: *地下水头*（潜水层中的水位深度）
- $w$: 河道宽度，$m$
- $l$: 河道长度，$m$
- $q$: 补给的流量，$m^3\/s$
- $R_{"rf"}$: 补给河道的水量，转换为网格径流深，$m$

=== $z_{"river", "surf"} >= z_{"wt"} > z_{"river", "bed"}$

*河道补给地下水*，补给量受$z_{"wt"}$的影响

套用的公式相同，需要注意此时$q$为负值，同时限制排泄量不能高于河道水量$d_"river" f$：

#mitex(`$$
R_{rf} = clamp(q \Delta t / area_{i,j}, -d_{river} f, 0)  % 正值
$$`)

其中，$f = {w l}/ "area"_{i,j}$是水量转换因子，将河道的水位深度转换为网格的深度。


=== $z_{"wt"} < z_{"river", "bed"}$ （Losing River）

Losing River情景，对于Gaining River的情景进行了简化。**认为$h - overline(z)_r = overline(b)_{"rb"}$，因此公式变为：**

#mitex(`$$
Q_{rf} = - \bar K_{rb} \bar{w}_r \sum{L_r}
$$`)

其中负号表示，河道向地下水补给。

这里Fan et al. (2007) @fan_incorporating_2007 与MODFLOW6的处理方式不同，MODFLOW6认为，当$z_"wt" < z_{"river","bed"}$时，河流与含水层之间出现非饱和带，此时河流向含水层的补给量与含水层的水头$h$无关，仅与河床的厚度$b_{"rb"}$和河道的水头$overline(z)_r$有关。因此，在MODFLOW6中，$Q_{"rf"}$的计算公式为：
$ Q_{"rf"} = - "RC" (z_"river" - z_{"river","bed"}) $



== 地下水水位更新 (update_wtd)

=== Fan2007


#mitex(`$$
(z_{gw} - z_{i+1}) \theta_{sat} + (z_i - z_{gw}) \theta_e = \theta dz 
$$`)

#mitex(`$$
z_{gw} (\theta_{sat} - \theta_e) = \theta dz - z_i \theta_e + z_{i+1} \theta_{sat}
$$`)

#figure(
  image("images/Fan_土壤层定义.svg", width: 60%),
  caption: [(a)地下水储水$S_g$，侧视图；(b) 俯视图；(c)正八边形网格，边长$w = delta(x) sqrt(0.5 tan(pi\/8))$; 
    (d) 导水系数（Transmissivity，$m^2\/s$）。
    图件源自Fan et al., 2007。在地下水侧向交互时，采用的是正八边形网格，每个方向的$Q_n$通过的剖面面积和距离都相同。
    ]
) // <fig2_T>

=== CoLM2024

#highlight()[深层地下水与浅层地下水的更新方法。]

可以采用CoLM的土壤水与地下水的交互更新方案。

需要知道，*补给量*与*排泄量*。

#bibliography("References.bib")
// #import "@preview/modern-nju-thesis:0.3.4": documentclass, bilingual-bibliography
// #bilingual-bibliography(full: true)
