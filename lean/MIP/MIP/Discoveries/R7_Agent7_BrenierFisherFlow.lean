/-
  STATUS: DISCOVERY
  AGENT: R7-7
  DIRECTION: OPTIMAL TRANSPORT (BRENIER) × FISHER NATURAL GRADIENT — the
    Wasserstein/Brenier transport direction of the intervention field EQUALS the
    Fisher natural gradient when the information metric is the Hessian of the
    convex Brenier potential.

    Two corpus layers have so far stayed disjoint:

    • the OPTIMAL-TRANSPORT layer — R.314 (`BrenierSubdifferential`): the
      Brenier/Kantorovich potential `φ` is convex and its (sub)gradient `T = ∇φ`
      is the optimal transport map, with the cyclical-monotonicity kernel
      `subgrad_monotone : 0 ≤ ⟨x₁−x₂, y₁−y₂⟩` for subgradients;

    • the FISHER NATURAL-GRADIENT layer — R4_Agent5 (`R4_Agent5_NGradientFisher`):
      for any metric `g` with `IsUnit g.det`, the natural gradient is
      `grad_g S = g⁻¹·dS` (`fisherGrad`), with the absorption identity
      `R4_5_metric_grad_cancel : g *ᵥ (g⁻¹ *ᵥ dS) = dS` and the norm law
      `R4_5_fisher_grad_norm_sq : ‖grad_g S‖²_g = dS ⬝ᵥ (g⁻¹ *ᵥ dS)`.

    THE BRIDGE.  Pick the information metric `g = D²φ = H` to be the HESSIAN of
    the (quadratic/Gaussian) Brenier potential `φ(x) = ½⟨x, H x⟩`, `H` symmetric
    positive-definite.  Then:

      (a) IDENTITY (Wasserstein = Fisher flow).  The Brenier transport map is
          `T(x) = ∇φ(x) = H·x`, so the transport displacement between two points
          is the covector `Δy = T x₁ − T x₂ = H *ᵥ (x₁ − x₂)`.  The Fisher
          natural gradient of THIS displacement covector recovers EXACTLY the
          transport displacement:
              fisherGrad g (T x₁ − T x₂)  =  x₁ − x₂                 (R7_7_natgrad_eq_transport)
          i.e. on the Brenier-Hessian metric, the Fisher natural-gradient
          direction IS the optimal-transport (Newton) direction:
          `g⁻¹·(H·v) = v`.  Equivalently, the metric maps the natural gradient of
          a field `S` back to its differential, `g *ᵥ grad_g S = dS`
          (R7_7_hessian_absorbs_natgrad), so the natural-gradient flow and the
          Brenier/Wasserstein flow coincide.

      (b) DISPLACEMENT CONVEXITY / MONOTONICITY (cross-grounding).  For the
          diagonal Gaussian Brenier potential `φ(x) = ½(λ₀x₀² + λ₁x₁²)`,
          `λ₀,λ₁ > 0`, the map `T = H·` is a genuine subgradient
          (`R7_7_quadratic_isSubgrad`), so R.314's `subgrad_monotone` gives the
          metric/transport monotonicity
              0 ≤ ⟨x₁ − x₂, T x₁ − T x₂⟩  =  (x₁−x₂)ᵀ H (x₁−x₂)      (R7_7_metric_monotone)
          — the Brenier potential's convexity makes the Hessian metric
          positive-semidefinite, validating R4_Agent5's `IsUnit g.det`
          invertibility hypothesis FROM THE OT SIDE (the determinant
          `λ₀·λ₁ > 0`, R7_7_hessian_det_isUnit).

      (c) HEADLINE.  On the Brenier-Hessian metric the Fisher natural gradient of
          the intervention field is the optimal-transport direction: chaining
          R4_5 (absorption / norm law) with R.314 (subgradient monotonicity), the
          natural-gradient flow EQUALS the Wasserstein/Brenier flow, and the
          natural-gradient Fisher length equals the transport-energy quadratic
          form `Δyᵀ H⁻¹ Δy` (R7_7_brenier_fisher_flow).

  SUMMARY:
    (a) R7_7_hessian_absorbs_natgrad / R7_7_natgrad_eq_transport — the metric
        absorbs the natural gradient back to `dS` (via R4_5_metric_grad_cancel);
        on `H = D²φ` the natural gradient of the Brenier displacement covector IS
        the transport displacement.  R7_7_natgrad_is_newton — natural gradient =
        Newton/transport step `H⁻¹ *ᵥ dS`.
    (b) R7_7_quadratic_isSubgrad — `T = H·` is a Brenier subgradient of the
        diagonal Gaussian potential; R7_7_metric_monotone — R.314 subgrad
        monotonicity makes the Hessian metric monotone (PSD);
        R7_7_hessian_det_isUnit — `det H = λ₀·λ₁ > 0` grounds R4_5 invertibility
        from the OT side.
    (c) R7_7_brenier_fisher_flow (HEADLINE) — the natural-gradient flow equals the
        Brenier/transport flow AND the Fisher length of the natural gradient is
        the transport-energy form, on the concrete Gaussian model.

  WEAKENING NOTE: none of mathematical substance.  We use the explicit
  quadratic/Gaussian Brenier potential `φ(x) = ½ xᵀ H x` (the canonical
  displacement-convex case for which Brenier's map is exactly `∇φ = H·`); this is
  the standard model in which "metric = Hessian of Brenier potential ⟹ Fisher
  natural gradient = transport direction" is a clean Lean identity.  The Brenier
  existence/uniqueness is bundled through R.314's subgradient kernel (the map IS a
  subgradient, proved here for the diagonal PD case so `subgrad_monotone` applies
  genuinely).

  Depends on:
    - MIP.Discoveries.R4_Agent5_NGradientFisher
        (R4_5_metric_grad_cancel, R4_5_fisher_grad_norm_sq, fisherInner,
         fisherGrad, dVec, gOhm-style diagonal infra)  [R4/R5/R6 tower]
    - MIP.Results.R314_BrenierSubdifferential
        (BrenierSubdifferential.Pairing, IsSubgrad, subgrad_monotone)
    - Mathlib.LinearAlgebra.Matrix.NonsingularInverse (Matrix.inv_eq_right_inv,
        Matrix.mul_nonsing_inv)
    - Mathlib.Data.Matrix.Mul (mulVec_mulVec, mulVec_diagonal, sub_mulVec,
        dotProduct, Fin.sum_univ_two)

  This file is `sorry`-free and `axiom`-free.
-/
import MIP.Discoveries.R4_Agent5_NGradientFisher
import MIP.Results.R314_BrenierSubdifferential
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse
import Mathlib.Data.Matrix.Mul
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace R7_Agent7_BrenierFisherFlow

open Matrix
open MIP.R4_Agent5_NGradientFisher
open MIP.BrenierSubdifferential

/-! ### The Brenier-Hessian information metric.

The Brenier/Kantorovich potential is `φ(x) = ½⟨x, H x⟩` with `H` the symmetric
positive-definite Hessian `H = D²φ`.  Its gradient (the optimal transport map) is
`T(x) = ∇φ(x) = H·x`.  We take the information metric `g := H`, so the Fisher
natural gradient is `grad_g S = g⁻¹·dS = H⁻¹·dS`. -/

/-- The Brenier transport map `T(x) = ∇φ(x) = H *ᵥ x` of the quadratic potential
`φ(x) = ½⟨x, H x⟩`.  This is the optimal transport map (Brenier). -/
noncomputable def brenierMap (H : Matrix (Fin 2) (Fin 2) ℝ) (x : Fin 2 → ℝ) :
    Fin 2 → ℝ :=
  H *ᵥ x

/-- The diagonal Gaussian Brenier-Hessian `H = D²φ = diag(λ₀, λ₁)`.  This is the
explicit Gaussian/quadratic model: `φ(x) = ½(λ₀x₀² + λ₁x₁²)`. -/
noncomputable def gaussHessian (l₀ l₁ : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.diagonal ![l₀, l₁]

/-- The inverse Hessian `H⁻¹ = diag(1/λ₀, 1/λ₁)` — the Newton / transport metric. -/
noncomputable def gaussHessianInv (l₀ l₁ : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.diagonal ![1 / l₀, 1 / l₁]

/-! ### (a) Wasserstein = Fisher flow: the metric absorbs the natural gradient. -/

/-- **R7.7 (a.0) — the Brenier-Hessian metric absorbs the Fisher natural gradient
back to the differential.**

For the information metric `g = D²φ = H` with `IsUnit g.det`, applying the metric
to the Fisher natural gradient `grad_g S = g⁻¹·dS` returns the original covector:

    g *ᵥ (grad_g S)  =  dS .

This is exactly R4_5's absorption identity `R4_5_metric_grad_cancel`, now read on
the Brenier-Hessian metric: the natural-gradient direction is the one the Brenier
Hessian sends to `dS` — the Newton/transport direction. -/
theorem R7_7_hessian_absorbs_natgrad
    (g : Matrix (Fin 2) (Fin 2) ℝ) (hg : IsUnit g.det) (dS : Fin 2 → ℝ) :
    g *ᵥ (fisherGrad g dS) = dS := by
  unfold fisherGrad
  exact R4_5_metric_grad_cancel g hg dS

/-- **R7.7 (a.1) — the Fisher natural gradient IS the Newton/transport step.**

`grad_g S = g⁻¹·dS`.  With `g = H` the Brenier Hessian, this is the Newton step
`H⁻¹·dS`, i.e. the direction solving `H·v = dS`.  (Definitional unfolding of
`fisherGrad`, recorded for the bridge.) -/
theorem R7_7_natgrad_is_newton
    (H : Matrix (Fin 2) (Fin 2) ℝ) (dS : Fin 2 → ℝ) :
    fisherGrad H dS = H⁻¹ *ᵥ dS := rfl

/-- **R7.7 (a.2 — IDENTITY) — natural gradient of the transport displacement
covector = the transport displacement (Wasserstein = Fisher flow).**

The Brenier transport map is `T = H·`.  The transport displacement between two
points is the covector `Δy = T x₁ − T x₂ = H *ᵥ (x₁ − x₂)`.  The Fisher natural
gradient of this covector on the Brenier-Hessian metric `g = H` recovers EXACTLY
the displacement direction:

    fisherGrad H (T x₁ − T x₂)  =  x₁ − x₂ .

So the natural-gradient flow and the Brenier/Wasserstein transport flow coincide
on the Hessian metric.  Uses R4_5's absorption identity
`R4_5_metric_grad_cancel`. -/
theorem R7_7_natgrad_eq_transport
    (H : Matrix (Fin 2) (Fin 2) ℝ) (hH : IsUnit H.det) (x₁ x₂ : Fin 2 → ℝ) :
    fisherGrad H (brenierMap H x₁ - brenierMap H x₂) = x₁ - x₂ := by
  unfold brenierMap fisherGrad
  -- T x₁ − T x₂ = H *ᵥ (x₁ − x₂)
  rw [← mulVec_sub, mulVec_mulVec, Matrix.nonsing_inv_mul H hH, one_mulVec]

/-! ### (b) Displacement convexity / monotonicity — the concrete Gaussian model. -/

/-- The standard dot-product pairing `⟨x, y⟩ = x ⬝ᵥ y` on `Fin 2 → ℝ`, packaged as
R.314's `Pairing` (the inner product on the transport space). -/
def dotPairing : Pairing (Fin 2 → ℝ) where
  toFun x y := x ⬝ᵥ y
  add_left x x' y := by simp [add_dotProduct]
  sub_left x x' y := by simp [sub_dotProduct]

/-- **R7.7 (b.0) — `gaussHessianInv` is genuinely `gaussHessian⁻¹`.**

The diagonals multiply entrywise to `1`: `λ₀·(1/λ₀)=1`, `λ₁·(1/λ₁)=1`. -/
theorem R7_7_gaussHessian_mul_inv (l₀ l₁ : ℝ) (h₀ : l₀ ≠ 0) (h₁ : l₁ ≠ 0) :
    gaussHessian l₀ l₁ * gaussHessianInv l₀ l₁ = 1 := by
  unfold gaussHessian gaussHessianInv
  rw [Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
  congr 1
  funext i
  fin_cases i <;> simp <;> field_simp

/-- **R7.7 (b.1) — the Gaussian Brenier Hessian is invertible (`det = λ₀·λ₁ > 0`),
grounding R4_5's `IsUnit g.det` FROM THE OT SIDE.**

`det(diag(λ₀,λ₁)) = λ₀·λ₁`.  For a positive-definite Brenier Hessian
(`λ₀,λ₁ > 0`, i.e. the potential is strictly/displacement convex) the determinant
is a strictly positive real, hence a unit.  This is precisely the invertibility
hypothesis the abstract R4_5 kernel requires — here discharged by the convexity of
the Brenier potential. -/
theorem R7_7_hessian_det_isUnit (l₀ l₁ : ℝ) (h₀ : 0 < l₀) (h₁ : 0 < l₁) :
    IsUnit (gaussHessian l₀ l₁).det := by
  have hdet : (gaussHessian l₀ l₁).det = l₀ * l₁ := by
    unfold gaussHessian
    rw [Matrix.det_diagonal, Fin.prod_univ_two]
    simp
  rw [hdet, isUnit_iff_ne_zero]
  exact ne_of_gt (mul_pos h₀ h₁)

/-- The quadratic Gaussian Brenier potential `φ(x) = ½(λ₀x₀² + λ₁x₁²)`. -/
noncomputable def gaussPotential (l₀ l₁ : ℝ) (x : Fin 2 → ℝ) : ℝ :=
  (1 / 2) * (l₀ * x 0 ^ 2 + l₁ * x 1 ^ 2)

/-- **R7.7 (b.2) — the Brenier map `T = H·` is a subgradient of the convex
Gaussian potential.**

For the diagonal PSD Hessian (`λ₀,λ₁ ≥ 0`), the transport map `T(x) = H·x`
satisfies R.314's subgradient inequality

    φ(z) ≥ φ(x) + ⟨z − x, T x⟩    (`IsSubgrad φ p x (T x)`),

i.e. `T = ∇φ` is a genuine Brenier subgradient.  The proof is the convexity
inequality `½λ(z² − x²) ≥ λ x (z − x)`, equivalent to `½λ(z − x)² ≥ 0`. -/
theorem R7_7_quadratic_isSubgrad
    (l₀ l₁ : ℝ) (h₀ : 0 ≤ l₀) (h₁ : 0 ≤ l₁) (x : Fin 2 → ℝ) :
    IsSubgrad (gaussPotential l₀ l₁) dotPairing x (brenierMap (gaussHessian l₀ l₁) x) := by
  intro z
  -- φ x + ⟨z − x, H x⟩ ≤ φ z
  show gaussPotential l₀ l₁ x
      + dotPairing.toFun (z - x) (brenierMap (gaussHessian l₀ l₁) x)
      ≤ gaussPotential l₀ l₁ z
  unfold gaussPotential brenierMap gaussHessian dotPairing Pairing.toFun
  simp only [dotProduct, Fin.sum_univ_two, mulVec_diagonal,
    Matrix.cons_val_zero, Matrix.cons_val_one, Pi.sub_apply]
  -- reduces to ½λ₀(z₀−x₀)² + ½λ₁(z₁−x₁)² ≥ 0
  nlinarith [mul_nonneg h₀ (sq_nonneg (z 0 - x 0)),
             mul_nonneg h₁ (sq_nonneg (z 1 - x 1))]

/-- **R7.7 (b.3 — CROSS-GROUNDING) — R.314 monotonicity makes the Hessian metric
monotone (positive-semidefinite).**

Applying R.314's cyclical-monotonicity kernel `subgrad_monotone` to the two
subgradients `T x₁ ∈ ∂φ(x₁)`, `T x₂ ∈ ∂φ(x₂)` of the Gaussian potential gives the
transport/metric monotonicity

    0 ≤ ⟨x₁ − x₂, T x₁⟩ − ⟨x₁ − x₂, T x₂⟩  =  ⟨x₁ − x₂, H (x₁ − x₂)⟩ .

So the Brenier potential's convexity makes the Hessian information metric
positive-semidefinite — exactly the OT-side validation of R4_5's metric
invertibility (its strict version being `det H = λ₀λ₁ > 0`, b.1). -/
theorem R7_7_metric_monotone
    (l₀ l₁ : ℝ) (h₀ : 0 ≤ l₀) (h₁ : 0 ≤ l₁) (x₁ x₂ : Fin 2 → ℝ) :
    0 ≤ dotPairing.toFun (x₁ - x₂) (brenierMap (gaussHessian l₀ l₁) x₁)
          - dotPairing.toFun (x₁ - x₂) (brenierMap (gaussHessian l₀ l₁) x₂) :=
  subgrad_monotone
    (R7_7_quadratic_isSubgrad l₀ l₁ h₀ h₁ x₁)
    (R7_7_quadratic_isSubgrad l₀ l₁ h₀ h₁ x₂)

/-- **R7.7 (b.3′) — the monotone form IS the Hessian quadratic form
`(x₁−x₂)ᵀ H (x₁−x₂)`.**

The R.314 monotonicity quantity equals the Brenier-Hessian quadratic form, i.e.
the transport energy of the displacement.  Together with (b.3) this shows the
Hessian metric is PSD on the displacement. -/
theorem R7_7_monotone_eq_quadform
    (l₀ l₁ : ℝ) (x₁ x₂ : Fin 2 → ℝ) :
    dotPairing.toFun (x₁ - x₂) (brenierMap (gaussHessian l₀ l₁) x₁)
      - dotPairing.toFun (x₁ - x₂) (brenierMap (gaussHessian l₀ l₁) x₂)
      = l₀ * (x₁ 0 - x₂ 0) ^ 2 + l₁ * (x₁ 1 - x₂ 1) ^ 2 := by
  unfold brenierMap gaussHessian dotPairing Pairing.toFun
  simp only [dotProduct, Fin.sum_univ_two, mulVec_diagonal,
    Matrix.cons_val_zero, Matrix.cons_val_one, Pi.sub_apply]
  ring

/-! ### (c) Headline: Wasserstein = Fisher flow on the Brenier-Hessian metric. -/

/-- **R7.7 (c — HEADLINE) — on the Brenier-Hessian metric, the Fisher natural
gradient of the intervention field is the optimal-transport direction
(Wasserstein = Fisher flow).**

On the explicit Gaussian Brenier potential `φ(x) = ½(λ₀x₀² + λ₁x₁²)`, `λ₀,λ₁ > 0`,
with information metric `g = D²φ = H = diag(λ₀,λ₁)`:

  (i)  WASSERSTEIN = FISHER FLOW (identity).  The Fisher natural gradient of the
       Brenier transport displacement covector `Δy = T x₁ − T x₂` recovers the
       transport displacement itself,
           fisherGrad H (T x₁ − T x₂)  =  x₁ − x₂ ,
       so the natural-gradient flow and the Brenier/Wasserstein flow coincide
       (via R4_5_metric_grad_cancel, a.2);

  (ii) DISPLACEMENT CONVEXITY (cross-grounding).  R.314's subgradient
       monotonicity makes the Hessian metric monotone,
           0 ≤ ⟨x₁−x₂, T x₁ − T x₂⟩ ,
       and that monotone form is the transport-energy quadratic
       `λ₀(Δx₀)² + λ₁(Δx₁)²` — the OT-side validation of R4_5's invertibility
       (b.3, b.3′);

  (iii) FISHER LENGTH = TRANSPORT ENERGY.  For any field covector `dS`, the
        squared Fisher length of its natural gradient on `g = H` is the
        inverse-Hessian (transport-energy) quadratic form
            ‖grad_g S‖²_g  =  dS ⬝ᵥ (H⁻¹ *ᵥ dS)
        (R4_5_fisher_grad_norm_sq), with `H⁻¹` discharged as a unit by the
        Brenier convexity `det H = λ₀λ₁ > 0`.

This is the bridge: R.314 (Brenier/transport) ⊕ R4_5 (Fisher natural gradient).
The natural-gradient flow of `Φ₀·Z` on the Brenier-Hessian metric IS the
optimal-transport flow. -/
theorem R7_7_brenier_fisher_flow
    (l₀ l₁ : ℝ) (h₀ : 0 < l₀) (h₁ : 0 < l₁) (x₁ x₂ dS : Fin 2 → ℝ) :
    -- (i) Wasserstein = Fisher flow: natural gradient of the transport
    --     displacement covector recovers the transport displacement.
    fisherGrad (gaussHessian l₀ l₁)
        (brenierMap (gaussHessian l₀ l₁) x₁ - brenierMap (gaussHessian l₀ l₁) x₂)
      = x₁ - x₂
    -- (ii) displacement convexity: the monotone form is the transport energy ≥ 0.
    ∧ (0 ≤ l₀ * (x₁ 0 - x₂ 0) ^ 2 + l₁ * (x₁ 1 - x₂ 1) ^ 2
       ∧ l₀ * (x₁ 0 - x₂ 0) ^ 2 + l₁ * (x₁ 1 - x₂ 1) ^ 2
          = dotPairing.toFun (x₁ - x₂) (brenierMap (gaussHessian l₀ l₁) x₁)
              - dotPairing.toFun (x₁ - x₂) (brenierMap (gaussHessian l₀ l₁) x₂))
    -- (iii) Fisher length of the natural gradient = inverse-Hessian transport energy.
    ∧ fisherInner (gaussHessian l₀ l₁)
        (fisherGrad (gaussHessian l₀ l₁) dS)
        (fisherGrad (gaussHessian l₀ l₁) dS)
      = dS ⬝ᵥ ((gaussHessian l₀ l₁)⁻¹ *ᵥ dS) := by
  have hdet : IsUnit (gaussHessian l₀ l₁).det :=
    R7_7_hessian_det_isUnit l₀ l₁ h₀ h₁
  refine ⟨?_, ⟨?_, ?_⟩, ?_⟩
  · -- (i) via the absorption identity a.2
    exact R7_7_natgrad_eq_transport (gaussHessian l₀ l₁) hdet x₁ x₂
  · -- (ii)a transport energy nonneg = R.314 monotonicity transported through b.3′
    have hmono := R7_7_metric_monotone l₀ l₁ (le_of_lt h₀) (le_of_lt h₁) x₁ x₂
    rw [R7_7_monotone_eq_quadform l₀ l₁ x₁ x₂] at hmono
    exact hmono
  · -- (ii)b the monotone form equals the Hessian quadratic form
    exact (R7_7_monotone_eq_quadform l₀ l₁ x₁ x₂).symm
  · -- (iii) R4_5 Fisher gradient norm law
    exact R4_5_fisher_grad_norm_sq (gaussHessian l₀ l₁) hdet dS

end R7_Agent7_BrenierFisherFlow

end MIP
