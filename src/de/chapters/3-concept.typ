#import "/src/util.typ": *

#todo[
  Elaborate on the Problems of T4gl-Arrays:
  - [ ] expensive deep copies for writes on shared data
  - [ ] expensive deep copies for context switches
  - [ ] other not yet identified problems?
]

#todo[
  Clearly communicate that these problems are largely with respect to the underlying data structure, i.e the Qt-Types, not the T4gl-Arrays themselves.
]

#todo[
  Talk about how the solution will use a persistent tree data structure to mitigate the complexity of copying when buffers are shared.

  See source code for a draft taken from chapter 2.

  // Ein Hauptproblem von T4gl-Arrays ist, dass Modifikationen der Arrays bei nicht-einzigartigem Referenten eine Kopie des gesamten Buffers benötigt.
  // Obwohl es bereits persistent Sequenzdatenstrukturen @bib:br-11 @bib:brsu-15 @bib:stu-15 und assoziative Array Datenstrukturen @bib:hp-06 @bib:bm-70 @bib:bay-71 gibt welche bei Modifikationen nur die Teile des Buffers kopieren welche modifiziert werden müssen.
]
