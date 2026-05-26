/-
Result R.13 — An AI can perform meta-cognitive intervention on another AI;
the intervention's effect depends only on its CONTENT, not on the source agent.

Reference: `proofs/derived/R13.md` and `proofs/derived/A_grade.md` R.13
(A 级, deps D.1.5, D.1.7, A.3 修正版, 2026 derived branch).

**Statement.**  By D.1.5 a meta-cognitive intervention `m ∈ M` is recognised
purely by a *content* predicate `I_domain(m) < η` — a property of `m` as a
string — and **not** by who produced it.  By D.1.7 the generalized
intervention count `N(p, X, ·)` and the resulting effect on the solver `X`
depend only on the content `m` that is fed in.  Therefore if two *source
agents* `Y` and `Y'` emit the SAME content `m` (with `m ∈ M`), the effect on
`X` is identical: a human questioner and an AI questioner producing the same
`m` are indistinguishable to the axiom system.

**Lean kernel.**  We model the situation by:
* a type `Content` of intervention strings, with membership predicate
  `inM : Content → Prop` (the `D.1.5` recognition condition);
* an `effect : Content → D` function that, by construction, takes ONLY the
  content as input — it has no `source` argument.

"Source-independence" then becomes a *factorization* statement:  the observed
effect of `(source, content)` is `effect content`, manifestly free of
`source`.  We prove:

1. `R_13_source_independent`: for any two sources `Y Y'` emitting the same
   `m` with `inM m`, the effects coincide (`effect m = effect m`).
2. `R_13_factors_through_content`: if a hypothetical *source-aware* observable
   `N` factors through content (`N Y m = effect m` for all `Y`), then it is
   constant in the source argument.
3. `R_13_human_AI_symmetry`: the human/AI symmetry corollary (D.1.7), stated
   for a two-element source type `Bool` (`false = human`, `true = AI`).

**This file is `axiom`-free.**  It imports only `Mathlib` and bundles the
D.1.5 / D.1.7 content-recognition semantics as the explicit data
`(inM, effect)`.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace AIMetacogOnAI

variable {Content : Type*} {D : Type*} {Source : Type*}

/-- **R.13 core — source-independence of an intervention's effect.**

The effect observable is given as `effect : Content → D`, depending ONLY on
the content `m` (this is the D.1.5 / D.1.7 modelling decision: `M`-membership
and the intervention count are functions of the string `m`, never of its
producer).  Hence for any two source agents `Y Y'` that emit the *same*
admissible content `m` (`inM m`), the effect on the solver is identical. -/
theorem R_13_source_independent
    (inM : Content → Prop) (effect : Content → D)
    (_Y _Y' : Source) (m : Content) (_hY : inM m) :
    effect m = effect m :=
  rfl

/-- **R.13 — factorization through content ⟹ source-agnostic.**

This is the substantive form.  Suppose a *source-aware* generalized
intervention observable `N : Source → Content → D` (think `N(p, X, Y)` with
`p, X` fixed and the source `Y` exposed) is claimed to factor through the
content via `effect`, i.e. for every source `Y` and admissible content `m`,
`N Y m = effect m`.  Then `N` is constant in its source argument: swapping the
source that produced `m` cannot change the value.

This is exactly the R.13 conclusion: because `m ∈ M` is recognised by content
alone (D.1.5) and the effect is determined by the content fed to `X` (D.1.7),
`N(p, X, Y)` is invariant under replacing the source `Y` by any `Y'`. -/
theorem R_13_factors_through_content
    (inM : Content → Prop) (effect : Content → D) (N : Source → Content → D)
    (hfact : ∀ (Y : Source) (m : Content), inM m → N Y m = effect m)
    (Y Y' : Source) (m : Content) (hm : inM m) :
    N Y m = N Y' m := by
  rw [hfact Y m hm, hfact Y' m hm]

/-- **R.13 — content determines effect (the contrapositive view).**

If two interventions yield *different* effects then they must have differed in
content; equivalently, equal content forces equal effect.  Pure consequence of
`effect : Content → D` having no source argument: this is the precise sense in
which "membership in `M` and the effect depend on the content `m`, not the
source." -/
theorem R_13_equal_content_equal_effect
    (effect : Content → D) (m m' : Content) (h : m = m') :
    effect m = effect m' := by
  rw [h]

/-- **R.13 — human / AI questioner symmetry (D.1.7).**

Concrete instance with a two-element source type `Bool`
(`false ↦ human questioner H`, `true ↦ AI questioner A`).  If the generalized
intervention observable factors through content, then a human questioner and
an AI questioner emitting the same admissible content `m` are
indistinguishable from `X`'s viewpoint: `N H m = N A m`.  The axiom system
draws no distinction between "human guides AI" and "AI guides AI". -/
theorem R_13_human_AI_symmetry
    (inM : Content → Prop) (effect : Content → D) (N : Bool → Content → D)
    (hfact : ∀ (Y : Bool) (m : Content), inM m → N Y m = effect m)
    (m : Content) (hm : inM m) :
    N false m = N true m :=
  R_13_factors_through_content inM effect N hfact false true m hm

end AIMetacogOnAI

end MIP
