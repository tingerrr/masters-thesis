#import "/src/util.typ": *
#import "/src/figures.typ"

= Motivation
In der Automobilindustrie gibt es verschiedene Systeme, welche die Automation von Prüfständen erleichtern oder gar ganz übernehmen.
Eines dieser Systeme ist T4gl, eine Programmiersprache und gleichnamiges Laufzeitsystem zur Interpretation von Testskripten in Reifenprüfständen.
Bei diesen Reifenprüfständen werden verschiedene Tests und Messvorgänge durchgeführt, welche bestimmte Zeitanforderungen aufweisen.
Können diese Zeitanforderungen nicht eingehalten werden, müssen Testvorgänge verworfen und wiederholt werden.
Daher ist es essentiell, dass das T4gl-Laufzeitsystem in der Lage ist die erwarteten Testvorgänge innerhalb einer festgelgeten Zeit abzuarbeiten, ungeachtet der anfallenden Testdatenmengen.
T4gl is eine Hochlevel-Programmiersprache, Speicherverwaltung oder Synchronization werden vom Laufzeitsystem übernommen und müssen in den meisten Fällen nicht vom Programmierer beachtet werden.
Wie in fast allen Hochlevel-Programmiersprachen, gibt es in T4gl dynamische Datenstrukturen zur Verwaltung von mehreren Elementen.
Diese werden in T4gl als Arrays bezeichnet und bieten eine generische Datenstruktur für Sequenzen, Tabellen, _ND-Arrays_ oder _Queues_.
Intern wird die gleiche Datenstruktur für alle Anwendungsfälle verwendet, in welchen ein T4gl-Programmierer eine dynamische Datenstruktur benötigt, ungeachtet der individuellen Anforderungen.
Aus der Interaktion verschiedener Features des Laufzeitsystems und der Standardbibliothek der Programmiersprache kommt es, zusätzlich dazu, zu unnötig häufigen Kopien von Daten.
Schlimmer noch, durch die jetzige Implementierung wächst die Länge von Kopiervorgängen der T4gl-Arrays proportional zur Anzahl der darin verwalteten Elemente.
Bei diese Kopien kann es sich um T4gl-Arrays mit fünfzig Elementen oder T4gl-Arrays mit fünfmillionen Elementen handeln.
Durch diese unzureichende Flexibilität bei der Wahl der Datenstruktur ist es dem T4gl-Programmierer nicht möglich die Nutzung der Datenstruktur hinreichend auf die jeweiligen Anwendungsfälle zu optimieren.
Das Laufzeitsystem kann die gestellten Zeitanforderungen nicht garantiert einhalten, da die Anzahl der Elemente in T4gl-Arrays erst zur Laufzeit bekannt ist.

Das Endziel dieser Arbeit ist die Verbesserung der Latenzen des T4gl-Laufzeitsystems durch Analyse und gezielte Verbesserung der Datenverwaltung von T4gl-Arrays.
Dabei werden verschiedene Lösungsansätze evaluiert, teilweise implementiert, getestet und verglichen.

= Struktur
@chap:t4gl beschreibt T4gl und dessen Komponenten genauer, sowie die Implementierung der T4gl-Arrays.
Darin wird erarbeitet, wie es zu den meist unnötigen Kopiervorgängen kommt und in welchen Fällen diese auftreten.
In @chap:non-solutions werden verschiedene Veränderungen an der Programmiersprache selbst erörtert und warum diese unzureichend oder anderweitig unerwünscht sind.
Dazu zählen verschiedene neue syntaktische Konstrukte zur statischen Analyse oder optimierten Implementierung, sowie die Einführung neuer Semantik existierenden Syntax's.
@chap:persistence fürt den Begriff der Persistenz im Sinne von Datenstrukuren ein und befasst sich mit verschiedenen Datenstrukuren, durch welche die zeitliche Komplexität von Kopien der T4gl-Arrays reduziert werden kann.
Im Anschluss werden in @chap:impl implementierungspezifische Optimierungen beschreiben.
Die daraus folgenden Implementierungen werden in @chap:benchmarks getestet und verglichen.
Zu guter Letzt wird in @chap:conclusion das Resultat der Arbeit evaluiert und weiterführende Arbeit beschrieben.

= Begrifflichkeiten
Im Verlauf dieser Arbeit wird oft von Zeit- und Speicherkomplexität gesprochen.
Komplexitätstheorie befasst sich mit der Komplexität von Algorithmen und algorithmischen Problemen, vor allem in Bezug auf Speicherverbrauch und Bearbeitungszeit.
Dabei sind folgende Begriffe relevant:

/ Zeitkomplexität:
  Zeitverhalten eines Algorithmus über eine Menge von Daten in Bezug auf die Anzahl dieser @bib:clrs-09[S. 44].
/ Speicherkomplexität:
  Der Speicherbedarf eines Algorithmus zur Bewältigung eines Problems @bib:clrs-09[S. 44].
  Wird auch für den Speicherbedarf von Datenstrukturen verwendet.
/ Amortisierte Komplexität:
  Unter Bezug einer Sequenz von $n$ Operationen mit einer Dauer von $T(n)$, gibt die amortisierte Komplexität den Durchschnitt $T(n)\/n$ einer einzigen Operation an @bib:clrs-09[S. 451].

#todo[If necessary add a glossary and refer to it here.]

= Legende & Konventionen
Die folgenden Konventionen und Notationen werden während der Arbeit verwendet.
Sollten bestimmte Teile der Arbeit diesen Konventionen nicht folgen, sind diese Abweichungen im umliegenden Text beschrieben.

== Grafiken
@tbl:legend beschreibt die Konventionen für Grafiken, vor allem Grafiken zu Baum- oder Listenstrukturen.
Diese Konventionen sollen vorallem Konzepte der Persistenz vereinfachen.

#let fdiag = fletcher.diagram.with(node-stroke: 0.075em)
#let node = fletcher.node.with((0, 0), `n`)

#figure(
  table(columns: 2, align: (x, y) => horizon + if x == 1 { left },
    table.header[Umrandung][Beschreibung],
    fdiag(node(stroke: green)), [
      Geteilte Knoten, d.h. Knoten welche mehr als einen Referenten haben.
    ],
    fdiag(node(stroke: red)), [
      Kopierte (nicht geteilte) Knoten, d.h. Knoten welche durch eine Operation kopiert wurden statt geteilt zu werden, z.B. durch _path copying_.
    ],
    fdiag(node(stroke: (paint: gray, dash: "dashed"))), [
      Visuelle Orientierungshilfe für folgende Abbildungen, kann hypothetischen oder gelöschten Knoten darstellen.
      Die genaue bedeutung ist im Umliegenden text beschrieben.
    ],
    fdiag(node(extrude: (-2, 0))), [
      Instanzknoten, d.h. Knoten, welche nur Verwaltungsinformationen enthalten, wie die Instanz eines `std::vector`.
    ],
  ),
  caption: [Legende der Konventionen in Datenstrukturgrafiken.],
) <tbl:legend>

== Notation
#todo[This is too elaborate and needs to be slimmed down to the bare minimum.]

!Landau-Symbole umfassen Symbole zur Klassifizierung der asymptotischen Komplexität von Funktionen und Algorithmen.
Im folgenden werden Variationen der !Knuth'schen Definitionen verwendet @bib:knu-76[S. 19] @bib:clrs-09[S. 44-48], sprich:

$
  O(f) &= {
    g : NN -> NN | exists n_0, c > 0
    quad &&forall n >= n_0
    quad 0 <= g(n) <= c f(n)
  } \
  Omega(f) &= {
    g : NN -> NN | exists n_0, c > 0
    quad &&forall n >= n_0
    quad 0 <= c f(n) <= g(n)
  } \
  Theta(f) &= {
    g : NN -> NN | exists n_0, c_1, c_2 > 0
    quad &&forall n >= n_0
    quad c_1 f(n) <= g(n) <= c_2 f(n)
  }
$ <eq:big-o>

Bei der Verwendung von !Landau-Symbolen steht die Variable $n$ für die Größe der Daten welche für die Laufzeit eines Algorithmus relevant sind.
Bei Operationen auf Datenstrukturen entspricht die Größe der Anzahl der verwalteten Elemente in der Struktur.

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


$O(f)$ beschreibt die Menge der Funktionen, welche die _obere_ asymptotische Grenze $f$ haben.
Gleichermaßen gibt $Omega(f)$ die Menge der Funktionen an welche die _untere_ asymptotische Grenze $f$ haben.
$Theta(f)$ ist die Schnittmenge aus $O(f)$ und $Omega(f)$ @bib:clrs-09[S. 48, Theorem 3.1].
Trotz der Definition der Symbole in @eq:big-o als Mengen, schreibt man oft $g(n) = O(f(n))$, statt $g(n) in O(f(n))$ @bib:knu-76[S. 20].
Im folgenden wird sich an diese Konvention gehalten.
@tbl:landau zeigt verschiedene Komplexitäten in aufsteigender Ordnung der Funktion $f(n)$, dabei steht $alpha$ für ein Symbol aus @eq:big-o.
Unter Betrachtung der asymptotischen Komplexität werden konstante Faktoren und Terme geringerer Ordnung generell ignoriert, sprich $g(n) = 2n^2 + n = O(n^2)$.

