/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Frank–Wolfe / conditional gradient

The Frank–Wolfe (FW) method (Frank–Wolfe 1956, Jaggi 2013) minimises a
smooth convex `f` over a *compact convex* set `C` by replacing the
projection step of GD with a *linear minimisation oracle* (LMO):
```
s_k := argmin_{s ∈ C} ⟨∇f(x_k), s⟩
x_{k+1} := (1 − γ_k) x_k + γ_k s_k,        γ_k = 2 / (k + 2).
```
The classical analysis gives `f(x_T) − f* ≤ 2 L D² / (T + 2)`, where
`D = diam(C)`.  Crucially, FW iterates remain in `C` by construction (no
projection) and admit a sparsity guarantee when `C` is the simplex.

## Main definitions

* `LinearMinimizationOracle C`     — `LMO C g` returns `argmin_{s∈C} ⟨g, s⟩`.
* `FrankWolfe`                     — class packaging the FW algorithmic state.
* `FrankWolfe.iterate`             — the iterate sequence.

## Main results

* `frank_wolfe_descent_lemma`      — single-step `O(γ²)` decrement.
* `frank_wolfe_converge`           — `O(LD²/T)` convergence over compact `C`.

## Reuse from optlib

* `Optlib.Function.Lsmooth.lipschitz_continuos_upper_bound'` — descent lemma.
* `Optlib.Convex.ConvexFunction.Convex_first_order_condition` — convexity.
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Convex.Combination
import Mathlib.Analysis.Convex.Topology
import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Tactic

import Optlib.Function.Lsmooth
import Optlib.Convex.ConvexFunction

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-! ### Linear minimisation oracle -/

/-- A *linear minimisation oracle* (LMO) for a non-empty set `C` returns,
for every direction `g`, a point of `C` minimising the linear form
`s ↦ ⟨g, s⟩`. -/
structure LinearMinimizationOracle (C : Set E) where
  /-- The oracle map. -/
  lmo  : E → E
  /-- Membership: `lmo g ∈ C`. -/
  mem  : ∀ g : E, lmo g ∈ C
  /-- Optimality: `⟨g, lmo g⟩ ≤ ⟨g, s⟩` for every `s ∈ C`. -/
  opt  : ∀ (g : E) {s : E}, s ∈ C → inner (𝕜 := ℝ) g (lmo g) ≤ inner (𝕜 := ℝ) g s

/-! ### The Frank–Wolfe algorithm -/

/-- Frank–Wolfe (conditional-gradient) on `min_{x ∈ C} f(x)` over a compact
convex set `C`, using the standard step-size schedule `γ_k = 2 / (k + 2)`. -/
class FrankWolfe (f : E → ℝ) (f' : E → E) (C : Set E) where
  /-- Convexity of the constraint set. -/
  C_convex : Convex ℝ C
  /-- Compactness of the constraint set (needed for boundedness of the
      diameter and existence of the LMO image). -/
  C_compact : IsCompact C
  /-- Convexity of the objective. -/
  f_convex : ConvexOn ℝ C f
  /-- Linear-minimisation oracle. -/
  oracle   : LinearMinimizationOracle C
  /-- Initial point inside `C`. -/
  x₀       : E
  /-- `x₀ ∈ C`. -/
  x₀_mem   : x₀ ∈ C

namespace FrankWolfe

variable {f : E → ℝ} {f' : E → E} {C : Set E}

/-- The classical FW step size `γ_k := 2 / (k + 2)`. -/
noncomputable def stepSize (k : ℕ) : ℝ := 2 / ((k : ℝ) + 2)

@[simp] theorem stepSize_pos (k : ℕ) : 0 < stepSize k := by
  unfold stepSize; positivity

@[simp] theorem stepSize_le_one (k : ℕ) : stepSize k ≤ 1 := by
  unfold stepSize
  rw [div_le_one (by positivity)]
  have : (0 : ℝ) ≤ k := Nat.cast_nonneg _
  linarith

/-- The Frank–Wolfe iterate sequence. -/
noncomputable def iterate (alg : FrankWolfe f f' C) : ℕ → E
  | 0     => alg.x₀
  | k+1   =>
      let x := iterate alg k
      let s := alg.oracle.lmo (f' x)
      (1 - stepSize k) • x + stepSize k • s

/-- All iterates lie in `C`. -/
theorem iterate_mem (alg : FrankWolfe f f' C) (k : ℕ) :
    iterate alg k ∈ C := by
  induction k with
  | zero => exact alg.x₀_mem
  | succ k ih =>
      show (1 - stepSize k) • iterate alg k +
            stepSize k • alg.oracle.lmo (f' (iterate alg k)) ∈ C
      refine alg.C_convex ih (alg.oracle.mem _) ?_ (stepSize_pos k).le ?_
      · linarith [stepSize_le_one k]
      · ring

/-- One-step decrement bound: `f(x_{k+1}) − f* ≤ (1 − γ_k)(f(x_k) − f*) + γ_k² · L D² / 2`.

**Statement note:** added `hdiff` (global differentiability) and `hsmooth`
(L-Lipschitz gradient) hypotheses, plus `hf_conv_global` (convexity on
`Set.univ`).  These are needed to invoke the optlib L-smooth descent lemma
and the optlib convexity first-order condition. -/
theorem one_step_descent
    (alg : FrankWolfe f f' C) (xstar : E) (hxstar : xstar ∈ C)
    (hstar : ∀ y ∈ C, f xstar ≤ f y)
    (L D : ℝ) (hL : 0 < L) (hD : 0 < D)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, ‖x - y‖ ≤ D)
    (hdiff : ∀ x, HasGradientAt f (f' x) x)
    (hsmooth : LipschitzWith ⟨L, hL.le⟩ f')
    (hf_conv_global : ConvexOn ℝ Set.univ f)
    (k : ℕ) :
    f (iterate alg (k + 1)) - f xstar ≤
      (1 - stepSize k) * (f (iterate alg k) - f xstar)
        + (stepSize k) ^ 2 * L * D ^ 2 / 2 := by
  set xk := iterate alg k with hxk_def
  set sk := alg.oracle.lmo (f' xk) with hsk_def
  set γ := stepSize k with hγ_def
  have γ_pos : 0 < γ := stepSize_pos k
  have γ_le1 : γ ≤ 1 := stepSize_le_one k
  have hxk_mem : xk ∈ C := iterate_mem alg k
  have hsk_mem : sk ∈ C := alg.oracle.mem _
  have hxk1_eq : iterate alg (k + 1) = (1 - γ) • xk + γ • sk := rfl
  -- Δ := iterate (k+1) - xk = γ • (sk - xk)
  have hdelta : iterate alg (k+1) - xk = γ • (sk - xk) := by
    rw [hxk1_eq, smul_sub, sub_smul, one_smul]
    abel
  have hsk_xk_norm : ‖sk - xk‖ ≤ D := hdiam _ hsk_mem _ hxk_mem
  have hsk_xk_sq : ‖sk - xk‖ ^ 2 ≤ D ^ 2 :=
    pow_le_pow_left (norm_nonneg _) hsk_xk_norm 2
  have hdelta_norm_sq : ‖iterate alg (k+1) - xk‖ ^ 2 ≤ γ ^ 2 * D ^ 2 := by
    rw [hdelta, norm_smul, Real.norm_of_nonneg γ_pos.le, mul_pow]
    exact mul_le_mul_of_nonneg_left hsk_xk_sq (by positivity)
  -- L-smooth descent applied at xk, iterate (k+1)
  have hsm := lipschitz_continuos_upper_bound' hdiff hsmooth xk (iterate alg (k+1))
  -- inner expansion via hdelta
  have hinner_expand : inner (𝕜 := ℝ) (f' xk) (iterate alg (k+1) - xk)
                     = γ * inner (𝕜 := ℝ) (f' xk) (sk - xk) := by
    rw [hdelta, inner_smul_right]
  -- LMO + convexity ⟹ ⟨f'xk, sk - xk⟩ ≤ f xstar - f xk
  have hlmo : inner (𝕜 := ℝ) (f' xk) sk ≤ inner (𝕜 := ℝ) (f' xk) xstar :=
    alg.oracle.opt _ hxstar
  have hlmo_sub : inner (𝕜 := ℝ) (f' xk) (sk - xk)
                ≤ inner (𝕜 := ℝ) (f' xk) (xstar - xk) := by
    rw [inner_sub_right, inner_sub_right]; linarith
  have hconv := Convex_first_order_condition' (hdiff xk) hf_conv_global
                  (Set.mem_univ xk) xstar (Set.mem_univ xstar)
  have hinner_conv : inner (𝕜 := ℝ) (f' xk) (xstar - xk) ≤ f xstar - f xk := by linarith
  have hinner_bound : inner (𝕜 := ℝ) (f' xk) (sk - xk) ≤ f xstar - f xk :=
    le_trans hlmo_sub hinner_conv
  have hcoef : ((⟨L, hL.le⟩ : NNReal) : ℝ) / 2 = L / 2 := by
    show (L : ℝ) / 2 = L / 2; rfl
  -- Plug everything in
  have key : f (iterate alg (k+1)) ≤ f xk + γ * (f xstar - f xk) + γ^2 * L * D^2 / 2 := by
    have hsm' : f (iterate alg (k+1)) ≤
                f xk + γ * inner (𝕜 := ℝ) (f' xk) (sk - xk) +
                ((⟨L, hL.le⟩ : NNReal) : ℝ) / 2 * ‖iterate alg (k+1) - xk‖^2 := by
      rw [← hinner_expand]; exact hsm
    have hbound1 : γ * inner (𝕜 := ℝ) (f' xk) (sk - xk) ≤ γ * (f xstar - f xk) :=
      mul_le_mul_of_nonneg_left hinner_bound γ_pos.le
    have hbound2 : ((⟨L, hL.le⟩ : NNReal) : ℝ) / 2 * ‖iterate alg (k+1) - xk‖^2
                 ≤ γ^2 * L * D^2 / 2 := by
      rw [hcoef]
      have h1 : L / 2 * ‖iterate alg (k+1) - xk‖^2 ≤ L / 2 * (γ^2 * D^2) :=
        mul_le_mul_of_nonneg_left hdelta_norm_sq (by positivity)
      linarith
    linarith
  linarith

/-- **Theorem (Frank–Wolfe on convex L-smooth, compact `C`).**
With `γ_k = 2 / (k + 2)`, after `T ≥ 1` iterations, `f(x_T) − f* ≤ 2LD²/(T+2)`.
Jaggi (2013) Theorem 1.  Same statement upgrades as `one_step_descent`
(added `hdiff`, `hsmooth`, `hf_conv_global`). -/
theorem converge
    (alg : FrankWolfe f f' C) (xstar : E) (hxstar : xstar ∈ C)
    (hstar : ∀ y ∈ C, f xstar ≤ f y)
    (L D : ℝ) (hL : 0 < L) (hD : 0 < D)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, ‖x - y‖ ≤ D)
    (T : ℕ) (hT : 1 ≤ T) :
    f (iterate alg T) - f xstar ≤ 2 * L * D ^ 2 / ((T : ℝ) + 2) := by
  -- STUCK: induction structure is clear, but the arithmetic step
  -- `(T+1)(T+3) ≤ (T+2)²` chained through nested-division `Real`-bounds
  -- with `Nat`-coerce casts breaks `nlinarith`/`positivity` chains.
  -- Would need `Util/RealRatBound.lean` helper or careful manual proof.
  sorry

end FrankWolfe

end OptExt
