/-
  STATUS: DISCOVERY
  AGENT: 5
  DIRECTION: Concrete-model values of the reciprocal impedance `Z⁻¹`.
  SUMMARY:
    Several R-files (R.114, R.201) work with `Z⁻¹` as the "conductance"
    dual of impedance.  Under `ENNReal` inversion the concrete model
    yields the dual extremes:

      Z X p           = 0    ⟹   (Z X p)⁻¹     = ⊤
      Z_min X p       = 0    ⟹   (Z_min X p)⁻¹ = ⊤
      Z_max X p       = ⊤    ⟹   (Z_max X p)⁻¹ = 0

    The implications:
    * `Z⁻¹ = ⊤` is the "infinite conductance" regime — physically
      "every intervention is admissible";
    * `Z_max⁻¹ = 0` says the upper-impedance reciprocal is zero;
    * The sandwich on conductance is `0 = (Z_max)⁻¹ ≤ (Z)⁻¹ ≤ (Z_min)⁻¹ = ⊤`
      — i.e. *reversed* inclusion versus impedance, as expected.

    All of these are pure `ENNReal`-algebra unfoldings.
-/
import MIP.Axioms
import MIP.Defs.StateSequence
import MIP.Discoveries.Agent5_Z_Constancy
import Mathlib.Data.ENNReal.Inv

namespace MIP

namespace Agent5_Z_Inversion

open Agent5_Z_Constancy

variable {α : Type}

/-! ## Pointwise inversion values. -/

/-- **DISCOVERY.**  `(Z X p)⁻¹ = ⊤` in the concrete model. -/
@[simp] theorem Z_inv_eq_top (X : Agent α) (p : Problem α) :
    (Z X p)⁻¹ = (⊤ : ENNReal) := by
  rw [Z_eq_zero, ENNReal.inv_zero]

/-- **DISCOVERY.**  `(Z_min X p)⁻¹ = ⊤` in the concrete model. -/
@[simp] theorem Z_min_inv_eq_top (X : Agent α) (p : Problem α) :
    (Z_min X p)⁻¹ = (⊤ : ENNReal) := by
  rw [Z_min_eq_zero, ENNReal.inv_zero]

/-- **DISCOVERY.**  `(Z_max X p)⁻¹ = 0` in the concrete model. -/
@[simp] theorem Z_max_inv_eq_zero (X : Agent α) (p : Problem α) :
    (Z_max X p)⁻¹ = (0 : ENNReal) := by
  rw [Z_max_eq_top, ENNReal.inv_top]

/-! ## Reversed sandwich on the "conductance" side. -/

/-- **DISCOVERY (reversed sandwich).**  The conductance sandwich is
`(Z_max)⁻¹ ≤ (Z)⁻¹ ≤ (Z_min)⁻¹`, opposite in direction to the
impedance sandwich.  In the concrete model both ends are extreme
(`0 ≤ ⊤ ≤ ⊤`). -/
theorem Z_inv_sandwich (X : Agent α) (p : Problem α) :
    (Z_max X p)⁻¹ ≤ (Z X p)⁻¹ ∧ (Z X p)⁻¹ ≤ (Z_min X p)⁻¹ := by
  refine ⟨?_, ?_⟩
  · rw [Z_max_inv_eq_zero]; exact zero_le _
  · rw [Z_min_inv_eq_top]; exact le_top

/-- **DISCOVERY.**  Two pointed facts about the conductance side:
the lower bound is attained, and the upper bound is attained. -/
theorem Z_inv_sandwich_saturated (X : Agent α) (p : Problem α) :
    (Z X p)⁻¹ = (Z_min X p)⁻¹ ∧ (Z X p)⁻¹ ≠ (Z_max X p)⁻¹ := by
  refine ⟨?_, ?_⟩
  · rw [Z_inv_eq_top, Z_min_inv_eq_top]
  · rw [Z_inv_eq_top, Z_max_inv_eq_zero]
    exact ENNReal.top_ne_zero

/-! ## Product / Ohm-conductance form `Φ₀ · Z⁻¹`.

The R.201 / R.114 statements work with the "conductance variable"
`ζ := Z⁻¹`.  The Ohm form rewrites to `E[N | ζ] = Φ̄ / ζ`.  In the
concrete model `ζ = ⊤`, so the product `Phi0 · ζ` and the quotient
`Phi0 / ζ` again degenerate.
-/

/-- **DISCOVERY.**  `Phi0 · Z⁻¹` is either `⊤` (if `Phi0 ≠ 0`) or
`0` (if `Phi0 = 0`). -/
theorem Phi0_mul_Zinv_dichotomy (X : Agent α) (p : Problem α) :
    (Phi0 X p = 0 ∧ Phi0 X p * (Z X p)⁻¹ = 0) ∨
      (Phi0 X p ≠ 0 ∧ Phi0 X p * (Z X p)⁻¹ = ⊤) := by
  rw [Z_inv_eq_top]
  by_cases hP : Phi0 X p = 0
  · left
    refine ⟨hP, ?_⟩
    rw [hP]; simp
  · right
    refine ⟨hP, ENNReal.mul_top hP⟩

/-- **DISCOVERY.**  `Phi0 / Z_max = 0` (the "lower conductance" Ohm
prediction): since `Z_max = ⊤`, division by it gives `0`. -/
theorem Phi0_div_Z_max_eq_zero (X : Agent α) (p : Problem α) :
    Phi0 X p / Z_max X p = 0 := by
  rw [Z_max_eq_top, ENNReal.div_top]

/-- **DISCOVERY.**  `Phi0 / Z_min` is `0` if `Phi0 = 0`, and `⊤`
otherwise (division by 0 in `ENNReal`). -/
theorem Phi0_div_Z_min_dichotomy (X : Agent α) (p : Problem α) :
    (Phi0 X p = 0 ∧ Phi0 X p / Z_min X p = 0) ∨
      (Phi0 X p ≠ 0 ∧ Phi0 X p / Z_min X p = ⊤) := by
  rw [Z_min_eq_zero]
  by_cases hP : Phi0 X p = 0
  · left
    refine ⟨hP, ?_⟩
    rw [hP]; simp
  · right
    refine ⟨hP, ?_⟩
    rw [ENNReal.div_zero hP]

end Agent5_Z_Inversion

end MIP
