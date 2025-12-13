#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

=== 5.3.2 偏微分实战

首先定义土壤结构体：
```julia
@with_kw_noshow mutable struct Soil{FT}
  N::Int = 10                        # layers of soil
  ibeg::Int = 1                      # index of the first layer，边界层条件指定
  inds_obs::Vector{Int} = ibeg:N     # indices of observed layers

  dt::Float64 = 3600                 # 时间步长, seconds
  z::Vector{FT} = zeros(FT, N)       # m, 向下为负
  z₊ₕ::Vector{FT} = zeros(FT, N)
  Δz::Vector{FT} = zeros(FT, N)
  Δz₊ₕ::Vector{FT} = zeros(FT, N)

  # 温度
  Tsoil::Vector{FT} = fill(NaN, N)    # [°C]
  κ₊ₕ::Vector{FT} = zeros(FT, N - 1)  # thermal conductivity at interface [W m-1 K-1]
  F::Vector{FT} = zeros(FT, N)   # heat flux, [W m-2]
  Tsurf::FT = FT(NaN)            # surface temperature, [°C]
  F0::FT = FT(NaN)               # heat flux at the surface, [W m-2]，向下为负

  ## Parameter: [水力] + [热力]参数
  param::SoilParam{FT} = SoilParam{FT}(; N)

  # ODE求解临时变量
  u::Vector{FT} = fill(NaN, N)   # [°C], 为了从ibeg求解地温，定义的临时变量
  du::Vector{FT} = fill(NaN, N)  # [°C]
  timestep::Int = 0              # 迭代次数
end
```

计算每一层的土壤热通量$F_i (i=0,...,N)$，这里套用的主要是如下公式：

#nonum([$
  rho c_v^\* delta(x) delta(y) delta(z) delta(T) = -(F_"in" - F_"out") delta(x) delta(y) delta(t) \
  c_v delta(T) / delta(t) = - delta(F) / delta(z), c_v = rho c_v^\* \
  // 其中，$c_v$是体积热容量（volumetric heat capacity，$J m^(-3)s^(-1)$)。写成偏微分形式，则是：
  c_v pdv(T, t) = - pdv(F, z) = kappa pdv(T, z, 2) \
  F_i^n = - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1))
$])

```jl
function soil_HeatFlux!(F::V, T::V, κ::V, z::V, z₊ₕ::V;
  F0::FT=NaN, Tsurf::FT=NaN, 
  method="Tsurf", ibeg::Int=1) where {FT<:Real,V<:AbstractVector{FT}}

  N = length(T)
  if method == "Tsurf"
    if ibeg == 1
      F0 = -κ[1] * (Tsurf - T[1]) / (0 - z[1])
    elseif ibeg > 1
      F0 = -κ[ibeg] * (Tsurf - T[ibeg]) / (z[ibeg-1] - z[ibeg])
    end
  end

  @inbounds for i in ibeg:N-1
    d1 = z[i] - z₊ₕ[i]
    d2 = z₊ₕ[i] - z[i+1]
    κ₊ₕ = κ[i] * κ[i+1] * (d1 + d2) / (κ[i] * d2 + κ[i+1] * d1) # Eq. 5.16, 
    # κ₊ₕ = (κ[i] + κ[i+1]) / 2
    Δz₊ₕ = z[i] - z[i+1]
    F[i] = -κ₊ₕ * (T[i] - T[i+1]) / Δz₊ₕ
  end
  F[N] = 0
  return F0
end
```

得出每一层的热通量后，

$
  F_i^n = - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \
  F_(i-1)^n = - #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) \
$

$ c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = -(F_(i-1)^n - F_i^n) $ <eq_5_11>

// 可以根据式#[@eq_5_11]求解每一层的温度变化。

$ c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = -(F_(i-1)^n - F_i^n) $


```jl
function TsoilEquation(dT, T, soil::Soil, t; method="Tsurf", ibeg::Int=1)
  soil.timestep += 1
  # TODO: 根据t，更新Tsurf
  (; N, Δz, z, z₊ₕ, F, Tsurf) = soil
  (; κ, cv) = soil.param
  F0 = soil_HeatFlux!(F, T, κ, z, z₊ₕ; Tsurf, F0=soil.F0, method, ibeg)

  dT[ibeg] = -(F0 - F[ibeg]) / (Δz[ibeg] * cv[ibeg])
  @inbounds for i in ibeg+1:N
    dT[i] = -(F[i-1] - F[i]) / (Δz[i] * cv[i])
  end
end

# 该函数目的：跳过不需要求解的签1:ibeg-1层
function TsoilEquation_partial(dT, T, p::Soil, t; method="Tsurf", ibeg::Int=1)
  p.du[ibeg:end] .= dT
  p.u[ibeg:end] .= T
  TsoilEquation(p.du, p.u, p, t; method, ibeg)
  dT .= p.du[ibeg:end]
  return nothing
end
```

之后带入偏微分方程求解器，即可得到每一层的土壤温度。

- 解一个时刻：
  ```jl
  using DifferentialEquations
  tspan = (0, dt)
  prob = ODEProblem(TsoilEquation, u0, tspan, soil)
  sol = solve(prob, solver; reltol, abstol, saveat=dt)
  Tsoil = sol.u[end]
  ```

- 解所有时刻：
  ```jl
  function solve_Tsoil_ODE(soil, Tsurf; solver, 
    reltol=1e-3, abstol=1e-3, verbose=false)
    (; N, inds_obs, ibeg, dt) = soil
  
    ntime = length(Tsurf)
    u0 = soil.Tsoil[ibeg:end]
  
    _TsoilEquation(dT, T, p, t) = TsoilEquation_partial(dT, T, p, t; ibeg)
    tspan = (0, dt)
    prob = ODEProblem(_TsoilEquation, u0, tspan, soil)
  
    R = zeros(ntime, N - ibeg + 1)
    R[1, :] .= soil.Tsoil[ibeg:end]
  
    for i = 2:ntime
      soil.Tsurf = Tsurf[i]
      prob.u0 .= soil.Tsoil[ibeg:end]
  
      sol = solve(prob, solver; reltol, abstol, saveat=dt)
      soil.Tsoil[ibeg:end] .= sol.u[end] # 更新这个时刻的结果
      R[i, :] .= soil.Tsoil[ibeg:end]
    end
  
    inds = @. inds_obs - ibeg + 1
    R[:, inds]
  end
  ```

完整代码见：https://github.com/CUG-hydro/SoilTemperature.jl/blob/main/test/case01_solve_Tsoil_CUG.jl。

=== 5.3.3 参数优化

随机参数，模拟结果：

#figure(
  image("Figures/case01_Tsoil_CUG_ODE_raw.png", width: 85%),
  caption: [
    大气系土壤温度观测与随机参数$kappa$, $c_v$土壤温度模拟结果。
  ],
) <fig_cug_Tsoil_raw>


参数优化之后，模拟结果：

#figure(
  image("Figures/case01_Tsoil_CUG_ODE.png", width: 85%),
  caption: [
    与图#[@fig_cug_Tsoil_raw]相似，只是参数$kappa$, $c_v$进行了优化。
  ],
) <fig_cug_Tsoil>

参数优化过程如下，设置（1）初始参数$x_0$；（2）参数值域`[lower, upper]`；（3）目标函数$f$，之后代入优化函数`sceua`即可得到最优参数。

```julia
soil = init_soil(; soil_type=7)
x0 = [soil.param.κ; soil.param.cv]
lower = [fill(0.1, 9); fill(0.1, 9) * 1e6]
upper = [fill(10.0, 9); fill(5.0, 9) * 1e6]

f(theta) = goal(theta)
@time theta, feval, exitflag = sceua(f, x0, lower, upper; maxn=Int(2 * 1e4))
```
