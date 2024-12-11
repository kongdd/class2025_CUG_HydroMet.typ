#import "./typst/lib.typ": *

#counter(heading).update(4)
#let delta(x) = $Delta #x$
#show math.equation: set text(11pt)

#show: (doc) => template(doc, 
  size: 13pt,
  footer: "CUG水文气象学2024",
  header: "土壤热通量")

= 土壤热通量

#beamer-block()[本章理论主要参考#cite(<bonan2019climate>, form: "prose")。]

基于能量平衡公式和净辐射公式，可知：

$ cases(
    R_n - G = lambda E + H,
    R_n = R"ns" + R"nl" = (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4
) $

代入$G$, $H$, $lambda E$的公式，可得：

$
  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p delta(e)) / (gamma r_v) + (rho c_p delta(T)) / r_H \

  (1 - alpha) R_s + epsilon"Rln" - epsilon sigma T_s^4 - kappa / delta(z) (T_s - T_1) = (rho c_p (e_"surf" - e) ) / (gamma r_v) + (rho c_p (T_s - T_a)) / r_H
$ <eq_5.2>

- $kappa$: 热传导系数，$"W"\/m^2\/K$
- $R_n$: 净辐射，MJ
- $lambda$: 汽化潜热，2.5 MJ / kg
- $gamma$：湿度计常数，kPa / K
- $rho$: 空气密度，$"kg"\/m^3$
- $r_v$, $r_H$：分别是水汽和热量的传导阻力，$s\/m$。
- $T_s$：地表温度，℃
- $T_a$：空气温度，℃
- $e_"surf"$：蒸发面的水汽压，kPa
- $e$：空气水汽压，kPa
- $T_1$：第一层土壤的温度，℃
- $delta(z)$: 第一层土壤的厚度，m


#box-red([
  *为何要研究土壤热通量？*

  日内尺度，土壤温度$T_s$变化剧烈，根据玻尔兹曼定律，$T_s$变化会引起地表净辐射$R_n$的变化，影响地表能量平衡和水量平衡。

  1. 若想准确模拟陆表能量平衡（$lambda H$和$lambda E$）和水量平衡（$E$）过程，需要清楚土壤温度是如何变化的。

  2. 厘清土壤温度与空气温度之间的关系，可应用于城市热岛研究，边界层研究，例如城市、水体对周边区域空气温度的影响。基于式#[@eq_5.2]，已知土壤温度，可求解空气温度。
])

如下图所示，表层的土壤温度变化非常剧烈，地表的土壤温度TS_0日内变化幅度甚至超过了空气温度，在空气温度为30℃时，地表温度甚至可以达到50℃。与之形成鲜明对比，深层土壤温度变化非常缓慢，40cm以下的土壤温度几乎看不到日内波动，80cm以下的土壤温度在图中几乎是一条直线。

#figure(
  image("images/土壤热通量/Figure_CUG_Tsoil_202306.svg", width: 100%),
  caption: [中国地质大学（武汉）大气系气象观测站2023年6月逐小时土壤温度。

    其中黑线为空气温度。
  ]
) <fig_CUG_Tsoil>


== 基本原理

#figure(
  image("images/土壤热通量/土壤热通量_连续性原理.png", width: 100%),
  caption: [
    （a）土壤通量与土壤温度连续性原理示意图；（b）土壤分层说明。
    $z_i$代表的是每一层土壤的中间位置；$z_(i+1/2)$代表的是每层土壤的下边界。$z$与$F$均是向下为负。
  ]
) <fig_Tsoil_cont>

// #pagebreak()

*热通量公式：*

$ F = - kappa pdv(T, z) $

- $kappa$: 热传导系数，$"W"\/m\/K$；
- $F$: 土壤热通量，$"W"\/m^2$；
- 负号代表土壤热通量向下为负。

*连续性原理：*

$ rho c_v^\* delta(x) delta(y) delta(z) delta(T) =  -(F_"in" - F_"out") delta(x) delta(y) delta(t) $

$ c_v delta(T) / delta(t) = - delta(F) / delta(z), c_v = rho c_v^\* $ <eq_5.5>

其中，$c_v$是体积热容量（volumetric heat capacity，$J m^(-3)s^(-1)$)，是比热容与密度的乘积。式#[@eq_5.5]写成偏微分形式，则是：

$ c_v pdv(T, t) = - pdv(F, z) = kappa pdv(T, z, 2) $ <eq_heat>


#figure(
  image("images/土壤热通量/土壤热通量-土壤结构.png", width: 54%),
  caption: [
    每层的土壤状态与土壤热通量。
  ]
) <fig_Tsoil_cont>


#figure(
  caption: [土壤热通量参数。数据源于de Vries (1963)。],
  table(
    columns: (3.2cm, 5.5cm, 5.4cm),
    // inset: 10pt,
    align: (left, center, center),
    table.header(
      [*Type*], [Thermal conductivity ($kappa$) \ $W m^(-1) K^(-1)$], [Heat capacity ($c_v$) \ $"MJ" m^(-3) K^(-1)$],
    ),
    [Quartz], [8.80], [2.12], 
    [Clay minerals], [2.92], [2.44], 
    [Organic matter], [0.25], [2.50], 
    [Liquid water], [0.57], [4.19], 
    [Ice], [2.18], [1.88], 
    [Air], [0.025], [0.0012], 
  )
)

// #pagebreak()

== 数值求解——复杂版 三角矩阵

#highlight()[如何求解土壤温度随时间的变化？] 主要用的是1个核心公式，式@eq_heat。

=== 差分方法

式#[@eq_heat]的差分方法有三种：

*显式差分* （explicit），又称向前差分，空间偏微分求解用的是历史时刻。

  $ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v ( (T_(i-1)^(n) - 2T_i^n + T_(i+1)^n) / delta(z^2) ) $

  令$M = kappa / c_v delta(t) / delta(z^2)$，可以直接得到下一时刻的温度：

  $ M T_(i-1)^n + (1 - 2M) T_i^n + M T_(i+1)^n = T_i^(n+1) $

  #beamer-block([这种方法的优点是简单，但是需要满足稳定性条件$M≤1/2$，稳定性相对较差。])

*隐式差分*（implicit），又称向后差分，空间偏微分求解用的是未来时刻。

$ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v ( (T_(i-1)^(n+1) - 2T_i^(n+1) + T_(i+1)^(n+1)) / delta(z^2) ) $

$ -M T_(i-1)^(n+1) + (1+2M) T_(i)^(n+1) - M T_(i+1)^(n+1) = T_i^n $

#beamer-block([稳定性条件$M>0$，稳定性相对较好。])

// 第一个时刻，$i=1$，
// $ c_v (T_i^(n+1) - T_i^(n)) / delta(t) = -( F_0 - kappa / delta(z) (T_i^(n+1) - T_(i+1)^(n+1))) / delta(z) ) $

*中间差分*（Cran-Nicolson），空间偏微分求解用的是历史和未来时刻。

$ (T_i^(n+1) - T_i^(n)) / delta(t) = kappa / c_v (  
  (T_(i-1)^(n) - 2T_i^n + T_(i+1)^n) / (2 delta(z^2)) + 
  (T_(i-1)^(n+1) - 2T_i^(n+1) + T_(i+1)^(n+1)) / (2 delta(z^2))
) $



=== 求解过程

*(a) 隐式差分为例，展示求解过程。*

#let kappa-coef(i)={
  // let p = $i+1/2$
  $kappa_#i / delta(z_#i)$
}

// #let cal_F(i) = {
//   // let i = $i+1$
//   $ - #kappa-coef(#i+1/2) (T_i^(n+1) - T_(i+1)^(n+1)) $
// }
// $ #cal_F(i) $

$
  F_i^n = - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \
  F_(i-1)^n = - #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) \
$

$ c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = -(F_(i-1)^n - F_i^n) $ <eq_5_11>

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \ 
$ <eq_5_12>

$
  - #kappa-coef($i-1/2$) T_(i-1)^(n+1)  + (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$)) T_i^(n+1) - #kappa-coef($i+1/2$) T_(i+1)^(n+1) = c_(v, i) delta(z_i) T_i^n / delta(t)
$

其中，$delta(z_i) = z_(i-1) - z_i$。上式可以写成矩阵形式：

$ a_i T_(i-1)^(n+1) + b_i T_i^(n+1) + c_i T_(i+1)^(n+1) = d_i $

之后便可利用三角阵的方式进行求解。

#figure(
  image("images/土壤热通量/三角阵求解.png", width: 70%),
  caption: [三角阵求解。]
) <fig_>

#highlight()[TODO: 补充公式推导过程。]

*边界条件*

对于第一层：

- 已知通量：土壤热通量$F_0$（也是能量平衡中的$G$），带入式#[@eq_5_11]：

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = -F_0 - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \ 
$

$
  (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i+1/2$) ) T_i^(n+1) 
    - #kappa-coef($i+1/2$) T_(i+1)^(n+1) = -F_0 + c_(v, i) delta(z_i) T_i^n / delta(t)
$

- 已知状态：土壤温度$T_0^(n+1)$，带入式#[@eq_5_12]：

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(0)^(n+1) - T_(i)^(n+1)) - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \ 
$

$
  (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$)) T_i^(n+1) - #kappa-coef($i+1/2$) T_(i+1)^(n+1) = c_(v, i) delta(z_i) T_i^n / delta(t) + #kappa-coef($i-1/2$) T_(0)^(n+1) 
$

对于第N层，认为$F_N = 0$，，带入式#[@eq_5_11]：

$
   c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) - F_N 
$

$
  - #kappa-coef($i-1/2$) T_(i-1)^(n+1) + (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) ) T_i^(n+1) = -F_N + c_(v, i) delta(z_i) T_i^n / delta(t)
$


*(b) 另一种解法，根据变化量$delta(T_i^n)$ （本科生跳过）* 

定义$delta(T_i^n) = T_i^(n+1) - T_i^(n)$。

$
  T_(i-1)^(n+1) &= (T_(i-1)^(n+1) - T_(i-1)^(n)) + T_(i-1)^(n) = delta(T_(i-1)^n) + T_(i-1)^(n)  \
  T_(i)^(n+1) &= (T_(i)^(n+1) - T_(i)^(n)) + T_(i)^(n) = delta(T_(i)^n) + T_(i)^(n)  \
  T_(i+1)^(n+1) &= (T_(i+1)^(n+1) - T_(i+1)^(n)) + T_(i+1)^(n) = delta(T_(i+1)^n) + T_(i+1)^(n) 
$

式#[@eq_5_12]可以写成：

$
  c_(v, i) delta(z_i) delta(T_i^n) / delta(t) = 
    #kappa-coef($i-1/2$) [ delta(T_(i-1)^n) + T_(i-1)^(n)  -(delta(T_(i)^n) + T_(i)^(n) ) ] \
    - #kappa-coef($i+1/2$) [ delta(T_(i)^n) + T_(i)^(n)  -(delta(T_(i+1)^n) + T_(i+1)^(n) ) ]
$

$
  - #kappa-coef($i-1/2$) delta(T_(i-1)^n) + 
    (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$)) delta(T_(i)^n) 
    -#kappa-coef($i+1/2$) delta(T_(i+1)^n) = \
    #kappa-coef($i-1/2$) (T_(i-1)^(n)  - T_(i)^(n)) - #kappa-coef($i+1/2$) (T_(i)^(n) - T_(i+1)^(n))
$

*边界条件*

对于第一层：

- 已知通量：土壤热通量$F_0$（也是能量平衡中的$G$），带入式#[@eq_5_11]：

$
  c_(v, i) delta(z_i) delta(T_i^n) / delta(t) = -F_0 - 
    #kappa-coef($i+1/2$) [ delta(T_(i)^n) + T_(i)^(n)  -(delta(T_(i+1)^n) + T_(i+1)^(n) ) ] \ 
$

$
  (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i+1/2$) )  delta(T_i^n)
    - #kappa-coef($i+1/2$) delta(T_(i+1)^n) = -F_0 - #kappa-coef($i+1/2$) (T_(i)^(n) - T_(i+1)^(n))
$


- 已知状态：土壤温度$T_0^(n+1)$，带入式#[@eq_5_12]：

$
  c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(0)^(n+1) - T_(i)^(n+1)) - #kappa-coef($i+1/2$) (T_i^(n+1) - T_(i+1)^(n+1)) \ 
$

$
  c_(v, i) delta(z_i) delta(T_i^n) / delta(t) = 
    #kappa-coef($i-1/2$) (T_(0)^(n+1) - (delta(T_(i)^n) + T_(i)^(n) ) ) 
    -#kappa-coef($i+1/2$) [ delta(T_(i)^n) + T_(i)^(n)  -(delta(T_(i+1)^n) + T_(i+1)^(n) ) ] 
$

$
  ( c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) + #kappa-coef($i+1/2$) )delta(T_i^n) 
  - #kappa-coef($i+1/2$) delta(T_i^(n+1)) = \
  #kappa-coef($i-1/2$) (T_(0)^(n+1) - T_(i)^(n)) - #kappa-coef($i+1/2$) (T_i^(n) - T_(i+1)^(n))
$



// 对于第N层，认为$F_N = 0$，，带入式#[@eq_5_11]：

// $
//    c_(v, i) delta(z_i) (T_i^(n+1) - T_i^n) / delta(t) = #kappa-coef($i-1/2$) (T_(i-1)^(n+1) - T_(i)^(n+1)) - F_N 
// $

// $
//   - #kappa-coef($i-1/2$) T_(i-1)^(n+1) + (c_(v, i) delta(z_i) / delta(t) + #kappa-coef($i-1/2$) ) T_i^(n+1) = -F_N + c_(v, i) delta(z_i) T_i^n / delta(t)
// $

== 数值求解——简易版 偏微分方程

=== 偏微分基础

解决诸如此类问题：

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

绘图展示结果：

```julia
using Plots
plot(sol, linewidth = 5, title = "Solution to the linear ODE with a thick line",
    xaxis = "Time (t)", yaxis = "u(t) (in μm)", 
    label = "My Thick Line!") # legend=false
plot!(sol.t, t -> 0.5 * exp(1.01t), lw = 3, ls = :dash, label = "True Solution!")
```

#figure(
  image("images/土壤热通量/ex_ODE_01.png", width: 70%),
  caption: [
    ODE求解示例1。
  ]
) <fig_>

=== 偏微分实战

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
  rho c_v^\* delta(x) delta(y) delta(z) delta(T) =  -(F_"in" - F_"out") delta(x) delta(y) delta(t)  \

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

得出每一层的热通量后，可以根据式#[@eq_5_11]求解每一层的温度变化。

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

=== 参数优化

随机参数，模拟结果：

#figure(
  image("images/土壤热通量/case01_Tsoil_CUG_ODE_raw.png", width: 85%),
  caption: [
    大气系土壤温度观测与随机参数$kappa$, $c_v$土壤温度模拟结果。
  ]
) <fig_cug_Tsoil_raw>


参数优化之后，模拟结果：

#figure(
  image("images/土壤热通量/case01_Tsoil_CUG_ODE.png", width: 85%),
  caption: [
    与图#[@fig_cug_Tsoil_raw]相似，只是参数$kappa$, $c_v$进行了优化。
  ]
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


#bibliography("References.bib", title: "参考文献", style:"gb-7714-2015-author-date")
