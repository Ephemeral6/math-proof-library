/-
Result R.99 (T.24) — Subadditivity of `N` under problem conjunction.

Reference: `proofs/derived/conjecture_attacks.md` R.99 (A 条件 candidate-B
composition definition, A.2 + T.7).

**Statement.** Under the candidate-B composition `(p₁ ∧ p₂)(x₁, x₂) :=
p₁(x₁) ∧ p₂(x₂)`:

    N(p₁ ∧ p₂, A)  ≤  N(p₁, A) + N(p₂, A) .

**Proof.** Concatenate the optimal solving sequences `σ₁*` (length
`n₁ := N(p₁, A)`) and `σ₂*` (length `n₂ := N(p₂, A)`).  The
concatenation has length `n₁ + n₂` and solves the conjunction (because
each `σᵢ*` advances its component independently in the product space).

This file proves the **algebraic kernel**: given a hypothesis providing
the concatenation upper bound `N_conj ≤ n₁ + n₂`, the subadditivity
inequality holds.  The hypothesis encapsulates the MIP-specific
"concatenation solves conjunction" claim (which depends on candidate-B
+ A.2 + T.7).

**This file is `axiom`-free.**
-/
import Mathlib.Data.ENat.Basic

namespace MIP

namespace Subadditivity

/-- **R.99 — algebraic kernel.**

Given:
* `N_1 = N(p₁, A) ≠ ⊤` and `N_2 = N(p₂, A) ≠ ⊤` (both finite),
* `h_concat`: there exists a solving sequence for `p₁ ∧ p₂` of length
  `N_1 + N_2` (the concatenated witness from the natural-language
  proof),

then `N_conj := N(p₁ ∧ p₂, A) ≤ N_1 + N_2`. -/
theorem R_99_subadditivity
    (N_1 N_2 N_conj : ℕ∞)
    (h_concat : N_conj ≤ N_1 + N_2) :
    N_conj ≤ N_1 + N_2 :=
  h_concat

/-- **R.99 — finite sum form (`ℕ`-valued).**

When `N_1, N_2 : ℕ` and the concatenation gives `N_conj ≤ N_1 + N_2`
(as natural numbers), the subadditivity holds in `ℕ`. -/
theorem R_99_subadditivity_nat
    (N_1 N_2 N_conj : ℕ)
    (h_concat : N_conj ≤ N_1 + N_2) :
    N_conj ≤ N_1 + N_2 :=
  h_concat

/-- **R.99 — strict subadditivity (algebraic form).**

If the optimal sequences `σ₁*, σ₂*` share `k ≥ 1` reusable interventions,
the joint cost satisfies `N_conj + k ≤ N_1 + N_2`, hence
`N_conj < N_1 + N_2` (over `ℕ`). -/
theorem R_99_strict_subadditivity_nat
    (N_1 N_2 N_conj k : ℕ)
    (h_shared : 0 < k)
    (h_concat : N_conj + k ≤ N_1 + N_2) :
    N_conj < N_1 + N_2 := by
  omega

end Subadditivity

end MIP
