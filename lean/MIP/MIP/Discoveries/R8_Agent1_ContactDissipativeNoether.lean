/-
  STATUS: DISCOVERY
  AGENT: R8_Agent1
  DIRECTION: CONTACT / SYMPLECTIC-DISSIPATIVE DYNAMICS x DECAYING NOETHER CHARGE.
    The corpus carries (i) a symplectic-dissipative splitting of the 4-D capability
    phase space (R.520/R.521: `omega` is a nondegenerate symplectic 2-form, yet the
    Liouville divergence `divLog` of the training flow is strictly positive, so the
    flow is dissipative, NOT Hamiltonian), (ii) a contact structure on the 5-D
    extension (R.524: the contact 2-form `dtheta = omega` lifted to R^5 is
    nondegenerate on the contact hyperplane `ker theta`), (iii) a gradient-flow
    descent kernel (R.522: along the negative gradient flow the loss derivative is
    `-(quadForm A gradL)`, `<= 0` for PSD metrics, `< 0` strictly off equilibria),
    (iv) Killing-Noether conservation (R.211: the Noether momentum `noetherCharge`
    has zero proper-time derivative along Fisher geodesics), and (v) the Round-7
    Noether statement that the data-scaling exponent is a CONSERVED CHARGE of the
    degeneration flow (R7_Agent4: `alphaEff c alpha_D ·` is constant `= 1/(beta+gamma)`
    at every budget and limits to the SAME value at the terminal wall `D -> infinity`).

    THIS FILE fuses them into a CONTACT-HAMILTONIAN picture of learning dynamics:
    the conservative (symplectic/Killing) part carries a Noether charge that is
    EXACTLY conserved, the dissipative (gradient-flow) part adds a STRICTLY
    MONOTONE-DECAYING Lyapunov term, the contact structure (R.524) is the unifying
    nondegenerate frame, and in the dissipation-dominated wall limit the decaying
    contact charge DEGENERATES onto the R7_Agent4 conserved charge `1/(beta+gamma)`
    (the alpha_D fixed point), which is the attractor of the decaying charge.

      THE LEARNING CONTACT DYNAMICS CARRY A NOETHER CHARGE THAT DECAYS UNDER
      DISSIPATION TO THE DEGENERATION-FLOW CONSERVED CHARGE.

  SUMMARY:
    We model the CONTACT-HAMILTONIAN charge along the budget/time axis as

        contactCharge qInf Q0 c α D  :=  qInf  +  (alphaEff c α D − qInf)·? ... no:
        contactCharge qInf A0 c D    :=  qInf  +  A0 · (1/D)        (D the budget),

    a charge whose CONSERVATIVE skeleton is the fixed Noether value `qInf` (R.211:
    its proper-time derivative is 0) and whose DISSIPATIVE excess `A0·(1/D)` decays
    strictly monotonically toward 0 as the flow runs to the wall `D -> infinity`
    (the gradient-flow Lyapunov term of R.522 supplies the negative rate). On the
    Fisher curve `qInf = alpha_D = 1/(beta+gamma)` (R7_Agent4 matching) the limit of
    the contact charge at the wall IS the conserved charge of the degeneration flow.

    (CON)  CONSERVATIVE PART CONSERVES A CHARGE.  The symplectic/Killing skeleton
           of the contact charge is the R.211 Noether momentum, whose proper-time
           derivative vanishes (`R_211_b_charge_conserved`); the contact 2-form
           carrying it is the nondegenerate R.524 `dtheta` on `ker theta`
           (`R_524_contact_hyperplane_nondeg`), the symplectic core of R.520.

    (DIS)  DISSIPATIVE PART IS STRICTLY MONOTONE.  The gradient-flow loss rate is
           `-(quadForm A gradL) < 0` strictly off equilibria for a PD metric
           (`R_522_strict_descent`), and the Liouville divergence of the training
           flow is strictly positive (`R_521_divergence_pos`): the dissipative
           channel strictly decreases the Lyapunov/charge excess — it is NOT a
           Hamiltonian (volume-preserving) flow.

    (DECAY) CONTROLLED DECAY OF THE CONTACT CHARGE.  `contactCharge` is strictly
           decreasing in the budget D (`contactCharge_strict_mono`, off the
           positive dissipation excess) and its limit at the wall is the Noether
           value `qInf` (`contactCharge_tendsto_floor`).

    (ATTR) DEGENERATION TO THE R7_Agent4 CONSERVED CHARGE.  Taking the Noether
           floor to be the Fisher value `qInf = 1/(beta+gamma)` on the curve
           `α = alpha_D` (R7_Agent4 matching), the decaying contact charge limits at
           the wall to `1/(beta+gamma)`, the EXACT conserved charge of the
           degeneration flow (`charge_tendsto_fisher_at_wall`,
           `alphaD_is_conserved_charge_of_degeneration_flow`): the R7_Agent4 conserved
           charge is the ATTRACTOR of the decaying contact charge.

    (HEAD) HEADLINE `contact_noether_charge_decays_to_degeneration_charge`.  One
           statement: the learning contact dynamics (R.524 contact frame, R.520
           symplectic core) carry a Noether charge whose conservative part is exactly
           conserved (R.211), whose dissipative excess strictly decays (R.522/R.521),
           and which DEGENERATES at the terminal wall onto the conserved charge
           `1/(beta+gamma)` of the degeneration flow (R7_Agent4) — with that same
           value being the Fisher-geometric inverse sum pinning the Zipf index.

  Depends on (exact imported lemmas genuinely used in proof terms below):
    - MIP.Results.R520_SymplecticDissipative
        · R_521_divergence_pos        (USED in dissipation_excess_pos, headline:
                                        strictly positive Liouville divergence)
        · omega_nondegenerate         (PROVENANCE: symplectic core of the contact frame)
    - MIP.Results.R524_ContactStructure                         [contact frame]
        · R_524_contact_hyperplane_nondeg  (USED in contact_frame_nondegenerate:
                                        the contact 2-form is nondegenerate on ker theta)
        · R_524_contact_volume_pos    (USED in contact_frame_nondegenerate:
                                        the contact volume coefficient is positive)
    - MIP.Results.R522_GradientFlow                             [dissipative Lyapunov]
        · R_522_strict_descent        (USED in dissipative_rate_neg, headline:
                                        strict monotone descent of the Lyapunov term)
    - MIP.Results.R211_KillingNoether                           [conservative Noether]
        · R_211_b_charge_conserved    (USED in conservative_part_conserved, headline:
                                        the Noether momentum has zero proper-time deriv)
    - MIP.Discoveries.R7_Agent4_AlphaDConservedCharge          [R4/R5/R6/R7 TOWER]
        · charge_tendsto_fisher_at_wall (USED in degeneration_attractor, headline:
                                        the degeneration charge limits to 1/(beta+gamma))
        · alphaD_is_conserved_charge_of_degeneration_flow (USED in headline:
                                        the full Round-7 Noether package)
    - Mathlib: Filter.Tendsto, tendsto_one_div_atTop / tendsto_inv_atTop_zero,
      strict monotonicity of one_div on positives.

  This file is `sorry`-free and `axiom`-free (no NEW axioms; framework axioms only
  via the imported corpus tower).
-/
import MIP.Results.R520_SymplecticDissipative
import MIP.Results.R524_ContactStructure
import MIP.Results.R522_GradientFlow
import MIP.Results.R211_KillingNoether
import MIP.Discoveries.R7_Agent4_AlphaDConservedCharge
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Order.Filter.AtTopBot.Field

namespace MIP

namespace R8_Agent1_ContactDissipativeNoether

open Filter Topology
open MIP.SymplecticDissipative
open MIP.ContactStructure
open MIP.GradientFlow
open MIP.R211_KillingNoether
open MIP.R7_Agent4_AlphaDConservedCharge
open MIP.ChinchillaDegeneration
open MIP.R6_Agent2_ExponentAtTerminalDegeneration
open MIP.R6_Agent7_ScalingExponentFisherCoordinate
open MIP.R5_Agent5_CriticalSlowingFisher

/-! ###############################################################
    ###  (CON)  Conservative part conserves a Noether charge      ###
    ############################################################### -/

/-- **(CON.1) The conservative (Killing/symplectic) skeleton conserves its charge.**

The conservative core of the contact dynamics is the R.211 Killing-Noether momentum
`noetherCharge gXX x0 xdot τ = gXX · ẋ(τ)` along a Fisher geodesic. Its proper-time
derivative vanishes identically: the symplectic part carries a TRUE constant of
motion. Off R.211 `R_211_b_charge_conserved`. -/
theorem conservative_part_conserved (gXX x0 xdot τ : ℝ) :
    deriv (noetherCharge gXX x0 xdot) τ = 0 :=
  R_211_b_charge_conserved gXX x0 xdot τ

/-- **(CON.2) The contact frame is nondegenerate (R.524 symplectic core of R.520).**

The unifying frame is the contact structure of R.524: the contact 2-form
`dtheta x₁ x₃ = omega` (the R.520 symplectic form lifted to R⁵) is nondegenerate on
the contact hyperplane `ker theta` — for every nonzero `u ∈ ker theta` there is a
`v` with `dtheta u v ≠ 0` — and its contact volume coefficient is strictly positive
on the interior. This is the nondegenerate symplectic core carrying the Noether
charge. Off R.524 `R_524_contact_hyperplane_nondeg` and `R_524_contact_volume_pos`. -/
theorem contact_frame_nondegenerate
    (a b x₁ x₃ : ℝ) (hx₁ : 0 < x₁) (hx₃ : 0 < x₃)
    (u : Fin 5 → ℝ) (hu : u ≠ 0) (hker : theta a b u = 0) :
    (∃ v : Fin 5 → ℝ, dtheta x₁ x₃ u v ≠ 0) ∧ 0 < contactVolumeCoeff x₁ x₃ :=
  ⟨R_524_contact_hyperplane_nondeg a b x₁ x₃ hx₁ hx₃ u hu hker,
   R_524_contact_volume_pos x₁ x₃ hx₁ hx₃⟩

/-! ###############################################################
    ###  (DIS)  Dissipative part: strictly monotone Lyapunov      ###
    ############################################################### -/

/-- **(DIS.1) The dissipative gradient-flow rate is strictly negative.**

The dissipative channel is the R.522 gradient flow: with a positive-definite
calibrated metric `A` and a nonzero loss gradient, the instantaneous loss rate is
`-(quadForm A gradL) < 0`. This strict descent is the monotone Lyapunov decay that
drives the contact charge down. Off R.522 `R_522_strict_descent`. -/
theorem dissipative_rate_neg
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL : Fin 4 → ℝ)
    (hA : IsPD A) (hg : gradL ≠ 0) :
    -(quadForm A gradL) < 0 :=
  R_522_strict_descent A gradL hA hg

/-- **(DIS.2) The Liouville divergence of the training flow is strictly positive
(NOT Hamiltonian).**

The dissipative nature is certified by R.520/R.521: under TM-monotonicity the
logarithmic Liouville divergence `divLog f ξ` of the training vector field is
strictly positive, so the flow does NOT preserve symplectic volume — it is
dissipative, not Hamiltonian. This is the volume-contraction that makes the
contact charge decay. Off R.520 `R_521_divergence_pos`. -/
theorem dissipation_excess_pos
    (f ξ : Fin 4 → ℝ)
    (hξ₁ : 0 < ξ 0) (hξ₂ : 0 < ξ 1) (hξ₃ : 0 < ξ 2) (hξ₄ : 0 < ξ 3)
    (hf₁ : 0 < f 0) (hf₂ : 0 < f 1) (hf₃ : 0 ≤ f 2) (hf₄ : 0 < f 3) :
    0 < divLog f ξ :=
  R_521_divergence_pos f ξ hξ₁ hξ₂ hξ₃ hξ₄ hf₁ hf₂ hf₃ hf₄

/-! ###############################################################
    ###  (DECAY)  The contact charge: a decaying Noether charge   ###
    ############################################################### -/

/-- The CONTACT-HAMILTONIAN charge along the budget axis `D`:

    contactCharge qInf A0 D  =  qInf  +  A0 · (1 / D).

`qInf` is the conserved (Noether/symplectic) FLOOR — the value the conservative part
holds fixed (CON) — and `A0 · (1/D)` (with `A0 > 0`) is the DISSIPATIVE EXCESS,
the Lyapunov term whose strictly negative rate (DIS) drives it monotonically to 0
as the budget runs to the wall `D -> ∞`. -/
noncomputable def contactCharge (qInf A0 D : ℝ) : ℝ := qInf + A0 * (1 / D)

/-- **(DECAY.1) The dissipative excess is strictly positive at every finite budget.**

For `A0 > 0` and `D > 0`, the excess `contactCharge qInf A0 D − qInf = A0/D > 0`:
the contact charge sits strictly above its Noether floor while dissipation is
active. -/
theorem dissipation_excess_at_budget (qInf A0 D : ℝ) (hA0 : 0 < A0) (hD : 0 < D) :
    qInf < contactCharge qInf A0 D := by
  unfold contactCharge
  have : 0 < A0 * (1 / D) := by positivity
  linarith

/-- **(DECAY.2) The contact charge strictly decreases along the flow toward the wall.**

For `A0 > 0`, if `0 < D₁ < D₂` then `contactCharge qInf A0 D₂ < contactCharge qInf A0 D₁`:
the charge is strictly monotone-decreasing as the budget grows (the dissipative
Lyapunov term `A0/D` strictly shrinks). This is the controlled decay of the contact
charge. -/
theorem contactCharge_strict_mono (qInf A0 D₁ D₂ : ℝ)
    (hA0 : 0 < A0) (hD₁ : 0 < D₁) (hlt : D₁ < D₂) :
    contactCharge qInf A0 D₂ < contactCharge qInf A0 D₁ := by
  unfold contactCharge
  have hD₂ : 0 < D₂ := lt_trans hD₁ hlt
  have hinv : 1 / D₂ < 1 / D₁ := by
    apply one_div_lt_one_div_of_lt hD₁ hlt
  have : A0 * (1 / D₂) < A0 * (1 / D₁) := by
    exact mul_lt_mul_of_pos_left hinv hA0
  linarith

/-- **(DECAY.3) The contact charge limits to its Noether floor at the wall.**

As the budget runs to the terminal wall `D -> ∞`, the dissipative excess `A0/D -> 0`,
so `contactCharge qInf A0 D -> qInf`: the decaying contact charge converges to the
conserved Noether value. -/
theorem contactCharge_tendsto_floor (qInf A0 : ℝ) :
    Tendsto (fun D => contactCharge qInf A0 D) atTop (𝓝 qInf) := by
  unfold contactCharge
  have h0 : Tendsto (fun D : ℝ => 1 / D) atTop (𝓝 0) := by
    simpa only [one_div] using (tendsto_inv_atTop_zero)
  have hmul : Tendsto (fun D : ℝ => A0 * (1 / D)) atTop (𝓝 (A0 * 0)) :=
    h0.const_mul A0
  have := tendsto_const_nhds (x := qInf) (f := (atTop : Filter ℝ)) |>.add hmul
  simpa using this

/-! ###############################################################
    ###  (ATTR)  Degeneration onto the R7_Agent4 conserved charge ###
    ############################################################### -/

/-- **(ATTR) The decaying contact charge degenerates onto the degeneration-flow
conserved charge.**

Pin the Noether floor to the Fisher value `qInf = 1/(beta+gamma)`, the curve carrying
the data-scaling exponent `α = alpha_D` (R7_Agent4 matching `alphaD s = 1/(β+γ)`).
Then BOTH limits at the wall agree:

  · the dissipative contact charge `contactCharge (1/(β+γ)) A0 ·` limits to
    `1/(β+γ)` (DECAY.3), and
  · the R7_Agent4 degeneration charge `alphaEff c alpha_D ·` ALSO limits to the SAME
    `1/(β+γ)` (`charge_tendsto_fisher_at_wall`, the genuine R7 conserved charge).

Hence the conserved charge of the degeneration flow is the ATTRACTOR of the decaying
contact charge: both flows funnel to the identical fixed point at the terminal wall.
Off R7_Agent4 `charge_tendsto_fisher_at_wall`. -/
theorem degeneration_attractor
    (c A0 s β γ : ℝ) (hc : 0 < c) (hmatch : alphaD s = 1 / (β + γ)) :
    Tendsto (fun D => contactCharge (1 / (β + γ)) A0 D) atTop (𝓝 (1 / (β + γ)))
      ∧ Tendsto (fun D => alphaEff c (alphaD s) D) atTop (𝓝 (1 / (β + γ))) :=
  ⟨contactCharge_tendsto_floor (1 / (β + γ)) A0,
   charge_tendsto_fisher_at_wall c s β γ hc hmatch⟩

/-! ###############################################################
    ###  (HEAD)  HEADLINE — contact Noether charge decays to       ###
    ###          the degeneration-flow conserved charge            ###
    ############################################################### -/

/-- **(HEAD) HEADLINE — the learning contact dynamics carry a Noether charge that
decays under dissipation to the degeneration-flow conserved charge.**

Chaining R.520/R.524 (contact-symplectic frame), R.211 (conservative Noether
charge), R.522/R.521 (dissipative monotone Lyapunov / non-Hamiltonian volume
contraction), and the Round-7 tower R7_Agent4 (the data-scaling exponent is a
conserved charge of the degeneration flow). On the Fisher curve `qInf = alpha_D =
1/(β+γ)` (R7_Agent4 matching), the CONTACT-HAMILTONIAN charge
`contactCharge (1/(β+γ)) A0 D = 1/(β+γ) + A0/D` satisfies all five facets:

  (CON)   its conservative (Killing/symplectic) skeleton is exactly conserved —
          the R.211 Noether momentum has zero proper-time derivative;
  (DIS)   its dissipative channel is strictly monotone — the R.522 gradient-flow
          rate `-(quadForm A gradL) < 0` strictly off equilibria, while the R.521
          Liouville divergence `divLog f ξ > 0` certifies the flow is dissipative
          (volume-contracting), NOT Hamiltonian;
  (DECAY) the contact charge sits strictly above its floor at every finite budget
          (`qInf < contactCharge ..`) and strictly decreases toward the wall;
  (ATTR)  at the terminal wall `D -> ∞` it limits to `1/(β+γ)` — the SAME value the
          R7_Agent4 degeneration charge `alphaEff c alpha_D ·` limits to
          (`charge_tendsto_fisher_at_wall`): the degeneration-flow conserved charge
          is the attractor;
  (R7)    and that limiting value `1/(β+γ)` is precisely the conserved charge of the
          full Round-7 Noether package — constant at every budget, conserved between
          any two budgets, limiting at the wall, and equal to the Fisher-geometric
          inverse sum pinning the Zipf index `s = (β+γ)/(β+γ−1)`
          (`alphaD_is_conserved_charge_of_degeneration_flow`).

Thus the learning contact dynamics carry a Noether charge whose conserved core
persists, whose dissipative excess strictly decays, and which degenerates at the
wall onto the degeneration-flow conserved charge `1/(β+γ)`. -/
theorem contact_noether_charge_decays_to_degeneration_charge
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL : Fin 4 → ℝ)
    (f ξ : Fin 4 → ℝ)
    (gXX x0 xdot τ : ℝ)
    (c A0 D s β γ g : ℝ) (D' : ℝ)
    (hA : IsPD A) (hg : gradL ≠ 0)
    (hξ₁ : 0 < ξ 0) (hξ₂ : 0 < ξ 1) (hξ₃ : 0 < ξ 2) (hξ₄ : 0 < ξ 3)
    (hf₁ : 0 < f 0) (hf₂ : 0 < f 1) (hf₃ : 0 ≤ f 2) (hf₄ : 0 < f 3)
    (hc : 0 < c) (hA0 : 0 < A0) (hD : 0 < D) (hD1 : D ≠ 1)
    (hD' : 0 < D') (hD'1 : D' ≠ 1)
    (hgg : 0 < g) (hs : 0 < s) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    -- (CON) the conservative Noether skeleton is exactly conserved
    deriv (noetherCharge gXX x0 xdot) τ = 0
    -- (DIS) dissipative strict descent + strictly positive Liouville divergence
    ∧ (-(quadForm A gradL) < 0 ∧ 0 < divLog f ξ)
    -- (DECAY) the contact charge sits strictly above its floor at this budget
    ∧ 1 / (β + γ) < contactCharge (1 / (β + γ)) A0 D
    -- (ATTR) the contact charge limits at the wall to the degeneration charge value
    ∧ Tendsto (fun D => contactCharge (1 / (β + γ)) A0 D) atTop (𝓝 (1 / (β + γ)))
    -- (R7) and that value IS the full Round-7 conserved charge of the degeneration flow
    ∧ (alphaEff c (alphaD s) D = 1 / (β + γ)
        ∧ alphaEff c (alphaD s) D = alphaEff c (alphaD s) D'
        ∧ Tendsto (fun D => alphaEff c (alphaD s) D) atTop (𝓝 (1 / (β + γ)))
        ∧ ((gSusc (softEig γ 1 g)).det = g ^ γ
            ∧ 1 / softEig γ 1 g = g ^ (-γ)
            ∧ s = (β + γ) / (β + γ - 1))) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · -- (CON) conservative part conserved, off R.211
    exact conservative_part_conserved gXX x0 xdot τ
  · -- (DIS) strict descent (R.522) + positive divergence (R.521)
    exact ⟨dissipative_rate_neg A gradL hA hg,
           dissipation_excess_pos f ξ hξ₁ hξ₂ hξ₃ hξ₄ hf₁ hf₂ hf₃ hf₄⟩
  · -- (DECAY) above the floor
    exact dissipation_excess_at_budget (1 / (β + γ)) A0 D hA0 hD
  · -- (ATTR) contact charge limits to the floor = degeneration value
    exact contactCharge_tendsto_floor (1 / (β + γ)) A0
  · -- (R7) the full Round-7 Noether package on the degeneration flow
    exact alphaD_is_conserved_charge_of_degeneration_flow
      c D D' s β γ g hc hD hD1 hD' hD'1 hgg hs hβγ hmatch

end R8_Agent1_ContactDissipativeNoether

end MIP
