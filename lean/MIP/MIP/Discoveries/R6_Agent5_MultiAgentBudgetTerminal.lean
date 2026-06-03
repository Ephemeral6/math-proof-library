/-
  STATUS: DISCOVERY
  AGENT: R6_Agent5
  DIRECTION: TERMINAL ELEMENT OF THE MULTI-AGENT OHM BUDGET.

    Round-5 Agent 4 (`R5_Agent4_TensorOhmBudget`) proved the JOINT Ohm budget
    subadditivity for `k` tensor-independent agents in the FINITE regime:
    grounded in the tensor conservation law, the joint integer budget
    `N_joint = ⌈Z·Φ_joint⌉₊` satisfies
        N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊            (`multi_agent_ohm_budget_law`).
    Round-5 Agent 6 (`R5_Agent6_SaturationIsTerminalDegeneration`) proved the
    extrapolation wall `N = ⊤` is the TERMINAL, ABSORBING element of the
    degeneration cost order on `ℕ∞`:
        `wall_is_top_cost : ∀ m : ℕ∞, m ≤ ⊤`,
        `cost_absorb_top : ⊤ ≤ x → x = ⊤`,
        `ood_reaches_cost_top : IsOOD (p,X) → N p X = ⊤`.

    THIS FILE composes the two SECOND-ORDER structures into a THIRD-ORDER one:
    it lifts the multi-agent Ohm budget into the cost order `ℕ∞` (where a
    walled agent can genuinely take the value `⊤`) and characterises what
    happens to the JOINT committee budget when one or more agents hit the wall.

    Setup.  A committee of `k = |ι|` agents.  Each agent `a` carries a per-agent
    cost in `ℕ∞` packaged by `agentBudget`:
        agentBudget walled fin a  =  if walled a then ⊤ else (fin a : ℕ∞).
    The JOINT committee budget is the `ℕ∞`-sum  `jointBudget = ∑_a agentBudget a`.
    The all-wall configuration is `walled = fun _ => True` (every agent at `⊤`).

  SUMMARY (three results; ⊤-in-ℕ∞ handled carefully throughout):

    (a) ABSORPTION LAW (`one_walled_agent_absorbs`).  If ANY single agent is at
        the wall (`agentBudget _ _ b = ⊤`, i.e. R5_Agent6 / R4_Agent9's
        `IsOOD ⟹ N = ⊤` for that agent), the WHOLE joint committee budget is
        `⊤`:  one failing agent absorbs the entire joint system.  The wall is
        ABSORBING across the tensor product / committee sum.  Proof: the walled
        agent's `⊤` is `≤ ∑` (`Finset.single_le_sum`, ℕ∞ canonically ordered),
        then R5_Agent6's `cost_absorb_top` forces the sum to `⊤`.

    (b) MONOTONICITY (`joint_budget_monotone`).  The joint budget is monotone in
        each agent's individual cost: pointwise `B a ≤ B' a` ⟹ `∑ B ≤ ∑ B'`.
        More capable agents (smaller per-agent cost) never enlarge the joint
        budget.  Hence (`all_wall_is_terminal`) the all-at-the-wall configuration
        `fun _ => ⊤` is the GREATEST element of the multi-agent budget order —
        every committee budget is `≤` the all-wall budget — mirroring
        R5_Agent6's terminality at the multi-agent level, and its value is `⊤`.

    (c) HEADLINE — `all_wall_is_terminal_multiagent_budget`.  Packaging
        (a)+(b) with the R5_Agent4 grounding and the R5_Agent6 wall bridge:
          (T1) GROUNDING: in the all-FINITE (no-wall) configuration the joint
               `ℕ∞` budget equals the cast of R5_Agent4's finite joint budget
               sum, and is therefore `< ⊤`; the finite multi-agent law
               `multi_agent_ohm_budget_law` bounds the true joint `N_joint`
               under it (a genuine, non-vacuous finite floor);
          (T2) ABSORPTION: one walled agent ⟹ joint = `⊤`;
          (T3) MONOTONICITY + TERMINALITY: joint budget is monotone, and the
               all-wall config is the greatest element (`≤ ⊤` for every config,
               attained as `= ⊤`);
          (T4) WALL BRIDGE: an OOD agent's emergence cost `N p X = ⊤` IS a
               walled budget, so an OOD agent in the committee triggers (a) —
               the joint budget degenerates to the terminal `⊤`.
        The all-wall configuration is the TERMINAL (greatest, absorbing) element
        of the multi-agent Ohm budget order; one walled agent absorbs the joint
        budget — chaining R5_Agent4 (finite subadditive floor) with R5_Agent6
        (terminal absorbing wall) one order DEEPER than either.

  Depends on (exact imported lemmas used as proof terms):
    - MIP.Discoveries.R5_Agent4_TensorOhmBudget
        · R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
            (the finite joint subadditivity `N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊`;
             genuinely invoked in `finite_config_grounds_joint`, the T1 floor)
          (NOTE: `agent_expectation_le_envelope` is NOT invoked directly here; it
           enters only TRANSITIVELY, inside the proof of `multi_agent_ohm_budget_law`.
           This file's only direct R5_Agent4 proof-term dependency is
           `multi_agent_ohm_budget_law`.)
    - MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
        · R5_Agent6_SaturationIsTerminalDegeneration.cost_absorb_top
            (`⊤ ≤ x → x = ⊤`; the absorbing fixed point, invoked in (a))
        · R5_Agent6_SaturationIsTerminalDegeneration.wall_is_top_cost
            (`∀ m, m ≤ ⊤`; the cost-top, invoked in terminality)
        · R5_Agent6_SaturationIsTerminalDegeneration.ood_reaches_cost_top
            (`IsOOD ⟹ N p X = ⊤`; the wall bridge for (T4))
        · R5_Agent6_SaturationIsTerminalDegeneration.IsOOD (re-exported)
    - Mathlib: Finset.single_le_sum, Finset.sum_le_sum, Finset.sum_congr,
        le_top, top_le_iff, ENat (`ℕ∞ = WithTop ℕ`), Nat.cast_sum.
-/
import MIP.Discoveries.R5_Agent4_TensorOhmBudget
import MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.ENat.Basic

namespace MIP

open scoped BigOperators

namespace R6_Agent5_MultiAgentBudgetTerminal

open MIP.R5_Agent6_SaturationIsTerminalDegeneration (cost_absorb_top wall_is_top_cost ood_reaches_cost_top)
open MIP.R4_Agent9_ScalingSaturationWall (IsOOD)

/-! ## The committee budget in the cost order `ℕ∞`.

Each agent `a` of a finite committee `ι` carries a cost in `ℕ∞ = WithTop ℕ`:
either a FINITE Ohm budget `(fin a : ℕ∞)` (the R5_Agent4 per-agent budget
`⌈Z·Mφ a⌉₊`) or the WALL value `⊤` (R5_Agent6 / R4_Agent9: an OOD agent has
`N = ⊤`).  The committee/joint budget is the `ℕ∞`-sum of the per-agent
budgets. -/

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- **Per-agent budget in the cost order.**  Agent `a`'s cost is `⊤` when it is
"walled" (OOD / `N = ⊤`, R5_Agent6) and the finite Ohm budget `(fin a : ℕ∞)`
otherwise. -/
def agentBudget (walled : ι → Prop) [DecidablePred walled] (fin : ι → ℕ)
    (a : ι) : ℕ∞ :=
  if walled a then (⊤ : ℕ∞) else (fin a : ℕ∞)

/-- **Joint committee budget.**  The `ℕ∞`-sum of the per-agent budgets. -/
def jointBudget (walled : ι → Prop) [DecidablePred walled] (fin : ι → ℕ) : ℕ∞ :=
  ∑ a, agentBudget walled fin a

@[simp] theorem agentBudget_walled
    {walled : ι → Prop} [DecidablePred walled] {fin : ι → ℕ} {a : ι}
    (h : walled a) : agentBudget walled fin a = (⊤ : ℕ∞) := by
  simp [agentBudget, h]

@[simp] theorem agentBudget_not_walled
    {walled : ι → Prop} [DecidablePred walled] {fin : ι → ℕ} {a : ι}
    (h : ¬ walled a) : agentBudget walled fin a = (fin a : ℕ∞) := by
  simp [agentBudget, h]

/-! ## (a) ABSORPTION — one walled agent absorbs the joint budget. -/

/-- **(a) Absorption law.**  If ANY single agent `b` is at the wall
(`agentBudget _ _ b = ⊤`), the joint committee budget is `⊤`.

This is the multi-agent lift of R5_Agent6's terminal absorbing wall: the
walled agent's cost `⊤` is `≤` the committee sum (`Finset.single_le_sum`, valid
because every element of `ℕ∞` is `0 ≤ ·`), and R5_Agent6's `cost_absorb_top`
(`⊤ ≤ x → x = ⊤`) then forces the whole sum to `⊤`.  One failing agent
dominates the entire committee — the wall is absorbing across the joint sum. -/
theorem one_walled_agent_absorbs
    (walled : ι → Prop) [DecidablePred walled] (fin : ι → ℕ)
    (b : ι) (hb : agentBudget walled fin b = (⊤ : ℕ∞)) :
    jointBudget walled fin = (⊤ : ℕ∞) := by
  -- The walled agent's ⊤ is ≤ the joint sum.
  have h_le : agentBudget walled fin b ≤ jointBudget walled fin :=
    Finset.single_le_sum (f := agentBudget walled fin)
      (fun i _ => bot_le) (Finset.mem_univ b)
  -- Rewrite the walled budget as ⊤, then absorb via R5_Agent6's cost_absorb_top.
  rw [hb] at h_le
  exact cost_absorb_top (jointBudget walled fin) h_le

/-- **(a′) Absorption from the `walled` predicate.**  If the predicate `walled`
actually flags some agent `b`, the joint budget is `⊤`.  This is (a) packaged
on the predicate side: a single OOD / saturated agent in the committee
collapses the joint budget to the terminal wall. -/
theorem walled_agent_absorbs
    (walled : ι → Prop) [DecidablePred walled] (fin : ι → ℕ)
    (b : ι) (hb : walled b) :
    jointBudget walled fin = (⊤ : ℕ∞) :=
  one_walled_agent_absorbs walled fin b (agentBudget_walled hb)

/-! ## (b) MONOTONICITY and TERMINALITY of the all-wall configuration. -/

/-- **(b) Monotonicity of the joint budget.**  If every agent's cost is
pointwise dominated, `B a ≤ B' a`, the joint sums are ordered `∑ B ≤ ∑ B'`.
More capable agents (smaller per-agent cost) never enlarge the joint budget. -/
theorem joint_budget_monotone
    (B B' : ι → ℕ∞) (h : ∀ a, B a ≤ B' a) :
    (∑ a, B a) ≤ ∑ a, B' a :=
  Finset.sum_le_sum (fun a _ => h a)

/-- The all-wall configuration as a per-agent budget family: every agent at the
wall `⊤`. -/
def allWallBudget : ι → ℕ∞ := fun _ => (⊤ : ℕ∞)

/-- **The all-wall joint budget is `⊤`.**  When every agent is walled the joint
committee budget is the terminal cost-top.  (Special case of absorption, or
directly: any nonempty committee already gives `⊤`; with the convention here we
read it off the `walled = fun _ => True` configuration.) -/
theorem allWall_joint_budget [Nonempty ι] (fin : ι → ℕ) :
    jointBudget (fun _ => True) fin = (⊤ : ℕ∞) := by
  obtain ⟨b⟩ := (inferInstance : Nonempty ι)
  exact walled_agent_absorbs (fun _ => True) fin b trivial

/-- **(b′) The all-wall configuration is the GREATEST element of the
multi-agent budget order.**  Every per-agent budget family `B : ι → ℕ∞` is
pointwise `≤` the all-wall family (`B a ≤ ⊤`, R5_Agent6's `wall_is_top_cost`),
hence its joint sum is `≤` the all-wall joint sum:

    ∀ B, (∑ a, B a) ≤ ∑ a, allWallBudget a.

So `allWallBudget` is the TERMINAL (greatest) element of the multi-agent Ohm
budget order — the multi-agent mirror of R5_Agent6's single-agent terminality
of the wall. -/
theorem all_wall_is_terminal (B : ι → ℕ∞) :
    (∑ a, B a) ≤ ∑ a, (allWallBudget : ι → ℕ∞) a :=
  joint_budget_monotone B allWallBudget (fun a => wall_is_top_cost (B a))

/-- The all-wall joint sum is itself `⊤` (the greatest element is attained at
the cost-top). -/
theorem all_wall_sum_eq_top [Nonempty ι] :
    (∑ a, (allWallBudget : ι → ℕ∞) a) = (⊤ : ℕ∞) := by
  obtain ⟨b⟩ := (inferInstance : Nonempty ι)
  have h_le : (allWallBudget : ι → ℕ∞) b ≤ ∑ a, (allWallBudget : ι → ℕ∞) a :=
    Finset.single_le_sum (f := (allWallBudget : ι → ℕ∞))
      (fun i _ => bot_le) (Finset.mem_univ b)
  have hb : (allWallBudget : ι → ℕ∞) b = (⊤ : ℕ∞) := rfl
  rw [hb] at h_le
  exact cost_absorb_top _ h_le

/-! ## (c.0) GROUNDING the finite (no-wall) configuration in R5_Agent4.

When NO agent is walled the joint `ℕ∞` budget is the cast of the finite
per-agent Ohm-budget sum `∑_a fin a`.  We take `fin a := ⌈Z·Mφ a⌉₊` (R5_Agent4's
per-agent budgets) and use R5_Agent4's finite `multi_agent_ohm_budget_law` to
certify the true joint integer budget `N_joint` lies UNDER this finite sum: the
all-finite branch of the `ℕ∞` budget genuinely floors the honest joint Ohm
budget.  This makes the finite side non-vacuous before the wall absorbs it. -/

/-- **All-finite collapse.**  With no walled agent, the joint `ℕ∞` budget equals
the cast of the finite per-agent sum. -/
theorem joint_budget_all_finite
    (walled : ι → Prop) [DecidablePred walled] (fin : ι → ℕ)
    (hnone : ∀ a, ¬ walled a) :
    jointBudget walled fin = ((∑ a, fin a : ℕ) : ℕ∞) := by
  unfold jointBudget
  rw [Nat.cast_sum]
  exact Finset.sum_congr rfl (fun a _ => agentBudget_not_walled (hnone a))

/-- **(c.0) R5_Agent4 grounds the finite configuration.**

Take the finite per-agent budgets `fin a := ⌈Z·Mφ a⌉₊`.  In the no-wall
configuration the joint `ℕ∞` budget is `(∑_a ⌈Z·Mφ a⌉₊ : ℕ∞)`, which is FINITE
(`< ⊤`), AND R5_Agent4's `multi_agent_ohm_budget_law` certifies the honest
joint integer Ohm budget `N_joint` (`= ⌈Z·Φ_joint⌉₊`) satisfies
`N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊`, i.e. `(N_joint : ℕ∞) ≤ jointBudget`.

So the finite branch is a genuine, non-vacuous FLOOR for the multi-agent budget
before any wall is hit — the R5_Agent4 second-order law sits underneath this
third-order `ℕ∞` lift. -/
theorem finite_config_grounds_joint
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_def : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊)
    (walled : ι → Prop) [DecidablePred walled]
    (hnone : ∀ a, ¬ walled a) :
    jointBudget walled (fun a => ⌈Z * Mφ a⌉₊)
        = ((∑ a, ⌈Z * Mφ a⌉₊ : ℕ) : ℕ∞)
      ∧ jointBudget walled (fun a => ⌈Z * Mφ a⌉₊) ≠ (⊤ : ℕ∞)
      ∧ (Njoint : ℕ∞) ≤ jointBudget walled (fun a => ⌈Z * Mφ a⌉₊) := by
  -- All-finite collapse to the cast of the finite per-agent sum.
  have hcollapse :
      jointBudget walled (fun a => ⌈Z * Mφ a⌉₊)
        = ((∑ a, ⌈Z * Mφ a⌉₊ : ℕ) : ℕ∞) :=
    joint_budget_all_finite walled (fun a => ⌈Z * Mφ a⌉₊) hnone
  -- R5_Agent4's finite joint subadditivity: N_joint ≤ ∑ ⌈Z·Mφ a⌉₊.
  have hsub : Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊ :=
    R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
      π φ Mφ Φjoint Z Njoint hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm
  refine ⟨hcollapse, ?_, ?_⟩
  · rw [hcollapse]; exact (ENat.coe_ne_top _)
  · rw [hcollapse]
    exact_mod_cast hsub

/-! ## (c) HEADLINE — the all-wall configuration is the terminal multi-agent
Ohm budget; one walled agent absorbs the joint budget. -/

/-- **(c) HEADLINE — terminal element of the multi-agent Ohm budget.**

For a committee `ι` of agents with finite per-agent Ohm budgets
`fin a := ⌈Z·Mφ a⌉₊` (R5_Agent4) and a wall predicate `walled` (R5_Agent6 /
R4_Agent9: `walled a` iff agent `a`'s emergence cost is `⊤`), the joint `ℕ∞`
committee budget `jointBudget walled fin = ∑_a agentBudget walled fin a`
satisfies:

  (T1) **GROUNDING (finite floor).**  In the no-wall configuration the joint
       budget is the FINITE cast `(∑_a ⌈Z·Mφ a⌉₊ : ℕ∞) < ⊤`, and R5_Agent4's
       `multi_agent_ohm_budget_law` floors the honest joint integer budget
       `N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊` underneath it (a non-vacuous finite regime);
  (T2) **ABSORPTION.**  one walled agent `b` ⟹ joint budget `= ⊤`
       (R5_Agent6's `cost_absorb_top`): one failing agent dominates the
       committee;
  (T3) **MONOTONICITY + TERMINALITY.**  the joint budget is monotone in each
       agent's cost, and the all-wall family `fun _ => ⊤` is the GREATEST
       element of the multi-agent budget order — `(∑ B) ≤ ∑ allWallBudget` for
       every family `B` (R5_Agent6's `wall_is_top_cost`), attained as `= ⊤`;
  (T4) **WALL BRIDGE.**  an OOD agent's emergence cost is `⊤`
       (R5_Agent6's `ood_reaches_cost_top`), so flagging that agent as walled
       triggers (T2): an OOD agent in the committee degenerates the joint
       budget to the terminal `⊤`.

The all-wall configuration is the TERMINAL (greatest, absorbing) element of the
multi-agent Ohm budget order, mirroring R5_Agent6's single-agent terminality at
the committee level, and chaining it with R5_Agent4's finite subadditivity one
order deeper. -/
theorem all_wall_is_terminal_multiagent_budget
    [Nonempty ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_def : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊) :
    -- (T1) GROUNDING: finite no-wall floor from R5_Agent4.
    (∀ (walled : ι → Prop) [DecidablePred walled], (∀ a, ¬ walled a) →
        jointBudget walled (fun a => ⌈Z * Mφ a⌉₊) ≠ (⊤ : ℕ∞)
        ∧ (Njoint : ℕ∞) ≤ jointBudget walled (fun a => ⌈Z * Mφ a⌉₊))
    -- (T2) ABSORPTION: one walled agent ⟹ joint = ⊤.
    ∧ (∀ (walled : ι → Prop) [DecidablePred walled] (b : ι), walled b →
        jointBudget walled (fun a => ⌈Z * Mφ a⌉₊) = (⊤ : ℕ∞))
    -- (T3) MONOTONICITY + TERMINALITY of the all-wall configuration.
    ∧ ((∀ B B' : ι → ℕ∞, (∀ a, B a ≤ B' a) → (∑ a, B a) ≤ ∑ a, B' a)
        ∧ (∀ B : ι → ℕ∞, (∑ a, B a) ≤ ∑ a, (allWallBudget : ι → ℕ∞) a)
        ∧ (∑ a, (allWallBudget : ι → ℕ∞) a) = (⊤ : ℕ∞))
    -- (T4) WALL BRIDGE: an OOD agent has cost ⊤, so it is a walling event.
    ∧ (∀ {α' Ω' : Type} (p : MIP.Problem α') (X : MIP.Agent α'),
        IsOOD (Ω := Ω') (p, X) → MIP.N p X = (⊤ : ℕ∞)) := by
  refine ⟨?_, ?_, ⟨?_, ?_, ?_⟩, ?_⟩
  · -- (T1)
    intro walled _ hnone
    have h := finite_config_grounds_joint π φ Mφ Φjoint Z Njoint
      hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm walled hnone
    exact ⟨h.2.1, h.2.2⟩
  · -- (T2)
    intro walled _ b hb
    exact walled_agent_absorbs walled (fun a => ⌈Z * Mφ a⌉₊) b hb
  · -- (T3) monotonicity
    intro B B' h
    exact joint_budget_monotone B B' h
  · -- (T3) terminality (greatest)
    intro B
    exact all_wall_is_terminal B
  · -- (T3) all-wall value is ⊤
    exact all_wall_sum_eq_top
  · -- (T4) wall bridge
    intro α' Ω' p X hood
    exact (ood_reaches_cost_top (Ω' := Ω') p X hood).1

end R6_Agent5_MultiAgentBudgetTerminal

end MIP
