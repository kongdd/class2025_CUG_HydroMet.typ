// #import "@preview/modern-cug-report:0.1.0": *
#import "../typst/lib.typ": *
#counter(heading).update(0)
#show: (doc) => template(doc, 
  size: 13pt,
  footer: "",
  header: "项目研究计划")
#show math.equation: set text(12pt)
#show: p-indent
// #set par(
//   leading: 1em,
//   spacing: 1.24em, 
// )
#let delta(x) = $Delta #x$

// = 研究计划
= 研究背景

// === 观测频次偏差
// === 城市化偏差
#v(0.3em)

#figure(
  image("../images/土壤热通量/ls9_地表温度.jpg", width: 70%),
  caption: [
    基于Landsat 9卫星的武汉市2023年夏季平均地表温度。\
    https://code.earthengine.google.com/15e4ea013ba99ec9ed67145be670c0d8。\
    #v(0.3em)
  ]
) <fig_ls9_Tsoil>

