#import "/util.typ": *

// TODO: see various notes about structure, the order doesn't quite make sense yet

= Grundlagen
== Komplexität und Landau-Symbole
Für den Verlauf dieser Arbeit sind Verständnis von Zeit- und Speicherkomplexität und der verwendeten Landau-Symbole unabdingbar.
Komplexitätstheorie befasst sich mit der Komplexität von Algorithmen und algorithmischen Problemen, vorallem im Bezug auf Speicherverbrauch und Bearbeitungszeit. Dabei sind folgende Begriffe relevant:

/ Zeitkomplexität: Zeitverhalten einer Operation (oft simple Operationen oder Algorithmen) über ein Menge von Daten in Bezug auf die Anzahl dieser.
/ Speicherkomplexität: Speicherverhalten einer Menge an Daten in Bezug auf die Anzahl dieser.
/ amortisierte Komplexität: Unter Bezug einer Sequenz von $n$ Operationen mit einer Höchstdauer von $T(n)$, gibt die amortisierte Komplexität den Durchschnitt $T(n)\/n$ einer einzigen Operation an @bib:intro-to-algo[S. 451].

Landau-Symbole (nach Edmund Landau) sind eine Notation welche zur Klassifizierung der Komplexität von Funktionen und Algorithmen verwendet wird.
#no-cite
Im Weiteren wird vorwiegend $O(f)$ verwendet um die Komplexität des Speicherverbrauchs oder die Laufzeit bestimmter Operationen im Bezug auf die Anzahl der Elemente einer Datenstruktur zu beschreiben.
Tabelle @tbl:landau zeigt weitere Komplexitäten.
Sprich, $O(n)$ beschreibt lineare zeitliche Komplexität einer Operation über $n$ Elemente, oder den linearen Speicherverbauch einer Datenstruktur mit $n$ Elementen.

Dabei werden für die Klassifizerung mit Landau-Symbolen meist das asymptotische Verhalten betrachtet.
Ein Algorithmus $f(n) in O(2n)$ ist einem Algorithmus $g(n) in O(3n)$ gleichzustellen, während $h(n) in O(n^2)$ als komplexer gilt, da die unterschiede zwischen $f$ und $g$ im Vergleich zu $h$ bei großen Datenmengen ve vernachlässigen sind.
Sprich, aus sicht der Komplexität gilt dann $f = g$, und $f < h and g < h$ für große $n$.

#figure(
  table(columns: 2, align: left,
    table.header[Komplexität][Beschriebung],
    $O(k)$, [Komplexität unabhängig der Menge der Daten $n$, oft mit $O(n)$ gleichzusetzen],
    $O(log_k n)$, [Logarithmische Komplexität über die Menge der Daten $n$ zur Basis $k$],
    $O(n)$, [Lineare Komplexität über die Menge der Daten $n$],
    $O(n^k)$, [Polynomialkomplexität des grades $k$ über die Menge der Daten $n$],
    $O(k^n)$, [Exponentialkomplexität über die Menge der Daten $n$ zur Basis $k$],
  ),
  caption: [
    Unvollständige Liste verschiedene Komplexitäten in aufsteigender Reihenfolge.
  ],
) <tbl:landau>

== Echtzeitsysteme
Unter Echtzeitsystemen versteht man diese Systeme, welche ihre Aufgaben oder Berechnungen in einer vorgegebenen Zeit abarbeiten. Ist ein System nicht in der Lage eine Aufgabe in der vorgegebenen Zeit vollständig abzuarbeiten, so spricht man von Verletzung der Echtzeitbedinungen welche an das System gestellt wurden.

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
    Ein `std::array` der Länge 3 wird an die Funktion übergeben und dessen Werte werden in einer Schleife ausgegeben.
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
      Unter Anwendung von Compiler-Optimierungen wird dies wenn möglich automatisch vorgenommen.
    ]
  ],
) <lst:array-ex-unrolled>

Es folgt aus der Substitution, dass das Programm keine Schleifen enthält deren Höchstiterationszahl nicht bekannt ist.
Die Analyse zur Einhaltung der Echtzeitbedingungen dieses Programms ist dann trivial.
Man vergleiche dies mit dem Program in @lst:vector-ex.
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
    Ähnlich wie bei @lst:array-ex, mit einem `std::vector`, statt einem `std::array`.
  ],
) <lst:vector-ex>

Es ist nicht unmöglich fundierte Vermutungen über die Anzahl von Elementen in einer Datenstruktur anzustellen, dennoch fällt es mit dynamischen Datenstrukturen schwerer alle Invarianzen eines Programms bei der Analyse zu berücksichtigen.
Je nach Operation und Nutzungsfall können Datenstrukturen in Ihrer Programmierschnittstelle erweitert oder verringert werden, um diese Invarianzen auszunutzen oder sicherzustellen.

// TODO: this doesn't feel right here, and ought to be moved into another section

= Problemstellung und Motivation
// TODO: talk about the general motivation

== Statische und Dynamische Datenstrukturen
Dynamische Datenstrukturen sind Datenstrukturen welche vor allem dann Verwendung finden, wenn die Anzahl der in der Struktur verwalteten Elemente nicht vorraussehbar ist.
In den meisten Bereichen der Programmierung sind diese unabdingbar, da diese oft durch die Implementierungssprache beretgestellte Mechanismen den Speicher für die Struktur selbst verwalten und abstrahieren.
So wird für den Konsument meist nur eine Hoch-Level Schnittstelle beretigestellt mit welcher dieser interagiert.
Ein klassisches Beispiel für eine dynamische Datenstruktur ist ein dynamisches Array, die dynamische Erweiterung zum Array mit statischer Größe.

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
    `std::vector` vergrößert die eigene Kapazität dynamisch zur Laufzeit des Programms.
    Die Speicherverwaltung des Vectors ist hinter dessen Programmierschnittstelle abstrahiert.
  ],
) <lst:vec-ex>

Die C++ Standardbibliothek stellt unter der Header-Datei `<vector>` die gleichnamige Template-Klasse bereit.
`std::vector` verfügt über Methoden welche eigenhändig den Speicher erweitern oder verringern, insofern das für die gegebene Operation nötig oder möglich ist.
So wird zum Beispiel bei der Verwendung von `push_back()` der Speicher erweitert wenn die jetzige Kapazität des Vectors unzureichend ist.

Generell gibt es zu fast jeder Datenstruktur eine statische und dynamische Variante, in der Praxis werden aber oft nur eine dieser Varianten bereitgestellt.

#figure(
  table(columns: 3, align: left,
    table.header[Typ][Statisch][Dynamisch],
    // NOTE: the linebreak is intentional, see typst/typst#3864
    [Array], [`std::array<int, 10>`/\ `int arr[10]`], [`std::vector<int>`],
    [Stack], [-], [`std::vector<int>`],
    [Hash Set], [-], [`std::unordered_set<int>`],
    [Hash Map], [-], [`std::unordered_map<int, int>`],
  ),
  caption: [Statische und dynamische Datenstrukturen in der C++ Standardbibliothek.],
) <tbl:stat-dyn>

Wie in @tbl:stat-dyn zu sehen ist, werden in der Praxis vorwiegend dynamische Strukturen verwendet.
Das hat Folgen für die Zeit- und Speicherkomplexität der Operationen auf diesen Strukturen.
Während bei Datenstrukturen wie `std::array<int, 10>` die Größe der Struktur bereits bekannt ist -- und somit Obergrenzen für Zeit- und Speicherkomplexitäten -- so können bei den Komplexitäten von `std::vector<int>` nicht ohne Weiteres Obergrenzen festgelegt werden.

Diese Obergrenzen und das asymptotische Verhalten der Datenstrukturen sind wichtige Charakteristiken für die korrekte Wahl der Datenstruktur.
Wird eine Datenstruktur benötigt welche vorwiegend dazu benutzt nach dem LIFO (Last-In-First-Out) Prinzip Elemente zu verwalten, dann werden Datenstrukturen gewählt, welche für `push` und `pop` Operationen geringe Zeitkomplexität aufweisen, z.B. einen Stack.

== Speicher Operationen
Die in @lst:vec-ex zu sehenden Methoden auf `std::vector` abstrahieren potentiell teure Operationen:

/ Speicheranlegung: Neue Speicherregion wird angelegt.
/ Speicherlöschung: Bestehende Speicherregion wird gelöscht.
/ Speichererweiterung: Bestehende Speicherregion wird erweitert.
/ Speicherverringerung: Bestehender Speicherregion wird verkleinert.
/ Speicherverschiebung: Kombination aus Speicheranlegung, Kopie der Daten und Speicherlöschung.

Bei der Implementierung des `std::vector` wird vorallem die Speicherverschiebung wenn möglich, vermieden, da diese selbst eine wort-case Zeitkomplexität von $O(n)$ (mit $n = $ Anhzal der Element im Vector) aufweist.
#footnote[
  Die Zeitkomplexität von `push_back` über die gesamte Lebenszeit eines Vectors ist durch den Wachstumsfaktor amortisiert Konstant @bib:cppref-vector.
  Unter bestimmten Bedingungen ist amortisiert Konstant allerdings nicht ausreichend.
]
Sprich, wenn Speicherverschiebung nötig ist, weil der Speicher nicht erweitert werden kann, müssen alle Elemente in die neue Speicherregion kopiert werden.

= Stand der Technik
// TODO: talk about optimized general purpose implementations of such as rrb-vectors
