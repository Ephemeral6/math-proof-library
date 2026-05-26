/-
Result R.98 (T.23) — Combinatorial closure κ obeys the Gompertz dynamics.

Reference: `proofs/derived/learning_mechanics.md` R.98 (T.23)
(A 条件性 under R.61s compact form + Z slow-varying + coverage complete).

**Statement.** Under (a) T.5 flywheel decay `N(t) = N₀·exp(-α·t)`,
(b) `Z` slow-varying `Z(t) ≈ Z_∞`, and the R.61s compact relation
`N(t) ≈ c·r·|log κ(t)|·Z(t)`, the combinatorial closure `κ` satisfies the
Gompertz ODE

    dκ/dt  =  α · κ · |log κ|  =  -α · κ · log κ     (on κ ∈ (0,1)),

with closed-form solution

    κ(t)  =  κ₀ ^ exp(-α·(t - t_c))
          =  exp( log κ₀ · exp(-α·(t - t_c)) ) .

For `κ ∈ (0,1)` we have `log κ < 0`, so `|log κ| = -log κ` and the ODE
reads `dκ/dt = -α·κ·log κ`.

**This file proves the closed form solves the ODE.** With
`κ₀ ∈ (0,1)` (so `log κ₀ < 0`) and
`κ t := exp( log κ₀ · exp(-α·(t - t_c)) )`, we prove

    HasDerivAt κ (-α · (κ t) · log (κ t)) t      for all `t`,

i.e. the function satisfies `dκ/dt = -α·κ·log κ` exactly.  We also prove
the saturation limit `κ t → 1` as `t → ∞` (for `0 < α`).

**This file is `axiom`-free.**  It states R.98 as a self-contained
analysis theorem; the MIP-side premises (T.5, R.61s, Z slow-varying)
enter only through the explicit form of `κ`.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace GompertzKappa

open Real Filter Topology

/-- The closed-form Gompertz solution
`κ t = exp( log κ₀ · exp(-α·(t - t_c)) )`. -/
noncomputable def kappa (κ₀ α t_c : ℝ) (t : ℝ) : ℝ :=
  Real.exp (Real.log κ₀ * Real.exp (-α * (t - t_c)))

/-- The inner exponent `g t = log κ₀ · exp(-α·(t - t_c))`. -/
noncomputable def g (κ₀ α t_c : ℝ) (t : ℝ) : ℝ :=
  Real.log κ₀ * Real.exp (-α * (t - t_c))

/-- **Auxiliary: the inner exponent `g` cancels under `log ∘ κ`.**

Since `κ t = exp (g t)`, we have `log (κ t) = g t`. -/
theorem log_kappa_eq_g (κ₀ α t_c t : ℝ) :
    Real.log (kappa κ₀ α t_c t) = g κ₀ α t_c t := by
  unfold kappa g
  rw [Real.log_exp]

/-- **Auxiliary: derivative of the inner exponent.**

`g t = log κ₀ · exp(-α·(t - t_c))`, so
`g' t = log κ₀ · (-α) · exp(-α·(t - t_c)) = -α · g t`. -/
theorem hasDerivAt_g (κ₀ α t_c t : ℝ) :
    HasDerivAt (g κ₀ α t_c) (-α * g κ₀ α t_c t) t := by
  -- inner affine map  s ↦ -α * (s - t_c)  has derivative  -α.
  have h_aff : HasDerivAt (fun s => -α * (s - t_c)) (-α) t := by
    have h1 : HasDerivAt (fun s : ℝ => s - t_c) (1 : ℝ) t :=
      (hasDerivAt_id t).sub_const t_c
    have h2 := h1.const_mul (-α)
    simpa using h2
  -- exp of it:  s ↦ exp(-α*(s - t_c))  has derivative  (-α)·exp(-α*(t - t_c)).
  have h_exp : HasDerivAt (fun s => Real.exp (-α * (s - t_c)))
      (Real.exp (-α * (t - t_c)) * (-α)) t := h_aff.exp
  -- multiply by the constant  log κ₀.
  have h_g := h_exp.const_mul (Real.log κ₀)
  -- reshape the derivative value into  -α * g t.
  unfold g
  convert h_g using 1
  ring

/-- **R.98 — the Gompertz closed form solves the ODE.**

For `κ₀ ∈ (0,1)` (so `log κ₀ < 0`), the function
`κ t = exp( log κ₀ · exp(-α·(t - t_c)) )` satisfies at every `t`

    dκ/dt  =  -α · κ(t) · log (κ(t)) ,

which is the Gompertz equation `dκ/dt = α·κ·|log κ|` on `κ ∈ (0,1)`. -/
theorem R_98_gompertz_ode
    (κ₀ α t_c : ℝ) (t : ℝ) :
    HasDerivAt (kappa κ₀ α t_c)
      (-α * kappa κ₀ α t_c t * Real.log (kappa κ₀ α t_c t)) t := by
  -- κ = exp ∘ g, so  κ' t = exp(g t) · g'(t) = κ t · (-α · g t).
  have hg : HasDerivAt (g κ₀ α t_c) (-α * g κ₀ α t_c t) t :=
    hasDerivAt_g κ₀ α t_c t
  have hκ : HasDerivAt (fun s => Real.exp (g κ₀ α t_c s))
      (Real.exp (g κ₀ α t_c t) * (-α * g κ₀ α t_c t)) t := hg.exp
  -- `(fun s => exp (g s))` is definitionally `kappa`.
  have h_fun : (fun s => Real.exp (g κ₀ α t_c s)) = kappa κ₀ α t_c := by
    funext s; rfl
  rw [h_fun] at hκ
  -- Rewrite the derivative value:  exp(g t)·(-α·g t) = -α·(κ t)·(log (κ t)).
  have h_log : Real.log (kappa κ₀ α t_c t) = g κ₀ α t_c t :=
    log_kappa_eq_g κ₀ α t_c t
  have h_kappa : Real.exp (g κ₀ α t_c t) = kappa κ₀ α t_c t := rfl
  convert hκ using 1
  rw [h_log, h_kappa]
  ring

/-- **R.98 — monotone saturation `κ t → 1` as `t → ∞`.**

For `0 < α`, the exponent `exp(-α·(t - t_c)) → 0` as `t → ∞`, so
`g t → 0` and `κ t = exp (g t) → exp 0 = 1`.  This is the doubly
exponential approach to the closure ceiling. -/
theorem R_98_saturation
    (κ₀ α t_c : ℝ) (h_α_pos : 0 < α) :
    Filter.Tendsto (kappa κ₀ α t_c) Filter.atTop (nhds 1) := by
  -- The affine argument  -α*(t - t_c) → -∞.
  have h_arg : Filter.Tendsto (fun t : ℝ => -α * (t - t_c)) atTop atBot := by
    have h_lin : Filter.Tendsto (fun t : ℝ => t - t_c) atTop atTop :=
      tendsto_atTop_add_const_right atTop (-t_c) tendsto_id
    -- multiply by negative constant  -α  flips to  atBot.
    have h_neg : (-α) < 0 := by linarith
    have := (tendsto_const_mul_atBot_of_neg (r := -α) (f := fun t : ℝ => t - t_c)
      h_neg).mpr h_lin
    simpa using this
  -- exp(-α*(t - t_c)) → 0.
  have h_exp0 : Filter.Tendsto (fun t : ℝ => Real.exp (-α * (t - t_c)))
      atTop (nhds 0) :=
    Real.tendsto_exp_atBot.comp h_arg
  -- g t = log κ₀ · exp(...) → log κ₀ · 0 = 0.
  have h_g0 : Filter.Tendsto (g κ₀ α t_c) atTop (nhds 0) := by
    unfold g
    have := h_exp0.const_mul (Real.log κ₀)
    simpa using this
  -- κ t = exp (g t) → exp 0 = 1.
  have h_kappa : Filter.Tendsto (kappa κ₀ α t_c) atTop (nhds (Real.exp 0)) := by
    unfold kappa
    exact (Real.continuous_exp.tendsto 0).comp h_g0
  simpa using h_kappa

end GompertzKappa

end MIP
