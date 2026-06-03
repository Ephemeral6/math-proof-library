/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: A.1's joint-failure mode — the (N, Phi0) Cartesian product has only 2 of 4 quadrants realisable.
  SUMMARY:
    A.1 (`N = 0 ↔ Phi0 = 0`) implicitly rules out two of the four
    quadrants of the (N-zero?, Phi0-zero?) Cartesian product:
      Quadrant   |  N = 0?  |  Phi0 = 0?  |  realisable?
        Q1 (=,=)   yes        yes           ✓ (R0)
        Q2 (=,≠)   yes        no            ✗ (A.1.mp)
        Q3 (≠,=)   no         yes           ✗ (A.1.mpr)
        Q4 (≠,≠)   no         no            ✓ (RP ∪ R∞)
    We package this as a sharper *non-go* statement — the diagonal-only
    realisability of (N=0?, Phi0=0?). The strictly off-diagonal pair
    `(N = 0, Phi0 ≠ 0)` is impossible; so is `(N ≠ 0, Phi0 = 0)`.
    These are the two A.1-induced impossibilities, derived as crisp
    `False`-conclusion lemmas.

    Bonus theorem: the joint-degree map `X ↦ (N p X = 0, Phi0 X p = 0)`
    factors through the diagonal — i.e. its image lies in
    `{(true, true), (false, false)}`, never on the off-diagonal.
-/
import MIP.Axioms

namespace MIP

namespace Agent9_NPhi0_JointFailures

variable {α : Type}

/-! ## (1) Off-diagonal Q2: `N = 0 ∧ Phi0 ≠ 0` is impossible. -/

/-- **Impossibility of `(N = 0, Phi0 ≠ 0)`.**

If `N p X = 0` then A.1.mp gives `Phi0 X p = 0`, contradicting `Phi0 ≠ 0`. -/
theorem impossible_N0_Phi0_nonzero
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0) (hPhi : Phi0 X p ≠ 0) : False :=
  hPhi ((Axioms.A1 p X).mp hN)

/-! ## (2) Off-diagonal Q3: `N ≠ 0 ∧ Phi0 = 0` is impossible. -/

/-- **Impossibility of `(N ≠ 0, Phi0 = 0)`.**

If `Phi0 X p = 0` then A.1.mpr gives `N p X = 0`, contradicting `N ≠ 0`. -/
theorem impossible_Nnonzero_Phi0_zero
    (p : Problem α) (X : Agent α)
    (hN : N p X ≠ 0) (hPhi : Phi0 X p = 0) : False :=
  hN ((Axioms.A1 p X).mpr hPhi)

/-! ## (3) Both off-diagonals are impossible — the diagonal lemma. -/

/-- **A.1 diagonal lemma.** `N p X = 0` and `Phi0 X p = 0` agree as truth
values. Equivalently: the map `X ↦ (N p X = 0, Phi0 X p = 0)` lies in
`{(true, true), (false, false)}`. -/
theorem N_zero_Phi0_zero_diagonal (p : Problem α) (X : Agent α) :
    (N p X = 0) ↔ (Phi0 X p = 0) :=
  Axioms.A1 p X

/-- **Diagonal-only realisability.** The truth values of `N p X = 0` and
`Phi0 X p = 0` always agree. -/
theorem N_zero_iff_Phi0_zero (p : Problem α) (X : Agent α) :
    (decide (N p X = 0)) = (decide (Phi0 X p = 0)) := by
  by_cases h : N p X = 0
  · have h' : Phi0 X p = 0 := (Axioms.A1 p X).mp h
    simp [h, h']
  · have h' : Phi0 X p ≠ 0 := fun hPhi => h ((Axioms.A1 p X).mpr hPhi)
    simp [h, h']

/-! ## (4) The bundled "no off-diagonal" theorem. -/

/-- **Bundled off-diagonal impossibility.** Neither off-diagonal pair is
realisable.  Stated as a `¬ (∨)`. -/
theorem off_diagonal_impossible (p : Problem α) (X : Agent α) :
    ¬ ((N p X = 0 ∧ Phi0 X p ≠ 0) ∨ (N p X ≠ 0 ∧ Phi0 X p = 0)) := by
  rintro (⟨hN, hPhi⟩ | ⟨hN, hPhi⟩)
  · exact impossible_N0_Phi0_nonzero p X hN hPhi
  · exact impossible_Nnonzero_Phi0_zero p X hN hPhi

/-! ## (5) Sharper: the joint pair lies in `{(0,0), (≠0,≠0)}`.

This is the same content as `off_diagonal_impossible`, but stated as
the *positive* dichotomy: exactly one of `(N=0 ∧ Phi0=0)` and
`(N≠0 ∧ Phi0≠0)` holds. -/

/-- **Joint dichotomy on (N, Phi0).** For any `(p, X)`, exactly one of:
    * `(N p X = 0 ∧ Phi0 X p = 0)`         — the trivially-solvable case
    * `(N p X ≠ 0 ∧ Phi0 X p ≠ 0)`         — the non-trivial case
is realisable.  This is A.1's "no off-diagonal" content stated
positively. -/
theorem N_Phi0_dichotomy (p : Problem α) (X : Agent α) :
    (N p X = 0 ∧ Phi0 X p = 0)
      ∨ (N p X ≠ 0 ∧ Phi0 X p ≠ 0) := by
  by_cases h : N p X = 0
  · exact Or.inl ⟨h, (Axioms.A1 p X).mp h⟩
  · refine Or.inr ⟨h, ?_⟩
    intro hPhi
    exact h ((Axioms.A1 p X).mpr hPhi)

end Agent9_NPhi0_JointFailures

end MIP
