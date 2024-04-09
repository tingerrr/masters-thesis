#let cpp = [C] + text(0.75em, baseline: -0.175em)[++]

#let todo(body) = [\[] + text(red, if body == [] [todo] else { body }) + [\]]

#let no-cite = todo[Quelle Benötigt]
