#import "typst/lib.typ": *

#show: (doc) => template(doc, 
  size: 11.5pt,
  footer: "CUG水文气象学2024",
  header: "交互过程")
#counter(heading).update(4)
#set par(leading: 1.24em)
#let delta(x) = $Delta #x$

= 交互过程
