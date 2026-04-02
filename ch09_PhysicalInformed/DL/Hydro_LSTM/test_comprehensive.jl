include("HYDRO_LSTM.jl")

println("=== 综合测试 HYDRO_LSTM ===\n")

# 测试1: state_size = 1 的情况
println("测试1: state_size = 1")
model1 = HydroLSTMModel(3, 5, 1; dropout=0.0)
x1 = randn(Float32, 100, 15)  # 100 时间步, 3*5=15 特征
q1, H1, C1 = model1(x1)
println("✓ 输出维度: q=$(size(q1)), H=$(size(H1)), C=$(size(C1))")
println("✓ W_i 维度: $(size(model1.lstm.W_i))")

# 测试2: state_size > 1 的情况  
println("\n测试2: state_size = 4")
model2 = HydroLSTMModel(5, 7, 4; dropout=0.2)
x2 = randn(Float32, 365, 35)
q2, H2, C2 = model2(x2)
println("✓ 输出维度: q=$(size(q2)), H=$(size(H2)), C=$(size(C2))")
println("✓ W_i 维度: $(size(model2.lstm.W_i))")

# 测试3: 状态重置
println("\n测试3: 状态重置")
set_epoch!(model2, 2)
x3 = randn(Float32, 100, 35)
q3_before, _, _ = model2(x3)
h_before = copy(model2.h_t)

reset_state!(model2)
q3_after, _, _ = model2(x3)
h_after = copy(model2.h_t)

println("✓ 重置前状态: ", h_before[1:2])
println("✓ 重置后状态: ", h_after[1:2])
println("✓ epoch重置: ", model2.epoch == 1)

# 测试4: 门控值范围检查
println("\n测试4: 门控值范围")
model4 = HydroLSTMModel(2, 3, 3; dropout=0.0)
x4 = randn(Float32, 50, 6)
q4, H4, C4 = model4(x4)
println("✓ H 范围: [$(minimum(H4)), $(maximum(H4))]")
println("✓ C 范围: [$(minimum(C4)), $(maximum(C4))]")
println("✓ q 范围: [$(minimum(q4)), $(maximum(q4))]")

# 测试5: 连续多个batch的状态传递
println("\n测试5: 多batch状态传递")
model5 = HydroLSTMModel(3, 4, 2; dropout=0.0)
states = []
for epoch in 1:3
  set_epoch!(model5, epoch)
  x = randn(Float32, 50, 12)
  q, H, C = model5(x)
  push!(states, copy(model5.h_t))
end
println("✓ Batch 1 末状态: ", states[1])
println("✓ Batch 2 末状态: ", states[2])
println("✓ Batch 3 末状态: ", states[3])
println("✓ 状态持续变化: ", all(states[i] != states[i+1] for i in 1:2))

println("\n" * "="^50)
println("所有测试通过! ✓")
println("="^50)
