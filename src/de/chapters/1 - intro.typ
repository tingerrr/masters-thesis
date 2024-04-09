#import "/util.typ": *

// TODO: see various notes about structure, the order doesn't quite make sense yet

= Grundlagen
== Komplexität und Landau-Symbol
Für den Verlauf dieser Arbeit sind Verständnis von Zeit- und Speicherkomplexität und der verwendeten Landau-Notation unabdingbar.

/ Zeitkomplexität: Zeitverhalten einer Operation (oft simple Operationen oder Algorithmen) über ein Menge von Daten in Bezug auf die Anzahl dieser.
/ Speicherkomplexität: Speicherverhalten einer Menge an Daten in Bezug auf die Anzahl dieser.

Landau-Symbole (nach Edmund Landau) sind eine Notation welche zur Klassifizierung der Komplexität von Funktionen und Algorithmen verwendet wird.
#no-cite
Im weiteren wird vorwiegend lediglich $O(f)$ verwendet um die Komplexität von Speicher oder Laufeit bestimmter Operationen im Bezug auf die Anzahl der Elemente bestimmter Datenstrukturen zu beschreiben.
Sprich, $O(n)$ beschreibt lineare zeitliche Komplexität einer Operation, oder den linearen Speicherverbauch im Bezug der Anzahl der Elemente $n$ der Datenstruktur.

/ amortisierte Komplexität: #todo[
  cite: https://archive.org/details/introduction-to-algorithms-by-thomas-h.-cormen-charles-e.-leiserson-ronald.pdf/page/451/mode/2up
]

== Echtzetisysteme
Unter Echtzeitsystemen versteht man diese, welche ihre Aufgaben oder Berechnungen in einer vorgegebenen Zeit erledigen könnnen müssen. Ist ein System nicht in der Lage eine Aufgabe in der vorgegebenen Zeit vollständig abzuarbeiten, so spricht man von Verletzung der Echtzeitbedinungen welche an das System gestellt wurden.

Für die verifizierbare Einhaltung der Echtzeitbedingungen eines Systems ist unter anderem auch das Zeit- und Speicherverhalten der verwendeten Datenstrukturen relevant.
Unter Verwendung von Datenstrukturen wie `std::array`, können für Iterationen die Höchstwerte zur Kompilierzeit Höchstwerte definiert werden.

#figure(
  ```cpp
  std::array<int, 3> arr = { 1, 2, 3 };

  for (const int& value : arr) {
    std::cout << value << std::endl;
  }
  ```,
  caption: [
    Ein `std::array` der Länge 3 wird angelegt und die Werte werden in einer Schleife ausgegeben.
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

Es folgt aus der Substitution, dass das Programm keine Schleifen enthält deren Höchstiterationszahl nicht bekannt sind.
Die Analyse zur Einhaltung der Echtzeitbedingungen dieses Programms ist dann trivial.

// TODO: show counter example with vector + explain that vector is not inherently impossible to use here, rather that analysis is harder

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
    Die Speicherverwaltung des dynamischen Arrays ist hinter dessen Programmierschnittstelle abstrahiert.
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
  caption: [Statische und dynamische Datenstrukturen in C++.],
) <tbl:stat-dyn>

Wie in @tbl:stat-dyn zu sehen ist, werden in der Praxis vorwiegend dynamische Strukturen verwendet.
Das hat Folgen für die Zeit- und Speicherkomplexität der Operationen auf diesen Strukturen.
Während bei Datenstrukturen mit statisch bekannter Größe wie `std::array<int, 10>` die Größe der Struktur bereits bekannt ist -- und somit Obergrenzen für Zeit- und Speicherkomplexitäten -- so können bei den Komplexitäten von `std::vector<int>` nicht ohne weiteres Obergrenzen für Komplexitäten festgelegt werden.

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
  Die Zeitkomplexität von `push_back` über die gesamte Lebenszeit eines Vectors ist durch den Wachstumsfaktor amortisiert Konstant. @bib:cppref-vector
  Unter bestimmten Bedingungen ist amortisiert Konstant allerdings nicht ausreichend.
]
Sprich, wenn Speicherverschiebung nötig ist, weil der Speicher nicht erweitert werden kann, müssen alle Elemente in die neue Speicherregion kopiert werden.

= Stand der Technik
// TODO: talk about optimized general purpose implementations of such as rrb-vectors
