/-
  STATUS: DISCOVERY
  AGENT: R2-6
  DIRECTION: The "demand-realiser" set `realisers p X := {R' ∈ ℛ(p) |
    R' ⊆ K X}` is monotone in `K X`, and `N p X ≠ ⊤ ↔ realisers p X
    is nonempty`. Both are immediate from A.2 and set transitivity, but
    naming them as bundled lemmas makes downstream multi-agent statements
    much cleaner.
  SUMMARY:
    A.2 states `N p X ≠ ⊤ ↔ ∃ R' ∈ ℛ(p), R' ⊆ K X`. The set on the right
    we name `realisers p X`. The key facts:

      (i)   `realisers_mono`: `K A ⊆ K B → realisers p A ⊆ realisers p B`
      (ii)  `N_finite_iff_realisers_nonempty`: `N p X ≠ ⊤ ↔
                  (realisers p X).Nonempty`
      (iii) `N_zero_imp_realisers_nonempty`: corollary, since `N = 0
                  → N ≠ ⊤`.
      (iv)  K-equality form: `K A = K B → realisers p A = realisers p B`
            (true antisymmetry of `⊆` on `realisers`).
      (v)   Three-agent monotone chain: `K A ⊆ K B ⊆ K C → realisers p A
                  ⊆ realisers p B ⊆ realisers p C`.

    The `realisers` set is also a clean witness for the `K`-preorder of
    agents to "lift" to a `⊆`-preorder on `Set (Set Ω)`.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic

namespace MIP

namespace R2_Agent6_RealisersTransport

variable {α : Type} {Ω : Type}

/-! ## (1) Definition of `realisers`. -/

/-- The set of demand-realisers for agent `X` on problem `p`: members of
`ℛ(p)` that are contained in `K X`. -/
def realisers (p : Problem α) (X : Agent α) : Set (Set Ω) :=
  { R' | R' ∈ (demandFamily p : Set (Set Ω)) ∧ R' ⊆ (K X : Set Ω) }

/-! ## (2) Monotonicity in `K X`. -/

/-- **`realisers` is monotone in K-containment.** If `K A ⊆ K B`, then
`realisers p A ⊆ realisers p B`. -/
theorem realisers_mono
    (p : Problem α) (A B : Agent α)
    (hKAB : (K A : Set Ω) ⊆ (K B : Set Ω)) :
    realisers (Ω := Ω) p A ⊆ realisers (Ω := Ω) p B := by
  intro R' hR'
  exact ⟨hR'.1, hR'.2.trans hKAB⟩

/-! ## (3) Restating A.2 in terms of realisers. -/

/-- **N-finiteness ⟺ realisers nonempty.** This is precisely A.2,
rephrased. -/
theorem N_finite_iff_realisers_nonempty
    (p : Problem α) (X : Agent α) :
    N p X ≠ ⊤ ↔ (realisers (Ω := Ω) p X).Nonempty := by
  rw [Axioms.A2 (Ω := Ω) p X]
  constructor
  · rintro ⟨R', hMem, hSub⟩
    exact ⟨R', hMem, hSub⟩
  · rintro ⟨R', hMem, hSub⟩
    exact ⟨R', hMem, hSub⟩

/-- **`N p X = 0 → realisers p X nonempty`.** Immediate from
A.1 + N-finiteness equivalence. -/
theorem N_zero_imp_realisers_nonempty
    (p : Problem α) (X : Agent α)
    (h : N p X = 0) :
    (realisers (Ω := Ω) p X).Nonempty := by
  apply (N_finite_iff_realisers_nonempty (Ω := Ω) p X).mp
  rw [h]; decide

/-! ## (4) K-equality form. -/

/-- **K-equality ⟹ realisers equal.** Antisymmetry of `⊆` lifted through
`realisers_mono` both ways. -/
theorem realisers_eq_of_K_eq
    (p : Problem α) (A B : Agent α)
    (hK : (K A : Set Ω) = (K B : Set Ω)) :
    realisers (Ω := Ω) p A = realisers (Ω := Ω) p B := by
  apply Set.Subset.antisymm
  · exact realisers_mono (Ω := Ω) p A B hK.subset
  · exact realisers_mono (Ω := Ω) p B A hK.symm.subset

/-! ## (5) Three-agent chain. -/

/-- **Three-agent monotone chain for realisers.** -/
theorem realisers_chain
    (p : Problem α) (A B C : Agent α)
    (hAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hBC : (K B : Set Ω) ⊆ (K C : Set Ω)) :
    realisers (Ω := Ω) p A ⊆ realisers (Ω := Ω) p B ∧
      realisers (Ω := Ω) p B ⊆ realisers (Ω := Ω) p C := by
  exact ⟨realisers_mono (Ω := Ω) p A B hAB,
         realisers_mono (Ω := Ω) p B C hBC⟩

/-! ## (6) Multi-agent: realisers for an intersection of K's are the
    common realisers. -/

/-- **Triple-intersection realisers = triple common realisers.** A
demand `R'` is in `realisers p A`, `realisers p B`, AND `realisers p C`
iff it sits inside `K A ∩ K B ∩ K C` (and is a demand member). This is
the realisers-level identity matching `Agent8_TriangleWitness`. -/
theorem mem_triple_realisers_iff
    (p : Problem α) (A B C : Agent α) (R' : Set Ω) :
    (R' ∈ realisers (Ω := Ω) p A ∧
      R' ∈ realisers (Ω := Ω) p B ∧
      R' ∈ realisers (Ω := Ω) p C)
      ↔ R' ∈ (demandFamily p : Set (Set Ω)) ∧
          R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) ∩ (K C : Set Ω) := by
  constructor
  · rintro ⟨⟨hMem, hA⟩, ⟨_, hB⟩, ⟨_, hC⟩⟩
    refine ⟨hMem, ?_⟩
    exact Set.subset_inter (Set.subset_inter hA hB) hC
  · rintro ⟨hMem, hSub⟩
    have hA : R' ⊆ (K A : Set Ω) := hSub.trans (Set.inter_subset_left.trans Set.inter_subset_left)
    have hB : R' ⊆ (K B : Set Ω) := hSub.trans (Set.inter_subset_left.trans Set.inter_subset_right)
    have hC : R' ⊆ (K C : Set Ω) := hSub.trans Set.inter_subset_right
    exact ⟨⟨hMem, hA⟩, ⟨hMem, hB⟩, ⟨hMem, hC⟩⟩

/-! ## (7) Anti-monotone consequence on top-status. -/

/-- **Empty realisers ⟺ N = ⊤.** -/
theorem realisers_empty_iff_top
    (p : Problem α) (X : Agent α) :
    realisers (Ω := Ω) p X = ∅ ↔ N p X = ⊤ := by
  constructor
  · intro hEmpty
    by_contra hNeTop
    have ⟨R', hR'⟩ := (N_finite_iff_realisers_nonempty (Ω := Ω) p X).mp hNeTop
    rw [hEmpty] at hR'
    exact hR'.elim
  · intro hTop
    by_contra hNonEmpty
    have hNE : (realisers (Ω := Ω) p X).Nonempty := Set.nonempty_iff_ne_empty.mpr hNonEmpty
    have hNeTop : N p X ≠ ⊤ :=
      (N_finite_iff_realisers_nonempty (Ω := Ω) p X).mpr hNE
    exact hNeTop hTop

end R2_Agent6_RealisersTransport

end MIP
