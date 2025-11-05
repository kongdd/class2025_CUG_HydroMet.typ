#import "./typst/lib.typ": *

#show: (doc) => template(doc,
  footer: "CUG水文气象学2024",
  header: "干球温度与湿球温度推导")

= 从干球温度到湿球温度的推导

== 1. 物理情景

=== 1.1 初始状态（X点）- 干球温度

- 温度：$T$（干球温度，即空气实际温度）
- 水汽压：$e$（未饱和，$e < "es"(T)$）
- 相对湿度：$"RH" = e\/"es"(T) < 100%$

=== 1.2 最终状态（Y点）- 湿球温度

- 温度：$T'$（湿球温度，$T' < T$）
- 水汽压：$"es"(T')$（达到饱和）
- 相对湿度：$"RH" = 100%$

=== 1.3 过程条件

- *避光*：$R_n = 0$（无净辐射）
- *湿布包裹*，充分供水
- *绝热过程*：$lambda E + H = 0$

== 2. 推导过程

=== 2.1 第一步：写出潜热和感热表达式

==== 潜热通量

$ lambda E [X -> Y] = lambda Delta(rho_v) V = lambda epsilon rho / P Delta(e) dot V $

其中：
- $Delta(e) = "es"(T') - e > 0$（水汽压升高）
- $lambda E > 0$：*吸收热量进行蒸发*

==== 感热通量

$ H[X -> Y] = c_p rho V Delta(T) $

其中：
- $Delta(T) = T' - T < 0$（温度降低）
- $H < 0$：*释放感热*

=== 2.2 第二步：能量平衡

在绝热条件下（$R_n = 0$）：

$ lambda E + H = 0 $

代入上述表达式：

$ lambda epsilon rho / P Delta(e) dot V + c_p rho V Delta(T) = 0 $

消去 $rho V$：

$ lambda epsilon / P Delta(e) + c_p Delta(T) = 0 $

整理得：

$ Delta(e) = -(c_p P) / (epsilon lambda) Delta(T) = -gamma Delta(T) $

其中，*湿度计常数*：

$ gamma = (c_p P) / (epsilon lambda) approx 66.5 "Pa"/℃ $

（在标准大气压下）

== 3. 物理意义解释

公式 $Delta(e) = -gamma Delta(T)$ 描述了*绝热蒸发降温*过程：

#table(
  columns: (auto, auto, auto),
  align: (center, center, left),
  [*物理量变化*], [*数学表达*], [*物理过程*],
  [温度], [$Delta(T) = T' - T < 0$], [温度*降低*],
  [水汽压], [$Delta(e) = "es"(T') - e > 0$], [水汽压*升高*],
  [能量转换], [$Delta(e) = -gamma Delta(T)$], [感热转化为潜热],
)

=== 3.1 关键点

1. 湿布表面的水*蒸发*（不是冷凝！）

2. 蒸发需要吸收热量（潜热 $lambda E > 0$）

3. 热量来自空气降温释放的感热（$H < 0$）

4. 最终达到平衡：湿球温度 $T'$，水汽压饱和 $"es"(T')$

=== 3.2 蒸发与冷凝的区别

#showybox(frame: (
    border-color: red.darken(30%),
    body-color: red.lighten(95%) ),
  )[

- *蒸发*：液态水 → 水汽，水汽压*升高*，*吸收*热量
- *冷凝*：水汽 → 液态水，水汽压*降低*，*释放*热量

在湿球温度计中，湿布上的水*蒸发到空气中*，所以是*蒸发过程*，不是冷凝！
]

== 4. 求解湿球温度的公式

从 $Delta(e) = -gamma Delta(T)$ 可以得到：

$ "es"(T') - e = -gamma (T' - T) $

$ "es"(T') = e + gamma (T - T') $

这是计算湿球温度 $T'$ 的*隐式方程*，需要迭代求解。

=== 4.1 线性近似方法

可以用线性近似：

$ "es"(T') approx "es"(T) - Delta dot Delta(T) $

其中 $Delta = (d "es") / (d T) |_T$ 是饱和水汽压曲线的斜率。

结合能量平衡，可以得到：

$ "es"(T') approx "es"(T) - Delta (T' - T) $

联立 $"es"(T') = e + gamma (T - T')$，可以解出：

$ T' = T - ("es"(T) - e) / (Delta + gamma) $

或者用饱和水汽压差（VPD）表示：

$ T' = T - "VPD" / (Delta + gamma) $

其中 $"VPD" = "es"(T) - e$。

== 5. 数值示例

假设：
- 干球温度 $T = 30℃$
- 相对湿度 $"RH" = 50%$
- $"es"(30℃) = 4.24 "kPa"$
- $e = 0.5 times 4.24 = 2.12 "kPa"$
- $Delta approx 189 "Pa"/℃$（在30℃时）
- $gamma approx 66.5 "Pa"/℃$

计算湿球温度：

$ T' = 30 - (4240 - 2120) / (189 + 66.5) = 30 - 2120 / 255.5 approx 21.7℃ $

因此，湿球温度约为 *21.7℃*，比干球温度低了约 *8.3℃*。

== 6. 应用

=== 6.1 湿度测量

通过测量干球温度和湿球温度，可以反推空气的水汽压和相对湿度。

=== 6.2 蒸发冷却

湿球温度是蒸发冷却能达到的理论最低温度，用于：
- 空调设计（湿帘冷却）
- 冷却塔设计
- 干燥过程分析

=== 6.3 气象观测

干湿球温度计是传统气象观测的重要仪器。