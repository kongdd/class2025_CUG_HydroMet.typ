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
    [*授课题目：*], [第六章 土壤水运动],
    [*授课对象：*], [大三学生],
    [*授课时间：*], [2 学时],
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
  [*课程类型*], [专业选修课], [*授课时间*], [2 学时],
  [*教学内容*], table.cell(colspan: 3)[第六章 土壤水运动],
  [*授课对象*], table.cell(colspan: 3)[环境学院 大气科学系 大三学生],
  [*教学目的\ 与要求*],
  table.cell(colspan: 3)[#align(left + top)[
      *教学目的：*

      1. 理解土壤水势 $psi$ 的物理含义——毛管力、重力势的叠加，掌握饱和/非饱和条件下 $psi$ 的变化规律；

      2. 掌握达西定律的广义形式 $q = -K pdv((psi + z), z)$，理解水力传导系数 $K$ 随土壤含水量变化的非线性特征；

      3. 理解 Richards 方程的推导过程——达西定律与连续性方程的结合，掌握其离散化形式；

      4. 了解土壤水运动的边界条件设置：上边界（下渗量/表层水势）与下边界（重力排水/地下水交互 Zeng2009 方案）；

      5. 了解用 Julia 语言调用 DifferentialEquations.jl 求解 Richards 方程的基本流程，建立"物理方程→数值求解"的完整认知链条。

      *教学要求：*

      能写出达西定律和 Richards 方程；理解均衡水势 $psi_E$ 的物理意义；能读懂 Julia 求解代码的主要逻辑；理解本章与蒸散发（ch03）、土壤热通量（ch05）的耦合关系。
    ]
  ],
  [*教学重点\ 与难点*],
  table.cell(colspan: 3)[
    *教学重点：*

    1. 达西定律广义形式中总水势 $psi + z$ 的推导（毛管水势 + 重力势）；

    2. Richards 方程离散化：层间流量 $q_i = -K_(i+1/2) (psi_(i+1) + z_(i+1) - psi_i - z_i) / (z_(i+1) - z_i)$；

    3. 下边界与地下水交互方案（Zeng2009）——均衡水势 $psi_E$ 概念与 $q = -K pdv((psi - psi_E), z)$ 的物理含义；

    4. Richards 方程与 ODE 求解框架 $d u \/ d t = f(u, p, t)$ 的对应关系。

    *教学难点：*

    1. 水力传导系数 $K$ 的非线性——$K$ 随 $theta$ 变化几个数量级，使 Richards 方程成为强非线性方程，是数值求解困难的根本原因；

    2. 均衡水势 $psi_E$ 的积分推导——需理解"$q = 0$ 时各层总势能相等"这一均衡假设；

    3. 边界条件的两类形式（第一类：给定状态 $psi_0$；第二类：给定通量 $q_0$）及其在上下边界的不同应用场景。
  ],
  [*教学手段*],
  table.cell(colspan: 3)[
    利用 Typst 课件，结合土壤分层与土壤水运动示意图（Bonan 2019）；通过 Julia 代码现场演示 Richards 方程数值求解，直观展示土壤水在降雨入渗/蒸散发提取过程中的剖面变化；与 ch03 蒸散发和 ch05 热通量联立，强调多过程耦合的模拟思路。
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

      以农业灌溉节水为切入点，引导学生理解精确掌握土壤水运动规律对粮食安全的重要意义。结合我国北方干旱半干旱地区地下水超采问题，引导学生认识土壤水—地下水交互研究在水资源可持续利用中的现实价值，培养服务国家农业与水资源战略的责任意识。

      *问题导入（第1学时）：*

      - 提问：浇水后，水是如何在土壤中运动的？为什么湿润锋会逐渐向下推进而不是瞬间到达深层？
      - 提问：达西定律描述的是地下水运动，能否直接用于非饱和土壤？关键的区别是什么？（引出土壤水势与 $K(theta)$ 非线性）

      *教学安排：*

      *第1学时（45 min）——达西定律与 Richards 方程*

      1. （10 min）章节定位与背景：
        - 回顾 ch03 蒸散发中的根系吸水项 $e_i$、ch05 能量平衡中的土壤水对 $kappa$ 和 $c_v$ 的影响；
        - 土壤水剖面示意图（Bonan 图）：饱和带、非饱和带、根区的位置关系。

      2. （15 min）达西定律广义形式：
        - 土壤水势 $psi$：饱和时 $psi = 0$，非饱和时 $psi < 0$（毛管吸力为负值）；
        - 总水势 = 毛管水势 + 重力势：$Phi = psi + z$；
        - 达西定律：$q = -K pdv((psi + z), z)$，$K$ 为非饱和水力传导系数（$"cm" dot h^(-1)$）；
        - $K(theta)$ 非线性：土壤由饱和变干时，$K$ 可降低 5～8 个数量级（强非线性的来源）。

      3. （20 min）Richards 方程推导与离散化：
        - 连续性方程：$(Delta theta_i) / (Delta t) Delta z_i = -q_(i-1) + q_i - e_i$；
        - 层间界面水力传导系数：$K_(i+1/2) = (K_i + K_(i+1)) / 2$（调和平均）；
        - 离散流量：$q_i = -K_(i+1/2) (psi_(i+1) + z_(i+1) - psi_i - z_i) / (z_(i+1) - z_i)$；
        - 整理为 $d theta \/ d t = f(theta, p, t)$ 的 ODE 形式，对应 Julia 求解框架。

      *第2学时（45 min）——边界条件与数值求解*

      1. （15 min）边界条件设置：
        - 上边界（第1层）两类：第一类（已知 $psi_0$）、第二类（已知下渗通量 $q_0$）；
        - 下边界——重力排水：$q_N = -K_N$（假设底部为自由排水）；
        - 下边界——与地下水交互（Zeng2009）：
          均衡水势定义（$q = 0$ 时各层总势相等）：$psi_E + z = C$；
          修正流量：$q = -K pdv((psi - psi_E), z)$，体现地下水对土壤水的补给与排泄。

      2. （20 min）Julia 数值求解演示：
        - ODE 框架：$d u \/ d t = f(u, p, t)$，$u$ 为各层 $theta$ 向量；
        - 5行代码求解简单 ODE 示例（$d u \/ d t = 1.01 u$）验证框架；
        - `RichardsEquation` 函数：调用 `soil_WaterFlux!` 计算各层流量，更新 $d theta$；
        - 演示降雨入渗场景：表层 $theta$ 迅速升高，湿润锋逐步下移；
        - 演示蒸散发抽取场景：根区 $theta$ 降低，干旱胁迫函数触发。

      3. （10 min）综合小结与多过程耦合：
        - 梳理：达西定律 → Richards 方程 → ODE 离散 → Julia 求解的完整链条；
        - 土壤水与蒸散发（ch03 根系吸水 $e_i$）、土壤温度（ch05 $kappa(theta)$、$c_v(theta)$）的双向耦合；
        - 课后思考：地下水位升高时，均衡水势如何变化？对土壤水剖面有何影响？

    ]
  ],
  [*参考资料*],
  [
    1. 课件：《第六章 土壤水运动求解》（Typst格式）

    2. Bonan, G.B. (2019). *Climate Change and Terrestrial Ecosystem Modeling*. Cambridge University Press. Chapter 8.

    3. Zeng, X., & Decker, M. (2009). Improving the numerical solution of soil moisture–based Richards equation for land models with a deep or shallow water table. *Journal of Hydrometeorology*, 10(1), 308–319.

    4. DifferentialEquations.jl 文档：https://docs.sciml.ai/DiffEqDocs/stable/

    5. Richards, L.A. (1931). Capillary conduction of liquids through porous mediums. *Physics*, 1(5), 318–333.
  ],
  [*课后小结*],
  [
    本章建立了土壤水运动的完整数值模拟框架：从达西定律的广义形式出发，推导 Richards 方程，设置上下边界条件（含 Zeng2009 地下水交互方案），最终转化为 ODE 问题用 Julia 求解。核心难点在于 $K(theta)$ 的强非线性。本章是陆面过程模型（CLM、VIC）土壤水模块的理论基础，与蒸散发、土壤温度模块紧密耦合，共同构成完整的陆面水热传输体系。
  ],
)
