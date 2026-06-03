/-
  STATUS: OBSERVATION
  AGENT: 6
  DIRECTION: Group 4 — T.8 "simplifies at the H_K extremes" claim has no
             formal counterpart at the concrete-model level.
  SUMMARY:
    The book's natural-language reading of T.8 says `N ≈ Φ₀ · Z`
    simplifies at the two entropy extremes: at `H_K = 0` ("pure expert")
    and at `H_K = log |K|` ("pure generalist").  We document — as a
    Lean theorem about the *formal model* — that this claim has no
    formal counterpart at the concrete state-sequence model used here.

    The reason: in `MIP/Defs/StateSequence.lean` the impedance and its
    bounds are defined as
        Z       := 0
        Z_min   := 0
        Z_max   := ⊤
    so `Φ₀ · Z = 0` identically, independent of `H_K`.  Whatever value
    `H_K(d)` takes — `0`, `log |Ω|`, or anything in between — the Ohm
    form is degenerate.

    Hence the NL "simplification at H_K extremes" is invisible to the
    formal model.  We record this as an OBSERVATION so future agents
    don't chase a formal version of the claim at this layer.
-/
import MIP.Axioms
import MIP.Defs.Knowledge
import MIP.Defs.StateSequence

namespace MIP

namespace Agent6

open MIP

variable {α Ω : Type} [Fintype Ω]

/-- **OBSERVATION (Group 4).** In the concrete state-sequence model, the
"Ohm-law-like product" `Φ₀ · Z` is identically `0`, regardless of the
agent / problem / knowledge entropy.  Symbolically:

    `(Phi0 X p) * Z X p = 0`   for every `X, p`.

So the NL "T.8 simplifies at `H_K = 0`" and "T.8 simplifies at
`H_K = log |K|`" do not produce inequivalent formal predictions at this
layer — both endpoints give the *same* trivial equation `LHS = 0`. -/
theorem Phi0_mul_Z_eq_zero (X : Agent α) (p : Problem α) :
    (Phi0 X p) * Z X p = 0 := by
  unfold Z
  simp

/-- **OBSERVATION (Group 4, restatement).** The "Ohm-law product"
`Φ₀ · Z_max` is degenerate the other way: when `Phi0 ≠ 0` it is `⊤`,
when `Phi0 = 0` it is `0`.  Either way it does not record any
entropy information. -/
theorem Phi0_mul_Z_max_dichotomy (X : Agent α) (p : Problem α) :
    (Phi0 X p) * Z_max X p = 0 ∨ (Phi0 X p) * Z_max X p = ⊤ := by
  unfold Z_max
  by_cases hP : Phi0 X p = 0
  · left
    rw [hP]
    simp
  · right
    exact ENNReal.mul_top hP

/-- **OBSERVATION (Group 4, the "no formal counterpart" claim).** The
`Φ₀ · Z` product is independent of any entropy data of an activation
distribution `d`.  Formally: for any two distributions `d₁, d₂`, the
product is the same. -/
theorem Phi0_mul_Z_indep_of_dist (X : Agent α) (p : Problem α)
    (_d₁ _d₂ : ActivationDist Ω) :
    (Phi0 X p) * Z X p = (Phi0 X p) * Z X p := rfl

/-! ### A clean restatement: H_K extremes are entropy-only facts in the
    formal model.

The natural-language T.8 hopes for a *coupled* statement of the form
"H_K = endpoint ⟹ specific Ohm-law form".  In this model there is no
such coupling: `H_K` is a function on `ActivationDist Ω` only, while
the Ohm-law form is a function on `Agent α × Problem α` only, and the
two spaces are formally disjoint (no opaque coupling in `Axioms.lean`).

Concretely: `H_K(d)` does not appear in any axiom that constrains
`Phi0 X p` or `Z X p`.
-/

/-- The Φ₀ · Z product does not depend on any `ActivationDist Ω` data.
A trivial Lean statement, recorded here to make explicit the lack of
formal coupling. -/
theorem Phi0_mul_Z_const_in_d (X : Agent α) (p : Problem α) :
    ∀ d : ActivationDist Ω, (Phi0 X p) * Z X p = (Phi0 X p) * Z X p :=
  fun _ => rfl

end Agent6

end MIP
