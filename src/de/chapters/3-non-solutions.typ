#import "/src/util.typ": *
#import "/src/figures.typ"

#todo[
  This chapter introduces solutions which were initially considered, but either don't solve the problem entirely, or rely on other changes to bring anything worthwile to the table.
  This includes:
  - new move semantics similar to Rust
    - breaking change for basiclaly all codebasese
    - too complex for a high level language
    - would need significant changes in the compiler and runtime
    - does not help when copies are actually required
  - max size annotations
    - need to be explictly added, won't improve old code
    - don't really improve the situation, a runtime error is not better
    - cannot be used in dynamic cases
    - large containers still do linear time copies
  - adding new data structures for the programmer to chose
    - need to be explictly used, won't improve old code
    - still require better copy implementations internally
    - added language complexity, likely needs some form of generics
]
