/-
Result R.25 — `T = N/|B|` is a second, independent difficulty dimension.

Reference: `proofs/derived/A_grade.md` R.25 (A 无条件, deps T.1, T.3, D.3.4).

**Statement.** The difficulty parameters `(|B|, T)` jointly characterise `N`
via the identity `N = T · |B|` (from D.3.4 `T = N / |B|`), and `|B|` and `T`
are mutually independent: there exist problems with the same `|B|` but
different `T` (and, symmetrically, the same `T` but different `|B|`).  Thus `T`
is a genuine second axis, not a function of `|B|`.

**NL core.**

* Identity (D.3.4 + T.3): `T(p) = N(p) / |B(p)|`, so `N = T · |B|` whenever
  `|B| ≠ 0`.
* Independence witness: take two problems sharing `|B| = k` barriers.
  - `p₁`: `k` mutually independent atomic barriers, each of measure 1, so
    `N(p₁) = k` and `T(p₁) = k/k = 1`.
  - `p₂`: `k` barriers in a DAG chain, each needing `c > 1` interventions, so
    `N(p₂) = c·k` and `T(p₂) = c`.
  With `c ≥ 2` we have `T(p₁) = 1 ≠ c = T(p₂)` at equal `|B| = k`: `T` is not
  determined by `|B|`.  Symmetrically one fixes `T` and varies `|B|`.

**Pure-math kernel.**  (a) the field identity `T = N/B → N = T·B` for `B ≠ 0`;
(b) explicit existence witnesses encoding the counterexample, established by
exhibiting the concrete configurations and discharging the arithmetic.

**This file is `axiom`-free.**  Configurations are modelled as real triples
`(N, B, T)` constrained by the defining identity `N = T · B`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace SecondDifficultyDim

/-- **R.25 — defining identity `T = N/|B| ⟹ N = T·|B|`.**

From D.3.4 (`T := N / |B|`) with a non-degenerate barrier count `|B| ≠ 0`,
the emergence cost factors as `N = T · |B|`. -/
theorem R_25_identity
    (N B T : ℝ) (hB : B ≠ 0) (hT : T = N / B) :
    N = T * B := by
  rw [hT, div_mul_cancel₀ N hB]

/-- **R.25 — the reverse identity `N = T·|B| ⟹ T = N/|B|`.**

The two presentations are interchangeable for `|B| ≠ 0`. -/
theorem R_25_identity_rev
    (N B T : ℝ) (hB : B ≠ 0) (hN : N = T * B) :
    T = N / B := by
  rw [hN, mul_div_assoc, div_self hB, mul_one]

/-- A *difficulty configuration*: barrier count `B`, per-barrier intervention
`T`, total cost `N`, tied together by the D.3.4 identity `N = T · B`. -/
structure Config where
  /-- Barrier count `|B|`. -/
  B : ℝ
  /-- Per-barrier average intervention count `T = N/|B|`. -/
  T : ℝ
  /-- Total emergence cost `N`. -/
  N : ℝ
  /-- The defining identity `N = T · B` (D.3.4). -/
  identity : N = T * B

/-- **R.25 — independence of `T` from `|B|` (existence witness).**

For every barrier count `k ≠ 0` and every intervention multiplier `c ≥ 2`,
there exist two configurations with the **same** `|B| = k` but **different**
`T` (namely `T = 1` versus `T = c`).  Hence `T` is not a function of `|B|`:
it is a genuinely independent difficulty axis.

This reproduces the NL counterexample: `p₁` (`k` independent atomic barriers,
`T = 1`) versus `p₂` (`k` chained barriers, `T = c`). -/
theorem R_25_T_independent_of_B
    (k c : ℝ) (_hk : k ≠ 0) (hc : 2 ≤ c) :
    ∃ p₁ p₂ : Config, p₁.B = p₂.B ∧ p₁.T ≠ p₂.T := by
  -- p₁: k atomic independent barriers, N = k, T = 1.
  refine ⟨⟨k, 1, k, by ring⟩, ⟨k, c, c * k, by ring⟩, rfl, ?_⟩
  -- T₁ = 1 ≠ c = T₂ since c ≥ 2 > 1.
  simp only
  linarith

/-- **R.25 — independence of `|B|` from `T` (existence witness, symmetric).**

For every intervention level `T₀` and any two distinct barrier counts
`k₁ ≠ k₂`, there exist two configurations with the **same** `T = T₀` but
**different** `|B|`.  Hence `|B|` is not determined by `T` either: the two
axes vary freely. -/
theorem R_25_B_independent_of_T
    (T₀ k₁ k₂ : ℝ) (hk : k₁ ≠ k₂) :
    ∃ p₁ p₂ : Config, p₁.T = p₂.T ∧ p₁.B ≠ p₂.B := by
  -- Same per-barrier cost T₀, different barrier counts k₁ ≠ k₂.
  exact ⟨⟨k₁, T₀, T₀ * k₁, by ring⟩, ⟨k₂, T₀, T₀ * k₂, by ring⟩, rfl, hk⟩

/-- **R.25 — full independence (combined).**

`(|B|, T)` are jointly free: there is a pair witnessing varying `T` at fixed
`|B|`, and a pair witnessing varying `|B|` at fixed `T`.  Together with the
identity `N = T · |B|`, this shows `N` decomposes along two independent axes. -/
theorem R_25_joint_independence
    (k c T₀ k₁ k₂ : ℝ) (hk : k ≠ 0) (hc : 2 ≤ c) (hk' : k₁ ≠ k₂) :
    (∃ p₁ p₂ : Config, p₁.B = p₂.B ∧ p₁.T ≠ p₂.T) ∧
    (∃ q₁ q₂ : Config, q₁.T = q₂.T ∧ q₁.B ≠ q₂.B) :=
  ⟨R_25_T_independent_of_B k c hk hc, R_25_B_independent_of_T T₀ k₁ k₂ hk'⟩

end SecondDifficultyDim

end MIP
