#import "/src/util.typ": *

= Grundlagen
== Komplexität und Landau-Symbole <sec:complexity>
Für den Verlauf dieser Arbeit sind Verständnis von Zeit- und Speicherkomplexität und der verwendeten Landau-Symbole unabdingbar.
Komplexitätstheorie befasst sich mit der Komplexität von Algorithmen und algorithmischen Problemen, vor allem in Bezug auf Speicherverbrauch und Bearbeitungszeit.
Dabei sind folgende Begriffe relevant:

/ Zeitkomplexität: Zeitverhalten einer Operation (oft simple Operationen oder Algorithmen) über eine Menge von Daten in Bezug auf die Anzahl dieser.
/ Speicherkomplexität: Speicherverhalten einer Menge an Daten in Bezug auf die Anzahl dieser.
/ Amortisierte Komplexität: Unter Bezug einer Sequenz von $n$ Operationen mit einer Dauer von $T(n)$, gibt die amortisierte Komplexität den Durchschnitt $T(n)\/n$ einer einzigen Operation an @bib:clrs-09[S. 451].

Landau-Symbole (nach Edmund Landau) sind eine Notation welche zur Klassifizierung der Komplexität von Funktionen und Algorithmen verwendet wird.
#no-cite
Im Weiteren wird vorwiegend $O(f)$ verwendet um die Komplexität des Speicherverbrauchs oder die Laufzeit bestimmter Operationen in Bezug auf die Anzahl der Elemente einer Datenstruktur zu beschreiben.
Sprich, $O(n)$ beschreibt lineare zeitliche Komplexität einer Operation über $n$ Elemente, oder den linearen Speicherverbrauch einer Datenstruktur mit $n$ Elementen.
@tbl:landau zeigt weitere Komplexitäten.

Dabei werden für die Klassifizierung mit Landau-Symbolen meist das asymptotische Verhalten betrachtet.
Ein Algorithmus $f in O(2n)$ ist einem Algorithmus $g in O(3n)$ gleichzustellen, während $h in O(n^2)$ als komplexer gilt, da die Unterschiede zwischen $f$ und $g$ im Vergleich zu $h$ bei großen Datenmengen zu vernachlässigen sind.
Sprich, aus Sicht der Komplexität gilt dann $f = g$, und $f < h and g < h$ für große $n$.

#figure(
  table(columns: 2, align: left,
    table.header[Komplexität][Beschreibung],
    $O(k)$, [Komplexität unabhängig der Menge der Daten $n$, oft mit $O(n)$ gleichzusetzen],
    $O(log_k n)$, [Logarithmische Komplexität über die Menge der Daten $n$ zur Basis $k$],
    $O(k n)$, [Lineare Komplexität über die Menge der Daten $n$ und einem Koeffizienten $k$],
    $O(n^k)$, [Polynomialkomplexität des Grades $k$ über die Menge der Daten $n$],
    $O(k^n)$, [Exponentialkomplexität über die Menge der Daten $n$ zur Basis $k$],
  ),
  caption: [
    Unvollständige Liste verschiedener Komplexitäten in aufsteigender Reihenfolge. Dabei ist $k$ eine beliebige Konstante.
  ],
) <tbl:landau>

== Dynamische Datenstrukturen
Datenstrukturen sind eine Organisierungsstruktur der Daten in Speicher eines Rechensystems welches das Speicher- und/oder Zeitverhalten für bestimmte Operationen verbessern soll.
Bei Datenstrukturen spricht man oft von geordneten oder ungeordneten Mengen, eine Datenstruktur kann aber auch dazu verwendet werden nur ein einziges Element zu verwalten (z.B. `std::optional` oder `std::atomic` in der C++ Standardbibliothek).

Dynamische Datenstrukturen sind Datenstrukturen welche vor allem dann Verwendung finden, wenn die Anzahl der in der Struktur verwalteten Elemente nicht vorraussehbar ist.
Je nach Programmiersprache kann eine Datenstruktur interne Operationen durch dessen Programmierschnittstelle abstrahieren, um dessen Invarianzen zu wahren.
So muss zum Beispiel eine Binärbaumimplementierung in C vom Konsument der Datenstruktur selbst ausbalanciert werden, während eine Implementierung in C++ diese Operation "hinter den Kulissen" durchführt.
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
    `std::vector` vergrößert die eigene Kapazität dynamisch zur Laufzeit des Programms.
    Die Speicherverwaltung des Vektors ist hinter dessen Programmierschnittstelle abstrahiert.
  ],
) <lst:vec-ex>

Die C++ Standardbibliothek stellt unter der Header-Datei `<vector>` die gleichnamige Template-Klasse bereit.
`std::vector` verfügt über Methoden, welche eigenhändig den Speicher erweitern oder verringern, insofern das für die gegebene Operation nötig oder möglich ist.
So wird zum Beispiel bei der Verwendung von `push_back()` der Speicher erweitert, wenn die jetzige Kapazität des Vektors unzureichend ist.
Eine restriktivere Variante des Vektors ist das Array (`int arr[10]` oder `std::array<int, 10>`).
Die bekannte Größe der Datenstruktur bringt verschiedene Vor- und Nachteile mit sich.

*Vorteile*
- Der Speicher der Datenstruktur kann ohne Indirektion angelegt werden.
  - Die Elemente von Arrays können direkt auf dem Stack oder in einer Klasse gespeichert werden.
    Das fördert räumliche Lokalität und kann damit die Verwendung der CPU-Cache erhöhen.
  - Der Speicher der Datenstruktur muss nicht zur Laufzeit angelegt werden. Das verringert die Anzahl potenziell teurer Allokationsaufrufe.
- Durch die bekannte Größe können Iterationen über die Struktur aufgerollt oder anderweitig optimiert werden.

*Nachteile*
- Die Kapazität ist fest definiert, es können nicht weniger oder mehr Objekte gespeichert werden.
- Gelten Teile des Arrays als uninitialisiert müssen Informationen darüber separat verwaltet werden.

Die bekannte Größe des Arrays hat nicht nur Einfluss auf die Optimierungsmöglichkeiten eines Programms, sondern auch auf die Komplexitätsanalyse.
Iteration auf bekannter Größe sind, wie in @sec:complexity bereits beschrieben, effektiv konstant.
Dieser Zerfall von nicht konstanter zu konstanter Zeitkomplexität propagiert durch alle Operationen, welche nur auf den Elementen dieser Datenstrukturen operieren oder anderweitig konstante Operationen ausführen.
Sei ein Programm gegeben, welches auf einer dynamischen Länge von Elementen $n$ operiert, so könnnen durch die Substitution von $n$ durch eine Konstante $k$ für alle Opertionen auf $n$ die Zeitkomplexität evaluiert werden.
Trivialerweise gilt, ist $x$ eine Konstante, so ist $y = f(x)$ eine Konstante, unter der Annahme das $f(x)$ wirkungsfrei ist.
#footnote[
  Eine Funktion $f(x)$ gilt als wirkungsfrei, wenn diese für jeden Aufruf mit $x_n$ die gleiche Ausgabe $y_n$ ergibt und der Aufruf keinen Einfluss auf diese Eigenschaft anderer Funktionen hat.
]

=== Speicheroperationen
Die in @lst:vec-ex zu sehenden Methoden auf `std::vector` abstrahieren potentiell teure Operationen:

/ Speicheranlegung: Neue Speicherregion wird angelegt.
/ Speicherlöschung: Bestehende Speicherregion wird gelöscht.
/ Speichererweiterung: Bestehende Speicherregion wird erweitert.
/ Speicherverringerung: Bestehender Speicherregion wird verkleinert.
/ Speicherverschiebung: Kombination aus Speicheranlegung, Kopie der Daten und Speicherlöschung.

Bei der Implementierung des `std::vector` wird vorallem die Speicherverschiebung wenn möglich, vermieden, da diese selbst eine wort-case Zeitkomplexität von $O(n)$ (mit $n = $ Anhzal der Element im Vektor) aufweist.
#footnote[
  Die Zeitkomplexität von `push_back` über die gesamte Lebenszeit eines Vektors ist durch den Wachstumsfaktor amortisiert Konstant @bib:iso-cpp-20[S. 834].
  Unter bestimmten Bedingungen ist amortisiert Konstant allerdings nicht ausreichend.
]
Sprich, wenn Speicherverschiebung nötig ist, weil der Speicher nicht erweitert werden kann, müssen alle Elemente in die neue Speicherregion kopiert werden.

== Echtzeitsysteme
Unter Echtzeitsystemen versteht man diese Systeme, welche ihre Aufgaben oder Berechnungen in einer vorgegebenen Zeit abarbeiten. Ist ein System nicht in der Lage eine Aufgabe in der vorgegebenen Zeit vollständig abzuarbeiten, so spricht man von Verletzung der Echtzeitbedinungen, welche an das System gestellt wurden.

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
    Ähnlich wie bei @lst:array-ex, mit einem `std::vector`, statt einem `std::array`.
  ],
) <lst:vector-ex>

Es ist nicht unmöglich fundierte Vermutungen über die Anzahl von Elementen in einer Datenstruktur anzustellen, dennoch fällt es mit dynamischen Datenstrukturen schwerer alle Invarianzen eines Programms bei der Analyse zu berücksichtigen.
Je nach Operation und Nutzungsfall können Datenstrukturen in Ihrer Programmierschnittstelle erweitert oder verringert werden, um diese Invarianzen auszunutzen oder sicherzustellen.

= Stand der Technik
// TODO: talk about optimized general purpose implementations of such as rrb vectors, chunked sequnces and finger trees

= T4gl
T4gl (#strong[T]esting *4GL* #footnote[4th Generation Language]) ist eine proprietäre Programmiersprache, sowie ein gleichnamiger Compiler und Laufzeitsystem, welche von der Brückner und Jarosch Ingenieurgesellschaft mbH (BJ-IG) entwickelt und verwendet werden.
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
    `T[U] name`, `std::unordered_map<U, T> name`,
    `T[U, N] name`, `std::unordered_map<U, std::array<T, N>> name`,
    `T[N, U] name`, `std::array<std::unordered_map<U, T>, N> name`,
    align(center)[...], align(center)[...],
  ),
  caption: [
    Semantische Analogien in C++ zu spezifischen Varianten von T4gl-Arrays. `T` und `U` sind Typen und `N` ist eine Zahl aus $NN^+$.
  ],
) <tbl:t4gl-array-analogies>

Die Datenspeicherung im Laufzeitsystem kann nicht direkt ein statisches Array (`std::array<T, 10>`) verwenden, da T4gl nicht direkt in C++ übersetzt und kompiliert wird, sondern in Instruktionen welche vom Laufzeitsystem interpretiert werden.
Außerdem werden bei komplexen Datentypen oder potenziellen Kontextwechseln noch weitere Speicherabstraktionen hinzugefügt.
Für manche Schlüsseltypen können auch Binärbäume statt Hashtabellen zum Einsatz kommen, wenn das Laufzeitsystem davon ausgeht, dass dies angebrachter ist #no-cite.

// TODO: talk about the array problems here or in the concept chapter?
