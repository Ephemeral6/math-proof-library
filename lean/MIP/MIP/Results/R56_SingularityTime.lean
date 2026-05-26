/-
Result R.56 — Cognitive-singularity arrival time `t* = O(log(E₀/ε)/α)`.

Reference: `proofs/derived/A_grade.md` R.56 (A 条件, deps T.5, D.4.3, Cj.3 = 0).

**Statement.** Under the conditional assumption `E* = lim_{t→∞} E_t = 0`
(Cj.3 positive case), the emergence energy decays geometrically (T.5)

    E_t ≤ E₀ · (1 − α)^t ,                       (0 < 1 − α < 1)

and the "approximate singularity" `E_t ≤ ε` is first reached at time

    t* ≥ log(E₀/ε) / log(1/(1−α)) = log(E₀/ε) / (−log(1 − α)) ,

so that `t* = O(log(E₀/ε)/α)` (small-α approximation `log(1/(1−α)) ≈ α`).

**Pure-math kernel.**  Two layers, both furnished here:

* `R_56_threshold` — the real-analysis statement: with `0 < α`, `α < 1`,
  `0 < ε`, `0 < E₀`, and the decay law `E_t ≤ E₀ · (1 − α)^t` (rpow), any time
  `t ≥ log(E₀/ε) / (−log(1 − α))` forces `E_t ≤ ε`.  Proof: turn the
  exponential bound into a log inequality via `rpow_le_iff_le_log`, then use
  that `log(1 − α) < 0` flips the threshold inequality.

* `R_56_discrete_decay` — the simpler discrete monotone-decay bound
  `E_t ≤ E₀ · (1 − α)^t` for `t : ℕ`, kept as the unconditional skeleton
  (the RHS `→ 0`, so `E_t` is eventually `≤ ε`).

It is fine to take the decay law as a hypothesis (it is T.5).  This file
encodes the algebraic/analytic content only.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

namespace SingularityTime

open Real

/-- **R.56 — singularity-time threshold (real-analysis core).**

Let the emergence energy obey the T.5 geometric decay law
`E_t ≤ E₀ · (1 − α)^t` (real exponent `t`), with effective decay rate
`0 < α < 1`, target tolerance `0 < ε`, and initial energy `0 < E₀`.  Then for
every time

    t ≥ log(E₀/ε) / (−log(1 − α))

the approximate-singularity condition `E_t ≤ ε` holds. -/
theorem R_56_threshold
    (α ε E₀ t E_t : ℝ)
    (hα_pos : 0 < α) (hα_lt_one : α < 1)
    (hε : 0 < ε) (hE₀ : 0 < E₀)
    (h_decay : E_t ≤ E₀ * (1 - α) ^ t)
    (h_t : log (E₀ / ε) / (-log (1 - α)) ≤ t) :
    E_t ≤ ε := by
  -- Base `r := 1 − α` lies strictly in (0, 1), so `log r < 0`.
  have hr_pos : 0 < 1 - α := by linarith
  have hr_lt_one : 1 - α < 1 := by linarith
  have h_logr_neg : log (1 - α) < 0 := Real.log_neg hr_pos hr_lt_one
  -- Step 1: it suffices to show `(1 − α)^t ≤ ε / E₀`, since then
  -- `E₀ · (1 − α)^t ≤ E₀ · (ε / E₀) = ε`.
  have h_div_pos : 0 < ε / E₀ := div_pos hε hE₀
  -- `rpow_le_iff_le_log`: `(1−α)^t ≤ ε/E₀ ↔ t · log(1−α) ≤ log(ε/E₀)`.
  -- Step 2: prove the log inequality `t · log(1−α) ≤ log(ε/E₀)`.
  -- We have `log(ε/E₀) = − log(E₀/ε)` and the threshold gives, after
  -- multiplying by the negative number `log(1−α)`:
  --   t · log(1−α) ≤ [log(E₀/ε)/(−log(1−α))] · log(1−α) = − log(E₀/ε).
  have h_log_swap : log (ε / E₀) = - log (E₀ / ε) := by
    rw [Real.log_div (ne_of_gt hε) (ne_of_gt hE₀),
        Real.log_div (ne_of_gt hE₀) (ne_of_gt hε)]
    ring
  have h_log_ineq : t * log (1 - α) ≤ log (ε / E₀) := by
    rw [h_log_swap]
    -- From `L ≤ t` and `log(1−α) < 0`: `t · log(1−α) ≤ L · log(1−α)`.
    have h_mul : t * log (1 - α)
        ≤ (log (E₀ / ε) / (-log (1 - α))) * log (1 - α) :=
      mul_le_mul_of_nonpos_right h_t (le_of_lt h_logr_neg)
    -- And `L · log(1−α) = − log(E₀/ε)` since `log(1−α) ≠ 0`.
    have h_logr_ne : log (1 - α) ≠ 0 := ne_of_lt h_logr_neg
    have h_simp : (log (E₀ / ε) / (-log (1 - α))) * log (1 - α)
        = - log (E₀ / ε) := by
      field_simp
    linarith [h_mul, h_simp.le, h_simp.ge]
  -- Step 3: convert the log inequality back to the rpow bound.
  have h_pow_le : (1 - α) ^ t ≤ ε / E₀ :=
    (rpow_le_iff_le_log hr_pos h_div_pos).2 h_log_ineq
  -- Step 4: multiply through by `E₀ > 0` and chain with the decay law.
  have h_chain : E₀ * (1 - α) ^ t ≤ ε := by
    calc E₀ * (1 - α) ^ t ≤ E₀ * (ε / E₀) :=
          mul_le_mul_of_nonneg_left h_pow_le (le_of_lt hE₀)
      _ = ε := by field_simp
  linarith

/-- **R.56 — discrete monotone-decay skeleton.**

The unconditional layer: the T.5 geometric decay `E_t ≤ E₀ · (1 − α)^t` over
discrete time `t : ℕ`.  Here it is simply re-exposed (taking the decay law as a
hypothesis), and `(1 − α)^t` is a non-increasing, non-negative sequence whose
limit is `0` for `0 ≤ 1 − α < 1`. -/
theorem R_56_discrete_decay
    (α E₀ : ℝ) (t : ℕ) (E_t : ℝ)
    (h_decay : E_t ≤ E₀ * (1 - α) ^ t) :
    E_t ≤ E₀ * (1 - α) ^ t :=
  h_decay

/-- **R.56 — the geometric bound `(1 − α)^t ≤ 1` (so energy never exceeds E₀).**

For `0 ≤ α ≤ 1` (hence `0 ≤ 1 − α ≤ 1`) and any discrete time `t : ℕ`,
`(1 − α)^t ≤ 1`, so the decay bound gives `E_t ≤ E₀` when `0 ≤ E₀`. -/
theorem R_56_bounded_by_initial
    (α E₀ : ℝ) (t : ℕ) (E_t : ℝ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1) (hE₀ : 0 ≤ E₀)
    (h_decay : E_t ≤ E₀ * (1 - α) ^ t) :
    E_t ≤ E₀ := by
  have hr0 : 0 ≤ 1 - α := by linarith
  have hr1 : 1 - α ≤ 1 := by linarith
  have h_pow_le_one : (1 - α) ^ t ≤ 1 := pow_le_one₀ hr0 hr1
  have : E₀ * (1 - α) ^ t ≤ E₀ * 1 :=
    mul_le_mul_of_nonneg_left h_pow_le_one hE₀
  linarith

end SingularityTime

end MIP
