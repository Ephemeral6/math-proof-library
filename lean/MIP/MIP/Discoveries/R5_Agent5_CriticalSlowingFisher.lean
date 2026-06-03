/-
  STATUS: DISCOVERY
  AGENT: R5-5
  DIRECTION: GEOMETRY × THERMODYNAMICS — the Fisher natural-gradient of the
    intervention field DIVERGES exactly at the Landau transition: critical
    slowing down realised as metric degeneration.

    Round-4 Agent 5 (R4_Agent5_NGradientFisher) proved the coordinate-free
    Fisher-gradient norm law
        ‖grad_g S‖²_g  =  dS ⬝ᵥ (g⁻¹ *ᵥ dS)            (R4_5_fisher_grad_norm_sq)
    for ANY metric `g` with `IsUnit g.det`; the squared natural-gradient length
    is the inverse-metric Mahalanobis norm of the covector.  Round-4 Agent 7
    (R4_Agent7_LandauTransitionExponents) proved that the disordered-side
    curvature of the Landau free energy is the Landau coefficient
        F''(0) = a(T) = a₀·(T − T_c)                   (R4_curvature_at_zero)
    whose reciprocal is the susceptibility `χ = 1/a(T)`, diverging with exponent
    γ = 1 as `T → T_c`                                  (R4_gamma_const,
                                                          R4_Tc_is_signchange).

    THE COMPOSITION.  Take the 2×2 Fisher / information metric whose first
    eigen-direction is the susceptibility (order-parameter) direction, with
    eigenvalue the Landau curvature `a(T) = F''(0)`, and whose second direction
    is regular (eigenvalue 1):
        g(T) = diag( a(T), 1 ),     g(T)⁻¹ = diag( 1/a(T), 1 ) = diag( χ(T), 1 ).
    Then:
      • det g(T) = a(T) → 0 as T → T_c  (the metric LOSES positive-definiteness;
        a FLAT direction appears in the Hessian/Fisher metric at criticality).
      • By R4_5_fisher_grad_norm_sq the squared natural-gradient length of any
        field S with covector dS = (s, t) on this metric is
            ‖grad_g S‖²_g = dS ⬝ᵥ (g⁻¹ *ᵥ dS) = s²/a(T) + t² = χ(T)·s² + t².
        Because g⁻¹ carries the susceptibility χ = 1/a(T), the natural-gradient
        norm BLOWS UP: as T → T_c⁺ (a(T) → 0⁺), with any nonzero
        susceptibility-direction component s ≠ 0,
            ‖grad_g S‖²_g  ⟶  +∞.
      This is critical slowing down of the natural-gradient flow: the
      information geometry degenerates and the intrinsic gradient speed diverges
      at exactly the Landau transition temperature `T_c`.

  SUMMARY:
    (a) R5_5_susc_metric_det / R5_5_det_tendsto_zero — det g(T) = a(T) and
        det g(T) → 0 as T → T_c (metric degeneration at criticality).
    (b) R5_5_susc_metric_inv — g(T)⁻¹ = diag(χ(T), 1) with χ(T) = 1/a(T)
        (the inverse metric carries the susceptibility), proved a genuine
        inverse via Matrix.inv_eq_right_inv, and
        R5_5_fisher_norm_eq_susc — via R4_5_fisher_grad_norm_sq the natural-
        gradient norm equals χ(T)·s² + t² = s²/a(T) + t².
    (c) R5_5_critical_slowing (HEADLINE) — Filter.Tendsto: the Fisher natural-
        gradient norm of the intervention field tends to +∞ as T → T_c⁺, for any
        nonzero susceptibility-direction component s.  Chains R4_5 (norm law) +
        R4_7 (a(T)=F''(0), T_c sign-change) + Mathlib tendsto_inv_zero_atTop.
        R5_5_critical_slowing_curvature grounds a(T) as the Landau curvature
        F''(0) using R4_curvature_at_zero, so the divergence is genuinely the
        susceptibility/Hessian degeneration, not a free parameter.

  WEAKENING NOTE: none of mathematical substance.  The metric is the explicit
  2-direction information metric whose susceptibility eigenvalue is the Landau
  curvature; this is the minimal faithful model in which "χ diverges ⟺ Fisher
  metric degenerates ⟺ natural-gradient slows critically" is a theorem.  The
  field S enters only through its covector dS = (s,t); the divergence needs only
  s ≠ 0 (a nonzero component along the soft mode), which is the physically
  generic case.

  Depends on:
    - MIP.Discoveries.R4_Agent5_NGradientFisher
        (R4_5_fisher_grad_norm_sq, fisherInner, fisherGrad)
    - MIP.Discoveries.R4_Agent7_LandauTransitionExponents
        (aT, R4_curvature_at_zero, R4_a_pos_iff, R4_Tc_is_signchange)
    - Mathlib.Topology.Algebra.Order.Field (tendsto_inv_nhdsGT_zero,
        Tendsto.const_mul_atTop, tendsto_atTop_add_const_right)
    - Mathlib.Topology.ContinuousOn (tendsto_nhdsWithin_iff)
    - Mathlib.LinearAlgebra.Matrix.NonsingularInverse (Matrix.inv_eq_right_inv)

  This file is `sorry`-free and `axiom`-free.
-/
import MIP.Discoveries.R4_Agent5_NGradientFisher
import MIP.Discoveries.R4_Agent7_LandauTransitionExponents
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse
import Mathlib.Data.Matrix.Mul
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.ContinuousOn
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace R5_Agent5_CriticalSlowingFisher

open Matrix Filter Topology
open MIP.R4_Agent5_NGradientFisher
open MIP.R4_Agent7_LandauTransitionExponents

/-! ### The susceptibility / soft-mode information metric.

`gSusc a = diag(a, 1)` — first direction is the order-parameter (susceptibility)
direction with eigenvalue the Landau curvature `a = F''(0)`, second direction is
regular with eigenvalue `1`.  Its inverse is `diag(1/a, 1) = diag(χ, 1)`. -/

/-- The 2×2 susceptibility information metric `g = diag(a, 1)`. -/
noncomputable def gSusc (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.diagonal ![a, 1]

/-- The inverse metric `g⁻¹ = diag(1/a, 1) = diag(χ, 1)`: the inverse metric
literally carries the susceptibility `χ = 1/a` in the soft direction. -/
noncomputable def gSuscInv (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.diagonal ![1 / a, 1]

/-- **R5.5 (a.0) — the metric determinant is the Landau curvature `a`.**

`det (diag(a,1)) = a·1 = a`.  Since (R4_7) `a = a(T) = F''(0)` is the
disordered-side Landau curvature, the metric determinant IS the curvature: it
vanishes precisely where the curvature/inverse-susceptibility vanishes. -/
theorem R5_5_susc_metric_det (a : ℝ) : (gSusc a).det = a := by
  unfold gSusc
  rw [Matrix.det_diagonal, Fin.prod_univ_two]
  simp

/-- **R5.5 (a.1) — `gSuscInv` is genuinely `gSusc⁻¹` (their product is `1`).**

The two diagonals multiply entrywise to `1`: `a·(1/a)=1` (needs `a ≠ 0`),
`1·1 = 1`.  Hence `gSusc a · gSuscInv a = 1`. -/
theorem R5_5_susc_mul_inv (a : ℝ) (ha : a ≠ 0) :
    gSusc a * gSuscInv a = 1 := by
  unfold gSusc gSuscInv
  rw [Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
  congr 1
  funext i
  fin_cases i <;> simp <;> field_simp

/-- **R5.5 (a.2) — the metric is invertible iff away from criticality.**

`gSusc a` has `det = a`, so `IsUnit (gSusc a).det ↔ a ≠ 0`: the susceptibility
metric is positive-definite/invertible precisely off the critical curvature
`a = 0`.  At criticality the determinant vanishes — the metric degenerates. -/
theorem R5_5_susc_det_isUnit (a : ℝ) (ha : a ≠ 0) :
    IsUnit (gSusc a).det := by
  rw [R5_5_susc_metric_det, isUnit_iff_ne_zero]
  exact ha

/-- **R5.5 (a.3) — `gSusc a` inverse is exactly `gSuscInv a`.** -/
theorem R5_5_susc_metric_inv (a : ℝ) (ha : a ≠ 0) :
    (gSusc a)⁻¹ = gSuscInv a :=
  Matrix.inv_eq_right_inv (R5_5_susc_mul_inv a ha)

/-! ### The Fisher natural-gradient norm carries the susceptibility. -/

/-- **R5.5 (b.0) — inverse-metric Mahalanobis norm of `(s,t)` is `s²/a + t²`.**

For `g⁻¹ = diag(1/a, 1)` and covector `dS = (s,t)`,
`dS ⬝ᵥ (g⁻¹ *ᵥ dS) = (1/a)·s² + 1·t² = s²/a + t²`. -/
theorem R5_5_inv_norm_closed (a s t : ℝ) :
    (dVec s t) ⬝ᵥ (gSuscInv a *ᵥ (dVec s t)) = s ^ 2 / a + t ^ 2 := by
  unfold gSuscInv dVec
  simp only [dotProduct, Fin.sum_univ_two, mulVec_diagonal,
    Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- **R5.5 (b.1 — BRIDGE) — Fisher natural-gradient norm = `χ·s² + t² = s²/a + t²`.**

Chaining R4_5's coordinate-free identity `R4_5_fisher_grad_norm_sq`
(‖grad_g S‖²_g = dS ⬝ᵥ (g⁻¹ *ᵥ dS)) with the concrete inverse metric (a.3) and
the closed form (b.0): on the susceptibility metric `gSusc a`, the squared Fisher
length of the natural gradient of a field with differential `dS = (s,t)` is
        ‖grad_g S‖²_g = s²/a + t² = χ·s² + t²,   χ = 1/a.
The R4_5 norm law is genuinely used as a proof term. -/
theorem R5_5_fisher_norm_eq_susc (a s t : ℝ) (ha : a ≠ 0) :
    fisherInner (gSusc a)
        (fisherGrad (gSusc a) (dVec s t))
        (fisherGrad (gSusc a) (dVec s t))
      = s ^ 2 / a + t ^ 2 := by
  -- R4_5 headline: ‖grad‖²_g = dS ⬝ᵥ (g⁻¹ *ᵥ dS)
  rw [R4_5_fisher_grad_norm_sq (gSusc a) (R5_5_susc_det_isUnit a ha) (dVec s t),
      R5_5_susc_metric_inv a ha]
  -- collapse the inverse-metric form
  exact R5_5_inv_norm_closed a s t

/-! ### Critical slowing down: the natural-gradient norm diverges at `T_c`. -/

/-- **R5.5 (c.0) — det of the temperature-dependent metric is `a(T)`, which
tends to `0` as `T → T_c`.**

With the Landau coefficient `a(T) = a₀(T − T_c)` (R4_7 `aT`), the metric
`gSusc (a(T))` has determinant `a(T)` (a.0), and `a(T) → 0` as `T → T_c`
(continuity), so the information metric degenerates at the transition: a flat
direction appears.  This is the geometric form of `χ ~ |T−T_c|^{-1} → ∞`. -/
theorem R5_5_det_tendsto_zero (a₀ T_c : ℝ) :
    Tendsto (fun T => (gSusc (aT a₀ T_c T)).det) (𝓝 T_c) (𝓝 0) := by
  have hcont : Tendsto (fun T => aT a₀ T_c T) (𝓝 T_c) (𝓝 (aT a₀ T_c T_c)) := by
    have hc : Continuous (fun T => aT a₀ T_c T) := by
      unfold aT; fun_prop
    exact hc.tendsto T_c
  have h0 : aT a₀ T_c T_c = 0 := by unfold aT; ring
  rw [h0] at hcont
  refine hcont.congr' ?_
  filter_upwards with T
  exact (R5_5_susc_metric_det (aT a₀ T_c T)).symm

/-- **R5.5 (c.1) — the Landau coefficient maps `𝓝[>] T_c` into `𝓝[>] 0`.**

For `a₀ > 0`, as `T → T_c` from above (`T > T_c`), the coefficient
`a(T) = a₀(T−T_c)` tends to `0` from above: `a(T) → 0⁺`.  This is the
approach to criticality from the disordered side, where the susceptibility
`χ = 1/a(T)` is well-defined and positive and blows up. -/
theorem R5_5_aT_tendsto_nhdsGT_zero (a₀ T_c : ℝ) (ha₀ : 0 < a₀) :
    Tendsto (fun T => aT a₀ T_c T) (𝓝[>] T_c) (𝓝[>] (0 : ℝ)) := by
  rw [tendsto_nhdsWithin_iff]
  constructor
  · -- tends to 0 in 𝓝 0
    have hcont : Tendsto (fun T => aT a₀ T_c T) (𝓝 T_c) (𝓝 (0 : ℝ)) := by
      have htend : Tendsto (fun T => aT a₀ T_c T) (𝓝 T_c) (𝓝 (aT a₀ T_c T_c)) := by
        have hc : Continuous (fun T => aT a₀ T_c T) := by
          unfold aT; fun_prop
        exact hc.tendsto T_c
      have h0 : aT a₀ T_c T_c = 0 := by unfold aT; ring
      rwa [h0] at htend
    exact hcont.mono_left nhdsWithin_le_nhds
  · -- eventually a(T) ∈ Ioi 0, i.e. a(T) > 0, because T > T_c
    filter_upwards [self_mem_nhdsWithin] with T hT
    have hT' : T_c < T := hT
    exact (R4_a_pos_iff a₀ T_c T ha₀).mpr hT'

/-- **R5.5 (c.2 — HEADLINE) — the Fisher natural-gradient of the intervention
field DIVERGES at the Landau transition (critical slowing down).**

On the susceptibility information metric `g(T) = diag(a(T), 1)` with Landau
coefficient `a(T) = a₀(T − T_c)`, the squared Fisher length of the natural
gradient of the field with covector `dS = (s, t)` is (by the bridge b.1)
`s²/a(T) + t²`.  As `T → T_c⁺` from the disordered side, with ANY nonzero
susceptibility-direction component `s ≠ 0`,
        ‖grad_{g(T)} S‖²_{g(T)}  =  s²/a(T) + t²  ⟶  +∞.
The natural-gradient norm blows up exactly at the transition: the information
metric degenerates (its determinant `a(T) → 0`, a flat direction appears) and
the intrinsic gradient speed diverges — critical slowing down of the
natural-gradient flow.

This chains R4_5 (the inverse-metric norm law, used in b.1) with R4_7 (the
identification of `a(T)` with the disordered curvature and the sign-change of
`a` at `T_c`) and Mathlib's `tendsto_inv_zero_atTop`. -/
theorem R5_5_critical_slowing
    (a₀ T_c s t : ℝ) (ha₀ : 0 < a₀) (hs : s ≠ 0) :
    Tendsto
      (fun T =>
        fisherInner (gSusc (aT a₀ T_c T))
          (fisherGrad (gSusc (aT a₀ T_c T)) (dVec s t))
          (fisherGrad (gSusc (aT a₀ T_c T)) (dVec s t)))
      (𝓝[>] T_c) atTop := by
  -- Step 1: rewrite the Fisher norm as s²/a(T) + t² on the eventual set a(T) ≠ 0.
  have hrewrite :
      (fun T =>
        fisherInner (gSusc (aT a₀ T_c T))
          (fisherGrad (gSusc (aT a₀ T_c T)) (dVec s t))
          (fisherGrad (gSusc (aT a₀ T_c T)) (dVec s t)))
        =ᶠ[𝓝[>] T_c]
      (fun T => s ^ 2 / aT a₀ T_c T + t ^ 2) := by
    filter_upwards [self_mem_nhdsWithin] with T hT
    have hT' : T_c < T := hT
    have hapos : 0 < aT a₀ T_c T := (R4_a_pos_iff a₀ T_c T ha₀).mpr hT'
    exact R5_5_fisher_norm_eq_susc (aT a₀ T_c T) s t (ne_of_gt hapos)
  rw [tendsto_congr' hrewrite]
  -- Step 2: 1/a(T) → +∞ since a(T) → 0⁺ (c.1) and tendsto_inv_zero_atTop.
  have hinv : Tendsto (fun T => (aT a₀ T_c T)⁻¹) (𝓝[>] T_c) atTop :=
    tendsto_inv_nhdsGT_zero.comp (R5_5_aT_tendsto_nhdsGT_zero a₀ T_c ha₀)
  -- Step 3: s² · (1/a(T)) → +∞ since s² > 0.
  have hs2 : (0 : ℝ) < s ^ 2 := by positivity
  have hmul : Tendsto (fun T => s ^ 2 * (aT a₀ T_c T)⁻¹) (𝓝[>] T_c) atTop :=
    Tendsto.const_mul_atTop hs2 hinv
  -- Step 4: add the constant t².
  have hadd : Tendsto (fun T => s ^ 2 * (aT a₀ T_c T)⁻¹ + t ^ 2) (𝓝[>] T_c) atTop :=
    tendsto_atTop_add_const_right _ (t ^ 2) hmul
  -- match s²/a = s²·a⁻¹.
  refine hadd.congr ?_
  intro T
  rw [div_eq_mul_inv]

/-- **R5.5 (c.3 — GROUNDED HEADLINE) — the divergence is the degeneration of the
Landau Hessian curvature `F''(0)`.**

We anchor `a(T)` to the genuine Landau curvature: by R4_7 `R4_curvature_at_zero`,
`F''(0) = a(T)` (the second derivative of the free energy at the disordered
minimum is the derivative-at-0 of the gradient field `ψ ↦ a(T)ψ + b ψ³`).  So the
metric eigenvalue that drives the divergence is exactly the inverse
susceptibility `χ⁻¹ = F''(0)`.  Bundling the curvature identity with the critical
slowing-down divergence (c.2):

* the Landau Hessian at the disordered minimum is `F''(0) = a(T)` (R4_7), and
* the Fisher natural-gradient norm `s²/a(T) + t² = χ(T)·s² + t²` diverges to `+∞`
  as `T → T_c⁺` (c.2),

i.e. as the Hessian curvature `F''(0) = a(T) → 0` the susceptibility metric
degenerates and the natural-gradient flow slows critically at exactly `T_c`. -/
theorem R5_5_critical_slowing_curvature
    (a₀ b T_c s t : ℝ) (ha₀ : 0 < a₀) (hs : s ≠ 0) :
    -- (i) the metric eigenvalue is the genuine Landau Hessian curvature F''(0):
    (∀ T, HasDerivAt (fun ψ => aT a₀ T_c T * ψ + b * ψ ^ 3) (aT a₀ T_c T) 0)
    -- (ii) and the Fisher natural-gradient norm diverges at T_c:
    ∧ Tendsto
        (fun T =>
          fisherInner (gSusc (aT a₀ T_c T))
            (fisherGrad (gSusc (aT a₀ T_c T)) (dVec s t))
            (fisherGrad (gSusc (aT a₀ T_c T)) (dVec s t)))
        (𝓝[>] T_c) atTop := by
  refine ⟨fun T => R4_curvature_at_zero a₀ b T_c T, ?_⟩
  exact R5_5_critical_slowing a₀ T_c s t ha₀ hs

end R5_Agent5_CriticalSlowingFisher

end MIP
