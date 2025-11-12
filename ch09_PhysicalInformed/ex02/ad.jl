using Enzyme

# 定义固定点求解的自定义规则
function fixed_point_solve(f, x0, params; tol=1e-6, max_iter=100)
  x = x0
  for i in 1:max_iter
    x_new = f(x, params)
    if norm(x_new - x) < tol
      return x_new
    end
    x = x_new
  end
  return x
end


# Enzyme规则
function EnzymeRules.augmented_primal(
  config::ConfigWidth{1},
  func::Const{typeof(fixed_point_solve)},
  ::Type{<:Active},
  f::Const,
  x0::Duplicated,
  params::Duplicated
)
  # 前向计算
  primal = fixed_point_solve(f.val, x0.val, params.val)

  # 保存必要信息用于反向传播
  tape = (f=f.val, x_sol=primal, params=params.val)

  return AugmentedReturn(primal, nothing, tape)
end


function EnzymeRules.reverse(
  config::ConfigWidth{1},
  func::Const{typeof(fixed_point_solve)},
  dret::Active,
  tape,
  f::Const,
  x0::Duplicated,
  params::Duplicated
)
  # 隐式函数定理计算梯度
  # ∂L/∂θ = (I - ∂f/∂x)^(-T) * ∂L/∂x

  # 使用自动微分计算雅可比
  J = Enzyme.jacobian(Forward, x -> tape.f(x, tape.params), tape.x_sol)

  # 求解线性系统
  λ = (I - J') \ dret.val

  # 参数梯度
  ∂f∂p = Enzyme.gradient(Reverse, p -> tape.f(tape.x_sol, p), tape.params)
  params.dval .+= λ' * ∂f∂p

  return (nothing, nothing, nothing)
end
