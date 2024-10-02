#import "/src/util.typ": fletcher, touying

#import touying: *
#import themes.university: *

#import "/src/figures.typ"

#pdfpc.config(
  duration-minutes: 20,
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
)

#show: university-theme.with(
  aspect-ratio: "16-9",
  header-right: self => utils.display-current-heading(level: 1),
  config-info(
    title: [Dynamische Datensturkturen unter Echtzeitbedingungen],
    author: [Erik Bünnig],
    date: datetime(year: 2024, month: 10, day: 21),
    institution: [Fachhochschule Erfurt],
    // TODO: move to template
    logo: image("/assets/logo-fhe.svg", width: 25%),
  ),
)

#set text(lang: "de")
#set raw(syntaxes: "/assets/t4gl.sublime-syntax")

#title-slide()

#{
  // NOTE: resetting the styles afterwards doesn't fix the footer size issue
  set text(size: 20pt)
  outline(indent: 1em)
}

= ?
#slide(repeat: 4, self => [
  #pdfpc.speaker-note(
    ```md
    - explain both terms shortly
    - explain how dyn data structures make real-time anlysis harder
    - segway into t4gl being a system where both are relevant
    ```
  )

  #let (uncover, only, alternatives) = utils.methods(self)

  #set align(center + horizon)

  #alternatives[
    #set align(center + horizon)
    #set text(42pt)
    *Dynamische Datenstrukturen \ unter Echtzeitbedingungen*
  ][
    #set align(center + horizon)
    #set text(42pt)
    *#text(red)[Dynamische Datenstrukturen] \ unter Echtzeitbedingungen*
  ][
    #set align(center + horizon)
    #set text(42pt)
    *Dynamische Datenstrukturen \ unter #text(red)[Echtzeitbedingungen]*
  ][
    #set align(center + horizon)
    #set text(42pt)
    *#text(red)[Dynamische Datenstrukturen \ unter Echtzeitbedingungen]*
  ]
])

= T4gl
#pdfpc.speaker-note(
  ```md
  - machines where t4gl is used: HSU, LUB, , etc.
  - signal analysis may happen post measurement or during
  - analysis during measurement requires repeated execution in a certian time
    due to the iterative nature of measuring tires
  - t4gl programs are compiled to microsteps which are executed in a "generation"
  - generations are usually 1ms long and each t4gl green thread receives a
    certain number of slots in which to execute its steps
  - therein lies a major problem, generations have a fixed length, but data has
    variable length at run time
  ```
)

- Was ist T4gl?
  #pause
  - Es ist eine Programmiersprache, ein Kompiler und ein Laufzeitsystem
  #pause
- Wo kommt T4gl zum Einsatz?
  #pause
  - Verschiedene Industrieprüfmaschinen in der Automobil- und Reifenindustrie
  #pause
- Was hat das mit Echtzeit zutun?
  #pause
  - T4gl-Programme kommen vorallem für Verarbeitung von Messsignalen verwendet

#slide(repeat: 2, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #alternatives[
    `src/foo.t4gl`
    ```t4gl
    void ()
    {
      String[Double, Integer] array
      array[3.14, 42] = "Hello World"

      forEach (String[Integer] values : array) {
        // ...
      }
    }
    ```
  ][
    `src/foo.cpp`
    ```cpp
    void foo() {
      std::map<double, std::map<int, std::string>> array;
      array[3.14] = std::map();
      array[3.14][42] = "Hello World";

      for (const auto& values : array) {
        // ...
      }
    }
    ```
  ]
])

#pdfpc.speaker-note(
  ```md
  - channels with history annotations are often used for elaborate signal
    processing
  - histories incur complete copies because of the underlying data strucutres
  - in the worst case it's copied once each generation (n / ms)
  ```
)


`src/global.t4gl`
```t4gl
global
{
  @history(0:05.0)
  Double channel <- foo * bar - qux
}
```

#pause

`src/foo.t4gl`
```t4gl
void ()
{
  channel.getHistory() // 5.000 copies
}
```

---

#pdfpc.speaker-note(
  ```md
  - examples from the LUB5 repository
  - other uses may be even higher
  ```
)

```sh
❯ rg -tt4gl '@history'
logic/test/leakageBefore/global.t4gl
24:    @history(1:00.0)

logic/test/leakageAfter/global.t4gl
24:    @history(1:00.0)

logic/test/rimWidthAdjustment/global.t4gl
24:    @history(10:00.0)
26:    @history(10:00.0)
```

---

#let tmsec = math.upright("ms")
#let tsec = math.upright("s")
#let tmin = math.upright("min")

$
  10tmin
  pause dot.c 60 tsec / tmin
  pause dot.c 1.000 tmsec / tsec
  pause = 600.000 tmsec
$

#pause

`src/foo.t4gl`
```t4gl
void ()
{
  channel.getHistory() // 600.000 copies
}
```

= Qt, QMaps & QProbleme
#slide(repeat: 6, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #uncover("2-")[- Qt ist sehr tief in T4gl integriert]
  #uncover("3-")[- T4gl-Arrays bauen auf QMaps auf, einer CoW-Datenstruktur]
  #uncover("6-")[- QMaps kopieren mehr als sie müssen]

  #only(4)[
    ```cpp
    std::map<int, std::string> map;
    map.insert(0, "Hello World");

    std::map<int, std::string> other = map;
    other.insert(1, "Goodbye World");
    ```
  ]
  #only("5-6")[
    ```cpp
    QMap<int, std::string> map;
    map.insert(0, "Hello World");

    QMap<int, std::string> other = map;
    other.insert(1, "Goodbye World");
    ```
  ]
])

= Persistenz
#pdfpc.speaker-note(
  ```md
  - not writing into data directly enables easy sharing of common data
  - each instance of a sequence data structure is very similar to the last after
    each write
  - new instances are copies of old instances with the new change
    (removal/insertion/etc.)
  - QMaps are CoW in the most primitive form of persistence, a core building
    block
  ```
)

#pause

- persistente Datenstrukturen sind solche, welche nicht direkt in die Daten schreiben auf die sie verweisen
  #pause
- jeder Schreibzugriff erzeugt eine neue veränderte Instanz
  #pause
- QMaps sind also persistent

#focus-slide[
  Aber wie hilft das, weniger Daten zu kopieren?
]

#pdfpc.speaker-note(
  ```md
  - could be done using a linked list of chunks
  - no improvement in the order of time complexity, chunking would simply changeI
    the constant factor
  - applying this recursively however, yields better results
  ```
)

#pause

- Was wäre, wenn wir die Sequenzen in Chunks teilen?
  #pause
- Jeder unveränderte Chunk wird beim Kopieren zwischen Instanzen geteilt
  #pause
- Immer noch $Theta(n)$...

---

#import "/src/figures/util.typ": *

#let t = {
  instance((0, 0), `t`, name: <t-root>)
  node((0, 0.5), `A`, name: <t-A>)
  node((0.5, 1), `C`, name: <t-C>)

  edge(<t-root>, <t-A>, "-|>")
  edge(<t-A>, <t-B>, "-|>")
  edge(<t-A>, <t-C>, "-|>")
  edge(<t-B>, <t-D>, "-|>")
  edge(<t-B>, <t-E>, "-|>")
}

#let t-new = t + {
  node((-0.5, 1), `B`, name: <t-B>)
  node((-1, 1.5), `D`, name: <t-D>)
  node((0, 1.5), `E`, name: <t-E>)

  node((1, 1.5), `X`, name: <t-X>, post: cetz.draw.hide)
}

#let t-shared = t + {
  node((-0.5, 1), `B`, name: <t-B>, stroke: green)
  node((-1, 1.5), `D`, name: <t-D>, stroke: green)
  node((0, 1.5), `E`, name: <t-E>, stroke: green)
}

#let t-hinted = t + {
  node((-0.5, 1), `B`, name: <t-B>)
  node((-1, 1.5), `D`, name: <t-D>)
  node((0, 1.5), `E`, name: <t-E>)

  node((1, 1.5), `X`, name: <t-X>, stroke: dstroke(gray))
  edge(<t-C>, <t-X>, "-|>", stroke: dstroke(gray))
}

#let t-shared-hinted = t-shared + {
  node((1, 1.5), `X`, name: <t-X>, stroke: dstroke(gray))
  edge(<t-C>, <t-X>, "-|>", stroke: dstroke(gray))
}

#let u = {
  instance((1, 0), `u`, name: <u-root>)
  node((1, 0.5), `A`, name: <u-A>, stroke: red)
  node((1.5, 1), `C`, name: <u-C>, stroke: red)

  edge(<u-A>, <t-B>, "-|>")

  edge(<u-root>, <u-A>, "-|>")
  edge(<u-A>, <u-C>, "-|>")
}

#let u-new = u + {
  node((2, 1.5), `X`, name: <u-X>, post: cetz.draw.hide)
}

#let u-shared = u + {
  node((2, 1.5), `X`, name: <u-X>)
  edge(<u-C>, <u-X>, "-|>")
}

#slide(repeat: 4, self => [
  #pdfpc.speaker-note(
    ```md
    - note that there are more green than red notes
    - note how this generalizes for deeper trees
    - only guarantees better complexity if tree is balanced
    - segway to trees
    ```
  )

  #let (uncover, only, alternatives) = utils.methods(self)

  #alternatives(
    ..(
      t-new,
      t-hinted,
      t-shared-hinted + u-new,
      t-shared + u-shared,
    )
    // poor man's align(center)
    .map(d => h(6.25em) + fdiag(d)),
  )
])

= Bäume Bäume Bäume
#pdfpc.speaker-note(
  ```md
  - 3 specializations of the b-tree for various use cases
  - all structures are presistence friendly, but need not be persistent
  ```
)

- B-Baum
- SRB-Baum
- 2-3-Fingerbaum

== B-Baum
#pdfpc.speaker-note(
  ```md
  - mccreight: "the more you think about what the b in b-trees stands for, the more you understand b-trees"
  - simple but effective search tree
  - generic over its branching factors (with some rules)
  - comes in various types
  - works for any key type that can be totally ordered in some way
  ```
)

#pause

- _engl._ #text(red)[???] tree
  #pause
- Grundbaustein eines jeden Informatikers
  #pause
- balancierter Suchbaum
  #pause
- funktioniert mit allen Schlüsseltypen, welche eine totale Ordnungsrelation besitzen
  #pause
- `search`, `insert`, `remove`: $Theta(log n)$

#pause

#align(center + horizon, figures.b-tree.node)

== SRB-Baum
#pdfpc.speaker-note(
  ```md
  - perfect balancing enables radix search on every level
  - nodes are sparse (not every key is contained)
  - complexity upper bounded by key width
  - can be extended to signed integers wiht some 2's-complement math
  ```
)

#pause

- _engl._ sparse radix balanced tree
  #pause
- Spezialisierung von Radix-Bäumen
  #pause
- inherent perfekt balanciert, muss nicht umbalanciert werden
  #pause
- Pfadindizes können vor der Suche errechnet werden
  #pause
- funktioniert nur mit Ganzzahltypen
  #pause
- `search`, `insert`, `remove`: $Theta(log 2^b)$

---

#pdfpc.speaker-note(
  ```md
  - blue keys are indices from contianed keys
  - need extra field storing the dead nodes (as bit field)
  - indices are computed from the key using the given radix
  ```
)

#figures.srb-tree

---

#slide(repeat: 8, self => [
  #pdfpc.speaker-note(
    ```md
    - perfect balance -> fully realized b-tree for key type
    - perfect for analysis
    - can degenerate space wise, if sparsely populated
    - can't drive with 0.97 promille
    - thesis did not investigate further because of this
    ```
  )

  #let (uncover, only, alternatives) = utils.methods(self)

  #uncover("2-")[
    - Zeitkomplexität ergibt sich aus der Tiefe eines voll-belegten B-Baums $d = log_k 2^b only("3", = log_32 2^64) only("4-", = 12)$
  ]
  #uncover("5-")[
    - Worst Case Speicherauslastung:
      $
        s_U (p, v) &= (k^(d - 1) v) / (k^d v + sum_(n = 1)^(d - 1) k^n p)
        uncover("6-", \ s_U (p, v) &= (32^11 v) / (32^12v + 32^11p + 32^10p + ... + 32^1p))
        uncover("7-", \ s_U (8, 8) &approx 0.00097% uncover("8-", approx 0.97 permille))
      $
  ]
])

== 2-3-Fingerbaum
#pdfpc.speaker-note(
  ```md
  - extends a 2-3-tree sequence
  - uses a monoid called a measure to serve as many different data structures
  - thesis focuses on key and size monoid
  - doesn't come with insert or remove by default, these require the key and
    size monoid
  ```
)

#pause

- _engl._ 2-3-finger-tree
  #pause
- baut auf 2-3-Bäumen auf, optimiert den Zugriff auf die Enden es Baums
  #pause
- Sequenzdatenstruktur, kann als Basis für verschiedenste Datenstrukturen verwendet werden
  #pause
- `search`, `split`, `concat`: $Theta(log n)$
  #pause
- `push`, `pop`: $Theta(1)$ #footnote(numbering: "*")[amortisiert]

---

#align(center, figures.finger-tree.repr)

---

#pdfpc.speaker-note(
  ```md
  - need not be persistent
  - amortized bounds rely on lazy evaluation
  - lots of value shuffling, small factors increase indirection
  ```
)

#pause

- nicht zwangsläufig persistent
  #pause
- baut stark auf lazy evaluation auf
  #pause
- geringe Zweigfaktoren und viele Kopien

#focus-slide[
  Geht das gut?
]

#pdfpc.speaker-note(
  ```md
  - increase of branching factors could reduce indirection and improve cache
    efficiency
  - increased factors must maintain bounds
  ```
)

#pause

- können die Zweigfaktoren erhöht werden?
  #pause
- wie verhalten sich diese?

== Generische Fingerbäume
#pdfpc.speaker-note(
  ```md
  - bounds must not degenerate, otherwise they have no improvement over b-trees
  ```
)

#pause

- statt 2-3, 8-16 oder 16-32
  #pause
- halten die worst case Komplexitäten?
  #pause
- halten die amortisierten Komplexitäten?
  #pause
- Lohnt sich das?

---

#pdfpc.speaker-note(
  ```md
  - key monoid, we need to ensure the ordering of keys is consistent to before
  - keys may have variable size (strings) or non trivial ordering (floats)
  - insert and remove are compound operations of the others
  ```
)

=== Operationen
#slide(repeat: 8, self => [
  #only(1)[=== Operationen]
  #only("2-")[
    #set heading(outlined: false)
    === Operationen
  ]
  #pdfpc.speaker-note(
    ```md
    - higher branching factors means more skipped values during search
    - "safety" of nodes represents whethe they can hold the amortized push and pop
      bounds
    - worst case bounds of push and pop are ensured by the structure of the tree
      regardless of the factors
    - split and concat need closer inspection
    ```
  )

  #let (uncover, only, alternatives) = utils.methods(self)

  #uncover("2-")[Welche Art von Schlüsseln haben wir?]

  #uncover("3-")[- totale Ordnungsrelation]
  #uncover("4-")[- nur zur Laufzeit bekannte Länge]

  #uncover("5-")[Welche Operationen müssen generalisiert werden?]

  #uncover("6-")[- `search`]
  #uncover("7-")[- `push`, `pop`]
  #uncover("8-")[- `split`, `concat`]
])

=== Komplexitäten
#slide(repeat: 11, self => [
  #only(1)[=== Komplexitäten]
  #only("2-")[
    #set heading(outlined: false)
    === Komplexitäten
  ]
  #pdfpc.speaker-note(
    ```md
    - k_min to k_max: b-tree, ensure depth and flexibility in length of subtrees
    - d_min to k_min: to ensure inner sequence in concat can buid valid nodes
    - last in equality comes from layer safety constraint
    - the inequalities alone aren't enough
    - length of inner sequence of concat must have an upper bound
    ```
  )

  #only("2-7")[Wovon hängen diese ab?]

  #only("3-7")[- Zweigfaktoren]
  #only("4-7")[- Über-/Unterlaufsicherheit]

  #only("5-7")[Welche Zweigfaktoren definieren wir?]

  #only("6-7")[- Digits: $d_min = 1, d_max = 4$]
  #only("7")[- Knoten: $k_min = 2, k_max = 3$]

  #only("8-")[Wie hängen diese zusammen?]

  $
    only("9-", k_min = ceil(k_max / 2)) \
    only("10-", d_min = ceil(k_min / 2)) \
    only("11-", d_max - d_min + 1 > k_max) \
  $
])

#slide(repeat: 7, self => [
  #pdfpc.speaker-note(
    ```md
    - color coded for clarity
    - both minimum and maximum length of inner sequence has relevance
    - minimum must be enough to build at least one b-tree node,
      i.e. 2d_min >= k_min
    - maximum must have a well known constant or logarithmic upper bound
    ```
  )

  #set align(center + horizon)

  #let node = node.with(shape: circle, radius: 0.75em)
  #let edge = (a, b, ..args) => edge(a, b, "-|>", ..args)

  #let left = (stroke: red, fill: red.lighten(75%))
  #let middle = (stroke: yellow, fill: yellow.lighten(75%))
  #let right = (stroke: green, fill: green.lighten(75%))

  #let fdiag = fdiag.with(axes: (ltr, btt), spacing: 1em)

  #let l0a = {
    node((-2, 0), `-2`, ..left)
    node((-1, 0), `-1`, ..left)

    node((0, 0), ` `, stroke: (dash: "dashed", paint: yellow), fill: yellow.lighten(75%))

    node((1, 0), `+1`, ..right)
    node((2, 0), `+2`, ..right)
    node((3, 0), `+3`, ..right)
  }

  #let l0b = {
    node((-2, 0), `-2`, ..left)
    node((-1, 0), `-1`, ..left)
    node((0, 0), `+1`, ..right)

    node((1, 0), `+2`, ..right)
    node((2, 0), `+3`, ..right)
  }

  #let l1a = l0b + {
    node((-1, 1), ` `, ..middle)
    node((1.5, 1), ` `, ..middle)

    edge((-1, 1), (-2, 0))
    edge((-1, 1), (-1, 0))
    edge((-1, 1), (0, 0))

    edge((1.5, 1), (1, 0))
    edge((1.5, 1), (2, 0))
  }

  #let l1b = l1a + {
    node((-4, 0), `-4`, ..left)
    node((-3, 0), `-3`, ..left)

    node((3, 0), `+4`, ..right)
    node((4, 0), `+5`, ..right)

    node((-3.5, 1), ` `, ..left)
    node((3.5, 1), ` `, ..right)

    edge((-3.5, 1), (-4, 0))
    edge((-3.5, 1), (-3, 0))

    edge((3.5, 1), (3, 0))
    edge((3.5, 1), (4, 0))
  }

  #let l2a = l1b + {
    node((-2, 2), ` `, ..middle)
    node((2.5, 2), ` `, ..middle)

    edge((-2, 2), (-3.5, 1))
    edge((-2, 2), (-1, 1))

    edge((2.5, 2), (1.5, 1))
    edge((2.5, 2), (3.5, 1))
  }

  #let l2b = l2a + {
    node((-6, 0), `-6`, ..left)
    node((-5, 0), `-5`, ..left)

    node((5, 0), `+6`, ..right)
    node((6, 0), `+7`, ..right)

    node((-5.5, 1), ` `, ..left)
    fletcher.hide(node((-6.5, 1), ` `, ..left))
    node((5.5, 1), ` `, ..right)
    fletcher.hide(node((6.5, 1), ` `, ..right))

    node((-5.5, 2), ` `, ..left)
    node((5.5, 2), ` `, ..right)

    edge((-5.5, 2), (-6.5, 1), stroke: (dash: "dashed"))
    edge((-5.5, 2), (-5.5, 1))
    edge((5.5, 2), (5.5, 1))
    edge((5.5, 2), (6.5, 1), stroke: (dash: "dashed"))

    edge((-5.5, 1), (-5, 0))
    edge((-5.5, 1), (-6, 0))

    edge((5.5, 1), (5, 0))
    edge((5.5, 1), (6, 0))
  }

  #let l3a = l2b + {
    node((-3.5, 3), ` `, ..middle)
    node((4, 3), ` `, ..middle)

    edge((-3.5, 3), (-5.5, 2))
    edge((-3.5, 3), (-2, 2))

    edge((4, 3), (2.5, 2))
    edge((4, 3), (5.5, 2))
  }

  #alternatives(
    ..(l0a, l0b, l1a, l1b, l2a, l2b, l3a).map(fdiag).map(align.with(center + bottom))
  )
])

= Benchmarks
#let data = json("/src/benchmarks.json")
#let benchmarks = (:)

#for entry in data.benchmarks {
  let name = entry.remove("name")

  if "BigO" in name or "RMS" in name {
    continue
  }

  name = name.trim(at: start, "benchmarks::")

  let (type_, method, arg) = name.split(regex("::|/"));

  if type_ not in benchmarks {
    benchmarks.insert(type_, (:))
  }

  if method not in benchmarks.at(type_) {
    benchmarks.at(type_).insert(method, (:))
  }

  benchmarks.at(type_).at(method).insert(arg, entry)
}

#let plot-operation(type, op) = cetz.plot.add(
  op.pairs().map(((arg, entry)) => (int(arg), entry.real_time)),
  label: box(inset: 0.25em, raw(block: false, type)),
)

#pdfpc.speaker-note(
  ```md
  - small bump yet to be explained
  - logarithmic growth for all three until around 120k
  - qmap starts degenerating
  - persistent trees perform better for very high values
  ```
)

`get`

#align(center, cetz.canvas({
  import cetz.draw: *
  import cetz.plot

  cetz.draw.set-style(axes: (bottom: (tick: (label: (angle: 45deg, anchor: "north-east")))))

  plot.plot(
    size: (15, 8),
    x-label: $n$,
    x-format: x => [#calc.round(x / 1000)],
    x-unit: "k",
    y-label: $t$,
    y-unit: "ns",
    {
      for (type, methods) in benchmarks {
        plot-operation(type, methods.get)
      }
    }
  )
}))

---

#pdfpc.speaker-note(
  ```md
  - logarithmic groth for all throughout
  - comparison of worst case trees to best case qmap
  - finger tree is compount of worst case split worst case push and worst case
    concat
  - even if all three worst cases may not happen irl
  - funny rocket to the moon graph
  ```
)

`insert`

#align(center, cetz.canvas({
  import cetz.draw: *
  import cetz.plot

  set-style(axes: (bottom: (tick: (label: (angle: 45deg, anchor: "north-east")))))

  plot.plot(
    size: (15, 8),
    x-label: $n$,
    x-format: x => [#calc.round(x / 1000)],
    x-unit: "k",
    y-label: $t$,
    y-format: y => [#int(y / 1000)],
    y-unit: "µs",
    {
      plot-operation("qmap", benchmarks.qmap.insert_unique)
      plot-operation("b_tree", benchmarks.b_tree.insert)
      plot-operation(
        "finger_tree",
        benchmarks
          .finger_tree
          .split
          .pairs()
          .map(((arg, entry)) => (
            (arg): (
              real_time: entry.real_time
                + benchmarks.finger_tree.push_worst.at(arg).real_time
                + benchmarks.finger_tree.concat.at(arg).real_time
              )
            )
          )
          .fold((:), (acc, it) => acc + it)
      )
    }
  )
}))

---

`insert`

#align(center, cetz.canvas({
  import cetz.draw: *
  import cetz.plot

  set-style(axes: (bottom: (tick: (label: (angle: 45deg, anchor: "north-east")))))

  let y = benchmarks.qmap.insert_shared.values().map(x => int(x.real_time))
  let tick-step = int((y.last() - y.first()) / 10)

  plot.plot(
    size: (15, 8),
    x-label: $n$,
    x-format: x => [#calc.round(x / 1000)],
    x-unit: "k",
    y-label: $t$,
    y-tick-step: tick-step,
    y-format: y => [#int(y / (1000 * 1000))],
    y-unit: "ms",
    {
      plot-operation("qmap unique", benchmarks.qmap.insert_unique)
      plot-operation("b_tree", benchmarks.b_tree.insert)
      plot-operation(
        "finger_tree",
        benchmarks
          .finger_tree
          .split
          .pairs()
          .map(((arg, entry)) => (
            (arg): (
              real_time: entry.real_time
                + benchmarks.finger_tree.push_worst.at(arg).real_time
                + benchmarks.finger_tree.concat.at(arg).real_time
              )
            )
          )
          .fold((:), (acc, it) => acc + it)
      )
      plot-operation("qmap shared", benchmarks.qmap.insert_shared)
    }
  )
}))

= Fazit
#pdfpc.speaker-note(
  ```md
  - generic finger trees may be possible, the initial implementation was wholy
    unoptimized
  - universal proof for generality could not be found largely because of
    concat's node merging requiring an explicit existence argument
  - b-trees are, well studied, simpler to implement and provide simlar worst
    case bounds, finger trees only provider better average bounds
  - real time analysis doesn't care about average bounds
  ```
)

#pause

- generische Fingerbäume sind vermutlich möglich
  #pause
- universeller Beweise konnte nicht gefunden werden
  #pause
- Implementierung von 2-3-Fingerbäumen hat Optimierungsbedarf
  #pause
- B-Bäume bieten schon in simpler Implementierung bessere Performance

#focus-slide[
  Danke für Ihre Zeit und Aufmerksamkeit!
]
