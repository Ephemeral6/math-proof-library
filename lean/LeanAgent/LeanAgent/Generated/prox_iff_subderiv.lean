import Mathlib.Analysis.Convex.Function
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Tactic

namespace LeanAgent.Generated

open Set

/-! Item 08 — `prox_iff_subderiv`.

We supply standalone definitions for `prox_prop`, `HasSubgradientAt`, `SubderivAt`,
and `mem_SubderivAt` (the optlib symbols of the same name) so the theorem
statement is self-contained — no dependency on optlib. The proof goes through
two elementary inequalities (one in each direction); only Mathlib's inner-product
identities and `ConvexOn.2` are used. No subgradient additivity (`SubderivAt.add`)
or auxiliary `convex_of_norm_sq` / `gradient_of_sq` lemmas are needed.
-/

section Defs

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- `prox_prop f x u` says `u` minimizes `z ↦ f z + ‖z - x‖²/2` globally on `E`. -/
def prox_prop (f : E → ℝ) (x u : E) : Prop :=
  ∀ y : E, f u + ‖u - x‖ ^ 2 / 2 ≤ f y + ‖y - x‖ ^ 2 / 2

/-- `g` is a subgradient of `f` at `x`: `f x + ⟨g, y - x⟩ ≤ f y` for every `y`. -/
def HasSubgradientAt (f : E → ℝ) (g x : E) : Prop :=
  ∀ y : E, f x + inner ℝ g (y - x) ≤ f y

/-- The subdifferential of `f` at `x` (set of all subgradients). -/
def SubderivAt (f : E → ℝ) (x : E) : Set E :=
  {g | HasSubgradientAt f g x}

/-- Membership unfolding for `SubderivAt`. -/
theorem mem_SubderivAt {f : E → ℝ} {g x : E} :
    g ∈ SubderivAt f x ↔ ∀ y, f x + inner ℝ g (y - x) ≤ f y := Iff.rfl

end Defs

section Theorem

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {x : E}

/-- **Item 08**: For convex `f` on the whole space, `u` is a proximal point of `x`
    w.r.t. `f` iff `x - u` belongs to the subdifferential of `f` at `u`. -/
theorem prox_iff_subderiv (f : E → ℝ) (hfun : ConvexOn ℝ univ f) :
    ∀ u : E, prox_prop f x u ↔ x - u ∈ SubderivAt f u := by
  intro u
  refine ⟨?_, ?_⟩
  -- ============================================================
  -- Direction (→): prox-min ⇒ subgradient.  Uses convexity.
  -- ============================================================
  · intro hmin y
    -- Goal: f u + inner ℝ (x - u) (y - u) ≤ f y.
    by_cases hyu : y = u
    · simp [hyu]
    have hyu_ne : y - u ≠ 0 := sub_ne_zero.mpr hyu
    have hyu_norm_pos : 0 < ‖y - u‖ ^ 2 := by positivity
    by_contra Hcontr
    push_neg at Hcontr
    -- L is the strictly-positive defect we will derive a contradiction from.
    set L : ℝ := f u + inner ℝ (x - u) (y - u) - f y with hLdef
    have hL_pos : 0 < L := by simp only [hLdef]; linarith
    -- Pick `t = min 1 (L / ‖y - u‖²)` ∈ (0, 1].
    set t : ℝ := min 1 (L / ‖y - u‖ ^ 2) with htdef
    have t_pos : 0 < t := lt_min one_pos (div_pos hL_pos hyu_norm_pos)
    have t_le_one : t ≤ 1 := min_le_left _ _
    have t_div_bound : t ≤ L / ‖y - u‖ ^ 2 := min_le_right _ _
    -- t * ‖y - u‖² ≤ L
    have t_bound : t * ‖y - u‖ ^ 2 ≤ L := by
      have := mul_le_mul_of_nonneg_right t_div_bound (le_of_lt hyu_norm_pos)
      rwa [div_mul_cancel₀ L (ne_of_gt hyu_norm_pos)] at this
    -- Apply hmin at the convex combination z = (1 - t) • u + t • y.
    set z : E := (1 - t) • u + t • y with hzdef
    have hmin_z := hmin z
    -- Algebraic identity for z - x.
    have hz_minus_x : z - x = (u - x) + t • (y - u) := by
      simp only [hzdef, sub_smul, one_smul, smul_sub]; abel
    -- ‖z - x‖² expansion.
    have hnorm_sq : ‖z - x‖ ^ 2
        = ‖u - x‖ ^ 2 + 2 * t * inner ℝ (u - x) (y - u) + t ^ 2 * ‖y - u‖ ^ 2 := by
      rw [hz_minus_x, norm_add_sq_real, real_inner_smul_right, norm_smul,
          Real.norm_eq_abs, mul_pow, sq_abs]
      ring
    -- Convexity inequality at the same convex combination.
    have h_convex : f z ≤ (1 - t) * f u + t * f y := by
      have ha : (0 : ℝ) ≤ 1 - t := by linarith
      have hb : (0 : ℝ) ≤ t := le_of_lt t_pos
      have hab : (1 - t) + t = 1 := by ring
      have key := hfun.2 (mem_univ u) (mem_univ y) ha hb hab
      simpa [hzdef, smul_eq_mul] using key
    -- Sign-flip in the inner factor.
    have inner_neg_uxyu : inner ℝ (u - x) (y - u) = - inner ℝ (x - u) (y - u) := by
      rw [show u - x = -(x - u) from by abel, inner_neg_left]
    -- Step 1: chain hmin_z, h_convex, hnorm_sq.
    have step_combined :
        f u + ‖u - x‖ ^ 2 / 2
          ≤ (1 - t) * f u + t * f y + ‖u - x‖ ^ 2 / 2
              + t * inner ℝ (u - x) (y - u) + t ^ 2 / 2 * ‖y - u‖ ^ 2 := by
      calc f u + ‖u - x‖ ^ 2 / 2
          ≤ f z + ‖z - x‖ ^ 2 / 2 := hmin_z
        _ ≤ (1 - t) * f u + t * f y + ‖z - x‖ ^ 2 / 2 := by linarith
        _ = (1 - t) * f u + t * f y +
              (‖u - x‖ ^ 2 + 2 * t * inner ℝ (u - x) (y - u) + t ^ 2 * ‖y - u‖ ^ 2) / 2 := by
            rw [hnorm_sq]
        _ = (1 - t) * f u + t * f y + ‖u - x‖ ^ 2 / 2
              + t * inner ℝ (u - x) (y - u) + t ^ 2 / 2 * ‖y - u‖ ^ 2 := by ring
    -- Step 2: cancel ‖u - x‖²/2 and isolate the f u, f y terms.
    have step_isolated :
        t * f u ≤ t * f y + t * inner ℝ (u - x) (y - u) + t ^ 2 / 2 * ‖y - u‖ ^ 2 := by
      linarith [step_combined]
    -- Step 3: rewrite into t * L ≤ t² / 2 * ‖y - u‖².
    have step_tL : t * L ≤ t ^ 2 / 2 * ‖y - u‖ ^ 2 := by
      simp only [hLdef]
      nlinarith [step_isolated, inner_neg_uxyu]
    -- Step 4: t² ‖y - u‖² ≤ t * L (from t_bound and t > 0).
    have t_sq_bound : t ^ 2 * ‖y - u‖ ^ 2 ≤ t * L := by
      have hrew : t ^ 2 * ‖y - u‖ ^ 2 = t * (t * ‖y - u‖ ^ 2) := by ring
      rw [hrew]
      exact mul_le_mul_of_nonneg_left t_bound (le_of_lt t_pos)
    -- Combining: t * L ≤ t² / 2 * ‖y - u‖² ≤ (t * L) / 2.
    have htL_half : t * L ≤ t * L / 2 := by linarith [step_tL, t_sq_bound]
    -- But t * L > 0 ⇒ t * L > t * L / 2.  Contradiction.
    have htL_pos : 0 < t * L := mul_pos t_pos hL_pos
    linarith
  -- ============================================================
  -- Direction (←): subgradient ⇒ prox-min.  Pure algebra.
  -- ============================================================
  · intro hsub z
    have hsub_z : f u + inner ℝ (x - u) (z - u) ≤ f z := hsub z
    have inner_swap : inner ℝ (z - u) (u - x) = - inner ℝ (x - u) (z - u) := by
      rw [show u - x = -(x - u) from by abel, inner_neg_right, real_inner_comm]
    have heq : z - x = (z - u) + (u - x) := by abel
    have hid : ‖z - x‖ ^ 2
        = ‖z - u‖ ^ 2 - 2 * inner ℝ (x - u) (z - u) + ‖u - x‖ ^ 2 := by
      calc ‖z - x‖ ^ 2 = ‖(z - u) + (u - x)‖ ^ 2 := by rw [heq]
        _ = ‖z - u‖ ^ 2 + 2 * inner ℝ (z - u) (u - x) + ‖u - x‖ ^ 2 :=
            norm_add_sq_real _ _
        _ = ‖z - u‖ ^ 2 - 2 * inner ℝ (x - u) (z - u) + ‖u - x‖ ^ 2 := by
            rw [inner_swap]; ring
    have h_norm_zu_nn : 0 ≤ ‖z - u‖ ^ 2 := sq_nonneg _
    linarith [hsub_z, hid, h_norm_zu_nn]

end Theorem

end LeanAgent.Generated
