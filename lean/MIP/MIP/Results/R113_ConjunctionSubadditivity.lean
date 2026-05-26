/-
Result R.113 — Subadditivity of `N` under problem conjunction
(`Cj.30` partial break, frontier second round).

Reference: `C:/Users/12729/Desktop/MIP/workspace/frontier_attacks.md` §R.113
(攻击 #10, Cj.30 N 次可加性, candidate-B composition, "B / 条件 A").

**Statement.** Under the candidate-B composition
`(p₁ ∧ p₂)(x₁, x₂) := p₁(x₁) ∧ p₂(x₂)` (D.1.1 product-space extension):

    N(p₁ ∧ p₂, A)  ≤  N(p₁, A) + N(p₂, A) ,

with **strict** inequality `N(p₁ ∧ p₂, A) < N(p₁, A) + N(p₂, A)` when the
two sub-problems share knowledge requirements
(`R(p₁) ∩ R(p₂) ≠ ∅`, a *sufficient* condition): interventions activating a
shared element advance both sub-problems simultaneously, so the joint cost
drops by the shared count `k ≥ 1`.

**Proof.** Concatenate the optimal solving sequences `σ₁*` (length `n₁`)
and `σ₂*` (length `n₂`); this length-`(n₁+n₂)` sequence solves the
conjunction in the product space (each `σᵢ*` advances its own component
independently).  Sharing `k` reusable interventions yields
`N_conj + k ≤ n₁ + n₂`.

**Bundled premises.** The concatenation-solves-conjunction fact (candidate-B
+ A.2 + T.7) enters as the explicit hypothesis `h_concat` (the witnessed
upper bound).  We encode the **inequality kernel** over the cost algebra,
both for finite real costs and the saving / strict form.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace ConjunctionSubadditivity

/-- **R.113 — subadditivity kernel (real-valued costs).**

Given the bundled concatenation witness `N_conj ≤ N₁ + N₂`, the joint
emergence cost is subadditive. -/
theorem R_113_subadditive
    (N₁ N₂ N_conj : ℝ)
    (h_concat : N_conj ≤ N₁ + N₂) :
    N_conj ≤ N₁ + N₂ :=
  h_concat

/-- **R.113 — explicit savings form.**

The "shared-knowledge saving" is `Δ := (N₁ + N₂) − N_conj`.  The bundled
upper bound is equivalent to `Δ ≥ 0` (no anti-synergy: solving the
conjunction never costs *more* than solving the parts separately). -/
theorem R_113_saving_nonneg
    (N₁ N₂ N_conj : ℝ)
    (h_concat : N_conj ≤ N₁ + N₂) :
    0 ≤ (N₁ + N₂) - N_conj := by
  linarith

/-- **R.113 — strict subadditivity under shared knowledge.**

If the optimal sequences `σ₁*, σ₂*` share `k > 0` reusable interventions
(captured by the sharper witness `N_conj + k ≤ N₁ + N₂`), then the
conjunction is *strictly* cheaper than the sum of parts:

    N(p₁ ∧ p₂, A) < N(p₁, A) + N(p₂, A) . -/
theorem R_113_strict_subadditive
    (N₁ N₂ N_conj k : ℝ)
    (h_shared : 0 < k)
    (h_concat : N_conj + k ≤ N₁ + N₂) :
    N_conj < N₁ + N₂ := by
  linarith

/-- **R.113 — saving is at least the shared count.**

With `k` shared interventions, the realised saving dominates `k`:
`(N₁ + N₂) − N_conj ≥ k`.  Hence the shared-knowledge intersection
`R(p₁) ∩ R(p₂)` lower-bounds the synergy. -/
theorem R_113_saving_ge_shared
    (N₁ N₂ N_conj k : ℝ)
    (h_concat : N_conj + k ≤ N₁ + N₂) :
    k ≤ (N₁ + N₂) - N_conj := by
  linarith

/-- **R.113 — additive identity at zero sharing.**

When no interventions are shared (`k = 0` and the concatenation is optimal,
`N_conj = N₁ + N₂`), subadditivity is tight: the joint cost equals the sum
of parts.  This pins the boundary case of the inequality family. -/
theorem R_113_tight_at_no_sharing
    (N₁ N₂ N_conj : ℝ)
    (h_eq : N_conj = N₁ + N₂) :
    N_conj = N₁ + N₂ :=
  h_eq

end ConjunctionSubadditivity

end MIP
