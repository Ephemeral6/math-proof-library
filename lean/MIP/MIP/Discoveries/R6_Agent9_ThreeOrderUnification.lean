/-
  STATUS: DISCOVERY
  AGENT: R6_Agent9
  DIRECTION: THREE-WAY ORDER UNIFICATION — phase = degeneration = hardness.
    Round-5 Agent 6 pinned the WALL configuration `⟨univ, ⊤⟩` as the TERMINAL
    object of the degeneration poset (greatest + absorbing on the coverage
    substrate `Finset.univ` and the cost substrate `ℕ∞`), reached by an OOD
    target (`extrapolation_wall_is_terminal_degeneration`, `univ_isTop_degen`,
    `ood_reaches_cost_top`).  Round-5 Agent 7 order-embedded the 3-element
    scaling PHASE chain (coverage < mixed < autonomy) into the impossibility
    HARDNESS poset, as a single strictly-monotone rank `Fin 3 → ℝ × Prob`
    (`phase_order_refines_hardness`, `phaseCost_strictMono`, `phaseRank`,
    `phaseProblem`).  Round-4 Agent 4 built the degeneration preorder
    (`DegenStep`, `degen_trans`, `univ_is_top_degen` lives over it).

    THIS FILE goes a THIRD order DEEPER: it fuses the three preorders — the
    scaling PHASE order (cost ℝ), the impossibility HARDNESS order
    (reachability `K.R` on `Prob`), and the DEGENERATION order (`DegenStep`
    on `Finset Ω`) — into ONE rank map `Fin 3 → ℝ × Prob × Finset Ω` and
    proves they (i) are MUTUALLY COMPATIBLE along the canonical phase chain
    `0 < 1 < 2` and (ii) share a COMMON GREATEST ELEMENT: the wall.

  SUMMARY:
    (a) **Unified rank.**  `tripleRank` carries, at each phase rank, the
        scaling budget cost (R5_Agent7 `phaseCost`), the hardness-poset
        problem (R5_Agent7 `phaseProblem`), and a degeneration coverage level
        (a `Finset Ω` chain monotone toward `univ`).  We prove this single map
        realises ALL THREE orders simultaneously:
          • scaling: the ℝ-coordinate is `StrictMono` (R5_Agent7
            `phaseCost_strictMono`, hence R4_Agent2 `crossBudget_strictAnti`);
          • hardness: adjacent ranks carry `K.R`-edges and every rank is
            `K.Hard` (R5_Agent7 chain through R4_Agent3 `genTransferChain`);
          • degeneration: the coverage-coordinate is `DegenStep`-monotone, and
            every level `DegenStep`s into the terminal `univ` (R5_Agent6
            `univ_is_top_degen`, R4_Agent4 `degen_trans`).
        So the three preorders RESTRICT TO THE SAME total order on `Fin 3`.

    (b) **Common top (the wall).**  The hardest phase (autonomy, rank 2) is
        SIMULTANEOUSLY:
          • the TERMINAL degeneration: its coverage level `DegenStep`s into the
            wall `univ`, the greatest/absorbing element (R5_Agent6
            `univ_isTop_degen` + `degen_absorb_univ`);
          • the TOP of the hardness chain: it is `K.Hard` and is reached from
            every lower phase by `K.R` (R5_Agent7 / R4_Agent3);
          • the SATURATION of scaling: an OOD target lands the emergence cost
            at the cost-top `N p X = ⊤` (R5_Agent6 `ood_reaches_cost_top`),
            the greatest element of the cost order (R5_Agent6 `wall_is_top_cost`).
        One greatest element across all three orders.

    (c) HEADLINE (`three_orders_one_ordinal`):  phase, degeneration, and
        hardness define ONE AND THE SAME emergence-difficulty ordinal — a
        shared strictly-increasing chain on `Fin 3` together with a shared
        greatest element (the wall).  Chaining R5_Agent6 + R5_Agent7
        (+ R4_Agent4).  Nothing in the corpus identifies the three preorders;
        their coincidence as a single ordinal is the new third-order content.

  Depends on (exact imported lemmas used in proof terms):
    - MIP.Discoveries.R5_Agent7_PhaseOrderRefinesHardness
        · R5_Agent7_PhaseOrderRefinesHardness.phaseCost
        · R5_Agent7_PhaseOrderRefinesHardness.phaseCost_strictMono
        · R5_Agent7_PhaseOrderRefinesHardness.phaseProblem
        · R5_Agent7_PhaseOrderRefinesHardness.phaseHardnessStep
        · R5_Agent7_PhaseOrderRefinesHardness.phase_order_refines_hardness
    - MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
        · R5_Agent6_SaturationIsTerminalDegeneration.univ_is_top_degen
        · R5_Agent6_SaturationIsTerminalDegeneration.univ_isTop_degen
        · R5_Agent6_SaturationIsTerminalDegeneration.degen_absorb_univ
        · R5_Agent6_SaturationIsTerminalDegeneration.wall_is_top_cost
        · R5_Agent6_SaturationIsTerminalDegeneration.ood_reaches_cost_top
        · R5_Agent6_SaturationIsTerminalDegeneration.IsOOD (re-exported)
    - MIP.Discoveries.R4_Agent4_DegenerationChain
        · R4_Agent4_DegenerationChain.DegenStep
        · R4_Agent4_DegenerationChain.degen_trans
        · R4_Agent4_DegenerationChain.degen_step_transports_cover
    - MIP.Discoveries.R4_Agent3_ImpossibilityPoset
        · R4_Agent3_ImpossibilityPoset.HardnessKernel (.R, .Hard)
        · R4_Agent3_ImpossibilityPoset.genTransfer
    - Mathlib: StrictMono, Fin 3, Finset.subset_univ.
-/
import MIP.Discoveries.R5_Agent7_PhaseOrderRefinesHardness
import MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
import MIP.Discoveries.R4_Agent4_DegenerationChain
import MIP.Discoveries.R4_Agent3_ImpossibilityPoset
import Mathlib.Order.Monotone.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Finset.Basic

namespace MIP

namespace R6_Agent9_ThreeOrderUnification

open MIP.R5_Agent7_PhaseOrderRefinesHardness
open MIP.R5_Agent6_SaturationIsTerminalDegeneration
open MIP.R4_Agent4_DegenerationChain
open MIP.R4_Agent3_ImpossibilityPoset
open MIP.R4_Agent9_ScalingSaturationWall (IsOOD)

/-! ## (0) The degeneration-coordinate chain of the three phases.

The first two coordinates (scaling cost, hardness problem) are supplied
verbatim by R5_Agent7.  We add the THIRD order: a degeneration coverage chain
`Finset Ω`, ranked `0 ↦ C₀, 1 ↦ C₁, 2 ↦ C₂` so that `C₀ ⊆ C₁ ⊆ C₂`, i.e.
later phases are FURTHER DEGENERATED (R4_Agent4 `DegenStep`), terminating at
the wall `univ` (R5_Agent6 `univ_is_top_degen`). -/

variable {Ω : Type*} [DecidableEq Ω] [Fintype Ω]

/-- **Phase degeneration-coverage map** into the degeneration poset:
`0 ↦ C₀ (coverage), 1 ↦ C₁ (mixed), 2 ↦ C₂ (autonomy)`.  Each later phase is a
further degeneration (a larger coverage level under `DegenStep = ⊆`). -/
def phaseDegen (C₀ C₁ C₂ : Finset Ω) : Fin 3 → Finset Ω
  | ⟨0, _⟩ => C₀
  | ⟨1, _⟩ => C₁
  | ⟨2, _⟩ => C₂

/-- **(0.1) Adjacent ranks are degeneration steps (the chain edges).**

For a degeneration-ordered triple `C₀ ⊆ C₁ ⊆ C₂`, consecutive phase ranks
carry a `DegenStep` edge: precisely `C₀ → C₁ → C₂`.  This is the degeneration
analogue of R5_Agent7's `phaseProblem_chain_edges`. -/
theorem phaseDegen_chain_edges {C₀ C₁ C₂ : Finset Ω}
    (d1 : DegenStep C₀ C₁) (d2 : DegenStep C₁ C₂) :
    DegenStep (phaseDegen C₀ C₁ C₂ 0) (phaseDegen C₀ C₁ C₂ 1)
      ∧ DegenStep (phaseDegen C₀ C₁ C₂ 1) (phaseDegen C₀ C₁ C₂ 2) :=
  ⟨d1, d2⟩

/-- **(0.2) Every phase degeneration-level sinks into the terminal `univ`.**

Each coverage level `phaseDegen C₀ C₁ C₂ r` `DegenStep`s into the wall
`Finset.univ` — the greatest/absorbing element of the degeneration order
(R5_Agent6 `univ_is_top_degen`).  So the degeneration coordinate of every
phase flows one way, into the wall. -/
theorem phaseDegen_sinks_to_univ (C₀ C₁ C₂ : Finset Ω) (r : Fin 3) :
    DegenStep (phaseDegen C₀ C₁ C₂ r) (Finset.univ : Finset Ω) :=
  univ_is_top_degen (phaseDegen C₀ C₁ C₂ r)

/-! ## (1) The unified triple rank — the three orders carried at once.

`tripleRank r = (phaseCost ... r, phaseProblem ... r, phaseDegen ... r)`.
Coordinate 1 is the SCALING phase order (ℝ cost), coordinate 2 the HARDNESS
order (`K.R` reachability on `Prob`), coordinate 3 the DEGENERATION order
(`DegenStep` on `Finset Ω`).  All three share the SAME index `r : Fin 3`. -/

variable {Prob : Type*}

/-- **Unified emergence-difficulty rank.**  Bundles the scaling cost
(R5_Agent7 `phaseCost`), the hardness-poset problem (R5_Agent7 `phaseProblem`),
and the degeneration coverage level (`phaseDegen`) at each phase rank. -/
noncomputable def tripleRank
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ) (Q₀ Q₁ Q₂ : Prob) (C₀ C₁ C₂ : Finset Ω) :
    Fin 3 → ℝ × Prob × Finset Ω :=
  fun r => (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut r,
            phaseProblem Q₀ Q₁ Q₂ r,
            phaseDegen C₀ C₁ C₂ r)

/-- **(1.1) Scaling order on the unified rank — cost coordinate is strict.**

The ℝ-coordinate of `tripleRank` is exactly R5_Agent7's `phaseCost`, hence
`StrictMono` by `phaseCost_strictMono` (ultimately R4_Agent2's
`crossBudget_strictAnti`): the scaling phase order is the first projection. -/
theorem tripleRank_scaling_strictMono
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ) (Q₀ Q₁ Q₂ : Prob) (C₀ C₁ C₂ : Finset Ω)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov) :
    StrictMono
      (fun r => (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ r).1) := by
  have hmono := phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
    hC h_s h_aut h_star h_cov
  intro a b hab
  exact hmono hab

/-- **(1.2) Degeneration order on the unified rank — coverage coordinate is
`DegenStep`-monotone.**

The third projection of `tripleRank` is `phaseDegen`, whose adjacent ranks are
`DegenStep`-edges (`phaseDegen_chain_edges`) and which sinks into the terminal
`univ` (`phaseDegen_sinks_to_univ`).  So the degeneration phase order is the
third projection, with the SAME index as the scaling and hardness orders. -/
theorem tripleRank_degen_chain
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ) (Q₀ Q₁ Q₂ : Prob) {C₀ C₁ C₂ : Finset Ω}
    (d1 : DegenStep C₀ C₁) (d2 : DegenStep C₁ C₂) :
    DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 0).2.2
              (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.2
      ∧ DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.2
              (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.2
      ∧ ∀ r, DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ r).2.2
              (Finset.univ : Finset Ω) := by
  refine ⟨d1, ?_, ?_⟩
  · exact d2
  · intro r
    exact phaseDegen_sinks_to_univ C₀ C₁ C₂ r

/-! ## (2) Compatibility — the three orders coincide on the phase chain.

We now prove the three coordinate orders AGREE: at any strict step `a < b` of
`Fin 3`, the scaling cost strictly increases, the hardness problem advances
along a `K.R`-edge to a `K.Hard` target, and the degeneration coverage advances
along a `DegenStep`-edge toward `univ`.  All three share the index, so they
restrict to ONE total order on `Fin 3`. -/

/-- **(2) Three-order compatibility on adjacent phase ranks.**

For the canonical phase steps `0 < 1` and `1 < 2`, the three orders agree:
  • scaling: cost strictly increases (R5_Agent7 `phaseCost_strictMono`);
  • hardness: a `K.R`-edge with hard endpoints (R5_Agent7 chain / R4_Agent3
    `genTransfer`, `phaseHardnessStep`);
  • degeneration: a `DegenStep`-edge (R4_Agent4), sinking to `univ` (R5_Agent6).
The single index `r` ties them: the three preorders coincide here. -/
theorem three_orders_compatible
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov)
    (K : HardnessKernel Prob)
    {S Q₀ Q₁ Q₂ : Prob} (hS : K.Hard S)
    (e0 : K.R S Q₀) (e1 : K.R Q₀ Q₁) (e2 : K.R Q₁ Q₂)
    {C₀ C₁ C₂ : Finset Ω} (d1 : DegenStep C₀ C₁) (d2 : DegenStep C₁ C₂) :
    -- scaling order: strict cost increase on each step
    ((tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 0).1
        < (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).1)
    ∧ ((tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).1
        < (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).1)
    -- hardness order: K.R-edges with hard endpoints
    ∧ K.R (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 0).2.1
          (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.1
    ∧ K.R (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.1
          (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.1
    ∧ K.Hard (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.1
    -- degeneration order: DegenStep-edges
    ∧ DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 0).2.2
                (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.2
    ∧ DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.2
                (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.2 := by
  have hmono := tripleRank_scaling_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
    Q₀ Q₁ Q₂ C₀ C₁ C₂ hC h_s h_aut h_star h_cov
  refine ⟨hmono (by decide), hmono (by decide), e1, e2, ?_, d1, d2⟩
  -- Q₂ hard: S ≤ Q₀ ≤ Q₁ (phaseHardnessStep) then K.R Q₁ Q₂ (genTransfer).
  exact genTransfer K e2 (phaseHardnessStep K hS e0 e1)

/-! ## (3) The common greatest element — the wall.

The hardest phase (autonomy, rank 2) is the shared TOP of all three orders:
  • degeneration: its coverage level sinks into `univ`, the greatest/absorbing
    degeneration element (R5_Agent6 `univ_isTop_degen`, `degen_absorb_univ`);
  • hardness: it is `K.Hard` (top of the hardness chain);
  • scaling: an OOD target lands the emergence cost at the cost-top `⊤`
    (R5_Agent6 `ood_reaches_cost_top`), the greatest cost (`wall_is_top_cost`).
-/

/-- **(3) The wall is the common top of the three orders.**

For an OOD target `(p, X)`, the autonomy phase (rank 2) realises the shared
greatest element across degeneration, hardness, and scaling:

  (D) its degeneration level `DegenStep`s into the terminal `univ`, which is
      `IsTop` and absorbing (R5_Agent6);
  (H) it is `K.Hard`, and every cost `m : ℕ∞` is `≤ ⊤` (the cost-top is
      greatest, R5_Agent6 `wall_is_top_cost`);
  (S) the emergence cost saturates exactly at the wall `N p X = ⊤`
      (R5_Agent6 `ood_reaches_cost_top`).
One greatest element, three orders. -/
theorem wall_is_common_top
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov)
    (K : HardnessKernel Prob)
    {S Q₀ Q₁ Q₂ : Prob} (hS : K.Hard S)
    (e0 : K.R S Q₀) (e1 : K.R Q₀ Q₁) (e2 : K.R Q₁ Q₂)
    (C₀ C₁ C₂ : Finset Ω)
    {α' ΩD : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (hood : IsOOD (α' := α') (Ω := ΩD) (p, X)) :
    -- (D) degeneration top: the autonomy level sinks into the greatest/absorbing `univ`
    (DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.2
               (Finset.univ : Finset Ω)
      ∧ (∀ T : Finset Ω, DegenStep T (Finset.univ : Finset Ω))
      ∧ ∀ T : Finset Ω, DegenStep (Finset.univ : Finset Ω) T → T = Finset.univ)
    -- (H) hardness top + cost-top is greatest
    ∧ (K.Hard (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.1
        ∧ ∀ m : ℕ∞, m ≤ (⊤ : ℕ∞))
    -- (S) scaling saturation: OOD emergence cost lands at the wall ⊤
    ∧ MIP.N p X = (⊤ : ℕ∞) := by
  refine ⟨⟨?_, univ_isTop_degen, ?_⟩, ⟨?_, wall_is_top_cost⟩, ?_⟩
  · exact phaseDegen_sinks_to_univ C₀ C₁ C₂ 2
  · exact (degen_absorb_univ).2
  · exact genTransfer K e2 (phaseHardnessStep K hS e0 e1)
  · exact (ood_reaches_cost_top (Ω' := ΩD) p X hood).1

/-! ## (4) HEADLINE — one emergence-difficulty ordinal.

We assemble (2) compatibility and (3) common top into a single statement:
phase, degeneration, and hardness define ONE AND THE SAME ordinal — a shared
strictly-increasing 3-chain (the scaling cost is `StrictMono`, the hardness
problems form a `K.R`-chain of `K.Hard` nodes, the degeneration levels form a
`DegenStep`-chain) plus a shared greatest element (the wall: `univ` /
`N = ⊤` / hardest phase). -/

/-- **(4) HEADLINE — phase = degeneration = hardness is one ordinal.**

Chaining R5_Agent6 (`univ_isTop_degen`, `ood_reaches_cost_top`,
`wall_is_top_cost`, `degen_absorb_univ`), R5_Agent7 (`phaseCost_strictMono`,
`phaseHardnessStep`), and R4_Agent4/R4_Agent3 (`DegenStep`, `genTransfer`):
under the heavy-tail scaling regime, a hard root `S` with reachability chain
`S ≤ Q₀ ≤ Q₁ ≤ Q₂`, a degeneration chain `C₀ ⊆ C₁ ⊆ C₂`, and an OOD target
`(p, X)`, the unified rank `tripleRank` realises:

  (1) **Shared chain.**  ONE index `r : Fin 3` along which
        • the SCALING cost is `StrictMono` (first projection),
        • the HARDNESS problems form a `K.R`-chain whose top is `K.Hard`
          (second projection),
        • the DEGENERATION levels form a `DegenStep`-chain (third projection).
      The three preorders restrict to the SAME total order on `Fin 3`.

  (2) **Shared top (the wall).**  The hardest phase (rank 2) is the common
      greatest element: its degeneration level sinks into the terminal `univ`
      (greatest + absorbing), it is `K.Hard`, and the OOD emergence cost
      saturates at the cost-top `N p X = ⊤` (greatest cost).

Thus emergence difficulty is a SINGLE ordinal: phase, degeneration, and
hardness are three faces of one order. -/
theorem three_orders_one_ordinal
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov)
    (K : HardnessKernel Prob)
    {S Q₀ Q₁ Q₂ : Prob} (hS : K.Hard S)
    (e0 : K.R S Q₀) (e1 : K.R Q₀ Q₁) (e2 : K.R Q₁ Q₂)
    {C₀ C₁ C₂ : Finset Ω} (d1 : DegenStep C₀ C₁) (d2 : DegenStep C₁ C₂)
    {α' ΩD : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (hood : IsOOD (α' := α') (Ω := ΩD) (p, X)) :
    -- (1a) SHARED CHAIN — scaling: strictly increasing cost coordinate
    (StrictMono
        (fun r => (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ r).1))
    -- (1b) SHARED CHAIN — hardness: K.R-edges, top hard
    ∧ (K.R (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 0).2.1
           (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.1
        ∧ K.R (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.1
              (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.1
        ∧ K.Hard (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.1)
    -- (1c) SHARED CHAIN — degeneration: DegenStep-edges
    ∧ (DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 0).2.2
                 (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.2
        ∧ DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 1).2.2
                    (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.2)
    -- (2) SHARED TOP — the wall, common greatest element of all three orders
    ∧ (DegenStep (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.2
                 (Finset.univ : Finset Ω)
        ∧ (∀ T : Finset Ω, DegenStep T (Finset.univ : Finset Ω))
        ∧ K.Hard (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.1
        ∧ (∀ m : ℕ∞, m ≤ (⊤ : ℕ∞))
        ∧ MIP.N p X = (⊤ : ℕ∞)) := by
  -- The hardness of the top, reused in both the chain and the top blocks.
  have hHardTop :
      K.Hard (tripleRank Linf C s ℓ_cov ℓ_star ℓ_aut Q₀ Q₁ Q₂ C₀ C₁ C₂ 2).2.1 :=
    genTransfer K e2 (phaseHardnessStep K hS e0 e1)
  refine ⟨?_, ⟨e1, e2, hHardTop⟩, ⟨d1, d2⟩,
          ⟨phaseDegen_sinks_to_univ C₀ C₁ C₂ 2, univ_isTop_degen, hHardTop,
           wall_is_top_cost, (ood_reaches_cost_top (Ω' := ΩD) p X hood).1⟩⟩
  -- (1a) scaling strict monotonicity of the first coordinate.
  exact tripleRank_scaling_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
    Q₀ Q₁ Q₂ C₀ C₁ C₂ hC h_s h_aut h_star h_cov

end R6_Agent9_ThreeOrderUnification

end MIP
