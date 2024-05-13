#let (
  list,
  tree,
) = {
  import "/src/util.typ": *
  import fletcher: edge, node

  let list-node = node.with(extrude: (-2, 0))
  // let edge = edge.with(mark: "-|>")

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

  let tree-new = fdiag({
    list-node((0, 0), `t`, name: <root>)
    node((0, 0.5), `A`, name: <A>)
    node((-0.5, 1), `B`, name: <B>)
    node((0.5, 1), `C`, name: <C>)
    node((-1, 1.5), `D`, name: <D>)
    node((0, 1.5), `E`, name: <E>)
    node((1, 1.5), `X`, name: <X>, stroke: (paint: gray, dash: "dashed"))

    edge(<root>, <A>, "->")
    edge(<A>, <B>, "->")
    edge(<A>, <C>, "->")
    edge(<B>, <D>, "->")
    edge(<B>, <E>, "->")
    edge(<C>, <X>, "->", stroke: (paint: gray, dash: "dashed"))
  })

  let tree-shared = fdiag({
    list-node((0, 0), `t`, name: <t-root>)
    node((0, 0.5), `A`, name: <t-A>)
    node((-0.5, 1), `B`, name: <B>, stroke: green)
    node((0.5, 1), `C`, name: <t-C>)
    node((-1, 1.5), `D`, name: <D>, stroke: green)
    node((0, 1.5), `E`, name: <E>, stroke: green)

    edge(<t-root>, <t-A>, "->")
    edge(<t-A>, <B>, "->")
    edge(<t-A>, <t-C>, "->")

    edge(<B>, <D>, "->")
    edge(<B>, <E>, "->")

    list-node((1, 0), `u`, name: <u-root>)
    node((1, 0.5), `A`, name: <u-A>, stroke: red)
    node((1.5, 1), `C`, name: <u-C>, stroke: red)
    node((2, 1.5), `X`, name: <X>)

    edge(<u-A>, <B>, "->")

    edge(<u-root>, <u-A>, "->")
    edge(<u-A>, <u-C>, "->")
    edge(<u-C>, <X>, "->")
  })

  (
    list: (
      new: list-new,
      copy: list-copy,
      pop: list-pop,
      push: list-push,
    ),
    tree: (
      new: tree-new,
      shared: tree-shared,
    )
  )
}


