/-
  STATUS: DISCOVERY
  AGENT: 2
  DIRECTION: Full unconditional trichotomy on N — the headline boundary theorem.
  SUMMARY:
    Combining A.1 (N=0 ↔ Phi0=0) and A.2 (N≠⊤ ↔ coverage), every pair (p, X)
    falls into exactly one of three regimes:
      (R0) N = 0       — trivially solvable: Phi0 = 0 ∧ coverage exists.
      (RP) 0 < N < ⊤   — finitely emergent: Phi0 ≠ 0 ∧ coverage exists.
      (R∞) N = ⊤       — knowledge-deficient: Phi0 ≠ 0 ∧ ¬ ∃ R'⊆K(X) in ℛ(p).
    This is the FULL trichotomy proposed in the briefing — provable from
    A.1 + A.2 alone, no extra hypotheses. We use `Phi0 X p ≠ 0` rather
    than `> 0` (which would need `Phi0 X p ≠ ⊤`, a stronger ENNReal fact).
    Agent 1 proved a *coverage-conditional* dichotomy; we prove the
    *unconditional* trichotomy.
-/
import MIP.Axioms

namespace MIP

namespace Agent2_NTrichotomy_Full

variable {α : Type} {Ω : Type}

/-- **N trichotomy (full, unconditional).**

Every (problem, agent) pair falls into exactly one of:

* **(R0)** `N = 0 ∧ Phi0 = 0 ∧ (∃ R' ∈ ℛ(p), R' ⊆ K X)`  (trivially solvable),
* **(RP)** `0 < N ∧ N < ⊤ ∧ Phi0 ≠ 0 ∧ (∃ R' ∈ ℛ(p), R' ⊆ K X)`  (positively emergent),
* **(R∞)** `N = ⊤ ∧ Phi0 ≠ 0 ∧ ∀ R' ∈ ℛ(p), ¬ R' ⊆ K X`  (knowledge-deficient).

Provable from A.1 + A.2 alone. -/
theorem N_trichotomy (p : Problem α) (X : Agent α) :
    (N p X = 0 ∧ Phi0 X p = 0
        ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)))
      ∨ (0 < N p X ∧ N p X < ⊤ ∧ Phi0 X p ≠ 0
        ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)))
      ∨ (N p X = ⊤ ∧ Phi0 X p ≠ 0
        ∧ ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) := by
  by_cases hTop : N p X = ⊤
  · -- (R∞) case
    refine Or.inr (Or.inr ⟨hTop, ?_, ?_⟩)
    · -- Phi0 ≠ 0: contrapositive of A.1
      intro hPhi
      have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
      rw [hTop] at hN0
      exact ENat.top_ne_zero hN0
    · -- ∀ R', ¬ ⊆ : contrapositive of A.2.mpr
      intro R' hR' hSub
      have : N p X ≠ ⊤ := (Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hR', hSub⟩
      exact this hTop
  · -- N ≠ ⊤ → coverage by A.2
    have hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) :=
      (Axioms.A2 (Ω := Ω) p X).mp hTop
    by_cases hZero : N p X = 0
    · -- (R0) case
      have hPhi : Phi0 X p = 0 := (Axioms.A1 p X).mp hZero
      exact Or.inl ⟨hZero, hPhi, hCov⟩
    · -- (RP) case: 0 < N < ⊤
      refine Or.inr (Or.inl ⟨?_, ?_, ?_, hCov⟩)
      · -- 0 < N: in ℕ∞, x ≠ 0 → 0 < x
        exact Ne.lt_of_le' hZero bot_le
      · -- N < ⊤: from N ≠ ⊤
        exact lt_top_iff_ne_top.mpr hTop
      · -- Phi0 ≠ 0: from N ≠ 0 + A.1
        intro hPhi
        exact hZero ((Axioms.A1 p X).mpr hPhi)

/-! ## Disjointness: the three regimes are pairwise exclusive. -/

/-- The three regimes' first conjuncts (N=0, 0<N<⊤, N=⊤) are pairwise
disjoint by trichotomy on `ℕ∞`. We record this as a sanity check. -/
theorem regimes_disjoint (p : Problem α) (X : Agent α) :
    ¬ (N p X = 0 ∧ 0 < N p X)
      ∧ ¬ (N p X = 0 ∧ N p X = ⊤)
      ∧ ¬ (N p X < ⊤ ∧ N p X = ⊤) := by
  refine ⟨?_, ?_, ?_⟩
  · rintro ⟨h0, hPos⟩
    rw [h0] at hPos
    exact absurd hPos (by decide)
  · rintro ⟨h0, hTop⟩
    rw [h0] at hTop
    exact ENat.top_ne_zero hTop.symm
  · rintro ⟨hLt, hTop⟩
    rw [hTop] at hLt
    exact lt_irrefl _ hLt

/-! ## Coverage-form trichotomy: the (∃ R') ∨ (∀ R', ¬) split. -/

/-- **Coverage dichotomy** (consequence of the trichotomy): either some demand
is covered, or no demand is covered. Trivial by excluded middle but the
A.1 + A.2 contribution is that the side coincides with `N < ⊤ ↔ N = ⊤`. -/
theorem coverage_dichotomy (p : Problem α) (X : Agent α) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
      ∨ (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) := by
  by_cases hTop : N p X = ⊤
  · refine Or.inr ?_
    intro R' hR' hSub
    have : N p X ≠ ⊤ := (Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hR', hSub⟩
    exact this hTop
  · exact Or.inl ((Axioms.A2 (Ω := Ω) p X).mp hTop)

end Agent2_NTrichotomy_Full

end MIP
