/-
Result R.206 — Σ₀ isosurface normal vector in the 4-D phase space.
Reference: branches/geometry/workspace/new_results.md (old geom R.128).

**Statement.** In the 4-D phase space `S(A) = (|K|, ζ, H_K, κ)` (with
`ζ = Z⁻¹`, R.30), the zero-emergence isosurface
`Σ₀ = {s : N(p, A_s) = 0}` has, in the `N > 0` region, a steepest-descent
"normal" direction `n̂ ∝ −∇_nat N`, the negative Fisher natural gradient.

Using the R.61w midpoint simplification `N ≈ c·|log κ|·Z = c·|log κ|/ζ`
(so `N` depends explicitly only on `(κ, ζ)`; the `|K|, H_K` directions are
absorbed into `c`), the Euclidean partials are
`∂N/∂ζ = −c·|log κ|·Z²`, `∂N/∂κ = −c·Z/κ`, `∂N/∂|K| = ∂N/∂H_K = 0`.
Raising indices with the R.106 + R.201 clean-Ohm inverse metric
`g⁻¹ = diag(α·κ², ζ²/β)` gives the natural-gradient components

    (∇_nat N)^ζ = (ζ²/β)·(−c·|log κ|/ζ²) = −c·|log κ|/β,
    (∇_nat N)^κ = α·κ²·(−c·Z/κ)        = −α·c·κ·Z,

so the 4-D natural gradient and normal are

    ∇_nat N ≈ (0, −c·|log κ|/β, 0, −α·c·κ·Z),
    n̂ ∝ −∇_nat N = (0, c·|log κ|/β, 0, α·c·κ·Z).

Its Fisher-norm is `|∇_nat N|_g = c·Z·√(α + log²κ/β)`, and the normal is
**not** axis-aligned: it carries both κ and ζ components, so single-direction
training is never the steepest path toward Σ₀.

**Kernel formalized here.**
* (a) raising-index identity for the ζ-component:
  `(ζ²/β)·(−c·|log κ|·Z²) = −c·|log κ|/β` using `Z = 1/ζ` (i.e. `Z·ζ = 1`);
* (b) raising-index identity for the κ-component:
  `α·κ²·(−c·Z/κ) = −α·c·κ·Z`;
* (c) Fisher squared-norm identity
  `g_κκ·(∇^κ)² + g_ζζ·(∇^ζ)² = c²·Z²·(α + log²κ/β)`;
* (d) **orthogonality**: the gradient covector ∇N is orthogonal (Euclidean dot
  product = 0) to the in-isosurface tangent direction
  `t = (∂N/∂ζ, −∂N/∂κ)` rotated into the level set — concretely the tangent
  `t` with `⟨∇N, t⟩ = 0` by the antisymmetric pairing — proven by `ring`;
* (e) non-axis-alignment: both components of `n̂` are nonzero on the interior.

**Bridge.** The T.8 / R.61w emergence-cost model and the R.106 + R.201 Fisher
metric enter only as the bundled partials and inverse-metric coefficients; the
gradient/normal/orthogonality facts below are real-vector algebra.

Axiom-free (no A.1–A.4 used; Mathlib only).
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace R206_SigmaNormal4D

open Real

/-- **R.206 (a) — natural-gradient ζ-component.**

Raising the index of `∂N/∂ζ = −c·|log κ|·Z²` (premise `hdNz`, with `Lκ = |log κ|`)
with the inverse-metric coefficient `g^{ζζ} = ζ²/β` (R.201) gives
`(∇_nat N)^ζ = −c·Lκ/β`, using `Z = 1/ζ` so `ζ²·Z² = 1`. -/
theorem R_206_a_nat_grad_zeta
    (c Lκ Z ζ β dNz : ℝ) (hζ : ζ ≠ 0) (hβ : β ≠ 0)
    (hZ : Z = 1 / ζ)
    (hdNz : dNz = -c * Lκ * Z ^ 2) :
    (ζ ^ 2 / β) * dNz = -c * Lκ / β := by
  subst hZ hdNz
  field_simp

/-- **R.206 (b) — natural-gradient κ-component.**

Raising the index of `∂N/∂κ = −c·Z/κ` (premise `hdNk`) with
`g^{κκ} = α·κ²` (R.106) gives `(∇_nat N)^κ = −α·c·κ·Z`. -/
theorem R_206_b_nat_grad_kappa
    (α c Z κ dNk : ℝ) (hκ : κ ≠ 0)
    (hdNk : dNk = -c * Z / κ) :
    (α * κ ^ 2) * dNk = -α * c * κ * Z := by
  subst hdNk
  field_simp

/-- **R.206 (c) — Fisher squared-norm of the natural gradient.**

With `g_κκ = 1/(α·κ²)`, `g_ζζ = β/ζ²` and the components from (a),(b):
`(∇^κ)² ↦ g_κκ·(−α·c·κ·Z)² = α·c²·Z²`,
`(∇^ζ)² ↦ g_ζζ·(−c·Lκ/β)² = c²·Lκ²/(β·ζ²)`.
Using `Z = 1/ζ` (so `1/ζ² = Z²`) their sum is

    |∇_nat N|²_g = c²·Z²·(α + Lκ²/β),

i.e. `|∇_nat N|_g = c·Z·√(α + log²κ/β)`. -/
theorem R_206_c_fisher_norm_sq
    (α β c Lκ Z κ ζ : ℝ)
    (_hα : α ≠ 0) (hβ : β ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0)
    (hZ : Z = 1 / ζ) :
    (1 / (α * κ ^ 2)) * (-α * c * κ * Z) ^ 2
      + (β / ζ ^ 2) * (-c * Lκ / β) ^ 2
      = c ^ 2 * Z ^ 2 * (α + Lκ ^ 2 / β) := by
  subst hZ
  field_simp

/-- **R.206 (d) — orthogonality of ∇N to the in-level-set tangent.**

The Euclidean gradient (κ, ζ-components) is `∇N = (gk, gz)` with
`gk = ∂N/∂κ`, `gz = ∂N/∂ζ`.  A tangent vector to the level set
`{N = const}` is any `t ⟂ ∇N`; the canonical one is the rotation
`t = (−gz, gk)`.  Then the dot product `⟨∇N, t⟩ = gk·(−gz) + gz·gk = 0`,
so `∇N` is indeed normal to the isosurface. -/
theorem R_206_d_orthogonal (gk gz : ℝ) :
    gk * (-gz) + gz * gk = 0 := by ring

/-- **R.206 (e) — the normal is not axis-aligned (both components nonzero).**

The Fisher normal `n̂ ∝ −∇_nat N = (0, c·|log κ|/β, 0, α·c·κ·Z)` has BOTH a
ζ-component `c·Lκ/β` and a κ-component `α·c·κ·Z` strictly nonzero on the
interior (`c > 0`, `α > 0`, `β > 0`, `κ > 0`, `Z > 0`, `Lκ = |log κ| > 0` for
`κ ∈ (0,1)`).  Hence no single-coordinate training direction is the steepest
descent toward Σ₀. -/
theorem R_206_e_not_axis_aligned
    (α β c Lκ κ Z : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hc : 0 < c) (hκ : 0 < κ) (hZ : 0 < Z)
    (hLκ : 0 < Lκ) :
    0 < c * Lκ / β ∧ 0 < α * c * κ * Z := by
  constructor
  · positivity
  · positivity

/-- **R.206 (e′) — concrete `|log κ| > 0` witness on `κ ∈ (0,1)`.**

For `κ ∈ (0,1)` the closure deficit `|log κ| = −log κ > 0`, confirming the
ζ-component of the normal is genuinely nonzero (so the non-axis-alignment of
(e) is realised, not vacuous). -/
theorem R_206_e_logabs_pos (κ : ℝ) (hκ0 : 0 < κ) (hκ1 : κ < 1) :
    0 < -Real.log κ := by
  have : Real.log κ < 0 := Real.log_neg hκ0 hκ1
  linarith

end R206_SigmaNormal4D

end MIP
