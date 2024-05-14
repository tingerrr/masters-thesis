= QnA

= Research
== Partial State
- interesting, but likely not relevant for this thesis
- cited left-right as inspiration for its partial state

== Left-Right
- they weren't lying, this announcement is _brief_
- concurrency primitive
- many readers are lock free, single writer must write once, wait for previous readers to finish then write again and are not lock-free
- might be relevant for cross-thread data sharing to avoid clones

== RRB-Vector Tail Optimization
- improves performance by adding a transient tail node where most updates happen
- it seems no special consideration other than index adjustment and no inplace mutation of the root are enough to make the tail optimization work
- if I understood this right it should also be applicable at the head of the data structure
- this resembles the finger tree approach of placing "fingers" the most often accessed nodes

== B-Trees
- very similar to rrb-trees (unsurprisingly)
- storage utilization might be as low as 50% in extreme cases, rrb trees improve on this
