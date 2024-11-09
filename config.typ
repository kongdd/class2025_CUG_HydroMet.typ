#import "@preview/codly:1.0.0": *
#import "@preview/mitex:0.2.4": *

#let format_eq(it) = {
  show "{": ""
  show "}": ""
  it
}

#let beamer_block(value) =  {
  block(
    fill: luma(240), 
    inset: 0.6em,
    stroke: (left: 0.25em))[#value]
}

#let set_supplement(it) = {
  it
}

#let ref_zh(it) = {
  let el = it.element
  let eq = math.equation
  
  if el != none {
    if el.func() == eq {
      link(el.location(), numbering(
        "(1)", 
        ..counter(eq).at(el.location())
      ))
    } else if el.func() == figure {
      link(el.location(), numbering(
        "1.1", 
        ..counter(figure).at(el.location())
      ))
    }
    // else if el.func() == table {
    //   link(el.location(), numbering(
    //     "表 1", 
    //     ..counter(tab).at(el.location())
    //   ))
    // } 
    // el.func()
  } else {
    it
  }
}

#let btext(x, color: red, bg: rgb("fffd11a1")) = {
  highlight(fill: bg)[
    #text(x, fill: color)
  ]
}


#let template(doc, size: 13pt, footer: "", header: "") = {
  set text(size: size) // font: ("Microsoft YaHei")
  set heading(numbering: "1.1")
  set par(justify: true)
  set math.equation(numbering: "(1)")
  set list(indent: 1em)

  // 代码
  show: codly-init.with()
  codly(stroke: 1pt + blue)
  codly(display-icon: true)
  
  set figure(
    numbering: it => strong[#numbering("1.1", it)], 
    supplement: text("图", weight:"bold"))
  set figure.caption(separator: ". ")
  
  show ref: ref_zh  // 引用
  
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

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
