#import "/src/util.typ": *
#import "/src/figures.typ"

= Von Haskell zu C++
Die ursprüngliche Implementierung hat drei verschiedene Zustände, welche verschiedene Invarianzen von 2-3-Fingerbäumen sichern.
- `Empty`: Ein leerer Zustand ohne Felder.
- `Single`: Ein Überbrückungszustand zum Speichern eines einzelnen Knotens in einer Ebene, hat einen einzelnen Knoten als Feld.
- `Deep`: Die rekursive Definition der Datenstruktur, hat drei Felder, die _Digits_ auf beiden Seiten und einen weiteren Fingerbaum mit nicht-regulärer Rekursion auf Typebene.
  Die Definition von `FingerTree a` verwendet nicht erneut `FingerTree a`, sondern `FingerTree (Node a)`, daraus wird die Tiefe der Knoten auf jeder Ebene automatische durch den Typ gesichert.

In C++ ist die Definition von rekursiven Typen möglich, diese müssen aber regulär erfolgen.
Eine Klasse `C<T>` kann in der eigenen Definition auf folgende Versionen von `C<T>` zurückgreifen:
- Voll-instanzierte Typen wie `C<int>` oder `C<std::string>`.
- Neu parametrierte Typkonstruktoren wie ```cpp template<typename U> class C<U>```, in sofern diese nicht on `T` abhängen.
- Eigenverweise wie `C<T>` ohne _verpacken_ von Typen wie `C<A<T>>`.

Die Definition in @lst:illegal-recursive-type ist demnach Illegal und hat bestimmte folgen für die API der Datenstruktur.
Während die gleichen Algorithmen in der Haskell-Definition verwendert werden können, um einzelne Elemente vom Typ `a`, sowie deren Verpackete Knoten (`Node a`, `Node (Node a)`, etc.) einzufügen oder abzutrennen, muss die C++-Definition immer Knoten einfügen und zurückgeben.
Die internen rekursiven Algorithmen werden als `private` markiert und nur von speziellen Hilfsfunktionen aufgerufen, welche die Knoten entpacken oder verpacken.

Da die Implementierung des 2-3-Fingerbaums persistent sein soll, werden statt gewöhnlichen Pointern `std::shared_ptr` verwendet um auf geteilte Knoten und Unterbäume zu zeigen.
Damit die `Empty`-Variante nicht unnötig angelegt und von einem `std::shared_ptr` verwaltet wird, wurden die Varianten `Empty` und `Single` in einer Variante `Shallow` vereint, welche für `Empty` lediglich einen ```cpp nullptr``` enthält.

#figure(
  figures.finger-tree.def.illegal,
  caption: [Nicht-reguläre Definition von Fingerbäumen.],
) <lst:illegal-recursive-type>

In @lst:finger-tree ist bereits zu sehen, dass die Elemente `a` und deren generische _Mesures_ `v` durch die expliziten Typen `K` und `V` ersetzt wurden, für T4gl sind andere _Measures_ als `Key` über Schlüssel-Wert-Paare nicht relevant und wurden daher direkt eingesetzt.
Diese Ersetzung zeigt sich auch in den Algorithmen, welche einerseits direkt auf die Invarianzen von `Key` und dessen Ordnungsrelation zurückgreifen, sowie auch diese Algorithmen enthalten, welche nur für geordnete Sequenzen sinnvoll sind (_Insert_ und _Remove_).

Die Implementierung von 2-3-Fingerbäumen, sowie deren Benchmarks mit Tests von `QMap` und einer persistenten B-Baum-Implementierung zur Kontrolle können unter #link("https://github.com/tingerrr/finger-tree")[GitHub:tingerrr/FingerTree] eingesehen werden.
Verweise auf die Implementierung beziehen sich auf den letzten Stand dieses Repositories, welches mit Abgabe dieser Arbeit archiviert wird.

@lst:finger-tree-initial zeigt die initiale Implementierung der 2-3-Fingerbäume, dabei ist die Parametrierung der Klassen durch ```cpp template <typename k, typename V>``` aus Platzgründen ausgelassen.

#figure(
  figures.finger-tree.def.initial,
  caption: [Die initiale Implementierung von 2-3-Fingerbäumen in C++.],
) <lst:finger-tree-initial>
