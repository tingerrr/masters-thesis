#import "/src/util.typ": *
#import "/src/figures.typ"

Die in @chap:non-solutions beschriebenen Lösungsansätze haben alle etwas gemeinsam, sie bekämpfen Symptome statt Ursachen.
Die Häufigkeit der Kopien kann reduziert werden, aber nie komplett eliminiert, da es eine fundamentale Operation ist.
Es gilt also, ungeachtet der Häufigkeit einer solchen Operation, auf Seiten der Implementierung von T4gl-Arrays, Kopien von Daten nur dann anzufertigen, wenn das vonnöten ist.
In @sec:t4gl:arrays wurde beschrieben, wie T4gl-Arrays bereits Daten teilen und nur bei Schreibzugriffen auf geteilte Daten Kopien erstellen.
Das fundamentale Problem ist, dass bei Schreibzugriffen auf geteilte Daten, ungeachtet der Ähnlichkeit der Daten nach dem Schreibzugriff, alle Daten kopiert werden.

Im Folgenden wird beschrieben, wie effiziente Datenteilung durch _Persistenz_ @bib:fk-03, auf Speicherebene der T4gl-Arrays die Komplexität von Typ-3-Kopien auf logarithmische Komplexität senken kann.
Es werden die Begriffe der _Persistenz_ und _Kurzlebigkeit_ im Kontext von Datenstrukturen eingeführt, sowie der aktuelle Stand persistenter Datenstrukturen beschrieben.
Im Anschluss werden persistente Datenstrukturen untersucht, welche als Alternative der jetzigen _Qt-Instanzen_ verwendet werden können.

= Kurzlebige Datenstrukturen <sec:eph-data>
Um den Begriff der _Persistenz_ zu verstehen, müssen zunächst _kurzlebige_ oder gewöhnliche Datenstrukuren entgegengestellt werden.
Dafür betrachten wir den Vektor, ein dynamisches Array.

#figure(
  figures.vector.repr,
  caption: [Der Aufbau eines Vektors in C++.],
) <fig:vec-repr>

Ein Vektor besteht in den meisten Fällen aus 3 Elementen, einem Pointer `ptr` auf die Daten des Vektors (in #text(gray)[*grau*] eingezeichnet), der Länge `len` des Vektors und die Kapazität `cap`.
@fig:vec-repr zeigt den Aufbau eines Vektors in C++ #footnote[
  Der gezeigte Aufbau ist nicht vom Standard @bib:iso-cpp-20 vorgegeben, manche Implementierungen speichern statt der Kapazität einen `end` Pointer, aus welchem die Kapaziät errechnet werden kann.
  Funktionalität und Verhalten sind allerdings gleich.
].
Operationen am Vektor wie `push_back`, `pop_back` oder Indizierung arbeiten direkt am Speicher, welcher an `ptr` anfängt.
Reicht der Speicher nicht aus, wird er erweitert und die Daten werden aus dem alten Speicher in den neuen Speicher verschoben.
Die in @lst:vec-ex gezeigten Aufrufe zu `push_back` schreiben die Werte direkt in den Speicher des Vektors.
Zu keinem Zeitpunkt gibt es mehrere Instanzen, welche auf die gleichen Daten zeigen.
Wird der Vektor `vec` auf `other` zugewiesen, werden alle Daten kopiert, die Zeitkomplexität der Kopie selbst ist proportional zur Anzahl der Elemente $Theta(n)$.

#figure(
  figures.vector.example,
  caption: [
    Ein C++ Program, welches einen `std::vector` anlegt und mit Werten befüllt.
  ],
) <lst:vec-ex>

= Persistenz und Kurzlebigkeit <sec:per-eph>
Wenn eine Datenstruktur bei Schreibzugriffen die bis dahin bestehenden Daten nicht verändert, gilt diese als _persistent/langlebig_ @bib:kt-96[S. 202].
In den Standardbibliotheken verschiedener Programmiersprachen hat sich für dieses Konzept der Begriff _immutable_ durchgesetzt.
Im Gegensatz dazu stehen Datenstrukturen, welche bei Schreibzugriffen ihre Daten direkt beschreiben, diese gelten als _kurzlebig_, wie zum Beispiel der Vektor, beschrieben in @sec:eph-data.
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
    Soll der Kopf von `m` gelöscht werden, zeigt eine neue Liste `n` stattdessen auf den Rest. \
  ]),
  figure(figures.list.push, caption: [
    Soll ein neuer Kopf an `n` angefügt werden, kann der Rest durch die neue Instanz `o` weiterhin geteilt werden.
  ]),
  columns: 2,
  caption: [
    Eine Abfolge von Operationen auf persistenten verketten Listen.
  ],
  label: <fig:linked-sharing>,
)

Im Folgenden werden durch die Datenteilung _Instanzen_ und _Daten_ semantische getrennt:
/ Instanzen:
  Teile der Datenstruktur, welche auf die geteilten Daten verweisen und anderweitig nur Verwaltungsinformationen enthalten.
/ Daten:
  Die Teile einer Datenstruktur, welche die eigentlichen Elemente enthält, in @fig:linked-sharing beschreibt das die Knoten mit einfacher Umrandung, während doppelt umrandete Knoten die Instanzen sind.

Persistenz zeigt vor allem bei Baumstrukturen ihre Vorteile, bei der Kopie der Daten eines persistenten Baums können je nach Tiefe und Balance des Baumes Großteile des Baumes geteilt werden.
Ähnlich wie bei persistenten einfach verketteten Listen, werden bei Schreibzugriffen auf persistente Bäume nur die Knoten des Baumes kopiert, welche zwischen Wurzel und dem veränderten Knoten liegen.
Dass nennt sich eine Pfadkopie (_engl._ path copying).
Betrachten wir partielle Persistenz von Bäume am Beispiel eines Binärbaums, sprich eines Baums mit Zweigfaktoren (ausgehendem Knotengrad) zwischen $0$ und $2$.
@fig:tree-sharing illustriert, wie am Binärbaum `t` ein Knoten `X` angefügt werden kann, ohne dessen partielle Persistenz aufzugeben.
Es wird eine neue Instanz angelegt und eine Kopie der Knoten `A` und `C` angelegt, der neue Knoten `X` wird in `C` eingehängt und der Knoten `B` wird von beiden `A` Knoten geteilt.
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
Je besser ein persistenter Baum balanciert ist, desto geringer ist die Anzahl der Knoten, welche bei Pfadkopien unnötig kopiert werden müssen.

= Lösungsansatz
Zunächst definieren wir Invarianzen von T4gl-Arrays, welche durch eine Änderung der Implementierung nicht verletzt werden dürfen:
+ T4gl-Arrays sind assoziative Datenstrukturen.
  - Es werden Werte mit Schlüsseln addressiert.
+ T4gl-Arrays sind nach ihren Schlüsseln geordnet.
  - Die Schlüsseltypen von T4gl-Arrays haben eine voll definierte Ordnungsrelation.
  - Iteration über T4gl-Arrays ist deterministisch in aufsteigender Reihenfolge der Schlüssel.
+ T4gl-Arrays verhalten sich wie Referenztypen.
  - Schreibzugriffe auf ein Array, welches eine flache Kopie eines anderen T4gl-Arrays ist, sind in beiden Instanzen sichtbar.
  - Tiefe Kopien von T4gl-Arrays teilen sichtbar keine Daten, ungeachtet, ob die darin enthaltenen Typen selbst Referenztypen sind.

Die Ordnung der Schlüssel schließt ungeordnete assoziative Datenstrukturen wie Hashtabellen aus.
Das Referenztypenverhalten ist dadurch umzusetzen, dass wie bis dato drei Ebenen verwendet werden (@sec:t4gl:arrays), es werden lediglich die _Qt-Instanzen_ durch neue Datenstrukturen ersetzt.
Essentiell für die Verbesserung des _worst-case_ Zeitverhaltens bei Kopien und Schreibzugriffen ist die Reduzierung der Daten, welche bei Schreibzugriffen kopiert werden müssen.
Hauptproblem bei flachen Kopien, gefolgt von Schreibzugriff auf CoW-Datenstrukturen, ist die tiefe Kopie _aller_ Daten in den Daten der Instanzen, selbst wenn nur ein einziges Element beschrieben oder eingefügt/entfernt wird.
Ein Großteil der Elemente in den originalen und neuen kopierten Daten sind nach dem Schreibzugriff gleich.
Durch höhere Granularität der Datenteilung müssen bei Schreibzugriffen weniger unveränderte Daten kopiert werden.

Ein Beispiel für persistente Datenstrukturen mit granularer Datenteilung sind RRB-Vektoren @bib:br-11 @bib:brsu-15 @bib:stu-15, eine Sequenzdatenstruktur auf Basis von Radix-Balancierten Bäumen.
Trotz der zumeist logarithmischen _worst-case_ Komplexitäten, können RRB-Vektoren nicht als Basis für T4gl-Arrays verwendet werden.
Die Effizienz der RRB-Vektoren baut auf der Relaxed-Radix-Balancierung, dabei wird von einer Sequenzdatenstrukur ausgegangen.
Da die Schlüsselverteilung in T4gl-Arrays nicht dicht ist, können die Schlüssel nicht ohne Weiteres auf dicht verteilte Indizes abgebildet werden.
Etwas fundamentaler sind B-Bäume @bib:bm-70 @bib:bay-71, bei persistenten B-Bäumen haben die meisten Operationen eine _worst-_ und _average-case_ Zeitkomplexität von $Theta(log n)$.
Eine Verbesserung der _average-case_ Zeitkomplexität für bestimmte Sequenzoperationen (_Push_, _Pop_) bieten 2-3-Fingerbäume @bib:hp-06.
Diese bieten sowohl exzellentes Zeitverhalten, als auch keine Enschränkung auf die Schlüsselverteilung.
Im folgenden werden 2-3-Fingerbäume als alternative Storage-Datenstrukturen für T4gl-Arrays untersucht.

#todo[
  The above could go with some examples, especially regarding RRB-Vectors and how they could be used as paired sequences ordered by key on insertion given that it's insert/remove bounds are sublinear.
]

= B-Bäume <sec:b-tree>
Eine für die Persistenz besonders gut geeignete Datenstruktur sind B-Bäume @bib:bm-70 @bib:bay-71, da diese durch ihren Aufbau und Operationen generell balanciert sind.
Schreiboperationen auf persistenten B-Bäumen müssen lediglich $Theta(log n)$ Knoten kopieren.
B-Bäume können vollständig durch ihre Zweigfaktoren beschreiben werden, sprich, die Anzahl der Kindknoten, welche ein interner Knoten haben kann bzw. muss.
Ein B-Baum ist wiefolgt definiert @bib:knu-98[S. 483]:
+ Jeder Knoten hat maximal $k_max$ Kindknoten.
+ Jeder interne Knoten, außer dem Wurzelknoten, hat mindestens $k_min = ceil(k_max \/ 2)$ Knoten.
+ Der Wurzelknoten hat mindestens 2 Kindknoten, es sei den, er ist selbst ein Blattknoten.
+ Alle Blattknoten haben die gleiche Entfernung zum Wurzelknoten.
+ Ein interner Knoten mit $k$ Kindknoten enthält $k - 1$ Schlüssel.

Üblicherweise beschreibt man B-Bäume durch Angabe ihrer Zweigfaktoren, ein B-Baum mit den Zweigfaktoren $k_min = 32$ und $k_max = 64$ wäre eine 32-64-Baum.

Die Schlüssel innerhalb eines internen Knoten dienen als Suchhilfe, sie sind Typen mit fester Ordnungsrelation und treten aufsteigend geordnet auf.
@fig:b-tree zeigt einen internen Knoten eins B-Baumes mit $k_min = 2$ und $k_max = 4$, ein sogannter 2-4-Baum.
Jeder Schlüssel $s_i$ mit $1 <= i <= k - 1$ dient als Trennwert zwischen den Unterbäumen in den Kindknoten $k_j$ mit $1 <= j <= k$.
Sei $x$ ein Schlüssel im Unterbaum mit der Wurzel $k_i$, so gilt

$
  &x <= s_i             &&bold("wenn") i = 1 \
  &x > s_(i - 1)        &&bold("wenn") i = k_max \
  &s_(i - 1) < x <= s_i &&bold("sonst") \
$

Die Schlüssel erlauben bei der Suche auf jeder Ebene den Suchbereich drastisch zu reduzieren.
Die simpelste Form von B-Bäumen sind sogenannte 2-3-Bäume (B-Bäume mit $k_min = 2$ und $k_max = 3$), dabei ist die Angabe der Zweigfaktoren als Prefix des Baums eine übliche Konvention.

#figure(
  figures.b-tree.node,
  caption: [Ein interner B-Baum-Knoten eines 2-4-Baumes.],
) <fig:b-tree>

= 2-3-Fingerbäume
2-3-Fingerbäume wurden von !Hinze und !Paterson @bib:hp-06 eingeführt und sind eine Erweiterung von 2-3-Bäumen, welche für verschiedene Sequenzoperationen optimiert wurden.
Die Authoren führen dabei folgende Begriffe im Verlauf des Texts ein:
/ Spine:
  Die Wirbelsäule eines Fingerbaums, sie beschreibt die Kette der zentralen Knoten, welche die sogenannten _Digits_ enthalten.
/ Digit:
  Erweiterung von 2-3-Knoten auf 1-4-Knoten, von welchen jeweils zwei in einem Wirbelknoten vorzufinden sind.
  Obwohl ein Wirbelknoten zwei Digits enthält, sind, statt dieser selbst, direkt deren 1 bis 4 Kindknoten an beiden Seiten angefügt.
  Das reduziert die Anzahl unnötiger Knoten in Abbildungen und entspricht mehr der späteren Implementierung.
  Demnach wird im Folgenden _Digits_ verwendet, um die linken und rechten direkten Kindknoten der Wirbelknoten zu beschreiben.
/ Measure:
  Wert, welcher aus den Elementen errechnet und kombiniert werden kann.
  Dient als Suchhilfe innerhalb des Baumes, durch welchen identifiziert wird, wo ein Element im Baum zu finden ist, ähnlich den Schlüssel in @fig:b-tree.
/ Safe:
  Sichere Ebenen sind Ebenen mit 2 oder 3 _Digits_, ein _Digit_ kann ohne Probleme entnommen oder hinzugefügt werden.
  Zu beachten ist dabei, dass die Sicherheit einer Ebene sich auf eine Seite bezieht, eine Ebene kann links sicher und rechts unsicher sein.
/ Unsafe:
  Unsichere Ebenen sind Ebenen mit 1 oder 4 _Digits_, ein _Digit_ zu entnehmen oder hinzuzufügen kann Über- bzw. Unterlauf verursachen (Wechsel von _Digits_ zwischen Ebenen des Baumes, um die Zweigfaktoren zu bewahren).

Der Name Fingerbäume rührt daher, dass imaginär zwei Finger an die beiden Enden der Sequenz gesetzt werden.
Diese Finger ermöglichen den schnellen Zugriff an den Enden der Sequenz.
Die zuvor definierten _Digits_ haben dabei keinen direkten Zusammenhang mit den Fingern eines Fingerbaums, trotz der etymologischen Verwandschaft beider Begriffe.
@fig:finger-tree zeigt den Aufbau eines 2-3-Fingerbaums, die in #text(blue.lighten(75%))[*blau*] eingefärbten Knoten sind Wirbelknoten, die in #text(teal.lighten(50%))[*türkis*] eingefärbten Knoten sind die _Digits_.
In #text(gray)[*grau*] eingefärbte Knoten sind interne Knoten.
Weiße Knoten sind Elemente, die Blattknoten der Teilbäume.
Knoten, welche mehr als einer Kategorie zuzuordnen sind, sind geteilt eingefärbt.

#figure(
  figures.finger-tree.repr,
  caption: [Ein 2-3-Fingerbaum der Tiefe 3 und 21 Elementen.],
) <fig:finger-tree>

Die Tiefe ergibt such bei 2-3-Fingerbäumen aus der Anzahl der zentralen Wirbel.
Jeder Wirbelknoten beschreibe eine Ebene $t$, der Baum in @fig:finger-tree hat Ebene 1 bis Ebene 3.
Aus der Tiefe der Wirbelknoten ergibt sich die Tiefe der Teilbäume (2-3-Baume) in deren _Digits_.
Die Elemente sind dabei nur in den Blattknoten vorzufinden.
In Ebene 1 sind Elemente direkt in den _Digits_ enhalten, die Teilbäume haben die Tiefe 1.
In Ebene 2 sind die Elemente in Knoten verpackt, die _Digits_ von Ebene 2 enthalten Teilbäume der Tiefe 2.
Die dritte Ebene enthält Knoten von Knoten von Elementen, sprich Teilbäume der Tiefe 3, und so weiter.
Dabei ist zu beachten, dass der letzte Wirbelknoten einen optionalen mittleren Einzelknoten enthalten kann. Dieses _Sonderdigit_ wird verwendet um die Bildung interner Ebenen zu überbrückung, da diese mindestens zwei _Digits_ enhalten müssen.
Die linken _Digits_ jedes Wirbelknoten bilden dabei den Anfang der Sequenz, während die rechten _Digits_ das Ende der Sequenz beschreiben.
Die Nummerierung der Knoten in @fig:finger-tree illustriert die Reihenfolge der Elemente.
Interne Knoten und Wirbelknoten enthalten außerdem die Suchinformationen des Unterbaums, in dessen Wurzel sie liegen.
Je nach Wahl des Typs dieser Suchinformationen kann ein 2-3-Fingerbaum als gewöhnlicher Vektor, geordnete Sequenz, _Priority-Queue_ oder Intervallbaum verwendet werden.

Durch den speziellen Aufbau von 2-3-Fingerbäumen weisen diese im Vergleich zu gewöhnlichen 2-3-Bäumen geringere asymptotische Komplexitäten für Sequenzoperationen auf.
@tbl:finger-tree-complex zeigt einen Vergleich der Komplexitäten verschiedener Operationen über $n$ Elemente.
Dabei ist zu sehen, dass _Push_- und _Pop_-Operationen auf 2-3-Fingerbäumen im _average-case_ amortisiert konstantes Zeitverhalten aufweisen, im Vergleich zu dem generell logarithmischen Zeitverhalten bei gewöhnlichen 2-3-Bäumen.
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

Ein wichtiger Bestandteil der Komplexitätsanalyse der _Push_- und _Pop_-Operationen von 2-3-Fingerbäumen ist die Suspension der Wirbelknoten durch _lazy evaluation_.

#todo[
  They argue that rebalancing is paid for by the previous cheap operations using Okasakis debit analysis.
  I'm unsure how to properly write this down without stating something incorrect, so I probably don't understand it completely yet.
  My assumption was that the rebalancing simply happens less and less often as it always creates safe layers when it happens, each time it gets deeper it creates it leaves only safe layers.
]

Die Definition von 2-3-Fingerbäumen ist in @lst:finger-tree beschrieben.
`T` sind die im Baum gespeicherten Elemente und `M` die Suchinformationen für interne Knoten.
Im Regelfall wären alle Klassendefinitionen über `T` und `M` per ```cpp template``` parametriert, darauf wurde verzichtet, um die Definition im Rahmen zu halten.

#figure(
  figures.finger-tree.def.old,
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
  ceil(k_max / 2) = k_min \
$

Die in @lst:finger-tree gegebene Definition lässt sich dadurch erweitern, das `std::array` durch `std::vector` ersetzt wird, um die wählbaren Zweigfaktoren zu ermöglichen.
Diese können ebenfalls mit ```cpp template``` Parametern zur Kompilierzeit gesetzt werden, um den Wechsel auf Vektoren zu vermeiden.
Die Definition von `Shallow` wird ebenfalls erweitert, sodass diese mehr als ein _Sonderdigit_ enthalten kann.

#figure(
  figures.finger-tree.def.new,
  caption: [Die Definition von generischen Fingerbäumen in C++.],
) <lst:gen-finger-tree>

#todo[
  A later inequality seems to imply $d_min < k_min$ as well as $k_max < d_max$, so this may be worth mentioning here once proven.
]

Da Wirbelknoten mindestens $2 d_min$ _Digits_ enthalten, muss die Bildung dieser Minimalanzahl der Elemente im letzten Wirbelknoten überbrückt werden.
Das erzielt man durch das Einhängen von _Sonderdigits_ in den letzten Wirbelknoten, bis genug für beide Seiten vorhanden sind.
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
$n_"imin"$ ist das Minimum interner Wirbelknoten.
Für die kumulativen Minima und Maxima aller Ebenen bis zur Ebene $t$ ergibt sich

$
  n'_"lmin" (t) &= n_"lmin" (t) + n'_"lmin" (t - 1) \
  n'_"imin" (t) &= n_"imin" (t) + n_"imin" (t - 1) + dots.c + n_"imin" (1) &= sum_(i = 1)^t n_"imin" (i) \
  n'_max (t) &= n_max (t) + n_max (t - 1) + dots.c + n_max (1) &= sum_(i = 1)^t n_min (i) \
$

Das wirkliche Minimum eines Baumes der Tiefe $t$ ist daher $n'_min (t) = n'_"lmin"$, da es immer einen letzten nicht internen Wirbelknoten auf Tiefe $t$ gibt.
@fig:cum-depth zeigt die Minima und Maxima von $n$ für die Baumtiefen $t in [1, 8]$ für 2-3-Fingerbäume.
Dabei zeigen die horizontalen Linien das kumulative Minimum $n'_min$ und Maximum $n'_max$ pro Ebene.

#figure(
  figures.finger-tree.ranges,
  caption: [Die möglichen Tiefen $t$ für einen 2-3-Fingerbaum mit $n$ Blattknoten.],
) <fig:cum-depth>

== Über- & Unterlaufsicherheit
Über- bzw. Unterlauf einer Ebene $t$ ist der Wechsel von _Digits_ zwischen der Ebene $t$ und der Ebene $t + 1$.
Beim Unterlauf der Ebene $t$ sind nicht genug _Digits_ in $t$ enthalten.
Es wird ein _Digit_ aus der Ebene $t + 1$ entnommen und dessen Kindknoten in $t$ gelegt.
Der Überlauf einer Ebene $t$ erfolgt, wenn in $t$ zu viele _Digits_ enthalten sind.
Es werden genug _Digits_ aus $t$ entnommen, sodass diese in einen Knoten verpackt und als _Digit_ in $t + 1$ gelegt werden können.
Das Verpacken und Entpacken der _Digits_ ist nötig, um die erwarteten Baumtiefen pro Ebene zu erhalten, sowie zur Reduzierung der Häufigkeit der Über- und Unterflüsse je tiefer der Baum wird.

#quote(block: true, attribution: [!Hinze und !Paterson @bib:hp-06])[
  We classify digits of two or three elements (which are isomorphic to elements of type Node a) as safe, and those of one or four elements as dangerous. A deque operation may only propagate to the next level from a dangerous digit, but in doing so it makes that digit safe, so that the next operation to reach that digit will not propagate. Thus, at most half of the operations descend one level, at most a quarter two levels, and so on. Consequently, in a sequence of operations, the average cost is constant.
]

#todo[
  After this quote they start talking how lazy evaluation is needed to make this work in a persistent setting.
]

Wir erweitern den Begriff der Sicherheit einer Ebene $t$ mit $d$ _Digits_ als

#let dd = $Delta d$

$
  d_min < d_t < d_max
$

Ist eine Ebene sicher, ist das Hinzufügen oder Wegnehmen eines Elements trivial.
Ist eine Ebene unsicher, kommt es beim Hinzufügen oder Wegnehmen zum Über- oder Unterlauf, Elemente müssen zwischen Ebenen gewechselt werden, um die obengenannten Ungleichungen einzuhalten.
Erneut gilt zu beachten, dass die Sicherheit einer Ebene nur für eine Seite der Ebene gilt.
Welche Seite, hängt davon ab, an welcher Seite eine Operation wie _Push_ oder _Pop_ durchgeführt wird.
Wir betrachten den Über- und Unterlauf einer unsicheren Ebene $t$ in eine oder aus einer sicheren Ebene $t + 1$.
 Über- oder Unterlauf von unsicheren Ebenen in bzw. aus unsicheren Ebenen kann rekursiv angewendet werden bis eine sichere Ebene erreicht wird.
Ähnlich den 2-3-Fingerbäumen wird durch die Umwandlung von unsicheren in sichere Ebenen dafür gesorgt, dass nur jede zweite Operation eine Ebene in dem Baum herabsteigen muss, nur jede vierte zwei Ebenen, und so weiter.
Dieses Konzept nennt sich implizite rekursive Verlangsamung (_engl._ implicit recursive slowdown) @bib:oka-98 und ist Kernbestandteil der amortisierten Komplexität _Deque_-Operationen (_Push_/_Pop_).

Damit die _Digits_ einer Ebene $t$ in eine andere Ebene $t + 1$ überlaufen können, müssen diese in einen _Digit_-Knoten der Ebene $t + 1$ passen, es gilt
$
  k_min <= dd <= k_max \
$ <eq:node-constraint>

Dabei ist $dd$ die Anzahl der _Digits_ in $t$, welche in $t + 1$ überlaufen sollen.
Essentiell ist, dass eine unsiche Ebene nach dem Überlauf wieder sicher ist, dazu muss $dd$ folgende Ungleichungen einhalten.
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

Die Zweigfaktoren $d_min$, $d_max$, $k_min$ und $k_max$ sind so zu wählen, dass Werte für $dd$ gefunden werden könne, für die die zuvorgenannten Ungleichungen halten.
Betrachten wir 2-3-Fingerbäume, gilt $d_min = 1$, $d_max = 4$, $k_min = 2$ und $k_max = 3$, daraus ergibt sich

$
  "Überlauf" &: 2 <= dd <= 3 \
  "Unterlauf" &: 1 < dd < 4 \
$

!Hinze und !Paterson entschieden sich bei Überlauf für $dd = 3$, gaben aber an, dass $dd = 2$ ebenfalls funktioniert @bib:hp-06[S. 8].
Aus den oben genannten Ungleichungen lassen sich Fingerbäume mit anderen $d$ und $k$ wählen, welche die gleichen asymptotischen Komplexitäten für _Deque_-Operationen aufweisen.
Zum Beispiel 2-4-Fingerbäume mit $d_min = 1$:
$
  2 <= dd <= 4 \
  dd < d_max \
  4 < d_max \
$

Daraus ergibt sich, dass $d_min = 1$, $d_max = 5$, $k_min = 2$ und $k_max = 4$ einen validen Fingerbaum beschreiben.

#todo[
  + Now the quesiton is if @eq:node-constraint is enough on it's own to chose $dd$, this may be related to the relation of $d$ to $k$ noted further up.
  + Below here should follow the debit analysis, or further down with more context from the push and pop operations.
]

== Push & Pop
Kernbestandteil von Fingerbäumen sind _Push_ und _Pop_ an beiden Seiten mit amortisierter Zeitkomplexität von $Theta(1)$.
Die Algorithmen @alg:finger-tree:push-left[] und @alg:finger-tree:pop-left[] beschreiben die Operationen an der linken Seite eines Fingerbaums, durch die Symmetrie von Fingerbäumen lassen sich diese auf die rechte Seite übertragen.

#let show-E = body => {
  import "/src/figures.typ": math-type
  show math.equation: it => {
    show "E": math-type
    it
  }

  body
}

#let Deep = math-type("Deep")
#let Shallow = math-type("Shallow")

#let None = math-type("None")

@alg:finger-tree:push-left ist in zwei Fälle getrennt, je nach der Art des Wirbelknotens $t$, in welchen der Knoten $e$ eingefügt werden soll.
Ist der Wirbelknoten $Shallow$, wird der Knoten $e$ direkt als linke _Digit_ angefügt, sollten dabei genug Digits vorhanden sein um einen Wirbelknoten des Typs $Deep$ zu erstellen, wird dieser erstellt, ansonsten bleibt der Fingerbaum $Shallow$.
In beiden Fällen kommt es nicht zum Überlauf.
Sollte der Wirbelknoten $Deep$ sein, wird der neue Knoten $e$ als linke _Digit_ angefügt.
Wird die maximale Anzahl der _Digits_ $d_max$ überschritten, kommt es zum Überlauf.
Beim Überlauf werden $dd$ _Digits_ in einen Knoten verpackt und in die nächste Ebene verschoben.

#[
  #show: show-E
  #figure(
    kind: "algorithm",
    supplement: [Algorithmus],
    figures.finger-tree.alg.pushl,
    caption: [Die _Push_-Operation an der linken Seite eines Fingerbaumes.],
  ) <alg:finger-tree:push-left>
]

@alg:finger-tree:pop-left ist auf ähnliche Weise wie @alg:finger-tree:push-left in zwei Fälle getrennt, $Shallow$ und $Deep$.
Ist der Wirbelknoten $Shallow$, wird lediglich ein _Digit_ von links abgetrennt und zurückgegeben.
Bei null _Digits_ wird der Wert $None$ zurückgegeben, in einer Spache wie C++ könnte das durch einen ```cpp nullptr``` oder das Werfen einer _Exception_ umgesetzt werden.
Bei einem $Deep$ Wirbelknoten wird eine linke _Digit_ entfernt.
Bleiben dabei weniger als $d_min$ _Digits_ vorhanden, erzeugt das entweder Unterlauf oder den Übergang zum $Shallow$ Fingerbaum.
Ist die nächste Ebene selbst $Shallow$ und leer, werden die linken und rechten _Digits_ zusammengenommen und diese Ebene selbst wird $Shallow$.
Ist die nächste Ebene nicht leer, wird ein Knoten entommen und dessen Kindknoten füllen die linken _Digits_ auf.

#[
  #show: show-E
  #figure(
    kind: "algorithm",
    supplement: [Algorithmus],
    figures.finger-tree.alg.popl,
    caption: [Die _Pop_-Operation an der linken Seite eines Fingerbaumes.],
  ) <alg:finger-tree:pop-left>
]

== Suche
Um ein gesuchtes Element in einem Fingerbaum zu finden, werden ähnlich wie bei B-Bäumen Hilfswerte verwendet um die richtigen Teilbäume zu finden.
In Fingerbäumen sind das die sogenannten _Measures_.
Ein Unterschied zu B-Bäumen ist, wo diese Werte vorzufinden sind.
In B-Bäumen sind direkt in den internen Knoten bei $k$ Kindknoten $k - 1$ solcher Hilfswerte zu finden, bei Fingerbäumen sind _Measures_ stattdessen einmal pro internem Knoten vorzufinden.
Desweiteren sind die _Measures_ in Fingerbäumen die Kombination der _Measures_ ihrer Kindknoten.

Um einen Fingerbaum als Vektor zu verwenden, würde als _Measure_ ein Typ gewählt, für welchen die Kombination durch Addition erfolgt.
Ein solcher _Measure_ gibt dann den Index eines Wertes an.

Für die Anwendung in T4gl werden geordnete Sequenzen benötigt, ein angebrachter _Measure_ dafür ist der Schlüsselwert und die Kombination durch die Funktion $max$, sodass der _Measure_ interner Knoten den größten Schlüssel des Subbaums angibt.
Ist der _Measure_ des Subbaums kleiner als der Suchschlüssel, so ist der Schlüssel nicht in diesem Subbaum enthalten.

#let dsearch = math-func("digit-search")

@alg:finger-tree:search zeigt, wie durch _Measures_ ein Fingerbaum durchsucht werden kann.
Dabei ist $dsearch$ Binärsuche anhand der _Measures_ über eine Sequenz von _Digits_, gefolgt von gewöhnlicher B-Baumsuche (nach @sec:b-tree) der gefundenen _Digit_.
Bevor aber $dsearch$ angewendet werden kann, muss der richtige Wirbelknoten gefundenn werden.

#todo[Add the remaining part, ensure the explanantion and algorithm are correct.]

#[
  #show: show-E
  #figure(
    kind: "algorithm",
    supplement: [Algorithmus],
    figures.finger-tree.alg.search,
    caption: [Die _Search_ Operation auf einem Fingerbaum.],
  ) <alg:finger-tree:search>
]

== Insert & Remove
Die Operationen _Insert_ und _Remove_ sind in @bib:hp-06 durch eine Kombination von _Split_, _Push_ bzw. _Pop_ und _Concat_ implementiert.
Dabei sind _Split_ und _Concat_ jeweils Operationen mit logarithmischer Zeitkomplexität $Theta(log n)$.
Obwhol in @bib:hp-06 von _Concat_ die Rede ist, handelt es sich dabei eher um eine _Merge_-Operation.
Je nach Implementierung können spezialisierte Varianten von _Insert_ und _Remove_ durch den gleichen Über-/Unterlauf Mechanismus implementiert werden, welcher bei _Push_ und _Pop_ zum Einsatz kommt.

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

= SRB-Bäume
RRB-Bäume (engl. _Relaxed Radix Balanced Trees_) sind beinahe perfekt balancierte Suchbäume, welche für Sequenzdatenstrukturen wie Vektoren verwendet werden, und wurden von !Bagwell _et al._ eingeführt @bib:br-11 @bib:brsu-15 @bib:stu-15.
Um das Element an einem bestimmten Index zu finden, wird bei perfekter Balancierung eines Knotens der Teilindex direkt errechnet.
Bei nicht perfekter Balancierung stützt sich die Suche auf Längeninformationen der Kindknoten, dazu enthält jeder interne Knoten ein Array der kummulativen Anzahlen von Werten in dessen Kindknoten.
Dabei wird nach Indizes gesucht, sprich, fortlaufende Ganzzahlwerte zwischen 0 und der Anzahl der Elemente $n$ in der Sequenz.
Im folgenden wird eine Erweiterung von RRB-Bäumen vorgestellt, SRB-Bäume (engl. _Sparse Radix Balanced Trees_), welche für nicht fortlaufende Schlüssel verwendet werden können.
Ein SRB-Baum ist aufgebaut wie ein perfekt balancierter voll belegter RRB-Baum über alle Indizes, welche vom Schlüsseltyp dargestellt werden können, aber ohne diese Knoten, welche nicht belegt sind.
Im Gegensatz zu RRB-Bäumen können Teilindizes auf jeder Ebene direkt errechnet werden, ohne dass die Länge der Kindknoten bekannt sein muss.
Da aber nicht alle Knoten besetzt sind, muss auf jeder Ebene geprüft werden, ob der errechnete Teilindex auf einen besetzten Knoten zeigt.
Durch die perfekte Balancierung ist die Baumtiefe $d$ nur von der Schlüsselbreite $b$ (die Anzahl der Bits im Schlüssel) und dem Zweigfaktor $k$ abhängig.

$
  d = log_k 2^b
$ <eq:srb-tree:depth>

@fig:srb-tree zeigt einen SRB-Baum über die Sequenz `[0, 16, 65279, 65519]` für `uint16` Schlüssel und mit einem Zweigfaktor von 16.
Die belegten Knoten sind in #text(teal.lighten(50%))[*türkis*] hervorgehoben.

#figure(
  figures.srb-tree,
  caption: [Ein SRB-Baum für die 16 bit Schlüssel und einen Zweigfaktor von 16.],
) <fig:srb-tree>

== Schlüsseltypen
Durch die spezifische Art der Suche können nur Schlüsseltypen verwendet werden, welche anhand von Radixsuche Teilindizes errechnen lassen.
Das beschränkt sich generell auf nicht vorzeichenbehaftet Ganzzahltypen.
Für diese Schlüssel $u$ ergibt sich ein Teilindex $i$ auf Ebene $t$ wie folgt:
$
  u / k^(d - t) mod k
$

Bei Zweigfaktoren $k = 2^l$ ergibt sich eine optimierte Rechnung, welche verschiedene Bitshifting Operationen verwendet:
$
  (u >> (l dot.op (d - t))) \& (k - 1)
$

Sollte für einen Schlüsseltyp $T$, eine bijektive Abbildung $f$ und deren Inverses $f^(-1)$ existieren und es gilt
$
  forall t_1, t_2 in T : t_1 < t_2 <=> f(t_1) < f(t_2)
$

dann kann durch diese Abbildungen auch der Schlüsseltyp $T$ durch einen SRB-Baum verwaltet werden.
Ein simples Beispiel sind vorzeichenbehaftete Schlüssel, welche einfach um ihr Minimum verschoben werden, so dass alle möglichen Werte vorzeichenunbehaftet sind.
Das setzt natürlich voraus, dass ein Minimum existiert, wie es bei Ganzzahlräpresentationen in den meisten Prozessoren der Fall ist.

#todo[
  Restriktion not needed by interspersing negative values as $2 abs(t) + 1$ and positive values as $2 abs(t)$.

  But if there's no minimum/maximum, then this implies a non static known bit width, at which point our guarantees go out the window.
]

== Zeitverhalten
Um zur Laufzeit den Blattknoten zu finden, in welchem sich ein Schlüssel befindet, wird pro Ebene per Radixsuche der Index dieser Ebene errechnet und geprüft ob dieser Index besetzt ist.
Ist der Index nicht besetzt, endet die Suche, ansonsten fährt diese fort, bis der Blattknoten erreicht ist.
Durch die perfekte Balancierung ist die Baumtiefe nur von der Schlüsselbreite abhängig, nicht von der Anzahl der gespeicherten Elemente.
Operationen wie _Insert_, _Remove_ oder _Search_ haben daher eine Zeitkomplexität von $Theta(d)$ mit $d$ aus @eq:srb-tree:depth.

Gerade unter Echzeitbedingungen erleichtert das die Analyse enorm, durch die Wahl von Höchstschlüsselbreiten kann SRB-Bäumen konstantes _worst-case_ Zeitverhalten für alle Operationen zugewiesen werden.

#todo[
  Elaborate on examples of this in the implementation chapter, notably we only expect integral keys of size $[8, 16, 32, 64]$ bit.
]

== Speicherauslastung
Sei $v$ der benötigte Speicher eines Werts und $p$ der benötigte Speicher eines Pointers in einem SRB-Baum.
Wir definieren die Speicherauslastung $s_U$ als das Verhältnis zwischen den belegten Speicherplätzen $s_S$ und den gesamten Speicherplätzen $s_A$, welche von der Datenstruktur angelegt wurden.

$
  s_U (p, v) = (s_S (p, v)) / (s_A (p, v)) \
$

Im Idealfall liegt $s_U$ nahe 1, sprich 100%.
Die in @fig:srb-tree gegebene SRB-Baum verbraucht pro Blattknoten $16 s_v$ Speicherplatz, ungeachtet der Belegung.
Interne Knoten benötigen $16 s_p$ Speicherplatz.
Bei ungünstiger Belegung, zum Beispiel einem Element pro möglichem Blattknoten, ergibt sich ein Speicherplatzverbrauch von $16^4 s_v + 16^3 s_p + 16^2 s_p + 16 s_p$ bei nur $16^3$ belegten Elementen.
Bei Pointern mit $p = 8 "byte"$ und Pointern als Werten ($v = p$) folgt eine Speicherauslastung von

$
  s_U (p, v) &= (16^3 v) / (16^4 v + 16^3 p + 16^2 p + 16 p) \
  &= 0.058... \
  &approx 6% \
$

Dabei sind Verwaltungsstrukturen ignoriert, welche die Belegung der Elemente enthalten, da diese verhältnismäßig klein sind.
Für einen SRB-Baum mit einem Zweigfaktor $k$ und einer Schlüsselbreite $b$ und der sich daraus ergebenden Baumtiefe $d = ceil(log_k 2^b)$, ergibt sich eine Speicherauslastung im _worst-case_ von:

$
  s_U (p, v) = (k^(d - 1) v) / (k^d v + sum_(n = 1)^(d - 1) k^n p)
$

#todo[
  It remains to be seen, whether this is actually a problem.

  Perhaps nodes can be interned in some way, to reduce duplication.
  This could be beneficial especially for smaller branching factors.
]
