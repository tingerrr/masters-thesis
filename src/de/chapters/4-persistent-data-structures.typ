#import "/src/util.typ": *
#import "/src/figures.typ"

#todo[This is too elaborate and needs to be slimmed down.]

Datenstrukturen sind Organisierungsstrukturen der Daten im Speicher eines Rechensystems.
Der Aufbau dieser Datenstrukturen hat Einfluss auf deren Speicherbedarf und das Zeitverhalten verschiedener Operationen auf diesen Datenstrukturen.
Die Wahl der Datenstruktur ist abhängig vom Anwendungsfall und den Anforderungen der Datenverwaltung.

Dynamische Datenstrukturen sind Datenstrukturen, welche vor allem dann Verwendung finden, wenn die Anzahl der verwalteten Elemente nicht vorraussehbar ist.
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
In den Standartbibliotheken verschiedener Programmiersprachen hat sich für dieses Konzept der Begriff _Immutable_ durchgesetzt.
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

= Lösungsansatz
Zunächst definieren wir Invarianzen von T4gl-Arrays, welche durch eine Änderung der Storage-Datenstruktur nicht verletzt werden dürfen:
+ T4gl-Arrays sind assoziative Datenstrukturen.
  - Es werden Werte mit Schlüsseln addressiert.
+ T4gl-Arrays sind nach ihren Schlüsseln geordnet.
  - Die Schlüsseltypen von T4gl-Arrays haben eine voll definierte Ordnungsrelation.
  - Iteration über T4gl-Arrays ist deterministisch in aufsteigender Reihenfolge der Schlüssel.
+ T4gl-Arrays verhalten sich wie Referenztypen.
  - Schreibzugriffe auf ein Array, welches eine flache Kopie eines anderen T4gl-Arrays ist, sind in beiden Instanzen sichtbar.
  - Tiefe Kopien von T4gl-Arrays teilen sichtbar keine Daten, ungeachtet, ob die darin enthaltenen Typen selbst Referenztypen sind.

Die Ordnung der Schlüssel schließt ungeordnete assoziative Datenstrukturen wie Hashtabellen aus und das Referenztypenverhalten ist durch Referenzzählung und Storage-Instanzteilung wie bis dato umsetzbar.
Es muss lediglich die Implementierung der Storage-Instanzen insofern verbessert werden, dass Schlüssel geordnet vorliegen und nicht dicht verteilt sein müssen.
Essentiell für die Verbesserung des _worst-case_ Zeitverhaltens bei Kopien und Schreibzugriffen ist die Reduzierung der Daten, welche bei Schreibzugriffen kopiert werden müssen.
Hauptproblem bei flachen Kopien gefolgt von Schreibzugriff auf CoW-Datenstrukturen, ist die tiefe Kopie _aller_ Daten in den Daten der Instanzen, selbst wenn nur ein einziges Element beschrieben oder eingefügt/entfernt wird.
Ein Großteil der Elemente in den originalen und neuen kopierten Daten sind nach dem Schreibzugriff gleich.
Deshalb wurde als Basis des Lösungsansatzes die Wahl einer persistenten Datenstruktur mit granularer Datenteilung festgelegt.
Durch höhere Granularität der Datenteilung müssen bei Schreibzugriffen weniger Daten kopiert werden.
Ein Beispiel für persistente Datenstrukturen mit granularer Datenteilung sind RRB-Vektoren @bib:br-11 @bib:brsu-15 @bib:stu-15, eine Sequenzdatenstruktur auf Basis von Radix-Balancierten Bäumen.
Trotz der zumeist logarithmischen _worst-case_ Komplexitäten können RRB-Vektoren nicht als Basis für T4gl-Arrays dienen, da die Effizienz der RRB-Vektoren auf der Relaxed-Radix-Balancierung aufbaut, welche von einer Sequenzdatenstrukur ausgeht.
Da die Schlüsselverteilung in T4gl-Arrays nicht dicht ist, können die Schlüssel nicht ohne Weiteres auf dicht verteilte Indizes abgebildet werden, welche für die Radixsuche essentiell sind.
Ohne die Relaxed-Radix-Balancierung handelt es sich bei RRB-Vektoren lediglich um B-Bäume @bib:bm-70 @bib:bay-71 hoher Ordnung.
Bei persistenten B-Bäumen haben die meisten Operationen eine _worst-_ und _average-case_ Zeitkomplexität von $Theta(log n)$.
Eine Verbesserung der _average-case_ Zeitkomplexität für bestimmten Sequenzoperationen (_Push_, _Pop_) bieten 2-3-Fingerbäume @bib:hp-06.
Diese bieten sowohl exzellentes Zeitverhalten, als auch keine Enschränkung auf die Schlüsselverteilung.
Im folgenden werden 2-3-Fingerbäume als alternative Storage-Datenstrukturen für T4gl-Arrays untersucht.

#todo[
  + The mention of persistence without an example seems jarring, but showing an example here and in @sec:per-eph also feels weird.
  + The above could go with some examples, especially regarding RRB-Vectors and how they could be used as paired sequences ordered by key on insertion given that it's insert/remove bounds are sublinear.
]

= 2-3-Bäume
#todo[
  Introduce the notation of 2-3 Trees as the simpelest Form of B-Tree, this should give a good indication why the generalization of FingerTrees uses B-Trees itself and what 2-3-4-FingerTrees mean notationally.
  Introduce the usage of branching factors here or further up depending on when it is first used.
]

= 2-3-Fingerbäume
2-3-Fingerbäume wurden von !HINZE und !PATERSON @bib:hp-06 eingeführt und sind eine Erweiterung von 2-3-Bäumen, welche für verschiedene Sequenzoperationen optimiert wurden.
Die Authoren führen dabei folgende Begriffe im Verlauf des Texts ein:
/ Spine: Die Wirbelsäule eines Fingerbaums, sie beschreibt die Kette der zentralen Knoten, welche die sogenannten _Digits_ enthalten.
/ Digit: Erweiterung von 2-3-Knoten auf 1-4-Knoten, von welchen jeweils zwei in einem Wirbelknoten vorzufinden sind.
  Obwohl ein Wirbelknoten zwei Digits enthält, sind, statt diesen selbst, direkt deren 1 bis 4 Kindknoten an beiden Seiten angefügt.
  Das reduziert die Anzahl unnötiger Knoten in Abbildungen und entspricht mehr der späteren Implementierung.
  Demnach wird im Folgenden _Digits_ verwendet um die linken und rechten direkten Kindknoten der Wirbelknotne zu beschreiben.
/ Safe: Sichere Ebenen sind Ebenen mit 2 oder 3 _Digits_, ein _Digit_ kann ohne Probleme entnommen oder hinzugefügt werden.
  Zu beachten ist dabei, dass die Sicherheit einer Ebene sich auf eine Seite bezieht, eine Ebene kann links sicher und rechts unsicher sein.
/ Unsafe: Unsichere Ebenen sind Ebenen mit 1 oder 4 _Digits_, ein _Digit_ zu entnehmen oder hinzuzufügen kann Über- bzw. Unterlauf verursachen (Wechsel von _Digits_ zwischen Ebenen des Baumes um die Zweigfaktoren zu bewahren).

Der Name Fingerbäume rührt daher, dass imaginär zwei Finger an die beiden Enden der Sequenz gesetzt werden.
Diese Finger ermöglichen den schnellen Zugriff an den Enden der Sequenz.
Die zuvor definierten _Digits_ haben dabei keinen direkten Zusammenhang mit den Fingern eines Fingerbaums, trotz der etymologischen Verwandschaft beider Begriffe.
@fig:finger-tree zeigt den Aufbau eines 2-3-Fingerbaums, die in #text(blue.lighten(75%))[*blau*] eingefärbten Knoten sind Wirbelknoten, die in #text(teal.lighten(50%))[*türkis*] eingefärbten Knoten sind die _Digits_.
In #text(gray)[*grau*] eingefärbte Knoten sind interne Knoten.
Weiße Knoten sind Elemente, die Blattknoten der Teilbäume.
Knoten, welche mehr als einer Kategorie zuzuordnen sind, sind geteilt eingefärbt.

#figure(
  figures.finger-tree,
  caption: [Ein 2-3-Fingerbaum der Tiefe 3 und 21 Elementen.],
) <fig:finger-tree>

Die Tiefe ergibt such bei 2-3-Fingerbäumen aus der Anzahl der zentralen Wirbel.
Jeder Wirbelknoten beschreibe eine Ebene $t$, der Baum in @fig:finger-tree hat Ebene 1 bis Ebene 3.
Aus der tiefe der Wirbelknoten ergibt sich die Tiefe der Teilbäume (2-3-Baume) in deren _Digits_.
Die Elemente sind dabei nur in den Blattknoten vorzufinden.
In Ebene 1 sind Elemente direkt in den _Digits_ enhalten, die Teilbäume haben die Tiefe 1.
In Ebene 2 sind die Elemente in Knoten verpackt, die _Digits_ von Ebene 2 enthalten Teilbäume der Tiefe 2.
Die dritte Ebene enthält Knoten von Knoten von Elementen, sprich Teilbäume der Tiefe 3, und so weiter.
Dabei ist zu beachten, dass der letzte Wirbelknoten einen optionalen mittleren Einzelknoten enthalten kann, ein _Sonderdigit_ zur Überbrückung der der Bildung interner Wirbleknoten.
Die linken _Digits_ jedes Wirbelknoten bilden dabei den Anfang der Sequenz, während die rechten _Digits_ das Ende der Sequenz beschreiben.
Die Nummerierung der Knoten in @fig:finger-tree illustriert die Reihenfolge der Elemente.
Interne Knoten und Wirbelknoten enthalten außerdem die Suchinformationen des Unterbaums in dessen Wurzel sie liegen.
Je nach Wahl des Typs dieser Suchinformationen kann ein 2-3-Fingerbaum als gewöhnlicher Vektor, geordnete Sequenz, _Priority-Queue_ oder Intervalbaum verwendet werden.

Durch den speziellen Aufbau von 2-3-Fingerbäumen weisen diese im Vergleich zu gewöhnlichen 2-3-Bäumen geringere asymptotische Komplexitäten für Sequenzoperationen auf.
@tbl:finger-tree-complex zeigt einen Vergleich der Komplexitäten verschiedener Operationen über $n$ Elemente.
Dabei ist zu sehen, dass _Push_ und _Pop_ Operationen auf 2-3-Fingerbäumen im _average-case_ amortisiert konstantes Zeitverhalten aufweisen, im Vergleich zu dem generell logarithmischen Zeitverhalten bei gewöhnlichen 2-3-Bäumen.
Fingerbäume sind symmetrische Datenstrukturen, _Push_ und _Pop_ kann problemlos an beiden Enden durchgeführt wurden.

#let am1 = [#footnote(numbering: "*")[Amortisiert] <ft:amortized>]
#let am2 = footnote(numbering: "*", <ft:amortized>)

#figure(
  figures.complexity-comparison(
    (
      "2-3-Baum": (
        "Search": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Insert": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Remove": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Push":   ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Pop":    ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
      ),
      "2-3-Fingerbaum": (
        "Search": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Insert": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Remove": ($Theta(log n)$, $Theta(log n)$, $Theta(log n)$),
        "Push":   ($Theta(log n)$, $Theta(1)#am1$, $Theta(1)$),
        "Pop":    ($Theta(log n)$, $Theta(1)#am2$, $Theta(1)$),
      ),
    ),
  ),
  caption: [Die Komplexitäten von 2-3-Fingerbäumen im Vergleich zu gewöhnlichen 2-3-Bäumen.],
) <tbl:finger-tree-complex>

Ein wichtiger Bestandteil der Komplexitätsanalyse der _Push_ und _Pop_ Operationen von 2-3-Fingerbäumen ist die Suspension der Wirbelknoten durch _lazy evaluation_.

#todo[
  They argue that rebalancing is paid for by the previous cheap operations using Okasakis debit analysis.
  I'm unsure how to properly write this down without stating something incorrect, so I probably don't understand it completely yet.
  My assumption was that the rebalancing simply happens less and less often as it always creates safe layers when it happens, each time it gets deeper it creates it leaves only safe layers.
]

Die Definition von 2-3-Fingerbäumen ist in @lst:finger-tree beschrieben.
`T` sind die im Baum gespeicherten Elemente und `M` die Suchinformationen für interne Knoten.
Im Regelfall wären alle Klassendefinitionen über `T` und `M` per ```cpp template``` parametriert, darauf wurde Verzichtet um die Definition im Rahmen zu halten.

#figure(
  ```cpp
  using T = ...;
  using M = ...;

  class Node {};
  class Internal : public Node {
    M measure;
    std::array<Node*, 3> children; // 2..3 children
  };
  class Leaf : public Node {
    T value;
  };

  class FingerTree {};
  class Shallow : public FingerTree {
    Node* value; // 0..1 digits
  };
  class Deep : public FingerTree {
    M measure;
    std::array<Node*, 4> left;  // 1..4 digits
    FingerTree* middle;
    std::array<Node*, 4> right; // 1..4 digits
  };
  ```,
  caption: [Die Definition von 2-3-Fingerbäumen in C++ übersetzt.],
) <lst:finger-tree>

= Generische Fingerbäume
Im Folgenden wird betrachtet, inwiefern die Zweigfaktoren von Fingerbäumen generalisierbar sind, ohne die in @tbl:finger-tree-complex beschriebenen Komplexitäten zu verschlechtern.
Höhere Zweigfaktoren der Teilbäume eines Fingerbaums reduzieren die Tiefe des Baumes und können die Cache-Effizienz erhöhen.

Wir beschreiben die Struktur eines Fingerbaums durch die Minima und Maxima seiner Zweigfaktoren $k$ (Zweigfaktor der internen Knoten) und $d$ (Anzahl der _Digits_ auf jeder Seite einer Ebene)

$
  k_min &<= k &<= k_max \
  d_min &<= d &<= d_max \
$

Die Teilbäume, welche in den _Digits_ liegen, werden auf B-Bäume generalisiert, daher gilt für deren interne Knoten außerdem

$
  ceil(k_max / 2) <= k_min \
$

Die in @lst:finger-tree gegebene Definition lässt sich dadurch erweitern, das `std::array` durch `std::vector` ersetzt wird um die wählbaren Zweigfaktoren zu ermöglichen.
Diese können ebenfalls mit ```cpp template``` Parametern zur Kompilierzeit gesetzt um den Wechsel auf Vektoren zu vermeiden.
Die Definition von `Shallow` wird ebenfalls erweitert, sodass diese mehr als ein _Sonderdigit_ enthalten kann.

#figure(
  ```cpp
  using T = ...;
  using M = ...;

  class Node {};
  class Internal : public Node {
    M measure;
    std::vector<Node*> children; // k_min..k_max children
  };
  class Leaf : public Node {
    T value;
  };

  class FingerTree {};
  class Shallow: public FingerTree {
    std::vector<Node*> values; // 0..(2 d_min - 1) digits
  };
  class Deep : public FingerTree {
    M measure;
    std::vector<Node*> left;  // d_min..d_max digits
    FingerTree* middle;
    std::vector<Node*> right; // d_min..d_max digits
  };
  ```,
  caption: [Die Definition von generischen Fingerbäumen in C++.],
) <lst:gen-finger-tree>

#todo[
  A later inequality seems to imply $d_min < k_min$ as well as $k_max < d_max$, so this may be worth mentioning here once proven.
]

Da Wirbelknoten mindestens $2 d_min$ _Digits_ enthalten, muss die Bildung dieser Minimalanzahl der Elemente im letzten Wirbelknoten überbrückt werden.
Das erzielt man durch das Einhängen von _Sonderdigits_ in den letzten Wirbleknoten, bis genug für beide Seiten vorhanden sind.
Prinzipiell gilt für den letzten Wirbelknoten

$
  0 <= d < 2 d_min
$

Ein generischer Fingerbaum ist dann durch diese Minima und Maxima beschrieben.
Im Beispiel des 2-3-Fingerbaums gilt

$
  2 &<= k &<= 3 \
  1 &<= d &<= 4 \
$

== Baumtiefe
Sei $n(t)$ die Anzahl $n$ der Elemente einer Ebene $t$, also die Anzahl aller Elemente in allen Teilbäumen der Digits eines Wirbelknotens, so gibt es ebenfalls die minimale und maximale mögliche Anzahl für diesen Wirbelknoten.
Diese ergeben sich jeweils aus den minimalen und maximalen Anzahlen der _Digits_, welche Teilbäme mit minimal bzw. maximal belegten Knoten enthalten.

$
  n_"lmin" (t) &= k_min^(t - 1) \
  n_"imin" (t) &= 2 d_min k_min^(t - 1) \
  n_max (t) &= 2 d_max k_max^(t - 1) \
$

$n_"lmin"$ beschreibt das Minimum des letzten Wirbelknotens, da dieser nicht an die Untergrenze $2 d_min$ gebunden ist.
$n_"imin"$ ist das Minimum interner Wirbleknoten.
Für die kumulativen Minima und Maxima aller Ebenen bis zur Ebene $t$ ergibt sich

$
  n'_"lmin" (t) &= n_"lmin" (t) + n'_"tmin" (t - 1) \
  n'_"imin" (t) &= n_"imin" (t) + n_"imin" (t - 1) + dots.c + n_"imin" (1) &= sum_(i = 1)^t n_"imin" (i) \
  n'_max (t) &= n_max (t) + n_max (t - 1) + dots.c + n_max (1) &= sum_(i = 1)^t n_min (i) \
$

Das wirkliche Minimum eines Baumes der Tiefe $t$ ist daher $n'_min (t) = n'_"lmin"$, da es immer einen letzten nicht internen Wirbelknoten auf Tiefe $t$ gibt.
@fig:cum-depth zeigt die Minima und Maxima von $n$ für die Baumtiefen $t in [1, 8]$ für 2-3-Fingerbäume.
Dabei zeigen die horizontalen Linien das kumulative Minimum $n'_min$ und Maximum $n'_max$ pro Ebene.

#todo[
  Perhaps flip the plot's axes, it may be confusing that $n(t)$ is used in the label, implying a running variable of $t$.
  But this may increase the vertical size unecessarily, leaving lots of white space.
]

#[
  #let (kmin, kmax) = (2, 3)
  #let (dmin, dmax) = (1, 4)

  #let fmins(t) = calc.pow(kmin, t - 1)
  #let fmin(t) = 2 * dmin * calc.pow(kmin, t - 1)
  #let fmax(t) = 2 * dmax * calc.pow(kmax, t - 1)

  #let fcummin(t) = range(1, t + 1).map(fmin).fold(0, (acc, it) => acc + it)
  #let fcummins(t) = fmins(t) + fcummin(t - 1)
  #let fcummax(t) = range(1, t + 1).map(fmax).fold(0, (acc, it) => acc + it)

  #let ranges(t) = {
    let individual = range(2, t + 1).map(t => (
      t: t,
      mins: fmins(t),
      min: fmin(t),
      max: fmax(t),
    ))

    individual
  }

  #let cum-ranges(t) = {
    let cummulative = range(1, t + 1).map(t => (
      t: t,
      mins: fcummins(t),
      min: fcummin(t),
      max: fcummax(t),
    ))

    cummulative
  }

  #let count = 8
  #let cum-ranges = cum-ranges(count)
  #let mmax = cum-ranges.last().max

  #let base = 2
  #let sqr = calc.pow.with(base)
  #let lg = calc.log.with(base: base)
  #let tick-max = int(calc.round(lg(mmax)))
  #let tick-args = (
    x-tick-step: none,
    x-ticks: range(tick-max + 1).map(x => (x, sqr(x))),
  )

  // comment out to make linear scale plot
  // #let sqr = x => x
  // #let lg = x => x
  // #let tick-max = int(lg(mmax))
  // #let tick-args = ()

  #import "@preview/cetz:0.2.2"

  #figure(
    cetz.canvas({
      cetz.draw.set-style(axes: (bottom: (tick: (label: (angle: 45deg, anchor: "north-east")))))

      cetz.plot.plot(
        size: (9, 6),
        x-label: $n$,
        y-label: $t$,
        y-tick-step: none,
        y-ticks: range(1, count + 1),
        plot-style: cetz.palette.pink,
        ..tick-args,
        {
          let intersections(n) = {
            cetz.plot.add-vline(
              style: (stroke: (paint: gray.lighten(70%), dash: "dashed")),
              lg(n),
            )
            cetz.plot.add(
              label: box(inset: 0.2em)[$n' = #n$],
              style: (stroke: none),
              mark-style: cetz.palette.new(
                colors: color.map.crest.chunks(32).map(array.first)
              ).with(stroke: true),
              mark: "x",
              cum-ranges.filter(r => r.mins <= n and n <= r.max).map(r => (lg(n), r.t))
            )
          }
          // force the plot domain
          cetz.plot.add(
            style: (stroke: none),
            ((-1, 0), (tick-max + 1, count + 1)),
          )
          for t in cum-ranges {
            cetz.plot.add(
              label: if t.t == 1 { box(inset: 0.2em)[$n'(t)$] },
              domain: (0, lg(mmax)),
              style: cetz.palette.blue.with(stroke: true),
              mark-style: cetz.palette.blue.with(stroke: true),
              mark: "|",
              (
                (lg(t.mins), t.t),
                (lg(t.max), t.t),
              )
            )
          }
          intersections(9)
          intersections(27)
          intersections(250)
        },
      )
    }),
    caption: [
      Die minimale und maximale Anzahl von Elementen $n$ für einen 2-3-Fingerbaum der Tiefe $t$.
    ],
  ) <fig:cum-depth>

  // #table(
  //   columns: 6,
  //   align: right,
  //   table.header[$t$],
  //   ..cum-ranges.map(t => (t.t, t.mins, $<=$, $n$, $<=$, t.max)).flatten().map(x => $#x$)
  // )
]

== Über- & Unterlaufsicherheit
Über- bzw. Unterlauf einer Ebene $t$ ist der Wechsel von _Digits_ zwischen der Ebene $t$ und der Ebene $t + 1$.
Beim Unterlauf der Ebene $t$ sind nicht genug _Digits_ in $t$ enthalten.
Es wird ein _Digit_ aus der Ebene $t + 1$ entnommen und dessen Kindknoten in $t$ gelegt.
Der Überlauf einer Ebene $t$ erfolgt, wenn in $t$ zu viele _Digits_ enthalten sind.
Es werden genug _Digits_ aus $t$ entnommen, sodass diese in einen Knoten verpackt und als _Digit_ in $t + 1$ gelegt werden können.
Das Verpacken und Entpacken der _Digits_ ist nötig um die erwarteten Baumtiefen pro Ebene zu erhalten, sowie zur Reduzierung der Häufigkeit der Über- und Unterflüsse je tiefer der Baum wird.
Eine Ebene $t$ mit $d$ _Digits_ gilt als sicher @bib:hp-06[S. 7], wenn

#let dd = $Delta d_t$

$
  d_min < d_t < d_max
$

Ist eine Ebene sicher, ist das Hinzufügen oder Wegnehmen eines Elements trivial.
Ist eine Ebene unsicher, kommt es beim Hinzufügen oder Wegnehmen zum Über- oder Unterlauf, Elemente müssen zwischen Ebenen gewechselt werden, um die obengenannten Ungleichungen einzuhalten.
Erneut gilt zu beachten, dass die Sicherheit einer Ebene nur für eine Seite der Ebene gilt.
Welche Seite, hängt davon ab an welcher Seite eine Operation wie _Push_ oder _Pop_ durchgeführt wird.
Wir betrachten den Über- und Unterlauf einer unsicheren Ebene $t$ in eine oder aus einer sicheren Ebene $t + 1$.
 Über- oder Unterlauf von unsicheren Ebenen in bzw. aus unsicheren Ebenen kann rekursiv angewendet werden bis eine sichere Ebene erreicht wird.
Ähnlich der 2-3-Fingerbäume wird durch die Umwandlung von unsicheren in sichere Ebenen dafür gesorgt, dass nur jede zweite Operation eine Ebene in dem Baum herabsteigen muss, nur jede vierte zwei Ebenen, und so weiter.

#todo[Mention the term of "recursive slowdown" (coined by Okasaki).]

Damit die Elemente einer Ebene $t$ in eine andere Ebene $t + 1$ überlaufen können, müssen diese in einen Knoten der Ebene $t + 1$ passen, es gilt
$
  k_min <= dd <= k_max \
$ <eq:node-constraint>

Dabei ist $dd$ die Anzahl der Elemente in $t$ welche in $t + 1$ überlaufen sollen.
Essentiell ist, dass eine unsicher Ebene nach dem Übelauf wieder sicher ist, dazu müssen folgende Ungleichung eingehalten werden.
Die Ebene $t + 1$, kann dabei sicher bleiben oder unsicher werden.
$
  t     &: d_min <& d_max     &text(#green, - dd) text(#red, + 1) &<  d_max \
  t + 1 &: d_min <& d_(t + 1) &text(#green, + 1)                  &<= d_max \
$

Gleichermaßen gelten für den Unterlauf folgende Ungleichungen.
$
  t     &: d_min <&  d_min     &text(#green, + dd) text(#red, - 1) &< d_max \
  t + 1 &: d_min <=& d_(t + 1) &text(#green, - 1)                  &< d_max \
$

$dd$ und die Zweigfaktoren $d_min$, $d_max$, $k_min$ und $k_max$ sind so zu wählen, die zuvorgenannten Ungleichungen halten.
Betrachten wir 2-3-Fingerbäume, gilt $d_min = 1$, $d_max = 4$, $k_min = 2$ und $k_max = 3$, daraus ergibt sich

$
  "Überlauf" &: 2 <= dd <= 3 \
  "Unterlauf" &: 1 < dd < 4 \
$

In @bib:hp-06 entschieden sich die Authoren bei Überlauf für $dd = 3$, gaben aber an, dass $dd = 2$ ebenfalls funktioniert.
Aus den oben genannten Ungleichungen lassen sich Fingerbäume mit anderen $d$ und $k$ wählen, welche die gleichen asymptotischen Komplexitäten für _Deque_-Operationen aufweisen.
Zum Beispiel 2-3-4-Fingerbäume mit $d_min = 1$:
$
  2 <= dd <= 4 \
  dd < d_max \
  4 < d_max \
$

Daraus ergibt sich, dass $d_min = 1$, $d_max = 5$, $k_min = 2$ und $k_max = 4$ einen validen 2-3-4-Fingerbaum beschreiben.

#todo[
  + Now the quesiton is if @eq:node-constraint is enough on it's own to chose $dd$, this may be related to the relation of $d$ to $k$ noted further up.
  + Below here should follow the debig analysis, or further down with more context from the push and pop operations.
]

== Push & Pop
#let math-type(ty) = $text(#teal.darken(35%), ty)$
#let math-func(ty) = $op(text(#fuchsia.darken(35%), ty))$

#let Maybe = math-type("Maybe")

#let Node = math-type("Node")
#let Deep = math-type("Deep")
#let Shallow = math-type("Shallow")
#let FingerTree = math-type("FingerTree")

#let popl = math-func("pop-left")
#let pushl = math-func("push-left")
#let concat = math-func("concat")
#let split = math-func("split")

#let ftpushl = math-func("ftree-push-left")
#let ftpopl = math-func("ftree-pop-left")

#[
  #show math.equation: it => {
    show "E": math-type
    it
  }

#figure(
  kind: "algorithm",
  supplement: [Algorithmus],
  algorithm(numbered-title: $ftpushl(e, t): (E, FingerTree E) -> FingerTree E$)[
    + *switch* $t$
      + *case* $t$ *is* $Shallow$
        + *let* $"values" = pushl(e, t."values")$
        + *if* $|"values"| < 2 d_min$
          + *return* $Shallow("values")$
        + *let* $"left", "right" = split("values", d_min)$
        + *return* $Deep("left", Shallow(nothing), "right")$
      + *case* $t$ *is* $Deep$
        + *let* $"left" = pushl(e, t."left")$
        + *if* $|"left"| <= d_max$
          + *return* $Deep("left", t."middle", t."right")$
        + *let* $"rest", "overflow" = split("left", |"left"| - dd)$
        + *let* $"middle" = ftpushl(Node("overflow"), t."middle")$
        + *return* $Deep("rest", "middle", t."right")$
  ],
  caption: [Die _Insert_ Operation an der linken Seite eines Fingerbaumes.],
) <alg:finger-tree:push-left>

#figure(
  kind: "algorithm",
  supplement: [Algorithmus],
  // BUG: this should break nicely with 0.12
  algorithm(numbered-title: par(justify: false)[$ftpopl(t): FingerTree E -> (Maybe E, FingerTree E)$])[
    + *switch* $t$
      + *case* $t$ *is* $Shallow$
        + *let* $e, "rest" = popl(t."values")$
        + *return* $(e, Shallow("rest"))$
      + *case* $t$ *is* $Deep$
        + *let* $e, "rest" = popl(t."left")$
        + *if* $|"rest"| >= d_min$
          + *return* $(e, Deep("rest", t."middle", t."right"))$
        + *if* $t."middle"$ *is* $Shallow$ *and* $|t."middle"."values"| = 0$
          + *return* $(e, Shallow(concat(t."left", t."right")))$
        + *let* $"node", "mrest" = ftpopl(t."middle")$
        + *return* $(e, Deep(concat("rest", "node"."values"), "mrest", t."right"))$
  ],
  caption: [Die _Pop_ Operation an der linken Seite eines Fingerbaumes.],
) <alg:finger-tree:pop-left>
]

== Insert & Remove
Die Operationen _Insert_ und _Remove_ sind in @bib:hp-06 durch eine Kombination von _Split_, _Push_ bzw. _Pop_ und _Concat_ implementiert.
Dabei sind _Split_ und _Concat_ jeweils Operationen mit logarithmischer Zeitkomplexität $Theta(log n)$.
Je nach Implementierung können spezialisierte Varianten von _Insert_ und _Remove_ durch den gleichen Über-/Unterfluss Mechanismus implementiert werden welcher bei _Push_ und _Pop_ zum Einsatz kommt.

#todo[
  See if this is feasible.
  Perhaps show pseudo code of how this would be achieved.
]

== Echtzeitanalyse
Das amortisierte Zeitverhalten der verschiedenen Operationen hat für die Echtzeitanalyse keinen Belang.
Dennoch bieten Fingerbäume sublineares Zeitverhalten für alle Operationen im _worst-case_ und sind daher gewöhnlichen CoW-Datenstrukturen ohne granulare Persistenz vorzuziehen.
Je nach Anforderungen des Systems können für verschiedene Operationen zulässige Höchstlaufzeiten festegelegt werden.
Granular persistente Baumstrukturen wie Fingerbäume können prinzipell mehr Elemente enthalten bevor diese Höchstlaufzeiten pro Operationen erreicht werden.
Aus Sicht der Echtzeitanforderungen an die Operationen auf der Datenstruktur selbst, ist jede Datenstruktur mit logarithmischem Zeitverhalten vorzuziehen.
Die Wahl von Fingerbäumen über B-Bäumen ist daher eher eine Optimierung als eine Notwendigkeit.

#todo[Perhaps talk about the constant factors introduced by the choice of the branching factors.]

// diff marker
