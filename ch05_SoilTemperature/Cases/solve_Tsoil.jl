using OrdinaryDiffEq, Plots
gr(framestyle=:box, fmt=:png)

const σ = 5.67e-8 # Stefan-Boltzmann constant (W m⁻² K⁻⁴)
const ρa = 1.225  # Air density (kg m⁻³)
const cp = 1005.0 # Specific heat of air at constant pressure (J kg⁻¹ K⁻¹)

# --- 1. Parameters & Constants (Unified) ---
param = (
  κ=1.5, Cv=2.0e6, N=50, L=1.0,  # Soil props
  α=0.25, ε=0.95, ra=50.0, Rln=300.0, # Surface props
)
Δz = param.L / param.N

# --- 2. Forcing Functions (Concise) ---
cal_Rs(t) = (d = mod(t, 86400); 21600 < d < 64800 ? 800sin(π * (d - 21600) / 43200) : 0.0)
cal_Tair(t) = 20.0 + 10.0sin(2π * (t - 32400) / 86400)

blackbody(T::FT, ε::FT) where {FT<:Real} = ε * σ * (T + 273.15)^4

cal_Rn(Rs, Rln, Ts; α, ε) = (1 - α) * Rs + ε * Rln - blackbody(Ts, ε)

cal_H(Ts, Ta; ra) = ρa * cp / ra * (Ts - Ta)

cal_G(Ts, T1; κ, Δz) = κ / (Δz/2) * (Ts - T1)

# --- 3. Core Logic: Surface Temperature Solver ---
function solve_ts(T1, t, p; nmax=6)
  (; α, ε, ra, κ, Rln) = p
  Rs, Ta = cal_Rs(t), cal_Tair(t)
  Ts = T1 # Initial guess

  for _ in 1:nmax
    Rn = cal_Rn(Rs, Rln, Ts; α, ε)
    H = cal_H(Ts, Ta; ra)
    G = cal_G(Ts, T1; κ, Δz)
    f = Rn - H - G

    TsK = Ts + 273.15
    J = -4 * ε * σ * TsK^3 - ρa * cp / ra - κ / (Δz / 2)

    dTs = f / J
    Ts -= dTs
    abs(dTs) < 1e-4 && break
  end
  return Ts
end

# --- 4. ODE Definition ---
function heat_eq!(du, u, p, t)
  (; N, κ, Cv) = p
  Ts = solve_ts(u[1], t, p)

  G0 = 2κ / Δz * (Ts - u[1])
  du[1] = (G0 - κ * (u[1] - u[2]) / Δz) / (Δz * Cv) # Layer 1 (Surface BC)

  c = κ / (Cv * Δz^2)
  @inbounds for i in 2:N-1    # Layers 2..N-1 (Diffusion)
    du[i] = c * (u[i-1] - 2u[i] + u[i+1])
  end
  du[N] = c * (u[N-1] - u[N]) # Layer N (Adiabatic Bottom)
end

# --- 5. Execution & Plotting ---
u0 = fill(20.0, param.N)
sol = solve(ODEProblem(heat_eq!, u0, (0.0, 172800.0), param), Tsit5(), saveat=1800)

# Post-processing map
ts_surf = [solve_ts(u[1], t, param) for (u, t) in zip(sol.u, sol.t)]
tm = sol.t ./ 3600

plot(tm, Tair.(sol.t), label="T_air", ls=:dash, c=:blue)
plot!(tm, ts_surf, label="Ts", lw=2, c=:red, title="Minimalist Soil Heat")
plot!(tm, [u[1] for u in sol.u], label="Tsoil_1", ls=:dot, c=:green, lw=1.5)
xlabel!("Time (h)");
ylabel!("Temp (°C)");
savefig("Figures/solve_Tsoil_result.png")
