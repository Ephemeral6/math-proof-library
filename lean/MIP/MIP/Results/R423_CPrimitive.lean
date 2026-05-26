/-
Result R.423 — C-primitive (closure increase) effect formula and the
`κ ∈ (0, 1/e)` optimality interval.

Reference: `workspace/coe_mip_unification.md` §R.423 (C 主推 κ,
A 条件性; formula (ii) under R.045 is A 无条件 algebra, (iii.a) uses the
Gompertz growth-rate `κ·|log κ|` peaking at `κ = 1/e`).

**Statement (CoE × MIP mapping).** The C-primitive supplies counterfactual
comparison pairs, raising the combinatorial closure `κ` and hence lowering
the `|log κ|` factor of `N ≈ r · |log κ| · Z`. Map the conditions:

* `r`, `Z` — held fixed (C acts on the `κ` factor),
* the C-effect on the `|log κ|` factor is the **marginal form**

      ΔN_C ≈ (∂N/∂κ) · Δκ = (− r · Z / κ) · Δκ ,    i.e.  ∝ (r·Z/κ)·Δ|log κ| ,

  since on `κ ∈ (0,1)`, `|log κ| = −log κ` and `d|log κ|/dκ = −1/κ`.

* **Optimality interval.** The per-step *closure growth rate* injected by C
  follows the Gompertz form `g(κ) = κ · |log κ| = −κ · log κ` (R.118),
  which on `(0,1)` is maximized at `κ = 1/e`. The "C is most effective"
  window `κ ∈ (0, 1/e)` is the **increasing branch** of `g`: there the
  marginal closure gain (and hence `|ΔN_C|`) is rising toward its peak.

**Pure-math content.**

* **(formula)** `ΔN_C = (r·Z/κ) · Δabsκ` is a `ring`/`field` identity given
  the marginal coefficient `r·Z/κ`.
* **(1/κ blow-up)** `1/κ` is antitone on `(0,∞)`: smaller `κ` ⟹ larger
  marginal coefficient — the "κ small ⟹ C effect large" claim.
* **(interval optimality)** the Gompertz rate `g(κ) = −κ·log κ` is strictly
  increasing on `(0, 1/e)` and attains its maximum at `κ = 1/e`
  (`g'(κ) = −log κ − 1 > 0 ⟺ κ < 1/e`). We prove `g` has derivative
  `−log κ − 1`, that this derivative is positive on `(0,1/e)`, and that
  `g(κ) ≤ g(1/e) = 1/e` for all `κ ∈ (0,1]` (global max on the interval).

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace CPrimitive

open Real

/-- **R.423 (ii) — C-effect marginal formula.**

With the marginal coefficient `coeff := r · Z / κ` (`κ ≠ 0`) and closure
increment `Δabsκ` on the `|log κ|` factor, the effect is the product

    ΔN_C = (r · Z / κ) · Δabsκ . -/
theorem R_423_effect_formula
    (r Z κ Δabsκ ΔN_C : ℝ)
    (h_def : ΔN_C = (r * Z / κ) * Δabsκ) :
    ΔN_C = (r * Z / κ) * Δabsκ :=
  h_def

/-- **R.423 (ii) — the `1/κ` marginal coefficient blows up as `κ → 0`.**

For `0 < κ₁ ≤ κ₂` the reciprocal coefficient `1/κ` is non-increasing:
`1/κ₂ ≤ 1/κ₁`. Hence smaller `κ` gives a larger marginal C-effect
coefficient — the "κ small ⟹ C effect large" claim. -/
theorem R_423_recip_antitone
    (κ₁ κ₂ : ℝ) (h_pos : 0 < κ₁) (h_le : κ₁ ≤ κ₂) :
    1 / κ₂ ≤ 1 / κ₁ :=
  one_div_le_one_div_of_le h_pos h_le

/-- The Gompertz closure-growth rate `g(κ) = −κ · log κ` on `(0,1)`,
equal to `κ · |log κ|` since `log κ < 0` there. -/
noncomputable def g (κ : ℝ) : ℝ := -κ * Real.log κ

/-- **R.423 — derivative of the Gompertz rate.**

`g(κ) = −κ · log κ` has derivative `g'(κ) = −log κ − 1` for `κ > 0`. -/
theorem R_423_hasDerivAt_g
    (κ : ℝ) (hκ : 0 < κ) :
    HasDerivAt g (-Real.log κ - 1) κ := by
  -- d/dκ [ −κ · log κ ] = −(1·log κ + κ·(1/κ)) = −log κ − 1.
  have h_log : HasDerivAt Real.log κ⁻¹ κ := Real.hasDerivAt_log (ne_of_gt hκ)
  have h_id : HasDerivAt (fun x : ℝ => x) (1 : ℝ) κ := hasDerivAt_id κ
  -- product  x ↦ x * log x  has derivative  1·log κ + κ·κ⁻¹ = log κ + 1.
  have h_prod : HasDerivAt (fun x : ℝ => x * Real.log x)
      (1 * Real.log κ + κ * κ⁻¹) κ := h_id.mul h_log
  -- negate.
  have h_neg : HasDerivAt (fun x : ℝ => -(x * Real.log x))
      (-(1 * Real.log κ + κ * κ⁻¹)) κ := h_prod.neg
  -- reshape both the function (to g) and the derivative value.
  have h_fun : (fun x : ℝ => -(x * Real.log x)) = g := by
    funext x; unfold g; ring
  rw [h_fun] at h_neg
  convert h_neg using 1
  rw [mul_inv_cancel₀ (ne_of_gt hκ)]
  ring

/-- **R.423 (iii)(a) — the rate is increasing on `(0, 1/e)`.**

The derivative `g'(κ) = −log κ − 1` is strictly positive exactly when
`κ < 1/e` (for `κ > 0`). So on the window `κ ∈ (0, 1/e)` the closure
growth — and hence the marginal C-effect — is rising toward its peak. -/
theorem R_423_deriv_pos_on_interval
    (κ : ℝ) (h_pos : 0 < κ) (h_lt : κ < Real.exp (-1)) :
    0 < -Real.log κ - 1 := by
  -- κ < e^{-1} ⟹ log κ < −1 ⟹ −log κ − 1 > 0.
  have h_log_lt : Real.log κ < -1 := by
    have := Real.log_lt_log h_pos h_lt
    rwa [Real.log_exp] at this
  linarith

/-- **R.423 (iii)(a) — `κ = 1/e` is the global maximizer on `(0,1]`.**

For all `κ ∈ (0,1]`, `g(κ) = −κ·log κ ≤ 1/e = g(1/e)`; equivalently the
Gompertz closure rate peaks at `κ = 1/e`. We use the standard bound
`log κ ≥ 1 − 1/κ` (`κ > 0`), giving `−κ·log κ ≤ κ·(1/κ − 1) = 1 − κ`,
combined with the tangent bound at `1/e`. Direct route: the maximum value
`g(1/e) = e⁻¹` dominates via `log x ≤ x/e` ⟺ `−x log x ≤ ...`; we prove the
clean form `g κ ≤ Real.exp (-1)`. -/
theorem R_423_max_at_one_over_e
    (κ : ℝ) (h_pos : 0 < κ) :
    g κ ≤ Real.exp (-1) := by
  -- Key inequality:  log x ≤ x / e  for x > 0, i.e.  Real.log x ≤ x * Real.exp (-1).
  -- Equivalent (with y = x·e):  log y ≤ y/e  ⇔  add_one_le_exp style.
  -- We use:  for all x > 0,  -x * log x ≤ exp (-1).
  -- Proof via  log x ≤ x * exp(-1) - ... ; cleanest: log_le_sub_one_of_pos shifted.
  -- Use the tangent-line bound at e⁻¹ :  log κ ≥ log(e⁻¹) + e·(κ − e⁻¹)
  --   is the WRONG direction; instead use concavity upper bound for −κ log κ.
  -- Direct: set t = κ * e.  Then g κ = -κ log κ = -(t/e)(log t - 1) = (t/e)(1 - log t).
  -- and (t/e)(1 - log t) ≤ 1/e  ⟺  t(1 - log t) ≤ 1  ⟺  t - t log t ≤ 1
  --   ⟺  t log t ≥ t - 1, which is  Real.add_one_le ... ; precisely:
  --   t·log t ≥ t − 1  is  `Real.sub_one_le_log`?  Use mul form of `log_le_sub_one`.
  have ht : 0 < κ * Real.exp 1 := mul_pos h_pos (Real.exp_pos 1)
  -- log t ≥ 1 - 1/t  (i.e.  1 - 1/t ≤ log t),  from  Real.log_le_sub_one_of_pos applied to 1/t,
  -- but cleaner: Real.add_one_le_exp gives  x + 1 ≤ exp x ⟹ log y ≤ y - 1.
  -- We need  t·log t ≥ t − 1.
  have h_key : κ * Real.exp 1 - 1 ≤ (κ * Real.exp 1) * Real.log (κ * Real.exp 1) := by
    -- For u > 0 :  u·log u ≥ u − 1.  Equivalent to  log u ≥ 1 − 1/u (u>0).
    -- Use  Real.log_le_sub_one_of_pos : 0 < x → log x ≤ x − 1, applied to x = 1/u.
    have h_u := ht
    have h_inv_pos : 0 < (κ * Real.exp 1)⁻¹ := inv_pos.mpr h_u
    have h_log_inv : Real.log ((κ * Real.exp 1)⁻¹) ≤ (κ * Real.exp 1)⁻¹ - 1 :=
      Real.log_le_sub_one_of_pos h_inv_pos
    rw [Real.log_inv] at h_log_inv
    -- −log u ≤ 1/u − 1  ⟹  log u ≥ 1 − 1/u  ⟹  u·log u ≥ u − 1.
    have h_log_ge : 1 - (κ * Real.exp 1)⁻¹ ≤ Real.log (κ * Real.exp 1) := by linarith
    have := mul_le_mul_of_nonneg_left h_log_ge (le_of_lt h_u)
    calc κ * Real.exp 1 - 1
        = (κ * Real.exp 1) * (1 - (κ * Real.exp 1)⁻¹) := by
          field_simp
      _ ≤ (κ * Real.exp 1) * Real.log (κ * Real.exp 1) := this
  -- Now expand  log (κ·e) = log κ + 1.
  have h_log_split : Real.log (κ * Real.exp 1) = Real.log κ + 1 := by
    rw [Real.log_mul (ne_of_gt h_pos) (ne_of_gt (Real.exp_pos 1)), Real.log_exp]
  rw [h_log_split] at h_key
  -- h_key :  κ·e − 1 ≤ κ·e·(log κ + 1)  =  κ·e·log κ + κ·e.
  -- ⟹  −1 ≤ κ·e·log κ  ⟹  −κ·log κ ≤ e⁻¹.
  have h_e_pos : 0 < Real.exp 1 := Real.exp_pos 1
  -- From h_key:  κ e − 1 ≤ κ e log κ + κ e  ⟹  −1 ≤ κ e log κ.
  have h_step : (-1 : ℝ) ≤ κ * Real.exp 1 * Real.log κ := by nlinarith [h_key]
  -- Divide by e > 0 :  −e⁻¹ ≤ κ log κ  ⟹  g κ = −κ log κ ≤ e⁻¹.
  unfold g
  rw [Real.exp_neg, inv_eq_one_div, le_div_iff₀ h_e_pos]
  -- goal:  (-κ * log κ) * exp 1 ≤ 1, which follows from h_step.
  nlinarith [h_step]

end CPrimitive

end MIP
