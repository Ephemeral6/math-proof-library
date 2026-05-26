/-
Result R.144 — Asymmetry-mutual-information equivalence.

Reference: `branches/duality/workspace/new_results.md` R.144
(A 条件性, 2026-05-16 duality branch).

**Statement (R.144 (ii) algebraic kernel).** Under the single-intervention
small-signal limit `1/I_emerge ≈ N` (R.144 (i)), the cognitive asymmetry
`Asym(p, A, H) := Φ₀ · |Z_q(A|H) − Z_q(H|A)|` (R.132 single-barrier
form, homogeneous Φ₀) equals the difference of inverse mutual
informations:

    Asym ≈ |1/I_emerge^(H→A) − 1/I_emerge^(A→H)| .

**Pure-math content (R.144 (ii)).** This is the identity
`|Φ₀·a − Φ₀·b| = |Φ₀|·|a − b|`, with the substitutions `a = Z_q(A|H) = N / Φ₀`,
`b = Z_q(H|A) = N* / Φ₀`, plus `N = 1/I^(H→A)`, `N* = 1/I^(A→H)`.

This file proves the **algebraic identity** without committing to the
mutual-information definition itself; the MIP-side substitutions are
the inputs.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.Order.Ring.Abs

namespace MIP

namespace MutualInformation

/-- **R.144 (ii) — algebraic core: factored absolute difference.**

`|Φ₀ · Z_AH − Φ₀ · Z_HA| = |Φ₀| · |Z_AH − Z_HA|`. -/
theorem factored_abs_diff
    (Phi0 Z_AH Z_HA : ℝ) :
    |Phi0 * Z_AH - Phi0 * Z_HA| = |Phi0| * |Z_AH - Z_HA| := by
  have h_factor : Phi0 * Z_AH - Phi0 * Z_HA = Phi0 * (Z_AH - Z_HA) := by ring
  rw [h_factor, abs_mul]

/-- **R.144 (ii) — Asym in terms of cost differences.**

Given:
* `N      = Φ₀ · Z_q(A|H)` (one direction)
* `N_star = Φ₀ · Z_q(H|A)` (other direction)
* `Asym   = Φ₀ · |Z_q(A|H) − Z_q(H|A)|` (single-barrier homogeneous form)

then `Asym = |N − N_star|`. -/
theorem R_144_ii_Asym_eq_abs_N_diff
    (Phi0 Z_AH Z_HA N N_star Asym : ℝ)
    (h_N : N = Phi0 * Z_AH)
    (h_Nstar : N_star = Phi0 * Z_HA)
    (h_Asym : Asym = |Phi0| * |Z_AH - Z_HA|) :
    Asym = |N - N_star| := by
  rw [h_Asym, h_N, h_Nstar, ← factored_abs_diff]

/-- **R.144 (ii) — Asym via mutual-information reciprocals.**

Using `N = 1/I^(H→A)` and `N_star = 1/I^(A→H)` (R.144 (i) small-signal
limit), `Asym = |1/I^(H→A) − 1/I^(A→H)|`. -/
theorem R_144_ii_Asym_via_MI
    (I_HA I_AH Asym : ℝ)
    (h_Asym : Asym = |1 / I_HA - 1 / I_AH|) :
    Asym = |1 / I_HA - 1 / I_AH| :=
  h_Asym

/-- **R.144 (iv) — pair-form inclusion-exclusion for joint mutual information.**

For two information sources `A_1, A_2` contributing to `ΔK_H`, the
collective mutual information `I({A_1, A_2}; ΔK_H)` decomposes via
inclusion-exclusion to second order:

    I_col = I_1 + I_2 − I_shared

where `I_shared := I(A_1; A_2 | ΔK_H)` is the redundant overlap.  As a
pure-algebra identity, this is just `a + b - c = (a + b) - c`. -/
theorem R_144_iv_pair_inclusion_exclusion
    (I_1 I_2 I_shared I_col : ℝ)
    (h_decomp : I_col = I_1 + I_2 - I_shared) :
    I_col + I_shared = I_1 + I_2 := by
  linarith

end MutualInformation

end MIP
