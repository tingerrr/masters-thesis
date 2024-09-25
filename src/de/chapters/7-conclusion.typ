#import "/src/util.typ": *
#import "/src/figures.typ"

= Ergebnis
#todo[
  It seems the curent implementation of finger trees is horrendously slow and prematurely optimized, the control-implementation of b-trees performas much better and only one order of magnitude worse then q-map without the presence of clones.
]

= Weitere Arbeit
== Lazy-Evaluation
Das Aufschieben von Operationen druch _lazy evaluation_ hat einen direkten Einfluss auf die amortisierten Komplexitäten der _Deque_-Operationen @bib:hp-06[S. 7].
Da für die Echzeitanalyse der Datenstruktur nur die _worst-case_ Komplexitäten relevant sind, wurde diese allderings vernachlässigt.

Zur generellen Verbersserung der durschnittlichen Komplexitäten der Implementierung ist die Verwendung von _lazy evaluation_ unabdingbar.

== Generalisierung & Cache-Effizienz
#todo[
  move this forward to the generalize section.
]
Die _Cache_ eines CPU ist ein kleiner Speicher, zwischen CPU und RAM, welcher generell schneller zu lesen und schreiben ist.
Ist ein Wert nicht in der CPU-_Cache_, wird in den meisten Fällen beim Lesen einer Addresse im RAM der umliegende Speicher mit in die _Cache_ gelesen.
Das ist einer der Gründe warum Arrays als besonders schnelle Datenstrukturen gelten, wiederholte Lese- und Schreibzugriffe im gleichen Speicherbereich können häufig auf die _Cache_ zurückgreifen.
In Präsenz von Indirektion, also der Verwendung von Pointern wie bei Baumstrukturen können Lese- und Schreibzugriffen in den Speicher öfter auf Bereiche zeigen, welche nicht in der _Cache_ liegen, dabei spricht man von einem _Cache-Miss_.

@sec:finger-tree:generic beschreibt einen Versuch die _Cache_-Effizienz von 2-3-Fingerbäumen zu erhöhen, in dem durch höhere Zweigfakotren die Tiefe der Bäume reduziert werden soll.
Durch die geringere Tiefe sollen die rekursiven Algorithmen welche den Baumknoten folgen weniger oft _Cache-Misses_ verursachen.

Für verschiedene Teile der generalisierten Zweigfaktoren von Fingerbäumen konnten keine Beweise vorgelegt werden.
Es wurden allerdings auch keine Beweise gefunden oder erarbeitet welche die generalisierung auf höhere Zweigfaktoren gänzlich ausschließen.
Je nach Stand der Beweise könnten generalisierte Varianten von Fingerbäumen in Zukunft in T4gl eingesetzt werden.
Unklar ist, ob der Aufwand der Generalisierung sich mit der verbesserten _Cache-Effizienz_ aufwiegen lässt.

Die schlechten Ergebnisse der 2-3-Fingerbaum lassen sich nicht direkt auf die Generalisierung schließen, sondern scheinen eher direkte Folge der Implementierung zu sein, da die in @bib:hp-06[S. 20] gegebenen Benchmarks exzellente Performance vorweisen.
Dabei ist allerdings unklar, wie stark der Einfluss von _lazy evaluation_ in Haskell sich auf die Ergebnisse der Benchmarks auswirkt.


== Vererbung & Virtual Dispatch
Wird eine Klasse in C++ vererbt, und besitzt Methoden, welche überschreibbar sind, gilt diese als _virtuell_.
Hat eine vererbare Klasse eine Methode ohne eine Implementierung, gilt diese als _abstrakt_.
Abstrakten Methoden (diese ohne Implementierung) müssen bei ihrem Aufruf zur Laufzeit zunächst die richtige Implementierung der Methode finden.
Das erfolgt durch einen sogenannten _virtual table_, auf welchen jede abstrakte Klasse und deren vererbende Klassen verweisen.
Dabei werden für den CPU wichtige Optimierung erschwert, wie _branch-prediction_, _instruction caching_ oder _instruction prefetching_.

Die in @lst:finger-tree gegebene Definition verwendet Vererbung der Klasse `FingerTree`zur Darstellung der verschiedenen Varianten.
Daraus folgt das Fingerbäume nicht mehr direkt verwendet werden können, eine `FingerTree`-Instanz selbst ist nutzlos ohne die Felder und Implementierung der vererbenden Varianten.
Instanzen von `FingerTree` müssen durch Indirektion übergeben werden, da diese generell auf deren vererbenden Varianten verweisen.
Die Operationen auf den verschiedenen Varianten von `FingerTree` müssten entweder durch vorsichtiges _casten_ der Pointer oder durch einheitliche API anhand abstrakter Methoden erfolgen.
Ersteres ist unergonomisch und Fehlerbehaftet, `FingerTree` wird zwangsläufig zur abstrakten Klasse, daraus folgt,
- dass für abstrakte Methoden _virtual dispatch_ verwendet werden muss
- und dass jeder Zurgriff auf einen `FingerTree` zunächst die Indirektion auflösen muss (Pointerdereferenzierung).

Um zu vermeiden, dass jeder Aufruf essentieller Funktionen wie `pop` und `pop` auf _virtual dispatch_ zurückgreifen muss, können statt abstrakten Methoden durch gezieltes _casten_ auf die korrekte vererbenden Variante dire korrekte Implementierung ausgeführt werden.
Die Auswahl der Klasse kann durch das mitführen eines Diskriminators erfolgen welcher angibt auf welche Variante verwiesen wird.
Damit wird sowhol die Existenz des _virtual table_ Pointers in allen Instanzen, sowie auch die doppelte Indirektion dadurch vermieden.
Besonders häufige Pfade wie die der `Deep`-Variante können dem CPU als heiß vorgeschlagen werden, um diese bei der _branch-prediction_ zu bevorzugen.

== Memory-Layout
Bei C++ hat jeder Datentyp für den Speicher zwei relevante Metriken, dessen Größe und dessen Alignment.
Das Alignment eines Datentyps gibt an, auf welchen Adressen im Speicher ein Wert gelegt werden darf.
Ist das Alignment eines Typs `T` 8, kann dieser nur auf die Addressen gelegt werden, welche Vielfache von 8 sind, also `0x0`, `0x8`, `0x10`, `0x18` und so weiter.
Da komplexe Datentypen aus anderen Datentypen bestehen, müssen auch diese im Speicher korrekt angelegt werden, deren Alignment wirkt sich auf das des komplexen Datentyps aus.
Desweiteren werden Felder in Deklarationreihenfolge angelegt.
Damit die Alignments der einzelnen Feldertypen eingehalten werden, werden wennnötig vom Compiler unbenutze Bytes zwischen Feldern eingefügt, das nennt sich Padding.
Durch klevere sortierung der Felder können Paddingbytes durch kleinere Felder gefüllt werden.
Padding zu reduzieren, reduziert die Größe des komplexen Datentyps.
Reduziert man die Größe des Datentyps, erhöht man die Anzahl der Elemente, welche vom CPU in dessen Cache geladen werden können.

== Spezialisierte Allokatoren
Eine mögliche Darstellung von Graphen ist es, Knoten in Arrays zu speichern und deren Verbindungen in Adjazenzlisten zu speichern.
Dadurch können mehr Knoten in die CPU-Cache geladen werden als durch rekursive Definitionen.
Da Bäume lediglich Sonderformen von Graphen sind kann das auch auf die meisten Baumdatenstrukturen angewendet werden.
Das bedeutet aber auch das alle Knoten kopiert werden müssten welche von einem Graph erwaltet werden wenn dieser kopiert wird.
Das steht gegen das Konzept der Pfadkopie in persistenten Bäumen.

Eine Alternative, welche die KNoten eines Baumes nah bei einander im Speicher anelgen könnten ohne die Struktur der Bäume zu zerstören sind Allokatoren welche einen kleinen Speicherbereich für die Knoten der Bäume verwalten.
Somit könnte die Cache-Effizienz von 2-3-Fingerbäumen erhöht werden ohne besonders große Änderungen an deren Implementierung vorzunehmen.

== Unsichtbare Persistenz <sec:invis-pers>
Da die Persistenz von 2-3-Fingerbäumen durch die API der Klassen versteckt wird können diese auch auf Persistenz verzichten, wenn es sich nicht auf andere Instanzen auswirken kann.
Wenn eine Instanz des Typs `T` der einzige Referent auf die in `_repr` verwiesene Instanz ist kann diese Problemlos direkt in diese Instanz schreiben ohne vorher eine Kopie anzufertigen.
Das ist das Kernprinzip von vielen Datenstrukuren, welche auf CoW-Persisten basieren.
Dazu gehören auch die Qt-Datenstrukturen, welche ursprünglich in T4gl zu Einsatz kamen.

Das hat allerdings einen Einfluss auf die Art auf welche eine solche Klasse verwendet werden kann.
Wird eine Instanz `t1` angelegt und eine reference `&t1` wird an einen anderen Thread übergeben kann zwischen dem Abgleich von `_repr.use_count() == 1` und der direkten Beschreibung der Instanz in `_repr` eine Kopie von `t1` auf dem anderen Thread angelget werden.
Das hat zur Folge das der Schreibzugriff in beiden Instanzen `t1` und `t2` sichtbar wird, obwohl der Schreibzugriff nach der Kopie von `t1` stattfand.
Um diese Einzigartikgeit auszunutzen, dürfen keine Referenzen oder Pointer zu Instanzen von `T` an andere Threads gesendet werden
Stattdessen sollten diese auf einem Thread kopiert werden bevor sie an einen anderen Thread gesendet werden.
