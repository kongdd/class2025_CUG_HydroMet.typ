#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

#beamer-block[为什么开放系统需要引入传输阻力？]

// #set text(font: ("New Computer Modern", "Source Han Serif SC"), size: 11pt)
// #set par(justify: true, leading: 0.8em)
// #show heading: set text(font: ("New Computer Modern", "Source Han Sans SC"))

= 1 阻力

#box-red()[
  当我们知道两个物体之间存在温度差时，能直接确定它们之间的热流量吗？*不能！*
]
// 这就是为什么我们需要"阻力"这个概念。

假设有两个物体，物体A 温度 $T_A = 100°C$，物体B 温度 $T_B = 20°C$，温差$Delta T = 80°C$。
从A传到B传导的热流是多少？

1. 热汤，用力吹，为何凉得快？

2. 夏天开风扇，为何能降温？（吹走热空气、吹走湿空气）。空气间隔，取决于风速于距离。Why?

3. 铜棒与木帮的热传导阻力差异。

*结论*：同样的温差(80°C)，热流完全不同！这完全类似于欧姆定律：$I = (U_2 - U_1) / R$。

$ "热流" = "驱动力(温差)" / "阻力(传输难度)" $


*物理本质：*

梯度（温差、压差）只告诉我们"传输"方向，但*不能告诉我们"能传多快"*。

传输速率还取决于：1. 传输路径的长短；2. 介质的物理性质；3. 流动状态（层流/湍流）；4. 几何形状和尺寸。
这些因素的综合效应，就是*"阻力"*。

#pagebreak()

= 2 密闭系统（不需要知道阻力）

#figure(
  rect(width: 80%)[
    #align(center)[
      *密闭绝热容器* \
      初态：$(T, e)$ （空气+水） \
      $arrow.b$ 等待足够长时间... \

      末态：$(T', e_s(T'))$ （达到平衡）
    ]
  ],
  caption: [密闭系统示意图],
)
// 思想实验：

#box-blue()[
  一个密闭容器，有充足的水，水的上方是空气。
  1. 初始状态，水和空气采用一个薄板完全分离，空气的初始状态为$(T, e_a)$，此时的温度即为*干球温度*。
  2. 之后抽开挡板，水和空气开始相互接触。水面蒸发，空气水汽含量增加；同时，蒸发吸热（从液态$->$气态），空气温度降低。
  3. 最终，稳定状态下，充分供水、蒸发降温所能达到的最低温度称为#Blue[湿度温度]。
]

*使用的原理*：能量守恒

$
  H + lambda E = 0 \
  lambda (m'_v - m_v) + m_a c_p (T' - T) = 0
$

感热与潜热发生在同一个密闭体积中，因此V相同。假定是单位体积：

$ lambda (rho'_v - rho_v) + rho_a c_p (T - T') = 0 $ <eq_wet_bulb_balance>

$
  lambda E' = lambda (rho'_v - rho_v), quad & "水汽含量升高", & lambda E > 0 \
              H' = rho_a c_p (T' - T), quad & "温度下降",     &        H < 0
$

其中：
$lambda$为汽化潜热，$m_"v"$为蒸发的水量，$m_"a"$为空气质量，$c_p$为空气比热容。$lambda E'$和$H'$分别表示密闭容器的潜热与感热通量。

令$Delta rho_v = rho'_v - rho_v, Delta T = T' - T$。式#[@eq_wet_bulb_balance]可写作：

$ lambda Delta rho_v = - rho_a c_p Delta T $

由 $rho_v = epsilon rho_a e / P ==> Delta rho_v = epsilon rho_a (Delta e) / P$，带入：

$
  lambda epsilon (Delta e) / P = - c_p Delta T \
  Delta e = - (c_p P) / (epsilon lambda) Delta T
$



#box-red[
  *为什么不需要阻力？* ① 不关心过程快慢；② 不关心传输路径；③ 只计算初末状态的差别。
]

*关心的问题*：最终平衡状态是什么？不需要知道阻力、传递速率。

#block(
  fill: rgb("#e8f4f8"),
  inset: 10pt,
  radius: 4pt,
  [
    *案例：* 两个连通水库
    
    #figure(
      ```
            初态：  [高水库 h₁] ════ [低水库 h₂]
            末态：  [平衡水位 h_f] ══ [平衡水位 h_f]
      ```,
    )
    
    最终水位，可根据总水量守恒得到 $h_f = (A_1 h_1 + A_2 h_2) / (A_1 + A_2)$。
    
    但如果想知道传递速度，则需要管道粗细、长度、流速。
  ],
)

= 3 开放系统（需要知道阻力）

在一个开放系统中，水汽和热量传递的效率，需要知道水汽和热量的传递阻力。

*关心的问题*：单位时间的传输速率是多少？

// 若考虑他们的

// #figure(
//   diagram(
//     node-stroke: 1pt,
//     edge-stroke: 1pt,
//     node((0, 0), [空气流 \ $(T, e)$], name: <air1>),
//     node((2, 0), [湿球表面 \ $T_w$], name: <bulb>, shape: circle),
//     node((4, 0), [空气流 \ $(T, e)$], name: <air2>),
//     edge(<air1>, <bulb>, "->"),
//     edge(<bulb>, <air2>, "->"),
//     edge((2, -0.5), (2, -1), "->", label: [蒸发]),
//   ),
//   caption: [开放系统：湿球温度计],
// )

*必须确定*：
- 感热通量：$H$ (W/m²)
- 潜热通量：$lambda E$ (W/m²)

*稳态能量平衡*：
$ H + lambda E = 0 $

即：对流输入的热量 = 蒸发带走的热量

== 3.1 为什么"温差"不能直接给出"热流"？

=== 3.1.1 实验观察

对同一个湿球温度计，在相同的空气状态 $(T=20°C, e=1000"Pa")$ 下：

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: center,
  [*风速*], [*边界层*], [*蒸发速率*], [*湿球温度*],
  [$u = 0.1 "m/s"$], [很厚], [很慢], [$T_w approx 19°C$],
  [$u = 1 "m/s"$], [中等], [中等], [$T_w approx 15°C$],
  [$u = 10 "m/s"$], [很薄], [很快], [$T_w approx 12°C$],
)

*观察*：同样的空气状态，不同风速下湿球温度不同！

*原因*：传输速率不同 → 冷却强度不同 → 稳态温度不同

=== 3.1.2 边界层的作用

真实的温度分布：

// #figure(
//   image("boundary_layer_sketch.svg", width: 70%),
//   caption: [边界层内的温度梯度],
// )

```
      温度
        ↑
        │        T (自由大气，恒定)
        │       ╱
        │      ╱  边界层
        │     ╱   (有温度梯度)
        │    ╱
        │   ╱
   Tw  │──╯  (表面，恒定)
        └──────────────→ 距离 z
```

*关键认识*：
- 热量通过边界层传输
- 边界层越厚 → 传输越慢
- 边界层厚度取决于风速、尺寸

微观上，Fourier定律：
$ q = -kappa (partial T) / (partial z) $

但我们*不知道* $partial T slash partial z$！

我们只能测量：
- 表面温度：$T_w$
- 远处温度：$T$

== 3.2 阻力的数学表达

=== 3.2.1 定义传热阻力

为了从已知量 $(T, T_w)$ 计算热流 $C$，定义：

$ C = rho c_p (T - T_w) / r_H $

其中 $r_H$ 是*传热阻力*，单位：s/m 或 s/cm

*物理意义*：
- $r_H$ 小 → 传输容易 → 同样温差，热流大
- $r_H$ 大 → 传输困难 → 同样温差，热流小

=== 3.2.2 阻力的影响因素

传热阻力取决于：

$ r_H = d / (kappa dot "Nu") $

其中：
- $d$：特征尺寸（如圆柱直径）
- $kappa$：热扩散系数
- $"Nu"$：Nusselt数（无量纲传热系数）

对于圆柱体强制对流：
$ "Nu" = 0.6 dot "Re"^0.5 $
$ "Re" = (u d) / nu $

因此：
$ r_H prop d^0.5 dot u^(-0.5) $

*规律*：
- 尺寸越大 → 阻力越大
- 风速越大 → 阻力越小

=== 3.2.3 传质阻力

类似地，水汽传输：

$ lambda E = (lambda rho epsilon) / p dot (e_s(T_w) - e) / r_v $

可改写为：
$ lambda E = rho c_p (e_s(T_w) - e) / (gamma r_v) $

其中：
- $r_v$：水汽阻力
- $gamma = c_p p / (lambda epsilon) approx 66 "Pa/K"$：湿度计常数

*关系*：
$ r_v = (kappa / D)^0.67 r_H approx 0.93 r_H $

因为水汽扩散系数 $D$ 略大于热扩散系数 $kappa$。

== 3.3 完整的能量平衡方程

=== 3.3.1 稳态条件

湿球温度计的稳态条件：
$ C = lambda E $

代入阻力表达式：
$ rho c_p (T - T_w) / r_H = rho c_p (e_s(T_w) - e) / (gamma r_v) $

化简（令 $gamma^* = gamma r_v / r_H approx 0.93 gamma$）：
$ e = e_s(T_w) - gamma^* (T - T_w) $

这就是*实际湿球温度计方程*！

=== 3.3.2 与热力学湿球温度的比较

*热力学湿球温度* $T'$（密闭系统）：
$ e = e_s(T') - gamma (T - T') $

*实际湿球温度* $T_w$（开放系统）：
$ e = e_s(T_w) - gamma^* (T - T_w) $

*差异*：
- $gamma$ vs $gamma^*$
- $gamma^* = gamma dot r_v / r_H$ 取决于流动条件

#block(
  fill: rgb("#fff4e6"),
  inset: 10pt,
  radius: 4pt,
  [
    *注意*：只有当 $r_v = r_H$（实际上不可能）时，才有 $T_w = T'$。

    一般情况下，由于 $r_v / r_H approx 0.93$，实际湿球温度与热力学湿球温度略有差异。
  ],
)

== 3.4 Penman方程：非绝热系统

=== 3.4.1 问题提出

如果表面不仅有蒸发冷却，还有辐射加热：
$ C + lambda E = R_n $

其中 $R_n$ 是净辐射（W/m²）。

=== 3.4.2 推导过程

*步骤1*：写出热流和水汽通量
$ C = rho c_p (T_0 - T) / r_H $
$ lambda E = rho c_p (e_s(T_0) - e) / (gamma^* r_H) $

*步骤2*：线性化 $e_s(T_0)$
$ e_s(T_0) approx e_s(T) - Delta (T - T_0) $

其中 $Delta = (partial e_s) / (partial T)$ 在温度 $T$ 处求值。

*步骤3*：代入能量平衡
$ C + lambda E = R_n $

*步骤4*：消去未知的 $T_0$，得到：

#block(
  fill: rgb("#e8f4f8"),
  inset: 10pt,
  radius: 4pt,
  [
    *Penman方程*：
    $ lambda E = (Delta R_n) / (Delta + gamma^*) + (rho c_p [e_s(T) - e] r_H^(-1)) / (Delta + gamma^*) $

    $ = "diabatic term" + "adiabatic term" $
  ],
)

=== 3.4.3 物理意义

第一项（*diabatic*）：辐射能量的分配
- 净辐射 $R_n$ 被分成两部分
- 潜热份额：$Delta / (Delta + gamma^*)$
- 显热份额：$gamma^* / (Delta + gamma^*)$

第二项（*adiabatic*）：大气需求
- 由饱和差 $D = e_s(T) - e$ 驱动
- 经过阻力 $r_H$ 的限制
- 修正系数：$1 / (Delta + gamma^*)$

== 3.5 总结：为什么需要阻力？

#table(
  columns: (auto, 1fr, 1fr),
  align: left,
  [*比较项*], [*密闭系统*], [*开放系统*],

  [*系统状态*], [从非平衡→平衡], [维持稳态非平衡],

  [*关心的量*], [状态变化量], [传输速率（通量）],

  [*时间尺度*], [无关紧要], [关键参数],

  [*控制方程*], [积分守恒定律], [微分通量方程],

  [*需要阻力？*], [❌ 不需要], [✅ 必须],

  [*驱动力*], [热力学势差], [温度/浓度梯度],

  [*限制因素*], [热力学极限], [传输系数],

  [*典型例子*], [绝热饱和过程], [蒸发冷却塔、湿球温度计],
)

=== 3.5.1 核心结论

#block(
  fill: rgb("#fff4e6"),
  inset: 15pt,
  radius: 4pt,
  [
    *开放系统需要阻力的根本原因*：

    1. *稳态 ≠ 平衡态*
      - 系统持续维持温差/浓度差
      - 存在持续的传输过程

    2. *驱动力不能唯一确定通量*
      - 同样的驱动力（温差、压差）
      - 不同的传输路径 → 不同的通量
      - 必须量化"传输的难易程度"

    3. *阻力是路径特性的参数化*
      - 包含几何效应（尺寸、形状）
      - 包含流动效应（风速、Re数）
      - 包含物性效应（扩散系数）

    $ boxed("通量" = "驱动力" / "阻力") $

    这是所有传输现象的*本构关系*。
  ],
)

== 3.6 类比帮助理解

=== 3.6.1 电路类比

#table(
  columns: (1fr, 1fr, 1fr),
  align: center,
  [*物理量*], [*电学*], [*传热*],
  [驱动力], [电压 $V$], [温差 $Delta T$],
  [通量], [电流 $I$], [热流 $C$],
  [阻力], [电阻 $R$], [热阻 $r_H$],
  [本构关系], [$I = V/R$], [$C = rho c_p Delta T / r_H$],
)

=== 3.6.2 水流类比

*密闭系统*（两个连通水库）：
- 问题：最终水位是多少？
- 方法：总水量守恒
- 不需要：管道粗细

*开放系统*（水泵维持水位差）：
- 问题：每秒流量是多少？
- 方法：流量 = 压差 / 阻力
- 必须知道：管道直径、长度、粗糙度

== 3.7 参考文献

- Monteith, J. L., & Unsworth, M. H. (2013). _Principles of Environmental Physics_ (4th ed.). Academic Press. Chapter 13.

- Penman, H. L. (1948). Natural evaporation from open water, bare soil and grass. _Proceedings of the Royal Society of London A_, 193(1032), 120-145.

#align(center)[
  #text(size: 10pt, style: "italic")[
    --- 文档结束 ---
  ]
]
