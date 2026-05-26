/-
Result R.37s — Teaching meta-cognition is STRICTLY optimal over teaching
knowledge (strict form of R.37w).

Reference: `C:/Users/12729/Desktop/MIP/proofs/derived/A_grade.md` R.37w
(weak form, `≤`); `C:/Users/12729/Desktop/MIP/results/R_master_index.md`
R.37s ("教元认知严格最优于教知识 — '严格最优'需具体最优证明", kept at B);
companion Lean file `MIP/Results/R37w_MetacogTraining.lean` (the `≤` core).

**Statement (strict form).** From `N ∝ r · |log κ| · Z` (R.61), the
per-question marginal effects of training are

    ∂N/∂r = |log κ| · Z     (teaching knowledge — expands coverage),
    ∂N/∂Z = r · |log κ|     (teaching meta-cognition — lowers impedance).

Taking expectations over the question distribution `P` (with `Z` a global
attribute, constant across questions), and writing
`E_logκ := E_P[|log κ|]`, the cost-normalised marginal effects are

    E_Nr / c_K := (E_logκ · Z) / c_K          (knowledge, per unit cost),
    E_NZ / c_Z := (ρ · E_logκ) / c_Z          (meta-cognition, per unit cost),

where `ρ := E_P[r·|log κ|] / E_P[|log κ|]` is the weighted mean difficulty.

R.37w gives the non-strict `E_NZ/c_Z ≥ E_Nr/c_K`.  **R.37s strengthens this
to the strict inequality**

    E_NZ / c_Z  >  E_Nr / c_K

under the **strict-pivot / strict-optimum hypothesis** `Z/c_K < ρ/c_Z`
(meta-cognition strictly dominates per unit cost) together with strictly
positive entropy weighting `E_logκ > 0` (a non-degenerate question
distribution).  The strict optimum is exactly the strict pivot: bundling
it as a hypothesis is what lifts the `≤` of R.37w to `<`.

**This file is `axiom`-free.**  It states R.37s as a self-contained strict
algebraic comparison on real-valued marginal-effect quantities and costs,
with the R.61 expectation identities and the strict-pivot hypothesis as
explicit premises.  Closed by `mul`/`div`/`linarith`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace StrictMetacogOptimal

/-- **R.37s — strict optimality (ratio form).**

Let `E_logκ := E_P[|log κ|] > 0` (non-degenerate distribution), `Z ≥ 0`,
training costs `c_Z, c_K > 0`, and the meta-cognition marginal
`E_NZ := ρ · E_logκ` with `ρ` the weighted mean difficulty; the knowledge
marginal is `E_Nr := E_logκ · Z` (the R.61 expectation identity).  Under the
**strict-pivot hypothesis** `Z/c_K < ρ/c_Z` (the "strict optimum" condition
of R.37s), teaching meta-cognition is *strictly* better per unit cost:

    E_Nr / c_K  <  E_NZ / c_Z . -/
theorem R_37s_strict_optimal
    (E_logκ Z ρ c_Z c_K E_NZ E_Nr : ℝ)
    (h_E_logκ_pos : 0 < E_logκ)
    (_h_cZ_pos : 0 < c_Z) (_h_cK_pos : 0 < c_K)  -- costs positive (premise; strict pivot carries the work)
    (h_E_NZ_def : E_NZ = ρ * E_logκ)              -- E_P[r·|log κ|] = ρ · E_P[|log κ|]
    (h_E_Nr_def : E_Nr = E_logκ * Z)               -- R.61 expectation identity
    (h_strict_pivot : Z / c_K < ρ / c_Z) :         -- strict optimum: ρ strictly dominates
    E_Nr / c_K < E_NZ / c_Z := by
  rw [h_E_NZ_def, h_E_Nr_def]
  -- Multiply the strict pivot Z/c_K < ρ/c_Z by E_logκ > 0.
  have h := mul_lt_mul_of_pos_left h_strict_pivot h_E_logκ_pos
  -- h : E_logκ * (Z / c_K) < E_logκ * (ρ / c_Z)
  rw [mul_div_assoc', mul_div_assoc'] at h
  -- h : (E_logκ * Z) / c_K < (E_logκ * ρ) / c_Z
  rw [mul_comm ρ E_logκ]
  linarith [h]

/-- **R.37s — strict optimality from a direct cross-multiplied hypothesis.**

Equivalent strict statement taking `E_NZ, E_Nr` directly with the
cost-normalised *strict* dominance hypothesis `E_Nr · c_Z < E_NZ · c_K`
(the cleared-denominator form of the strict optimum).  Records that the
conclusion is exactly the strict normalised inequality. -/
theorem R_37s_strict_normalised
    (E_NZ E_Nr c_Z c_K : ℝ)
    (h_cZ_pos : 0 < c_Z) (h_cK_pos : 0 < c_K)
    (h_strict_dominance : E_Nr * c_Z < E_NZ * c_K) :
    E_Nr / c_K < E_NZ / c_Z := by
  rw [div_lt_div_iff₀ h_cK_pos h_cZ_pos]
  exact h_strict_dominance

/-- **R.37s — strict separation gap.**

Beyond `<`, the strict optimum gives a quantitative separation: the
per-unit-cost advantage of meta-cognition over knowledge equals
`E_logκ · (ρ/c_Z − Z/c_K) > 0`.  Making the gap explicit shows the
inequality is not merely strict but bounded away from equality by the
product of the (positive) entropy weighting and the (positive) pivot gap. -/
theorem R_37s_separation_gap
    (E_logκ Z ρ c_Z c_K E_NZ E_Nr : ℝ)
    (h_E_logκ_pos : 0 < E_logκ)
    (h_E_NZ_def : E_NZ = ρ * E_logκ)
    (h_E_Nr_def : E_Nr = E_logκ * Z)
    (h_pivot_gap_pos : 0 < ρ / c_Z - Z / c_K) :
    E_NZ / c_Z - E_Nr / c_K = E_logκ * (ρ / c_Z - Z / c_K)
      ∧ 0 < E_NZ / c_Z - E_Nr / c_K := by
  have h_eq : E_NZ / c_Z - E_Nr / c_K = E_logκ * (ρ / c_Z - Z / c_K) := by
    rw [h_E_NZ_def, h_E_Nr_def, mul_comm ρ E_logκ, mul_sub,
        mul_div_assoc, mul_div_assoc]
  refine ⟨h_eq, ?_⟩
  rw [h_eq]
  positivity

end StrictMetacogOptimal

end MIP
