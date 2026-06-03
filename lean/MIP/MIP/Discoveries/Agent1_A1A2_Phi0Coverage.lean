/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.1 ∧ A.2 — chaining "Phi0 = 0" through to coverage and back.
  SUMMARY:
    Existing corollaries (C.1, C.2, C.6, C.8) all use A.2 alone — none chain
    through A.1's `N p X = 0 ↔ Phi0 X p = 0`. We close that gap with four
    derived statements: (i) `Phi0 = 0 → coverage` (cheap win); (ii)
    `no coverage → Phi0 ≠ 0`; (iii) (sharper) `no coverage → N p X = ⊤`,
    which directly forces `Phi0 X p ≠ 0` whenever the agent has any positive
    potential, and (iv) the symmetric "trichotomy under coverage" stating
    that when SOME demand is covered AND `Phi0 ≠ 0`, the emergence degree is
    a genuine positive natural (strictly between 0 and ⊤). None of these are
    in `Corollaries/` or `Results/`.
-/
import MIP.Axioms

namespace MIP

namespace Agent1_A1A2_Phi0Coverage

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (i) `Phi0 = 0 → coverage` — the "cheap win"

The hop `Phi0 = 0 ⟹(A.1) N = 0 ⟹ N ≠ ⊤ ⟹(A.2) ∃ R' ∈ ℛ(p), R' ⊆ K(X)`
needs both axioms; neither alone suffices. -/

/-- **Phi0-zero forces coverage.** If `Phi0 X p = 0` then `N p X = 0 ≠ ⊤`,
hence by A.2 some demand `R' ∈ ℛ(p)` is covered by `K X`. -/
theorem coverage_of_phi0_zero
    (p : Problem α) (X : Agent α)
    (hPhi : Phi0 X p = 0) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) := by
  have hN : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  have hNe : N p X ≠ ⊤ := by rw [hN]; decide
  exact (Axioms.A2 (Ω := Ω) p X).mp hNe

/-! ## (ii) `no coverage → Phi0 ≠ 0` (the contrapositive). -/

/-- **No coverage forces `Phi0 ≠ 0`.** Contrapositive of (i). -/
theorem phi0_ne_zero_of_no_coverage
    (p : Problem α) (X : Agent α)
    (hNoCov : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    Phi0 X p ≠ 0 := by
  intro hPhi
  exact hNoCov (coverage_of_phi0_zero (Ω := Ω) p X hPhi)

/-! ## (iii) Stronger: no coverage forces `N = ⊤`, not just `N ≠ 0`. -/

/-- **No coverage forces `N p X = ⊤`.** Direct contrapositive of A.2's `⟸`,
*not* of A.1+A.2 — this is the A.2-only kernel that exists in `C2_Solvability`
(see `Corollary_C2.no_cover_of_infinite`). We restate it here as a stepping
stone for the next theorem (`N_positive_finite_of_coverage_and_nonzero`),
where it gets combined with A.1.  This particular form (returning `N = ⊤`
rather than the negation of the existential) is the version we need for the
trichotomy below. -/
theorem N_top_of_no_coverage
    (p : Problem α) (X : Agent α)
    (hNoCov : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    N p X = ⊤ := by
  by_contra hNe
  exact hNoCov ((Axioms.A2 (Ω := Ω) p X).mp hNe)

/-! ## (iv) Trichotomy: coverage + `Phi0 ≠ 0` ⟹ `N ∈ {1, 2, …}`

This is the genuinely new statement that needs both A.1 and A.2: under
coverage A.2 gives `N ≠ ⊤`, and under `Phi0 ≠ 0` A.1 gives `N ≠ 0`. So
`N` is a genuine positive natural — strictly between `0` and `⊤`. -/

/-- **Genuine positive finite emergence degree.** If both
* some `R' ∈ ℛ(p)` is covered by `K X` (A.2 hypothesis), and
* `Phi0 X p ≠ 0` (A.1 hypothesis),

then `N p X` is a positive finite natural: `0 < N p X` AND `N p X < ⊤`. -/
theorem N_positive_finite_of_coverage_and_nonzero
    (p : Problem α) (X : Agent α)
    (hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
    (hPhi : Phi0 X p ≠ 0) :
    0 < N p X ∧ N p X < ⊤ := by
  refine ⟨?_, ?_⟩
  · -- 0 < N: from A.1's contrapositive, N ≠ 0; for ℕ∞, 0 < x ↔ x ≠ 0.
    have hNne : N p X ≠ 0 := fun h => hPhi ((Axioms.A1 p X).mp h)
    exact Ne.lt_of_le' hNne bot_le
  · -- N < ⊤: from A.2, N ≠ ⊤; for ℕ∞, x < ⊤ ↔ x ≠ ⊤.
    have hNeTop : N p X ≠ ⊤ := (Axioms.A2 (Ω := Ω) p X).mpr hCov
    exact lt_top_iff_ne_top.mpr hNeTop

/-- **Trichotomy law on `N`.**  Under coverage, `N` is bivalent between `0`
and a positive finite value, distinguished by `Phi0`.  Stated as a
case-split: either `Phi0 = 0` and `N = 0`, or `Phi0 ≠ 0` and `0 < N < ⊤`. -/
theorem N_trichotomy_under_coverage
    (p : Problem α) (X : Agent α)
    (hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    (Phi0 X p = 0 ∧ N p X = 0)
      ∨ (Phi0 X p ≠ 0 ∧ 0 < N p X ∧ N p X < ⊤) := by
  by_cases hPhi : Phi0 X p = 0
  · exact Or.inl ⟨hPhi, (Axioms.A1 p X).mpr hPhi⟩
  · refine Or.inr ⟨hPhi, ?_, ?_⟩
    · exact (N_positive_finite_of_coverage_and_nonzero (Ω := Ω) p X hCov hPhi).1
    · exact (N_positive_finite_of_coverage_and_nonzero (Ω := Ω) p X hCov hPhi).2

/-- **Coverage-based biconditional.** Under coverage, `Phi0 X p = 0` is
*equivalent* to `N p X = 0`.  (The A.1 biconditional, restated in a form
that emphasises the role of the A.2 hypothesis as removing the `N = ⊤`
escape.) -/
theorem phi0_zero_iff_N_zero_under_coverage
    (p : Problem α) (X : Agent α)
    (_hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    Phi0 X p = 0 ↔ N p X = 0 :=
  (Axioms.A1 p X).symm

/-- **Sharper restatement.**  Under coverage, the two extreme cases for `N`
collapse: `N = ⊤` is impossible (A.2), so the trichotomy of `ℕ∞` `{0, n>0, ⊤}`
reduces to the dichotomy `{0, n>0}`, and A.1 identifies which case via `Phi0`. -/
theorem N_dichotomy_under_coverage
    (p : Problem α) (X : Agent α)
    (hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    N p X = 0 ∨ 0 < N p X ∧ N p X < ⊤ := by
  rcases N_trichotomy_under_coverage (Ω := Ω) p X hCov with ⟨_, h⟩ | ⟨_, h1, h2⟩
  · exact Or.inl h
  · exact Or.inr ⟨h1, h2⟩

end Agent1_A1A2_Phi0Coverage

end MIP
