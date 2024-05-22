#import "/src/util.typ": *
#import "/src/figures.typ"

= Problematik
Die in @sec:t4gl:arrays beschrieben T4gl-Arrays bestehen aus Komponenten in drei Ebenen:
+ T4gl: Die Instanzen aus Sicht des T4gl Programmierers.
+ Storage: Die Buffer aus Sicht des T4gl Programmierers, aber Instanzen aus sicht des T4gl-Laufzeitsystems.
+ Speicher: Die Buffer aus Sicht des T4gl-Laufzeitsystems. Diese Ebene ist für den T4gl Programmierer unsichtbar.

Zwischen den Ebenen 1 und 2 kommt geteilte Schreibfähigkeit durch Referenzzählung zum Einsatz, mehrere T4gl-Instanzen teilen sich eine Storage-Instanz und können von von dieser Lesen als auch in sie Schreiben.
Zwischen den Ebenen 2 und 3 kommt CoW + Referenzzählung zum Einsatz, mehrer Storage-Instanz teilen sich einen Buffer, Schreibzugriffe auf den Buffer sorgen vorher dafür dass die Storage-Instanz der einzige Referent ist, wenn nötig durch Kopie des gesamten Buffers.
Wir definieren je nach Ebene zwei Arten von Kopien:
/ seichte Kopie:
  Eine Kopie der T4gl-Instanz erstellt lediglich eine neue Instanz welche auf die gleichen Storage-Instanz zeigt.
  Wird in T4gl durch Initialisierung von Arrays durch existierende Instanzen oder die Übergabe von Arrays an normale Funktionen hervorgerufen.
/ tiefe Kopie:
  Eine Kopie der T4gl-Instanz *und* der Storage-Instanz welche beide auf den gleichen Buffer zeigen.
  Das erfolgt entweder über den expliziten Aufruf der Methode `clone` durch den T4gl Programmierer, oder bei Ausnahmefällen von Zuweisungen durch das Laufzeitsystem.

Bei einer seichten Kopie der Instanz `a` in @fig:t4gl-indirection:new ergibt sich die Instanz `b` in @fig:t4gl-indirection:shallow.
Eine tiefe Kopie hingegen führt zur Instanz `c` in @fig:t4gl-indirection:deep.
Obwohl eine tiefe Kopie zunächst nur auf Ebene 1 und 2 Instanzen Kopiert, erfolgt die Kopie der Daten auf Ebene 3 beim ersten Schreibzugriff einer der Instanzen (@fig:t4gl-indirection:mut).

#subpar.grid(
  figure(figures.t4gl.new, caption: [
    Ein T4gl Array nach Initalisierung. \ \
  ]), <fig:t4gl-indirection:new>,
  figure(figures.t4gl.shallow, caption: [
    Zwei T4gl-Arrays teilen sich eine C++ Instanz nach seichter Kopie.
  ]), <fig:t4gl-indirection:shallow>,
  figure(figures.t4gl.deep-new, caption: [
    Zwei T4gl-Arrays teilen sich einen Buffer nach tiefer Kopie. \ \
  ]), <fig:t4gl-indirection:deep>,
  figure(figures.t4gl.deep-mut, caption: [
    Zwei T4gl-Arrays teilen sich keinen Buffer nach tiefer kopie und Schreibzugriff.
  ]), <fig:t4gl-indirection:mut>,
  columns: 2,
  caption: [T4gl-Arrays in verschiedenen Stadien der Bufferteilung.],
  label: <fig:t4gl-indirection>,
)

#todo[
  Annotate the levels in the above figure to show which level manages which part of the system.
]

Durch die Teilung der Buffer in Ebene 3 nach einer tiefen Kopie kommt es somit nicht zur Kopie wenn keine weiteren Schreibzugriffe auf `a` oder `c` passieren.
Allerdings ist das selten der Fall.
Ein Hauptanwendungsfall für T4gl-Arrays ist die Ausgabe einer rollenden Historie von Werten einer Variable.
Wenn diese vom Laufzeitsystem erfassten Werte vom T4gl Programmierer ausgelesen werden, wird eine Tiefe Kopie der Storage-Instanz erstellt.
Die T4gl-Instanz welche an den Programmierer übergeben wird und die interne Storage-Instanz teilen sich einen Buffer welcher vom Laufzeitsystem zwangsläufig beim nächsten Schreibzugriff kopiert werden muss.
Diese Kopie und, daraus folgend, der Schreibzugriff haben dann eine Zeitkomplexität von $Theta(n)$.
Das gilt für jeden ersten Schreibzugriff, welcher nach einer Übergabe der Daten an den T4gl-Programmierer erfolgt.

#todo[
  Obwohl es bereits persistente Sequenzdatenstrukturen @bib:br-11 @bib:brsu-15 @bib:stu-15 und persistente assoziative Array Datenstrukturen @bib:hp-06 @bib:bm-70 @bib:bay-71 gibt welche bei Modifikationen nur die Teile des Buffers kopieren welche modifiziert werden müssen.
]
