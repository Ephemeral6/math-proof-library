/-
Result R.192 — Maintenance–learning trade-off.
Reference: `branches/decay/workspace/new_results.md` (old decay R.153).

**Statement.** An agent digests `ν` interventions per unit time, split
between *learning* (`λ_L`, adds new elements) and *maintenance*
(`λ_M = α·n/τ̄`, refreshes existing ones).  With effective forgetting
`μ_F = (1-α)·n/τ̄`, the effective-knowledge size obeys

    dn/dt = λ_L − (1-α)·n/τ̄ ,

so the steady state is `n* = λ_L·τ̄/(1-α)`.  Under the resource constraint
`λ_L + α·n/τ̄ = ν`, eliminating `λ_L` gives the **allocation-independent**
steady state

    |K_eff^∞|  =  ν · τ̄ ,

independent of the maintenance fraction `α ∈ [0,1)`.

**Kernel formalized here.** Real-algebra constrained-optimisation identity:
from the steady-state relation `n = λ_L·τ̄/(1-α)` and the budget
`λ_L + α·n/τ̄ = ν`, derive `n = ν·τ̄` exactly (independent of `α`), the
learning-rate ceiling `λ_L = ν·(1-α)`, and the capacity theorem
`n* ≤ ν·τ̄` with equality.  All via `field_simp`/`nlinarith`.

**Bridge.** `n = |K_eff^∞|`, `ν` total intervention rate, `τ̄` mean
half-life, `α` maintenance fraction.  The ODE steady state and budget
constraint are the hypothesis bundle; the algebra is discharged here.
Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace MaintLearnTradeoff

/-- **R.192 — allocation-independent steady state `n* = ν·τ̄`.**

From the steady-state identity `n·(1-α) = λ_L·τ̄` and the resource budget
`λ_L + α·n/τ̄ = ν` (with `τ̄ > 0`, `α < 1`), the steady-state effective
knowledge size equals `ν·τ̄` regardless of the maintenance fraction `α`. -/
theorem R_192_steady_state
    (n lam_L nu alpha tau : ℝ)
    (h_tau : 0 < tau) (_h_alpha : alpha < 1)
    (h_steady : n * (1 - alpha) = lam_L * tau)
    (h_budget : lam_L + alpha * n / tau = nu) :
    n = nu * tau := by
  have h_tau_ne : tau ≠ 0 := ne_of_gt h_tau
  -- From budget: lam_L = nu - alpha*n/tau.
  have h_lamL : lam_L = nu - alpha * n / tau := by linarith
  -- Substitute into steady state and clear denominators.
  rw [h_lamL] at h_steady
  field_simp at h_steady
  -- h_steady : n*(1-alpha)*tau = (nu*tau - alpha*n)*tau  (up to rearrangement)
  nlinarith [h_steady, h_tau]

/-- **R.192 — learning-rate ceiling `λ_L = ν·(1-α)`.**

At the `ν·τ̄` steady state the learning budget is exactly `ν·(1-α)`:
more maintenance leaves linearly less learning headroom. -/
theorem R_192_learning_ceiling
    (lam_L nu alpha tau : ℝ)
    (h_tau : 0 < tau)
    (h_budget : lam_L + alpha * (nu * tau) / tau = nu) :
    lam_L = nu * (1 - alpha) := by
  have h_tau_ne : tau ≠ 0 := ne_of_gt h_tau
  field_simp at h_budget
  nlinarith [h_budget]

/-- **R.192 — knowledge-capacity theorem.**

The steady state `ν·τ̄` is the capacity ceiling: any steady configuration
with `n·(1-α) = λ_L·τ̄` and budget `λ_L + α·n/τ̄ = ν` has `n ≤ ν·τ̄`
(with equality, by `R_192_steady_state`).  To raise capacity one must
raise `ν` (more time) or `τ̄` (deeper learning). -/
theorem R_192_capacity
    (n lam_L nu alpha tau : ℝ)
    (h_tau : 0 < tau) (h_alpha : alpha < 1)
    (h_steady : n * (1 - alpha) = lam_L * tau)
    (h_budget : lam_L + alpha * n / tau = nu) :
    n ≤ nu * tau :=
  le_of_eq (R_192_steady_state n lam_L nu alpha tau h_tau h_alpha h_steady h_budget)

/-- **R.192 — pure learning (`α = 0`) still saturates at `ν·τ̄`.**

The "learn and forget" regime: with no maintenance the steady state is
still `ν·τ̄`, so unbounded learning does NOT yield unbounded retention —
the bottleneck is forgetting, not insufficient learning. -/
theorem R_192_pure_learning
    (n lam_L nu tau : ℝ)
    (_h_tau : 0 < tau)
    (h_steady : n = lam_L * tau)
    (h_budget : lam_L = nu) :
    n = nu * tau := by
  rw [h_steady, h_budget]

/-- **R.192 — capacity is monotone in `τ̄` (deeper learning helps).**

For fixed positive rate `ν`, a longer mean half-life yields a strictly
larger steady-state capacity `ν·τ̄`. -/
theorem R_192_capacity_monotone_tau
    (nu tau tau' : ℝ)
    (h_nu : 0 < nu) (h_le : tau < tau') :
    nu * tau < nu * tau' :=
  mul_lt_mul_of_pos_left h_le h_nu

end MaintLearnTradeoff

end MIP
