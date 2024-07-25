#import "/src/util.typ": *
#import "/src/figures.typ"

T4gl (_engl._ #strong[T]esting #strong[4]th #strong[G]eneration #strong[L]anguage) ist ein proprietäres Softwareprodukt zur Entwicklung von Testsoftware für Reifenprüfanlagen.
T4gl steht bei der Brückner und Jarosch Ingenieurgesellschaft mbH (BJ-IG) unter Entwicklung und umfasst die folgenden Komponenten:
- Programmiersprache
  - Anwendungsspezifische Features
- Compiler
  - Statische Anaylse
  - Übersetzung in Instruktionen
- Laufzeitsystem
  - Ausführen der Instruktionen
  - Scheduling von Green Threads
  - Bereitstellung von Maschinen- oder Protokollspezifischen Schnittstellen

Wird ein T4gl-Script dem Compiler übergeben startet dieser zunächst mit der statischen Analyse.
Bei der Analyse der Skripte werden bestimmte Invarianzen geprüft, wie die statische Länge bestimmter Arrays, die Typsicherheit und die syntaktische Korrektheit des Scripts.
Nach der Analyse wird das Script in eine Sequenz von _Microsteps_ (Atomare Instruktionen) kompiliert.
Im Anschluss führt des Laufzeitsystem die kompilierten _Microsteps_ aus, verwaltet Speicher und Kontextwechsel der _Microsteps_ und stellt die benötigten Systemschnittstellen zur Verfügung.

= Scheduling
#todo[
  Introduce t4gl's scheduling and runtime model and how certain operations are or aren't broken into microsteps.
  This will later be relevant for the realtime analysis of the new storage data structure.
  Especially with regards to which steps must complete in a certian time and which don't.
  Maybe include the figure from the wiki explaining the execution model und how latencies introduced by longrunning instructions can break the real time constraints.
]

= Echtzeitanforderungen <sec:realtime>
Je nach Anwendungsfall werden an das T4gl-Laufzeitsystem Echtzeitanforderungen gestellt.

#quote(block: true, attribution: [
  Peter Scholz @bib:sch-05[S. 39] unter Verweis auf DIN 44300
])[
  Unter Echtzeit versteht man den Betrieb eines Rechensystems, bei dem Programme zur Verarbeitung anfallender Daten ständig betriebsbereit sind, derart, dass die Verarbeitungsergebnisse innerhalb einer vorgegebenen Zeitspanne verfügbar sind.
  Die Daten können je nach Anwendungsfall nach einer zeitlich zufälligen Verteilung oder zu vorherbestimmten Zeitpunkten anfallen.
]

Ist ein Echtzeitsystem nicht in der Lage, eine Aufgabe in der vorgegebenen Zeit vollständig abzuarbeiten, spricht man von Verletzung der Echtzeitbedingungen, welche an das System gestellt wurden.
Je nach Strenge der Anforderungen lassen sich Echtzeitsysteme in drei verschiedene Stufen einteilen:
/ Weiches Echtzeitsystem:
  Die Verletzung der Echtzeitbedinungen führt zu degenerierter, aber nicht zerstörter Leistung des Echtzeitsystems und hat _keine_ katastrophalen Folgen @bib:lo-11[S. 6].
/ Festes Echtzeitsystem:
  Eine geringe Anzahl an Verletzungen der Echtzeitbedingungen hat katastrophale Folgen für das Echtzeitsystem  @bib:lo-11[S. 7].
/ Hartes Echtzeitsystem:
  Eine einzige Verletzung der Echtzeitbedingungen hat katastrophale Folgen für das Echtzeitsystem @bib:lo-11[S. 6].

#todo[
  Reduce this to simply mention hard and firm realtime, but since they aren't important the definitions can go.
]

Für Anwendungsfälle in denen Echtzeitanforderungen an T4gl gestellt werden, gibt es bei Nichteinhaltung keine katastrophalen Folgen, es müssen lediglich Testergibnisse verwofen werden.
T4gl ist demnach ein weiches Echtzeitsystem.

= T4gl-Arrays <sec:t4gl:arrays>
Bei T4gl-Arrays handelt es sich um mehrdimensionale assoziative Arrays mit Schlüsseln, welche eine voll definierte Ordnungsrelation haben.
Um ein Array in T4gl zu deklarieren, wird mindestens ein Schlüssel- und ein Wertetyp benötigt.
Auf den Wertetyp folgt in eckigen Klammern eine komma-separierte Liste von Schlüsseltypen.
Indiezierung erfolgt wie in der Deklaration durch eckige Klammern, es muss aber nicht für alle Schlüssel einen Wert angegeben werden.
Bei Angabe von weniger Schlüsseln als in der Deklaration, wird eine Referenz auf einen Teil des Arrays zurückgegben.
Sprich, ein Array des Typs `T[U, V, W]` welches mit `[u]` indieziert wird, gibt ein Unter-Array des Typs `T[V, W]` zurück.
Wird in der Deklaration des Arrays ein Ganzzahlwert statt eines Typs angegeben (z.B. `T[10]`), wird das Array mit fester Größe und Standartwerten und durchlaufenden Schlüsseln (`0` bis `9`) angelegt.
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
    Beispiele für Deklaration und Indiezierung von T4gl-Arrays.
  ],
) <lst:t4gl-ex>

Bei den in @lst:t4gl-ex gegebenen Deklarationen werden je nach den angegebenen Typen verschiedene Datenstrukturen vom Laufzeitsystem gewählt, diese ähneln den analogen C++ Varianten in @tbl:t4gl-array-analogies, wobei `T` und `U` Typen sind und `N` eine Zahl aus $NN^+$.
Die Deklaration von `static` enthält 10 Standardwerte für den `String` Typ (die leere Zeichenkette `""`) für die Schlüssel 0 bis einschließlich 9.
Es handelt sich um eine Sonderform des T4gl-Arrays, welches eine dichte festgelegte Schlüsselverteilung hat (es entspricht einem gewöhnlichen Array).

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
    Semantische Analogien in C++ zu spezifischen Varianten von T4gl-Arrays.
  ],
) <tbl:t4gl-array-analogies>

Die Datenspeicherung im Laufzeitsystem kann nicht direkt ein statisches Array (`std::array<T, 10>`) verwenden, da T4gl nicht direkt in C++ übersetzt und kompiliert wird.
Intern werden, je nach Schlüsseltyp, pro Dimension entweder ein Vektor oder ein geordnetes assoziatives Array angelegt.
T4gl-Arrays verhalten sich wie Referenztypen, wird eine Array `array2` durch ein anderes Array `array1` initialisiert, teilen sich diese die gleichen Daten.
Schreibzugriffe in einer Instanz sind auch in der anderen lesbar (Demonstiert in @lst:t4gl-ref).

#figure(
  ```t4gl
  String[10] array1
  String[10] array2 = array1

  array1[0] = "Hello World!"
  // array1[0] == array2[0]
  ```,
  caption: [Demonstration von Referenzverhalten von T4gl-Arrays.],
) <lst:t4gl-ref>

Im Gegensatz zu dem Referenzverhalten der Arrays aus sicht des T4gl-Programmieriers steht die Implementierug durch _Qt-Maps_, bei diesen handelt es sich um Copy-On-Write (CoW) Datenstrukturen.
Mehrere Instanzen teilen sich die gleichen Daten und erlauben zunächst nur Lesezugriffe darauf.
Muss eine Instanz einen Schreibzugriff durchführen, wird vorher sichergestellt, dass diese Instanz der einzige Referent der Daten ist, wenn nötig durch eine Kopie der gesamten Daten.
Dadurch sind Kopien von _Qt-Maps_ initial sehr effizient, es muss lediglich die Referenzzahl der Daten erhöht werden.
Die Kosten der Kopie zeigt sich erst dann, wenn ein Scheibzugriff nötig ist.

Damit sch T4gl-Arrays trotzdem wie Referenzdaten verhalten, teilen sie sich nicht direkt die Daten mit CoW-Semantik, sondern _Qt-Maps_ durch eine weitere Indirektionsebene.
T4gl-Arrays bestehen aus Komponenten in drei Ebenen:
+ T4gl: Die Instanzen aus Sicht des T4gl-Programmierers (z.B. die Variable `array1` in @lst:t4gl-ref).
+ Indirektionsebene: Die Daten aus Sicht des T4gl-Programmierers, die Ebene zwischen T4gl-Array Instanzen und deren Daten.
  Dabei handelt es sich um _Qt-Datentypen_ wie _Qt-Maps_ oder _Qt-Vectors_.
+ Speicherebene: Die Daten aus Sicht des T4gl-Laufzeitsystems. Diese Ebene ist für den T4gl-Programmierer unsichtbar.

Zwischen den Ebenen 1 und 2 kommt geteilte Schreibfähigkeit durch Referenzzählung zum Einsatz, mehrere T4gl-Instanzen teilen sich eine _Qt-Instanz_ und können von dieser lesen, als auch in sie schreiben, ungeachtet der Anzahl der Referenten.
Zwischen den Ebenen 2 und 3 kommt CoW + Referenzzählung zum Einsatz, mehrere _Qt-Instanz_ teilen sich die gleichen Daten, Schreibzugriffe auf die Daten sorgen vorher dafür, dass die _Qt-Instanz_ der einzige Referent ist, wenn nötig durch eine Kopie.
Wir definieren je nach Teife drei Arten von Kopien:
/ Typ-1 (seichte Kopie):
  Eine Kopie der T4gl-Instanz erstellt lediglich eine neue Instanz, welche auf die gleichen _Qt-Instanz_ zeigt.
  Wird in T4gl durch Initialisierung von Arrays durch existierende Instanzen oder die Übergabe von Arrays an normale Funktionen hervorgerufen.
  Eine seichte Kopie ist immer eine $Theta(1)$ Operation.
/ Typ-2:
  Eine Kopie der T4gl-Instanz *und* der _Qt-Instanz_, welche beide auf die gleichen Daten zeigen.
  Wird eine tiefe Kopie durch das Laufzeitsystem selbst hervorgerufen, erfolgt die Kopie der Daten verspätet beim nächten Schreibzugriff auf eine der _Qt-Instanzen_.
  Halbtiefe Kopien sind Operationen konstanter Zeitkomplexität $Theta(1)$.
  Aus einer halbtiefen Kopie und einem Schreibzugriff folgt eine volltiefe Kopie.
/ Typ-3 (tiefe Kopie):
  Eine Kopie der T4gl-Instanz, der _Qt-Instanz_ *und* der Daten.
  Beim explizitem Aufruf der Methode `clone` durch den T4gl Programmierer werden die Daten ohne Verzögerung kopiert.
  Tiefe Kopien sind Operationen linearer Zeitkomplexität $Theta(n)$.

Bei einer Typ-1 Kopie der Instanz `a` in @fig:t4gl-indirection:new ergibt sich die Instanz `b` in @fig:t4gl-indirection:shallow.
Eine Typ-2 Kopie hingegen führt zur Instanz `c` in @fig:t4gl-indirection:deep.
Obwohl eine tiefe Kopie zunächst nur auf Ebene 1 und 2 Instanzen Kopiert, erfolgt die Typ-3 Kopie der Daten auf Ebene 3 beim ersten Schreibzugriff einer der Instanzen (@fig:t4gl-indirection:mut).

In seltenen Fällen kann es dazu führen, dass wie in @fig:t4gl-indirection:deep eine Typ-2 Kopie angelegt wurde, aber nie ein Schreibzugriff auf `a` oder `c` durchgeführt wird, während beide Instanzen existieren.
Sprich, es kommt zur Typ-2 Kopie, aber nicht zur Typ-3 Kopie.
Diese Fälle sind nicht nur selten, sondern meist auch Fehler der Implementierung.
Bei korrektem Betrieb des Laufzeitsystems sind Typ-2 Kopien kurzlebig und immer von Typ-3 Kopien gefolgt, daher betrachten wir im folgenden auch Typ-2 Kopien als Operationen linearer Zeitkomplexität $Theta(n)$.

#subpar.grid(
  figure(figures.t4gl.new, caption: [
    Ein T4gl Array nach Initalisierung. \ \
  ]), <fig:t4gl-indirection:new>,
  figure(figures.t4gl.shallow, caption: [
    Zwei T4gl-Arrays teilen sich eine C++ Instanz nach seichter Kopie.
  ]), <fig:t4gl-indirection:shallow>,
  figure(figures.t4gl.deep-new, caption: [
    Zwei T4gl-Arrays teilen sich die gleichen Daten nach tiefer Kopie. \ \
  ]), <fig:t4gl-indirection:deep>,
  figure(figures.t4gl.deep-mut, caption: [
    Zwei T4gl-Arrays teilen sich keine Daten nach tiefer Kopie und Schreibzugriff.
  ]), <fig:t4gl-indirection:mut>,
  columns: 2,
  caption: [T4gl-Arrays in verschiedenen Stadien der Datenteilung.],
  label: <fig:t4gl-indirection>,
)
#todo[
  Annotate the levels in the above figure to show which level manages which part of the system.
]

Ein Hauptanwendungsfall für T4gl-Arrays ist die Ausgabe einer rollenden Historie von Werten einer Variable.
Wenn diese vom Laufzeitsystem erfassten Werte vom T4gl-Programmierer ausgelesen werden, wird eine Typ-2 Kopie erstellt.
Die T4gl-Instanz, welche an den Programmierer übergeben wird, sowie die interne _Qt-Instanz_ teilen sich Daten, welche vom Laufzeitsystem zwangsläufig beim nächsten Schreibzugriff kopiert werden müssen.
Es kommt zur Typ-3 Kopie, und daraus folgend, zu einem nicht-trivialem zeitlichem Aufwand von $Theta(n)$.
Das gilt für jeden ersten Schreibzugriff, welcher nach einer Übergabe der Daten an den T4gl-Programmierer erfolgt.
