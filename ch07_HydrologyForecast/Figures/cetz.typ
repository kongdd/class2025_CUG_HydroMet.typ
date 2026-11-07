#import "@preview/cetz:0.5.3"
#import cetz.draw: content, line, rect, set-style

#let ss = h(0.4em)

#let label(doc, outset: 2pt, color: black, ..args) = {
  box(fill: white, outset: outset, ..args)[#text(fill: color)[#doc]]
}

#let hline(width, y0, ..args) = line((0, y0), (width, y0), ..args)

#let vline(height, x0, ..args) = line((x0, 0), (x0, height), ..args)

// arrow: stealth, triangle, straight, barbed
// vertical arrow
#let v_arrow(height, x0, y0, name: "Q0", arrow: "straight", anchor: "west", ..args) = {
  line(
    (x0, y0),
    (x0, y0 - height),
    mark: (start: "stealth", fill: black),
    name: name,
    ..args,
  )
  content(name + ".mid", label(outset: -1pt, inset: 3pt)[#name], anchor: anchor)
}

// measurement arrow (vertical)
#let mv_arrow(height, x0, y0, text: "Z1", arrow: "stealth", anchor: "east", ..args) = {
  let name = "mv"
  line(
    (x0, y0),
    (x0, y0 - height),
    mark: (end: arrow, start: arrow, fill: black, scale: 0.7),
    name: name,
    ..args,
  )
  content(name + ".mid", label(outset: -1pt, inset: 3pt)[#text], anchor: anchor)
}

// measurement arrow (horizontal)
#let mh_arrow(width, x0, y0, text: "X1", arrow: "stealth", anchor: "north", ..args) = {
  let name = "mh"
  line(
    (x0, y0),
    (x0 + width, y0),
    mark: (end: arrow, start: arrow, fill: black, scale: 0.7),
    name: name,
    ..args,
  )
  content(name + ".mid", label(outset: -1pt, inset: 3pt)[#text], anchor: anchor)
}

// #let y_axis(height, x0, y0, name: "Q0", text: $y$, arrow: "straight", anchor: "south", ..args) = {
//   line(
//     (x0, y0),
//     (x0, y0 + height),
//     mark: (end: "stealth", fill: black),
//     name: name,
//     ..args,
//   )
//   content(name + ".end", label(outset: -1pt, inset: 3pt)[#text], anchor: anchor)
// }

// #let x_axis(width, x0, y0, name: "Q0", text: $x$, arrow: "straight", anchor: "west", ..args) = {
//   line(
//     (x0, y0),
//     (x0 + width, y0),
//     mark: (end: "stealth", fill: black),
//     name: name,
//     ..args,
//   )
//   content(name + ".end", label(outset: -1pt, inset: 3pt)[#text], anchor: anchor)
// }
