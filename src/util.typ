#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "@preview/cetz:0.2.2"
#import "@preview/fletcher:0.4.4"
#import "@preview/showybox:2.0.1"
#import "@preview/cheq:0.1.0"

#let cpp = [C] + text(0.75em, baseline: -0.175em)[++]

#let _block = block

#let todo(body, block: true) ={
  if body == [] { body = [todo] }

  if block {
    showybox.showybox(
      title: [TODO],
      title-style: (
        weight: 900,
        color: red.darken(40%),
        sep-thickness: 0pt,
      ),
      frame: (
        title-color: red.transparentize(80%),
        border-color: red.darken(40%),
        body-color: white.transparentize(100%),
        thickness: (left: 1pt),
        radius: 0pt,
      ),
      {
        show: cheq.checklist
        [#metadata(body) <todo>]
        body
      },
    )
  } else {
    "["
    h(0pt, weak: true)
    text(red, body)
    [#metadata(body) <todo>]
    h(0pt, weak: true)
    "]"
  }
}

#let no-cite = todo(block: false)[Quelle Benötigt]
