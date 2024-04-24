#let date(..args, fmt: auto) = {
  let comps = args.pos()
  assert(comps.len() in (1, 2, 3))

  datetime(
    year: comps.at(0),
    month: comps.at(1, default: 01),
    day: comps.at(2, default: 01),
  ).display(fmt)
}

#let chapter = heading.with(level: 1)
