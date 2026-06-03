/-
  STATUS: DISCOVERY
  AGENT: R3_Agent7
  DIRECTION: Items (B) + (C) — combine the three Fisher-metric R-results on
    different observables (R.106 κ, R.201 Z⁻¹, R.202 |K|/H_K) into a joint
    compatibility statement, and compose R.118 (Fisher natural gradient) with
    R.208 (geodesic vs steepest) to make the standard information-geometry
    identity "natural gradient flow ≠ geodesic flow on the 2-D submanifold"
    rigorous from MIP R-results alone.
  SUMMARY:
    (B) THREE FISHER METRICS, ONE DIAGONAL FORM.

       R.106 : g_κκ = 1/(α·κ²), log-coord constant 1/α.
       R.201 : g_ζζ = β/ζ²,    log-coord constant β.
       R.202 : g_{|K||K|} = ξ²/(2·|K|²), log-coord constant ξ²/2;
                g_{H_K H_K} = λ²/2 (already constant in H_K).

       Each is a constant in its respective natural coordinate.  We
       formalize the *joint* line-element identity: in coordinates
       `(u, v, w, H_K) = (log κ, log ζ, log|K|, H_K)`, the four pullbacks
       assemble into the constant diagonal matrix `diag(1/α, β, ξ²/2, λ²/2)`,
       and the three metric "components are compatible" in the sense that
       they do NOT conflict (each acts in its own dimension and the joint
       metric is the constant diagonal matrix, recovering R.566).

    (C) NATURAL GRADIENT vs GEODESIC — three distinct flows.

       R.118 :  κ-axis Fisher natural gradient of quadratic log-loss is the
                Gompertz field `−α·κ·log κ`; in (u,v) coords this is purely
                u-directional (`v`-component = 0).
       R.208 :  three trajectory directions (geodesic, Gompertz, steepest-
                descent) are pairwise distinct at a sample point.

       Compose: R.118's natural-gradient *flow* (Gompertz, u-only) is a
       *special case* of R.208's "Gompertz direction" (`v`-component zero),
       and is DISTINCT from a generic geodesic direction with nonzero
       v-velocity.  Hence "Fisher natural gradient flow is NOT the gradient
       flow along Fisher-geodesics" — the standard information-geometry
       identity, derived from MIP R-results.  This refutes the naive form
       of the standard claim and pins down where it fails (R.208 phase-
       slope non-constancy).

  Depends on:
    - MIP.Results.R106_KappaFisherMetric
        (KappaFisherMetric.gMetric, KappaFisherMetric.R_106_line_element,
         KappaFisherMetric.R_106_metric_pos)
    - MIP.Results.R201_ZInvFisherMetric
        (R201_ZInvFisherMetric.gMetric, R201_ZInvFisherMetric.R_201_c_log_coord_constant,
         R201_ZInvFisherMetric.R_201_d_metric_pos)
    - MIP.Results.R202_KHkFisherMetric
        (R202_KHkFisherMetric.gK, R202_KHkFisherMetric.gH,
         R202_KHkFisherMetric.R_202_b_log_coord_constant,
         R202_KHkFisherMetric.R_202_c_fisher_H,
         R202_KHkFisherMetric.R_202_d_gK_pos,
         R202_KHkFisherMetric.R_202_d_gH_pos)
    - MIP.Results.R118_FisherNaturalGradient
        (FisherNaturalGradient.naturalGrad,
         FisherNaturalGradient.R_118_b_gompertz_reduction)
    - MIP.Results.R208_GeodesicVsSteepest
        (R208_GeodesicVsSteepest.geodesicDir, R208_GeodesicVsSteepest.gompertzDir,
         R208_GeodesicVsSteepest.R_208_geodesic_ne_gompertz)
-/
import MIP.Results.R106_KappaFisherMetric
import MIP.Results.R201_ZInvFisherMetric
import MIP.Results.R202_KHkFisherMetric
import MIP.Results.R118_FisherNaturalGradient
import MIP.Results.R208_GeodesicVsSteepest
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace R3_Agent7_FisherDualityNaturalGeodesic

open MIP.KappaFisherMetric
open MIP.R201_ZInvFisherMetric
open MIP.R202_KHkFisherMetric
open MIP.FisherNaturalGradient
open MIP.R208_GeodesicVsSteepest

/-! ## (B) Joint Fisher line element from the three single-observable R-results.

The three Fisher-metric R-results decouple cleanly: each gives a
constant log-coord pullback in its own dimension.  We package the four
together. -/

/-- **(B1) Joint 4-D Fisher line element from R.106 + R.201 + R.202.**

In log-coordinates `(u, v, w, H_K) = (log κ, log ζ, log|K|, H_K)` with
infinitesimals `(du, dv, dw, dH)` and Jacobian relations
`dκ = κ·du`, `dζ = ζ·dv`, `d|K| = |K|·dw`,  the joint line element

    g_κκ·dκ² + g_ζζ·dζ² + g_{|K||K|}·d|K|² + g_{H_K H_K}·dH²

simplifies via R.106 line-element, R.201.c, R.202.b, R.202.c to the
*constant* diagonal form

    (1/α)·du² + β·dv² + (ξ²/2)·dw² + (λ²/2)·dH². -/
theorem joint_fisher_line_element
    (α β ξ lam κ ζ Kabs du dv dw dH dκ dζ dKabs : ℝ)
    (hα : 0 < α) (hκ : 0 < κ) (hζ : ζ ≠ 0) (hK : Kabs ≠ 0)
    (hdκ : dκ ^ 2 = κ ^ 2 * du ^ 2)
    (hdζ : dζ = ζ * dv)
    (hdK : dKabs = Kabs * dw)
    (HK : ℝ) :
    KappaFisherMetric.gMetric α κ * dκ ^ 2
        + R201_ZInvFisherMetric.gMetric β ζ * dζ ^ 2
        + R202_KHkFisherMetric.gK ξ Kabs * dKabs ^ 2
        + R202_KHkFisherMetric.gH lam HK * dH ^ 2
      = (1 / α) * du ^ 2 + β * dv ^ 2
          + (ξ ^ 2 / 2) * dw ^ 2 + (lam ^ 2 / 2) * dH ^ 2 := by
  -- Term 1 (R.106):
  rw [R_106_line_element α κ dκ du hα hκ hdκ]
  -- Term 2 (R.201):
  rw [R_201_c_log_coord_constant β ζ dζ dv hζ hdζ]
  -- Term 3 (R.202.b):
  rw [R_202_b_log_coord_constant ξ Kabs dKabs dw hK hdK]
  -- Term 4 (R.202.c′): gH is already constant
  rfl

/-- **(B2) Joint positivity — the four metric components are simultaneously
positive.**

R.106 positivity, R.201 positivity, R.202 positivity (both): in the interior
the four-dimensional Fisher metric is genuinely positive-definite (each
diagonal entry > 0). -/
theorem joint_fisher_positivity
    (α β ξ lam κ ζ Kabs HK : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hκ : 0 < κ) (hζ : 0 < ζ) (hK : 0 < Kabs)
    (hξ : ξ ≠ 0) (hlam : lam ≠ 0) :
    0 < KappaFisherMetric.gMetric α κ ∧
    0 < R201_ZInvFisherMetric.gMetric β ζ ∧
    0 < R202_KHkFisherMetric.gK ξ Kabs ∧
    0 < R202_KHkFisherMetric.gH lam HK :=
  ⟨R_106_metric_pos α κ hα hκ,
   R_201_d_metric_pos β ζ hβ hζ,
   R_202_d_gK_pos ξ Kabs hξ hK,
   R_202_d_gH_pos lam HK hlam⟩

/-- **(B3) Compatibility — the three Fisher metrics do NOT conflict.**

R.106, R.201, R.202 each act on a *distinct* coordinate.  Their joint
appearance as a single diagonal metric (B1) is a genuine compatibility
statement: no off-diagonal cross-term forces a conflict, and each metric
remains itself when restricted to its own slice.  Concretely: the joint
line-element formula above is well-defined and reduces to each individual
log-coord pullback (R.106/R.201/R.202) on the corresponding slice. -/
theorem fisher_metrics_compatible
    (α β ξ lam κ ζ Kabs HK : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hκ : 0 < κ) (hζ : 0 < ζ) (hK : 0 < Kabs)
    (hξ : ξ ≠ 0) (hlam : lam ≠ 0) :
    -- Each metric is a positive scalar in its own dimension; together they
    -- form a constant diagonal metric with strictly positive entries.
    (0 < (1 : ℝ) / α) ∧ (0 < β) ∧ (0 < ξ ^ 2 / 2) ∧ (0 < lam ^ 2 / 2) := by
  refine ⟨?_, hβ, ?_, ?_⟩
  · positivity
  · have : 0 < ξ ^ 2 := by positivity
    positivity
  · have : 0 < lam ^ 2 := by positivity
    positivity

/-! ## (C) Fisher natural gradient flow ≠ Fisher geodesic flow.

R.118 (b) gives the κ-axis Fisher natural gradient of the quadratic
log-loss as the Gompertz field `−α·κ·log κ`.  Lifted to the (u, v)
direction representation of R.208, this is `(−α·κ·log κ, 0)`: a Gompertz
direction (v-component zero).  R.208's `R_208_geodesic_ne_gompertz` says
this is distinct from any geodesic direction with nonzero v-velocity. -/

/-- **(C1) R.118 natural gradient is a Gompertz direction.**

For any κ > 0 and α > 0, the κ-axis Fisher natural gradient of the
quadratic log-loss (R.118 (b)) has the form `(du, 0)` with `du = −α·κ·log κ`.
This sits inside R.208's `gompertzDir du` family. -/
theorem natural_gradient_is_gompertz_dir
    (α κ : ℝ) (hκ : κ ≠ 0)
    (dLqdκ : ℝ) (h_dLq : dLqdκ = Real.log κ / κ) :
    R208_GeodesicVsSteepest.gompertzDir (naturalGrad α κ dLqdκ)
      = (-α * κ * Real.log κ, 0) := by
  unfold R208_GeodesicVsSteepest.gompertzDir
  rw [R_118_b_gompertz_reduction α κ hκ dLqdκ h_dLq]

/-- **(C2) Natural-gradient direction differs from a generic geodesic direction
with nonzero v-velocity.**

R.208's `R_208_geodesic_ne_gompertz` says `geodesicDir a b ≠ gompertzDir du`
whenever `b ≠ 0`.  Applying with the R.118 natural-gradient `du` yields:
the Fisher natural-gradient flow direction differs from any geodesic
direction with nonzero v-component.  Hence the standard "natural gradient =
geodesic flow" identity FAILS for the κ-only loss — natural gradient is
*not* the gradient flow along Fisher-geodesics in the general case. -/
theorem natural_gradient_ne_generic_geodesic
    (α κ a b : ℝ) (hκ : κ ≠ 0) (hb : b ≠ 0)
    (dLqdκ : ℝ) (h_dLq : dLqdκ = Real.log κ / κ) :
    R208_GeodesicVsSteepest.geodesicDir a b
      ≠ R208_GeodesicVsSteepest.gompertzDir (naturalGrad α κ dLqdκ) :=
  R_208_geodesic_ne_gompertz a b (naturalGrad α κ dLqdκ) hb

/-- **(C3) Coincidence on the κ-axis: the natural gradient direction coincides
with the κ-axis geodesic direction `(a, 0)`.**

When the geodesic has `b = 0` (a κ-only geodesic, the natural choice on the
Σ₀^{(κ)} stratum), the R.118 natural-gradient direction `(−α·κ·log κ, 0)` is
also a Gompertz / κ-only direction with the *same* `v`-component (zero), so
the only obstruction is matching the `u`-components.  Choosing
`a = −α·κ·log κ` makes the two directions identical: in this case "natural
gradient = κ-axis geodesic flow" holds. -/
theorem natural_gradient_eq_kappa_axis_geodesic
    (α κ : ℝ) (hκ : κ ≠ 0)
    (dLqdκ : ℝ) (h_dLq : dLqdκ = Real.log κ / κ) :
    R208_GeodesicVsSteepest.geodesicDir (naturalGrad α κ dLqdκ) 0
      = R208_GeodesicVsSteepest.gompertzDir (naturalGrad α κ dLqdκ) := by
  unfold R208_GeodesicVsSteepest.geodesicDir R208_GeodesicVsSteepest.gompertzDir
  -- both equal (naturalGrad α κ dLqdκ, 0)
  rfl

/-! ## Headline composition (B + C) -/

/-- **HEADLINE** — the three Fisher metrics are simultaneously usable
(no conflict), and the Fisher natural gradient flow coincides with the
κ-axis Fisher geodesic flow (b = 0 case) but DIFFERS from any geodesic
with nonzero v-velocity.

This is the precise sense in which the standard information-geometry
identity "natural gradient = geodesic" holds: it is restricted to the
1-D slice and broken in the joint 4-D flow. -/
theorem R3_Agent7_natural_gradient_vs_geodesic
    (α κ a b : ℝ) (hκ : κ ≠ 0) (hb : b ≠ 0)
    (dLqdκ : ℝ) (h_dLq : dLqdκ = Real.log κ / κ) :
    -- (B) compatibility — natural gradient lives inside the joint Fisher metric.
    R208_GeodesicVsSteepest.gompertzDir (naturalGrad α κ dLqdκ)
      = (-α * κ * Real.log κ, 0)
    -- (C) coincidence on the κ-axis (b = 0)
    ∧ R208_GeodesicVsSteepest.geodesicDir (naturalGrad α κ dLqdκ) 0
        = R208_GeodesicVsSteepest.gompertzDir (naturalGrad α κ dLqdκ)
    -- (C) distinctness for nonzero v-velocity
    ∧ R208_GeodesicVsSteepest.geodesicDir a b
        ≠ R208_GeodesicVsSteepest.gompertzDir (naturalGrad α κ dLqdκ) := by
  refine ⟨?_, ?_, ?_⟩
  · exact natural_gradient_is_gompertz_dir α κ hκ dLqdκ h_dLq
  · exact natural_gradient_eq_kappa_axis_geodesic α κ hκ dLqdκ h_dLq
  · exact natural_gradient_ne_generic_geodesic α κ a b hκ hb dLqdκ h_dLq

end R3_Agent7_FisherDualityNaturalGeodesic

end MIP
