#import "@preview/showybox:2.0.3": showybox

#let beamer-block(value) = {
  block(fill: luma(240), inset: 0.6em, stroke: (left: 0.25em))[#value]
}

#let box-blue(it) = {
  showybox(
    it,
    frame: (
      // title-color: red.darken(30%),
      border-color: blue.darken(10%),
      body-color: blue.lighten(95%),
    ),
    // title: [*比热容*]
  )
}

#let box-red(it) = {
  showybox(
    it,
    frame: (
      // title-color: red.darken(30%),
      border-color: red.darken(30%),
      body-color: red.lighten(95%),
    ),
    // title: [*比热容*]
  )
}
