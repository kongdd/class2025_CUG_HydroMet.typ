#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "LSTM 序列处理详解")

#set par(leading: 1em, spacing: 0.9em)

= LSTM 序列处理

== 1. 核心概念：三个维度

LSTM 处理*序列数据*，关键是理解三个维度的区别：

#table(
  columns: (auto, auto, auto, auto),
  inset: 6pt,
  stroke: 0.5pt,
  [*维度*], [*含义*], [*依赖关系*], [*示例*],
  [`features`], [每时刻的特征数], [无], [3个气象变量],
  [`seq`], [时间步数], [*有依赖*，状态传递], [365天],
  [`batch`], [独立样本数], [无依赖，并行], [32个流域],
)

#block(
  fill: luma(240),
  inset: 8pt,
  radius: 4pt,
)[
  *关键区别*：seq 内部状态递归传递，batch 之间完全独立
]

== 2. LSTM 内部 seq 展开机制

每个时刻的计算：

$ bold(h)_t, bold(c)_t = "LSTMCell"(bold(x)_t, bold(h)_(t-1), bold(c)_(t-1)) $

seq 展开就是对时间的循环：

```julia
# Flux.jl 核心代码 (scan函数)
function scan(cell, x, state)
  y = []
  for x_t in eachslice(x, dims=2)   # 沿时间维切片
    yt, state = cell(x_t, state)    # 更新状态
    y = vcat(y, [yt])
  end
  return stack(y, dims=2), state
end
```

== 3. 三种输入方式对比

以"3个气象变量，预测128个时刻"为例：

#table(
  columns: (auto, auto, auto, auto),
  inset: 6pt,
  stroke: 0.5pt,
  [*方式*], [*输入形状*], [*时间依赖*], [*适用场景*],
  [① 完整序列], [`(3, 128)`], [LSTM自动学习], [*推荐，最自然*],
  [② 固定窗口], [`(3, 24, 128)`], [人工限定24h], [已知物理时间尺度],
  [③ 特征拼接], [`(72, 128)`], [无（已平铺）], [不关心时序],
)

=== 方式① 完整序列（推荐）

```julia
x = rand(Float32, 3, 128)  # (feat, time)
y = lstm(x)                 # LSTM自动学习时间依赖
```

优点：不需要人工设定窗口 | 缺点：长序列可能梯度消失

=== 方式② 固定时间窗口

```julia
x = rand(Float32, 3, 24, 128)  # (feat, seq=24小时, batch=128时刻)
y = lstm(x)
```

优点：控制历史窗口长度 | 缺点：需要人工设定

=== 方式③ 特征拼接（lag）

```julia
x = rand(Float32, 72, 128)  # 24h × 3变量 = 72维特征
y = lstm(x)
```

优点：计算快 | 缺点：丢失时序结构

== 4. PyTorch vs Flux.jl

#table(
  columns: (auto, 1fr, 1fr),
  inset: 6pt,
  stroke: 0.5pt,
  [], [*PyTorch*], [*Flux.jl*],
  [维度顺序], [`(batch, seq, feat)`], [`(feat, seq, batch)`],
  [seq展开], [内部自动], [内部自动],
  [状态管理], [显式传入 `(h_0, c_0)`], [隐式保存在层内],
  [状态重置], [传入新初始状态], [`Flux.reset!(lstm)`],
)

== 5. 水文模型特殊需求

=== 跨batch状态传递

普通深度学习：batch 独立，状态重置

水文模型：状态需要*跨batch传递*（土壤水、地下水连续性）

```julia
# ❌ 错误：每个batch重置
for batch in batches
    Flux.reset!(lstm)
    outputs = lstm(batch)
end

# ✅ 正确：状态保持
for batch in batches
    outputs = lstm(batch)  # 状态自动传递
end
```

=== HYDRO_LSTM 的设计

使用 `epoch` 变量控制状态继承：

```julia
if epoch == 1
    h_0, c_0 = zeros(...)       # 首次初始化
else
    h_0, c_0 = model.h_t, model.c_t  # 继承上一batch
end
```

== 6. 总结

#block(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
)[
  *维度规则*：
  - `seq`：时间步，状态递归传递
  - `batch`：独立样本，并行处理

  *输入方式选择*：
  - 单流域：`(feat, time)` 二维即可
  - 多流域：`(feat, time, basin)` 三维
  - 推荐让 LSTM 自动学习时间依赖

  *水文应用*：
  跨batch状态传递是物理需求，不能随意重置
]
