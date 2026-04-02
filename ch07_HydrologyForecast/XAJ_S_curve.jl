
# 调试与验证脚本: XAJ_S_curve.jl
# 目的: 验证自由水蓄水量 S 与水位 AU 的关系，并解析物理极值

function newton_solver(f, x0, grad, y_target=0.0;
  atol=1e-8, rtol=1e-8, maxiter=50) # 增加迭代次数
  x = float(x0)
  iter = 0
  fx = 0.0

  while iter < maxiter
    iter += 1
    fx = f(x) - y_target

    if abs(fx) <= atol
      return x
    end

    dfx = grad(x)

    # 导数过小保护
    if abs(dfx) < 1e-12
      if abs(fx) < 1e-5
        # 已经很接近且导数为0（极值点），认为收敛
        return x
      end
      println("Warning: Zero derivative at x=$x, fx=$fx")
      return x
    end

    Δx = fx / dfx

    # 步长限制 (Damping)
    Δx = clamp(Δx, -10.0, 10.0)

    x -= Δx

    isfinite(x) || (println("Non-finite value at iter $iter"); return x)

    if abs(Δx) <= atol + rtol * abs(x)
      return x
    end
  end
  println("Newton failed to converge after $iter iterations")
  return x
end

# 核心公式: 计算自由水蓄水量 S
# 物理含义: 在产流面积 FR 上，自由水水位为 AU 时的蓄水量 (Wedge Storage)
# S = AU * FR - Integral(Alpha)
# 等价于: S_max * [1 - (1 - AU/SM)^EX+1] - AU * (1 - FR)
function separate_S_state(AU; SM_max, EX, FR)
  S_max = SM_max / (1 + EX)
  term_base = max(0.0, 1.0 - AU / SM_max)
  S_full_term = S_max * (1.0 - term_base^(EX + 1))
  return S_full_term - AU * (1.0 - FR)
end

# 导数: dS/dAU
# dS/dAU = (1 - AU/SM)^EX - (1 - FR)
function gradient_S_state(AU; SM_max, EX, FR)
  if AU >= SM_max
    return -(1.0 - FR)
  end
  term_base = max(0.0, 1.0 - AU / SM_max)
  term_exp = term_base^EX
  return term_exp - (1.0 - FR)
end

function inverse_AU(S_target; SM_max, EX, FR)
  println("\nSolving for S_target = $S_target ...")

  # 1. 确定物理可行域边界 (AU_crit)
  # 条件: Alpha(AU) = FR
  if FR >= 1.0 - 1e-6
    AU_crit = SM_max
  else
    AU_crit = SM_max * (1.0 - (1.0 - FR)^(1.0 / EX))
  end
  println("  Physical Limit AU_crit: $(round(AU_crit, digits=4)) mm")

  # 2. 计算物理最大容量
  S_capacity = separate_S_state(AU_crit; SM_max, EX, FR)
  println("  Physical Capacity S_cap: $(round(S_capacity, digits=4)) mm")

  if S_target > S_capacity + 1e-4
    println("  [Alert] Target S ($S_target) exceeds Capacity ($S_capacity)!")
    println("  Returning AU_crit (Saturating the partial area).")
    return AU_crit
  end

  # 3. 求解
  f(AU) = separate_S_state(AU; SM_max, EX, FR)
  df(AU) = gradient_S_state(AU; SM_max, EX, FR)

  # 初值猜测
  ratio = S_target / S_capacity
  ratio = clamp(ratio, 0.0, 0.95) # 避开导数为0的奇点
  AU0 = AU_crit * ratio

  return newton_solver(f, AU0, df, S_target)
end

# --- 测试用例 ---
SM_max = 100.0
EX = 2.0
FR = 0.4
# 1. 正常情况
val2 = inverse_AU(2.0; SM_max, EX, FR)
println("  => Solved AU: $(round(val2, digits=4))")
println("  => Check S: $(round(separate_S_state(val2; SM_max, EX, FR), digits=4))")

# 2. 溢出情况 (用户报告的 S=10)
val10 = inverse_AU(10.0; SM_max, EX, FR)
println("  => Solved AU: $(round(val10, digits=4))")
println("  => Check S: $(round(separate_S_state(val10; SM_max, EX, FR), digits=4))")
