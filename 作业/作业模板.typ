#import "@preview/modern-cug-report:0.1.0": *

#counter(heading).update(2)
#let delta(x) = $Delta #x$

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "蒸散发的基本原理")

= 蒸散发的基本原理

== 蒸散发数据观测

中科院禹城综合试验站（简称禹城站）是黄河下游灌区冬小麦夏玉米农田生态
系统的典型试验站。冬小麦夏玉米农田生态系统是黄淮海平原最大的生态系统类型。

$ R_n - G = lambda E + H $

$ R_n - G = lambda E + H $

== 蒸散发的基本原理

#figure(
  image("../images/蒸散发/FluxMet_禹城_daily.svg", width: 100%),
  caption: [
    禹城站基本的通量与气象变量观测。

    $"GPP"$: 总光合速率，单位$"gC"\/m^2\/d$；
    $"LE"$: 潜热通量，单位$W\/m^2$；
    $T_a$：空气温度，单位℃；
    $R_s$：短波辐射，单位$W\/m^2$；
    $R_n$：净辐射，单位$W\/m^2$；
    $"Prcp"$: 降水，单位$"mm"$；
    $"VPD"$: 饱和水气压差，单位$"kPa"$；
    $"SM_1"$: 5cm土壤湿度，单位$%$；
    $"SM_2"$: 10cm土壤湿度，单位$%$；
    ]
) <fig1_yuchen>

