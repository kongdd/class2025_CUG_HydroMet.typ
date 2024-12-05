#import "@preview/modern-cug-report:0.1.0": *
#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "山洪预报")

#counter(heading).update(0)
#let delta(x) = $Delta #x$

$
  y = a + b
$
