= T4gl
T4gl (#strong[T]esting *4GL* #footnote[4th Generation Language]) ist eine proprietäre Programmiersprache, sowie ein gleichnamiger Compiler und Laufzeitsystem, welche von der Brückner und Jarosch Ingenieurgesellschaft mbH (BJ-IG) entwickelt wird.
Die in T4gl geschriebenen Skripte werden vom Compiler analysiert und kompiliert, woraufhin sie vom Laufzeitsystem ausgeführt werden.
Dabei werden an das System in manchen Fällen Echtzeitanforderungen gestellt.

// TODO: elaborate on the requirements and the general mechanisms and terminology of t4gl

== T4gl-Arrays
Bei T4gl-Arrays handelt es sich nicht nur um gewöhnliche lineare Sequenzen, sondern um assoziative Multischlüssel-Arrays.
Um ein Array in T4gl zu Deklarierung wird mindestens ein Schlüssel und ein Wertetyp benötigt.
Auf den Wertetyp folgt in eckigen Klammern eine kommaseparierte Liste von Schlüsseltypen.
Indezierung erfolgt wie in der Deklaration durch eckige Klammern, es müssen aber nicht für alle Schlüssel ein Wert angegeben werden.
Bei Angabe von weniger Schlüsseln als in der Deklaration, wird eine Referenz auf einen Teil des Arrays zurückgegben.
Sprich, ein Array des Typs `T[U, V, W]` welches mit `[u]` indeziert wird, gibt ein Unter-Array des Typs `T[V, W]` zurück.
Wird in der Deklaration des Arrays ein Ganzahlwert statt einem Typen angegeben (z.B. `T[10]`), wird das Array mit fester Größe und vorgefüllten Werten angelegt.
Für ein solches Array können keine Schlüssel hinzugefügt oder entnommen werden.

#figure(
  ```t4gl
  String[Integer] map
  map[42] = "Hello World!"

  String[Integer, Integer] nested
  nested[0] = map
  nested[1, 37] = "first item in second sub array"

  String[10] static
  static[9] = "last item"
  ```,
  caption: [
    Beispiele für Deklaration und Indezierung von T4gl-Arrays.
    Die Deklaration von `static` enthält 10 Standardwerte für den `String` Typ (die leere Zeichenkette `""`) für die Schlüssel 0 bis einschließlich 9.
  ],
) <lst:t4gl-ex>

Bei den in @lst:t4gl-ex gegebenen Deklarationen werden je nach den angegebenen Typen verschiedene Datenstrukturen vom Laufzeitsystem gewählt, diese ähneln den analogen C++ Varianten in @tbl:t4gl-array-analogies.
Allerdings gibt es dabei gewisse Unterschiede.

#figure(
  table(columns: 2, align: left,
    table.header[Signatur][C++ Analogie],
    `T[N] name`, `std::array<T, N>`,
    `T[U] name`, `std::map<U, T> name`,
    `T[U, N] name`, `std::map<U, std::array<T, N>> name`,
    `T[N, U] name`, `std::array<std::map<U, T>, N> name`,
    align(center)[...], align(center)[...],
  ),
  caption: [
    Semantische Analogien in C++ zu spezifischen Varianten von T4gl-Arrays. `T` und `U` sind Typen und `N` ist eine Zahl aus $NN^+$.
  ],
) <tbl:t4gl-array-analogies>

Die Datenspeicherung im Laufzeitsystem kann nicht direkt ein statisches Array (`std::array<T, 10>`) verwenden, da T4gl nicht direkt in C++ übersetzt und kompiliert wird, sondern in Instruktionen welche vom Laufzeitsystem interpretiert werden.
Intern werden, je nach Schlüsseltyp, pro Dimension entweder eine dynamische Sequenzdatenstruktur oder ein geordentes assoiatives Array angelegt.
T4gl-Arrays werden intern durch Qt-Klassen verwaltet, diese implementieren einen Copy-on-Write Mechanismus, Kopien der Instanzen teilen sich den gleichen Buffer.
Im Gegensatz zu persistenten verknüpften Listen werden die Buffer nicht partiell geteilt, eine Modifikation am Buffer benötigt eine komplette Kopie des Buffers.
T4gl-Arrays sind daher nur zu einem gewissen grad _persistent_.

// TODO: elaborate more precisely on the writing problems as explained shortly in intro
// - [ ] expensive deep copies for writes on shared data
// - [ ] expensive deep copies for context switches
// - [ ] other not yet identified problems?

== Häufige Schreibzugriffe & Datenteilung
Ein Hauptnutzungsfall dieser Arrays ist das Speichern von geordneten Wertereihen als Historie einer Variable.
Beim Erfassen der Historie wird das Array dauerhaft mit neuen Werten belegt welche am Ende der Wertereihe liegen.
Wird das Array an ein Skript übergeben, kommt es zu einer flachen Kopie, welche lediglich die Referenzzahl der Daten erhöht.
Beim nächsten Schreibzugriff durch das Anhaften neuer Werte, kommt es zur tiefen Kopie, da die unterliegenden Daten nicht mehr nur einen Referenten haben.

== Multithreading
Wird eine Array an eine Funktion übergeben welche auf einem einderen Thread ausgeführt wird, wird eine tiefe Kopie angelegt.

In beiden Fällen werden tiefe Kopien von Datenmengen angelegt welche dem Scheduler unbekannt sind.
Dabei entstehen Latenzen welche das Laufzeitsystem verlangsamen und dessen Echtzeiteinhaltung beeinflussen.

= Stand der Technik
// TODO: talk about optimized general purpose implementations of such as rrb vectors, chunked sequnces and finger trees

// NOTE: QMaps use std::maps by default, which "usually" use red-black-trees, seems to be an implementaiton detail again
// NOTE: QMaps only do top level sharing, unmodified branches are not shared across copies
// NOTE: As far as I am aware, t4gl arrays are really just either vectors or maps (depeniding on key type) exactly as the analogies show

= Rahmenbedingungen
Bei der Entwicklung dieser verbesserten Datenstruktur werden folgenden Einschränkungen gestellt:
- Schlüsseltypen sind numerisch oder können numerisch dargestellt werden, Arrays mit Schlüsseltypen wie `String` sind von der Verbesserung zunächst ausgeschlossen.
- Viele geringe Latenzen sind wenigen hohen Latenzen vorzuziehen. Armortisierung muss teure Operationen gleich verteilen.

