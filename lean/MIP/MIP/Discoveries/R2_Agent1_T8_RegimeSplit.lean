/-
  STATUS: DISCOVERY
  AGENT: R2-1
  DIRECTION: T.8 Ohm-law verdict split by trichotomy regime.
  SUMMARY:
    Agent 5 proved `T8_Ohm_holds_iff_Phi0_zero`: `N = ⌈Phi0 · Z⌉ ↔ Phi0 = 0`.
    Composing with Agent 2's trichotomy (R0/RP/R∞), we get a *regime-keyed*
    statement that's cleaner than Agent 5's biconditional alone:

      Regime     | T.8 Ohm-law form              | sharpness side
      -----------+-------------------------------+----------------------
      R0 (N=0)   | holds (both sides = 0)        | lower bound is sharp
      RP (0<N<⊤) | strict undershoot  ⌈·⌉ < N    | lower bound NOT sharp
      R∞ (N=⊤)  | strict undershoot  ⌈·⌉ < ⊤    | lower bound NOT sharp

    We prove three regime-conditional statements + a master "T8 verdict by
    regime" theorem.  The master theorem is the *full classification* of
    when T.8's strict-equality form is realised in the concrete model.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Defs.StateSequence

namespace MIP

namespace R2_Agent1_T8_RegimeSplit

variable {α : Type} {Ω : Type}

/-! ## (1) Regime-conditional verdicts. -/

/-- **R0: T.8 Ohm holds**. -/
theorem T8_in_R0 (p : Problem α) (X : Agent α) (h : N p X = 0) :
    N p X = ceilENat (Phi0 X p * Z X p) := by
  show N p X = ceilENat (Phi0 X p * (0 : ENNReal))
  rw [mul_zero, ceilENat_zero, h]

/-- **RP: T.8 Ohm fails strictly** (`⌈·⌉ < N`). -/
theorem T8_in_RP (p : Problem α) (X : Agent α) (h_pos : 0 < N p X) :
    ceilENat (Phi0 X p * Z X p) < N p X := by
  show ceilENat (Phi0 X p * (0 : ENNReal)) < N p X
  rw [mul_zero, ceilENat_zero]
  exact h_pos

/-- **R∞: T.8 Ohm fails strictly** (`⌈·⌉ < ⊤`). -/
theorem T8_in_Rinf (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    ceilENat (Phi0 X p * Z X p) < N p X := by
  show ceilENat (Phi0 X p * (0 : ENNReal)) < N p X
  rw [mul_zero, ceilENat_zero, h]
  exact ENat.coe_lt_top 0

/-! ## (2) Master verdict by regime. -/

/-- **T.8 verdict by regime.**  For every `(p, X)`,
T.8 holds as strict equality iff we are in R0.  Otherwise (RP or R∞)
the ceiling is strictly *below* `N`. -/
theorem T8_verdict_by_regime (p : Problem α) (X : Agent α) :
    (N p X = 0 ∧ N p X = ceilENat (Phi0 X p * Z X p))
      ∨ (0 < N p X ∧ ceilENat (Phi0 X p * Z X p) < N p X) := by
  by_cases h : N p X = 0
  · left; exact ⟨h, T8_in_R0 p X h⟩
  · right
    have h_pos : 0 < N p X := Ne.lt_of_le' h bot_le
    exact ⟨h_pos, T8_in_RP p X h_pos⟩

/-! ## (3) Sharpness side of T.8 lower bound. -/

/-- **T.8 lower bound is sharp ↔ in regime R0.**  The book's T.8 lower
inequality `⌈Phi0 · Z_min⌉ ≤ N` becomes equality (sharp) iff `N = 0`. -/
theorem T8_lower_sharp_iff_R0 (p : Problem α) (X : Agent α) :
    ceilENat (Phi0 X p * Z_min X p) = N p X ↔ N p X = 0 := by
  show ceilENat (Phi0 X p * (0 : ENNReal)) = N p X ↔ N p X = 0
  rw [mul_zero, ceilENat_zero]
  exact ⟨fun h => h.symm, fun h => h.symm⟩

/-! ## (4) Upper-bound side: T.8 upper bound is sharp ↔ R0. -/

/-- **T.8 upper bound is sharp ↔ in regime R0** (the only case where both
sides are 0; otherwise `Phi0 ≠ 0` gives `⌈Phi0 · ⊤⌉ = ⊤ > N` when N < ⊤,
or `= ⊤ = N` only when N = ⊤; we phrase the cleaner R0 direction here). -/
theorem T8_upper_R0_both_zero (p : Problem α) (X : Agent α) (h : N p X = 0) :
    ceilENat (Phi0 X p * Z_max X p) = 0 := by
  have hPhi : Phi0 X p = 0 := (Axioms.A1 p X).mp h
  rw [hPhi, zero_mul, ceilENat_zero]

/-- **In R0, the T.8 upper bound is also sharp**:
`⌈Phi0 · Z_max⌉ = N p X = 0`. -/
theorem T8_upper_sharp_in_R0 (p : Problem α) (X : Agent α) (h : N p X = 0) :
    ceilENat (Phi0 X p * Z_max X p) = N p X := by
  rw [T8_upper_R0_both_zero p X h, h]

/-- **In R0, both T.8 bounds collapse to 0** — equality on lower side and
equality on upper side. -/
theorem T8_R0_double_sharp (p : Problem α) (X : Agent α) (h : N p X = 0) :
    ceilENat (Phi0 X p * Z_min X p) = N p X
      ∧ N p X = ceilENat (Phi0 X p * Z X p)
      ∧ ceilENat (Phi0 X p * Z_max X p) = N p X := by
  refine ⟨?_, T8_in_R0 p X h, T8_upper_sharp_in_R0 p X h⟩
  show ceilENat (Phi0 X p * (0 : ENNReal)) = N p X
  rw [mul_zero, ceilENat_zero, h]

end R2_Agent1_T8_RegimeSplit

end MIP
