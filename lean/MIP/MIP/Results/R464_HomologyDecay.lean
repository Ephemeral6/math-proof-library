/-
Result R.464 — homology decay ODE
`d(dim H_n)/dt ~ −α_n · dim H_n · |log κ_{n+1}|`.

Reference: `workspace/k_a_simplicial_homology.md` §2.3 (R.464)
(A 条件性 / conditional-A: needs the higher-`κ_r` Gompertz law and R.463
δ-closure).

**Statement.** The source derives, in the R.98 regime, that the `n`-dimensional
homology dimension extinguishes at a rate proportional to itself:
```
    d(dim H_n)/dt  ~  −α_n · dim H_n · |log κ_{n+1}| .
```
When the effective hole-filling factor `rate := α_n · |log κ_{n+1}|` is treated
as a constant (late-training regime, where `κ_{n+1} ≈ 1` and the source replaces
the bracket by an effective constant), this is a **linear decay ODE**
`H' = −rate · H` whose solution is the exponential
```
    dim H_n(t)  =  H₀ · exp(−rate · t) .
```

We reduce the heavy persistent-homology content to the **defensible ODE
kernel** (the R.98 `HasDerivAt` pattern): we prove the exponential closed form
*exactly* solves the decay equation, that it decays to `0`, that it is
nonincreasing for nonnegative rate, and that with `rate = α_n · |log κ_{n+1}|`
the right-hand side has exactly the source's product shape.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace HomologyDecay

open Real Filter Topology

/-- The closed-form homology-dimension trajectory
`dimH n t = H₀ · exp(−rate · t)`. Here `H₀ = dim H_n(0)` is the initial number
of `n`-holes and `rate = α_n · |log κ_{n+1}|` is the effective extinction rate
(treated as a constant in the late-training regime). -/
noncomputable def dimH (H₀ rate : ℝ) (t : ℝ) : ℝ :=
  H₀ * Real.exp (-rate * t)

/-- **R.464 — the exponential closed form solves the decay ODE.**

For every `t`,
```
    d/dt (dimH H₀ rate t)  =  −rate · dimH H₀ rate t ,
```
i.e. `dim H_n` obeys `H' = −rate · H`, the linear-decay reading of the R.464
extinction law. (Same `HasDerivAt` chain-rule pattern as R.98.) -/
theorem R_464_decay_ode (H₀ rate : ℝ) (t : ℝ) :
    HasDerivAt (dimH H₀ rate) (-rate * dimH H₀ rate t) t := by
  -- inner affine map  s ↦ -rate * s  has derivative  -rate.
  have h_aff : HasDerivAt (fun s : ℝ => -rate * s) (-rate) t := by
    simpa using (hasDerivAt_id t).const_mul (-rate)
  -- exp of it: s ↦ exp(-rate*s)  has derivative  exp(-rate*t) * (-rate).
  have h_exp : HasDerivAt (fun s => Real.exp (-rate * s))
      (Real.exp (-rate * t) * (-rate)) t := h_aff.exp
  -- multiply by the constant H₀.
  have h := h_exp.const_mul H₀
  -- reshape the derivative value into  -rate * dimH H₀ rate t.
  unfold dimH
  convert h using 1
  ring

/-- **R.464 — the right-hand side has the source's product shape.**

With `rate = α_n · |log κ_{n+1}|`, the decay rate factorises as
`−α_n · |log κ_{n+1}| · dim H_n`, matching
`d(dim H_n)/dt ~ −α_n · dim H_n · |log κ_{n+1}|` verbatim. -/
theorem R_464_rate_shape (H₀ α_n κ : ℝ) (t : ℝ) :
    HasDerivAt (dimH H₀ (α_n * |Real.log κ|))
      (-(α_n) * dimH H₀ (α_n * |Real.log κ|) t * |Real.log κ|) t := by
  have h := R_464_decay_ode H₀ (α_n * |Real.log κ|) t
  -- the derivative value -(α_n*|log κ|)*H equals -(α_n)*H*|log κ|
  convert h using 1
  ring

/-- **R.464 — extinction: `dim H_n(t) → 0` as `t → ∞` for positive rate.**

For `0 < rate`, the holes are filled in the limit: `dim H_n(t) → 0`. This is
the homological reading of training "filling all holes". -/
theorem R_464_extinction (H₀ rate : ℝ) (hrate : 0 < rate) :
    Filter.Tendsto (dimH H₀ rate) Filter.atTop (nhds 0) := by
  -- -rate * t → -∞
  have h_arg : Filter.Tendsto (fun t : ℝ => -rate * t) atTop atBot := by
    have := (tendsto_const_mul_atBot_of_neg (r := -rate) (f := fun t : ℝ => t)
      (by linarith)).mpr tendsto_id
    simpa using this
  -- exp(-rate*t) → 0
  have h_exp0 : Filter.Tendsto (fun t : ℝ => Real.exp (-rate * t)) atTop (nhds 0) :=
    Real.tendsto_exp_atBot.comp h_arg
  -- H₀ * exp(...) → H₀ * 0 = 0
  have h := h_exp0.const_mul H₀
  simp only [mul_zero] at h
  exact h

/-- **R.464 — the trajectory is nonincreasing for nonneg initial value and
rate.**

For `0 ≤ H₀`, `0 ≤ rate`, and `t₁ ≤ t₂`, we have
`dimH H₀ rate t₂ ≤ dimH H₀ rate t₁`: homology can only shrink under training.
-/
theorem R_464_nonincreasing (H₀ rate : ℝ) (hH : 0 ≤ H₀) (hrate : 0 ≤ rate)
    {t₁ t₂ : ℝ} (h : t₁ ≤ t₂) :
    dimH H₀ rate t₂ ≤ dimH H₀ rate t₁ := by
  unfold dimH
  apply mul_le_mul_of_nonneg_left _ hH
  apply Real.exp_le_exp.mpr
  -- -rate * t₂ ≤ -rate * t₁  ⟺  rate * t₁ ≤ rate * t₂
  nlinarith [mul_le_mul_of_nonneg_left h hrate]

/-- **R.464 — initial condition.** `dimH H₀ rate 0 = H₀` (the trajectory starts
at the initial hole count). -/
theorem R_464_initial (H₀ rate : ℝ) : dimH H₀ rate 0 = H₀ := by
  unfold dimH; simp

end HomologyDecay

end MIP
