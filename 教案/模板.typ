// ===== 全局设置 =====
#set page(paper: "a4", margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm))
// #set par(leading: 1.4em, justify: true)

// ===== 封面 =====
#align(center)[
  #v(3cm)
  #image("./images/logo_cug.png", width: 7cm)
  // #text(size: 26pt, font: ("KaiTi", "FangSong", "serif"))[中国地质大学]

  // #v(0.5cm)
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
    [*授课题目：*], [水汽通量与暴雨分析],
    [*授课对象：*], [大三学生],
    [*授课时间：*], [4 学时],
  )
]

#pagebreak()
#counter(page).update(1)

#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "", header: "")

// ===== 教案正文 =====
#align(center)[#text(size: 20pt, font: "SimHei")[*教　　案*]]
#v(0.8em)

*课程名称*：#underline[《水文气象学》]

#let l = 0.8cm
#let l1 = 12cm
#let l2 = 10cm

// 表1：基本信息
#table(
  columns: (2.2cm, 3fr, 3fr, 3fr),
  rows: (l, l, l, l, 7cm, 10cm, l),
  align: (horizon + center, horizon + left),
  stroke: 0.5pt,
  // inset: (x: 6pt, y: 5pt),
  [*授课教师*], [孔冬冬], [*所在单位*], [环境学院],
  [*课程类型*], [专业选修课], [*授课时间*], [2 学时],
  [*教学内容*], table.cell(colspan: 3)[第四章 水汽通量与暴雨分析],
  [*授课对象*], table.cell(colspan: 3)[环境学院 大气科学系 大三学生],
  [*教学目的\ 与要求*],
  table.cell(colspan: 3)[
    *教学目的：*

    1. 学会分析暴雨水汽来源的主要方法；

    2. 根据水汽通量散度，学会分析容易发生暴雨的区域。

    *教学要求：*

    理解水汽通量、水汽通量散度等指标的含义，并学会使用这些指标分析暴雨水汽来源；理解垂直运动与水汽辐合、辐散的关系，据此分析容易发生降水的区域。
  ],
  [*教学重点\ 与难点*],
  table.cell(colspan: 3)[

  ],
  [*教学手段*],
  table.cell(colspan: 3)[
    利用 PowerPoint 课件、相关视频，讲授本节内容。
  ],
)


// 教学方案设计

#pagebreak()

#table(
  columns: (2.2cm, 1fr),
  rows: (1cm, 10cm, 1cm, 2cm),
  align: (horizon + center, horizon + left),
  stroke: 0.5pt,
  table.cell(colspan: 2)[*教学方案设计*],
  table.cell(colspan: 2)[#align(left)[
      // 填写内容
      // 思政教育：
      *思政：*

      *问题导入：*

      *教学安排：*
    ]
  ],
  [*参考资料*], [],
  [*课后小结*], [],
)
