/-
Result R.146 (iv) — Ideal-curriculum vanishing cost.

Reference: `branches/duality/workspace/new_results.md` R.146 (iv)
(A 条件 ITA, 2026-05-16 duality branch).

**Statement (R.146 (iv)).** If the curriculum ordering `π` makes H's
post-state cover the next problem's knowledge demand at every step
(`K(H^{(i)}) ⊇ R(p_{π(i+1)})`), then the next-step external-aid cost
vanishes:

    N*(p_{π(i+1)}, A, H^{(i)})  =  0  for sufficiently late `i` .

**Proof.** Direct application of A.1: `N(p, X) = 0 ↔ Φ₀(X, p) = 0`.
Under the coverage hypothesis, `Φ₀ = 0` (no autonomous gap remains), so
`N = 0` (and equally `N* = 0`).

This file proves the **algebraic core**: a "knowledge-coverage ⟹ Φ₀ = 0"
hypothesis combined with A.1 gives the vanishing-cost conclusion.

**This file is `axiom`-free** (apart from re-using the project's
foundational axiom `MIP.Axioms.A1`).
-/
import MIP.Axioms
import Mathlib.Data.ENNReal.Basic

namespace MIP

namespace IdealCurriculum

open MIP.Axioms

/-- **R.146 (iv) — algebraic kernel via A.1.**

If H's knowledge state covers the demand of problem `p` (so the
autonomous emergence potential `Φ₀(H, p) = 0` by the coverage axiom in
the natural-language proof), then `N(p, H) = 0`. -/
theorem R_146_iv_zero_cost
    {α : Type} (p : Problem α) (H : Agent α)
    (h_cover : Phi0 H p = 0) :
    N p H = 0 :=
  (A1 p H).mpr h_cover

/-- **R.146 (iv) — curriculum step form.**

If after solving problems `p_1, …, p_i`, the post-state `H_i` covers the
next problem's demand (`Φ₀(H_i, p_{i+1}) = 0`), then the next-step cost
is zero. -/
theorem R_146_iv_step
    {α : Type} (H : ℕ → Agent α) (p : ℕ → Problem α) (i : ℕ)
    (h_step_cover : Phi0 (H i) (p (i + 1)) = 0) :
    N (p (i + 1)) (H i) = 0 :=
  R_146_iv_zero_cost (p (i + 1)) (H i) h_step_cover

/-- **R.146 (iv) — asymptotic vanishing (sequence form).**

If at some stage `i₀` the coverage condition holds, then from that
stage onward (until knowledge regresses) the step cost is zero. -/
theorem R_146_iv_asymptotic
    {α : Type} (H : ℕ → Agent α) (p : ℕ → Problem α)
    (i₀ : ℕ) (h_eventually : ∀ i ≥ i₀, Phi0 (H i) (p (i + 1)) = 0) :
    ∀ i ≥ i₀, N (p (i + 1)) (H i) = 0 :=
  fun i hi => R_146_iv_step H p i (h_eventually i hi)

end IdealCurriculum

end MIP
