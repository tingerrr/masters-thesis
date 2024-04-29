#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#let cpp = [C] + text(0.75em, baseline: -0.175em)[++]

#let todo(body) = {
  if body == [] { body = [todo] }
  "["
  h(0pt, weak: true)
  text(red, body)
  [#metadata(body) <todo>]
  h(0pt, weak: true)
  "]"
}

#let no-cite = todo[Quelle Benötigt]
