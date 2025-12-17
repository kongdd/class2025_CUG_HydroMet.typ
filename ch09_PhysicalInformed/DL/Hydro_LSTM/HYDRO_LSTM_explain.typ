// HYDRO_LSTM 代码与数学公式对照表
#import "@local/modern-cug-report:0.1.3": *
// #show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

// #set page(width: auto, height: auto, margin: 1em)
// #set text(font: "Source Han Sans SC", size: 10pt)

= 1 HYDRO_LSTM 代码解析

== 1.1 模型架构概述

HYDRO_LSTM与标准LSTM的核心区别：*多状态变量*（`state_size`）

- 标准LSTM: 单一隐藏状态 $bold(h)_t$
- HYDRO_LSTM: 多个独立状态变量，如 积雪 $S_"snow"$、土壤水 $S_"soil"$、水库 $S_"res"$、地下水 $S_"gw"$ 等

#v(0.5em)

== 1.2 参数初始化

#table(
  columns: (1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [*Python 代码*], [*说明*],

  [```python
  self.state_size = state_size
  ```],
  [状态变量个数 $n$，如 $n=4$ 表示4个水文储量],

  [```python
  # state_size == 1
  weight_input: (4, input_size)
  # state_size > 1
  weight_input: (state_size, 4, input_size)
  ```],
  [输入权重维度随状态数变化：
    - 单状态: $bold(W)_i in RR^(4 times d)$
    - 多状态: $bold(W)_i in RR^(n times 4 times d)$
    每个状态变量有独立的权重],

  [```python
  weight_recur: (4, state_size)
  bias: (4, state_size)
  ```],
  [循环权重 $bold(W)_r in RR^(4 times n)$
    偏置 $bold(b) in RR^(4 times n)$
    4对应4个门 (f, i, o, g)],
)

#v(0.5em)

== 1.3 状态初始化（对角矩阵表示）

#table(
  columns: (1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [*Python 代码*], [*数学含义*],

  [```python
  h_0 = torch.diagflat(h_0)
  c_0 = torch.diagflat(c_0)
  ```],
  [将向量转为对角矩阵，*实现状态间的独立性*：
    $ bold(H)_0 = "diag"(h_1, h_2, ..., h_n) $
    每个状态变量独立演化，不相互干扰],
)

#v(0.5em)

== 1.4 门控计算（单状态 vs 多状态）

#table(
  columns: (1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [*Python 代码*], [*数学公式*],

  // 单状态情况
  [```python
  # state_size == 1
  gates = torch.addmm(bias, weight_recur, h_0) \
        + torch.mm(weight_input, x_t)
  ```],
  [单状态门控计算：
    $ bold(G) = bold(W)_r bold(H)_(t-1) + bold(W)_i bold(x)_t + bold(b) $],

  // 多状态情况
  [```python
  # state_size > 1
  x_t = x_t.repeat(state_size, 1, 1)
  sum1 = torch.bmm(weight_input, x_t)
  gates = torch.addmm(bias, weight_recur, h_0) + sum1
  ```],
  [多状态门控计算（批量矩阵乘法）：
    $ bold(G)^((k)) = bold(W)_r^((k)) bold(H)_(t-1) + bold(W)_i^((k)) bold(x)_t + bold(b)^((k)) $
    $k = 1, 2, ..., n$ 为各状态变量索引],
)

#v(0.5em)

== 1.5 四个门的激活

#table(
  columns: (1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [*Python 代码*], [*数学公式*],

  [```python
  f, i, o, g = gates.chunk(4, dim=0)
  ```],
  [将门向量拆分为4个门：$bold(G) -> (bold(f), bold(i), bold(o), bold(g))$],

  [```python
  f = torch.sigmoid(f)  # [0,1]
  ```],
  [遗忘门: $bold(f)_t = sigma(bold(G)_f) in [0,1]$],

  [```python
  i = torch.sigmoid(i)  # [0,1]
  ```],
  [输入门: $bold(i)_t = sigma(bold(G)_i) in [0,1]$],

  [```python
  o = torch.sigmoid(o)  # [0,1]
  ```],
  [输出门: $bold(o)_t = sigma(bold(G)_o) in [0,1]$],

  [```python
  g = torch.tanh(g)     # [-1,1]
  ```],
  [候选状态: $tilde(bold(c))_t = tanh(bold(G)_g) in [-1,1]$],
)

#v(0.5em)

== 1.6 细胞状态更新（核心水文物理）

#table(
  columns: (1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [*Python 代码*], [*数学公式 & 水文意义*],

  [```python
  # state_size == 1
  c_1 = f * c_0 + i * g
  ```],
  [单状态更新：
    $ c_t = f_t dot c_(t-1) + i_t dot tilde(c)_t $],

  [```python
  # state_size > 1
  c_1 = torch.mm(f, c_0) + torch.mul(i, g)
  c_1 = torch.diagflat(c_1)
  ```],
  [多状态更新（对角矩阵保持独立性）：
    $ bold(C)_t = bold(F)_t bold(C)_(t-1) + bold(I)_t dot.circle tilde(bold(C))_t $

    *水文意义*：
    - $bold(C)_t$: 各储量状态 (积雪、土壤、地下水...)
    - $bold(F)_t$: 各储量的保持率 (衰减)
    - $bold(I)_t dot.circle tilde(bold(C))_t$: 输入补给量
  ],
)

#v(0.5em)

== 1.7 隐藏状态输出（流量计算）

#table(
  columns: (1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [*Python 代码*], [*数学公式 & 水文意义*],

  [```python
  h_1 = torch.mul(o, torch.tanh(c_1))
  ```],
  [$ bold(h)_t = bold(o)_t dot.circle tanh(bold(C)_t) $

    *水文意义*：线性水库出流
    - $bold(o)_t$: 各储量的出流系数
    - $tanh(bold(C)_t)$: 归一化储量
    - $bold(h)_t$: 各储量对总径流的贡献
  ],

  [```python
  h_1 = torch.diag(h_1, 0)
  h_n = torch.cat((h_n, h_1), 0)
  ```],
  [提取对角线元素，拼接时间序列：
    $ bold(H) = [bold(h)_1, bold(h)_2, ..., bold(h)_T] $],
)

#v(0.5em)

== 1.8 最终流量输出

#table(
  columns: (1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [*Python 代码*], [*数学公式*],

  [```python
  self.regression = nn.Linear(state_size, 1)
  q_t = self.regression(h_t)
  ```],
  [多状态汇流到单一出口：
    $ Q_t = sum_(k=1)^n w_k dot h_t^((k)) + b $

    将各储量贡献加权求和得到总流量],
)

// #v(1em)
// #line(length: 100%)

#pagebreak()

== 1.9 符号说明

#table(
  columns: (auto, auto, auto),
  inset: 5pt,
  [*符号*], [*名称*], [*取值/意义*],
  [$sigma$], [Sigmoid], [$[0,1]$],
  [$tanh$], [双曲正切], [$[-1,1]$],
  [$dot.o$], [Hadamard积], [逐元素乘法],
  [$n$], [state_size], [状态变量个数],
  [$bold(f)_t$], [遗忘门], [控制历史信息保留],
  [$bold(i)_t$], [输入门], [控制新信息接收],
  [$bold(o)_t$], [输出门], [控制出流系数],
  [$bold(C)_t$], [细胞状态], [水文储量 (长期记忆)],
  [$bold(h)_t$], [隐藏状态], [出流贡献 (短期输出)],
)

#v(0.5em)

== 1.10 水文物理解释

#block(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
)[
  *HYDRO_LSTM 将 LSTM 结构映射到水文系统：*

  - *状态变量* ($bold(C)_t$): 多个独立水文储量
    - $C^((1))$: 积雪储量
    - $C^((2))$: 土壤水储量
    - $C^((3))$: 浅层地下水
    - $C^((4))$: 深层地下水 / 水库

  - *遗忘门* ($bold(f)_t$): 各储量的衰减/消耗率
  - *输入门* ($bold(i)_t$): 降水分配到各储量的比例
  - *输出门* ($bold(o)_t$): 各储量对径流的贡献系数

  *关键创新*：使用对角矩阵保持状态独立性，避免物理上不合理的状态耦合
]
