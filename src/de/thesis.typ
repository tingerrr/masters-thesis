#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "/src/util.typ"

#show "C++": util.cpp

// convenient smallcaps for simple author names
#show regex("![A-Za-z]{2,}\b"): it => smallcaps(it.text.slice(1))

#show: doc(
  kind: masters-thesis(
    id: [AI-2024-MA-005],
    title: [Dynamische Datenstrukturen unter Echtzeitbedingungen],
    author: "B. Sc. Erik Bünnig",
    supervisors: (
      "Prof. Dr. Kay Gürtzig",
      "Dipl-Ing. Peter Brückner",
    ),
    date: datetime(year: 2024, month: 10, day: 09),
    field: [Angewandte Informatik],
  ),
  abstracts: (
    (title: [Kurzfassung], body: lorem(100)),
    (title: [Abstract], body: lorem(100)),
  ),
  outlines: (
    (target: image, title: [Abbildungsverzeichnis]),
    (target: table, title: [Tabellenverzeichnis]),
    (target: raw,   title: [Listingverzeichnis]),
  ),
  outlines-position: start,
  bibliography: bibliography("/src/bib.yaml", title: "Literatur"),
  appendices: (
    include "appendices/a-non-rec-proof.typ",
  ),
)

#set grid.cell(breakable: false)
#show figure.where(kind: "algorithm"): set grid.cell(breakable: true)
#show figure.where(kind: "algorithm"): set par(justify: false)

#set raw(syntaxes: "/assets/t4gl.sublime-syntax")

#chapter[Einleitung] <chap:intro>
#include "chapters/1-intro.typ"

#chapter[T4gl] <chap:t4gl>
#include "chapters/2-t4gl.typ"

#chapter[Lösungsansätze] <chap:non-solutions>
#include "chapters/3-non-solutions.typ"

#chapter[Persistente Datastrukturen] <chap:persistence>
#include "chapters/4-persistent-data-structures.typ"

#chapter[Implementierung & Optimierungen] <chap:impl>
#include "chapters/5-implementation-optimizations.typ"

#chapter[Analyse & Vergleich] <chap:benchmarks>
#include "chapters/6-benchmarks.typ"

#chapter[Fazit] <chap:conclusion>
#include "chapters/7-conclusion.typ"
