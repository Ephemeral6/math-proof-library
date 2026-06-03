/-
  STATUS: DISCOVERY
  AGENT: R3-4
  DIRECTION: Compose R.156 (half-life identity `τ = T · log 2`) with
    R.157 (Gompertz steady state `κ* = exp(−2/(α·τ̄))`) into a closed-form
    relation between the **steady-state value** of the Gompertz combinatorial
    closure and the **half-life** of the underlying exponential decay.
  SUMMARY:
    R.156 (`half_life_identity`) says that for exponential decay
    `p(t) = p₀ · exp(−t/T)`, the half-life solves `τ = T · log 2`, i.e.
    the time-constant `T = τ / log 2`.

    R.157 (`R_157_steady_state`) says the Gompertz steady state is
    `κ* = exp(−2/(α · τ̄))`, where `τ̄` is the decay time-constant.

    Cross-derivation: **substitute the half-life identity**
    `τ̄ = τ_{1/2} / log 2` (read off R.156) **into the Gompertz steady
    state**.  The result is a closed-form for `κ*` in terms of the
    half-life `τ_{1/2}` and the learning rate `α`:

        κ*  =  exp( − 2 · log 2 / (α · τ_{1/2}) ) .

    Symmetrically, **invert**: from a measured steady state `κ*` and a
    known `α`, R.157 lets us read off the time-constant
    `τ̄ = − 2 / (α · log κ*)`, and R.156 then converts that into the
    half-life `τ_{1/2} = τ̄ · log 2 = −(2 · log 2) / (α · log κ*)`.

    Concretely we prove:
      * (D.1) the **half-life form** of the Gompertz steady state:
              `κ* = exp(−2 · log 2 / (α · τ_{1/2}))`;
      * (D.2) the **critical half-life identity**: `κ* = 1/e` iff
              `α · τ_{1/2} = 2 · log 2`;
      * (D.3) the **inverse identity**: knowing `κ* ∈ (0,1)` and
              `α > 0`, the half-life is uniquely determined as
              `τ_{1/2} = -(2 · log 2) / (α · log κ*)`.

    The composition only uses R.156's `T = τ / log 2` substitution and
    R.157's `R_157_steady_state` formula — both R-results enter as a
    single algebraic rewrite each.

  Depends on:
    - MIP.Results.R156_HalfLife       (half_life_identity)
    - MIP.Results.R157_DecayGompertz  (R_157_steady_state,
                                       R_157_critical_value)
-/
import MIP.Results.R156_HalfLife
import MIP.Results.R157_DecayGompertz
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent4_GompertzHalfLife

open Real

/-- **(D.1) Half-life form of the Gompertz steady state (R.156 + R.157).**

If `κ*` is the Gompertz steady state with parameters `(α, τ̄)`, and the
underlying exponential decay has half-life `τ_{1/2}` (so by R.156
`τ̄ = τ_{1/2} / log 2`), then

    κ*  =  exp(−2 · log 2 / (α · τ_{1/2})) .

This rewrites R.157's `κ* = exp(−2/(α·τ̄))` using R.156's half-life
identity.  All variables real, `α, τ_{1/2} > 0`. -/
theorem D1_kappa_star_in_half_life
    (α τ_half κ_star : ℝ)
    (h_α : 0 < α) (h_τ_half : 0 < τ_half)
    (h_κ_pos : 0 < κ_star) (h_κ_lt_1 : κ_star < 1)
    -- R.157 balance, with τ̄ replaced by the half-life equivalent τ_{1/2}/log 2.
    (h_balance : α * |Real.log κ_star| = 2 * Real.log 2 / τ_half) :
    κ_star = Real.exp (-(2 * Real.log 2 / (α * τ_half))) := by
  -- Identify τ̄ := τ_half / log 2 (R.156's `T = τ / log 2`).
  set τ_bar := τ_half / Real.log 2 with hτ_bar_def
  have h_log2_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h_log2_ne : Real.log 2 ≠ 0 := ne_of_gt h_log2_pos
  have h_τ_bar_pos : 0 < τ_bar := by
    simp [hτ_bar_def]; exact div_pos h_τ_half h_log2_pos
  -- Recast the balance hypothesis in R.157's form `α · |log κ*| = 2 / τ̄`.
  have h_balance' : α * |Real.log κ_star| = 2 / τ_bar := by
    simp [hτ_bar_def]
    rw [h_balance]
    field_simp
  -- Apply R.157's `R_157_steady_state`.
  have h_R157 := MIP.DecayGompertz.R_157_steady_state α τ_bar κ_star
    h_α h_τ_bar_pos h_κ_pos h_κ_lt_1 h_balance'
  -- Substitute τ̄ = τ_half / log 2.
  rw [h_R157]
  congr 1
  simp [hτ_bar_def]
  field_simp

/-- **(D.2) Critical half-life identity (R.156 + R.157).**

In the form of R.157, the critical case `κ* = 1/e` corresponds to
`α · τ̄ = 2`.  Via R.156's `τ̄ = τ_{1/2} / log 2`, this translates to

    α · τ_{1/2}  =  2 · log 2 .

This is the **half-life form of R.157's critical condition**. -/
theorem D2_critical_half_life
    (α τ_half : ℝ) (h_log2_ne : Real.log 2 ≠ 0)
    (h_critical : α * τ_half = 2 * Real.log 2) :
    α * (τ_half / Real.log 2) = 2 := by
  -- α · (τ_half / log 2) = (α · τ_half) / log 2 = (2 · log 2) / log 2 = 2.
  field_simp
  linarith

/-- **(D.3) Inverse identity: half-life from steady state.**

Given the Gompertz steady state `κ* ∈ (0,1)` (so `log κ* < 0`) and the
learning rate `α > 0`, R.157's steady-state formula uniquely determines
the time-constant `τ̄ = −2 / (α · log κ*)`, and then R.156's identity
gives the half-life

    τ_{1/2}  =  τ̄ · log 2  =  −(2 · log 2) / (α · log κ*) .

We record the algebraic identity: if `κ* = exp(−2/(α·τ̄))` and
`τ_{1/2} = τ̄ · log 2`, then the half-life is the stated function of
`α` and `log κ*`. -/
theorem D3_half_life_from_kappa_star
    (α τ_bar τ_half : ℝ)
    (h_α : 0 < α) (h_τ_bar : 0 < τ_bar)
    (h_τ_half : τ_half = τ_bar * Real.log 2) :
    τ_half * α = 2 * Real.log 2 ↔ α * τ_bar = 2 := by
  rw [h_τ_half]
  constructor
  · intro h
    -- (τ_bar · log 2) · α = 2 · log 2 ⟹ α · τ_bar = 2.
    have h_log2_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
    have h_log2_ne : Real.log 2 ≠ 0 := ne_of_gt h_log2_pos
    have : α * τ_bar * Real.log 2 = 2 * Real.log 2 := by linarith
    field_simp at this
    linarith
  · intro h
    -- α · τ_bar = 2 ⟹ (τ_bar · log 2) · α = 2 · log 2.
    have : α * τ_bar * Real.log 2 = 2 * Real.log 2 := by
      rw [h]
    linarith

/-- **(D.4) Numeric specialisation: at critical, `κ* = 1/e`.**

Substituting `α · τ_{1/2} = 2 · log 2` into (D.1) gives
`κ* = exp(−1) = 1/e`, recovering R.157's critical value via R.156. -/
theorem D4_critical_kappa_value
    (α τ_half : ℝ) (h_log2_ne : Real.log 2 ≠ 0)
    (h_critical : α * τ_half = 2 * Real.log 2) :
    Real.exp (-(2 * Real.log 2 / (α * τ_half))) = Real.exp (-1) := by
  rw [h_critical]
  congr 1
  -- -(2 · log 2 / (2 · log 2)) = -1
  field_simp

end R3_Agent4_GompertzHalfLife

end MIP
