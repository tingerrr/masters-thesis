#import "util.typ": *

#let dd = $Delta d$

#let Maybe = math-type("Maybe")
#let None = math-type("None")

#let Node = math-type("Node")
#let Deep = math-type("Deep")
#let Measure = math-type("Measure")
#let Shallow = math-type("Shallow")
#let FingerTree = math-type("FingerTree")

#let isempty = math-func("is-empty")

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
  + *else*
    + *let* $"left" = pushl(e, t."left")$
    + *if* $abs("left") <= d_max$
      + *return* $Deep("left", t."middle", t."right")$
    + *let* $"rest", "overflow" = split("left", abs("left") - dd)$
    + *let* $"middle" = ftpushl(Node("overflow"), t."middle")$
    + *return* $Deep("rest", Shallow("middle"), t."right")$
]

#let ftpopl = math-func("ftree-pop-left")

#let finger-tree-alg-pop-left = algorithm(
  numbered-title: $ftpopl(t): FingerTree -> (Node, FingerTree)$,
)[
  + *if* $t$ *is* $Shallow$
    + *if* $abs(t."values") = 0$
      + *return* $(None, t)$
    + *else*
      + *let* $e, "rest" = popl(t."values")$
      + *return* $(e, Shallow("rest"))$
  + *else*
    + *let* $e, "rest"_l = popl(t."left")$
    + *if* $abs("rest") >= d_min$
      + *return* $(e, Deep("rest", t."middle", t."right"))$
    + *if not* $isempty(t."middle")$
      + *return* $(e, Shallow(concat(t."left", t."right")))$
    + *else*
      + *let* $"node", "rest"_m = ftpopl(t."middle")$
      + *return* $(e, Deep(concat("rest"_l, "node"."values"), "rest"_m, t."right"))$
]

#let ftsearch = math-func("ftree-search")

#let finger-tree-alg-search = algorithm(
  numbered-title: $ftsearch(t, m): (FingerTree, Measure) -> Node$,
)[
  + *if* $t$ *is* $Shallow$
    + *return* $dsearch(t."values", m)$
  + *else*
    + *let* $m_l = last(t."left")."measure"$
    + *let* $m_m = t."middle"."measure"$
    + *let* $m_r = last(t."right")."measure"$
    + *if* $n <= m_l$
      + *return* $dsearch(t."left", m)$
    + *if* $m_l < m <= m_m$
      + *return* $ftsearch(t."middle", m)$
    + *if* $m_m < m <= m_r$
      + *return* $dsearch(t."right", m)$
    + *else*
      + *return* $None$
]
