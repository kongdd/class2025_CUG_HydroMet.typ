#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, 
  footer: "CUG水文气象学2025", 
  header: "第6章 土壤水运动"
)

#counter(heading).update(5)
#set par(leading: 1.24em)
#let delta(x) = $Delta #x$

// =
// =
// =
// =
// =
= 6 土壤水运动求解

// #beamer-block()[本章理论主要参考#cite(<bonan2019climate>, form: "prose") chapter 8。]

#figure(
  image("Figures/Bonan_Soil_SM.png", width: 55%),
  caption: [土壤分层与土壤水运动示意图。]
) <fig_soil>

*核心公式：*

// ^(n+1)
$ q = -K pdv(psi + z, z) $
$ (Delta theta_(i)) / (Delta t)  Delta z_i = -q_(i-1) + q_(i) - e_i $

$
  q_i = -K_(i+1/2) ( (psi_(i+1) + z_(i+1)) -  (psi_(i) + z_(i))) / (z_(i+1) - z_(i))
$

$
  q_(i-1) = -K_(i-1/2) ( (psi_i + z_i) -  (psi_(i-1) + z_(i-1))) / (z_i - z_(i-1))
$

- 上标$n$和$n+1$代表时间；下标$i-1$、$i$、$i+1$代表土壤层（图@fig_soil）。
- $K$：水力传导系数，$"cm" h^(-1)$
- $psi$：土壤水势，土壤水饱和为0，缺水为负，单位cm
- $q$：土壤水运动对应的流量，向下为负，单位$"cm" h^(-1)$
- $e$: 蒸发量，$"cm" h^(-1)$


== 6.1 边界层条件

=== 6.1.1 第1层

- 已知通量：表层的土壤水运动的流量$q_0$（也即是下渗量）
- 已知状态：表层的土壤水势$psi_0$

=== 6.1.2 第N层

==== 6.1.2.1 重力排水

  $ q_N = -K_N $

==== 6.1.2.2 与地下水交互

*(1) 均衡水势$psi_E$*

  为了考虑土壤水与地下水的交互作用，Zeng et al. (2009)引入了均衡水势的概念$psi_E$。$q = 0$时，对应的土壤水势，即均衡水势$psi_E$，对应的土壤含水量为均衡含水量$theta_E$。当处于均衡状态时，每一层土壤的总势能均相等：
  
  $ psi_E + z = psi_"sat" [theta_E(z) / theta_"sat"]^(-B) + z = psi_"sat" + z_"wt" = C $

$ 
  overline(theta_{E,i}) = integral_(z_1)^(z_2) theta_E(z) d z \/delta(z) &= 
    theta_"sat" psi_"sat"^(1/B) integral_(z_1)^(z_2) (C - z)^(-1/B) d z \/delta(z) \
 // &= theta_"sat" psi_"sat"^(1/B) B / (B-1) [-(C - z)^(1 - 1/B)]_(z_1)^(z_2) \/delta(z) \
  &= theta_"sat" psi_"sat"^(1/B) B / (B-1) [(C - z_1)^(1 - 1/B) - (C - z_2)^(1 - 1/B)] \/delta(z)
  $

$ psi_"sat" [theta_E(z) / theta_"sat"]^(-B) = C - z $

  $ theta_E(z) = theta_"sat" ((C - z) / psi_"sat")^(-1/B)  
    = theta_"sat" psi_"sat"^(1/B) (C - z)^(-1/B) $

其中：当$z_"wt"$不变时，C为常数。

从$z_1$到$z_2$的土壤的平均均衡含水量$overline(theta_E)$：


- $delta(z) = z_2 - z_1$

```julia
function cal_θE(z1::T, z0::T, zwt::T, ψ_sat::T, B::T; 
  use_clamp=true) where {T<:Real}
  C = ψ_sat + zwt
  Δz = z1 - z0
  u1 = ((C - z1) / ψ_sat)^(1 - 1 / B) # z1 = z[j]
  u0 = ((C - z0) / ψ_sat)^(1 - 1 / B) # z2 = z[j-1]
  θE = -ψ_sat[j] * θ_sat[j] / (1 - 1 / B) / Δz * (u1 - u0) # Zeng2009, Eq.9
  use_clamp && (θE = clamp(θE, 0, θ_sat))
  return θE
end
```
// #highlight()[TODO: 绘制均衡水势曲线，测试均衡水势函数。]

*(2) 流量$q$*
  $
    q &= -K pdv((psi + z), z) = -K pdv((psi + z - C), z) \
      &= -K pdv((psi - psi_E), z)
  $ <q_psi_e>

// 式@dq1 \~ @dq4 

对于i-1层， $q_"in"$: $q_(i-1)$，$q_"out"$: $q_(i)$。

1. *若zwt位于土壤中*，假定在第N层（i=N）。

  由于下方处于均衡状态，因此$q_"out" = 0 (q_i = 0), pdv(q_i, theta_(i))=0, pdv(q_i, theta_(i+1))=0$。

  *对于第$N$层：*
  $
    a &= - pdv(q_(i-1), theta_(i-1)) \
    b &= pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) = 
         - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) \
    c &= pdv(q_(i), theta_(i+1)) = 0 \
    r &= q_(i-1)^(n) - q_(i)^(n) + e_i = q_(i-1)^(n) + e_i
  $

  *对于第$N+1$层：* $q_"in" = 0, q_"out" = 0$，地下水不存在直接蒸发$e_(i+1)=0$。

  $
    a = 0, b = (Delta z_i)  / (Delta t), c = 0, r = 0
  $

2. *若zwt位于土壤之下*，设置了一个虚拟层N+1层，向下不排水，厚度为$Delta z_(N+1) = "zwt" - z_(+h,N)$，中心位置
   $z_(N + 1) = ("zwt" + z_(+h,N) ) / 2$。对于第N+1层，
   
   土壤水$theta$的水势：$theta = (theta_N + theta_("sat"))/2$，$psi = cal\_psi(theta)$。
   
   均衡水势$psi_E$：根据土壤的上下边界$z_0, z_1$，以及水位$"zwt"$，可以计算出均衡水势$psi_E$和均衡土壤含水量$theta_E$。

  *对于第$N$层：* 正常求解。

  *对于第$N+1$层：* 底部为0，$q_i = 0, pdv(q_i, theta_(i+1)) =0$

  $
    a &= - pdv(q_(i-1), theta_(i-1)) \
    b &= pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) = 
         - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) \
    c &= pdv(q_(i), theta_(i+1)) = 0 \
    r &= q_(i-1)^(n) - q_(i)^(n) + e_i = q_(i-1)^(n) + e_i
  $

// #box-red[
//   #highlight([*思考*：])
//   *地下水与土壤水的交互，体现在什么地方？*
// ]

#figure(``, caption: "Zeng2009代码实现。", 
  supplement: text("表", weight:"bold"))
```julia
# Nodes j=2 to j=N-1
for i in 2:N-1
  dz = (zmm[i] - zmm[i-1])
  dψ = ψ[i] - ψE[i] - (ψ[i-1] - ψE[i-1])
  qin[i] = -K₊ₕ[i-1] * dψ / dz
  dqidθ0[i] = -(-K₊ₕ[i-1] * dψdθ[i-1] + dψ * dKdθ[i-1]) / dz
  dqidθ1[i] = -(K₊ₕ[i-1] * dψdθ[i] + dψ * dKdθ[i-1]) / dz

  dz = (zmm[i+1] - zmm[i])
  dψ = ψ[i+1] - ψE[i+1] - (ψ[i] - ψE[i])
  qout[i] = -K₊ₕ[i] * dψ / dz
  dqodθ1[i] = -(-K₊ₕ[i] * dψdθ[i] + dψ * dKdθ[i]) / dz
  dqodθ2[i] = -(K₊ₕ[i] * dψdθ[i+1] + dψ * dKdθ[i]) / dz

  rmx[i] = qin[i] - qout[i] - e[i]
  amx[i] = -dqidθ0[i]
  bmx[i] = dzmm[i] / dtime - dqidθ1[i] + dqodθ1[i]
  cmx[i] = dqodθ2[i]
end
```

#v(1em)
== 6.2 土壤水运动求解

采用偏微分方程求解器（DifferentialEquations.jl）进行求解。

$
  (d u) / (d t) = f(u, p, t)
$

- u：要求解的状态变量；
- p：参数；
- t：时间。

*5行代码求解偏微分方程：*
```julia
using DifferentialEquations

f(u, p, t) = 1.01 * u
u0 = 1 / 2
tspan = (0.0, 1.0)
prob = ODEProblem(f, u0, tspan)
sol = solve(prob, Tsit5(), reltol = 1e-8, abstol = 1e-8)
```

=== 6.2.1 流量$q$

```julia
function soil_WaterFlux!(soil::Soil{T}, θ::AbstractVector{T};
  ψ0::T=NaN, Q0::T=NaN, method="ψ0") where {T<:Real}
  (; ibeg, N, Q, K, K₊ₕ, ψ) = soil
  z = soil.z_cm
  cal_ψ!(soil, θ)
  cal_K!(soil, θ)
  cal_K₊ₕ!(soil)

  if method == "ψ0"
    z_prev = ibeg == 1 ? 0 : z[ibeg-1]
    Q0 = -K[ibeg] * ((ψ0 - ψ[ibeg]) / (z_prev - z[ibeg]) + 1) # [cm/s]
  elseif method == "Q0"
    # Q0 = Q0
  end
  @inbounds for i in ibeg:N-1
    # K₊ₕ = (K[i] + K[i+1]) / 2
    Δz₊ₕ = z[i] - z[i+1]
    Q[i] = -K₊ₕ[i] * ((ψ[i] - ψ[i+1]) / Δz₊ₕ + 1)
  end
  Q[N] = -K[N] # 尾部重力排水
  Q0
end
```

=== 6.2.2 偏微分方程$(d theta) / (d t)$定义

```julia
"""
# Arguments
- `method`: 
  + `ψ0`: ψ0 boundary condition, 第一类边界条件
  + `Q0`: Q0 boundary condition, 第二类边界条件
"""
function RichardsEquation(dθ::AbstractVector{T}, θ::AbstractVector{T}, 
  p::Soil{T}, t; method="ψ0") where {T<:Real}
  p.timestep += 1
  (; ibeg, N, Q, ψ0, Q0, sink) = p # Δz, z, 
  Δz = p.Δz_cm
  Q0 = soil_WaterFlux!(p, θ; ψ0, Q0, method)

  dθ[ibeg] = -((Q0 - Q[ibeg]) + sink[ibeg]) / Δz[ibeg]
  @inbounds for i in ibeg+1:N
    dθ[i] = -(Q[i-1] - Q[i]) / Δz[i] - sink[i] / Δz[i]
  end
end
```

```julia
tspan = (0, dt)
prob = ODEProblem(RichardsEquation, u0, tspan, soil)

sol = solve(prob, solver; reltol, abstol, saveat=dt)
θ_next = sol.u[end]
```

// #v(1em)
// == 如何研究土壤水运动？

// #box-red[
//   土壤水运动影响因素众多，包括下渗、蒸发、地下水运动。研究问题需控制单一变量。

//   - 蒸发、地下水运动：日间尺度二者对土壤水运动的影响较小，可忽略。
//   - 下渗：土壤水运动从第2层土壤开始求解，以第一层的土壤含水量作为边界条件，可跳过下渗的问题。
// ]

// #pagebreak()

// == Zeng2009 地下水与土壤水交互方案

// === 方程求解

// #bibliography("References.bib", title: "参考文献", style:"gb-7714-2015-author-date")
