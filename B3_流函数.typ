#import "typst/lib.typ": *

#show: (doc) => template(doc, 
  size: 11.5pt,
  footer: "CUG水文气象学2024",
  header: "流函数")
#counter(heading).update(3)
#set par(leading: 1.24em)
#let delta(x) = $Delta #x$

= 流函数

== 连续性方程

对于不可压缩流体，连续性方程在z坐标下表现为：
$
  pdv(u, x) + pdv(v, y) + pdv(w, z) = 0
$

p坐标下为：
$
  pdv(u, x) + pdv(v, y) + pdv(omega, p) = 0 \
  
  Delta dot bold(v) = 0
$

代入球坐标中，$d x = a cos phi d lambda$, $d y = a d phi $

$
  u = dv(x, t) = a cos phi dv(lambda, t), 
  v = dv(y, t) = a dv(phi, t)
$

#mitex(`$$
\frac{1}{a \cos \phi} \left( \frac{\partial u}{\partial \lambda} + \frac{\partial (v \cos \phi)}{\partial \phi} \right) + \frac{\partial \omega}{\partial p} = 0
$$`)


满足流函数的$u$, $omega$为：
#mitex(`$$
v = \frac{1}{\cos \phi} \frac{\partial \psi}{\partial p}, \quad \omega = -\frac{1}{a \cos \phi} \frac{\partial \psi}{\partial \phi}
$$`)


== 平均径向环流

#let phi = $phi.alt$

取纬向平均，

$
  1 / (a cos phi) pdv((v cos phi), phi) + pdv(omega, p) = 0
$

流函数$Psi_M$ ($"kg"\/s$)，此处定义的流函数代表的含义为向北流动的质量。

$ Psi_M (phi, p) = (2pi a cos phi) / g integral_(p_0)^p [v] d p $

注意，积分中的上标p可以为任意高度，因此可计算出任意高度处的$Psi_M (phi, p)$

$
  [v] = g / (2pi a cos phi) pdv(Psi_M, p),  \
  [omega] = - g / (2pi a cos phi) pdv(Psi_M, phi)
$

应用示例：

#figure(
  image("images/大气科学/流函数-示例.png", width: 70%),
  caption: [
    流函数分析方法示例。
    红色代表的是$Psi_M > 0$，质量向北输送；蓝色代表的是$Psi_M < 0$，向南。
    因此，赤道附近红蓝交汇处是ITCZ的位置。据图，也可以分析出副高的位置。
  ]
) <fig_>





=== 推导过程

// - *东西向*
#mitex(`$$
\Delta \Phi_{\lambda} = \left[ u(\lambda + \tfrac{\Delta \lambda}{2}, \phi) - u(\lambda - \tfrac{\Delta \lambda}{2}, \phi) \right] \cdot a \, \Delta \phi
$$`)

#mitex(`$$
\Delta \Phi_{\phi} = \left[ v(\lambda, \phi + \tfrac{\Delta \phi}{2}) \cos(\phi + \tfrac{\Delta \phi}{2}) - v(\lambda, \phi - \tfrac{\Delta \phi}{2}) \cos(\phi - \tfrac{\Delta \phi}{2}) \right] \cdot a \, \Delta \lambda
$$`)

#mitex(`$$
\Delta \Phi_{\lambda} + \Delta \Phi_{\phi} = 0
$$`)

两边同时除以控制单位体积#mi("a^2 \cos \phi \, \Delta \lambda \Delta \phi")，

*东西向*：
#mitex(`$$
\frac{1}{a^2 \cos \phi \, \Delta \lambda \Delta \phi} \cdot a \, \Delta \phi \cdot \left[ u(\lambda + \tfrac{\Delta \lambda}{2}, \phi) - u(\lambda - \tfrac{\Delta \lambda}{2}, \phi) \right] = \frac{1}{a \cos \phi} \cdot \frac{\partial u}{\partial \lambda}
$$`)

*南北向*：

#mitex(`$$
\frac{1}{a^2 \cos \phi \, \Delta \lambda \Delta \phi} \cdot a \, \Delta \lambda \cdot \left[ v(\lambda, \phi + \tfrac{\Delta \phi}{2}) \cos(\phi + \tfrac{\Delta \phi}{2}) - v(\lambda, \phi - \tfrac{\Delta \phi}{2}) \cos(\phi - \tfrac{\Delta \phi}{2}) \right] = \\ \frac{1}{a \cos \phi} \cdot \frac{\partial (v \cos \phi)}{\partial \phi}
$$`)

== 流函数

流函数𝜓是一个标量函数，其等值线（即𝜓 = 常数）表示流线，流线是流体粒子运动
的轨迹。对于二维不可压缩流体，流函数通过流体的速度场定义：

$
  u = pdv(psi, y), v = -pdv(psi, x)
$

== 体积流量与流函数之间的关系

$
  d x^2  + d y^2 = d s^2
$

方向向量l，和法向量n：
$
  l &= (d x) / (d s) i + (d y) / (d s) j \
  n &= -(d y) / (d s) i + (d x) / (d s) j, "(前进方向的右侧)" \ 
$

体积流量Q（$m^2\/s$）。体积流量Q再乘以垂向高度得到单位时间流过的体积（$m^3\/s$）。

#mitex(`$$
Q = \int_C (\mathbf{u} \cdot \mathbf{n}) \, ds = \int_{t_A}^{t_B} \left[ u \left(-\frac{dy}{dt}\right) + v \left(\frac{dx}{dt}\right) \right] dt
$$`)

将$u = pdv(psi, y)$, $v = -pdv(psi, x)$带入得，

#mitex(`$$
u \left(-\frac{dy}{dt}\right) + v \left(\frac{dx}{dt}\right) = \left( \frac{\partial \psi}{\partial y} \right) \left(-\frac{dy}{dt}\right) + \left( -\frac{\partial \psi}{\partial x} \right) \left(\frac{dx}{dt}\right) \\
= -\frac{\partial \psi}{\partial y} \frac{dy}{dt} - \frac{\partial \psi}{\partial x} \frac{dx}{dt}
$$`)

注意到，

#mitex(`$$
\frac{d\psi}{dt} = \frac{\partial \psi}{\partial x} \frac{dx}{dt} + \frac{\partial \psi}{\partial y} \frac{dy}{dt}
$$`)

因此，
#mitex(`$$
u \left(-\frac{dy}{dt}\right) + v \left(\frac{dx}{dt}\right) = 
-\frac{\partial \psi}{\partial y} \frac{dy}{dt} - \frac{\partial \psi}{\partial x} \frac{dx}{dt} = -\frac{d\psi}{dt}
$$`)

#mitex(`$$
Q = \int_{t_A}^{t_B} \left( -\frac{d\psi}{dt} \right) dt = -\int_{t_A}^{t_B} \frac{d\psi}{dt} dt = -\left[ \psi(t_B) - \psi(t_A) \right] \\
= \psi(t_A) - \psi(t_B) = \psi_A - \psi_B
$$`)

流量符号取决于法向量选择，物理上流量为绝对值，方向由流场决定。
