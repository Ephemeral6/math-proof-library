/-
Result R.268 — three-phase classification of the emergent phase diagram
by the sign of the Landau coefficient `a(Z⁻¹, κ)`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.268
(B, C-3 family).

**Statement.**

In the mean-field Landau free energy (R.119 / R.268)

    F̃_landau(ψ) = (a/2)·ψ² + (b/4)·ψ⁴ ,        b > 0 ,

the equilibrium order parameter `ψ_eq` (a stationary point,
`V'(ψ) = a·ψ + b·ψ³ = 0`) is classified by the sign of `a`:

* **Disordered phase** `a > 0`: the only real stationary point is `ψ = 0`.
* **Ordered phase** `a < 0`: there is a nonzero equilibrium with
  `ψ_eq² = -a/b > 0`.
* **Critical locus** `a = 0`: the transition line (`a(Z⁻¹) = 0` ⇔
  `Z⁻¹ = Z⁻¹_c`), where the quartic well degenerates `V(ψ) = (b/4)ψ⁴`.

The critical locus `a = 0` is the second-order phase-transition line.

**This file is `axiom`-free.**  The Landau form enters only through the
explicit real coefficients `a, b`; we formalize the algebraic trichotomy
of the stationary-point equation `a·ψ + b·ψ³ = 0`.
-/
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace PhaseDiagram

open Real

/-- The Landau derivative / stationary-point equation `V'(ψ) = a·ψ + b·ψ³`. -/
def stationaryEq (a b ψ : ℝ) : ℝ := a * ψ + b * ψ ^ 3

/-- **R.268 (I) — disordered phase `a > 0`: only `ψ = 0` is stationary.**

For `a > 0`, `b > 0`, the only real solution of `a·ψ + b·ψ³ = 0`
is `ψ = 0`.  (`ψ_eq = 0`, disordered/diffusive phase II.) -/
theorem R_268_disordered_unique
    (a b ψ : ℝ) (ha : 0 < a) (hb : 0 < b)
    (hstat : stationaryEq a b ψ = 0) :
    ψ = 0 := by
  -- a·ψ + b·ψ³ = ψ·(a + b·ψ²) = 0; the factor (a + b·ψ²) > 0, so ψ = 0.
  have hfac : ψ * (a + b * ψ ^ 2) = 0 := by
    have : stationaryEq a b ψ = ψ * (a + b * ψ ^ 2) := by
      unfold stationaryEq; ring
    rw [this] at hstat; exact hstat
  have hpos : 0 < a + b * ψ ^ 2 := by positivity
  rcases mul_eq_zero.mp hfac with h | h
  · exact h
  · exact absurd h (ne_of_gt hpos)

/-- **R.268 (II) — ordered phase `a < 0`: a nonzero equilibrium exists.**

For `a < 0`, `b > 0` there is `ψ_eq ≠ 0` with `ψ_eq² = -a/b > 0` and
`a·ψ_eq + b·ψ_eq³ = 0`.  (Ordered/frozen phase I.) -/
theorem R_268_ordered_exists
    (a b : ℝ) (ha : a < 0) (hb : 0 < b) :
    ∃ ψ : ℝ, ψ ≠ 0 ∧ ψ ^ 2 = -a / b ∧ stationaryEq a b ψ = 0 := by
  have hpos : 0 < -a / b := div_pos (by linarith) hb
  refine ⟨Real.sqrt (-a / b), ?_, ?_, ?_⟩
  · exact ne_of_gt (Real.sqrt_pos.mpr hpos)
  · rw [Real.sq_sqrt (le_of_lt hpos)]
  · have hsq : (Real.sqrt (-a / b)) ^ 2 = -a / b := Real.sq_sqrt (le_of_lt hpos)
    have hb' : b ≠ 0 := ne_of_gt hb
    have hfac : a + b * (Real.sqrt (-a / b)) ^ 2 = 0 := by
      rw [hsq]; field_simp; ring
    unfold stationaryEq
    calc a * Real.sqrt (-a / b) + b * Real.sqrt (-a / b) ^ 3
        = Real.sqrt (-a / b) * (a + b * (Real.sqrt (-a / b)) ^ 2) := by ring
      _ = Real.sqrt (-a / b) * 0 := by rw [hfac]
      _ = 0 := by ring

/-- **R.268 (II) — the ordered equilibrium value is real and positive.**

The order parameter magnitude `ψ_eq² = -a/b` is strictly positive
exactly when `a < 0` (with `b > 0`). -/
theorem R_268_ordered_value_pos
    (a b : ℝ) (ha : a < 0) (hb : 0 < b) :
    0 < -a / b :=
  div_pos (by linarith) hb

/-- **R.268 (III) — critical locus `a = 0`.**

On the transition line `a = 0` the stationary equation reduces to
`b·ψ³ = 0`, whose only real solution is `ψ = 0`: the ordered and
disordered branches merge.  This degeneracy is the second-order
critical line. -/
theorem R_268_critical_degenerate
    (b ψ : ℝ) (hb : 0 < b) (hstat : stationaryEq 0 b ψ = 0) :
    ψ = 0 := by
  have hb' : b ≠ 0 := ne_of_gt hb
  have hcube : b * ψ ^ 3 = 0 := by
    have : stationaryEq 0 b ψ = b * ψ ^ 3 := by unfold stationaryEq; ring
    rw [this] at hstat; exact hstat
  have hψ3 : ψ ^ 3 = 0 := by
    rcases mul_eq_zero.mp hcube with h | h
    · exact absurd h hb'
    · exact h
  exact pow_eq_zero_iff (by norm_num) |>.mp hψ3

/-- **R.268 — full trichotomy.**

The complete classification by `sign a` (with `b > 0` fixed): the squared
equilibrium order parameter is `max(0, -a/b)`; it is `0` for `a ≥ 0`
(disordered / critical) and `-a/b > 0` for `a < 0` (ordered).  Stated as
the disjunction. -/
theorem R_268_trichotomy
    (a b : ℝ) (hb : 0 < b) :
    (0 < a → ∀ ψ, stationaryEq a b ψ = 0 → ψ = 0)
    ∧ (a = 0 → ∀ ψ, stationaryEq a b ψ = 0 → ψ = 0)
    ∧ (a < 0 → ∃ ψ : ℝ, ψ ≠ 0 ∧ ψ ^ 2 = -a / b ∧ stationaryEq a b ψ = 0) := by
  refine ⟨?_, ?_, ?_⟩
  · intro ha ψ hstat; exact R_268_disordered_unique a b ψ ha hb hstat
  · intro ha ψ hstat; subst ha; exact R_268_critical_degenerate b ψ hb hstat
  · intro ha; exact R_268_ordered_exists a b ha hb

end PhaseDiagram

end MIP
