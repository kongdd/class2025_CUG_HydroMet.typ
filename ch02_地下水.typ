#import "config.typ": *
#import "@preview/showybox:2.0.2": showybox
#import "@preview/physica:0.9.3": *
#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "第二章 地下水运动")

#show math.equation: format_eq
#counter(heading).update(1)

#let delta(x) = $Delta #x$

= 渗流

== 导水系数

=== 垂向导水系数

#figure(
  image("images/Figure_Soil_K.svg", width: 60%),
  caption: [(a)地下水储水$S_g$，侧视图；(b) 俯视图；(c)正八面体网格; 
    (d) 导水系数（Transmissivity，$m^2\/s$）。图件源自Fan et al., 2007。]
) <fig2_T>


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
  Fan et al. (2007)的结果中，对于土壤，a = 120m, b = 150。对于基岩，a = 20m, b = 125。
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

=== 侧向导水系数

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

这里Fan et al. (2007)与MODFLOW6的处理方式不同，MODFLOW6认为，当$z_"wt" < z_{"river","bed"}$时，河流与含水层之间出现非饱和带，此时河流向含水层的补给量与含水层的水头$h$无关，仅与河床的厚度$b_{"rb"}$和河道的$overline(z)_r$水头有关。因此，在MODFLOW6中，$Q_{"rf"}$的计算公式为：
$ Q_{"rf"} = - "RC" (z_"river" - z_{"river","bed"}) $

== 侧向流


