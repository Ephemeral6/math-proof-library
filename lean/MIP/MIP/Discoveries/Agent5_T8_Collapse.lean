/-
  STATUS: DISCOVERY
  AGENT: 5
  DIRECTION: T.8 "Ohm-law" ceiling formula `⌈Φ₀ · Z⌉ = 0` collapses
             unconditionally in the concrete model.
  SUMMARY:
    The book's T.8 says `N = ⌈Φ₀ · Z⌉` in the uniform-impedance regime
    `Z_min = Z_max`.  In the concrete state-sequence model
    (`MIP/Defs/StateSequence.lean`) we have `Z := 0`, so the *predicted*
    side `⌈Φ₀ · Z⌉` is uniformly `0`, regardless of `Phi0`.  This means:

    * The Ohm form holds *iff* `N = 0` *iff* `Phi0 = 0` (by A.1), i.e.
      iff the problem is initially solved.
    * In every problem that requires intervention (`Phi0 > 0`, so `N ≥ 1`),
      the Ohm prediction `⌈Φ₀ · Z⌉ = 0` *underestimates* `N`, agreeing
      only with the T.8 lower bound `⌈Φ₀ · Z_min⌉ ≤ N`.

    Two clean consequences are proved:
      * `T8_Ohm_prediction_eq_zero`: `⌈Φ₀ · Z⌉ = 0` for every (X, p);
      * `T8_Ohm_holds_iff_Phi0_zero`: the strict-equality form
        `N = ⌈Φ₀ · Z⌉` holds iff `Phi0 X p = 0`.

    These make explicit the degeneration noted in T.8 Step 4.
-/
import MIP.Axioms
import MIP.Defs.StateSequence
import MIP.Discoveries.Agent5_Z_Constancy

namespace MIP

namespace Agent5_T8_Collapse

open Agent5_Z_Constancy

variable {α : Type}

/-- **DISCOVERY.**  The T.8 Ohm prediction `⌈Φ₀ · Z⌉` is identically `0`
in the concrete state-sequence model.  Reason: `Z X p = 0`, so
`Phi0 X p * Z X p = 0`, so `ceilENat 0 = 0`. -/
@[simp] theorem T8_Ohm_prediction_eq_zero (X : Agent α) (p : Problem α) :
    ceilENat (Phi0 X p * Z X p) = 0 := by
  rw [Z_eq_zero, mul_zero, ceilENat_zero]

/-- **DISCOVERY.**  The T.8 Ohm prediction at the *lower* bound,
`⌈Φ₀ · Z_min⌉`, is also identically `0` (same reason). -/
@[simp] theorem T8_Ohm_lower_prediction_eq_zero
    (X : Agent α) (p : Problem α) :
    ceilENat (Phi0 X p * Z_min X p) = 0 := by
  rw [Z_min_eq_zero, mul_zero, ceilENat_zero]

/-- **DISCOVERY.**  The strict-equality "Ohm-law" form
`N p X = ⌈Φ₀ · Z⌉` holds in the concrete model *iff* `Phi0 X p = 0`
*iff* `N p X = 0`.  Proof: LHS is `N p X`, RHS is `0` by the previous
theorem, so the equation is `N p X = 0`, which by A.1 is `Phi0 X p = 0`. -/
theorem T8_Ohm_holds_iff_Phi0_zero (X : Agent α) (p : Problem α) :
    N p X = ceilENat (Phi0 X p * Z X p) ↔ Phi0 X p = 0 := by
  rw [T8_Ohm_prediction_eq_zero]
  exact Axioms.A1 p X

/-- **DISCOVERY (negative form).**  Whenever the problem requires at
least one intervention (`Phi0 X p ≠ 0`, equivalently `N p X ≠ 0` by
A.1), the T.8 Ohm prediction *strictly under-shoots* `N p X`. -/
theorem T8_Ohm_strict_undershoot
    (X : Agent α) (p : Problem α) (hPhi : Phi0 X p ≠ 0) :
    ceilENat (Phi0 X p * Z X p) < N p X := by
  rw [T8_Ohm_prediction_eq_zero]
  -- N p X ≠ 0 by A.1
  have hN : N p X ≠ 0 := by
    intro h
    exact hPhi ((Axioms.A1 p X).mp h)
  exact pos_iff_ne_zero.mpr hN

/-- **DISCOVERY (lower-bound side is sharp only at solved problems).**
The T.8 lower bound `⌈Φ₀ · Z_min⌉ ≤ N` is sharp (equality) iff `N = 0`
iff `Phi0 = 0`. -/
theorem T8_lower_bound_sharp_iff (X : Agent α) (p : Problem α) :
    ceilENat (Phi0 X p * Z_min X p) = N p X ↔ Phi0 X p = 0 := by
  rw [T8_Ohm_lower_prediction_eq_zero, eq_comm]
  exact Axioms.A1 p X

/-- **DISCOVERY (upper-bound side: which agents saturate).**
The T.8 upper bound `N ≤ ⌈Φ₀ · Z_max⌉` is always trivially satisfied
because of the explicit values: when `Phi0 X p = 0` both sides are `0`;
when `Phi0 X p ≠ 0` then `Phi0 X p * Z_max X p = ⊤` and the bound is
`N ≤ ⊤`, vacuous. -/
theorem T8_upper_bound_dichotomy (X : Agent α) (p : Problem α) :
    (Phi0 X p = 0 ∧ ceilENat (Phi0 X p * Z_max X p) = 0) ∨
      (Phi0 X p ≠ 0 ∧ ceilENat (Phi0 X p * Z_max X p) = ⊤) := by
  rw [Z_max_eq_top]
  by_cases hP : Phi0 X p = 0
  · left
    refine ⟨hP, ?_⟩
    rw [hP]
    simp
  · right
    refine ⟨hP, ?_⟩
    rw [ENNReal.mul_top hP, ceilENat_top]

end Agent5_T8_Collapse

end MIP
