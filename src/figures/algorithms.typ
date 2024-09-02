#import "util.typ": *

#let comment(body) = text(gray, {
  h(1fr)
  sym.triangle.r
  [ ]
  body
})

#let dd = $Delta d$

#let None = math-type("None")
#let Predicate = math-type("Predicate")

#let Node = math-type("Node")
#let Deep = math-type("Deep")
#let Measure = math-type("Measure")
#let Shallow = math-type("Shallow")
#let FingerTree = math-type("FingerTree")

#let popl = math-func("pop-left")
#let pushl = math-func("push-left")
#let popr = math-func("pop-right")
#let pushr = math-func("push-right")
#let concat = math-func("concat")
#let split = math-func("split")
#let last = math-func("last")
#let rev = math-func("rev")

#let dsearch = math-func("digit-search")
#let dsplit = math-func("digit-split")

#let pnodes = math-func("pack-nodes")

#let ftpushl = math-func("ftree-push-left")
#let ftpushr = math-func("ftree-push-right")
#let ftpopl = math-func("ftree-pop-left")
#let ftpopr = math-func("ftree-pop-right")
#let ftsearch = math-func("ftree-search")
#let ftsplit = math-func("ftree-split")
#let ftinsert = math-func("ftree-insert")
#let ftconcat = math-func("ftree-concat")
#let ftremove = math-func("ftree-remove")


#let finger-tree-alg-push-left = algorithm(
  numbered-title: $ftpushl(e, t): (Node, FingerTree) -> FingerTree$,
)[
  + *if* $t$ *is* $Shallow$
    + *let* $"children" = pushl(e, t."children")$
    + *if* $|"children"| < 2 d_min$
      #comment[no overflow]
      + *return* $Shallow("children")$
    + *let* $"left", "right" = split("children", d_min)$
      #comment[overflow by left+right split]
    + *return* $Deep("left", Shallow(nothing), "right")$
  + *else*
    + *let* $"left" = pushl(e, t."left")$
    + *if* $abs("left") <= d_max$
      #comment[no overflow]
      + *return* $Deep("left", t."middle", t."right")$
    + *let* $"rest", "overflow" = split("left", abs("left") - dd)$
      #comment[overflow by descent]
    + *let* $"middle" = ftpushl(Node("overflow"), t."middle")$
    + *return* $Deep("rest", "middle", t."right")$
]

#let finger-tree-alg-pop-left = algorithm(
  numbered-title: $ftpopl(t): FingerTree -> (Node, FingerTree)$,
)[
  + *if* $t$ *is* $Shallow$
    + *if* $abs(t."children") = 0$
      + *return* $(None, t)$
    + *else*
      + *let* $e, "rest" = popl(t."children")$
      + *return* $(e, Shallow("rest"))$
  + *else*
    + *let* $e, "rest"_l = popl(t."left")$
    + *if* $abs("rest") >= d_min$
      #comment[no underflow]
      + *return* $(e, Deep("rest", t."middle", t."right"))$
    + *if* $abs(t."middle") = 0$
      #comment[underflow by left+right merge]
      + *return* $(e, Shallow(concat(t."left", t."right")))$
    + *else*
      #comment[underflow by descent]
      + *let* $"node", "rest"_m = ftpopl(t."middle")$
      + *return* $(e, Deep(concat("rest"_l, "node"."children"), "rest"_m, t."right"))$
]

#let finger-tree-alg-search = algorithm(
  numbered-title: $ftsearch(t, m): (FingerTree, Measure) -> Node$,
)[
  + *if* $t$ *is* $Shallow$
    + *if* $m <= t."measure"$
      + *return* $dsearch(t."children", m)$
    + *else*
      #comment[measure not in this subtree]
      + *return* $None$
  + *else*
    #comment[find suitable branch to descend]
    + *if* $m <= t."left"."measure"$
      + *return* $dsearch(t."left", m)$
    + *if* $m <= t."middle"."measure"$
      + *return* $ftsearch(t."middle", m)$
    + *if* $m <= t."right"."measure"$
      + *return* $dsearch(t."right", m)$
    + *else*
      #comment[measure not in this subtree]
      + *return* $None$
]

#let finger-tree-alg-nodes = algorithm(
  numbered-title: $pnodes(n) : [Node] -> [Node]$,
)[
  + *if* $abs(n) < k_min$
    #comment[can't form a single node]
    + *return*  $None$
  + *else*
    + *let* $n' := nothing$
    + *while* $abs(n) eq.not 0$
      // TODO: chose split such that we can always fit the remainder into nodes,
      // if this is even possible, it definitly works for 2..3, but does it
      // always work for floor(k / 2)..k?
      + *let* $k, "rest" = split(k, ...)$
      + $n = "rest"$
      + $n' = pushr(n', Node(k))$
        #comment[pack nodes into nodes]
    + *return* $n'$
]

#let finger-tree-alg-concat = algorithm(
  numbered-title: $ftconcat(l, m, r): (FingerTree, [Node], FingerTree) -> FingerTree$,
)[
  + *if* $l$ *is* $Shallow$
    #comment[left is either empty or list of nodes]
    + *for* $v$ *in* $rev(concat(l."children", m))$
      + $r = ftpushl(v, r)$
    + *return* $r$
  + *if* $r$ *is* $Shallow$
    #comment[right is either empty or list of nodes]
    + *for* $v$ *in* $concat(m, r."children")$
      + $l = ftpushr(l, v)$
    + *return* $l$
  + *else*
    + *let* $m' = nothing$
    + *for* $e$ *in* $concat(l."right", m, r."left")$
      #comment[lift node children by one layer]
      + $m' = concat(m', e."children")$
    + *return* $Deep(l."left", ftconcat(l."middle", m', r."middle"), r."right")$
]

#let finger-tree-alg-split = algorithm(
  numbered-title: $ftsplit(t, m): (FingerTree, Measure) -> (FingerTree, FingerTree)$,
)[
  + *if* $t$ *is* $Shallow$
    + *let* $l, r = dsplit(t."children", m)$
    + *return* $(Shallow(l), Shallow(r))$
  + *else*
    + *if* $m <= t."left"."measure"$
      + *let* $l, r = dsplit(t."left", m)$
      // TODO: (l, r + middle + right)
    + *if* $m <= t."middle"."measure"$
      + *let* $l, r = ftsplit(t."middle", m)$
      // TODO
    + *if* $m <= t."right"."measure"$
      + *let* $l, r = dsplit(t."right", m)$
      // TODO
    + *else*
      + *return* $(t, Shallow(nothing))$
]

#let finger-tree-alg-insert = algorithm(
  numbered-title: $ftinsert(t, e): (FingerTree, Node) -> FingerTree$,
)[
  + *let* $l, r = ftsplit(t, e."measure")$
  + *if* $abs(l) eq.not 0 and last(l)."measure" = m$
    #comment[$e."measure"$ at end of $l$]
    + *let* $l', "__" = ftpopr(l)$
    + *return* $ftconcat(ftpushr(l', e), r)$
  + *else*
    #comment[$m$ not in $t$]
    + *return* $ftconcat(ftpushr(l, e), r)$
]

#let finger-tree-alg-remove = algorithm(
  numbered-title: $ftremove(t, m): (FingerTree, Measure) -> (FingerTree, Node)$,
)[
  + *let* $l, r = ftsplit(t, m)$
  + *if* $abs(l) eq.not 0 and last(l)."measure" = m$
    #comment[$m$ at end of $l$]
    + *let* $l', e = ftpopr(l)$
    + *let* $t' = ftconcat(l', r)$
    + *return* $(t', e)$
  + *else*
    #comment[$m$ not in $t$]
    + *return* $(t, None)$
]
