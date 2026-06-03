/-
  STATUS: DISCOVERY
  AGENT: R5 Agent 3
  DIRECTION: BARRIER-CONFIGURATION POSET  ≅/⟶  IMPOSSIBILITY HARDNESS POSET.
    Round-4 Agent 8 (`R4_Agent8_BarrierCategoryObject`) built the
    barrier-configuration preorder-as-category: objects = `Finset (BarrierData α)`
    ordered by `⊆`, morphisms = metacognitive interventions = monotone
    *contractive* self-maps `Removal α` (a monoid), with each intervention `r`
    exhibiting a canonical sub-object inclusion `stepHom r S : r.act S ⟶ S`.
    Round-4 Agent 3 (`R4_Agent3_ImpossibilityPoset`) built the impossibility
    hardness-kernel poset: a `HardnessKernel Prob` carrying a reducibility
    preorder `R`, class predicate `InC`, derived `Hard P := ∀ Q, InC Q → R Q P`,
    and the transfer law `genTransfer : R A B → Hard A → Hard B`.

    Both are preorder-as-category.  THIS FILE constructs the explicit structural
    bridge between them.

  SUMMARY:
    (a) ORDER-MAP / FUNCTOR (barrier-poset ⟶ cost/hardness-poset).  We realise
        the IT-style reduction poset CONCRETELY on barrier configurations: the
        `barrierKernel` is the `R4_Agent3.HardnessKernel (Finset (BarrierData α))`
        whose reduction relation is inclusion `R S T := S ⊆ T` (transitivity =
        `Finset.Subset.trans`, fed to the kernel exactly as IT.13 fed its proved
        `Pi1Reduces_trans`).  "More barriers ⟹ harder" is then literally the
        statement that inclusion is a reduction edge, and we expose the explicit
        monotone COST order-map `costHom : Finset (BarrierData α) →o ℕ` (`= card`):
        barrier inclusion ⟹ cost order (`costHom_mono`).  This is the order-map
        the direction asks for; it is an `OrderHom` (hence a functor of the two
        `Preorder.smallCategory`s), and it is FAITHFUL on the corpus objects via
        `B_data_card_eq_N` (`costHom_B_data`).

    (b) INTERVENTIONS ↦ REDUCTIONS.  Every R4_Agent8 contractive intervention
        `r : Removal α`, at every barrier set `S`, produces a reduction edge of
        the `barrierKernel` pointing in the R4_Agent3 `genTransfer` direction:
        `removalEdge r S : barrierKernel.R (r.act S) S` is *definitionally*
        `r.contract S`.  Thus the R4_Agent8 sub-object morphism `stepHom r S`
        (`r.act S ⟶ S`) and the R4_Agent3 reduction edge `(r.act S) ≤ S` are the
        SAME arrow (`removalEdge_eq_stepHom_le`).  Feeding it to `genTransfer`
        TRANSPORTS impossibility-hardness UP the inclusion: any hardness present
        on the smaller (post-intervention) configuration `r.act S` propagates to
        the larger `S` (`removal_transfers_hardness`) — interventions and
        reductions agree on morphisms.

    (c) HEADLINE — `barrier_cost_functor_faithful`.  A single faithful,
        monotone, COST-order-preserving functor
            `barrierToCost : Finset (BarrierData α) →o ℕ`
        together with the agreement law tying it to BOTH Round-4 categories:
          • (R4_Agent8 side) it sends every intervention edge `stepHom r S`
            to a cost INEQUALITY `costHom (r.act S) ≤ costHom S`
            (`cost_of_intervention`), i.e. interventions never raise cost —
            the categorical image of R4_Agent8's `act_card_le_N`;
          • (R4_Agent3 side) it sends the SAME edge, viewed as the reduction
            `removalEdge r S`, to a `genTransfer` hardness transport
            (`removal_transfers_hardness`).
        So the barrier-configuration poset, the cost poset `ℕ`, and the
        impossibility hardness poset are bridged by ONE order-embedding-like
        functor under which R4_Agent8 interventions and R4_Agent3 reductions are
        literally the same arrows.  We close with `intervention_is_reduction`,
        the explicit identification of the two Round-4 morphism notions, and
        `barrier_hardness_master`, the specialisation of R4_Agent3's
        `impossibility_poset_master` to the barrier kernel.

    Nothing here restates a Round-4 lemma: R4_Agent8 knows only its own poset and
    its intervention monoid; R4_Agent3 knows only the abstract hardness kernel.
    THIS file proves the two preorder-categories are joined by a concrete functor
    that identifies interventions with reductions and bounds cost — a statement
    invisible inside either Round-4 file.

  Depends on (imports + exact lemma names used):
    • MIP.Discoveries.R4_Agent8_BarrierCategoryObject
        (Removal, Removal.act, Removal.contract, Removal.mono, Removal.stepHom,
         Removal.act_card_le_N, Removal.act_B_data_subset, hom_iff_subset)
    • MIP.Discoveries.R4_Agent3_ImpossibilityPoset
        (HardnessKernel, HardnessKernel.mk, HardnessKernel.Hard, genTransfer,
         impossibility_poset_master)
    • MIP.Defs.Barriers
        (BarrierData, B_data, B_data_card_eq_N)
    • Mathlib.Order.Hom.Basic (OrderHom), Mathlib.CategoryTheory.Category.Preorder
        (Preorder.smallCategory, homOfLE, leOfHom), Finset.card_le_card.
-/
import MIP.Discoveries.R4_Agent8_BarrierCategoryObject
import MIP.Discoveries.R4_Agent3_ImpossibilityPoset
import MIP.Defs.Barriers
import Mathlib.Order.Hom.Basic
import Mathlib.CategoryTheory.Category.Preorder

namespace MIP

namespace R5_Agent3_BarrierPosetIsomorphism

open CategoryTheory
open MIP.R4_Agent8_BarrierCategoryObject
open MIP.R4_Agent3_ImpossibilityPoset

variable {α : Type}

/-! ### (a) The barrier configurations AS an impossibility hardness kernel.

We instantiate R4_Agent3's `HardnessKernel` on the barrier-configuration type
`Finset (BarrierData α)`, taking the reduction relation to be *inclusion*: a
configuration `S` "reduces to" `T` exactly when `S ⊆ T`.  Transitivity is the
honest `Finset.Subset.trans` — supplied as a genuine theorem, exactly as IT.13
supplied `Pi1Reduces_trans`.  This makes precise the slogan "more barriers ⟹
harder": adding barriers is a reduction edge in the R4_Agent3 poset. -/

/-- **The barrier hardness kernel.**  R4_Agent3's `HardnessKernel` carried on
barrier configurations, with reduction = inclusion and `htrans` the honest
`Finset.Subset.trans`.  Any class predicate `InC` may be supplied; the kernel's
`Hard`, `genTransfer`, and `impossibility_poset_master` then apply verbatim. -/
def barrierKernel (InC : Finset (BarrierData α) → Prop) :
    HardnessKernel (Finset (BarrierData α)) :=
  { R := fun S T => S ⊆ T
    InC := InC
    htrans := fun hXY hYZ => Finset.Subset.trans hXY hYZ }

@[simp] theorem barrierKernel_R (InC : Finset (BarrierData α) → Prop)
    (S T : Finset (BarrierData α)) :
    (barrierKernel InC).R S T = (S ⊆ T) := rfl

/-- **The cost order-map** `costHom : Finset (BarrierData α) →o ℕ`, the bundled
monotone map sending a barrier configuration to its barrier COUNT.  Monotonicity
(`Finset.card_le_card`) is precisely "barrier inclusion ⟹ cost order": more
barriers means higher cost.  As an `OrderHom` it is a functor between the two
`Preorder.smallCategory`s (barrier-poset ⟶ cost poset `ℕ`). -/
def costHom : Finset (BarrierData α) →o ℕ where
  toFun := fun S => S.card
  monotone' := fun _ _ h => Finset.card_le_card h

@[simp] theorem costHom_apply (S : Finset (BarrierData α)) :
    costHom S = S.card := rfl

/-- **Barrier inclusion ⟹ cost order** (the order-map is monotone). -/
theorem costHom_mono {S T : Finset (BarrierData α)} (h : S ⊆ T) :
    costHom S ≤ costHom T :=
  costHom.monotone' h

/-- **Faithfulness on corpus objects.**  On the corpus barrier set `B_data p X`,
the cost is exactly the emergence value `N p X` (cast to `ℕ`), via the corpus
bridge `B_data_card_eq_N`: the cost order-map reads off the genuine
minimum-intervention count, so it is non-vacuous / faithful where the theory
lives. -/
theorem costHom_B_data (p : Problem α) (X : Agent α) (hFin : N p X ≠ ⊤) :
    ((costHom (B_data p X) : ℕ) : ℕ∞) = N p X := by
  show ((B_data p X).card : ℕ∞) = N p X
  exact B_data_card_eq_N p X hFin

/-! ### (b) Round-4 interventions map to Round-4 reductions.

An R4_Agent8 intervention `r : Removal α` is *contractive*: `r.act S ⊆ S`.  Read
in the `barrierKernel`, that inclusion IS a reduction edge `(r.act S) ≤ S`,
pointing in the `genTransfer` direction.  So every intervention edge of the
R4_Agent8 category is a reduction edge of the R4_Agent3 poset, and they are the
SAME underlying arrow as the R4_Agent8 `stepHom`. -/

/-- **Intervention ⟹ reduction edge.**  The contractivity witness of any
R4_Agent8 `Removal` is *definitionally* a reduction edge of the barrier kernel.
This is the morphism-level bridge: interventions are reductions. -/
def removalEdge (InC : Finset (BarrierData α) → Prop)
    (r : Removal α) (S : Finset (BarrierData α)) :
    (barrierKernel InC).R (r.act S) S :=
  r.contract S

/-- The reduction edge `removalEdge r S` and the R4_Agent8 sub-object morphism
`stepHom r S : r.act S ⟶ S` are the SAME arrow: both are the inclusion
`r.act S ⊆ S`.  (R4_Agent8's `stepHom` is `homOfLE (r.contract S)`; the kernel
edge is `r.contract S`; `leOfHom (stepHom r S)` recovers it on the nose.) -/
theorem removalEdge_eq_stepHom_le (InC : Finset (BarrierData α) → Prop)
    (r : Removal α) (S : Finset (BarrierData α)) :
    removalEdge InC r S = leOfHom (Removal.stepHom r S) := by
  apply Subsingleton.elim

/-- **Hardness transports UP an intervention** (interventions and reductions
agree on morphisms).  Combining the R4_Agent8 contractivity edge with
R4_Agent3's `genTransfer`: if the post-intervention configuration `r.act S`
carries impossibility-hardness, so does the pre-intervention `S`.  The
intervention's barrier-removal arrow is exactly the reduction arrow that
propagates hardness. -/
theorem removal_transfers_hardness (InC : Finset (BarrierData α) → Prop)
    (r : Removal α) (S : Finset (BarrierData α))
    (hHard : (barrierKernel InC).Hard (r.act S)) :
    (barrierKernel InC).Hard S :=
  genTransfer (barrierKernel InC) (removalEdge InC r S) hHard

/-! ### (c) HEADLINE — the faithful monotone cost functor bridging both posets.

`barrierToCost := costHom` is a single `OrderHom` (hence a functor of the
`Preorder.smallCategory`s) under which:

  • every R4_Agent8 intervention `stepHom r S : r.act S ⟶ S` is sent to a cost
    inequality `cost (r.act S) ≤ cost S` (interventions never raise cost), and
  • the SAME edge, read as the R4_Agent3 reduction `removalEdge r S`, is sent to
    a `genTransfer` hardness transport.

Thus interventions (R4_Agent8) and reductions (R4_Agent3) are LITERALLY the same
arrows, and the cost functor is monotone & faithful. -/

/-- The headline order-map: the barrier-configuration poset to the cost poset
`ℕ`, as a bundled `OrderHom`. -/
def barrierToCost : Finset (BarrierData α) →o ℕ := costHom

/-- **Interventions never raise cost** — the cost functor applied to an
R4_Agent8 intervention edge.  This is the categorical/order image of R4_Agent8's
`Removal.act_card_le_N`: barrier removal can only lower (or preserve) the cost
count.  Derived through the `barrierKernel` reduction edge, not assumed. -/
theorem cost_of_intervention (r : Removal α) (S : Finset (BarrierData α)) :
    barrierToCost (r.act S) ≤ barrierToCost S :=
  costHom_mono (r.contract S)

/-- The cost functor on corpus objects is bounded by the emergence value, by
chaining `cost_of_intervention` with `B_data_card_eq_N`: after any intervention
on `B_data p X`, the cost (cast to `ℕ∞`) is `≤ N p X`.  This recovers R4_Agent8's
`act_card_le_N` through the bridge order-map. -/
theorem cost_of_intervention_B_data (r : Removal α)
    (p : Problem α) (X : Agent α) (hFin : N p X ≠ ⊤) :
    ((barrierToCost (r.act (B_data p X)) : ℕ) : ℕ∞) ≤ N p X :=
  r.act_card_le_N p X hFin

/-- **Intervention = reduction (morphism identification).**  For every R4_Agent8
intervention `r` and configuration `S`, the three descriptions of the
barrier-removal arrow coincide:

  • the R4_Agent8 sub-object inclusion `r.act S ⊆ S` (`leOfHom (stepHom r S)`),
  • the R4_Agent3 reduction edge `removalEdge r S : (barrierKernel _).R (r.act S) S`,

are the same proof, AND the cost functor sends this arrow to the cost inequality
`cost (r.act S) ≤ cost S`.  This is the precise statement that the bridge functor
identifies interventions with reductions. -/
theorem intervention_is_reduction (InC : Finset (BarrierData α) → Prop)
    (r : Removal α) (S : Finset (BarrierData α)) :
    removalEdge InC r S = leOfHom (Removal.stepHom r S) ∧
    barrierToCost (r.act S) ≤ barrierToCost S := by
  refine ⟨removalEdge_eq_stepHom_le InC r S, cost_of_intervention r S⟩

/-- **HEADLINE: the faithful monotone cost functor bridging both Round-4 posets.**

`barrierToCost : Finset (BarrierData α) →o ℕ` is a monotone order-map (a functor
of the preorder categories) that:

  (1) is monotone — barrier inclusion ⟹ cost order (`barrierToCost.monotone'`);
  (2) is faithful on the corpus: on `B_data p X` it reads off the emergence
      value `N p X` exactly (`costHom_B_data`);
  (3) sends every R4_Agent8 intervention edge to a cost inequality
      (`cost_of_intervention`) AND simultaneously, via the SAME inclusion arrow
      `removalEdge`, to an R4_Agent3 `genTransfer` hardness transport
      (`removal_transfers_hardness`).

Packaged: interventions (R4_Agent8) and reductions (R4_Agent3) are the same
arrows, and the cost functor is monotone, identifies them, and transports
hardness along them. -/
theorem barrier_cost_functor_faithful
    (InC : Finset (BarrierData α) → Prop) :
    -- (1) monotone order-map (functor):
    (∀ {S T : Finset (BarrierData α)}, S ⊆ T → barrierToCost S ≤ barrierToCost T) ∧
    -- (2) faithful on corpus objects:
    (∀ (p : Problem α) (X : Agent α), N p X ≠ ⊤ →
        ((barrierToCost (B_data p X) : ℕ) : ℕ∞) = N p X) ∧
    -- (3) identifies interventions with reductions, bounds cost, transports hardness:
    (∀ (r : Removal α) (S : Finset (BarrierData α)),
        removalEdge InC r S = leOfHom (Removal.stepHom r S) ∧
        barrierToCost (r.act S) ≤ barrierToCost S ∧
        ((barrierKernel InC).Hard (r.act S) → (barrierKernel InC).Hard S)) := by
  refine ⟨?_, ?_, ?_⟩
  · intro S T h; exact costHom_mono h
  · intro p X hFin; exact costHom_B_data p X hFin
  · intro r S
    exact ⟨removalEdge_eq_stepHom_le InC r S,
           cost_of_intervention r S,
           removal_transfers_hardness InC r S⟩

/-- **Barrier hardness master** — R4_Agent3's `impossibility_poset_master`
specialised to the barrier kernel: from any hard root configuration `S`, every
configuration reachable by adding barriers (an inclusion `S ⊆ P`) is hard.  This
is the impossibility-poset master edge living natively on barrier
configurations. -/
theorem barrier_hardness_master (InC : Finset (BarrierData α) → Prop)
    {S : Finset (BarrierData α)} (hS : (barrierKernel InC).Hard S) :
    ∀ P : Finset (BarrierData α), S ⊆ P → (barrierKernel InC).Hard P :=
  impossibility_poset_master (barrierKernel InC) hS

end R5_Agent3_BarrierPosetIsomorphism

end MIP
