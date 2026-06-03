/-
  STATUS: DISCOVERY
  AGENT: 2
  DIRECTION: Boundary regime N p X = 0 — full characterisation chain.
  SUMMARY:
    Three equivalent ways to say "trivially solvable" for the pair (p, X):
      (a) Phi0 X p = 0          (potential-side)
      (b) N p X = 0              (degree-side)
      (c) [coverage from A.2]    — derivable consequence of (a)/(b).
    We make the equivalence (a) ↔ (b) explicit (it IS Axiom A.1, restated as a
    Prop instance), and we prove the strict implication chain
    (a)/(b) → coverage (combining A.1 and A.2 — coverage is a non-equivalent
    consequence: there exist agents with coverage but Phi0 ≠ 0, namely whenever
    0 < N p X < ⊤). Includes derived facts: N=0 → N ≠ ⊤, N=0 → N < ⊤.
-/
import MIP.Axioms

namespace MIP

namespace Agent2_NZero_Chain

variable {α : Type} {Ω : Type}

/-! ## (1) Trivial chains within `N = 0` -/

/-- `N p X = 0` forces `N p X ≠ ⊤`. (Trivial in `ℕ∞`; useful for chaining
into A.2.) -/
theorem N_zero_imp_N_ne_top
    (p : Problem α) (X : Agent α) (h : N p X = 0) :
    N p X ≠ ⊤ := by
  rw [h]; decide

/-- `N p X = 0` forces `N p X < ⊤`. Lt-form of the previous. -/
theorem N_zero_imp_N_lt_top
    (p : Problem α) (X : Agent α) (h : N p X = 0) :
    N p X < ⊤ := by
  rw [h]; decide

/-! ## (2) `N = 0 → ∃ R' ∈ ℛ(p), R' ⊆ K(X)` — combining A.1 and A.2.

The "trivially-solvable" regime is forced by EITHER side (potential or
degree), and both sides force coverage.  This is the canonical N=0
characterisation that is missing as a standalone result. -/

/-- **N=0 forces coverage.** Direct application of A.2 once we observe
`N = 0 → N ≠ ⊤`. -/
theorem coverage_of_N_zero
    (p : Problem α) (X : Agent α) (h : N p X = 0) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) :=
  (Axioms.A2 (Ω := Ω) p X).mp (N_zero_imp_N_ne_top p X h)

/-- **Phi0=0 forces coverage** — symmetric statement to
`Agent1_A1A2_Phi0Coverage.coverage_of_phi0_zero`, restated to make the
N=0 path explicit. -/
theorem coverage_of_phi0_zero_via_N
    (p : Problem α) (X : Agent α) (hPhi : Phi0 X p = 0) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) :=
  coverage_of_N_zero (Ω := Ω) p X ((Axioms.A1 p X).mpr hPhi)

/-! ## (3) The full N=0 characterisation triangle.

Two equivalent forms (A.1 itself), one strict implication (to coverage). -/

/-- **A.1 restated**: `N p X = 0 ↔ Phi0 X p = 0`. (For convenient use as a
biconditional `Prop` value rather than always applying `Axioms.A1`.) -/
theorem N_zero_iff_phi0_zero (p : Problem α) (X : Agent α) :
    N p X = 0 ↔ Phi0 X p = 0 :=
  Axioms.A1 p X

/-- **Triple-implication chain.** `Phi0 X p = 0 → N p X = 0 → coverage`,
packaged as a chain of three equivalent/consequence forms. -/
theorem N_zero_chain (p : Problem α) (X : Agent α) :
    (Phi0 X p = 0 → N p X = 0)
      ∧ (N p X = 0 → Phi0 X p = 0)
      ∧ (N p X = 0 →
          ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) := by
  refine ⟨?_, ?_, ?_⟩
  · exact (Axioms.A1 p X).mpr
  · exact (Axioms.A1 p X).mp
  · exact coverage_of_N_zero (Ω := Ω) p X

end Agent2_NZero_Chain

end MIP
