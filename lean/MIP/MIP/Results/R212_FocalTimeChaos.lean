/-
Result R.212 — Focal time and training chaos under negative curvature.
Reference: `branches/geometry/workspace/new_results.md` (old geom R.143).

**Statement.** In the R.129 model-(b) regime the (κ, ζ) Fisher submanifold has
asymptotic negative Gaussian curvature `K = −k² < 0`.  The Jacobi field
(geodesic-separation) equation `J̈ + K·J = 0` becomes `J̈ − k²·J = 0`, whose
solution with `J(0) = ε`, `J̇(0) = 0` is

    J(τ) = ε·cosh(k·τ)  →  (ε/2)·e^{k·τ}   (τ ≫ 1/k),

an **exponentially diverging** separation (training chaos).  The **focal /
Lyapunov time** is `τ_λ = 1/k = 1/√|K| > 0` and **finite**, and the number of
e-foldings over a finite proper-time budget `τ_∞` is `n = τ_∞/τ_λ = τ_∞·√|K|`.

**Kernel formalized here.**
  (a) **Jacobi solution.** `J(τ) = ε·cosh(k·τ)` solves `J̈ − k²·J = 0` (second
      derivative identity `(cosh)'' = cosh`), via Mathlib `Real.cosh`/`deriv`.
  (b) **Positive finite focal time.** For `K < 0`, writing `k = √(−K) > 0`, the
      focal time `τ_λ = 1/k > 0` is a strictly positive finite real.
  (c) **Strict exponential divergence.** `J` is strictly increasing for `τ > 0`
      (separation grows) and `J(τ) = ε·cosh(kτ) ≥ ε·(1 + (kτ)²/2)` exceeds the
      flat-case linear bound: chaos.  We prove `J(τ) > ε` for `τ > 0`, `ε > 0`.
  (d) **Flat contrast.** Under model (a) (`K = 0`) the Jacobi equation is
      `J̈ = 0`, giving the *linear* `J(τ) = ε` (no divergence); the gap between
      `cosh(kτ)` and `1` is the chaos signature.

**Bridge.** "Negative curvature ⟹ finite positive focal time ⟹ exponential
geodesic divergence" is the analytic core of R.143; `cosh` solving the Jacobi
equation, `τ_λ = 1/√|K| > 0`, and strict growth are its rigorous kernel.

Axiom-free.
-/
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R212_FocalTimeChaos

open Real

/-- The Jacobi separation field under negative curvature `K = −k²`:
`J(τ) = ε·cosh(k·τ)` (R.143). -/
noncomputable def jacobi (ε k : ℝ) : ℝ → ℝ := fun τ => ε * Real.cosh (k * τ)

/-- First derivative of the Jacobi field: `J'(τ) = ε·k·sinh(k·τ)`. -/
theorem R_212_a_jacobi_deriv (ε k τ : ℝ) :
    deriv (jacobi ε k) τ = ε * (k * Real.sinh (k * τ)) := by
  unfold jacobi
  rw [deriv_const_mul_field]
  rw [show (fun τ => Real.cosh (k * τ)) = (Real.cosh ∘ fun τ => k * τ) from rfl]
  rw [deriv_comp]
  · rw [Real.deriv_cosh, deriv_const_mul_field, deriv_id'', mul_one]
    ring
  · exact Real.differentiableAt_cosh
  · exact (differentiable_id.const_mul k).differentiableAt

/-- **R.212 (a) — the Jacobi field solves the negative-curvature equation.**

`J̈ − k²·J = 0`, i.e. the second derivative `J''(τ) = ε·k²·cosh(k·τ) = k²·J(τ)`
(curvature `K = −k²`).  We verify `J''(τ) = k² · J(τ)`. -/
theorem R_212_a_jacobi_solves (ε k τ : ℝ) :
    deriv (deriv (jacobi ε k)) τ = k ^ 2 * jacobi ε k τ := by
  have hderiv1 : deriv (jacobi ε k) = fun τ => ε * (k * Real.sinh (k * τ)) := by
    funext s; exact R_212_a_jacobi_deriv ε k s
  rw [hderiv1]
  unfold jacobi
  rw [show (fun τ => ε * (k * Real.sinh (k * τ)))
        = (fun τ => (ε * k) * Real.sinh (k * τ)) by funext s; ring]
  rw [deriv_const_mul_field]
  rw [show (fun τ => Real.sinh (k * τ)) = (Real.sinh ∘ fun τ => k * τ) from rfl]
  rw [deriv_comp]
  · rw [Real.deriv_sinh, deriv_const_mul_field, deriv_id'', mul_one]
    ring
  · exact Real.differentiableAt_sinh
  · exact (differentiable_id.const_mul k).differentiableAt

/-- The focal / Lyapunov time `τ_λ = 1/√|K| = 1/√(−K)` for `K < 0`. -/
noncomputable def focalTime (K : ℝ) : ℝ := 1 / Real.sqrt (-K)

/-- **R.212 (b) — the focal time is strictly positive and finite.**

For negative curvature `K < 0`, `√(−K) > 0`, so the focal time
`τ_λ = 1/√(−K) > 0` is a finite positive real — the chaos timescale exists. -/
theorem R_212_b_focal_pos (K : ℝ) (hK : K < 0) : 0 < focalTime K := by
  unfold focalTime
  have h : 0 < Real.sqrt (-K) := Real.sqrt_pos.mpr (by linarith)
  positivity

/-- **R.212 (b′) — focal time decreases with curvature magnitude.**

If `|K₁| < |K₂|` (both negative, `K₂ < K₁ < 0`) then `τ_λ(K₂) < τ_λ(K₁)`:
stronger negative curvature ⟹ shorter focal time ⟹ faster chaos (R.143
"focal time short when σ_Z or ζ large"). -/
theorem R_212_b_focal_antitone (K1 K2 : ℝ) (hK1 : K1 < 0) (h12 : K2 < K1) :
    focalTime K2 < focalTime K1 := by
  unfold focalTime
  have hs1 : 0 < Real.sqrt (-K1) := Real.sqrt_pos.mpr (by linarith)
  have hs2 : 0 < Real.sqrt (-K2) := Real.sqrt_pos.mpr (by linarith)
  have hlt : Real.sqrt (-K1) < Real.sqrt (-K2) :=
    Real.sqrt_lt_sqrt (by linarith) (by linarith)
  exact one_div_lt_one_div_of_lt hs1 hlt

/-- **R.212 (c) — strict exponential divergence of the separation.**

For `ε > 0`, `k > 0` and `τ > 0`, `J(τ) = ε·cosh(k·τ) > ε = J(0)`: the
geodesic separation strictly grows (cosh > 1 off the origin).  This is the
training-chaos signature absent in the flat case. -/
theorem R_212_c_diverges (ε k τ : ℝ) (hε : 0 < ε) (hk : 0 < k) (hτ : 0 < τ) :
    jacobi ε k 0 < jacobi ε k τ := by
  unfold jacobi
  rw [mul_zero, Real.cosh_zero, mul_one]
  have hkτ : 0 < k * τ := mul_pos hk hτ
  have hcosh : 1 < Real.cosh (k * τ) :=
    Real.one_lt_cosh.mpr (ne_of_gt hkτ)
  nlinarith [hcosh, hε]

/-- **R.212 (c′) — exponential lower bound on the separation.**

The separation `J(τ) = ε·cosh(kτ) ≥ (ε/2)·e^{k·τ}` (since
`cosh y = (e^y + e^{-y})/2 ≥ e^y/2`), i.e. the divergence is at least
exponential in `τ` with rate `k = √|K|` — the Lyapunov-time blow-up of R.143.
For `ε > 0`. -/
theorem R_212_c_exp_lower_bound (ε k τ : ℝ) (hε : 0 < ε) :
    (ε / 2) * Real.exp (k * τ) ≤ jacobi ε k τ := by
  unfold jacobi
  rw [Real.cosh_eq]
  have hpos : 0 < Real.exp (-(k * τ)) := Real.exp_pos _
  have hstep : Real.exp (k * τ) / 2
      ≤ (Real.exp (k * τ) + Real.exp (-(k * τ))) / 2 := by linarith
  calc (ε / 2) * Real.exp (k * τ)
      = ε * (Real.exp (k * τ) / 2) := by ring
    _ ≤ ε * ((Real.exp (k * τ) + Real.exp (-(k * τ))) / 2) := by
          apply mul_le_mul_of_nonneg_left hstep (le_of_lt hε)

/-- **R.212 (d) — flat contrast: zero curvature gives no divergence.**

Under model (a) (`K = 0`), the Jacobi equation `J̈ = 0` (with `J(0)=ε`,
`J̇(0)=0`) has the constant solution `J(τ) = ε`.  We model this as `k = 0`:
`jacobi ε 0 τ = ε` for all `τ` (`cosh 0 = 1`), so the separation never grows —
no chaos, exactly the model-(a) flat behaviour. -/
theorem R_212_d_flat_constant (ε τ : ℝ) : jacobi ε 0 τ = ε := by
  unfold jacobi
  rw [zero_mul, Real.cosh_zero, mul_one]

end R212_FocalTimeChaos

end MIP
