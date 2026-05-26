/-
Result R.136 — Explicit dynamics of the cognitive asymmetry `dAsym/dt`.

Reference: `branches/duality/workspace/new_results.md` R.136
(局部编号 R.063, A 条件, duality branch).

**Statement.** With `Asym(t) = Σ_{b ∈ B(p)} Φ(b)·|Z_A(b,t) − Z_H(b,t)|`
(D.4.15), and the human side static (`dZ_H/dt = 0` in the original ITA
setting, here kept general by allowing a derivative), differentiating
barrier-by-barrier on the sign-definite branch `Z_A − Z_H > 0` — where
`|Z_A − Z_H| = Z_A − Z_H` — gives, by the chain rule,

    d/dt [ Φ · (Z_A − Z_H) ] = Φ · (Z_A' − Z_H') ,

and summing over barriers,

    dAsym/dt = Σ_b Φ(b) · (Z_A'(b) − Z_H'(b)) .

The absolute value in `Asym` is differentiable exactly on the
sign-definite branch (away from the measure-zero crossing set), which is
how the NL proof (步骤 1) handles it; on that branch the formula above is
the crisp chain-rule content of R.136.

This file formalises:

* `R_136_single_barrier`: for one barrier on the branch where
  `Z_A − Z_H > 0`, with `Φ` constant and `Z_A, Z_H` differentiable,
  `HasDerivAt (fun t => Φ * (Z_A t - Z_H t)) (Φ * (Z_A' - Z_H')) t`.
* `R_136_abs_branch`: on the positive branch `|Z_A − Z_H| = Z_A − Z_H`,
  so the same derivative governs `Φ * |Z_A t - Z_H t|` at points where
  the branch is sign-definite.
* `R_136_finite_sum`: the finite-sum version
  `HasDerivAt (fun t => ∑ b ∈ B, Φ b * (Z_A b t - Z_H b t))
              (∑ b ∈ B, Φ b * (ZA' b - ZH' b)) t`
  via `HasDerivAt.sum`.

`Φ b` (and the constant `Φ`) enter as fixed reals (independent of `t`,
matching "Φ 仅依赖问题 p，与 t 无关"); the per-barrier derivatives
`HasDerivAt (Z_A b) (ZA' b) t` and `HasDerivAt (Z_H b) (ZH' b) t` are the
explicit hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Data.Real.Basic

namespace MIP

namespace AsymDynamics

open scoped BigOperators

/-- **R.136 — single-barrier chain rule (sign-definite branch).**

For one barrier, on the branch where `Z_A − Z_H > 0` so that
`|Z_A − Z_H| = Z_A − Z_H`, with `Φ` a constant `Φ-weight` and
`Z_A, Z_H : ℝ → ℝ` differentiable at `t`, the contribution
`Φ * (Z_A t - Z_H t)` to `Asym` has derivative `Φ * (Z_A' - Z_H')`. -/
theorem R_136_single_barrier
    (Φ : ℝ) (Z_A Z_H : ℝ → ℝ) (Z_A' Z_H' : ℝ) (t : ℝ)
    (hA : HasDerivAt Z_A Z_A' t) (hH : HasDerivAt Z_H Z_H' t) :
    HasDerivAt (fun s => Φ * (Z_A s - Z_H s)) (Φ * (Z_A' - Z_H')) t := by
  -- d/dt (Z_A - Z_H) = Z_A' - Z_H', then multiply by the constant Φ.
  exact (hA.sub hH).const_mul Φ

/-- **R.136 — the absolute value collapses on the positive branch.**

On the sign-definite branch `Z_A t - Z_H t > 0`, the local form of the
`Asym` summand `Φ * |Z_A t - Z_H t|` agrees with `Φ * (Z_A t - Z_H t)`.
This is the pointwise reduction the NL proof uses (步骤 1) to drop the
absolute value before differentiating. -/
theorem R_136_abs_branch
    (Φ : ℝ) (Z_A Z_H : ℝ → ℝ) (t : ℝ)
    (h_pos : Z_A t - Z_H t > 0) :
    Φ * |Z_A t - Z_H t| = Φ * (Z_A t - Z_H t) := by
  rw [abs_of_pos h_pos]

/-- **R.136 — finite-sum (`dAsym/dt`).**

Summing the single-barrier chain rule over the finite barrier set `B`,
on the all-positive branch the smooth-branch `Asym`
`Σ_{b ∈ B} Φ(b)·(Z_A(b,·) − Z_H(b,·))` has derivative
`Σ_{b ∈ B} Φ(b)·(Z_A'(b) − Z_H'(b))`, the explicit `dAsym/dt` of R.136
(with `sign(Z_A − Z_H) = +1` on this branch). -/
theorem R_136_finite_sum
    {ι : Type*} (B : Finset ι)
    (Φ : ι → ℝ) (Z_A Z_H : ι → ℝ → ℝ) (ZA' ZH' : ι → ℝ) (t : ℝ)
    (hA : ∀ b ∈ B, HasDerivAt (Z_A b) (ZA' b) t)
    (hH : ∀ b ∈ B, HasDerivAt (Z_H b) (ZH' b) t) :
    HasDerivAt (fun s => ∑ b ∈ B, Φ b * (Z_A b s - Z_H b s))
      (∑ b ∈ B, Φ b * (ZA' b - ZH' b)) t := by
  -- Rewrite the pointwise sum `fun s => ∑ b, ...` as the sum of functions
  -- `∑ b, (fun s => ...)`, the shape `HasDerivAt.sum` expects.
  have h_swap : (fun s => ∑ b ∈ B, Φ b * (Z_A b s - Z_H b s))
      = ∑ b ∈ B, (fun s => Φ b * (Z_A b s - Z_H b s)) := by
    funext s
    rw [Finset.sum_apply]
  rw [h_swap]
  apply HasDerivAt.sum
  intro b hb
  exact R_136_single_barrier (Φ b) (Z_A b) (Z_H b) (ZA' b) (ZH' b) t
    (hA b hb) (hH b hb)

end AsymDynamics

end MIP
