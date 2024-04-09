#let cpp = [C] + text(0.75em, baseline: -0.175em)[++]

#let todo(body) = {
  if body == [] { body = [todo] }
  "["
  text(red, body)
  [#metadata(body) <todo>]
  "]"
}

#let no-cite = todo[Quelle Benötigt]
