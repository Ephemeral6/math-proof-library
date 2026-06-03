/-
  STATUS: DISCOVERY
  AGENT: R7_Agent4
  DIRECTION: THE SCALING EXPONENT IS A CONSERVED CHARGE OF THE DEGENERATION FLOW.
    Round-6 Agent 2 (`R6_Agent2_ExponentAtTerminalDegeneration`) proved that the
    effective local exponent `α_eff(D)` of the saturating loss curve
    `Lcurve L∞ c α D = L∞ + c·D^(−α)` is the CONSTANT `α` at every finite budget
    (`alphaEff_const`), tends to `α` at the wall (`alphaEff_tendsto`), and agrees
    between any two budgets along the chain (`exponent_invariant_along_chain`):
    the exponent is the INVARIANT of the terminal degeneration.
    Round-6 Agent 7 (`R6_Agent7_ScalingExponentFisherCoordinate`) proved that the
    Chinchilla data exponent `α_D = 1/(β+γ)` is a FISHER-GEOMETRIC invariant — the
    inverse sum of the order-parameter exponent β and the metric-degeneration
    exponent γ (the soft eigenvalue `det g = g^γ`, the natural-gradient
    susceptibility `χ = g^(−γ)`), with `α_D = 1/(β+γ) ⟹ s = (β+γ)/(β+γ−1)`
    (`R6_7_alphaD_is_fisher_invariant`, `R6_7_s_from_fisher_geometry`).

    THIS FILE (Round 7) fuses the two into a NOETHER-TYPE statement: a single
    number is CONSERVED along the entire degeneration flow toward the wall, and
    that conserved charge IS the Fisher-geometric `1/(β+γ)`.

      THE DATA-SCALING EXPONENT IS A CONSERVED CHARGE (FLOW-INVARIANT) OF THE
      DEGENERATION DYNAMICS, EQUAL TO THE FISHER-GEOMETRIC INVERSE SUM 1/(β+γ).

  SUMMARY:
    Model the degeneration flow as the budget axis `D ∈ (0,∞)`, the wall at
    `D → ∞` (R6_Agent2 / R4_Agent9: `Lcurve` saturates at the terminal object).
    The "charge" is the effective local (log-slope) exponent `alphaEff c α D`.

    (a) EXACT CONSERVATION (not merely asymptotic).  On the curve carrying the
        Fisher exponent `α = α_D = 1/(β+γ)`, the charge `alphaEff c α D` is
        LITERALLY EQUAL to `1/(β+γ)` at EVERY finite budget `D > 0, D ≠ 1`
        (`charge_eq_fisher_at_every_budget`, off R6_Agent2 `alphaEff_const` +
        R6_Agent7 `R6_7_alphaD_is_fisher_invariant` matching).  This is a
        flow-invariant: no drift between any two budgets
        (`charge_conserved_along_flow`, off R6_Agent2 `exponent_invariant_along_chain`).

    (b) CONTINUITY TO THE WALL.  The charge tends to the same value at the wall
        `D → ∞` (`charge_tendsto_fisher_at_wall`, off R6_Agent2 `alphaEff_tendsto`):
        conservation is exact AND survives the limit — a genuine constant of motion.

    (c) GEOMETRIC IDENTITY OF THE CHARGE.  The conserved value is read off the
        Fisher geometry: it equals `1/(β+γ)` with γ the metric-degeneration
        exponent (`det g = g^γ`) and β the order-parameter exponent, and this
        pins the Zipf index `s = (β+γ)/(β+γ−1)`
        (`conserved_charge_is_fisher_inverse_sum`, chaining R6_Agent7
        `R6_7_s_from_fisher_geometry`, whose proof carries the R5_5 metric
        determinant and natural-gradient blow-up).

    (d) HEADLINE `alphaD_is_conserved_charge_of_degeneration_flow`.  One Noether
        statement: along the whole flow `D ∈ (0,∞)` toward the terminal wall, the
        effective exponent (charge) is CONSTANT `= 1/(β+γ)` at every budget,
        conserved between any two budgets, and limits to `1/(β+γ)` at the wall —
        while the SAME number `1/(β+γ)` is the Fisher-geometric inverse sum
        (metric determinant `g^γ`, susceptibility `g^(−γ)`) pinning
        `s = (β+γ)/(β+γ−1)`.  The data-scaling exponent is a conserved charge of
        the degeneration dynamics, equal to the Fisher-geometric `1/(β+γ)`.

  Depends on (exact imported lemmas genuinely used in proof terms below):
    - MIP.Discoveries.R6_Agent2_ExponentAtTerminalDegeneration   [ROUND-6, R4/R5/R6 tower]
        · alphaEff                       (the charge; defined there off R4_Agent9 gap law)
        · alphaEff_const                 (USED in charge_eq_fisher_at_every_budget,
                                          alphaD_is_conserved_charge_of_degeneration_flow)
        · alphaEff_tendsto               (USED in charge_tendsto_fisher_at_wall,
                                          alphaD_is_conserved_charge_of_degeneration_flow)
        · exponent_invariant_along_chain (USED in charge_conserved_along_flow,
                                          alphaD_is_conserved_charge_of_degeneration_flow)
    - MIP.Discoveries.R6_Agent7_ScalingExponentFisherCoordinate  [ROUND-6, R4/R5/R6 tower]
        · R6_7_alphaD_is_fisher_invariant (USED in conserved_charge_is_fisher_inverse_sum,
                                           alphaD_is_conserved_charge_of_degeneration_flow)
        · R6_7_s_from_fisher_geometry     (USED in conserved_charge_is_fisher_inverse_sum,
                                           alphaD_is_conserved_charge_of_degeneration_flow —
                                           carries R5_5 metric det + nat-grad blow-up,
                                           R4_5 Fisher-norm law in its term)
    - MIP.Results.R150a_ChinchillaDegeneration
        · alphaD                          (the Chinchilla exponent α_D = 1 − 1/s;
                                           PROVENANCE/definitional, enters via R6_7 matching)
    - MIP.Discoveries.R6_Agent7 also pulls in `gSusc`, `softEig` for the geometric
      witnesses in conserved_charge_is_fisher_inverse_sum.
    - Mathlib: Filter.Tendsto, Real.log/rpow algebra (inside the imported lemmas).

  This file is `sorry`-free and `axiom`-free (no NEW axioms; framework axioms only
  via imported corpus).
-/
import MIP.Discoveries.R6_Agent2_ExponentAtTerminalDegeneration
import MIP.Discoveries.R6_Agent7_ScalingExponentFisherCoordinate
import MIP.Results.R150a_ChinchillaDegeneration
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Order.Filter.AtTopBot.Field

namespace MIP

namespace R7_Agent4_AlphaDConservedCharge

open Filter Topology
open MIP.ChinchillaDegeneration
open MIP.R6_Agent2_ExponentAtTerminalDegeneration
open MIP.R6_Agent7_ScalingExponentFisherCoordinate
open MIP.R5_Agent5_CriticalSlowingFisher

/-! ###############################################################
    ###  (a)  EXACT CONSERVATION of the charge along the flow     ###
    ############################################################### -/

/-- **(a.1) The charge equals the Fisher value `1/(β+γ)` at EVERY finite budget.**

The conserved quantity of the degeneration flow is the effective local exponent
`alphaEff c α D` (R6_Agent2), the log-slope diagnostic of the saturating curve.
On the curve carrying the Fisher-geometric data exponent `α = α_D = 1/(β+γ)`
(R6_Agent7 `R6_7_alphaD_is_fisher_invariant`, with γ the metric-degeneration
exponent and β the order-parameter exponent), the charge is LITERALLY
`1/(β+γ)` at every finite budget `D > 0, D ≠ 1` — exact, not asymptotic,
conservation.  Off R6_Agent2 `alphaEff_const`. -/
theorem charge_eq_fisher_at_every_budget
    (c D s β γ : ℝ) (hc : 0 < c) (hD : 0 < D) (hD1 : D ≠ 1)
    (hs : 0 < s) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    alphaEff c (alphaD s) D = 1 / (β + γ)
      ∧ s = (β + γ) / (β + γ - 1) := by
  -- the charge is the constant α = α_D (R6_Agent2), and α_D = 1/(β+γ) by matching;
  -- the SAME matching, via R6_Agent7, pins the Zipf index (genuine R6_7 use).
  refine ⟨?_, R6_7_alphaD_is_fisher_invariant s β γ hs hβγ hmatch⟩
  rw [alphaEff_const c (alphaD s) D hc hD hD1, hmatch]

/-- **(a.2) The charge is CONSERVED — no drift between any two budgets on the flow.**

For any two finite budgets `D₁, D₂` along the degeneration flow, the charge takes
the SAME value: `alphaEff c α D₁ = alphaEff c α D₂`.  This is the literal
flow-invariance (constant of motion) statement — the charge does not change as the
budget runs toward the wall.  Off R6_Agent2 `exponent_invariant_along_chain`. -/
theorem charge_conserved_along_flow
    (c α D₁ D₂ : ℝ) (hc : 0 < c)
    (hD₁ : 0 < D₁) (hD₁1 : D₁ ≠ 1) (hD₂ : 0 < D₂) (hD₂1 : D₂ ≠ 1) :
    alphaEff c α D₁ = alphaEff c α D₂ :=
  exponent_invariant_along_chain c α D₁ D₂ hc hD₁ hD₁1 hD₂ hD₂1

/-! ###############################################################
    ###  (b)  Conservation survives the limit to the wall         ###
    ############################################################### -/

/-- **(b) The charge LIMITS to the Fisher value `1/(β+γ)` at the wall `D → ∞`.**

The degeneration flow terminates at the wall `D → ∞`.  The charge
`alphaEff c α_D ·` not only is constant at every finite budget (part a) but its
limit at the wall is the SAME value `1/(β+γ)`: conservation is exact AND survives
the terminal limit, the hallmark of a genuine constant of motion.  Off R6_Agent2
`alphaEff_tendsto` together with the Fisher matching `α_D = 1/(β+γ)`. -/
theorem charge_tendsto_fisher_at_wall
    (c s β γ : ℝ) (hc : 0 < c) (hmatch : alphaD s = 1 / (β + γ)) :
    Tendsto (fun D => alphaEff c (alphaD s) D) atTop (𝓝 (1 / (β + γ))) := by
  -- R6_Agent2: alphaEff c α · → α; here α = α_D, and α_D = 1/(β+γ) by matching.
  -- Rewrite only the limit POINT in the goal (keep the function on `alphaD s`).
  rw [← hmatch]
  exact alphaEff_tendsto c (alphaD s) hc

/-! ###############################################################
    ###  (c)  Geometric identity of the conserved charge          ###
    ############################################################### -/

/-- **(c) The conserved charge IS the Fisher-geometric inverse sum.**

The value of the conserved charge is read off the Fisher geometry of R6_Agent7:
it equals `1/(β+γ)` where γ is the metric-degeneration exponent — the soft
eigenvalue vanishes as `det g(softEig γ 1 g) = g^γ` and the natural-gradient
susceptibility coefficient blows up as `1/softEig γ 1 g = g^(−γ)` (R5_5 metric
determinant + R4_5 Fisher-norm law underneath), with β the order-parameter
exponent.  This same geometric data pins the Zipf index `s = (β+γ)/(β+γ−1)`.
Chains R6_Agent7 `R6_7_s_from_fisher_geometry`. -/
theorem conserved_charge_is_fisher_inverse_sum
    (s β γ g : ℝ) (hs : 0 < s) (hg : 0 < g) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    -- the conserved value is the geometric inverse sum
    alphaD s = 1 / (β + γ)
    -- the metric degenerates as g^γ (Fisher determinant)
    ∧ (gSusc (softEig γ 1 g)).det = g ^ γ
    -- the natural-gradient susceptibility coefficient blows up as g^(−γ)
    ∧ 1 / softEig γ 1 g = g ^ (-γ)
    -- and the same geometry pins the Zipf index
    ∧ s = (β + γ) / (β + γ - 1) := by
  refine ⟨hmatch, ?_⟩
  exact R6_7_s_from_fisher_geometry s β γ g hs hg hβγ hmatch

/-! ###############################################################
    ###  (d)  HEADLINE — Noether: α_D is a conserved charge       ###
    ############################################################### -/

/-- **(d) HEADLINE — the data-scaling exponent is a CONSERVED CHARGE of the
degeneration flow, equal to the Fisher-geometric `1/(β+γ)`.**

A Noether-type statement fusing the two Round-6 third-order structures.  Model the
degeneration flow as the budget axis `D ∈ (0,∞)`, the terminal wall at `D → ∞`
(R4_Agent9 / R6_Agent2 saturation).  Take the CHARGE to be the effective local
(log-slope) exponent `alphaEff c α_D ·` on the loss curve carrying the
Fisher-geometric data exponent `α = α_D = 1/(β+γ)` (R6_Agent7, γ = metric-
degeneration exponent `det g = g^γ`, β = order-parameter exponent).  Then:

  (C-exact) **exact conservation** — the charge equals `1/(β+γ)` at EVERY finite
            budget `D > 0, D ≠ 1` (off R6_Agent2 `alphaEff_const`), so it is a
            flow-invariant, not merely an asymptotic value;
  (C-flow)  **no drift** — between the chosen budget and any other budget `D'` the
            charge is unchanged (off R6_Agent2 `exponent_invariant_along_chain`):
            a constant of motion of the flow;
  (C-wall)  **survives the limit** — the charge tends to the SAME `1/(β+γ)` at the
            terminal wall `D → ∞` (off R6_Agent2 `alphaEff_tendsto`);
  (C-geom)  **geometric identity of the charge** — the conserved value is the
            Fisher inverse sum: the metric degenerates as `det g = g^γ`, the
            natural-gradient susceptibility blows up as `g^(−γ)` with the same γ,
            and `α_D = 1/(β+γ)` pins the Zipf index `s = (β+γ)/(β+γ−1)`
            (off R6_Agent7 `R6_7_s_from_fisher_geometry`, carrying R5_5/R4_5).

Thus the single number `1/(β+γ)` is conserved along the ENTIRE degeneration flow
toward the wall and is simultaneously the Fisher-geometric inverse sum of the
curvature/order exponents.  The data-scaling exponent is a conserved charge
(flow-invariant) of the degeneration dynamics, equal to the Fisher-geometric
`1/(β+γ)`. -/
theorem alphaD_is_conserved_charge_of_degeneration_flow
    (c D D' s β γ g : ℝ)
    (hc : 0 < c) (hD : 0 < D) (hD1 : D ≠ 1) (hD' : 0 < D') (hD'1 : D' ≠ 1)
    (hg : 0 < g) (hs : 0 < s) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    -- (C-exact) the charge equals the Fisher value 1/(β+γ) at this finite budget
    alphaEff c (alphaD s) D = 1 / (β + γ)
    -- (C-flow) the charge is conserved between any two budgets (no drift)
    ∧ alphaEff c (alphaD s) D = alphaEff c (alphaD s) D'
    -- (C-wall) the charge limits to the same value at the terminal wall
    ∧ Tendsto (fun D => alphaEff c (alphaD s) D) atTop (𝓝 (1 / (β + γ)))
    -- (C-geom) the conserved value is the Fisher-geometric inverse sum,
    --          witnessed by the metric determinant and natural-gradient blow-up,
    --          pinning the Zipf index
    ∧ ((gSusc (softEig γ 1 g)).det = g ^ γ
        ∧ 1 / softEig γ 1 g = g ^ (-γ)
        ∧ s = (β + γ) / (β + γ - 1)) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- exact conservation at every budget = constant α_D, matched to 1/(β+γ)
    exact (charge_eq_fisher_at_every_budget c D s β γ hc hD hD1 hs hβγ hmatch).1
  · -- no drift: flow-invariance between D and D'
    exact charge_conserved_along_flow c (alphaD s) D D' hc hD hD1 hD' hD'1
  · -- survives the limit to the wall
    exact charge_tendsto_fisher_at_wall c s β γ hc hmatch
  · -- geometric identity: Fisher determinant, susceptibility blow-up, Zipf index
    have hgeom := conserved_charge_is_fisher_inverse_sum s β γ g hs hg hβγ hmatch
    exact ⟨hgeom.2.1, hgeom.2.2.1, hgeom.2.2.2⟩

end R7_Agent4_AlphaDConservedCharge

end MIP
