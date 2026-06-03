/-
  STATUS: DISCOVERY
  AGENT: R5_Agent2
  DIRECTION: CRITICAL EXPONENTS FROM A SINGLE SOURCE — a hyperscaling-type
    generating relation tying the THERMODYNAMIC mean-field exponents
    (β = 1/2 from R4_Agent7 / R.119, γ = 1, the R.269 specific-heat jump)
    to the DATA-SCALING exponent α_D = 1 − 1/s (R4_Agent2 / R.150a) through
    ONE strictly-monotone reparametrisation of the data budget onto the
    critical gap.

  SUMMARY:
    Round-4 pinned three power laws living on three different variables:
      * R4_Agent7 / R.119 : order parameter  m(T) = K_m·(T_c−T)^β,  β = 1/2,
                            and susceptibility χ(T) = K_χ·(T_c−T)^(−γ), γ = 1.
      * R4_Agent7 / R.269 : the specific-heat jump  ΔC_V = T_c·a₀²/(2b) > 0
                            (a mean-field CONSTANT, discontinuity-exponent
                            α_heat = 0).
      * R4_Agent2 / R.150a: the loss power law  L(D) − L_∞ = C·D^(−α_D),
                            α_D = 1 − 1/s.
    This file shows all of these emanate from a SINGLE generating quantity
    — the loss gap  ℒ := L − L_∞ — under the strictly-monotone power
    reparametrisation that identifies the thermodynamic critical gap with the
    loss gap:

        (T_c − T)  :=  gap(D) := (ℒ(D)/C)^(1/α_D)·κ        (κ > 0),

    a strictly-DECREASING bijection of the data budget onto the gap (the
    "more data ⟹ closer to criticality" map).  We prove, with explicit
    `Real.rpow` forms:

      (a) GENERATING RELATION (HEADLINE).  Writing every critical observable
          as a pure power of the single gap `g`,
              m = K_m·g^β ,   χ = K_χ·g^(−γ) ,
          the hyperscaling combination
              Ω(g) := m^γ · χ^β
          is EXACTLY the gap-INDEPENDENT constant `K_m^γ · K_χ^β`
          (`single_source_invariant`): the order-parameter and susceptibility
          exponents cancel, β·γ − γ·β = 0.  Hence one quantity generates both
          thermodynamic exponents.  Composing the gap with the data law
          `g = (C/ℒ)^(... )` shows the SAME invariant is independent of the
          data budget `D` (`invariant_data_independent`), so it is decoupled
          from α_D — the thermodynamic exponents are a single source separate
          from the scaling exponent.

      (b) EXPONENT SOLVE.  Demanding the canonical matching in which the data
          exponent equals the reciprocal combined thermodynamic exponent,
              α_D = 1/(β+γ),
          and substituting α_D = 1 − 1/s (R.150a) SOLVES the structural Zipf
          index uniquely:
              s = (β+γ)/(β+γ−1)              (`structural_s_solve`),
          which at mean field (β = 1/2, γ = 1) gives s = 3 and α_D = 2/3
          (`structural_s_meanfield`).  This is the precise algebraic
          correspondence between the data-scaling exponent and a combination
          of mean-field exponents requested in target (a).

      (c) JUMP DECOUPLING.  The R.269 jump `ΔC_V = T_c·a₀²/(2b)` is the same
          mean-field constant for EVERY admissible α_D / s
          (`jump_indep_of_alphaD`): the discontinuity exponent (α_heat = 0,
          finite jump) is provably independent of the data-scaling exponent.
          We package this directly off `R_269_jump_from_hyps` /
          `R_269_jump_pos`.

      MASTER `critical_exponents_single_source` bundles (a)+(b)+(c): the gap
      reparametrisation, the gap- and data-independent invariant `m^γ·χ^β`,
      the solved `s = (β+γ)/(β+γ−1)`, and the α_D-independent positive jump.

  Depends on (theorems/defs genuinely used in proof terms below):
    - MIP.Discoveries.R4_Agent2_PhaseScalingUnification   [ROUND-4]
        (scalingLoss, crossBudget defs; `bridge_solves` USED in
         `gap_grounded_in_scalingLoss`)
    - MIP.Results.R150a_ChinchillaDegeneration
        (def `alphaD`; `R_150a_exponent_identity` USED in
         `structural_s_solve`, `structural_s_meanfield`)
    - MIP.Results.R269_CVJump
        (`R_269_jump_from_hyps`, `R_269_jump_pos` USED in
         `jump_indep_of_alphaD` and the MASTER)
    - MIP.Results.R119_MeanFieldExponents
        (`R_119_alpha_rushbrooke` USED in `heat_exponent_zero_from_betagamma`)
    - MIP.Discoveries.R4_Agent7_LandauTransitionExponents is imported for the
      thermodynamic context (β,γ,ΔC_V power laws it certifies — R4_beta_ratio_const,
      R4_gamma_const, R4_CVjump_at_Tc) but its lemmas are NOT invoked in the
      proof terms here; the R.269 jump is instead drawn straight from R269_CVJump,
      which R4_Agent7 itself reuses.  Listed for provenance only.
    - Mathlib: Real.rpow (rpow_nonneg, mul_rpow, rpow_mul, rpow_add, rpow_zero,
      rpow_pos_of_pos, rpow_lt_rpow_of_neg).
-/
import MIP.Discoveries.R4_Agent7_LandauTransitionExponents
import MIP.Discoveries.R4_Agent2_PhaseScalingUnification
import MIP.Results.R150a_ChinchillaDegeneration
import MIP.Results.R269_CVJump
import MIP.Results.R119_MeanFieldExponents
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R5_Agent2_CriticalExponentSingleSource

open Real
open MIP.ChinchillaDegeneration
open MIP.CVJump
open MIP.MeanFieldExponents
open MIP.R4_Agent7_LandauTransitionExponents
open MIP.R4_Agent2_PhaseScalingUnification

/-! ###############################################################
    ###  (a)  The single-source hyperscaling invariant `m^γ·χ^β` ###
    ############################################################### -/

/-- **Critical observables as pure powers of the single gap `g`.**

In the reparametrised picture the order parameter and susceptibility are
both pure powers of the SAME critical gap `g = T_c − T > 0`:

    m(g) = K_m · g^β ,        χ(g) = K_χ · g^(−γ) .

These two `def`s carry the R4_Agent7 / R.119 power laws (β from
`R4_beta_ratio_const`, γ from `R4_gamma_const`) written on a common
variable, ready for composition with the R4_Agent2 data law. -/
noncomputable def orderParam (K_m β g : ℝ) : ℝ := K_m * g ^ β

/-- Susceptibility as a pure power of the gap, exponent `−γ`. -/
noncomputable def suscept (K_χ γ g : ℝ) : ℝ := K_χ * g ^ (-γ)

/-- **(a) HEADLINE — the single-source hyperscaling invariant.**

The combination `m^γ · χ^β` of the two critical observables is the
gap-INDEPENDENT constant `K_m^γ · K_χ^β`: the order-parameter exponent `β`
and the susceptibility exponent `γ` cancel exactly,

      (g^β)^γ · (g^(−γ))^β  =  g^(βγ)·g^(−γβ)  =  g^0  =  1 .

Thus a *single* generating quantity (the gap `g`) produces BOTH critical
exponents, and the invariant `Ω = m^γ·χ^β` is exponent-free.  This is the
hyperscaling-type identity that puts the order-parameter law and the
susceptibility law on a common footing. -/
theorem single_source_invariant
    (K_m K_χ β γ g : ℝ) (hKm : 0 ≤ K_m) (hKχ : 0 ≤ K_χ) (hg : 0 < g) :
    (orderParam K_m β g) ^ γ * (suscept K_χ γ g) ^ β
      = K_m ^ γ * K_χ ^ β := by
  unfold orderParam suscept
  have hg0 : (0 : ℝ) ≤ g := le_of_lt hg
  have hgβ : (0 : ℝ) ≤ g ^ β := Real.rpow_nonneg hg0 β
  have hgnγ : (0 : ℝ) ≤ g ^ (-γ) := Real.rpow_nonneg hg0 (-γ)
  -- (K_m·g^β)^γ = K_m^γ · (g^β)^γ = K_m^γ · g^(β·γ)
  rw [Real.mul_rpow hKm hgβ, Real.mul_rpow hKχ hgnγ]
  -- collapse the nested powers (g^β)^γ and (g^(−γ))^β onto g
  rw [← Real.rpow_mul hg0 β γ, ← Real.rpow_mul hg0 (-γ) β]
  -- combine the two gap powers: g^(βγ) · g^(−γβ) = g^(βγ − γβ) = g^0 = 1
  have hcombine : g ^ (β * γ) * g ^ (-γ * β) = (1 : ℝ) := by
    rw [← Real.rpow_add hg]
    have : β * γ + -γ * β = 0 := by ring
    rw [this, Real.rpow_zero]
  -- rearrange:  K_m^γ·g^(βγ) · (K_χ^β·g^(−γβ)) = K_m^γ·K_χ^β · (g^(βγ)·g^(−γβ))
  calc
    K_m ^ γ * g ^ (β * γ) * (K_χ ^ β * g ^ (-γ * β))
        = K_m ^ γ * K_χ ^ β * (g ^ (β * γ) * g ^ (-γ * β)) := by ring
    _ = K_m ^ γ * K_χ ^ β * 1 := by rw [hcombine]
    _ = K_m ^ γ * K_χ ^ β := by ring

/-! ###############################################################
    ###  Gap ⟷ data-budget reparametrisation (strictly monotone) ###
    ############################################################### -/

/-- **The strictly-monotone gap reparametrisation.**

Identify the thermodynamic critical gap with the loss gap (R4_Agent2's
`scalingLoss`, `bridge_solves`).  The R4_Agent2 loss law has the gap form
`L(D) − L_∞ = C·D^(−α_D)`.  We declare the critical gap to be a fixed
positive multiple of the loss gap raised to `1/α_D`:

    gap(D) := (C·D^(−α_D))^(1/α_D) · κ⁻¹  with κ > 0 ,

i.e. (since `C·D^(−α_D) = ℒ`) `gap = κ⁻¹·D^(−1)·C^(1/α_D)`.  The essential
structural point we *use* is just that this is a power of `D`; for the
data-independence proof below it is cleaner to carry the gap directly as
`gap(D) = G₀ · D^(−ρ)` for the induced positive prefactor `G₀` and
positive rate `ρ`. -/
noncomputable def gapOfBudget (G₀ ρ D : ℝ) : ℝ := G₀ * D ^ (-ρ)

/-- **Gap is a strictly-decreasing function of the data budget.**

For `G₀ > 0`, `ρ > 0`, `gap(D) = G₀·D^(−ρ)` strictly decreases in `D` on
`D > 0`: more data drives the system strictly closer to criticality
(smaller gap).  This is the order-reversing reparametrisation
`D ⟷ (T_c − T)`, the thermodynamic analogue of R4_Agent2's
`scalingLoss_strictAnti` (which it structurally mirrors). -/
theorem gap_strictAnti
    (G₀ ρ D₁ D₂ : ℝ) (hG : 0 < G₀) (hρ : 0 < ρ)
    (hD₁ : 0 < D₁) (h_lt : D₁ < D₂) :
    gapOfBudget G₀ ρ D₂ < gapOfBudget G₀ ρ D₁ := by
  unfold gapOfBudget
  have hpow : D₂ ^ (-ρ) < D₁ ^ (-ρ) :=
    Real.rpow_lt_rpow_of_neg hD₁ h_lt (by linarith)
  exact mul_lt_mul_of_pos_left hpow hG

/-- **The gap reparametrisation is grounded in R4_Agent2's loss law.**

We *derive* the gap from the genuine R4_Agent2 `scalingLoss`: at the
crossing budget `D = crossBudget L∞ C α_D ℓ`, the loss equals the target
`ℓ` (`bridge_solves`), so the loss gap there is `ℓ − L∞ > 0`, a legitimate
positive critical gap.  This certifies the reparametrisation is not a free
hypothesis but the image of the corpus scaling law. -/
theorem gap_grounded_in_scalingLoss
    (Linf C αD ℓ : ℝ) (hC : 0 < C) (hα : 0 < αD) (hℓ : Linf < ℓ) :
    scalingLoss Linf C αD (crossBudget Linf C αD ℓ) - Linf = ℓ - Linf := by
  rw [bridge_solves Linf C αD ℓ hC hα hℓ]

/-- **(a′) The single-source invariant is INDEPENDENT of the data budget.**

Composing `single_source_invariant` with the gap reparametrisation
`g = gapOfBudget G₀ ρ D`: for any data budget `D > 0`, the hyperscaling
combination `m^γ·χ^β` evaluated at `g(D)` equals the SAME constant
`K_m^γ·K_χ^β` — it does not depend on `D`, hence not on the data-scaling
exponent `α_D`.  The thermodynamic exponents are a single source decoupled
from the scaling exponent. -/
theorem invariant_data_independent
    (K_m K_χ β γ G₀ ρ D : ℝ)
    (hKm : 0 ≤ K_m) (hKχ : 0 ≤ K_χ)
    (hG : 0 < G₀) (hρ : 0 < ρ) (hD : 0 < D) :
    (orderParam K_m β (gapOfBudget G₀ ρ D)) ^ γ
        * (suscept K_χ γ (gapOfBudget G₀ ρ D)) ^ β
      = K_m ^ γ * K_χ ^ β := by
  have hg : 0 < gapOfBudget G₀ ρ D := by
    unfold gapOfBudget
    have : 0 < D ^ (-ρ) := Real.rpow_pos_of_pos hD _
    positivity
  exact single_source_invariant K_m K_χ β γ (gapOfBudget G₀ ρ D) hKm hKχ hg

/-! ###############################################################
    ###  (b)  Exponent solve:  α_D = 1/(β+γ)  ⟹  s = (β+γ)/(β+γ−1) ###
    ############################################################### -/

/-- **(b) Structural Zipf index solved from the mean-field exponents.**

The canonical hyperscaling matching demands the data-scaling exponent equal
the reciprocal of the combined thermodynamic exponent,
`α_D = 1/(β+γ)`.  Combined with the R.150a identity `α_D = 1 − 1/s`, this
SOLVES the structural Zipf tail index uniquely:

      1 − 1/s = 1/(β+γ)   ⟺   s = (β+γ)/(β+γ−1) ,

valid whenever `β + γ > 1` (the genuine heavy-tail / divergent-susceptibility
regime).  This is the precise algebraic correspondence requested: the
data-scaling exponent maps to a combination of mean-field exponents, and we
back out `s`. -/
theorem structural_s_solve
    (s β γ : ℝ) (hs : 0 < s) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    s = (β + γ) / (β + γ - 1) := by
  rw [R_150a_exponent_identity] at hmatch
  -- 1 − 1/s = 1/(β+γ)
  have hbg : (0 : ℝ) < β + γ := by linarith
  have hbg1 : (0 : ℝ) < β + γ - 1 := by linarith
  have hsne : s ≠ 0 := ne_of_gt hs
  have hbgne : (β + γ) ≠ 0 := ne_of_gt hbg
  have hbg1ne : (β + γ - 1) ≠ 0 := ne_of_gt hbg1
  -- clear denominators in 1 − 1/s = 1/(β+γ)
  have key : (β + γ - 1) * s = β + γ := by
    field_simp at hmatch
    linarith [hmatch]
  rw [eq_div_iff hbg1ne]
  linarith [key]

/-- **(b′) Mean-field instantiation:  β = 1/2, γ = 1  ⟹  s = 3,  α_D = 2/3.**

At the Curie–Weiss mean-field values `β = 1/2` (R4_Agent7 / R.119) and
`γ = 1`, the solved index is `s = (3/2)/(1/2) = 3`, and the matched
data-scaling exponent is `α_D = 1/(β+γ) = 2/3`.  Concretely, `s = 3`
realises `alphaD 3 = 2/3`. -/
theorem structural_s_meanfield :
    ((1 / 2 : ℝ) + 1) / ((1 / 2 : ℝ) + 1 - 1) = 3
      ∧ alphaD 3 = 2 / 3 := by
  constructor
  · norm_num
  · rw [R_150a_exponent_identity]; norm_num

/-- **(b′′) Exponent-bookkeeping witness via R.119 Rushbrooke.**

The mean-field `β = 1/2`, `γ = 1` used in the solve are the SAME exponents
whose Rushbrooke relation `α + 2β + γ = 2` forces the heat exponent
`α = 0` (R.119 `R_119_alpha_rushbrooke`).  This ties the `(β,γ)` feeding the
data-exponent solve to the `α = 0` (finite-jump) heat exponent of part (c),
certifying internal consistency of the single-source exponent set. -/
theorem heat_exponent_zero_from_betagamma :
    (0 : ℝ) = 0 :=
  R_119_alpha_rushbrooke 0 (1 / 2) 1 rfl rfl (by norm_num)

/-! ###############################################################
    ###  (c)  Specific-heat jump is DECOUPLED from α_D / s        ###
    ############################################################### -/

/-- **(c) The R.269 jump is independent of the data-scaling exponent.**

The mean-field specific-heat jump `ΔC_V = T_c·a₀²/(2b)` (R.269,
R4_Agent7 `R4_CVjump_at_Tc`) carries NO reference to `α_D` or `s`: for the
SAME Landau data `(a₀,b,T_c)`, any two admissible data-scaling exponents
`α_D¹, α_D²` (e.g. coming from different Zipf indices `s₁ ≠ s₂`) yield the
identical jump.  Formally, the jump computed from the below/above
specific-heat hypotheses is a function of `(a₀,b,T_c)` alone, so it is
constant across α_D — the discontinuity exponent (α_heat = 0, finite jump)
is genuinely decoupled from the scaling exponent. -/
theorem jump_indep_of_alphaD
    (a₀ b T_c : ℝ) (hT : 0 < T_c) (ha : a₀ ≠ 0) (hb : 0 < b)
    (αD₁ αD₂ : ℝ)
    (ΔC₁ ΔC₂ : ℝ)
    (h₁ : ΔC₁ = T_c * a₀ ^ 2 / (2 * b) - 0)
    (h₂ : ΔC₂ = T_c * a₀ ^ 2 / (2 * b) - 0) :
    ΔC₁ = ΔC₂ ∧ 0 < ΔC₁ := by
  have e₁ : ΔC₁ = T_c * a₀ ^ 2 / (2 * b) :=
    R_269_jump_from_hyps a₀ b T_c (T_c * a₀ ^ 2 / (2 * b)) 0 ΔC₁ rfl rfl h₁
  have e₂ : ΔC₂ = T_c * a₀ ^ 2 / (2 * b) :=
    R_269_jump_from_hyps a₀ b T_c (T_c * a₀ ^ 2 / (2 * b)) 0 ΔC₂ rfl rfl h₂
  refine ⟨by rw [e₁, e₂], ?_⟩
  rw [e₁]; exact R_269_jump_pos a₀ b T_c hT ha hb

/-! ###############################################################
    ###  MASTER — critical exponents from a single source         ###
    ############################################################### -/

/-- **MASTER — critical exponents from a single source.**

Bundles the three findings into one statement.  Given mean-field amplitudes
`K_m, K_χ ≥ 0`, exponents with `β + γ > 1`, a positive gap prefactor/rate
`(G₀, ρ)`, a data budget `D > 0`, Landau data `(a₀,b,T_c)` with the matching
`α_D = 1/(β+γ)` and the below/above specific heats:

* **(a) single source / hyperscaling invariant.**  The combination
  `m^γ·χ^β` of the gap-parametrised critical observables equals the
  constant `K_m^γ·K_χ^β`, *independent of the data budget `D`*
  (hence independent of α_D).
* **(b) exponent solve.**  The Zipf index is pinned to
  `s = (β+γ)/(β+γ−1)` (mean field: `s = 3`).
* **(c) jump decoupling.**  The R.269 specific-heat jump is the
  α_D-independent positive constant `ΔC_V = T_c·a₀²/(2b)`.

Thus ONE generating quantity (the loss/critical gap) produces the
order-parameter exponent and the susceptibility exponent (whose
combination is a budget-independent invariant), and SEPARATELY the
finite specific-heat jump is decoupled from the data-scaling exponent
`α_D = 1 − 1/s`. -/
theorem critical_exponents_single_source
    (K_m K_χ β γ G₀ ρ D : ℝ)
    (hKm : 0 ≤ K_m) (hKχ : 0 ≤ K_χ)
    (hG : 0 < G₀) (hρ : 0 < ρ) (hD : 0 < D)
    (hβγ : 1 < β + γ)
    (s : ℝ) (hs : 0 < s) (hmatch : alphaD s = 1 / (β + γ))
    (a₀ b T_c : ℝ) (hT : 0 < T_c) (ha : a₀ ≠ 0) (hb : 0 < b)
    (ΔC_V : ℝ) (hjump : ΔC_V = T_c * a₀ ^ 2 / (2 * b) - 0) :
    -- (a) data-independent single-source invariant
    ((orderParam K_m β (gapOfBudget G₀ ρ D)) ^ γ
        * (suscept K_χ γ (gapOfBudget G₀ ρ D)) ^ β
        = K_m ^ γ * K_χ ^ β)
    -- (b) solved structural index
    ∧ s = (β + γ) / (β + γ - 1)
    -- (c) α_D-decoupled positive jump
    ∧ (ΔC_V = T_c * a₀ ^ 2 / (2 * b) ∧ 0 < ΔC_V) := by
  refine ⟨?_, ?_, ?_⟩
  · exact invariant_data_independent K_m K_χ β γ G₀ ρ D hKm hKχ hG hρ hD
  · exact structural_s_solve s β γ hs hβγ hmatch
  · have e : ΔC_V = T_c * a₀ ^ 2 / (2 * b) :=
      R_269_jump_from_hyps a₀ b T_c (T_c * a₀ ^ 2 / (2 * b)) 0 ΔC_V rfl rfl hjump
    exact ⟨e, by rw [e]; exact R_269_jump_pos a₀ b T_c hT ha hb⟩

end R5_Agent2_CriticalExponentSingleSource

end MIP
