#import "@local/modern-cug-report:0.1.1":*

#show: (doc) => template(doc, 
  size: 12pt,
  numbering: none,
  footer: "",
  header: "")

// #counter(heading).update(3)
#let delta(x) = $Delta #x$
#show math.equation: set text(11pt)

#let rm-bracket(it) = {
  show "{": ""
  show "}": ""
  it
}
#show math.equation: rm-bracket

#let first-line-indent = (amount: 2em, all: true)
#set par(spacing: 1.24em + 0.4em, leading: 1.24em)
#show math.equation.where(block: true): set par(spacing: 0.9em, leading: 1.24em)

#set heading(numbering: none)
#show heading: it => {
  v(0.2em)
  it
  v(0.2em)
}

#set text(12pt,font:("Times New Roman", "FangSong"))
// #set enum(numbering: "1")

// “年度执行报告主要包括项目总体进展情况、年度目标完成情况、已取得的成果、经费使用情况、项目变更与终止情况、存在问题以及2025年度工作计划等内容”

= 1 项目总体进展情况

项目按计划执行，碳、水、能量耦合模型有序研发。碳方面，完成两种植被光合光合。水方面，3种蒸散发模型，4种土壤水运动模型。能量方面，完成土壤热通量求解方案。模型模拟表现良好。发表中科院一区SCI论文一篇。

// 计划2025年上半年，主要攻坚土壤水与地下水耦合、土壤湿度高精度模拟，揭示土壤水如何限制植被光合、植被蒸腾。下半年，耦合碳、水、能量模型，生成长江流域森林生态系统碳汇数据库。

= 2 年度目标完成情况

== 2.1 2024年度计划

- 调研长江流域森林植被结构特征，整编植被结构数据集，包括冠层高度、冠层形状、叶面积指数垂向分布、根系深度等信息；
- 确定多层树冠概化方案，厘清冠层结构对冠层微气象的影响，构建多层树冠辐射传输模型，并在涡度相关通量站上进行验证。
- 构建土壤热通量与土壤水运动模型。同时整编土壤湿度和土壤温度数据，率定模型参数，验证模型表现。

== 2.2 完成情况

- 已收集长江流域冠层高度、冠层形状、叶面积指数垂向分布、根系深度等信息；

- 编写完成两种冠层概化方案，基于PML-V2模型的大叶模型方案（https://github.com/jl-pkgs/PML.jl）和基于BEPS模型的双叶模型方案（https://github.com/jl-pkgs/BEPS.jl）。

- 完成基于Bonan2019的土壤热通量求解方案。完成4种土壤水运动求解方案，包括BEPS、SITH、CoLM和CLM5；完成基于Zeng 2009均衡水势的地下水耦合方案。

= 3 已取得的成果

以通讯作者，发表中科院一区SCI论文一篇。

[1] Lu J, *Kong D.*\*, Zhang Y, Xie Y, Gu X, Gulakhmadov A. Hotspots of Global Water Resource Changes and Their Causes[J]. #emph[*Earth’s Future*], 2025, 13(2): e2024EF005461. DOI:10.1029/2024EF005461.

#pagebreak()

= 4 经费使用情况

#v(0.4em)
项目共计支出3.4799万元，其中学校管理费0.8000万元，科研人员绩效2.1000万元，会议差旅费0.5799万元。

#figure(
  image("../Table1_经费使用_V2.png", width: 100%),
  // caption: []
) <fig_>

= 5 项目变更与终止情况

项目按计划执行。

= 6 存在问题

无。

= 7 2025年度工作计划

1. 构建SPAC模型耦合器，协同考虑植被光合、气孔导度、叶片温度、植被蒸腾、土壤热通量、辐射传输等过程，实现碳、水、能量全过程的耦合。

2. 利用涡度相关通量站全过程的观测资料，验证SPAC模型的表现；之后将模型推广到区域尺度，生成长江流域森林生态系统碳汇数据库，量化森林生态系统在碳减排中的贡献。

该年度预期产：SCI论文1\~2篇，申请专利1项，森林碳汇数据库1套。

