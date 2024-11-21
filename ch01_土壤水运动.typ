#import "config.typ": *
#import "@preview/showybox:2.0.2": showybox
#import "@preview/physica:0.9.3": *
#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold

#show: (doc) => template(doc, 
  size: 13pt,
  footer: "CUG水文气象学2024",
  header: "第一章 土壤水运动")
#counter(heading).update(0)

= 土壤水运动求解

#figure(
  image("images/Bonan_Soil_SM.png", width: 55%),
  caption: [土壤分层与土壤水运动示意图。]
) <fig_soil>

== CLM土壤水运动求解方案

=== 构造三角矩阵

在微积分中，若$z = f(x, y)$，则$ d z = pdv(z, x)d y + pdv(z, y) d x$。若$ q_(i-1) = f(theta_(i-1), theta_i)$，根据积分法则可以得到：

$ d q_(i-1) = pdv(q_(i-1), theta_(i-1)) d theta_(i-1) +  pdv(q_(i-1), theta_(i)) d theta_(i) $

// q = $#(q)_#iq$
#let dqdw(q, w) = pdv(q, w) + $Delta$ + w

#let calqRight(i0, i1, t0, t1) = {
  $q_#i0^#t0 + dqdw(q_#i0, theta_(#i0)) + dqdw(q_#i0, theta_(#i1))$
}

#let calq(i0, i1, t0, t1) = {
  $q_#i0^#t1 = #calqRight(i0, i1, t0, t1)$
}

$ calq(i-1, i, n, n+1) $ <q_i0>
$ calq(i, i+1, n, n+1) $ <q_i1>

$
  (Delta theta_(i)) / (Delta t)  Delta z_i = -q_(i-1)^(n+1) + q_(i)^(n+1) - e_i
$ <d_theta>

其中，上标$n$和$n+1$代表时间；下标$i-1$、$i$、$i+1$代表土壤层（图@fig_soil）。

#beamer_block(
  [1. $q$为矢量，向下为负，$-q$是为了从矢量转为标量。*进多出少，则$theta$增。反之，则降。*
  2. $Delta z_i$为正，注意区分坐标系是*向下为正，还是向上为正*。
  ]
)

将公式@q_i0 、@q_i1 带入@d_theta，得到：

$ (Delta theta_(i)) / (Delta t)  Delta z_i = 
    -&[calqRight(i-1, i, n, n+1)] + \
    &[calqRight(i, i+1, n, n+1)]
    - e_i $ 

合并同类项，整理成$a Delta  theta_(i-1) + b Delta  theta_(i) + c Delta  theta_(i+1) = r$的形式：

$
  - pdv(q_(i-1), theta_(i-1)) Delta  theta_(i-1) + 
  [pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t)  ] Delta  theta_(i) + 
  pdv(q_(i), theta_(i+1)) Delta  theta_(i+1)

   = q_(i-1)^(n) - q_(i)^(n) + e_i
$

因此，
$
  a &= - pdv(q_(i-1), theta_(i-1)) \
  b &= pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) \
  c &= pdv(q_(i), theta_(i+1)) \
  r &= q_(i-1)^(n) - q_(i)^(n) + e_i
$

之后，可利用带状矩阵的方法进行求解。

// 两类边界条件。

- #btext("i=1时")：

$ (Delta theta_(i)) / (Delta t)  Delta z_i = 
    -q_(i-1)^(n+1) + 
    &[calqRight(i, i+1, n, n+1)]
    - e_i $ 
$
  [pdv(q_i, theta_i) - (Delta z_i) / (Delta t)] Delta theta_(i) + 
  pdv(q_i, theta_(i+1)) Delta theta_(i+1) = q_(i-1)^(n+1) + e_i
$

$
  a &= 0, \
  b &= pdv(q_i, theta_i) - (Delta z_i) / (Delta t) \
  c &= pdv(q_i, theta_(i+1)) \
  r &= q_(i-1)^(n+1) + e_i
$
#beamer_block(
  [另外一种理解方式：$q_0$是初始边界条件，不随$theta_0$和$theta_1$变化而变化。]
)

- #btext("i=N时")：

*若底部自由排水*，$q_i^(n+1) = -K_i^(n+1) = -K_I^(n) + pdv(K_i, theta_i) Delta theta_i $，$pdv(q_i^(n+1), theta_i) = -pdv(K_i, theta_i)$、$pdv(q_i^(n+1), theta_(i+1)) = 0$，可得，

$
  a &= - pdv(q_(i-1), theta_(i-1)) \
  b &= pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t)  = -pdv(K_i, theta_i) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t)\
  c &= 0 \
  r &= q_(i-1)^(n) - q_(i)^(n) + e_i
$

*若底部零排水*，$q_i^(n+1) = C = 0$

$ (Delta theta_(i)) / (Delta t)  Delta z_i = 
    -[calqRight(i-1, i, n, n+1)] + 
    q_i^(n+1) - e_i $

$ -pdv(q_(i-1), theta_(i-1)) Delta theta_(i-1) 
  -[(Delta z_i) / (Delta t) + pdv(q_(i-1), theta_i) ]Delta theta_i = q_(i-1)^n - q_i^n + e_i $

$
  a &= -pdv(q_(i-1), theta_(i-1)), \
  b &= -[(Delta z_i) / (Delta t) + pdv(q_(i-1), theta_i)], \
  c &= 0, \
  r &= q_(i-1)^n - q_i^n + e_i
$

// #pagebreak()

=== $q$的偏微分

$ q = -K pdv(psi + z, z) $ <q>

$
  q_(i-1) &= -K_(i-1/2) ( (psi_i + z_i) -  (psi_(i-1) + z_(i-1))) / (z_i - z_(i-1))
$

$
  q_(i) &= -K_(i+1/2) ( (psi_(i+1) + z_(i+1)) -  (psi_(i) + z_(i))) / (z_(i+1) - z_(i))
$


对$q$求偏导：

$ pdv(q_(i-1), theta_(i-1)) = 
    K_(i-1/2) / (z_i - z_(i-1)) pdv(psi_(i-1), theta_(i-1)) 
    - pdv(K_(i-1/2), theta_(i-1)) [(psi_i + z_i - psi_(i-1) - z_(i-1)) / (z_i - z_(i-1))] $ <dq1>

$ pdv(q_(i-1), theta_(i)) = 
    -K_(i-1/2) / (z_i - z_(i-1)) pdv(psi_(i), theta_(i)) 
    - pdv(K_(i-1/2), theta_(i)) [(psi_i + z_i - psi_(i-1) - z_(i-1)) / (z_i - z_(i-1))] $

$ pdv(q_(i), theta_(i)) = 
    K_(i+1/2) / (z_(i+1) - z_(i)) pdv(psi_(i), theta_(i)) 
    - pdv(K_(i+1/2), theta_(i)) [(psi_(i+1) + z_(i+1) - psi_(i) - z_(i)) / (z_(i+1) - z_(i))] $

$ pdv(q_(i), theta_(i+1)) = 
    -K_(i+1/2) / (z_(i+1) - z_(i)) pdv(psi_(i+1), theta_(i+1)) 
    - pdv(K_(i+1/2), theta_(i+1)) [(psi_(i+1) + z_(i+1) - psi_(i) - z_(i)) / (z_(i+1) - z_(i))] $ <dq4>

// #pagebreak()

== Zeng2009 地下水与土壤水交互方案

Zeng et al. (2009)对式 @q 采用均衡水势进行了修改（式@q_psi_e），仅$pdv(q, theta)$偏微分部分需要更新，其他计算过程与CLM完全一致，式@dq1 \~ @dq4 。

$ q = -K pdv((psi - psi_E), z) $ <q_psi_e>

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
其中，对于i-1层， qin: $q_(i-1)$，qout: $q_(i)$。

1. *若zwt位于土壤中*，假定在第N层（i=N）。

  由于下方c处于均衡状态，因此$q_o = q_i = 0, pdv(q_i, theta_(i))=0, pdv(q_i, theta_(i+1))=0$。

  *对于第$N$层：*
  $
    a &= - pdv(q_(i-1), theta_(i-1)) \
    b &= pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) = 
         - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) \
    c &= pdv(q_(i), theta_(i+1)) = 0 \
    r &= q_(i-1)^(n) - q_(i)^(n) + e_i = q_(i-1)^(n) + e_i
  $

  *对于第$N+1$层：* $q_i = 0, q_o = 0$，地下水不存在直接蒸发$e_(i+1)=0$。

  $
    a = 0, b = (Delta z_i)  / (Delta t), c = 0, r = 0
  $

2. *若zwt位于土壤之下*，设置了一个虚拟层N+1层，向下不排水，厚度为$Delta z_(N+1) = "zwt" - z_(+h,N)$，中心位置
   $z_(N + 1) = ("zwt" + z_(+h,N) ) / 2$。对于第N+1层，
   
   土壤水$theta$的水势：$theta = (theta_N + theta_("sat"))/2$，$psi = cal\_psi(theta)$。
   
   均衡水势：根据土壤的上下边界$z_0, z_1$，以及水位$"zwt"$，可以计算出均衡水势$psi_E$和均衡土壤含水量$theta_E$。

  *对于第$N$层：* 正常求解。

  *对于第$N+1$层：* 底部为0，$q_i = 0, pdv(q_i, theta_(i+1)) =0$

  $
    a &= - pdv(q_(i-1), theta_(i-1)) \
    b &= pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) = 
         - pdv(q_(i-1), theta_(i)) - (Delta z_i)  / (Delta t) \
    c &= pdv(q_(i), theta_(i+1)) = 0 \
    r &= q_(i-1)^(n) - q_(i)^(n) + e_i = q_(i-1)^(n) + e_i
  $

#highlight([*遗留问题*])

#showybox(
  // shadow: (color: yellow.lighten(55%), offset: 3pt),
  // body-color: red.lighten(95%)
  frame: (
    title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(95%)
  ),
  // title: 
)[
  *地下水与土壤水的交互，体现在什么地方？*
]
