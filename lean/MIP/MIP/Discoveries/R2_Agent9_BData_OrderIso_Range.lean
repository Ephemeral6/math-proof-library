/-
  STATUS: DISCOVERY
  AGENT: R2-9
  DIRECTION: `B_data p X` is order-isomorphic to `Finset.range (N p X).toNat`
    via the `s_pre.step` projection.
  SUMMARY:
    Agent 4 established that `(B_data p X).image (fun b => b.s_pre.step)
    = Finset.range (N p X).toNat` and that `s_pre.step` is injective on
    `B_data p X`. Together this means the step-projection gives a Finset
    bijection between `B_data p X` and `Finset.range (N p X).toNat`. We
    package this explicitly as
      * `step_bijOn`: `Set.BijOn (s_pre.step) (B_data p X) (Finset.range _)`
      * `step_le_iff`: order compatibility — `b_synth X p i ≤ b_synth X p j`
        in the step order iff `i ≤ j`.
    The order on `B_data` induced by `s_pre.step` is what makes `B_data`
    a linearly-ordered "timeline" of length `(N p X).toNat`.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Image
import Mathlib.Data.Set.Function

namespace MIP

namespace R2_Agent9_BData_OrderIso_Range

variable {α : Type}

/-! ## (1) The step-projection function. -/

/-- **Step projection**: send a barrier to its `s_pre.step`. -/
def stepProj (b : BarrierData α) : ℕ := b.s_pre.step

/-! ## (2) `stepProj` is a `Set.BijOn` between `B_data` and `Finset.range`. -/

/-- **Step projection maps `B_data p X` into `Finset.range (N p X).toNat`.** -/
theorem stepProj_mapsTo (p : Problem α) (X : Agent α) :
    Set.MapsTo stepProj
      (B_data p X : Set (BarrierData α))
      (↑(Finset.range (N p X).toNat) : Set ℕ) := by
  intro b hb
  -- b ∈ B_data p X ⟹ b = b_synth X p i for some i < (N p X).toNat
  rw [Finset.mem_coe] at hb
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, heq⟩ := hb
  rw [Finset.mem_range] at hi
  rw [Finset.mem_coe, Finset.mem_range]
  unfold stepProj
  rw [← heq]
  -- (b_synth X p i).s_pre.step = i
  show i < (N p X).toNat
  exact hi

/-- **`stepProj` is injective on `B_data p X`.** -/
theorem stepProj_injOn (p : Problem α) (X : Agent α) :
    Set.InjOn stepProj (B_data p X : Set (BarrierData α)) := by
  intro b₁ hb₁ b₂ hb₂ hEq
  rw [Finset.mem_coe] at hb₁ hb₂
  unfold B_data at hb₁ hb₂
  rw [Finset.mem_image] at hb₁ hb₂
  obtain ⟨i, _, hi⟩ := hb₁
  obtain ⟨j, _, hj⟩ := hb₂
  unfold stepProj at hEq
  rw [← hi, ← hj] at hEq
  -- (b_synth X p i).s_pre.step = i
  have hi_step : (b_synth X p i).s_pre.step = i := rfl
  have hj_step : (b_synth X p j).s_pre.step = j := rfl
  rw [hi_step, hj_step] at hEq
  rw [← hi, ← hj, hEq]

/-- **`stepProj` is surjective onto `Finset.range (N p X).toNat`.** -/
theorem stepProj_surjOn (p : Problem α) (X : Agent α) :
    Set.SurjOn stepProj
      (B_data p X : Set (BarrierData α))
      (↑(Finset.range (N p X).toNat) : Set ℕ) := by
  intro k hk
  rw [Finset.mem_coe, Finset.mem_range] at hk
  refine ⟨b_synth X p k, ?_, ?_⟩
  · rw [Finset.mem_coe]
    unfold B_data
    rw [Finset.mem_image]
    refine ⟨k, ?_, rfl⟩
    rw [Finset.mem_range]; exact hk
  · unfold stepProj
    show (b_synth X p k).s_pre.step = k
    rfl

/-- **Headline: `stepProj` is a `Set.BijOn` between `B_data p X` and
`Finset.range (N p X).toNat`.** -/
theorem stepProj_bijOn (p : Problem α) (X : Agent α) :
    Set.BijOn stepProj
      (B_data p X : Set (BarrierData α))
      (↑(Finset.range (N p X).toNat) : Set ℕ) := by
  refine ⟨?_, ?_, ?_⟩
  · exact stepProj_mapsTo p X
  · exact stepProj_injOn p X
  · exact stepProj_surjOn p X

/-! ## (3) Order compatibility on the indexed family. -/

/-- **Order compatibility on the indexed family**: `b_synth X p i` and
`b_synth X p j` are ordered by `stepProj` exactly as `i ≤ j`. -/
theorem stepProj_b_synth_le_iff (X : Agent α) (p : Problem α) (i j : ℕ) :
    stepProj (b_synth X p i) ≤ stepProj (b_synth X p j) ↔ i ≤ j := by
  unfold stepProj
  -- (b_synth X p i).s_pre.step = i and (b_synth X p j).s_pre.step = j
  show i ≤ j ↔ i ≤ j
  rfl

/-- **`stepProj` of a synthetic barrier is its index.** -/
@[simp] theorem stepProj_b_synth (X : Agent α) (p : Problem α) (i : ℕ) :
    stepProj (b_synth X p i) = i := rfl

/-! ## (4) The image-equation form. -/

/-- **`(B_data p X).image stepProj = Finset.range (N p X).toNat`** —
restating Agent 4's step-image result in our `stepProj` notation. -/
theorem B_data_image_stepProj (p : Problem α) (X : Agent α) :
    ((B_data p X).image stepProj) = Finset.range (N p X).toNat := by
  apply Finset.ext
  intro k
  rw [Finset.mem_image, Finset.mem_range]
  refine ⟨?_, ?_⟩
  · rintro ⟨b, hb, hStep⟩
    -- b ∈ B_data p X gives b = b_synth X p i for some i, then stepProj b = i
    unfold B_data at hb
    rw [Finset.mem_image] at hb
    obtain ⟨i, hi, heq⟩ := hb
    rw [Finset.mem_range] at hi
    unfold stepProj at hStep
    rw [← heq] at hStep
    have hi_step : (b_synth X p i).s_pre.step = i := rfl
    rw [hi_step] at hStep
    rw [← hStep]; exact hi
  · intro hk
    refine ⟨b_synth X p k, ?_, rfl⟩
    unfold B_data
    rw [Finset.mem_image]
    refine ⟨k, ?_, rfl⟩
    rw [Finset.mem_range]; exact hk

end R2_Agent9_BData_OrderIso_Range

end MIP
