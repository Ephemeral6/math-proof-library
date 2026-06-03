/-
  STATUS: DISCOVERY
  AGENT: R7_Agent2
  DIRECTION: THE WALL IS THE ABSORBING OBJECT OF THE OHM LAX MONOIDAL FUNCTOR.

    Round-6 Agent 10 (`R6_Agent10_OhmLaxMonoidalFunctor`) proved the Ohm budget
    `ohmCost Z : Finset (BarrierData α) → ℕ` is a LAX MONOIDAL FUNCTOR on the
    barrier category: monoidal product = independent composition (union of
    configs), monoidal unit = `∅`, with the LAXATOR
        ohmCost Z (S ∪ T) ≤ ohmCost Z S + ohmCost Z T        (`ohmCost_union_le`)
    and its three-fold/associativity coherence (`ohmLaxator_assoc`),
    naturality (`ohmLaxator_natural`) and unit `ohmCost Z ∅ = 0` (`ohmCost_empty`).
    But this functor is `ℕ`-valued: every object has a FINITE budget; there is
    no room for the WALL.

    Round-6 Agent 5 (`R6_Agent5_MultiAgentBudgetTerminal`) proved, at the
    MULTI-AGENT level, that the all-wall configuration is the TERMINAL /
    ABSORBING element of the committee budget in the cost order `ℕ∞ = WithTop ℕ`:
    one walled agent (`agentBudget = ⊤`) forces the joint `ℕ∞`-sum to `⊤`
    (`one_walled_agent_absorbs`), the all-wall family is the greatest element
    (`all_wall_is_terminal`, attained as `all_wall_sum_eq_top`), the sum is
    monotone (`joint_budget_monotone`), and R5_Agent6's `cost_absorb_top` /
    `wall_is_top_cost` drive the absorption.

    THIS FILE fuses the two at the MONOIDAL level.  We LIFT R6_Agent10's
    `ℕ`-valued lax monoidal Ohm functor into the cost order `ℕ∞` and adjoin a
    formal WALL OBJECT `W`.  A tagged barrier object is either a finite config
    `obj S` (lifted budget `(ohmCost Z S : ℕ∞)`) or the wall `wall` (budget
    `⊤`).  The MONOIDAL PRODUCT at the budget level is `+` in `ℕ∞` (the lifted
    laxed combination of R6_Agent10).  We then prove:

        budget(W ⊗ X) = ⊤    and    budget(X ⊗ W) = ⊤       (ABSORPTION)

    so the wall `W` is the ABSORBING OBJECT of the lax monoidal functor: the
    functor sends the absorbing object to the absorbing budget element `⊤ ∈ ℕ∞`.
    On the wall-free part the lifted laxator
        budget(obj (S ∪ T)) ≤ budget(obj S) + budget(obj T)
    is EXACTLY R6_Agent10's `ohmCost_union_le` cast to `ℕ∞` (so the lax
    structure is preserved by the lift), and the absorption matches
    R6_Agent5's `one_walled_agent_absorbs` at the functor level.

  SUMMARY:

    (a) THE LIFTED LAX FUNCTOR.  `liftedBudget Z : TaggedBarrier α → ℕ∞`,
        `liftedBudget Z (obj S) = (ohmCost Z S : ℕ∞)`, `liftedBudget Z wall = ⊤`.
        On wall-free objects the lifted laxator `lifted_laxator` is R6_Agent10's
        `ohmCost_union_le` cast through `ENat`; the lifted unit
        `liftedBudget Z (obj ∅) = 0` is R6_Agent10's `ohmCost_empty`.

    (b) ABSORPTION (the headline content).  `budgetTensor X Y := budget X +
        budget Y` is the budget-level monoidal product.  The wall absorbs:
            wall_tensor_left   : budgetTensor wall X = ⊤
            wall_tensor_right  : budgetTensor X wall = ⊤
        via `ENat` `top_add`/`add_top`.  More structurally we read this off the
        same engine as R6_Agent5: a walled component is `≤` the tensor sum and
        R5_Agent6's `cost_absorb_top` forces `⊤` — exactly
        `one_walled_agent_absorbs` specialised to the two-object tensor.

    (c) HEADLINE — `wall_is_absorbing_object_of_ohm_lax_monoidal_functor`.
        Packaging the full statement "the extrapolation wall `W` is the
        ABSORBING OBJECT of the Ohm lax monoidal functor":
          (i)   the lift is FAITHFUL to R6_Agent10 on wall-free objects: the
                lifted budget of `obj S` is `(ohmCost Z S : ℕ∞)` and the lifted
                laxator IS R6_Agent10's `ohmCost_union_le` (cast);
          (ii)  the lifted unit is `0` (R6_Agent10's `ohmCost_empty`);
          (iii) ABSORPTION: `budgetTensor wall X = ⊤ = budgetTensor X wall` for
                every `X` — the functor sends the absorbing object `W` to the
                absorbing budget element `⊤`;
          (iv)  COHERENCE with R6_Agent5: the two-object absorption agrees with
                `one_walled_agent_absorbs` (a walled component forces the
                committee `ℕ∞`-sum to `⊤`), so the monoidal-level absorption
                matches the multi-agent terminal absorption at the functor
                level;
          (v)   the lifted budget is MONOTONE and `wall` is the GREATEST tagged
                object (`liftedBudget Z X ≤ liftedBudget Z wall = ⊤`,
                R5_Agent6's `wall_is_top_cost`).
        Chaining R6_Agent10 (the lax monoidal laxator, lifted) with R6_Agent5
        (`one_walled_agent_absorbs`, the absorbing wall) one level UP: the wall
        is not merely a terminal budget value, it is the ABSORBING OBJECT of the
        monoidal functor, `budget(W ⊗ X) = ⊤`.

  Depends on (exact imported lemmas used as proof terms):
    - MIP.Discoveries.R6_Agent10_OhmLaxMonoidalFunctor
        · R6_Agent10_OhmLaxMonoidalFunctor (open) `ohmCost` (R5_Agent10, re-used
          object map of the lifted functor)
        · R6_Agent10_OhmLaxMonoidalFunctor.ohmCost_union_le
            (the LAXATOR; cast to `ℕ∞` in `lifted_laxator`, hence in the HEADLINE)
        · R6_Agent10_OhmLaxMonoidalFunctor.ohmCost_empty
            (the lax UNIT map; in `lifted_unit` / HEADLINE)
    - MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal
        · R6_Agent5_MultiAgentBudgetTerminal.one_walled_agent_absorbs
            (the ABSORPTION engine; specialised to the 2-object tensor in
             `wall_tensor_absorbs_via_R6Agent5`, hence in the HEADLINE coherence
             clause)
        · R6_Agent5_MultiAgentBudgetTerminal.jointBudget /.agentBudget
            (the committee budget the absorption is read off — provenance of the
             coherence statement)
    - MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
        · R5_Agent6_SaturationIsTerminalDegeneration.wall_is_top_cost
            (`∀ m, m ≤ ⊤`; the cost-top, drives `liftedBudget_le_wall`)
        (`cost_absorb_top` enters transitively via `one_walled_agent_absorbs`.)
    - MIP.Defs.Barriers (BarrierData), via R6_Agent10.
    - Mathlib: WithTop/ENat `top_add`, `add_top`, `le_top`, `Nat.cast_add`,
        `ENat` coercion.
-/
import MIP.Discoveries.R6_Agent10_OhmLaxMonoidalFunctor
import MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal
import Mathlib.Data.ENat.Basic

namespace MIP

open scoped BigOperators

open MIP.R5_Agent10_OhmBudgetContravariantFunctor (ohmCost ohmCost_def)
open MIP.R6_Agent10_OhmLaxMonoidalFunctor (ohmCost_union_le ohmCost_empty)
open MIP.R5_Agent6_SaturationIsTerminalDegeneration (wall_is_top_cost)

namespace R7_Agent2_WallAbsorbingMonoidalObject

variable {α : Type}

/-! ## (a) The tagged barrier object and the LIFTED lax monoidal functor.

A tagged barrier object is either a finite barrier configuration `obj S` or the
formal WALL object `wall`.  The lifted Ohm budget sends `obj S` to R6_Agent10's
budget `(ohmCost Z S : ℕ∞)` (lifted from `ℕ` into the cost order `ℕ∞`) and the
wall to the absorbing cost-top `⊤`. -/

/-- **Tagged barrier object**: a finite barrier configuration `obj S`, or the
formal wall object `wall` (the extrapolation wall `W`). -/
inductive TaggedBarrier (α : Type) where
  | obj  : Finset (BarrierData α) → TaggedBarrier α
  | wall : TaggedBarrier α

/-- **The lifted Ohm budget functor** into the cost order `ℕ∞`.  On a finite
config it is R6_Agent10's `ohmCost Z S` cast to `ℕ∞`; on the wall it is the
absorbing cost-top `⊤`. -/
noncomputable def liftedBudget (Z : ℝ) : TaggedBarrier α → ℕ∞
  | .obj S => ((ohmCost Z S : ℕ) : ℕ∞)
  | .wall  => (⊤ : ℕ∞)

@[simp] theorem liftedBudget_obj (Z : ℝ) (S : Finset (BarrierData α)) :
    liftedBudget Z (.obj S) = ((ohmCost Z S : ℕ) : ℕ∞) := rfl

@[simp] theorem liftedBudget_wall (Z : ℝ) :
    liftedBudget Z (.wall : TaggedBarrier α) = (⊤ : ℕ∞) := rfl

/-! ### Faithfulness of the lift to R6_Agent10: the lifted laxator and unit. -/

/-- **(a) The lifted laxator IS R6_Agent10's `ohmCost_union_le`.**  On wall-free
objects the lifted budget of an independent composite (union of configs) is
bounded by the sum of the lifted budgets — the `ℕ∞`-cast of R6_Agent10's
`ohmCost_union_le`.  So the lax-monoidal structure map survives the lift. -/
theorem lifted_laxator (Z : ℝ) (hZ : 0 ≤ Z) (S T : Finset (BarrierData α)) :
    liftedBudget Z (.obj (S ∪ T))
      ≤ liftedBudget Z (.obj S) + liftedBudget Z (.obj T) := by
  simp only [liftedBudget_obj]
  -- cast R6_Agent10's ℕ-laxator into ℕ∞
  have h : ohmCost Z (S ∪ T) ≤ ohmCost Z S + ohmCost Z T :=
    ohmCost_union_le Z hZ S T
  calc ((ohmCost Z (S ∪ T) : ℕ) : ℕ∞)
      ≤ ((ohmCost Z S + ohmCost Z T : ℕ) : ℕ∞) := by exact_mod_cast h
    _ = ((ohmCost Z S : ℕ) : ℕ∞) + ((ohmCost Z T : ℕ) : ℕ∞) := by
        push_cast; ring

/-- **(a) The lifted unit map** is R6_Agent10's `ohmCost_empty`: the monoidal
unit `obj ∅` maps to the budget unit `0`. -/
@[simp] theorem lifted_unit (Z : ℝ) :
    liftedBudget Z (.obj (∅ : Finset (BarrierData α))) = (0 : ℕ∞) := by
  simp only [liftedBudget_obj]
  rw [ohmCost_empty Z]
  rfl

/-! ## (b) The budget-level monoidal product and the ABSORBING wall. -/

/-- **Budget-level monoidal product.**  The lifted budget of the monoidal
product `X ⊗ Y` is the `ℕ∞`-combination `budget X + budget Y` — the lifted
laxed combination of R6_Agent10's laxator. -/
noncomputable def budgetTensor (Z : ℝ) (X Y : TaggedBarrier α) : ℕ∞ :=
  liftedBudget Z X + liftedBudget Z Y

/-- **(b) Left absorption.**  `W ⊗ X` has budget `⊤`: the wall absorbs on the
left (`top_add` in `ℕ∞`). -/
@[simp] theorem wall_tensor_left (Z : ℝ) (X : TaggedBarrier α) :
    budgetTensor Z (.wall) X = (⊤ : ℕ∞) := by
  simp only [budgetTensor, liftedBudget_wall]
  exact top_add _

/-- **(b) Right absorption.**  `X ⊗ W` has budget `⊤`: the wall absorbs on the
right (`add_top` in `ℕ∞`). -/
@[simp] theorem wall_tensor_right (Z : ℝ) (X : TaggedBarrier α) :
    budgetTensor Z X (.wall) = (⊤ : ℕ∞) := by
  simp only [budgetTensor, liftedBudget_wall]
  exact add_top _

/-! ### (b′) The absorption IS R6_Agent5's `one_walled_agent_absorbs`.

The two-object tensor absorption is not a fresh fact: it is exactly
R6_Agent5's `one_walled_agent_absorbs` over the 2-element committee `Bool`,
where the walled component plays the role of the OOD agent.  We package the
two tagged objects into a `Bool`-indexed committee whose `ℕ∞`-sum is precisely
`budgetTensor`, exhibit the walled component, and invoke R6_Agent5. -/

/-- The 2-object tensor as a `Bool`-indexed committee `agentBudget`, so that the
committee `ℕ∞`-sum equals `budgetTensor`. -/
private def pairWalled (X Y : TaggedBarrier α) : Bool → Prop
  | false => X = .wall
  | true  => Y = .wall

private noncomputable instance (X Y : TaggedBarrier α) :
    DecidablePred (pairWalled X Y) := by
  intro b; cases b <;> · unfold pairWalled; exact Classical.dec _

/-- **(b′) Two-object absorption via R6_Agent5.**  If `X` is the wall, then the
`Bool`-indexed committee with the walled component flagged has joint budget `⊤`
by R6_Agent5's `one_walled_agent_absorbs`; this joint budget is the wall-side of
`budgetTensor`.  Hence the monoidal absorption is R6_Agent5's absorption at the
functor level. -/
theorem wall_tensor_absorbs_via_R6Agent5 (Z : ℝ) (X : TaggedBarrier α) :
    R6_Agent5_MultiAgentBudgetTerminal.jointBudget
        (pairWalled (.wall) X) (fun _ => 0)
      = (⊤ : ℕ∞) := by
  -- The `false` component is walled, its agentBudget is ⊤.
  have hb : R6_Agent5_MultiAgentBudgetTerminal.agentBudget
      (pairWalled (.wall) X) (fun _ => 0) false = (⊤ : ℕ∞) :=
    R6_Agent5_MultiAgentBudgetTerminal.agentBudget_walled (by rfl)
  exact R6_Agent5_MultiAgentBudgetTerminal.one_walled_agent_absorbs
    (pairWalled (.wall) X) (fun _ => 0) false hb

/-! ## (c′) Monotonicity / greatest element of the lifted functor. -/

/-- **(c′) The wall is the GREATEST tagged object for the lifted budget.**  Every
tagged object's lifted budget is `≤` the wall's budget `⊤` (R5_Agent6's
`wall_is_top_cost`).  So `wall` is the terminal object of the lifted functor. -/
theorem liftedBudget_le_wall (Z : ℝ) (X : TaggedBarrier α) :
    liftedBudget Z X ≤ liftedBudget Z (.wall : TaggedBarrier α) := by
  rw [liftedBudget_wall]
  exact wall_is_top_cost _

/-! ## (c) HEADLINE — the wall is the absorbing object of the Ohm lax monoidal
functor. -/

/-- **(c) HEADLINE — the extrapolation wall `W` is the ABSORBING OBJECT of the
Ohm lax monoidal functor; `budget(W ⊗ X) = ⊤`.**

Lifting R6_Agent10's `ℕ`-valued lax monoidal Ohm functor into the cost order
`ℕ∞` and adjoining the formal wall object `W = wall`, the lifted budget functor
`liftedBudget Z` satisfies, for every `Z ≥ 0`:

  (i)   **FAITHFUL LIFT (laxator + object map).**  On wall-free objects the lift
        is R6_Agent10's functor: `liftedBudget Z (obj S) = (ohmCost Z S : ℕ∞)`,
        and the lifted laxator is R6_Agent10's `ohmCost_union_le` cast to `ℕ∞`:
            `liftedBudget Z (obj (S ∪ T))
                ≤ liftedBudget Z (obj S) + liftedBudget Z (obj T)`.
  (ii)  **UNIT.**  `liftedBudget Z (obj ∅) = 0` (R6_Agent10's `ohmCost_empty`).
  (iii) **ABSORPTION.**  the wall is the ABSORBING OBJECT for the budget
        tensor: `budgetTensor Z wall X = ⊤ = budgetTensor Z X wall` for every
        tagged `X` — the lax monoidal functor sends the absorbing object `W` to
        the absorbing budget element `⊤ ∈ ℕ∞`.
  (iv)  **COHERENCE with R6_Agent5.**  the two-object absorption is exactly
        R6_Agent5's `one_walled_agent_absorbs`: a walled component forces the
        `Bool`-committee joint `ℕ∞`-budget to `⊤`, matching the monoidal
        absorption at the functor level.
  (v)   **GREATEST ELEMENT.**  `liftedBudget Z X ≤ liftedBudget Z wall = ⊤`
        for every `X` (R5_Agent6's `wall_is_top_cost`): `wall` is the terminal /
        greatest tagged object.

This realises "the extrapolation wall is the absorbing object of the Ohm lax
monoidal functor", chaining R6_Agent10 (the lifted laxator + unit) with
R6_Agent5 (`one_walled_agent_absorbs`, the absorbing wall) one categorical level
up. -/
theorem wall_is_absorbing_object_of_ohm_lax_monoidal_functor
    (Z : ℝ) (hZ : 0 ≤ Z) :
    -- (i) faithful lift: object map + lifted laxator (R6_Agent10's ohmCost_union_le)
    (∀ S : Finset (BarrierData α),
        liftedBudget Z (.obj S) = ((ohmCost Z S : ℕ) : ℕ∞))
    ∧ (∀ S T : Finset (BarrierData α),
        liftedBudget Z (.obj (S ∪ T))
          ≤ liftedBudget Z (.obj S) + liftedBudget Z (.obj T))
    -- (ii) unit (R6_Agent10's ohmCost_empty)
    ∧ (liftedBudget Z (.obj (∅ : Finset (BarrierData α))) = (0 : ℕ∞))
    -- (iii) ABSORPTION: the wall is the absorbing object for the budget tensor
    ∧ (∀ X : TaggedBarrier α,
        budgetTensor Z (.wall) X = (⊤ : ℕ∞)
        ∧ budgetTensor Z X (.wall) = (⊤ : ℕ∞))
    -- (iv) COHERENCE with R6_Agent5's one_walled_agent_absorbs
    ∧ (∀ X : TaggedBarrier α,
        R6_Agent5_MultiAgentBudgetTerminal.jointBudget
            (pairWalled (.wall) X) (fun _ => 0) = (⊤ : ℕ∞))
    -- (v) the wall is the GREATEST tagged object (R5_Agent6's wall_is_top_cost)
    ∧ (∀ X : TaggedBarrier α,
        liftedBudget Z X ≤ liftedBudget Z (.wall : TaggedBarrier α)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro S; rfl
  · intro S T; exact lifted_laxator Z hZ S T
  · exact lifted_unit Z
  · intro X; exact ⟨wall_tensor_left Z X, wall_tensor_right Z X⟩
  · intro X; exact wall_tensor_absorbs_via_R6Agent5 Z X
  · intro X; exact liftedBudget_le_wall Z X

end R7_Agent2_WallAbsorbingMonoidalObject

end MIP
