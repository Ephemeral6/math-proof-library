/-
  STATUS: DISCOVERY
  AGENT: 5
  DIRECTION: Concrete-model impedance is a constant function of (X, p).
  SUMMARY:
    In the concrete state-sequence model (`MIP/Defs/StateSequence.lean`),
    `Z`, `Z_min`, `Z_max` are all literal constant functions of the agent
    and problem.  This file records the three explicit equalities and
    their immediate "constant function" form: for every pair of agents
    `X, Y` and every pair of problems `p, q`, all three quantities agree
    across `(X, p)` and `(Y, q)`.  These are pure unfolding-level facts,
    but they make explicit the degeneracy that a future, richer impedance
    model will have to break.
-/
import MIP.Axioms
import MIP.Defs.StateSequence

namespace MIP

namespace Agent5_Z_Constancy

variable {α : Type}

/-! ## Pointwise constancy of `Z`, `Z_min`, `Z_max`. -/

/-- **DISCOVERY.** In the concrete state-sequence model, `Z X p = 0`. -/
@[simp] theorem Z_eq_zero (X : Agent α) (p : Problem α) :
    Z X p = 0 := rfl

/-- **DISCOVERY.** In the concrete state-sequence model, `Z_min X p = 0`. -/
@[simp] theorem Z_min_eq_zero (X : Agent α) (p : Problem α) :
    Z_min X p = 0 := rfl

/-- **DISCOVERY.** In the concrete state-sequence model, `Z_max X p = ⊤`. -/
@[simp] theorem Z_max_eq_top (X : Agent α) (p : Problem α) :
    Z_max X p = (⊤ : ENNReal) := rfl

/-! ## Global constancy across all agents and all problems. -/

/-- **DISCOVERY.** `Z` is globally constant on `Agent α × Problem α`: any
two agent/problem pairs give the same impedance. -/
theorem Z_const (X Y : Agent α) (p q : Problem α) :
    Z X p = Z Y q := by
  rw [Z_eq_zero, Z_eq_zero]

/-- **DISCOVERY.** `Z_min` is globally constant on `Agent α × Problem α`. -/
theorem Z_min_const (X Y : Agent α) (p q : Problem α) :
    Z_min X p = Z_min Y q := by
  rw [Z_min_eq_zero, Z_min_eq_zero]

/-- **DISCOVERY.** `Z_max` is globally constant on `Agent α × Problem α`. -/
theorem Z_max_const (X Y : Agent α) (p q : Problem α) :
    Z_max X p = Z_max Y q := by
  rw [Z_max_eq_top, Z_max_eq_top]

/-! ## A neater statement: collapse of `Z_min` and `Z` (they coincide). -/

/-- **DISCOVERY.** In the concrete model, `Z` actually saturates its lower
bound: `Z X p = Z_min X p` for every `(X, p)`.  This is the "lower-extreme"
case of the sandwich `Z_min ≤ Z ≤ Z_max`. -/
theorem Z_eq_Z_min (X : Agent α) (p : Problem α) :
    Z X p = Z_min X p := rfl

/-- **DISCOVERY (negative form).** `Z` does *not* attain its upper bound
`Z_max`: indeed `Z X p ≠ Z_max X p` for every `(X, p)`. -/
theorem Z_ne_Z_max (X : Agent α) (p : Problem α) :
    Z X p ≠ Z_max X p := by
  rw [Z_eq_zero, Z_max_eq_top]
  exact ENNReal.zero_ne_top

end Agent5_Z_Constancy

end MIP
