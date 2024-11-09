#import "config.typ": *
#import "@preview/showybox:2.0.2": showybox
#import "@preview/physica:0.9.3": *
#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold

#show: (doc) => template(doc, 
  size: 13pt,
  footer: "CUG水文气象学2024",
  header: "第一章 土壤水运动")


= 数值解求解

== 构造三角矩阵


在微积分中，若$z = f(x, y)$，则$ d z = pdv(z, x)d y + pdv(z, y) d x$。若$ q_(i)^(n+1) = f(theta_(i-1), theta_i)$，根据积分法则可以得到：

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

#beamer_block(
  [1. $q$为矢量，向下为负，$-q$是为了从矢量转为标量。*进多出少，则$theta$增。反之，则降。*
  2. $Delta z_i$为正，注意区分坐标系是*向下为正，还是向上为正*。
  ]
)

将公式@q_i0 、@q_i1 带入@d_theta，得到：

$
  (Delta theta_(i)) / (Delta t)  Delta z_i = 
    -&[calqRight(i-1, i, n, n+1)] + \
    &[calqRight(i, i+1, n, n+1)]
    - e_i
$ 

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
  b &= pdv(q_(i), theta_(i)) - pdv(q_(i-1), theta_(i)) - Delta z_i  / (Delta t) \
  c &= pdv(q_(i), theta_(i+1)) \
  r &= q_(i-1)^(n) - q_(i)^(n) + e_i
$

之后，可利用带状矩阵的方法进行求解。


#figure(
  image("images/Bonan_Soil_SM.png", width: 55%),
  caption: [土壤分层与土壤水运动示意图。]
) <fig_soil>

// #pagebreak()

== 偏微分

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


Zeng et al. (2009)对式 @q 采用均衡水势进行了修改（式@q_psi_e），仅$pdv(q, theta)$偏微分部分需要更新，其他计算过程与CLM5完全一致，式@dq1 \~ @dq4 。

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

  rmx[i] = qin[i] - qout[i] - qflx_rootsoi_col[i]
  amx[i] = -dqidθ0[i]
  bmx[i] = dzmm[i] / dtime - dqidθ1[i] + dqodθ1[i]
  cmx[i] = dqodθ2[i]
end
```
其中，对于i-1层， qin: $q_(i-1)$，qout: $q_(i)$。
