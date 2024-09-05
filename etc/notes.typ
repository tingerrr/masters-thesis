#import "@preview/timeliney:0.0.1"

#let consultations = (
  (2024, 04, 25),
  (2024, 05, 16),
  (2024, 06, 13),
  (2024, 06, 26),
  (2024, 07, 18),
  (2024, 07, 29),
  (2024, 08, 14),
  (2024, 09, 05),
  (2024, 09, 20),
)

#import "util.typ": *

#set heading(offset: 1, numbering: (..args) => {
  let nums = args.pos()
  if nums.len() == 1 {
    numbering("I", ..nums)
  } else {
    numbering("1.1", ..nums.slice(1))
  }
})

#show heading.where(level: 1): it => pagebreak(weak: true) + it

#chapter[Initial Notes]
= Publication
- some proprietary code is given, but not relevant for the thesis, anything else may be included for clarity where needed
- references to internal documents like documentation must be available to the public
- thesis must adhere to the FHE style guide #footnote[
    https://ai.fh-erfurt.de/fileadmin/ai_daten/download-bereich/studiendokumente/ba-und-ma-arbeiten/03_AI-Hinweise-BA-MA-Arbeiten_2019-04.pdf
  ]

= Basics
== Core Issues
- arrays in t4gl internally use a copy-on-write mechanism to share memory where possible and avoid expensive clones in the absence of mutating operations
- a common use case for arrays in t4gl are value histories, a snapshot of a value is appended to a history in regular intervals, the resulting array of snapshots can get non-trivially large, such that clones of the date itself are expensive
- if a reader now copies the history array, another modification from the writer thread will cause this thread to eat the cost of the expensive clone
- ideally the cost of cloning the history should be mitigated by reducing how much must be cloned for a modification, or possibly delegated to the reader thread in some way
- copies to other threads always incure a clone, ideally this can be mitigated too
- t4gl already suffers from latencies because of these issues
- the improved data structures *should* have the following time complexities:

#table(columns: 2,
  table.header[Operation][Complexity],
  `clone`, $O(1)$,
  `write`, $O(log n)$,
  `read`, sym.dash.em,
)

== Non-Issues
- generalization to keys other than numeric key types shall not be in scope of the thesis
- allocation is assumed to be constant time
  - this is apparently sufficiently fast for the constraints at hand
- deallocation is assumed to be constant time
	- generally deletion of objects is not a problem for the runtime, it is delegated to another thread
- general data structure implementation
  - the implementation side will be domain (t4gl) specific
  - the algorithm and data structure explanation should be enough to allow reimplementation in other contexts

#chapter[General Timeline]

#timeliney.timeline(show-grid: true, {
  import timeliney: *

  let day(m, d, fmt: auto) = datetime(
    year: 2024,
    month: m,
    day: d,
  ).display(if fmt == auto { "[month repr:short] [day]" } else { fmt })

  let month(m, fmt: auto) = day(m, 01, fmt: if fmt == auto { "[month repr:short]" } else { fmt })

  let date-to-at(m, d) = (m - 4) + (d / 30)
  let ms(m, d, ..args) = milestone(at: date-to-at(m, d), ..args)
  let ts(name, from, to, ..args) = task(name, (date-to-at(..from), date-to-at(..to)), ..args)

  let consultation(m, d) = {
    let num(n) = {
      let suffix = ("1": "st", "2": "nd", "3": "rd").at(str(n), default: "th")
      [#n#super(suffix)]
    }

    let c = counter("consultations")
    let n = context { c.display(num) }
    let body = c.step() + align(center, [
      *#n Cons.* \
      #day(m, d)
    ])

    ms(m, d,
      style: (stroke: (dash: "dashed")),
      body,
    )
  }

  headerline(group(([*2024*], 7)))
  headerline(group(..range(4, 11).map(month)))

  taskgroup(title: [*Thesis*], {
    ts("Writing", (4, 9), (10, 9), style: (stroke: 2pt + gray))
    ts("Research", (4, 9), (6, 30), style: (stroke: 2pt + gray))
    ts("Development", (6, 0), (8, 30), style: (stroke: 2pt + gray))
    ts("Review & Corrections", (9, 0), (10, 9), style: (stroke: 2pt + gray))
    ts("Defense", (10, 9), (10, 30), style: (stroke: 2pt + gray))
  })

  // consultations
  for (_, m, d) in consultations {
    consultation(m, d)
  }

  // end goals
  ms(10, 09,
    style: (stroke: (dash: "dashed")),
    move(dx: -15pt, align(center, [
      *Due Date* \
      #day(10, 09)
    ]))
  )

  ms(10, 20,
    style: (stroke: (dash: "dashed")),
    align(center, [
      *Defense* \
      // TODO: defense date
      #month(10, fmt: "[month repr:short] ??")
    ])
  )
})

#chapter[Consultation Notes]
#let log(d) = {
  let date = date(..d)
  heading(level: 2)[Konsultation #date]

  set heading(offset: 2)
  include "log/" + date + ".typ"
}

#consultations.map(log).join(pagebreak(weak: true))
