#import "@local/modern-cug-report:0.1.3": *
#import "@preview/cetz:0.3.1": canvas, draw
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

#set par(leading: 1.24em, spacing: 1.14em)

#let PE = "PE"
#let AU = "AU"

= 1 核心思想
== 1.1 背景
- *起源*：1973年，河海大学赵人俊教授团队。
- *适用*：*湿润、半湿润地区*（南方流域为主）。
- *核心*：
  - *蓄满产流*（Saturation Excess）：土满了，才产流。
  - *分散产流，总汇流*：分单元计算，最后叠加。

= 2 四大计算模块
模型遵循水循环逻辑，分为四个步骤：
1. *蒸散发*（Evapotranspiration）
2. *产流*（Runoff Generation）
3. *水源划分*（Source Separation）
4. *汇流*（Flow Concentration）

== 2.1 模块一：三层蒸散发
将土壤分为上、下、深三层，依次由易到难蒸发。
- *逻辑*：
  1. 降雨 $P$ 优先满足蒸发能力 $E_p$。
  2. 若 $P < E_p$，不足部分由土壤水补充。
  3. *顺序*：上层 $->$ 下层 $->$ 深层。
- *参数*：上层容量 $W_"UM"$，下层 $W_"LM"$，深层 $W_"DM"$，深层系数 $C$。

```julia
# 核心逻辑伪代码
E = P
E_rem = Ep - P
if E_rem > 0:
    E += min(WU, E_rem)         # 上层贡献
    E += E_rem_new * (WL / WLM) # 下层贡献 (线性简化)
```

== 2.2 模块二：蓄满产流
*核心假设*：降雨 $P$ 扣除蒸发 $E$ 后，净雨 $PE$ 必须先填满包气带缺水量 $Delta W$，剩余部分才形成径流 $R$。
$ R = P - E - Delta W $

=== 蓄水容量分布曲线
由于流域土壤厚薄不均，引入抛物线型分布曲线描述这种*空间不均匀性*。
- *曲线公式*：$alpha = 1 - (1 - W'_"M" / W_"MM")^B$
- *关键参数*：
  - $W_"M"$：平均蓄水容量（最敏感参数）。
  - $B$：分布形状指数（反映不均匀程度）。


== 2.4 模块四：汇流计算
将三种水源转化为出口流量。
1. *坡地汇流*（子流域内）：
  - 地表水 $->$ 单位线 (Unit Hydrograph)。
  - 壤中水、地下水 $->$ 线性水库 (Linear Reservoir)。
2. *河网汇流*（子流域间）：
  - 滞后演算法 (Lag and Route)：$Q_"out"(t) = C_S Q_"in"(t - L) + (1 - C_S) Q_"out"(t - 1)$



= 3 参数总结 (15个)
#figure(
  table(
    columns: (auto, auto, 2fr),
    inset: 8pt,
    align: horizon,
    table.header([*模块*], [*参数*], [*物理意义*]),
    table.cell(rowspan: 4)[蒸散发], [$W_"UM"$, $W_"LM"$, $W_"DM"$], [上/下/深层蓄水容量],
    [$C$], [深层蒸发系数],
    table.cell(rowspan: 2)[产流], [$W_"M"$], [*平均蓄水容量* (决定产流总量)],
    [$B$], [分布曲线指数 (产流面积)],
    table.cell(rowspan: 4)[水源], [$S_"M"$], [自由水蓄水容量],
    [$"EX"$], [自由水分布指数],
    [$K_"I"$, $K_"G"$], [壤中/地下出流系数],
    table.cell(rowspan: 3)[汇流], [$K_"S"$, $K_"I"$, $K_"G"$], [消退系数 (汇流速度)],
    table.cell(rowspan: 2)[河道], [$L$], [滞后时间],
    [$C_S$], [河道坦化系数],
  ),
  caption: [新安江模型参数一览],
) <tbl:params>
