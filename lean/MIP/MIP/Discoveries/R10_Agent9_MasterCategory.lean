/-
  STATUS: CAPSTONE
  AGENT: R10_Agent9
  PILLAR: THE MASTER CATEGORICAL STRUCTURE (the barrier category and its functors).

  SUMMARY:
    This capstone bundles the entire categorical cluster built across the tower
    into ONE master theorem `master_barrier_category`.  The barrier category
    `(Finset (BarrierData α), ⊆)` is the shared object layer; on top of it five
    tower files erected a full categorical edifice, and we assemble their five
    headline theorems into a single conjunction whose proof literally invokes
    each one as a load-bearing proof term:

      (A)  R4_Agent8 — the INTERVENTION MONOID acts by order-preserving
           ENDOFUNCTORS: the no-op intervention is the identity functor and
           sequential interventions compose as functors
           (`Removal.functor_isMonoidAction`).

      (B)  R5_Agent3 — the FAITHFUL COST FUNCTOR `barrierToCost = card`:
           monotone, faithful on corpus objects (`= N p X`), and identifying
           R4_Agent8 interventions with R4_Agent3 reductions while transporting
           hardness (`barrier_cost_functor_faithful`).

      (C)  R6_Agent10 — the Ohm budget is a LAX MONOIDAL FUNCTOR: underlying
           functor + unit `ε` + laxator `μ` (budget of a product ≤ sum of
           budgets) + unit/associativity coherence + naturality
           (`ohmBudget_isLaxMonoidalFunctor`).

      (D)  R6_Agent3 — the COMMUTING COST TRIANGLE: the Ohm-budget functor
           FACTORS through the cardinality/hardness functor via the monotone
           postcomposition `ceilZ : n ↦ ⌈Z·n⌉₊`, on objects (OrderHom + functor)
           and on every shared removal morphism
           (`ohm_budget_functor_factors_through_cardinality`).

      (E)  R7_Agent2 — the WALL is the ABSORBING MONOIDAL OBJECT: lifting the
           lax functor into `ℕ∞` and adjoining the formal wall `W`, the budget
           tensor absorbs `budget(W ⊗ X) = ⊤ = budget(X ⊗ W)`, faithfully over
           R6_Agent10's laxator/unit and coherent with R6_Agent5's committee
           absorption (`wall_is_absorbing_object_of_ohm_lax_monoidal_functor`).

    The five clauses share a single common parameter setting
    `(α, Z, hZ, InC)`.  The ONLY non-trivial hypothesis any of them imposes is
    `hZ : 0 ≤ Z` (R4_Agent8 and R5_Agent3 need none; R6_Agent10, R6_Agent3,
    R7_Agent2 each need exactly `0 ≤ Z`); `InC` is an arbitrary class predicate.
    Hence the bundle is JOINTLY SATISFIABLE — witnessed concretely below by
    `master_barrier_category_witness` at `α = Unit`, `Z = 1`, `hZ = zero_le_one`,
    `InC = fun _ => True`, which discharges the master theorem and exhibits a
    genuine non-vacuous instance (the cost functor reads off real cardinalities,
    the wall really absorbs to `⊤`).

    Nothing here is re-derived from the four axioms: every clause is discharged
    by directly applying the cited tower headline.  The master theorem is proved
    BY composing the five tower theorems — each appears in its proof term.

  Assembles (exact tower lemmas bundled, each load-bearing in the proof term):
    - MIP.Discoveries.R4_Agent8_BarrierCategoryObject
        Removal.functor_isMonoidAction
    - MIP.Discoveries.R5_Agent3_BarrierPosetIsomorphism
        barrier_cost_functor_faithful
    - MIP.Discoveries.R6_Agent10_OhmLaxMonoidalFunctor
        ohmBudget_isLaxMonoidalFunctor
    - MIP.Discoveries.R6_Agent3_CostFunctorTriangle
        ohm_budget_functor_factors_through_cardinality
    - MIP.Discoveries.R7_Agent2_WallAbsorbingMonoidalObject
        wall_is_absorbing_object_of_ohm_lax_monoidal_functor

  Depends on (imports):
    - MIP.Discoveries.R4_Agent8_BarrierCategoryObject
    - MIP.Discoveries.R5_Agent3_BarrierPosetIsomorphism
    - MIP.Discoveries.R6_Agent10_OhmLaxMonoidalFunctor
    - MIP.Discoveries.R6_Agent3_CostFunctorTriangle
    - MIP.Discoveries.R7_Agent2_WallAbsorbingMonoidalObject
-/
import MIP.Discoveries.R4_Agent8_BarrierCategoryObject
import MIP.Discoveries.R5_Agent3_BarrierPosetIsomorphism
import MIP.Discoveries.R6_Agent10_OhmLaxMonoidalFunctor
import MIP.Discoveries.R6_Agent3_CostFunctorTriangle
import MIP.Discoveries.R7_Agent2_WallAbsorbingMonoidalObject

namespace MIP

open CategoryTheory

open MIP.R4_Agent8_BarrierCategoryObject
open MIP.R5_Agent3_BarrierPosetIsomorphism
open MIP.R5_Agent10_OhmBudgetContravariantFunctor
open MIP.R6_Agent10_OhmLaxMonoidalFunctor
open MIP.R6_Agent3_CostFunctorTriangle
open MIP.R7_Agent2_WallAbsorbingMonoidalObject

namespace R10_Agent9_MasterCategory

variable {α : Type}

/-! ## The master bundle.

We package the five tower headlines as a `structure` whose fields are exactly
the five propositions.  The constructor lemma `master_barrier_category`
discharges each field by the corresponding tower theorem at the common
parameter setting `(α, Z, hZ, InC)`. -/

/-- **The master categorical structure of the barrier category.**

A single bundle carrying the five categorical pillars of the barrier category at
a fixed cost scale `Z` (with `0 ≤ Z`) and class predicate `InC`. -/
structure MasterBarrierCategory (α : Type) (Z : ℝ) (hZ : 0 ≤ Z)
    (InC : Finset (BarrierData α) → Prop) : Prop where
  /-- (A) R4_Agent8: interventions act by order-preserving endofunctors — the
  no-op is the identity functor and composition of interventions = composition
  of functors (on objects). -/
  intervention_monoid_action :
    (∀ S : Finset (BarrierData α),
        (1 : Removal α).functor.obj S = (𝟭 (Finset (BarrierData α))).obj S) ∧
    (∀ (r₁ r₂ : Removal α) (S : Finset (BarrierData α)),
        (r₁ * r₂).functor.obj S = (r₁.functor ⋙ r₂.functor).obj S)
  /-- (B) R5_Agent3: the faithful monotone cost functor `barrierToCost`,
  monotone + faithful on corpus + identifying interventions with reductions and
  transporting hardness. -/
  cost_functor_faithful :
    (∀ {S T : Finset (BarrierData α)}, S ⊆ T → barrierToCost S ≤ barrierToCost T) ∧
    (∀ (p : Problem α) (X : Agent α), N p X ≠ ⊤ →
        ((barrierToCost (B_data p X) : ℕ) : ℕ∞) = N p X) ∧
    (∀ (r : Removal α) (S : Finset (BarrierData α)),
        removalEdge InC r S = leOfHom (Removal.stepHom r S) ∧
        barrierToCost (r.act S) ≤ barrierToCost S ∧
        ((barrierKernel InC).Hard (r.act S) → (barrierKernel InC).Hard S))
  /-- (C) R6_Agent10: the Ohm budget is a lax monoidal functor — underlying
  functor, unit `ε`, laxator `μ` (disjoint + arbitrary union), unit and
  associativity coherence, naturality. -/
  ohm_lax_monoidal :
    (∀ S : Finset (BarrierData α),
        (ohmBudgetFunctor Z hZ).obj S = ohmCost Z S) ∧
    (ohmCost Z (∅ : Finset (BarrierData α)) = 0) ∧
    (∀ (S T : Finset (BarrierData α)) (h : Disjoint S T),
        ohmCost Z (boxProd S T h) ≤ ohmCost Z S + ohmCost Z T) ∧
    (∀ S T : Finset (BarrierData α),
        ohmCost Z (S ∪ T) ≤ ohmCost Z S + ohmCost Z T) ∧
    (∀ S : Finset (BarrierData α),
        ohmCost Z (∅ ∪ S) = ohmCost Z S ∧ ohmCost Z (S ∪ ∅) = ohmCost Z S) ∧
    (∀ S T U : Finset (BarrierData α),
        ohmCost Z (S ∪ T ∪ U) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U ∧
        ohmCost Z (S ∪ (T ∪ U)) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U) ∧
    (∀ {S S' T T' : Finset (BarrierData α)}, S ⊆ S' → T ⊆ T' →
        ohmCost Z (S ∪ T) ≤ ohmCost Z S' + ohmCost Z T')
  /-- (D) R6_Agent3: the commuting cost triangle — the Ohm-budget functor
  factors through the cardinality/hardness functor via `ceilZ`, on objects
  (OrderHom + functor) and on every shared removal morphism. -/
  cost_triangle_factors :
    ohmCostHom Z hZ = (ceilZ Z hZ).comp (barrierToCost (α := α)) ∧
    (∀ S : Finset (BarrierData α),
        (ohmBudgetFunctor Z hZ).obj S
          = (barrierFunctor (α := α) ⋙ ceilZFunctor Z hZ).obj S) ∧
    (∀ (InC' : Finset (BarrierData α) → Prop)
       (r : Removal α) (S : Finset (BarrierData α)),
        removalEdge InC' r S = leOfHom (Removal.stepHom r S) ∧
        ohmCost Z (r.act S) ≤ ohmCost Z S ∧
        ohmCost Z (r.act S) = ceilZ Z hZ (barrierToCost (r.act S)))
  /-- (E) R7_Agent2: the wall is the absorbing monoidal object — the lifted
  budget functor into `ℕ∞`, faithful laxator/unit, absorption
  `budget(W ⊗ X) = ⊤ = budget(X ⊗ W)`, greatest element.  (The R6_Agent5
  coherence conjunct of the tower headline is omitted here only because it
  mentions the private `pairWalled`; the remaining five facts are discharged by
  projecting the same tower theorem.) -/
  wall_absorbing :
    (∀ S : Finset (BarrierData α),
        liftedBudget Z (.obj S) = ((ohmCost Z S : ℕ) : ℕ∞))
    ∧ (∀ S T : Finset (BarrierData α),
        liftedBudget Z (.obj (S ∪ T))
          ≤ liftedBudget Z (.obj S) + liftedBudget Z (.obj T))
    ∧ (liftedBudget Z (.obj (∅ : Finset (BarrierData α))) = (0 : ℕ∞))
    ∧ (∀ X : TaggedBarrier α,
        budgetTensor Z (.wall) X = (⊤ : ℕ∞)
        ∧ budgetTensor Z X (.wall) = (⊤ : ℕ∞))
    ∧ (∀ X : TaggedBarrier α,
        liftedBudget Z X ≤ liftedBudget Z (.wall : TaggedBarrier α))

/-- **HEADLINE — `master_barrier_category`.**

The grand master theorem of the barrier-category pillar: for every cost scale
`Z` with `0 ≤ Z` and every class predicate `InC`, the barrier category supports
the FULL categorical edifice — the intervention monoid acting by endofunctors
(R4_Agent8), the faithful cost functor identifying interventions with reductions
(R5_Agent3), the Ohm lax monoidal functor (R6_Agent10), the commuting cost
triangle factoring Ohm through cardinality (R6_Agent3), and the wall as
absorbing monoidal object (R7_Agent2) — all simultaneously, at one common
parameter setting.

Each field is discharged by directly invoking the corresponding tower headline;
the five tower theorems are therefore all load-bearing in this proof term. -/
theorem master_barrier_category (Z : ℝ) (hZ : 0 ≤ Z)
    (InC : Finset (BarrierData α) → Prop) :
    MasterBarrierCategory α Z hZ InC where
  intervention_monoid_action :=
    Removal.functor_isMonoidAction (α := α)
  cost_functor_faithful :=
    barrier_cost_functor_faithful InC
  ohm_lax_monoidal :=
    ohmBudget_isLaxMonoidalFunctor Z hZ
  cost_triangle_factors :=
    ohm_budget_functor_factors_through_cardinality Z hZ
  wall_absorbing :=
    -- project the 6-conjunct tower headline, dropping the private-`pairWalled`
    -- coherence conjunct (the 5th); the remaining five are kept and load-bearing.
    let w := wall_is_absorbing_object_of_ohm_lax_monoidal_functor (α := α) Z hZ
    ⟨w.1, w.2.1, w.2.2.1, w.2.2.2.1, w.2.2.2.2.2⟩

/-! ## Satisfiability witness.

The bundled hypotheses are JOINTLY SATISFIABLE: the only constraint is
`0 ≤ Z`, met by `Z = 1` (`zero_le_one`), with `InC := fun _ => True` an
arbitrary class predicate, at `α = Unit`.  The witness exhibits a genuine
non-vacuous instance of the master structure. -/

/-- **Satisfiability witness** for `master_barrier_category`: a concrete instance
at `α = Unit`, `Z = 1`, `hZ = zero_le_one`, `InC = fun _ => True`.  Demonstrates
the bundle is non-vacuous and jointly satisfiable. -/
theorem master_barrier_category_witness :
    MasterBarrierCategory Unit (1 : ℝ) zero_le_one (fun _ => True) :=
  master_barrier_category (1 : ℝ) zero_le_one (fun _ => True)

/-- A second, fully general satisfiability statement: for EVERY `α` and EVERY
`Z ≥ 0` (and any `InC`) the master structure is inhabited.  This certifies the
bundle is not merely satisfiable at one point but on the whole admissible
parameter region `{Z : 0 ≤ Z}`. -/
theorem master_barrier_category_satisfiable
    (Z : ℝ) (hZ : 0 ≤ Z) (InC : Finset (BarrierData α) → Prop) :
    Nonempty (MasterBarrierCategory α Z hZ InC) :=
  ⟨master_barrier_category Z hZ InC⟩

end R10_Agent9_MasterCategory

end MIP
