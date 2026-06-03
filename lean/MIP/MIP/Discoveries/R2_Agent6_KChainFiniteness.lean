/-
  STATUS: DISCOVERY
  AGENT: R2-6
  DIRECTION: Sharpen multi-agent N-finiteness transitivity along K-chains.
             Agent 8 had 3-agent chains; we add the 4-agent chain and a
             general k-agent (finset-indexed) chain via induction.
  SUMMARY:
    `Agent8_ThreeAgent_Chain.ne_top_chain` propagates A.2 finiteness along
    `K A ⊆ K B ⊆ K C`. We extend to:

      (1) 4-agent chain  `K A ⊆ K B ⊆ K C ⊆ K D → N p A ≠ ⊤
                         → N p B ≠ ⊤ ∧ N p C ≠ ⊤ ∧ N p D ≠ ⊤`
      (2) k-agent indexed-family chain over a `Finset` of indices:
          if `f 0 ≠ ⊤` and `K (f i) ⊆ K (f (i+1))` along a finite path,
          then `f j ≠ ⊤` for every `j` reachable from `0`.
      (3) Star form: if a single agent `A_0` has `N p A_0 ≠ ⊤` and every
          agent in a finset `S` dominates `A_0` by K-inclusion, then EVERY
          agent in `S` is A.2-finite.

    These are pure A.2 corollaries, but the finset-indexed form
    `ne_top_of_dominates_finset` and the inductive linear-chain
    `ne_top_finset_chain` give a uniform statement that the Agent 8
    triple did not surface.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Data.Finset.Basic

namespace MIP

namespace R2_Agent6_KChainFiniteness

variable {α : Type} {Ω : Type}

/-! ## (0) Re-derivation of the two-agent kernel (self-contained). -/

/-- **Two-agent finiteness transfer (re-derivation of `Corollary_C6`).** -/
theorem ne_top_of_subset
    (p : Problem α) (A B : Agent α)
    (hK : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p A).mp hA
  exact (Axioms.A2 (Ω := Ω) p B).mpr ⟨R', hMem, hSub.trans hK⟩

/-! ## (1) Four-agent chain. -/

/-- **Four-agent finiteness chain.** If `K A ⊆ K B ⊆ K C ⊆ K D` and
`N p A ≠ ⊤`, then `N p B`, `N p C`, `N p D` are all `≠ ⊤`. -/
theorem ne_top_chain_four
    (p : Problem α) (A B C D : Agent α)
    (hAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hBC : (K B : Set Ω) ⊆ (K C : Set Ω))
    (hCD : (K C : Set Ω) ⊆ (K D : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ ∧ N p C ≠ ⊤ ∧ N p D ≠ ⊤ := by
  have hB : N p B ≠ ⊤ := ne_top_of_subset (Ω := Ω) p A B hAB hA
  have hC : N p C ≠ ⊤ := ne_top_of_subset (Ω := Ω) p B C hBC hB
  have hD : N p D ≠ ⊤ := ne_top_of_subset (Ω := Ω) p C D hCD hC
  exact ⟨hB, hC, hD⟩

/-- **Four-agent top-status backward chain.** Contrapositive. -/
theorem top_chain_four
    (p : Problem α) (A B C D : Agent α)
    (hAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hBC : (K B : Set Ω) ⊆ (K C : Set Ω))
    (hCD : (K C : Set Ω) ⊆ (K D : Set Ω))
    (hD : N p D = ⊤) :
    N p A = ⊤ ∧ N p B = ⊤ ∧ N p C = ⊤ := by
  refine ⟨?_, ?_, ?_⟩
  · by_contra hA
    have ⟨_, _, hD'⟩ := ne_top_chain_four (Ω := Ω) p A B C D hAB hBC hCD hA
    exact hD' hD
  · by_contra hB
    have hC : N p C ≠ ⊤ := ne_top_of_subset (Ω := Ω) p B C hBC hB
    have hD' : N p D ≠ ⊤ := ne_top_of_subset (Ω := Ω) p C D hCD hC
    exact hD' hD
  · by_contra hC
    have hD' : N p D ≠ ⊤ := ne_top_of_subset (Ω := Ω) p C D hCD hC
    exact hD' hD

/-! ## (2) Direct A-to-D shortcut via inclusion transitivity. -/

/-- **Direct A-to-D finiteness.** A single A.2 step on the transitive
inclusion. -/
theorem ne_top_chain_four_direct
    (p : Problem α) (A D : Agent α)
    (hAD : (K A : Set Ω) ⊆ (K D : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p D ≠ ⊤ :=
  ne_top_of_subset (Ω := Ω) p A D hAD hA

/-! ## (3) k-agent star: one finite agent + many K-dominators. -/

/-- **Star form: one finite source, many K-dominators.** Given a finset
of agents `S`, if some agent `A0` satisfies `N p A0 ≠ ⊤` and every agent
`X ∈ S` has `K A0 ⊆ K X`, then `N p X ≠ ⊤` for every `X ∈ S`. -/
theorem ne_top_of_dominates_finset
    (p : Problem α) (A0 : Agent α)
    (S : Finset (Agent α))
    (hDom : ∀ X ∈ S, (K A0 : Set Ω) ⊆ (K X : Set Ω))
    (hA0 : N p A0 ≠ ⊤) :
    ∀ X ∈ S, N p X ≠ ⊤ := by
  intro X hX
  exact ne_top_of_subset (Ω := Ω) p A0 X (hDom X hX) hA0

/-- **Star form, ∀X∈S → N p X ≠ ⊤ via a single shared witness.** Bundles
the existential witness produced by A.2.mp once and re-uses it. -/
theorem ne_top_finset_shared_witness
    (p : Problem α) (A0 : Agent α)
    (S : Finset (Agent α))
    (hDom : ∀ X ∈ S, (K A0 : Set Ω) ⊆ (K X : Set Ω))
    (hA0 : N p A0 ≠ ⊤) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      ∀ X ∈ S, R' ⊆ (K X : Set Ω) := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p A0).mp hA0
  refine ⟨R', hMem, ?_⟩
  intro X hX
  exact hSub.trans (hDom X hX)

/-! ## (4) Indexed family: chain along ℕ-indexed agents. -/

/-- **Indexed chain of finiteness.** Given `f : ℕ → Agent α` with
consecutive K-inclusion `K (f i) ⊆ K (f (i+1))` for all `i < n`, if
`N p (f 0) ≠ ⊤`, then `N p (f k) ≠ ⊤` for every `k ≤ n`. -/
theorem ne_top_indexed_chain
    (p : Problem α) (f : ℕ → Agent α) :
    ∀ n : ℕ,
      (∀ i < n, (K (f i) : Set Ω) ⊆ (K (f (i+1)) : Set Ω))
      → N p (f 0) ≠ ⊤
      → ∀ k ≤ n, N p (f k) ≠ ⊤
  | 0 => by
      intro _ h0 k hk
      obtain rfl : k = 0 := Nat.le_zero.mp hk
      exact h0
  | n + 1 => by
      intro hChain h0 k hk
      rcases Nat.lt_or_ge k (n + 1) with hk' | hk'
      · -- k ≤ n: use induction hypothesis with restricted chain
        have hChain' : ∀ i < n, (K (f i) : Set Ω) ⊆ (K (f (i+1)) : Set Ω) := by
          intro i hi
          exact hChain i (by omega)
        exact ne_top_indexed_chain p f n hChain' h0 k (Nat.le_of_lt_succ hk')
      · -- k = n+1: get f n finite, then step via hChain n
        have hkeq : k = n + 1 := le_antisymm hk hk'
        have hChain' : ∀ i < n, (K (f i) : Set Ω) ⊆ (K (f (i+1)) : Set Ω) := by
          intro i hi
          exact hChain i (by omega)
        have hn : N p (f n) ≠ ⊤ :=
          ne_top_indexed_chain p f n hChain' h0 n (le_refl n)
        have hStep : (K (f n) : Set Ω) ⊆ (K (f (n+1)) : Set Ω) :=
          hChain n (Nat.lt_succ_self n)
        rw [hkeq]
        exact ne_top_of_subset (Ω := Ω) p (f n) (f (n+1)) hStep hn

end R2_Agent6_KChainFiniteness

end MIP
