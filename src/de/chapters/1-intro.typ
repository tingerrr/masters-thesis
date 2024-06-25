#import "/src/util.typ": *

= Motivation
#todo[Introduce t4gl and the main problem roughly here before going more into detail later on.]

Das Endziel dieser Arbeit ist die Verbesserung der Latenzen des T4gl-Laufzeitsystems durch Analyse und gezielte Verbesserung der Datenspeicherung von T4gl-Arrays.
Die in T4gl verwendeten assoziativen Arrays sind in ihrer jetzigen Form für manche Nutzungsfälle unzureichend optimiert.
Häufige Schreibzugriffe und unzureichend granulare Datenteilung verursachen unnötig tiefe Kopien der Daten und darausfolgende Latenzen.

#todo[
  Expand this section a little more.
  If new problems are identified that can be solved by the approach in this thesis, outline them here too.
]

= Herangehensweise
#todo[Short explanation of the general idea of partial peristence to solve these problems.]

= Anleitung zum Lesen
== Struktur
#todo[Add a short reading guide explaining the chapters and document structure.]

== Legende & Konventionen
Die folgenden Konventionen werden während der Arbeit verwendet.
Sollten bestimmte Teile der Arbeit diesen Konventionen nicht folgen, sind diese Abweichungen im umliegenden Text beschrieben.

=== Grafiken
@tbl:legend beschreibt die Konventionen für Grafiken, vor allem Grafiken zu Baum- oder Listenstrukturen.
Diese Konventionen sollen Konzepte der Persistenz vereinfachen.

#let fdiag = fletcher.diagram.with(node-stroke: 0.075em)
#let node = fletcher.node.with((0, 0), `n`)

#figure(
  table(columns: 2, align: (x, y) => horizon + if x == 1 { left },
    table.header[Umrandung][Beschreibung],
    fdiag(node(stroke: green)), [
      geteilte Knoten, d.h. Knoten welche mehr als einer Instanz zuzuordnen sind
    ],
    fdiag(node(stroke: red)), [
      kopierte (nicht geteilte) Knoten, d.h. Knoten welche durch eine Operation kopiert wurden statt geteilt zu werden, z.B. durch "path copying"
    ],
    fdiag(node(stroke: (paint: gray, dash: "dashed"))), [
      visuelle Orientierungshilfe für folgende Abbildungen, kann hypothetischen oder gelöschten Knoten darstellen
    ],
    fdiag(node(extrude: (-2, 0))), [
      Instanzknoten, d.h. Knoten, welche nur Verwaltungsinformationen enthalten, wie die Instanz eines `std::vector`
    ],
  ),
  caption: [Legende der Konventionen in Datenstrukturgrafiken.],
) <tbl:legend>

=== Notation
Bei der Verwendung von !LANDAU-Symbolen steht die Variable $n$ für die Größe der Daten welche für die Laufzeit eines Algorithmus relevant sind.
Bei Operationen auf Datenstrukturen entspricht die Größe der Anzahl der verwalteten Elemente in der Struktur.
