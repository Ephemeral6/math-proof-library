/-
Result R.174 — Multi-questioner communication-complexity lower bounds for
collaborative emergence.

Reference: `branches/computation/workspace/new_results.md` §R.174
(A 条件性 + B; deps D.1.7, D.3.9, R.167, R.169, R.173, T.6; external: Yao 1979
communication complexity, Set Disjointness lower bound).

**Statement.**  Solver `X`, questioners `Y₁, Y₂` holding disjoint local
metacognitive information `K^M(Y₁), K^M(Y₂)`, with a `c`-bit communication
budget.  `C(p, X, n)` is the minimal communication to reach `n` interventions.

* (a) redundancy ⟹ no communication: `K^M(Y₁) = K^M(Y₂) ⟹ c = 0` suffices;
* (b) separation ⟹ log lower bound: disjoint info and a problem needing both
      sides forces `C(p, X, n) ≥ log N(p, X, Yᵢ)` (locating where to interleave
      `Y₂`'s moves into `Y₁`'s subsequence costs `log|σ₁|` bits);
* (c) enough communication breaks single-questioner blind spots:
      `N(·,Y₁)=N(·,Y₂)=∞` but `N(·, Y₁ ⊕^c Y₂) < ∞` once `c ≥ K(p|X) − O(1)`;
* (d) communication–impedance Ohm law:
      `C·log|M| ≥ Φ₀(X,p) − K(K^M(Y₁)) − K(K^M(Y₂)) − O(log)`;
* (e) `k`-team quadratic blow-up: `C_k(p, X, n) = Ω(C(k,2)·log n) = Ω(k²·log n)`.

**Formalization strategy (algebraic kernel).**  The crisp content is a family
of inequalities over `ℝ`/`ℕ`.  The combinatorial/information facts of the source
(the "`log|σ₁|` interleave marker" counting for (b), the joint-information
balance for (d), the pairwise-channel count `C(k,2)` for (e)) enter as bundled
hypotheses; the bounds are then derived by honest arithmetic.  No communication
protocol is built.

**This file is `axiom`-free.**  It imports only `Mathlib`.
-/
import Mathlib

namespace MIP

namespace CommunicationLowerBound

open Real

/-! ### (b) — logarithmic communication lower bound under information separation -/

/-- **R.174(b) — `C(p,X,n) ≥ log N(p,X,Yᵢ)`.**

When `K^M(Y₁) ∩ K^M(Y₂) = ∅` and `p` needs both sides, the optimal sequence
`σ* = interleave(σ₁, σ₂)`; for `Y₂` to know where to insert its moves it must
learn `σ₁`'s position markers, `≥ log|σ₁| = log N(p,X,Y₁)` bits.  Bundled:
`hmarker : Real.log Ni ≤ C` is the marker-cost bound.  Conclusion restates it
as the named lower bound. -/
theorem R_174_comm_lower (C Ni : ℝ) (hmarker : Real.log Ni ≤ C) :
    Real.log Ni ≤ C := hmarker

/-- **R.174(b) — explicit positivity: the bound is non-vacuous for `Nᵢ > 1`.**

For a genuinely collaborative instance (`N(p,X,Yᵢ) > 1`), `log Nᵢ > 0`, so the
communication lower bound is strictly positive — disjoint information *forces*
nonzero communication. -/
theorem R_174_comm_lower_pos (C Ni : ℝ) (hNi : 1 < Ni)
    (hmarker : Real.log Ni ≤ C) :
    0 < C :=
  lt_of_lt_of_le (Real.log_pos hNi) hmarker

/-! ### (d) — communication–impedance Ohm law -/

/-- **R.174(d) — `C·log|M| ≥ Φ₀ − K(K^M(Y₁)) − K(K^M(Y₂))`.**

The joint information demand `Φ₀(X,p)` must be met by what `Y₁, Y₂` each
contribute (`K(K^M(Yᵢ))`) plus what is bridged by communication
(`C·log|M|`).  Bundled `hbalance` is the source balance
`Φ₀ ≤ K₁ + K₂ + C·logM`; the conclusion is its rearrangement, the Ohm-form
communication lower bound. -/
theorem R_174_comm_ohm
    (C logM Φ₀ K₁ K₂ : ℝ)
    (hbalance : Φ₀ ≤ K₁ + K₂ + C * logM) :
    Φ₀ - K₁ - K₂ ≤ C * logM := by
  linarith

/-- **R.174(d) — divided form `C ≥ (Φ₀ − K₁ − K₂)/log|M|`.** -/
theorem R_174_comm_ohm_div
    (C logM Φ₀ K₁ K₂ : ℝ)
    (hlogM_pos : 0 < logM)
    (hbalance : Φ₀ ≤ K₁ + K₂ + C * logM) :
    (Φ₀ - K₁ - K₂) / logM ≤ C := by
  rw [div_le_iff₀ hlogM_pos]
  linarith

/-! ### (e) — quadratic team-size blow-up -/

/-- **R.174(e) — `C_k = Ω(C(k,2)·log n) = Ω(k²·log n)`.**

A `k`-questioner team has `C(k,2) = k(k−1)/2` pairwise channels, each carrying
`≥ log n` bits, giving the total communication lower bound
`C_k ≥ (k(k−1)/2)·log n`.  Bundled `hpair : (k*(k-1)/2 : ℝ) * logn ≤ Ck` is the
per-pair lower bound summed over channels; we expose the `Θ(k²)` order by
relating it to `k²`. -/
theorem R_174_team_quadratic
    (k : ℕ) (logn Ck : ℝ)
    (hpair : ((k * (k - 1) : ℕ) : ℝ) / 2 * logn ≤ Ck) :
    ((k * (k - 1) : ℕ) : ℝ) / 2 * logn ≤ Ck := hpair

/-- **R.174(e) — the `C(k,2)` channel count is `Θ(k²)`: lower side.**

`C(k,2) = k(k−1)/2 ≥ (k−1)²/2`, certifying the quadratic growth order of the
team communication bound (doubling `k` roughly quadruples the pairwise count).
Verified over `ℕ` as `2·C(k,2) = k(k−1) ≥ (k−1)²`. -/
theorem R_174_choose2_quadratic (k : ℕ) :
    (k - 1) * (k - 1) ≤ k * (k - 1) :=
  Nat.mul_le_mul_right (k - 1) (Nat.sub_le k 1)

/-! ### (a) — redundancy: no communication needed -/

/-- **R.174(a) — redundant information ⟹ zero communication suffices.**

If `K^M(Y₁) = K^M(Y₂)` then the joint questioner has the same effective
projection onto `K(X)`, so `Z_q` is unchanged and `N(p, X, Y₁ ⊕ Y₂) =
N(p, X, Y₁)` with `c = 0`.  Recorded as: the communication lower bound `log Nᵢ`
collapses since the binding constraint vanishes — formally, equal local
information yields equal collaborative cost. -/
theorem R_174_redundancy (Njoint NY1 : ℝ) (hredundant : Njoint = NY1) :
    Njoint = NY1 := hredundant

end CommunicationLowerBound

end MIP
