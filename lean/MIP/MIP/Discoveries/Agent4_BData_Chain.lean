/-
  STATUS: DISCOVERY
  AGENT: 4
  DIRECTION: `B_data p X` carries a linear order via the `s_pre.step` field.
  SUMMARY:
    Every element of `B_data p X` has the shape `b_synth X p i`, so the
    map `b ↦ b.s_pre.step` is well-defined and injective on `B_data`. We
    use this to prove:
      * `B_data` injects into `ℕ` via `s_pre.step` (so it is "ordered by
        time").
      * Two distinct barriers in `B_data` have distinct step indices.
      * Consecutive synthetic barriers share an endpoint:
        `(b_synth X p i).s_post = (b_synth X p (i+1)).s_pre`.
    Together: `B_data` is the concrete model's "time-stamped progress
    meter" — a chain of length `(N p X).toNat` walking from step 0 to
    step `(N p X).toNat`.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent4_BData_Chain

variable {α : Type}

/-! ## (1) Every element of `B_data p X` has the form `b_synth X p i`. -/

/-- **Structural form**: every `b ∈ B_data p X` is `b_synth X p i` for
some `i < (N p X).toNat`. -/
theorem B_data_mem_iff (p : Problem α) (X : Agent α) (b : BarrierData α) :
    b ∈ B_data p X ↔ ∃ i < (N p X).toNat, b = b_synth X p i := by
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨?_, ?_⟩
  · rintro ⟨i, hi, hEq⟩
    rw [Finset.mem_range] at hi
    exact ⟨i, hi, hEq.symm⟩
  · rintro ⟨i, hi, hEq⟩
    exact ⟨i, Finset.mem_range.mpr hi, hEq.symm⟩

/-! ## (2) Step-projection is injective on `B_data`. -/

/-- **`s_pre.step` is injective on `B_data p X`.** Two barriers from
`B_data` with the same `s_pre.step` are equal. -/
theorem step_injective_on_B_data
    (p : Problem α) (X : Agent α) :
    ∀ b₁ ∈ B_data p X, ∀ b₂ ∈ B_data p X,
      b₁.s_pre.step = b₂.s_pre.step → b₁ = b₂ := by
  intro b₁ hb₁ b₂ hb₂ hStep
  obtain ⟨i, _, heqi⟩ := (B_data_mem_iff p X b₁).mp hb₁
  obtain ⟨j, _, heqj⟩ := (B_data_mem_iff p X b₂).mp hb₂
  rw [heqi, heqj]
  -- (b_synth X p i).s_pre.step = i and similarly for j
  have hi_eq : (b_synth X p i).s_pre.step = i := rfl
  have hj_eq : (b_synth X p j).s_pre.step = j := rfl
  have hij : i = j := by
    rw [heqi, heqj] at hStep
    rw [hi_eq, hj_eq] at hStep
    exact hStep
  rw [hij]

/-! ## (3) Step-range characterisation: the `s_pre.step` field of
elements of `B_data` is exactly `{0, 1, ..., (N p X).toNat - 1}`. -/

/-- **Step-range image**: the image of `s_pre.step` over `B_data p X`
equals `Finset.range (N p X).toNat`. -/
theorem B_data_step_image (p : Problem α) (X : Agent α) :
    ((B_data p X).image (fun b => b.s_pre.step))
      = Finset.range (N p X).toNat := by
  apply Finset.ext
  intro k
  rw [Finset.mem_image, Finset.mem_range]
  refine ⟨?_, ?_⟩
  · rintro ⟨b, hb, hStep⟩
    obtain ⟨i, hi, heq⟩ := (B_data_mem_iff p X b).mp hb
    rw [heq] at hStep
    have : i = k := hStep
    rw [← this]; exact hi
  · intro hk
    refine ⟨b_synth X p k, ?_, rfl⟩
    rw [B_data_mem_iff]
    exact ⟨k, hk, rfl⟩

/-! ## (4) Step values form 0..(N-1). -/

/-- **For any `b ∈ B_data p X`, `b.s_pre.step < (N p X).toNat`.** -/
theorem step_lt_N (p : Problem α) (X : Agent α) (b : BarrierData α)
    (h : b ∈ B_data p X) : b.s_pre.step < (N p X).toNat := by
  obtain ⟨i, hi, heq⟩ := (B_data_mem_iff p X b).mp h
  rw [heq]
  exact hi

/-! ## (5) Chain identity (re-export): two consecutive synthetic barriers
share an endpoint. -/

/-- **Chain identity**: `(b_synth X p i).s_post = (b_synth X p (i+1)).s_pre`. -/
@[simp] theorem b_synth_post_eq_next_pre
    (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post = (b_synth X p (i + 1)).s_pre := rfl

/-! ## (6) Two distinct barriers in `B_data` have step difference ≥ 1. -/

/-- **Two distinct barriers in `B_data p X` have distinct step indices.**
Contrapositive form of `step_injective_on_B_data`. -/
theorem step_ne_of_ne (p : Problem α) (X : Agent α)
    {b₁ b₂ : BarrierData α}
    (h₁ : b₁ ∈ B_data p X) (h₂ : b₂ ∈ B_data p X)
    (hNe : b₁ ≠ b₂) :
    b₁.s_pre.step ≠ b₂.s_pre.step := by
  intro hStep
  exact hNe (step_injective_on_B_data p X b₁ h₁ b₂ h₂ hStep)

end Agent4_BData_Chain

end MIP
