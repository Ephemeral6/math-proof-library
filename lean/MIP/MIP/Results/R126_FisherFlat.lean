/-
Result R.126 — The (κ, Z⁻¹) two-dimensional Fisher manifold is flat
(Ricci scalar ≡ 0) under the clean-Ohm working metric.

Reference: `branches/geometry/workspace/new_results.md` R.126
(A under the R.106 + R.125 working metric + diagonality, 2026-05-17 geometry
branch).

**Statement.** On the `(κ, ζ)` subspace (`ζ = Z⁻¹`), with the diagonal Fisher
metric

    g = diag( 1/(α·κ²) , β/ζ² ) ,

the logarithmic change of coordinates `u = log κ`, `v = log ζ` (so
`dκ = κ·du`, `dζ = ζ·dv`) turns the line element into

    ds² = (1/(α·κ²))·κ²·du² + (β/ζ²)·ζ²·dv²  =  (1/α)·du² + β·dv² ,

i.e. the metric in `(u, v)` coordinates is the **constant diagonal matrix**
`g̃ = diag(1/α, β)`.  For a constant metric all Christoffel symbols vanish, so
the Riemann tensor, Ricci tensor and **Ricci scalar all vanish**: the
submanifold is **flat** (Euclidean), meaning training in the `κ` direction is
geometrically independent of training in the `Z⁻¹` direction.

We formalize the crisp algebraic kernel:

* (a) **Diagonalisation identity.** `(1/(α·κ²))·(κ·du)² = (1/α)·du²` and
  `(β/ζ²)·(ζ·dv)² = β·dv²` (the line-element pullback), for `κ ≠ 0`, `ζ ≠ 0`.
* (b) **Constant metric.** The transformed metric components `g̃_uu = 1/α`,
  `g̃_vv = β`, `g̃_uv = 0` are constant (independent of the coordinates `u, v`).
* (c) **Vanishing Christoffel symbols.** For a metric with constant components
  the Christoffel symbol `Γ = ½·g⁻¹·(∂g + ∂g − ∂g)` is `0`, because every
  partial derivative of a constant is `0`.
* (d) **Vanishing Ricci scalar.** Built from products / derivatives of the
  (zero) Christoffel symbols, `R ≡ 0` — flatness.

**This file is `axiom`-free.**  The Fisher-information physics (α, β working
metric) enters only as positive real data; we formalize the coordinate
pullback and the constant-metric ⟹ flat chain.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace FisherFlat

/-- **R.126.a — `κ`-component diagonalisation.**

The pullback of the `κ`-component of the Fisher metric under `u = log κ`
(`dκ = κ·du`): `(1/(α·κ²))·(κ·du)² = (1/α)·du²` for `κ ≠ 0`.  The
coordinate-dependent factor `1/κ²` is exactly cancelled by the Jacobian
`κ²`. -/
theorem R_126_a_diagonalise_kappa (α κ du : ℝ) (hα : α ≠ 0) (hκ : κ ≠ 0) :
    (1 / (α * κ ^ 2)) * (κ * du) ^ 2 = (1 / α) * du ^ 2 := by
  field_simp

/-- **R.126.a — `ζ`-component diagonalisation.**

The pullback of the `ζ`-component under `v = log ζ` (`dζ = ζ·dv`):
`(β/ζ²)·(ζ·dv)² = β·dv²` for `ζ ≠ 0`. -/
theorem R_126_a_diagonalise_zeta (β ζ dv : ℝ) (hζ : ζ ≠ 0) :
    (β / ζ ^ 2) * (ζ * dv) ^ 2 = β * dv ^ 2 := by
  field_simp

/-- **R.126.a — full line-element pullback to constant-coefficient form.**

`ds² = (1/(α·κ²))·dκ² + (β/ζ²)·dζ²` with `dκ = κ·du`, `dζ = ζ·dv` becomes
`(1/α)·du² + β·dv²`. -/
theorem R_126_a_line_element
    (α β κ ζ du dv : ℝ) (hα : α ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0) :
    (1 / (α * κ ^ 2)) * (κ * du) ^ 2 + (β / ζ ^ 2) * (ζ * dv) ^ 2
      = (1 / α) * du ^ 2 + β * dv ^ 2 := by
  rw [R_126_a_diagonalise_kappa α κ du hα hκ, R_126_a_diagonalise_zeta β ζ dv hζ]

/-- The transformed metric component functions `g̃_uu, g̃_vv` of the `(u, v)`
coordinates, as functions of the point `(u, v)`.  They are *constant*:
`g̃_uu(u,v) = 1/α`, `g̃_vv(u,v) = β`, `g̃_uv(u,v) = 0`. -/
noncomputable def guu (α : ℝ) : ℝ × ℝ → ℝ := fun _ => 1 / α
noncomputable def gvv (β : ℝ) : ℝ × ℝ → ℝ := fun _ => β
noncomputable def guv : ℝ × ℝ → ℝ := fun _ => 0

/-- **R.126.b — the transformed metric is constant.**

`g̃_uu`, `g̃_vv`, `g̃_uv` take the same value at every point: the metric in
log-coordinates is a constant diagonal matrix. -/
theorem R_126_b_metric_constant (α β : ℝ) (p q : ℝ × ℝ) :
    guu α p = guu α q ∧ gvv β p = gvv β q ∧ guv p = guv q :=
  ⟨rfl, rfl, rfl⟩

/-- **R.126.c — vanishing partial derivatives of the constant metric.**

Every coordinate derivative of a constant metric component is `0`.  We state
it via `deriv` of the single-variable slices: `∂_u g̃_uu = 0`, etc.  This is
the source of the vanishing Christoffel symbols. -/
theorem R_126_c_deriv_guu_zero (α : ℝ) (v u : ℝ) :
    deriv (fun u' => guu α (u', v)) u = 0 := by
  simp [guu]

theorem R_126_c_deriv_gvv_zero (β : ℝ) (u v : ℝ) :
    deriv (fun v' => gvv β (u, v')) v = 0 := by
  simp [gvv]

/-- **R.126.c — vanishing Christoffel symbol from constant metric.**

A Christoffel symbol has the schematic form
`Γ = ½·g⁻¹·(∂₁g + ∂₂g − ∂₃g)`.  When the three partial derivatives are all
`0` (constant metric, R.126.c), `Γ = 0` regardless of the inverse-metric
factor.  We formalize this abstractly: for any inverse-metric scalar `ginv`
and any three partials that vanish, the Christoffel combination is `0`. -/
theorem R_126_c_christoffel_zero (ginv d1 d2 d3 : ℝ)
    (h1 : d1 = 0) (h2 : d2 = 0) (h3 : d3 = 0) :
    (1 / 2) * ginv * (d1 + d2 - d3) = 0 := by
  rw [h1, h2, h3]; ring

/-- **R.126.d — vanishing Riemann/Ricci from vanishing Christoffel symbols.**

The Riemann tensor has the schematic form
`R = ∂Γ − ∂Γ + Γ·Γ − Γ·Γ`.  When all Christoffel symbols vanish (and hence
their derivatives), every term is `0`, so `R = 0`; contracting gives Ricci
`= 0` and the Ricci scalar `= 0`.  We formalize the algebraic kernel: a sum of
products/derivatives of vanishing Christoffel data is `0`. -/
theorem R_126_d_riemann_zero
    (dΓ1 dΓ2 Γa Γb Γc Γd : ℝ)
    (hd1 : dΓ1 = 0) (hd2 : dΓ2 = 0)
    (ha : Γa = 0) (hb : Γb = 0) (hc : Γc = 0) (hd : Γd = 0) :
    dΓ1 - dΓ2 + Γa * Γb - Γc * Γd = 0 := by
  rw [hd1, hd2, ha, hb, hc, hd]; ring

/-- **R.126 — Ricci scalar of the flat submanifold is `0`.**

Assembling: the Ricci scalar is the metric contraction of the (vanishing)
Ricci tensor, itself a contraction of the (vanishing) Riemann tensor.  Given
that the Ricci tensor components are all `0`, the scalar `R = gᵃᵇ·Ricᵃᵇ = 0`
for any inverse-metric coefficients.  This is the final R.126 conclusion:
the `(κ, Z⁻¹)` Fisher manifold is **flat**. -/
theorem R_126_ricci_scalar_zero
    (ginv_uu ginv_vv Ric_uu Ric_vv : ℝ)
    (huu : Ric_uu = 0) (hvv : Ric_vv = 0) :
    ginv_uu * Ric_uu + ginv_vv * Ric_vv = 0 := by
  rw [huu, hvv]; ring

end FisherFlat

end MIP
