#import "/src/util.typ": *
#import "/src/figures.typ"

= Komplexität und Landau-Symbole <sec:complexity>
Für den Verlauf dieser Arbeit sind Verständnis von Zeit- und Speicherkomplexität und der verwendeten !LANDAU-Symbole unabdingbar.
Komplexitätstheorie befasst sich mit der Komplexität von Algorithmen und algorithmischen Problemen, vor allem in Bezug auf Speicherverbrauch und Bearbeitungszeit.
Dabei sind folgende Begriffe relevant:

/ Zeitkomplexität:
  Zeitverhalten eines Algorithmus über eine Menge von Daten in Bezug auf die Anzahl dieser @bib:clrs-09[S. 44].
/ Speicherkomplexität:
  Der Speicherbedarf eines Algorithmus zur Bewältigung eines Problems @bib:clrs-09[S. 44].
  Wird auch für den Speicherbedarf von Datenstrukturen verwendet.
/ Amortisierte Komplexität:
  Unter Bezug einer Sequenz von $n$ Operationen mit einer Dauer von $T(n)$, gibt die amortisierte Komplexität den Durchschnitt $T(n)\/n$ einer einzigen Operation an @bib:clrs-09[S. 451].

!LANDAU-Symbole umfassen Symbole zur Klassifizierung der asymptotischen Komplexität von Funktionen und Algorithmen.
Im folgenden werden Variationen der !KNUTH'schen Definitionen verwendet @bib:knu-76[S. 19] @bib:clrs-09[S. 44-48], sprich:

#figures.big-o <eq:big-o>

Trotz der definition der Symbole in @eq:big-o als Mengen schreibt man $g(n) = O(f(n))$, wenn $g(n)$ die obere asymptotische Grenze $f(n)$ hat, gleicherweise gibt $Omega(f(n))$ eine untere asymptotische Grenze an.
Es gilt $g(n) = Theta(f(n))$ wenn sowohl $g(f) = O(f(n))$ als auch $g(f) = Omega(f(n))$ gilt @bib:clrs-09[S. 48, Theorem 3.1].
Die Varianten $o(f(n))$ und $omega(f(n))$ werden im Weiteren nicht verwendet.
@tbl:landau zeigt verschiedene Komplexitäten in aufsteigender Ordnung der Funktion $f(n)$, dabei steht $alpha$ für ein Symbol aus @eq:big-o.
Unter Betrachtung der asymptotischen Komplexität werden konstante Faktoren und Terme geringerer Ordnung generell ignoriert, sprich $g(n) = 2n^2 + n = O(n^2)$.
Die Richtung der Gleichung hat dabei Relevanz und ähnelt eher einer Elementenrelation $g(f) in O(f(n))$ oder einer Teilmengenrelation (bei !LANDAU-Symbolen auf beiden Seiten) @bib:knu-76[S. 20].
!KNUTH behält die Gleichungsnotation konventionshalber, im weiteren wird sich ebenfalls an diese Konvention gehalten.

#figure(
  table(columns: 2, align: left,
    table.header[Komplexität][Beschreibung],
    $alpha(1)$, [Konstante Komplexität, unabhängig der Menge der Daten $n$],
    $alpha(log_k n)$, [Logarithmische Komplexität über die Menge der Daten $n$ zur Basis $k$],
    $alpha(n)$, [Lineare Komplexität über die Menge der Daten $n$],
    $alpha(n^k)$, [Polynomialkomplexität des Grades $k$ über die Menge der Daten $n$],
    $alpha(k^n)$, [Exponentialkomplexität über die Menge der Daten $n$ zur Basis $k$],
  ),
  caption: [
    Unvollständige Liste verschiedener Komplexitäten in aufsteigender Reihenfolge.
  ],
) <tbl:landau>

= Dynamische Datenstrukturen
Datenstrukturen sind Organisierungsstrukturen der Daten im Speicher eines Rechensystems.
Der Aufbau dieser Datenstrukturen hat Einfluss auf deren Speicherbedarf und das Zeitverhalten verschiedener Operationen auf diesen Datenstrukturen.
Die Wahl der Datenstruktur ist abhängig vom Anwendungsfall und den Anforderungen der Datenverwaltung.

Dynamische Datenstrukturen sind Datenstrukturen welche vor allem dann Verwendung finden, wenn die Anzahl der verwalteten Elemente nicht vorraussehbar ist.
Ein klassisches Beispiel für eine dynamische Datenstruktur ist der Vektor, ein dynamisches Array.

#figure(
  ```cpp

  #import <vector>

  int main() {
    std::vector<int> vec;

    vec.push_back(3);
    vec.push_back(2);
    vec.push_back(1);

    return 0;
  }
  ```,
  caption: [
    Ein C++ Program welches einen `std::vector` anlegt und mit Werten befüllt.
  ],
) <lst:vec-ex>

Die C++ Standardbibliothek stellt unter der Header-Datei `<vector>` die gleichnamige Template-Klasse bereit.
`std::vector` verfügt über Methoden, welche eigenhändig den Speicher erweitern, insofern das für die gegebene Operation nötig oder möglich ist.
So wird zum Beispiel bei der Verwendung von `push_back` der Speicher erweitert, wenn die jetzige Kapazität des Vektors unzureichend ist.
@lst:vec-ex zeigt wie ein `std::vector` angelegt und stückweise befüllt werden kann, dabei wird zum ersten Aufruf von `push_back` der dynamische Speicher angelegt.
Muss der Speicher zum Erweitern verschoben werden, ergibt sich eine Zeitkomplexität von $O(n)$ ($n = $ Anhzal der Element im Vektor).
#footnote[
  Die Zeitkomplexität von `push_back` über die gesamte Lebenszeit eines Vektors ist durch den Wachstumsfaktor amortisiert Konstant @bib:iso-cpp-20[S. 834].
  Wird die Kapazität vorher reserviert und nicht überschritten, ist die Komplexität $O(1)$.
]
Nach dem dritten Aufruf von `push_back` enthält der Vektor die Sequenz `[3, 2, 1]`.
Ein Vektor bringt über dem herkömmlichen Array verschiedene Vor- und Nachteile mit sich.

// NOTE: typst needs general purpose sticky elements, these are not headings, but behave very similar
#block(breakable: false)[
  *Vorteile*
  - Die Kapazität ist nicht fest definiert, es kann zur Laufzeit entschieden werden wie viele Objekte gespeichert werden.
  - Die Verwaltung des Buffers wird automatisch durch den Vektor übernommen.
]
#block(breakable: false)[
  *Nachteile*
  - Durch die unbekannte Größe können Iterationen über die Struktur seltener aufgerollt oder anderweitig optimiert werden.
  - Der Buffer der Datenstruktur kann meist nicht ohne Indirektion angelegt werden, sprich eine Instanz enthält meist die Elemente nicht direkt, sondern nur einen Pointer zum eigentlichen Buffer. #footnote[
    Manche Programmiersprachen unterstützen dynamische Speicheranlegung ohne Indirektion wie `alloca` oder "Variable-Sized Types" welche Indirektion in manchen Fällen verhindern können.
  ]
]

Die bekannte Größe eines Arrays hat nicht nur Einfluss auf die Optimierungsmöglichkeiten eines Programms, sondern auch auf die Komplexitätsanalyse.
Ist die Länge der Iteration bereits zur Analysezeit bekannt, kann diese wie eine Konstante behandelt werden.

#figure(
  ```cpp
  void print_array(std::array<int, 3>& arr) {
    for (const int& value : arr) {
      std::cout << value << std::endl;
    }
  }
  ```,
  caption: [
    Eine Funktion welche über ein `std::array` der Länge 3 iteriert und dessen Werte ausgibt.
  ],
) <lst:array-ex>

Die Zeitkomplexität von `print_array` in @lst:array-ex ist $Theta(n)$ mit $n = 3$, für die weitere Analyse kann die Zeitkomplexität von `print_array` als $Theta(1)$ betrachtet werden.
@lst:array-ex-unrolled zeigt eine alternative Schreibweise der Schleife aus @lst:array-ex.
#footnote[
  Unter Anwendung von Compiler-Optimierungen wird dies, wenn sinnvoll, automatisch vorgenommen.
]

#figure(
  ```cpp
  std::cout << value[0] << std::endl;
  std::cout << value[1] << std::endl;
  std::cout << value[2] << std::endl;
  ```,
  caption: [Die Schleife aus @lst:array-ex nach dem Aufrollen.],
) <lst:array-ex-unrolled>

Es folgt aus der Substitution, dass das Programm keine Schleifen enthält deren Höchstiterationszahl nicht bekannt ist.
Man vergleiche dies mit dem Programm in @lst:vector-ex.
Die Schleife ist nicht mehr trivial aufrollbar, da über die Anzahl der Elemente in `vec` ohne Weiteres keine Annahme gemacht werden kann.
Die Zeitkomplexität der Funktion `print_vector` ist $Theta(n)$.

#figure(
  ```cpp
  void print_vector(std::vector<int>& vec) {
    for (const int& value : vec) {
      std::cout << value << std::endl;
    }
  }
  ```,
  caption: [
    Eine Funktion ähnlich der aus @lst:array-ex, mit einem `std::vector`, statt einem `std::array`.
  ],
) <lst:vector-ex>

Es ist nicht unmöglich fundierte Vermutungen über die Anzahl von Elementen in einer Datenstruktur anzustellen, dennoch fällt es mit dynamischen Datenstrukturen schwerer alle Invarianzen eines Programms bei der Analyse zu berücksichtigen.

= Persistenz und Kurzlebigkeit <sec:per-eph>
Wenn eine Datenstruktur bei Schreibzugriffen die bis dahin bestehenden Daten nicht verändert gilt diese als _persistent/langlebig_ @bib:kt-96[S. 202].
Im Gegensatz dazu stehen Datenstrukturen welche bei Schreibzugriffen ihre Daten direkt beschreiben, diese gelten als _kurzlebig_.
Persistente Datenstrukturen erstellen meist neue Instanzen für jeden Schreibzugriff welche die Daten der vorherigen Instanz teilen.
Ein gutes Beispiel bietet die einfach verknüpfte Liste (@fig:linked-sharing).

#set grid.cell(breakable: false)
#subpar.grid(
  figure(figures.list.new, caption: [
    Eine Liste `l` wird über die Sequenz `[A, B, C]` angelegt.
  ]),
  figure(figures.list.copy, caption: [
    Eine Kopie `m` von `l` teilt sich den Kopf der Liste mit `l`.
  ]),
  figure(figures.list.pop, caption: [
    // NOTE: the double linebreaks are a bandaid fix for the otherwise unaligned captions
    Soll der Kopf von `m` gelöscht werden, zeigt `m` stattdessen auf den Rest. \ \
  ]),
  figure(figures.list.push, caption: [
    Soll ein neuer Kopf an `n` angefügt werden, kann der Rest weiterhin geteilt werden.
  ]),
  columns: 2,
  caption: [
    Eine Abfolge von Operationen auf persistenten verknüpften Listen.
  ],
  label: <fig:linked-sharing>,
)

Die in @fig:linked-sharing gezeigte Trennung von Kopf und Instanz ermöglicht im folgenden klare Terminologie für bestimmte Konzepte der Persistenz.

/ Buffer:
  Der Speicherbereich einer Datenstruktur welche die eigentlichen Daten enthält in @fig:linked-sharing beschreibt das die Knoten mit einfachem Strich. Während die doppelgestrichenen Knoten die Instanzen sind.
  Bei einer CoW Datenstruktur können sich viele Instanzen einen einzigen Buffer teilen.
/ Schreibfähigkeit:
  Möglichkeit von Schreibzugriffen ohne die vorherigen Daten intakt zu lassen.
  Das steht im Gegensatz zu persistenten Datenstrukturen, welche bei jedem Schreibzugriff.
  Die Listen in @fig:linked-sharing sind Teilweise schreibfähig, da eine Instanz selbst schreibfähig ist, aber geteilte Daten nicht von einer Instanz allein verändert werden können.
/ Copy-on-Write (CoW):
  Mechanismus zur Bufferteilung + Schreibfähigkeit, viele Instanzen teilen sich einen Buffer.
  Eine Instanz gilt als Referent des Buffers auf welchen sie zeigt.
  Ist diese Instanz der einzige Referent, könnne die Daten direkt beschrieben werden, ansonsten wird der geteilte Buffer kopiert (teilweise insofern möglich), sodass die Instanz einziger Referent des neuen Buffers ist. #no-cite

#todo[
  Elaborate on the different types of mutability and cow granularity depending on where it happens (instanz vs buffer).
]

Persistenz zeigt vorallem bei Baumstrukturen ihre Vorteile, bei der Kopie des Buffers eines persistenten Baums können je nach Tiefe und Balance des Baumes Großteile des Baumes geteilt werden.
Ähnlich persistenter einfacher verknüpfter Listen werden bei Schreibzugriffen auf peristente Bäume der originale Baum kopiert und nur die Knoten des Buffers kopiert welche zwischen Wurzel und dem veränderten Knoten liegen.
@fig:tree-sharing illustriert wie an einen Baum `t` ein Knoten `X` angefügt werden kann ohne dessen {Persistenz aufzugeben.

#subpar.grid(
  figure(figures.tree.new, caption: [
    Eine Baumstruktur `t` an welche ein neuer Knoten `X` unter `C` angefügt werden soll.
  ]), <fig:tree-sharing:new>,
  figure(figures.tree.shared, caption: [
    Bei Hinzufügen des Knotens `X` als Kind des Knotens `C` wird ein neuer Baum `m` angelegt.
  ]), <fig:tree-sharing:shared>,
  columns: 2,
  caption: [
    Partielle Persistenz teilt zwischen mehreren Instanzen die Teile des Buffers welche sich nicht verändert haben, ähnlich der Persistenz in @fig:linked-sharing.
  ],
  label: <fig:tree-sharing>,
)

Für unbalancierte Bäume lässt sich dabei aber noch keine besonders gute Zeitkomplexität garantieren.
Bei einem Binärbaum mit $n$ Kindern, welcher maximal unbalanciert ist (equivalent einer verknüpften Liste), degeneriert die Zeitkomplexität zu $Theta(n)$ für Veränderungen am Blatt des Baumes.
Ein perfekt balancierter Binärbaum hat eine Tiefe $d = log_2 n$, so dass jeder Schreibzugriff auf einem persistenten Binärbaum maximal $d$ Knoten (Pfad zwischen Wurzel und Blattknoten) kopieren muss.

= Echtzeitsysteme <sec:realtime>
Unter Echtzeitsystemen versteht man Rechensysteme, welche ihre Aufgaben oder Berechnungen in einer vorgegebenen Zeit abarbeiten. Formal dazu die Definition von _Echtzeit_:

#quote(block: true, attribution: [
  Peter Scholz @bib:sch-05[S. 39] unter Verweis auf DIN 44300
])[
  Unter Echtzeit versteht man den Betrieb eines Rechensystems, bei dem Programme zur Verarbeitung anfallender Daten ständig betriebsbereit sind, derart, dass die Verarbeitungsergebnisse innerhalb einer vorgegebenen Zeitspanne verfügbar sind.
  Die Daten können je nach Anwendungsfall nach einer zeitlich zufälligen Verteilung oder zu vorherbestimmten Zeitpunkten anfallen.
]

Ist ein Echtzeitsystem nicht in der Lage eine Aufgabe in der vorgegebenen Zeit vollständig abzuarbeiten spricht man von Verletzung der Echtzeitbedinungen, welche an das System gestellt wurden.
Je nach Strenge der Anforderungen lassen sich Echtzeitsysteme in drei verschiedene Stufen einteilen:
/ Weiches Echtzeitsystem:
  Die Verletzung der Echtzeitbedinungen führt zu degenerierter aber nicht zerstörter Leistung des Echtzeitsystems und hat _keine_ katastrophalen Folgen @bib:lo-11[S. 6].
/ Festes Echtzeitsystem:
  Eine geringe Anzahl an Verletzungen der Echtzeitbedingungen hat katastrophale Folgen für das Echtzeitsystem  @bib:lo-11[S. 7].
/ Hartes Echtzeitsystem:
  Eine einzige Verletzung der Echtzeitbedingungen hat katastrophale Folgen für das Echtzeitsystem @bib:lo-11[S. 6].

= T4gl
Besonders relevant für die weiteren Kapitel dieser Arbeit ist Verständnis von T4gl und dessen Komponenten.
T4gl und umfasst die folgenden Komponenten:
- Programmiersprache
  - Formale Grammatik
  - Anwendungsspezifische Features
- Compiler
  - Statische Anaylse
  - Typanalyse
  - Übersetzung in Instruktionen
- Laufzeitsystem
  - Ausführen der Instruktionen
  - Scheduling von Green Threads

T4gl steht unter Entwicklung bei der Brückner und Jarosch Ingenieurgesellschaft mbH (BJ-IG) und ist ein propräiteres Produkt.
Wird ein T4gl-Script dem Compiler übergeben startet dieser zunächst mit der statischen Analyse.
Bei der Analyse der Skripte werden bestimmte Invarianzen geprüft, wie die statische Länge bestimmter Arrays, die Typsicherheit und die syntaktische Korrektheit des Scripts.
Nach der Analyse wird das Script in eine Sequenz von _Microsteps_ kompiliert.
Im Anschluss führt des Laufzeitsystem die kompilierten Microsteps aus, verwaltet Speicher und Kontextwechsel der Microsteps und stellt die benöigten Systemschnittstellen zur Verfügung.
Je nach Anwendungsfall werden an das Laufzeitsystem Echtzeitanforderungen gestellt.

#todo[
  Maybe include the figure from the wiki explaining the execution model und how latencies introduced by longrunning instructions can break the real time constraints.
]

== T4gl-Arrays
Bei T4gl-Arrays handelt es sich um assoziative Arrays, sprich eine Datenstruktur welche Schlüsseln Werte zuordnet.
Um ein Array in T4gl zu deklarieren wird mindestens ein Schlüssel- und ein Wertetyp benötigt.
Auf den Wertetyp folgt in eckigen Klammern eine Komma-separierte Liste von Schlüsseltypen.
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
  ],
) <lst:t4gl-ex>

Bei den in @lst:t4gl-ex gegebenen Deklarationen werden je nach den angegebenen Typen verschiedene Datenstrukturen vom Laufzeitsystem gewählt, diese ähneln den analogen C++ Varianten in @tbl:t4gl-array-analogies, wobei `T` und `U` Typen sind und `N` eine Zahl aus $NN^+$.
Die Deklaration von `static` enthält 10 Standardwerte für den `String` Typ (die leere Zeichenkette `""`) für die Schlüssel 0 bis einschließlich 9.
Es handelt sich um eine Sonderform des T4gl-Arrays welches eine dichte festgelegt Schlüsselverteilung hat.
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
    Semantische Analogien in C++ zu spezifischen Varianten von T4gl-Arrays.
  ],
) <tbl:t4gl-array-analogies>

Die Datenspeicherung im Laufzeitsystem kann nicht direkt ein statisches Array (`std::array<T, 10>`) verwenden, da T4gl nicht direkt in C++ übersetzt und kompiliert wird.
Intern werden, je nach Schlüsseltyp, pro Dimension entweder eine dynamische Sequenzdatenstruktur oder ein geordentes assoiatives Array angelegt.
T4gl-Arrays werden intern durch Qt-Klassen verwaltet, diese implementieren einen CoW-Mechanismus, Kopien der Instanzen teilen sich den gleichen Buffer.
Im Gegensatz zu persistenten verknüpften Listen werden die Buffer nicht partiell geteilt, eine Modifikation am Buffer benötigt eine komplette Kopie des Bufffers.

#subpar.grid(
  figure(figures.t4gl.new, caption: [
    Ein T4gl Array nach Initalisierung. \ \
  ]),
  figure(figures.t4gl.shallow, caption: [
    Zwei T4gl-Arrays teilen sich eine C++ Instanz nach _shallow-clone_.
  ]), <fig:t4gl-indirection:shallow>,
  figure(figures.t4gl.deep-new, caption: [
    Zwei T4gl-Arrays teilen sich einen Buffer nach _deep-clone_. \ \
  ]), <fig:t4gl-indirection:deep>,
  figure(figures.t4gl.deep-mut, caption: [
    Zwei T4gl-Arrays teilen sich _keinen_ Buffer nach _deep-clone_ *und* Schreibzugriff.
  ]), <fig:t4gl-indirection:mut>,
  columns: 2,
  caption: [T4gl-Arrays in verschiedenen Stadien der Bufferteilung.],
  label: <fig:t4gl-indireciton>,
)

#todo[
  Annotate the levels in the above figure to show which level manages which part of the system.
]

T4gl Arrays selbst setzen kein CoW zwischen der T4gl und C++ Ebene durch, sondern teilen sich die C++ Instanzen schreibfähig, sprich, Schreibzugriffe auf `a` in @fig:t4gl-indirection:shallow sind in `b` zu sehen und umgekehrt.
Erst durch einen _deep-clone_ kommt es in T4gl zu einer Kopie der C++ Instanz wie in @fig:t4gl-indirection:deep.
Die eigentliche Kopie der Daten erfolgt dann beim nächsten Schreibzugriff in @fig:t4gl-indirection:mut.
