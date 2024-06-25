#import "/src/util.typ": *
#import "/src/figures.typ"

= Problematik
Die in @sec:t4gl:arrays beschrieben T4gl-Arrays bestehen aus Komponenten in drei Ebenen:
+ T4gl: Die Instanzen aus Sicht des T4gl-Programmierers.
+ Storage: Die Daten aus Sicht des T4gl-Programmierers, aber Instanzen aus Sicht des T4gl-Laufzeitsystems.
+ Speicher: Die Daten aus Sicht des T4gl-Laufzeitsystems. Diese Ebene ist für den T4gl-Programmierer unsichtbar.

Zwischen den Ebenen 1 und 2 kommt geteilte Schreibfähigkeit durch Referenzzählung zum Einsatz, mehrere T4gl-Instanzen teilen sich eine Storage-Instanz und können von dieser lesen als auch in sie schreiben.
Zwischen den Ebenen 2 und 3 kommt CoW + Referenzzählung zum Einsatz, mehrere Storage-Instanz teilen sich die gleichen Daten, Schreibzugriffe auf die Daten sorgen vorher dafür, dass die Storage-Instanz der einzige Referent ist, wenn nötig durch Kopie.
Wir definieren je nach Ebene zwei Arten von Kopien:
/ seichte Kopie:
  Eine Kopie der T4gl-Instanz erstellt lediglich eine neue Instanz, welche auf die gleichen Storage-Instanz zeigt.
  Wird in T4gl durch Initialisierung von Arrays durch existierende Instanzen oder die Übergabe von Arrays an normale Funktionen hervorgerufen.
/ tiefe Kopie:
  Eine Kopie der T4gl-Instanz *und* der Storage-Instanz, welche beide auf die gleichen Daten zeigen.
  Das erfolgt entweder über den expliziten Aufruf der Methode `clone` durch den T4gl Programmierer, oder bei Ausnahmefällen von Zuweisungen durch das Laufzeitsystem.

Bei einer seichten Kopie der Instanz `a` in @fig:t4gl-indirection:new ergibt sich die Instanz `b` in @fig:t4gl-indirection:shallow.
Eine tiefe Kopie hingegen führt zur Instanz `c` in @fig:t4gl-indirection:deep.
Obwohl eine tiefe Kopie zunächst nur auf Ebene 1 und 2 Instanzen Kopiert, erfolgt die Kopie der Daten auf Ebene 3 beim ersten Schreibzugriff einer der Instanzen (@fig:t4gl-indirection:mut).

#subpar.grid(
  figure(figures.t4gl.new, caption: [
    Ein T4gl Array nach Initalisierung. \ \
  ]), <fig:t4gl-indirection:new>,
  figure(figures.t4gl.shallow, caption: [
    Zwei T4gl-Arrays teilen sich eine C++ Instanz nach seichter Kopie.
  ]), <fig:t4gl-indirection:shallow>,
  figure(figures.t4gl.deep-new, caption: [
    Zwei T4gl-Arrays teilen sich die gleichen Daten nach tiefer Kopie. \ \
  ]), <fig:t4gl-indirection:deep>,
  figure(figures.t4gl.deep-mut, caption: [
    Zwei T4gl-Arrays teilen sich keine Daten nach tiefer Kopie und Schreibzugriff.
  ]), <fig:t4gl-indirection:mut>,
  columns: 2,
  caption: [T4gl-Arrays in verschiedenen Stadien der Datenteilung.],
  label: <fig:t4gl-indirection>,
)

#todo[
  Annotate the levels in the above figure to show which level manages which part of the system.
]

Durch die Teilung der Daten in Ebene 3 nach einer tiefen Kopie kommt es somit nicht zur Kopie wenn keine weiteren Schreibzugriffe auf `a` oder `c` passieren.
Allerdings ist das selten der Fall.
Ein Hauptanwendungsfall für T4gl-Arrays ist die Ausgabe einer rollenden Historie von Werten einer Variable.
Wenn diese vom Laufzeitsystem erfassten Werte vom T4gl-Programmierer ausgelesen werden, wird eine tiefe Kopie der Storage-Instanz erstellt.
Die T4gl-Instanz, welche an den Programmierer übergeben wird, sowie die interne Storage-Instanz teilen sich Daten, welche vom Laufzeitsystem zwangsläufig beim nächsten Schreibzugriff kopiert werden müssen.
Diese Kopie und, daraus folgend, der Schreibzugriff haben dann eine Zeitkomplexität von $Theta(n)$.
Das gilt für jeden ersten Schreibzugriff, welcher nach einer Übergabe der Daten an den T4gl-Programmierer erfolgt.

= Lösungsansatz
Zunächst definieren wir Invarianzen von T4gl-Arrays, welche durch eine Änderung der Storage-Datenstruktur nicht verletzt werden dürfen:
+ T4gl-Arrays sind assoziative Datenstrukturen.
  - Es werden Werte mit Schlüsseln addressiert.
+ T4gl-Arrays sind nach ihren Schlüsseln geordnet.
  - Die Schlüsseltypen von T4gl-Arrays haben eine voll definierte Ordnungsrelation.
  - Iteration über T4gl-Arrays ist deterministisch in aufsteigender Reihenfolge der Schlüssel.
+ T4gl-Arrays verhalten sich wie Referenztypen.
  - Schreibzugriffe auf ein Array, welches eine seichte Kopie eines anderen T4gl-Arrays ist, sind in beiden Instanzen sichtbar.
  - Tiefe Kopien von T4gl-Arrays teilen sichtbar keine Daten, ungeachtet, ob die darin enthaltenen Typen selbst Referenztypen sind.

Die Ordnung der Schlüssel schließt ungeordnete assoziative Datenstrukturen wie Hashtabellen aus und das Referenztypenverhalten ist durch Referenzzählung und Storage-Instanzteilung wie bis dato umsetzbar.
Es muss lediglich die Implementierung der Storage-Instanzen insofern verbessert werden, dass Schlüssel geordnet vorliegen und nicht dicht verteilt sein müssen.
Essentiell für die Verbesserung des _worst-case_ Zeitverhaltens bei Kopien und Schreibzugriffen ist die Reduzierung der Daten, welche bei Schreibzugriffen kopiert werden müssen.
Hauptproblem bei seichten Kopien gefolgt von Schreibzugriff auf CoW-Datenstrukturen, ist die tiefe Kopie _aller_ Daten in den Daten der Instanzen, selbst wenn nur ein einziges Element beschrieben oder eingefügt/entfernt wird.
Ein Großteil der Elemente in den originalen und neuen kopierten Daten sind nach dem Schreibzugriff gleich.
Deshalb wurde als Basis des Lösungsansatzes die Wahl einer persistenten Datenstruktur mit granularer Datenteilung festgelegt.
Durch höhere Granularität der Datenteilung müssen bei Schreibzugriffen weniger Daten kopiert werden.
Ein Beispiel für persistente Datenstrukturen mit granularer Datenteilung sind RRB-Vektoren @bib:br-11 @bib:brsu-15 @bib:stu-15, eine Sequenzdatenstruktur auf Basis von Radix-Balancierten Bäumen.
Trotz der zumeist logarithmischen _worst-case_ Komplexitäten können RRB-Vektoren nicht als Basis für T4gl-Arrays dienen, da die Effizienz der RRB-Vektoren auf der Relaxed-Radix-Balancierung aufbaut, welche von einer Sequenzdatenstrukur ausgeht.
Da die Schlüsselverteilung in T4gl-Arrays nicht dicht ist, können die Schlüssel nicht ohne Weiteres auf dicht verteilte Indizes abgebildet werden, welche für die Radixsuche essentiell sind.
Ohne die Relaxed-Radix-Balancierung handelt es sich bei RRB-Vektoren lediglich um B-Bäume @bib:bm-70 @bib:bay-71 hoher Ordnung.
Bei persistenten B-Bäumen haben die meisten Operationen eine _worst-_ und _average-case_ Zeitkomplexität von $Theta(log n)$.
Eine Verbesserung der _average-case_ Zeitkomplexität für bestimmten Sequenzoperationen (_Push_, _Pop_) bieten 2-3-Fingerbäume @bib:hp-06.
Diese bieten sowohl exzellentes Zeitverhalten, als auch keine Enschränkung auf die Schlüsselverteilung.
Im folgenden werden 2-3-Fingerbäume als alternative Storage-Datenstrukturen für T4gl-Arrays untersucht.

#todo[
  + The mention of persistence without an example seems jarring, but showing an example here and in @sec:per-eph also feels weird.
  + The above could go with some examples, especially regarding RRB-Vectors and how they could be used as paired sequences ordered by key on insertion given that it's insert/remove bounds are sublinear.
]

= 2-3-Bäume
#todo[
  Introduce the notation of 2-3 Trees as the simpelest Form of B-Tree, this should give a good indicaiton why the generalization of FingerTrees uses B-Trees itself and what 2-3-4-FingerTrees mean notationally.
  Introduce the usage of branching factors here or further up depending on when it is first used.
]

= 2-3-Fingerbäume
2-3-Fingerbäume wurden von !HINZE und !PATERSON @bib:hp-06 eingeführt und sind eine Erweiterung von 2-3-Bäumen, welche für verschiedene Sequenzoperationen optimiert wurden.
Die Authoren führen dabei folgende Begriffe ein:
/ Spine: Die Wirbelsäule eines Fingerbaums, sie beschreibt die Kette der zentralen Knoten, welche die sogenannten _Digits_ enthalten.
/ Digit: Erweiterung von 2-3-Knoten auf 1-4-Knoten, von welchen jeweils zwei in einem internen Wirbelknoten vorzufinden sind.
/ Safe: Sichere _Digits_ sind _Digits_ mit 2 oder 3 Elementen, ein Element kann ohne Probleme entnommen oder hinzugefügt werden.
/ Unsafe: Unsichere _Digits_ sind _Digits_ mit 1 oder 4 Elementen, ein Element zu entnehmen oder hinzuzufügen kann Über- bzw. Unterlauf verursachen (Wechsel von Elementen zwischen Ebenen des Baumes).

#todo[
  Clear up that Digit is indeed derived from the "numerical" representation which inspired them (Okasaki).
  Clear up that the concept of fingers refers to getting easy access at some point of a data structure by placing "fingers" there.
  The usage of both Digit and Finger in FingerTrees to refer to different concepts is more or less coincidental.
]

Die Definition von 2-3-Fingerbäumen ist in @lst:finger-tree beschrieben, dabei sind diese über `v` und `a` parametriert.
`a` sind die im Baum gespeicherten Elemente und `v` die Suchinformationen für interne Knoten.

#figure(
  ```haskell
  data FingerTree v a
      = Empty
      | Single a
      | Deep !v !(Digit a) (FingerTree v (Node v a)) !(Digit a)

  data Node v a = Node2 !v a a | Node3 !v a a a
  data Digit a = One a | Two a a | Three a a a | Four a a a a
  ```,
  caption: [Die Definition von 2-3-Fingerbäumen in Haskell.],
) <lst:finger-tree>

Durch die in @bib:hp-06 beschribenen Optimierungen weisen 2-3-Fingerbäume im Vergleich zu gewöhnlichen 2-3-Bäumen geringere asymptotische Komplexitäten für Sequenzoperationen auf.
@tbl:finger-tree-complex zeigt einen Vergleich der Komplexitäten verschiedener Operationen über $n$ Elemente.

Dabei ist zu sehen, dass _Push_ und _Pop_ Operationen auf 2-3-Fingerbäumen im _average-case_ amortisiert konstantes Zeitverhalten aufweisen, im Vergleich zu dem generell logarithmischen Zeitverhalten bei gewöhnlichen 2-3-Bäumen.
Fingerbäume sind symmetrische Datenstrukturen, _Push_ und _Pop_ kann problemlos an beiden Enden durchgeführt wurden.

2-3-Fingerbäume weisen verschiedene Besonderheiten auf:
+ Die Elemente sind nur in den Blattknoten von Teilbäumen vorzufinden, interne Knoten enthalten lediglich Suchinformationen.
+ Mit der Tiefe der Wirbelknoten steigt die Tiefe der Teilbäume in den _Digits_.
+ Ein innerer Wirbelknoten enthält je ein _Digit_ für den Anfang und das Ende der Sequenz, und kann daher zwischen 2 bis 8 Knoten enhalten (1 bis 4 pro Seite).
+ Der letzte Wirbelknoten kann leer sein oder einen Knoten enthalten, dieser Knoten enthält die Mitte der Sequenz.
+ Je nach Wahl des Typs der Suchinformation `v` kann ein 2-3-Fingerbaum als gewöhnlicher Vektor, geordnete Sequenz oder _Priority-Queue_ verwendet werden.

#let am1 = [#footnote(numbering: "*")[Amortisiert] <ft:amortized>]
#let am2 = footnote(numbering: "*", <ft:amortized>)

#todo[Verify all of these complexity claims, ensure they're sufficiently precise.]

#figure(
  figures.complexity-comparison(
    (
      "2-3-Baum": (
        "Search": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Insert": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Remove": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Push":   ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Pop":    ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
      ),
      "2-3-Fingerbaum": (
        "Search": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Insert": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Remove": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Push":   ($Theta(log n)$, $Theta(1)#am1$, $Theta(1)$),
        "Pop":    ($Theta(log n)$, $Theta(1)#am2$, $Theta(1)$),
      ),
    ),
  ),
  caption: [Die Komplexitäten von 2-3-Fingerbäumen im Vergleich zu gewöhnlichen 2-3-Bäumen.],
) <tbl:finger-tree-complex>

Ein wichtiger Bestandteil der Komplexitätsanalyse der _Push_ und _Pop_ Operationen von 2-3-Fingerbäumen ist die Suspension der Wirbelknoten durch _lazy evaluation_.
@fig:finger-tree zeigt den Aufbau eines 2-3-Fingerbaums, die in #text(blue.lighten(75%))[*blau*] eingefärbten Knoten sind Wirbelknoten, die in #text(teal.lighten(50%))[*türkis*] eingefärbten Knoten sind _Digits_, die Zahlen geben die Elemente und deren Ordnung an.
In #text(gray)[*grau*] eingefärbte Knoten sind interne Knoten.

#todo[
  They argue that rebalancing is paid for by the previous cheap operations using Okasakis debit analysis.
  I'm unsure how to properly write this down without stating something incorrect, so I probably don't understand it completely yet.
  My assumption was that the rebalancing simply happens less and less often as it always creates safe layers when it happens, each time it gets deeper it creates it leaves only safe layers.
]

#figure(
  figures.finger-tree,
  caption: [Ein 2-3-Fingerbaum der Tiefe 2 und 12 Elementen.],
) <fig:finger-tree>

= Generische Fingerbäume
Im Folgenden wird betrachtet, inwiefern die Zweigfaktoren von Fingerbäumen generalisierbar sind, ohne die in @tbl:finger-tree-complex beschriebenen Komplexitäten zu verschlechtern.
Höhere Zweigfaktoren der Teilbäume eines Fingerbaums reduzieren die Tiefe des Baumes und können die Cache-Effizienz erhöhen.

Wir beschreiben die Struktur eines Fingerbaums durch die Minima und Maxima seiner Zweigfaktoren $k$ (Zweigfaktor der internen Knoten) und $d$ (Zweigfaktor der _Digits_)

$
  k_min &<= k &<= k_max \
  d_min &<= d &<= d_max \
$

Die Teilbäume, welche in den _Digits_ liegen, werden auf B-Bäume generalisiert, daher gilt für deren interne Knoten außerdem

$
  ceil(k_max / 2) <= k_min \
$

#todo[
  A later inequality seems to imply $d_min < k_min$ as well as $k_max < d_max$, so this may be worth mentioning here once proven.
]

#todo[
  We need better terminology to separate the notion of
  - elements of the tree (those in the leaves, always of type `a`)
  - elements in a layer (those which are packed up for the next layer or unwrapped for the previous layer, those being the nested type `Node^t a`)
  - nodes (as being names for those "wrapped" elements, those being of type `Node a'` where `a'` is the nested type at layer `t`)

  This was repeatedly brought up in review of the sections below.
]

Da jeder tiefe Wirbelknoten mindestens $2 d_min$ Elemente enthalten muss, muss die Bildung dieser minimal Anzahl der Elemente im letzten Wirbelknoten überbrückt werden.
Prinzipiell gilt für die letzten Wirbelknoten

$
  0 <= d <= d_max
$

Ein generischer Fingerbaum ist dann durch diese Minima und Maxima beschrieben.
Im Beispiel des 2-3-Fingerbaums gilt

$
  2 &<= k &<= 3 \
  1 &<= d &<= 4 \
$

== Baumtiefe
Sei $n(t)$ die Anzahl $n$ der Elemente in beiden _Digits_ eines Wirbelknotens auf Ebene $t$, so gibt es ebenfalls die minimale und maximale Anzahl $n_min (t) <= n(t) <= n_max (t)$ für diesen Wirbelknoten.
Diese ergeben sich jeweils aus den minimalen und maximalen Anzahlen der _Digits_, welche Teilbäme mit minimalen bzw. maximalen Knoten enthalten.

$
  n_"smin" (t) &= k_min^(t - 1) \
  n_min (t) &= 2 d_min k_min^(t - 1) \
  n_max (t) &= 2 d_max k_max^(t - 1) \
$

$n_"smin"$ beschreibt das Sonderminimum der letzten Wirbelknoten.
Für die kumulativen Minima und Maxima aller Ebenen bis zur Ebene $t$ ergibt sich

$
  n'_"smin" (t) &= n_"smin" (t) + n'_min (t - 1) \
  n'_min (t) &= n_min (t) + n_min (t - 1) + dots.c + n_min (1) &= sum_(i = 1)^t n_min (i) \
  n'_max (t) &= n_max (t) + n_max (t - 1) + dots.c + n_max (1) &= sum_(i = 1)^t n_min (i) \
$

@fig:cum-depth zeigt die Minima und Maxima von $n$ für die Baumtiefen $t in [1, 8]$ für 2-3-Fingerbäume.
Dabei zeigen die horizontalen Linien das kumulative Sonderminimum $n'_"smin"$ und Maximum $n'_max$ pro Ebene.

#todo[
  Flip the plot's axes, it may be confusing that $n(t)$ is used in the label, implying a running variable of $t$, but this may increase the vertical size unecessarily, leaving lots of white space.
]

#[
  #let (kmin, kmax) = (2, 3)
  #let (dmin, dmax) = (1, 4)

  #let fmins(t) = calc.pow(kmin, t - 1)
  #let fmin(t) = 2 * dmin * calc.pow(kmin, t - 1)
  #let fmax(t) = 2 * dmax * calc.pow(kmax, t - 1)

  #let fcummin(t) = range(1, t + 1).map(fmin).fold(0, (acc, it) => acc + it)
  #let fcummins(t) = fmins(t) + fcummin(t - 1)
  #let fcummax(t) = range(1, t + 1).map(fmax).fold(0, (acc, it) => acc + it)

  #let ranges(t) = {
    let individual = range(2, t + 1).map(t => (
      t: t,
      mins: fmins(t),
      min: fmin(t),
      max: fmax(t),
    ))

    individual
  }

  #let cum-ranges(t) = {
    let cummulative = range(1, t + 1).map(t => (
      t: t,
      mins: fcummins(t),
      min: fcummin(t),
      max: fcummax(t),
    ))

    cummulative
  }

  #let count = 8
  #let cum-ranges = cum-ranges(count)
  #let mmax = cum-ranges.last().max

  #let base = 2
  #let sqr = calc.pow.with(base)
  #let lg = calc.log.with(base: base)
  #let tick-max = int(calc.round(lg(mmax)))
  #let tick-args = (
    x-tick-step: none,
    x-ticks: range(tick-max + 1).map(x => (x, sqr(x))),
  )

  // comment out to make linear scale plot
  // #let sqr = x => x
  // #let lg = x => x
  // #let tick-max = int(lg(mmax))
  // #let tick-args = ()

  #import "@preview/cetz:0.2.2"

  #figure(
    cetz.canvas({
      cetz.draw.set-style(axes: (bottom: (tick: (label: (angle: 45deg, anchor: "north-east")))))

      cetz.plot.plot(
        size: (9, 6),
        x-label: $n$,
        y-label: $t$,
        y-tick-step: none,
        y-ticks: range(1, count + 1),
        plot-style: cetz.palette.pink,
        ..tick-args,
        {
          let intersections(n) = {
            cetz.plot.add-vline(
              style: (stroke: (paint: gray.lighten(70%), dash: "dashed")),
              lg(n),
            )
            cetz.plot.add(
              label: box(inset: 0.2em)[$n' = #n$],
              style: (stroke: none),
              mark-style: cetz.palette.new(
                colors: color.map.crest.chunks(32).map(array.first)
              ).with(stroke: true),
              mark: "x",
              cum-ranges.filter(r => r.mins <= n and n <= r.max).map(r => (lg(n), r.t))
            )
          }
          // force the plot domain
          cetz.plot.add(
            style: (stroke: none),
            ((-1, 0), (tick-max + 1, count + 1)),
          )
          for t in cum-ranges {
            cetz.plot.add(
              label: if t.t == 1 { box(inset: 0.2em)[$n'(t)$] },
              domain: (0, lg(mmax)),
              style: cetz.palette.blue.with(stroke: true),
              mark-style: cetz.palette.blue.with(stroke: true),
              mark: "|",
              (
                (lg(t.mins), t.t),
                (lg(t.max), t.t),
              )
            )
          }
          intersections(9)
          intersections(27)
          intersections(250)
        },
      )
    }),
    caption: [
      Die minimale und maximale Anzahl von Elementen $n$ für einen 2-3-Fingerbaum der Tiefe $t$.
    ],
  ) <fig:cum-depth>

  // #table(
  //   columns: 6,
  //   align: right,
  //   table.header[$t$],
  //   ..cum-ranges.map(t => (t.t, t.mins, $<=$, $n$, $<=$, t.max)).flatten().map(x => $#x$)
  // )
]

== Über- & Unterlaufsicherheit
#todo[
  Incorporate the bounds mentioned in @bib:hp-06 regarding deque operations and why they are important for us.
  We want to ensure amortized $Theta(1)$ for those.
]

#let dd1 = $Delta d_t$
#let dd2 = $Delta d_(t + 1)$

Eine Ebene $t$ mit $d$ Elementen gilt als sicher @bib:hp-06[S. 7], wenn

#todo[
  It must be made clear that because of the nested type definition digits are elemnts of a layer and in the first layer they are elements of the tree as well.
  This dichotomy in the branching factors being the child element count was noted as confusing.
]

$
  d_min < d_t < d_max
$

#todo[
  Under and overflow can also occur when inserting/removing but may be remedied by other nodes in the same layer's digits.
  It seems that these can be handled just fine as long as overflow moves inwards as with the push/pop cases.
]

Ist eine Ebene sicher, ist das Hinzufügen oder Wegnehmen eines Elements trivial.
Ist eine Ebene unsicher, kommt es beim Hinzufügen oder Wegnehmen zum Über- oder Unterlauf, Elemente müssen zwischen Ebenen gewechselt werden, um die obengenannten Ungleichungen einzuhalten.
Damit die obengenannten Komplexitäten eingehalten werden, dürfen nur alle $n$ Operationen $log n$ Ebenen in den Baum über- oder unterfließen.
#todo[
  Construct a debit analysis of deque-operations to prove that said bounds hold under those more generic conditions.
]
Das ist möglich, solange eine unsichere Ebene nach Über- oder Unterlauf wieder sicher ist.
Dazu betrachten wir den Über- und Unterlauf einer unsicheren Ebene $t$ in eine oder aus einer sicheren Ebene $n + 1$.
Über- oder Unterlauf von unsicheren Ebenen in bzw. aus unsicheren Ebenen kann rekursiv angewendet werden bis eine sichere Ebene erreicht wird.

Der Wechsel von Elementen zwischen zwei Ebenen erfordert entweder
- das Anheben von Elementen der Ebene $t$ in Knoten zur Ebene $t + 1$ bei Überlauf,
- oder das Herunterlassen von Knoten der Ebene $t + 1$ zu Ebene $t$ bei Unterlauf.

$Delta d_(t + 1)$ ist die Anzahl der Knoten in Ebene $t + 1$, welche für $dd1$ Elemente in Ebene $t$ benötigt werden, es gilt
$
  dd2_min k_min <= dd1 <= dd2_max k_max \
$

Überlauf entsteht bei Hinzufügen eines Elements in eine Ebene mit $d_max$ Elementen, es werden Elemente aus Ebene $t$ zu Ebene $t + 1$ bewegt, die folgenden Ungleichungen müssen eingehalten werden, damit die Ebene $t$ nach dem Überlauf sicher ist.
Die Ebene $t + 1$, kann dabei sicher bleiben oder unsicher werden.
$
  t     &: d_min <& d_max     &text(#green, - dd1) text(#red, + 1) &<  d_max \
  t + 1 &: d_min <& d_(t + 1) &text(#green, + dd2)                 &<= d_max \
$

Gleichermaßen gelten für den Unterlauf folgende Ungleichungen.
$
  t     &: d_min <&  d_min     &text(#green, + dd1) text(#red, - 1) &< d_max \
  t + 1 &: d_min <=& d_(t + 1) &text(#green, - dd2)                 &< d_max \
$

Betrachten wir nun 2-3-Fingerbäume, bei $d_min = 1$, $d_max = 4$, $k_min = 2$ und $k_max = 3$ ergibt sich

$
  "überlauf" &: 2 <= dd1 <= 3 \
  "unterlauf" &: 1 < dd1 < 4 \
$

In @bib:hp-06 entschieden sich die Authoren bei Überlauf für $dd1 = 3$, gaben aber an, dass $dd1 = 2$ ebenfalls funktioniert.
Daraus folgt unmittelbar $dd2 = 1$.
Aus den oben genannten Ungleichungen lassen sich Fingerbäume mit anderen $d$ und $k$ wählen, welche die gleichen asymptotischen Komplexitäten für _Deque_-Operationen aufweisen.
Zum Beispiel 2-3-4-Fingerbäume mit $dd2 = 1$ und $d_min = 1$:
$
  2 <= dd1 <= 4 \
  dd1 < d_max \
  4 < d_max \
$

Daraus ergibt sich, dass $d_min = 1$, $d_max = 5$, $k_min = 2$ und $k_max = 4$ einen validen 2-3-4-Fingerbaum beschreiben.

== Push & Pop
#todo[
  Given the above inequalities and the following over and underflow which must necessarily only happen every $d_min$ push or pop operations respectively, it should follow that push and pop are both amortized constant time and logarithmic worst time.
  Perform amortized analysis to prove these claims.
]

== Insert & Remove
#todo[
  Insert and remove in @bib:hp-06 are done using a split + push/pop + concat, I'm unsure whether this is a feasible thing to do when we need to carefully manage the lazy evaluation ourselves.
  Either prove that the bounds hold given the correct suspension or propose specialized implementations which do inter-digit rebalancing with over/underflow in the correct direction.
]

== Echtzeitanalyse
#todo[
  Analyze the theoretical impact the new data structure _should_ have on the current runtime given its _worst-case_ bounds.
  This should also require a more thorough introduction of how t4gl schedules its threads and microsteps, as well as how these operations would fit into this.
  Show whether the data structure is a suitable fit for t4gl given the insight from the analysis.
]
