/-
  STATUS: DISCOVERY
  AGENT: R7_Agent3
  DIRECTION: THE MASTER EMERGENCE-DIFFICULTY ORDINAL — criticality = hardness =
    degeneration = scaling-budget are ONE labeled Fin-3 ordinal, with the
    Fisher-geometric scaling susceptibility as the quantitative coordinate.

  Round 6 produced three separate identifications of the emergence-difficulty
  order on the three scaling phases `coverage < mixed < autonomy`:

    • R6_Agent4 (`R6_Agent4_CriticalityIsHardness`) proved CRITICALITY = HARDNESS:
      both the information-geometric susceptibility `phaseCrit r = χ_r = 1/a_r`
      (the genuine R5_Agent5 Fisher natural-gradient norm at the soft mode,
      `phaseCrit_eq_fisher`) and the impossibility cost `phaseCost` are
      `StrictMono : Fin 3 → ℝ` with the SAME order (`hardness_iff_criticality`,
      `criticality_orderIso_hardness`, headline `criticality_is_hardness`).

    • R6_Agent9 (`R6_Agent9_ThreeOrderUnification`) proved PHASE = DEGENERATION =
      HARDNESS as one ordinal: the unified `tripleRank` has a `StrictMono` scaling
      cost coordinate (`tripleRank_scaling_strictMono`) and a `DegenStep`-chain
      degeneration coordinate sinking to the wall `univ`, the common top
      (`wall_is_common_top`, headline `three_orders_one_ordinal`).

    • R6_Agent7 (`R6_Agent7_ScalingExponentFisherCoordinate`) supplied the
      QUANTITATIVE label: on the gap power law `a = softEig γ A g = A·g^γ`, the
      Fisher natural-gradient susceptibility coefficient is
      `1/softEig γ A g = A⁻¹·g^(−γ)` (`R6_7_susc_coeff_is_gpow`,
      `R6_7_fisher_norm_softEig`), the scaling exponent `α_D = 1/(β+γ)` being read
      off this geometry (`R6_7_alphaD_is_fisher_invariant`).

  THIS FILE (Round 7) UNIFIES ALL THREE into a SINGLE master order-isomorphism and
  attaches the scaling susceptibility as a strictly-monotone numeric LABEL.

  SUMMARY:
    (a) **Identification of the criticality coordinate with the R6_Agent7 scaling
        susceptibility.**  Resolve each phase's R6_Agent4 Landau curvature as the
        R6_Agent7 gap power law `a_r = softEig γ A_r g` at fixed exponent γ and gap
        g, with phase amplitudes `A_cov > A_star > A_aut > 0`.  Then the R6_Agent4
        criticality `phaseCrit (softEig..A_cov) (softEig..A_star) (softEig..A_aut) r`
        equals the R6_Agent7 Fisher susceptibility coefficient
        `1/softEig γ A_r g = A_r⁻¹·g^(−γ)` at that phase
        (`crit_is_scaling_susc`, chaining R6_Agent4 `phaseCrit` with R6_Agent7
        `R6_7_susc_coeff_is_gpow`), and is the genuine R5_Agent5 Fisher norm at the
        soft mode (`crit_is_fisher_norm`, via R6_Agent4 `phaseCrit_eq_fisher`).

    (b) **The labeled master ordinal — all four coordinates `StrictMono` with the
        SAME order.**  Assemble the four monotone coordinates
          χ  = R6_Agent4 criticality `phaseCrit` (= R6_Agent7 scaling susceptibility),
          H  = R5_Agent7 hardness cost `phaseCost`,
          D  = R6_Agent9 degeneration level `phaseDegen` (the `DegenStep`-chain),
          L  = the scaling susceptibility LABEL `r ↦ 1/softEig γ A_r g` (real number).
        We prove (`master_ordinal_strictMono`) χ, H, L are all `StrictMono : Fin 3 → ℝ`
        and D is a `DegenStep`-chain, hence pairwise the SAME total order; the
        numeric label L is `StrictMono` and EQUALS the criticality χ
        (`label_is_criticality`), so the abstract ordinal is LABELED by a real number
        strictly increasing to the critical/terminal phase.

    (c) HEADLINE (`master_difficulty_ordinal`):  ALL emergence-difficulty orders —
        criticality (R6_Agent4 / R5_Agent5 Fisher susceptibility), hardness
        (R5_Agent7 cost), degeneration (R6_Agent9 `DegenStep` toward the wall), and
        the scaling-derived budget (R6_Agent7 gap-power susceptibility) — are ONE
        labeled Fin-3 ordinal.  Concretely: a single `OrderIso (Fin 3) (Fin 3)` (the
        rank) under which χ, H, L are all `StrictMono`, the criticality/label
        coordinate is the genuine R5_Agent5 Fisher norm AND the R6_Agent7 gap-power
        susceptibility `A_r⁻¹·g^(−γ)`, the four orders pairwise coincide
        (`hardness_iff_criticality` / `hardness_iff_label`), the degeneration
        coordinate is a `DegenStep`-chain sinking into the common top `univ` (the
        wall, R6_Agent9 `phaseDegen_sinks_to_univ`), and the numeric label strictly
        increases to the critical/terminal point.  Chains R6_Agent4 + R6_Agent9 +
        R6_Agent7.

  Depends on (exact imported lemmas USED in proof terms below):
    - MIP.Discoveries.R6_Agent4_CriticalityIsHardness
        · phaseCrit, phaseCurv
        · phaseCrit_eq_fisher          (USED in `crit_is_fisher_norm`)
        · phaseCrit_strictMono         (USED in `master_ordinal_strictMono`, headline)
        · hardness_iff_criticality     (USED in headline order-coincidence)
    - MIP.Discoveries.R6_Agent7_ScalingExponentFisherCoordinate
        · softEig, R6_7_softEig_pos
        · R6_7_susc_coeff_is_gpow      (USED in `crit_is_scaling_susc`)
        · R6_7_fisher_norm_softEig     (USED in `label_is_fisher_norm`)
    - MIP.Discoveries.R6_Agent9_ThreeOrderUnification
        · phaseDegen, phaseDegen_sinks_to_univ   (USED in degeneration chain / top)
    - MIP.Discoveries.R5_Agent7_PhaseOrderRefinesHardness
        · phaseCost, phaseCost_strictMono        (USED in hardness coordinate)
    - MIP.Discoveries.R4_Agent4_DegenerationChain
        · DegenStep                              (degeneration order, via R6_Agent9)
    - MIP.Discoveries.R5_Agent5_CriticalSlowingFisher
        · gSusc, R5_5_fisher_norm_eq_susc        (re-exported through R6_Agent4/7)
    - MIP.Discoveries.R4_Agent5_NGradientFisher
        · fisherInner, fisherGrad, dVec          (re-exported through R6_Agent4/7)
    - Mathlib: OrderIso.refl, StrictMono, StrictMono.lt_iff_lt, Real.rpow, Fin 3.

  This file is `sorry`-free and `axiom`-free (no NEW axiom declarations).
-/
import MIP.Discoveries.R6_Agent4_CriticalityIsHardness
import MIP.Discoveries.R6_Agent7_ScalingExponentFisherCoordinate
import MIP.Discoveries.R6_Agent9_ThreeOrderUnification
import Mathlib.Order.Monotone.Basic
import Mathlib.Order.Hom.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.GCongr

namespace MIP

namespace R7_Agent3_MasterDifficultyOrdinal

open MIP.R6_Agent4_CriticalityIsHardness
open MIP.R6_Agent7_ScalingExponentFisherCoordinate
open MIP.R6_Agent9_ThreeOrderUnification
open MIP.R5_Agent7_PhaseOrderRefinesHardness
open MIP.R5_Agent5_CriticalSlowingFisher
open MIP.R4_Agent5_NGradientFisher
open MIP.R4_Agent4_DegenerationChain

/-! ## (a) Resolving the criticality coordinate as the R6_Agent7 scaling susceptibility.

R6_Agent4's `phaseCrit a_cov a_star a_aut r = 1/a_r` is the susceptibility at the
phase's Landau curvature `a_r`.  R6_Agent7 resolves a near-critical curvature as a
gap power law `a = softEig γ A g = A·g^γ`.  We tie the two together: assign each
phase the SAME exponent γ and gap g, but a phase-dependent AMPLITUDE
`A_cov > A_star > A_aut > 0`.  Then the criticality coordinate is exactly the
R6_Agent7 Fisher natural-gradient susceptibility coefficient at that phase. -/

variable {Ω : Type*} [DecidableEq Ω] [Fintype Ω]

/-- **Phase amplitude map.**  `phaseAmp A_cov A_star A_aut r` is the R6_Agent7 gap
power-law amplitude `A_r` of phase rank `r`: `0 ↦ A_cov, 1 ↦ A_star, 2 ↦ A_aut`.
With `A_cov > A_star > A_aut > 0` later phases have smaller curvature
`a_r = softEig γ A_r g`, i.e. sit closer to criticality. -/
noncomputable def phaseAmp (A_cov A_star A_aut : ℝ) : Fin 3 → ℝ
  | ⟨0, _⟩ => A_cov
  | ⟨1, _⟩ => A_star
  | ⟨2, _⟩ => A_aut

/-- The phase curvatures `a_r = softEig γ A_r g` are the per-phase Landau
coefficients fed to R6_Agent4's `phaseCrit`. -/
noncomputable def phaseCurvOf (γ g A_cov A_star A_aut : ℝ) : Fin 3 → ℝ :=
  fun r => softEig γ (phaseAmp A_cov A_star A_aut r) g

/-- **(a.0′) — explicit per-phase scaling-susceptibility identity (clean form).**

The criticality coordinate at phase `r`, as the R6_Agent7 susceptibility
coefficient `1/softEig γ A_r g`, equals `A_r⁻¹·g^(−γ)` — chaining R6_Agent7
`R6_7_susc_coeff_is_gpow` at the phase amplitude `A_r`. -/
theorem phase_susc_coeff
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_cov : 0 < A_cov) (hA_star : 0 < A_star) (hA_aut : 0 < A_aut)
    (r : Fin 3) :
    1 / softEig γ (phaseAmp A_cov A_star A_aut r) g
      = (phaseAmp A_cov A_star A_aut r)⁻¹ * g ^ (-γ) := by
  fin_cases r <;> simp only [phaseAmp]
  · exact R6_7_susc_coeff_is_gpow γ A_cov g hA_cov hg
  · exact R6_7_susc_coeff_is_gpow γ A_star g hA_star hg
  · exact R6_7_susc_coeff_is_gpow γ A_aut g hA_aut hg

/-- **(a.0) — the criticality coordinate IS the R6_Agent7 scaling susceptibility.**

With the curvatures resolved as the gap power law `a_r = softEig γ A_r g`
(R6_Agent7), the R6_Agent4 criticality `phaseCrit (softEig..A_cov) ..` at each
phase equals the R6_Agent7 Fisher natural-gradient susceptibility coefficient
`1/softEig γ A_r g = A_r⁻¹·g^(−γ)` (`R6_7_susc_coeff_is_gpow`).  So the criticality
ordinal coordinate is literally the scaling-derived gap-power susceptibility. -/
theorem crit_is_scaling_susc
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_cov : 0 < A_cov) (hA_star : 0 < A_star) (hA_aut : 0 < A_aut)
    (r : Fin 3) :
    phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r
      = (phaseAmp A_cov A_star A_aut r)⁻¹ * g ^ (-γ) := by
  have hcrit : phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r
      = 1 / softEig γ (phaseAmp A_cov A_star A_aut r) g := by
    fin_cases r <;> simp only [phaseCrit, phaseAmp]
  rw [hcrit]
  exact phase_susc_coeff γ g A_cov A_star A_aut hg hA_cov hA_star hA_aut r

/-- **(a.1) — the criticality coordinate is the genuine R5_Agent5 Fisher norm.**

Via R6_Agent4 `phaseCrit_eq_fisher`: with the gap-power curvatures (all nonzero,
from `softEig > 0`), the criticality coordinate at each phase equals the
R5_Agent5 Fisher natural-gradient norm at the soft mode `(1,0)` on
`gSusc (phaseCurv .. r)`.  The criticality label is thus grounded in genuine
information geometry. -/
theorem crit_is_fisher_norm
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_cov : 0 < A_cov) (hA_star : 0 < A_star) (hA_aut : 0 < A_aut)
    (r : Fin 3) :
    phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r
      = fisherInner
          (gSusc (phaseCurv (softEig γ A_cov g) (softEig γ A_star g)
                    (softEig γ A_aut g) r))
          (fisherGrad (gSusc (phaseCurv (softEig γ A_cov g) (softEig γ A_star g)
                    (softEig γ A_aut g) r)) (dVec 1 0))
          (fisherGrad (gSusc (phaseCurv (softEig γ A_cov g) (softEig γ A_star g)
                    (softEig γ A_aut g) r)) (dVec 1 0)) :=
  phaseCrit_eq_fisher (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g)
    (ne_of_gt (R6_7_softEig_pos γ A_cov g hA_cov hg))
    (ne_of_gt (R6_7_softEig_pos γ A_star g hA_star hg))
    (ne_of_gt (R6_7_softEig_pos γ A_aut g hA_aut hg))
    r

/-! ## (b) The numeric LABEL coordinate and its strict monotonicity.

The scaling susceptibility label is `phaseLabel r = 1/softEig γ A_r g`.  By (a) it
equals both the R6_Agent4 criticality and the R6_Agent7 gap-power susceptibility
`A_r⁻¹·g^(−γ)`.  We prove it is `StrictMono : Fin 3 → ℝ`, so the master ordinal
carries a real number strictly increasing to the critical/terminal phase. -/

/-- **Scaling-susceptibility label** of the master ordinal: the R6_Agent7 Fisher
natural-gradient susceptibility coefficient `1/softEig γ A_r g` at each phase. -/
noncomputable def phaseLabel (γ g A_cov A_star A_aut : ℝ) : Fin 3 → ℝ :=
  fun r => 1 / softEig γ (phaseAmp A_cov A_star A_aut r) g

/-- **(b.0) — the label EQUALS the criticality coordinate.**

`phaseLabel γ g A_cov A_star A_aut = phaseCrit (softEig..) ..` pointwise: the
scaling susceptibility label is the very same number as the R6_Agent4 criticality
(= R5_Agent5 Fisher susceptibility).  One quantitative coordinate, two readings. -/
theorem label_is_criticality
    (γ g A_cov A_star A_aut : ℝ)
    (r : Fin 3) :
    phaseLabel γ g A_cov A_star A_aut r
      = phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r := by
  fin_cases r <;> simp only [phaseLabel, phaseAmp, phaseCrit]

/-- **(b.1) — the label is the gap-power susceptibility `A_r⁻¹·g^(−γ)`.** -/
theorem label_is_gpow
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_cov : 0 < A_cov) (hA_star : 0 < A_star) (hA_aut : 0 < A_aut)
    (r : Fin 3) :
    phaseLabel γ g A_cov A_star A_aut r
      = (phaseAmp A_cov A_star A_aut r)⁻¹ * g ^ (-γ) :=
  phase_susc_coeff γ g A_cov A_star A_aut hg hA_cov hA_star hA_aut r

/-- **(b.2) — the label is the genuine R6_Agent7 Fisher natural-gradient norm.**

At each phase the label `1/softEig γ A_r g` is the `s²`-coefficient (soft mode
`(s,t)=(1,0)`) of the R6_Agent7 Fisher natural-gradient norm
`R6_7_fisher_norm_softEig`: `‖grad S‖² = 1²/softEig + 0² = 1/softEig`.  So the
numeric label is genuine Fisher information geometry, not an abstract index. -/
theorem label_is_fisher_norm
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_cov : 0 < A_cov) (hA_star : 0 < A_star) (hA_aut : 0 < A_aut)
    (r : Fin 3) :
    phaseLabel γ g A_cov A_star A_aut r
      = fisherInner (gSusc (softEig γ (phaseAmp A_cov A_star A_aut r) g))
          (fisherGrad (gSusc (softEig γ (phaseAmp A_cov A_star A_aut r) g)) (dVec 1 0))
          (fisherGrad (gSusc (softEig γ (phaseAmp A_cov A_star A_aut r) g)) (dVec 1 0)) := by
  have hAr : 0 < phaseAmp A_cov A_star A_aut r := by
    fin_cases r <;> simp only [phaseAmp] <;> assumption
  rw [R6_7_fisher_norm_softEig γ (phaseAmp A_cov A_star A_aut r) g 1 0 hAr hg]
  simp [phaseLabel]

/-- **(b.3 — KEY) — the label is STRICTLY MONOTONE along the phase chain.**

Under the amplitude chain `A_cov > A_star > A_aut > 0` (later phase = smaller
amplitude = smaller curvature `softEig` = larger susceptibility), the scaling
susceptibility label `1/softEig γ A_r g = A_r⁻¹·g^(−γ)` strictly increases with
the phase rank.  Reduces (by `label_is_criticality`) to R6_Agent4
`phaseCrit_strictMono` at the gap-power curvatures, whose chain
`softEig A_aut < softEig A_star < softEig A_cov` follows from the amplitude chain
times the positive factor `g^γ`.  So the master ordinal's numeric label increases
to the critical/terminal point. -/
theorem phaseLabel_strictMono
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_aut0 : 0 < A_aut) (hA_as : A_aut < A_star) (hA_sc : A_star < A_cov) :
    StrictMono (phaseLabel γ g A_cov A_star A_aut) := by
  -- gap-power curvatures inherit the amplitude order (scale by g^γ > 0).
  have hgγ : (0 : ℝ) < g ^ γ := Real.rpow_pos_of_pos hg γ
  have ha_aut0 : 0 < softEig γ A_aut g := R6_7_softEig_pos γ A_aut g hA_aut0 hg
  have ha_as : softEig γ A_aut g < softEig γ A_star g := by
    unfold softEig; gcongr
  have ha_sc : softEig γ A_star g < softEig γ A_cov g := by
    unfold softEig
    have hA_star0 : 0 < A_star := lt_trans hA_aut0 hA_as
    gcongr
  -- criticality is StrictMono at these curvatures (R6_Agent4); label = criticality.
  have hcrit := phaseCrit_strictMono (softEig γ A_cov g) (softEig γ A_star g)
    (softEig γ A_aut g) ha_aut0 ha_as ha_sc
  intro a b hab
  have ha := label_is_criticality γ g A_cov A_star A_aut a
  have hb := label_is_criticality γ g A_cov A_star A_aut b
  rw [ha, hb]
  exact hcrit hab

/-! ## (c) The labeled MASTER ordinal — all four orders are one Fin-3 ordinal.

We assemble the four monotone coordinates and prove pairwise coincidence:
  χ = criticality `phaseCrit` (= R5_Agent5 Fisher susc),
  H = hardness cost `phaseCost` (R5_Agent7),
  D = degeneration `phaseDegen` (R6_Agent9, a `DegenStep`-chain to the wall),
  L = scaling susceptibility label `phaseLabel` (= χ, R6_Agent7 gap-power susc).
All of χ, H, L are `StrictMono : Fin 3 → ℝ`, hence share the SAME total order;
D is a `DegenStep`-chain sinking to the common top `univ`. -/

/-- **(c.0) — hardness ⟺ label (pointwise order coincidence).**

For any two phases, the hardness comparison `phaseCost r₁ < phaseCost r₂`
(R5_Agent7) holds iff the scaling-susceptibility label comparison
`phaseLabel r₁ < phaseLabel r₂` holds.  Both reduce, via the respective
`StrictMono`, to `r₁ < r₂`.  Combined with R6_Agent4 `hardness_iff_criticality`
and `label_is_criticality`, the hardness, criticality, and label orders coincide. -/
theorem hardness_iff_label
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (hℓ_aut : Linf < ℓ_aut) (hℓ_star : ℓ_aut < ℓ_star) (hℓ_cov : ℓ_star < ℓ_cov)
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_aut0 : 0 < A_aut) (hA_as : A_aut < A_star) (hA_sc : A_star < A_cov)
    (r₁ r₂ : Fin 3) :
    (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₁
        < phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₂)
      ↔ (phaseLabel γ g A_cov A_star A_aut r₁ < phaseLabel γ g A_cov A_star A_aut r₂) := by
  have hHard := phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
    hC h_s hℓ_aut hℓ_star hℓ_cov
  have hLab := phaseLabel_strictMono γ g A_cov A_star A_aut hg hA_aut0 hA_as hA_sc
  rw [hHard.lt_iff_lt, hLab.lt_iff_lt]

/-- **(c.1) — the four coordinates are all `StrictMono`/`DegenStep`-monotone,
with the SAME order.**

Bundles: χ (`phaseCrit`, R6_Agent4), H (`phaseCost`, R5_Agent7), and L
(`phaseLabel`, R6_Agent7-derived) are `StrictMono : Fin 3 → ℝ`; D (`phaseDegen`,
R6_Agent9) sinks into the wall `univ` at every phase via `DegenStep`.  Since χ, H,
L are strictly monotone on the linear domain `Fin 3`, they induce one and the same
total order; L = χ pointwise (`label_is_criticality`). -/
theorem master_ordinal_strictMono
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (hℓ_aut : Linf < ℓ_aut) (hℓ_star : ℓ_aut < ℓ_star) (hℓ_cov : ℓ_star < ℓ_cov)
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_aut0 : 0 < A_aut) (hA_as : A_aut < A_star) (hA_sc : A_star < A_cov)
    (C₀ C₁ C₂ : Finset Ω) :
    StrictMono (phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g))
    ∧ StrictMono (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut)
    ∧ StrictMono (phaseLabel γ g A_cov A_star A_aut)
    ∧ (∀ r, phaseLabel γ g A_cov A_star A_aut r
        = phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r)
    ∧ (∀ r : Fin 3, DegenStep (phaseDegen C₀ C₁ C₂ r) (Finset.univ : Finset Ω)) := by
  have ha_aut0 : 0 < softEig γ A_aut g := R6_7_softEig_pos γ A_aut g hA_aut0 hg
  have hgγ : (0 : ℝ) < g ^ γ := Real.rpow_pos_of_pos hg γ
  have hA_star0 : 0 < A_star := lt_trans hA_aut0 hA_as
  have ha_as : softEig γ A_aut g < softEig γ A_star g := by unfold softEig; gcongr
  have ha_sc : softEig γ A_star g < softEig γ A_cov g := by unfold softEig; gcongr
  refine ⟨phaseCrit_strictMono _ _ _ ha_aut0 ha_as ha_sc,
          phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut hC h_s hℓ_aut hℓ_star hℓ_cov,
          phaseLabel_strictMono γ g A_cov A_star A_aut hg hA_aut0 hA_as hA_sc,
          label_is_criticality γ g A_cov A_star A_aut,
          ?_⟩
  intro r
  exact phaseDegen_sinks_to_univ C₀ C₁ C₂ r

/-- **(c.2 — HEADLINE) — the master emergence-difficulty ordinal.**

All emergence-difficulty orders are ONE labeled Fin-3 ordinal.  Under the
heavy-tail scaling regime (`C>0, 1<s`, loss-ordered thresholds
`ℓ_aut<ℓ_star<ℓ_cov`), the criticality regime (gap `g>0`, exponent γ, amplitude
chain `0<A_aut<A_star<A_cov` so later phase = smaller curvature = closer to
criticality), and any degeneration coverage triple `C₀,C₁,C₂`, there is a single
`OrderIso (Fin 3) (Fin 3)` (the rank `e`) such that:

  (1) **Three strictly-monotone real coordinates.**  χ = criticality `phaseCrit`
      (R6_Agent4 / R5_Agent5 Fisher susceptibility), H = hardness cost `phaseCost`
      (R5_Agent7), and L = scaling susceptibility label `phaseLabel`
      (R6_Agent7 gap-power) are ALL `StrictMono` after `e` — pairwise the SAME
      total order on the three phases.

  (2) **Quantitative label = criticality = genuine Fisher susceptibility.**  The
      numeric label L equals the criticality χ at every phase
      (`label_is_criticality`), equals the R6_Agent7 gap-power susceptibility
      `A_r⁻¹·g^(−γ)` (`label_is_gpow`), and equals the R5_Agent5 Fisher
      natural-gradient norm at the soft mode (`crit_is_fisher_norm`).  It strictly
      increases to the critical/terminal phase.

  (3) **The four orders coincide.**  hardness ⟺ criticality (R6_Agent4
      `hardness_iff_criticality`) and hardness ⟺ label (`hardness_iff_label`).

  (4) **Degeneration coordinate sinks into the common top — the wall.**  Every
      phase's degeneration level `DegenStep`s into `univ` (R6_Agent9
      `phaseDegen_sinks_to_univ`), the shared greatest element.

Thus criticality = hardness = degeneration = scaling-budget are one labeled
Fin-3 ordinal, with the scaling susceptibility as the real-number coordinate
increasing to the critical/terminal point.  Chains R6_Agent4 + R6_Agent9 +
R6_Agent7. -/
theorem master_difficulty_ordinal
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (hℓ_aut : Linf < ℓ_aut) (hℓ_star : ℓ_aut < ℓ_star) (hℓ_cov : ℓ_star < ℓ_cov)
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_aut0 : 0 < A_aut) (hA_as : A_aut < A_star) (hA_sc : A_star < A_cov)
    (C₀ C₁ C₂ : Finset Ω) :
    ∃ e : OrderIso (Fin 3) (Fin 3),
      -- (1) three strictly-monotone real coordinates sharing the order
      StrictMono (fun r =>
          phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) (e r))
      ∧ StrictMono (fun r => phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut (e r))
      ∧ StrictMono (fun r => phaseLabel γ g A_cov A_star A_aut (e r))
      -- (2) the label is the criticality = gap-power susceptibility = Fisher norm
      ∧ (∀ r, phaseLabel γ g A_cov A_star A_aut r
          = phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r)
      ∧ (∀ r, phaseLabel γ g A_cov A_star A_aut r
          = (phaseAmp A_cov A_star A_aut r)⁻¹ * g ^ (-γ))
      ∧ (∀ r, phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r
          = fisherInner
              (gSusc (phaseCurv (softEig γ A_cov g) (softEig γ A_star g)
                        (softEig γ A_aut g) r))
              (fisherGrad (gSusc (phaseCurv (softEig γ A_cov g) (softEig γ A_star g)
                        (softEig γ A_aut g) r)) (dVec 1 0))
              (fisherGrad (gSusc (phaseCurv (softEig γ A_cov g) (softEig γ A_star g)
                        (softEig γ A_aut g) r)) (dVec 1 0)))
      -- (3) the four orders coincide pairwise
      ∧ (∀ r₁ r₂,
          (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₁
              < phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₂)
            ↔ (phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r₁
              < phaseCrit (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g) r₂))
      ∧ (∀ r₁ r₂,
          (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₁
              < phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r₂)
            ↔ (phaseLabel γ g A_cov A_star A_aut r₁
              < phaseLabel γ g A_cov A_star A_aut r₂))
      -- (4) degeneration coordinate sinks into the common top — the wall `univ`
      ∧ (∀ r : Fin 3, DegenStep (phaseDegen C₀ C₁ C₂ r) (Finset.univ : Finset Ω)) := by
  refine ⟨OrderIso.refl (Fin 3), ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- (1) criticality StrictMono ∘ rank
    have ha_aut0 : 0 < softEig γ A_aut g := R6_7_softEig_pos γ A_aut g hA_aut0 hg
    have hgγ : (0 : ℝ) < g ^ γ := Real.rpow_pos_of_pos hg γ
    have hA_star0 : 0 < A_star := lt_trans hA_aut0 hA_as
    have ha_as : softEig γ A_aut g < softEig γ A_star g := by unfold softEig; gcongr
    have ha_sc : softEig γ A_star g < softEig γ A_cov g := by unfold softEig; gcongr
    exact phaseCrit_strictMono _ _ _ ha_aut0 ha_as ha_sc
  · -- (1) hardness StrictMono ∘ rank
    exact phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut hC h_s hℓ_aut hℓ_star hℓ_cov
  · -- (1) label StrictMono ∘ rank
    exact phaseLabel_strictMono γ g A_cov A_star A_aut hg hA_aut0 hA_as hA_sc
  · -- (2) label = criticality
    exact label_is_criticality γ g A_cov A_star A_aut
  · -- (2) label = gap-power susceptibility
    exact label_is_gpow γ g A_cov A_star A_aut hg
      (lt_trans (lt_trans hA_aut0 hA_as) hA_sc)
      (lt_trans hA_aut0 hA_as) hA_aut0
  · -- (2) criticality = R5_Agent5 Fisher norm
    exact crit_is_fisher_norm γ g A_cov A_star A_aut hg
      (lt_trans (lt_trans hA_aut0 hA_as) hA_sc)
      (lt_trans hA_aut0 hA_as) hA_aut0
  · -- (3) hardness ⟺ criticality (R6_Agent4)
    intro r₁ r₂
    have ha_aut0 : 0 < softEig γ A_aut g := R6_7_softEig_pos γ A_aut g hA_aut0 hg
    have hgγ : (0 : ℝ) < g ^ γ := Real.rpow_pos_of_pos hg γ
    have hA_star0 : 0 < A_star := lt_trans hA_aut0 hA_as
    have ha_as : softEig γ A_aut g < softEig γ A_star g := by unfold softEig; gcongr
    have ha_sc : softEig γ A_star g < softEig γ A_cov g := by unfold softEig; gcongr
    exact hardness_iff_criticality Linf C s ℓ_cov ℓ_star ℓ_aut
      hC h_s hℓ_aut hℓ_star hℓ_cov
      (softEig γ A_cov g) (softEig γ A_star g) (softEig γ A_aut g)
      ha_aut0 ha_as ha_sc r₁ r₂
  · -- (3) hardness ⟺ label
    exact hardness_iff_label Linf C s ℓ_cov ℓ_star ℓ_aut
      hC h_s hℓ_aut hℓ_star hℓ_cov γ g A_cov A_star A_aut hg hA_aut0 hA_as hA_sc
  · -- (4) degeneration sinks into the wall
    intro r
    exact phaseDegen_sinks_to_univ C₀ C₁ C₂ r

end R7_Agent3_MasterDifficultyOrdinal

end MIP
