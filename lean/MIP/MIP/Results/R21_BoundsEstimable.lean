/-
Result R.21 — The N upper/lower bounds (|B|, ⌈Φ₀·Z⌉) are experimentally
estimable to `O(1/√n)`.

Reference: `proofs/derived/A_grade.md` R.21 (A 条件 under algorithm convergence /
state-space parameterizability).

**Statement.** There is an algorithm estimating, to any precision, the lower
bound `|B(p, A)|` (number of independent barriers, T.1) and the upper bound
`⌈Φ₀·Z_max⌉` (T.8).  Both estimators converge at the Glivenko–Cantelli /
LLN rate `O(n^{-1/2})`:

* `Φ̂₀`  with  `|Φ̂₀ − Φ₀| ≤ O(1/√n)`  (LLN on the empirical success rate),
* `|B̂|` with  `||B̂| − |B|| ≤ O(1/√n)` (χ²-test independence-graph estimate).

**Pure-math kernel (Hypothesis-Bundle encoding).** Each of the two estimator
sequences carries a bundled `C / sqrt n` error bound; we prove that **both**
estimators are consistent:

    lower_hat n → lower    and    upper_hat n → upper      as `n → ∞`.

The kernel is the same squeeze as R.2 (`C / sqrt n → 0`), applied to two
estimators with their own rate constants, plus the conclusion that the pair
converges jointly to the true `(lower, upper)`.

**This file is `axiom`-free.**  The MIP-side machinery (T.1, T.8, the χ²
independence test, the ε-net for `Z_max`) enters only through the two
explicit error-bound hypotheses.
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Order.Filter.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.Linarith

namespace MIP

namespace BoundsEstimable

open Filter Topology

/-- **Auxiliary: `C / sqrt n → 0` as `n → ∞`** (shared rate kernel). -/
theorem tendsto_const_div_sqrt (C : ℝ) :
    Tendsto (fun n : ℕ => C / Real.sqrt n) atTop (nhds 0) := by
  have h_sqrt : Tendsto (fun n : ℕ => Real.sqrt n) atTop atTop := by
    have h_nat : Tendsto (fun n : ℕ => (n : ℝ)) atTop atTop :=
      tendsto_natCast_atTop_atTop
    exact Real.tendsto_sqrt_atTop.comp h_nat
  have h_inv : Tendsto (fun n : ℕ => (Real.sqrt n)⁻¹) atTop (nhds 0) :=
    h_sqrt.inv_tendsto_atTop
  have h_mul : Tendsto (fun n : ℕ => C * (Real.sqrt n)⁻¹) atTop (nhds (C * 0)) :=
    tendsto_const_nhds.mul h_inv
  simp only [mul_zero] at h_mul
  simpa [div_eq_mul_inv] using h_mul

/-- **Auxiliary: a single `O(1/√n)`-rate estimator is consistent.**

If `θ_hat n` satisfies `|θ_hat n − θ| ≤ C / sqrt n` for all `n ≥ 1`, then
`θ_hat n → θ`. -/
theorem consistent_of_sqrt_rate
    (θ_hat : ℕ → ℝ) (θ C : ℝ)
    (h_rate : ∀ n : ℕ, 1 ≤ n → |θ_hat n - θ| ≤ C / Real.sqrt n) :
    Tendsto θ_hat atTop (nhds θ) := by
  rw [← tendsto_sub_nhds_zero_iff, tendsto_zero_iff_abs_tendsto_zero]
  apply squeeze_zero' (f := fun n : ℕ => |θ_hat n - θ|)
      (g := fun n : ℕ => C / Real.sqrt n)
  · exact Eventually.of_forall (fun n => abs_nonneg _)
  · filter_upwards [eventually_ge_atTop 1] with n hn
    exact h_rate n hn
  · exact tendsto_const_div_sqrt C

/-- **R.21 — both bounds are estimable to `O(1/√n)`.**

Given a lower-bound estimator `lower_hat` (for `|B(p,A)|`) with rate
`C_lo / sqrt n`, and an upper-bound estimator `upper_hat`
(for `⌈Φ₀·Z_max⌉`) with rate `C_hi / sqrt n`, both estimators are
consistent:

    lower_hat n → lower    and    upper_hat n → upper .

Hence the pair `(lower_hat n, upper_hat n) → (lower, upper)`, i.e. the
two N-bounds are experimentally estimable to any precision. -/
theorem R_21_bounds_estimable
    (lower_hat upper_hat : ℕ → ℝ) (lower upper C_lo C_hi : ℝ)
    (h_rate_lo : ∀ n : ℕ, 1 ≤ n → |lower_hat n - lower| ≤ C_lo / Real.sqrt n)
    (h_rate_hi : ∀ n : ℕ, 1 ≤ n → |upper_hat n - upper| ≤ C_hi / Real.sqrt n) :
    Tendsto lower_hat atTop (nhds lower) ∧
      Tendsto upper_hat atTop (nhds upper) :=
  ⟨consistent_of_sqrt_rate lower_hat lower C_lo h_rate_lo,
   consistent_of_sqrt_rate upper_hat upper C_hi h_rate_hi⟩

/-- **R.21 (joint form).**

The pair-valued estimator `n ↦ (lower_hat n, upper_hat n)` converges to the
true pair `(lower, upper)` in the product topology. -/
theorem R_21_bounds_estimable_joint
    (lower_hat upper_hat : ℕ → ℝ) (lower upper C_lo C_hi : ℝ)
    (h_rate_lo : ∀ n : ℕ, 1 ≤ n → |lower_hat n - lower| ≤ C_lo / Real.sqrt n)
    (h_rate_hi : ∀ n : ℕ, 1 ≤ n → |upper_hat n - upper| ≤ C_hi / Real.sqrt n) :
    Tendsto (fun n : ℕ => (lower_hat n, upper_hat n)) atTop
      (nhds (lower, upper)) :=
  (consistent_of_sqrt_rate lower_hat lower C_lo h_rate_lo).prodMk_nhds
    (consistent_of_sqrt_rate upper_hat upper C_hi h_rate_hi)

end BoundsEstimable

end MIP
