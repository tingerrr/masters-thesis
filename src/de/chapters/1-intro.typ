#import "/src/util.typ": *

= Motivation
Das Endziel dieser Arbeit ist die Verbesserung der Latenzen des T4gl-Laufzeitsystems durch Analyse und gezielte Verbesserung der Datenspeicherung von T4gl-Arrays.
Die in T4gl verwendeten assoziativen Arrays sind in ihrer jetzigen Form für manche Nutzungsfälle unzurreichend optimiert.
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
@tbl:legend beschreibt die Konventionen für Grafiken, vorallem Grafiken zu Baum- oder Listenstrukturen.
Diese Konventionen sollen Konzepte der Persistenz vereinfachen.

#let fdiag = fletcher.diagram.with(node-stroke: 0.075em)
#let node = fletcher.node.with((0, 0), `n`)

#figure(
  table(columns: 2, align: (x, y) => horizon + if x == 1 { left },
    table.header[Strichform][Beschreibung],
    fdiag(node(stroke: green)), [
      geteilte Knoten, Knoten welche mehr als einer Instanz zuzuordnen sind
    ],
    fdiag(node(stroke: red)), [
      kopierte, nicht-einzigartige Knoten, sprich Knoten welche durch eine Operation kopiert wurden statt geteilt zu werden, z.B. durch "path copying"
    ],
    fdiag(node(stroke: (paint: gray, dash: "dashed"))), [
      visuelle Orientierungshilfe für folgende Abbildungen, kann hypothetischen oder gelöschten Knoten darstellen
    ],
    fdiag(node(extrude: (-2, 0))), [
      Instanzknoten, Knoten welche nur Verwaltungsinformationen enthalten wie die Instanz eines `std::vector`
    ],
  ),
  caption: [Legende der Konventionen in Datenstrukturgrafiken.],
) <tbl:legend>

=== Notation
Bei der Verwendung von !LANDAU-Symbolen steht die Variable $n$ für die Größe der Daten über die Operation zu welcher das Symbol verwendet wird.
Bei Operationen auf Datenstrukturen korrespondiert die Größe zur Anzahl der verwalteten Elemente in der Struktur.
