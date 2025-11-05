#import "@preview/fletcher:0.5.6" as fletcher: diagram, node, edge

// 设置页面和文本样式
#set page(width: auto, height: auto, margin: 5mm, fill: white)
#set text(font: "New Computer Modern")

// 绘制流程图
#diagram(
  node-stroke: 1pt,
  node-fill: white,
  edge-stroke: 1pt,
  
  // 节点定义
  node((0, 0), [气孔尺度 g_s]),
  node((0, 1), [植物光合 A]),
  node((2, 0), [土壤水动力]),
  node((4, 0), [theta]),
  // node((6, 0), [未授权副本]),
  node((8, 0), [植物水力]),
  node((10, 0), [psi]),
  node((12, 0), [地表蒸腾]),
  node((14, 0), [蒸腾作用 T]),
  
  // 箭头连接
  edge((0, 0), (2, 0), "->"),
  edge((0, 1), (6, 0), "->"),
  edge((2, 0), (4, 0), "->"),
  // // edge((4, 0), (6, 0), ">"),
  edge((6, 0), (8, 0), "->"),
  edge((8, 0), (10, 0), "->"),
  edge((10, 0), (12, 0), "->"),
  edge((12, 0), (14, 0), "->")
)
