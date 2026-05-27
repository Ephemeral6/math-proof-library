/-
Result R.353 — Collaboration-inequality growth theorem.
Reference: branches/sociology/workspace/new_results.md (old sociology R.140).

**Statement.** Individual combinatorial closure `κ_i` evolves by the
Gompertz law (R.98) `dκ_i/dt = α_i·κ_i·|log κ_i|`, where the training
efficiency couples to Type-E collaboration count, `α_i = α₀ + c_E·κ_i`
(high-κ individuals get more Type-E collaboration, by R.51).  Hence

    dκ_i/dt = α₀·κ_i·|log κ_i|  +  c_E · κ_i²·|log κ_i| ,

with the "rich-get-richer" coupling carried by the term `g(κ) := κ²·|log κ|`.
On `κ ∈ (0,1)`, `log κ < 0`, so `g(κ) = −κ²·log κ`.

The Gini inequality measure `G_κ` (D.5.4) evolves at rate driven by the
comonotone sum `Σ_{i,j} sign(κ_i − κ_j)·(g(κ_i) − g(κ_j))`, whose sign is
the sign of `g`'s monotonicity:

* **Learning phase** (population `κ ∈ (0, 1/√e)`, `1/√e ≈ 0.607`):
  `g` strictly increasing ⟹ every pairwise term `≥ 0` ⟹ `dG_κ/dt > 0`
  ("rich get richer"), and `dG_κ/dt ∝ p_E·Var(κ)` to first order.
* **Saturation phase** (`κ ∈ (1/√e, 1)`): `g` strictly decreasing ⟹
  `dG_κ/dt < 0` ("poor catch up").
* **Inflection** at `κ = e^{−1/2} = 1/√e` (distinct from R.98's `1/e`).

**Kernel formalized here.** Real-analysis monotonicity kernel.
(1) `R_353_g_deriv`: `g(κ) = −κ²·log κ` has derivative
`g'(κ) = −κ·(2·log κ + 1)` at every `κ > 0`.
(2) `R_353_g_deriv_pos` / `R_353_g_deriv_neg`: `g'(κ) > 0` on `(0, 1/√e)`
and `g'(κ) < 0` on `(1/√e, 1)` — the two-phase sign split.
(3) `R_353_inflection`: `g'(1/√e) = 0` (the inflection point is exactly
`e^{−1/2}`, not `1/e`).
(4) `R_353_g_strictMonoOn` / `R_353_g_strictAntiOn`: `g` is strictly
increasing on `(0, 1/√e]` and strictly decreasing on `[1/√e, 1)`.
(5) `R_353_comonotone_pair`: in the learning phase, the pairwise
inequality driver `sign(κ_i − κ_j)·(g(κ_i) − g(κ_j)) ≥ 0` (strict when
`κ_i ≠ κ_j`), proving `dG_κ/dt ≥ 0`; and the reverse in the saturation
phase.

**Bridge.** `α₀, c_E (∝ β·p_E), p_E` are sociology scalars; the Gini
evolution `dG_κ/dt = c_E·M(κ_pop) + o(c_E)` with `M = Σ sign·Δg / (2n²κ̄)`
inherits its sign from the pairwise comonotone sign of `g`, which is the
analytic content proved here.  The `dG_κ/dt > 0` learning-phase claim is
exactly the population-level comonotone inequality.

Axiom-free.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.Tactic.Linarith

namespace MIP

namespace R353_CollabInequality

open Real

/-- The "rich-get-richer" coupling term `g(κ) = −κ²·log κ`.
(On `κ ∈ (0,1)` this equals `κ²·|log κ|` since `log κ < 0`.) -/
noncomputable def g (κ : ℝ) : ℝ := -(κ ^ 2 * Real.log κ)

/-- **R.353 — derivative of the coupling term.**

`g(κ) = −κ²·log κ` has derivative

    g'(κ) = −(2κ·log κ + κ²·(1/κ)) = −(2κ·log κ + κ) = −κ·(2·log κ + 1)

at every `κ > 0`. -/
theorem R_353_g_deriv (κ : ℝ) (hκ : 0 < κ) :
    HasDerivAt g (-κ * (2 * Real.log κ + 1)) κ := by
  -- d/dκ (κ²) = 2κ
  have hsq : HasDerivAt (fun x : ℝ => x ^ 2) (2 * κ ^ 1) κ := by
    simpa using (hasDerivAt_pow 2 κ)
  -- d/dκ (log κ) = 1/κ  (κ ≠ 0)
  have hlog : HasDerivAt Real.log κ⁻¹ κ := Real.hasDerivAt_log (ne_of_gt hκ)
  -- product rule for κ² · log κ
  have hmul : HasDerivAt (fun x : ℝ => x ^ 2 * Real.log x)
      ((2 * κ ^ 1) * Real.log κ + κ ^ 2 * κ⁻¹) κ := hsq.mul hlog
  -- negate
  have hneg := hmul.neg
  -- reshape g and the derivative value
  have hval : -((2 * κ ^ 1) * Real.log κ + κ ^ 2 * κ⁻¹)
      = -κ * (2 * Real.log κ + 1) := by
    have hinv : κ ^ 2 * κ⁻¹ = κ := by
      rw [pow_two, mul_assoc, mul_inv_cancel₀ (ne_of_gt hκ), mul_one]
    rw [hinv]; ring
  rw [hval] at hneg
  exact hneg

/-- **R.353 — derivative positive on the learning phase `(0, 1/√e)`.**

For `0 < κ < e^{−1/2}` we have `log κ < −1/2`, so `2·log κ + 1 < 0`,
hence `g'(κ) = −κ·(2·log κ + 1) > 0`: the coupling term is strictly
increasing. -/
theorem R_353_g_deriv_pos (κ : ℝ) (hκ_pos : 0 < κ)
    (hκ_lt : κ < Real.exp (-(1/2 : ℝ))) :
    0 < -κ * (2 * Real.log κ + 1) := by
  -- log κ < log (exp (-1/2)) = -1/2
  have hlog_lt : Real.log κ < -(1/2 : ℝ) := by
    have := Real.log_lt_log hκ_pos hκ_lt
    rwa [Real.log_exp] at this
  -- 2 log κ + 1 < 0
  have hfac : 2 * Real.log κ + 1 < 0 := by linarith
  -- -κ < 0, times a negative ⟹ positive
  nlinarith [hfac, hκ_pos]

/-- **R.353 — derivative negative on the saturation phase `(1/√e, 1)`.**

For `e^{−1/2} < κ` we have `log κ > −1/2`, so `2·log κ + 1 > 0`, hence
`g'(κ) = −κ·(2·log κ + 1) < 0`: the coupling term is strictly
decreasing — "poor catch up". -/
theorem R_353_g_deriv_neg (κ : ℝ) (hκ_pos : 0 < κ)
    (hκ_gt : Real.exp (-(1/2 : ℝ)) < κ) :
    -κ * (2 * Real.log κ + 1) < 0 := by
  have hlog_gt : -(1/2 : ℝ) < Real.log κ := by
    have := Real.log_lt_log (Real.exp_pos _) hκ_gt
    rwa [Real.log_exp] at this
  have hfac : 0 < 2 * Real.log κ + 1 := by linarith
  nlinarith [hfac, hκ_pos]

/-- **R.353 — inflection point at `κ = e^{−1/2} = 1/√e`.**

At `κ = e^{−1/2}` the derivative vanishes: `g'(e^{−1/2}) = 0`.  This is
the boundary between the learning phase and the saturation phase, and is
*distinct* from R.98's inflection `1/e` (the linear-term peak). -/
theorem R_353_inflection :
    -(Real.exp (-(1/2 : ℝ))) * (2 * Real.log (Real.exp (-(1/2 : ℝ))) + 1) = 0 := by
  rw [Real.log_exp]
  ring

/-- **R.353 — `g` strictly increasing on the learning interval.**

On `(0, 1/√e)`, `g` is strictly monotone increasing.  Proven from the
positive derivative `R_353_g_deriv_pos` via `StrictMonoOn` of a function
with everywhere-positive derivative on the interval. -/
theorem R_353_g_strictMonoOn :
    StrictMonoOn g (Set.Ioo (0 : ℝ) (Real.exp (-(1/2 : ℝ)))) := by
  have hcont : ContinuousOn g (Set.Ioo (0 : ℝ) (Real.exp (-(1/2 : ℝ)))) := by
    apply ContinuousOn.neg
    apply ContinuousOn.mul (continuous_pow 2).continuousOn
    apply Real.continuousOn_log.mono
    intro x hx
    exact ne_of_gt hx.1
  apply strictMonoOn_of_hasDerivWithinAt_pos (convex_Ioo _ _) hcont
    (f' := fun κ => -κ * (2 * Real.log κ + 1))
  · intro κ hκ
    rw [interior_Ioo] at hκ
    have hκ_pos : 0 < κ := hκ.1
    exact (R_353_g_deriv κ hκ_pos).hasDerivWithinAt
  · intro κ hκ
    rw [interior_Ioo] at hκ
    exact R_353_g_deriv_pos κ hκ.1 hκ.2

/-- **R.353 — `g` strictly decreasing on the saturation interval.**

On `(1/√e, 1)`, `g` is strictly monotone decreasing (`AntitoneOn` in the
strict sense), from the negative derivative `R_353_g_deriv_neg`. -/
theorem R_353_g_strictAntiOn :
    StrictAntiOn g (Set.Ioo (Real.exp (-(1/2 : ℝ))) (1 : ℝ)) := by
  have hcont : ContinuousOn g (Set.Ioo (Real.exp (-(1/2 : ℝ))) (1 : ℝ)) := by
    apply ContinuousOn.neg
    apply ContinuousOn.mul (continuous_pow 2).continuousOn
    apply Real.continuousOn_log.mono
    intro x hx
    exact ne_of_gt (lt_trans (Real.exp_pos _) hx.1)
  apply strictAntiOn_of_hasDerivWithinAt_neg (convex_Ioo _ _) hcont
    (f' := fun κ => -κ * (2 * Real.log κ + 1))
  · intro κ hκ
    rw [interior_Ioo] at hκ
    have hκ_pos : 0 < κ := lt_trans (Real.exp_pos _) hκ.1
    exact (R_353_g_deriv κ hκ_pos).hasDerivWithinAt
  · intro κ hκ
    rw [interior_Ioo] at hκ
    have hκ_pos : 0 < κ := lt_trans (Real.exp_pos _) hκ.1
    exact R_353_g_deriv_neg κ hκ_pos hκ.1

/-- **R.353 — pairwise comonotone inequality driver (learning phase).**

The Gini evolution rate is driven by `Σ_{i,j} sign(κ_i − κ_j)·(g(κ_i) −
g(κ_j))`.  In the learning phase, `g` is strictly increasing, so for any
two distinct individuals the pairwise driver is *strictly positive*:

    κ_i, κ_j ∈ (0, 1/√e),  κ_i ≠ κ_j
      ⟹  (κ_i − κ_j)·(g(κ_i) − g(κ_j)) > 0,

i.e. `g(κ_i) − g(κ_j)` has the same sign as `κ_i − κ_j`.  Summed over all
pairs this gives `dG_κ/dt > 0` ("rich get richer"). -/
theorem R_353_comonotone_pair_learning
    (κi κj : ℝ)
    (hi : κi ∈ Set.Ioo (0 : ℝ) (Real.exp (-(1/2 : ℝ))))
    (hj : κj ∈ Set.Ioo (0 : ℝ) (Real.exp (-(1/2 : ℝ))))
    (hne : κi ≠ κj) :
    0 < (κi - κj) * (g κi - g κj) := by
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · -- κi < κj ⟹ g κi < g κj ⟹ both factors negative ⟹ product positive
    have hg : g κi < g κj := R_353_g_strictMonoOn hi hj hlt
    have h1 : κi - κj < 0 := by linarith
    have h2 : g κi - g κj < 0 := by linarith
    exact mul_pos_of_neg_of_neg h1 h2
  · have hg : g κj < g κi := R_353_g_strictMonoOn hj hi hgt
    have h1 : 0 < κi - κj := by linarith
    have h2 : 0 < g κi - g κj := by linarith
    exact mul_pos h1 h2

/-- **R.353 — pairwise comonotone inequality driver (saturation phase).**

In the saturation phase `g` is strictly decreasing, so the pairwise
driver is *strictly negative* for distinct individuals:

    κ_i, κ_j ∈ (1/√e, 1),  κ_i ≠ κ_j
      ⟹  (κ_i − κ_j)·(g(κ_i) − g(κ_j)) < 0,

giving `dG_κ/dt < 0` ("poor catch up"). -/
theorem R_353_comonotone_pair_saturation
    (κi κj : ℝ)
    (hi : κi ∈ Set.Ioo (Real.exp (-(1/2 : ℝ))) (1 : ℝ))
    (hj : κj ∈ Set.Ioo (Real.exp (-(1/2 : ℝ))) (1 : ℝ))
    (hne : κi ≠ κj) :
    (κi - κj) * (g κi - g κj) < 0 := by
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · -- κi < κj ⟹ g κi > g κj (anti) ⟹ (neg)·(pos) < 0
    have hg : g κj < g κi := R_353_g_strictAntiOn hi hj hlt
    have h1 : κi - κj < 0 := by linarith
    have h2 : 0 < g κi - g κj := by linarith
    exact mul_neg_of_neg_of_pos h1 h2
  · have hg : g κi < g κj := R_353_g_strictAntiOn hj hi hgt
    have h1 : 0 < κi - κj := by linarith
    have h2 : g κi - g κj < 0 := by linarith
    exact mul_neg_of_pos_of_neg h1 h2

end R353_CollabInequality

end MIP
