// #import "../typst/lib.typ": *
#import "@local/modern-cug-report:0.1.3": *
#counter(heading).update(2)
#let delta(x) = $Delta #x$

#set par(spacing: 1.3em, leading: 1.3em)
#show: doc => template(
  doc,
  size-config: (
    math: (
      text: 12pt, // 插入正文的公式
      block: 12pt, // 单独一行的公式
    ),
  ),
  pagenum: true,
  footer: "CUG水文气象学2025",
  header: "第九章 深度学习水文预报",
)

// =
// =
// =
// =
// =
= 6 水文预报

== 6.1 LSTM (Long Short-Term Memory)

LSTM 通过门控机制解决了 RNN 的梯度消失问题，能够学习长期依赖关系。

#box-blue[
  遗忘门$f_t$、输入门$i_t$、候选单元状态$tilde(C)_t$、单元状态$C_t$、输出门$O_t$、隐状态$H_t$、输出$Y_t$
]

$
  f_t &= sigma(W_f dot [H_(t-1), X_t]) \
  i_t &= sigma(W_i dot [H_(t-1), X_t]) \
  tilde(C)_t &= tanh(W_c dot [H_(t-1), X_t]) \
  C_t &= f_t dot.o C_(t-1) + i_t dot.o tilde(C)_t \
  O_t &= sigma(W_o dot [H_(t-1), X_t]) \
  H_t &= O_t dot.o tanh(C_t) \
  Y_t &= W_q dot H_t
$

其中：
- $[H_(t-1), X_t]$：将隐状态和输入拼接
- $W_f, W_i, W_c, W_o, W_q$：权重矩阵（已包含偏置）
- $C_t$：单元状态（长期记忆）
- $H_t$：隐状态（短期记忆/输出）



== 6.2 Peephole LSTM

Peephole LSTM 是 LSTM 的一种变体，其特点是门控单元可以"偷看"（peep）单元状态 $C$。

#box-blue[
  遗忘门$f_t$、输入门$i_t$、候选单元状态$tilde(C)_t$、单元状态$C_t$、输出门$o_t$、隐状态$H_t$、输出$Y_t$
]

$
  f_t &= sigma(W_f dot [H_(t-1), X_t] + C_(t-1) dot.o W_(p f)) \
  i_t &= sigma(W_i dot [H_(t-1), X_t] + C_(t-1) dot.o W_(p i)) \
  tilde(C)_t &= tanh(W_c dot [H_(t-1), X_t]) \
  C_t &= f_t dot.o C_(t-1) + i_t dot.o tilde(C)_t \
  O_t &= sigma(W_o dot [H_(t-1), X_t] + C_t dot.o W_(p o)) \
  H_t &= O_t dot.o tanh(C_t) \
  Y_t &= W_q dot H_t
$

其中：
- $[H_(t-1), X_t]$：将隐状态和输入拼接
- $W_f, W_i, W_c, W_o$：权重矩阵（已包含偏置）
- $W_(c f), W_(c i), W_(c o)$：peephole 权重（对角矩阵）
- $C_t$：单元状态（长期记忆）
- $H_t$：隐状态（短期记忆/输出）




== 6.3 GRU (Gated Recurrent Unit)

GRU 是一种循环神经网络结构，通过门控机制来控制信息的流动。其核心公式如下：

#box-blue[
  更新门$Z_t$、重置门$R_t$、候选隐状态$tilde(H)_t$、隐状态$H_t$、输出$Y_t$
]

$
  Z_t &= sigma(W_z dot [H_(t-1), X_t]) \
  R_t &= sigma(W_r dot [H_(t-1), X_t]) \
  tilde(H)_t &= tanh(W_h dot [R_t dot.o H_(t-1), X_t]) \
  H_t &= Z_t dot.o H_(t-1) + (1 - Z_t) dot.o tilde(H)_t \
  Y_t &= W_q dot H_t
$

其中：
- $[H_(t-1), X_t]$：将隐状态和输入拼接
- $W_z, W_r, W_h, W_q$：权重矩阵（已包含偏置）
- $dot.o$：按元素乘法 (Hadamard 积)
- $sigma$：Sigmoid 激活函数

*代码实现：*
```python
H, = state
outputs = []
for X in inputs:
    Z = torch.sigmoid((X @ W_xz) + (H @ W_hz) + b_z)
    R = torch.sigmoid((X @ W_xr) + (H @ W_hr) + b_r)
    H_tilda = torch.tanh((X @ W_xh) + ((R * H) @ W_hh) + b_h)
    H = Z * H + (1 - Z) * H_tilda
    Y = H @ W_hq + b_q
    outputs.append(Y)
return torch.cat(outputs, dim=0), (H,)
```
