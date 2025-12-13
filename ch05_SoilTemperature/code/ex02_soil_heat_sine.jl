# 土壤热通量求解案例
# ====================
# 上边界：土壤热通量以正弦波动（模拟日变化）
# 下边界：温度保持恒定（深层土壤温度稳定）

# 使用轻量级 ODE 求解器（比 DifferentialEquations 快很多）
using OrdinaryDiffEq
using Plots

# =============================================================================
# 土壤参数设置
# =============================================================================
struct SoilParams
    N::Int           # 土壤层数
    z::Vector{Float64}       # 每层中心深度 (m), 向下为负
    Δz::Vector{Float64}      # 每层厚度 (m)
    κ::Float64       # 热传导系数 (W m⁻¹ K⁻¹)
    cv::Float64      # 体积热容量 (J m⁻³ K⁻¹)
    T_bottom::Float64  # 底层温度 (°C)
end

# 创建均匀分层的土壤
function create_soil(; N=10, depth=1.0, κ=1.5, cv=2.0e6, T_bottom=18.0)
    Δz = depth / N
    z = collect(range(-Δz/2, -depth + Δz/2, length=N))
    SoilParams(N, z, fill(Δz, N), κ, cv, T_bottom)
end

# =============================================================================
# 上边界条件：正弦变化的地表热通量
# =============================================================================
# 模拟日变化：白天热量向下传递（G>0），夜间热量向上散失（G<0）
function surface_heat_flux(t; G_amp=50.0, period=24*3600)
    # G_amp: 热通量振幅 (W/m²)
    # period: 周期 (秒), 默认24小时
    G_amp * sin(2π * t / period)
end

# =============================================================================
# 热传导方程
# =============================================================================
# c_v ∂T/∂t = -∂F/∂z = κ ∂²T/∂z²

function soil_heat_equation!(dT, T, p::SoilParams, t)
    (; N, z, Δz, κ, cv, T_bottom) = p
    
    # 上边界：已知热通量 F₀
    F0 = surface_heat_flux(t)
    
    # 第一层
    # c_v * Δz * dT/dt = -(F₀ - F₁)
    # F₁ = -κ * (T₁ - T₂) / Δz
    F1 = -κ * (T[1] - T[2]) / Δz[1]
    dT[1] = -(F0 - F1) / (Δz[1] * cv)
    
    # 中间层
    for i in 2:N-1
        F_up = -κ * (T[i-1] - T[i]) / Δz[i]
        F_down = -κ * (T[i] - T[i+1]) / Δz[i]
        dT[i] = -(F_up - F_down) / (Δz[i] * cv)
    end
    
    # 底层：固定温度边界条件
    # 可以理解为：底层温度被"锁定"，不随时间变化
    F_up = -κ * (T[N-1] - T[N]) / Δz[N]
    F_down = -κ * (T[N] - T_bottom) / Δz[N]  # 热量流向更深处
    dT[N] = -(F_up - F_down) / (Δz[N] * cv)
end

# =============================================================================
# 求解
# =============================================================================
# 创建土壤（10层，总深度1m）
soil = create_soil(N=10, depth=1.0, κ=1.5, cv=2.0e6, T_bottom=18.0)

# 初始温度：线性分布，从表层20°C到底层18°C
T0 = collect(range(20.0, 18.0, length=soil.N))

# 模拟3天
tspan = (0.0, 3 * 24 * 3600.0)  # 3天，单位：秒

# 求解ODE
prob = ODEProblem(soil_heat_equation!, T0, tspan, soil)
sol = solve(prob, saveat=3600.0)  # 每小时保存一次

# =============================================================================
# 可视化
# =============================================================================
# 提取结果
times = sol.t ./ 3600  # 转换为小时
T_matrix = hcat(sol.u...)'  # 时间 × 层数

# Plot 1: Temperature time series at different depths
p1 = plot(title="Soil Temperature at Different Depths", xlabel="Time (hour)", ylabel="Temperature (C)")
depths_to_plot = [1, 3, 5, 7, 10]  # Select typical depths
for i in depths_to_plot
    depth_cm = round(-soil.z[i] * 100, digits=1)
    plot!(p1, times, T_matrix[:, i], label="$(depth_cm) cm", lw=2)
end

# Plot 2: Temperature profiles at different times
p2 = plot(title="Temperature Profile", xlabel="Temperature (C)", ylabel="Depth (m)")
hours_to_plot = [6, 12, 18, 24, 36, 48]  # Select time points
for h in hours_to_plot
    idx = findfirst(times .>= h)
    if !isnothing(idx)
        plot!(p2, T_matrix[idx, :], soil.z, label="$(h)h", lw=2, marker=:circle)
    end
end

# Plot 3: Heatmap
p3 = heatmap(times, soil.z, T_matrix',
    xlabel="Time (hour)", ylabel="Depth (m)",
    title="Soil Temperature Distribution", colorbar_title="Temp (C)",
    c=:thermal)

# 组合图
plot(p1, p2, layout=(1, 2), size=(1000, 400))
savefig("Figures/ex_soil_heat_sine_timeseries.png")

plot(p3, size=(800, 400))
savefig("Figures/ex_soil_heat_sine_heatmap.png")

println("Soil heat simulation done!")
println("Observations:")
println("  1. Surface temp fluctuates strongly, deep layer stays stable")
println("  2. Temperature wave has phase delay (deep layer lags behind surface)")
println("  3. Amplitude decays exponentially with depth")
