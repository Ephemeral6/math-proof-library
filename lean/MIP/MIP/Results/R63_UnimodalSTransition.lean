/-
Result R.63 — Unimodal autonomy phase transition: S-shaped CDF → 1.

Reference: `proofs/derived/A_grade.md` R.63 ("单峰分布相变", A 弱形式,
依赖 T.5 + T.8) and `proofs/derived/conjecture_attacks.md` R.102 (T.27,
S-shaped structure, shape-invariance).

**Statement.** Let the mode of the shape-invariant `Φ₀`-distribution decay
geometrically (T.5):

    μ_t = (1 − α)^t · μ₀ ,        0 < α < 1 ,

so `μ_t → 0` as `t → ∞`.  Write the "solved with no further intervention"
probability as the threshold CDF evaluated after the mode shift
(shape-invariance, R.102 step 1):

    P0 t := F (δ − μ_t) ,     where `F` is the (monotone) noise CDF.

Then `P0` is **monotone non-decreasing in `t`** (the S-shaped rise), and if
`F` is continuous at `δ` with `F δ = 1` (the CDF saturates above the noise
support at the threshold limit), then

    P0 t  ⟶  1     as  t → ∞ .

**Proof.**
* *Mode decay.* `(1 − α) ∈ [0, 1)` ⟹ `(1 − α)^t → 0`
  (`tendsto_pow_atTop_nhds_zero_of_lt_one`); multiply by `μ₀` ⟹ `μ_t → 0`.
* *Monotonicity.* `μ_t ↓` ⟹ `δ − μ_t ↑` ⟹ `F(δ − μ_t) ↑` (F monotone).
* *Limit.* `δ − μ_t → δ − 0 = δ`; continuity of `F` at `δ` carries the
  limit to `F δ = 1`.

This file proves the **monotonicity kernel** and the **`Tendsto … 1`
limit** without committing to MIP opaques (specific `F`, `μ₀`, `α`).

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.ContinuousOn
import Mathlib.Tactic.Linarith

namespace MIP

namespace UnimodalSTransition

open Filter Topology

/-- **R.63 — geometric mode decay: `μ_t = (1−α)^t·μ₀ → 0`.**

For `0 < α < 1` the mode `μ_t := (1 − α)^t · μ₀` tends to `0` as
`t → ∞` (T.5 flywheel decay). -/
theorem R_63_mode_tendsto_zero
    (α μ₀ : ℝ) (hα0 : 0 < α) (hα1 : α < 1) :
    Tendsto (fun t : ℕ => (1 - α) ^ t * μ₀) atTop (𝓝 0) := by
  have h_base_nonneg : (0 : ℝ) ≤ 1 - α := by linarith
  have h_base_lt_one : (1 : ℝ) - α < 1 := by linarith
  have h_pow : Tendsto (fun t : ℕ => (1 - α) ^ t) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one h_base_nonneg h_base_lt_one
  have h_mul := h_pow.mul_const μ₀
  -- (𝓝 (0 * μ₀)) = (𝓝 0)
  rwa [zero_mul] at h_mul

/-- **R.63 — monotonicity of the S-curve (shape-invariant CDF after mode
shift).**

If `F` is monotone non-decreasing and `μ : ℕ → ℝ` is monotone
non-increasing, then `t ↦ F (δ − μ t)` is monotone non-decreasing: the
autonomy probability rises monotonically (the S-shaped transition). -/
theorem R_63_S_shape_monotone
    (F : ℝ → ℝ) (μ : ℕ → ℝ) (δ : ℝ)
    (hF_mono : Monotone F)
    (hμ_dec : ∀ t₁ t₂, t₁ ≤ t₂ → μ t₂ ≤ μ t₁) :
    ∀ t₁ t₂, t₁ ≤ t₂ → F (δ - μ t₁) ≤ F (δ - μ t₂) := by
  intro t₁ t₂ h_le
  have h_μ_le : μ t₂ ≤ μ t₁ := hμ_dec t₁ t₂ h_le
  exact hF_mono (by linarith)

/-- **R.63 — the geometric mode is monotone non-increasing in `t`.**

For `0 ≤ α ≤ 1` and `0 ≤ μ₀`, `μ_t = (1 − α)^t · μ₀` is non-increasing in
`t` (each extra training step multiplies by the contraction factor
`1 − α ∈ [0, 1]`). This feeds `R_63_S_shape_monotone`. -/
theorem R_63_geometric_mode_decreasing
    (α μ₀ : ℝ) (hα0 : 0 ≤ α) (hα1 : α ≤ 1) (hμ₀ : 0 ≤ μ₀) :
    ∀ t₁ t₂ : ℕ, t₁ ≤ t₂ →
      (1 - α) ^ t₂ * μ₀ ≤ (1 - α) ^ t₁ * μ₀ := by
  intro t₁ t₂ h_le
  have h_base_nonneg : (0 : ℝ) ≤ 1 - α := by linarith
  have h_base_le_one : (1 : ℝ) - α ≤ 1 := by linarith
  have h_pow_le : (1 - α) ^ t₂ ≤ (1 - α) ^ t₁ :=
    pow_le_pow_of_le_one h_base_nonneg h_base_le_one h_le
  exact mul_le_mul_of_nonneg_right h_pow_le hμ₀

/-- **R.63 — autonomy probability tends to 1 (S-curve late regime).**

Core S-transition limit.  Let `μ_t = (1 − α)^t · μ₀` with `0 < α < 1` (so
`μ_t → 0`), and `P0 t := F (δ − μ_t)`.  If `F` is continuous at `δ` with
`F δ = 1` (CDF saturates at the threshold), then `P0 t → 1` as `t → ∞`. -/
theorem R_63_autonomy_tendsto_one
    (F : ℝ → ℝ) (α μ₀ δ : ℝ)
    (hα0 : 0 < α) (hα1 : α < 1)
    (hF_cont : ContinuousAt F δ) (hF_one : F δ = 1) :
    Tendsto (fun t : ℕ => F (δ - (1 - α) ^ t * μ₀)) atTop (𝓝 1) := by
  -- μ_t → 0
  have h_mode : Tendsto (fun t : ℕ => (1 - α) ^ t * μ₀) atTop (𝓝 0) :=
    R_63_mode_tendsto_zero α μ₀ hα0 hα1
  -- δ − μ_t → δ − 0 = δ
  have h_arg : Tendsto (fun t : ℕ => δ - (1 - α) ^ t * μ₀) atTop (𝓝 δ) := by
    have := h_mode.const_sub δ
    rwa [sub_zero] at this
  -- continuity of F at δ carries the limit to F δ = 1
  have h_comp : Tendsto (fun t : ℕ => F (δ - (1 - α) ^ t * μ₀)) atTop (𝓝 (F δ)) :=
    (hF_cont.tendsto).comp h_arg
  rwa [hF_one] at h_comp

/-- **R.63 — full S-transition (combined monotone + limit).**

Packaging the two halves: under the standing hypotheses, the autonomy
probability `P0 t = F (δ − μ_t)` is monotone non-decreasing in `t` *and*
tends to `1`. This is the crisp core of the S-shaped autonomy phase
transition. -/
theorem R_63_S_transition
    (F : ℝ → ℝ) (α μ₀ δ : ℝ)
    (hα0 : 0 < α) (hα1 : α < 1) (hμ₀ : 0 ≤ μ₀)
    (hF_mono : Monotone F)
    (hF_cont : ContinuousAt F δ) (hF_one : F δ = 1) :
    (∀ t₁ t₂ : ℕ, t₁ ≤ t₂ →
        F (δ - (1 - α) ^ t₁ * μ₀) ≤ F (δ - (1 - α) ^ t₂ * μ₀))
      ∧ Tendsto (fun t : ℕ => F (δ - (1 - α) ^ t * μ₀)) atTop (𝓝 1) := by
  refine ⟨?_, R_63_autonomy_tendsto_one F α μ₀ δ hα0 hα1 hF_cont hF_one⟩
  exact R_63_S_shape_monotone F (fun t => (1 - α) ^ t * μ₀) δ hF_mono
    (R_63_geometric_mode_decreasing α μ₀ hα0.le hα1.le hμ₀)

end UnimodalSTransition

end MIP
