# 模拟参数
const σ = 5.67e-8
const ε = 0.95
const α = 0.2
const ρ_air = 1.2
const Cp_air = 1005.0
const ra = 50.0 # s/m
const κ = 0.5   # W/m/K
const Δz = 0.1  # m
const heat_coeff = ρ_air * Cp_air / ra

# 测试输入
Rs = 600.0      # W/m2
Rln_in = 350.0  # W/m2
T_air = 25.0    # Celsius
T_soil_1 = 20.0 # Celsius, 第一层土壤温度

# 目标方程: Rn - H - G = 0
# Rn = (1-α)*Rs + ε*Rln_in - ε*σ*(Ts+273.15)^4
# H = heat_coeff * (Ts - T_air)
# G = κ * (Ts - T_soil_1) / (Δz / 2)  <-- 注意这里通常用半层厚度，或者如果T1是节点温度，Δz是节点间距

function energy_balance_residual(Ts)
    Ts_K = Ts + 273.15
    Rln_out = ε * σ * Ts_K^4
    Rn = (1 - α) * Rs + ε * Rln_in - Rln_out
    H = heat_coeff * (Ts - T_air)
    # G calculation: assuming T_soil_1 is at depth Δz implicitly or explicitly defined.
    # In the original code: G = κ * (u[1] - u[2]) / Δz. 
    # For surface: Flux from surface to node 1.
    # Let's assume T_soil_1 is the temperature of the first layer node.
    # Distance from surface (z=0) to first node (z=Δz/2 or similar).
    # Let's stick to the user's previous simple formulation G = k * (Ts - T1) / Dz for consistency if that was the intent,
    # but strictly it should be distance. Let's use dz as in the original code for now, but clarify physical meaning.
    G = κ * (Ts - T_soil_1) / Δz 
    return Rn - H - G
end

# Simple Newton-Raphson solver
function solve_Ts(T_guess)
    T = T_guess
    for i in 1:10
        f = energy_balance_residual(T)
        # Derivative approx
        df = (energy_balance_residual(T + 0.001) - f) / 0.001
        
        T_new = T - f / df
        if abs(T_new - T) < 1e-4
            return T_new
        end
        T = T_new
    end
    return T
end

ts_sol = solve_Ts(T_air)
println("Solved Ts: ", ts_sol)
println("Residual: ", energy_balance_residual(ts_sol))

# 验证 check: Fluxes
Ts_K = ts_sol + 273.15
Rn = (1 - α) * Rs + ε * Rln_in - ε * σ * Ts_K^4
H = heat_coeff * (ts_sol - T_air)
G = κ * (ts_sol - T_soil_1) / Δz
println("Rn: ", Rn)
println("H: ", H)
println("G: ", G)
println("Sum: ", Rn - H - G)
