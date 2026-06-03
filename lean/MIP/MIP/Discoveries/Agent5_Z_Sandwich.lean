/-
  STATUS: DISCOVERY
  AGENT: 5
  DIRECTION: Concrete-model impedance sandwich `Z_min ≤ Z ≤ Z_max`.
  SUMMARY:
    The book (D.4.9) states the sandwich bound `Z_min ≤ Z ≤ Z_max`.
    In the concrete state-sequence model, the bound is `0 ≤ 0 ≤ ⊤`,
    holding trivially.  This file packages the sandwich and several
    sharper variants:

    * `Z_min X p = Z X p` (lower side is saturated);
    * `Z X p < Z_max X p` (upper side is strict);
    * the sandwich is independent of `(X, p)` and equals the constant
      chain `0 ≤ 0 ≤ ⊤`.

    These are immediate from `Agent5_Z_Constancy`, but they are the form
    the book actually states, so we record them as discoveries: the
    formal book-level "sandwich" is the trivial chain.
-/
import MIP.Axioms
import MIP.Defs.StateSequence
import MIP.Discoveries.Agent5_Z_Constancy

namespace MIP

namespace Agent5_Z_Sandwich

open Agent5_Z_Constancy

variable {α : Type}

/-- **DISCOVERY (sandwich).**  The book's `Z_min ≤ Z ≤ Z_max` sandwich,
re-stated as a conjunction.  Both bounds are trivial in the concrete
model. -/
theorem Z_sandwich (X : Agent α) (p : Problem α) :
    Z_min X p ≤ Z X p ∧ Z X p ≤ Z_max X p :=
  ⟨Z_min_le_Z X p, Z_le_Z_max X p⟩

/-- **DISCOVERY (lower side is saturated).**  In this model, `Z` equals
its lower bound exactly. -/
theorem Z_min_eq_Z (X : Agent α) (p : Problem α) :
    Z_min X p = Z X p := rfl

/-- **DISCOVERY (upper side is strict).**  `Z X p < Z_max X p` for every
`(X, p)`, since `0 < ⊤`. -/
theorem Z_lt_Z_max (X : Agent α) (p : Problem α) :
    Z X p < Z_max X p := by
  rw [Z_eq_zero, Z_max_eq_top]
  exact ENNReal.zero_lt_top

/-- **DISCOVERY (constancy of the sandwich).**  Across every pair of
agent/problem pairs, the sandwich chain is literally identical. -/
theorem Z_sandwich_const
    (X Y : Agent α) (p q : Problem α) :
    (Z_min X p, Z X p, Z_max X p) = (Z_min Y q, Z Y q, Z_max Y q) := by
  simp [Z_min_eq_zero, Z_eq_zero, Z_max_eq_top]

/-- **DISCOVERY (concrete form of the sandwich).**  The sandwich for any
`(X, p)` is the literal chain `0 ≤ 0 ≤ ⊤`. -/
theorem Z_sandwich_concrete (X : Agent α) (p : Problem α) :
    Z_min X p = (0 : ENNReal) ∧ Z X p = (0 : ENNReal) ∧
      Z_max X p = (⊤ : ENNReal) :=
  ⟨rfl, rfl, rfl⟩

/-- **DISCOVERY (strictness collapses only on the upper side).**  We
cannot have `Z_min X p = Z_max X p` in the concrete model (`0 ≠ ⊤`).
Combined with `Z_min_eq_Z`, this means the *uniform-impedance* regime
`Z_min = Z_max` of D.4.9 is empty in the formal model: there is no
`(X, p)` for which it holds. -/
theorem Z_min_ne_Z_max (X : Agent α) (p : Problem α) :
    Z_min X p ≠ Z_max X p := by
  rw [Z_min_eq_zero, Z_max_eq_top]
  exact ENNReal.zero_ne_top

end Agent5_Z_Sandwich

end MIP
