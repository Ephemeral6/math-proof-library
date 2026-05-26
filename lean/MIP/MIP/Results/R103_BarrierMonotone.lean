/-
Result R.103 — `|B(p, A)|` monotone under the capability partial order.

Reference: `proofs/derived/conjecture_attacks.md` R.103 (A 弱形式 无条件
under T.7 + C.6).

**Statement.** For agents `A₁ ≼ A₂` (capability partial order), the
barrier cardinality is monotone non-increasing:

    |B(p, A₂)|  ≤  |B(p, A₁)| .

I.e. as an AI grows in capability, the number of independent barriers
on any problem shrinks (or stays the same).

**Proof.** Two-line algebraic composition:
* **T.7** (uniqueness): `N(p, A) = |B(p, A)|` for every (p, A).
* **R.58 / C.6** (capability ordering): `A₁ ≼ A₂ ⟹ N(p, A₂) ≤ N(p, A₁)`.
Combining the two equalities and the inequality gives the conclusion.

This file proves the **algebraic kernel** by composing the two
hypotheses; the MIP-side facts (T.7 and R.58) enter as explicit
hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Data.ENat.Basic

namespace MIP

namespace BarrierMonotone

/-- **R.103 — algebraic kernel (composition of T.7 and R.58).**

Given:
* `T.7`: `N i = B_card i` for every agent index `i` (uniqueness theorem,
  emergence cost equals barrier cardinality),
* `R.58`: `N` monotone in the capability order.

Then `B_card` is also monotone in the capability order. -/
theorem R_103_barrier_monotone
    (N B_card : ℕ → ℕ∞)
    (h_T7    : ∀ i, N i = B_card i)
    (i₁ i₂ : ℕ) (h_N_mono : N i₂ ≤ N i₁) :
    B_card i₂ ≤ B_card i₁ := by
  rw [← h_T7 i₁, ← h_T7 i₂]
  exact h_N_mono

/-- **R.103 (real-valued cardinality form).**

Same statement when `B_card` returns natural-number cardinalities (the
common form when `|B|` is known finite). -/
theorem R_103_barrier_monotone_nat
    (N B_card : ℕ → ℕ)
    (h_T7    : ∀ i, N i = B_card i)
    (i₁ i₂ : ℕ) (h_N_mono : N i₂ ≤ N i₁) :
    B_card i₂ ≤ B_card i₁ := by
  rw [← h_T7 i₁, ← h_T7 i₂]
  exact h_N_mono

end BarrierMonotone

end MIP
