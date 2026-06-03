/-
  STATUS: DISCOVERY
  AGENT: R2-9
  DIRECTION: Global "step class" structure: barriers in `B_data p X`
    indexed by step value.
  SUMMARY:
    For each fixed `k : ℕ`, the intersection of "the step-k class" with
    `B_data p X` is either empty (when `k ≥ (N p X).toNat`) or the
    singleton `{b_synth X p k}` (when `k < (N p X).toNat`). Equivalently,
    each step value in `0 .. (N p X).toNat - 1` is occupied by exactly
    one barrier from `B_data p X`. We package this as:
      * `step_class_eq_singleton_or_empty`
      * `step_class_card`: the step-class card is 0 or 1
      * `step_class_disjoint_below`: distinct step classes within
        `B_data` are disjoint singletons.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Filter
import Mathlib.Data.Finset.Card

namespace MIP

namespace R2_Agent9_BData_StepClass

variable {α : Type}

/-! ## (1) The step-k class within `B_data p X`. -/

/-- **Step-k slice**: barriers in `B_data p X` with `s_pre.step = k`. -/
noncomputable def step_class (p : Problem α) (X : Agent α) (k : ℕ) :
    Finset (BarrierData α) :=
  (B_data p X).filter (fun b => b.s_pre.step = k)

/-! ## (2) When `k ≥ (N p X).toNat`, the step-k class is empty. -/

/-- **Out-of-range step is empty.** When `(N p X).toNat ≤ k`, the
step-`k` class in `B_data p X` is empty. -/
theorem step_class_eq_empty_of_ge (p : Problem α) (X : Agent α) (k : ℕ)
    (hk : (N p X).toNat ≤ k) :
    step_class p X k = ∅ := by
  rw [step_class]
  apply Finset.filter_eq_empty_iff.mpr
  intro b hb hStep
  -- b ∈ B_data p X has step < (N p X).toNat
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, heq⟩ := hb
  rw [Finset.mem_range] at hi
  rw [← heq] at hStep
  have : (b_synth X p i).s_pre.step = i := rfl
  rw [this] at hStep
  omega

/-! ## (3) When `k < (N p X).toNat`, the step-k class is `{b_synth X p k}`. -/

/-- **In-range step is a singleton.** When `k < (N p X).toNat`, the
step-`k` class in `B_data p X` equals `{b_synth X p k}`. -/
theorem step_class_eq_singleton_of_lt (p : Problem α) (X : Agent α) (k : ℕ)
    (hk : k < (N p X).toNat) :
    step_class p X k = {b_synth X p k} := by
  apply Finset.ext
  intro b
  rw [step_class, Finset.mem_filter, Finset.mem_singleton]
  constructor
  · rintro ⟨hbMem, hbStep⟩
    unfold B_data at hbMem
    rw [Finset.mem_image] at hbMem
    obtain ⟨i, _, heq⟩ := hbMem
    rw [← heq] at hbStep
    have h_eq : (b_synth X p i).s_pre.step = i := rfl
    rw [h_eq] at hbStep
    rw [← heq, hbStep]
  · intro heq
    refine ⟨?_, ?_⟩
    · rw [heq]
      unfold B_data
      rw [Finset.mem_image]
      exact ⟨k, Finset.mem_range.mpr hk, rfl⟩
    · rw [heq]; rfl

/-! ## (4) The step-class card is 0 or 1. -/

/-- **Step-class is 0 or 1.** -/
theorem step_class_card (p : Problem α) (X : Agent α) (k : ℕ) :
    (step_class p X k).card = if k < (N p X).toNat then 1 else 0 := by
  by_cases hk : k < (N p X).toNat
  · rw [step_class_eq_singleton_of_lt p X k hk, Finset.card_singleton]
    simp [hk]
  · push_neg at hk
    rw [step_class_eq_empty_of_ge p X k hk, Finset.card_empty]
    simp [Nat.not_lt.mpr hk]

/-- **Step-class trichotomy.** Either empty (`card = 0`) or singleton
(`card = 1`). -/
theorem step_class_card_le_one (p : Problem α) (X : Agent α) (k : ℕ) :
    (step_class p X k).card ≤ 1 := by
  rw [step_class_card]
  split <;> simp

/-! ## (5) Disjointness across distinct step values. -/

/-- **Distinct step classes are disjoint.** -/
theorem step_class_disjoint (p : Problem α) (X : Agent α) {k₁ k₂ : ℕ}
    (h : k₁ ≠ k₂) :
    Disjoint (step_class p X k₁) (step_class p X k₂) := by
  rw [Finset.disjoint_left]
  intro b hb₁ hb₂
  rw [step_class, Finset.mem_filter] at hb₁ hb₂
  have h₁ : b.s_pre.step = k₁ := hb₁.2
  have h₂ : b.s_pre.step = k₂ := hb₂.2
  exact h (h₁.symm.trans h₂)

/-! ## (6) Covering: B_data = union of step classes. -/

/-- **B_data is the union of its step classes.** -/
theorem B_data_eq_biUnion_step_class (p : Problem α) (X : Agent α) :
    B_data p X
      = (Finset.range (N p X).toNat).biUnion (fun k => step_class p X k) := by
  apply Finset.ext
  intro b
  rw [Finset.mem_biUnion]
  constructor
  · intro hb
    -- b = b_synth X p i for some i < (N p X).toNat
    -- step value of b is i, hence b ∈ step_class p X i
    unfold B_data at hb
    rw [Finset.mem_image] at hb
    obtain ⟨i, hi, heq⟩ := hb
    rw [Finset.mem_range] at hi
    refine ⟨i, Finset.mem_range.mpr hi, ?_⟩
    rw [step_class, Finset.mem_filter]
    refine ⟨?_, ?_⟩
    · rw [← heq]
      unfold B_data
      rw [Finset.mem_image]
      exact ⟨i, Finset.mem_range.mpr hi, rfl⟩
    · rw [← heq]; rfl
  · rintro ⟨k, _, hbStep⟩
    rw [step_class, Finset.mem_filter] at hbStep
    exact hbStep.1

end R2_Agent9_BData_StepClass

end MIP
