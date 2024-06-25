#import "/src/util.typ": *
#import "/src/figures.typ"

= Komplexität und Landau-Symbole <sec:complexity>
#todo[This is too elaborate and needs to be slimmed down.]

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

$O(f)$ beschreibt die Menge der Funktionen, welche die _obere_ asymptotische Grenze $f$ haben.
Gleichermaßen gibt $Omega(f)$ die Menge der Funktionen an welche die _untere_ asymptotische Grenze $f$ haben.
$Theta(f)$ ist die Schnittmenge aus $O(f)$ und $Omega(f)$ @bib:clrs-09[S. 48, Theorem 3.1].
Trotz der Definition der Symbole in @eq:big-o als Mengen, schreibt man oft $g(n) = O(f(n))$, statt $g(n) in O(f(n))$ @bib:knu-76[S. 20].
Im folgenden wird sich an diese Konvention gehalten.
@tbl:landau zeigt verschiedene Komplexitäten in aufsteigender Ordnung der Funktion $f(n)$, dabei steht $alpha$ für ein Symbol aus @eq:big-o.
Unter Betrachtung der asymptotischen Komplexität werden konstante Faktoren und Terme geringerer Ordnung generell ignoriert, sprich $g(n) = 2n^2 + n = O(n^2)$.

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
#todo[This is too elaborate and needs to be slimmed down.]

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
`std::vector` verfügt über Methoden, welche den Speicher erweitern, sofern das für die gegebene Operation nötig oder möglich ist.
So wird zum Beispiel bei der Verwendung von `push_back` der Speicher erweitert, wenn die jetzige Kapazität des Vektors unzureichend ist.
@lst:vec-ex zeigt wie ein `std::vector` angelegt und stückweise befüllt werden kann, dabei wird zum ersten Aufruf von `push_back` der dynamische Speicher angelegt.
Muss der Speicher zum Erweitern verschoben werden, ergibt sich eine Zeitkomplexität von $O(n)$.
#footnote[
  Die Zeitkomplexität von `push_back` über die gesamte Lebenszeit eines Vektors ist durch den Wachstumsfaktor amortisiert konstant @bib:iso-cpp-20[S. 834].
  Wird die Kapazität vorher reserviert und nicht überschritten, ist die Komplexität $O(1)$.
]
Nach dem dritten Aufruf von `push_back` enthält der Vektor die Sequenz `[3, 2, 1]`.
Ein Vektor bringt über dem herkömmlichen Array verschiedene Vor- und Nachteile mit sich.

*Vorteile*
- Die Kapazität ist nicht fest definiert, es kann zur Laufzeit entschieden werden, wie viele Objekte gespeichert werden.
- Die Verwaltung der Daten wird automatisch durch den Vektor übernommen.

*Nachteile*
- Durch die unbekannte Größe können Iterationen über die Struktur seltener aufgerollt oder anderweitig optimiert werden.

Die bekannte Größe eines Arrays hat nicht nur Einfluss auf die Optimierungsmöglichkeiten eines Programms, sondern auch auf die Komplexitätsanalyse.
Ist die Länge des Arrays bereits zur Analysezeit bekannt und unabhängig von er Problemgröße, kann sie wie eine Konstante behandelt werden.

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

Es folgt aus der Substitution, dass das Programm keine Schleifen enthält, deren Höchstiterationszahl nicht bekannt ist.
Man vergleiche dies mit dem Programm in @lst:vector-ex.
Die Schleife ist nicht mehr trivial aufrollbar, da über die Anzahl der Elemente in `vec` ohne Weiteres keine Annahme gemacht werden kann.
Die Zeitkomplexität der Funktion `print_vector` ist $Theta(n)$, da deren Laufzeit linear von der Problemgröße $n$ abhängt.

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

Es ist nicht unmöglich, fundierte Vermutungen über die Anzahl von Elementen in einer Datenstruktur anzustellen.
Dennoch fällt es mit dynamischen Datenstrukturen schwerer, alle Invarianzen eines Programms bei der Analyse zu berücksichtigen.

= Persistenz und Kurzlebigkeit <sec:per-eph>
Wenn eine Datenstruktur bei Schreibzugriffen die bis dahin bestehenden Daten nicht verändert, gilt diese als _persistent/langlebig_ @bib:kt-96[S. 202].
In Standartbibliotheken vercsshiedene Programmiersprachen hat sich für dieses Konzept der Begriff _Immutable_ durchgesetzt.
Im Gegensatz dazu stehen Datenstrukturen, welche bei Schreibzugriffen ihre Daten direkt beschreiben, diese gelten als _kurzlebig_.
Persistente Datenstrukturen erstellen meist neue Instanzen für jeden Schreibzugriff, welche die Daten der vorherigen Instanz teilen.
Ein gutes Beispiel bietet die einfach verkettete Liste (@fig:linked-sharing).

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
    Eine Abfolge von Operationen auf persistenten verketten Listen.
  ],
  label: <fig:linked-sharing>,
)

Die in @fig:linked-sharing gezeigte Trennung von Kopf und Instanz ermöglicht im folgenden klare Terminologie für bestimmte Konzepte der Persistenz.

/ Daten:
  Die Teile einer Datenstruktur welche die eigentlichen Elemente enthält, in @fig:linked-sharing beschreibt das die Knoten mit einfacher Umrandung, während doppelt umrandete Knoten die Instanzen sind.
/ Schreibfähigkeit:
  Möglichkeit von Schreibzugriffen, ohne die vorherigen Daten intakt zu lassen.
  Das steht im Gegensatz zu persistenten Datenstrukturen, welche bei jedem Schreibzugriff eine neue Instanz zurückgeben.
  Die Listen in @fig:linked-sharing sind teilweise schreibfähig, da eine Instanz selbst schreibfähig ist, aber geteilte Daten nicht von einer Instanz allein verändert werden können.
/ Copy-on-Write (CoW):
  Mechanismus zur Datenteilung + Schreibfähigkeit, viele Instanzen teilen sich die gleichen Daten.
  Eine Instanz gilt als Referent der Daten, auf welchen sie zeigt.
  Ist diese Instanz der einzige Referent, können die Daten direkt beschrieben werden, ansonsten werden die geteilten Daten kopiert (teilweise, sofern möglich), sodass die Instanz einziger Referent der neuen Daten ist. #no-cite

Persistenz zeigt vorallem bei Baumstrukturen ihre Vorteile, bei der Kopie der Daten eines persistenten Baums können je nach Tiefe und Balance des Baumes Großteile des Baumes geteilt werden.
Ähnlich persistenter einfacher verketteter Listen, werden bei Schreibzugriffen auf persistente Bäume nur die Knoten des Baumes kopiert, welche zwischen Wurzel und dem veränderten Knoten liegen.
Betrachten wir partielle Persistenz von Bäume am Beispiel eines Binärbaums, sprich eines Baums mit Zweigfakoren zwishen $0$ und $2$.
@fig:tree-sharing illustriert wie am Binärbaum `t` ein Knoten `X` angefügt werden kann, ohne dessen partielle Persistenz aufzugeben.
Es wird eine neue Instanz angelegt und eine Kopie der Knoten `A` und `C` angelegt, der neue Knoten `X` wird in `C` eingehangen und der Knoten `B` wird von beiden `A` Knoten geteilt.
Durch die Teilung on `B` werden auch alle Kindknoten unter `B` geteilt.

#subpar.grid(
  figure(figures.tree.new, caption: [
    Eine Baumstruktur `t`, an welche ein neuer Knoten `X` unter `C` angefügt werden soll.
  ]), <fig:tree-sharing:new>,
  figure(figures.tree.shared, caption: [
    Bei Hinzufügen des Knotens `X` als Kind des Knotens `C` wird ein neuer Baum `u` angelegt.
  ]), <fig:tree-sharing:shared>,
  columns: 2,
  caption: [
    Partielle Persistenz teilt zwischen mehreren Instanzen die Teile der Daten, welche sich nicht verändert haben, ähnlich der Persistenz in @fig:linked-sharing.
  ],
  label: <fig:tree-sharing>,
)

Für unbalancierte Bäume lässt sich dabei aber noch keine besonders gute Zeitkomplexität garantieren.
Bei einem Binärbaum mit $n$ Kindern, welcher maximal unbalanciert ist (equivalent einer verketten Liste), degeneriert die Zeitkomplexität zu $Theta(n)$ für Veränderungen am Blatt des Baumes.
Ein perfekt balancierter Binärbaum hat eine Tiefe $d = log_2 n$, sodass jeder Schreibzugriff auf einem persistenten Binärbaum maximal $d$ Knoten (Pfad zwischen Wurzel und Blattknoten) kopieren muss.

= Echtzeitsysteme <sec:realtime>
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

= T4gl <sec:t4gl>
T4gl (_engl._ #strong[T]esting #strong[4]th #strong[G]eneration #strong[L]anguage) ist ein proprietäres Softwareprodukt zur Entwicklung von Testsoftware für Reifenprüfmaschienen.
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
Im Anschluss führt des Laufzeitsystem die kompilierten _Microsteps_ aus, verwaltet Speicher und Kontextwechsel der _Microsteps_ und stellt die benöigten Systemschnittstellen zur Verfügung.
Je nach Anwendungsfall werden an das Laufzeitsystem Echtzeitanforderungen gestellt.
Für Anwendungsfälle in denen Echtzeitanforderungen gestellt werden, gibt es bei Nichteinhaltung keine katastrophalen Folgen, es müssen lediglich Testergibnisse verwofen werden.
T4gl ist demnach ein weiches Echtzeitsystem.

#todo[
  Maybe include the figure from the wiki explaining the execution model und how latencies introduced by longrunning instructions can break the real time constraints.
]

== T4gl-Arrays <sec:t4gl:arrays>
Bei T4gl-Arrays handelt es sich um mehrdimensionale assoziative Arrays mit Schlüsseln welche eine voll definierte Ordnungsrelation haben.
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
Semantisch verhalten sich T4gl-Arrays wie Referenzdatentypen, wird ein T4gl-Array mit einer existierenden Instanz initialisiert, verwalten beide Instanzen aus Sicht von T4gl die gleichen Daten.

#figure(
  ```t4gl
  String[10] array1
  String[10] array2 = array1

  array1[0] = "Hello World!"
  // array1[0] == array2[0]
  ```,
  caption: [Demonstration von Referenzverhalten von T4gl-Array.],
) <lst:t4gl-ref>

Die beiden T4gl-Arrays in @lst:t4gl-ref zeigen auf die gleichen Elemente, Schreibzugriffe in `array1` sind auch in `array2` zu sehen und umgekehrt.

== Scheduling
#todo[
  Introduce t4gls scheduling and runtime model, how certain operations are ore aren't broken into microsteps.
  This will later be relevant for the realtime analysis of the new storage data structure.
]
