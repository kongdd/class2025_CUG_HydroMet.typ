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
    [*授课题目：*], [第四章 辐射与能量平衡],
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
  [*教学内容*], table.cell(colspan: 3)[第四章 辐射与能量平衡],
  [*授课对象*], table.cell(colspan: 3)[环境学院 大气科学系 大三学生],
  [*教学目的\ 与要求*],
  table.cell(colspan: 3)[#align(left + top)[
      *教学目的：*

      1. 理解普朗克定律、维恩位移定律和斯提芬-波尔茨曼定律的物理意义，能用公式定量计算辐射通量；

      2. 掌握基尔霍夫定律 $epsilon_lambda = alpha_lambda$ 及 $alpha + rho + tau = 1$ 的含义，理解雪和保温瓶等案例的辐射机制；

      3. 理解三种能量传递方式（辐射、对流、热传导）的比较与适用条件；

      4. 掌握辐射通量密度 $F$ 与辐射强度 $I$ 的定义，理解日地距离变化对大气层顶辐射的影响；

      5. 掌握太阳高度角公式，能够计算任意地点、任意日期的日出日落时间和大气层顶辐射积分；

      6. 理解地表能量平衡 $R_n - G = lambda E + H$ 各项的物理意义，掌握大气能量平衡的定量分配；

      7. 掌握地表净辐射 $R_n = (1 - alpha) R_s + epsilon "Rln" - epsilon sigma T_s^4$ 的计算，能用牛顿梯度法迭代求解地表温度 $T_s$。

      *教学要求：*

      能用斯提芬-波尔茨曼定律估算人体辐射散热功率；能推导维恩位移定律给出太阳与地球辐射峰值波长；能由太阳高度角公式计算日出日落时间；能建立地表温度 $T_s$ 的能量平衡方程组并用牛顿梯度法迭代求解。
    ]
  ],
  [*教学重点\ 与难点*],
  table.cell(colspan: 3)[
    *教学重点：*

    1. 三大辐射定律——普朗克定律、维恩位移定律、斯提芬-波尔茨曼定律的物理意义及定量计算；

    2. 基尔霍夫定律 $epsilon_lambda = alpha_lambda$（热平衡条件下发射率等于吸收率）及其工程应用；

    3. 太阳高度角公式 $sinh = cos phi cos delta cos omega + sin phi sin delta$ 及日出日落时间计算；

    4. 地表能量平衡方程 $R_n - G = lambda E + H$ 各分量的来源与量级；

    5. 地表净辐射 $R_n$ 公式中短波与长波收支的合并；利用牛顿梯度法迭代求 $T_s$。

    *教学难点：*

    1. 雪的"黑白二象性"——可见光波段高反射率（$rho approx 0.9$）与热红外波段高发射率（$epsilon approx 0.99$）并不矛盾，因为两者涉及不同波段的基尔霍夫定律；

    2. 大气层顶太阳辐射积分 $R s_"toa"$ 的推导——需理解余弦因子投影与日长积分的几何关系；

    3. 地表温度 $T_s$ 的求解——$R_n$ 中含 $T_s^4$ 项，需将感热 $H$、潜热 $lambda E$ 和地热 $G$ 同时联立，形成非线性方程组，用牛顿迭代法求解。
  ],
  [*教学手段*],
  table.cell(colspan: 3)[
    利用 Typst 课件配合辐射光谱图（黑体曲线）、太阳高度角示意图和大气能量收支示意图直观讲授；以人体辐射散热、保温瓶银内壁、雪的二象性等生活案例激发兴趣；结合 Landsat 热红外遥感反演地表温度的工程背景，体现课程的实际应用价值；通过随堂计算（人体辐射功率、峰值波长）即时检验理解效果。
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

      以人体辐射散热（约 130 W）、保温瓶银内壁、雪的"黑白二象性"等日常案例切入，消除学生对"辐射"的神秘感，激发探究兴趣。结合 Landsat 8/9 热红外波段（10.6–11.2 μm）反演城市地表温度的工程应用，引导学生认识遥感卫星在城市热岛监测、农业旱情评估等领域服务国家战略的现实意义。通过普朗克、斯提芬、玻尔茨曼等物理学家的历史故事，体现科学积累与量化思维的力量；引导学生认识到"地表能量平衡"是连接大气、水文、生态多学科的基础纽带，培养跨学科系统思维。

      *问题导入（第1学时）：*

      - 提问：人体体表温度约 33°C，皮肤面积约 1.8 m²，每秒向外辐射多少能量？吃一顿饭（约 2500 kJ）能维持人体散热多少小时？
      - 展示太阳与地球的黑体辐射光谱对比，提问：为什么太阳辐射是可见光，而地球辐射是热红外？两者用什么定律来解释？

      *教学安排：*

      *第1学时（45 min）——辐射基本定律*

      1. （8 min）引言与案例：
        - 三种能量传递方式对比表（辐射/对流/热传导：传播介质、速度、波长依赖性）；
        - 引出问题：太阳能量如何穿越真空到达地球？

      2. （12 min）普朗克定律与维恩位移定律：
        - 普朗克定律 $I_lambda (T) = (2 h c^2) / lambda^5 dot 1 / (e^(h c \/ lambda k T) - 1)$；
        - 对 $lambda$ 求导令其为零，得维恩位移定律 $lambda_"max" = b / T$（$b = 2.898 times 10^(-3) "m" dot "K"$）；
        - 随堂计算：太阳 $T approx 6000 "K"$ → $lambda_"max" approx 0.48 mu "m"$（可见光）；地球 $T approx 300 "K"$ → $lambda_"max" approx 9.66 mu "m"$（热红外）。

      3. （12 min）斯提芬-波尔茨曼定律：
        - 对普朗克函数全波段积分，得 $E = epsilon sigma T^4$（$sigma = 5.67 times 10^(-8) "W" dot "m"^(-2) dot "K"^(-4)$）；
        - 案例计算：人体（$T = 306 "K"$，$epsilon approx 0.95$，$A approx 1.8 "m"^2$）：$E = 0.95 times 5.67 times 10^(-8) times 306^4 times 1.8 approx 130 "W"$；
        - 引导学生思考：吃一顿饭约 2500 kJ，维持约 5 h 散热——与实际代谢吻合！

      4. （13 min）基尔霍夫定律：
        - 热平衡条件下 $epsilon_lambda = alpha_lambda$（光谱发射率等于光谱吸收率）；
        - $alpha + rho + tau = 1$（吸收率＋反射率＋透射率守恒）；
        - 案例 1——保温瓶银内壁：$rho approx 1$，$alpha approx 0$，$epsilon approx 0$，因此辐射散热极小；
        - 案例 2——雪的"黑白二象性"：可见光（0.4–0.7 μm）$rho approx 0.9$（白色，高反射），热红外（8–14 μm）$epsilon approx 0.99$（"黑体"，高发射）；两者涉及不同波段，并不矛盾——Landsat 热红外正是利用了雪/地表在 10 μm 附近的高发射率。

      *第2学时（45 min）——太阳辐射*

      1. （8 min）辐射通量密度与辐射强度：
        - 辐射通量密度 $F$（单位 $"W" dot "m"^(-2)$）：单位面积单位时间辐射能量；
        - 辐射强度 $I$（单位 $"W" dot "m"^(-2) dot "sr"^(-1)$）：单位立体角内的辐射通量密度；
        - 太阳常数 $I_0 = 1370 "W" dot "m"^(-2)$（大气层顶垂直日面辐射通量密度）。

      2. （10 min）日地距离变化：
        - 地球绕太阳的椭圆轨道（近日点1月初，远日点7月初），日地距离 $d$ 以平均距离 $d_0$ 为基准变化约 ±1.7%；
        - 辐射强度随距离平方反比：$I = I_0 / rho^2$（$rho = d / d_0$ 为相对日地距离，近日点 $rho approx 0.983$，辐射增强约 3.5%）；
        - 引导思考：北半球冬季近日点，为何仍然寒冷？（入射角才是主因）

      3. （22 min）太阳高度角与日出日落：
        - 太阳高度角公式（余弦定理推导）：$sin h = cos phi cos delta cos omega + sin phi sin delta$，其中 $phi$ 为纬度，$delta$ 为太阳赤纬，$omega$ 为时角；
        - 太阳赤纬 $delta$ 随日序 $J$ 变化：简单估算式 $delta approx 23.45 sin(360 / 365 dot (J - 81))°$；用于划分24节气的物理基础（赤纬极值、零值对应节气）；
        - 日出日落条件：$h = 0$ 时 $cos omega_0 = -tan phi tan delta$，日长 $"DL" = 2 omega_0 / 15°$ h；
        - 随堂练习：武汉（$phi = 30.5°$）夏至（$delta = 23.45°$）的日出日落时间（约 5:15 至 19:15，日长约 14 h）。

      4. （5 min）大气层顶太阳辐射：
        - $R s_"toa" = I_0 / rho^2 dot cos theta_z$，对时角从 $-omega_0$ 到 $omega_0$ 积分得日总量；
        - 简要说明量级：武汉夏至约 $41 "MJ" dot "m"^(-2) dot "d"^(-1)$，冬至约 $17 "MJ" dot "m"^(-2) dot "d"^(-1)$。

      *第3学时（45 min）——能量平衡*

      1. （15 min）大气能量平衡（定量讲解）：
        - 以太阳入射 100 单位为基准，逐项列出大气收支：
          - 大气顶入射：100（短波）；
          - 大气直接反射/散射回太空：约 30（其中云层反射 20，大气散射 6，地表反射 4）；
          - 大气吸收短波：约 19；
          - 地表吸收短波：约 51；
          - 地表向上长波（净）：约 29 传到大气，21 逃出大气层；
          - 对流感热：约 7；潜热：约 23；
        - 强调辐射收支闭合对气候系统的意义（温室效应使大气长波向下补偿地表）；
        - 结合数字讨论：若大气 $"CO"_2$ 增加，哪一项会变化？

      2. （15 min）地表能量平衡：
        - 地表能量平衡方程：$R_n - G = lambda E + H$；
        - 各项定义与正负号约定：$R_n$ 向下为正，$G$ 向下为正，$lambda E$ 和 $H$ 向上为正；
        - Bowen 比 $beta = H / (lambda E)$ 的物理意义（湿润地表 $beta < 1$，干旱地表 $beta >> 1$）；
        - 典型案例对比：热带雨林（$beta approx 0.1$）、沙漠（$beta approx 5$）、城市（$beta approx 2-5$）。

      3. （15 min）土壤热通量与综合小结：
        - 土壤热通量 $G = -lambda_s dif T / dif z$（$lambda_s$ 为土壤导热系数）；
        - 日内 $G$ 变化规律（白天向下，夜间向上），日均量级约为 $R_n$ 的 5–15%；
        - 观测方法：热流板直接测量、土壤温度梯度间接推算；
        - 综合小结：能量在大气–地表系统中如何流动——从太阳辐射输入到地表辐射、感热、潜热输出的完整链条。

      *第4学时（45 min）——地表净辐射与地表温度求解*

      1. （12 min）地表净辐射公式：
        - 短波净辐射：$(1 - alpha) R_s$（$alpha$ 为地表反照率，典型值：草地 0.23，雪地 0.85，水面 0.06）；
        - 向下长波辐射 $"Rln"$（来自大气，由空气温度和水汽决定）；
        - 向上长波辐射：$epsilon sigma T_s^4$；
        - 合并：$R_n = (1 - alpha) R_s + epsilon "Rln" - epsilon sigma T_s^4$；
        - Landsat 热红外应用：利用地表发射亮度温度反演 $T_s$，再代入上式计算 $R_n$，最终得到蒸散发——展示城市与农田的 $T_s$ 差异图。

      2. （18 min）地表温度 $T_s$ 联立方程求解：
        - 各通量均含 $T_s$（或依赖 $T_s$ 的饱和水汽压）：
          - $R_n = (1 - alpha) R_s + epsilon "Rln" - epsilon sigma T_s^4$；
          - $H = (rho c_p (T_s - T_a)) / r_H$；
          - $lambda E = (rho c_p (e_s (T_s) - e_a)) / (gamma (r_v + r_s))$；
          - $G = C_G (T_s - T_"soil")$；
        - 代入能量平衡 $R_n - G - H - lambda E = 0$，得到以 $T_s$ 为未知量的非线性方程 $f(T_s) = 0$；
        - 讨论方程难以解析求解的原因（$T_s^4$ 项与 $e_s(T_s)$ 的克劳修斯-克拉佩龙非线性）。

      3. （15 min）牛顿梯度法迭代求解 $T_s$：
        - 牛顿迭代公式：$T_s^(k+1) = T_s^k - f(T_s^k) / f'(T_s^k)$；
        - 导数 $f'(T_s)$ 的解析形式（对各通量关于 $T_s$ 求导合并）：
          $f'(T_s) = -4 epsilon sigma T_s^3 - 1 / r_H - (rho c_p) / (gamma (r_v + r_s)) dot (dif e_s) / (dif T_s)$，
          其中 $dif e_s \/ dif T_s = Delta$（饱和水汽压斜率）；
        - 演示迭代过程：初始猜测 $T_s^0 = T_a$，通常 3–5 次收敛（误差 < 0.01 K）；
        - 综合小结：从辐射三定律 → 太阳辐射 → 能量平衡 → 净辐射 → $T_s$ 求解的完整闭环；布置课后思考题。

    ]
  ],
  [*参考资料*],
  [
    1. 课件：《第四章 辐射与能量平衡》（Typst 格式）

    2. Liou, K.N. (2002). *An Introduction to Atmospheric Radiation* (2nd ed.). Academic Press. 第1–2章。

    3. Monteith, J.L. & Unsworth, M.H. (2013). *Principles of Environmental Physics* (4th ed.). 第2–5章（辐射收支与能量平衡）。

    4. Allen, R.G., et al. (1998). FAO Irrigation and Drainage Paper No. 56. 附录 A（太阳辐射计算）。

    5. Landsberg, J.J. & Sands, P. (2011). *Physiological Ecology of Forest Production*. 辐射截获章节。

    6. NASA CERES 辐射收支数据：https://ceres.larc.nasa.gov/

    7. Landsat 8/9 地表温度反演产品文档（USGS Level-2 LST）。
  ],
  [*课后小结*],
  [
    本章围绕"辐射如何驱动地表能量流动"这一核心主线，逐层展开：从普朗克定律出发推导维恩位移定律（太阳可见光 vs 地球热红外）和斯提芬-波尔茨曼定律（$E = epsilon sigma T^4$），用基尔霍夫定律（$epsilon_lambda = alpha_lambda$）解释雪的"黑白二象性"和保温瓶原理；再结合太阳高度角公式，定量计算大气层顶辐射和日出日落时间；最终通过大气与地表能量平衡（$R_n - G = lambda E + H$）将各辐射分量整合，建立地表净辐射方程，并用牛顿迭代法求解地表温度 $T_s$。该框架是卫星遥感反演地表参数（温度、蒸散发）的理论基础。
  ],
)
