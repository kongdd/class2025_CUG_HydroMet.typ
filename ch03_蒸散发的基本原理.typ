#import "config.typ": *
// #show math.equation: format_eq
#counter(heading).update(2)
#let delta(x) = $Delta #x$

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "蒸发信号分离")


= 蒸散发的基本原理

== 气化潜热

#showybox(frame: (
    // title-color: red.darken(30%),
    border-color: blue.darken(10%),
    body-color: blue.lighten(95%) ), 
    // title: [*比热容*]
  )[
  
  *气化潜热* $lambda$：单位质量的液体，气化所需要吸收的热量，$"MJ"\/"kg"$。
  
  根据比热容$c_p$的定义，可以得到温度变化引起的潜热$"LE"$：
  
  $ "LE" = lambda delta(m_v) = lambda delta(rho_v) V $
]



其中，$delta(m_v)$是蒸发导致的水汽质量的变化，$"LE"$是蒸发所需的能量。

== 比热容

#showybox(frame: (
    // title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(95%) ), 
    // title: [*比热容*]
  )[
  *比热容* $c_p$：单位质量的物质升高1℃所需要的能量，$J \/ ("kg" ℃)$。
  
  根据比热容$c_p$的定义，可以得到温度变化引起的感热$H$：
  $ H = c_p rho V delta(t) $
]

#beamer_block([
  空气的比热容$c_p = 1103 J \/ ("kg" ℃)$，空气的密度$rho = 1.2 "kg" \/ m^3$。
  $1m^3$的空气，温度升高1℃，需要吸收多少能量？
])


