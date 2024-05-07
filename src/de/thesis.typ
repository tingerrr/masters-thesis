#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "/src/util.typ"

#show "C++": util.cpp

#let bib = "/src/bib.yaml"
#let glossary = (
  (
    key: "gls:cow",
    short: "CoW",
    long: "Copy-on-Write",
    desc: [Kopie-bei-Schreibzugriff (_engl._), Mechanismus für @gls:per.],
  ),
  (
    key: "gls:buf",
    short: "Buffer",
    desc: [Der Speicherbereich einer Datenstruktur welche die eigentlichen Datenenthält.],
  ),
  (
    key: "gls:mut",
    short: "Schreibfähigkeit",
    desc: [Möglichkeit von Schreibzugriffen auf eine Instanz ohne Rückgabe neuer Instanz.],
  ),
  (
    key: "gls:per",
    short: "Langlebigkeit",
    desc: [
      Auch Persistenz, Intakthaltung früherer Versionen von Daten bei Schreibzugriffen (Gegenteil zu @gls:eph).
    ],
  ),
  (
    key: "gls:eph",
    short: "Kurzlebgikeit",
    desc: [
      Keine Intakthaltung früherer versionen von Daten bei Schreibzugriffen (Gegenteil zu @gls:per).
    ],
  ),
)

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
  glossary: glossary,
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
