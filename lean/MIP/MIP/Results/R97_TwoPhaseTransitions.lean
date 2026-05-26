/-
Result R.97 — Two-phase transition: the coverage→autonomy time gap.

Reference: `proofs/derived/learning_mechanics.md` R.97 (A conditional,
under R.61s compact form + Z slow-varying + coverage complete).

**Statement.** In the 4D phase space the training trajectory crosses two
disjoint hypersurfaces in order: first the coverage surface `Π_cov` at
time `t_cov` (where `N: ∞ → finite`), then the autonomy surface `Σ_δ` at
time `t_aut` (where `N: finite → 0`).  In the κ-decay regime
`κ(t) = κ₀^{exp(-α_κ(t-t_cov))}` the autonomy timing reduces to a
logarithmic relation, giving the time gap

    t_aut − t_cov  =  log(r / δ) / α_κ ,

with `t_cov < t_aut` whenever `δ < r` (the two surfaces are disjoint and
correctly ordered).

**Pure-math content.** Two crisp algebraic facts.

1. **Gap formula.** From the defining threshold equation
   `α_κ · (t_aut − t_cov) = log(r/δ)` with `α_κ > 0`, divide:
   `t_aut − t_cov = log(r/δ) / α_κ`.

2. **Disjointness / ordering.** With `α_κ > 0` and `0 < δ < r`, we have
   `r/δ > 1`, so `log(r/δ) > 0`, hence the gap is strictly positive and
   `t_cov < t_aut`.  (Coverage strictly precedes autonomy; the surfaces do
   not coincide.)

**This file is `axiom`-free.**  The MIP-side premises (R.61s compact form,
Z slow-varying, coverage complete) enter only through the explicit
threshold equation taken as a hypothesis.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace TwoPhaseTransitions

open Real

/-- **R.97 — autonomy-coverage time-gap formula.**

Given the defining threshold equation `α_κ · (t_aut − t_cov) = log(r/δ)`
(the κ-decay regime collapsing the autonomy timing to a log relation) with
`α_κ > 0`, the gap between the two phase transitions is

    t_aut − t_cov  =  log(r / δ) / α_κ . -/
theorem R_97_time_gap
    (α_κ r δ t_cov t_aut : ℝ)
    (h_α : 0 < α_κ)
    (h_threshold : α_κ * (t_aut - t_cov) = Real.log (r / δ)) :
    t_aut - t_cov = Real.log (r / δ) / α_κ := by
  have h_ne : α_κ ≠ 0 := ne_of_gt h_α
  field_simp
  linarith [h_threshold]

/-- **R.97 — strict positivity of `log(r/δ)` under `0 < δ < r`.**

The autonomy threshold `δ` is strictly below the coverage scale `r`, so
`r/δ > 1` and `log(r/δ) > 0`.  This is the key sign fact behind the
ordering of the two transitions. -/
theorem R_97_log_pos
    (r δ : ℝ) (h_δ : 0 < δ) (h_lt : δ < r) :
    0 < Real.log (r / δ) := by
  apply Real.log_pos
  rw [lt_div_iff₀ h_δ]
  linarith

/-- **R.97 — disjointness / ordering: `t_cov < t_aut`.**

Combining the gap formula with `0 < δ < r` (so `log(r/δ) > 0`) and
`α_κ > 0`: the gap `log(r/δ)/α_κ` is strictly positive, hence coverage
strictly precedes autonomy.  The two hypersurfaces `Π_cov` and `Σ_δ` are
therefore disjoint and crossed in the stated order. -/
theorem R_97_ordering
    (α_κ r δ t_cov t_aut : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_threshold : α_κ * (t_aut - t_cov) = Real.log (r / δ)) :
    t_cov < t_aut := by
  have h_gap : t_aut - t_cov = Real.log (r / δ) / α_κ :=
    R_97_time_gap α_κ r δ t_cov t_aut h_α h_threshold
  have h_log_pos : 0 < Real.log (r / δ) := R_97_log_pos r δ h_δ h_lt
  have h_gap_pos : 0 < t_aut - t_cov := by
    rw [h_gap]
    exact div_pos h_log_pos h_α
  linarith

/-- **R.97 — gap bound under a stronger threshold (≤ form).**

If only the inequality `α_κ · (t_aut − t_cov) ≤ log(r/δ)` is known (the
autonomy surface reached *no later* than the log time), then the gap is
bounded above by `log(r/δ)/α_κ`. -/
theorem R_97_time_gap_le
    (α_κ r δ t_cov t_aut : ℝ)
    (h_α : 0 < α_κ)
    (h_threshold : α_κ * (t_aut - t_cov) ≤ Real.log (r / δ)) :
    t_aut - t_cov ≤ Real.log (r / δ) / α_κ := by
  rw [le_div_iff₀ h_α, mul_comm]
  exact h_threshold

end TwoPhaseTransitions

end MIP
