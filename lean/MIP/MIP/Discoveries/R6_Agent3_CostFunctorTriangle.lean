/-
  STATUS: DISCOVERY
  AGENT: R6_Agent3
  DIRECTION: COMMUTING TRIANGLE OF COST FUNCTORS ON THE BARRIER CATEGORY.
    Round-5 Agent 3 (`R5_Agent3_BarrierPosetIsomorphism`) built the
    barrier ⟶ hardness/cost functor: the monotone order-map
    `barrierToCost : Finset (BarrierData α) →o ℕ`, definitionally `= card`,
    sending every R4_Agent8 intervention edge to a cost inequality
    (`cost_of_intervention`) and identifying interventions with reductions
    (`removalEdge_eq_stepHom_le`, `intervention_is_reduction`).
    Round-5 Agent 10 (`R5_Agent10_OhmBudgetContravariantFunctor`) built the
    Ohm-budget (contravariant on removals) functor with object map
    `ohmCost Z S = ⌈Z·|S|⌉₊` and its order-reversal
    `ohmCost_removal_antitone`, packaged as `ohmBudgetFunctor`.

    BOTH functors factor through the barrier CARDINALITY `card`.  THIS file
    proves they form a COMMUTING TRIANGLE: the Ohm-budget functor factors
    through the cardinality/hardness functor of R5_Agent3 via the monotone
    "ceiling-budget" map `ceilZ : n ↦ ⌈Z·n⌉₊`.

  SUMMARY:
    (a) FACTORISATION OF OBJECT MAPS.  We bundle the per-count ceiling budget
        `ceilZ Z : ℕ →o ℕ`, `n ↦ ⌈Z·n⌉₊` (monotone by `Nat.ceil_mono` and
        `mul_le_mul_of_nonneg_left`), and prove
            `ohmCost Z S = (ceilZ Z) (barrierToCost S)`
        on the nose (`ohmCost_factors_pointwise`), hence as bundled `OrderHom`s
            `ohmCostHom Z hZ = (ceilZ Z hZ).comp barrierToCost`
        (`ohmCostHom_eq_comp`) — the TRIANGLE
            barrier  --barrierToCost-->  ℕ(card)  --ceilZ-->  ℕ(budget)
        commutes, the long edge being `ohmCostHom`.

    (b) FACTORISATION ON MORPHISMS.  R5_Agent3 and R5_Agent10 share the SAME
        removal morphisms (R4_Agent8 `stepHom`).  We prove the two functors
        agree up to postcomposition by `ceilZ`: the Ohm-budget inequality on a
        removal is the image under `ceilZ` of the cardinality inequality
            `ohmCost Z (r.act S) = ceilZ Z (barrierToCost (r.act S))
                                 ≤ ceilZ Z (barrierToCost S) = ohmCost Z S`
        with the middle step `ceilZ`-monotone applied to R5_Agent3's
        `cost_of_intervention` (`ohm_removal_factors_through_cost`).  Thus the
        whole order-reversal of R5_Agent10's functor on removals is
        `ceilZ`-postcomposed R5_Agent3 cardinality descent — a natural
        factorisation between the two functors on the shared morphisms
        (`removalEdge_eq_stepHom_le` ties the arrow to R5_Agent3's reduction).

    (c) HEADLINE — `ohm_budget_functor_factors_through_cardinality`.  The
        Ohm-budget functor factors through the barrier-cardinality/hardness
        functor: there is a monotone postcomposition `ceilZ Z` with
            `ohmCostHom Z hZ = ceilZ Z hZ ∘ barrierToCost`   (OrderHom eq),
            `ohmBudgetFunctor Z hZ = barrierFunctor ⋙ ceilZFunctor Z hZ`
                                                       (functor eq, on objects),
        and on every shared removal morphism the Ohm descent is the
        `ceilZ`-image of the cardinality descent.  A concrete commuting triangle
        of cost functors chaining R5_Agent3 + R5_Agent10.

  Depends on (imports + exact lemma names used):
    • MIP.Discoveries.R5_Agent3_BarrierPosetIsomorphism
        (barrierToCost, costHom_apply, costHom_mono, cost_of_intervention,
         removalEdge, removalEdge_eq_stepHom_le, barrierKernel)
    • MIP.Discoveries.R5_Agent10_OhmBudgetContravariantFunctor
        (ohmCost, ohmCost_def, ohmCostHom, ohmCostHom_apply, ohmCost_mono,
         ohmCost_removal_antitone, ohmBudgetFunctor, ohmBudgetFunctor_obj)
    • MIP.Discoveries.R4_Agent8_BarrierCategoryObject
        (Removal, Removal.act, Removal.stepHom)
    • Mathlib: OrderHom, OrderHom.comp, Nat.ceil_mono, Monotone.functor,
      Functor composition (⋙), Preorder.smallCategory.
-/
import MIP.Discoveries.R5_Agent3_BarrierPosetIsomorphism
import MIP.Discoveries.R5_Agent10_OhmBudgetContravariantFunctor
import MIP.Discoveries.R4_Agent8_BarrierCategoryObject
import Mathlib.Order.Hom.Basic
import Mathlib.CategoryTheory.Category.Preorder

namespace MIP

namespace R6_Agent3_CostFunctorTriangle

open CategoryTheory
open MIP.R4_Agent8_BarrierCategoryObject
open MIP.R5_Agent3_BarrierPosetIsomorphism
open MIP.R5_Agent10_OhmBudgetContravariantFunctor

variable {α : Type}

/-! ### (a) The per-count ceiling-budget map `ceilZ : ℕ →o ℕ`

The postcomposition factor of the triangle: a barrier COUNT `n : ℕ` is mapped
to its R5_Agent10 ceiling budget `⌈Z·n⌉₊`.  This is exactly the R5_Agent10
cost map "with the cardinality already taken", so composing it after
R5_Agent3's `barrierToCost = card` reproduces `ohmCost`. -/

/-- **The ceiling-budget map** `n ↦ ⌈Z·n⌉₊` as a bundled `OrderHom ℕ ℕ`.
Monotone because `Z ≥ 0` makes `n ↦ Z·n` monotone and `Nat.ceil_mono` is
monotone — the SAME ceiling monotonicity used in R5_Agent10's `ohmCost_mono`,
here on the count axis. -/
noncomputable def ceilZ (Z : ℝ) (hZ : 0 ≤ Z) : ℕ →o ℕ where
  toFun := fun n => ⌈Z * (n : ℝ)⌉₊
  monotone' := by
    intro m n hmn
    have hcast : (m : ℝ) ≤ (n : ℝ) := by exact_mod_cast hmn
    exact Nat.ceil_mono (mul_le_mul_of_nonneg_left hcast hZ)

@[simp] theorem ceilZ_apply (Z : ℝ) (hZ : 0 ≤ Z) (n : ℕ) :
    ceilZ Z hZ n = ⌈Z * (n : ℝ)⌉₊ := rfl

/-! ### (a) The triangle commutes on objects

`ohmCost Z S = ⌈Z·|S|⌉₊` and `barrierToCost S = |S|`, so
`ohmCost Z S = ceilZ Z (barrierToCost S)` — pointwise, then as bundled
`OrderHom`s. -/

/-- **Pointwise factorisation of the Ohm cost.**  The R5_Agent10 Ohm cost is
the R5_Agent3 cardinality cost postcomposed with the ceiling-budget map:
    `ohmCost Z S = ceilZ Z (barrierToCost S)`.
Both sides are `⌈Z·|S|⌉₊` (R5_Agent10 `ohmCost_def`; R5_Agent3
`barrierToCost = costHom = card`). -/
theorem ohmCost_factors_pointwise (Z : ℝ) (hZ : 0 ≤ Z)
    (S : Finset (BarrierData α)) :
    ohmCost Z S = ceilZ Z hZ (barrierToCost S) := by
  rw [ohmCost_def, ceilZ_apply]
  -- `barrierToCost S = costHom S = S.card`, so both sides are `⌈Z·|S|⌉₊`.
  have hcard : barrierToCost S = S.card := costHom_apply S
  rw [hcard]

/-- **The triangle commutes as bundled `OrderHom`s.**  The long edge
`ohmCostHom` equals the composite `ceilZ ∘ barrierToCost`:
    `ohmCostHom Z hZ = (ceilZ Z hZ).comp barrierToCost`.
This is the precise statement "the Ohm-budget order-map factors through the
barrier-cardinality order-map of R5_Agent3". -/
theorem ohmCostHom_eq_comp (Z : ℝ) (hZ : 0 ≤ Z) :
    ohmCostHom Z hZ = (ceilZ Z hZ).comp (barrierToCost (α := α)) := by
  ext S
  show ohmCost Z S = ceilZ Z hZ (barrierToCost S)
  exact ohmCost_factors_pointwise Z hZ S

/-! ### (b) The triangle commutes on morphisms (shared removal arrows)

R5_Agent3 and R5_Agent10 act on the SAME removal morphisms (R4_Agent8
`stepHom`).  R5_Agent3's `cost_of_intervention` gives the cardinality descent
`barrierToCost (r.act S) ≤ barrierToCost S`; postcomposing by the monotone
`ceilZ` yields R5_Agent10's Ohm descent `ohmCost_removal_antitone`. -/

/-- **The Ohm descent on a removal is the `ceilZ`-image of the cardinality
descent.**  For any R4_Agent8 intervention `r` and configuration `S`:
    `ohmCost Z (r.act S) = ceilZ Z (barrierToCost (r.act S))`
                         ≤ `ceilZ Z (barrierToCost S) = ohmCost Z S`,
where the inequality is `ceilZ`-monotonicity applied to R5_Agent3's
`cost_of_intervention`.  Thus R5_Agent10's order-reversal on removals factors
through R5_Agent3's cardinality order-reversal. -/
theorem ohm_removal_factors_through_cost (Z : ℝ) (hZ : 0 ≤ Z)
    (r : Removal α) (S : Finset (BarrierData α)) :
    ohmCost Z (r.act S) ≤ ohmCost Z S := by
  rw [ohmCost_factors_pointwise Z hZ (r.act S),
      ohmCost_factors_pointwise Z hZ S]
  exact (ceilZ Z hZ).monotone' (cost_of_intervention r S)

/-- **Consistency with R5_Agent10's native descent.**  The factored Ohm
descent on a removal coincides with R5_Agent10's `ohmCost_removal_antitone`
(both are propositions about the same `≤`; recorded for completeness, tying
our triangle factorisation to the original Round-5 lemma). -/
theorem ohm_removal_factors_eq_antitone (Z : ℝ) (hZ : 0 ≤ Z)
    (r : Removal α) (S : Finset (BarrierData α)) :
    ohm_removal_factors_through_cost Z hZ r S
      = ohmCost_removal_antitone Z hZ r S := by
  rfl

/-- **The shared removal arrow.**  The arrow underlying both functors' action
on a removal is R5_Agent3's reduction edge `removalEdge`, equal to R4_Agent8's
`stepHom` (R5_Agent3 `removalEdge_eq_stepHom_le`).  We re-export the
identification to certify that the morphism whose images we compared in
`ohm_removal_factors_through_cost` / `cost_of_intervention` is literally the
same arrow in both Round-5 functors. -/
theorem shared_removal_arrow (InC : Finset (BarrierData α) → Prop)
    (r : Removal α) (S : Finset (BarrierData α)) :
    removalEdge InC r S = leOfHom (Removal.stepHom r S) :=
  removalEdge_eq_stepHom_le InC r S

/-! ### (c) HEADLINE — the Ohm-budget functor factors through the
cardinality/hardness functor (commuting triangle of cost functors)

We realise both functors of the triangle as `Monotone.functor`s on the
`Preorder.smallCategory`s and prove the functor-level factorisation. -/

/-- The R5_Agent3 cardinality/hardness functor `barrier ⥤ ℕ` induced by
`barrierToCost`. -/
def barrierFunctor : Finset (BarrierData α) ⥤ ℕ :=
  (barrierToCost (α := α)).monotone'.functor

@[simp] theorem barrierFunctor_obj (S : Finset (BarrierData α)) :
    (barrierFunctor (α := α)).obj S = barrierToCost S := rfl

/-- The postcomposition ceiling-budget functor `ℕ ⥤ ℕ` induced by `ceilZ`. -/
noncomputable def ceilZFunctor (Z : ℝ) (hZ : 0 ≤ Z) : ℕ ⥤ ℕ :=
  (ceilZ Z hZ).monotone'.functor

@[simp] theorem ceilZFunctor_obj (Z : ℝ) (hZ : 0 ≤ Z) (n : ℕ) :
    (ceilZFunctor Z hZ).obj n = ceilZ Z hZ n := rfl

/-- **The functor triangle commutes on objects.**  The Ohm-budget functor of
R5_Agent10 equals the cardinality functor of R5_Agent3 followed by the
ceiling-budget functor:
    `(ohmBudgetFunctor Z hZ).obj S = (barrierFunctor ⋙ ceilZFunctor Z hZ).obj S`.
The object map of the long edge factors as `ceilZ ∘ barrierToCost`. -/
theorem ohmBudgetFunctor_obj_factors (Z : ℝ) (hZ : 0 ≤ Z)
    (S : Finset (BarrierData α)) :
    (ohmBudgetFunctor Z hZ).obj S
      = (barrierFunctor (α := α) ⋙ ceilZFunctor Z hZ).obj S := by
  show ohmCost Z S = ceilZ Z hZ (barrierToCost S)
  exact ohmCost_factors_pointwise Z hZ S

/-- **The functor triangle commutes on morphisms.**  In the thin target `(ℕ,≤)`
the two functors agree on every barrier morphism once they agree on objects;
combined with `ohmBudgetFunctor_obj_factors` this is the full functor
factorisation on morphisms. -/
theorem ohmBudgetFunctor_map_factors (Z : ℝ) (hZ : 0 ≤ Z)
    {S T : Finset (BarrierData α)} (f : S ⟶ T) :
    HEq ((ohmBudgetFunctor Z hZ).map f)
        ((barrierFunctor (α := α) ⋙ ceilZFunctor Z hZ).map f) := by
  apply Subsingleton.helim
  rw [ohmBudgetFunctor_obj_factors Z hZ, ohmBudgetFunctor_obj_factors Z hZ]

/-- **HEADLINE: the Ohm-budget functor factors through the barrier-cardinality /
hardness functor (commuting triangle of cost functors).**

Chaining R5_Agent3 (`barrierToCost = card`, `cost_of_intervention`) and
R5_Agent10 (`ohmCost = ⌈Z·|·|⌉₊`, `ohmBudgetFunctor`), with the monotone
postcomposition `ceilZ Z : n ↦ ⌈Z·n⌉₊`:

  (1) OBJECT-LEVEL `OrderHom` factorisation — the long edge equals the
      composite order-map:
        `ohmCostHom Z hZ = (ceilZ Z hZ).comp barrierToCost`;
  (2) OBJECT-LEVEL FUNCTOR factorisation — the Ohm-budget functor is the
      cardinality functor postcomposed with the ceiling-budget functor:
        `(ohmBudgetFunctor Z hZ).obj S
            = (barrierFunctor ⋙ ceilZFunctor Z hZ).obj S`;
  (3) MORPHISM-LEVEL factorisation — on every shared R4_Agent8 removal arrow
      the Ohm descent of R5_Agent10 is the `ceilZ`-image of the cardinality
      descent of R5_Agent3:
        `ohmCost Z (r.act S) ≤ ohmCost Z S`
      obtained by `ceilZ`-monotonicity from `cost_of_intervention`, and the
      arrow itself is R5_Agent3's `removalEdge = stepHom`.

The Ohm-budget functor therefore factors through the cardinality/hardness
functor: a concrete commuting triangle of cost functors on the barrier
category. -/
theorem ohm_budget_functor_factors_through_cardinality (Z : ℝ) (hZ : 0 ≤ Z) :
    -- (1) OrderHom factorisation of the long edge:
    ohmCostHom Z hZ = (ceilZ Z hZ).comp (barrierToCost (α := α)) ∧
    -- (2) functor factorisation on objects:
    (∀ S : Finset (BarrierData α),
        (ohmBudgetFunctor Z hZ).obj S
          = (barrierFunctor (α := α) ⋙ ceilZFunctor Z hZ).obj S) ∧
    -- (3) morphism factorisation on every shared removal arrow:
    (∀ (InC : Finset (BarrierData α) → Prop)
       (r : Removal α) (S : Finset (BarrierData α)),
        removalEdge InC r S = leOfHom (Removal.stepHom r S) ∧
        ohmCost Z (r.act S) ≤ ohmCost Z S ∧
        ohmCost Z (r.act S) = ceilZ Z hZ (barrierToCost (r.act S))) :=
  ⟨ohmCostHom_eq_comp Z hZ,
   fun S => ohmBudgetFunctor_obj_factors Z hZ S,
   fun InC r S =>
     ⟨removalEdge_eq_stepHom_le InC r S,
      ohm_removal_factors_through_cost Z hZ r S,
      ohmCost_factors_pointwise Z hZ (r.act S)⟩⟩

end R6_Agent3_CostFunctorTriangle

end MIP
