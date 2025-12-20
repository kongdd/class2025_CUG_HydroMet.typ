using Random, Statistics, LinearAlgebra, Printf, Plots
Random.seed!(1234)
gr(framestyle=:box)

# --- Core Logic ---
# Target: S_norm = 1 - (1 - Alpha_norm)^K; EX = 1/K
function fit_K(alpha, s)
  mask = (alpha .< 0.9999) .& (s .< 0.9999)
  A, B = log.(1 .- s[mask]), log.(1 .- alpha[mask])
  K = dot(A, B) / dot(B, B)
  R2 = 1 - sum((A .- K .* B) .^ 2) / sum((A .- mean(A)) .^ 2)
  return 1 / K, R2
end

# --- Data Gen ---
N, SM_max, EX_true = 10000, 100.0, 1.5
data = sort([(SM_max * (1 - (1 - r)^(1 / EX_true)), r) for r in rand(N)], by=x -> x[1])
S, Alpha = first.(data), last.(data)

# --- Simulation ---
results = []
println("FR\tTest1(EX, R2)\tTest2(EX, R2)")

for pct in 0.1:0.1:1.0
  n = Int(floor(N * pct))
  s_sub, a_sub = S[1:n], Alpha[1:n]
  FR, S_cut = a_sub[end], s_sub[end]

  # Test 1: Alpha normalized, S global normalized
  ex1, r21 = fit_K(a_sub ./ FR, s_sub ./ SM_max)

  # Test 2: Alpha normalized, S local normalized
  ex2, r22 = fit_K(a_sub ./ FR, s_sub ./ S_cut)

  push!(results, (pct, ex1, r21, ex2, r22))
  @printf("%.1f\t%.4f, %.4f\t%.4f, %.4f\n", pct, ex1, r21, ex2, r22)
end

# --- Plotting ---
extract(i) = [r[i] for r in results]
x = 0.1:0.1:1.0
p = plot(layout=(2, 1), size=(800, 600), legend=:topright)
plot!(p[1], x, extract(2), label="T1 EX", m=:circle, ylabel="EX", title="Test 1: S unscaled", c=:blue)
plot!(p[1], x, extract(3), label="T1 R2", m=:square, ls=:dash, c=:red, secondary=true)
plot!(p[2], x, extract(4), label="T2 EX", m=:circle, ylabel="EX", title="Test 2: S scaled", c=:blue)
plot!(p[2], x, extract(5), label="T2 R2", m=:square, ls=:dash, c=:red, secondary=true)
hline!(p[2], [EX_true], label="True EX", c=:green, ls=:dot)
savefig("../Figures/freewater_v2_results.png")


# --- Shape Visualization ---
p_shapes = [plot(title="T1: Unscaled Fit", xlabel="Alpha/FR", ylabel="S/SM_max", left_margin=5Plots.mm),
  plot(title="T2: Scaled Fit", xlabel="Alpha/FR", ylabel="S/S_cut", left_margin=5Plots.mm)]
colors = [:red, :green, :blue]

for (i, pct) in enumerate([0.3, 0.6, 1.0])
  n = Int(floor(N * pct))
  s, a = S[1:n], Alpha[1:n]
  FR, S_cut = a[end], s[end]
  # K_fit = 1 / results[findfirst(r->r[1]≈pct, results)][(i==1 ? 2 : 4)] # T1 uses idx 2(ex1), T2 uses idx 4(ex2)
  # Wait, simple extraction from results
  res_row = results[findfirst(r -> r[1] ≈ pct, results)]

  # Test 1
  # Real Curve
  plot!(p_shapes[1], a ./ FR, s ./ SM_max, label="Data (FR=$pct)", c=colors[i], ls=:solid, lw=1.5)
  # Fit Curve (using T1 K)
  K1 = 1 / res_row[2]
  plot!(p_shapes[1], x -> (1 - (1 - x)^K1), 0, 1, label="Fit (EX=$(round(res_row[2],digits=1)))", c=colors[i], ls=:dash, lw=1.5)

  # Test 2
  # Real Curve
  plot!(p_shapes[2], a ./ FR, s ./ S_cut, label="Data (FR=$pct)", c=colors[i], ls=:solid, lw=1.5)
  # Fit Curve (using T2 K)
  K2 = 1 / res_row[4]
  plot!(p_shapes[2], x -> (1 - (1 - x)^K2), 0, 1, label="Fit (EX=$(round(res_row[4],digits=2)))", c=colors[i], ls=:dash, lw=1.5)
end

plot(p_shapes..., layout=(1, 2), size=(1000, 500), margin=5Plots.mm)
savefig("../Figures/freewater_v2_shapes.png")
