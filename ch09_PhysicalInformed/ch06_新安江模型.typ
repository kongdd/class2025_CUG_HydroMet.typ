// #import "../typst/lib.typ": *
#import "@local/modern-cug-report:0.1.3": *
#counter(heading).update(2)
#let delta(x) = $Delta #x$

#set par(spacing: 1.2em, leading: 1em)
#show: doc => template(
  doc,
  size-config: (
    math: (
      text: 12pt, // 插入正文的公式
      block: 12pt, // 单独一行的公式
    ),
  ),
  pagenum: true,
  footer: "CUG水文气象学2025",
  header: "第六章 水文预报",
)

// =
// =
// =
// =
// =
= 6 水文预报
