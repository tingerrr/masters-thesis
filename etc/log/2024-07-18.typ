= QnA
- srb-trees
  - an idea by Ralf to sparsly populate a perfectly balanced tree for radix search (similar to rrb-trees)
  - excellent time complexity, upper bounds are functions of key width and branching factor
  - can have horrible storage utilization if values are inconveniently placed
- finger trees
  - proof is not yet done
    - trouble understanding the proof by okasaki which is referenced by hinze and paterson
    - simplification of $Delta d_(t + 1) = 1$ greatly simplifies the proof
  - some more content about their real time implications
  - pseudo code and algorithm explanation
    - done: push and pop
    - missing: insert and remove
    - missing: concat and split (we may not provide these as they aren't commonly used in t4gl)
- benchmarking
  - what are common considerations for benchmarking
  - what are common fallacies when benchmarking
  - do we already have a benchmarking suite?
  - if no do we have data for possible benchmarking workloads

= Review
- concat and split may be added to provide a better impl than a programmer may use
- benchmarking:
  - look at the structure itself
  - look at sources where history was used
  - ensure benchmakrs run long enough
  - ensure benchmarks run often enough, take median and average
  - ensure diverse operation sequenzes for benchmarks (interspersed push pop, worst case operation sequences)
  - ensure diverse datasets for benchmarks (ordered vs random keys, etc.)
  - ensure no optimization for benchmakrs
  - ensure benchmarking measurement has minimal impact on benchmarking result
- review:
  - intro should touch roughly on t4gl and it's main problem
  - use more appropriate and less ambiguous phrasing (e.g. "nicht-geteilte" instead of "einzigartige Knoten")
  - "Instanz" is used in a way that is confusing, the usage in the thesis refers to parts of the data structure which contain only supplemental informaiton and no data
  - "Persistenz" is confusing to the uninitiated and may be confused with a different similarly named concept in Databases, should touch on it's definition as "Immutable" in many programming languages
  - branching factor of vector is ver relevant to it's complexity but only touched on in a footnote
  - big o notation needs an explanantion of what Omicron of f of n actually means (i.e. how it defines the set of all functions with an asymptotic upper and lower bound of, yadda yadda)
  - small omicron and small o don't need ot be mentione dif they're not used
  - t4gl array implementaiton must be more clearly illustrated, it being a CoW data structure is not well understood from the text
  - 2.5.1 "geordnete Schlüssel" is confusing, talk about Keys which have a well defined order
  - 3.1 The separation of "Storage" and "Speicher" is fuzzy, need better names
  - 3.1 "Buffer" is defined and consistently used, but could have a better name too
  - "Schreibfähigkeit" doesn't seem to be important as a term as it simply refers to buffers in ephemeral data structures
  - sometimes paragraphs leave questions to the next paragraph, making understanding harder than necessary
  - explicit clone of t4gl instances does a deep clone to the memory layer, nut just on the storage layer, the delayed deep clone is only used within the runtime system (sort of as a side effect)
  - the overall direction of the thesis is correct
  - review notes use the following syntax
    / A: Ausdruck
    / B: Begrifflichkeiten
    / rosa: Orthographie
