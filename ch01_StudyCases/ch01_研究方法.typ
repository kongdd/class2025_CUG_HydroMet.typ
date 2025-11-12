#import "@local/modern-cug-report:0.1.3": *

// #let scale = 0.6
// #set page(
//   paper: "a4",
//   width: 16in * scale,
//   height: 9in * scale,
//   margin: 0.2in,
// )
#show: doc => template(doc, size-config: (raw: 9pt), footer: "CUG水文气象学2025", header: "第1章 研究方法")

= 第1章 水文气象学研究方法 // <!-- omit in toc -->

#outline(
  title: "目录",
  depth: 3,
  indent: 1.5em,
)

#pagebreak()

= 1 AI学习法

#h(2em)
抛弃word的原因：AI难以读取word内容，难以操作word插入内容。而typst作为纯文本标记语言，AI可以轻松读取和编辑内容，能够直接插入文本、代码和公式，同时支持版本控制，非常适合与AI协作编写技术文档。

#h(2em)
AI能看到我们在编辑器中选择了哪些内容，必要时可读取上下文，能理解typst语法，并生成typst公式和文本。
能帮我们解释我们看不懂的公式，能帮我补全相关章节的理论内容，....。

#figure(
  image("Figures/Claude_01.png", width: 70%),
  caption: [
    Claude交互编辑过程。
  ],
) <fig_>

== 1.1 安装方法

- Claude付费用户
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install nodejs
npm install -g @anthropic-ai/claude-code
```

- 国产大模型智普
```powershell
code $profile
# 请私信我索要API
$env:ANTHROPIC_AUTH_TOKEN = "78ebe840d4c24f1b8387b5a1384ed747.jVlWgUA2MsJrg"
$env:ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
$env:API_TIMEOUT_MS = "3000000"
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1
```

= 2 干旱的主要研究方法

水量平衡是分析干旱的基本框架：

$ P - E - R = Delta S + "Human" $ <eq_water_balance>

其中：
- $P$：降水量 (mm)
- $E$：蒸散发 (mm)
- $R$：径流 (mm)
- $Delta S$：储水量变化 (mm)
- $"Human"$：人类用水活动 (mm)

#box-red[
  #set text(size: 12pt)
  #set par(leading: 1em, spacing: 1.1em)

  人类活动对水量平衡的影响

  *1. 人类用水活动*

  - 生活用水：R
  - 农业用水：P（雨养）、 R（灌溉）、GW（北方干旱区）
  - 工业用水：R
  - 生态用水：P（陆表植被）、R（河道、湖泊水生生物）
  - 航运：R
  - 水力发电：R

  *2. 水力工程*
  - 水库调蓄：调节径流，影响下游水量（三峡、小浪底）
  - 引水工程：改变流域水量分布（南水北调中线，丹江口水库）
  - 水力发电
  - 提防
  - 蓄滞洪区
]


== 2.1 干旱的分类

根据影响领域和表现形式，干旱可分为：

1. *气象干旱*：降水量持续低于正常值
2. *水文干旱*：河流、湖泊、地下水等水资源量减少
3. *农业干旱*：土壤水分不足以满足作物生长需求
4. *社会经济干旱*：供水无法满足人类社会经济需求

#beamer-block([
  *思考：*不同类型的干旱之间有何联系？哪种类型的干旱最先发生？
])



= 3 洪水过程

== 3.1 研究目的

能够提前预知洪水信息：包括洪峰、洪量、峰现时间。

#figure(
  image("Figures/Figure1_孤山_hour_Q&P_V4.pdf", width: 90%),
  caption: [
    十堰市孤山水文站新安江模型水文预报。
  ],
) <fig_>

#figure(
  image("Figures/研究背景_洪涝.png", width: 90%),
  caption: [
    研究背景：我国洪涝灾害频发。
  ],
) <fig_>




== 3.2 基本概念

#v(-0.9em)

=== 3.2.1 水文循环过程

#figure(
  image("Figures/水文循环.png", width: 100%),
  caption: [
    水文循环示意图（https://www.britannica.com/science/water-cycle
    ）。
  ],
) <fig_>

#figure(
  image("Figures/地下水主要过程.png", width: 100%),
  caption: [
    地下水主要过程示意图，https://pressbooks.openeducationalberta.ca/planetearth/chapter/water-within-the-geosphere-groundwater/。
  ],
) <fig_>

=== 3.2.2 流域

分水线所形成的闭合区域，分水线一般为提防、山脊等高地。

// #figure(
//   image("Figures/孤山流域.png", width: 90%),
//   caption: [
//     孤山流域子流域编号、河网等级、与河网结构。
//   ]
// ) <fig_>

#figure(
  image("Figures/流域提取.png", width: 100%),
  caption: [
    流域与流域提取方法。
  ],
) <fig_>

=== 3.2.3 流域面积

哪些区域的降水会从该出水口流出？是影响流量、洪峰大小的重要因素。

- 水文站：代表的其控制面积（流域）上的水资源量；
- 气象站：代表的是气象站周围的气象要素。

#figure(
  image("Figures/水文站控制_01.png", width: 60%),
  caption: [
    水文站控制流域面积示意图。
  ],
) <fig_>

#figure(
  image("Figures/湖北三市_中小流域.png", width: 90%),
  caption: [
    湖北三市典型中小流域。
  ],
) <fig_>

=== 3.2.4 汇流时间

降雨洪水从流域最远处汇集到出口的时间，反映流域水文响应速度。

#v(-0.8em)
#figure(
  image("Figures/降雨径流滞后_gg.layers.png", height: 6.5cm),
  caption: [
    降雨径流滞后时间。
  ],
) <fig_>

#v(-0.8em)
#figure(
  image("Figures/降雨径流滞后时间.png", width: 80%),
  caption: [
    湖北省典型中小河流降雨径流滞后时间。
  ],
) <fig_>


=== 3.2.5 地下面属性与空间异质性

#figure(
  image("Figures/空间异质性.png", width: 70%),
  caption: [
    气象驱动与下垫面属性空间异质性。
  ],
) <fig_>

#figure(
  image("Figures/城区不透水界面.png", width: 70%),
  caption: [
    城市不透水界面的对饱和水力传导系数的影响。
  ],
) <fig_>


== 3.3 曼宁公式

#beamer-block[曼宁公式，#Blue[用于研究地表产流]，包括坡面与河道径流。]

$ V = (R_h^(2/3)) / n S^(1/2), quad R_h = A/P $ <eq_manning_v>

$ Q = V A = (A^(5/3)) / (n P^(2/3)) S^(1/2) $ <eq_manning_q>

其中$V$为流速，流体在断面上的平均速度，单位 $m\/s$。常见范围：河道 0.1–3 m/s。
$Q$是流量，过断面单位时间体积流量 $Q = V times A$，单位 $m^3\/s$。


#box-blue[
  #set text(size: 11pt)
  #set par(leading: 1.2em, spacing: 1.1em)
  - *$R_h$ 水力半径*：过水面积与湿周比值 $R_h = A\/P$，单位 $m$。代表流体"有效水深"，与流速、摩阻相关。

  - *$n$ 曼宁糙率系数*：描述河道粗糙程度导致的阻力，单位 $s\/m^(1/3)$。典型值：混凝土 0.011，砂砾河 0.03–0.05，天然泥沙河或多植被 0.05–0.1。

  - *$S$ 水力坡度*：沿流向的能量坡度或床面坡，单位无量纲或百分比。平缓河道 $10^(-4)$–$10^(-3)$；山区河道 $10^(-2)$ 以上。

  - *$A$ 过水断面面积*：水流占据的横断面面积，单位 $m^2$。矩形断面：$A = b times y$（$b$ 宽，$y$ 水深）。

  - *$P$ 湿周*：水与边界接触的周长（仅湿着部分），单位 $m$。矩形断面：$P = b + 2y$。
]

#figure(
  image("Figures/manning_n.png", width: 40%),
  caption: [
    典型下垫面的曼宁糙率系数$n$值参考。
  ],
) <fig_>

=== 3.3.1 坡面汇流

对于坡面径流，$A = h b$，$P = 2h + b$。其中$b$为宽，$h$为水深，$b >> h$。

$ R = (h b) / (2h + b) = h / (1 + 2h/b) approx h $


==== 圣维南方程 // <!-- omit in toc -->

#let delta(x) = $Delta #x$

该方程由法国科学家圣维南在1871年提出。

#beamer-block[
  对于一个微小距离$delta(x)$，$W = A times Delta X$；对于一个固定点$x$，两个时刻$t + delta(t)$，蓄水量变化为$[A(x, t + delta(t)) - A(x, t)] delta(x)$。
]

根据连续性原理

$
  (I - O) delta(t) + q = W_2 - W_1 \
  [Q(x, t) - Q(x + delta(x), t)] delta(t) + W_"part" = [A(x, t + delta(t)) - A(x, t)] delta(x) \
  [ Q(x + delta(x), t) - Q(x, t)] / delta(x) + [A(x, t + delta(t)) - A(x, t)] / delta(t) = W_"part" / (delta(x) delta(t))
$

- $I$：入流$m^3\/s$，$Q(x, t)$
- $O$: 出流$m^3\/s$，$Q(x + delta(x), t)$
- $A(x, t)$: 河道过水断面平均面积$m^2$
- $W_1$: $t_1$时刻河道的水储量$m^3$，$A(x, t) delta(x)$
- $W_2$: $t_2$时刻河道的水储量$m^3$，$A(x, t + delta(t)) delta(x)$
- $W_"part"$: *区间径流*对应的水量，$m^3$

令$q = W_"part" / (delta(x) delta(t))$，可得
$ pdv(Q, x) + pdv(A, t) = q $

*该方程的作用*：已知入流$Q(x, t)$与河道断面信息$A(x, t)、A(x, t + delta(t))$，求解出流$Q(x + delta(x), t)$。

=== 3.3.2 河道汇流

#figure(
  image("Figures/河道断面.png", width: 90%),
  caption: [
    河道断面测量。
  ],
) <fig_>


=== 3.3.3 下渗

净雨到达地表之后，分为三部分：地表积水、地表产流与下渗。

地表产流分为三阶段：

- 不产流（$h > "ponding"_min$）：填洼

- 曼宁公式产流（$"ponding"_min < h < "ponding"_max$）：与水深呈非线性关系

- 饱和产流（$h > "ponding"_max$）：与水深呈线性关系，全部产流

```julia
z_water_cm <= h_pond_min && return T(0.0)
if z_water_cm <= h_pond_max
  h_excess = (z_water_cm - h_pond_min) / 100.0  # [cm] → [m]
  drainage_rate = c_inf * h_excess^(5 / 3)   # [cm/h]
else
  h_excess_max = (h_pond_max - h_pond_min) / 100.0  # [cm] → [m]
  drainage_rate = c_inf * h_excess_max^(5 / 3)      # [cm/h], manning
  drainage_rate += (z_water_cm - h_pond_max) / dt_h # [cm/h], spillover
end
```

// 下渗分为两种情景：
地表无积水情景下：

$P > "inf"_"potential"$：地表产生积水

$P < "inf"_"potential"$：全部下渗。

有积水情景下：
```julia
# 有地表积水: 总水量 = 积水 + 降雨
water_total = z_water + P_cm * dt_h  # [cm]

# 计算入渗潜力 [cm h-1]
inf_potential = infiltration_potential(soil, ps, water_total) # [cm h-1]

# 3. 计算地表径流 (基于总水量)
Rs_rate = cal_drainage(ponding, water_total, dt_h)  # [cm h-1]
Rs = Rs_rate * dt_h  # [cm]

# 4. 可供入渗的水量 = 总水量 - 径流
water_available = water_total - Rs  # [cm]

# 5. 实际入渗 = min(潜力, 可用量)
inf = min(inf_potential * dt_h, water_available)  # [cm]

# 6. 更新地表积水
z_water_new = water_available - inf  # [cm]
```

== 3.4 达西定律

#figure(
  image("Figures/土壤水运动.png", width: 100%),
  caption: [
    基于达西定律的土壤水运动。
  ],
) <fig_>

#figure(
  image("Figures/地下水运动.png", width: 100%),
  caption: [
    基于达西定律的地下水运动（Fan 2007, JGR-A）
  ],
) <fig_>

= 4 陆面植被过程

#figure(
  image("Figures/SPAC连续体.png", width: 80%),
  caption: [
    土壤—植被—大气交互影响示意图。
  ],
) <fig_>

== 4.1 植被对水文过程的影响

1. 冠层截留蒸发

2. 植被蒸腾

3. 根系抽水，影响SM与GW，植被水力再分配

4. 根茎叶水力连续体

5. 影响地表粗糙度（曼宁粗糙度$n$），影响地表汇流过程

6. 影响地表下渗速率（草地与不透水界面）

7. 影响地表反照率、影响地表温度，能量平衡。

#figure(
  image("Figures/ls8_Tland.png", width: 12cm),
  caption: [
    Landsat8 地表温度。
  ],
) <fig_>

#figure(
  image("Figures/ls8_Veg_Tland.png", width: 12cm),
  caption: [
    植被对地表温度的影响。
  ],
) <fig_>

== 4.2 水文过程对植被的影响

1. 干旱

2. 洪涝

#figure(
  image("Figures/20200720-王家坝.png", width: 100%),
  caption: [
    2020年7月20日王家坝蓄滞洪区开闸泄洪。
  ],
) <fig_>


#figure(
  image("Figures/20230730-河北保定.png", width: 100%),
  caption: [
    2023年7月30日河北保定市区洪涝。
  ],
) <fig_>

= 小结 // <!-- omit in toc -->

- 如何感知干旱的发生，干旱的表现。几种不同类型的干旱，在水量平衡公式中如何体现？干旱的演进过程

- 洪水的研究方法，曼宁公式、圣维南方程、达西定律（地表产流、坡面与河道汇流、土壤水运动、地下水运动）

- 水文过程对植被的影响，以及植被对水文过程的反馈。
