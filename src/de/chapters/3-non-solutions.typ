#import "/src/util.typ": *
#import "/src/figures.typ"

Initial wurden zur Reduzieirung der Latenzen im T4gl-Laufzeitsystem verschiedene Veränderung auf Sprachebene, wie die Einführung von Move-Semantik oder neuer Syntax/Annotationen in T4gl-Arrays in Erwägung gezogen.
In den folgenden Abschnitten werden diese Kurz umrissen, warum diese für das Problem unzurreichend sind und wie diese Erkenntnisse zum Lösungsansatz in @chap:persistence führten.

= Move-Semantik <sec:move>
Eine der möglichen Lösungen zur Reduzierung von Array-Kopien in T4gl ist die Einführen einer Move-Semantik ähnlich derer in Rust oder `std::move` in C++.
@lst:cpp-move zeigt die Initialisierung dreier Vektoren.
Zu erst wird der Vektor `foo` angelegt.
Danach wird der Vektor `foo` Kopiert um `bar` zu initialisieren.
Darauf hin wird `baz` durch den _Move_ von `bar` initialisiert.
Im Anschluss sind `foo` und `baz` mit der Sequenz `[0, 1, 2]` belegt, während `bar` leer ist.

#figure(
  ```cpp
  std::vector<int> foo = {0, 1, 2};
  std::vector<int> bar = foo;            // copy!
  std::vector<int> baz = std::move(bar); // no copy!
  ```,
  caption: [Demonstration der Move-Semantik in C++.],
) <lst:cpp-move>

In C++ wird durch den Aufruf von `std::move` ein _MoveConstructor_ aufgerufen, dessen Aufgabe es ist, aus einer alten Instanz eines Typs Daten in die neue Instanz zu übertragen, ähnlich wie bei einer Kopie.
Im Gegensatz zu einer Kopie, wird die alter Instanz aber in einen uninitialisierten aber validen Zustand gesetzt, dieser ist Implementierungsdefiniert, aber meistens der Standardwert eines Typs.
Im Falles des Vektors wird, beim _Move_ der Daten von `bar` zu `baz` die Instanz `bar` deinitialisiert.

#figure(
  ```rust
  let foo = vec![0, 1, 2];
  let bar = foo.clone(); // copy!
  let baz = bar;         // no copy!
  ```,
  caption: [Demonstration der Move-Semantik in Rust.],
) <lst:rust-move>

In @lst:rust-move ist die Rust-Variante von @lst:cpp-move zu sehen.
Der Unterschied liegt darin, dass `bar` danach nicht leer ist, sondern invalide.
Zugriffe auf die Variable `bar` sind nach der dritten Zeile nicht mehr erlaubt und werden zu Kompilierzeit geprüft.

Beide Varianten ermöglichen es potentiell teuer Kopien zu vermeiden indem die Verantwortung über Daten des Programms von einem Punkt zum anderem übertragen wird.
Die C++-Variante kann in T4gl eingeführt, werden ohne das Verhalten alter Skripte zu verändern.
Zuweisungen in T4gl würden weiterhin intern Daten teilen, statt direkt Kopien anzulegen.
Neue Skripte können durch explizitem _Move_ von Instanzen Kopien vermeiden.
Daraus folgt aber auch, das alte Skripte keinen Nutzen daraus ziehen, ohne dass diese überarbeitet werden müssen.
Bei Unachtsamkeit durch den T4gl-Programmierer können fälschlicherweise Instanzen verwendet werden welche durch einen _Move_ deinitialisiert wurden.
Die Rust-Variante verhindert durch die Invalidierung von Variablen, welche auf der rechten Seite eines _Move-Assignements_ standen, dass solche Instanzen verwendet werden.
Kann aber durch diese Restriktion Migrationsaufwand von Projekten vorraussetzen, welcher bei der C++-Variante optional wäre.
In beiden Fällen sind also Codeänderung bei T4gl-Projekten vonnöten, um von der verringerten Anzahl an Kopien zu profitieren.
Ungeachtet dessen, löst dieses verändertes Verhlaten nicht das eigentliche Problem, wenn eine Kopie durchgeführt werden muss, ist diese immernoch teuer.
Außerdem benötigt die Rust-Variante nicht-triviale Änderungen an der Analyse-Stufe des T4gl-Kompilers.

= Annotationen
Wie im vorherigen Abschnitt beschrieben, müssen die Kosten von Kopien selbst reduziert werden.
Kopien zu vermeiden bekämpft nur ein Symptom der Implementierung ohne die Ursache zu beheben.
Wenn T4gl-Arrays zu groß sind, sind Kopien rechentechnisch zu aufwendig.

#figure(
  ```t4gl
  @ArrayMax(1024)
  String[Integer] array
  ```,
  caption: [Eine `ArrayMax` Annotation begrenzt das Array auf 1024 Elemente.],
) <lst:max-annot>

Ein alternativer Lösungsansatz zur Reduzierung der Kosten von Kopien, sind Annotationen, welche die Anzahl on T4gl-Arrays begrenzen.
@lst:max-annot zeigt wie eine solche Annotation verwendet werden könnte.
Es gibt verschiedene Möglichkeiten solche Annotationen zu implementieren:
+ Überprüfung zur Analyse-Stufe:
  Ähnlich der statischen T4gl-Arrays (z.B. `String[10]`) müsste überprüft werden, dass die Länge des Arrays 1024 nicht übersteigt.
+ Überprüfung zur Laufzeit:
  Überschreitung der Maximallänge würde einen Laufzeitfehler hervorrufen.

Das Verhalten von statischen Arrays ist verhältnismäßig simpel, die Funktionen `insert` oder `remove` können zu Kompilizerzeit schon nicht aufgerufen werden und Elemente sind durchgängig initialisiert.
Um die Überschreitung der Maximallänge zur Analyse-Stufe zu überprüfen, müsste der Kompiler zur Analyse-Stufe Annahmen über unbekannte Größen stellen von welchen die Anzahl der Elemente abhängen.
Hängen diese von Laufzeitwerten wie _I/O_ ab, dann ist die Analyse in den meisten zu Analyse-Stufe unmöglich.
Es ist auch nicht trivial zu überprüfen, wann ein T4gl-Array durch ein anderes intialisiert wurde, welches eine solche Annotation hat.
Die Zuweisung von verschiedenen T4gl-Instanzen kann ebenfalls von Laufzeitvariablen abhängen.

Bei Überprüfung zur Laufzeit wird zwar verhindert das T4gl-Arrays eine Maximallänge überschreiten, das erfolgt aber durch einen Laufzeitfehler.
Wird ein Laufzeitfehler nicht verarbeitet, beendet dieser das Programm.

Ähnlich der Move-Semantik in @sec:move, müssen Annotationen explizit zu alten Projekten hinzugefügt werden um von diesen zu profitieren.
Anaylse ist beinahe unmöglich und Laufzeitfehler sind in den meisten Fällen schlimmer als Verzögerungen.
Desweiteren verhindern diese nur Kopien von Arrays mit mehr Elementen als die Annotation angibt, wird eine Annotation aber mit einem Wert wie $2^64$ verwendet, ist diese nutzlos.
