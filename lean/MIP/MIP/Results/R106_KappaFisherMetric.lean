/-
Result R.106 — κ-dimension Fisher metric reproduces Gompertz as a natural
gradient flow; in log-coordinates the metric is constant `1/α` (Cj.17).

Reference: `workspace/frontier_attacks.md` §R.106 (攻击 #1, Cj.17).
Status: B (Gompertz → Fisher reverse derivation, κ-dimension).

**Statement.** The Fisher natural-gradient flow has the standard form
`dκ/dt = -g(κ)⁻¹ · L'(κ)`. With the working potential `L(κ) = (log κ)²/2`
(so `L'(κ) = (log κ)/κ`) and the metric component

    g_κκ(κ) = 1/(α·κ²),

the natural gradient flow reproduces the Gompertz field:

    -g(κ)⁻¹ · L'(κ) = -α·κ² · (log κ)/κ = -α·κ·log κ.

In the log-coordinate `u = log κ` the metric pulls back to a constant:

    ds² = g_κκ dκ² = dκ²/(α·κ²) = (d log κ)²/α = du²/α,

i.e. `g_uu = 1/α` is constant — `log κ` is the natural (exponential-family)
parameter, on which Gompertz becomes a plain exponential decay.

This file encodes the two algebraic kernels:

* the **natural-gradient identity** `-g⁻¹·L' = -α·κ·log κ` with
  `g = 1/(α·κ²)`, `L' = (log κ)/κ` (entered as the bundled
  derivative-of-potential premise `hL`);
* the **coordinate-change identity** for the metric coefficient: under
  `u = log κ`, the Riemannian line element `g_κκ·(dκ)²` transforms with
  the Jacobian `dκ/du = κ` to `g_uu = g_κκ·κ² = 1/α`, constant.

The "Fisher information / natural gradient" geometry enters only through
these algebraic shapes; `α > 0` and `κ > 0` (interior closure) ensure
well-posedness of the reciprocals.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace KappaFisherMetric

open Real

/-- The κ-dimension Fisher metric component `g_κκ(κ) = 1/(α·κ²)`. -/
noncomputable def gMetric (α κ : ℝ) : ℝ := 1 / (α * κ ^ 2)

/-- **R.106 (i) — natural-gradient identity reproduces the Gompertz field.**

With potential `L(κ) = (log κ)²/2` so that `L'(κ) = (log κ)/κ`
(bundled as `hL`), the Fisher natural gradient
`-g(κ)⁻¹·L'(κ)` with `g = 1/(α·κ²)` equals the Gompertz field
`-α·κ·log κ`. -/
theorem R_106_i_natural_gradient
    (α κ Lprime : ℝ) (hα : 0 < α) (hκ : 0 < κ)
    (hL : Lprime = Real.log κ / κ) :
    -(gMetric α κ)⁻¹ * Lprime = -α * κ * Real.log κ := by
  unfold gMetric
  rw [hL]
  have hαne : α ≠ 0 := ne_of_gt hα
  have hκne : κ ≠ 0 := ne_of_gt hκ
  -- (1/(α κ²))⁻¹ = α κ²;  then -α κ² · (log κ / κ) = -α κ log κ.
  field_simp

/-- **R.106 (ii) — log-coordinate metric is the constant `1/α`.**

Under the change of variable `u = log κ` (so `dκ/du = κ`, the Jacobian),
the metric coefficient transforms as `g_uu = g_κκ · (dκ/du)² = g_κκ · κ²`.
With `g_κκ = 1/(α·κ²)` this collapses to the **constant** `1/α`,
independent of `κ`.  (The Jacobian `dκ/du = κ` is the elementary
`d(exp u)/du = exp u = κ`, entered as the bundled premise `hJac`.) -/
theorem R_106_ii_log_coord_constant
    (α κ jac : ℝ) (hα : 0 < α) (hκ : 0 < κ)
    (hJac : jac = κ) :
    gMetric α κ * jac ^ 2 = 1 / α := by
  unfold gMetric
  rw [hJac]
  have hαne : α ≠ 0 := ne_of_gt hα
  have hκne : κ ≠ 0 := ne_of_gt hκ
  field_simp

/-- **R.106 (ii) — metric positivity / well-posedness.**

The metric component `g_κκ = 1/(α·κ²)` is strictly positive on the
interior `κ > 0` with `α > 0`, so the Fisher metric is a genuine
Riemannian metric (positive definite). -/
theorem R_106_metric_pos
    (α κ : ℝ) (hα : 0 < α) (hκ : 0 < κ) :
    0 < gMetric α κ := by
  unfold gMetric
  apply div_pos one_pos
  positivity

/-- **R.106 — line-element invariance (corollary of (ii)).**

The proper-length integrand `g_κκ · (dκ)²` equals `g_uu · (du)²` with the
constant `g_uu = 1/α`, once `(dκ)² = κ²·(du)²` (Jacobian, premise `hdκ`).
This is the statement that Gompertz dynamics is an exponential decay in
the natural coordinate `u = log κ`. -/
theorem R_106_line_element
    (α κ dκ du : ℝ) (hα : 0 < α) (hκ : 0 < κ)
    (hdκ : dκ ^ 2 = κ ^ 2 * du ^ 2) :
    gMetric α κ * dκ ^ 2 = (1 / α) * du ^ 2 := by
  unfold gMetric
  rw [hdκ]
  have hαne : α ≠ 0 := ne_of_gt hα
  have hκne : κ ≠ 0 := ne_of_gt hκ
  field_simp

end KappaFisherMetric

end MIP
