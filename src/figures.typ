#let (
  list,
) = {
  import "/src/util.typ": *
  import fletcher: edge, node

  let list-node = node.with(extrude: (-2, 0))

  let fdiag = fletcher.diagram.with(
    node-stroke: .075em,
    spacing: 4em,
  )

  let list-new = fdiag({
    list-node((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`)
    edge("-|>")
    node((1, 0), `B`)
    edge("-|>")
    node((1.5, 0), `C`)
  })

  let list-copy = fdiag({
    list-node((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`)
    edge("-|>")
    node((1, 0), `B`)
    edge("-|>")
    node((1.5, 0), `C`)
    list-node((0, 0.5), `m`)
    edge((0.5, 0), "-|>")
  })

  let list-pop = fdiag({
    list-node((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`)
    edge("-|>")
    node((1, 0), `B`)
    edge("-|>")
    node((1.5, 0), `C`)
    list-node((0, 0.5), `m`)
    edge((1, 0), "-|>")
  })

  let list-push = fdiag({
    list-node((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`)
    edge("-|>")
    node((1, 0), `B`)
    edge("-|>")
    node((1.5, 0), `C`)
    list-node((0, 0.5), `m`)
    edge("-|>")
    node((0.5, 0.5), `D`)
    edge((1, 0), "-|>")
  })

  (
    list: (
      new: list-new,
      copy: list-copy,
      pop: list-pop,
      push: list-push,
    ),
  )
}


