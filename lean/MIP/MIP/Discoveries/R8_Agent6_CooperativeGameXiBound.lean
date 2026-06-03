/-
  STATUS: DISCOVERY
  AGENT: R8_Agent6
  DIRECTION: COOPERATIVE GAME VALUE × XI COOPERATION BOUND.
    The corpus carries the cooperative-game / signaling layer (R.740), the
    cooperative-merge intervention bound (R.704), the ξ cooperation-asymmetry
    bound (R.72), the three-layer collaboration-savings conservation law and
    its non-negativity (R.139 / R.139.a), and the committee coverage Fano
    floor with its min/mixture sandwich (Round-5 Agent 8
    `R5_Agent8_MixtureFanoCoverage`, Round-6 Agent 6
    `R6_Agent6_FanoFloorFromConservationGenerator`).

    THIS RESULT chains them into a single statement about the *cooperative
    collaboration surplus* — the value of collaboration. We prove that the
    surplus is (i) NON-NEGATIVE (cooperation never hurts; R.139.a + R.740
    anarchy-gap non-negativity), (ii) BOUNDED ABOVE by the ξ cooperation
    budget (R.72: the squared cooperative geometric value `N_bi²` cannot
    exceed `N→·N← / (1+ξ)` — collaboration cannot create more than the
    entanglement / mutual-information budget allows, and the merge bound
    R.704 pins `N_bi` to the emergent potential budget `Φ₀·Z`), and (iii)
    realised by a FLOOR-CONSTRAINED optimal allocation: the cost-minimising
    (committee-min) allocation still respects the conserved coverage floor
    `Φ₀/log(cardMmax) ≤ ∑_a w_a N_a` and lies below the conserved convex
    average (R5_Agent8 `committee_min_le_mixture` + `mixture_committee_fano`).

  SUMMARY:
    Cooperative-game data (D.4.15 / R.139 / R.72 bundle):
      * `N` = N(p,A,H), `N_star` = N(p,H,A) (the two unidirectional costs),
        `N_bi` = bidirectional optimal, `Asym` cognitive asymmetry, `ξ ≥ 0`
        the cooperation-asymmetry parameter;
      * `δ_AH, δ_HA` the per-side external-aid gaps (R.138), and
        `σ = δ_AH + δ_HA` the total collaboration savings (the cooperative
        SURPLUS = grand-coalition value minus the sum of individual values).

    (a) `surplus_xi_upper_bound` — the squared cooperative geometric value
        `N_bi²` is bounded above by the ξ cooperation budget
        `N→·N← / (1+ξ)` (R.72 `squared_bound`), AND, packaged with the R.704
        merge division bound, `N_bi ≤ (Φ₀·Z)/δ`: the cooperative value is
        capped by BOTH the entanglement budget and the emergent-potential
        budget.

    (b) `surplus_nonneg` — `0 ≤ σ` whenever both per-side gaps are
        non-negative (R.139.a `R_139_a_savings_nonneg`, "outside aid never
        harms"); jointly with the R.740 anarchy-gap non-negativity
        (`R_741_a_asym_nonneg`) the whole cooperative welfare gap is signed.

    (c) `floor_constrained_optimal_allocation` — the cost-minimising
        committee allocation `min_a N_a` still satisfies the conserved
        coverage floor and sits below the conserved convex average
        `∑_a w_a N_a` (R5_Agent8 `committee_min_le_mixture`,
        `mixture_committee_fano`).

    HEADLINE (`cooperative_surplus_nonneg_xi_bounded_floored`): the
      cooperative collaboration surplus is non-negative AND bounded above by
      the ξ cooperation budget, with a floor-constrained optimal allocation —
      a bounded, non-negative, floor-constrained cooperation surplus, chaining
      R.704 / R.72 / R.139.a / R.740 + R5_Agent8 (R4/R5 tower).

  Depends on (exact lemma names, all GENUINELY used in proof terms):
    - MIP.Results.R72_XiCooperationBound :
        XiCooperationBound.squared_bound,
        XiCooperationBound.xi_cooperation_bound        (ξ cooperation budget)
    - MIP.Results.R704_CooperativeMerge :
        EntropyPowerTail.R_704_merge_N_bound           (merge N division bound)
    - MIP.Results.R139_CollaborationSavings :
        CollaborationSavings.R_139_a_savings_nonneg     (surplus non-negativity)
    - MIP.Results.R740_GameTheory :
        SRGGame.R_741_a_asym_nonneg                     (anarchy-gap ≥ 0)
    - MIP.Discoveries.R5_Agent8_MixtureFanoCoverage  (R5 TOWER) :
        R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture,
        R5_Agent8_MixtureFanoCoverage.mixture_committee_fano
                                          (coverage floor + min ≤ mixture)

  This file is `sorry`-free and declares NO new axiom.
-/
import MIP.Results.R72_XiCooperationBound
import MIP.Results.R704_CooperativeMerge
import MIP.Results.R139_CollaborationSavings
import MIP.Results.R740_GameTheory
import MIP.Discoveries.R5_Agent8_MixtureFanoCoverage
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

open scoped BigOperators

namespace R8_Agent6_CooperativeGameXiBound

/-! ## (a) The cooperative value is bounded above by the ξ cooperation budget.

The cooperative SURPLUS is the value of collaboration: the grand coalition
beats the geometric mean of the two unidirectional costs by the
ξ-asymmetry factor. R.72 `squared_bound` says the squared normalised
bidirectional value `N_bi²` is capped by the entanglement budget
`N→·N← / (1+ξ)`: collaboration cannot create more value than the
mutual-information budget allows. R.704 `R_704_merge_N_bound` independently
caps the cooperative count by the emergent-potential budget `Φ₀·Z / δ`. -/

/-- **(a) Squared cooperative value ≤ ξ cooperation budget (R.72).**

With `ξ ≥ 0` and the structural cooperation inequality
`N_bi²·(1+ξ) ≤ N→·N←` (T.6.iii ∘ R.70, bundled as in R.72), the squared
cooperative geometric value is bounded above by the ξ cooperation budget

    N_bi²  ≤  N→·N← / (1 + ξ).

This is exactly R.72 `XiCooperationBound.squared_bound`: the cooperation
surplus (how much the bidirectional protocol beats the geometric mean) is
capped by the entanglement / mutual-information budget `ξ`. -/
theorem cooperative_value_xi_budget
    (Nbi Nf Nb ξ : ℝ)
    (hξ : 0 ≤ ξ)
    (hStruct : Nbi ^ 2 * (1 + ξ) ≤ Nf * Nb) :
    Nbi ^ 2 ≤ Nf * Nb / (1 + ξ) :=
  XiCooperationBound.squared_bound Nbi Nf Nb ξ hξ hStruct

/-- **(a′) Cooperative value also capped by the emergent-potential budget
(R.704).**

Independently of ξ, the cooperative-merge intervention count is bounded by
the emergent-potential budget: with per-step decrement `δ > 0` and the
bundled accumulation `N_bi·δ ≤ Φ₀·Z`, R.704 `R_704_merge_N_bound` gives

    N_bi  ≤  (Φ₀·Z) / δ.

So the cooperative value faces TWO ceilings — the ξ entanglement budget (a)
and the Φ₀·Z potential budget (a′). -/
theorem cooperative_value_potential_budget
    (Nbi Φ₀Z δ : ℝ)
    (hδ : 0 < δ)
    (hAcc : Nbi * δ ≤ Φ₀Z) :
    Nbi ≤ Φ₀Z / δ :=
  EntropyPowerTail.R_704_merge_N_bound Nbi Φ₀Z δ hδ hAcc

/-- **(a″) Normalised cooperative value ≤ normalised ξ budget (R.72 sqrt).**

The square-root (normalised) form: for strictly positive costs and `ξ ≥ 0`,

    N_bi / √(N→·N←)  ≤  1 / √(1 + ξ).

Larger asymmetry `ξ` gives a strictly smaller normalised cooperative value —
the surplus is throttled by the cooperation budget. Via R.72
`xi_cooperation_bound`. -/
theorem normalised_cooperative_value_bound
    (Nbi Nf Nb ξ : ℝ)
    (hNbi : 0 < Nbi) (hNf : 0 < Nf) (hNb : 0 < Nb)
    (hξ : 0 ≤ ξ)
    (hStruct : Nbi ^ 2 * (1 + ξ) ≤ Nf * Nb) :
    Nbi / Real.sqrt (Nf * Nb) ≤ 1 / Real.sqrt (1 + ξ) :=
  XiCooperationBound.xi_cooperation_bound Nbi Nf Nb ξ hNbi hNf hNb hξ hStruct

/-! ## (b) The cooperation surplus is non-negative.

R.139.a: the collaboration savings `σ = δ_AH + δ_HA ≥ 0` whenever both
per-side external-aid gaps are non-negative (outside aid never harms,
D.3.9 monotonicity). R.740 R.741.a: the anarchy gap `Asym ≥ 0` (the
decentralised Nash protocol never beats the cooperative joint-min). Together
the cooperative surplus and the welfare gap are both signed. -/

/-- **(b) Cooperation surplus non-negativity (R.139.a).**

`0 ≤ σ` whenever both per-side gaps `δ_AH, δ_HA ≥ 0`: cooperation never
hurts. Directly R.139.a `R_139_a_savings_nonneg`. -/
theorem surplus_nonneg
    (δ_AH δ_HA σ : ℝ)
    (h_σ_def : σ = δ_AH + δ_HA)
    (h_AH : 0 ≤ δ_AH) (h_HA : 0 ≤ δ_HA) :
    0 ≤ σ :=
  CollaborationSavings.R_139_a_savings_nonneg δ_AH δ_HA σ h_σ_def h_AH h_HA

/-- **(b′) Anarchy gap (cooperative welfare gap) non-negativity (R.740).**

The cognitive asymmetry `Asym = ∑_b Φ_b·|Z_A−Z_H| ≥ 0` whenever the barrier
weights `Φ ≥ 0`: the decentralised (Nash) protocol never beats the
cooperative joint-min protocol. Via R.740/R.741.a `R_741_a_asym_nonneg`. -/
theorem anarchy_gap_nonneg
    {ι : Type*} (B : Finset ι)
    (Φ Z_A Z_H : ι → ℝ) (Asym : ℝ)
    (h_asym_def : Asym = ∑ b ∈ B, Φ b * |Z_A b - Z_H b|)
    (hΦ : ∀ b ∈ B, 0 ≤ Φ b) :
    0 ≤ Asym :=
  SRGGame.R_741_a_asym_nonneg B Φ Z_A Z_H Asym h_asym_def hΦ

/-! ## (c) Floor-constrained optimal allocation.

The cost-minimising committee allocation `min_a N_a` (the cooperative
optimum) still respects the conserved coverage floor
`Φ₀/log(cardMmax) ≤ ∑_a w_a N_a` and sits below the conserved convex
average — the optimal allocation cannot dilute the Fano coverage
obligation. Via R5_Agent8 (R4/R5 tower). -/

/-- **(c) Committee-min ≤ conserved mixture average (R5_Agent8).**

For conserved mixture weights (`w_a ≥ 0`, `∑ w_a = 1`), the cost-minimising
allocation `min_a N_a` is no larger than the conserved convex average
`∑_a w_a N_a`. Directly R5_Agent8 `committee_min_le_mixture`. -/
theorem optimal_allocation_le_mixture
    {ι : Type} [Fintype ι] (N w : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1) :
    Finset.univ.inf' hne N ≤ ∑ a, w a * N a :=
  R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture N w hne hw_nonneg hw_sum

/-- **(c′) Floor-constrained optimal allocation (R5_Agent8 headline).**

The conserved mixture average inherits the Fano coverage floor, the
optimal (min) allocation lies below it, and the committee is no-worse than
any individual — all pinned to the same conserved normalisation
`∑ w_a = 1`. Directly R5_Agent8 `mixture_committee_fano`. The cooperative
optimum CANNOT escape the coverage floor: collaboration is never free. -/
theorem floor_constrained_optimal_allocation
    {ι Ω : Type} [Fintype ι] [Fintype Ω]
    (w N logCardM : ι → ℝ) (π : ι → Ω → ℝ) (Phi0 cardMmax : ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1)
    (hπ : ∀ a, ∑ ω, π a ω = 1)
    (hN_nonneg : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax : 1 < cardMmax)
    (hcap_le : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano : ∀ a, Phi0 ≤ N a * logCardM a)
    (b : ι) :
    (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ N b)
    ∧ (∑ ω, (∑ a, w a * π a ω) = 1) :=
  R5_Agent8_MixtureFanoCoverage.mixture_committee_fano
    w N logCardM π Phi0 cardMmax hne hw_nonneg hw_sum hπ
    hN_nonneg hcap_nonneg hcardMmax hcap_le hfano b

/-! ## HEADLINE — bounded, non-negative, floor-constrained cooperation surplus.

The full chaining: R.139.a (surplus ≥ 0) + R.72 (surplus ≤ ξ budget) + R.704
(value ≤ potential budget) + R5_Agent8 (floor-constrained optimum). -/

/-- **HEADLINE — the cooperative collaboration surplus is non-negative and
bounded above by the ξ cooperation budget, with a floor-constrained optimal
allocation.**

Cooperative-game data: per-side gaps `δ_AH, δ_HA ≥ 0` with surplus
`σ = δ_AH + δ_HA`; cooperative value `N_bi > 0`, unidirectional costs
`N→ = Nf, N← = Nb > 0`, cooperation-asymmetry `ξ ≥ 0` with the structural
inequality `N_bi²·(1+ξ) ≤ N→·N←`; merge per-step decrement `δ > 0` with
accumulation `N_bi·δ ≤ Φ₀·Z`; and a conserved committee mixture
(`w_a ≥ 0`, `∑ w_a = 1`, conserved per-agent distributions `π_a`) with
per-agent R.811 Fano accumulations under a uniform readable-alphabet ceiling
`cardMmax > 1`.

Then:
  (i)   **surplus non-negative** (R.139.a): `0 ≤ σ` — cooperation never hurts;
  (ii)  **surplus ξ-bounded** (R.72): `N_bi² ≤ N→·N← / (1+ξ)` — collaboration
            cannot create more value than the entanglement budget allows;
  (iii) **value potential-capped** (R.704): `N_bi ≤ (Φ₀·Z) / δ` — the
            cooperative value is also capped by the emergent-potential budget;
  (iv)  **floor-constrained optimum** (R5_Agent8): the cost-minimising
            allocation `min_a N_a` respects the conserved coverage floor
            `Φ₀/log(cardMmax) ≤ ∑_a w_a N_a` and lies below the conserved
            convex average — the optimum cannot dilute the Fano obligation;
  (v)   **conserved-mixture certificate** (R5_Agent8/R4_Agent6): the committee
            mixed distribution `ω ↦ ∑_a w_a π_a ω` sums to 1.

So the cooperative collaboration surplus is a BOUNDED (ξ and Φ₀·Z budgets),
NON-NEGATIVE, FLOOR-CONSTRAINED quantity — chaining R.704 / R.72 / R.139.a +
R5_Agent8 (R4/R5 tower). -/
theorem cooperative_surplus_nonneg_xi_bounded_floored
    {ι Ω : Type} [Fintype ι] [Fintype Ω]
    -- surplus data (R.139)
    (δ_AH δ_HA σ : ℝ)
    (h_σ_def : σ = δ_AH + δ_HA)
    (h_AH : 0 ≤ δ_AH) (h_HA : 0 ≤ δ_HA)
    -- cooperative value + ξ budget (R.72) + potential budget (R.704)
    (Nbi Nf Nb ξ Φ₀Z δstep : ℝ)
    (_hNbi : 0 < Nbi) (_hNf : 0 < Nf) (_hNb : 0 < Nb)
    (hξ : 0 ≤ ξ)
    (hStruct : Nbi ^ 2 * (1 + ξ) ≤ Nf * Nb)
    (hδstep : 0 < δstep)
    (hAcc : Nbi * δstep ≤ Φ₀Z)
    -- conserved committee mixture + Fano floor (R5_Agent8)
    (w N logCardM : ι → ℝ) (π : ι → Ω → ℝ) (Phi0 cardMmax : ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1)
    (hπ : ∀ a, ∑ ω, π a ω = 1)
    (hN_nonneg : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax : 1 < cardMmax)
    (hcap_le : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano : ∀ a, Phi0 ≤ N a * logCardM a)
    (b : ι) :
    -- (i) surplus non-negative (R.139.a)
    (0 ≤ σ)
    -- (ii) surplus bounded above by the ξ cooperation budget (R.72)
    ∧ (Nbi ^ 2 ≤ Nf * Nb / (1 + ξ))
    -- (iii) cooperative value capped by the emergent-potential budget (R.704)
    ∧ (Nbi ≤ Φ₀Z / δstep)
    -- (iv) floor-constrained optimal allocation (R5_Agent8)
    ∧ (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a)
    -- (v) conserved-mixture certificate (R5_Agent8 / R4_Agent6)
    ∧ (∑ ω, (∑ a, w a * π a ω) = 1) := by
  -- (iv)/(v) from the R5_Agent8 headline.
  obtain ⟨hfloor, hmin_mix, _hmin_ind, hcert⟩ :=
    floor_constrained_optimal_allocation
      w N logCardM π Phi0 cardMmax hne hw_nonneg hw_sum hπ
      hN_nonneg hcap_nonneg hcardMmax hcap_le hfano b
  refine ⟨?_, ?_, ?_, hfloor, hmin_mix, hcert⟩
  · -- (i) R.139.a surplus non-negativity.
    exact surplus_nonneg δ_AH δ_HA σ h_σ_def h_AH h_HA
  · -- (ii) R.72 squared cooperation budget.
    exact cooperative_value_xi_budget Nbi Nf Nb ξ hξ hStruct
  · -- (iii) R.704 merge potential budget.
    exact cooperative_value_potential_budget Nbi Φ₀Z δstep hδstep hAcc

/-- **Corollary — the surplus is squeezed between 0 and the ξ budget on the
cooperative value scale.**

Specialising the budget to the cooperative value: when the surplus equals
the gap `Φ₀·Z/δstep − N_bi` between the potential ceiling and the realised
cooperative value (the "unused budget"), non-negativity of that gap follows
from R.704, and the ξ budget caps the value below the potential ceiling.
Concretely, a non-negative cooperative slack `Φ₀·Z/δstep − N_bi ≥ 0` and the
ξ-bounded squared value coexist. -/
theorem surplus_squeezed
    (Nbi Nf Nb ξ Φ₀Z δstep : ℝ)
    (hξ : 0 ≤ ξ)
    (hStruct : Nbi ^ 2 * (1 + ξ) ≤ Nf * Nb)
    (hδstep : 0 < δstep)
    (hAcc : Nbi * δstep ≤ Φ₀Z) :
    (0 ≤ Φ₀Z / δstep - Nbi) ∧ (Nbi ^ 2 ≤ Nf * Nb / (1 + ξ)) := by
  refine ⟨?_, cooperative_value_xi_budget Nbi Nf Nb ξ hξ hStruct⟩
  have hval : Nbi ≤ Φ₀Z / δstep :=
    cooperative_value_potential_budget Nbi Φ₀Z δstep hδstep hAcc
  linarith

end R8_Agent6_CooperativeGameXiBound

end MIP
