/-
Result R.461 — the Yoneda agent behavioural-equivalence principle: agents
are determined by their behaviour across all problems.

Reference: `workspace/categorical_formalization.md` §R.461
(A 条件性, 2026-05-16, second-round categorical extension).

**Statement.**  D.1.2 models an agent as a conditional-probability kernel.
The categorical content of R.461 is the *behavioural-equivalence
principle*:

    X ≅ X'   ⟺   Bhv(·, X) ≅ Bhv(·, X')

i.e. two agents are equivalent exactly when their behaviour profiles
across *all* problems agree.  This is the Yoneda lemma's fully-faithful
embedding, instantiated to agents: an agent's internal state carries no
information beyond its behaviour functor (minimal-sufficiency).

This file formalises BOTH kernels, all `axiom`-free:

* **(a) genuine Yoneda form** (`R_461_yoneda_behavioral_equivalence`):
  for any small category `Agents`, the Yoneda embedding
  `𝔶 : Agents → (Agentsᵒᵖ ⥤ Type)` is fully faithful, so it gives a
  *bijection*
      `(X ≅ X') ≃ (𝔶.obj X ≅ 𝔶.obj X')`,
  reusing Mathlib's `CategoryTheory.yoneda.fullyFaithful`.  Hence
  `Nonempty (X ≅ X') ↔ Nonempty (𝔶.obj X ≅ 𝔶.obj X')`
  (`R_461_iso_iff`): agents are iso iff their behaviour functors are iso.

* **(b) elementary behaviour form**
  (`R_461_behavioral_equivalence_principle`): modelling behaviour directly
  as `Bhv : Agent → (Prob → Set Outcome)`, agents with identical behaviour
  on every problem are behaviourally equal:
      `(∀ p, Bhv X p = Bhv X' p) ↔ Bhv X = Bhv X'`.
  This is the funext form of minimal-sufficiency — the behaviour profile
  is a complete invariant of the agent.

**What is reduced (documented).**  The probability-enriched Yoneda of
R.461's O.13 (agents as profunctors with probabilistic, not `Set`,
values) is *not* formalised: it would need an enriched-category Yoneda
over the cost/probability base, which Mathlib does not provide in the
required form.  The `Set`-valued behaviour functor (b) and the genuine
small-category Yoneda (a) together carry the load-bearing kernel of parts
(b), (c), (d).  Part (a)'s functoriality over a *problem-reduction*
category (R.461 (a), depending on NC.2) is sidestepped by taking the
behaviour profile as a plain indexed family.

**This file is `axiom`-free.**
-/
import Mathlib.CategoryTheory.Yoneda
import Mathlib.CategoryTheory.Functor.FullyFaithful

namespace MIP

namespace YonedaBehavior

open CategoryTheory

/-! ### (a) Genuine Yoneda behavioural-equivalence principle

For a small category `Agents`, the Yoneda embedding sends an agent `X` to
its behaviour functor `Bhv(·, X) = 𝔶.obj X : Agentsᵒᵖ ⥤ Type`.  Yoneda is
fully faithful, so isomorphism of agents is equivalent to isomorphism of
their behaviour functors. -/

universe v u

variable (Agents : Type u) [Category.{v} Agents]

/-- **R.461 (b)(c) — the Yoneda behavioural-equivalence bijection.**

`X ≅ X'` is in natural bijection with `𝔶.obj X ≅ 𝔶.obj X'`: an agent's
isomorphism class is faithfully recorded by its behaviour functor.  This
is `yoneda.fullyFaithful.isoEquiv`. -/
noncomputable def R_461_yoneda_behavioral_equivalence (X X' : Agents) :
    (X ≅ X') ≃ ((yoneda.obj X) ≅ (yoneda.obj X')) :=
  (Yoneda.fullyFaithful (C := Agents)).isoEquiv

/-- **R.461 (c) — agents iso iff behaviour functors iso.**

Stripping to mere existence: there is an isomorphism `X ≅ X'` iff there is
an isomorphism of behaviour functors `𝔶.obj X ≅ 𝔶.obj X'`.  This is the
behavioural-equivalence principle in its cleanest categorical form. -/
theorem R_461_iso_iff (X X' : Agents) :
    Nonempty (X ≅ X') ↔ Nonempty ((yoneda.obj X) ≅ (yoneda.obj X')) :=
  ⟨fun ⟨e⟩ => ⟨yoneda.mapIso e⟩,
   fun ⟨e⟩ => ⟨(Yoneda.fullyFaithful (C := Agents)).preimageIso e⟩⟩

/-- **R.461 (d) — Yoneda is faithful on agents (behaviour determines maps).**

Two simulation morphisms `f, g : X ⟶ X'` that induce the same map of
behaviour functors are equal: behaviour determines the morphism, not just
the object.  This is `yoneda.map_injective`. -/
theorem R_461_behavior_determines_map {X X' : Agents} (f g : X ⟶ X')
    (h : yoneda.map f = yoneda.map g) : f = g :=
  yoneda.map_injective h

/-! ### (b) Elementary behaviour-profile form

Independent of category structure: behaviour is an indexed family
`Bhv : Agent → (Prob → Set Outcome)`.  Two agents with the same behaviour
on every problem are behaviourally equal. -/

section Elementary

variable {Agent : Type*} {Prob : Type*} {Outcome : Type*}

/-- **R.461 (d) — behavioural-equivalence principle (funext form).**

Agents `X, X'` have identical behaviour on *all* problems iff their
behaviour profiles are equal as functions `Prob → Set Outcome`.  This is
minimal-sufficiency: the per-problem behaviour family is a complete
invariant — no hidden internal state can distinguish two agents that act
identically everywhere. -/
theorem R_461_behavioral_equivalence_principle
    (Bhv : Agent → Prob → Set Outcome) (X X' : Agent) :
    (∀ p, Bhv X p = Bhv X' p) ↔ Bhv X = Bhv X' :=
  ⟨funext, fun h p => congrFun h p⟩

/-- **R.461 (c) — extensional behavioural equivalence.**

Spelling minimal-sufficiency at the level of individual outcomes: two
agents are behaviourally equal iff, for every problem `p` and every
outcome `o`, they agree on whether `o` is a behaviour of solving `p`. -/
theorem R_461_behavioral_equivalence_pointwise
    (Bhv : Agent → Prob → Set Outcome) (X X' : Agent) :
    (∀ p o, o ∈ Bhv X p ↔ o ∈ Bhv X' p) ↔ Bhv X = Bhv X' := by
  constructor
  · intro h
    funext p
    ext o
    exact h p o
  · intro h p o
    rw [h]

/-- **R.461 (d) — behaviour as a complete invariant: equal behaviour ⇒
indistinguishable on any test.**

If two agents share a behaviour profile, then for *any* predicate `T` on
behaviour profiles (any behavioural test / evaluation suite), they give
the same verdict.  This is the formal sense in which behaviour evaluation
is *sufficient* to determine the agent's equivalence class. -/
theorem R_461_behavior_sufficient_for_tests
    (Bhv : Agent → Prob → Set Outcome) (X X' : Agent)
    (hEq : Bhv X = Bhv X') (T : (Prob → Set Outcome) → Prop) :
    T (Bhv X) ↔ T (Bhv X') := by
  rw [hEq]

end Elementary

end YonedaBehavior

end MIP
