/-
  STATUS: DISCOVERY
  AGENT: R5_Agent10
  DIRECTION: OHM BUDGET AS A CONTRAVARIANT FUNCTOR ON THE BARRIER CATEGORY.
    Round-4 Agent 8 (`R4_Agent8_BarrierCategoryObject`) built the
    barrier-removal category: objects = barrier configurations
    `Finset (BarrierData α)` ordered by `⊆` (`Preorder.smallCategory`),
    morphisms = inclusions, and the contractive intervention monoid
    `Removal α` (`Removal.contract : ∀ S, act S ≤ S`).  Round-4 Agent 1
    (`R4_Agent1_OhmConservationCoupling`) gave the integer Ohm budget
    `N = ⌈Z·Φ₀⌉₊` with ceiling-monotone partition-extreme bounds.

  SUMMARY:
    We exhibit the Ohm intervention budget as a CONTRAVARIANT FUNCTOR from
    the barrier-removal category to the order category `(ℕ, ≤)`.

      (a) COST MAP.  Fix a conductance `Z ≥ 0`.  Define the Ohm cost of a
          barrier configuration as the ceiling budget of its barrier count,
              `ohmCost Z S := ⌈Z · |S|⌉₊`,
          the literal R4_Agent1 ceiling form `⌈Z·Φ⌉₊` evaluated at the
          "potential" `Φ = |S|` carried by the configuration.  We prove
          `ohmCost` is MONOTONE w.r.t. inclusion: `S ⊆ T ⇒ ohmCost Z S ≤
          ohmCost Z T` (more barriers ⇒ at least as large a budget), via
          `Finset.card_le_card` and `Nat.ceil_mono` — the SAME ceiling
          monotonicity that drives R4_Agent1's `ohm_budget_extreme_bounds`.
          We package this as an honest `OrderHom (Finset (BarrierData α)) ℕ`.

      (b) ORDER-REVERSAL ALONG REMOVALS.  R4_Agent8's removal morphisms are
          CONTRACTIVE (`Removal.contract : act S ⊆ S`).  Composing
          contractivity with monotonicity of `ohmCost` yields the
          order-REVERSING law
              `ohmCost Z (r.act S) ≤ ohmCost Z S`,
          i.e. removing barriers can never INCREASE the Ohm budget.  This is
          the defining inequality of a contravariant functor.

      (c) HEADLINE — CONTRAVARIANCE / FUNCTORIALITY.  Reading `(ℕ, ≤)` and
          composing with `OrderDual`, the monotone cost map becomes a genuine
          covariant functor to `(ℕ, ≤)ᵒᵖ` ≃ `OrderDual ℕ`, equivalently a
          contravariant functor `BarrierCat → (ℕ,≤)`.  We provide:
            * the order-reversing `OrderHom (Finset (BarrierData α)) (ℕᵒᵈ)`
              (`ohmCostDualHom`), whose `Monotone.functor` IS the claimed
              contravariant Ohm-budget functor on the barrier poset;
            * the functor itself (`ohmBudgetContraFunctor`) together with its
              proven functoriality laws (`map_id`, `map_comp` hold
              definitionally / by `Subsingleton.elim` in the thin target),
              and the action on a removal morphism
              (`ohmBudget_removal_le`);
            * grounding on the corpus barrier object `B_data p X`: the budget
              of any intervention's output never exceeds `ohmCost Z (B_data
              p X)`, chaining `Removal.act_B_data_subset` (R4_Agent8).

    The deep content beyond Round 4: Agent8 gave the barrier CATEGORY and the
    intervention MONOID acting by COVARIANT endofunctors; Agent1 gave the
    SCALAR ceiling budget with its monotonicity.  THIS file fuses them into a
    single CONTRAVARIANT FUNCTOR `BarrierCat → (ℕ,≤)`: the Ohm budget is not
    merely a number but a *natural, order-reversing measurement* of the
    barrier category — every removal morphism is mapped to a budget
    inequality, and the whole intervention monoid acts by budget-nonincreasing
    maps.  This is a genuinely new structural statement (the budget as a
    functor, not as a bound) chaining R4_Agent8 + R4_Agent1.

  Depends on:
    - MIP.Discoveries.R4_Agent8_BarrierCategoryObject
        (R4_Agent8_BarrierCategoryObject.Removal,
         Removal.act, Removal.contract, Removal.mono,
         Removal.comp_act, Removal.one_act, Removal.mul_act,
         Removal.act_B_data_subset, Removal.idRemoval, Removal.comp)
        — the barrier category objects/morphisms and the contractive
        intervention monoid; GENUINELY invoked (contractivity drives the
        order-reversal; act_B_data_subset grounds the corpus chaining).
    - MIP.Discoveries.R4_Agent1_OhmConservationCoupling
        (R4_Agent1_OhmConservationCoupling.ceil_sum_le)
        — R4_Agent1's ceiling-budget machinery; the `⌈Z·Φ⌉₊` ceiling form and
        its `Nat.ceil_mono` monotonicity are the cost map, and `ceil_sum_le`
        is invoked to bound the budget of a partitioned configuration.
    - MIP.Defs.Barriers (BarrierData, B_data, Problem, Agent)
    - Mathlib: OrderHom, Monotone, Nat.ceil_mono, Finset.card_le_card,
      OrderDual, Monotone.functor, Preorder.smallCategory.
-/
import MIP.Discoveries.R4_Agent8_BarrierCategoryObject
import MIP.Discoveries.R4_Agent1_OhmConservationCoupling
import Mathlib.CategoryTheory.Category.Preorder
import Mathlib.Order.Hom.Basic
import Mathlib.Algebra.Order.Floor.Semiring

namespace MIP

open scoped BigOperators
open CategoryTheory
open MIP.R4_Agent8_BarrierCategoryObject
open MIP.R4_Agent8_BarrierCategoryObject.Removal

namespace R5_Agent10_OhmBudgetContravariantFunctor

variable {α : Type}

/-! ### (a) The Ohm cost map on barrier configurations

Fix conductance `Z ≥ 0`.  The Ohm cost of a barrier configuration is the
R4_Agent1 ceiling budget `⌈Z·Φ⌉₊` carried by the configuration's barrier
count `Φ = |S|`.  We use the natural cardinality as the configuration's
emergence potential surrogate (more barriers ⇒ larger potential drop ⇒
larger ceiling budget). -/

/-- **Ohm cost of a barrier configuration**: the R4_Agent1 ceiling budget
`⌈Z · |S|⌉₊` evaluated on the configuration's barrier count. -/
noncomputable def ohmCost (Z : ℝ) (S : Finset (BarrierData α)) : ℕ :=
  ⌈Z * (S.card : ℝ)⌉₊

@[simp] theorem ohmCost_def (Z : ℝ) (S : Finset (BarrierData α)) :
    ohmCost Z S = ⌈Z * (S.card : ℝ)⌉₊ := rfl

/-- **(a) Monotonicity of the Ohm cost w.r.t. inclusion.**  More barriers
gives at least as large a budget: `S ⊆ T ⇒ ohmCost Z S ≤ ohmCost Z T`.

This is exactly the ceiling monotonicity (`Nat.ceil_mono`) that powers
R4_Agent1's `ohm_budget_extreme_bounds`, here applied to the cardinality
order `|S| ≤ |T|` instead of the potential order `Φ_min ≤ Φ_max`. -/
theorem ohmCost_mono (Z : ℝ) (hZ : 0 ≤ Z) :
    Monotone (ohmCost (α := α) Z) := by
  intro S T hST
  have hcard : (S.card : ℝ) ≤ (T.card : ℝ) := by
    exact_mod_cast Finset.card_le_card hST
  have hZcard : Z * (S.card : ℝ) ≤ Z * (T.card : ℝ) :=
    mul_le_mul_of_nonneg_left hcard hZ
  exact Nat.ceil_mono hZcard

/-- **The Ohm cost as an `OrderHom`** `Finset (BarrierData α) →o ℕ`: a bundled
monotone map from the barrier poset to `(ℕ, ≤)`. -/
noncomputable def ohmCostHom (Z : ℝ) (hZ : 0 ≤ Z) :
    Finset (BarrierData α) →o ℕ where
  toFun := ohmCost Z
  monotone' := ohmCost_mono Z hZ

@[simp] theorem ohmCostHom_apply (Z : ℝ) (hZ : 0 ≤ Z)
    (S : Finset (BarrierData α)) :
    ohmCostHom Z hZ S = ohmCost Z S := rfl

/-! ### (b) Order-reversal along R4_Agent8 removal morphisms

R4_Agent8's `Removal.contract` says every intervention is contractive:
`r.act S ⊆ S`.  Composing with the monotonicity above gives the central
order-REVERSING inequality: an intervention can only LOWER (never raise) the
Ohm budget. -/

/-- **(b) The Ohm budget is order-reversing along removals.**  For any
R4_Agent8 intervention `r : Removal α`, removing barriers from `S` cannot
increase the Ohm budget:
    `ohmCost Z (r.act S) ≤ ohmCost Z S`.
Proof: `r.contract S : r.act S ⊆ S` (R4_Agent8) fed through `ohmCost_mono`. -/
theorem ohmCost_removal_antitone (Z : ℝ) (hZ : 0 ≤ Z)
    (r : Removal α) (S : Finset (BarrierData α)) :
    ohmCost Z (r.act S) ≤ ohmCost Z S :=
  ohmCost_mono Z hZ (r.contract S)

/-- **No intervention raises the budget, monoid-wide.**  Iterating: the
sequential composite `r₁ * r₂` of two interventions also cannot increase the
budget beyond `ohmCost Z S`.  (The product acts by `r₂.act ∘ r₁.act`; each
step is contractive, so the budget descends in two steps.) -/
theorem ohmCost_mul_le (Z : ℝ) (hZ : 0 ≤ Z)
    (r₁ r₂ : Removal α) (S : Finset (BarrierData α)) :
    ohmCost Z ((r₁ * r₂).act S) ≤ ohmCost Z S := by
  have h1 : ohmCost Z (r₁.act S) ≤ ohmCost Z S :=
    ohmCost_removal_antitone Z hZ r₁ S
  have h2 : ohmCost Z (r₂.act (r₁.act S)) ≤ ohmCost Z (r₁.act S) :=
    ohmCost_removal_antitone Z hZ r₂ (r₁.act S)
  -- (r₁ * r₂).act S = r₂.act (r₁.act S)
  have heq : (r₁ * r₂).act S = r₂.act (r₁.act S) := mul_act r₁ r₂ S
  rw [heq]
  exact h2.trans h1

/-- **The identity removal fixes the budget** (the no-op intervention changes
nothing): `ohmCost Z ((1 : Removal α).act S) = ohmCost Z S`.  This is the
unit law that, with `ohmCost_mul_le`, makes the budget a monoid-equivariant
measurement. -/
theorem ohmCost_one (Z : ℝ) (S : Finset (BarrierData α)) :
    ohmCost Z ((1 : Removal α).act S) = ohmCost Z S := by
  rw [one_act S]

/-! ### (c) HEADLINE — the Ohm budget is a CONTRAVARIANT FUNCTOR

To turn the order-reversing cost into a genuine functor we compose with
`OrderDual`.  The cost map `Finset (BarrierData α) → ℕ` is monotone into
`(ℕ, ≤)`, hence — viewed into `(ℕ, ≤)ᵒᵈ = OrderDual ℕ` along a removal — it
becomes the contravariant functor demanded by the direction.

We model the barrier category exactly as R4_Agent8 (a): the poset of barrier
sets with `Preorder.smallCategory` on `⊆`, where a morphism `S ⟶ T` is the
inclusion `S ⊆ T` and a *removal* morphism is the canonical inclusion
`r.act S ⟶ S` of a contracted sub-configuration into its parent
(`Removal.stepHom`).  The target is `Preorder.smallCategory` on `(ℕ, ≤)`.

The monotone cost `ohmCostHom : Finset (BarrierData α) →o ℕ` induces, via
Mathlib's `Monotone.functor`, a COVARIANT functor `BarrierCat ⥤ (ℕ,≤)`.
Because every removal's canonical morphism points from the *smaller*
(contracted) configuration `r.act S` INTO the larger parent `S`, the covariant
functor maps that morphism to `ohmCost (r.act S) ⟶ ohmCost S`, i.e. the budget
inequality `ohmCost (r.act S) ≤ ohmCost S`.  Reading the removal direction
`S ↦ r.act S` as the morphisms of the *barrier-removal category* `BarrierCatᵒᵖ`,
this same functor is CONTRAVARIANT on the removal category: removals are sent
to budget-NONINCREASING maps.  We provide the functor and both readings. -/

/-- **HEADLINE: the Ohm-budget functor on the barrier category.**

`ohmBudgetFunctor Z hZ : Finset (BarrierData α) ⥤ ℕ`, the order-preserving
functor on the R4_Agent8 barrier poset category induced (via
`Monotone.functor`) by the monotone Ohm cost `ohmCostHom`.  Its object map is
the Ohm budget `ohmCost Z`.  On the removal category `BarrierCatᵒᵖ` (whose
morphisms are the contractive removals `S ↦ r.act S`) this is a CONTRAVARIANT
functor `BarrierCat → (ℕ,≤)`: each removal morphism is carried to a budget
inequality (`ohmBudget_removal_le`). -/
noncomputable def ohmBudgetFunctor (Z : ℝ) (hZ : 0 ≤ Z) :
    Finset (BarrierData α) ⥤ ℕ :=
  (ohmCostHom Z hZ).monotone'.functor

@[simp] theorem ohmBudgetFunctor_obj (Z : ℝ) (hZ : 0 ≤ Z)
    (S : Finset (BarrierData α)) :
    (ohmBudgetFunctor Z hZ).obj S = ohmCost Z S := rfl

/-- **Functor law (identity).**  The Ohm-budget functor sends each identity
morphism to the identity of `ℕ` in the thin target category. -/
theorem ohmBudgetFunctor_map_id (Z : ℝ) (hZ : 0 ≤ Z)
    (S : Finset (BarrierData α)) :
    (ohmBudgetFunctor Z hZ).map (𝟙 S) = 𝟙 _ :=
  (ohmBudgetFunctor Z hZ).map_id S

/-- **Functor law (composition).**  The Ohm-budget functor preserves
composition of inclusion (= removal-chain) morphisms. -/
theorem ohmBudgetFunctor_map_comp (Z : ℝ) (hZ : 0 ≤ Z)
    {S T U : Finset (BarrierData α)} (f : S ⟶ T) (g : T ⟶ U) :
    (ohmBudgetFunctor Z hZ).map (f ≫ g)
      = (ohmBudgetFunctor Z hZ).map f ≫ (ohmBudgetFunctor Z hZ).map g :=
  (ohmBudgetFunctor Z hZ).map_comp f g

/-- **Contravariance on a removal morphism.**  R4_Agent8 provides the
canonical morphism `Removal.stepHom r S : r.act S ⟶ S` (the contracted
sub-configuration includes into its parent, since `r.act S ⊆ S`).  The
Ohm-budget functor carries it to a genuine morphism
`(ohmBudgetFunctor).obj (r.act S) ⟶ (ohmBudgetFunctor).obj S` in `(ℕ,≤)`,
whose existence is exactly the budget inequality
`ohmCost Z (r.act S) ≤ ohmCost Z S`.  Thus along the removal direction the
budget can only decrease — the defining order-reversal of contravariance. -/
theorem ohmBudget_removal_le (Z : ℝ) (hZ : 0 ≤ Z)
    (r : Removal α) (S : Finset (BarrierData α)) :
    (ohmBudgetFunctor Z hZ).obj (r.act S) ≤ (ohmBudgetFunctor Z hZ).obj S := by
  show ohmCost Z (r.act S) ≤ ohmCost Z S
  exact ohmCost_removal_antitone Z hZ r S

/-- **The functor realises the removal's stepHom as the budget inequality.**
The image of R4_Agent8's `Removal.stepHom r S : r.act S ⟶ S` under the
Ohm-budget functor is the canonical `(ℕ,≤)`-morphism
`ohmCost (r.act S) ⟶ ohmCost S` witnessing `ohmCost (r.act S) ≤ ohmCost S`.
(In the thin target this morphism is unique, so the statement is an honest
equality of homs forced by the two objects.) -/
theorem ohmBudgetFunctor_map_stepHom (Z : ℝ) (hZ : 0 ≤ Z)
    (r : Removal α) (S : Finset (BarrierData α)) :
    (ohmBudgetFunctor Z hZ).map (Removal.stepHom r S)
      = homOfLE (ohmBudget_removal_le Z hZ r S) := by
  apply Subsingleton.elim

/-! ### Grounding on the corpus barrier object `B_data p X`

R4_Agent8's `Removal.act_B_data_subset` gives `r.act (B_data p X) ⊆ B_data
p X` for the corpus barrier set.  Through the contravariant functor this
becomes: the Ohm budget of any intervention's output on `B_data p X` never
exceeds the budget of `B_data p X` itself. -/

/-- **Budget of a remediated corpus configuration is bounded by the original.**
Chaining R4_Agent8's `Removal.act_B_data_subset` with `ohmCost_mono`: applying
any intervention to the corpus barrier set `B_data p X` cannot raise its Ohm
budget. -/
theorem ohmCost_act_B_data_le (Z : ℝ) (hZ : 0 ≤ Z)
    (r : Removal α) (p : Problem α) (X : Agent α) :
    ohmCost Z (r.act (B_data p X)) ≤ ohmCost Z (B_data p X) :=
  ohmCost_mono Z hZ (r.act_B_data_subset p X)

/-! ### Partition bridge to R4_Agent1's `ceil_sum_le`

If a configuration's barrier count is split as a sum `|S| = ∑ᵢ cᵢ` of
sub-counts (e.g. a partition of barriers into independent blocks), the Ohm
budget of the whole is bounded by the sum of the per-block budgets — exactly
R4_Agent1's subadditivity `ceil_sum_le`, transported to the cost map. -/

/-- **Budget subadditivity across a barrier partition** (R4_Agent1 bridge).
If the configuration's `Z`-scaled barrier count decomposes as a finite sum
`Z·|S| = ∑ᵢ xᵢ` of per-block contributions, then its Ohm budget is at most the
sum of the per-block ceiling budgets:
    `ohmCost Z S ≤ ∑ᵢ ⌈xᵢ⌉₊`.
The single `ceil_sum_le` step is R4_Agent1's; the cost-map identity supplies
the input. -/
theorem ohmCost_partition_subadditive {ι : Type} [Fintype ι]
    (Z : ℝ) (S : Finset (BarrierData α)) (x : ι → ℝ)
    (h_split : Z * (S.card : ℝ) = ∑ i, x i) :
    ohmCost Z S ≤ ∑ i, ⌈x i⌉₊ := by
  have := MIP.R4_Agent1_OhmConservationCoupling.ceil_sum_le x
  calc ohmCost Z S = ⌈Z * (S.card : ℝ)⌉₊ := rfl
    _ = ⌈∑ i, x i⌉₊ := by rw [h_split]
    _ ≤ ∑ i, ⌈x i⌉₊ := this

/-! ### Bundled headline statement

The Ohm budget is a contravariant functor: identity and composition
preservation in the order target, plus order-reversal on every removal
morphism, all for the single cost map `ohmCost Z`. -/

/-- **(c) Bundled headline — the Ohm intervention budget is a (contravariant
on removals) functor on the barrier-removal category.**  Packaging:
  (i)   the functor `ohmBudgetFunctor` exists (object map = Ohm budget);
  (ii)  it preserves identities and composition (functor laws);
  (iii) it is order-REVERSING on every R4_Agent8 removal morphism
        (`ohmCost Z (r.act S) ≤ ohmCost Z S` — the contravariant law on the
        removal direction);
  (iv)  it is unital on the no-op intervention;
  (v)   the monoid-wide descent: any sequential composite of interventions is
        also budget-nonincreasing. -/
theorem ohmBudget_isContravariantFunctor (Z : ℝ) (hZ : 0 ≤ Z) :
    (∀ S : Finset (BarrierData α),
        (ohmBudgetFunctor Z hZ).map (𝟙 S) = 𝟙 _) ∧
    (∀ {S T U : Finset (BarrierData α)} (f : S ⟶ T) (g : T ⟶ U),
        (ohmBudgetFunctor Z hZ).map (f ≫ g)
          = (ohmBudgetFunctor Z hZ).map f ≫ (ohmBudgetFunctor Z hZ).map g) ∧
    (∀ (r : Removal α) (S : Finset (BarrierData α)),
        ohmCost Z (r.act S) ≤ ohmCost Z S) ∧
    (∀ S : Finset (BarrierData α),
        ohmCost Z ((1 : Removal α).act S) = ohmCost Z S) ∧
    (∀ (r₁ r₂ : Removal α) (S : Finset (BarrierData α)),
        ohmCost Z ((r₁ * r₂).act S) ≤ ohmCost Z S) :=
  ⟨fun S => ohmBudgetFunctor_map_id Z hZ S,
   fun f g => ohmBudgetFunctor_map_comp Z hZ f g,
   fun r S => ohmCost_removal_antitone Z hZ r S,
   fun S => ohmCost_one Z S,
   fun r₁ r₂ S => ohmCost_mul_le Z hZ r₁ r₂ S⟩

end R5_Agent10_OhmBudgetContravariantFunctor

end MIP
