#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// --- 样式定义 (Pastel Style) ---
#let c-bg-main = rgb("ffffff")
#let c-blue = rgb("dcebf7")
#let c-blue-s = rgb("7daecc")
#let c-yellow = rgb("fff2cc")
#let c-yellow-s = rgb("d6b656")
#let c-orange = rgb("fce5cd")
#let c-orange-s = rgb("e69138")
#let c-text = rgb("333333")

// 节点样式封装
#let gate-node(pos, label, name: none) = {
  node(
    pos,
    align(center)[#math.sigma \ #label],
    fill: c-blue,
    stroke: 1pt + c-blue-s,
    shape: rect,
    width: 2em,
    height: 2.2em,
    corner-radius: 3pt,
    name: name,
  )
}

#let tanh-node(pos, name: none) = {
  node(
    pos,
    text(10pt)[tanh],
    fill: c-blue,
    stroke: 1pt + c-blue-s,
    shape: rect,
    width: 2.5em,
    height: 1.8em,
    corner-radius: 3pt,
    name: name,
  )
}

#let op-node(pos, label, name: none) = {
  node(
    pos,
    text(12pt, weight: "bold")[#label],
    fill: c-blue,
    stroke: 1pt + c-blue-s,
    shape: circle,
    radius: 0.6em,
    name: name,
  )
}

#let op-one-minus(pos, name: none) = {
  node(
    pos,
    text(10pt)[$1-$],
    fill: c-blue,
    stroke: 1pt + c-blue-s,
    shape: circle,
    radius: 0.7em,
    name: name,
  )
}

#set page(width: auto, height: auto, margin: 1cm)

// --- 布局绘制 ---
#stack(
  dir: ltr,
  spacing: 2em,
  
  // 图形主体
  diagram(
    spacing: (1.2cm, 1cm),
    node-stroke: 1pt,
    edge-stroke: 1pt + c-text,
    mark-scale: 60%,
    label-sep: 2pt,
    
    // 1. 输入与主干
    node((0, 0), text(12pt)[${H}_{t-1}$], name: <h_prev>),
    node((0, 5), text(12pt)[${X}_t$], name: <x_t>),
    
    // 2. 门控层 (Gates)
    // 重置门 R (Reset Gate)
    gate-node((2, 3), ${R}_t$, name: <gate_r>),
    // 更新门 Z (Update Gate)
    gate-node((3, 3), ${Z}_t$, name: <gate_z>),
    
    // 3. Reset 运算逻辑
    // H 往下走，与 R 相乘
    op-node((2, 2), $dot$, name: <op_reset_mul>),
    
    // 4. 候选隐状态 (Candidate)
    // 接收 Reset 后的 H 和 X
    tanh-node((4, 3), name: <tanh>),
    node((5.2, 3), $tilde{{H}}_t$), // 标注
    
    // 5. Update 运算逻辑
    // 路径 A: Z * H_prev (保留旧信息)
    op-node((3, 0), $dot$, name: <op_z_mul_h>),
    
    // 路径 B: (1-Z) * H_tilde (写入新信息)
    op-one-minus((3.5, 1.5), name: <op_one_minus>),
    op-node((4, 1.5), $dot$, name: <op_new_mul>),
    
    // 聚合 +
    op-node((4, 0), $+$, name: <op_final_add>),
    
    // 输出
    node((5.5, 0), text(12pt)[${H}_t$], name: <h_next>),
    
    // --- 连线 (Edges) ---
    
    // 输入 X_t 分发
    edge(<x_t>, <gate_r>, "-|>", corner: right),
    edge(<x_t>, <gate_z>, "-|>", corner: right),
    edge(<x_t>, <tanh>, "-|>", corner: right),
    
    // H_t-1 主干向右
    edge(<h_prev>, <op_z_mul_h>, "->"),
    
    // H_t-1 分发到门控
    edge((0.5, 0), <gate_r>, "-|>", corner: left), // H -> R
    edge((0.8, 0), <gate_z>, "-|>", corner: left), // H -> Z
    
    // Reset 逻辑: H -> op_reset <- R
    edge((1.2, 0), <op_reset_mul>, "->"), // H branch to mul
    edge(<gate_r>, <op_reset_mul>, "->"), // R output to mul
    edge(<op_reset_mul>, <tanh>, "-|>", corner: right), // (H*R) -> tanh
    
    // Update 逻辑
    // Z 分发
    edge(<gate_z>, <op_z_mul_h>, "->"), // Z -> top mul
    edge(<gate_z>, <op_one_minus>, "->", corner: right), // Z -> 1-
    
    // path 1-Z
    edge(<op_one_minus>, <op_new_mul>, "->"),
    
    // Candidate H_tilde 进 mix
    edge(<tanh>, <op_new_mul>, "->"),
    
    // 汇聚到主干
    edge(<op_z_mul_h>, <op_final_add>, "->"),
    edge(<op_new_mul>, <op_final_add>, "->"),
    
    // 最终输出
    edge(<op_final_add>, <h_next>, "->"),
  ),
)

#v(1em)

// --- 公式标注 (数学公式渲染) ---
#align(center)[
  #block(
    fill: rgb("f9f9f9"),
    stroke: 1pt + rgb("e0e0e0"),
    inset: 1em,
    radius: 5pt,
    width: 90%,
    [
      #set text(font: "New Computer Modern Math", size: 10pt)
      $
        "更新门" quad & {Z}_t = sigma({X}_t {W}_{"xz"} + {H}_{t-1} {W}_{"hz"} + {b}_z) \
        "重置门" quad & {R}_t = sigma({X}_t {W}_{"xr"} + {H}_{t-1} {W}_{"hr"} + {b}_r) \
        "候选态" quad & tilde{{H}}_t = tanh({X}_t {W}_{"xh"} + ({R}_t dot {H}_{t-1}) {W}_{"hh"} + {b}_h) \
        "隐状态" quad & {H}_t = {Z}_t dot {H}_{t-1} + (1 - {Z}_t) dot tilde{{H}}_t \
        "输  出" quad & {Y}_t = {H}_t {W}_{"hq"} + {b}_q
      $
    ],
  )
]
