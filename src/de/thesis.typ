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
    (title: [Kurzfassung], body: [
      Die Verwendung dynamischer Datenstrukturen unter Echtzeitbedingungen muss genau geprüft werden um sicher zustellen, dass ein Echtzeitsystem dessen vorgegebene Aufgaben in der erwarteten Zeit erfüllen kann.
      Ein solches Echtzeitsystem ist das Laufzeitsystem der T4gl-Progrmmiersprache, eine Domänenspezifische Sprache für Reifenprüfmaschinen.
      In dieser Arbeit wird untersucht, auf welche Weise die in T4gl verwendeten Datenstrukturen optimiert oder ausgetauscht werden können um das Zeitverhalten unter Schlimmstbedingungen zu verbessern.
      Dabei werden vorallem persistente Datenstrukturen implementiert, getestet und verglichen.
    ]),
    (title: [Abstract], body: [
      The usage of dynamic data strucutres under real time constraints must be analyzed precisely in order to ensure that a real time system can execute its tasks in the expected time.
      Such a real time system is the runtime of the T4gl programming language, a domain-specific language for tire measurement machines.
      This thesis is concerned with the analysis, optimization and re-implementation of T4gl's data structures, in order to improve thier worst-case time complexity.
      For this, various, but foremost persistent data structures are implemented, benchmarked and compared.
    ]),
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
