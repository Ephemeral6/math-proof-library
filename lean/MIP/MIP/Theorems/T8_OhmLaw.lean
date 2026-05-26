/-
Theorem T.8 — Emergence Ohm's law.

Reference: `proofs/T8.md`, book Chapter 5 (Theorem 5.1).

**Statement.** Under the Ohm regime σ_Z = 0 (i.e. `Z_min = Z_max`):
`N(p, X) = ⌈Φ₀(X, p) · Z(X, p)⌉` whenever the emergence degree and the
initial emergence potential are both finite.  Outside the Ohm regime
only the two-sided bound `⌈Φ₀ · Z_min⌉ ≤ N ≤ ⌈Φ₀ · Z_max⌉` holds.

Phase 4 status: the substantive `T8_lower_bound` / `T8_upper_bound` /
`T8_OhmLaw_core` live in `MIP.Defs.StateSequence` as theorems whose
proofs run the full `proofs/T8.md` derivation (telescoping + per-step
bound + greedy feasibility) above an axiomatised state-sequence
layer.  This file glues them into the final two-sided / strict form
of T.8.
-/
import MIP.Axioms
import MIP.Defs.StateSequence

namespace MIP

namespace OhmLaw

open MIP.Axioms

variable {α : Type}

/-- **Sub-lemma T.8-zero (Φ₀ = 0 fragment of `T8_OhmLaw`).**

Direct consequence of axiom A.1 and the convention `0 · a = 0` on
`ENNReal`: when the initial emergence potential is zero, `N p X = 0`
and the right-hand side `⌈Φ₀ · Z⌉` also evaluates to `0`. -/
theorem T8_OhmLaw_zero_case
    (p : Problem α) (X : Agent α)
    (hPhi0 : Phi0 X p = 0) :
    N p X = ceilENat (Phi0 X p * Z X p) := by
  have hN : N p X = 0 := (Axioms.A1 p X).mpr hPhi0
  rw [hN, hPhi0, zero_mul]
  unfold ceilENat
  simp

/-- **Theorem T.8 (Emergence Ohm's Law, two-sided form).**

`⌈Φ₀ · Z_min⌉ ≤ N(p, X) ≤ ⌈Φ₀ · Z_max⌉` whenever `N` and `Φ₀` are
finite. -/
theorem T8_two_sided
    (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤) (hPhi : Phi0 X p ≠ ⊤) :
    ceilENat (Phi0 X p * Z_min X p) ≤ N p X
      ∧ N p X ≤ ceilENat (Phi0 X p * Z_max X p) :=
  ⟨T8_lower_bound p X hFin hPhi, T8_upper_bound p X hFin hPhi⟩

/-- **Theorem T.8 (Ohm regime, strict equality).**

`N(p, X) = ⌈Φ₀(X, p) · Z(X, p)⌉` when the state-impedance is uniform
(`Z_min = Z_max`, i.e. σ_Z = 0). -/
theorem T8_OhmLaw
    (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤) (hPhi : Phi0 X p ≠ ⊤)
    (hUniform : Z_min X p = Z_max X p) :
    N p X = ceilENat (Phi0 X p * Z X p) :=
  T8_OhmLaw_core p X hFin hPhi hUniform

end OhmLaw

end MIP
