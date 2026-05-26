/-
Result R.118 — Fisher natural gradient on the κ-axis reproduces Gompertz
(`Cj.38` κ-dimension break of the 4D phase-space gradient flow).

Reference: `C:/Users/12729/Desktop/MIP/workspace/frontier_attacks.md` §R.118
(攻击 #15, Cj.38 四维相空间梯度流, Fisher metric R.106, "B (κ 维)").

**Statement.** On the κ-axis with the R.106 Fisher metric
`g_κκ = 1/(α·κ²)` (so `g_κκ⁻¹ = α·κ²`), the Fisher *natural* gradient flow of
a loss `L` is

    dκ/dt |_natural  =  − g_κκ⁻¹ · ∂L/∂κ  =  − α·κ² · ∂L/∂κ .

Two facts:

* **(a) Generic N-loss.**  Using `L = N` with the R.77 derivative
  `∂N/∂κ = − N/(κ·|log κ|)` (on `κ ∈ (0,1)`, `|log κ| = −log κ > 0`),

      dκ/dt |_natural  =  − α·κ² · ( − N/(κ·|log κ|) )  =  α·κ·N / |log κ| .

* **(b) Gompertz reduction.**  Taking instead the quadratic surrogate loss
  `L = (log κ)²/2`, one has `∂L/∂κ = (log κ)/κ`, hence

      dκ/dt |_natural  =  − α·κ² · (log κ)/κ  =  − α·κ·log κ ,

  which is **exactly** the Gompertz right-hand side (R.98).  So the κ-axis
  natural gradient of the quadratic log-loss IS the Gompertz dynamics.

* **(c) Mismatch obstruction.**  The R.61 emergence cost
  `N = c·r·|log κ|·Z` is *not* the quadratic loss `(log κ)²/2` in general
  (they would require `c·r·Z·|log κ| = (log κ)²/2`, i.e.
  `|log κ| = 2·c·r·Z`, a single-point condition, not an identity).  Hence
  the κ-axis natural gradient flow uses a *different* loss from the true
  emergence cost — the 4D joint flow stays open, matching the source's "B".

**Bundled premises.** The R.106 Fisher metric and the R.77 partial derivative
enter as the explicit functional forms; we encode the algebraic reduction and
the mismatch.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

namespace MIP

namespace FisherNaturalGradient

open Real

/-- The κ-axis Fisher natural gradient `−g_κκ⁻¹·∂L/∂κ` with the R.106
inverse metric `g_κκ⁻¹ = α·κ²`. -/
def naturalGrad (α κ dLdκ : ℝ) : ℝ := -(α * κ ^ 2) * dLdκ

/-- **R.118 (a) — natural gradient of the N-loss equals `α·κ·N/|log κ|`.**

With `∂N/∂κ = −N/(κ·L)` (R.77, `L := |log κ| > 0`, `κ > 0`), the κ-axis
Fisher natural gradient simplifies to `α·κ·N/L`. -/
theorem R_118_a_natural_grad_N
    (α κ N L : ℝ) (hκ : κ ≠ 0) (hL : L ≠ 0)
    (dNdκ : ℝ) (h_dN : dNdκ = -N / (κ * L)) :
    naturalGrad α κ dNdκ = α * κ * N / L := by
  unfold naturalGrad
  rw [h_dN]
  field_simp

/-- **R.118 (b) — Gompertz reduction from the quadratic log-loss.**

For the surrogate loss `L_q = (log κ)²/2` we have `∂L_q/∂κ = (log κ)/κ`.
The κ-axis Fisher natural gradient then equals the Gompertz right-hand side

    dκ/dt |_natural  =  −α·κ·log κ . -/
theorem R_118_b_gompertz_reduction
    (α κ : ℝ) (hκ : κ ≠ 0)
    (dLqdκ : ℝ) (h_dLq : dLqdκ = Real.log κ / κ) :
    naturalGrad α κ dLqdκ = -α * κ * Real.log κ := by
  unfold naturalGrad
  rw [h_dLq]
  field_simp

/-- **R.118 (b′) — agreement with the Gompertz ODE on `κ ∈ (0,1)`.**

On `κ ∈ (0,1)` (`log κ < 0`, `|log κ| = −log κ`), the natural-gradient
value `−α·κ·log κ` is positive (κ increases toward the closure ceiling),
matching the R.98 Gompertz form `α·κ·|log κ|`. -/
theorem R_118_b_gompertz_positive
    (α κ : ℝ) (hα : 0 < α) (hκ0 : 0 < κ) (hκ1 : κ < 1) :
    0 < -α * κ * Real.log κ := by
  have hlog : Real.log κ < 0 := Real.log_neg hκ0 hκ1
  have : 0 < -Real.log κ := by linarith
  nlinarith [mul_pos hα hκ0]

/-- **R.118 (c) — loss mismatch obstruction.**

The R.61 emergence cost `N = c·r·|log κ|·Z` coincides with the quadratic
surrogate `(log κ)²/2` only on the single-point condition
`|log κ| = 2·c·r·Z` (not as a functional identity).  Concretely, there exist
admissible positive constants `(c, r, Z)` and a value `κ` for which
`c·r·|log κ|·Z ≠ (log κ)²/2`, so the natural-gradient loss of (b) is *not*
the true emergence cost — the κ-axis flow ≠ the 4D `∇N` flow. -/
theorem R_118_c_loss_mismatch :
    ∃ (c r Z L : ℝ), 0 < c ∧ 0 < r ∧ 0 < Z ∧ 0 < L ∧
      c * r * L * Z ≠ L ^ 2 / 2 := by
  -- Take c = r = Z = 1, L = |log κ| = 1.  Then LHS = 1, RHS = 1/2.
  refine ⟨1, 1, 1, 1, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · norm_num
  · norm_num
  · norm_num
  · norm_num

/-- **R.118 (c′) — no universal identification of the two losses.**

The proposition "for all admissible `(c, r, Z, L)` the emergence cost equals
the quadratic surrogate" is FALSE.  Hence the κ-axis Fisher natural gradient
(which reproduces Gompertz via the quadratic loss) cannot be the gradient of
the genuine R.61 emergence cost across the board — the full 4D joint gradient
flow remains open. -/
theorem R_118_c_no_universal_identification :
    ¬ (∀ (c r Z L : ℝ), 0 < c → 0 < r → 0 < Z → 0 < L →
        c * r * L * Z = L ^ 2 / 2) := by
  intro hAll
  obtain ⟨c, r, Z, L, hc, hr, hZ, hL, hne⟩ := R_118_c_loss_mismatch
  exact hne (hAll c r Z L hc hr hZ hL)

end FisherNaturalGradient

end MIP
