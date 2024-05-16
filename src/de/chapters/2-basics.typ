#import "/src/util.typ": *
#import "/src/figures.typ"

#todo[Reduce basics to what is actually required to understand the thesis.]

= Komplexität und Landau-Symbole <sec:complexity>
Für den Verlauf dieser Arbeit sind Verständnis von Zeit- und Speicherkomplexität und der verwendeten LANDAU-Symbole unabdingbar.
Komplexitätstheorie befasst sich mit der Komplexität von Algorithmen und algorithmischen Problemen, vor allem in Bezug auf Speicherverbrauch und Bearbeitungszeit.
Dabei sind folgende Begriffe relevant:

#todo[Ensure this is correct according to the citaitons at hand.]

/ Zeitkomplexität:
  Zeitverhalten eines Algorithmus über eine Menge von Daten in Bezug auf die Anzahl dieser. @bib:clrs-09[S. 44]
/ Speicherkomplexität:
  Der Speicherbedarf eines Algorithmus zur Bewältigung eines Problems. @bib:clrs-09[S. 44]
  Wird auch für den Speicherbedarf von Datenstrukturen verwendet.
/ Amortisierte Komplexität:
  Unter Bezug einer Sequenz von $n$ Operationen mit einer Dauer von $T(n)$, gibt die amortisierte Komplexität den Durchschnitt $T(n)\/n$ einer einzigen Operation an. @bib:clrs-09[S. 451]

LANDAU-Symbole umfassen Symbole zur Klassifizierung der asymptotischen Komplexität von Funktionen und Algorithmen.
Im folgenden werden die KNUTH'schen Definitionen @bib:knu-76[S. 19] der LANDAU-Symbol verwendet #footnote[
  LANDAU-Symbole wurden erstmals von Edmund LANDAU bei der Analyse der Verteilung von Primzahlen @bib:lan-09 und Paul BACHMANN in analytischer Zahlentheorie @bib:bac-94 eingeführt.
  Später wurden die gleichen Symbole aber auch in der Komplexitätstheorie verwendet, dort gibt es bestimmte Unterschiede für die Bedeutung von $Omega$, sowie die Inkulsion von $Theta$ als LANDAU-Symbol. @bib:knu-76[S. 19]
], sprich:

#figure(
  kind: math.equation,
  $
        O(f(n)) &= exists n_0, c     &&forall n >= n_0 : { g(n) : |g(n)| <= c f(n) } \
    Omega(f(n)) &= exists n_0, c     &&forall n >= n_0 : { g(n) : g(n) >= c f(n) } \
    Theta(f(n)) &= exists n_0, c, c' &&forall n >= n_0 : { g(n) : c f(n) <= g(n) <= c' f(n) }
  $,
  caption: [Definition von $O(f(n))$, $Omega(f(n))$ und $Theta(f(n))$ nach KNUTH.],
)

Man spricht von $g(f) = O(f(n))$ wenn $g(n)$ die obere asymptotische Grenze $f(n)$ hat, gleicherweise gibt $Omega(f(n))$ eine untere asymptotische Grenze an. Es gilt $g(n) = Theta(f(n))$ wenn sowohl $g(f) = O(f(n))$ als auch $g(f) = Omega(f(n))$ gilt @bib:clrs-09[S. 48, Theorem 3.1].
Die Varianten $o(f(n))$ und $omega(f(n))$ werden im Weiteren nicht verwendet.
@tbl:landau zeigt verschiedene Komplexitäten sortiert nach Ordnung der Funktion $f(n)$, dabei steht $alpha$ für ein Symbol aus ${O, Omega, Theta}$.
Unter Betrachtung der asymptotischen Komplexität werden konstante Faktoren und Terme geringere Ordnung generell ignoriert, sprich $g(n) = 2n^2 + n = O(n^2)$.
Die Richtung der Gleichung hat dabei Relevanz @bib:knu-76[S. 20] und ähnelt unter den KNUTH'schen Definitionen eher einer Mengenzuweisung $g(f) in O(f(n))$.
KNUTH behält die Gleichungsnotation konventionshalber, CORMEN _et al._ ebenfalls und zeigen welche Vorteile das hat @bib:clrs-09[S. 49].

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
Verschiedene Datenstrukturen weisen verschiedenes Speicher- und/oder Zeitverhalten auf.
Je nach Anwendungsfall gibt es Datenstrukturen welche besser oder schlechter geeignet sind.

Dynamische Datenstrukturen sind Datenstrukturen welche vor allem dann Verwendung finden, wenn die Anzahl der verwalteten Elemente nicht vorraussehbar ist.
Ein klassisches Beispiel für eine dynamische Datenstruktur ist ein dynamisches Array.

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
`std::vector` verfügt über Methoden, welche eigenhändig den Speicher erweitern oder verringern, insofern das für die gegebene Operation nötig oder möglich ist.
So wird zum Beispiel bei der Verwendung von `push_back` der Speicher erweitert, wenn die jetzige Kapazität des Vektors unzureichend ist.
Ein Vektor bringt über dem herkömmlichen Array verschiedene Vor- und Nachteile mit sich.
@lst:vec-ex zeigt wie ein `std::vector` angelegt und stückweise befüllt werden kann, dabei wird bei dem ersten Aufruf von `push_back` der dynamische Speicher angelegt.
Nach dem dritten Aufruf von `push_back` enthält der Vektor die Sequenz `[3, 2, 1]`.

*Vorteile*
- Die Kapazität ist nicht fest definiert, es kann zur Laufzeit entschieden werden wie viele Objekte gespeichert werden.

*Nachteile*
- Durch die unbekannte Größe können Iterationen über die Struktur seltener aufgerollt oder anderweitig optimiert werden.
- Der Speicher der Datenstruktur kann meist nicht ohne Indirektion angelegt werden.
  - Da die Größe nicht bekannt ist müssen dynamische Datenstrukturen den eigentlichen Buffer meistens auf dem Heap anlegen.
    #footnote[
      Manche Programmiersprachen unterstüzen dynamische Speicheranlegung ohne Indirektion wie `alloca` oder "Variable-Sized Types".
    ] <ft:indir>
  - Die Elemente von gewöhnlichen Arrays können, dank der bekannten Größe, direkt auf dem Stack oder in einer Klasse gespeichert, das vermeidet unnötige Indirektion oder dynamische Speicherverwaltung. @ft:indir

#todo[
  The upper section isn't clear enough about the causality of dynamic size and indirection.
]

Die bekannte Größe des statischen Arrays hat nicht nur Einfluss auf die Optimierungsmöglichkeiten eines Programms, sondern auch auf die Komplexitätsanalyse.
Iteration auf bekannter Größe sind, wie in @sec:complexity bereits beschrieben, effektiv Konstant.

#todo[
  Apparently the upper claim is incorrect, but I fail to see how, given a known constant upper bound of iteration we do effectively have a constant time operation.
  A least asymptotically.
]

Dieser Zerfall von nicht konstanter zu konstanter Zeitkomplexität propagiert durch alle Operationen, welche nur auf den Elementen dieser Datenstrukturen operieren oder anderweitig konstante Operationen ausführen.
Sei ein Programm gegeben, welches auf einer dynamischen Länge von Elementen $n$ operiert, so könnnen durch die Substitution von $n$ durch eine Konstante $k$ für alle Opertionen auf $n$ die Zeitkomplexität evaluiert werden.
Trivialerweise gilt, ist $x$ eine Konstante, so ist $y = f(x)$ eine Konstante, unter der Annahme das $f(x)$ wirkungsfrei ist.
#footnote[
  Eine Funktion $f(x)$ gilt als wirkungsfrei, wenn diese für jeden Aufruf mit $x_n$ die gleiche Ausgabe $y_n$ ergibt und der Aufruf keinen Einfluss auf diese Eigenschaft anderer Funktionen hat.
]
Bei Operationen wie `push_back` in @lst:vec-ex kommt es durch die dynamische Größe auch zu Speicheroperationen.
Muss der Speicher zum Erweitern verschoben werden, ergibt sich einen wort-case Zeitkomplexität von $O(n)$ ($n = $ Anhzal der Element im Vektor) aufweist.
#footnote[
  Die Zeitkomplexität von `push_back` über die gesamte Lebenszeit eines Vektors ist durch den Wachstumsfaktor amortisiert Konstant @bib:iso-cpp-20[S. 834].
  Wird die Kapazität vorher reserviert und nicht überschritten, ist die Komplexität $O(1)$.
]

== Persistenz und Kurzlebigkeit <sec:per-eph>
Wenn eine Datenstruktur bei Schreibzugriffen die bis dahin bestehenden Daten nicht verändert gilt diese als @gls:per[_persistent/langlebig_]. #no-cite
Im Gegensatz dazu stehen Datenstrukturen welche bei Schreibzugriffen ihre Daten direkt beschreiben, diese gelten als @gls:eph[_kurzlebig_]. #no-cite
@gls:per[Persistente] Datenstrukturen erstellen meist neue Instanzen für jeden Schreibzugriff welche die Daten der vorherigen Instanz teilen.
Ein gutes Beispiel bietet die einfach verknüpfte Liste, @fig:linked-sharing zeigt presistente verknüpfte Listen.

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
    Eine Abfolge von Operationen auf @gls:per[persistenten] verknüpften Listen.
  ],
  label: <fig:linked-sharing>,
)

Die in @fig:linked-sharing gezeigte Trennung von Kopf und Instanz ermöglicht im folgenden klarere Terminologie.
Die Knoten mit einfachem Strich in @fig:linked-sharing sind der @gls:buf der Listen, während die Knoten mit Doppelstrich die einzelnenInstanzen sind.

/ @gls:buf:
  Der Speicherbereich einer Datenstruktur welche die eigentlichen Daten enthält in @fig:linked-sharing beschreibt das die Knoten mit einfachem Strich. Während die doppelgestrichenen Knoten die Instanzen sind.
  Bei einer @gls:cow Datenstruktur können sich viele Instanzen einen einzigen @gls:buf teilen.
/ @gls:mut:
  Möglichkeit von Schreibzugriffen ohne die vorherigen Daten intakt zu lassen.
  Das steht im Gegensatz zu @gls:per[persistenten] Datenstrukturen, welche bei jedem Schreibzugriff.
  Die Listen in @fig:linked-sharing sind Teilweise schreibfähig, da eine Instanz selbst schreibfähig ist, aber geteilte Daten nicht von einer Instanz allein verändert werden können.
/ #gls("gls:cow", long: true):
  Mechanismus zur @gls:buf[Bufferteilung] + @gls:mut[Schreibfähigkeit], viele Instanzen teilen sich einen Buffer.
  Eine Instanz gilt als Referent des @gls:buf[Buffers] auf welchen sie zeigt.
  Ist diese Instanz der einzige Referent, könnne die Daten direkt beschrieben werden, ansonsten wird der geteilte @gls:buf kopiert (teilweise insofern möglich), sodass die Instanz einziger Referent des neuen @gls:buf ist.

#todo[
  Judging by the other feedback I will hav to cite here too, but only half of this is established knowledge, `Buffer` is more or less a convention for this work specifically.
  I think it's fine if I make this clear.
]

= Echtzeitsysteme
Unter Echtzeitsystemen versteht man diese Systeme, welche ihre Aufgaben oder Berechnungen in einer vorgegebenen Zeit abarbeiten.
Ist ein System nicht in der Lage eine Aufgabe in der vorgegebenen Zeit vollständig abzuarbeiten, so spricht man von Verletzung der Echtzeitbedinungen, welche an das System gestellt wurden.

Für die verifizierbare Einhaltung der Echtzeitbedingungen eines Systems ist unter anderem auch das Zeit- und Speicherverhalten der verwendeten Datenstrukturen relevant.
Unter Verwendung von Datenstrukturen wie `std::array`, können für Iterationen die Höchstwerte zur Kompilierzeit definiert werden.

#figure(
  ```cpp
  void print_array(std::array<int, 3>& arr) {
    for (const int& value : arr) {
      std::cout << value << std::endl;
    }
  }
  ```,
  caption: [
    Eine Funktion welche über ein `std::array` der Länge 3 iteriert und desen werte ausgibt.
  ],
) <lst:array-ex>

Für das Programm in @lst:array-ex ist die Obergrenze der Schleife über `arr` bekannt, die Schleife kann aufgerollt und durch die Zeilen in @lst:array-ex-unrolled ersetzt werden.
#figure(
  ```cpp
  std::cout << value[0] << std::endl;
  std::cout << value[1] << std::endl;
  std::cout << value[2] << std::endl;
  ```,
  caption: [
    Die Schleife aus @lst:array-ex nach dem Aufrollen.
    #footnote[
      Unter Anwendung von Compiler-Optimierungen wird dies, wenn möglich automatisch vorgenommen.
    ]
  ],
) <lst:array-ex-unrolled>

Es folgt aus der Substitution, dass das Programm keine Schleifen enthält deren Höchstiterationszahl nicht bekannt ist.
Die Analyse zur Einhaltung der Echtzeitbedingungen dieses Programms ist dann trivial.
Man vergleiche dies mit dem Programm in @lst:vector-ex.
Die Schleife ist nicht mehr trivial aufrollbar, da über die Anzahl der Elemente in `vec` ohne Weiteres keine Annahme gemacht werden kann.

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
Je nach Operation und Nutzungsfall können Datenstrukturen in Ihrer Programmierschnittstelle erweitert oder verringert werden, um diese Invarianzen auszunutzen oder sicherzustellen.

= T4gl
Besonders Relevant für die weiteren Kapitel dieser Arbeit ist Verständnis von @gls:t4gl und dessen Zweck.
@gls:t4gl und umfasst die folgenden Komponenten:
- Programmiersprache
  - Formale Grammatik
  - Anwendungsspezifische Features
- Compiler
  - Statische Anaylse
  - Typanalyse
  - Übersetzung in Instruktionen
- Laufzeitsystem
  - Ausführung der Instruktionen
  - Scheudling von Green Threads

@gls:t4gl steht unter Entwicklung bei der @gls:bjig und ist ein propräiteres Produkt.
Wird ein T4gl-Script dem Compiler übergeben startet dieser zunächst mit der statischen Analyse.
Bei der Analyse der Skripte werden bestimmte Invarianzen geprüft, wie die statische Länge bestimmter Arrays, die Typsicherheit und die syntaktische Korrektheit des Scripts.
Nach der Analyse wird das Script in eine Sequenz von @gls:instr[_Microsteps_] kompiliert.
Im Anschluss führt des Laufzeitsystem die kompilierten Microsteps aus, verwaltet Speicher und Kontextwechsel der @gls:instr[s] und stellt die benöigten Systemschnittstellen zur Verfügung.
Je nach Anwendungsfall werden an das Laufzeitsystem Echtzeitanforderungen gestellt.

#todo[
  Maybe include the figure from the wiki explaining the execution model und how latencies introduced by longrunning instructions can break the real time constraints.
]

== T4gl-Arrays
Bei T4gl-Arrays handelt es sich um assoziative Arrays, sprich eine Datenstruktur welche Schlüsseln Werte zuordnet.
Um ein Array in @gls:t4gl zu deklarieren wird mindestens ein Schlüssel und ein Wertetyp benötigt.
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

Die Datenspeicherung im Laufzeitsystem kann nicht direkt ein statisches Array (`std::array<T, 10>`) verwenden, da @gls:t4gl nicht direkt in C++ übersetzt und kompiliert wird.
Intern werden, je nach Schlüsseltyp, pro Dimension entweder eine dynamische Sequenzdatenstruktur oder ein geordentes assoiatives Array angelegt.
T4gl-Arrays werden intern durch Qt-Klassen verwaltet, diese implementieren einen Copy-on-Write Mechanismus, Kopien der Instanzen teilen sich den gleichen @gls:buf.
Im Gegensatz zu @gls:per[persistenten] verknüpften Listen werden die @gls:buf nicht partiell geteilt, eine Modifikation am @gls:buf benötigt eine komplette Kopie des @gls:buf[s].
T4gl-Arrays sind daher nur zu einem gewissen grad @gls:per[persistent].

#todo[
  Elaborate more precisely on the writing problems as explained shortly in intro
  - [ ] expensive deep copies for writes on shared data
  - [ ] expensive deep copies for context switches
  - [ ] other not yet identified problems?

  Elaborate on the fact that these problems are largely with respect to the underlying data structure.
  Correct the above section to reflect this.
]

#subpar.grid(
  figure(figures.t4gl.new, caption: [
    Wird eine neues Array in T4gl erstellet wird eine C++ Instanz mit neuem @gls:buf angelegt. \ \ \
  ]),
  figure(figures.t4gl.shallow, caption: [
    Wird in T4gl eine Array Instanz `a` in `b` kopiert, teilen diese Instanzen sich die gleiche C++ Instanz.
    Schreibzugriffe auf `a` sind in `b` zu sehen und umgekehrt.
  ]),
  figure(figures.t4gl.deep-new, caption: [
    Wird in T4gl stattdessen ein deep-clone der Instanz `a` in `b` angelegt, teilen sich diese keine `C++` Instanz, aber der @gls:buf wird weiterhin geteilt.
  ]), <fig:t4gl-indireciton:deep>,
  figure(figures.t4gl.deep-mut, caption: [
    Nach einem Schreibzugriff greift der @gls:cow Mechanismus und die @gls:buf werden getrennt. \ \
  ]), <fig:t4gl-indireciton:mut>,
  columns: 2,
  caption: [
    Die hoch-level Instanzen in T4gl fügen der Persistenz eine weitere Indirektion hinzu.
  ],
  label: <fig:t4gl-indireciton>,
)

#todo[
  Annotate the levels in the above figure to show which level manages which part of the system.
]

In @fig:t4gl-indireciton ist zu sehen, dass T4gl Arrays selbst kein @gls:cow auf der C++ ebene durchsetzen sondern sich C++ Instanzen @gls:mut[schreibfähig] teilen.
Erst durch einen deep-clone wie in @fig:t4gl-indireciton:deep kommt es explizit @gls:cow beim nächsten Schreibzugriff in @fig:t4gl-indireciton:mut.

// == Häufige Schreibzugriffe & Datenteilung
// Ein Hauptnutzungsfall dieser Arrays ist das Speichern von geordneten Wertereihen als Historie einer Variable.
// Beim Erfassen der Historie wird das Array dauerhaft mit neuen Werten belegt welche am Ende der Wertereihe liegen.
// Wird das Array an ein Skript übergeben, kommt es zu einer flachen Kopie, welche lediglich die Referenzzahl der Daten erhöht.
// Beim nächsten Schreibzugriff durch das Anhaften neuer Werte, kommt es zur tiefen Kopie, da die unterliegenden Daten nicht mehr nur einen Referenten haben.

// == Multithreading
// Wird eine Array an eine Funktion übergeben welche auf einem einderen Thread ausgeführt wird, wird eine tiefe Kopie angelegt.

// In beiden Fällen werden tiefe Kopien von Datenmengen angelegt welche dem Scheduler unbekannt sind.
// Dabei entstehen Latenzen welche das Laufzeitsystem verlangsamen und dessen Echtzeiteinhaltung beeinflussen.

= Partielle Persistenz
Ein Hauptproblem von T4gl-Arrays ist, dass Modifikationen der Arrays bei nicht-einzigartigem Referenten eine Kopie des gesamten Buffers benötigt.
Obwohl es bereits @gls:per[persistent] Sequenzdatenstrukturen @bib:br-11 @bib:brsu-15 @bib:stu-15 und assoziative Array Datenstrukturen @bib:hp-06 @bib:bm-70 @bib:bay-71 gibt welche bei Modifikationen nur die Teile des @gls:buf[s] kopieren welche modifiziert werden müssen.
Partielle @gls:per[Persistenz] kann durch verschiedene Implementierungen umgesetzt werden, semantisch handelt es sich aber fast immer um Baumstrukturen.
Sie soll als Grundlage der neuen T4gl-Arrays dienen.

#subpar.grid(
  figure(figures.tree.new, caption: [
    Eine Baumstruktur `t` an welche ein neuer Knoten `X` unter `C` angefügt werden soll.
  ]), <fig:tree-sharing:new>,
  figure(figures.tree.shared, caption: [
    Bei Hinzufügen des Knotens `X` als Kind des Knotens `C` wird ein neuer Baum `m` angelegt.
  ]), <fig:tree-sharing:shared>,
  columns: 2,
  caption: [
    Partielle Persistenz teilt zwischen mehreren Instanzen die Teile des @gls:buf[s] welche sich nicht verändert haben, ähnlich der Persistenz in @fig:linked-sharing.
  ],
  label: <fig:tree-sharing>,
)

@fig:tree-sharing zeigt partielle @gls:per[Persistenz] bei Bäumen, dabei sind #text(green)[grüne] Knoten diese, welche geteilt werden und #text(red)[rote] Knoten diese welche Kopiert wurden.
Für unbalancierte Bäume lässt sich dabei aber noch keine verbesserte worst-case Zeitkomplexität gegenüber eines @gls:cow Vektors garantieren.
Ein Binärbaum mit $n$ Kindern, welcher maximal unbalanciert ist (equivalent einer verknüpften Liste), hat beim Hinzufügen von Knoten am Ende eine best-case Zeitkomplexität von $O(n)$.
Für einen perfekt balancierten @gls:per[persistenten] Binärbaum mit $n$ Elementen hingegen, ist die worst-case Zeitkomplexität für das Hinzufügen oder Löschen eines Blattknotens $O(d)$  oder $O(log_b n)$ ($d =$ Tiefe des Baums und $b = 2 =$ Zweigfaktor).

#todo[
  Elaborate on how combination of the right branching factor and balancing constraints ensures known logarithmic upper bounds, as shown by the various rrb papers.
]
