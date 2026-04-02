# 牛顿法求解非线性方程 f(x) = y_target
function newton_solver(f::Function, grad::Function, x0, y_target=0.0;
  atol=1e-10, rtol=1e-10, maxiter=20, verbose=false)
  x = float(x0)
  iter = 0
  fx = 0.0

  while iter < maxiter
    iter += 1
    fx = f(x) - y_target
    verbose && println("[iter = $iter], x = $x, \t fx = $fx")

    abs(fx) <= atol && return x

    dfx = grad(x)
    if dfx == 0
      @warn "Derivative is zero at $x"
      return x
    end

    Δx = fx / dfx
    x -= Δx
    isfinite(x) || (@warn("Non-finite value at iteration $iter"); return x)
    abs(Δx) <= atol + rtol * abs(x) && return x
  end
  @warn("Newton failed to converge after $iter iterations")
  return x # (; x, iter, fx)
end


function newton_solver(fdf::Function, x0, y_target=0.0;
  atol=1e-10, rtol=1e-10, maxiter=20, verbose=false)

  x = float(x0)
  iter = 0
  fx = 0.0

  while iter < maxiter
    iter += 1
    val, dfx = fdf(x)
    fx = val - y_target
    verbose && println("[iter = $iter], x = $x, \t fx = $fx")

    abs(fx) <= atol && return x # 收敛判断 1: 残差足够小

    if dfx == 0
      @warn "Derivative is zero at $x"
      return x
    end

    Δx = fx / dfx
    x -= Δx
    isfinite(x) || (@warn("Non-finite value at iteration $iter"); return x)
    abs(Δx) <= atol + rtol * abs(x) && return x # 收敛判断 2: 步长足够小
  end
  @warn("Newton failed to converge after $iter iterations")
  return x # 保持返回值类型一致，方便由调用方处理
end


## 核心加速：同时计算 S 和 dS/dAU
# 专门提供给牛顿法使用，避免重复计算幂函数，性能提升约 30%
function calc_S_dS(AU, FR; SM_max, EX)
  S_max = SM_max / (1 + EX) # grid_max -> regional_max
  rel_au = clamp(1.0 - AU / SM_max, 0.0, 1.0)

  rel_au <= 1e-12 && (rel_au = 0.0) # 极小值保护，防止导数计算溢出
  term_pow = rel_au^EX

  # 导数 dS = (FR - 1) + (1 - AU/SM_max)^EX
  dS = (FR - 1) + term_pow

  # 值 S = AU*(FR-1) + S_max_param * (1 - (1-AU/SM_max)^(EX+1))
  # 利用 term_pow * rel_au 替代 rel_au^(EX+1) 以复用计算
  S = AU * (FR - 1) + S_max * (1.0 - term_pow * rel_au)
  return S, dS
end


function cal_SM(FR::T; SM_max::T, EX::T) where {T<:AbstractFloat}
  return SM_max * (1 - (1 - FR)^(1 / EX))
end


# 传统方法, 不考虑FR的影响
function solve_AU(W::T, WMM::T, B::T) where {T<:AbstractFloat}
  W_max = WMM / (1 + B) # grid_max -> regional_max
  W_frac = clamp(W / W_max, 0.0, 1.0)
  AU = WMM * (1 - (1 - W_frac)^(1 / (1 + B))) # Eq. 2-58, 根据W反推AU
  return 1 - (1 - AU / WMM)^B                 # Eq. 2-55, 产流面积α0
end


## 用于求解前期AU, S_target是流域平均!
function solve_AU_newton(S_target::T, FR::T; SM_max::T, EX::T,
  atol=1e-10, rtol=1e-10, maxiter=20, verbose=false) where {T<:AbstractFloat}

  max = cal_SM(FR; SM_max, EX)
  AU = clamp(S_target / FR, 0.0, max) # 初始猜测值，假设R占比很小

  fdf = AU -> calc_S_dS(AU, FR; SM_max, EX) # function to solve AU
  newton_solver(fdf, AU, S_target; atol, rtol, maxiter, verbose)
end



function cal_S(AU::T, FR::T; SM_max::T, EX::T) where {T<:AbstractFloat}
  S_max = SM_max / (1 + EX)   # grid_max -> regional_max  
  R = AU - S_max * (1 - (1 - AU / SM_max)^(EX + 1))
  S = AU * FR - R
  return S
end

function solve_AU_bisection(S_target::T, FR::T; SM_max::T, EX::T) where {T<:AbstractFloat}
  max = cal_SM(FR; SM_max, EX)
  eq = AU -> cal_S(AU, FR; SM_max, EX) - S_target
  find_zero(eq, (0.0, max), Bisection()) # return AU
end
