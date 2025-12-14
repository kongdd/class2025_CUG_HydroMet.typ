using OrdinaryDiffEq, Plots, LinearAlgebra
gr(framestyle=:box, fmt=:png, dpi=300)

const σ = 5.67e-8
const ρa = 1.225
const cp = 1005.0

# --- 1. Parameters ---
param = (
  κ=1.5, Cv=2.0e6, N=50, L=1.0,
  α=0.25, ε=0.95, ra=50.0, Rln=300.0,
)
Δz = param.L / param.N

# --- 2. Forcing & Flux Functions ---
cal_Rs(t) = (d = mod(t, 86400); 21600 < d < 64800 ? 800sin(π * (d - 21600) / 43200) : 0.0)
cal_Tair(t) = 20.0 + 10.0sin(2π * (t - 32400) / 86400)

f_Rn(Ts, Rs; α, ε, Rln) = (1 - α) * Rs + ε * Rln - ε * σ * (Ts + 273.15)^4
f_H(Ts, Ta; ra) = ρa * cp / ra * (Ts - Ta)
# 注意：这里 Δz/2 是从表面到第一层节点的距离
f_G(Ts, T1; κ) = κ * (Ts - T1) / (Δz / 2)

# --- 3. DAE Definition (Mass Matrix Form) ---
# M * du/dt = f(u, p, t)
# Row 1: 0 * dTs/dt = Balance (Algebraic Constraint)
# Row 2+: 1 * dT/dt = Diffusion (Differential Equation)

function heat_eq_dae!(du, u, p, t)
  (; κ, Cv, N) = p

  # Unpack state: u[1] is Ts, u[2] is Soil_1
  Ts, T1 = u[1], u[2]
  Rs, Ta = cal_Rs(t), cal_Tair(t)

  # --- Equation 1: Surface Energy Balance (Algebraic) ---
  # Since Mass_Matrix[1,1] is 0, this says: 0 = Rn - H - G
  Rn = f_Rn(Ts, Rs; p.α, p.ε, p.Rln)
  H = f_H(Ts, Ta; p.ra)
  G = f_G(Ts, T1; p.κ)
  du[1] = Rn - H - G  # Residual, not derivative!

  # --- Equation 2..N+1: Soil Heat Diffusion ---
  # First soil layer (receives flux G from surface)
  G_bottom_1 = κ * (u[2] - u[3]) / Δz
  du[2] = (G - G_bottom_1) / (Δz * Cv)

  c = κ / (Cv * Δz^2)
  @inbounds for i in 3:N # Middle layers
    du[i] = c * (u[i-1] - 2u[i] + u[i+1])
  end
  du[N+1] = c * (u[N] - u[N+1]) # Bottom layer (Adiabatic)
end

# --- 4. Mass Matrix Setup ---
# 1st element is 0 (Algebraic), others are 1 (Differential)
M = Diagonal([0.0; ones(param.N)])

# --- 5. Execution ---
# Initial Guess needs to be consistent! 
# We just guess Ts=20, solver will adjust it to satisfy algebraic constraint at t=0
u0 = fill(20.0, param.N + 1)
tspan = (0.0, 172800.0)

# Define ODEFunction with Mass Matrix
func = ODEFunction(heat_eq_dae!, mass_matrix=M)
prob = ODEProblem(func, u0, tspan, param)

# Must use a DAE-compatible solver (Rodas5 is excellent for this)
sol = solve(prob, Rodas5(), saveat=1800, reltol=1e-6)

# --- 6. Plotting ---
tm = sol.t ./ 3600
# Now Ts is simply u[1], no need to re-calculate!
Ts_res = [u[1] for u in sol.u]
T1_res = [u[2] for u in sol.u]

p = plot(tm, cal_Tair.(sol.t), label="T_air", ls=:dash, c=:blue)
plot!(p, tm, Ts_res, label="Ts (DAE/Diagnostic)", c=:red, lw=2)
plot!(p, tm, T1_res, label="T_soil_1", c=:green, ls=:dot)
title!(p, "Diagnostic Ts via DAE Mass Matrix")
xlabel!(p, "Time (h)")
ylabel!(p, "Temperature (°C)")

savefig("Figures/dae_soil_result.png")
