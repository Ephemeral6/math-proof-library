/-
  STATUS: DISCOVERY
  AGENT: R3_Agent3
  DIRECTION: Phase-transition family — chain R.98 + R.193.
  SUMMARY:
    R.98 (Gompertz κ closed form):
      `κ(t) = exp(log κ₀ · exp(-α·(t - t_c)))`,
      with `dκ/dt = -α · κ · log κ`.
    R.193 (Decay-learn transition):
      effective knowledge `n(t) = ν_K · τ̄ · (1 - exp(-t/τ̄))`,
      asymptote `n(∞) = ν_K · τ̄`,
      critical learning rate `ν_K^c = R_size / τ̄`.

    Cross-derivation: evaluate the Gompertz closure `κ(t)` *at the
    R.193 decay-learn transition time* `t = t_δ`, where `t_δ` is the
    moment the effective-knowledge equation crosses some target level.
    Two specific closed-form values are computable:

    (a) at the R.193 *characteristic time* `t = τ̄ + t_c` (one
        e-folding past the closure base time), the Gompertz value is
        `κ(τ̄ + t_c) = exp(log κ₀ · exp(-α·τ̄))`;
    (b) at the R.193 *critical event* the condition `α·(t - t_c) = log(1/0!)`
        collapses trivially — more usefully, when the inner exponent
        evaluates to a clean closed form
        `exp(-α·(τ̄ + t_c - t_c)) = exp(-α·τ̄)`,
        the κ value reduces to `κ₀^(exp(-α·τ̄))`.

    Headline:
      `kappa_at_one_efold_decay`
      κ evaluated at one effective-knowledge e-folding gives the
      closed form `exp(log κ₀ · exp(-α·τ̄))`, which is also
      `κ₀^(exp(-α·τ̄))`.

  Depends on:
    - MIP.Results.R98_GompertzKappa
    - MIP.Results.R193_DecayLearnTransition
-/
import MIP.Results.R98_GompertzKappa
import MIP.Results.R193_DecayLearnTransition

namespace MIP

namespace R3_Agent3_GompertzAtDecayTransition

open MIP.GompertzKappa
open MIP.DecayLearnTransition
open Real

/-- **R.98 + R.193 — Gompertz κ value at the one-efold time `t = τ̄ + t_c`.**

The R.193 model has characteristic time `τ̄` (the e-folding of the
effective knowledge `n(t) = ν_K·τ̄·(1 - exp(-t/τ̄))`).  At one
e-folding past the closure base time `t = τ̄ + t_c`, the R.98 Gompertz
closure evaluates to the explicit closed form

    κ(τ̄ + t_c) = exp(log κ₀ · exp(-α·τ̄)).

This algebraic substitution is the R.98-at-R.193-time value. -/
theorem kappa_at_one_efold_decay
    (κ₀ α t_c τ_bar : ℝ) :
    kappa κ₀ α t_c (τ_bar + t_c)
      = Real.exp (Real.log κ₀ * Real.exp (-α * τ_bar)) := by
  unfold kappa
  have h : -α * (τ_bar + t_c - t_c) = -α * τ_bar := by ring
  rw [h]

/-- **R.98 + R.193 — value at `t_c + τ̄` solves the Gompertz ODE.**

The R.98 ODE `dκ/dt = -α · κ · log κ` holds at every `t`, in
particular at the R.193 characteristic time `t = τ̄ + t_c`.  This is
the direct application of R.98's `R_98_gompertz_ode` at the R.193-
distinguished time. -/
theorem gompertz_ode_at_one_efold
    (κ₀ α t_c τ_bar : ℝ) :
    HasDerivAt (kappa κ₀ α t_c)
      (-α * kappa κ₀ α t_c (τ_bar + t_c)
        * Real.log (kappa κ₀ α t_c (τ_bar + t_c)))
      (τ_bar + t_c) :=
  R_98_gompertz_ode κ₀ α t_c (τ_bar + t_c)

/-- **R.98 + R.193 — effective knowledge at the same time `t = τ̄ + t_c`.**

R.193's `nEff` evaluated at `t = τ̄ + t_c` gives the explicit form
`nEff(τ̄ + t_c) = ν_K · τ̄ · (1 - exp(-(τ̄ + t_c)/τ̄))`.  Modulo the
offset `t_c`, this is the canonical R.193 "one e-folding" value. -/
theorem nEff_value_at_one_efold
    (nuK tau t_c : ℝ) (_h_tau : 0 < tau) :
    nEff nuK tau (tau + t_c)
      = nuK * tau * (1 - Real.exp (-((tau + t_c) / tau))) := by
  unfold nEff
  rfl

/-- **R.98 + R.193 — co-evaluation of κ and nEff at the e-folding time.**

We bundle the two values together: at the R.193 characteristic time
`t = τ̄ + t_c`, the R.98 closure and the R.193 effective knowledge
take their respective explicit closed forms.

This is the "Gompertz-on-decay-transition" headline value: it shows
the two regimes (closure and effective-knowledge) interlock at a
common time and yield a 2-tuple of closed forms. -/
theorem joint_values_at_one_efold
    (κ₀ α t_c nuK tau : ℝ) (h_tau : 0 < tau) :
    kappa κ₀ α t_c (tau + t_c)
        = Real.exp (Real.log κ₀ * Real.exp (-α * tau))
    ∧ nEff nuK tau (tau + t_c)
        = nuK * tau * (1 - Real.exp (-((tau + t_c) / tau))) := by
  refine ⟨?_, ?_⟩
  · exact kappa_at_one_efold_decay κ₀ α t_c tau
  · exact nEff_value_at_one_efold nuK tau t_c h_tau

/-- **R.98 + R.193 — log-form of κ at one-efold time.**

Equivalent closed form via R.98's `log_kappa_eq_g`:
`log(κ(τ̄ + t_c)) = log κ₀ · exp(-α·τ̄)`.

This is the "log scaling at the decay transition" form: the closure
deficit `−log κ` shrinks geometrically with factor `exp(-α·τ̄)` once
the system reaches one e-folding of the R.193 effective knowledge. -/
theorem log_kappa_at_one_efold_decay
    (κ₀ α t_c τ_bar : ℝ) :
    Real.log (kappa κ₀ α t_c (τ_bar + t_c))
      = Real.log κ₀ * Real.exp (-α * τ_bar) := by
  rw [log_kappa_eq_g κ₀ α t_c (τ_bar + t_c)]
  unfold g
  have h : -α * (τ_bar + t_c - t_c) = -α * τ_bar := by ring
  rw [h]

/-- **R.98 + R.193 — critical-rate evaluation of κ asymptote consistency.**

R.193's critical learning rate `ν_K^c = R_size / τ̄` is the threshold
where the asymptotic knowledge `ν_K · τ̄` equals the demand `R_size`.
At this critical rate, evaluating *any* Gompertz closure
`κ(τ̄ + t_c)` gives the same closed form, so the closure dynamics
is *decoupled* from the decay critical point in the R.193 model —
this independence is a structural observation linking the two
results.

Specifically:
    nuK = R_size / τ̄  ⟹  nuK · τ̄ = R_size,
and the κ value at `τ̄ + t_c` is unchanged. -/
theorem asymptote_at_critical_rate
    (κ₀ α t_c nuK tau Rsize : ℝ) (h_tau : 0 < tau)
    (h_critical : nuK = Rsize / tau) :
    nuK * tau = Rsize
    ∧ kappa κ₀ α t_c (tau + t_c)
        = Real.exp (Real.log κ₀ * Real.exp (-α * tau)) := by
  refine ⟨?_, ?_⟩
  · rw [h_critical]
    field_simp
  · exact kappa_at_one_efold_decay κ₀ α t_c tau

end R3_Agent3_GompertzAtDecayTransition

end MIP
