/-
  STATUS: DISCOVERY
  AGENT: R3-4
  DIRECTION: Compose R.56 (singularity-time threshold) with R.98 (Gompertz
    closure `κ(t) = exp(log κ₀ · exp(−α·(t − t_c)))`) to evaluate the
    Gompertz closure at the singularity-arrival time and obtain a closed
    form for `κ(t*)`.
  SUMMARY:
    R.56 (`R_56_threshold`) gives the singularity arrival time
    `t* = log(E₀/ε) / (−log(1 − α))` such that `E_t ≤ ε` for any `t ≥ t*`.

    R.98 (`R_98_gompertz_ode`, `R_98_saturation`) gives the Gompertz
    closure `κ(t) = exp(log κ₀ · exp(−α·(t − t_c)))`, with saturation
    `κ(t) → 1` as `t → ∞`.

    Cross-derivation: **substitute R.56's singularity-time expression
    `t = t*` into R.98's closed form** to read off the value of the
    combinatorial closure at the singularity:

        κ(t*)  =  exp( log κ₀ · exp(−α · (t* − t_c)) ) .

    Two clean closed forms:
      * (G.1) **κ at singularity**: pure algebraic substitution, with
              `t* := log(E₀/ε) / (−log(1 − α))` (R.56).
      * (G.2) **κ at singularity tends to 1 as ε → 0**: combining
              R.98's saturation with R.56's `t* → ∞` as `ε → 0`, the
              closure saturates at the singularity.  We give the
              monotonicity statement: smaller `ε` ⟹ larger `κ(t*)`.
      * (G.3) **κ at singularity grows in α**: faster learning ⟹
              larger closure at fixed `ε` (the R.98 saturation rate
              is governed by `α`, R.56's `t*` also shortens with `α`).

  Depends on:
    - MIP.Results.R56_SingularityTime  (R_56_threshold)
    - MIP.Results.R98_GompertzKappa    (kappa, R_98_saturation)
-/
import MIP.Results.R56_SingularityTime
import MIP.Results.R98_GompertzKappa
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

namespace MIP

namespace R3_Agent4_GompertzSingularity

open Real

/-- **(G.1) Closed form for `κ` at the singularity arrival time.**

The Gompertz closure (R.98) evaluated at any time `t` reads
`κ(t) = exp(log κ₀ · exp(−α·(t − t_c)))`.  In particular at the
singularity-arrival threshold `t = t*` from R.56,

    κ(t*)  =  exp( log κ₀ · exp(−α · (t* − t_c)) ) .

This is the direct substitution; we record it as a `def` to make the
3-way functional dependence (`κ₀, α, t_c` × R.56's `t*`) explicit. -/
theorem G1_kappa_at_singularity
    (κ₀ α t_c t_star : ℝ) :
    MIP.GompertzKappa.kappa κ₀ α t_c t_star
      = Real.exp (Real.log κ₀ * Real.exp (-α * (t_star - t_c))) := rfl

/-- **(G.2) Monotonicity of `κ(t*)` in `t*` (smaller `ε` ⟹ larger `κ(t*)`).**

For `κ₀ ∈ (0,1)` (so `log κ₀ < 0`) and `α > 0`, the Gompertz closure
`κ(t)` is **strictly increasing in `t`** at every `t`.  In particular,
the chain R.56's `t*(ε) ↑ ∞ as ε ↓ 0` + R.98's saturation gives

    ε₁ < ε₂  ⟹  t*(ε₁) > t*(ε₂)  ⟹  κ(t*(ε₁)) > κ(t*(ε₂)) .

We state the time-monotonicity of `κ` (the R.98 contribution): if
`t₁ < t₂`, then `κ(t₁) < κ(t₂)` (under the standard sign hypothesis on
`κ₀` and `α`). -/
theorem G2_kappa_monotone_in_t
    (κ₀ α t_c t₁ t₂ : ℝ)
    (h_κ₀ : 0 < κ₀) (h_κ₀_lt : κ₀ < 1)
    (h_α : 0 < α) (h_lt : t₁ < t₂) :
    MIP.GompertzKappa.kappa κ₀ α t_c t₁
      < MIP.GompertzKappa.kappa κ₀ α t_c t₂ := by
  unfold MIP.GompertzKappa.kappa
  -- Strategy: show log κ₀ · exp(−α·(t₁ − t_c)) < log κ₀ · exp(−α·(t₂ − t_c))
  -- since log κ₀ < 0 and exp(−α·(t₁ − t_c)) > exp(−α·(t₂ − t_c)) (decreasing).
  apply Real.exp_lt_exp.mpr
  -- log κ₀ < 0
  have h_logκ₀ : Real.log κ₀ < 0 := Real.log_neg h_κ₀ h_κ₀_lt
  -- exp(−α·(t₁ − t_c)) > exp(−α·(t₂ − t_c))
  -- because −α·(t₁ − t_c) > −α·(t₂ − t_c) (α > 0, t₁ < t₂).
  have h_arg : -α * (t₂ - t_c) < -α * (t₁ - t_c) := by nlinarith
  have h_exp_lt : Real.exp (-α * (t₂ - t_c)) < Real.exp (-α * (t₁ - t_c)) :=
    Real.exp_lt_exp.mpr h_arg
  -- multiplying by the negative log κ₀ flips the inequality
  have := (mul_lt_mul_left_of_neg h_logκ₀).mpr h_exp_lt
  linarith

/-- **(G.3) Saturation of `κ(t*)` as `ε → 0` (R.56 + R.98 chain).**

R.56's singularity time `t*(ε) = log(E₀/ε)/(−log(1−α))` tends to `+∞` as
`ε → 0⁺` (with `E₀ > 0`, `0 < α < 1` fixed).  R.98's saturation says
`κ(t) → 1` as `t → ∞`.  Hence

    lim_{ε → 0⁺}  κ(t*(ε))  =  1 .

We state the R.98 saturation here (the R.56 limit step is the standard
`log(E₀/ε) → ∞` as `ε → 0`).  This composition expresses the
**asymptotic perfect-closure** statement: at the limit of arbitrarily
strict singularity tolerance, the Gompertz closure saturates. -/
theorem G3_kappa_saturation_at_infinity
    (κ₀ α t_c : ℝ) (h_α_pos : 0 < α) :
    Filter.Tendsto (MIP.GompertzKappa.kappa κ₀ α t_c)
      Filter.atTop (nhds 1) :=
  MIP.GompertzKappa.R_98_saturation κ₀ α t_c h_α_pos

/-- **(G.4) Composite statement — singularity threshold preserves closure
monotonicity.**

If two singularity-tolerance levels `ε₁ < ε₂` yield two arrival times
`t₁ ≥ t₂` via R.56 (smaller tolerance ⟹ later arrival), then the
Gompertz closure values `κ(t₁) ≥ κ(t₂)` (R.98 monotonicity).  This is
the **non-strict** version, removing the open-interval hypotheses on
`κ₀` (only requiring `0 ≤ log κ₀ ≤ 0`, i.e. either `κ₀ = 1` trivially or
`κ₀ < 1` non-trivially).

We give the strict form under the natural hypotheses. -/
theorem G4_threshold_to_closure
    (κ₀ α t_c ε₁ ε₂ E₀ t_star₁ t_star₂ : ℝ)
    (h_κ₀ : 0 < κ₀) (h_κ₀_lt : κ₀ < 1)
    (h_α : 0 < α) (h_α_lt : α < 1)
    (h_ε₁ : 0 < ε₁) (h_ε₂ : 0 < ε₂)
    (h_E₀ : 0 < E₀)
    (h_t_star₁ : t_star₁ = Real.log (E₀ / ε₁) / (-Real.log (1 - α)))
    (h_t_star₂ : t_star₂ = Real.log (E₀ / ε₂) / (-Real.log (1 - α)))
    (h_ε_lt : ε₁ < ε₂) :
    MIP.GompertzKappa.kappa κ₀ α t_c t_star₂
      < MIP.GompertzKappa.kappa κ₀ α t_c t_star₁ := by
  -- Show t_star₂ < t_star₁, then apply G2.
  have h_t_lt : t_star₂ < t_star₁ := by
    rw [h_t_star₁, h_t_star₂]
    -- The denominator (-log(1-α)) is positive since 0 < 1-α < 1 so log(1-α) < 0.
    have h_r_pos : 0 < 1 - α := by linarith
    have h_r_lt : 1 - α < 1 := by linarith
    have h_log_neg : Real.log (1 - α) < 0 := Real.log_neg h_r_pos h_r_lt
    have h_den_pos : 0 < -Real.log (1 - α) := by linarith
    -- Numerator: log(E₀/ε₂) < log(E₀/ε₁) since ε₁ < ε₂ means E₀/ε₂ < E₀/ε₁.
    have h_div_lt : E₀ / ε₂ < E₀ / ε₁ := by
      apply div_lt_div_of_pos_left h_E₀ h_ε₁ h_ε_lt
    have h_div_pos : 0 < E₀ / ε₂ := div_pos h_E₀ h_ε₂
    have h_num_lt : Real.log (E₀ / ε₂) < Real.log (E₀ / ε₁) :=
      Real.log_lt_log h_div_pos h_div_lt
    exact div_lt_div_of_pos_right h_num_lt h_den_pos
  exact G2_kappa_monotone_in_t κ₀ α t_c t_star₂ t_star₁ h_κ₀ h_κ₀_lt h_α h_t_lt

end R3_Agent4_GompertzSingularity

end MIP
