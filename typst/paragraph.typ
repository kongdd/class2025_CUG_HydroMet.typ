// // 为解决首行缩进问题
// #let fake-par = context {
//   // let b = par(box())
//   let b = box()
//   b
//   v(-measure(b + b).height)
// }

#let font = (
  四号: 14pt,
  小四: 12pt,
  五号: 10.5pt,
)

#let l1_h = 1.24em
#let l1 = 1.24em / 1.5

#let p-style-default = (
  leading: l1_h, // 1.5倍行距
  // line-height: 1.5em,        // 行高
  spacing: l1_h + l1 * 0.25, // 段前段后, 0.3倍行距
  font-en: "Times New Roman",
  font-cn: "STKaiti", // SimSun, STKaiti
)


#let set-heading(it, size: font.四号, fake-par: false) = {
  // https://github.com/typst/typst/issues/1896
  // https://github.com/shuosc/SHU-Bachelor-Thesis-Typst/issues/12
  show heading: it => {
    if fake-par {
      v(0.4em)
      it
      v(-1.0em)
      text(size: 0em)[#h(0em)]
    } else {
      // v(0.2em)
      it
      // v(0.2em)
    }
    // fake-par
  }

  show heading.where(level: 1): it => {
    set text(size: size + 3pt)
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }

  // show heading.where(level: 2): it => {
  //   set text(size: size + 1pt)
  //   it
  // }
  // show heading.where(level: 3): it => {
  //   // set text(size: size + 1pt)
  //   it
  // }
  // show bibliography: it => {
  //   it
  //   v(1em)
  // }
  it
  // show heading.where(level: 1): it => block(width: 100%)[#(it) #v(0.2em)]
  // show heading.where(level: 2): it => block(width: 100%)[#(it) #v(0.2em)]
}


#let p-full(it, style: p-style-default, first-line-indent: 0em) = {
  let leading = style.leading * 0.95
  set par(
    leading: leading,
    spacing: leading, // 如果顶满格的，则意味着它不需要段前行距。
    first-line-indent: first-line-indent,
    justify: true,
  )
  // let line-edge = (style.line-height - 1em)/2
  // top-edge: line-edge, bottom-edge: -line-edge
  set text(font: (style.font-en, style.font-cn))
  it
}

#let p-indent(it, style: p-style-default) = {
  set par(
    leading: style.leading,
    spacing: style.spacing,
    first-line-indent: 2em,
    justify: true,
  )
  // , top-edge:line-edge, bottom-edge:line-edge
  let line-edge = (style.leading) * 0.5
  set text(font: (style.font-en, style.font-cn), top-edge: line-edge, bottom-edge: line-edge)
  set-heading(it, size: font.四号, fake-par: true)
  // it
}
