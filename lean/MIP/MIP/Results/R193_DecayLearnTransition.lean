/-
Result R.193 — Decay–learning phase transition.
Reference: `branches/decay/workspace/new_results.md` (old decay R.154).

**Statement.** An agent learning new elements at constant rate `ν_K`, each
decaying with rate `1/τ̄`, has effective-knowledge size obeying

    d|K_eff|/dt = ν_K − |K_eff|/τ̄ ,   |K_eff|(0) = 0,

with closed form `n(t) = ν_K·τ̄·(1 − e^{−t/τ̄})` and asymptote
`n(∞) = ν_K·τ̄`.  The coverage condition `|K_eff^∞| ≥ |R(p)|` flips sign
at the **critical rate**

    ν_K^c := |R(p)| / τ̄ :

  • `ν_K > ν_K^c`  ⇒  `n(∞) > |R(p)|`  (coverage sustainable),
  • `ν_K < ν_K^c`  ⇒  `n(∞) < |R(p)|`  (coverage never reached).

**Kernel formalized here.**
  (1) the closed form solves the linear ODE (`HasDerivAt`), R.98-style;
  (2) the asymptote `n(t) → ν_K·τ̄` as `t → ∞`;
  (3) the threshold sign-flip: `ν_K·τ̄ > |R(p)| ⟺ ν_K > |R(p)|/τ̄`, the
      first-order transition in coverage at `ν_K^c`.

**Bridge.** `n = |K_eff|`, `ν_K` learning rate, `τ̄` mean half-life, `Rsize
= |R(p)|`.  The ODE model is the hypothesis; the analysis is discharged.
Axiom-free.
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace DecayLearnTransition

open Real Filter Topology

/-- The closed-form solution `n(t) = ν_K·τ̄·(1 − exp(−t/τ̄))`. -/
noncomputable def nEff (nuK tau : ℝ) (t : ℝ) : ℝ :=
  nuK * tau * (1 - Real.exp (-(t / tau)))

/-- **R.193 — the closed form solves the linear ODE.**

For `τ̄ > 0`, `n(t) = ν_K·τ̄·(1 − e^{−t/τ̄})` satisfies at every `t`

    dn/dt  =  ν_K − n(t)/τ̄ . -/
theorem R_193_ode
    (nuK tau : ℝ) (h_tau : 0 < tau) (t : ℝ) :
    HasDerivAt (nEff nuK tau) (nuK - nEff nuK tau t / tau) t := by
  have h_tau_ne : tau ≠ 0 := ne_of_gt h_tau
  -- inner affine map  s ↦ -(s/τ)  has derivative  -(1/τ).
  have h_aff : HasDerivAt (fun s : ℝ => -(s / tau)) (-(1 / tau)) t := by
    have h1 : HasDerivAt (fun s : ℝ => s / tau) (1 / tau) t := by
      simpa using (hasDerivAt_id t).div_const tau
    simpa using h1.neg
  -- exp of it:  s ↦ exp(-(s/τ))  has derivative  exp(-(t/τ))·(-(1/τ)).
  have h_exp : HasDerivAt (fun s => Real.exp (-(s / tau)))
      (Real.exp (-(t / tau)) * (-(1 / tau))) t := h_aff.exp
  -- 1 - exp(...) has derivative  -(exp(...)·(-(1/τ))).
  have h_sub : HasDerivAt (fun s => 1 - Real.exp (-(s / tau)))
      (-(Real.exp (-(t / tau)) * (-(1 / tau)))) t := by
    simpa using (hasDerivAt_const t (1 : ℝ)).sub h_exp
  -- multiply by constant ν_K·τ̄.
  have h_n := h_sub.const_mul (nuK * tau)
  -- reshape derivative value into  ν_K − n(t)/τ̄.
  unfold nEff
  convert h_n using 1
  field_simp
  ring

/-- **R.193 — asymptotic effective knowledge `n(t) → ν_K·τ̄`.**

For `τ̄ > 0`, the exponential term decays to `0`, so the effective
knowledge saturates at `ν_K·τ̄`. -/
theorem R_193_asymptote
    (nuK tau : ℝ) (h_tau : 0 < tau) :
    Filter.Tendsto (nEff nuK tau) Filter.atTop (nhds (nuK * tau)) := by
  -- t/τ → ∞ ⇒ -(t/τ) → -∞.
  have h_arg : Filter.Tendsto (fun t : ℝ => -(t / tau)) atTop atBot := by
    have h_div : Filter.Tendsto (fun t : ℝ => t / tau) atTop atTop := by
      have h_inv_pos : 0 < 1 / tau := by positivity
      have := Filter.Tendsto.const_mul_atTop h_inv_pos (tendsto_id (α := ℝ))
      simpa [div_eq_mul_inv, mul_comm] using this
    exact tendsto_neg_atBot_iff.mpr h_div
  -- exp(-(t/τ)) → 0.
  have h_exp0 : Filter.Tendsto (fun t : ℝ => Real.exp (-(t / tau)))
      atTop (nhds 0) :=
    Real.tendsto_exp_atBot.comp h_arg
  -- 1 - exp(...) → 1.
  have h_sub : Filter.Tendsto (fun t : ℝ => 1 - Real.exp (-(t / tau)))
      atTop (nhds (1 - 0)) :=
    (tendsto_const_nhds.sub h_exp0)
  -- multiply by ν_K·τ̄.
  have h_n : Filter.Tendsto (nEff nuK tau) atTop (nhds (nuK * tau * (1 - 0))) := by
    unfold nEff
    exact h_sub.const_mul (nuK * tau)
  simpa using h_n

/-- **R.193 — phase-transition threshold (sign flip at `ν_K^c`).**

With `τ̄ > 0`, the asymptotic coverage `n(∞) = ν_K·τ̄` exceeds the demand
`|R(p)|` exactly when `ν_K` exceeds the critical rate `ν_K^c = |R(p)|/τ̄`:

    ν_K·τ̄ > Rsize  ⟺  ν_K > Rsize / τ̄ . -/
theorem R_193_threshold
    (nuK tau Rsize : ℝ) (h_tau : 0 < tau) :
    nuK * tau > Rsize ↔ nuK > Rsize / tau := by
  rw [gt_iff_lt, gt_iff_lt, div_lt_iff₀ h_tau, mul_comm]

/-- **R.193 — net-growth regime (`ν_K > ν_K^c` ⇒ sustainable coverage).** -/
theorem R_193_net_growth
    (nuK tau Rsize : ℝ) (h_tau : 0 < tau)
    (h_super : nuK > Rsize / tau) :
    nuK * tau > Rsize :=
  (R_193_threshold nuK tau Rsize h_tau).mpr h_super

/-- **R.193 — net-decay regime (`ν_K < ν_K^c` ⇒ coverage never reached).** -/
theorem R_193_net_decay
    (nuK tau Rsize : ℝ) (h_tau : 0 < tau)
    (h_sub : nuK < Rsize / tau) :
    nuK * tau < Rsize := by
  rw [lt_div_iff₀ h_tau] at h_sub
  linarith [h_sub]

end DecayLearnTransition

end MIP
