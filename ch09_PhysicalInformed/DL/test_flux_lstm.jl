using Flux

println("=== Flux.jl LSTM 维度测试 ===\n")

lstm = LSTM(5 => 64)

# 1. 二维输入 (features, seq) — 单样本序列
println("1. 二维输入 (features, seq)")
x2 = rand(Float32, 5, 100)  # 5特征 × 100时刻
println("   输入: ", size(x2))
y2 = lstm(x2)
println("   输出: ", size(y2))

Flux.reset!(lstm)

# 2. 三维输入 (features, seq, batch) — 多样本序列
println("\n2. 三维输入 (features, seq, batch)")
x3 = rand(Float32, 5, 100, 32)  # 5特征 × 100时刻 × 32样本
println("   输入: ", size(x3))
y3 = lstm(x3)
println("   输出: ", size(y3))

println("\n=== 总结 ===")
println("Flux.jl LSTM 维度规则:")
println("  输入 (5, 100)     → 输出 (64, 100)      # 单样本序列")
println("  输入 (5, 100, 32) → 输出 (64, 100, 32)  # 多样本序列")
println("\n维度顺序: (features, seq, batch)")
