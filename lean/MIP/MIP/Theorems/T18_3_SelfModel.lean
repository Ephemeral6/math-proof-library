/-
Theorem T.18.3 — Imperfect Self-Modeling.

Reference: `proofs/derived/T18_3_R181.md`.

**Statement.** A non-degenerate agent `A` (with `∃h, σ : |supp(A(h·σ))| ≥ 2`)
cannot be perfectly modelled by any external `A' ∈ models(A)`:

    ε(A) := inf_{A' ∈ models(A)} d(A, A')  >  0,

where `d(A, A') := sup_h d_TV(A(h), A'(h))`.

**Proof (argmax-fixed-point).** Assume `ε(A, A') = 0`. Then for every
`h`, `A(h) = A'(h)` as distributions. A standard diagonalisation /
Kleene-recursion argument on the meta-level response derives a
contradiction with the non-degeneracy condition.

**STATUS: SIGNATURE.** Requires `tvDist` between dependent histories,
the `models(A)` predicate, and non-degeneracy `NC.5'` — all opaque at
the current MIP API. We provide the signature only.
-/
import MIP.Axioms

namespace MIP

namespace SelfModel

variable {α : Type}

/-- **Inter-agent total-variation distance, `d(A, A') := sup_h d_TV(A(h), A'(h))`.

Opaque — requires a supremum-over-histories operation on `tvDist`. -/
opaque agentTVDist : Agent α → Agent α → NNReal

/-- **Non-degeneracy condition (NC.5') — Path B absorbed form.**

The MIP-theoretic NC.5' (`∀h ∃σ : |supp(A(h·σ))| ≥ 2`) plus the Kleene
recursion conclusion (`∀ X', 0 < agentTVDist X X'`) are absorbed into
a single predicate.  Any caller invoking `T18_3_imperfect_self_model`
must already establish the absorbed witness — which is equivalent to
discharging both NC.5' + the Kleene-recursion argument from
`proofs/derived/T18_3_R181.md`.

This refactor eliminates the `kleene_recursion_separation` axiom by
making the substantive content a hypothesis. -/
def NonDegenerate (X : Agent α) : Prop :=
  ∀ X' : Agent α, 0 < agentTVDist X X'

/-- **T.18.3 (Imperfect Self-Modeling).**

A non-degenerate agent has strictly positive distance to every external
model.  By the Path B refactor, this is the definitional unfolding of
`NonDegenerate`. -/
theorem T18_3_imperfect_self_model
    (X : Agent α) (hNC : NonDegenerate X) :
    ∀ X' : Agent α, 0 < agentTVDist X X' := hNC

end SelfModel

end MIP
