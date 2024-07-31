#import "util.typ": *

#let dd = $Delta d$

#let Maybe = math-type("Maybe")
#let Some = math-type("Some")
#let None = math-type("None")

#let Node = math-type("Node")
#let Deep = math-type("Deep")
#let Measure = math-type("Measure")
#let Shallow = math-type("Shallow")
#let FingerTree = math-type("FingerTree")

#let popl = math-func("pop-left")
#let pushl = math-func("push-left")
#let concat = math-func("concat")
#let split = math-func("split")
#let last = math-func("last")
#let dsearch = math-func("digit-search")
#let measure = math-func("measure")

#let ftpushl = math-func("ftree-push-left")

#let finger-tree-alg-push-left = algorithm(
  numbered-title: $ftpushl(e, t): (Node, FingerTree) -> FingerTree$,
)[
  + *if* $t$ *is* $Shallow$
    + *let* $"values" = pushl(e, t."values")$
    + *if* $|"values"| < 2 d_min$
      + *return* $Shallow("values")$
    + *let* $"left", "right" = split("values", d_min)$
    + *return* $Deep("left", Shallow(nothing), "right")$
  + *if* $t$ *is* $Deep$
    + *let* $"left" = pushl(e, t."left")$
    + *if* $abs("left") <= d_max$
      + *return* $Deep("left", t."middle", t."right")$
    + *let* $"rest", "overflow" = split("left", abs("left") - dd)$
    + *let* $"middle" = ftpushl(Node("overflow"), t."middle")$
    + *return* $Deep("rest", "middle", t."right")$
]

#let ftpopl = math-func("ftree-pop-left")

// BUG: this should break nicely with 0.12
#let finger-tree-alg-pop-left = algorithm(
  numbered-title: $ftpopl(t): FingerTree -> (Maybe Node, FingerTree)$,
)[
  + *if* $t$ *is* $Shallow$
    + *if* $abs(t."values") = 0$
      + *return* $(None, t)$
    + *let* $e, "rest" = popl(t."values")$
    + *return* $(Some(e), Shallow("rest"))$
  + *if* $t$ *is* $Deep$
    + *let* $e, "rest" = popl(t."left")$
    + *if* $abs("rest") >= d_min$
      + *return* $(Some(e), Deep("rest", t."middle", t."right"))$
    + *if* $t."middle"$ *is* $Shallow$ *and* $abs(t."middle"."values") = 0$
      + *return* $(e, Shallow(concat(t."left", t."right")))$
    + *let* $"node", "mrest" = ftpopl(t."middle")$
    + *return* $(Some(e), Deep(concat("rest", "node"."values"), "mrest", t."right"))$
]

#let ftsearch = math-func("ftree-search")

#let finger-tree-alg-search = algorithm(
  numbered-title: $ftsearch(t, m): (FingerTree, Measure) -> Maybe Node$,
)[
  + *if* $t$ *is* $Shallow$
    + *return* $dsearch(t."values")$
  + *if* $t$ *is* $Deep$
    + *if* $t."measure" > m$
      + *return* $None$
    + *let* $m_"left" = last(t."left")."measure"$
    + *let* $m_"deep" = t."deep"."measure"$
    + *let* $m_"right" = last(t."right")."measure"$
    + *if* $m_"left" < m <= m_"deep"$
      + *return* $dsearch(t."left")$
    + *if* $m_"deep" < m <= m_"right"$
      + *return* $dsearch(t."right")$
    + *return* $ftsearch(t."middle", m)$
]
