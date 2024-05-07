#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "/src/util.typ"

#show "C++": util.cpp

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

#chapter[Konzept] <chap:concept>
#include "chapters/2-concept.typ"

#chapter[Implementierung] <chap:impl>
#include "chapters/3-impl.typ"

#chapter[Fazit] <chap:conclusion>
#include "chapters/4-conclusion.typ"

#chapter[Platzhalter]
Dieses Kapitel wird vor der Publikation gelöscht.

// BUG: bibliography(full: true) will not give us the correct references, since this is only for testing this is fine
// see: https://github.com/typst/typst/issues/3986
#for (key, _) in yaml(bib) {
  cite(label(key))
}
