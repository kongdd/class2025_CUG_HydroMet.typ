#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// --- 配色 ---
#let c-blue = rgb("d4e8f2")
#let c-blue-s = rgb("6fabc7")

#set page(width: auto, height: auto, margin: 0.8cm)

#diagram(
  spacing: (1.3cm, 1.2cm),
  node-stroke: 1.2pt + c-blue-s,
  edge-stroke: 1pt,
  mark-scale: 70%,

  // ========== 行0: 主干线 H_{t-1} → ... → H_t ==========
  node((-0.5, 0), align(left)[隐状态 \ $H_(t-1)$], stroke: none, name: <h_label>),
  
  // 运算节点
  node((2, 0), $dot$, fill: c-blue, shape: circle, radius: 0.5em, name: <mul1>),
  node((4, 0), $dot$, fill: c-blue, shape: circle, radius: 0.5em, name: <mul2>),
  node((5, 0), $+$, fill: c-blue, shape: circle, radius: 0.5em, name: <add>),
  
  // 输出 H_t 方框
  node((6, 0), $H_t$, stroke: 1.2pt, shape: rect, width: 2em, height: 1.6em, name: <h_out>),

  // ========== 行1: 中间运算层 ==========
  node((3, 1), text(9pt)[1-], fill: c-blue, shape: circle, radius: 0.45em, name: <one_minus>),
  node((3.8, 1), $dot$, fill: c-blue, shape: circle, radius: 0.5em, name: <mul3>),

  // ========== 行2: 门控层 ==========
  node((1.2, 2), $sigma$, fill: c-blue, shape: rect, width: 2em, height: 1.6em, corner-radius: 4pt, name: <r_gate>),
  node((2.5, 2), $sigma$, fill: c-blue, shape: rect, width: 2em, height: 1.6em, corner-radius: 4pt, name: <z_gate>),
  node((4.2, 2), text(10pt)[tanh], fill: c-blue, shape: rect, width: 2.6em, height: 1.6em, corner-radius: 4pt, name: <tanh>),
  
  // 门控标签
  node((1.2, 2.7), text(9pt)[重置门 \ $R_t$], stroke: none),
  node((2.5, 2.7), text(9pt)[更新门 \ $Z_t$], stroke: none),
  
  // 输入标签
  node((1.85, 3.2), text(10pt)[输入 $X_t$], stroke: none, name: <x_label>),
  
  // 候选隐状态标签
  node((5.8, 2), align(left)[候选隐状态 \ $tilde(H)_t$], stroke: none, name: <h_tilde>),

  // ========== 连线 ==========
  
  // H_{t-1} 主干线
  edge(<h_label>, (0.5, 0), "->"),
  edge((0.5, 0), <mul1>, "->"),
  edge(<mul1>, <mul2>, "->"),
  edge(<mul2>, <add>, "->"),
  edge(<add>, <h_out>, "->"),

  // H_{t-1} 向下分支到 R 门
  edge((0.7, 0), (0.7, 2), (1.2, 2), "-|>"),
  
  // H_{t-1} 向下分支到 Z 门
  edge((1, 0), (1, 1.5), (2.5, 1.5), (2.5, 2), "-|>"),
  
  // H_{t-1} 向下分支到 mul2 (经过 1-Z)
  edge((3.2, 0), (3.2, 1), "-|>"),
  edge((3.2, 1), <one_minus>, "->"),

  // X_t 到 R 门和 Z 门
  edge(<x_label>, (1.2, 3), "-"),
  edge((1.2, 3), <r_gate>, "->"),
  edge((1.2, 3), (2.5, 3), "->"),
  edge((2.5, 3), <z_gate>, "->"),

  // R 门输出到 mul1
  edge(<r_gate>, (1.2, 1), "-"),
  edge((1.2, 1), (1.2, 0.5), (2, 0.5), "-|>"),
  edge((2, 0.5), <mul1>, "->"),

  // mul1 输出分支到 tanh
  edge((2.5, 0), (2.5, -0.3), (4.2, -0.3), (4.2, 2), "-|>"),

  // Z 门输出分支
  edge(<z_gate>, (2.5, 1.5), "-"),
  edge((2.5, 1.5), <one_minus>, "->"),
  edge(<z_gate>, (3, 2), "-"),
  edge((3, 2), <mul3>, "-|>", corner: left),

  // 1-Z 输出到 mul2
  edge(<one_minus>, (3, 0.5), "-"),
  edge((3, 0.5), <mul2>, "-|>", corner: left),

  // tanh 输出
  edge(<tanh>, <mul3>, "->"),
  edge(<tanh>, <h_tilde>, "-->"),

  // mul3 输出到 add
  edge(<mul3>, (4.5, 1), "-"),
  edge((4.5, 1), (4.5, 0.5), (5, 0.5), "-|>"),
  edge((5, 0.5), <add>, "->"),
)
