include("HYDRO_LSTM.jl")

# 测试：input_size=5, lag=7, state_size=4
# 实际输入维度 = 5 * 7 = 35
model = HydroLSTMModel(5, 7, 4; dropout=0.0)

# 第一个epoch，状态从零开始
set_epoch!(model, 1)
x1 = randn(Float32, 365, 35)  # (seq_len=365, feat=35)
q1, H1, C1 = model(x1)

println("=== 第一个时间窗口 ===")
println("q1 size: ", size(q1))
println("H1 size: ", size(H1))
println("C1 size: ", size(C1))
println("input_size: ", model.input_size)
println("lag: ", model.lag)
println("effective_input: ", model.input_size * model.lag)
println("state_size: ", model.state_size)
println("最终状态 h_t: ", model.h_t)

# 第二个时间窗口，状态继承
set_epoch!(model, 2)
x2 = randn(Float32, 365, 35)
q2, H2, C2 = model(x2)

println("\n=== 第二个时间窗口 (状态继承) ===")
println("q2 size: ", size(q2))
println("状态继承成功: ", H2[1, :] != zeros(4))

println("\nSuccess!")
