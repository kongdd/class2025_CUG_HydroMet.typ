#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.2": plot

#import "cetz.typ": *

#show "{": ""
#show "}": ""

#let b = 0.4
#let cal_MM(x) = 1 - calc.pow(1 - x, 1 / b)
#let cal_a(MM) = 1 - calc.pow(1 - MM, b)

#let SM = "SM"
#let a0 = 0.2
#let MM0 = cal_MM(a0)
#let MM1 = 0.65
#let a1 = cal_a(MM1)

#let MM = "MM"
#let WM = "WM"
#let WMM = $"WM"_max$
// #let WMM = "WMM"
#let dWM = $d"WM"$

#let ifelse(con, a, b) = if (con) { a } else { b }

#let h_arrow(width, x0, y0, name: "Q0", text: none, arrow: "straight", anchor: "west", ..args) = {
  line(
    (x0, y0),
    (x0 + width, y0),
    mark: (end: "stealth", fill: black),
    name: name,
    ..args,
  )
  content(name + ".end", label(outset: -1pt, inset: 3pt)[#text], anchor: anchor)
}

#let v_arrow(height, x0, y0, name: "Q0", text: none, arrow: "straight", anchor: "west", ..args) = {
  line(
    (x0, y0),
    (x0, y0 - height),
    mark: (end: "stealth", fill: black),
    name: name,
    ..args,
  )
  content(name + ".end", label(outset: -1pt, inset: 3pt)[#text], anchor: anchor)
}

#let axis-config = (
  size: (1, 1),
  axis-style: "left",
  x-label: [$bold(alpha)$], // Y轴标题
  x-tick-step: none,
  y-tick-step: none,
  y-min: 0,
  y-max: 1,
  x-min: 0,
  x-max: 1,
)

#let label-title(title) = {
  content((-0.15, 0.94), text(fill: black, size: 13pt)[#title])
}


#let fig-S1 = cetz.canvas(length: 50mm, {
  set-style(stroke: (thickness: 0.8pt))
  set-style(
    axes: (stroke: 0.7pt, tick: (stroke: .5pt)),
    legend: (stroke: none, orientation: ttb, item: (spacing: .3), scale: 80%),
  )

  plot.plot(
    y-label: [$bold("SM")$], // X轴标题
    ..axis-config,
    {
      plot.add(cal_MM, domain: (0, 1))
      // W
      plot.add-fill-between(
        domain: (0, 0.4),
        style: (fill: black.lighten(90%), stroke: none),
        x => ifelse(x > a0, MM0, cal_MM(x)),
        x => { 0 },
      )
      // dW
      // plot.add-fill-between(
      //   domain: (a0, 0.4),
      //   style: (fill: blue.lighten(80%), stroke: none),
      //   x => ifelse(x > a1, MM1, cal_MM(x)),
      //   x => { MM0 },
      // )
      // RS1
      plot.add-fill-between(
        domain: (0, a0),
        style: (fill: green.lighten(80%), stroke: none),
        x => { MM0 },
        x => cal_MM(x),
      )
    },
  )

  hline(1, 1, stroke: (dash: "dashed", paint: black.lighten(60%)))
  vline(1, 1, stroke: (dash: "dashed", paint: black.lighten(60%)))

  vline(MM0, 0.4, stroke: (dash: "dashed", paint: red.lighten(20%), thickness: 1.5pt))

  line((0, MM0), (1.0, MM0), stroke: (dash: "dashed", paint: blue.lighten(40%)))
  // line((0, MM1), (1, MM1), stroke: (dash: "solid", paint: blue.lighten(40%)))

  content((0.25, 0.2), text(fill: black)[$bold(S_1)$])
  // content((0.34, (MM0 + MM1) / 2), text(fill: blue)[$bold(Delta S)$])

  content((0.5, 1.07), $bold(alpha) = 1 - (1 - SM/SM_max)^"EX"$)

  content((a1 / 2 - 0.08, MM0 / 2 + 0.16), text(size: 9pt, fill: green)[$bold("RS"_1)$])
  // mv_arrow(MM1 - MM0, -0.04, MM1, text: $"R"$)
  mv_arrow(MM0 - 0, -0.04, MM0, text: $"AU"$)

  mh_arrow(0.4, 0, -0.02, text: $"FR"_1$, anchor: "north", stroke: (paint: blue, thickness: 0.5pt))

  let mar = 0.035
  v_arrow(0.1, 0.35, 0.015, name: "RG", text: $bold("RG")$, anchor: "north")
  h_arrow(0.1, 0.4 - mar, name: "RI", text: $bold("RI")$, 0.1)

  label-title($bold((a))$) // title
})


#let fig-S = cetz.canvas(length: 50mm, {
  set-style(stroke: (thickness: 0.8pt))
  set-style(
    axes: (stroke: 0.7pt, tick: (stroke: .5pt)),
    legend: (stroke: none, orientation: ttb, item: (spacing: .3), scale: 80%),
  )

  let a0 = a0 - 0.05
  let MM0 = cal_MM(a0)

  plot.plot(
    y-label: [$bold("SM")$], // X轴标题
    ..axis-config,
    {
      plot.add(cal_MM, domain: (0, 1))
      // W
      plot.add-fill-between(
        domain: (0, 0.5),
        style: (fill: black.lighten(90%), stroke: none),
        x => ifelse(x > (a0), MM0, cal_MM(x)),
        x => { 0 },
      )
      // dW
      plot.add-fill-between(
        domain: (a0, 0.5),
        style: (fill: blue.lighten(80%), stroke: none),
        x => ifelse(x > a1, MM1, cal_MM(x)),
        x => { MM0 },
      )
      // dR
      plot.add-fill-between(
        domain: (0, a1),
        style: (fill: green.lighten(80%), stroke: none),
        x => { MM1 },
        x => ifelse(x < a0, MM0, cal_MM(x)),
      )
    },
  )

  vline(MM0, 0.4, stroke: (dash: "dashed", paint: red.lighten(20%), thickness: 1.5pt))

  hline(1, 1, stroke: (dash: "dashed", paint: black.lighten(60%)))
  vline(1, 1, stroke: (dash: "dashed", paint: black.lighten(60%)))

  line((0, MM0), (1, MM0), stroke: (dash: "dashed", paint: blue.lighten(40%)))
  line((0, MM1), (1, MM1), stroke: (dash: "solid", paint: blue.lighten(40%)))

  // content((0.23, 0.10), text(fill: black)[$bold((SM_1 times "FR"_1) / "FR")$])
  content((0.23, 0.10), text(fill: black)[$bold(S_1)$])
  content((0.37, (MM0 + MM1) / 2), text(fill: blue)[$bold(Delta"S")$])

  content((0.5, 1.07), $bold(alpha) = 1 - (1 - SM/SM_max)^"EX"$)
  content((a1 / 2 - 0.05, (MM0 + MM1) / 2), text(fill: green)[$bold("RS")$])

  let mar = 0.035
  v_arrow(0.1, 0.42, 0.015, name: "RG", text: $bold("RG")$, anchor: "north")
  h_arrow(0.1, 0.5 - mar, name: "RI", text: $bold("RI")$, 0.1)

  mv_arrow(MM1 - MM0, -0.04, MM1, text: $"R"$)
  mv_arrow(MM0 - 0, -0.04, MM0, text: $"AU"'$)

  mh_arrow(0.5, 0, -0.02, text: $"FR"$, anchor: "north", stroke: (paint: blue, thickness: 0.5pt))

  label-title($bold((b))$) // title
})

#figure(
  grid(
    columns: 2,
  )[#fig-S1][#fig-S],
  caption: [
    新安江模型自由水蓄量曲线。流域内每个网格都有一个自由水蓄量$s_i$，将所有网格的$s_i$从小到大排序后，拟合的曲线，即为流域的自由水容量曲线。

    （a）前期自由水容量为0的涨水过程；（b）前期自由水容量为$S_1$的涨水过程。
  ],
) <fig_>
