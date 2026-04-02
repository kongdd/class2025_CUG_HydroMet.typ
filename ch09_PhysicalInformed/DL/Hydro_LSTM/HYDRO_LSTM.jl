#=
HYDRO_LSTM in Julia Flux

Reference:
De la Fuente, L. A., Ehsani, M. R., Gupta, H. V., and Condon, L. E.: 
Towards Interpretable LSTM-based Modelling of Hydrological Systems,
EGUsphere [preprint], https://doi.org/10.5194/egusphere-2023-666, 2023.
=#

using Flux
using Functors: @functor
using LinearAlgebra

# HYDRO_LSTM 核心层
mutable struct HydroLSTM
  input_size::Int
  state_size::Int
  W_i::AbstractArray    # 输入权重
  W_r::Matrix{Float32}  # 循环权重
  b::Matrix{Float32}    # 偏置
end

@functor HydroLSTM (W_i, W_r, b)

function HydroLSTM(input_size::Int, state_size::Int)
  if state_size == 1
    W_i = Flux.glorot_uniform(4, input_size)
  else
    W_i = randn(Float32, state_size, 4, input_size) .* Float32(sqrt(2 / (4 + input_size)))
  end
  W_r = Flux.glorot_uniform(4, state_size)
  b = zeros(Float32, 4, state_size)
  HydroLSTM(input_size, state_size, W_i, W_r, b)
end

# 单步前向传播
function (m::HydroLSTM)(x_t::AbstractVector, h_prev::AbstractVector, c_prev::AbstractVector)
  n = m.state_size

  # 对角矩阵保持状态独立性
  H = diagm(h_prev)
  C = diagm(c_prev)

  # 计算门控
  if n == 1
    gates = m.W_r * H .+ m.W_i * x_t .+ m.b
  else
    sum1 = zeros(Float32, 4, n)
    for k in 1:n
      sum1[:, k] = m.W_i[k, :, :] * x_t
    end
    gates = m.W_r * H .+ sum1 .+ m.b
  end

  # 拆分4个门
  f = σ.(gates[1, :])    # 遗忘门 [0,1]
  i = σ.(gates[2, :])    # 输入门 [0,1]
  o = σ.(gates[3, :])    # 输出门 [0,1]
  g = tanh.(gates[4, :]) # 候选状态 [-1,1]

  # 细胞状态更新
  if n == 1
    c_new = f .* diag(C) .+ i .* g
  else
    F = diagm(f)
    c_new = diag(F * C) .+ i .* g
  end

  # 隐藏状态输出 (线性水库)
  h_new = o .* tanh.(c_new)

  h_new, c_new
end

# 序列前向传播（支持初始状态传入，用于跨batch传递）
# 使用 map + scan 模式，避免原地修改以支持自动微分
function forward_seq(m::HydroLSTM, x::AbstractMatrix, h_0::AbstractVector, c_0::AbstractVector)
  seq_len = size(x, 1)  # 第一维是时间步（与Python原版一致）
  
  # 使用 accumulate 进行状态传递（函数式编程）
  states = accumulate(1:seq_len; init=(h_0, c_0)) do (h, c), t
    m(Float32.(x[t, :]), h, c)
  end
  
  # 提取所有时间步的隐藏状态和细胞状态
  H = reduce(vcat, [reshape(s[1], 1, :) for s in states])
  C = reduce(vcat, [reshape(s[2], 1, :) for s in states])
  
  H, C
end


# 完整模型 Model_hydro_lstm（保存状态用于跨batch传递）
mutable struct HydroLSTMModel
  input_size::Int      # 原始输入特征数
  lag::Int             # 时间滞后窗口
  state_size::Int      # 状态变量个数
  lstm::HydroLSTM
  linear::Dense
  dropout::Dropout
  # 状态变量（跨batch传递，类似Python中的self.h_t, self.c_t）
  h_t::Vector{Float32}
  c_t::Vector{Float32}
  epoch::Int           # 用于判断是否重置状态
end

@functor HydroLSTMModel (lstm, linear)

# 对应Python: Model_hydro_lstm.__init__
function HydroLSTMModel(input_size::Int, lag::Int, state_size::Int; dropout=0.0)
  # Python: self.input_size = input_size * lag
  effective_input_size = input_size * lag
  lstm = HydroLSTM(effective_input_size, state_size)  # 使用扩展后的输入维度
  linear = Dense(state_size => 1)
  drop = Dropout(dropout)
  h_t = zeros(Float32, state_size)
  c_t = zeros(Float32, state_size)
  HydroLSTMModel(input_size, lag, state_size, lstm, linear, drop, h_t, c_t, 1)
end

# 对应Python: Model_hydro_lstm.forward
function (m::HydroLSTMModel)(x::AbstractMatrix)
  n = m.state_size

  # 根据epoch决定初始状态
  if m.epoch == 1
    # Python: h_0 = x.data.new(1, self.state_size).zero_()
    h_0 = zeros(Float32, n)
    c_0 = zeros(Float32, n)
  else
    # Python: h_0 = torch.ones(...) * self.h_t.data[-1]
    # 继承上一batch的最终状态（水文连续性）
    h_0 = copy(m.h_t)
    c_0 = copy(m.c_t)
  end

  H, C = forward_seq(m.lstm, x, h_0, c_0)

  # 保存最终状态，供下一batch使用
  m.h_t = H[end, :]
  m.c_t = C[end, :]

  # Python: if self.state_size != 1: h_t_dropout = dropout(h_t)
  if m.state_size != 1
    h_drop = m.dropout(H)
    q = vec(m.linear(h_drop'))
  else
    q = vec(m.linear(H'))
  end

  # Python版因为h_n包含h_0(T+1个)，所以需要[1:]
  # Julia版forward_seq只返回了T个结果，所以不需要切片，直接返回完整序列
  q, H, C
end

# 重置状态（新epoch开始时调用）
function reset_state!(m::HydroLSTMModel)
  m.epoch = 1
  m.h_t .= 0
  m.c_t .= 0
end

# 设置epoch（控制状态是否继承）
function set_epoch!(m::HydroLSTMModel, epoch::Int)
  m.epoch = epoch
end


#= 使用示例
# input_size=5 (特征数), lag=7 (时间窗口), state_size=4 (状态变量数)
model = HydroLSTMModel(5, 7, 4; dropout=0.2)

# 注意：输入维度 = input_size * lag = 5 * 7 = 35
# 第一个epoch，状态从零开始
set_epoch!(model, 1)
x1 = randn(Float32, 365, 35)  # (seq_len=365, feat=35)
q1, H1, C1 = model(x1)

# 后续时间窗口，状态继承（水文连续性）
set_epoch!(model, 2)
x2 = randn(Float32, 365, 35)
q2, H2, C2 = model(x2)  # 使用 x1 结束时的状态作为初始值
=#
