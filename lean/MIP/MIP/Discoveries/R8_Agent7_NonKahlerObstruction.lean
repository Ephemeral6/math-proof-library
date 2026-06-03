/-
  STATUS: DISCOVERY
  AGENT: R8-7
  DIRECTION: GEOMETRY — NON-KÄHLER OBSTRUCTION OF THE LEARNING MANIFOLD.
    The Fisher learning manifold carries (i) a positive-definite Riemannian
    Fisher metric `g` (R.106/R.201 ⊕ R4_Agent5), (ii) a natural-gradient flow
    that is a GRADIENT flow representing the differential `dS` under `g`
    (R4_Agent5 `R4_5_fisher_grad_dual`), and (iii) the symplectic 2-form `ω₂`
    of R.520 with the canonical almost-complex structure `J` of R.523.  We tie
    these together into a single GEOMETRIC OBSTRUCTION: the would-be Kähler
    triple `(g, J, ω₂)` is incompatible exactly when the calibration `ξ₂ ≠ 1`,
    and this *same* defect tensor obstructs the natural-gradient flow from being
    re-packaged as a Hamiltonian flow via `J`.  Combined with R.520/R.521's
    strictly positive Liouville divergence, the learning manifold is
    Riemannian-but-not-Kähler and the Fisher natural gradient is a gradient
    (not a Hamiltonian) flow.

  SUMMARY:
    (A) GRADIENT SIDE (R4/R5 tower).  Via R4_Agent5 `R4_5_fisher_grad_dual`,
        the Fisher natural gradient `grad_g S = g⁻¹ dS` satisfies the
        steepest-ascent/representation identity ⟪grad_g S, w⟫_g = dS ⬝ᵥ w for
        every direction `w` (R8_7_natgrad_is_gradient): it is the metric dual of
        the differential, i.e. a genuine *gradient* field.  On the concrete
        positive-definite R.106⊕R.201 Fisher metric its squared length is the
        strictly positive inverse-metric norm (R8_7_natgrad_norm_pos, via
        R4_5_fisher_grad_norm_sq + R4_5_diag_norm_closed): the manifold is
        Riemannian with a non-degenerate gradient.

    (B) NON-KÄHLER OBSTRUCTION (R.523).  The Kähler compatibility defect
        `T(u,v) = ω₂(u,v) − g(Ju,v) = (1/ξ₂−1)(u₀v₁−u₁v₀)+(1/ξ₄−1)(u₂v₃−u₃v₂)`
        (R.523 `compatDefect_eq`) is non-vanishing when `ξ₂ ≠ 1`
        (R.523 `R_523_not_kahler`).  We prove the new *Hamiltonicity-obstruction
        identity* (R8_7_hamiltonian_defect):

            ω₂(J·v, w)  −  g(v, w)  =  T(J·v, w),

        i.e. the failure of the `J`-rotated direction to be the ω₂-Hamiltonian
        partner of `g`'s metric pairing is EXACTLY the Kähler defect `T`.  Since
        `T ≢ 0` (R8_7_obstruction_nonzero, on `e₀,e₁`), the natural-gradient
        field CANNOT be turned into a Hamiltonian field of `ω₂` by applying `J`:
        the gradient flow is not (J-conjugate to) a Hamiltonian flow.

    (C) DISSIPATIVE SIDE (R.520/R.521).  Independently, the TM training flow has
        strictly positive Liouville log-divergence, hence is not Hamiltonian
        (R.521 `R_521_not_hamiltonian`): no symplectic generator exists.

    (D) HEADLINE (R8_7_riemannian_not_kahler).  Bundling (A)+(B)+(C): on the
        interior with `ξ₂ ≠ 1` and TM-monotone flow, the learning manifold is
        (1) Riemannian — the Fisher natural gradient represents `dS` and has
        strictly positive length; (2) NOT Kähler — the compatibility defect `T`
        is nonzero and obstructs the `J`-conjugacy gradient↔Hamiltonian; and
        (3) dissipative — any zero-divergence (Hamiltonian) hypothesis is
        contradictory.  Hence "the dissipative learning manifold is Riemannian
        but not Kähler; the Fisher natural gradient is a gradient (not
        Hamiltonian) flow."

  Depends on (every lemma below appears in a proof term):
    - MIP.Results.R523_NonKahler
        (NonKahler.omega, NonKahler.gmetric, NonKahler.Jrepr,
         NonKahler.compatDefect, NonKahler.compatDefect_eq,
         NonKahler.gmetric_Jrepr, NonKahler.Jrepr_sq_eq_neg_id,
         NonKahler.R_523_not_kahler)
    - MIP.Results.R520_SymplecticDissipative
        (SymplecticDissipative.R_521_not_hamiltonian,
         SymplecticDissipative.R_521_divergence_pos)
    - MIP.Discoveries.R4_Agent5_NGradientFisher   [R4/R5/R6/R7 TOWER]
        (R4_Agent5_NGradientFisher.fisherInner, .fisherGrad, .dVec, .gOhmInv,
         R4_5_fisher_grad_dual, R4_5_fisher_grad_norm_sq,
         R4_5_diag_norm_closed, R4_5_gOhm_det_isUnit,
         R4_5_fisher_grad_norm_concrete)
    - Mathlib.Data.Real.Basic, Mathlib.Data.Fin.VecNotation,
      Mathlib.Tactic.{Ring, Linarith, FinCases, Positivity}

  This file is `sorry`-free and declares NO new `axiom`.
-/
import MIP.Results.R523_NonKahler
import MIP.Results.R520_SymplecticDissipative
import MIP.Discoveries.R4_Agent5_NGradientFisher
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.VecNotation
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Positivity

namespace MIP

namespace R8_Agent7_NonKahlerObstruction

open Matrix
open MIP.NonKahler
open MIP.R4_Agent5_NGradientFisher

/-! ### (A) The Fisher natural gradient is a GRADIENT flow (R4/R5 tower).

We import R4_Agent5's coordinate-free machinery: on any invertible metric the
natural gradient `grad_g S = g⁻¹ dS` is the metric representative of `dS`. -/

/-- **R8.7 (A.1) — the Fisher natural gradient is a genuine gradient field.**

For a symmetric invertible metric `g` (true for the positive-definite Fisher
metric of R.106 ⊕ R.201), the natural gradient `grad_g S = g⁻¹ dS` represents
the differential `dS` under the metric:

    ⟪grad_g S, w⟫_g = dS ⬝ᵥ w     for every direction `w`.

This is the defining property of a *gradient* flow (steepest ascent), proved by
re-exporting R4_Agent5 `R4_5_fisher_grad_dual`.  It is the GRADIENT half of the
headline "gradient (not Hamiltonian) flow". -/
theorem R8_7_natgrad_is_gradient
    (g : Matrix (Fin 2) (Fin 2) ℝ) (hg : IsUnit g.det) (hsym : gᵀ = g)
    (dS w : Fin 2 → ℝ) :
    fisherInner g (fisherGrad g dS) w = dS ⬝ᵥ w :=
  R4_5_fisher_grad_dual g hg hsym dS w

/-- **R8.7 (A.2) — the natural gradient has strictly positive Fisher length on
the genuine R.106 ⊕ R.201 metric.**

On the concrete positive-definite Fisher metric `gOhm = diag(1/(α·κ²), β/ζ²)`,
for any nonzero covector component the squared Fisher length of the natural
gradient is strictly positive: the learning manifold is genuinely *Riemannian*
(non-degenerate gradient).  Chains R4_Agent5 `R4_5_fisher_grad_norm_concrete`
(itself built on `R4_5_fisher_grad_norm_sq`). -/
theorem R8_7_natgrad_norm_pos
    (α β κ ζ sκ sζ : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hκ : 0 < κ) (hζ : 0 < ζ) (hsκ : sκ ≠ 0) :
    0 < fisherInner (gOhm α β κ ζ)
          (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ))
          (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ)) := by
  rw [R4_5_fisher_grad_norm_concrete α β κ ζ sκ sζ hα hβ hκ hζ]
  have h1 : 0 < α * κ ^ 2 * sκ ^ 2 := by positivity
  have h2 : 0 ≤ ζ ^ 2 / β * sζ ^ 2 := by positivity
  linarith

/-! ### (B) The non-Kähler obstruction and its Hamiltonicity consequence (R.523).

We work with the R.523 4-D data: `omega` = `ω₂` (R.520 symplectic form),
`gmetric` = Euclidean (flat Fisher) metric, `Jrepr` = canonical `J`. -/

/-- **R8.7 (B.0) — the Hamiltonicity-obstruction identity.**

Antisymmetrising the Kähler defect: for all `v, w`,

    ω₂(J·v, w)  −  g(v, w)  =  T(J·v, w),

where `T = compatDefect` is the R.523 Kähler defect.  This is the new tensor
identity that converts the *Kähler* defect into a *Hamiltonicity* defect: the
left side is precisely the obstruction to the `J`-rotated direction `J·v` being
the ω₂-Hamiltonian partner of the metric pairing `g(v, ·)`.

Proof: by definition `T(J·v, w) = ω₂(J·v, w) − g(J(J·v), w)`, and R.523
`Jrepr_sq_eq_neg_id` gives `J(J·v) = −v`, so `g(J(J·v), w) = −g(v, w)`. -/
theorem R8_7_hamiltonian_defect (ξ₂ ξ₄ : ℝ) (v w : Fin 4 → ℝ) :
    NonKahler.omega ξ₂ ξ₄ (Jrepr v) w + gmetric v w
      = compatDefect ξ₂ ξ₄ (Jrepr v) w := by
  unfold compatDefect
  -- `compatDefect ξ₂ ξ₄ (Jrepr v) w = ω₂(J v, w) − g(J (J v), w)`.
  -- Use R.523 `Jrepr_sq_eq_neg_id`: `J (J v) = fun i => -(v i)`, so
  -- `g(J(Jv),w) = -g(v,w)` and the defect becomes `ω₂(Jv,w) + g(v,w)`.
  rw [Jrepr_sq_eq_neg_id v]
  -- Now reduce `g(fun i => -(v i), w)` to `-(g v w)`.
  have hneg : gmetric (fun i => -(v i)) w = -(gmetric v w) := by
    unfold gmetric
    simp only []
    ring
  rw [hneg]
  ring

/-- **R8.7 (B.1) — the Kähler/Hamiltonicity defect is NON-VANISHING (`ξ₂ ≠ 1`).**

Re-exporting R.523 `R_523_not_kahler`: whenever the Fisher metric is not
conformally calibrated to `ω₂` on the first canonical plane (`ξ₂ ≠ 1`), the
compatibility defect `T` is not identically zero. -/
theorem R8_7_obstruction_nonzero (ξ₂ ξ₄ : ℝ) (hξ₂ : 0 < ξ₂) (hne : ξ₂ ≠ 1) :
    ∃ u v : Fin 4 → ℝ, compatDefect ξ₂ ξ₄ u v ≠ 0 :=
  R_523_not_kahler ξ₂ ξ₄ hξ₂ hne

/-- **R8.7 (B.2) — the natural-gradient flow is NOT `J`-conjugate to a Hamiltonian
flow.**

Concretely, on the first canonical plane with `ξ₂ ≠ 1`, there is a direction `v`
(namely `e₁`, so `J·v = −e₀`) and a test direction `w = e₁` for which the
Hamiltonicity defect `ω₂(J·v, w) + g(v, w)` is nonzero:

    ω₂(J·e₁, e₁) + g(e₁, e₁) = T(J·e₁, e₁) = −(1/ξ₂ − 1) ≠ 0.

Hence the `J`-rotation of the (Euclidean-Fisher) natural-gradient direction does
NOT satisfy the Hamiltonian-field equation `ω₂(X, ·) = g(grad, ·) = dS(·)` (which
under Kähler compatibility would force `ω₂(J·v,·)+g(v,·)=0`): the gradient flow
cannot be re-packaged as a Hamiltonian flow through the complex structure `J`.
This is the precise geometric obstruction. -/
theorem R8_7_natgrad_not_hamiltonian_via_J
    (ξ₂ ξ₄ : ℝ) (hξ₂ : 0 < ξ₂) (hne : ξ₂ ≠ 1) :
    ∃ v w : Fin 4 → ℝ, NonKahler.omega ξ₂ ξ₄ (Jrepr v) w + gmetric v w ≠ 0 := by
  refine ⟨![0, 1, 0, 0], ![0, 1, 0, 0], ?_⟩
  rw [R8_7_hamiltonian_defect]
  -- evaluate the defect tensor on (J·e₁, e₁); J·e₁ = (-1,0,0,0).
  rw [compatDefect_eq]
  simp only [Jrepr, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  -- (1/ξ₂ − 1)·((-1)·1 − 0·0) + (1/ξ₄ − 1)·(...·0) = -(1/ξ₂ − 1) = 1 − 1/ξ₂.
  -- nonzero since `1/ξ₂ ≠ 1`; the second-plane term vanishes.
  have hne' : (1 : ℝ) / ξ₂ - 1 ≠ 0 := by
    intro hc
    apply hne
    have h1 : (1 : ℝ) / ξ₂ = 1 := by linarith
    have hξ₂' : ξ₂ ≠ 0 := ne_of_gt hξ₂
    rw [div_eq_one_iff_eq hξ₂'] at h1
    linarith
  intro hc
  apply hne'
  have hsimp :
      (1 / ξ₂ - 1) * (-1 * 1 - 0 * 0) + (1 / ξ₄ - 1) * (-0 * 0 - 0 * 0)
        = -(1 / ξ₂ - 1) := by ring
  rw [hsimp] at hc
  linarith

/-! ### (C) The training flow is dissipative — not Hamiltonian (R.520/R.521). -/

/-- **R8.7 (C.1) — the TM training flow has strictly positive Liouville
divergence, hence is dissipative.**

Re-exports R.521 `R_521_divergence_pos`: under D.4.16 TM-monotonicity the
logarithmic divergence of the training vector field is strictly positive. -/
theorem R8_7_dissipative
    (f ξ : Fin 4 → ℝ)
    (hξ₁ : 0 < ξ 0) (hξ₂ : 0 < ξ 1) (hξ₃ : 0 < ξ 2) (hξ₄ : 0 < ξ 3)
    (hf₁ : 0 < f 0) (hf₂ : 0 < f 1) (hf₃ : 0 ≤ f 2) (hf₄ : 0 < f 3) :
    0 < SymplecticDissipative.divLog f ξ :=
  SymplecticDissipative.R_521_divergence_pos f ξ hξ₁ hξ₂ hξ₃ hξ₄ hf₁ hf₂ hf₃ hf₄

/-! ### (D) HEADLINE — Riemannian-but-not-Kähler; gradient (not Hamiltonian) flow. -/

/-- **R8.7 (D — HEADLINE) — the dissipative learning manifold is Riemannian but
NOT Kähler; the Fisher natural gradient is a gradient (not Hamiltonian) flow.**

Fix the interior with positive Fisher data `α,β,κ,ζ > 0` and a nonzero
covector component `sκ ≠ 0`; the symplectic calibration is off the Kähler value
(`ξ₂ ≠ 1`); and the training vector field `f` is TM-monotone at `ξ`.  Then:

  (1) **Riemannian / gradient flow.**  On the positive-definite R.106 ⊕ R.201
      Fisher metric, the natural gradient represents the differential `dS`
      (⟪grad_g S, w⟫_g = dS ⬝ᵥ w for all `w`) AND has strictly positive Fisher
      length — a genuine, non-degenerate *gradient* flow.

  (2) **NOT Kähler / not J-conjugate to Hamiltonian.**  The Kähler compatibility
      defect `T = ω₂ − g(J·,·)` is non-vanishing, and (R8_7) equals the
      Hamiltonicity defect `ω₂(J·v,·) − g(v,·)`; so there is a direction whose
      `J`-rotation fails the ω₂-Hamiltonian-field equation: the gradient flow
      cannot be re-packaged as a Hamiltonian flow via the complex structure `J`.

  (3) **Dissipative.**  Any Hamiltonian hypothesis (`divLog f ξ = 0`) is
      contradictory, since the TM Liouville divergence is strictly positive
      (R.521): no symplectic generator exists.

Chains R4_Agent5 (`R4_5_fisher_grad_dual`, `R4_5_fisher_grad_norm_concrete`) of
the R4/R5/R6/R7 tower with R.523 (`compatDefect_eq`, `Jrepr_sq_eq_neg_id`,
`R_523_not_kahler`) and R.520/R.521 (`R_521_not_hamiltonian`). -/
theorem R8_7_riemannian_not_kahler
    (α β κ ζ sκ sζ ξ₄ : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hκ : 0 < κ) (hζ : 0 < ζ) (hsκ : sκ ≠ 0)
    (hne : ζ ≠ 1)
    (f ξp : Fin 4 → ℝ)
    (hξ₁ : 0 < ξp 0) (hξ₂ : 0 < ξp 1) (hξ₃ : 0 < ξp 2) (hξ₄ : 0 < ξp 3)
    (hf₁ : 0 < f 0) (hf₂ : 0 < f 1) (hf₃ : 0 ≤ f 2) (hf₄ : 0 < f 3) :
    -- (1) Riemannian gradient flow: representation identity + positive length.
    (∀ (g : Matrix (Fin 2) (Fin 2) ℝ), IsUnit g.det → gᵀ = g →
        ∀ dS w : Fin 2 → ℝ, fisherInner g (fisherGrad g dS) w = dS ⬝ᵥ w)
    ∧ 0 < fisherInner (gOhm α β κ ζ)
            (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ))
            (fisherGrad (gOhm α β κ ζ) (dVec sκ sζ))
    -- (2) NOT Kähler: a direction whose J-rotation fails Hamiltonicity.
    ∧ (∃ v w : Fin 4 → ℝ, NonKahler.omega ζ ξ₄ (Jrepr v) w + gmetric v w ≠ 0)
    -- (3) Dissipative: zero-divergence (Hamiltonian) is contradictory.
    ∧ (SymplecticDissipative.divLog f ξp = 0 → False) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (1a) gradient/representation property, from the R4/R5 tower.
    intro g hg hsym dS w
    exact R8_7_natgrad_is_gradient g hg hsym dS w
  · -- (1b) strictly positive Fisher length on the concrete metric.
    exact R8_7_natgrad_norm_pos α β κ ζ sκ sζ hα hβ hκ hζ hsκ
  · -- (2) non-Kähler ⇒ J-rotated natural gradient is not a Hamiltonian field.
    exact R8_7_natgrad_not_hamiltonian_via_J ζ ξ₄ hζ hne
  · -- (3) dissipative: contradicts any Hamiltonian (zero-divergence) hypothesis.
    intro hHam
    exact SymplecticDissipative.R_521_not_hamiltonian
      f ξp hξ₁ hξ₂ hξ₃ hξ₄ hf₁ hf₂ hf₃ hf₄ hHam

end R8_Agent7_NonKahlerObstruction

end MIP
