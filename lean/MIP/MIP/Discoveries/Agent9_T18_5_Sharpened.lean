/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: Sharpened T.18.5 alignment-impossibility — strengthen with the trichotomy.
  SUMMARY:
    T.18.5 (`T18_5_alignment_impossible`) currently says: if `X` is
    "perfectly aligned" (i.e. `∀ p, N p X ≠ ⊤`), then `∀ p, coverage`.
    Combining with the Agent 2 trichotomy and A.1, we get a *stronger*
    consequence: under universal alignment, for every problem, either
    `Phi0 = 0 ∧ N = 0` OR `Phi0 ≠ 0 ∧ 0 < N < ⊤`.

    In other words: a universally aligned agent has a *bivalent*
    `(Phi0, N)` profile across all problems — no `N = ⊤` ever, no
    intermediate `Phi0` regime ever.  This is a sharper non-go: the
    aligned agent's `(Phi0, N)` trace lies on a *one-dimensional*
    sub-manifold of the (Phi0, N) configuration space.

    Bonus joint impossibility: a universally aligned agent CANNOT have
    even a *single* OOD problem in the T.18.6 sense.
-/
import MIP.Axioms
import MIP.Theorems.T18_5_Alignment
import MIP.Theorems.T18_6_ExtrapolationWall

namespace MIP

namespace Agent9_T18_5_Sharpened

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) Bivalent (Phi0, N) profile under universal alignment. -/

/-- **Sharpened T.18.5: bivalent (Phi0, N) under universal alignment.**

If `X` satisfies `∀ p, N p X ≠ ⊤` (universal alignment, T.18.5
hypothesis), then for every problem `p`, EITHER `(Phi0 X p = 0 ∧ N p X = 0)`
OR `(Phi0 X p ≠ 0 ∧ 0 < N p X ∧ N p X < ⊤)`. The third regime (R∞:
`N = ⊤`) is universally excluded.

This sharpens `T18_5_alignment_impossible` (which only concludes
coverage) by simultaneously characterising the `(Phi0, N)` regime. -/
theorem T18_5_sharpened_bivalent
    (X : Agent α) (h_perfect : ∀ p : Problem α, N p X ≠ ⊤) :
    ∀ p : Problem α,
      (Phi0 X p = 0 ∧ N p X = 0)
        ∨ (Phi0 X p ≠ 0 ∧ 0 < N p X ∧ N p X < ⊤) := by
  intro p
  have hFin : N p X ≠ ⊤ := h_perfect p
  by_cases hN : N p X = 0
  · -- R0 branch
    exact Or.inl ⟨(Axioms.A1 p X).mp hN, hN⟩
  · -- RP branch
    refine Or.inr ⟨?_, ?_, ?_⟩
    · -- Phi0 ≠ 0 from A.1's contrapositive
      intro hPhi; exact hN ((Axioms.A1 p X).mpr hPhi)
    · -- 0 < N
      exact Ne.lt_of_le' hN bot_le
    · -- N < ⊤
      exact lt_top_iff_ne_top.mpr hFin

/-! ## (2) Universal alignment ⊕ even single OOD problem ⟹ contradiction. -/

/-- **Joint impossibility: universal alignment + single OOD problem.**

No agent can simultaneously be universally aligned (`∀ p, N p X ≠ ⊤`)
AND have any single OOD problem `p_OOD` with no cover in `K X`.

Proof: T.18.6 turns the OOD hypothesis into `N p_OOD X = ⊤`, which
directly contradicts universal `N ≠ ⊤`. -/
theorem T18_5_T18_6_no_aligned_with_OOD
    (X : Agent α)
    (h_perfect : ∀ p : Problem α, N p X ≠ ⊤)
    (p_OOD : Problem α)
    (h_OOD : ∀ R' ∈ (demandFamily p_OOD : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    False := by
  have hTop : N p_OOD X = ⊤ :=
    MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω) p_OOD X h_OOD
  exact h_perfect p_OOD hTop

/-! ## (3) Universal alignment + universal non-triviality ⟹ universal finite positive N. -/

/-- **Universal alignment + universal Phi0 ≠ 0 ⟹ universal finite positive N.**

If `X` is both universally aligned (`∀ p, N p X ≠ ⊤`) AND universally
non-trivial (`∀ p, Phi0 X p ≠ 0`), then for every problem, `0 < N p X ∧ N p X < ⊤`.
The agent's emergence degree is everywhere in the finite-positive regime. -/
theorem aligned_and_nontrivial_implies_finite_positive_N
    (X : Agent α)
    (h_perfect : ∀ p : Problem α, N p X ≠ ⊤)
    (h_nontriv : ∀ p : Problem α, Phi0 X p ≠ 0) :
    ∀ p : Problem α, 0 < N p X ∧ N p X < ⊤ := by
  intro p
  refine ⟨?_, ?_⟩
  · -- 0 < N: A.1's contrapositive on Phi0 ≠ 0.
    have hNne : N p X ≠ 0 := fun h => h_nontriv p ((Axioms.A1 p X).mp h)
    exact Ne.lt_of_le' hNne bot_le
  · exact lt_top_iff_ne_top.mpr (h_perfect p)

/-! ## (4) Contrapositive: any agent with some `N = ⊤` problem is *not* universally aligned. -/

/-- **Contrapositive of T.18.5.** If `X` has any single problem with
`N p X = ⊤` (knowledge-deficient on `p`), then `X` is not universally
aligned in the T.18.5 sense. -/
theorem alignment_witness_refutation
    (X : Agent α) (p₀ : Problem α) (h : N p₀ X = ⊤) :
    ¬ (∀ p : Problem α, N p X ≠ ⊤) := by
  intro h_perfect
  exact h_perfect p₀ h

end Agent9_T18_5_Sharpened

end MIP
