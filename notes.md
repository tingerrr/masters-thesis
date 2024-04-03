# Notes
- some proprietary code is given, but not relevant for the thesis, anyhing else may be included for clarity where needed
- template must be finished according to the FHE style guide [^1]

## Basics
### Core issues
- arrays in t4gl internally use a copy-on-write mechanism to share memory where possible and avoid expensive clones in the absence of mutating operations
- a common use case for arrays in t4gl are value histories, a snapshot of a value is appended to a history in regular intervals, the resulting array of snapshots can get non-trivially large, such that clones are expensive
- if a reader now copies the history array, another modification from the writer thread will cause this thread to eat the cost of the expensive clone
- ideally the cost of cloning the history should be mitigated by reducing how much must be cloned for a modification, or possibly delegated to the reader thread in some way
- copies to other threads always incure a clone, ideally this can be mitigated too
- t4gl already suffers from latencies because of these issues
- the improved data structures *should* have the following time complexities:

|Operation|Complexity|
|---|---|
|clone|O(1)|
|write|O(log n)|
|read| - |

### Non-issues
- generalization to keys other than numeric key types shall not be in scope of the thesis
- allocation is assumed to be constant time
  - this is apparently sufficiently fast for the constraints at hand
- deallocation is assumed to be constant time
	- generally deletion of objects is not a problem for the runtime, it is delegated to another thread
- general data structure implementation
  - the implementation side will be domain (t4gl) specific
  - the algorithm and data structure explanation should be enough to allow reimplementation in other contexts

## Brain storming results
- readonly wrapper which makes clones more explicit
  - does not reduce clones or help mitigate their costs
- chink-based backing storage to avoid clones of the whole structure on mutations
  - similar to rrb-tree paper [^2]
- linked list storage for sorted chunks
- stricter readonly modifier
  - does not help existing code
  - leaves questions open about the shared memory of reader and writer and synchronization
- rust move semantics
  - does not help existing code
  - complicates the high level language
- eventually consistent data sructure which looks at snapshots and copies changes on reads

## general tasks
- **start of thesis writing**
- research
	- state of the industry
  - existing data structures
- comparison of solutions
- chosing solution
- work on the theoretical basis of the solution
- implementing the solution
- **end of thesis writing**
- presentation

[^1]: https://ai.fh-erfurt.de/fileadmin/ai_daten/download-bereich/studiendokumente/ba-und-ma-arbeiten/03_AI-Hinweise-BA-MA-Arbeiten_2019-04.pdf
[^2]: https://infoscience.epfl.ch/record/213452/files/rrbvector.pdf
