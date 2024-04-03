#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#show: doc(
  kind: masters-thesis(
    id: [AI-1970-MA-999],
    title: [Dynamische Datenstrukturen unter Echtzeitbedingungen],
    author: "B. Sc. Erik Bünnig",
    supervisors: (
      "Prof. Dr. Kay Gürtzig",
      "Dipl-Ing. Peter Brückner",
    ),
    date: datetime(year: 2024, month: 01, day: 01),
    field: [Angewandte Informatik],
  ),
  listings: (
    (target: image, title: [Abbildungsverzeichnis]),
    (target: table, title: [Tabellenverzeichnis]),
    (target: raw,   title: [Listingverzeichnis]),
  ),
  listings-position: start,
  // glossary: import "/appendices/glossary.typ",
  // acronyms: import "/appendices/acronyms.typ",
  // bibliography: bibliography("/bibliography.yaml"),
)

#chapter[Intro] <chap:intro>
#include "chapters/1 - intro.typ"

#chapter[Basics] <chap:basics>
#include "chapters/2 - basics.typ"

#chapter[Concept] <chap:concept>
#include "chapters/3 - concept.typ"

#chapter[Implementation] <chap:impl>
#include "chapters/4 - impl.typ"

#chapter[Conculsion] <chap:conclusion>
#include "chapters/5 - conclusion.typ"
