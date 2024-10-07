#import "@local/chiral-thesis-fhe:0.1.0" as ctf
#import ctf.prelude: *

#import "/src/figures.typ"
#import "/src/util.typ"

#show: poster(
  kind: masters-thesis(
    id: [AI-2024-MA-005],
    title: [Dynamische Datenstrukturen unter Echtzeitbedingungen],
    author: "B. Sc. Erik Bünnig",
    supervisors: (
      "Prof. Dr. Kay Gürtzig",
      "Dipl-Ing. Peter Brückner",
    ),
    date: datetime(year: 2024, month: 10, day: 09),
    field: [Angewandte Informatik],
  ),
  cv: [
    #set text(42pt)
    - Mechatronikerausbildung --- SAMAG GmbH Saalfeld
    - Technische Fachhochschulreife --- FOS Rudolstadt
    - B. Sc. Angewandte Informatik --- FH Erfurt
  ],
)

#set text(size: 48pt, lang: "de")
#set par(justify: true)

#show figure.caption: set text(style: "italic", fill: gray)
#show figure.caption: set align(left)

#show: block.with(height: 82.5%)

#show: columns.with(3)

Die Verwendung dynamischer Datenstrukturen unter Echtzeitbedingungen muss genau geprüft werden, um sicher zustellen, dass ein Echtzeitsystem dessen vorgegebene Aufgaben in der erwarteten Zeit erfüllen kann.
Ein solches Echtzeitsystem ist das Laufzeitsystem der T4gl-Progrmmiersprache, eine Domänenspezifische Sprache für Industrieprüfmaschinen.
Die in T4gl verwendeten Datenstrukturen sorgen vorallem durch deren nicht-granulare Persistenz für hohe Latenzen durch auffwendige Kopievorgänge.
In dieser Arbeit wird untersucht, auf welche Weise die in T4gl verwendeten Datenstrukturen optimiert oder ausgetauscht werden können, um das Zeitverhalten im Worst Case zu verbessern.
Dabei werden vorallem granular-persistente Datenstrukturen implementiert, getestet und verglichen.

Bei persistenten Datenstrukturen handelt es sich um Datenstrukturen, welche bei Schreibzugriffen Kopien anfertigen, statt direkt in den Speicher der bestehenden Daten zu schreiben.
Viele moderne Standardbibliotheken bieten solche Datenstrukturen unter dem Begriff _Immutable Collections_ an.
Dadurch, dass nie in die bestehenden Daten geschrieben wird, können mehrere Instanzen Daten untereinander teilen, ohne das diese Datenteilung sichtbar ist.
Gerade bei Baumstrukturen kann durch Persistenz der Knoten Datenteilung trotz Schreibfähigkeit effizient umgesetzt werden. (Siehe @fig:new und @fig:shared[])

#figure(
  placement: auto,
  figures.tree.new,
  caption: [An einen persistenten Baum `t` wird ein Knoten `X` angefügt.],
) <fig:new>

#figure(
  placement: auto,
  figures.tree.shared,
  caption: [
    Das Anfügen von `X` erzeugt einen neuen Baum `u`, welcher mit `t` Daten teilt.
  ],
) <fig:shared>

Die in T4gl verwendeten Datenstrukturen setzten nur sehr grobe Persistenz um, sodass bei einem Schreibzugriff alle Daten kopiert werden.
Durch die Verwendung baumbasierter persistenter Datenstrukturen können die Kopiervorgänge dieser Datenstrukturen von linearer Zeitkomplexität $Theta(n)$, auf logarithmische Zeitkomplexität $Theta(log n)$ gesengt werden.

Im übrigen befasst sich die Arbeit mit verschiedenen exisitierenden granular-persistenten Datenstrukturen, deren Optimierung und wie diese in T4gl implementiert werden können.
