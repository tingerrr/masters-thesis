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

// TODO: ensure this will right come out right when printed and bound
#let chapter = chapter.with(to: "even")

#chapter(label: <chap:intro>)[Einleitung]
#include "chapters/1-intro.typ"

#chapter(label: <chap:t4gl>)[T4gl]
#include "chapters/2-t4gl.typ"

#chapter(label: <chap:non-solutions>)[Lösungsansätze]
#include "chapters/3-non-solutions.typ"

#chapter(label: <chap:persistence>)[Persistente Datastrukturen]
#include "chapters/4-persistent-data-structures.typ"

#chapter(label: <chap:impl>)[Implementierung]
#include "chapters/5-implementation.typ"

#chapter(label: <chap:benchmarks>)[Analyse & Vergleich]
#include "chapters/6-benchmarks.typ"

#chapter(label: <chap:conclusion>)[Fazit]
#include "chapters/7-conclusion.typ"
