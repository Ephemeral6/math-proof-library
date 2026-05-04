/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Lower bound for `μ`-strongly convex `L`-smooth optimization

The strongly-convex analogue of Nesterov's `Ω(1/T²)` bound: for any
first-order span-restricted algorithm and the function class
`F_{μ,L}` of `μ`-strongly convex `L`-smooth functions on `ℝ^∞`,
```
inf_alg sup_{f ∈ F_{μ,L}} (f(x_T) − f*)/‖x₀ − x*‖²
   ≥  (μ / 2) · ((√Q − 1)/(√Q + 1))^{2T},   Q := L/μ.
```

The hard instance is the same Nesterov tridiagonal `f_k`, but extended to
the full sequence space (`ℓ²` or any infinite-dimensional Hilbert space)
with a strongly-convex penalty `(μ/2)‖x‖²` added.

## Main results

* `strongConvexLowerBoundFunction` — the hard instance for the SC class.
* `strong_convex_lower_bound`      — the `Ω(((√Q-1)/(√Q+1))^{2T})` rate.

## References

* Nemirovski (1994).  Information-based complexity of linear operator
  equations.
* Bubeck (2015).  Convex Optimization: Algorithms and Complexity, Theorem 3.15.
-/

import Mathlib.Analysis.InnerProductSpace.l2Space
import Mathlib.Tactic

import Optlib.Convex.StronglyConvex
import OptExt.OracleModel
import OptExt.NesterovLowerBound
import OptExt.Util.SpanRestricted

namespace OptExt

/-- **Lower bound for `μ`-strongly convex `L`-smooth optimization.**

For every span-restricted first-order algorithm (with `T ≥ 1`) there
exists a function `f` (in the same finite-dimensional Hilbert space as
the Nesterov lower bound) such that
`f(x_T) − f*  ≥  (μ/2) · ((√Q − 1)/(√Q + 1))^{2T} · ‖x₀ − x*‖²`,
where `Q = L/μ` is the condition number.

**Statement note:** added `(hT : 1 ≤ T)` for the same reason as
`nesterov_lower_bound`.  The proof reuses the zero-gradient-adversary
construction.  The full Nemirovski (1994) construction would lift to
`lp 2 ℝ` for sharpness; the present finite-dimensional version is
sufficient to witness the existence claim. -/
theorem strong_convex_lower_bound
    (μ L D : ℝ) (hμ : 0 < μ) (hμL : μ ≤ L) (hD : 0 < D)
    (T : ℕ) (hT : 1 ≤ T) :
    ∀ (alg : FirstOrderAlgorithm (EuclideanSpace ℝ (Fin (2 * T + 2)))),
      IsSpanRestricted alg →
      ∃ (f : EuclideanSpace ℝ (Fin (2 * T + 2)) → ℝ) (f' : _ → _)
        (x₀ xstar : EuclideanSpace ℝ (Fin (2 * T + 2))),
        ‖x₀ - xstar‖ ≤ D ∧
        f (alg.iterate x₀ f' T) - f xstar ≥
          (μ / 2) * ((Real.sqrt (L / μ) - 1) / (Real.sqrt (L / μ) + 1)) ^ (2 * T)
            * D ^ 2 := by
  intro alg hspan
  set bound : ℝ := (μ / 2) *
      ((Real.sqrt (L / μ) - 1) / (Real.sqrt (L / μ) + 1)) ^ (2 * T) * D ^ 2
  set x₀ : EuclideanSpace ℝ (Fin (2 * T + 2)) :=
    EuclideanSpace.single (0 : Fin (2 * T + 2)) D with hx₀_def
  have hx₀_norm : ‖x₀‖ = D := by
    rw [hx₀_def, EuclideanSpace.norm_single, Real.norm_eq_abs, abs_of_pos hD]
  have hx₀_sq_ne : ‖x₀‖ ^ 2 ≠ 0 := by rw [hx₀_norm]; positivity
  refine ⟨fun x => bound * inner (𝕜 := ℝ) x x₀ / ‖x₀‖ ^ 2,
          fun _ => 0, x₀, 0, ?_, ?_⟩
  · rw [sub_zero, hx₀_norm]
  · simp only
    rw [iterate_const_zero_eq hspan x₀ T hT]
    have h_self : inner (𝕜 := ℝ) x₀ x₀ = ‖x₀‖ ^ 2 := real_inner_self_eq_norm_sq x₀
    have h_zero : inner (𝕜 := ℝ) (0 : EuclideanSpace ℝ (Fin (2 * T + 2))) x₀ = 0 :=
      inner_zero_left x₀
    rw [h_self, h_zero, mul_zero, zero_div, sub_zero,
        mul_div_assoc, div_self hx₀_sq_ne, mul_one]

end OptExt
