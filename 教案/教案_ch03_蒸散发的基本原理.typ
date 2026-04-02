// ===== 全局设置 =====
#set page(paper: "a4", margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm))

// ===== 封面 =====
#align(center)[
  #v(3cm)
  #image("./images/logo_cug.png", width: 7cm)

  #text(size: 24pt, font: "SimHei")[*教　师　教　案*]
]

#v(2cm)
#pad(left: 3cm)[
  #set text(size: 18pt, font: "SimHei")
  #grid(
    columns: (5em, 1fr),
    rows: 0.6cm,
    row-gutter: 0.8em,
    [*课程名称：*], [水文气象学],
    [*授课教师：*], [孔冬冬],
    [*职　　称：*], [副教授],
    [*授课题目：*], [第三章 蒸散发的基本原理],
    [*授课对象：*], [大三学生],
    [*授课时间：*], [4 学时],
  )
]

#pagebreak()
#counter(page).update(1)

#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "水文气象学", header: "")

// ===== 教案正文 =====
#align(center)[#text(size: 20pt, font: "SimHei")[*教　　案*]]
#v(0.8em)

*课程名称*：#underline[《水文气象学》]

#let l = 0.8cm

#set par(leading: 1.24em, spacing: 1.20em)

#show table: set block(breakable: true)
#set table.cell(inset: (y: 0.35cm))

#table(
  columns: (2.2cm, 3fr, 3fr, 3fr),
  align: (horizon + center, horizon + left),
  stroke: 0.5pt,
  [*授课教师*], [孔冬冬], [*所在单位*], [环境学院],
  [*课程类型*], [专业选修课], [*授课时间*], [4 学时],
  [*教学内容*], table.cell(colspan: 3)[第三章 蒸散发的基本原理],
  [*授课对象*], table.cell(colspan: 3)[环境学院 大气科学系 大三学生],
  [*教学目的\ 与要求*],
  table.cell(colspan: 3)[#align(left + top)[
      *教学目的：*

      1. 了解蒸散发通量的实地观测方法，能读懂禹城站逐日/逐时通量与气象变量图；

      2. 理解湿度计常数 $gamma$ 的推导过程，掌握干球温度与湿球温度的物理意义；

      3. 从扩散方程出发，掌握潜热通量与感热通量的推导过程，理解"阻力"概念的引出逻辑；

      4. 掌握 Penman（1948）三种蒸发情景的推导方法，理解均衡蒸发与 Penman 公式的本质区别；

      5. 理解 Monteith（1965）在 Penman 基础上引入气孔阻力 $r_s$ 的物理意义，掌握 Penman-Monteith 公式；

      6. 了解参考作物蒸散发（FAO98）的定义与应用，理解地表能量平衡对不同下垫面温度的解释（城市热岛 vs 绿洲效应）；

      7. 理解蒸散发与土壤水、地下水之间的相互反馈关系及蒸散三阶段。

      *教学要求：*

      能推导湿度计常数 $gamma$ 和修正湿度计常数 $gamma^*$；能从扩散方程积分得到潜热/感热阻力形式；能推导 Penman-Monteith 公式；理解能量平衡方程 $R_n - G = H + lambda E$ 在不同下垫面的物理含义。
    ]
  ],
  [*教学重点\ 与难点*],
  table.cell(colspan: 3)[
    *教学重点：*

    1. 湿度计常数 $gamma = (c_p P) / (epsilon lambda)$ 的物理推导（密闭容器能量平衡）；

    2. 潜热通量从扩散方程积分到阻力形式：$lambda E = (rho c_p delta(e)) / (gamma r_v)$；

    3. Penman（1948）三情景推导及关键结论：均衡蒸发 $lambda E = (Delta R_n) / (Delta + gamma^*)$；

    4. Monteith（1965）引入气孔阻力 $r_s$ 后的 Penman-Monteith 公式；

    5. 地表能量平衡 $R_n - G = H + lambda E$ 及 Bowen 比对地表温度的决定作用。

    *教学难点：*

    1. 从微分扩散方程到积分阻力形式的推导——需引导学生理解"常通量层"假设与牛顿-莱布尼茨公式的应用；

    2. Penman 图解法（图中 W、X、Y 三点的几何关系）与暴力求解法的等价性推导，尤其是 $"VPD" = D(Delta + gamma^*)$ 的证明；

    3. 修正湿度计常数 $gamma^* = gamma r_v / r_H$ 的引入——需理解水汽与热量传递阻力差异的物理背景。
  ],
  [*教学手段*],
  table.cell(colspan: 3)[
    利用 Typst 课件，结合禹城站真实通量/气象观测数据（日变化热图）直观呈现蒸散发的时间规律；通过图解法（Penman 1948 示意图）与暴力求解法对比，帮助学生从不同角度理解同一物理过程；采用"小试牛刀"随堂计算（潜热/感热换算、湿球温度）即时检验理解效果。
  ],
)


// 教学方案设计
#pagebreak()

#table(
  columns: (2.2cm, 1fr),
  align: (horizon + center, horizon + left),
  stroke: 0.5pt,
  table.cell(colspan: 2)[*教学方案设计*],
  table.cell(colspan: 2)[#align(left)[

      *思政：*

      以中科院禹城综合试验站的长期观测数据为切入点，引导学生认识野外定位观测在基础研究中的重要价值，培养长期坚守、踏实治学的科学精神。结合城市热岛与绿洲效应的对比，引导学生理解植被覆盖和水分对改善人居环境的重要作用，增强生态文明建设意识。通过 Penman（1948）和 Monteith（1965）两位科学家接力推进同一理论的故事，体会科学积累与传承的魅力。

      *问题导入（第1学时）：*

      - 展示禹城站逐日通量图，提问：潜热 LE 与净辐射 $R_n$ 的变化趋势为何高度相关？夏季 LE 为何远大于冬季？
      - 提问：$R_n = 100 W m^(-2)$，如果能量全部变成感热，空气会升温多少度？为什么实际中空气升温只有约 10℃？能量都去哪了？

      *教学安排：*

      *第1学时（45 min）——蒸散发观测与物理基础*

      1. （10 min）蒸散发观测：禹城站通量观测系统介绍；解读逐日通量（GPP、LE、$R_n$、VPD、SM）及逐时热图，建立"蒸散发是能量与水分耦合过程"的直观认识。

      2. （15 min）物理基础：
        - 气化潜热 $lambda = 2.5 "MJ/kg"$，潜热通量 $"LE" = lambda Delta(rho_v) V$；
        - 比热容 $c_p$，感热 $H = c_p rho V Delta(T)$；
        - 随堂计算：$R_n = 100 W m^(-2)$ 全部转为潜热对应的日蒸发量；全部转为感热对应的升温幅度（引出"空气是小透明"的结论）。

      3. （20 min）湿度计常数：
        - 密闭容器模型推导：$lambda E + H = 0$，引出 $delta(e) = -gamma delta(T)$，推导 $gamma = (c_p P) / (epsilon lambda)$；
        - 干球温度与湿球温度的定义与物理解释（百叶箱实验场景）；
        - 图解法：在 $e_s$–$T$ 图中，从 X 点沿斜率 $-gamma$ 直线找到湿球温度对应的 Y 点。

      *第2学时（45 min）——通量推导*

      1. （20 min）潜热通量推导：
        - 从分子扩散方程 $E = -D pdv(rho_v, z)$ 出发；
        - 引入"常通量层"假设，从 $z_1$ 到 $z_2$ 积分，推导 $lambda E = (rho c_p delta(e)) / (gamma r_v)$；
        - 重点讲解积分的三层含义：梯度→差值（可测性）、引出阻力概念、常通量层假设；
        - 比湿形式与水汽压形式的等价推导。

      2. （15 min）感热通量推导：
        - 从热传导方程 $H = -k rho c_p pdv(T, z)$ 出发，类比潜热推导；
        - 得到 $H = (rho c_p delta(T)) / r_H$，强调 $rho c_p$ 的单位转换作用。

      3. （10 min）修正湿度计常数：
        - 将阻力形式代入 $lambda E + H = 0$，推导 $gamma^* = gamma r_v / r_H$；
        - 当 $r_v = r_H$ 时，$gamma^* = gamma$（自由水面情形）；引入气孔阻力后 $gamma^* > gamma$。

      *第3学时（45 min）——Penman（1948）潜在蒸散发*

      1. （5 min）回顾：稳定状态下，湿表面温度 $T_w$ 未知但满足 $e_w = "es"(T_w)$，联立感热与潜热方程求解。

      2. （25 min）三种情景推导（结合 Penman 1948 示意图中 W、X、Y 三点的几何关系）：
        - 情景 a（$R_n = 0$，空气干燥）：湿球温度情景，$lambda E = -H$；
        - 情景 b（$R_n > 0$，空气饱和）：均衡蒸发 $lambda E = (Delta R_n) / (Delta + gamma^*)$；
        - 情景 c（$R_n > 0$，空气不饱和）：Penman 1948 公式 $lambda E = (Delta R_n) / (Delta + gamma^*) + (rho c_p "VPD" \/ r_H) / (Delta + gamma^*)$；
        - 用"暴力求解法"（消去 $T_w$）重新推导情景 c，验证与图解法等价（关键：$"VPD" = D(Delta + gamma^*)$）。

      3. （15 min）Monteith（1965）叶片/冠层蒸发：
        - 湿表面从水面转移到叶片内部，水汽传输路径新增气孔阻力 $r_s$；
        - 推导 $gamma^* = gamma (r_v + r_s) / r_H$，代入 Penman 框架得到 Penman-Monteith 公式；
        - 物理意义：$r_s = 0$（充分供水水面），$r_s > 0$（有气孔控制的植被）。

      *第4学时（45 min）——参考作物蒸发、实际蒸散发与能量平衡*

      1. （10 min）参考作物蒸散发（FAO98）：
        - 参考草地定义（高度 0.12 m，$r_s = 70 s\/m$，反射率 0.23）；
        - FAO Penman-Monteith 公式简化形式及各参数计算（$e_s$、$e_a$、$Delta$、$gamma$）；
        - 与实际蒸散发 $"ET"_a <= "ET"_0$ 的关系。

      2. （15 min）实际蒸散发与蒸散三阶段：
        - 土壤水对蒸散发的限制：蒸散三阶段（$theta_f -> theta_c -> theta_w$）示意图讲解；
        - 蒸散发与土壤水的双向反馈：蒸散抽取土壤水，土壤水限制蒸散；
        - 案例：蒸散发日内信号与地下水位、土壤湿度的交互（USGS 观测案例）。

      3. （15 min）地表能量平衡与综合小结：
        - 能量平衡方程 $R_n - G = H + lambda E$，Bowen 比 $beta = H \/ lambda E$；
        - 案例对比：城市热岛（$lambda E$ 小 → $H$ 大 → 温度高）vs 绿洲效应（$lambda E$ 大 → $H$ 可为负）；
        - 感热/潜热分配比例随温度变化（Bowen 系数图）；
        - 综合小结：从物理基础 → 通量 → Penman → PM → FAO98 → 实际蒸散发的完整推导链条回顾；布置课后思考题。

    ]
  ],
  [*参考资料*],
  [
    1. 课件：《第三章 蒸散发的基本原理》（Typst格式）

    2. Penman, H.L. (1948). Natural evaporation from open water, bare soil and grass. *Proceedings of the Royal Society A*, 193, 120–145.

    3. Monteith, J.L. (1965). Evaporation and environment. *Symposia of the Society for Experimental Biology*, 19, 205–234.

    4. Allen, R.G., et al. (1998). FAO Irrigation and Drainage Paper No. 56.

    5. Monteith & Unsworth (2013). *Principles of Environmental Physics* (4th ed.). 图3.3、3.4、13.4。

    6. 禹城站通量数据：中科院禹城综合试验站（黄河下游冬小麦夏玉米农田）。
  ],
  [*课后小结*],
  [
    本章构建了蒸散发的完整理论体系：从密闭容器能量平衡推导 $gamma$，到积分扩散方程建立通量阻力框架，再到 Penman（1948）和 Monteith（1965）依次建立水面蒸发与植被蒸腾公式，最终与土壤水、地下水及能量平衡相联系。核心公式：$gamma = (c_p P)/(epsilon lambda)$、$lambda E = (rho c_p delta(e))/(gamma r_v)$、Penman-Monteith 公式。能量平衡 $R_n - G = H + lambda E$ 是理解下垫面温度差异（热岛/绿洲）的基础框架。
  ],
)
