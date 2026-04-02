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
    [*授课题目：*], [第五章 土壤热通量],
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
  [*教学内容*], table.cell(colspan: 3)[第五章 土壤热通量],
  [*授课对象*], table.cell(colspan: 3)[环境学院 大气科学系 大三学生],
  [*教学目的\ 与要求*],
  table.cell(colspan: 3)[#align(left + top)[
      *教学目的：*

      1. 了解土壤温度的实际观测规律，能解读中国地质大学气象站逐小时土壤温度分层图；

      2. 掌握热传导系数 $kappa$、体积热容量 $c_v$ 和热扩散率 $kappa\/c_v$ 的物理含义及典型量值，能用其解释生活现象；

      3. 理解傅里叶热传导定律，能从连续性方程推导一维热传导方程；

      4. 了解 de Vries（1963）土壤热参数体系，理解土壤含水量对热参数的影响；

      5. 掌握土壤热通量在地表能量平衡方程中的作用，理解联立能量平衡与净辐射方程求解地表温度 $T_s$ 的思路；

      6. 了解数值方法（Julia ODE 求解器）在土壤热传导问题中的应用，建立"物理方程→数值求解"的完整概念。

      *教学要求：*

      能写出傅里叶热传导定律 $F = -kappa pdv(T, z)$ 及热传导方程 $c_v pdv(T, t) = kappa pdv(T, z, 2)$；能说明各热参数的物理含义；理解能量平衡 $R_n - G = H + lambda E$ 中土壤热通量 $G$ 的量级与作用；了解数值求解流程。
    ]
  ],
  [*教学重点\ 与难点*],
  table.cell(colspan: 3)[
    *教学重点：*

    1. 三个热参数的定义与关系：热传导系数 $kappa$（W/m/K）、体积热容量 $c_v = rho c_p$（MJ/m³/K）、热扩散率 $a = kappa\/c_v$（m²/s）；

    2. 傅里叶热传导定律 $F = -kappa pdv(T, z)$ 及其物理含义（负号、梯度方向）；

    3. 由能量守恒推导热传导方程 $c_v pdv(T, t) = kappa pdv(T, z, 2)$；

    4. 土壤热通量在能量平衡方程 $R_n - G = H + lambda E$ 中的地位；

    5. 联立能量平衡方程与净辐射公式求解地表温度 $T_s$ 的方法。

    *教学难点：*

    1. 从连续性方程推导热传导方程——需引导学生理解微元体的热量收支平衡与 Taylor 展开的物理意义；

    2. 热扩散率 $a = kappa\/c_v$ 的物理解释：热扩散率越大，温度波传播越快，但热容量越大的介质"抵抗"温度变化越强；干土与湿土热性质差异的量级认识；

    3. 地表温度的耦合求解——$T_s$ 同时影响感热、潜热、净长波辐射，需建立"方程组→迭代/数值求解"的思维框架。
  ],
  [*教学手段*],
  table.cell(colspan: 3)[
    展示中国地质大学气象站2023年6月逐小时土壤温度热图，直观呈现"表层剧烈波动、深层趋于稳定"的特征，激发学生对物理机制的探究兴趣；通过日常生活案例（沙滩烫脚、地窖储粮、地铁恒温）与传统农谚联系物理概念；利用 Julia 代码（5行 ODE 求解器）展示从物理方程到数值解的完整流程，体现计算思维在地学中的应用。
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

      以农谚"清明前后，种瓜点豆"引入——农民千百年来根据地温经验判断播种时机，体现了中华农耕文明对自然规律的深刻认识；以地窖储粮、冰窖藏冰等传统技术引导学生感受中国古人对土壤热性质的朴素利用，培养文化自信。联系当前冻土消融与碳排放的气候变化议题：多年冻土区储存了大量有机碳，冻土消融导致碳释放并进一步加剧变暖，形成正反馈——引导学生认识土壤热过程在全球变化研究中的重要地位，增强应对气候变化的责任感。

      *问题导入（第1学时）：*

      - 展示中国地质大学气象站2023年6月逐小时多层土壤温度图：表层 $T_(s,0)$ 日内变幅超50℃，80 cm 以下几乎是一条直线。提问：为什么越深温度越稳定？热量是如何向下传递的？
      - 生活追问：夏日沙滩为何烫脚？地窖为何冬暖夏凉？地铁隧道为何四季恒温？

      *教学安排：*

      *第1学时（45 min）——物理学基础与基本原理*

      1. （10 min）开篇：观测现象与应用案例

        - 展示 CUG 气象站土壤温度热图，引导学生描述分层特征；
        - 梳理应用背景：城市热岛（地表能量平衡）、农业气象（种子萌发最适地温）、冻土研究（碳循环反馈）、地源热泵（地热资源利用）、考古勘探（异常土壤热信号）；
        - 以沙滩、地窖、地铁隧道、农谚"清明前后种瓜点豆"串联生活体验，引出三个核心热参数。

      2. （20 min）物理学基础：三个热参数

        - *热传导系数* $kappa$（W/m/K）：描述介质传热能力。典型值：铜 385、铝 205、玻璃 1.0、木头 0.15、泡沫 0.03、空气 0.025。以羽绒服保暖原理（静止空气 $kappa$ 极低）说明其工程意义。

        - *体积热容量* $c_v = rho c_p$（MJ/m³/K）：描述单位体积介质升温1K所需热量。典型值：水 4.19、湿土 ~3.0、干土 ~1.5、空气 0.0012。以海边与沙漠的昼夜温差对比（同样 $R_n$ 输入，$c_v$ 差异导致升温幅度差几倍）直观说明。

        - *热扩散率* $a = kappa\/c_v$（m²/s）：描述温度变化传播速度。干土（$kappa$ 小、$c_v$ 小）vs 湿土（$kappa$ 大、$c_v$ 大）vs 饱和土的对比；热扩散率决定温度波在土壤中的衰减深度和相位滞后。

      3. （15 min）基本原理：傅里叶定律与热传导方程

        - 傅里叶热传导定律：$F = -kappa pdv(T, z)$，讲解负号（热量从高温流向低温）与梯度方向；

        - 连续性方程推导：对微元体 $Delta z$ 做热量收支平衡：

          $ c_v pdv(T, t) Delta z = F(z) - F(z + Delta z) = -pdv(F, z) Delta z $

          代入傅里叶定律，得热传导方程：

          $ c_v pdv(T, t) = kappa pdv(T, z, 2) $

          强调：当 $kappa$ 均匀时方程简化，热扩散率 $a = kappa\/c_v$ 是方程唯一参数；

        - 介绍 de Vries（1963）土壤热参数体系：石英（$kappa$ 高）、粘土矿物、有机质、液水、冰、空气的热参数表，说明土壤热参数是各组分加权平均，含水量升高时 $kappa$ 显著增大。

      *第2学时（45 min）——地表能量平衡、$T_s$ 求解与数值方法*

      1. （10 min）土壤热通量在能量平衡中的地位

        - 地表能量平衡方程：$R_n - G = H + lambda E$；
        - 土壤热通量 $G$ 的典型量级（晴天白天约为 $R_n$ 的 10%～20%，夜间方向反转）；
        - 实测示例：展示晴天 $G$、$H$、$lambda E$、$R_n$ 的日变化曲线，强调 $G$ 在日积分中接近零（日均闭合）；
        - 能量不平衡问题简介（涡动相关系统的实测挑战）。

      2. （20 min）核心理论：联立方程求解地表温度 $T_s$

        - 净辐射公式（线性化处理）：$R_n = R_(n,s) - epsilon sigma T_s^4 approx R_(n,s) - epsilon sigma T_a^4 - 4 epsilon sigma T_a^3 (T_s - T_a)$；
        - 感热通量：$H = (rho c_p (T_s - T_a)) / r_H$；
        - 土壤热通量参数化：$G = kappa (T_s - T_("deep")) / Delta z$（或简化为 $G = C_G R_n$）；
        - 联立能量平衡 $R_n - G = H + lambda E$ 与上述参数化方案，对未知量 $T_s$ 建立方程；
        - 讨论：$T_s$ 的求解需要迭代（因 $R_n$、$H$、$lambda E$ 均与 $T_s$ 耦合），引出数值方法的必要性；
        - 物理讨论：$T_s > T_a$ 时感热向上，$G > 0$ 时土壤吸热；比较裸地与植被覆盖地表的 $T_s$ 差异。

      3. （15 min）数值求解：Julia 代码求解 ODE

        - 展示一维土壤热传导的 Julia 求解示例（5行核心代码，使用 `DifferentialEquations.jl`）：

          ```julia
          using DifferentialEquations
          κ, cv = 0.5, 2.5e6          # 热参数（W/m/K, J/m³/K）
          f(u, p, t) = (κ/cv) * (u[2:end] - 2u[2:end-1] + u[1:end-2]) / dz^2
          prob = ODEProblem(f, T0, tspan)
          sol  = solve(prob, Tsit5())
          ```

        - 讲解离散化思路：将 $pdv(T, z, 2)$ 用有限差分近似，从 PDE 转化为 ODE 组；
        - 展示数值解示例图（温度波在土壤中的传播、衰减与相位滞后），与开篇气象站观测图对比，验证模型合理性；
        - 讨论边界条件的设置（地表温度强迫 vs 通量强迫）与典型应用场景。

    ]
  ],
  [*参考资料*],
  [
    1. 课件：《第五章 土壤热通量》（Typst格式）

    2. de Vries, D.A. (1963). Thermal properties of soils. In W.R. van Wijk (Ed.), *Physics of Plant Environment*. North-Holland, Amsterdam.

    3. Monteith, J.L. & Unsworth, M.H. (2013). *Principles of Environmental Physics* (4th ed.). Elsevier. 第2章 热传导相关内容。

    4. Campbell, G.S. & Norman, J.M. (1998). *An Introduction to Environmental Biophysics* (2nd ed.). Springer. 第4章 Soil Temperature。

    5. 中国地质大学（武汉）气象站2023年逐小时土壤温度观测数据。

    6. Hillel, D. (1998). *Environmental Soil Physics*. Academic Press. 第12章。
  ],
  [*课后小结*],
  [
    本章以土壤温度的实测现象为切入点，建立了土壤热过程的完整理论框架：热传导系数 $kappa$、体积热容量 $c_v$ 与热扩散率 $a = kappa\/c_v$ 三个参数决定土壤的热特性；傅里叶定律 $F = -kappa pdv(T, z)$ 与热传导方程 $c_v pdv(T, t) = kappa pdv(T, z, 2)$ 是描述热量传输的基本方程。土壤热通量 $G$ 作为地表能量平衡 $R_n - G = H + lambda E$ 的重要分量，与地表温度 $T_s$ 耦合求解；数值方法（Julia ODE 求解器）提供了从物理方程到定量解的实用工具。传统智慧（农谚、地窖）与现代气候变化议题（冻土碳释放）共同揭示了土壤热过程的现实意义。
  ],
)
