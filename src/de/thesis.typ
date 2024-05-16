#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "/src/util.typ"

#show "C++": util.cpp

// convenient smallcaps for simple author names
#show regex("\b[A-Z]{2,}\b"): it => smallcaps(it.text.slice(0, 1) + lower(it.text.slice(1)))

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
  (
    key: "gls:t4gl",
    short: "T4gl",
    long: "Testing 4GL",
    desc: [Programmiersprache, Compiler und Laufzeitsystem unter Entwicklung bei @gls:bjig.],
  ),
  (
    key: "gls:bjig",
    short: "BJ-IG",
    long: "Brückner und Jarosch Ingeneurgesellschaft mbH",
    desc: [Dienstleister für Soft- und Hardwareentwicklung.],
  ),
  (
    key: "gls:instr",
    short: "Microstep",
    long: "Microstep",
    desc: [Atomare Instruktion im Kontext des @gls:t4gl[T4gl-Laufzeitsystems].],
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

#chapter[Grundlagen] <chap:basics>
#include "chapters/2-basics.typ"

#chapter[Konzept] <chap:concept>
#include "chapters/3-concept.typ"

#chapter[Implementierung] <chap:impl>
#include "chapters/4-impl.typ"

#chapter[Fazit] <chap:conclusion>
#include "chapters/5-conclusion.typ"
