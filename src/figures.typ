#let (
  big-o,
  list,
  t4gl,
  tree,
  finger-tree,
) = {
  import "/src/util.typ": *
  import fletcher: edge, node

  let instance = node.with(extrude: (-2, 0))

  let fdiag = fletcher.diagram.with(
    node-stroke: 0.075em,
    spacing: 4em,
  )

  let dstroke(color, ..args) = (dash: "dashed", paint: color, ..args.named())

  let group(centers, name, color, ..args) = {
    let args = arguments(
      enclose: centers,
      inset: 10pt,
      ..args,
    )

    node(
      hide(name),
      layer: -1,
      stroke: dstroke(color),
      fill: color.lighten(75%),
      ..args,
    )

    node(
      context {
        let size = measure(name)
        // NOTE: align + move ensures the node thinks the text is inside, ensuring the text is not
        // hyphenated unecessarily
        align(top + left, move(
          dy: -(size.height + 10pt + 0.5em),
          dx: -10pt,
          box(fill: white, outset: 1pt, name),
        ))
      },
      layer: 1,
      stroke: none,
      fill: none,
      ..args,
    )
  }

  //
  // big-o
  //
  let big-o-def = $
    O(f) &= {
      g : NN -> NN | exists n_0, c > 0
      quad &&forall n >= n_0
      quad 0 <= g(n) <= c f(n)
    } \
    Omega(f) &= {
      g : NN -> NN | exists n_0, c > 0
      quad &&forall n >= n_0
      quad 0 <= c f(n) <= g(n)
    } \
    Theta(f) &= {
      g : NN -> NN | exists n_0, c_1, c_2 > 0
      quad &&forall n >= n_0
      quad c_1 f(n) <= g(n) <= c_2 f(n)
    }
  $

  //
  // linked lists
  //
  let list-new = fdiag({
    instance((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`)
    edge("-|>")
    node((1, 0), `B`)
    edge("-|>")
    node((1.5, 0), `C`)
  })

  let list-copy = fdiag({
    instance((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`, stroke: green)
    edge("-|>")
    node((1, 0), `B`, stroke: green)
    edge("-|>")
    node((1.5, 0), `C`, stroke: green)
    instance((0, 0.5), `m`)
    edge((0.5, 0), "-|>")
  })

  let list-pop = fdiag({
    instance((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`)
    edge("-|>")
    node((1, 0), `B`, stroke: green)
    edge("-|>")
    node((1.5, 0), `C`, stroke: green)
    instance((0, 0.5), `m`)
    edge((1, 0), "-|>")
  })

  let list-push = fdiag({
    instance((0, 0), `l`)
    edge("-|>")
    node((0.5, 0), `A`)
    edge("-|>")
    node((1, 0), `B`, stroke: green)
    edge("-|>")
    node((1.5, 0), `C`, stroke: green)
    instance((0, 0.5), `m`)
    edge("-|>")
    node((0.5, 0.5), `D`)
    edge((1, 0), "-|>")
  })

  //
  // t4gl arrays
  //
  let _t4gl(..args) = fdiag(..args, render: (grid, nodes, edges, options) => {
    fletcher.cetz.canvas({
      fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)
      import fletcher.cetz.draw: *

      // TODO: draw groups and group names manually here if need be
    })
  })

  let t4gl-new = fdiag({
    instance((0, 0), `a`, name: <i>)
    edge("-|>")
    instance((0, 0.5), `storage`, name: <s>)
    edge("-|>")
    node((0, 1), `buffer`, name: <b>)
  })

  let t4gl-shallow = fdiag({
    instance((-0.5, 0), `a`, name: <i_a>)
    edge("-|>")
    instance((0, 0.5), `shared storage`, name: <s>, stroke: green)
    edge("-|>")
    node((0, 1), `buffer`, name: <b>, stroke: green)

    instance((0.5, 0), `b`, name: <i_b>)
    edge(<i_b>, <s>, "-|>")
  })

  let t4gl-deep-new = fdiag({
    instance((-0.5, 0), `a`, name: <i_a>)
    instance((0.5, 0), `c`, name: <i_c>)

    instance((-0.5, 0.5), `storage a`, name: <s_a>)
    instance((0.5, 0.5), `storage c`, name: <s_c>, stroke: red)

    node((0, 1), `shared buffer`, name: <b>, stroke: green)

    edge(<i_a>, <s_a>, "-|>")
    edge(<i_c>, <s_c>, "-|>")
    edge(<s_c>, <b>, "-|>")
    edge(<s_a>, <b>, "-|>")
  })

  let t4gl-deep-mut = fdiag({
    instance((-0.5, 0), `a`, name: <i_a>)
    instance((0.5, 0), `c`, name: <i_c>)

    instance((-0.5, 0.5), `storage a`, name: <s_a>)
    instance((0.5, 0.5), `storage c`, name: <s_c>)

    node((-0.5, 1), `buffer a`, name: <b_a>)
    node((0.5, 1), `buffer c`, name: <b_c>, stroke: red)

    edge(<i_a>, <s_a>, "-|>")
    edge(<i_c>, <s_c>, "-|>")
    edge(<s_a>, <b_a>, "-|>")
    edge(<s_c>, <b_c>, "-|>")
  })

  //
  // trees
  //
  let tree-new = fdiag({
    instance((0, 0), `t`, name: <root>)
    node((0, 0.5), `A`, name: <A>)
    node((-0.5, 1), `B`, name: <B>)
    node((0.5, 1), `C`, name: <C>)
    node((-1, 1.5), `D`, name: <D>)
    node((0, 1.5), `E`, name: <E>)
    node((1, 1.5), `X`, name: <X>, stroke: dstroke(gray))

    edge(<root>, <A>, "-|>")
    edge(<A>, <B>, "-|>")
    edge(<A>, <C>, "-|>")
    edge(<B>, <D>, "-|>")
    edge(<B>, <E>, "-|>")
    edge(<C>, <X>, "-|>", stroke: dstroke(gray))
  })

  let tree-shared = fdiag({
    instance((0, 0), `t`, name: <t-root>)
    node((0, 0.5), `A`, name: <t-A>)
    node((-0.5, 1), `B`, name: <B>, stroke: green)
    node((0.5, 1), `C`, name: <t-C>)
    node((-1, 1.5), `D`, name: <D>, stroke: green)
    node((0, 1.5), `E`, name: <E>, stroke: green)

    edge(<t-root>, <t-A>, "-|>")
    edge(<t-A>, <B>, "-|>")
    edge(<t-A>, <t-C>, "-|>")

    edge(<B>, <D>, "-|>")
    edge(<B>, <E>, "-|>")

    instance((1, 0), `u`, name: <u-root>)
    node((1, 0.5), `A`, name: <u-A>, stroke: red)
    node((1.5, 1), `C`, name: <u-C>, stroke: red)
    node((2, 1.5), `X`, name: <X>)

    edge(<u-A>, <B>, "-|>")

    edge(<u-root>, <u-A>, "-|>")
    edge(<u-A>, <u-C>, "-|>")
    edge(<u-C>, <X>, "-|>")
  })

  //
  // finger-tree
  //

  let finger-tree = fdiag({
    let elem = node.with(radius: 7.5pt)
    let spine = node.with(radius: 7.5pt, fill: blue.lighten(75%))
    let node = node.with(radius: 5pt, fill: gray.lighten(50%))

    let elems(coord, data, parent: none, ..args) = {
      let parent = if parent != none { parent } else {
        label(str(data.first()) + "-" + str(data.last()))
      }
      let (x, y) = coord
      let deltas = range(0, data.len()).map(dx => dx * 0.3)
      let deltas = deltas.map(dx => dx - deltas.last() / 2)

      for (e, dx) in data.zip(deltas) {
        let l = label(str(e))

        elem((x + dx, y), raw(str(e)), name: l, ..args)
        edge(parent, l, "-|>")
      }
    }

    let fill-digit-elem = gradient.linear(angle: 45deg, teal.lighten(50%), white).sharp(2)
    let fill-digit-node = gradient.linear(angle: 45deg, teal.lighten(50%), gray).sharp(2)

    instance((0, -0.5), `t`)
    edge("-|>")
    spine((0, 0), name: <l1>)
    edge("-|>")
    spine((0, 0.5), name: <l2>)
    edge("-|>")
    spine((0, 1), name: <l3>)
    edge("-|>")
    spine((0, 1.5), name: <l4>)

    elems((-3.15, 1.25), (1, 2, 3), parent: <l1>, fill: fill-digit-elem)
    elems((2.15, 1.25), (20, 21), parent: <l1>, fill: fill-digit-elem)

    node((-2.45, 1.25), name: <4-5>, fill: fill-digit-node)
    node((-1.7, 1.25), name: <6-8>, fill: fill-digit-node)
    node((1.7, 1.25), name: <18-19>, fill: fill-digit-node)

    elems((-2.45, 1.75), (4, 5))
    elems((-1.7, 1.75), (6, 7, 8))
    elems((1.7, 1.75), (18, 19))

    edge(<l2>, <4-5>, "-|>")
    edge(<l2>, <6-8>, "-|>")
    edge(<l2>, <18-19>, "-|>")

    node((-0.725, 1.25), name: <9-12>, fill: fill-digit-node)
    node((0.725, 1.25), name: <13-17>, fill: fill-digit-node)

    node((-1.1, 1.75), name: <9-10>)
    node((-0.35, 1.75), name: <11-12>)
    node((0.35, 1.75), name: <13-14>)
    node((1.1, 1.75), name: <15-17>)

    elems((-1.1, 2.25), (9, 10))
    elems((-0.35, 2.25), (11, 12))
    elems((0.35, 2.25), (13, 14))
    elems((1.1, 2.25), (15, 16, 17))

    edge(<l3>, <9-12>, "-|>")
    edge(<9-12>, <9-10>, "-|>")
    edge(<9-12>, <11-12>, "-|>")

    edge(<l3>, <13-17>, "-|>")
    edge(<13-17>, <13-14>, "-|>")
    edge(<13-17>, <15-17>, "-|>")
  })

  (
    big-o-def,
    (
      new: list-new,
      copy: list-copy,
      pop: list-pop,
      push: list-push,
    ),
    (
      new: t4gl-new,
      shallow: t4gl-shallow,
      deep-new: t4gl-deep-new,
      deep-mut: t4gl-deep-mut,
    ),
    (
      new: tree-new,
      shared: tree-shared,
    ),
    finger-tree,
  )
}

#let complexity-comparison(
  cases: ([worst], [average], [best]),
  columns,
  ..args,
) = {
  let headers = columns.keys()
  let rows = (:)
  for (column, entry) in columns {
    for key in entry.keys() {
      if key not in rows {
        rows.insert(key, (:))
      }

      if column not in entry.at(key) {
        rows.at(key).insert(column, ())
      }

      for idx in range(cases.len()) {
        let comp = entry.at(key).at(idx)
        rows.at(key).at(column).push(if comp == none [-] else { comp })
      }
    }
  }

  let column-gutter = (
    ..(0.5em,) + ((0pt,) * (cases.len() - 1)),
  ) * (columns.len() + 1)

  table(
    columns: 1 + columns.len() * cases.len(),
    stroke: none,
    align: (x, y) => if y > 1 { left } else { center },
    column-gutter: column-gutter,
    ..args.named(),
    table.header(
      [Operation], ..headers.map(table.cell.with(colspan: cases.len(), stroke: (bottom: 0.5pt))),
      none, ..(cases * columns.len()),
      table.hline(stroke: 0.5pt),
    ),
    ..rows.pairs().map(((op, entries)) => {
      (op, ..headers.map(header => {
        entries.at(header, default: ([-], ) * 3)
      }))
    }).flatten()
  )
}
