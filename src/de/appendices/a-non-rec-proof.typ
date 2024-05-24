#import "/src/util.typ": *

$
  f(n, k) &= cases(
    1 &bold("wenn") k = 0,
    n &bold("wenn") k = 1,
    (n - 1) n^(k - 1) + f(n, k - 1) &bold("sonst"),
  ) \
  f(n, k) &= n^k \
$

#todo[
  Formalize the below lean proof of the above claim, written under the assistance of my friend Kiiya.
]

```lean
import Mathlib.Tactic.Linarith

def f : Int -> Nat -> Int
| _, 0 => 1
| n, 1 => n
| n, k + 1 => (n - 1) * n^k + (f n k)

theorem n_pow_k_eq_f_n_k (n : Int) (k : Nat) : (n^k) = f n k := by
  induction k with
  | zero => simp only [Int.pow_zero, f]
  | succ k ih =>
    match k with
    | 0 =>
      rw [f]
      simp
    | k + 1 =>
      rw [f]
      simp [pow_add, ih]
      have (x n : Int) : (n - 1) * x + x = n * x := by linarith
      rw [this]
      rw [Int.mul_comm]
      aesop
```

#todo[
  The recursively unfolded version of $f(n, k)$ can be used to rewrite the iterative $n'_min$ and $n'_max$ into a purely arithmetic function.
  $
    n'_min (t) = 2 d_min sum_(i = 1)^t k_min^(t - i) = ??? \
    n'_max (t) = 2 d_max sum_(i = 1)^t k_max^(t - i) = ??? \
  $
]
