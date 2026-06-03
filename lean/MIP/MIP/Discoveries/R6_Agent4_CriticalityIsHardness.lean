/-
  STATUS: DISCOVERY
  AGENT: R6_Agent4
  DIRECTION: CRITICALITY MONOTONE IN HARDNESS LEVEL — on the phase chain,
    impossibility-hardness and information-geometric criticality are the SAME order.

    Round-5 Agent 5 (`R5_Agent5_CriticalSlowingFisher`) proved that the Fisher
    natural-gradient norm of the intervention field on the susceptibility metric
    `gSusc a = diag(a,1)` equals the inverse-metric Mahalanobis form
        fisherInner (gSusc a) (fisherGrad (gSusc a) (s,t)) (...)  =  s²/a + t²
                                                          (R5_5_fisher_norm_eq_susc)
    i.e. along the soft (order-parameter) mode `dS = (1,0)` it is EXACTLY the
    Landau susceptibility `χ = 1/a`.  The smaller the curvature `a`, the larger
    the susceptibility / the more critical (slower) the phase.

    Round-5 Agent 7 (`R5_Agent7_PhaseOrderRefinesHardness`) embedded the scaling
    phase chain into the impossibility hardness ladder via the strictly-monotone
    cost map `phaseCost : Fin 3 → ℝ` (`phaseCost_strictMono`), with the strictness
    coming from R4_Agent2's `phase_budget_ordering_from_scaling`
    (`crossBudget_strictAnti`).  Rank `0 < 1 < 2` = `coverage < mixed < autonomy`.

    THE COMPOSITION (this file).  Assign each phase its CRITICALITY = the
    R5_Agent5 Fisher susceptibility `χ_i = 1/a_i` at that phase's Landau curvature
    `a_i`.  Order the phases so that the harder (later) phase has the SMALLER
    curvature (closer to criticality):  `a_cov > a_star > a_aut > 0`.  Then:

      (a) the criticality measure `phaseCrit : Fin 3 → ℝ`, `r ↦ χ_r = 1/a_r`,
          built LITERALLY from the R5_Agent5 Fisher norm at the soft mode
          (`phaseCrit_eq_fisher`), is STRICTLY MONOTONE along the phase chain
          `coverage < mixed < autonomy` (`phaseCrit_strictMono`): criticality
          increases with hardness level.

      (b) the criticality order is order-isomorphic to / refines the R5_Agent7
          hardness embedding: BOTH `phaseCost` (hardness/cost) and `phaseCrit`
          (criticality) are `StrictMono : Fin 3 → ℝ` with the SAME domain order,
          so they induce the SAME total order on the 3 phases; equivalently
          `phaseCost r₁ < phaseCost r₂ ↔ phaseCrit r₁ < phaseCrit r₂`
          (`hardness_iff_criticality`), and the rank itself is the shared
          `OrderIso (Fin 3) (Fin 3)` (the identity) intertwining both
          (`criticality_orderIso_hardness`).

      (c) HEADLINE — `criticality_is_hardness`.  On the phase chain, the
          impossibility-hardness order (R5_Agent7 `phaseCost`, ultimately
          R4_Agent2 `crossBudget_strictAnti`) and the information-geometric
          criticality order (R5_Agent5 Fisher susceptibility `χ = 1/a`) are ONE
          AND THE SAME strict total order on the three phases: the harder phase
          is exactly the more critical / slower phase.  A single rank function
          `Fin 3 → ℝ × ℝ` is strictly monotone in BOTH coordinates, each phase's
          criticality is its genuine R5_Agent5 Fisher natural-gradient norm at the
          soft mode, and the two strict orders coincide.

  Depends on (imports + exact lemma names used):
    • MIP.Discoveries.R5_Agent5_CriticalSlowingFisher
        (gSusc, gSuscInv, R5_5_fisher_norm_eq_susc, R5_5_inv_norm_closed)
    • MIP.Discoveries.R5_Agent7_PhaseOrderRefinesHardness
        (phaseCost, phaseCost_strictMono)
    • MIP.Discoveries.R4_Agent2_PhaseScalingUnification
        (crossBudget, alphaD)  — re-exported transitively through R5_Agent7
    • MIP.Discoveries.R4_Agent5_NGradientFisher (dVec, fisherInner, fisherGrad)
        — re-exported transitively through R5_Agent5
    • Mathlib: StrictMono, StrictMono.lt_iff_lt, OrderIso.refl, gcongr (1/·).

  This file is `sorry`-free and `axiom`-free.
-/
import MIP.Discoveries.R5_Agent5_CriticalSlowingFisher
import MIP.Discoveries.R5_Agent7_PhaseOrderRefinesHardness
import Mathlib.Order.Monotone.Basic
import Mathlib.Order.Hom.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.GCongr

namespace MIP

namespace R6_Agent4_CriticalityIsHardness

open MIP.R5_Agent5_CriticalSlowingFisher
open MIP.R5_Agent7_PhaseOrderRefinesHardness
open MIP.R4_Agent5_NGradientFisher

/-! ## (a) The criticality measure of a phase = R5_Agent5 Fisher susceptibility.

Each phase carries a Landau curvature `a_i = F''(0)` at its order-parameter
minimum.  The harder/later a phase, the closer it sits to its own critical point,
hence the SMALLER its curvature: we encode the phase chain as

    a_cov  >  a_star  >  a_aut  >  0 .

The criticality of a phase is its susceptibility `χ_i = 1/a_i`, which by
R5_Agent5's `R5_5_fisher_norm_eq_susc` is EXACTLY the Fisher natural-gradient
norm of the intervention field along the soft (order-parameter) mode
`dS = (1, 0)` on the susceptibility metric `gSusc a_i`. -/

/-- **Phase criticality map.**  `phaseCrit a_cov a_star a_aut r` assigns to phase
rank `r : Fin 3` its susceptibility `χ_r = 1/a_r`, in increasing-criticality
order `0 ↦ 1/a_cov`, `1 ↦ 1/a_star`, `2 ↦ 1/a_aut`.  With the curvature chain
`a_cov > a_star > a_aut > 0` this is the harder = more critical assignment. -/
noncomputable def phaseCrit (a_cov a_star a_aut : ℝ) : Fin 3 → ℝ
  | ⟨0, _⟩ => 1 / a_cov
  | ⟨1, _⟩ => 1 / a_star
  | ⟨2, _⟩ => 1 / a_aut

/-- **The phase curvature at a given rank** (the Landau coefficient `a_r`).
`0 ↦ a_cov`, `1 ↦ a_star`, `2 ↦ a_aut`.  This is the soft-mode eigenvalue of the
R5_Agent5 susceptibility metric `gSusc (phaseCurv ... r)` at phase `r`. -/
noncomputable def phaseCurv (a_cov a_star a_aut : ℝ) : Fin 3 → ℝ
  | ⟨0, _⟩ => a_cov
  | ⟨1, _⟩ => a_star
  | ⟨2, _⟩ => a_aut

/-- **(a.0) Criticality is the R5_Agent5 Fisher susceptibility at the soft mode.**

For every phase rank `r`, with curvature `a_r ≠ 0`, the criticality `phaseCrit r`
equals the R5_Agent5 Fisher natural-gradient norm of the intervention field with
covector `dS = (1, 0)` (pure order-parameter / soft mode) on the susceptibility
metric `gSusc a_r`.  This grounds the criticality measure in R5_Agent5's
`R5_5_fisher_norm_eq_susc`: criticality is the genuine information-geometric
natural-gradient speed `χ = 1/a` at the phase. -/
theorem phaseCrit_eq_fisher
    (a_cov a_star a_aut : ℝ)
    (h_cov : a_cov ≠ 0) (h_star : a_star ≠ 0) (h_aut : a_aut ≠ 0)
    (r : Fin 3) :
    phaseCrit a_cov a_star a_aut r
      = fisherInner (gSusc (phaseCurv a_cov a_star a_aut r))
          (fisherGrad (gSusc (phaseCurv a_cov a_star a_aut r)) (dVec 1 0))
          (fisherGrad (gSusc (phaseCurv a_cov a_star a_aut r)) (dVec 1 0)) := by
  fin_cases r <;>
    simp only [phaseCrit, phaseCurv] <;>
    rw [R5_5_fisher_norm_eq_susc _ 1 0 (by assumption)] <;>
    norm_num

/-- **(a.1 — KEY) — criticality is STRICTLY MONOTONE along the phase chain.**

Under the curvature chain `a_cov > a_star > a_aut > 0` (later phase = smaller
curvature = closer to criticality), the susceptibility `χ = 1/a` strictly
increases with the phase rank:

    χ_cov = 1/a_cov  <  χ_star = 1/a_star  <  χ_aut = 1/a_aut .

Hence `phaseCrit` is `StrictMono : Fin 3 → ℝ`.  Because each value is, by (a.0),
the R5_Agent5 Fisher natural-gradient norm at the soft mode, this says the harder
(later) phase has the strictly LARGER information-geometric criticality / slower
natural-gradient flow.  The strictness is the order-reversal `1/·` of the curvature
chain. -/
theorem phaseCrit_strictMono
    (a_cov a_star a_aut : ℝ)
    (h_aut0 : 0 < a_aut) (h_as : a_aut < a_star) (h_sc : a_star < a_cov) :
    StrictMono (phaseCrit a_cov a_star a_aut) := by
  have h_star0 : 0 < a_star := lt_trans h_aut0 h_as
  have h_cov0 : 0 < a_cov := lt_trans h_star0 h_sc
  -- the three susceptibility inequalities, from order-reversal of `1/·`.
  have c01 : 1 / a_cov < 1 / a_star := by
    gcongr
  have c12 : 1 / a_star < 1 / a_aut := by
    gcongr
  have c02 : 1 / a_cov < 1 / a_aut := lt_trans c01 c12
  intro a b hab
  fin_cases a <;> fin_cases b <;>
    simp only [phaseCrit, Fin.mk_lt_mk] at hab ⊢ <;>
    first
      | exact c01
      | exact c12
      | exact c02
      | exact absurd hab (by decide)

/-! ## (b) Criticality order = hardness order on the phase chain.

R5_Agent7's `phaseCost : Fin 3 → ℝ` is `StrictMono` (`phaseCost_strictMono`),
ranking phases by increasing crossing budget = impossibility hardness.  We just
proved `phaseCrit : Fin 3 → ℝ` is `StrictMono` for the criticality / susceptibility.
Two strictly-monotone real-valued maps out of the SAME linearly-ordered domain
`Fin 3` induce the SAME order on the phases: harder ⟺ more critical. -/

/-- **(b.0) — hardness order ⟺ criticality order (pointwise).**

For any two phase ranks `r₁, r₂`, the impossibility-hardness comparison
`phaseCost r₁ < phaseCost r₂` (R5_Agent7, ultimately R4_Agent2
`crossBudget_strictAnti`) holds IFF the criticality comparison
`phaseCrit r₁ < phaseCrit r₂` (R5_Agent5 Fisher susceptibility) holds — because
both reduce, via the respective `StrictMono`, to `r₁ < r₂`.  This is the precise
statement "hardness = criticality" as a comparison of orders. -/
theorem hardness_iff_criticality
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (hℓ_aut : Linf < ℓ_aut) (hℓ_star : ℓ_aut < ℓ_star) (hℓ_cov : ℓ_star < ℓ_cov)
    (a_cov a_star a_aut : ℝ)
    (h_aut0 : 0 < a_aut) (h_as : a_aut < a_star) (h_sc : a_star < a_cov)
    (r₁ r₂ : Fin 3) :
    (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₁
        < phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₂)
      ↔ (phaseCrit a_cov a_star a_aut r₁ < phaseCrit a_cov a_star a_aut r₂) := by
  have hHard := phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
    hC h_s hℓ_aut hℓ_star hℓ_cov
  have hCrit := phaseCrit_strictMono a_cov a_star a_aut h_aut0 h_as h_sc
  rw [hHard.lt_iff_lt, hCrit.lt_iff_lt]

/-- **(b.1) — the shared rank `OrderIso` intertwining hardness and criticality.**

The identity `OrderIso (Fin 3) (Fin 3)` is the order isomorphism of the phase
chain with itself under which the impossibility-hardness cost order and the
information-geometric criticality order are intertwined: applying it before either
strictly-monotone measure preserves the strict order (it IS the rank), so the two
measures live on the SAME ordered index.  Concretely, `phaseCost ∘ e` and
`phaseCrit ∘ e` are both `StrictMono` for `e = OrderIso.refl (Fin 3)`. -/
theorem criticality_orderIso_hardness
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (hℓ_aut : Linf < ℓ_aut) (hℓ_star : ℓ_aut < ℓ_star) (hℓ_cov : ℓ_star < ℓ_cov)
    (a_cov a_star a_aut : ℝ)
    (h_aut0 : 0 < a_aut) (h_as : a_aut < a_star) (h_sc : a_star < a_cov) :
    ∃ e : OrderIso (Fin 3) (Fin 3),
      StrictMono (fun r => phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut (e r))
        ∧ StrictMono (fun r => phaseCrit a_cov a_star a_aut (e r)) := by
  refine ⟨OrderIso.refl (Fin 3), ?_, ?_⟩
  · exact phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
      hC h_s hℓ_aut hℓ_star hℓ_cov
  · exact phaseCrit_strictMono a_cov a_star a_aut h_aut0 h_as h_sc

/-! ## (c) HEADLINE — on the phase chain, hardness = criticality. -/

/-- **Combined hardness–criticality rank.**  `phaseHC r = (phaseCost r, phaseCrit r)`:
the impossibility-hardness cost (R5_Agent7) paired with the information-geometric
criticality (R5_Agent5 Fisher susceptibility) at phase rank `r`. -/
noncomputable def phaseHC
    (Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut : ℝ) : Fin 3 → ℝ × ℝ :=
  fun r => (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r,
            phaseCrit a_cov a_star a_aut r)

/-- **(c) HEADLINE — criticality IS hardness on the phase chain.**

Chaining R5_Agent7 (`phaseCost_strictMono`, ultimately R4_Agent2
`crossBudget_strictAnti`) with R5_Agent5 (`R5_5_fisher_norm_eq_susc`): under the
heavy-tail scaling regime (`C > 0`, `1 < s`, loss-ordered thresholds
`ℓ_aut < ℓ_star < ℓ_cov`) and the criticality regime (curvature chain
`0 < a_aut < a_star < a_cov`, later phase closer to its critical point), the
combined rank `phaseHC` satisfies, for the canonical phase progression
`0 (coverage) < 1 (mixed) < 2 (autonomy)`:

  • **Hardness coordinate strictly increases** — `phaseCost` is `StrictMono`
    (the scaling-derived crossing-budget chain `D_cov < D_* < D_aut`).

  • **Criticality coordinate strictly increases** — `phaseCrit` is `StrictMono`
    (the Fisher susceptibility chain `χ_cov < χ_* < χ_aut`).

  • **Criticality is the genuine R5_Agent5 Fisher norm** — at every rank, the
    criticality coordinate equals the R5_Agent5 natural-gradient norm at the soft
    mode `(1,0)` on `gSusc (phaseCurv r)` (`phaseCrit_eq_fisher`).

  • **Same order** — the two coordinates induce the SAME strict order on the three
    phases: `phaseCost r₁ < phaseCost r₂ ↔ phaseCrit r₁ < phaseCrit r₂`.

Hence the impossibility-hardness order and the information-geometric criticality
order coincide on the phase chain: the harder phase is exactly the more critical /
slower phase. -/
theorem criticality_is_hardness
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (hℓ_aut : Linf < ℓ_aut) (hℓ_star : ℓ_aut < ℓ_star) (hℓ_cov : ℓ_star < ℓ_cov)
    (a_cov a_star a_aut : ℝ)
    (h_aut0 : 0 < a_aut) (h_as : a_aut < a_star) (h_sc : a_star < a_cov) :
    -- (1) hardness coordinate strictly increasing
    StrictMono (fun r =>
        (phaseHC Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut r).1)
    -- (2) criticality coordinate strictly increasing
    ∧ StrictMono (fun r =>
        (phaseHC Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut r).2)
    -- (3) criticality coordinate IS the R5_Agent5 Fisher susceptibility at the soft mode
    ∧ (∀ r, (phaseHC Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut r).2
        = fisherInner (gSusc (phaseCurv a_cov a_star a_aut r))
            (fisherGrad (gSusc (phaseCurv a_cov a_star a_aut r)) (dVec 1 0))
            (fisherGrad (gSusc (phaseCurv a_cov a_star a_aut r)) (dVec 1 0)))
    -- (4) hardness and criticality induce the SAME order on the phases
    ∧ (∀ r₁ r₂,
        ((phaseHC Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut r₁).1
            < (phaseHC Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut r₂).1)
          ↔ ((phaseHC Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut r₁).2
            < (phaseHC Linf C s ℓ_cov ℓ_star ℓ_aut a_cov a_star a_aut r₂).2)) := by
  have h_star0 : 0 < a_star := lt_trans h_aut0 h_as
  have h_cov0 : 0 < a_cov := lt_trans h_star0 h_sc
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (1) hardness coordinate = phaseCost, StrictMono
    exact phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
      hC h_s hℓ_aut hℓ_star hℓ_cov
  · -- (2) criticality coordinate = phaseCrit, StrictMono
    exact phaseCrit_strictMono a_cov a_star a_aut h_aut0 h_as h_sc
  · -- (3) criticality = R5_Agent5 Fisher susceptibility at the soft mode
    intro r
    exact phaseCrit_eq_fisher a_cov a_star a_aut
      (ne_of_gt h_cov0) (ne_of_gt h_star0) (ne_of_gt h_aut0) r
  · -- (4) the two orders coincide
    intro r₁ r₂
    exact hardness_iff_criticality Linf C s ℓ_cov ℓ_star ℓ_aut
      hC h_s hℓ_aut hℓ_star hℓ_cov a_cov a_star a_aut h_aut0 h_as h_sc r₁ r₂

end R6_Agent4_CriticalityIsHardness

end MIP
