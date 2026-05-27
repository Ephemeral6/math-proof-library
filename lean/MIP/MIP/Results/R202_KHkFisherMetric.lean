/-
Result R.202 — |K| and H_K dimension Fisher metric.
Reference: branches/geometry/workspace/new_results.md (old geom R.136).

**Statement.** In the coverage-completed asymptotic regime the emergence count
`N` has `∂E[N]/∂|K| ≈ 0` and `∂E[N]/∂H_K ≈ 0` (R.77), so the Fisher
information in these two directions comes *only* from the variance term of the
Gaussian-style formula

    F(θ) = (∂_θ E[N])² / Var[N] + ½·(∂_θ log Var[N])².

* **|K| direction.**  Under the Heaps'-law coverage model
  `f(|K|) = 1 − |K|^{-ξ}` (ξ > 0, R.95) the dominant variance scales as
  `Var[Φ₀] ∝ |K|^{-ξ}`, so `∂_{|K|} log Var[Φ₀] = −ξ/|K|` and

      g_{|K||K|}(|K|) = F(|K|) = ½·(ξ/|K|)² = ξ² / (2·|K|²).

  In the log-coordinate `w = log|K|` this pulls back to the **constant**
  `g_ww = ξ²/2`.

* **H_K direction.**  Under the exponential model
  `Var[Φ₀](H_K) = V₀·e^{−λ·H_K}` (λ > 0, R.116 / Cj.31) we get
  `∂_{H_K} log Var[Φ₀] = −λ`, so

      g_{H_K H_K} = F(H_K) = ½·λ² = λ² / 2,

  already **constant** (entropy is itself a log-scale coordinate).

Together with R.106 (`1/(α·κ²)`) and R.201 (`β/ζ²`) the full 4-D Fisher metric
in natural coordinates `(log κ, log ζ, log|K|, H_K)` is the constant diagonal
matrix `diag(1/α, β, ξ²/2, λ²/2)` — flat ℝ⁴ (R.136 / R.126 generalisation).

**Kernel formalized here.**
* (a) `|K|` Fisher value `½·(∂_{|K|}log Var)² = ξ²/(2·|K|²)` from the bundled
  Heaps'-law derivative `∂_{|K|}log Var = −ξ/|K|`;
* (b) log-coordinate pullback `g_{|K||K|}·(|K|·dw)² = (ξ²/2)·dw²`
  (constant `g_ww = ξ²/2`);
* (c) `H_K` Fisher value `½·λ² = λ²/2` from `∂_{H_K}log Var = −λ`, and its
  constancy (value independent of the point H_K);
* (d) positivity of both metric components (ξ ≠ 0, |K| > 0, λ ≠ 0).

**Bridge.** The Gaussian-Fisher / Heaps'-law / entropy-variance modeling
(R.77, R.89, R.95, R.116) enters only through the two bundled log-variance
derivatives; the rest is real-algebra.

Axiom-free (no A.1–A.4 used; Mathlib only).
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace R202_KHkFisherMetric

open Real

/-- The `|K|`-dimension Fisher metric component `g_{|K||K|}(|K|) = ξ²/(2·|K|²)`
(Heaps'-law coverage model). -/
noncomputable def gK (ξ Kabs : ℝ) : ℝ := ξ ^ 2 / (2 * Kabs ^ 2)

/-- The `H_K`-dimension Fisher metric component as a function of the point
`H_K`: `g_{H_K H_K}(H_K) = λ²/2` (the exponential variance model makes it
*independent* of `H_K`, hence constant). -/
noncomputable def gH (lam : ℝ) : ℝ → ℝ := fun _ => lam ^ 2 / 2

/-- **R.202 (a) — `|K|` Fisher value from the Heaps'-law variance slope.**

In the coverage-completed regime the mean derivative vanishes (R.77), so the
Gaussian Fisher information is the pure variance term `½·(∂_{|K|}log Var)²`.
With the Heaps'-law slope `∂_{|K|}log Var = −ξ/|K|` (premise `hSlope`) this is
`½·(ξ/|K|)² = ξ²/(2·|K|²) = g_{|K||K|}`. -/
theorem R_202_a_fisher_K
    (ξ Kabs dlogVar : ℝ) (hK : Kabs ≠ 0)
    (hSlope : dlogVar = -ξ / Kabs) :
    (1 / 2) * dlogVar ^ 2 = gK ξ Kabs := by
  unfold gK
  rw [hSlope]
  field_simp

/-- **R.202 (b) — `|K|` log-coordinate pullback is the constant `ξ²/2`.**

Under `w = log|K|` (so `d|K| = |K|·dw`, premise `hdK`), the line element
`g_{|K||K|}·d|K|²` becomes `(ξ²/(2·|K|²))·(|K|·dw)² = (ξ²/2)·dw²`: the
transformed coefficient `g_ww = ξ²/2` is **constant**.  This is the third
diagonal entry of the flat 4-D Fisher metric. -/
theorem R_202_b_log_coord_constant
    (ξ Kabs dKabs dw : ℝ) (hK : Kabs ≠ 0)
    (hdK : dKabs = Kabs * dw) :
    gK ξ Kabs * dKabs ^ 2 = (ξ ^ 2 / 2) * dw ^ 2 := by
  unfold gK
  rw [hdK]
  field_simp

/-- **R.202 (c) — `H_K` Fisher value is the constant `λ²/2`.**

The entropy direction needs no further log-coordinate (entropy is already a
log-scale).  With the exponential-variance slope `∂_{H_K}log Var = −λ`
(premise `hSlope`), the Fisher information is `½·λ² = λ²/2 = g_{H_K H_K}`,
directly constant. -/
theorem R_202_c_fisher_H
    (lam HK dlogVar : ℝ)
    (hSlope : dlogVar = -lam) :
    (1 / 2) * dlogVar ^ 2 = gH lam HK := by
  unfold gH
  rw [hSlope]
  ring

/-- **R.202 (c′) — `H_K` metric component is point-independent (constant).**

`g_{H_K H_K}` takes the same value `λ²/2` at every entropy value `H₁, H₂`:
the entropy-direction Fisher metric is constant, the fourth flat diagonal
entry. -/
theorem R_202_c_H_constant (lam H₁ H₂ : ℝ) :
    gH lam H₁ = gH lam H₂ := rfl

/-- **R.202 (d) — positivity / well-posedness of both components.**

With ξ ≠ 0 and `|K| > 0`, `g_{|K||K|} = ξ²/(2·|K|²) > 0`; with λ ≠ 0,
`g_{H_K H_K} = λ²/2 > 0`.  Both are genuine positive-definite metric
components. -/
theorem R_202_d_gK_pos (ξ Kabs : ℝ) (hξ : ξ ≠ 0) (hK : 0 < Kabs) :
    0 < gK ξ Kabs := by
  unfold gK
  have : 0 < ξ ^ 2 := by positivity
  positivity

theorem R_202_d_gH_pos (lam HK : ℝ) (hlam : lam ≠ 0) :
    0 < gH lam HK := by
  unfold gH
  have : 0 < lam ^ 2 := by positivity
  positivity

end R202_KHkFisherMetric

end MIP
