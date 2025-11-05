#import "typst/lib.typ": *

#show: (doc) => template(doc, 
  size: 11.5pt,
  footer: "CUG水文气象学2024",
  header: "产流过程")
#counter(heading).update(2)
#set par(leading: 1.24em)
#let delta(x) = $Delta #x$

= 产流过程

