/-
  STATUS: DISCOVERY
  AGENT: R2-7
  DIRECTION: α = ∞ Renyi divergence (max ratio) with uniform reference.
  SUMMARY:
    The α = ∞ Renyi divergence of `d` against `q` is
        D_∞(d ‖ q) := log (max_ω d.p ω / q.p ω).

    Specialised to uniform `q = 1/|Ω|`:
        D_∞(d ‖ uniform) = log (|Ω| · max_ω d.p ω).

    Two named results:

      • `Renyi_inf_to_uniform_nonneg`     — `D_∞ ≥ 0`.
                                           Proof: `max d.p ω ≥ 1/|Ω|` by
                                           pigeonhole on the masses
                                           summing to 1.
      • `Renyi_inf_to_uniform_le_log_card` — `D_∞ ≤ log |Ω|`.
                                           Proof: `max d.p ω ≤ 1`.

    The max is taken via `Finset.max'` on the image of `d.p` under the
    `(Ω → ℝ)` lift, requiring `Nonempty Ω`.

    The sharper bound `D_∞ ≥ KL_1(d ‖ uniform)` (from the standard
    Renyi-order monotonicity `D_α` non-decreasing in α) is *not*
    attempted here — Mathlib does not have the abstract Renyi-α
    machinery. We content ourselves with `0 ≤ D_∞ ≤ log |Ω|` matching
    the Shannon bracket.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard

namespace MIP

namespace R2_Agent7_RenyiInf_Reference

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- The max-mass `Finset` over the image of `d.p`. Requires `Nonempty Ω`. -/
private noncomputable def maxMass (d : ActivationDist Ω) [Nonempty Ω] : ℝ :=
  ((Finset.univ : Finset Ω).image (fun ω => (d.p ω : ℝ))).max' (by
    rw [Finset.image_nonempty]
    exact Finset.univ_nonempty)

/-- **α = ∞ Renyi divergence with uniform reference (closed form).**

`D_∞(d ‖ uniform) := log (|Ω| · max_ω d.p ω)`. -/
noncomputable def Renyi_inf_to_uniform (d : ActivationDist Ω) [Nonempty Ω] : ℝ :=
  Real.log ((Fintype.card Ω : ℝ) * maxMass d)

/-! ### Bounds on `maxMass d`. -/

/-- **`maxMass d ≥ 1/|Ω|`** (pigeonhole on `∑ d.p ω = 1`).

If every `d.p ω < 1/|Ω|`, the sum would be `< |Ω| · 1/|Ω| = 1`,
contradicting `∑ d.p = 1`. Hence some `d.p ω ≥ 1/|Ω|`, so the max is
at least `1/|Ω|`. -/
theorem maxMass_ge_inv_card [Nonempty Ω] (d : ActivationDist Ω) :
    (1 : ℝ) / (Fintype.card Ω : ℝ) ≤ maxMass d := by
  classical
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_sum : ∑ ω, (d.p ω : ℝ) = 1 := by
    have : ((∑ ω, d.p ω : NNReal) : ℝ) = ∑ ω, (d.p ω : ℝ) := by
      push_cast; rfl
    rw [← this, d.normalized]; simp
  -- Pigeonhole: max ≥ mean = 1/|Ω|.
  -- We use `Finset.exists_le_card_nsmul_of_sum_le_le` or simply the
  -- fact that if all `f ω ≤ c`, then ∑ f ≤ |Ω| · c.
  -- Contrapositive: if ∑ f = 1 and |Ω| · c = 1, then c = 1/|Ω| and
  -- not all f ω can be < 1/|Ω|.
  -- Direct route: among `d.p ω`, there exists `ω₀` with d.p ω₀ ≥ mean.
  -- The mean of `d.p` over univ is `∑ d.p / |Ω| = 1 / |Ω|`.
  -- Such `ω₀` exists by `Finset.exists_le_card_nsmul_of_sum_le`.
  obtain ⟨ω₀, _hω₀mem, hω₀⟩ :
      ∃ ω₀ ∈ (Finset.univ : Finset Ω),
        (1 : ℝ) / (Fintype.card Ω : ℝ) ≤ (d.p ω₀ : ℝ) := by
    -- Use: ∃ x ∈ s, mean ≤ f x  (pigeonhole-mean form).
    -- s.card • mean = ∑ f x  =  s.card · (1/s.card) = 1, so the mean
    -- can't beat all `f x`.
    by_contra h_all_lt
    push Not at h_all_lt
    have h_lt : ∀ ω, (d.p ω : ℝ) < 1 / (Fintype.card Ω : ℝ) := by
      intro ω
      exact h_all_lt ω (Finset.mem_univ ω)
    have h_sum_lt : ∑ ω, (d.p ω : ℝ)
                      < ∑ ω : Ω, (1 / (Fintype.card Ω : ℝ)) := by
      apply Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty
      intro ω _
      exact h_lt ω
    have h_rhs : (∑ ω : Ω, (1 : ℝ) / (Fintype.card Ω : ℝ))
                  = (Fintype.card Ω : ℝ) * (1 / (Fintype.card Ω : ℝ)) := by
      rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    have h_rhs_one : (∑ ω : Ω, (1 : ℝ) / (Fintype.card Ω : ℝ)) = 1 := by
      rw [h_rhs]; field_simp
    rw [h_rhs_one] at h_sum_lt
    linarith
  -- maxMass ≥ d.p ω₀.
  have h_in_img : (d.p ω₀ : ℝ) ∈
      ((Finset.univ : Finset Ω).image (fun ω => (d.p ω : ℝ))) := by
    rw [Finset.mem_image]
    exact ⟨ω₀, Finset.mem_univ ω₀, rfl⟩
  have h_le_max : (d.p ω₀ : ℝ) ≤ maxMass d := by
    unfold maxMass
    exact Finset.le_max' _ _ h_in_img
  linarith

/-- **`maxMass d ≤ 1`.**

Each `d.p ω ≤ 1` (the masses sum to 1, so each ≤ 1). The max over a
finite set of values each ≤ 1 is ≤ 1. -/
theorem maxMass_le_one [Nonempty Ω] (d : ActivationDist Ω) :
    maxMass d ≤ 1 := by
  classical
  have h_each_le_one : ∀ ω, (d.p ω : ℝ) ≤ 1 := by
    intro ω
    have h_sum : ∑ ω', (d.p ω' : ℝ) = 1 := by
      have : ((∑ ω', d.p ω' : NNReal) : ℝ) = ∑ ω', (d.p ω' : ℝ) := by
        push_cast; rfl
      rw [← this, d.normalized]; simp
    have h_le_sum : (d.p ω : ℝ) ≤ ∑ ω', (d.p ω' : ℝ) :=
      Finset.single_le_sum (f := fun ω' => (d.p ω' : ℝ))
        (fun ω' _ => (d.p ω').coe_nonneg) (Finset.mem_univ ω)
    linarith
  unfold maxMass
  apply Finset.max'_le
  intro y hy
  rw [Finset.mem_image] at hy
  obtain ⟨ω, _hω, h_eq⟩ := hy
  rw [← h_eq]
  exact h_each_le_one ω

/-- **`maxMass d > 0`** (since `maxMass d ≥ 1/|Ω| > 0`). -/
private lemma maxMass_pos [Nonempty Ω] (d : ActivationDist Ω) :
    0 < maxMass d := by
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_lower := maxMass_ge_inv_card d
  have h_inv_pos : 0 < (1 : ℝ) / (Fintype.card Ω : ℝ) := by positivity
  linarith

/-! ### Renyi-∞ bracket. -/

/-- **D_∞(d ‖ uniform) ≥ 0.**

`maxMass d ≥ 1/|Ω|` ⟹ `|Ω| · maxMass ≥ 1` ⟹ `log ≥ 0`. -/
theorem Renyi_inf_to_uniform_nonneg [Nonempty Ω] (d : ActivationDist Ω) :
    0 ≤ Renyi_inf_to_uniform d := by
  unfold Renyi_inf_to_uniform
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_lower := maxMass_ge_inv_card d
  have h_mul_ge : (Fintype.card Ω : ℝ) * maxMass d ≥ 1 := by
    have h_mul : (Fintype.card Ω : ℝ) * (1 / (Fintype.card Ω : ℝ))
                  ≤ (Fintype.card Ω : ℝ) * maxMass d :=
      mul_le_mul_of_nonneg_left h_lower (le_of_lt h_card_pos)
    have h_simp : (Fintype.card Ω : ℝ) * (1 / (Fintype.card Ω : ℝ)) = 1 := by
      field_simp
    linarith
  have h_log_ge : Real.log 1 ≤
      Real.log ((Fintype.card Ω : ℝ) * maxMass d) :=
    Real.log_le_log (by norm_num) h_mul_ge
  rw [Real.log_one] at h_log_ge
  exact h_log_ge

/-- **D_∞(d ‖ uniform) ≤ log |Ω|.**

`maxMass d ≤ 1` ⟹ `|Ω| · maxMass ≤ |Ω|` ⟹ `log ≤ log |Ω|`. -/
theorem Renyi_inf_to_uniform_le_log_card [Nonempty Ω] (d : ActivationDist Ω) :
    Renyi_inf_to_uniform d ≤ Real.log (Fintype.card Ω : ℝ) := by
  unfold Renyi_inf_to_uniform
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_upper := maxMass_le_one d
  have h_max_pos := maxMass_pos d
  have h_mul_le : (Fintype.card Ω : ℝ) * maxMass d ≤ (Fintype.card Ω : ℝ) := by
    have h_mul : (Fintype.card Ω : ℝ) * maxMass d
                  ≤ (Fintype.card Ω : ℝ) * 1 :=
      mul_le_mul_of_nonneg_left h_upper (le_of_lt h_card_pos)
    linarith
  have h_prod_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) * maxMass d :=
    mul_pos h_card_pos h_max_pos
  exact Real.log_le_log h_prod_pos h_mul_le

/-- **Bracket: `0 ≤ D_∞(d ‖ uniform) ≤ log |Ω|`.** -/
theorem Renyi_inf_to_uniform_bracket [Nonempty Ω] (d : ActivationDist Ω) :
    0 ≤ Renyi_inf_to_uniform d
      ∧ Renyi_inf_to_uniform d ≤ Real.log (Fintype.card Ω : ℝ) :=
  ⟨Renyi_inf_to_uniform_nonneg d, Renyi_inf_to_uniform_le_log_card d⟩

end R2_Agent7_RenyiInf_Reference

end MIP
