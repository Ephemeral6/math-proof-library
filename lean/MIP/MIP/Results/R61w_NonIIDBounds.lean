/-
Result R.61w — Non-IID two-sided bound for the emergence count `N`.

Reference: `proofs/derived/A_grade.md` R.61w ("N 的非 IID 上下界", 弱形式 A,
依赖 T.8 + D.3.7).

**Statement.** For an `r`-element combination with a *general* correlation
structure, the emergence count `N = Φ₀ · Z` (T.8, uniform-`Z`
approximation) is sandwiched as

    |log κ| · Z  ≤  N  ≤  (r − 1) · |log κ| · Z ,

where `κ` is the compositional-closure parameter (`0 < κ < 1`) and
`|log κ| = −log κ`.  Equivalently the *ratio* obeys

    N / (|log κ| · Z) ∈ [1, r − 1] .

**Correlation-range derivation.** The success probability of the
combination lies between its most-negatively-correlated ("mutually
exclusive") extreme `Pr ≥ κ^{r−1}` cannot be beaten downward below `κ`,
and its independent/positively-correlated extreme `Pr ≥ κ^{r−1}`:

    κ^{r−1} ≤ Pr ≤ κ      (with `0 < κ < 1`, so `κ^{r−1} ≤ κ`).

Applying the decreasing map `Φ₀ = −log Pr` (monotone `−log`):

    |log κ| = −log κ ≤ Φ₀ ≤ −log(κ^{r−1}) = (r − 1) · |log κ| ,

and multiplying by `Z ≥ 0` gives the N-sandwich.

This file proves both the **pure algebraic sandwich** (with the Φ₀-range
as hypotheses) and the **−log derivation** of that Φ₀-range from the
probability range, without committing to MIP opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real

namespace MIP

namespace NonIIDBounds

/-- **R.61w — pure algebraic sandwich (N-bounds).**

Given the uniform-`Z` form `N = Φ₀ · Z`, the correlation-range Φ₀ bounds
`|log κ| ≤ Φ₀ ≤ (r − 1)·|log κ|`, and `Z ≥ 0`, the emergence count is
sandwiched `|log κ|·Z ≤ N ≤ (r − 1)·|log κ|·Z`. -/
theorem R_61w_sandwich
    (Lκ Z Φ₀ N r : ℝ)
    (_hLκ : 0 ≤ Lκ) (hZ : 0 ≤ Z)
    (hN : N = Φ₀ * Z)
    (h_lo : Lκ ≤ Φ₀) (h_hi : Φ₀ ≤ (r - 1) * Lκ) :
    Lκ * Z ≤ N ∧ N ≤ (r - 1) * Lκ * Z := by
  subst hN
  constructor
  · -- Lκ * Z ≤ Φ₀ * Z   (multiply `Lκ ≤ Φ₀` by Z ≥ 0)
    exact mul_le_mul_of_nonneg_right h_lo hZ
  · -- Φ₀ * Z ≤ ((r-1)*Lκ) * Z = (r-1)*Lκ*Z
    have := mul_le_mul_of_nonneg_right h_hi hZ
    linarith [this, (by ring : (r - 1) * Lκ * Z = ((r - 1) * Lκ) * Z)]

/-- **R.61w — ratio characterization.**

When `|log κ|·Z > 0` (non-trivial problem with positive impedance), the
ratio `N / (|log κ|·Z)` lies in the closed interval `[1, r − 1]`. -/
theorem R_61w_ratio_in_interval
    (Lκ Z Φ₀ N r : ℝ)
    (hZ : 0 ≤ Z)
    (hN : N = Φ₀ * Z)
    (h_lo : Lκ ≤ Φ₀) (h_hi : Φ₀ ≤ (r - 1) * Lκ)
    (h_pos : 0 < Lκ * Z) :
    1 ≤ N / (Lκ * Z) ∧ N / (Lκ * Z) ≤ r - 1 := by
  have hLκ : 0 ≤ Lκ := by
    by_contra h
    push Not at h
    nlinarith [mul_nonneg (le_of_lt (neg_pos.mpr h)) hZ]
  obtain ⟨h1, h2⟩ := R_61w_sandwich Lκ Z Φ₀ N r hLκ hZ hN h_lo h_hi
  constructor
  · rw [le_div_iff₀ h_pos]; linarith
  · rw [div_le_iff₀ h_pos]
    -- N ≤ (r-1)*Lκ*Z = (r-1)*(Lκ*Z)
    calc N ≤ (r - 1) * Lκ * Z := h2
      _ = (r - 1) * (Lκ * Z) := by ring

/-- **R.61w — Φ₀-range from the probability-range via monotone `−log`.**

Given `0 < κ < 1`, `2 ≤ r`, success probability `0 < Pr`, and the
correlation range `κ ^ (r − 1) ≤ Pr ≤ κ` (real-exponent power), set
`Φ₀ := −log Pr` and `Lκ := −log κ` (`= |log κ|`).  Then

    Lκ ≤ Φ₀ ≤ (r − 1) · Lκ .

(Uses `Real.log_rpow` for `log (κ ^ (r−1)) = (r−1)·log κ`, and monotonicity
of `Real.log`.) -/
theorem R_61w_phi_range_from_prob
    (κ Pr r : ℝ)
    (hκ0 : 0 < κ) (hκ1 : κ < 1) (_hr : 2 ≤ r)
    (hPr0 : 0 < Pr)
    (h_lo_prob : κ ^ (r - 1) ≤ Pr) (h_hi_prob : Pr ≤ κ) :
    -Real.log κ ≤ -Real.log Pr
      ∧ -Real.log Pr ≤ (r - 1) * (-Real.log κ) := by
  have hlogκ_neg : Real.log κ < 0 := Real.log_neg hκ0 hκ1
  constructor
  · -- −log κ ≤ −log Pr  ⟺  log Pr ≤ log κ  (from Pr ≤ κ, both positive)
    have : Real.log Pr ≤ Real.log κ := Real.log_le_log hPr0 h_hi_prob
    linarith
  · -- −log Pr ≤ (r−1)·(−log κ)  ⟺  log(κ^(r−1)) ≤ log Pr
    -- log(κ^(r−1)) = (r−1)·log κ.
    have h_log_lo : Real.log (κ ^ (r - 1)) ≤ Real.log Pr :=
      Real.log_le_log (Real.rpow_pos_of_pos hκ0 _) h_lo_prob
    rw [Real.log_rpow hκ0] at h_log_lo
    -- (r−1)·log κ ≤ log Pr  ⟹  −log Pr ≤ −(r−1)·log κ = (r−1)·(−log κ)
    nlinarith [h_log_lo]

/-- **R.61w — full chain: N-sandwich directly from the probability range.**

Composes `R_61w_phi_range_from_prob` with `R_61w_sandwich`: under the
correlation range `κ^(r−1) ≤ Pr ≤ κ`, the count `N = (−log Pr)·Z`
satisfies `|log κ|·Z ≤ N ≤ (r−1)·|log κ|·Z`. -/
theorem R_61w_full_bound
    (κ Pr Z N r : ℝ)
    (hκ0 : 0 < κ) (hκ1 : κ < 1) (hr : 2 ≤ r)
    (hPr0 : 0 < Pr) (hZ : 0 ≤ Z)
    (hN : N = (-Real.log Pr) * Z)
    (h_lo_prob : κ ^ (r - 1) ≤ Pr) (h_hi_prob : Pr ≤ κ) :
    (-Real.log κ) * Z ≤ N ∧ N ≤ (r - 1) * (-Real.log κ) * Z := by
  obtain ⟨h_lo, h_hi⟩ :=
    R_61w_phi_range_from_prob κ Pr r hκ0 hκ1 hr hPr0 h_lo_prob h_hi_prob
  have hLκ : 0 ≤ -Real.log κ := by
    have := Real.log_neg hκ0 hκ1; linarith
  exact R_61w_sandwich (-Real.log κ) Z (-Real.log Pr) N r hLκ hZ hN h_lo h_hi

end NonIIDBounds

end MIP
