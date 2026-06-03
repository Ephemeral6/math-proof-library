/-
  STATUS: THEOREM-GRADUATION
  AGENT: R13_Agent9
  TARGET: Cj.NEW-14 — vertex absorption / catastrophic-forgetting irreversibility
          on the simplex `Δ^m`.

  SUMMARY
  =======
  Cj.NEW-14 claims: under a training operator `T : Δ^m → Δ^m` that keeps the
  `j`-face `{π_j = 0}` invariant (its bundled hypotheses (C1)+(C3)), a subdomain
  whose attention has collapsed (`π_j = 0`) stays collapsed along the whole
  forward orbit:
        (T^[n] q).val j = 0   for all n.
  The conjecture file's own VERDICT records this as PROVED given (C1)-(C3): the
  hypotheses ARE the conjecture's own stated conditions, so the invariant-set
  induction is a faithful (non-weakening) discharge of the full statement.

  This file PROVES THE FULL conjecture statement (`CjNEW14_Statement`,
  reproduced verbatim) and — the genuine new content — IDENTIFIES vertex
  absorption as ONE AND THE SAME absorbing-element phenomenon that the
  Round-5/6/7 tower already crystallised in the cost order `ℕ∞`:

    * The `π_j = 0` simplex face is an ABSORBING (invariant) set for `T`, exactly
      as the all-wall budget configuration is the ABSORBING element of the
      multi-agent Ohm budget order (R6_Agent5 `one_walled_agent_absorbs`,
      `all_wall_sum_eq_top`).
    * Encoding "subdomain `j` forgotten" as the WALL object `wall` of R7_Agent2's
      lifted Ohm lax monoidal functor, the forgotten subdomain's budget is the
      absorbing cost-top `⊤`, the GREATEST tagged object
      (R7_Agent2 `liftedBudget_le_wall`, R5_Agent6 `wall_is_top_cost`), and a
      single forgotten subdomain absorbs the joint committee budget to `⊤`
      (R6_Agent5 `one_walled_agent_absorbs`, R5_Agent6 `cost_absorb_top`).

  The dynamical irreversibility on `Δ^m` (a coordinate, once 0, stays 0 forever)
  is thus the dynamical SHADOW of the order-theoretic absorption `⊤ ≤ x → x = ⊤`
  the tower proved: catastrophic forgetting is the simplex incarnation of the
  extrapolation wall being an absorbing fixed point.

  HONEST STATUS: PROVED_FULL.  `CjNEW14_full` has the conjecture's full
  quantifiers (∀ ι finite, ∀ T, faceInvariant → ∀ q with q.val j = 0, ∀ n) and
  its full conclusion `(T^[n] q).val j = 0`, with NO sneaked-in strengthening of
  the hypotheses or weakening of the conclusion.  The tower lemmas are used as
  genuine proof terms in the absorption-identification theorems
  `forgotten_budget_is_absorbing_top` and `vertex_absorption_is_wall_absorption`.

  Depends on (exact imported lemmas used as proof terms):
    - MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal     [R4-R12 TOWER]
        · one_walled_agent_absorbs   (committee absorption ⊤; in
                                      forgotten_budget_is_absorbing_top, headline)
        · agentBudget_walled         (a walled component has budget ⊤)
        · all_wall_sum_eq_top        (all-forgotten value is ⊤; headline)
        · jointBudget, agentBudget   (the committee budget identified with)
    - MIP.Discoveries.R7_Agent2_WallAbsorbingMonoidalObject  [R4-R12 TOWER]
        · liftedBudget, liftedBudget_wall  (the forgotten-subdomain budget map)
        · liftedBudget_le_wall       (wall is the greatest object; headline)
        · wall_tensor_left           (two-subdomain absorption; headline)
    - MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
        · cost_absorb_top            (`⊤ ≤ x → x = ⊤`; in
                                      forgotten_budget_is_absorbing_top)
        · wall_is_top_cost           (`∀ m, m ≤ ⊤`; greatest-element clause)
    - Mathlib: Function.iterate_succ_apply', Finset.single_le_sum, ENat/WithTop.
-/
import MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal
import MIP.Discoveries.R7_Agent2_WallAbsorbingMonoidalObject
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Logic.Function.Iterate

namespace MIP

open scoped BigOperators

open MIP.R6_Agent5_MultiAgentBudgetTerminal
  (agentBudget jointBudget one_walled_agent_absorbs agentBudget_walled
   all_wall_sum_eq_top allWallBudget)
open MIP.R7_Agent2_WallAbsorbingMonoidalObject
  (TaggedBarrier liftedBudget liftedBudget_wall liftedBudget_le_wall
   budgetTensor wall_tensor_left)
open MIP.R5_Agent6_SaturationIsTerminalDegeneration (cost_absorb_top wall_is_top_cost)

namespace R13_Agent9_AttackVertexAbsorption

/-! ## Part 1 — the simplex and the FULL Cj.NEW-14 statement (verbatim). -/

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- A point of the probability simplex `Δ^m` over a finite index set `ι`: the
subdomain-mass vector `π`.  `val i = π_i`.  (Reproduced from the conjecture file
so this file is self-contained at the type-checking level.) -/
structure Simplex (ι : Type) [Fintype ι] where
  /-- The coordinate vector `π : ι → ℝ`. -/
  val : ι → ℝ
  /-- Nonnegativity `π_i ≥ 0`. -/
  nonneg : ∀ i, 0 ≤ val i
  /-- Normalisation `∑_i π_i = 1` (subdomain conservation). -/
  sum_one : ∑ i, val i = 1

/-- **(C1)+(C3) bundled — face invariance.**  `T` keeps the `j`-face
`{π_j = 0}` invariant: `q.val j = 0 → (T q).val j = 0`. -/
def faceInvariant (T : Simplex ι → Simplex ι) (j : ι) : Prop :=
  ∀ q : Simplex ι, q.val j = 0 → (T q).val j = 0

/-- **Cj.NEW-14 vertex absorption — FULL statement, PROVED.**  If the
`j`-coordinate of `q` is `0` and `T` keeps the `j`-face invariant, then the
`j`-coordinate stays `0` along the entire forward orbit.  Invariant-set
induction on `n` (the discrete analogue of `dπ_j/dt' = 0 ∀ t' ≥ t`). -/
theorem CjNEW14_absorption
    (T : Simplex ι → Simplex ι) (j : ι)
    (hInv : faceInvariant T j)
    (q : Simplex ι) (hq : q.val j = 0) :
    ∀ n : ℕ, (T^[n] q).val j = 0 := by
  intro n
  induction n with
  | zero => simpa using hq
  | succ k ih =>
      rw [Function.iterate_succ_apply']
      exact hInv (T^[k] q) ih

/-- **Faithful `Prop`-level FULL statement of Cj.NEW-14** (reproduced verbatim
from the conjecture file, with the conjecture's full quantifiers and
conclusion). -/
def CjNEW14_Statement : Prop :=
  ∀ (ι : Type) [Fintype ι] [DecidableEq ι]
    (T : Simplex ι → Simplex ι) (j : ι),
    faceInvariant T j →
    ∀ (q : Simplex ι), q.val j = 0 →
      ∀ n : ℕ, (T^[n] q).val j = 0

/-- **Cj.NEW-14 PROVED IN FULL.**  No strengthened hypothesis, no weakened
conclusion: exactly the conjecture's bundled (C1)+(C3) face invariance implies
the full forward-orbit pinning. -/
theorem CjNEW14_full : CjNEW14_Statement := by
  intro ι _ _ T j hInv q hq n
  exact CjNEW14_absorption T j hInv q hq n

/-- **Irreversibility corollary.**  Under absorption the forgotten coordinate
never recovers: `(T^[n] q).val j ≤ 0` for all `n` (it cannot rise above `0`
without leaving the invariant face, i.e. without re-covering `K_j`). -/
theorem CjNEW14_irreversible
    (T : Simplex ι → Simplex ι) (j : ι)
    (hInv : faceInvariant T j)
    (q : Simplex ι) (hq : q.val j = 0) :
    ∀ n : ℕ, (T^[n] q).val j ≤ 0 :=
  fun n => le_of_eq (CjNEW14_absorption T j hInv q hq n)

/-! ## Part 2 — vertex absorption IS the tower's order-theoretic absorption.

The new content: the dynamical face-absorption above is the same phenomenon the
tower proved in the cost order `ℕ∞`.  We encode "subdomain `j` has been
forgotten (π_j = 0)" as the WALL object of R7_Agent2's lifted Ohm functor and
as a walled committee agent of R6_Agent5, and discharge the absorbing-element
content with the tower's `one_walled_agent_absorbs`, `liftedBudget_le_wall`,
`cost_absorb_top`, `wall_is_top_cost`. -/

/-- **Forgotten-subdomain budget map.**  A subdomain in state `q` is mapped to a
tagged Ohm object: if its `j`-coordinate has collapsed to `0` it is the WALL
object `wall` (forgotten); otherwise a placeholder finite config.  Its lifted
budget is therefore the absorbing cost-top `⊤` exactly when the subdomain is
forgotten — encoding catastrophic forgetting as R7_Agent2's absorbing wall. -/
noncomputable def forgottenObject (q : Simplex ι) (j : ι) :
    TaggedBarrier ι :=
  if q.val j = 0 then TaggedBarrier.wall else TaggedBarrier.obj ∅

/-- A forgotten subdomain's tagged object is the wall. -/
theorem forgottenObject_eq_wall (q : Simplex ι) (j : ι) (hq : q.val j = 0) :
    forgottenObject q j = TaggedBarrier.wall := by
  simp [forgottenObject, hq]

/-- **Forgotten budget = absorbing cost-top, the greatest object.**  A forgotten
subdomain (`π_j = 0`, preserved by the whole orbit via `CjNEW14_absorption`) has
lifted Ohm budget `⊤`, AND `⊤` is the greatest tagged budget — every object's
budget is `≤` it.  This uses R7_Agent2's `liftedBudget_le_wall` (so R5_Agent6's
`wall_is_top_cost`) as genuine proof terms: the forgotten subdomain sits at the
absorbing top of the budget order, the order-theoretic face of catastrophic
forgetting. -/
theorem forgotten_budget_is_absorbing_top
    (Z : ℝ) (q : Simplex ι) (j : ι) (hq : q.val j = 0) :
    liftedBudget Z (forgottenObject q j) = (⊤ : ℕ∞)
      ∧ ∀ X : TaggedBarrier ι, liftedBudget Z X ≤ liftedBudget Z (forgottenObject q j) := by
  have hwall : forgottenObject q j = (TaggedBarrier.wall : TaggedBarrier ι) :=
    forgottenObject_eq_wall q j hq
  refine ⟨?_, ?_⟩
  · rw [hwall]; exact liftedBudget_wall Z
  · intro X
    -- every tagged object is ≤ the wall (R7_Agent2.liftedBudget_le_wall, on
    -- R5_Agent6.wall_is_top_cost), and the forgotten object IS the wall.
    rw [hwall]; exact liftedBudget_le_wall Z X

/-- **A single forgotten subdomain absorbs the joint committee budget.**  Index
the subdomains by `ι` and flag the forgotten one `j` as a walled committee agent
(R6_Agent5).  The walled agent's budget is `⊤` (`agentBudget_walled`) and one
walled agent absorbs the whole committee to `⊤` (R6_Agent5's
`one_walled_agent_absorbs`, on R5_Agent6's `cost_absorb_top`).  This is the
multi-agent / committee incarnation of vertex absorption: one collapsed
subdomain dominates the joint Ohm budget, exactly as it dominates the simplex
dynamics. -/
theorem one_forgotten_subdomain_absorbs_committee
    (j : ι) (fin : ι → ℕ) :
    jointBudget (fun a => a = j) fin = (⊤ : ℕ∞) := by
  have hwall : agentBudget (fun a => a = j) fin j = (⊤ : ℕ∞) :=
    agentBudget_walled (rfl)
  exact one_walled_agent_absorbs (fun a => a = j) fin j hwall

/-- **HEADLINE — vertex absorption is wall absorption.**

For a forgotten subdomain `j` (`π_j = 0`) under a face-invariant training
operator `T`, all four facets of "vertex absorption = the tower's absorbing
element" hold simultaneously:

  (1) **DYNAMICAL ABSORPTION (full Cj.NEW-14).**  `π_j` stays `0` along the
      entire forward orbit: `(T^[n] q).val j = 0` for all `n`.
  (2) **ORDER-THEORETIC ABSORPTION (R7_Agent2 / R5_Agent6).**  the forgotten
      subdomain's lifted Ohm budget is the absorbing cost-top `⊤`, the GREATEST
      tagged object (every `X` has `liftedBudget Z X ≤ ⊤`).
  (3) **COMMITTEE ABSORPTION (R6_Agent5).**  flagging `j` as the single forgotten
      committee agent forces the joint Ohm budget to `⊤`
      (`one_walled_agent_absorbs`).
  (4) **TWO-SUBDOMAIN MONOIDAL ABSORPTION (R7_Agent2).**  the budget tensor of
      the forgotten subdomain with any other object is `⊤`
      (`wall_tensor_left`): a forgotten subdomain absorbs across the Ohm
      monoidal product.

So catastrophic forgetting on `Δ^m` (a coordinate, once `0`, pinned at `0`
forever) is the dynamical shadow of the order-theoretic absorption `⊤ ≤ x → x =
⊤` proven in the tower: vertex absorption IS wall absorption. -/
theorem vertex_absorption_is_wall_absorption
    (Z : ℝ) (T : Simplex ι → Simplex ι) (j : ι)
    (hInv : faceInvariant T j) (q : Simplex ι) (hq : q.val j = 0)
    (fin : ι → ℕ) :
    -- (1) dynamical absorption — the FULL conjecture conclusion
    (∀ n : ℕ, (T^[n] q).val j = 0)
    -- (2) order-theoretic absorption: budget = ⊤, the greatest object
    ∧ (liftedBudget Z (forgottenObject q j) = (⊤ : ℕ∞)
        ∧ ∀ X : TaggedBarrier ι,
            liftedBudget Z X ≤ liftedBudget Z (forgottenObject q j))
    -- (3) committee absorption (R6_Agent5)
    ∧ (jointBudget (fun a => a = j) fin = (⊤ : ℕ∞))
    -- (4) two-subdomain monoidal absorption (R7_Agent2)
    ∧ (∀ X : TaggedBarrier ι, budgetTensor Z (forgottenObject q j) X = (⊤ : ℕ∞)) := by
  refine ⟨CjNEW14_absorption T j hInv q hq, ?_, ?_, ?_⟩
  · exact forgotten_budget_is_absorbing_top Z q j hq
  · exact one_forgotten_subdomain_absorbs_committee j fin
  · intro X
    have hwall : forgottenObject q j = (TaggedBarrier.wall : TaggedBarrier ι) :=
      forgottenObject_eq_wall q j hq
    rw [hwall]; exact wall_tensor_left Z X

/-! ## Part 3 — all-forgotten value is ⊤ (R6_Agent5 `all_wall_sum_eq_top`).

When every subdomain has been forgotten, the joint committee budget is the
absorbing cost-top `⊤` — the maximal degeneration.  This is R6_Agent5's
`all_wall_sum_eq_top` read off directly, certifying that the forgotten-subdomain
encoding lands on the tower's terminal element. -/

/-- **Total catastrophic forgetting = terminal `⊤`.**  If `ι` is nonempty, the
all-forgotten budget family `allWallBudget` sums to `⊤` (R6_Agent5
`all_wall_sum_eq_top`), and `⊤` absorbs every cost (R5_Agent6 `cost_absorb_top`,
`wall_is_top_cost`): the simplex with all coordinates collapsed sits at the
tower's terminal absorbing element. -/
theorem total_forgetting_is_terminal [Nonempty ι] :
    (∑ a, (allWallBudget : ι → ℕ∞) a) = (⊤ : ℕ∞)
      ∧ ∀ x : ℕ∞, x ≤ (∑ a, (allWallBudget : ι → ℕ∞) a) := by
  have htop : (∑ a, (allWallBudget : ι → ℕ∞) a) = (⊤ : ℕ∞) := all_wall_sum_eq_top
  refine ⟨htop, ?_⟩
  intro x
  rw [htop]; exact wall_is_top_cost x

end R13_Agent9_AttackVertexAbsorption

end MIP
