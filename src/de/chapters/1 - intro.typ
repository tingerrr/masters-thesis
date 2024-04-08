= Problemstellung und Motivation
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
)

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

Diese Obergrenzen und das asymptotische Verhalten der Datenstrukturen sind wichtige Charakteristiken nach welchen diese ausgewählt werden.
Wird eine Datenstruktur benötigt welche vorwiegend dazu benutzt nach dem LIFO (Last-In-First-Out) Prinzip Elemente zu verwalten, werden Datenstrukturen gewählt welche für `push` und `pop` Operationen geringe Zeitkomplexität aufweisen, z.B. einen Stack.

// TODO: go further into complexity and how static knowledge is important for assumptions under real time constraints, as well as how these can be better optimized for
// TODO: mention how memory management itself is part of the time complexity too because of reallocs
// TODO: talk about optimized general purpose implementations of such as rrb-vectors

