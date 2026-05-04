import Mathlib.Analysis.Convex.Function
import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.Calculus.FDeriv.Basic
import Mathlib.Analysis.InnerProductSpace.Dual
import Mathlib.Analysis.Asymptotics.Defs
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Tactic

namespace LeanAgent.Generated

open InnerProductSpace Set

/-- Local convergence form of `HasFDerivAt`: a linear remainder estimate.
    Inlined helper (same body as in `convex_first_order_condition_grad_depth2_idx1`). -/
private lemma hasFDerivAt_convergence_inlined_p
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {f : E → ℝ} {f'x : E →L[ℝ] ℝ} {x : E}
    (h : HasFDerivAt f f'x x) :
    ∀ ε > (0 : ℝ), ∃ δ > (0 : ℝ), ∀ x' : E, ‖x - x'‖ ≤ δ →
      ‖f x' - f x - f'x (x' - x)‖ ≤ ε * ‖x - x'‖ := by
  intro ε epos
  have hL := h.isLittleO
  rw [Asymptotics.isLittleO_iff] at hL
  specialize hL epos
  rw [Filter.eventually_iff_exists_mem] at hL
  rcases hL with ⟨V, hV, hbd⟩
  rw [Metric.mem_nhds_iff] at hV
  rcases hV with ⟨δ, dpos, hball⟩
  refine ⟨δ / 2, half_pos dpos, ?_⟩
  intro x' hxx
  have hmem : x' ∈ V := by
    apply hball
    rw [Metric.mem_ball, dist_comm, dist_eq_norm]
    exact lt_of_le_of_lt hxx (half_lt_self dpos)
  have hbd' := hbd x' hmem
  rw [show ‖x - x'‖ = ‖x' - x‖ from norm_sub_rev _ _]
  exact hbd'

private lemma point_proportion_inlined_p
    {E : Type*} [AddCommGroup E] [Module ℝ E] {x y x' : E} {a b : ℝ}
    (_ : 0 ≤ a) (_ : 0 ≤ b) (sumab : a + b = 1)
    (hpoint : x' = a • x + b • y) : x - x' = b • (x - y) := by
  calc
    x - x' = x - (a • x + b • y) := by rw [hpoint]
    _ = x - a • x - b • y := sub_add_eq_sub_sub x (a • x) (b • y)
    _ = (1 : ℝ) • x - a • x - b • y := by rw [one_smul]
    _ = (1 - a) • x - b • y := by rw [sub_smul 1 a]
    _ = b • x - b • y := by rw [← sumab]; ring_nf
    _ = b • (x - y) := Eq.symm (smul_sub b x y)

/-- First-order characterization of convex functions in **gradient form**, with the
    weaker hypothesis that the gradient exists only at the central point `x`
    (rather than everywhere on `s`).

    Optlib name: `Convex_first_order_condition'`.

    Proof structure adapted from the depth-2 recursive-synthesis helper
    `convex_first_order_condition_grad_depth2_idx1`: the original uses
    `∀ x ∈ s, HasGradientAt f (f' x) x`, but its proof body only ever invokes
    the gradient at the central point, so the same proof works with the
    weaker hypothesis here. -/
theorem Convex_first_order_condition_prime
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    {f : E → ℝ} {f' : E → E} {s : Set E} {x : E}
    (h : HasGradientAt f (f' x) x) (hf : ConvexOn ℝ s f)
    (xs : x ∈ s) : ∀ (y : E), y ∈ s → f x + inner ℝ (f' x) (y - x) ≤ f y := by
  intro y ys
  change f x + (toDual ℝ E (f' x)) (y - x) ≤ f y
  set fp : E →L[ℝ] ℝ := toDual ℝ E (f' x) with hfp
  have hfx : HasFDerivAt f fp x := h
  have h₁ := hasFDerivAt_convergence_inlined_p hfx
  by_cases h₂ : y = x
  · rw [h₂, sub_self, ContinuousLinearMap.map_zero, add_zero]
  have h₃ : 0 < ‖x - y‖ := by
    rw [norm_sub_pos_iff, Ne]; exact Iff.mpr ne_comm h₂
  by_contra H
  push_neg at H
  rw [ConvexOn] at hf
  rcases hf with ⟨_, cxf⟩
  specialize cxf xs ys
  set ε : ℝ := f x + fp (y - x) - f y with hε
  have epos : 0 < ε := Iff.mpr sub_pos H
  have lnmp : ∀ c : ℝ, fp (c • (y - x)) = c * (fp (y - x)) := by
    intro c; rw [map_smul, smul_eq_mul]
  set e1 : ℝ := ε / (2 * ‖x - y‖) with he1
  have e1pos : 0 < e1 := div_pos (by linarith) (by linarith)
  specialize h₁ e1 e1pos
  rcases h₁ with ⟨δ, dpos, converge⟩
  set b1 : ℝ := δ / ‖x - y‖ with hb1
  have b1pos : 0 < b1 := div_pos dpos h₃
  set b : ℝ := min b1 (1 : ℝ) with hb
  set a : ℝ := 1 - b with ha
  have sum_a_b : a + b = 1 := sub_add_cancel 1 b
  have b_nonneg : 0 ≤ b := le_min (LT.lt.le b1pos) zero_le_one
  have b_pos : 0 < b := lt_min b1pos zero_lt_one
  have a_nonneg : 0 ≤ a := by
    have h1 : 0 + b ≤ a + b := by rw [zero_add, sum_a_b]; exact min_le_right b1 1
    exact (add_le_add_iff_right b).mp h1
  specialize cxf a_nonneg b_nonneg sum_a_b
  set x' : E := a • x + b • y with hx'
  have x'rfl : x' = a • x + b • y := rfl
  have h1 : ‖x - x'‖ = ‖b • (x - y)‖ := by
    congr 1; exact point_proportion_inlined_p a_nonneg b_nonneg sum_a_b x'rfl
  have h2eq : ‖b • (x - y)‖ = b * ‖x - y‖ := by
    rw [norm_smul, Real.norm_of_nonneg b_nonneg]
  have x1nbhd : ‖x - x'‖ ≤ δ := by
    rw [h1, h2eq]
    have h3 : b * ‖x - y‖ ≤ b1 * ‖x - y‖ :=
      mul_le_mul_of_nonneg_right (min_le_left _ _) (le_of_lt h₃)
    have h4 : b1 * ‖x - y‖ = δ := by
      simp only [hb1]; rw [div_mul_cancel₀]; exact ne_of_gt h₃
    rw [← h4]; exact h3
  specialize converge x' x1nbhd
  have H1 : f x + fp (x' - x) - e1 * ‖x - x'‖ ≤ f x' := by
    have l1 : f x + fp (x' - x) - f x' ≤ ‖f x' - f x - fp (x' - x)‖ := by
      rw [Real.norm_eq_abs]
      have eq : f x + fp (x' - x) - f x' = -(f x' - f x - fp (x' - x)) := by ring
      rw [eq]; exact neg_le_abs _
    linarith [le_trans l1 converge]
  have H3 : f y = f x + fp (y - x) - ε := by simp only [hε]; ring
  have l4 : e1 * ‖x - x'‖ = ε * b / 2 := by
    rw [h1, h2eq]
    calc
      e1 * (b * ‖x - y‖) = ε / (2 * ‖x - y‖) * (b * ‖x - y‖) := rfl
      _ = ((ε / 2) / ‖x - y‖) * (b * ‖x - y‖) := by ring
      _ = ((ε / 2) / ‖x - y‖) * ‖x - y‖ * b := by rw [mul_comm b, mul_assoc]
      _ = (ε / 2) * b := by rw [div_mul_cancel₀]; exact ne_of_gt h₃
      _ = ε * b / 2 := by ring
  rw [l4] at H1
  rw [smul_eq_mul, smul_eq_mul] at cxf
  have H4 : a * f x + b * f y = f x + b * fp (y - x) - b * ε := by rw [H3]; ring
  have l5 : b * fp (y - x) = fp (x' - x) := by
    rw [← neg_sub x x', point_proportion_inlined_p a_nonneg b_nonneg sum_a_b x'rfl, smul_sub]
    rw [neg_sub, ← smul_sub, lnmp b]
  rw [l5] at H4
  rw [H4] at cxf
  have _hchain : f x + fp (x' - x) - ε * b / 2 ≤ f x + fp (x' - x) - b * ε := le_trans H1 cxf
  have H11 : ε ≤ 0 := nonpos_of_mul_nonpos_left (by linarith) b_pos
  linarith

end LeanAgent.Generated
