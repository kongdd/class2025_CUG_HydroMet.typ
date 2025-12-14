using OrdinaryDiffEq, Plots
gr(framestyle=:box, fmt=:png)

const σ = 5.67e-8 # Stefan-Boltzmann constant (W m⁻² K⁻⁴)
const ρa = 1.225  # Air density (kg m⁻³)
const cp = 1005.0 # Specific heat of air at constant pressure (J kg⁻¹ K⁻¹)

# --- 1. Parameters & Constants (Unified) ---
# Cv = rho_soil * cp_soil
param = (
  κ=1.5, Cv=2.0e6, N_soil=50, L=1.0,  # Soil properties
  d_skin=0.005,                       # 5mm Thin Layer (Litter/Crust)
  α=0.25, ε=0.95, ra=50.0, Rln=300.0  # Surface properties
)
# Derived geometric constants
Δz = param.L / param.N_soil        # Thickness of deep soil layers
C_skin = param.Cv * param.d_skin   # Heat capacity of skin layer (J m⁻² K⁻¹)
Δz_eff = param.d_skin / 2 + Δz / 2     # Dist. from skin center to 1st soil node

# --- 2. Flux Functions (Pure Physics) ---
cal_Rs(t) = (d = mod(t, 86400); 21600 < d < 64800 ? 800sin(π * (d - 21600) / 43200) : 0.0)
cal_Tair(t) = 20.0 + 10.0sin(2π * (t - 32400) / 86400)

# Fluxes (W m⁻²)
f_Rn(Ts, Rs; α, ε, Rln) = (1 - α) * Rs + ε * Rln - ε * σ * (Ts + 273.15)^4
f_H(Ts, Ta; ra) = ρa * cp / ra * (Ts - Ta)
f_G(Ts, T1; κ) = κ * (Ts - T1) / Δz_eff

# --- 3. ODE System (Prognostic / Thin Layer) ---
# u[1] = Ts (Skin), u[2:end] = Soil layers
function heat_eq_thin!(du, u, p, t)
  (; κ, Cv, N_soil) = p

  # A. Current State & Forcing
  Ts, T1 = u[1], u[2]
  Rs, Ta = cal_Rs(t), cal_Tair(t)

  # B. Surface Energy Balance (Prognostic)
  # C_skin * dTs/dt = Rn - H - G
  Rn = f_Rn(Ts, Rs; p.α, p.ε, p.Rln)
  H = f_H(Ts, Ta; p.ra)
  G = f_G(Ts, T1; p.κ)

  du[1] = (Rn - H - G) / C_skin

  # C. Soil Diffusion
  # Layer 1 (Interact with Skin)
  G_bottom_1 = κ * (u[2] - u[3]) / Δz
  du[2] = (G - G_bottom_1) / (Δz * Cv)

  # Middle Layers (Diffusion)
  c_diff = κ / (Cv * Δz^2)
  @inbounds for i in 3:N_soil
    du[i] = c_diff * (u[i-1] - 2u[i] + u[i+1])
  end

  # Bottom Layer (Adiabatic)
  du[N_soil+1] = c_diff * (u[N_soil] - u[N_soil+1])
end

# --- 4. Execution (Stiff Solver) ---
# Initial condition: u[1] is Ts, u[2:N+1] is Soil
u0 = fill(20.0, param.N_soil + 1)
tspan = (0.0, 172800.0)

# Key Change: Use Rodas5() for Stiff ODEs (Skin layer reacts fast, soil slow)
prob = ODEProblem(heat_eq_thin!, u0, tspan, param)
sol = solve(prob, Rodas5(), saveat=1800, reltol=1e-6, abstol=1e-6)

# --- 5. Visualization ---
tm = sol.t ./ 3600
Ts_res = [u[1] for u in sol.u] # No reconstruction needed, it's state var!
T1_res = [u[2] for u in sol.u]

p1 = plot(tm, cal_Tair.(sol.t), label="T_air", ls=:dash, c=:blue, lw=1.5)
plot!(p1, tm, Ts_res, label="Ts (Thin Layer)", c=:red, lw=2)
plot!(p1, tm, T1_res, label="T_soil_5cm", c=:green, ls=:dot, lw=2)
plot!(p1, xlabel="Time (h)", ylabel="Temperature (°C)",
  title="Prognostic Surface Temperature (Rodas5 Solver)", legend=:topright)

savefig("Figures/solve_Tsoil_result_ThinLayer.png")
