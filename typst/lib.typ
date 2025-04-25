// #import "@preview/codly:1.0.0": *
#import "@preview/mitex:0.2.4": *
#import "@preview/physica:0.9.3": *
#import "@preview/cuti:0.2.1": show-cn-fakebold
#import "./box.typ": *
#import "./paragraph.typ": *

#let rm-bracket(it) = {
  show "{": ""
  show "}": ""
  it
}

#let nonum(eq) = math.equation(block: true, numbering: none, eq)

#let num-include-chapter(num) = {
  numbering("(1.1)", counter(heading).get().first(), num)
}

#let ref-zh(it) = {
  let el = it.element
  let eq = math.equation
  
  if el != none {
    // el.fields()    
    if el.func() == eq {
      link(el.location(), 
        // numbering("(1)", ..counter(eq).at(el.location()))
        numbering("1.1", counter(heading).get().first(), ..counter(eq).at(el.location()))
      )
    } else if el.kind == figure {
      link(el.location(), 
        numbering("1.1", counter(heading).get().first(), ..counter(figure).at(el.location()))
      )
    } else if el.kind == table {
      let count = counter(figure.where(kind: table)).at(el.location());
      link(el.location(), numbering("1.1", counter(heading).get().first(), ..count))
      // link(el.location(), numbering("表 1",  ..counter(table).at(el.location()))
    } 
    // el.func()
  } else {
    // it
  }
}

#let highlight-text(x, color: red, bg: rgb("fffd11a1")) = {
  highlight(fill: bg)[#text(x, fill: color)]
}

#let md-highlight(x) = {
  // let txt = x.fields().text // content object
  let txt = x.text
  txt = txt.replace("==", "")
  highlight-text(txt)
}


#let set-figure(body) = {
  set figure(numbering: it => strong[#numbering("1.1", it)])
  set figure.caption(separator: ". ")
  // set figure(numbering: it => strong[#numbering("1.1", it)])
  set figure(numbering: num => numbering("1.1", counter(heading).get().first(), num))
  // set figure(numbering: num => numbering("1.1", counter(heading).get().first(), num))
  
  show figure.where(kind: image): set figure(supplement:  text("图", weight:"bold"))
  show figure.where(kind: table): set figure(supplement:  text("表", weight:"bold"))
  show figure.where(kind: table): set figure.caption(position: top)
  body
}


#let set-table(it) = {
  show table.cell.where(y: 0): strong
  // See the strokes section for details on this!
  let frame(stroke) = (x, y) => (
    left: 0pt, right: 0pt,
    // left: if x > 0 { 0pt } else { stroke },
    // right: stroke,
    top: if y < 2 { stroke } else { 0pt },
    bottom: stroke,
  )
  set table(
    // fill: (rgb("EAF2F5"), none),
    stroke: frame(rgb("21222C")),
    align: (x, y) => ( if x > 0 { center } else { left } )
  )
  it
}



#let template(doc, size: 12pt, footer: "", header: "", numbering: "1.1") = {
  set text(size: size) // font: ("Microsoft YaHei")
  set par(justify: true)
  set heading(numbering: numbering)
  // set math.equation(numbering: "(1.1)")
  set math.equation(numbering: num-include-chapter)
  set list(indent: 1em)

  // 代码
  // show raw: codly-init.with()
  // codly(stroke: 1pt + blue)
  // codly(display-icon: true)
  
  show ref: ref-zh  // 引用
  show heading: it => set-heading(it, size: size)
  
  show: set-figure
  show: set-table
  show: show-cn-fakebold

  // 链接
  show link: underline
  show link: set text(fill: rgb(0, 0, 255))

  // 代码
  show raw: set text(font: ("consolas", "Microsoft Yahei", "SimSun"), size: 10pt)

  // 页眉页脚
  set page(
    header: align(right)[ #text(header, weight: "bold") ],
    footer: context [#text(footer, weight: "bold") #h(1fr) #counter(page).display("1/1", both: true) ], 
    numbering: "1", )
  show regex("==(\w+)=="): md-highlight
  doc
}
