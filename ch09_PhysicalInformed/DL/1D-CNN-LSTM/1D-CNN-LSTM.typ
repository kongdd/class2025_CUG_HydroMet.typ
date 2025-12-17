#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "1D-CNN-LSTM 混合模型")
#import "@preview/oxdraw:0.1.0": *
// #set par(leading: 1em, spacing: 1.0em)

= 1D-CNN-LSTM 基本原理

在水文时间序列预测中，*1D-CNN-LSTM* 是一种经典的混合深度学习架构。它结合了卷积神经网络 (CNN) 的特征提取能力和长短期记忆网络 (LSTM) 的时序建模能力。

== 1. 数据输入格式

=== 1.1 维度约定

假设有一组水文气象数据：$N=32$ (batch), $L=100$ (时间步), $C=5$ (特征数：降水、温度、辐射、湿度、风速)。

#block[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 6pt,
    align: (horizon),
    stroke: 0.5pt,
    [*阶段*], [*PyTorch*], [*Flux.jl*], [*说明*],
    [1D-CNN 输入], [`(Batch, C, L)` =\ `(32, 5, 100)`], [`(C, L, Batch)` =\ `(5, 100, 32)`], [C=特征数, L=时间步],
    [1D-CNN 输出], [`(32, 16, 100)`], [`(16, 100, 32)`], [特征数 5 → 16],
    [LSTM 输入], [`(Batch, Seq, Feat)` =\ `(32, 100, 16)`], [`(Feat, Seq, Batch)` =\ `(16, 100, 32)`], [需维度置换],
    [LSTM 输出], [`(32, 100, Hidden)`], [`(Hidden, 100, 32)`], [每个时间步\ 隐藏状态],
  )
]

#block(fill: luma(240), inset: 8pt, radius: 4pt)[
  *核心思想*：CNN 作为"特征工程"工具，将 5 个气象变量提取为 16 个抽象特征；LSTM 在抽象特征上进行时序推理。
]

=== 1.2 构建训练样本：滑动窗口

假设原始数据长度 10000 时刻，窗口 $L=64$，步长 stride=1：
- 样本数 $N = 10000 - 64 + 1 = 9937$

#block[
  #table(
    columns: (auto, auto, auto),
    inset: 6pt,
    stroke: 0.5pt,
    [*框架*], [*形状*], [*说明*],
    [PyTorch], [`(9937, 5, 64)`], [`(Batch, C, L)`],
    [Flux.jl], [`(5, 64, 9937)`], [`(C, L, Batch)`],
  )
]

```julia
data = rand(Float32, 5, 10000)  # (C, T)
L = 64
X = stack([data[:, t:t+L-1] for t in 1:size(data,2)-L+1], dims=3)  # (5, 64, 9937)
```

#block(fill: rgb(255, 250, 230), inset: 8pt, radius: 4pt)[
  *样本重叠问题*：相邻窗口共享 63/64 数据。

  - *训练时*：无害，相当于数据增强。
  - *验证/测试*：需按时间切分（如 train:val:test = 8000:1000:1000），避免数据泄露。
  - *减少重叠*：增大 stride，如 `stride=32` → 样本数 ≈ 311。
]

=== 1.3 LSTM 的特殊需求

#block(fill: rgb(230, 245, 255), inset: 8pt, radius: 4pt)[
  #table(
    columns: (auto, auto, auto),
    inset: 6pt,
    stroke: 0.5pt,
    [*模式*], [*状态处理*], [*适用场景*],
    [滑动窗口], [每窗口重置], [CNN-LSTM 混合、多流域并行],
    [完整序列], [状态连续传递], [纯 LSTM、水文物理模拟],
  )

  - *纯 LSTM*：推荐完整序列（土壤湿度等具有长期记忆）。
  - *CNN-LSTM*：滑窗可行（CNN 先提取局部特征）。

  *三种输入方式*（3 变量，128 时刻）：

  #table(
    columns: (auto, auto, auto, auto),
    inset: 6pt,
    stroke: 0.5pt,
    [*方式*], [*形状*], [*时间依赖*], [*适用*],
    [① 完整序列], [`(3, 128)`], [自动学习], [*推荐*],
    [② 固定窗口], [`(3, 24, 128)`], [人工限定], [已知时间尺度],
    [③ 特征拼接], [`(72, 128)`], [无], [不关心时序],
  )
]

#block(fill: luma(245), inset: 8pt, radius: 4pt)[
  *为什么 CNN 需要滑窗，而 LSTM 不需要？*

  #table(
    columns: (auto, auto, auto),
    inset: 6pt,
    stroke: 0.5pt,
    [], [*CNN*], [*LSTM*],
    [计算方式], [局部卷积，无记忆], [递归，有状态记忆],
    [感受野], [固定 (= kernel size)], [理论无限 (隐藏状态传递)],
    [类比], [显微镜：只看局部], [日记本：记录所有历史],
  )

  - *CNN*：卷积核 $K=3$ 只能看 3 个时刻，需人工切窗口限定感受野。
  - *LSTM*：$h_t = f(x_t, h_(t-1))$，隐藏状态自动"滚动"传递历史信息。

  *为什么要融合 CNN 和 LSTM？*

  #table(
    columns: (auto, auto, auto),
    inset: 6pt,
    stroke: 0.5pt,
    [], [*单独使用的弱点*], [*融合后的作用*],
    [CNN], [无法捕捉长期依赖], [降噪 + 提取局部特征],
    [LSTM], [对高频噪声敏感], [在干净特征上建模长期记忆],
  )

  *数据流*：原始信号 → CNN (降噪+特征提取) → LSTM (长期记忆) → 预测

  *层级维度变化示例*（Flux.jl 格式，C=5, L=64, Batch=32, Hidden=128）：

  #table(
    columns: (auto, auto, auto),
    inset: 6pt,
    stroke: 0.5pt,
    [*层*], [*输出维度*], [*说明*],
    [Input], [`(5, 64, 32)`], [C=5 特征, L=64 时间步],
    [Conv1D(5→16, k=3)], [`(16, 62, 32)`], [特征增加，L 减少 k-1],
    [ReLU], [`(16, 62, 32)`], [激活，维度不变],
    [Permute], [`(16, 62, 32)`], [Flux 无需置换],
    [LSTM(16→128)], [`(128, 62, 32)`], [隐藏状态维度],
    [Dense(128→1)], [`(1, 62, 32)`], [输出预测值],
  )

  *为什么 L 从 64 变成 62？*

  Conv1D 默认无 padding，卷积核 $k=3$ 会"吃掉"边缘：$L_"out" = L_"in" - k + 1 = 64 - 3 + 1 = 62$。

  *输出 `(1, 62, 32)` 的含义*：对于每个输入窗口 (64 时刻)，模型输出 62 个时刻的预测值 (Many-to-Many)。

  #table(
    columns: (auto, auto, auto),
    inset: 6pt,
    stroke: 0.5pt,
    [*模式*], [*输出形状*], [*应用*],
    [Many-to-Many], [`(1, 62, 32)`], [预测连续多天径流],
    [Many-to-One], [`(1, 32)`], [只预测窗口最后一天],
  )

  *时刻对应关系*：
  ```
  输入: t=1, 2, 3, ... 62, 63, 64  (气象数据)
  输出:    y₂, y₃, ...  y₆₂, y₆₃    (对应 t=2 到 t=63)
  ```

  - Conv1D (k=3) 在位置 t=2 时"看"t=1,2,3 → 输出对应 t=2
  - 62 个输出是*当前时刻*的预测，不是"未来"预测
  - 模型自动学习降雨到产流的滞后关系
]

== 2. 1D-CNN 原理：时间维度的滑动窗口

1D-CNN (一维卷积) 在序列数据上沿*时间轴*滑动。

=== 卷积公式

对于第 $k$ 个输出通道，第 $t$ 个时间步的输出 $y_t^k$ 计算如下：

$ y_t^k = f(sum_(i=0)^(C_in - 1) sum_(j=0)^(K-1) w_(i,j)^k dot x_(t+j)^i + b^k) $

其中：
- $x$: 输入序列，$x^i$ 是第 $i$ 个输入特征。
- $w$: 卷积核权重，大小为 $C_in times K$ (输入特征数 $times$ 卷积核大小)。
- $K$: 卷积核长度 (Kernel Size)，例如 3 或 5，代表感受野范围。
- $b$: 偏置项。
- $f$: 激活函数 (通常为 ReLU)。

=== 物理意义：水文特征提取

在水文中，1D-CNN 的作用类似于*滑动平均*或*差分计算*的推广：

- *平滑核*：学习捕捉低频趋势（如季节性变化）。
- *差分核*：学习捕捉高频突变（如暴雨事件的起始时刻）。

通过堆叠多个卷积核，网络自动学习出对降雨-径流关系最有用的局部模式。

== 3. LSTM 原理简述

(详细推导见上一节 LSTM 序列处理)

LSTM 通过门控机制解决了长序列训练中的梯度消失问题。

核心公式回顾：
$ bold(f)_t = sigma(W_f dot [bold(h)_(t-1), bold(x)_t] + bold(b)_f) quad ("遗忘门") $
$ bold(i)_t = sigma(W_i dot [bold(h)_(t-1), bold(x)_t] + bold(b)_i) quad ("输入门") $
$ bold(c)_t = bold(f)_t dot bold(c)_(t-1) + bold(i)_t dot tanh(W_c dot [bold(h)_(t-1), bold(x)_t] + bold(b)_c) $
$ bold(h)_t = bold(o)_t dot tanh(bold(c)_t) $

在混合模型中，这里的输入 $bold(x)_t$ 不再是原始气象数据，而是 *CNN 提取后的特征向量*。

== 4. 混合模型架构 (Hybird Architecture)

为什么要把它们结合起来？

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  block(
    fill: rgb(230, 245, 255),
    inset: 8pt,
    radius: 4pt,
    [*CNN 的优势*]
      + [
        - 局部感知：擅长捕捉短期的局部依赖（例如一次连续3天的降雨过程）。
        - 计算高效：卷积是并行的，比 RNN 快。
        - 特征提取：能从含噪数据中提取鲁棒特征。
      ],
  ),
  block(
    fill: rgb(255, 245, 230),
    inset: 8pt,
    radius: 4pt,
    [*LSTM 的优势*]
      + [
        - 全局记忆：擅长捕捉长期的依赖关系（例如流域的前期土壤湿度记忆）。
        - 序列建模：天生适合处理时间顺序。
      ],
  ),
)

=== 模型结构图示

```mermaid
graph LR
    Input[原始气象序列\n(Batch, Feat, Time)] --> CNN[1D Conv 层\n提取局部特征]
    CNN --> Relu[ReLU 激活]
    Relu --> Pool[Pooling (可选)\n降低时间分辨率]
    Pool --> Permute[维度变换\n(Time, Batch, NewFeat)]
    Permute --> LSTM[LSTM 层\n捕捉长期记忆]
    LSTM --> Dense[全连接层\n映射到目标变量]
    Dense --> Output[预测径流 Q]
```

#oxdraw("
graph TD
    A[Start] --> B[End]
")

=== 应用案例

*案例：洪水预报*

1. *CNN 层*：识别短期暴雨模式。例如，卷积核可能学到了"急剧上升的降雨脉冲"这一特征。
2. *LSTM 层*：结合当前的暴雨特征和之前的土壤湿度状态（隐藏状态 $h$），进行最终的流量预测。

如果只用 LSTM，可能对突发暴雨的高频信号不够敏感；如果只用 CNN，则无法有效利用两个月前的干旱对当前产流的影响。两者结合，互补短板。
