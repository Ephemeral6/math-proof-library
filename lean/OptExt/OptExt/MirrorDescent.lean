/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Mirror descent

The mirror descent method (Nemirovski–Yudin 1983, Beck–Teboulle 2003)
generalises gradient descent by replacing the Euclidean potential
`(1/2)‖·‖²` by a strongly convex *mirror map* `h : E → ℝ`.  The associated
*Bregman divergence*
```
D_h(x, y) := h(x) − h(y) − ⟨∇h(y), x − y⟩
```
is non-negative and zero iff `x = y` (when `h` is strictly convex).  The
update rule is
```
x_{k+1} = argmin_{x ∈ C} { ⟨g_k, x⟩ + (1/η) D_h(x, x_k) },     g_k = ∇f(x_k).
```

For `η = 1/L` and `f` convex `L`-smooth (with `L` the smoothness constant
in the norm dual to `h`), one obtains the same `O(1/T)` rate as gradient
descent — but with a constant that may be exponentially smaller in
`dim(E)` for well-chosen `h`.

## Main definitions

* `BregmanDivergence h x y`        — `h(x) − h(y) − ⟨∇h(y), x − y⟩`.
* `MirrorDescent`                  — class packaging the algorithmic state.
* `MirrorDescent.iterate`          — the iterate sequence.

## Main results

* `bregman_divergence_nonneg`      — non-negativity for convex `h`.
* `mirror_descent_one_step`        — single-step Bregman descent identity.
* `mirror_descent_converge`        — `O(D_h(x*, x₀) / (η T))` convergence.

## Reuse from optlib

* `Optlib.Convex.ConvexFunction.Convex_first_order_condition`
* `Optlib.Convex.StronglyConvex.Strong_Convex_second_lower`
* `Optlib.Function.Lsmooth.lipschitz_continuos_upper_bound'`
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Convex.Function
import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Tactic

import Optlib.Convex.ConvexFunction
import Optlib.Convex.StronglyConvex
import Optlib.Function.Lsmooth

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-! ### Bregman divergence -/

/-- The *Bregman divergence* induced by a (smooth, convex) mirror map `h`
with gradient `h'`:
`D_h(x, y) := h(x) − h(y) − ⟨h'(y), x − y⟩`.

When `h(x) = (1/2)‖x‖²` (Euclidean), `D_h(x, y) = (1/2)‖x − y‖²`. -/
noncomputable def BregmanDivergence (h : E → ℝ) (h' : E → E) (x y : E) : ℝ :=
  h x - h y - inner (𝕜 := ℝ) (h' y) (x - y)

/-- Non-negativity of the Bregman divergence for convex differentiable `h`. -/
theorem bregman_divergence_nonneg
    (h : E → ℝ) (h' : E → E)
    (h_conv : ConvexOn ℝ Set.univ h)
    (h_diff : ∀ y, HasGradientAt h (h' y) y)
    (x y : E) :
    0 ≤ BregmanDivergence h h' x y := by
  have key := Convex_first_order_condition' (h_diff y) h_conv (Set.mem_univ y)
                  x (Set.mem_univ x)
  unfold BregmanDivergence
  linarith

/-! ### The Mirror Descent algorithm -/

/-- Mirror descent on `min_{x ∈ E} f(x)` with mirror map `h` (strictly
convex with gradient `h'`) and step size `η > 0`.  We package the
prox-mapping as an opaque `prox` step so that the formal definition does
not require closed-form access to `argmin`. -/
class MirrorDescent
    (f : E → ℝ) (f' : E → E)
    (h : E → ℝ) (h' : E → E) where
  /-- Step size. -/
  η         : ℝ
  /-- Initial iterate. -/
  x₀        : E
  /-- The mirror-descent prox step:
      `prox η g x` returns `argmin_y { η · ⟨g, y⟩ + D_h(y, x) }`. -/
  prox      : ℝ → E → E → E
  /-- Step-size positivity. -/
  η_pos     : 0 < η
  /-- `f` is convex. -/
  f_convex  : ConvexOn ℝ Set.univ f
  /-- `h` is strictly convex (so `D_h` is a genuine divergence). -/
  h_strict  : StrictConvexOn ℝ Set.univ h
  /-- `prox` actually minimises the surrogate.  This is a structural
      assumption stating that the user has supplied a true argmin oracle. -/
  prox_spec :
    ∀ (η' : ℝ) (g x : E),
      ∀ y : E,
        η' * inner (𝕜 := ℝ) g (prox η' g x) + BregmanDivergence h h' (prox η' g x) x ≤
          η' * inner (𝕜 := ℝ) g y + BregmanDivergence h h' y x

namespace MirrorDescent

variable {f : E → ℝ} {f' : E → E} {h : E → ℝ} {h' : E → E}

/-- The mirror-descent iterate sequence. -/
noncomputable def iterate (alg : MirrorDescent f f' h h') : ℕ → E
  | 0     => alg.x₀
  | k+1   => alg.prox alg.η (f' (iterate alg k)) (iterate alg k)

/-- One-step Bregman bound directly from the prox optimality.

Note: the classical "three-point lemma" of Bregman analysis includes an
additional `−D_h(y, x_{k+1})` term on the right.  That stronger form
requires the *first-order* optimality condition `h'(x_k) − h'(x_{k+1}) = η g`,
which does not follow from the variational-inequality form `prox_spec`
alone (one would need `D_h(y, x_{k+1}) ≤ 0`, contradicting non-negativity
of Bregman divergences).  We therefore state the directly-derivable
weaker bound; the stronger bound is recovered when `prox_spec` is
strengthened to a first-order condition (typically by assuming `h` is
differentiable on the unconstrained problem). -/
theorem one_step_prox_bound
    (alg : MirrorDescent f f' h h') (y : E) (k : ℕ) :
    alg.η * inner (𝕜 := ℝ) (f' (iterate alg k)) (iterate alg (k + 1) - y) ≤
      BregmanDivergence h h' y (iterate alg k)
      - BregmanDivergence h h' (iterate alg (k + 1)) (iterate alg k) := by
  have spec := alg.prox_spec alg.η (f' (iterate alg k)) (iterate alg k) y
  -- spec : η * ⟨g, x_{k+1}⟩ + D_h(x_{k+1}, x_k) ≤ η * ⟨g, y⟩ + D_h(y, x_k)
  -- Note: iterate alg (k+1) = alg.prox alg.η (f' (iterate alg k)) (iterate alg k)
  show alg.η * inner (𝕜 := ℝ) (f' (iterate alg k)) (iterate alg (k + 1) - y) ≤ _
  have h_iter : iterate alg (k + 1) =
      alg.prox alg.η (f' (iterate alg k)) (iterate alg k) := rfl
  rw [h_iter, inner_sub_right]
  linarith

/-- **Theorem (mirror descent on convex L-smooth, η = 1/L).**

For convex `f` that is `L`-smooth in the dual norm to `h`, mirror descent
with `η = 1/L` produces iterates whose averaged objective gap satisfies
`f(x̄_T) − f* ≤ L · D_h(x*, x₀) / T`, where `x̄_T = (1/T) ∑_{k<T} x_{k+1}`.

-- STUCK: standard analysis sums the three-point lemma over k = 0..T-1,
-- telescopes the `D_h(x*, x_k)` terms, applies convexity to lift `f(x_{k+1})` to
-- a gradient inner product, and uses the descent lemma on f to absorb the
-- `D_h(x_{k+1}, x_k)` term.  Direct port of Beck–Teboulle (2003).  Roughly 60 lines
-- of detailed Lean tactic code. -/
theorem mirror_descent_converge
    (alg : MirrorDescent f f' h h')
    (xstar : E) (hstar : ∀ y, f xstar ≤ f y)
    (L : ℝ) (hL : 0 < L) (hη : alg.η = 1 / L)
    (h_conv : ConvexOn ℝ Set.univ h)
    (h_diff : ∀ y, HasGradientAt h (h' y) y)
    (T : ℕ) (hT : 0 < T) :
    f ((T : ℝ)⁻¹ • ∑ k ∈ Finset.range T, iterate alg (k + 1)) - f xstar
      ≤ L * BregmanDivergence h h' xstar alg.x₀ / T := by
  sorry

end MirrorDescent

end OptExt
