/-
Result R.37w — Teaching meta-cognition is no worse than teaching knowledge,
in expectation (weak form A).

Reference: `C:/Users/12729/Desktop/MIP/proofs/derived/A_grade.md`
R.37w (A 弱; deps R.61, C.9; 2026 derived branch).

**Statement (weak form).** From `N ∝ r · |log κ| · Z` (R.61), the
per-question marginal effects of training are

    ∂N/∂r = |log κ| · Z     (teaching knowledge — expands coverage),
    ∂N/∂Z = r · |log κ|     (teaching meta-cognition — lowers impedance).

Taking expectations over the question distribution `P` (with `Z` a global
attribute, constant across questions):

    E_P[∂N/∂r] = E_P[|log κ|] · Z              =: E_Nr
    E_P[∂N/∂Z] = E_P[r · |log κ|]              =: E_NZ

Comparing the cost-normalised marginal effects (cost `c_Z` of training `Z`,
cost `c_K` of training knowledge), teaching meta-cognition is *no worse*
than teaching knowledge:

    E_NZ / c_Z  ≥  E_Nr / c_K .

The pivot quantity is the ratio `ρ := E_P[r·|log κ|] / E_P[|log κ|]`
(a weighted mean difficulty); the inequality holds once `ρ` is large
enough relative to `Z` and the cost ratio, namely `ρ / c_Z ≥ Z / c_K`.

**This file is `axiom`-free.**  It states R.37w as a self-contained
algebraic comparison on real-valued marginal-effect quantities and costs,
with the R.61 expectation identities and the "large `E_P[r·Z]`" hypothesis
entering as explicit premises.  Closed by `div`/`linarith`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace MetacogTraining

/-- **R.37w — core comparison (ratio form).**

Let `E_logκ := E_P[|log κ|] ≥ 0`, `Z ≥ 0`, training costs `c_Z, c_K > 0`,
and the meta-cognition marginal `E_NZ := E_P[r·|log κ|]`.  Write the
knowledge marginal as `E_Nr := E_logκ · Z` (the R.61 expectation
identity).  Define the weighted mean difficulty `ρ` by
`E_NZ = ρ · E_logκ`.  Then the pivot hypothesis `ρ / c_Z ≥ Z / c_K`
(meta-cognition dominates per unit cost) gives

    E_NZ / c_Z ≥ E_Nr / c_K . -/
theorem R_37w_core
    (E_logκ Z ρ c_Z c_K E_NZ E_Nr : ℝ)
    (h_E_logκ_nonneg : 0 ≤ E_logκ)
    (_h_cZ_pos : 0 < c_Z) (_h_cK_pos : 0 < c_K)  -- costs positive (premise; pivot carries the work)
    (h_E_NZ_def : E_NZ = ρ * E_logκ)         -- E_P[r·|log κ|] = ρ · E_P[|log κ|]
    (h_E_Nr_def : E_Nr = E_logκ * Z)          -- R.61 expectation identity
    (h_pivot : Z / c_K ≤ ρ / c_Z) :           -- "E_P[r·Z] large": ρ dominates
    E_Nr / c_K ≤ E_NZ / c_Z := by
  rw [h_E_NZ_def, h_E_Nr_def]
  -- Goal: (E_logκ * Z) / c_K ≤ (ρ * E_logκ) / c_Z
  -- Multiply the pivot Z/c_K ≤ ρ/c_Z by E_logκ ≥ 0.
  have h := mul_le_mul_of_nonneg_left h_pivot h_E_logκ_nonneg
  -- h : E_logκ * (Z / c_K) ≤ E_logκ * (ρ / c_Z)
  rw [mul_div_assoc', mul_div_assoc'] at h
  -- h : (E_logκ * Z) / c_K ≤ (E_logκ * ρ) / c_Z
  rw [mul_comm ρ E_logκ]
  linarith [h]

/-- **R.37w — comparison from a direct ratio hypothesis.**

Equivalent statement taking the marginal-effect quantities `E_NZ, E_Nr`
directly (both nonneg) with the cost-normalised dominance hypothesis
`E_Nr / c_K ≤ E_NZ / c_Z` already supplied as the "large `E_P[r·Z]`"
condition.  Records that the conclusion is exactly the normalised
inequality. -/
theorem R_37w_normalised
    (E_NZ E_Nr c_Z c_K : ℝ)
    (h_cZ_pos : 0 < c_Z) (h_cK_pos : 0 < c_K)
    (h_dominance : E_Nr * c_Z ≤ E_NZ * c_K) :
    E_Nr / c_K ≤ E_NZ / c_Z := by
  -- Clear denominators: cross-multiply by the positive costs.
  rw [div_le_div_iff₀ h_cK_pos h_cZ_pos]
  -- Goal: E_Nr * c_Z ≤ E_NZ * c_K
  exact h_dominance

/-- **R.37w.a — strict version.**

If the pivot is strict (`Z / c_K < ρ / c_Z`) and the weighting
`E_logκ` is strictly positive, then meta-cognition is *strictly* better
per unit cost. -/
theorem R_37w_a_strict
    (E_logκ Z ρ c_Z c_K E_NZ E_Nr : ℝ)
    (h_E_logκ_pos : 0 < E_logκ)
    (_h_cZ_pos : 0 < c_Z) (_h_cK_pos : 0 < c_K)  -- costs positive (premise; pivot carries the work)
    (h_E_NZ_def : E_NZ = ρ * E_logκ)
    (h_E_Nr_def : E_Nr = E_logκ * Z)
    (h_pivot : Z / c_K < ρ / c_Z) :
    E_Nr / c_K < E_NZ / c_Z := by
  rw [h_E_NZ_def, h_E_Nr_def]
  have h := mul_lt_mul_of_pos_left h_pivot h_E_logκ_pos
  rw [mul_div_assoc', mul_div_assoc'] at h
  rw [mul_comm ρ E_logκ]
  linarith [h]

end MetacogTraining

end MIP
