#import "config.typ": *
#import "@preview/showybox:2.0.2": showybox
#import "@preview/physica:0.9.3": *
#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold

#show: (doc) => template(doc, 
  size: 13pt,
  footer: "CUG水文气象学2024",
  header: "第一章 基本的水文气象变量")
#counter(heading).update(0)

= 基本的水文气象变量

== 理想气体状态方程

$ P V = n R^* T $
