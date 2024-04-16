#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "/src/util.typ"

#show "C++": util.cpp

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
  listings: (
    (target: image, title: [Abbildungsverzeichnis]),
    (target: table, title: [Tabellenverzeichnis]),
    (target: raw,   title: [Listingverzeichnis]),
  ),
  listings-position: start,
  bibliography: bibliography("/src/bibliography.yaml", title: "Literatur"),
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
Das ist ein Testkapitel, welches vor Fertigstellung der Arbeit gelöscht wird.
Es dient dazu Literaturverweise und anderes zu testen, wie zum Beispiel @bib:chunked-seq[S. 10].
