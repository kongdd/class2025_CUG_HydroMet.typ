using Random, Statistics, Plots
# default(fontfamily="Arial", label=nothing, grid=true, lw=2)
gr(framestyle=:box)

# Parameters
N, WM_mean, B, SM_mean, EX = 100000, 100.0, 0.4, 30.0, 1.2
WM_max, SM_max = WM_mean * (1 + B), SM_mean * (1 + EX)

# 重新生成的独立数据
parabolic(n, max_v, b) = max_v .* (1 .- (1 .- rand(n)) .^ b) # SM
curve(alpha, b) = 1 .- (1 .- alpha) .^ b # S/SM

function analyze(SM_i, WM_i, fr=0.3)
  idx = sortperm(WM_i)[1:Int(floor(fr * N))]
  SM_sub = sort(SM_i[idx])

  sub_max = maximum(SM_sub)
  alpha = (1:length(SM_sub)) ./ length(SM_sub)
  x_norm = SM_sub ./ sub_max

  valid = (x_norm .< 0.999) .& (alpha .< 0.999)
  xx, yy = log.(1 .- x_norm[valid]), log.(1 .- alpha[valid])

  ex_fit = sum(xx .* yy) / sum(xx .^ 2) # Param: EX
  r2 = 1 - sum((yy - ex_fit .* xx) .^ 2) / sum((yy .- mean(yy)) .^ 2)
  return x_norm, alpha, ex_fit, r2
end

u = rand(N)
WM_i = WM_max .* (1 .- (1 .- u) .^ (1 / B))

scenarios = [
  ("Independent", parabolic(N, SM_max, 1 / EX)),
  ("Positive Corr", SM_max .* (1 .- (1 .- u) .^ (1 / EX))),
  ("Negative Corr", SM_max .* (1 .- (1 .- (1 .- u)) .^ (1 / EX)))
]

println("Simulation Results:")
println("-"^50)
p = plot(layout=(1, 3), size=(1200, 400), margin=5Plots.mm)

for (i, (name, SM_vals)) in enumerate(scenarios)
  x, alpha, ex_new, r2 = analyze(SM_vals, WM_i)

  # Terminal Output
  println("Scenario: $name")
  println("  -> R2: $(round(r2, digits=4)) | Fitted EX: $(round(ex_new, digits=3))")

  # Plotting (English Labels)
  scatter!(p[i], x[1:100:end], alpha[1:100:end], ms=2, alpha=0.5, c=:blue, label="Simulated")
  plot!(p[i], a -> curve(a, 1 / ex_new), 0, 1, c=:red, ls=:dash, label="Fitted EX=$(round(ex_new, digits=2))")

  title!(p[i], "$name\nR²=$(round(r2, digits=4))")
  xlabel!(p[i], "Norm. Capacity")
  if i == 1
    ylabel!(p[i], "Area Fraction α")
  end
end

savefig("ch07_HydrologyForecast/Figures/freewater_dist_check.png")
println("-"^50)
println("Plot saved to Figures/freewater_dist_check.png")
