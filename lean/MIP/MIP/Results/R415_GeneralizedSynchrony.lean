/-
Result R.415 — Generalized synchrony as the T.30 second phase transition
`t*`: dyad mutual information peaks at `t*` then drifts.

Reference: `workspace/multiagent_fep_mip.md` §R.415 (A 条件, 2026-05-16
multi-agent FEP-MIP block), steps 1-3 + (F4-multi) upgrade.

**Statement.** Friston's interactive FEP usually assumes the dyad mutual
information `I(μ_1(t); μ_2(t))` is *monotone increasing*. MIP's R.134-v2
(T.30 second phase transition) corrects this: the cross-agent mutual
information has a *unique maximum* at the second phase transition time `t*`,
and **drifts (decreases) afterwards** ("partial decoupling"). Formally `I`
is unimodal:

* strictly increasing on `(-∞, t*]` (the hermeneutic / co-driving phase),
* strictly decreasing on `[t*, ∞)` (the drift / decoupling phase),

so `t*` is the unique global maximizer and (for a differentiable model)
`I'(t*) = 0`.

This file gives **two** encodings:

1. **Hypothesis-driven core.** From "strictly increasing before `t*`,
   strictly decreasing after `t*`", we derive that `t*` is the *strict*
   global maximizer: `I t < I t*` for every `t ≠ t*`.

2. **Concrete unimodal model.** The parabola `I t := c - (t - t*)^2` is
   shown to peak at `t*`: it is strictly increasing before, strictly
   decreasing after, has `I'(t*) = 0`, and `t*` is its unique global
   maximizer with value `c`.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Linarith

namespace MIP

namespace GeneralizedSynchrony

/-! ## Part 1: hypothesis-driven unimodal core -/

/-- **R.415 — unique peak at `t*` from before/after monotonicity.**

If the mutual-information curve `I` is strictly increasing on `(-∞, t*]`
(`h_inc`) and strictly decreasing on `[t*, ∞)` (`h_dec`), then `t*` is the
*strict* global maximizer: every `t ≠ t*` has `I t < I t*`. This is the
crisp "synchrony peaks at the second phase transition" statement. -/
theorem R_415_unique_peak
    (I : ℝ → ℝ) (t_star : ℝ)
    (h_inc : ∀ s t, s < t → t ≤ t_star → I s < I t)
    (h_dec : ∀ s t, t_star ≤ s → s < t → I t < I s) :
    ∀ t, t ≠ t_star → I t < I t_star := by
  intro t ht
  rcases lt_or_gt_of_ne ht with hlt | hgt
  · -- t < t_star : increasing phase, with endpoint t_star.
    exact h_inc t t_star hlt (le_refl t_star)
  · -- t > t_star : decreasing phase, from t_star.
    exact h_dec t_star t (le_refl t_star) hgt

/-- **R.415 — `I` is not monotone increasing across `t*` (drift exists).**

The MIP correction to Friston: there *is* a strict drop after the peak. For
any `t > t*`, `I t < I t*`, so `I` fails to be globally nondecreasing —
the post-`t*` drift phase is real. -/
theorem R_415_drift_after_peak
    (I : ℝ → ℝ) (t_star : ℝ)
    (h_dec : ∀ s t, t_star ≤ s → s < t → I t < I s)
    (t : ℝ) (ht : t_star < t) :
    I t < I t_star :=
  h_dec t_star t (le_refl t_star) ht

/-! ## Part 2: concrete unimodal model `I t = c - (t - t*)^2` -/

/-- The concrete mutual-information model: a downward parabola peaking at
`t*` with peak value `c`. `I t = c - (t - t*)^2`. -/
noncomputable def Imodel (c t_star t : ℝ) : ℝ := c - (t - t_star) ^ 2

/-- **R.415 (model) — `t*` is the strict global maximizer.**

For the parabolic model, `I t ≤ c = I t*` for all `t`, with equality iff
`t = t*`. So `t*` is the unique peak. -/
theorem R_415_model_unique_max (c t_star : ℝ) :
    (Imodel c t_star t_star = c) ∧
    (∀ t, Imodel c t_star t ≤ c) ∧
    (∀ t, t ≠ t_star → Imodel c t_star t < c) := by
  refine ⟨?_, ?_, ?_⟩
  · simp [Imodel]
  · intro t
    have hsq : 0 ≤ (t - t_star) ^ 2 := sq_nonneg _
    unfold Imodel
    linarith
  · intro t ht
    have hne : t - t_star ≠ 0 := sub_ne_zero.mpr ht
    have hsq : 0 < (t - t_star) ^ 2 := by positivity
    unfold Imodel
    linarith

/-- **R.415 (model) — strictly increasing before `t*`.** For `s < t ≤ t*`,
`I s < I t`: the co-driving phase. -/
theorem R_415_model_increasing_before (c t_star : ℝ)
    (s t : ℝ) (hst : s < t) (ht : t ≤ t_star) :
    Imodel c t_star s < Imodel c t_star t := by
  unfold Imodel
  -- need (t - t*)^2 < (s - t*)^2, i.e. |t - t*| < |s - t*| since both ≤ 0 side.
  -- s < t ≤ t* ⟹ s - t* < t - t* ≤ 0 ⟹ (s-t*)^2 > (t-t*)^2.
  nlinarith [sq_nonneg (s - t_star), sq_nonneg (t - t_star)]

/-- **R.415 (model) — strictly decreasing after `t*`.** For `t* ≤ s < t`,
`I t < I s`: the drift / decoupling phase. -/
theorem R_415_model_decreasing_after (c t_star : ℝ)
    (s t : ℝ) (hs : t_star ≤ s) (hst : s < t) :
    Imodel c t_star t < Imodel c t_star s := by
  unfold Imodel
  -- t* ≤ s < t ⟹ 0 ≤ s - t* < t - t* ⟹ (s-t*)^2 < (t-t*)^2.
  nlinarith [sq_nonneg (s - t_star), sq_nonneg (t - t_star)]

/-- **R.415 (model) — `I'(t*) = 0`.** The peak is a critical point: the
derivative of the parabolic model vanishes at `t*`. -/
theorem R_415_model_deriv_zero (c t_star : ℝ) :
    HasDerivAt (Imodel c t_star) 0 t_star := by
  -- I t = c - (t - t*)^2. d/dt = -2(t - t*); at t = t* this is 0.
  have hbase : HasDerivAt (fun t : ℝ => (t - t_star) ^ 2)
      (2 * (t_star - t_star) ^ 1 * 1) t_star := by
    have h1 : HasDerivAt (fun t : ℝ => t - t_star) (1 : ℝ) t_star :=
      (hasDerivAt_id t_star).sub_const t_star
    simpa using h1.pow 2
  have hsq : HasDerivAt (fun t : ℝ => (t - t_star) ^ 2) 0 t_star := by
    simpa using hbase
  have : HasDerivAt (fun t : ℝ => c - (t - t_star) ^ 2) (0 - 0) t_star :=
    (hasDerivAt_const t_star c).sub hsq
  simpa [Imodel] using this

end GeneralizedSynchrony

end MIP
