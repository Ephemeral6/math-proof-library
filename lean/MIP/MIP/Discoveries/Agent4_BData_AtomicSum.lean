/-
  STATUS: DISCOVERY
  AGENT: 4
  DIRECTION: Total atomic count over `B_data` equals `(N p X).toNat`.
  SUMMARY:
    `BarrierData.atomicDecomp b = {b}` in the concrete model (so each
    atomic decomposition has cardinality 1). Summing this card over every
    barrier in `B_data p X` therefore gives exactly `(B_data p X).card`,
    which equals `(N p X).toNat`. This is the L.2 "atomic-expansion
    preserves count" fact, never stated as an explicit Finset.sum lemma.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

namespace Agent4_BData_AtomicSum

variable {α : Type}

/-! ## (1) Atomic decomposition card is always 1. -/

/-- **`b.atomicDecomp` is a singleton**: cardinality 1 for every barrier.
This is forced by the concrete-model choice `atomicDecomp b := {b}`. -/
@[simp] theorem atomicDecomp_card (b : BarrierData α) :
    b.atomicDecomp.card = 1 := by
  unfold BarrierData.atomicDecomp
  exact Finset.card_singleton _

/-! ## (2) Total atomic count over `B_data`. -/

/-- **Total atomic-decomposition count equals `(N p X).toNat`.**
Summing the atomic-decomposition cardinalities over every barrier in
`B_data p X` gives `(N p X).toNat` — the L.2 atomic-expansion does not
inflate or deflate the count in this concrete model. -/
theorem B_data_atomicDecomp_sum_eq (p : Problem α) (X : Agent α) :
    (∑ b ∈ B_data p X, b.atomicDecomp.card) = (N p X).toNat := by
  -- Each summand is 1; the sum is just |B_data|.
  have hSum : (∑ _b ∈ B_data p X, (1 : ℕ)) = (B_data p X).card := by
    rw [Finset.sum_const, Nat.smul_one_eq_cast]
    simp
  have hRewrite : (∑ b ∈ B_data p X, b.atomicDecomp.card)
      = (∑ _b ∈ B_data p X, (1 : ℕ)) := by
    apply Finset.sum_congr rfl
    intro b _
    exact atomicDecomp_card b
  rw [hRewrite, hSum]
  -- and (B_data p X).card = (N p X).toNat
  unfold B_data
  rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
  exact Finset.card_range _

/-- **ENat-form**: when `N p X ≠ ⊤`, the atomic-sum cast to ℕ∞ equals
`N p X`. -/
theorem B_data_atomicDecomp_sum_eq_N
    (p : Problem α) (X : Agent α) (hFin : N p X ≠ ⊤) :
    ((∑ b ∈ B_data p X, b.atomicDecomp.card : ℕ) : ℕ∞) = N p X := by
  rw [B_data_atomicDecomp_sum_eq p X]
  exact ENat.coe_toNat hFin

/-! ## (3) Atomic decomp as union: the disjoint union over `B_data` of
`atomicDecomp` is just `B_data` itself (since each `atomicDecomp` is
`{b}`). We record the equality as a `simp` lemma. -/

/-- **Atomic biUnion equals `B_data`** (since each atomic decomp is a
singleton). -/
theorem B_data_atomicDecomp_biUnion (p : Problem α) (X : Agent α) :
    ((B_data p X).biUnion fun b => b.atomicDecomp) = B_data p X := by
  apply Finset.ext
  intro b
  rw [Finset.mem_biUnion]
  refine ⟨?_, ?_⟩
  · rintro ⟨b', hb', hmem⟩
    unfold BarrierData.atomicDecomp at hmem
    rw [Finset.mem_singleton] at hmem
    rw [hmem]; exact hb'
  · intro hMem
    refine ⟨b, hMem, ?_⟩
    unfold BarrierData.atomicDecomp
    exact Finset.mem_singleton.mpr rfl

end Agent4_BData_AtomicSum

end MIP
