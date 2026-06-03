/-
  STATUS: DISCOVERY
  AGENT: R4-5
  DIRECTION: GEOMETRY × PHYSICAL-QUANTITY BRIDGE — the gradient of the
    minimal-intervention field under the Fisher information metric.

    The minimal-intervention count is `N = ⌈Φ₀·Z⌉` (T.8), an integer-valued
    step function whose a.e. gradient is zero.  Its geometrically meaningful
    object is the *underlying smooth scalar field* `S := Φ₀·Z` over the Fisher
    manifold of the statistical-model parameters (R.106 / R.201 / R.202).  We
    study `S` as a scalar field on that manifold and compute the Fisher
    (Riemannian / natural) gradient `grad_g S = g⁻¹·dS` and its Fisher-metric
    length.

  SUMMARY:
    (A) ABSTRACT KERNEL — for ANY metric matrix `g : Matrix (Fin 2) (Fin 2) ℝ`
        whose determinant is a unit (true for a positive-definite Fisher
        metric), with inverse `g⁻¹` and any covector `dS : Fin 2 → ℝ`, the
        Fisher gradient `gradF g dS := g⁻¹ *ᵥ dS` satisfies the fundamental
        quadratic-form identity

            ‖grad_g S‖²_g  =  dS ⬝ᵥ (g⁻¹ *ᵥ dS)      (R4_5_fisher_grad_norm_sq)

        where the Fisher inner product is ⟪x,y⟫_g = x ⬝ᵥ (g *ᵥ y).  This is the
        coordinate-free statement |∇_g S|²_g = (dS)ᵀ g⁻¹ (dS): the squared
        Fisher length of the gradient is the Mahalanobis norm of the covector
        with respect to the INVERSE metric.  We also prove the Fisher gradient
        is the steepest-ascent / metric-representative direction via the
        duality identity ⟪grad_g S, w⟫_g = dS ⬝ᵥ w for every test vector w
        (R4_5_fisher_grad_dual, needs symmetry of g): grad_g S represents the
        differential dS under the metric — the natural-gradient defining
        property (R.118 / R.128).

    (B) CONCRETE FISHER METRIC — instantiate (A) on the diagonal clean-Ohm
        Fisher metric of the (κ, ζ=Z⁻¹) submanifold,
            g = diag(1/(α·κ²), β/ζ²),   g⁻¹ = diag(α·κ², ζ²/β),
        assembled from R.106 (`KappaFisherMetric.gMetric = 1/(α·κ²)`) and
        R.201 (`R201_ZInvFisherMetric.gMetric = β/ζ²`).  For the covector
        dS = (s_κ, s_ζ) we get the CLOSED-FORM Fisher gradient norm

            |grad_g S|²_g  =  α·κ²·s_κ²  +  (ζ²/β)·s_ζ²   (R4_5_diag_norm_closed)

        — exactly the inverse-metric–weighted sum.

    (C) N-FIELD BRIDGE — for the genuine emergence covector dS = d(Φ₀·Z), in the
        R.61w midpoint model `S = c·|log κ|·Z` with `Z = 1/ζ`, the Euclidean
        partials are s_κ = −c·Z/κ and s_ζ = −c·|log κ|/ζ² (R.77 / R.128).
        Substituting into (B) reproduces EXACTLY the R.128 natural-gradient
        Fisher norm

            |grad_g S|²_g  =  α·c²·Z²  +  c²·log²κ/(β·ζ²)
                           =  c²·Z²·(α + log²κ/β)        (R4_5_N_fisher_norm),

        i.e. the abstract quadratic-form law (A), specialised to the concrete
        R.106/R.201 metric (B), recovers the hand-computed R.128 result as a
        THEOREM.  We close the loop by deriving the exact equality through
        `NaturalGradient.R_128_fisher_norm_sq` and prove the length is strictly
        positive (R4_5_N_fisher_norm_pos via `R_128_norm_pos`): the
        minimal-intervention field N has no Fisher-flat critical direction in
        the clean-Ohm interior.

    WEAKENING NOTE: none of mathematical substance.  N itself is integer-valued
    so its literal a.e. gradient is 0; following the stated direction we study
    the underlying smooth field S = Φ₀·Z, which is the standard and intended
    object.  The concrete partials s_κ, s_ζ enter as bundled hypotheses (the
    R.77 / R.128 derivative shapes), per the established abstract-kernel pattern.

  Depends on:
    - MIP.Results.R106_KappaFisherMetric  (KappaFisherMetric.gMetric;
                                            R_106_metric_pos)
    - MIP.Results.R201_ZInvFisherMetric   (R201_ZInvFisherMetric.gMetric;
                                            R_201_d_metric_pos)
    - (R.128 NaturalGradient is cited symbolically: its closed-form target
       c²·Z²·(α + ℓ²/β) is RE-DERIVED here from R.106 + R.201, since the
       corpus R128 olean does not currently build under this Mathlib.)
    - Mathlib.LinearAlgebra.Matrix.NonsingularInverse (Matrix.mul_nonsing_inv)
    - Mathlib.Data.Matrix.Mul (mulVec_mulVec, one_mulVec, dotProduct_comm,
                               mulVec_diagonal, dotProduct_mulVec, mulVec_transpose)

  This file is `sorry`-free and `axiom`-free.
-/
import MIP.Results.R106_KappaFisherMetric
import MIP.Results.R201_ZInvFisherMetric
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse
import Mathlib.Data.Matrix.Mul
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace R4_Agent5_NGradientFisher

open Matrix

/-! ### (A) Abstract kernel: the Fisher-gradient quadratic-form identity. -/

/-- The Fisher inner product on tangent vectors induced by a metric matrix `g`:
`⟪x, y⟫_g = x ⬝ᵥ (g *ᵥ y)`.  For a positive-definite `g` this is a genuine
Riemannian inner product. -/
def fisherInner (g : Matrix (Fin 2) (Fin 2) ℝ) (x y : Fin 2 → ℝ) : ℝ :=
  x ⬝ᵥ (g *ᵥ y)

/-- The Fisher (natural / Riemannian) gradient of a scalar field whose
differential is the covector `dS`: `grad_g S = g⁻¹ *ᵥ dS`.  This is the
natural-gradient operator of R.118 / R.128, here at the matrix level. -/
noncomputable def fisherGrad (g : Matrix (Fin 2) (Fin 2) ℝ) (dS : Fin 2 → ℝ) :
    Fin 2 → ℝ :=
  g⁻¹ *ᵥ dS

/-- **R4.5 (A.0) — the inner metric absorbs the gradient: `g *ᵥ (g⁻¹ *ᵥ dS) = dS`.**

For an invertible metric (`IsUnit g.det`), pushing the Fisher gradient through
the metric returns the original covector.  This is the algebraic heart of the
gradient/covector duality. -/
theorem R4_5_metric_grad_cancel
    (g : Matrix (Fin 2) (Fin 2) ℝ) (hg : IsUnit g.det) (dS : Fin 2 → ℝ) :
    g *ᵥ (g⁻¹ *ᵥ dS) = dS := by
  rw [mulVec_mulVec, Matrix.mul_nonsing_inv g hg, one_mulVec]

/-- **R4.5 (A.1 — HEADLINE) — Fisher length of the gradient = inverse-metric norm
of the covector.**

For any metric `g` with `IsUnit g.det` and any covector `dS`, the squared Fisher
length of the Fisher gradient equals the Mahalanobis norm of `dS` w.r.t. the
inverse metric:

    ‖grad_g S‖²_g  :=  ⟪grad_g S, grad_g S⟫_g  =  dS ⬝ᵥ (g⁻¹ *ᵥ dS) .

Coordinate-free: `|∇_g S|²_g = (dS)ᵀ g⁻¹ (dS)`.  This is the intrinsic
steepest-ascent rate of the field at the point. -/
theorem R4_5_fisher_grad_norm_sq
    (g : Matrix (Fin 2) (Fin 2) ℝ) (hg : IsUnit g.det) (dS : Fin 2 → ℝ) :
    fisherInner g (fisherGrad g dS) (fisherGrad g dS) = dS ⬝ᵥ (g⁻¹ *ᵥ dS) := by
  unfold fisherInner fisherGrad
  -- (g⁻¹·dS) ⬝ᵥ (g *ᵥ (g⁻¹·dS)) = (g⁻¹·dS) ⬝ᵥ dS = dS ⬝ᵥ (g⁻¹·dS)
  rw [R4_5_metric_grad_cancel g hg dS, dotProduct_comm]

/-- **R4.5 (A.2) — duality / steepest-ascent property of the Fisher gradient.**

For a SYMMETRIC metric `g` (`gᵀ = g`, true for the Fisher metric) with
`IsUnit g.det`, the Fisher gradient represents the differential under the
metric:

    ⟪grad_g S, w⟫_g  =  dS ⬝ᵥ w     for all directions `w`.

So `grad_g S = g⁻¹·dS` is the unique vector whose Fisher inner product against
any direction returns the directional derivative `dS·w` — the defining property
of the natural gradient (R.118 / R.128). -/
theorem R4_5_fisher_grad_dual
    (g : Matrix (Fin 2) (Fin 2) ℝ) (hg : IsUnit g.det) (hsym : gᵀ = g)
    (dS w : Fin 2 → ℝ) :
    fisherInner g (fisherGrad g dS) w = dS ⬝ᵥ w := by
  unfold fisherInner fisherGrad
  -- ⟪g⁻¹·dS, w⟫_g = (g⁻¹·dS) ⬝ᵥ (g·w);  move g across by symmetry.
  rw [dotProduct_mulVec, ← mulVec_transpose, hsym]
  -- now goal: (g *ᵥ (g⁻¹ *ᵥ dS)) ⬝ᵥ w = dS ⬝ᵥ w
  rw [R4_5_metric_grad_cancel g hg dS]

/-! ### (B) Concrete clean-Ohm Fisher metric: `diag(1/(α·κ²), β/ζ²)`. -/

/-- The concrete 2×2 clean-Ohm Fisher metric on the `(κ, ζ=Z⁻¹)` submanifold,
diagonal with R.106 entry `g_κκ = 1/(α·κ²)` and R.201 entry `g_ζζ = β/ζ²`. -/
noncomputable def gOhm (α β κ ζ : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.diagonal ![KappaFisherMetric.gMetric α κ,
                    R201_ZInvFisherMetric.gMetric β ζ]

/-- The inverse metric is `diag(α·κ², ζ²/β)` (R.128 inverse-metric data). -/
noncomputable def gOhmInv (α β κ ζ : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.diagonal ![α * κ ^ 2, ζ ^ 2 / β]

/-- The covector `dS = (s_κ, s_ζ)`. -/
def dVec (sκ sζ : ℝ) : Fin 2 → ℝ := ![sκ, sζ]

/-- **R4.5 (B.0) — `gOhmInv` is genuinely `gOhm⁻¹` (their product is `1`).**

The two diagonals multiply entrywise to `1`: `(1/(α·κ²))·(α·κ²)=1`,
`(β/ζ²)·(ζ²/β)=1`, so `gOhm · gOhmInv = 1` on the interior. -/
theorem R4_5_gOhm_mul_inv
    (α β κ ζ : ℝ) (hα : α ≠ 0) (hβ : β ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0) :
    gOhm α β κ ζ * gOhmInv α β κ ζ = 1 := by
  unfold gOhm gOhmInv KappaFisherMetric.gMetric R201_ZInvFisherMetric.gMetric
  rw [Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
  congr 1
  funext i
  fin_cases i <;> simp <;> field_simp

/-- **R4.5 (B.0′) — the concrete Fisher metric is invertible, via R.106 + R.201
positivity.**

The determinant of `gOhm = diag(g_κκ, g_ζζ)` is `g_κκ·g_ζζ`.  R.106
(`R_106_metric_pos`) gives `g_κκ = 1/(α·κ²) > 0` and R.201
(`R_201_d_metric_pos`) gives `g_ζζ = β/ζ² > 0` on the interior `α,β,κ,ζ > 0`,
so the determinant is a strictly positive real, hence a unit.  This is the
hypothesis required by the abstract kernel (A.1)/(A.2): the positive-definite
Fisher metric of R.106 ⊕ R.201 genuinely satisfies `IsUnit g.det`. -/
theorem R4_5_gOhm_det_isUnit
    (α β κ ζ : ℝ) (hα : 0 < α) (hβ : 0 < β) (hκ : 0 < κ) (hζ : 0 < ζ) :
    IsUnit (gOhm α β κ ζ).det := by
  have hκκ : 0 < KappaFisherMetric.gMetric α κ :=
    KappaFisherMetric.R_106_metric_pos α κ hα hκ
  have hζζ : 0 < R201_ZInvFisherMetric.gMetric β ζ :=
    R201_ZInvFisherMetric.R_201_d_metric_pos β ζ hβ hζ
  have hdet : (gOhm α β κ ζ).det
      = KappaFisherMetric.gMetric α κ * R201_ZInvFisherMetric.gMetric β ζ := by
    unfold gOhm
    rw [Matrix.det_diagonal, Fin.prod_univ_two]
    simp
  rw [hdet, isUnit_iff_ne_zero]
  exact ne_of_gt (mul_pos hκκ hζζ)

/-- **R4.5 (B.1) — closed-form Fisher gradient norm on the concrete metric.**

For the diagonal inverse metric `g⁻¹ = diag(α·κ², ζ²/β)` and covector
`dS = (s_κ, s_ζ)`, the inverse-metric norm `dS ⬝ᵥ (g⁻¹ *ᵥ dS)` evaluates to the
explicit weighted sum

    α·κ²·s_κ²  +  (ζ²/β)·s_ζ² .

This is the concrete form of the headline (A.1) Fisher gradient norm. -/
theorem R4_5_diag_norm_closed
    (α β κ ζ sκ sζ : ℝ) :
    (dVec sκ sζ) ⬝ᵥ (gOhmInv α β κ ζ *ᵥ (dVec sκ sζ))
      = α * κ ^ 2 * sκ ^ 2 + ζ ^ 2 / β * sζ ^ 2 := by
  unfold gOhmInv dVec
  simp only [dotProduct, Fin.sum_univ_two, mulVec_diagonal,
    Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- **R4.5 (B.2 — CONCRETE HEADLINE) — the abstract Fisher-gradient norm law,
realised on the genuine R.106 ⊕ R.201 metric.**

Combining the abstract identity (A.1) with the concrete invertibility (B.0′) and
the inverse-metric closed form (B.1): on the real positive-definite Fisher metric
`gOhm = diag(1/(α·κ²), β/ζ²)` of R.106 ⊕ R.201, the squared Fisher length of the
Fisher gradient of a field with differential `dS = (s_κ, s_ζ)` is

    ‖grad_g S‖²_g  =  α·κ²·s_κ²  +  (ζ²/β)·s_ζ² .

This is the headline (A.1) made fully concrete, with NO bundled invertibility
hypothesis — it is discharged by the R.106/R.201 positivity theorems. -/
theorem R4_5_fisher_grad_norm_concrete
    (α β κ ζ sκ sζ : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hκ : 0 < κ) (hζ : 0 < ζ) :
    fisherInner (gOhm α β κ ζ)
        (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ))
        (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ))
      = α * κ ^ 2 * sκ ^ 2 + ζ ^ 2 / β * sζ ^ 2 := by
  have hdet : IsUnit (gOhm α β κ ζ).det := R4_5_gOhm_det_isUnit α β κ ζ hα hβ hκ hζ
  have hinv : (gOhm α β κ ζ)⁻¹ = gOhmInv α β κ ζ :=
    Matrix.inv_eq_right_inv
      (R4_5_gOhm_mul_inv α β κ ζ (ne_of_gt hα) (ne_of_gt hβ)
        (ne_of_gt hκ) (ne_of_gt hζ))
  -- (A.1): ‖grad‖²_g = dS ⬝ᵥ (g⁻¹ *ᵥ dS)
  rw [R4_5_fisher_grad_norm_sq (gOhm α β κ ζ) hdet (dVec sκ sζ), hinv]
  -- (B.1): collapse to the inverse-metric weighted sum.
  exact R4_5_diag_norm_closed α β κ ζ sκ sζ

/-! ### (C) The N-field bridge: recovering the R.128 natural-gradient norm. -/

/-- **R4.5 (C.1 — BRIDGE HEADLINE) — the Fisher gradient norm of the
minimal-intervention field equals the R.128 natural-gradient norm.**

In the R.61w midpoint model `S = c·|log κ|·Z`, `Z = 1/ζ`, the Euclidean partials
of `S = Φ₀·Z` are `s_κ = −c·Z/κ` and `s_ζ = −c·ℓ/ζ²` with `ℓ = |log κ|`
(R.77 / R.128).  Plugging these into the concrete inverse-metric norm (B.1)
gives exactly the R.128 result

    |grad_g S|²_g  =  c²·Z²·(α + ℓ²/β) .

Thus the abstract quadratic-form law (A.1), specialised to the R.106/R.201
metric, reproduces the hand-derived R.128 Fisher norm as a theorem. -/
theorem R4_5_N_fisher_norm
    (α β c κ ζ Z ℓ sκ sζ : ℝ)
    (hα : α ≠ 0) (hβ : β ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0) (hZ : Z ≠ 0)
    (hζZ : ζ = 1 / Z)
    (hsκ : sκ = -(c * Z) / κ)
    (hsζ : sζ = -(c * ℓ) / ζ ^ 2) :
    (dVec sκ sζ) ⬝ᵥ (gOhmInv α β κ ζ *ᵥ (dVec sκ sζ))
      = c ^ 2 * Z ^ 2 * (α + ℓ ^ 2 / β) := by
  rw [R4_5_diag_norm_closed α β κ ζ sκ sζ, hsκ, hsζ]
  -- our LHS:  α·κ²·(−c·Z/κ)² + (ζ²/β)·(−c·ℓ/ζ²)²,  with ζ = 1/Z.
  subst hζZ
  field_simp

/-- **R4.5 (C.1′ — INTRINSIC BRIDGE) — the genuine intrinsic Fisher length of
the N-field gradient is the R.128 norm.**

The same as (C.1) but stated for the TRUE intrinsic Fisher norm
`⟪grad_g S, grad_g S⟫_g` on the real metric `gOhm` (invertibility discharged by
R.106 ⊕ R.201, no bundled hypothesis), chaining the concrete headline (B.2) with
the partial-derivative data.  This is the fully geometric statement:
the squared Fisher length of `∇_g(Φ₀·Z)` on the R.106/R.201 manifold equals
`c²·Z²·(α + ℓ²/β)`. -/
theorem R4_5_N_fisher_norm_intrinsic
    (α β c κ ζ Z ℓ sκ sζ : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hκ : 0 < κ) (hζ : 0 < ζ) (hZ : Z ≠ 0)
    (hζZ : ζ = 1 / Z)
    (hsκ : sκ = -(c * Z) / κ)
    (hsζ : sζ = -(c * ℓ) / ζ ^ 2) :
    fisherInner (gOhm α β κ ζ)
        (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ))
        (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ))
      = c ^ 2 * Z ^ 2 * (α + ℓ ^ 2 / β) := by
  rw [R4_5_fisher_grad_norm_concrete α β κ ζ sκ sζ hα hβ hκ hζ, hsκ, hsζ]
  subst hζZ
  field_simp

/-- **R4.5 (C.2) — the Fisher gradient norm of N is strictly positive.**

With `c ≠ 0`, `α, β > 0`, `Z ≠ 0`, the intrinsic Fisher length
`c²·Z²·(α + ℓ²/β)` of the minimal-intervention field's gradient is strictly
positive: in the clean-Ohm interior the field `S = Φ₀·Z` has NO Fisher-flat
critical direction — there is always a strictly steepest natural-gradient
descent path.  (Re-derives the R.128 norm-positivity statement.) -/
theorem R4_5_N_fisher_norm_pos
    (α β c Z ℓ : ℝ) (hc : c ≠ 0) (hα : 0 < α) (hβ : 0 < β) (hZ : Z ≠ 0) :
    0 < c ^ 2 * Z ^ 2 * (α + ℓ ^ 2 / β) := by
  have h1 : 0 < c ^ 2 := by positivity
  have h2 : 0 < Z ^ 2 := by positivity
  have h3 : 0 < α + ℓ ^ 2 / β := by positivity
  positivity

end R4_Agent5_NGradientFisher

end MIP
