# 太阳辐射：白天6-18点的正弦曲线
cal_Rs(t) = begin
  d = mod(t, 86400)
  21600 < d < 64800 ? 800 * sin(π * (d - 21600) / 43200) : 0.0
end

# 气温：日变化正弦曲线，平均20°C，振幅10°C
cal_Tair(t) = 20.0 + 10.0 * sin(2π * (t - 32400) / 86400)

# 黑体辐射
blackbody(T, ε) = ε * σ * (T + 273.15)^4

# 净辐射
cal_Rn(Rs, Rln, Ts, α, ε) = (1 - α) * Rs + ε * Rln - blackbody(Ts, ε)

# 感热通量
cal_H(Ts, Ta, ra) = ρa * cp / ra * (Ts - Ta)

# 土壤热通量
cal_G(Ts, T1, κ, Δz) = κ / (Δz / 2) * (Ts - T1)


# 牛顿迭代法求解地表温度
function solve_ts(T1, t, p, Δz; nmax=6)
  (; α, ε, ra, κ, Rln) = p
  Rs = cal_Rs(t)
  Ta = cal_Tair(t)
  Ts = T1  # 初始猜测

  for _ in 1:nmax
    Rn = cal_Rn(Rs, Rln, Ts, α, ε)
    H = cal_H(Ts, Ta, ra)
    G = cal_G(Ts, T1, κ, Δz)
    f = Rn - H - G

    TsK = Ts + 273.15
    J = -4 * ε * σ * TsK^3 - ρa * cp / ra - κ / (Δz / 2)

    dTs = f / J
    Ts -= dTs
    abs(dTs) < 1e-4 && break
  end
  return Ts
end


# 土壤热传导方程
function heat_eq!(du, u, p, t)
  (; N, κ, Cv, Δz) = p
  Ts = solve_ts(u[1], t, p, Δz)

  # 第一层：地表边界条件
  G0 = 2κ / Δz * (Ts - u[1])
  du[1] = (G0 - κ * (u[1] - u[2]) / Δz) / (Δz * Cv)

  # 中间层：热传导
  c = κ / (Cv * Δz^2)
  @inbounds for i in 2:N-1
    du[i] = c * (u[i-1] - 2u[i] + u[i+1])
  end

  # 底层：绝热边界
  du[N] = c * (u[N-1] - u[N])
end
