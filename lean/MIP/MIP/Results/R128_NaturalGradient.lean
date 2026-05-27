/-
Result R.128 — Natural gradient of `N` toward the Σ₀ level surface in the
(κ, Z⁻¹) Fisher submanifold: components and Fisher-metric norm.

Reference: `branches/geometry/workspace/new_results.md` R.128
(B, condition A; R.61w simplified model + R.106 + R.125 Fisher metric lift).

**Setup.** In the R.61w midpoint model `N ≈ c·|log κ|·Z = c·|log κ|/ζ`
(`ζ = Z⁻¹`).  The Euclidean partials are

    ∂N/∂ζ = −c·|log κ|·Z² = −c·|log κ|/ζ² ,
    ∂N/∂κ = −c·Z/κ .

Lifting by the diagonal inverse Fisher metric `g⁻¹ = diag(α·κ², ζ²/β)`
(clean-Ohm region, R.106 + R.125) gives the **natural-gradient components**

    (∇_nat N)^ζ = g^{ζζ}·∂N/∂ζ = (ζ²/β)·(−c·|log κ|/ζ²) = −c·|log κ|/β ,
    (∇_nat N)^κ = g^{κκ}·∂N/∂κ = (α·κ²)·(−c·Z/κ)        = −α·c·κ·Z .

The **Fisher-metric squared norm** of the natural gradient is

    |∇_nat N|²_g = g_κκ·((∇_nat N)^κ)² + g_ζζ·((∇_nat N)^ζ)²
                 = (1/(α·κ²))·(α·c·κ·Z)² + (β/ζ²)·(c·|log κ|/β)²
                 = α·c²·Z² + c²·log²κ/(β·ζ²)
                 = c²·Z²·(α + log²κ/β)        (using ζ = 1/Z) ,

so `|∇_nat N|_g = c·Z·√(α + log²κ/β)` — the steepest-descent rate toward Σ₀
in the Fisher metric.

We formalize the three crisp algebraic identities (the two component
collapses and the norm), plus the qualitative fact that the natural gradient
descends `N` (both components have negative sign for `κ ∈ (0,1)`, `Z > 0`),
hence is *not* axis-aligned (both components nonzero).

**This file is `axiom`-free.**  The geometry enters as positive real data;
the content is the inverse-metric collapse algebra.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace NaturalGradient

/- Throughout, `ℓ := |log κ|` is the magnitude of the log-saturation
(positive for `κ ∈ (0,1)`), and `ζ := Z⁻¹`. -/

/-- **R.128 — `ζ`-component of the natural gradient.**

`(∇_nat N)^ζ = (ζ²/β)·(−c·ℓ/ζ²) = −c·ℓ/β`, where `ℓ = |log κ|`.  The
coordinate-dependent `ζ²` of the inverse metric cancels the `1/ζ²` of the
Euclidean partial, leaving a coordinate-free constant `−c·ℓ/β`. -/
theorem R_128_zeta_component
    (c ℓ β ζ : ℝ) (hβ : β ≠ 0) (hζ : ζ ≠ 0) :
    (ζ ^ 2 / β) * (-(c * ℓ) / ζ ^ 2) = -(c * ℓ) / β := by
  field_simp

/-- **R.128 — `κ`-component of the natural gradient.**

`(∇_nat N)^κ = (α·κ²)·(−c·Z/κ) = −α·c·κ·Z` for `κ ≠ 0`. -/
theorem R_128_kappa_component
    (α c κ Z : ℝ) (hκ : κ ≠ 0) :
    (α * κ ^ 2) * (-(c * Z) / κ) = -(α * c * κ * Z) := by
  field_simp
  ring_nf

/-- **R.128 — Fisher-metric squared norm of the natural gradient.**

`|∇_nat N|²_g = (1/(α·κ²))·(α·c·κ·Z)² + (β/ζ²)·(c·ℓ/β)²`.  Using `ζ = 1/Z`
(`ζ·Z = 1`) this collapses to `c²·Z²·(α + ℓ²/β)`. -/
theorem R_128_fisher_norm_sq
    (α β c κ Z ζ ℓ : ℝ)
    (hα : α ≠ 0) (hβ : β ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0)
    (hζZ : ζ = 1 / Z) (hZ : Z ≠ 0) :
    (1 / (α * κ ^ 2)) * (α * c * κ * Z) ^ 2
        + (β / ζ ^ 2) * (c * ℓ / β) ^ 2
      = c ^ 2 * Z ^ 2 * (α + ℓ ^ 2 / β) := by
  subst hζZ
  field_simp
  ring

/-- **R.128 — both components are strictly negative (descent direction).**

For `c > 0`, `ℓ > 0` (i.e. `κ ∈ (0,1)`), `α, β > 0`, `Z > 0`, `κ > 0`, both
natural-gradient components `−c·ℓ/β` and `−α·c·κ·Z` are strictly negative, so
`−∇_nat N` strictly *decreases* `N` along both axes. -/
theorem R_128_descent
    (α β c κ Z ℓ : ℝ)
    (hc : 0 < c) (hℓ : 0 < ℓ) (hα : 0 < α) (hβ : 0 < β)
    (hκ : 0 < κ) (hZ : 0 < Z) :
    -(c * ℓ) / β < 0 ∧ -(α * c * κ * Z) < 0 := by
  constructor
  · apply div_neg_of_neg_of_pos
    · nlinarith
    · exact hβ
  · have : 0 < α * c * κ * Z := by positivity
    linarith

/-- **R.128 — the natural gradient is not axis-aligned (both components ≠ 0).**

Since both components are strictly negative (R.128 descent), neither vanishes:
the steepest-descent direction toward Σ₀ has *both* a `κ` and a `ζ`
component.  Hence single-dimension training (moving only `κ` or only `ζ`) is
*not* the steepest path to Σ₀. -/
theorem R_128_not_axis_aligned
    (α β c κ Z ℓ : ℝ)
    (hc : 0 < c) (hℓ : 0 < ℓ) (hα : 0 < α) (hβ : 0 < β)
    (hκ : 0 < κ) (hZ : 0 < Z) :
    (-(c * ℓ) / β ≠ 0) ∧ (-(α * c * κ * Z) ≠ 0) := by
  obtain ⟨h1, h2⟩ := R_128_descent α β c κ Z ℓ hc hℓ hα hβ hκ hZ
  exact ⟨ne_of_lt h1, ne_of_lt h2⟩

/-- **R.128 — the Fisher norm is strictly positive.**

`|∇_nat N|²_g = c²·Z²·(α + ℓ²/β) > 0` for the positive data above, confirming
a genuine (nonzero) steepest-descent rate toward Σ₀. -/
theorem R_128_norm_pos
    (α β c Z ℓ : ℝ)
    (hc : c ≠ 0) (hα : 0 < α) (hβ : 0 < β) (hZ : Z ≠ 0) :
    0 < c ^ 2 * Z ^ 2 * (α + ℓ ^ 2 / β) := by
  have h1 : 0 < c ^ 2 := by positivity
  have h2 : 0 < Z ^ 2 := by positivity
  have h3 : 0 < α + ℓ ^ 2 / β := by positivity
  positivity

end NaturalGradient

end MIP
