using OrdinaryDiffEq
using Plots
gr(framestyle=:box)


# 模拟太阳短波辐射 Rs (W/m^2): 只有白天有，正午最大
function calc_Rs(t)
  day_time = mod(t, 86400)
  if 21600 < day_time < 64800  # 6:00-18:00
    return 800.0 * sin(π * (day_time - 21600) / 43200)
  else
    return 0.0
  end
end

# 自由大气温度 (作为边界条件驱动)
function get_T_free(t)
  # 自由大气温度日变化较小，滞后于太阳辐射
  return 18.0 + 5.0 * sin(2π * (t - 36000) / 86400)
end

# 灰体辐射 (Stefan-Boltzmann定律)
function blackbody(T_c; ε=1.0)
  σ = 5.67e-8  # W/m²/K⁴
  T_K = T_c + 273.15
  return ε * σ * T_K^4
end


# --- ODE 系统定义 ---
# 状态变量: u[1:N] = 土壤各层温度, u[N+1] = 边界层空气温度
function soil_air_coupled!(du, u, p, t)
  λ, Cv, Δz, N, α, ra, Rln_in, ε, h_bl, τ_mix = p

  ρ_air = 1.2       # kg/m³
  Cp_air = 1005.0   # J/kg/K

  Rs = calc_Rs(t)
  # T_free = get_T_free(t)  # 自由大气温度 (边界条件)
  T_free = 23.0

  T_surf = u[1]       # 地表温度
  T_air = u[N+1]      # 边界层空气温度

  # === 地表能量平衡 ===
  Rln_out = blackbody(T_surf; ε)
  Rn = (1 - α) * Rs + ε * Rln_in - Rln_out

  # 感热通量: 地表 → 空气
  H = ρ_air * Cp_air / ra * (T_surf - T_air)

  # 土壤热通量: 地表 → 深层
  G = λ * (T_surf - u[2]) / Δz

  # 地表温度变化
  du[1] = (Rn - H - G) / (Δz * Cv)

  # === 土壤内部热传导 ===
  κ = λ / Cv
  for i in 2:N-1
    du[i] = (κ / Δz^2) * (u[i+1] - 2 * u[i] + u[i-1])
  end

  # 底部绝热边界
  du[N] = (κ / Δz^2) * (u[N-1] - u[N])

  # === 边界层空气温度 ===
  # dT_air/dt = H / (ρ*Cp*h_bl) - (T_air - T_free) / τ_mix
  # 第一项: 来自地表的感热加热
  # 第二项: 边界层与自由大气的混合 (湍流交换)
  Cv_air = ρ_air * Cp_air * h_bl  # 边界层空气热容量 (J/m²/K)
  du[N+1] = H / Cv_air - (T_air - T_free) / τ_mix
end

# --- 参数设置 ---
# 土壤物理性质
λ_soil = 1.5       # W/m/K
Cv_soil = 2.0e6    # J/m³/K

# 能量平衡参数
α_surf = 0.25      # 反照率
ra_surf = 50.0     # s/m (空气动力学阻抗)
Rln_in = 300.0     # W/m² (入射长波辐射)
ε_surf = 0.95      # 地表发射率

# 边界层参数
h_bl = 100.0       # m (边界层厚度)
τ_mix = 3600.0     # s (边界层与自由大气混合时间尺度, 约1小时)

# 网格设置
L = 1.0
N = 50
Δz = L / N

# 初始条件: 土壤20℃ + 空气温度20℃
u0 = vcat(fill(20.0, N), [20.0])
tspan = (0.0, 86400.0 * 4)
p = (λ_soil, Cv_soil, Δz, N, α_surf, ra_surf, Rln_in, ε_surf, h_bl, τ_mix)

# 求解
prob = ODEProblem(soil_air_coupled!, u0, tspan, p)
sol = solve(prob, Tsit5(), saveat=1800)

# --- 可视化 ---
times = sol.t ./ 3600
T_surf_evolution = sol[1, :]      # 地表温度
T_air_evolution = sol[N+1, :]     # 边界层空气温度
T_free_evolution = [get_T_free(t) for t in sol.t]  # 自由大气温度

plot(times, T_surf_evolution, label="Soil Surface", lw=2, 
     xlabel="Time (Hour)", ylabel="Temperature (°C)")
plot!(times, T_air_evolution, label="Boundary Layer Air", lw=2)
plot!(times, T_free_evolution, label="Free Atmosphere", ls=:dash, lw=1.5, color=:gray)
title!("Coupled Soil-Atmosphere Temperature Evolution")
savefig("Figures/solve_Tair_(T_free=23).png")
