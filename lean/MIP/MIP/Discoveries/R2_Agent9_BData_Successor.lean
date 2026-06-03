/-
  STATUS: DISCOVERY
  AGENT: R2-9
  DIRECTION: Successor and predecessor maps on `B_data p X` indexed by
    step.
  SUMMARY:
    For any `b ∈ B_data p X` whose step is not the last, there is a
    canonical "next" element `next b = b_synth X p (b.s_pre.step + 1)`,
    which lies in `B_data p X` and has step `b.s_pre.step + 1`. By
    Agent 4's chain identity, `(next b).s_pre = b.s_post`. Dually we
    define a `prev` map. Both maps respect the step ordering and give
    bijections between `B_data \ {max}` and `B_data \ {min}` (after
    appropriately identifying barriers by step).
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image
import Mathlib.Data.Set.Function

namespace MIP

namespace R2_Agent9_BData_Successor

variable {α : Type}

/-! ## (1) The successor map. -/

/-- **`next` map on barriers**: send `b` to `b_synth X p (b.s_pre.step + 1)`. -/
noncomputable def next (X : Agent α) (p : Problem α)
    (b : BarrierData α) : BarrierData α :=
  b_synth X p (b.s_pre.step + 1)

/-- **`next` increments step by 1.** -/
@[simp] theorem next_step (X : Agent α) (p : Problem α) (b : BarrierData α) :
    (next X p b).s_pre.step = b.s_pre.step + 1 := rfl

/-- **`next` agent is `X`.** -/
@[simp] theorem next_agent (X : Agent α) (p : Problem α) (b : BarrierData α) :
    (next X p b).s_pre.agent = X := rfl

/-- **`next` problem is `p`.** -/
@[simp] theorem next_problem (X : Agent α) (p : Problem α) (b : BarrierData α) :
    (next X p b).s_pre.problem = p := rfl

/-! ## (2) `next` membership criterion: stays in `B_data p X` when step + 1
< (N p X).toNat. -/

/-- **`next` stays in `B_data` when step is not the last.** -/
theorem next_mem (p : Problem α) (X : Agent α) (b : BarrierData α)
    (hb : b ∈ B_data p X) (hLt : b.s_pre.step + 1 < (N p X).toNat) :
    next X p b ∈ B_data p X := by
  unfold next B_data
  rw [Finset.mem_image]
  refine ⟨b.s_pre.step + 1, ?_, rfl⟩
  rw [Finset.mem_range]; exact hLt

/-! ## (3) Chain identity through `next`: `(next b).s_pre = b.s_post`. -/

/-- **Chain identity (next form).** For `b ∈ B_data p X`,
`(next X p b).s_pre = b.s_post`. -/
theorem next_pre_eq_post (p : Problem α) (X : Agent α) (b : BarrierData α)
    (hb : b ∈ B_data p X) :
    (next X p b).s_pre = b.s_post := by
  -- b = b_synth X p i for some i; then b.s_post = ⟨X, p, i+1⟩
  -- and (next X p b).s_pre = ⟨X, p, b.s_pre.step + 1⟩.
  -- Since b.s_pre.step = i, both equal ⟨X, p, i+1⟩.
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, heq⟩ := hb
  rw [← heq]
  -- goal: (next X p (b_synth X p i)).s_pre = (b_synth X p i).s_post
  unfold next
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  -- (b_synth X p (i + 1)).s_pre = (b_synth X p i).s_post
  rfl

/-! ## (4) The predecessor map. -/

/-- **`prev` map on barriers**: send `b` to `b_synth X p (b.s_pre.step - 1)`. -/
noncomputable def prev (X : Agent α) (p : Problem α)
    (b : BarrierData α) : BarrierData α :=
  b_synth X p (b.s_pre.step - 1)

/-- **`prev` step.** -/
@[simp] theorem prev_step (X : Agent α) (p : Problem α) (b : BarrierData α) :
    (prev X p b).s_pre.step = b.s_pre.step - 1 := rfl

/-! ## (5) `next` and `prev` are mutual inverses on `B_data`-with-step-restriction. -/

/-- **`prev ∘ next` is identity on `B_data p X`** (for `b ∈ B_data p X`,
since each barrier `b ∈ B_data` is some `b_synth X p i`, `prev` of `next` returns
`b_synth X p i` = `b`). -/
theorem prev_next (p : Problem α) (X : Agent α) (b : BarrierData α)
    (hb : b ∈ B_data p X) :
    prev X p (next X p b) = b := by
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, heq⟩ := hb
  unfold prev next
  rw [← heq]
  -- (b_synth X p i).s_pre.step = i
  -- (next X p (b_synth X p i)).s_pre.step = i + 1
  -- prev returns b_synth X p ((i+1) - 1) = b_synth X p i
  have h1 : (b_synth X p i).s_pre.step = i := rfl
  rw [h1]
  -- goal: b_synth X p ((b_synth X p (i + 1)).s_pre.step - 1) = b_synth X p i
  have h2 : (b_synth X p (i + 1)).s_pre.step = i + 1 := rfl
  rw [h2]
  -- b_synth X p (i + 1 - 1) = b_synth X p i
  have : i + 1 - 1 = i := by omega
  rw [this]

/-- **`next ∘ prev` is identity on `B_data p X` for barriers with positive step**.
For `b ∈ B_data p X` with `b.s_pre.step ≥ 1`, `next (prev b) = b`. -/
theorem next_prev (p : Problem α) (X : Agent α) (b : BarrierData α)
    (hb : b ∈ B_data p X) (hPos : 1 ≤ b.s_pre.step) :
    next X p (prev X p b) = b := by
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, heq⟩ := hb
  unfold next prev
  rw [← heq]
  have h1 : (b_synth X p i).s_pre.step = i := rfl
  rw [h1]
  -- (b_synth X p (i - 1)).s_pre.step = i - 1
  have h2 : (b_synth X p (i - 1)).s_pre.step = i - 1 := rfl
  rw [h2]
  -- now i - 1 + 1 = i (since i ≥ 1)
  rw [← heq] at hPos
  have h3 : (b_synth X p i).s_pre.step = i := rfl
  rw [h3] at hPos
  have : i - 1 + 1 = i := Nat.sub_add_cancel hPos
  rw [this]

/-! ## (6) `prev` membership: when step ≥ 1 and `b ∈ B_data`. -/

/-- **`prev` stays in `B_data` when step is positive.** -/
theorem prev_mem (p : Problem α) (X : Agent α) (b : BarrierData α)
    (hb : b ∈ B_data p X) (hPos : 1 ≤ b.s_pre.step) :
    prev X p b ∈ B_data p X := by
  unfold prev B_data
  rw [Finset.mem_image]
  refine ⟨b.s_pre.step - 1, ?_, rfl⟩
  rw [Finset.mem_range]
  -- need b.s_pre.step - 1 < (N p X).toNat. Use that b.s_pre.step < (N p X).toNat.
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, heq⟩ := hb
  rw [Finset.mem_range] at hi
  rw [← heq]
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  omega

/-! ## (7) Bijection: next sends B_data minus the max to B_data minus the min. -/

/-- **`next` is injective on `B_data p X`** (anywhere it is defined). -/
theorem next_injOn (p : Problem α) (X : Agent α) :
    Set.InjOn (next X p) (B_data p X : Set (BarrierData α)) := by
  intro b₁ hb₁ b₂ hb₂ hEq
  rw [Finset.mem_coe] at hb₁ hb₂
  unfold B_data at hb₁ hb₂
  rw [Finset.mem_image] at hb₁ hb₂
  obtain ⟨i, _, hi⟩ := hb₁
  obtain ⟨j, _, hj⟩ := hb₂
  unfold next at hEq
  rw [← hi, ← hj] at hEq
  have hi_step : (b_synth X p i).s_pre.step = i := rfl
  have hj_step : (b_synth X p j).s_pre.step = j := rfl
  rw [hi_step, hj_step] at hEq
  -- b_synth X p (i + 1) = b_synth X p (j + 1) → i + 1 = j + 1 → i = j
  have h := b_synth_injective X p hEq
  have hij : i = j := by omega
  rw [← hi, ← hj, hij]

/-- **`prev` is injective on `B_data p X` restricted to step ≥ 1.** -/
theorem prev_injOn_pos (p : Problem α) (X : Agent α) :
    Set.InjOn (prev X p)
      ((B_data p X).filter (fun b => 1 ≤ b.s_pre.step) : Set (BarrierData α)) := by
  intro b₁ hb₁ b₂ hb₂ hEq
  rw [Finset.mem_coe, Finset.mem_filter] at hb₁ hb₂
  obtain ⟨hb₁mem, hb₁pos⟩ := hb₁
  obtain ⟨hb₂mem, hb₂pos⟩ := hb₂
  unfold B_data at hb₁mem hb₂mem
  rw [Finset.mem_image] at hb₁mem hb₂mem
  obtain ⟨i, _, hi⟩ := hb₁mem
  obtain ⟨j, _, hj⟩ := hb₂mem
  unfold prev at hEq
  rw [← hi, ← hj] at hEq
  have hi_step : (b_synth X p i).s_pre.step = i := rfl
  have hj_step : (b_synth X p j).s_pre.step = j := rfl
  rw [hi_step, hj_step] at hEq
  -- b_synth X p (i - 1) = b_synth X p (j - 1) → i - 1 = j - 1
  have h := b_synth_injective X p hEq
  rw [← hi] at hb₁pos
  rw [← hj] at hb₂pos
  rw [hi_step] at hb₁pos
  rw [hj_step] at hb₂pos
  have hij : i = j := by omega
  rw [← hi, ← hj, hij]

end R2_Agent9_BData_Successor

end MIP
