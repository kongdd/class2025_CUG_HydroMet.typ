using Flux
using Functors
using CUDA
using Statistics
using NNlib: batched_mul, softmax


# ==========================================
# 1. Attention 模块 (精细控制参数)
# ==========================================
struct ScaledDotProductAttention
  W_q::Dense
  W_k::Dense
  W_v::Dense
  scale::Float32
end

# 构造函数
function ScaledDotProductAttention(hidden_size::Int, head_size::Int)
  return ScaledDotProductAttention(
    Dense(hidden_size, head_size, bias=false),
    Dense(hidden_size, head_size, bias=false),
    Dense(hidden_size, head_size, bias=false),
    Float32(1.0 / sqrt(head_size))
  )
end

# [重点] 使用 Functors 注册
# 含义：只有 W_q, W_k, W_v 是子节点/参数，scale 被视为普通数据，不参与梯度更新
@functor ScaledDotProductAttention (W_q, W_k, W_v)

function (attn::ScaledDotProductAttention)(query::AbstractArray, key::AbstractArray, value::AbstractArray)
  # query: (hidden, 1, batch)   <- 来自 h_t
  # key:   (hidden, seq, batch) <- 来自 H
  # value: (hidden, seq, batch) <- 来自 H

  # 1. Projections
  q = attn.W_q(query)

  # Flatten key/value for Dense layer compatibility
  B = size(key, 3)
  T = size(key, 2)
  k_flat = reshape(key, size(key, 1), :)
  v_flat = reshape(value, size(value, 1), :)

  k = reshape(attn.W_k(k_flat), :, T, B)
  v = reshape(attn.W_v(v_flat), :, T, B)

  # 2. Scaled Dot-Product
  # (head, 1, B) * (head, T, B)^T -> (1, T, B)
  scores = batched_mul(permutedims(q, (2, 1, 3)), k)
  scores = scores .* attn.scale

  # 3. Attention Weights
  attn_weights = softmax(scores, dims=2)

  # 4. Context
  # (1, T, B) * (T, head, B) -> (1, head, B)
  context = batched_mul(attn_weights, permutedims(v, (2, 1, 3)))

  # Output: (head, B)
  return dropdims(permutedims(context, (2, 1, 3)), dims=2), attn_weights
end


# ==========================================
# 2. 主模型 (自动注册参数)
# ==========================================
struct HydroModel
  encoder
  attention::ScaledDotProductAttention
  decoder::Chain
end

function HydroModel(input_size, hidden_size)
  return HydroModel(
    LSTM(input_size, hidden_size),
    ScaledDotProductAttention(hidden_size, hidden_size),
    Chain(Dense(hidden_size * 2, hidden_size, relu), Dense(hidden_size, 1, softplus))
  )
end

# [重点] 默认用法
# 含义：结构体内的所有字段（encoder, attention, decoder）如果包含参数，都会被 Flux 识别
@functor HydroModel

function (m::HydroModel)(x::AbstractArray)
  # x: (features, seq_len, batch)
  Flux.reset!(m.encoder)

  # 1. Unroll LSTM
  # 相比 map，手动循环更可控，也容易调试
  seq_len = size(x, 2)
  h_list = [m.encoder(x[:, t, :]) for t in 1:seq_len]

  # 2. Prepare Q, K, V
  H = stack(h_list, dims=2) # Keys & Values
  h_last = h_list[end]      # Query Source

  # Reshape h_last to (hidden, 1, batch) for attention
  q_input = reshape(h_last, size(h_last, 1), 1, size(h_last, 2))

  # 3. Attention
  context, _ = m.attention(q_input, H, H)

  # 4. Decode
  return m.decoder(vcat(context, h_last))
end

# ==========================================
# 3. 验证 (Sanity Check)
# ==========================================

model = HydroModel(5, 64)

# 检查参数树
# params(model) 会利用 @functor 定义的规则遍历树
ps = Flux.params(model)
println("Total parameter arrays: ", length(ps))

# 检查 scale 是否被误认为是参数
# 如果 scale 在 params 里，说明 @functor 用错了
has_scale = any(p -> p === model.attention.scale, ps)
println("Is 'scale' trainable? ", has_scale ? "YES (Error)" : "NO (Correct)")

# 模拟运行
x = randn(Float32, 5, 24, 10)
y = model(x)
println("Output shape: ", size(y)) # Should be (1, 10)
