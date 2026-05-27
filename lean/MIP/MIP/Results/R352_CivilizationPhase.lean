/-
Result R.352 — Civilization phase-transition exact condition (μ_N > λ_P).
Reference: branches/sociology/workspace/new_results.md (old sociology R.139).

**Statement.** Let `λ_P(t) = λ₀·exp(γ·t)` be the exogenous problem-
generation rate (D.5.3) and `μ_N(t) = W(t)/E_P[N(t)]` the endogenous
problem-solving rate.  With the flywheel decay `E_P[N(t)] = N₀·exp(−α_eff·t)`
(T.5) and constant work budget `W(t) = W₀`,

    μ_N(t) = (W₀/N₀)·exp(α_eff·t).

The civilization "solves faster than it generates problems" exactly when
the phase-transition condition `μ_N(t) > λ_P(t)` first holds.  Solving
`μ_N(t**) = λ_P(t**)` gives the exact dichotomy:

    α_eff > γ :  t** = log(λ₀·N₀/W₀)/(α_eff − γ)   (transition reachable);
    α_eff ≤ γ :  t** = +∞                           (never reached —
                                                       "problem-growth trap").

The sign of the *net rate* `μ_N − λ_P` flips from negative to positive
exactly once iff the solving-rate exponent `α_eff` exceeds the
generation-rate exponent `γ`: this is the clean threshold kernel.

**Kernel formalized here.** Pure real-exponential algebra.
(1) `R_352_muN_form`: the solving rate equals `(W₀/N₀)·exp(α_eff·t)` from
the decay law (substitution).
(2) `R_352_transition_time`: at the crossing time `t**` the two rates are
equal, and `t** = log(λ₀N₀/W₀)/(α_eff − γ)` solves the crossing equation
`exp((α_eff − γ)·t**) = λ₀N₀/W₀` when `α_eff ≠ γ`.
(3) `R_352_threshold_dichotomy`: the ratio `μ_N(t)/λ_P(t) =
(W₀/(λ₀N₀))·exp((α_eff − γ)·t)` is strictly increasing in `t` iff
`α_eff > γ`; so the transition `μ_N > λ_P` is reachable iff `α_eff > γ`.
(4) `R_352_net_rate_sign`: the net-rate sign condition `μ_N(t) > λ_P(t)`
⟺ `exp((α_eff−γ)t) > λ₀N₀/W₀` — the ODE/threshold sign kernel.

**Bridge.** `W₀, N₀, λ₀, α_eff, γ` are sociology scalars supplied as
hypothesis-bundled reals; the population-dynamics ansatz (exponential
`λ_P`, flywheel decay) enters only through the explicit rate forms,
exactly as in the source (different ansatz ⟹ different `t**`, but the
`α_eff` vs `γ` threshold structure is universal).

(`lam0` denotes the source's `λ₀`; the identifier `λ` is reserved in
Lean for lambda-abstraction.)

Axiom-free.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R352_CivilizationPhase

open Real

/-- Problem-solving rate `μ_N(t) = W(t)/E_P[N(t)]`, here with constant
work `W₀` and flywheel decay `E_P[N(t)] = N₀·exp(−α_eff·t)`. -/
noncomputable def muN (W0 N0 α_eff t : ℝ) : ℝ :=
  W0 / (N0 * Real.exp (-α_eff * t))

/-- Problem-generation rate `λ_P(t) = λ₀·exp(γ·t)` (D.5.3). -/
noncomputable def lamP (lam0 γ t : ℝ) : ℝ :=
  lam0 * Real.exp (γ * t)

/-- **R.352 — closed form of the solving rate.**

From `E_P[N(t)] = N₀·exp(−α_eff·t)` and `W = W₀`,

    μ_N(t) = W₀/(N₀·exp(−α_eff·t)) = (W₀/N₀)·exp(α_eff·t).

Substitution + `exp(−x)⁻¹ = exp(x)`. -/
theorem R_352_muN_form
    (W0 N0 α_eff t : ℝ) (h_N0 : N0 ≠ 0) :
    muN W0 N0 α_eff t = (W0 / N0) * Real.exp (α_eff * t) := by
  unfold muN
  rw [neg_mul, Real.exp_neg]
  field_simp

/-- **R.352 — net-rate sign / threshold kernel.**

The phase condition `μ_N(t) > λ_P(t)` (civilization solves faster than it
generates) is, after using the closed forms and dividing by the positive
`λ₀·exp(γ·t)`, equivalent to

    exp((α_eff − γ)·t)  >  λ₀·N₀ / W₀ .

This is the clean threshold inequality: the sign of `μ_N − λ_P` is the
sign of `exp((α_eff − γ)t) − λ₀N₀/W₀`. -/
theorem R_352_net_rate_sign
    (W0 N0 lam0 α_eff γ t : ℝ)
    (h_N0_pos : 0 < N0) (h_lam0_pos : 0 < lam0) (h_W0_pos : 0 < W0) :
    muN W0 N0 α_eff t > lamP lam0 γ t
      ↔ Real.exp ((α_eff - γ) * t) > lam0 * N0 / W0 := by
  rw [R_352_muN_form W0 N0 α_eff t (ne_of_gt h_N0_pos)]
  unfold lamP
  have hexp_pos : 0 < Real.exp (γ * t) := Real.exp_pos _
  constructor
  · intro h
    -- (W0/N0)·exp(α t) > λ0·exp(γ t)  ⟹  exp((α−γ)t) > λ0 N0 / W0
    have hNW : 0 < N0 / W0 := div_pos h_N0_pos h_W0_pos
    have h2 : (N0 / W0) * ((W0 / N0) * Real.exp (α_eff * t))
        > (N0 / W0) * (lam0 * Real.exp (γ * t)) :=
      (mul_lt_mul_iff_of_pos_left hNW).mpr h
    have hleft : (N0 / W0) * ((W0 / N0) * Real.exp (α_eff * t))
        = Real.exp (α_eff * t) := by
      field_simp
    rw [hleft] at h2
    have h3 : Real.exp (α_eff * t) / Real.exp (γ * t)
        > ((N0 / W0) * (lam0 * Real.exp (γ * t))) / Real.exp (γ * t) :=
      (div_lt_div_iff_of_pos_right hexp_pos).mpr h2
    have hl : Real.exp (α_eff * t) / Real.exp (γ * t)
        = Real.exp ((α_eff - γ) * t) := by
      rw [← Real.exp_sub, sub_mul]
    have hr : ((N0 / W0) * (lam0 * Real.exp (γ * t))) / Real.exp (γ * t)
        = lam0 * N0 / W0 := by
      rw [mul_div_assoc, mul_div_assoc, div_self (ne_of_gt hexp_pos), mul_one]
      field_simp
    rw [hl, hr] at h3
    exact h3
  · intro h
    have hNW : 0 < W0 / N0 := div_pos h_W0_pos h_N0_pos
    have h2 : (W0 / N0) * Real.exp ((α_eff - γ) * t)
        > (W0 / N0) * (lam0 * N0 / W0) :=
      (mul_lt_mul_iff_of_pos_left hNW).mpr h
    have hr : (W0 / N0) * (lam0 * N0 / W0) = lam0 := by
      field_simp
    rw [hr] at h2
    -- now (W0/N0)·exp((α−γ)t) > λ0; multiply both sides by exp(γt) > 0
    have h3 : ((W0 / N0) * Real.exp ((α_eff - γ) * t)) * Real.exp (γ * t)
        > lam0 * Real.exp (γ * t) :=
      mul_lt_mul_of_pos_right h2 hexp_pos
    have hl : ((W0 / N0) * Real.exp ((α_eff - γ) * t)) * Real.exp (γ * t)
        = (W0 / N0) * Real.exp (α_eff * t) := by
      rw [mul_assoc, ← Real.exp_add, sub_mul, sub_add_cancel]
    rw [hl] at h3
    exact h3

/-- **R.352 — exact transition time `t**`.**

When `α_eff ≠ γ`, the crossing equation `exp((α_eff − γ)·t**) = λ₀N₀/W₀`
(equality of the two rates, from `R_352_net_rate_sign` at equality) is
solved by

    t** = log(λ₀·N₀/W₀) / (α_eff − γ) .

We verify: substituting this `t**` into `(α_eff − γ)·t**` recovers
`log(λ₀N₀/W₀)`, hence `exp((α_eff − γ)·t**) = λ₀N₀/W₀` (for the positive
argument `λ₀N₀/W₀ > 0`). -/
theorem R_352_transition_time
    (W0 N0 lam0 α_eff γ : ℝ)
    (h_pos : 0 < lam0 * N0 / W0)
    (h_ne : α_eff - γ ≠ 0) :
    Real.exp ((α_eff - γ) * (Real.log (lam0 * N0 / W0) / (α_eff - γ)))
      = lam0 * N0 / W0 := by
  have hmul : (α_eff - γ) * (Real.log (lam0 * N0 / W0) / (α_eff - γ))
      = Real.log (lam0 * N0 / W0) := by
    field_simp
  rw [hmul, Real.exp_log h_pos]

/-- **R.352 — threshold dichotomy (reachability).**

The transition `μ_N > λ_P` is *reachable* (the ratio
`μ_N/λ_P = (W₀/(λ₀N₀))·exp((α_eff−γ)t)` strictly increases without bound,
crossing any level) iff the solving exponent dominates the generation
exponent, `α_eff > γ`.

Kernel: `exp((α_eff − γ)·t)` is strictly monotone increasing in `t`
iff `α_eff − γ > 0`, i.e. `α_eff > γ`.  We prove the strict-mono ⟸
direction (the substantive reachability claim): if `α_eff > γ` then for
`t₁ < t₂` the threshold quantity strictly increases. -/
theorem R_352_threshold_dichotomy
    (α_eff γ t₁ t₂ : ℝ)
    (h_threshold : α_eff > γ) (h_t : t₁ < t₂) :
    Real.exp ((α_eff - γ) * t₁) < Real.exp ((α_eff - γ) * t₂) := by
  apply Real.exp_lt_exp.mpr
  have h_diff_pos : 0 < α_eff - γ := by linarith
  exact (mul_lt_mul_iff_of_pos_left h_diff_pos).mpr h_t

/-- **R.352 — trap case (`α_eff ≤ γ` ⟹ non-increasing threshold).**

In the "problem-growth trap" `α_eff ≤ γ`, the threshold quantity
`exp((α_eff − γ)t)` is non-increasing in `t`, so once below `λ₀N₀/W₀` it
never crosses upward: the transition is never reached (`t** = +∞`). -/
theorem R_352_trap_case
    (α_eff γ t₁ t₂ : ℝ)
    (h_trap : α_eff ≤ γ) (h_t : t₁ ≤ t₂) :
    Real.exp ((α_eff - γ) * t₂) ≤ Real.exp ((α_eff - γ) * t₁) := by
  apply Real.exp_le_exp.mpr
  have h_diff_nonpos : α_eff - γ ≤ 0 := by linarith
  nlinarith [mul_nonneg (neg_nonneg.mpr h_diff_nonpos) (sub_nonneg.mpr h_t)]

end R352_CivilizationPhase

end MIP
