#import "util.typ": *

#let dd = $Delta d$

#let Maybe = math-type("Maybe")

#let Node = math-type("Node")
#let Deep = math-type("Deep")
#let Shallow = math-type("Shallow")
#let FingerTree = math-type("FingerTree")

#let popl = math-func("pop-left")
#let pushl = math-func("push-left")
#let concat = math-func("concat")
#let split = math-func("split")

#let ftpushl = math-func("ftree-push-left")
#let ftpopl = math-func("ftree-pop-left")

#let finger-tree-alg-push-left = algorithm(
  numbered-title: $ftpushl(e, t): (E, FingerTree E) -> FingerTree E$
)[
  + *switch* $t$
    + *case* $t$ *is* $Shallow$
      + *let* $"values" = pushl(e, t."values")$
      + *if* $|"values"| < 2 d_min$
        + *return* $Shallow("values")$
      + *let* $"left", "right" = split("values", d_min)$
      + *return* $Deep("left", Shallow(nothing), "right")$
    + *case* $t$ *is* $Deep$
      + *let* $"left" = pushl(e, t."left")$
      + *if* $|"left"| <= d_max$
        + *return* $Deep("left", t."middle", t."right")$
      + *let* $"rest", "overflow" = split("left", |"left"| - dd)$
      + *let* $"middle" = ftpushl(Node("overflow"), t."middle")$
      + *return* $Deep("rest", "middle", t."right")$
]

// BUG: this should break nicely with 0.12
#let finger-tree-alg-pop-left = algorithm(
  numbered-title: par(justify: false)[$ftpopl(t): FingerTree E -> (Maybe E, FingerTree E)$]
)[
  + *switch* $t$
    + *case* $t$ *is* $Shallow$
      + *let* $e, "rest" = popl(t."values")$
      + *return* $(e, Shallow("rest"))$
    + *case* $t$ *is* $Deep$
      + *let* $e, "rest" = popl(t."left")$
      + *if* $|"rest"| >= d_min$
        + *return* $(e, Deep("rest", t."middle", t."right"))$
      + *if* $t."middle"$ *is* $Shallow$ *and* $|t."middle"."values"| = 0$
        + *return* $(e, Shallow(concat(t."left", t."right")))$
      + *let* $"node", "mrest" = ftpopl(t."middle")$
      + *return* $(e, Deep(concat("rest", "node"."values"), "mrest", t."right"))$
]
