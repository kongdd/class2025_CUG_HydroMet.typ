// 建议在正式编辑论文时，采用 typst.app 中的已发布版本模板
#import "@preview/modern-sysu-thesis:0.1.1": documentclass

#let (
  // 布局函数
  twoside, doc, preface, mainmatter, mainmatter-end, appendix,
  // 页面函数
  fonts-display-page, cover, title-page, decl-page, abstract, abstract-en, bilingual-bibliography,
  outline-page, list-of-figures, list-of-tables, notation, acknowledgement,
) = documentclass(
  // doctype: "bachelor",  // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为本科生 bachelor
  // degree: "academic",  // "academic" | "professional", 学位类型，默认为学术型 academic
  // anonymous: true,  // 盲审模式
  twoside: false,  // 双面模式，会加入空白页，便于打印
  // 可自定义字体，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")),
  info: (
    title: ("基于 Typst 的", "中山大学学位论文模板"),
    title-en: "A Typst Template for SYSU thesis",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    author-en: "Ming Xing",
    department: "某学院",
    department-en: "School of Chemistry and Chemical Engineering",
    major: "某专业",
    major-en: "Chemistry",
    supervisor: ("李四", "教授"),
    supervisor-en: "Professor My Supervisor",
    // supervisor-ii: ("王五", "副教授"),
    // supervisor-ii-en: "Professor My Supervisor",
    submit-date: datetime.today(),
  )
  // 参考文献源
  // bibliography: bibliography.with("ref.bib"),
)

// 正文
#show: mainmatter

#underline[_*hello wold*_]

#underline[_*为何中文不支持*_]

这样的

这样是可以的吗？

#mainmatter-end()
