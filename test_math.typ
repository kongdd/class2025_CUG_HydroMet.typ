#import "@preview/modern-cug-report:0.1.0": *
#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "山洪预报")
#counter(heading).update(0)
#let delta(x) = $Delta #x$



= 一级标题
== 一级标题
== 一级标题
=== 一级标题


$ y = a x + b $

$
  theta_(i)^(n+1) = pdv(theta, t, 2) Delta t 
$ <eq_2>

要引用这个公式了，如@eq_2。

$ (d S_g) / (d t) = delta(x) delta(y) R + sum_i^8 Q_n - Q_r $

= 一级标题

== 一级标题
== 一级标题
=== 一级标题

$
  y = a x + b
$
