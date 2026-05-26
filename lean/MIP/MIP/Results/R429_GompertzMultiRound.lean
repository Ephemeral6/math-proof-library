/-
Result R.429 — Multi-round CoE Gompertz S-curve and peak-benefit round.

Reference: `workspace/coe_mip_unification.md` §R.429
(A conditional, Block 9 "理论融合", 2026-05-16).
Reuses the continuous Gompertz closed form of R.98 (T.23).

**Statement.** Transferring the κ-Gompertz dynamics (R.118 / R.98) to a
multi-round CoE dialogue (turn `t ∈ ℕ`, one R+T+C injection per round):

(i) **Discrete Gompertz recurrence.**  With combination-closure `κ ∈ (0,1)`,
    rate `α > 0`, the per-round update

        κ_{t+1} = κ_t + α · κ_t · |log κ_t|

    is *strictly increasing* (`κ_{t+1} > κ_t`) and *stays positive*, so the
    closure monotonically climbs toward the ceiling `1`.  (`|log κ| = −log κ`
    on `(0,1)`.)

(ii) **Peak-benefit round `t*`.**  The single-round drop `|ΔN_t|` is maximal at
     the Gompertz inflection `κ(t*) = 1/e`.  Using the continuous closed form
     `κ(t) = exp( log κ₀ · exp(−α(t − t_cov)) )` of R.98, the defining threshold
     equation `κ(t*) = 1/e` is equivalent to the closed-form peak time

        t* = t_cov + (log |log κ₀|) / α .

**Proof.** (i) is sign analysis on `(0,1)`: `−log κ > 0`, `α > 0`, `κ > 0` give
the strictly positive increment and preserved positivity. (ii) is `Real.log` /
`Real.exp` algebra: take `log` of `κ(t*) = 1/e` (so `log κ(t*) = −1`), cancel
the outer `exp`, solve the resulting affine equation for `t*`.

**This file is `axiom`-free.**  The MIP premises (R.118 Z slow-varying, R.045
weak Ohm) enter only through the explicit recurrence and the closed form of κ.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace GompertzMultiRound

open Real

/-- One discrete-Gompertz round: `κ ↦ κ + α·κ·|log κ|`.  On `κ ∈ (0,1)` we have
`|log κ| = −log κ`, so the update is `κ + α·κ·(−log κ)`. -/
noncomputable def step (α κ : ℝ) : ℝ := κ + α * κ * (- Real.log κ)

/-- **R.429 (i.a) — the discrete recurrence is strictly increasing.**

For `κ ∈ (0,1)` and `α > 0`, `step α κ > κ`: each round strictly raises the
closure.  Because `log κ < 0` on `(0,1)`, the increment `α·κ·(−log κ)` is a
product of three positive numbers. -/
theorem R_429_i_strict_increase
    (α κ : ℝ) (hα : 0 < α) (hκ0 : 0 < κ) (hκ1 : κ < 1) :
    κ < step α κ := by
  unfold step
  have hlog : Real.log κ < 0 := Real.log_neg hκ0 hκ1
  have hneglog : 0 < - Real.log κ := by linarith
  have hpos : 0 < α * κ * (- Real.log κ) :=
    mul_pos (mul_pos hα hκ0) hneglog
  linarith

/-- **R.429 (i.b) — positivity is preserved by the recurrence.**

If `κ ∈ (0,1)` then `step α κ > 0` (in fact `> κ > 0`): the closure never
leaves the positive region while climbing toward `1`. -/
theorem R_429_i_pos_preserved
    (α κ : ℝ) (hα : 0 < α) (hκ0 : 0 < κ) (hκ1 : κ < 1) :
    0 < step α κ :=
  lt_trans hκ0 (R_429_i_strict_increase α κ hα hκ0 hκ1)

/-- **R.429 (i.c) — monotone climb toward the ceiling: the gap to `1` shrinks
in the sense `1 − step α κ < 1 − κ`.**

Equivalently the distance to the saturation ceiling `1` strictly decreases each
round (the increment is positive).  This is the discrete S-curve climbing
toward `1`. -/
theorem R_429_i_gap_shrinks
    (α κ : ℝ) (hα : 0 < α) (hκ0 : 0 < κ) (hκ1 : κ < 1) :
    (1 : ℝ) - step α κ < 1 - κ := by
  have := R_429_i_strict_increase α κ hα hκ0 hκ1
  linarith

/-- The continuous Gompertz closed form (R.98 form):
`κ(t) = exp( log κ₀ · exp(−α·(t − t_cov)) )`. -/
noncomputable def kappa (κ₀ α t_cov t : ℝ) : ℝ :=
  Real.exp (Real.log κ₀ * Real.exp (-α * (t - t_cov)))

/-- **R.429 (ii) — peak-benefit-round closed form `t*`.**

`κ(t)` is at the Gompertz inflection `1/e` precisely at

    t* = t_cov + (log |log κ₀|) / α ,

assuming `α > 0` and `κ₀ ∈ (0,1)` (so `log κ₀ < 0`, hence `|log κ₀| > 0`).

We prove the forward direction used in §R.429(iii): plugging `t*` into the
closed form gives `κ(t*) = 1/e` (equivalently `log κ(t*) = −1`).  This is the
defining threshold equation `κ(t*) = 1/e` solved in closed form. -/
theorem R_429_ii_peak_time
    (κ₀ α t_cov : ℝ) (hα : 0 < α) (hκ0 : 0 < κ₀) (hκ1 : κ₀ < 1) :
    kappa κ₀ α t_cov (t_cov + (Real.log (|Real.log κ₀|)) / α)
      = Real.exp (-1) := by
  unfold kappa
  -- log κ₀ < 0, so |log κ₀| = − log κ₀ and |log κ₀| > 0.
  have hlog_neg : Real.log κ₀ < 0 := Real.log_neg hκ0 hκ1
  have habs : |Real.log κ₀| = - Real.log κ₀ := abs_of_neg hlog_neg
  have habs_pos : 0 < |Real.log κ₀| := by rw [habs]; linarith
  -- The inner exponent argument −α·((t_cov + L/α) − t_cov) = −L,
  -- where L = log |log κ₀|.
  have hαne : α ≠ 0 := ne_of_gt hα
  have harg : -α * ((t_cov + (Real.log (|Real.log κ₀|)) / α) - t_cov)
      = - Real.log (|Real.log κ₀|) := by
    field_simp
    ring
  rw [harg]
  -- exp(−log|log κ₀|) = 1/|log κ₀|  =  −1/log κ₀ .
  rw [Real.exp_neg, Real.exp_log habs_pos]
  -- Now goal: exp( log κ₀ · (|log κ₀|)⁻¹ ) = exp(−1).
  rw [habs]
  -- log κ₀ · (− log κ₀)⁻¹ = −1  since log κ₀ ≠ 0.
  have hlne : Real.log κ₀ ≠ 0 := ne_of_lt hlog_neg
  have : Real.log κ₀ * (- Real.log κ₀)⁻¹ = -1 := by
    field_simp
  rw [this]

/-- **R.429 (ii') — peak-time identity in `log κ` form.**

Equivalent crisp statement: at `t* = t_cov + log|log κ₀|/α`, the *log* of the
closure equals `−1`, i.e. `log κ(t*) = −1`, which is exactly the Gompertz
inflection `κ(t*) = e⁻¹ = 1/e`. -/
theorem R_429_ii_peak_logkappa
    (κ₀ α t_cov : ℝ) (hα : 0 < α) (hκ0 : 0 < κ₀) (hκ1 : κ₀ < 1) :
    Real.log (kappa κ₀ α t_cov (t_cov + (Real.log (|Real.log κ₀|)) / α)) = -1 := by
  rw [R_429_ii_peak_time κ₀ α t_cov hα hκ0 hκ1, Real.log_exp]

end GompertzMultiRound

end MIP
