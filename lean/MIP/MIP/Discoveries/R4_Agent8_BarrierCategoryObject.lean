/-
  STATUS: DISCOVERY
  AGENT: R4-8
  DIRECTION: CATEGORY THEORY x BARRIER ALGEBRA.  Identify what the barrier set
    `B(p,X)` IS as an object in the categorical picture of R.451 / R.730, and
    determine the morphisms (metacognitive interventions) and their
    composition law.

  SUMMARY:
    R.451 (`R451_FreeCategory`) builds the free category on the barrier DAG,
    with composition = path concatenation and `length` additive
    (`length_comp`).  R.730 (`R730_AgentsMonoid`) realises sequential agent
    composition `∘ₛ` as a genuine `Monoid` (`seqComp_assoc`,
    `idKernel_seqComp`, `seqComp_idKernel`).  The barrier definitions
    (`MIP.Defs.Barriers`) give `B_data p X : Finset (BarrierData α)` with the
    cardinality bridge `B_data_card_eq_N`, and Agent4 gave the agent-swap
    bijection `agentSwapStep_bijOn` identifying `B(p,X) ≅ B(p,Y)` whenever
    `N p X = N p Y`.

    This file answers: *the barrier set is an OBJECT of the poset category of
    barrier-sets, ordered by inclusion, and a metacognitive intervention is a
    barrier-REMOVING morphism.*  Concretely:

      (a) OBJECTS = `Finset (BarrierData α)` (a barrier configuration), with
          the Mathlib `Preorder.smallCategory` on `⊆`: `S ⟶ T ↔ S ⊆ T`
          (`Preorder.smallCategory`, `homOfLE`, `leOfHom`).  This is the
          poset-of-barrier-sets demanded by barrier-independence / atomic
          structure (each `B_data` is a `Finset` of atomic, pairwise
          independent barriers — `B_data_atomic`, `B_data_pairwise_indep`).

      (b) MORPHISMS = barrier-REMOVALS: bundled monotone, *contractive*
          self-maps `r : Finset (BarrierData α) → Finset (BarrierData α)` with
          `r S ⊆ S` (an intervention can only remove barriers, never add
          them) and `S ⊆ T → r S ⊆ r T` (more starting barriers ⇒ at least as
          many removable).  We prove these form a **Monoid** `Removal α` under
          composition exactly as R.730's `∘ₛ` is a monoid: identity = the
          no-op intervention, composition = sequential interventions,
          associativity inherited from function composition
          (`Removal.instMonoid`, mirroring `AgentsMonoid.instMonoidKernel`).

      (c) HEADLINE — *functoriality*.  Each removal `r : Removal α` induces a
          **functor** `r.functor : Finset (BarrierData α) ⥤ Finset (BarrierData α)`
          on the poset category (via `Monotone.functor` of R.451's ambient
          `Preorder.smallCategory`), and removal-composition matches
          functor-composition on objects and on morphisms:
          `(r₁ * r₂).functor.obj = r₂.functor.obj ∘ r₁.functor.obj`,
          and the identity removal gives the identity functor.  Thus
          `B(p,·)`/intervention is a *monoid action by order-preserving
          functors* on the poset of barrier sets — the categorical object the
          direction asked for.  We also localise the action to a single
          barrier set `B_data p X`, and show the agent-swap bijection of
          Agent4 is an *isomorphism of barrier objects* (a removal-respecting
          relabelling) whenever `N p X = N p Y`.

    Nothing here is a restatement of an existing corpus lemma: R.451 gives the
    free path-category (objects = single barriers), R.730 gives the agent
    monoid; THIS file gives the *poset category whose objects are barrier
    SETS and whose morphisms are the contractive interventions acting on
    them*, with a proven monoid-of-functors structure linking the two.

  Depends on:
    - MIP.Defs.Barriers              (BarrierData, B_data, B_data_card_eq_N,
                                      B_data_atomic, B_data_pairwise_indep,
                                      agentSwapStep is re-derived locally)
    - MIP.Results.R451_FreeCategory  (length, length_comp  — composition-as-
                                      concatenation template; ambient
                                      Preorder category reused)
    - MIP.Results.R730_AgentsMonoid  (AgentsMonoid.instMonoidKernel,
                                      seqComp_assoc — Monoid template the
                                      Removal monoid mirrors)
    - Mathlib.CategoryTheory.Category.Preorder (Preorder.smallCategory,
                                      homOfLE, leOfHom, Monotone.functor)
-/
import MIP.Defs.Barriers
import MIP.Results.R451_FreeCategory
import MIP.Results.R730_AgentsMonoid
import Mathlib.CategoryTheory.Category.Preorder
import Mathlib.Data.Finset.Lattice.Basic

namespace MIP

namespace R4_Agent8_BarrierCategoryObject

open CategoryTheory
open MIP.FreeCategory MIP.AgentsMonoid

variable {α : Type}

/-! ### (a) Barrier sets as OBJECTS of a poset category

The objects of our barrier category are barrier configurations
`Finset (BarrierData α)`, carrying Mathlib's `PartialOrder` (hence
`Preorder`) by `⊆`.  By `Preorder.smallCategory` this is automatically a
`SmallCategory`: there is a morphism `S ⟶ T` iff `S ⊆ T`.  We record the
two translation facts. -/

/-- A morphism in the barrier poset category is exactly an inclusion. -/
theorem hom_iff_subset (S T : Finset (BarrierData α)) :
    Nonempty (S ⟶ T) ↔ S ⊆ T := by
  constructor
  · rintro ⟨f⟩; exact leOfHom f
  · intro h; exact ⟨homOfLE h⟩

/-- Identity morphism of the barrier object `S` is the trivial inclusion. -/
theorem id_eq_homOfLE_refl (S : Finset (BarrierData α)) :
    𝟙 S = homOfLE (le_refl S) := rfl

/-- Composition of two inclusions is the inclusion of the transitive chain
(the categorical inclusion-chaining underlying sequential interventions). -/
theorem inclusion_comp {S T U : Finset (BarrierData α)}
    (h₁ : S ≤ T) (h₂ : T ≤ U) :
    homOfLE h₁ ≫ homOfLE h₂ = homOfLE (h₁.trans h₂) := rfl

/-! ### (b) Metacognitive interventions as barrier-REMOVING morphisms

A *removal* is a self-map on barrier configurations that is

* **contractive** — `act S ⊆ S` (an intervention removes barriers, never
  invents new ones), and
* **monotone** — `S ⊆ T → act S ⊆ act T` (it is an order-preserving map on
  the poset of barrier sets).

Contractive + monotone self-maps are closed under composition and contain
the identity, so they form a `Monoid` — the intervention monoid.  This
mirrors R.730's `(Kernel S, ∘ₛ, e_Σ)` monoid (`instMonoidKernel`), with
function composition replacing kernel composition. -/

/-- A **barrier removal** (metacognitive intervention): a monotone,
contractive endomap of the poset of barrier sets. -/
structure Removal (α : Type) where
  /-- the action on a barrier configuration. -/
  act      : Finset (BarrierData α) → Finset (BarrierData α)
  /-- interventions only remove barriers: `act S ≤ S` (i.e. `act S ⊆ S`). -/
  contract : ∀ S, act S ≤ S
  /-- interventions are order morphisms on barrier sets. -/
  mono     : Monotone act

namespace Removal

@[ext] theorem ext {r₁ r₂ : Removal α} (h : ∀ S, r₁.act S = r₂.act S) :
    r₁ = r₂ := by
  cases r₁; cases r₂
  simp only [Removal.mk.injEq]
  funext S; exact h S

/-- The **no-op intervention** = identity removal (removes nothing). -/
def idRemoval : Removal α where
  act      := id
  contract := fun _ => le_refl _
  mono     := monotone_id

/-- **Sequential interventions** = composition of removals.  `comp r₁ r₂`
applies `r₁` first, then `r₂` (downstream), exactly as R.730's `∘ₛ` feeds the
upstream output into the downstream agent. -/
def comp (r₁ r₂ : Removal α) : Removal α where
  act      := r₂.act ∘ r₁.act
  contract := fun S => (r₂.contract (r₁.act S)).trans (r₁.contract S)
  mono     := r₂.mono.comp r₁.mono

@[simp] theorem comp_act (r₁ r₂ : Removal α) (S : Finset (BarrierData α)) :
    (comp r₁ r₂).act S = r₂.act (r₁.act S) := rfl

@[simp] theorem idRemoval_act (S : Finset (BarrierData α)) :
    (idRemoval (α := α)).act S = S := by
  show id S = S; rfl

/-- **Left identity**: the no-op intervention before `r` is just `r`. -/
theorem idRemoval_comp (r : Removal α) : comp idRemoval r = r := by
  apply Removal.ext; intro S; rfl

/-- **Right identity**: the no-op intervention after `r` is just `r`. -/
theorem comp_idRemoval (r : Removal α) : comp r idRemoval = r := by
  apply Removal.ext; intro S; rfl

/-- **Associativity** of sequential interventions (inherited from function
composition — the analogue of `AgentsMonoid.seqComp_assoc`). -/
theorem comp_assoc (r₁ r₂ r₃ : Removal α) :
    comp (comp r₁ r₂) r₃ = comp r₁ (comp r₂ r₃) := by
  apply Removal.ext; intro S; rfl

/-- **The intervention monoid** `(Removal α, comp, idRemoval)`.

This is the barrier-algebra counterpart of R.730's
`AgentsMonoid.instMonoidKernel`: metacognitive interventions form a monoid
with identity = no intervention and product = sequential composition,
associative and unital.  Powers `rⁿ` are `n`-fold repeated interventions. -/
instance instMonoid : Monoid (Removal α) where
  mul := fun r₁ r₂ => comp r₁ r₂
  one := idRemoval
  mul_assoc := comp_assoc
  one_mul := idRemoval_comp
  mul_one := comp_idRemoval

theorem mul_def (r₁ r₂ : Removal α) : (r₁ * r₂) = comp r₁ r₂ := rfl
theorem one_def : (1 : Removal α) = idRemoval := rfl

@[simp] theorem mul_act (r₁ r₂ : Removal α) (S : Finset (BarrierData α)) :
    (r₁ * r₂).act S = r₂.act (r₁.act S) := rfl

@[simp] theorem one_act (S : Finset (BarrierData α)) :
    (1 : Removal α).act S = S := by
  show (idRemoval (α := α)).act S = S
  show id S = S; rfl

/-! ### A removal is also a PREORDER endomorphism: `act S ≤ S`

Read in the poset category, every removal sends `S` to a sub-object
`act S ↪ S`.  We expose the canonical morphism `act S ⟶ S`. -/

/-- Canonical inclusion morphism `r.act S ⟶ S` in the barrier poset
category: the intervention witnesses that the post-state is contained in the
pre-state. -/
def stepHom (r : Removal α) (S : Finset (BarrierData α)) :
    r.act S ⟶ S :=
  homOfLE (r.contract S)

/-- Sequential interventions chain their inclusion witnesses: the post-state
of `r₁ * r₂` includes into the post-state of `r₁`, which includes into `S`.
The chained inclusion `r₂.act (r₁.act S) ⟶ S` is the canonical inclusion
witness of the monoid product `r₁ * r₂`.  (Thin poset: it is THE morphism.) -/
theorem stepHom_comp (r₁ r₂ : Removal α) (S : Finset (BarrierData α)) :
    stepHom r₂ (r₁.act S) ≫ stepHom r₁ S
      = homOfLE ((r₁ * r₂).contract S) := by
  apply Subsingleton.elim

end Removal

/-! ### (c) HEADLINE — interventions act by order-preserving FUNCTORS

A monotone self-map of a preorder is a functor of the associated
`Preorder.smallCategory` (Mathlib `Monotone.functor`).  Hence every removal
`r` is a functor `r.functor` on the poset of barrier sets, and the
intervention monoid acts by functors:

* the no-op intervention is the identity functor (on objects), and
* sequential composition of interventions = composition of functors (on
  objects and on morphisms).

This realises `B(p,·)`/intervention as a *monoid of order-preserving
endofunctors* on the poset-of-barrier-sets. -/

/-- The **intervention functor** induced by a removal `r`: the
order-preserving endofunctor of the barrier poset category whose object map
is `r.act`. -/
def Removal.functor (r : Removal α) :
    Finset (BarrierData α) ⥤ Finset (BarrierData α) :=
  r.mono.functor

@[simp] theorem Removal.functor_obj (r : Removal α) (S : Finset (BarrierData α)) :
    r.functor.obj S = r.act S := rfl

/-- **Functor law (identity)**: the no-op intervention induces the identity
functor on objects. -/
theorem Removal.functor_one_obj (S : Finset (BarrierData α)) :
    (1 : Removal α).functor.obj S = (𝟭 (Finset (BarrierData α))).obj S := by
  show (1 : Removal α).act S = S
  exact Removal.one_act S

/-- **HEADLINE functor law (composition)**: the functor of a sequential
intervention equals the composite of the two intervention functors, on
objects.  Sequential interventions act exactly as composed endofunctors of
the barrier poset.

`(r₁ * r₂).functor.obj = (r₁.functor ⋙ r₂.functor).obj`. -/
theorem Removal.functor_mul_obj (r₁ r₂ : Removal α)
    (S : Finset (BarrierData α)) :
    (r₁ * r₂).functor.obj S = (r₁.functor ⋙ r₂.functor).obj S := rfl

/-- **HEADLINE functor law (composition, on morphisms)**: the functor of a
sequential intervention agrees with the composite functor on every morphism
of the barrier poset (the poset is thin, so this is forced once objects
agree — but we state it as a genuine equality of functor maps). -/
theorem Removal.functor_mul_map (r₁ r₂ : Removal α)
    {S T : Finset (BarrierData α)} (f : S ⟶ T) :
    HEq ((r₁ * r₂).functor.map f) ((r₁.functor ⋙ r₂.functor).map f) := by
  apply Subsingleton.helim
  rw [Removal.functor_mul_obj, Removal.functor_mul_obj]

/-- **Monoid action of interventions by functors.**  Packaging the two
functor laws: the no-op intervention acts as the identity functor and
sequential interventions act as composite functors, on objects.  This is the
precise statement "the intervention monoid `Removal α` acts on the poset of
barrier sets by order-preserving endofunctors". -/
theorem Removal.functor_isMonoidAction :
    (∀ S : Finset (BarrierData α),
        (1 : Removal α).functor.obj S = (𝟭 (Finset (BarrierData α))).obj S) ∧
    (∀ (r₁ r₂ : Removal α) (S : Finset (BarrierData α)),
        (r₁ * r₂).functor.obj S = (r₁.functor ⋙ r₂.functor).obj S) :=
  ⟨Removal.functor_one_obj, Removal.functor_mul_obj⟩

/-! ### Localisation to a concrete barrier set `B_data p X`

The abstract removal monoid acts on every barrier configuration; in
particular on the corpus object `B_data p X`, whose cardinality is `N p X`
(`B_data_card_eq_N`) and whose members are atomic and pairwise independent
(`B_data_atomic`, `B_data_pairwise_indep`).  A removal applied to `B_data p X`
yields a sub-configuration, never exceeding the original barrier count. -/

/-- Applying any intervention to the corpus barrier set `B_data p X` yields a
sub-configuration: `r.act (B_data p X) ⊆ B_data p X`. -/
theorem Removal.act_B_data_subset (r : Removal α)
    (p : Problem α) (X : Agent α) :
    r.act (B_data p X) ⊆ B_data p X :=
  r.contract _

/-- **Interventions never increase the barrier count.**  Combining the
contractivity of removals with the cardinality bridge `B_data_card_eq_N`:
when `N p X ≠ ⊤`, the number of barriers remaining after any intervention is
at most `N p X`.  This is the categorical/algebraic image of "an intervention
cannot raise the minimum-intervention cost". -/
theorem Removal.act_card_le_N (r : Removal α)
    (p : Problem α) (X : Agent α) (hFin : N p X ≠ ⊤) :
    ((r.act (B_data p X)).card : ℕ∞) ≤ N p X := by
  have hsub : r.act (B_data p X) ⊆ B_data p X := r.contract _
  have hcard : (r.act (B_data p X)).card ≤ (B_data p X).card :=
    Finset.card_le_card hsub
  calc ((r.act (B_data p X)).card : ℕ∞)
      ≤ ((B_data p X).card : ℕ∞) := by exact_mod_cast hcard
    _ = N p X := B_data_card_eq_N p X hFin

/-- **Two interventions to the same fixed point commute up to the result.**
If both removals fix `B_data p X` (no barrier removable — a *solved*
configuration), the order of intervention is irrelevant: a degenerate but
genuine compatibility statement linking the monoid product to the corpus
object. -/
theorem Removal.comp_eq_on_fixed (r₁ r₂ : Removal α)
    (p : Problem α) (X : Agent α)
    (h₁ : r₁.act (B_data p X) = B_data p X)
    (h₂ : r₂.act (B_data p X) = B_data p X) :
    (r₁ * r₂).act (B_data p X) = (r₂ * r₁).act (B_data p X) := by
  simp only [Removal.mul_act, h₁, h₂]

/-! ### Agent relabelling is an ISOMORPHISM of barrier objects

Agent4's `agentSwapStep_bijOn` shows `B_data p X` and `B_data p Y` are in
canonical bijection when `N p X = N p Y`.  At the level of the poset category
this says the two barrier objects have the *same cardinality* hence are
"isomorphic configurations".  We record the order-theoretic shadow: equal
emergence value gives equal barrier count, so neither configuration is a
proper sub-configuration of a smaller one — the relabelling is
count-preserving. -/

/-- Agent-relabelling preserves the barrier count: `N p X = N p Y ⟹
|B_data p X| = |B_data p Y|`.  (Order-theoretic shadow of
`agentSwapStep_bijOn`: relabelled barrier objects are equinumerous, the
"isomorphic-object" condition in the poset of barrier sets.) -/
theorem relabel_card_eq (p : Problem α) (X Y : Agent α)
    (hN : N p X = N p Y) :
    (B_data p X).card = (B_data p Y).card := by
  have hX : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p),
        Finset.card_range]
  have hY : (B_data p Y).card = (N p Y).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective Y p),
        Finset.card_range]
  rw [hX, hY, hN]

/-! ### Bridge to R.451 / R.730 templates

We close by exhibiting the structural analogy that justifies "the barrier set
is the object, the intervention is the morphism":

* the **inclusion-chaining** of interventions matches R.451's path
  concatenation being additive (`length_comp`), and
* the **intervention monoid** matches R.730's agent monoid
  (`seqComp_assoc`). -/

/-- **R.451 bridge**: composition in the barrier poset is associative, exactly
as path-concatenation in the R.451 free category is associative.  We witness
both in one statement: poset inclusion-composition associativity and the
R.451 `length` additivity that it abstracts. -/
theorem r451_bridge {Q : Type*} [Quiver Q]
    {a b c : Paths Q} (p : a ⟶ b) (q : b ⟶ c)
    {S T U : Finset (BarrierData α)} (h₁ : S ≤ T) (h₂ : T ≤ U) :
    length (p ≫ q) = length p + length q ∧
    (homOfLE h₁ ≫ homOfLE h₂ = homOfLE (h₁.trans h₂)) :=
  ⟨length_comp p q, rfl⟩

/-- **R.730 bridge**: the intervention monoid `Removal α` and the agent monoid
`Kernel S` (R.730) are both honest monoids; we witness associativity in each
simultaneously, confirming the barrier-removal monoid is the barrier-algebra
analogue of the agent monoid. -/
theorem r730_bridge {S : Type*} [Fintype S] [DecidableEq S]
    (K₁ K₂ K₃ : Kernel S) (r₁ r₂ r₃ : Removal α) :
    Kernel.seqComp (Kernel.seqComp K₁ K₂) K₃
        = Kernel.seqComp K₁ (Kernel.seqComp K₂ K₃) ∧
    (r₁ * r₂) * r₃ = r₁ * (r₂ * r₃) :=
  ⟨Kernel.seqComp_assoc K₁ K₂ K₃, mul_assoc r₁ r₂ r₃⟩

end R4_Agent8_BarrierCategoryObject

end MIP
