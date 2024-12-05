// // 为解决首行缩进问题
// #let fake-par = context {
//   // let b = par(box())
//   let b = box()
//   b
//   v(-measure(b + b).height)
// }

#let l = 1.24em

#let p-style-default = (
  leading: l,                   // 1.5倍行距
  // line-height: 1.5em,        // 行高
  spacing: l + l * 0.1 * 2,     // 段前段后, 0.3倍行距
  font-en: "Times New Roman", 
  font-cn: "STKaiti", // SimSun, STKaiti
)


#let p-full(it, style: p-style-default, first-line-indent: 0em) = {
  let leading = style.leading * 0.95
  set par(
    leading: leading, 
    spacing: leading,   // 如果顶满格的，则意味着它不需要段前行距。
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
  // let line-edge = (style.line-height - 1em)/2
  set text(font: (style.font-en, style.font-cn))
  it
}
