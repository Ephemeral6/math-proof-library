/-
Result R.112 — Objectivity of the barrier-set cardinality `|B(p)|`
inside the A.3-regime.

Reference: `C:/Users/12729/Desktop/MIP/workspace/frontier_attacks.md` §R.112
(攻击 #9, R.9 升 A 带前提; "前提 A", A.3-regime, 2026 second round).

**Statement.** Restrict attention to agents `A` satisfying A.2 (`R(p) ⊆ K(A)`,
i.e. `N(p,A) < ∞`) *and* the A.3-regime (`K(e) ⊆ K(A)` for every expert
intervention `e`, so meta-cognitive responses can approximate any expert
response).  The natural-language argument (frontier_attacks.md §R.112) is:

  * the barrier set `B(p)` is a maximal independent set (D.2.8) in the
    Reach-graph of `p`;
  * A.2 + A.3-regime make two such agents `A, A'` have *equivalent*
    intervention expressivity, so the A.3-corrected approximation supplies
    a **bijection** `f : B_A(p) → B_{A'}(p)` between the two barrier sets;
  * a bijection between finite sets forces equal cardinality, hence
    `|B_A(p)| = |B_{A'}(p)| =: |B(p)|`, which therefore depends only on the
    intrinsic barrier topology of `p`, **not** on the chosen agent.

**Bundled premise.** The A.3-regime equivalence (an MIP geometric / Reach
fact, NOT formalised here) enters as the explicit hypothesis: the existence
of a bijection `f` between the two agents' barrier sets.  We encode the
**cardinality-invariance kernel**: a bijection between finite sets implies
equal cardinality; and the contrapositive sharpness (unequal cardinalities
rule out any A.3-equivalence bijection).

**This file is `axiom`-free.**  The barrier sets are `Finset`s over an
abstract barrier-type; the bijection is the bundled A.3-regime premise.
-/
import Mathlib.Data.Finset.Card
import Mathlib.Logic.Equiv.Defs
import Mathlib.Data.Fintype.Card

namespace MIP

namespace BarrierObjectivity

variable {β : Type*} [DecidableEq β]

/-- **R.112 — barrier-cardinality objectivity (Finset bijection form).**

Let `B_A, B_A' : Finset β` be the barrier sets of `p` as seen by two agents
`A, A'` in the A.3-regime.  If the A.3-regime supplies a bijection between
them — encoded as a function `f : β → β` that maps `B_A` *onto* `B_A'`
injectively on `B_A` — then the two cardinalities coincide:

    |B_A(p)| = |B_A'(p)| . -/
theorem R_112_card_invariant
    (B_A B_A' : Finset β) (f : β → β)
    (h_maps : ∀ b ∈ B_A, f b ∈ B_A')
    (h_inj : ∀ b₁ ∈ B_A, ∀ b₂ ∈ B_A, f b₁ = f b₂ → b₁ = b₂)
    (h_surj : ∀ b' ∈ B_A', ∃ b ∈ B_A, f b = b') :
    B_A.card = B_A'.card := by
  -- `f` is injective on `B_A` and its image is exactly `B_A'`, so the
  -- cardinality is preserved (image-of-injective + double inclusion).
  have hinjOn : Set.InjOn f (B_A : Set β) := by
    intro b₁ hb₁ b₂ hb₂ h
    exact h_inj b₁ hb₁ b₂ hb₂ h
  have h_image : B_A.image f = B_A' := by
    apply Finset.Subset.antisymm
    · intro x hx
      rw [Finset.mem_image] at hx
      obtain ⟨b, hb, rfl⟩ := hx
      exact h_maps b hb
    · intro x hx
      obtain ⟨b, hb, hfb⟩ := h_surj x hx
      rw [Finset.mem_image]
      exact ⟨b, hb, hfb⟩
  rw [← h_image, Finset.card_image_of_injOn hinjOn]

omit [DecidableEq β] in
/-- **R.112 — equiv form.**

If the A.3-regime equivalence is presented as a genuine type-level
bijection `e : B_A ≃ B_A'` (over the coerced finite subtypes), the
cardinalities coincide.  This is the `Fintype.card` restatement of the
same fact. -/
theorem R_112_card_invariant_equiv
    (B_A B_A' : Finset β) (e : (B_A : Finset β) ≃ (B_A' : Finset β)) :
    B_A.card = B_A'.card := by
  have h1 : Fintype.card (B_A : Finset β) = B_A.card := Fintype.card_coe B_A
  have h2 : Fintype.card (B_A' : Finset β) = B_A'.card := Fintype.card_coe B_A'
  rw [← h1, ← h2]
  exact Fintype.card_congr e

/-- **R.112 — contrapositive sharpness.**

If two agents report *different* barrier-set cardinalities, then no
A.3-regime equivalence bijection between their barrier sets can exist.
This is the rigorous content of "in the A.3-regime, `|B(p)|` is
agent-independent": a discrepancy certifies that at least one agent leaves
the regime. -/
theorem R_112_no_bijection_if_card_ne
    (B_A B_A' : Finset β) (h_ne : B_A.card ≠ B_A'.card) :
    ¬ ∃ f : β → β,
        (∀ b ∈ B_A, f b ∈ B_A') ∧
        (∀ b₁ ∈ B_A, ∀ b₂ ∈ B_A, f b₁ = f b₂ → b₁ = b₂) ∧
        (∀ b' ∈ B_A', ∃ b ∈ B_A, f b = b') := by
  rintro ⟨f, h_maps, h_inj, h_surj⟩
  exact h_ne (R_112_card_invariant B_A B_A' f h_maps h_inj h_surj)

omit [DecidableEq β] in
/-- **R.112 — transitivity of the objective value.**

Objectivity is an equivalence-class statement: if `A` and `A'` agree
(`|B_A| = |B_A'|`) and `A'` and `A''` agree, then `A` and `A''` agree.
Hence "the" objective `|B(p)|` is well-defined across the whole
A.3-regime class. -/
theorem R_112_objective_transitive
    (B_A B_A' B_A'' : Finset β)
    (h₁ : B_A.card = B_A'.card) (h₂ : B_A'.card = B_A''.card) :
    B_A.card = B_A''.card := h₁.trans h₂

end BarrierObjectivity

end MIP
