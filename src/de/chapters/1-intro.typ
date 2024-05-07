#import "/src/util.typ": *

= Motivation
Das Endziel dieser Arbeit ist die Verbesserung der Latenzen des T4gl-Laufzeitsystems durch Analyse und gezielte Verbesserung der Datenspeicherung von T4gl-Arrays.
Die in T4gl verwendeten assoziativen Arrays sind in ihrer jetzigen Form für manche Nutzungsfälle unzurreichend optimiert.
Häufige Schreibzugriffe und unzureichend granulare Datenteilung verursachen unnötig tiefe Kopien der Daten und darausfolgende Latenzen.

#todo[
  Explain the general problems this thesis aims to solve
  - [x] expensive deep copies for writes on shared data
  - [ ] expensive deep copies for context switches
  - [ ] other not yet identified problems?
]

= Herangehensweise
#todo[Short explanation of the general idea of partial peristence to solve these problems.]

= Anleitung zum Lesen
#todo[Add a short reading guide explaining the chapters and document structure.]
