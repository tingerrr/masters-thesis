#lorem(10)

// NOTE: partial persistence as basis for new t4gl arrays

// Ein Hauptproblem von T4gl-Arrays ist, dass Modifikationen der Arrays bei nicht-einzigartigem Referenten eine Kopie des gesamten Buffers benötigt.
// Obwohl es bereits @gls:per[persistent] Sequenzdatenstrukturen @bib:br-11 @bib:brsu-15 @bib:stu-15 und assoziative Array Datenstrukturen @bib:hp-06 @bib:bm-70 @bib:bay-71 gibt welche bei Modifikationen nur die Teile des @gls:buf[s] kopieren welche modifiziert werden müssen.
// Partielle @gls:per[Persistenz] kann durch verschiedene Implementierungen umgesetzt werden, semantisch handelt es sich aber fast immer um Baumstrukturen.
// Sie soll als Grundlage der neuen T4gl-Arrays dienen.
