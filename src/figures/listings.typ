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

class Digits {
  M measure;
  std::array<Node*, 4> children; // 1..4 digits
};

class FingerTree {
  M measure;
};
class Shallow : public FingerTree {
  Node* digit; // 0..1 digits
};
class Deep : public FingerTree {
  Digits left;  // 1..4 digits
  FingerTree* middle;
  Digits right; // 1..4 digits
};
```

#let finger-tree-def-new = ```cpp
using V = ...;
using K = ...;

class Node {};
class Internal : public Node {
  K key;
  std::vector<Node*> children; // k_min..k_max children
};
class Leaf : public Node {
  K key;
  V val;
};

class Digits {
  K key;
  std::vector<Node*> children;
};

class FingerTree {
  K key;
};
class Shallow : public FingerTree {
  Node* digit; // 0..1 digits
};
class Deep : public FingerTree {
  Digits left;  // d_min..d_max digits
  FingerTree* middle;
  Digits right; // d_min..d_max digits
};
```

#let finger-tree-def-illegal = ```cpp
template <typename T>
class Node2 : public Node { T* a; T* b; };

template <typename T>
class Node3 : public Node { T* a; T* b; T* c; };

// ...

template <typename T>
class Deep : public FingerTree {
  FingerTree<Node<T>> middle;
};
```

#let finger-tree-def-node = ```cpp
enum class Kind { Deep, Leaf };
class NodeBase {};
class Node {
  Kind _kind;
  std::shared_ptr<NodeBase<K, V>> _repr;
};
class NodeDeep: public NodeBase {
  uint _size;
  K _key;
  std::vector<Node<K, V>> _children;
};
class NodeLeaf : public NodeBase { K _key; V _val; };
```

#let finger-tree-def-digits = ```cpp
class DigitsBase {
  uint _size;
  K _key;
  std::vector<SharedNode<K, V>> _digits;
};
class Digits {
  std::shared_ptr<DigitsBase<K, V>> _repr;
};
```

#let finger-tree-def-self = ```cpp
enum class Kind { Empty, Single, Deep };
class FingerTreeBase {};
class FingerTree {
  Kind _kind;
  std::shared_ptr<FingerTreeBase<K, V>> _repr;
};
class FingerTreeEmpty : public FingerTreeBase {};
class FingerTreeSingle : public FingerTreeBase {
  Node<K, V> _node;
};
class FingerTreeDeep : public FingerTreeBase {
  Digits<K, V> _left;
  FingerTree<K, V> _middle;
  Digits<K, V> _right;
};
```
