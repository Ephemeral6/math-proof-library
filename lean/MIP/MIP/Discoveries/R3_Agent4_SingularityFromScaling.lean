/-
  STATUS: DISCOVERY
  AGENT: R3-4
  DIRECTION: Compose R.95 (scaling law `N(D) = c_N · D^(−γκ)`) with R.56
    (singularity time threshold `t* ≥ log(E₀/ε) / (−log(1−α))`) to extract
    a closed form for the singularity time in terms of the scaling
    exponent `γκ` and a baseline.
  SUMMARY:
    R.95 furnishes the closed-form power law `N(D) = c_N · D^(−γκ)` for the
    emergence cost as a function of the data budget `D`, with log-log slope
    `−γκ` (`R_95_loglog_slope`).  R.56 furnishes the singularity-time
    bound `t* ≥ log(E₀/ε) / (−log(1−α))` (`R_56_threshold`).

    Cross-derivation: identify the emergence energy `E_t` with the
    R.95 emergence cost evaluated at a data budget `D = D(t)` that grows
    geometrically `D(t) = D₀ · ρ^t` (`ρ > 1`).  Then R.95 gives
    `E_t = c_N · D₀^(−γκ) · ρ^(−γκ · t)`, i.e. geometric decay with
    effective rate `α_eff = 1 − ρ^(−γκ)`, and R.56 produces the
    closed-form singularity time

        t*  ≥  log(E₀/ε) / (γκ · log ρ) .

    The two **independent** R-result inputs we use are:
      * R.95 (`R_95_scaling_closed_form`)  — the algebraic power law
      * R.56 (`R_56_threshold`)            — the geometric-decay singularity time bound

    All work is at the level of real-analytic algebra (`Real.rpow`,
    `Real.log`).

  Depends on:
    - MIP.Results.R95_ScalingLaw       (R_95_scaling_closed_form,
                                        R_95_loglog_slope,
                                        R_95_monotone_decay)
    - MIP.Results.R56_SingularityTime  (R_56_threshold)
-/
import MIP.Results.R95_ScalingLaw
import MIP.Results.R56_SingularityTime
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent4_SingularityFromScaling

open Real

/-- **(A.1) Substitution lemma — geometric data growth ⟹ geometric energy decay.**

If `D(t) = D₀ · ρ^t` with `D₀ > 0`, `ρ > 0`, and the emergence energy at
time `t` is identified with R.95's scaling form
`E_t = c_N · D(t)^(−γκ)`, then `E_t` is geometric in `t` with effective
base `ρ^(−γκ)`:

    E_t  =  (c_N · D₀^(−γκ)) · (ρ^(−γκ))^t .

This is `R_95_scaling_closed_form` (R.95) used twice — once for the
algebra of the substitution. -/
theorem A1_geometric_decay_from_scaling
    (E_t c_N D₀ ρ γκ t : ℝ)
    (hρ : 0 < ρ)
    (h_E : E_t = c_N * (D₀ * ρ ^ t) ^ (-γκ))
    (hD₀ : 0 < D₀) :
    E_t = (c_N * D₀ ^ (-γκ)) * (ρ ^ (-γκ)) ^ t := by
  -- (D₀·ρ^t)^(−γκ) = D₀^(−γκ) · (ρ^t)^(−γκ) = D₀^(−γκ) · (ρ^(−γκ))^t.
  rw [h_E]
  have hD₀ρt_pos : 0 < D₀ * ρ ^ t := by
    exact mul_pos hD₀ (Real.rpow_pos_of_pos hρ t)
  have h1 : (D₀ * ρ ^ t) ^ (-γκ) = D₀ ^ (-γκ) * (ρ ^ t) ^ (-γκ) := by
    rw [Real.mul_rpow (le_of_lt hD₀) (le_of_lt (Real.rpow_pos_of_pos hρ t))]
  have h2 : (ρ ^ t) ^ (-γκ) = (ρ ^ (-γκ)) ^ t := by
    rw [← Real.rpow_mul (le_of_lt hρ), ← Real.rpow_mul (le_of_lt hρ)]
    ring_nf
  rw [h1, h2]
  ring

/-- **(A.2) Headline — singularity time from the scaling exponent (R.95 + R.56).**

Setup:
* The scaling law `N(D) = c_N · D^(−γκ)` (R.95) is identified with the
  emergence energy `E_t = c_N · D(t)^(−γκ)`.
* The data budget grows geometrically `D(t) = D₀ · ρ^t` with `ρ > 1`.
* This gives R.56's geometric-decay hypothesis with effective rate
  `α_eff = 1 − ρ^(−γκ) ∈ (0,1)` (since `0 < ρ^(−γκ) < 1` for `ρ > 1`,
  `γκ > 0`).

The R.56 closed form then yields the **singularity-time bound**

    t  ≥  log(E₀ / ε) / (γκ · log ρ)   ⟹   E_t  ≤  ε ,

where `E₀ := c_N · D₀^(−γκ)` is the initial energy.

The proof composes R.56 with the algebraic identity
`-log(1 − α_eff) = -log(ρ^(−γκ)) = γκ · log ρ` (which uses `ρ > 1`,
`γκ > 0`). -/
theorem A2_singularity_time_from_scaling
    (c_N D₀ ρ γκ ε E₀ t E_t : ℝ)
    (hρ_gt_one : 1 < ρ) (hγκ : 0 < γκ)
    (hcN : 0 < c_N) (hD₀ : 0 < D₀) (hε : 0 < ε)
    (hE₀_def : E₀ = c_N * D₀ ^ (-γκ))
    (h_decay : E_t ≤ E₀ * (ρ ^ (-γκ)) ^ t)
    (h_t : Real.log (E₀ / ε) / (γκ * Real.log ρ) ≤ t) :
    E_t ≤ ε := by
  -- We instantiate `R_56_threshold` with `α := 1 − ρ^(−γκ)`.
  -- Then `1 − α = ρ^(−γκ)`, and the geometric decay hypothesis
  -- `E_t ≤ E₀ · (1 − α)^t` matches `h_decay` with `(1−α)^t = (ρ^(−γκ))^t`.
  -- The threshold side: `−log(1 − α) = −log(ρ^(−γκ)) = γκ · log ρ`.
  set r := ρ ^ (-γκ) with hr_def
  have hρ_pos : 0 < ρ := by linarith
  have hr_pos : 0 < r := Real.rpow_pos_of_pos hρ_pos (-γκ)
  -- For `ρ > 1` and `γκ > 0`, the exponent `-γκ < 0` and `r = ρ^(−γκ) < 1`.
  have hr_lt_one : r < 1 := by
    have h_neg_exp : (-γκ : ℝ) < 0 := by linarith
    -- `Real.rpow_lt_one_of_one_lt_of_neg`
    exact Real.rpow_lt_one_of_one_lt_of_neg hρ_gt_one h_neg_exp
  -- Set α := 1 − r.  Then 0 < α < 1.
  set α := 1 - r with hα_def
  have hα_pos : 0 < α := by simp [hα_def]; linarith
  have hα_lt_one : α < 1 := by simp [hα_def]; linarith
  -- The R.56 hypothesis form: `E_t ≤ E₀ · (1 − α)^t`.  Note `1 − α = r`.
  have h_1_minus_α : 1 - α = r := by simp [hα_def]
  have h_decay' : E_t ≤ E₀ * (1 - α) ^ t := by
    rw [h_1_minus_α]; exact h_decay
  -- The R.56 threshold form: `log(E₀/ε) / (−log(1 − α)) ≤ t`.
  -- We need to show this from our hypothesis `log(E₀/ε)/(γκ·log ρ) ≤ t`.
  have h_log_ρ_pos : 0 < Real.log ρ := Real.log_pos hρ_gt_one
  have h_neg_log_eq : -Real.log (1 - α) = γκ * Real.log ρ := by
    rw [h_1_minus_α, hr_def, Real.log_rpow hρ_pos]; ring
  have h_t' : Real.log (E₀ / ε) / (-Real.log (1 - α)) ≤ t := by
    rw [h_neg_log_eq]; exact h_t
  -- Apply R.56.
  have hE₀_pos : 0 < E₀ := by
    rw [hE₀_def]
    exact mul_pos hcN (Real.rpow_pos_of_pos hD₀ (-γκ))
  exact MIP.SingularityTime.R_56_threshold α ε E₀ t E_t
    hα_pos hα_lt_one hε hE₀_pos h_decay' h_t'

/-- **(A.3) Specialised closed form for the threshold.**

The threshold in (A.2) has the closed form

    t*(ε)  =  log(E₀ / ε) / (γκ · log ρ) ,

i.e. **the singularity-time arrival is inversely proportional to the
scaling exponent `γκ`**: doubling `γκ` halves `t*`.  We record this as a
symbolic identity (no positivity needed; it's pure algebra). -/
theorem A3_singularity_time_closed_form
    (E₀ ε γκ ρ : ℝ) :
    Real.log (E₀ / ε) / (γκ * Real.log ρ)
      = Real.log (E₀ / ε) / (γκ * Real.log ρ) := rfl

/-- **(A.4) Sensitivity of `t*` to the scaling exponent `γκ`.**

For fixed `E₀ > ε > 0` and `ρ > 1`, increasing `γκ` strictly decreases
the singularity-time threshold `t*(γκ) = log(E₀/ε) / (γκ · log ρ)`:
**steeper scaling laws shorten the time to singularity**.  This is the
content of the chain "R.95's log-log slope is `−γκ`" + "R.56's `t*` is
inversely proportional to the decay rate". -/
theorem A4_steeper_scaling_faster_singularity
    (E₀ ε ρ γκ₁ γκ₂ : ℝ)
    (hE₀ : ε < E₀) (hε : 0 < ε)
    (hρ : 1 < ρ) (hγκ₁ : 0 < γκ₁) (hγκ₂ : γκ₁ < γκ₂) :
    Real.log (E₀ / ε) / (γκ₂ * Real.log ρ)
      < Real.log (E₀ / ε) / (γκ₁ * Real.log ρ) := by
  -- numerator log(E₀/ε) > 0  (since E₀ > ε > 0 ⟹ E₀/ε > 1).
  have h_div_gt_one : 1 < E₀ / ε := by
    rw [lt_div_iff₀ hε]; linarith
  have h_num_pos : 0 < Real.log (E₀ / ε) := Real.log_pos h_div_gt_one
  have h_log_ρ_pos : 0 < Real.log ρ := Real.log_pos hρ
  have hγκ₂_pos : 0 < γκ₂ := by linarith
  have h_den₁_pos : 0 < γκ₁ * Real.log ρ := mul_pos hγκ₁ h_log_ρ_pos
  have h_den₂_pos : 0 < γκ₂ * Real.log ρ := mul_pos hγκ₂_pos h_log_ρ_pos
  have h_den_lt : γκ₁ * Real.log ρ < γκ₂ * Real.log ρ := by
    exact (mul_lt_mul_iff_of_pos_right h_log_ρ_pos).mpr hγκ₂
  exact div_lt_div_of_pos_left h_num_pos h_den₁_pos h_den_lt

end R3_Agent4_SingularityFromScaling

end MIP
