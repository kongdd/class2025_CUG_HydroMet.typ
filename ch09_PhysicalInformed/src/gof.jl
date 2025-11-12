# 计算R²
function r_squared(pred, obs, mask)
  y_pred = Float64[]
  y_true = Float64[]
  for i in 1:length(pred)
    for j in 1:length(pred[i])
      if mask[i, j]
        push!(y_pred, pred[i][j])
        push!(y_true, obs[i][j])
      end
    end
  end

  ss_res = sum((y_true .- y_pred) .^ 2)
  ss_tot = sum((y_true .- mean(y_true)) .^ 2)
  return 1 - ss_res / ss_tot
end
