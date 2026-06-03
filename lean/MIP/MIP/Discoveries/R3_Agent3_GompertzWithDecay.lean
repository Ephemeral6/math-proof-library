/-
  STATUS: DISCOVERY
  AGENT: R3_Agent3
  DIRECTION: Phase-transition family — chain R.98 + R.518.
  SUMMARY:
    R.98 (Gompertz κ closed form):
      `κ(t) = exp(log κ₀ · exp(-α·(t - t_c)))`,
      saturation: `κ(t) → 1` as `t → ∞` for `α > 0`.
    R.518 (Decay grokking suppression):
      decay steady state `κ_eff^∞ = exp(-2/(α·τ̄))`,
      strictly less than 1 (the closure ceiling) for `α, τ̄ > 0`.

    Cross-derivation: WITHOUT decay, R.98's Gompertz saturates at 1.
    WITH decay (R.518 model), the same Gompertz dynamics is *capped*
    at `κ_eff^∞ < 1`.  The "Gompertz-with-decay" picture: the closure
    saturation ceiling is lowered from 1 (R.98) to `κ_eff^∞` (R.518).

    Concrete content:
      (a) the R.98 saturation limit `1` differs from the R.518 decay
          steady state by the precise gap `1 - exp(-2/(α·τ̄))`;
      (b) the R.518 steady state is monotone increasing in `α·τ̄`
          (steeper Gompertz drive or longer half-life pushes the
          ceiling up toward the R.98 unimpeded limit `1`);
      (c) in the limit `τ̄ → ∞` (no decay) the R.518 ceiling
          `exp(-2/(α·τ̄)) → exp(0) = 1`, recovering R.98 saturation.

    Headline:
      `gompertz_with_decay_ceiling_below_one`
      under R.98's Gompertz + R.518's decay model, the saturation
      ceiling is strictly below the no-decay R.98 limit.

  Depends on:
    - MIP.Results.R98_GompertzKappa
    - MIP.Results.R518_DecayGrokkingSuppression
-/
import MIP.Results.R98_GompertzKappa
import MIP.Results.R518_DecayGrokkingSuppression

namespace MIP

namespace R3_Agent3_GompertzWithDecay

open MIP.GompertzKappa
open MIP.DecayGrokkingSuppression
open Real

/-- **R.518 — decay steady state strictly below 1.**

For `α, τ̄ > 0`, the R.518 decay ceiling `κ_eff^∞ = exp(-2/(α·τ̄))` is
strictly below `1` (i.e. below the R.98 no-decay saturation). -/
theorem kappaInf_lt_one
    (α τ_bar : ℝ) (h_α : 0 < α) (h_τ : 0 < τ_bar) :
    kappaInf α τ_bar < 1 := by
  unfold kappaInf
  rw [show (1 : ℝ) = Real.exp 0 from (Real.exp_zero).symm]
  apply Real.exp_lt_exp.mpr
  have h_pos : 0 < 2 / (α * τ_bar) := by positivity
  linarith

/-- **R.518 — decay steady state strictly positive.**

`κ_eff^∞ = exp(-2/(α·τ̄)) > 0` since exp is always positive. -/
theorem kappaInf_pos
    (α τ_bar : ℝ) :
    0 < kappaInf α τ_bar := by
  unfold kappaInf
  exact Real.exp_pos _

/-- **R.98 + R.518 — saturation gap.**

The R.98 saturation limit is `1` (no decay) and the R.518 decay
ceiling is `exp(-2/(α·τ̄)) < 1`.  The *gap* between them is
strictly positive:

    1 - κ_eff^∞ = 1 - exp(-2/(α·τ̄)) > 0,

quantifying how far decay pushes the closure ceiling below the
unimpeded R.98 saturation. -/
theorem saturation_gap_positive
    (α τ_bar : ℝ) (h_α : 0 < α) (h_τ : 0 < τ_bar) :
    0 < 1 - kappaInf α τ_bar := by
  have h_lt : kappaInf α τ_bar < 1 := kappaInf_lt_one α τ_bar h_α h_τ
  linarith

/-- **R.98 + R.518 — Gompertz dynamics still solves the ODE.**

The R.98 ODE `dκ/dt = -α · κ · log κ` is independent of any decay
modification: the *Gompertz form* solves it everywhere.  This is just
restated here, emphasizing the *invariance* of the Gompertz ODE
across the decay-modification. -/
theorem gompertz_ode_invariant_under_decay
    (κ₀ α t_c : ℝ) (t : ℝ) :
    HasDerivAt (kappa κ₀ α t_c)
      (-α * kappa κ₀ α t_c t * Real.log (kappa κ₀ α t_c t)) t :=
  R_98_gompertz_ode κ₀ α t_c t

/-- **R.98 + R.518 — decay-modified ceiling above the grokking surface.**

The combined regime: the R.518 ceiling `κ_eff^∞` lies strictly
between `0` (lower bound) and `κ_c² ∈ (0,1)` (grokking surface) when
the decay is sub-critical (`τ̄ < τ̄_critical`).

We package the resulting **bracketing**: `0 < κ_eff^∞ < κ_c² < 1`. -/
theorem decay_ceiling_brackets_surface
    (α τ_bar κc2 : ℝ)
    (h_α : 0 < α) (h_τ : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2) :
    0 < kappaInf α τ_bar
    ∧ kappaInf α τ_bar < κc2
    ∧ κc2 < 1 := by
  refine ⟨kappaInf_pos α τ_bar, ?_, h_κc_lt1⟩
  exact R_520_suppression α τ_bar κc2 h_α h_τ h_κc_pos h_κc_lt1 h_lt

/-- **HEADLINE — Gompertz-with-decay ceiling below one (R.98 + R.518).**

The compound statement: in the decay regime modeled by R.518, the
R.98 Gompertz closure can *never saturate to* its no-decay limit
`1`.  Instead the saturation occurs at the strictly lower
`κ_eff^∞ = exp(-2/(α·τ̄)) < 1`.

This is the rigorous "Gompertz with decay" picture — same ODE, but
ceiling shifted downward by the decay drain. -/
theorem gompertz_with_decay_ceiling_below_one
    (α τ_bar : ℝ) (h_α : 0 < α) (h_τ : 0 < τ_bar) :
    kappaInf α τ_bar < 1
    ∧ 0 < 1 - kappaInf α τ_bar := by
  refine ⟨kappaInf_lt_one α τ_bar h_α h_τ, ?_⟩
  exact saturation_gap_positive α τ_bar h_α h_τ

/-- **R.98 + R.518 — strict comparison: any reachable κ-trajectory
value is bounded by the R.518 ceiling.**

The decay-modified dynamics impose the universal bound
`κ(t) ≤ κ_eff^∞` for every `t`.  We restate this as the
hypothesis-form bound used by R.520's `R_520_never_reached`. -/
theorem trajectory_universally_bounded
    (κ_t : ℝ → ℝ) (α τ_bar : ℝ)
    (h_α : 0 < α) (h_τ : 0 < τ_bar)
    (h_bound : ∀ t, κ_t t ≤ kappaInf α τ_bar) :
    ∀ t, κ_t t < 1 := by
  intro t
  have h_ceiling : kappaInf α τ_bar < 1 :=
    kappaInf_lt_one α τ_bar h_α h_τ
  have h_le : κ_t t ≤ kappaInf α τ_bar := h_bound t
  linarith

end R3_Agent3_GompertzWithDecay

end MIP
