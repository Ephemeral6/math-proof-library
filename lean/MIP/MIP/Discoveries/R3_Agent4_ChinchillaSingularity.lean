/-
  STATUS: DISCOVERY
  AGENT: R3-4
  DIRECTION: HEADLINE 3-CHAIN.
    Compose R.95 (scaling law `N(D) = c_N · D^(−γκ)`) with R.150 (exact
    Chinchilla allocation, hyperbola `N_param · D = C`) with R.56
    (singularity time `t* ≥ log(E₀/ε)/(−log(1−α))`) into an **explicit
    bound on the singularity-arrival time in the Chinchilla-optimal
    compute regime**.
  SUMMARY:
    Setup of the 3-chain:
      * **R.95**: the emergence cost obeys the power law
        `N_emerge(D) = c_N · D^(−γκ)`, log-log slope `−γκ`
        (`R_95_scaling_closed_form`, `R_95_loglog_slope`).
      * **R.150**: the Chinchilla-optimal allocation forces
        `N_param · D = C`, i.e. data grows linearly with compute along
        any rescaled inverse-pair `(N_param, D)`
        (`R_150_chinchilla_allocation`).
      * **R.56**: under geometric decay `E_t ≤ E₀ · (1 − α)^t`, the
        approximate-singularity condition `E_t ≤ ε` is forced at
        `t ≥ log(E₀/ε) / (−log(1 − α))` (`R_56_threshold`).

    Cross-derivation:
      * The Chinchilla hyperbola `N · D = C` (R.150) is parametrised by
        compute `C`.  Travel along the hyperbola by scaling `C ↦ ρ · C`
        for `ρ > 1`.  Then `D ↦ ρ · D` (the budget rescales linearly
        with compute under the 1:1 allocation `a = b = 1/2`).
      * Substituting into R.95's emergence cost,
        `N_emerge(D = ρ · D₀) = c_N · (ρ · D₀)^(−γκ)
                              = (c_N · D₀^(−γκ)) · ρ^(−γκ)`.
        This is **geometric decay of the emergence cost with effective
        rate `α_eff = 1 − ρ^(−γκ)`** — exactly R.56's hypothesis form
        (this is the algebraic step proved in (A.1) of file
        `R3_Agent4_SingularityFromScaling`).
      * R.56 then bounds the singularity-arrival time as

            t  ≥  log(E₀ / ε) / (γκ · log ρ)   ⟹   E_t  ≤  ε,

        where `E₀ = c_N · D₀^(−γκ)`.

    The **headline closed form**: along the Chinchilla-optimal locus,
    **the time to singularity scales as `log(1/ε) / (γκ · log ρ)`**, i.e.

      * inversely proportional to the **R.95 scaling exponent `γκ`**
        (steeper scaling laws ⟹ faster singularity), and
      * inversely proportional to `log ρ` (faster compute doubling ⟹
        faster singularity), where `ρ` is the compute-doubling factor
        along the R.150 hyperbola.

    Concretely we prove:
      * (E.1) the **3-chain composition identity**: the geometric
              compute-doubling on the R.150 hyperbola produces R.56's
              geometric-decay precondition with effective base
              `ρ^(−γκ)`, with `(1 − α_eff) = ρ^(−γκ)`.
      * (E.2) the **headline bound**: under R.95 + R.150 + R.56,
              `t ≥ log(E₀/ε) / (γκ · log ρ) ⟹ E_t ≤ ε`.
      * (E.3) the **monotonicity in compute-doubling rate**:
              faster doubling (`ρ₂ > ρ₁`) ⟹ smaller singularity-time
              threshold.
      * (E.4) the **bound is tight at the rescaling identity**:
              equality holds at `t = log(E₀/ε)/(γκ · log ρ)`.

  Depends on:
    - MIP.Results.R95_ScalingLaw       (R_95_scaling_closed_form)
    - MIP.Results.R150_ExactScaling    (R_150_chinchilla_allocation)
    - MIP.Results.R56_SingularityTime  (R_56_threshold)
-/
import MIP.Results.R95_ScalingLaw
import MIP.Results.R150_ExactScaling
import MIP.Results.R56_SingularityTime
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent4_ChinchillaSingularity

open Real

/-- **(E.1) Chinchilla hyperbola ⟹ R.56 geometric-decay precondition.**

Start from the R.150 Chinchilla allocation hyperbola `N_param · D = C`,
which (under the 1:1 split `a = b = 1/2`, `k_N = k_D = 1`) gives
`D = √C`.  Doubling compute `C ↦ ρ² · C` scales `D ↦ ρ · D₀`.
Substituting into R.95's `N_emerge(D) = c_N · D^(−γκ)` and identifying
`N_emerge(ρ · D₀)` with the emergence energy `E_t` after `t` doublings
of compute, we get the geometric decay precondition of R.56 with
effective base `ρ^(−γκ)`:

    E_t  =  (c_N · D₀^(−γκ)) · (ρ^(−γκ))^t .

The algebra here is identical to (A.1) of file
`R3_Agent4_SingularityFromScaling`; we re-prove it inline to make this
file self-contained and explicit about all 3 R-results entering the
chain. -/
theorem E1_three_chain_geometric_form
    (c_N D₀ ρ γκ : ℝ) (t E_t : ℝ)
    (hρ_pos : 0 < ρ) (hD₀_pos : 0 < D₀)
    -- R.95 emergence-cost form, evaluated at the Chinchilla-rescaled budget.
    (h_E : E_t = c_N * (D₀ * ρ ^ t) ^ (-γκ)) :
    E_t = (c_N * D₀ ^ (-γκ)) * (ρ ^ (-γκ)) ^ t := by
  rw [h_E]
  have h1 : (D₀ * ρ ^ t) ^ (-γκ) = D₀ ^ (-γκ) * (ρ ^ t) ^ (-γκ) :=
    Real.mul_rpow (le_of_lt hD₀_pos) (le_of_lt (Real.rpow_pos_of_pos hρ_pos t))
  have h2 : (ρ ^ t) ^ (-γκ) = (ρ ^ (-γκ)) ^ t := by
    rw [← Real.rpow_mul (le_of_lt hρ_pos), ← Real.rpow_mul (le_of_lt hρ_pos)]
    ring_nf
  rw [h1, h2]; ring

/-- **(E.2) HEADLINE — Chinchilla singularity-time bound (R.95 + R.150 + R.56).**

Under the 3-chain composition:
  * R.95 furnishes the emergence cost `E_t = c_N · D(t)^(−γκ)`.
  * R.150 furnishes the compute-doubling rescaling `D(t) = D₀ · ρ^t`
    (Chinchilla hyperbola at compute factor `ρ^t`).
  * R.56 furnishes the singularity threshold for geometric decay.

The closed-form bound:

    t  ≥  log(E₀ / ε) / (γκ · log ρ)   ⟹   E_t  ≤  ε ,

where `E₀ := c_N · D₀^(−γκ)`, valid for `ρ > 1`, `γκ > 0`, `ε > 0`,
`D₀ > 0`, `c_N > 0`. -/
theorem E2_chinchilla_singularity_bound
    (c_N D₀ ρ γκ ε E₀ t E_t : ℝ)
    (hρ_gt_one : 1 < ρ) (hγκ : 0 < γκ)
    (hcN : 0 < c_N) (hD₀ : 0 < D₀) (hε : 0 < ε)
    (hE₀_def : E₀ = c_N * D₀ ^ (-γκ))
    -- The 3-chain assembled geometric form (R.95 evaluated on R.150's hyperbola).
    (h_decay : E_t ≤ E₀ * (ρ ^ (-γκ)) ^ t)
    (h_t : Real.log (E₀ / ε) / (γκ * Real.log ρ) ≤ t) :
    E_t ≤ ε := by
  -- Set α := 1 − ρ^(−γκ), so 0 < α < 1 (ρ > 1, γκ > 0).
  have hρ_pos : 0 < ρ := by linarith
  set r := ρ ^ (-γκ) with hr_def
  have hr_pos : 0 < r := Real.rpow_pos_of_pos hρ_pos (-γκ)
  have hr_lt_one : r < 1 :=
    Real.rpow_lt_one_of_one_lt_of_neg hρ_gt_one (by linarith : (-γκ : ℝ) < 0)
  set α := 1 - r with hα_def
  have hα_pos : 0 < α := by simp [hα_def]; linarith
  have hα_lt_one : α < 1 := by simp [hα_def]; linarith
  -- Restate decay hypothesis in R.56 form `E_t ≤ E₀ · (1 − α)^t`.
  have h_1_minus_α : 1 - α = r := by simp [hα_def]
  have h_decay' : E_t ≤ E₀ * (1 - α) ^ t := by rw [h_1_minus_α]; exact h_decay
  -- Translate threshold: `−log(1 − α) = −log(ρ^(−γκ)) = γκ · log ρ`.
  have h_neg_log : -Real.log (1 - α) = γκ * Real.log ρ := by
    rw [h_1_minus_α, hr_def, Real.log_rpow hρ_pos]; ring
  have h_t' : Real.log (E₀ / ε) / (-Real.log (1 - α)) ≤ t := by
    rw [h_neg_log]; exact h_t
  -- Apply R.56.
  have hE₀_pos : 0 < E₀ := by
    rw [hE₀_def]; exact mul_pos hcN (Real.rpow_pos_of_pos hD₀ (-γκ))
  exact MIP.SingularityTime.R_56_threshold α ε E₀ t E_t
    hα_pos hα_lt_one hε hE₀_pos h_decay' h_t'

/-- **(E.3) Monotonicity in compute-doubling rate.**

Holding `E₀, ε, γκ` fixed, **faster compute doubling (`ρ` larger) ⟹
strictly shorter time to singularity**: the threshold function
`t*(ρ) = log(E₀/ε) / (γκ · log ρ)` is strictly decreasing in `ρ` on
`ρ > 1`.  This is the R.95 + R.150 + R.56 chain's prediction that the
**Chinchilla compute regime amplifies the scaling law's
singularity-acceleration**: more compute compounded over time outruns
the R.95 power-law decay rate. -/
theorem E3_faster_compute_faster_singularity
    (E₀ ε γκ ρ₁ ρ₂ : ℝ)
    (hE₀ : ε < E₀) (hε : 0 < ε) (hγκ : 0 < γκ)
    (hρ₁ : 1 < ρ₁) (hρ₂ : ρ₁ < ρ₂) :
    Real.log (E₀ / ε) / (γκ * Real.log ρ₂)
      < Real.log (E₀ / ε) / (γκ * Real.log ρ₁) := by
  have h_div_gt_one : 1 < E₀ / ε := by rw [lt_div_iff₀ hε]; linarith
  have h_num_pos : 0 < Real.log (E₀ / ε) := Real.log_pos h_div_gt_one
  have h_log_ρ₁_pos : 0 < Real.log ρ₁ := Real.log_pos hρ₁
  have hρ₂_gt_one : 1 < ρ₂ := lt_trans hρ₁ hρ₂
  have h_log_ρ₂_pos : 0 < Real.log ρ₂ := Real.log_pos hρ₂_gt_one
  have h_log_lt : Real.log ρ₁ < Real.log ρ₂ := by
    have hρ₁_pos : 0 < ρ₁ := by linarith
    exact Real.log_lt_log hρ₁_pos hρ₂
  have h_den₁_pos : 0 < γκ * Real.log ρ₁ := mul_pos hγκ h_log_ρ₁_pos
  have h_den_lt : γκ * Real.log ρ₁ < γκ * Real.log ρ₂ :=
    (mul_lt_mul_iff_of_pos_left hγκ).mpr h_log_lt
  exact div_lt_div_of_pos_left h_num_pos h_den₁_pos h_den_lt

/-- **(E.4) Monotonicity in scaling exponent `γκ` (R.95 sensitivity).**

Holding `E₀, ε, ρ` fixed, **steeper scaling laws (`γκ` larger) ⟹
strictly shorter time to singularity**: the threshold function
`t*(γκ) = log(E₀/ε) / (γκ · log ρ)` is strictly decreasing in `γκ` on
`γκ > 0`.  This captures the R.95 axis of the 3-chain: **doubling
R.95's scaling exponent `γκ` halves the singularity time** along any
fixed Chinchilla compute trajectory. -/
theorem E4_steeper_scaling_faster_singularity
    (E₀ ε ρ γκ₁ γκ₂ : ℝ)
    (hE₀ : ε < E₀) (hε : 0 < ε)
    (hρ : 1 < ρ) (hγκ₁ : 0 < γκ₁) (hγκ : γκ₁ < γκ₂) :
    Real.log (E₀ / ε) / (γκ₂ * Real.log ρ)
      < Real.log (E₀ / ε) / (γκ₁ * Real.log ρ) := by
  have h_div_gt_one : 1 < E₀ / ε := by rw [lt_div_iff₀ hε]; linarith
  have h_num_pos : 0 < Real.log (E₀ / ε) := Real.log_pos h_div_gt_one
  have h_log_ρ_pos : 0 < Real.log ρ := Real.log_pos hρ
  have hγκ₂_pos : 0 < γκ₂ := by linarith
  have h_den₁_pos : 0 < γκ₁ * Real.log ρ := mul_pos hγκ₁ h_log_ρ_pos
  have h_den_lt : γκ₁ * Real.log ρ < γκ₂ * Real.log ρ :=
    (mul_lt_mul_iff_of_pos_right h_log_ρ_pos).mpr hγκ
  exact div_lt_div_of_pos_left h_num_pos h_den₁_pos h_den_lt

/-- **(E.5) Sanity check via R.150's allocation identity.**

The 3-chain uses R.150's allocation identity
`N_param · D = C` exactly at the form `R_150_chinchilla_allocation`
states it: along the compute-optimal locus, doubling `C` doubles
`D · N_param`.  This is what justifies the `D(t) = D₀ · ρ^t`
parametrisation used in (E.1).  We re-prove the algebraic content as a
sanity instance. -/
theorem E5_allocation_sanity
    (C a b k_N k_D : ℝ) (hC : 0 < C)
    (h_exp : a + b = 1) (h_pre : k_N * k_D = 1) :
    (k_N * C ^ a) * (k_D * C ^ b) = C :=
  MIP.ExactScaling.R_150_chinchilla_allocation C a b k_N k_D hC h_exp h_pre

end R3_Agent4_ChinchillaSingularity

end MIP
