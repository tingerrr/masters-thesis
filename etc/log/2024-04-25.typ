= QnA
- citing-non public works
  - citing non-public works is ok if they are provided on a case by case basis to researcher, as well as reviwers of the thesis
- interval for regular consultations
  - bi-weekly, thursday morning
- structure and granularity
  - introduction, motivaiton and basics
  - keep basics to relevant topics, at best, write parts of the basics chapter as the concepts come up in the rest of the thesis
  - avoid explaining too much on the basics
  - ensure the constraints of the desired solution are written down in the motivation
  - take extra care for non-public knowledge like T4gl specific concepts
- analysis
  - ensure that the conclusion is drawn on empirical analysis
- rough timeline

= Research
== Chunked Sequences
- purely ephemeral data structure
- aimed at sequential data (items preserve insertion order)
  - push, pop, split and concatenate
- work was mostly on asymptotic efficiency, but not on reducing constant factors, authors attempt to focus on reducing constant factors and providing a practical implementation
- identifies two problems with chunking strategies at the time
  - push-pop sequences
  - sparse chunks
- provides $O(2n)$ space efficiency
- proofs take allocation cost into account as a constant factor $A$
- uses two special chunks on both ends and a sequence of dense chunks in the middle
- can be bootstrapped to be used in a tree like data structure to amortize costs further
- it seems that bounds are largely ensured by the $|c| + |c'| <= K$ invariant
- no special consideration for reducing the cloning bounds while keeping mutability and sharing intact

== Catenable Lists
- explains persistent data strucutres (useful for citations)
- see citation [10] about fully persistent arrays (which however fail on concatenation and splitting)
- mostly concerned with splitting and merging persistent lists
- likely not the focal point of my work

== RRB-Vector
- logarithmic and super linear complexities on read and write with random access
- the relaxtion needs extra metadata for unblanaced sub trees, efficient radix impl can be used on balanced trees
- balancing seems to happen in the same vein as in b-trees
- they talk about radix balanced trees a lot, I assume they mean b-trees on which one uses radix search (RB-Vectors are apparently the scala implementation they aim to improve)
- the figures show some redundant steps of splitting and re-merging nodes which are confusing at first because they show intermediate steps as if they persist
- concatenation sacrifices on performance for better balancing to improve all other operations
- shows ways to improve cache efficiency using focused branches
- transient state improves performance by adding local mutability
- canonicalization returns the vector into it's normal state, this is done automatically

== Ropes
- cited in the various RRB-Vector/RRB-Tree papers and thesis and clearly served as an inspiration
- less refined than RRB-Vectors with regards to efficient balancing
- more focus on string specific nodes, such as lazy-loaded files

== Finger Trees
- I have a hard time understanding the Haskell examples at times, but I understand the gist of the date stuture
