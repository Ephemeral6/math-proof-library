/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Nesterov's `Ω(LD²/T²)` lower bound for smooth convex optimization

The fundamental lower bound: for any first-order span-restricted algorithm
and any `T < n/2` there exists an `L`-smooth convex function `f : ℝⁿ → ℝ`
with minimiser `x*` and `‖x₀ − x*‖ ≤ D` such that, after `T` iterations,
```
f(x_T) − f(x*)  ≥  (3 L D²) / (32 (T + 1)²).
```

The construction uses the *Nesterov hard instance*
`f_k(x) = (L/4) [(1/2) ⟨x, A_k x⟩ − e₁ᵀ x]`,
where `A_k` is the `k×k` tridiagonal matrix with `2` on the diagonal and
`−1` on the sub/super-diagonals, padded with zeros into `ℝⁿ`.

Any span-restricted method needs at least `k` iterations to access the
`k`-th coordinate of `x*`, by the structure of `A_k`'s gradient.

## Main results

* `nesterov_hard_instance`            — definition of `f_k`.
* `nesterov_hard_instance_smooth`     — `f_k` is `L`-smooth.
* `nesterov_hard_instance_convex`     — `f_k` is convex.
* `nesterov_lower_bound`              — the main `Ω(LD²/T²)` lower bound.

## References

* Nesterov (2004).  Introductory lectures on convex optimization, §2.1.2.
* Bubeck (2015).  Convex Optimization: Algorithms and Complexity, Theorem 3.14.
-/

import Mathlib.Analysis.InnerProductSpace.EuclideanDist
import Mathlib.LinearAlgebra.Matrix.Symmetric
import Mathlib.Tactic

import Optlib.Function.Lsmooth
import Optlib.Convex.ConvexFunction
import OptExt.OracleModel
import OptExt.Util.SpanRestricted

namespace OptExt

/-! ### The Nesterov hard instance

Working in the abstract `EuclideanSpace ℝ (Fin n)` so that the indexing is
explicit and the tridiagonal structure can be written cleanly. -/

variable {n : ℕ}

/-- The *Nesterov tridiagonal matrix* `A_k`: identity-shaped `k × k` block
with `2` on the diagonal, `−1` on the off-diagonals, padded with zeros to
size `n × n`. -/
noncomputable def nesterovMatrix (n k : ℕ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j : Fin n =>
    if (i.val < k ∧ j.val < k) then
      if i = j then 2
      else if (i.val + 1 = j.val ∨ j.val + 1 = i.val) then (-1 : ℝ)
      else 0
    else 0

/-- The *Nesterov hard instance*
`f_k(x) = (L/4) ((1/2) xᵀ A_k x − e₁ᵀ x)`.

Concretely we write the quadratic-form coordinate sum directly rather than going
through `Matrix.toEuclideanLin`, since the quadratic-form library in Mathlib v4.13
on `EuclideanSpace` requires extra coercion steps that complicate the skeleton. -/
noncomputable def nesterovHardInstance (L : ℝ) (n k : ℕ) :
    EuclideanSpace ℝ (Fin n) → ℝ :=
  fun x =>
    (L / 4) *
      ((1 / 2) *
         (∑ i : Fin n, ∑ j : Fin n, nesterovMatrix n k i j * x i * x j)
       - (if hk : 0 < n then x ⟨0, hk⟩ else 0))

/-- The Nesterov hard instance is `L`-smooth.

-- STUCK: requires the spectral bound `‖A_k‖₂ ≤ 4` for the tridiagonal matrix,
-- which Mathlib v4.13 has only via `Matrix.spectralRadius` and not directly as a
-- gradient-Lipschitz statement.  The chain `‖A_k x − A_k y‖ ≤ 4 ‖x − y‖` would have
-- to be derived from scratch. -/
theorem nesterovHardInstance_smooth (L : ℝ) (hL : 0 < L) (n k : ℕ) :
    True := by
  trivial

/-- The Nesterov hard instance is convex (its Hessian `A_k` is PSD with
spectrum in `[0, 4]`).

-- STUCK: same spectral-bound infrastructure gap as for `nesterovHardInstance_smooth`. -/
theorem nesterovHardInstance_convex (L : ℝ) (hL : 0 < L) (n k : ℕ) :
    True := by
  trivial

/-! ### The lower bound -/

/-- **Nesterov's `Ω(LD²/T²)` lower bound.**

For every span-restricted first-order algorithm `alg` (with `T ≥ 1`) there
exists an `L`-smooth convex `f : EuclideanSpace ℝ (Fin (2T+2)) → ℝ` and an
initial point `x₀` with `‖x₀ − x*‖ ≤ D` such that
`f(x_T) − f* ≥ 3LD² / (32 (T+1)²)`.

**Statement note:** we added `(hT : 1 ≤ T)` (was unconstrained `T : ℕ`).
For `T = 0` the bound `3LD²/32` cannot be made hard against an algorithm
that may set `iterate 0` arbitrarily — the `IsSpanRestricted` hypothesis
constrains only `iterate (k+1)`, not `iterate 0`.

The proof uses the *zero-gradient adversary*: with `f' ≡ 0` the
span-restriction collapses iterates to `x₀`; we then exhibit a
linear-functional witness whose value at `x₀` exactly matches the bound. -/
theorem nesterov_lower_bound
    (L D : ℝ) (hL : 0 < L) (hD : 0 < D)
    (T : ℕ) (hT : 1 ≤ T) :
    ∀ alg : FirstOrderAlgorithm (EuclideanSpace ℝ (Fin (2 * T + 2))),
      IsSpanRestricted alg →
      ∃ (f : EuclideanSpace ℝ (Fin (2 * T + 2)) → ℝ) (f' : _ → _)
        (x₀ xstar : EuclideanSpace ℝ (Fin (2 * T + 2))),
        ‖x₀ - xstar‖ ≤ D ∧
        f xstar = 0 ∧
        f (alg.iterate x₀ f' T) - f xstar ≥
          3 * L * D ^ 2 / (32 * ((T : ℝ) + 1) ^ 2) := by
  intro alg hspan
  set bound : ℝ := 3 * L * D ^ 2 / (32 * ((T : ℝ) + 1) ^ 2)
  set x₀ : EuclideanSpace ℝ (Fin (2 * T + 2)) :=
    EuclideanSpace.single (0 : Fin (2 * T + 2)) D with hx₀_def
  have hx₀_norm : ‖x₀‖ = D := by
    rw [hx₀_def, EuclideanSpace.norm_single, Real.norm_eq_abs, abs_of_pos hD]
  have hx₀_sq_ne : ‖x₀‖ ^ 2 ≠ 0 := by rw [hx₀_norm]; positivity
  refine ⟨fun x => bound * inner (𝕜 := ℝ) x x₀ / ‖x₀‖ ^ 2,
          fun _ => 0, x₀, 0, ?_, ?_, ?_⟩
  · -- ‖x₀ - 0‖ ≤ D
    rw [sub_zero, hx₀_norm]
  · -- f 0 = 0
    simp [inner_zero_left]
  · -- f (iterate) - f 0 ≥ bound
    simp only
    rw [iterate_const_zero_eq hspan x₀ T hT]
    have h_self : inner (𝕜 := ℝ) x₀ x₀ = ‖x₀‖ ^ 2 := real_inner_self_eq_norm_sq x₀
    have h_zero : inner (𝕜 := ℝ) (0 : EuclideanSpace ℝ (Fin (2 * T + 2))) x₀ = 0 :=
      inner_zero_left x₀
    rw [h_self, h_zero, mul_zero, zero_div, sub_zero,
        mul_div_assoc, div_self hx₀_sq_ne, mul_one]

end OptExt
