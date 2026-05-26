/-
Result R.57 — Training-efficiency ratio ρ = Z / Φ₀.

Reference: `proofs/derived/A_grade.md` R.57 (A 无条件 under T.8 Ohm law in
the Z-uniform regime).

**Statement.** Under T.8 (Z-uniform regime), `N(Φ₀, Z) = Φ₀ · Z` viewed as
a smooth bivariate function on `ℝ`.  Its partial-derivative ratio is

    ρ := (∂N/∂Φ₀) / (∂N/∂Z) = Z / Φ₀ .

`ρ` is the marginal exchange rate between knowledge-side investment
(adding Φ₀) and collaboration-side investment (adding Z).

This file proves the **partial-derivative identity** for the real-valued
relaxation `N(Φ₀, Z) := Φ₀ · Z`, using Mathlib's univariate `deriv` on
each coordinate.  The Ohm-law substitution lives outside this file
(in `MIP.Theorems.T8_OhmLaw`); R.57 is a purely analytic corollary of
the bilinear form `Φ₀ · Z`.
-/
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Basic

namespace MIP

namespace TrainingEfficiency

/-- **R.57 — partial ∂N/∂Φ₀ = Z.**

For the real relaxation `N(Φ₀, Z) := Φ₀ · Z`, holding `Z` fixed:
`d/dΦ₀ (Φ₀ · Z) = Z`. -/
theorem partial_Phi0_eq_Z (Z : ℝ) :
    deriv (fun Φ₀ : ℝ => Φ₀ * Z) = fun _ => Z := by
  funext Φ₀
  rw [deriv_mul_const_field' Z]
  simp

/-- **R.57 — partial ∂N/∂Z = Φ₀.**

For the real relaxation `N(Φ₀, Z) := Φ₀ · Z`, holding `Φ₀` fixed:
`d/dZ (Φ₀ · Z) = Φ₀`. -/
theorem partial_Z_eq_Phi0 (Φ0 : ℝ) :
    deriv (fun Z : ℝ => Φ0 * Z) = fun _ => Φ0 := by
  funext Z
  rw [deriv_const_mul_field' Φ0]
  simp

/-- **R.57 — efficiency ratio identity.**

`ρ := (∂N/∂Φ₀) / (∂N/∂Z) = Z / Φ₀` for `Φ₀ ≠ 0`.

(With the natural-language sign convention: `ρ > 1 ⟺ Z > Φ₀` advises
adding knowledge; `ρ < 1 ⟺ Z < Φ₀` advises adding collaboration.) -/
theorem R_57_rho_identity (Φ0 Z : ℝ) :
    deriv (fun x : ℝ => x * Z) Φ0 / deriv (fun y : ℝ => Φ0 * y) Z
      = Z / Φ0 := by
  have h1 : deriv (fun x : ℝ => x * Z) Φ0 = Z := by
    rw [deriv_mul_const_field' Z]; simp
  have h2 : deriv (fun y : ℝ => Φ0 * y) Z = Φ0 := by
    rw [deriv_const_mul_field' Φ0]; simp
  rw [h1, h2]

/-- **ρ as the comparison statistic.**

When `Φ₀ > 0` and `Z > 0`:
* `Z / Φ₀ > 1 ⟺ Z > Φ₀` (collaboration more impedimental — invest in knowledge);
* `Z / Φ₀ < 1 ⟺ Z < Φ₀` (knowledge bottleneck — invest in collaboration);
* `Z / Φ₀ = 1 ⟺ Z = Φ₀` (balanced). -/
theorem rho_compare_gt {Φ0 Z : ℝ} (hΦ0 : 0 < Φ0) :
    1 < Z / Φ0 ↔ Φ0 < Z := by
  rw [lt_div_iff₀ hΦ0, one_mul]

theorem rho_compare_lt {Φ0 Z : ℝ} (hΦ0 : 0 < Φ0) :
    Z / Φ0 < 1 ↔ Z < Φ0 := by
  rw [div_lt_iff₀ hΦ0, one_mul]

theorem rho_compare_eq {Φ0 Z : ℝ} (hΦ0 : Φ0 ≠ 0) :
    Z / Φ0 = 1 ↔ Z = Φ0 := by
  rw [div_eq_one_iff_eq hΦ0]

end TrainingEfficiency

end MIP
