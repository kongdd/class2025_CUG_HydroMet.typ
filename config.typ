#import "@preview/codly:1.0.0": *


#let ref_zh(it) = {
  let el = it.element
  let eq = math.equation
  let fig = image
  let tab = table
  
  if el != none {
    if el.func() == eq {
      link(el.location(), numbering(
        "式 (1)", 
        ..counter(eq).at(el.location())
      ))
    } else if el.func() == fig {
      link(el.location(), numbering(
        "图 1", 
        ..counter(fig).at(el.location())
      ))
    } else if el.func() == tab {
      link(el.location(), numbering(
        "表 1", 
        ..counter(tab).at(el.location())
      ))
    } else {
      it
    }
  }
}



#let btext(x, color: red, bg: rgb("fffd11a1")) = {
  highlight(fill: bg)[
    #text(x, fill: color)
  ]
}

#let template(doc, size: 14pt, footer: "", header: "") = {
  set text(size: size) // font: ("Microsoft YaHei")
  set heading(numbering: "1.1")
  
  // 代码
  show: codly-init.with()
  codly(stroke: 1pt + blue)
  codly(display-icon: true)

  // 数学公式
  set math.equation(numbering: "(1)")
  show ref: ref_zh  // 引用公式

  // 链接
  show link: underline
  show link: set text(fill: rgb(0, 0, 255))

  // 代码
  show raw: set text(font: ("consolas", "Microsoft Yahei", "SimSun"), size: 10pt)

  // 页眉页脚
  
  // footer
  set page(
    footer: context [
      #text(footer, weight: "bold")
      #h(1fr)
      #counter(page).display("1/1", both: true)
    ], 
    header: align(right)[
      #text(header, weight: "bold")
    ],
    numbering: "1",
  )

  show regex("==(\w+)=="): x => {
    // let txt = x.fields().text // content object
    let txt = x.text
    txt = txt.replace("==", "")
    btext(txt)
  }
  doc
}
