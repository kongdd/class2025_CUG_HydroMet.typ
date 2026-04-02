using Random, Statistics, Printf, Plots

# Include the newly defined physics formulas
include("xaj_formulas.jl")

Random.seed!(2025)
mkpath("images")
gr(size=(1000, 500), margin=5Plots.mm, framestyle=:box)

# --- Config & Data ---
N, SM_max, EX = 10000, 100.0, 1.5
# SM_max is the Point Maximum Capacity
# S_max is the Basin Mean Storage Capacity = SM_max / (1 + EX)
S_max_global = SM_max / (1 + EX)

# True local capacities (Generated following parabolic distribution)
# We sort them to simulate that "wet" areas (small capacity?) or specific areas fill up first.
# Note: For free water, usually areas with small tension capacity generate runoff first.
# Here we just assume heterogeneity exists and we pick a subset.
caps = sort(SM_max .* (1 .- (1 .- rand(N)) .^ (1 / EX)))

# --- Simulation ---
res, P_step, T = [], 2.0, 100
trace = Dict()

println("FR\tTrue_mean_cap\tModel_mean_cap\tErr(%)\tErr_R(mm)")
for FR in [0.1, 0.2, 0.4, 0.6, 0.8, 1.0]
  # 1. Reality: The Active Area FR has a specific subset of capacities
  n = Int(floor(N * FR))
  sub_caps = caps[1:n]
  real_mean_cap = mean(sub_caps)

  # 2. Model Assumption: The Active Area FR has the GLOBAL distribution parameters
  # S_max_global = 40.0 (if SM_max=100, EX=1.5)

  S_true, S_mod, R_true, R_mod = 0.0, 0.0, 0.0, 0.0
  states = zeros(n) # Water storage in each cell of the active area
  tr_R_t, tr_R_m = Float64[], Float64[]

  for _ in 1:T
    # A. True Physics (Distributed Simulation)
    step_R = 0.0
    for i in 1:n
      # P_step is Local Depth on the active area
      # Capacity constraint: sub_caps[i]
      capacity = sub_caps[i]

      # Fill and Spill
      potential = states[i] + P_step
      excess = max(0.0, potential - capacity)
      states[i] = potential - excess
      step_R += excess
    end
    R_true += step_R / n # Average runoff depth on the active area

    # B. Model Calculation (Lumped Formula)
    # The model uses the GLOBAL SM_max and EX to simulate the LOCAL process
    # Inputs: P_step (Local depth), S_mod (Local depth)
    # Parameters: SM_max (Global), EX (Global)
    r_local, S_next = xaj_step_v2(P_step, S_mod, SM_max, EX)
    R_mod += r_local
    S_mod = S_next

    if FR == 0.2
      push!(tr_R_t, R_true)
      push!(tr_R_m, R_mod)
    end
  end

  if FR == 0.2
    trace[:t], trace[:m] = tr_R_t, tr_R_m
  end

  err_cap = (S_max_global - real_mean_cap) / real_mean_cap * 100
  err_R = R_mod - R_true
  push!(res, (FR, err_cap))
  @printf("%.1f\t%.1f\t%.1f\t%.0f%%\t%.1f\n", FR, real_mean_cap, S_max_global, err_cap, err_R)
end

# --- Plotting ---
p1 = plot([r[1] for r in res], [r[2] for r in res], m=:circle, c=:red, label="Cap Err %",
  xlabel="Runoff Area Fraction (FR)", ylabel="Capacity Error (%)", title="Structural Error (Capacity)")
hline!(p1, [0], c=:black, ls=:dot, label="")

p2 = plot(trace[:m], label="Model (Lumped)", c=:red, ls=:dash,
  xlabel="Time Step", ylabel="Runoff Depth (mm)", title="Runoff Generation (FR=0.2)")
plot!(p2, trace[:t], label="True (Distributed)", c=:blue, ls=:solid)

savefig(plot(p1, p2, layout=(1, 2)), "images/Figure_Error_Quantification.png")
