#import "util.typ": *

//
// t4gl
//

#let t4gl-ex-array1 = ```t4gl
String[Integer] map
map[42] = "Hello World!"

String[Integer, Integer] nested
nested[-1, 37] = "T4gl is wacky!"

String[10] staticArray
staticArray[9] = "Truly wacky!"
```

#let t4gl-ex-array2 = ```t4gl
String[10] array1
String[10] array2 = array1

array1[0] = "Hello World!"
// array1[0] == array2[0]
```

//
// vector
//

#let vector-ex = ```cpp
#import <vector>

int main() {
  std::vector<int> vec;

  vec.push_back(3);
  vec.push_back(2);
  vec.push_back(1);

  std::vector<int> other = vec;

  return 0;
}
```

//
// finger tree
//

#let finger-tree-def-old = ```cpp
using T = ...;
using M = ...;

class Node {};
class Internal : public Node {
  M measure;
  std::array<Node*, 3> children; // 2..3 children
};
class Leaf : public Node {
  T value;
};

class FingerTree {};
class Shallow : public FingerTree {
  Node* value; // 0..1 digits
};
class Deep : public FingerTree {
  M measure;
  std::array<Node*, 4> left;  // 1..4 digits
  FingerTree* middle;
  std::array<Node*, 4> right; // 1..4 digits
};
```

#let finger-tree-def-new = ```cpp
using T = ...;
using M = ...;

class Node {};
class Internal : public Node {
  M measure;
  std::vector<Node*> children; // k_min..k_max children
};
class Leaf : public Node {
  T value;
};

class FingerTree {};
class Shallow: public FingerTree {
  std::vector<Node*> values; // 0..(2 d_min - 1) digits
};
class Deep : public FingerTree {
  M measure;
  std::vector<Node*> left;  // d_min..d_max digits
  FingerTree* middle;
  std::vector<Node*> right; // d_min..d_max digits
};
```
