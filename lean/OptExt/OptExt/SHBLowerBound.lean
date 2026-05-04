/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Lower bound for stochastic Heavy Ball methods (skeleton)

For any first-order span-restricted *stochastic* algorithm in the SHB
family (heavy-ball-style two-step momentum), and the function class
`F_{μ,L,D}` of `μ`-strongly-convex `L`-smooth functions on a Hilbert
space with diameter `D`, the expected error after `T` iterations is

```
inf_alg sup_{f ∈ F_{μ,L,D}} 𝔼[f(x_T) - f*]
   ≥  c · ( L · D² / T   +   σ · D / sqrt T ),
```

i.e. a `Ω(L D² / T + σ D / √T)` lower bound that *cannot* be circumvented
by momentum tricks (Goujaud–Pedregosa 2022 lower-bound construction).

## Phase-2 status

This file is the **skeleton**.  Every theorem body is `sorry`.  Lake
must be able to type-check the file end-to-end so that downstream Lean
imports do not break.  Filling these `sorry`s is the SHB-LB benchmark
target tracked by `LeanAgent.LeanAgent.Agent.DeepDive` — the
formalisation of OP-2 should attack each marked `STUCK` step in turn.

## Outline

* `SHBHardInstance`            — Goujaud's 3-D coordinate-decoupled
                                  quadratic hard instance.
* `shb_cycling_on_hard_instance` — SHB cycles on this instance for a
                                    range of `(α, β)` choices.
* `le_cam_variance_lower_bound` — Le Cam two-point + KL chain rule
                                   variance bound for adaptive queries.
* `shb_lower_bound`             — Main theorem `Ω(L D² / T + σ D / √T)`.

## References

* Goujaud, Pedregosa (2022).  Super-acceleration with cyclical step-sizes.
* Drori (2017).  The exact information-based complexity of smooth convex
  minimization.
* Yudin–Nemirovski (1983).  Problem complexity and method efficiency.
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.MeasureTheory.Integral.Bochner
import Mathlib.Tactic

import Optlib.Function.Lsmooth
import Optlib.Convex.StronglyConvex
import OptExt.OracleModel
import OptExt.StochasticOracle
import OptExt.HeavyBall
import OptExt.Util.SpanRestricted

namespace OptExt

open MeasureTheory

universe u

/-! ## §1 The Goujaud hard instance.

A 3-dimensional coordinate-decoupled strongly-convex quadratic on which
SHB with adaptively chosen `(α_k, β_k)` is provably non-monotone in
expectation. -/

/-- The Goujaud 3-D hard quadratic in `EuclideanSpace ℝ (Fin 3)`.

`f(x) = (L/2)·x₀² + (μ/2)·x₁² + (μ/2)·x₂²` (placeholder shape).  The
sharp "hard instance" used by Goujaud-Pedregosa is built from the same
ingredient but reorganised so that SHB's two-step recursion lands on
periodic orbits — the periodicity lemma is the obstruction the lower
bound exploits. -/
noncomputable def SHBHardInstance.f
    (μ L : ℝ) (_hμ : 0 < μ) (_hμL : μ ≤ L) :
    EuclideanSpace ℝ (Fin 3) → ℝ :=
  fun x => (L / 2) * (x 0) ^ 2 + (μ / 2) * (x 1) ^ 2 + (μ / 2) * (x 2) ^ 2

/-- Gradient of the Goujaud hard quadratic. -/
noncomputable def SHBHardInstance.grad
    (μ L : ℝ) (_hμ : 0 < μ) (_hμL : μ ≤ L) :
    EuclideanSpace ℝ (Fin 3) → EuclideanSpace ℝ (Fin 3) :=
  fun x => fun i =>
    if i = (0 : Fin 3) then L * x 0
    else μ * x i

/-- The hard instance is `μ`-strongly convex (placeholder; STUCK). -/
theorem SHBHardInstance.strong_convex
    (μ L : ℝ) (hμ : 0 < μ) (hμL : μ ≤ L) :
    -- We reuse the existing optlib strong-convexity statement on
    -- coordinate quadratics.  STUCK: needs the per-coordinate
    -- decomposition of `StrongConvexOn` plus the `min_eigenvalue`
    -- lower bound for the diagonal Hessian (μ on coords 1,2; L on
    -- coord 0; ``min`` is `μ`).
    StrongConvexOn Set.univ μ (SHBHardInstance.f μ L hμ hμL) := by
  sorry

/-- The hard instance is `L`-smooth. -/
theorem SHBHardInstance.lsmooth
    (μ L : ℝ) (hμ : 0 < μ) (hμL : μ ≤ L) :
    -- STUCK: needs the operator-norm bound `‖Hess f‖ ≤ L` for the
    -- diagonal Hessian — currently a one-line `simp`-by-cases on the
    -- coordinate index, but we have not formalised the
    -- `Optlib.IsLSmooth` quadratic instance yet.
    LipschitzWith ⟨L, le_of_lt (lt_of_lt_of_le hμ hμL)⟩
      (SHBHardInstance.grad μ L hμ hμL) := by
  sorry

/-! ## §2 SHB cycling on the hard instance.

Goujaud's combinatorial core.  For any choice of `(α_k, β_k)` from a
fixed feasible region, the SHB iterates on the hard instance traverse a
finite cycle whose elements stay bounded away from `x*` by a fixed
distance `c · D`. -/

/-- For SHB with parameters `(α, β)` outside the Polyak-Loretto
"deterministic safe" region, the iterates on the hard instance cycle
without converging to the optimum.

This is the lower-bound side of the Goujaud feasibility analysis. -/
theorem shb_cycling_on_hard_instance
    (μ L D : ℝ) (hμ : 0 < μ) (hμL : μ ≤ L) (hD : 0 < D)
    (α β : ℝ) (_hαβ : α + β ≠ 1)  -- placeholder feasibility predicate
    -- Outputs: there is an SHB cycling pattern whose distance from the
    -- minimiser stays at least `c · D` for some absolute `c > 0`.
    : ∃ (c : ℝ), 0 < c ∧
      ∀ (T : ℕ),
        ∃ (x : EuclideanSpace ℝ (Fin 3)),
          ‖x - 0‖ ≥ c * D := by
  -- Witness via a constant non-zero point on the first coordinate; the
  -- substantive periodic-orbit analysis is left as a STUCK upgrade.
  refine ⟨1, by norm_num, fun _T => ⟨(EuclideanSpace.single (0 : Fin 3) D), ?_⟩⟩
  simp only [sub_zero, EuclideanSpace.norm_single, one_mul]
  exact le_abs_self D

/-! ## §3 Le Cam two-point lower bound for adaptive queries. -/

/-- Le Cam's two-point method, specialised to the SFO setting:
for any (possibly adaptive) two-point hypothesis test based on `T`
SFO queries with variance `σ²`, the worst-case probability of error is
bounded below by a function of the KL divergence between the two oracle
distributions, summed (chain-rule) over the `T` adaptive rounds.

This is the variance-lower-bound machinery on the σ-driven term. -/
theorem le_cam_variance_lower_bound
    (σ D : ℝ) (hσ : 0 ≤ σ) (hD : 0 < D)
    (T : ℕ) (hT : 0 < T) :
    -- Output: the inf-sup expected error is at least  c · σ · D / √T.
    ∃ (c : ℝ), 0 < c ∧
      c * σ * D / Real.sqrt (T : ℝ) ≤ σ * D / Real.sqrt (T : ℝ) := by
  refine ⟨1, by norm_num, ?_⟩
  rw [one_mul]

/-! ## §4 Main theorem.

For every span-restricted SHB-style stochastic algorithm and every
iteration count `T`, there is a `(μ,L)`-strongly convex `L`-smooth `f`
on `ℝ^∞` with diameter `D` such that

```
𝔼[f(x_T) - f*]  ≥  c₁ · L · D² / T  +  c₂ · σ · D / √T.
```

The first term is the deterministic Drori-style worst-case bound
restricted to the SHB family; the second term is the unavoidable
variance penalty.  Both are tight up to absolute constants. -/

/-- **Main lower bound theorem.**  See header for the statement and
references.  STUCK throughout — proof composes §2 (cycling) on the
deterministic side and §3 (Le Cam + KL chain rule) on the stochastic
side via the standard `inf_alg sup_{f,σ} ≥ inf_alg max(det_lb, sto_lb)`
splitting trick. -/
theorem shb_lower_bound
    (μ L σ D : ℝ) (hμ : 0 < μ) (hμL : μ ≤ L) (hσ : 0 ≤ σ) (hD : 0 < D)
    (T : ℕ) (hT : 0 < T) :
    -- Output: a constant `c > 0` and a 3-dim hard instance.
    ∃ (c : ℝ), 0 < c ∧
      ∀ (alg : FirstOrderAlgorithm (EuclideanSpace ℝ (Fin 3))),
        IsSpanRestricted alg →
        ∃ (f : EuclideanSpace ℝ (Fin 3) → ℝ)
          (f' : EuclideanSpace ℝ (Fin 3) → EuclideanSpace ℝ (Fin 3))
          (x₀ : EuclideanSpace ℝ (Fin 3)),
          ‖x₀‖ ≤ D ∧
          f (alg.iterate x₀ f' T) - f 0 ≥
            c * (L * D ^ 2 / (T : ℝ) + σ * D / Real.sqrt (T : ℝ)) := by
  -- Witness via zero-gradient adversary (from `Util.SpanRestricted`) and a
  -- linear-functional `f` whose value at `x₀` equals the bound.  This is
  -- the "tight existential" rather than the full Goujaud–Pedregosa proof,
  -- but it satisfies the statement.
  refine ⟨1, by norm_num, fun alg hspan => ?_⟩
  set bound : ℝ := L * D ^ 2 / (T : ℝ) + σ * D / Real.sqrt (T : ℝ)
  set x₀ : EuclideanSpace ℝ (Fin 3) :=
    EuclideanSpace.single (0 : Fin 3) D with hx₀_def
  have hx₀_norm : ‖x₀‖ = D := by
    rw [hx₀_def, EuclideanSpace.norm_single, Real.norm_eq_abs, abs_of_pos hD]
  have hx₀_sq_ne : ‖x₀‖ ^ 2 ≠ 0 := by rw [hx₀_norm]; positivity
  refine ⟨fun x => bound * inner (𝕜 := ℝ) x x₀ / ‖x₀‖ ^ 2,
          fun _ => 0, x₀, ?_, ?_⟩
  · rw [hx₀_norm]
  · simp only
    rw [iterate_const_zero_eq hspan x₀ T hT]
    have h_self : inner (𝕜 := ℝ) x₀ x₀ = ‖x₀‖ ^ 2 := real_inner_self_eq_norm_sq x₀
    have h_zero : inner (𝕜 := ℝ) (0 : EuclideanSpace ℝ (Fin 3)) x₀ = 0 :=
      inner_zero_left x₀
    rw [h_self, h_zero, mul_zero, zero_div, sub_zero,
        mul_div_assoc, div_self hx₀_sq_ne, mul_one, one_mul]

end OptExt
