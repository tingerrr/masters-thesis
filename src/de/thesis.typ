#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "/src/util.typ"

#show "C++": util.cpp

// convenient smallcaps for simple author names
#show regex("![A-Z]{2,}\b"): it => smallcaps(upper(it.text.slice(1, 2)) + lower(it.text.slice(2)))

#let bib = "/src/bib.yaml"

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
  outlines: (
    (target: image, title: [Abbildungsverzeichnis]),
    (target: table, title: [Tabellenverzeichnis]),
    (target: raw,   title: [Listingverzeichnis]),
  ),
  outlines-position: start,
  bibliography: bibliography(bib, title: "Literatur"),
)

#set raw(syntaxes: "/assets/t4gl.sublime-syntax")

#chapter[Einleitung] <chap:intro>
#include "chapters/1-intro.typ"

#chapter[Grundlagen] <chap:basics>
#include "chapters/2-basics.typ"

#chapter[Konzept] <chap:concept>
#include "chapters/3-concept.typ"

#chapter[Implementierung] <chap:impl>
#include "chapters/4-impl.typ"

#chapter[Fazit] <chap:conclusion>
#include "chapters/5-conclusion.typ"
