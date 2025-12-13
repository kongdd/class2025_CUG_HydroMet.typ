using OrdinaryDiffEq, Plots
gr(framestyle=:box, fmt=:png)

# --- 1. Parameters & Constants (Unified) ---
param = (
    κ = 1.5, Cv = 2.0e6, N = 50, L = 1.0,  # Soil props
    α = 0.25, ε = 0.95, ra = 50.0, Rln = 300.0, # Surface props
    σ = 5.67e-8, ρCp = 1206.0,             # Constants
)
Δz = param.L / param.N

# --- 2. Forcing Functions (Concise) ---
Rs(t)   = (d = mod(t, 86400); 21600 < d < 64800 ? 800sin(π*(d-21600)/43200) : 0.0)
Tair(t) = 20.0 + 10.0sin(2π*(t-32400)/86400)

function cal_Rn(; α, ε, Rln, σ, Tair, Ts)
    return (1-α)*Rs + ε*σ*(Ts+273.15)^4 - ε*σ*(Tair+273.15)^4
end

# --- 3. Core Logic: Surface Temperature Solver ---
function solve_ts(T1, t, p)
    S, Ta = Rs(t), Tair(t)
    Ts = T1 # Initial guess
    
    # Pre-calc constants for readability
    K_dz, H_coef = 2p.κ/Δz, p.ρCp/p.ra
    
    for _ in 1:6
        TsK = Ts + 273.15
        Rn = (1-p.α)*S + p.ε*p.Rln - p.ε*p.σ*TsK^4
        H  = H_coef * (Ts - Ta)
        G  = K_dz * (Ts - T1)
        
        f = Rn - H - G
        J = -4*p.ε*p.σ*TsK^3 - H_coef - K_dz
        
        dTs = f / J
        Ts -= dTs
        abs(dTs) < 1e-4 && break
    end
    return Ts
end

# --- 4. ODE Definition ---
function heat_eq!(du, u, p, t)
    Ts = solve_ts(u[1], t, p)
    
    # Layer 1 (Surface BC)
    G0 = 2p.κ/Δz * (Ts - u[1])
    du[1] = (G0 - p.κ*(u[1]-u[2])/Δz) / (Δz*p.Cv)
    
    # Layers 2..N-1 (Diffusion)
    c = p.κ / (p.Cv * Δz^2)
    @inbounds for i in 2:p.N-1
        du[i] = c * (u[i-1] - 2u[i] + u[i+1])
    end
    
    # Layer N (Adiabatic Bottom)
    du[p.N] = c * (u[p.N-1] - u[p.N])
end

# --- 5. Execution & Plotting ---
u0 = fill(20.0, param.N)
sol = solve(ODEProblem(heat_eq!, u0, (0.0, 172800.0), param), Tsit5(), saveat=1800)

# Post-processing map
ts_surf = [solve_ts(u[1], t, param) for (u,t) in zip(sol.u, sol.t)]
tm = sol.t ./ 3600

plot(tm, ts_surf, label="T_s", lw=2, c=:red, title="Minimalist Soil Heat")
plot!(tm, Tair.(sol.t), label="T_air", ls=:dash, c=:blue)
plot!(tm, [u[1] for u in sol.u], label="T_soil_1", ls=:dot, c=:green, lw=1.5)
xlabel!("Time (h)"); ylabel!("Temp (°C)")
savefig("Figures/solve_Tsoil_result.png")
