#import "@preview/modern-cug-report:0.1.0": *

#show: (doc) => template(doc, 
  size: 18pt,
  footer: "CUG水文气象学2024",
  header: "第二次 作业")
#counter(heading).update(0)

*请陈述如何更加准确的计算地表感热$lambda E$和潜热通量$H$，需要的数据，需要的公式、原理，主要求解思路、过程等。
*

#box-red([
  Clue: 
  #nonum([$
    R_n - G = lambda E + H 
  $])
  // 1. 各个成分如何准确表达
  // 2. 感热、潜热分配比例
])

#v(1em)

*要求：*

1. #highlight()[不超过一页]

2. 字体：小四，中文宋体、英文Times New Roman；段落：1.5倍行距，段前段后0.2行。

3. 作业需包含：标题、姓名、学号

4. 按时提交（下周三，12月18号），#highlight()[提交电子版]


#v(1em)

*评分依据：*

1. 知识点涵盖完整

2. 逻辑清晰

3. 写作规范，公式编号正确，变量说明完整。
