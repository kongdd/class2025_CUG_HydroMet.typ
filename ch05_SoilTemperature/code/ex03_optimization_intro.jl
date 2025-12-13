# 参数优化入门：小球下滚找最低点
# ================================
# 用直观的物理类比理解优化算法

using Plots

# =============================================================================
# 一维优化：小球在碗底滚动
# =============================================================================
# 目标函数（损失函数）：一个抛物线，代表"碗"的形状
# 小球从某个位置开始，沿着最陡的方向滚动，最终停在碗底

# 目标函数：f(x) = (x - 3)² + 1
# 最小值在 x = 3 处，f(3) = 1
loss_1d(x) = (x - 3)^2 + 1
grad_1d(x) = 2 * (x - 3)  # 导数

# 梯度下降法
function gradient_descent_1d(x0; lr=0.1, max_iter=50)
    x = x0
    history = [x]
    
    for i in 1:max_iter
        grad = grad_1d(x)
        x = x - lr * grad  # 沿梯度反方向移动
        push!(history, x)
        
        # 收敛判断
        if abs(grad) < 1e-6
            break
        end
    end
    
    return history
end

# 从 x=8 开始优化
history_1d = gradient_descent_1d(8.0, lr=0.2)

# Visualization
x_range = range(-1, 10, length=100)
p1 = plot(x_range, loss_1d.(x_range), label="Loss L(x)", lw=2, color=:blue)
scatter!(p1, history_1d, loss_1d.(history_1d), 
    label="Trajectory", markersize=6, color=:red)
plot!(p1, history_1d, loss_1d.(history_1d), 
    label="", lw=1, ls=:dash, color=:red, alpha=0.5)
xlabel!(p1, "Parameter x")
ylabel!(p1, "Loss L(x)")
title!(p1, "1D Optimization: Ball Rolling Down")
annotate!(p1, 3, 1.5, text("Minimum", 10, :center))

# =============================================================================
# 二维优化：山地中寻找最低点
# =============================================================================
# 目标函数：二维抛物面（或更复杂的地形）
# f(x,y) = (x-2)² + (y-3)² + 1

loss_2d(x, y) = (x - 2)^2 + (y - 3)^2 + 1
grad_2d(x, y) = [2*(x-2), 2*(y-3)]

# 梯度下降法 - 二维版本
function gradient_descent_2d(x0, y0; lr=0.1, max_iter=50)
    x, y = x0, y0
    history = [(x, y)]
    
    for i in 1:max_iter
        g = grad_2d(x, y)
        x = x - lr * g[1]
        y = y - lr * g[2]
        push!(history, (x, y))
        
        if sqrt(g[1]^2 + g[2]^2) < 1e-6
            break
        end
    end
    
    return history
end

# 从 (8, 8) 开始优化
history_2d = gradient_descent_2d(8.0, 8.0, lr=0.2)

# 可视化
x_range = range(-1, 10, length=50)
y_range = range(-1, 10, length=50)
Z = [loss_2d(x, y) for y in y_range, x in x_range]

p2 = contour(x_range, y_range, Z, levels=20, 
    xlabel="x", ylabel="y", title="2D Optimization: Finding Valley")
xs = [h[1] for h in history_2d]
ys = [h[2] for h in history_2d]
plot!(p2, xs, ys, label="Opt Path", lw=2, color=:red)
scatter!(p2, xs, ys, label="", markersize=4, color=:red)
scatter!(p2, [2], [3], label="Minimum", markersize=8, color=:green, marker=:star)

# =============================================================================
# 更复杂的地形：有多个局部最小值
# =============================================================================
# Rosenbrock 函数（香蕉函数）- 优化算法的经典测试函数
rosenbrock(x, y) = (1-x)^2 + 100*(y-x^2)^2

x_range_r = range(-2, 2, length=100)
y_range_r = range(-1, 3, length=100)
Z_r = [log(1 + rosenbrock(x, y)) for y in y_range_r, x in x_range_r]

p3 = contour(x_range_r, y_range_r, Z_r, levels=30,
    xlabel="x", ylabel="y", title="Complex: Rosenbrock Function",
    c=:viridis)
scatter!(p3, [1], [1], label="Global Min", markersize=8, color=:red, marker=:star)

# =============================================================================
# 组合显示
# =============================================================================
plot(p1, p2, p3, layout=(1, 3), size=(1400, 400))
savefig("Figures/ex_optimization_intro.png")

println("Optimization demo done!")
println("Key ideas:")
println("  1. Loss function measures gap between prediction and truth")
println("  2. Gradient points to steepest ascent direction")
println("  3. Move opposite to gradient to find minimum")
println("  4. Learning rate controls step size")
println("")
println("Apply to soil model:")
println("  - Parameters x, y -> kappa, cv")
println("  - Loss -> Error between simulated and observed temperature")
println("  - Goal -> Find parameters that minimize error")
