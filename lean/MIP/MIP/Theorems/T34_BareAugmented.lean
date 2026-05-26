/-
Theorem T.34 — Bare/Dressed (Bare-Augmented) Decomposition.

Reference: `proofs/derived/A4_grade.md` R.804 ＝ T.34 (A 无条件).

**Statement.** Let `X_base` be an agent satisfying A.1–A.4 with
`K_b := K(X_base)`. Let `X_aug : Σ* → Δ(Σ*)` be an augmentation channel
(not necessarily satisfying A.4). For the modular coupling

    X_total(h) := X_base(h · a),  a ~ X_aug(h)

we have

    𝓛(X_total(h)) = 𝓛(X_base(h · Restr_{K_b}(X_aug(h))))   in d_TV.

**Proof.** Fix one sample `a ∼ X_aug(h)`. By iterated A.4 (applied to
each token `ω ∈ tokens(a) \ K_b`), `𝓛(X_base(h · a)) = 𝓛(X_base(h · Restr a))`.
Take expectation over `a`. □

**Realising "expectation over `a`".** For a PMF-valued source, taking the
expectation of a PMF-valued map `a ↦ X_base(h · a)` over `a ~ X_aug(h)` is
*exactly* the probability monad's bind: `(X_aug h).bind (fun a => …)`. So the
compound output distribution `𝓛(X_total(h))` is the `PMF.bind` of the
augmentation kernel against `X_base ∘ (h · ·)`. The per-sample identity then
lifts to an honest equality of the two compound `PMF`s — not just an upper
bound on `d_TV`, but `d_TV = 0`. This is the faithful, exact form of T.34, and
it closes with no `sorry`.
-/
import MIP.Axioms
import MIP.Theorems.T33_UEA
import Mathlib.Probability.ProbabilityMassFunction.Monad

namespace MIP

open MIP.Axioms

namespace BareAugmented

open MIP.UEA (Restr RestrSpec)

variable {α : Type} {Ω : Type}

/-- **An augmentation channel** is just a function `Σ* → PMF Σ*`, the
same type as `Agent α`. We give it an alias for documentation. -/
abbrev AugChannel (α : Type) : Type := Agent α

/-- **T.34, per-sample form.** For any single augmentation output `a`,
`X_base` cannot distinguish `h · a` from `h · Restr a` — A.4 / L.F (1)
guarantees the K(X_base)-projection is the only thing that matters.

This is the pure-A.4 content of T.34.  The iterated-A.4 step is
extracted from `RestrSpec` (Path B form, replacing the
`restr_collapse` axiom of an earlier draft). -/
theorem T34_per_sample
    (X_base : Agent α) (h a : Str α)
    (hSpec : RestrSpec (α := α) Ω X_base) :
    X_base (extendHist h a) = X_base (extendHist h (Restr X_base a)) :=
  hSpec.2.1 h a

/-- **T.34 (Bare-Augmented Decomposition).**

Taking expectation of the per-sample identity over `a ~ X_aug(h)` gives the
population-level equality of the *compound* output distributions.

Here "expectation over `a ~ X_aug(h)` of the PMF-valued map
`a ↦ X_base(h · a)`" is realised, in the probability monad, as the bind
`PMF.bind (X_aug h) (fun a => X_base (extendHist h a))`. The conclusion is the
equality of two compound `PMF (Str α)`:

    PMF.bind (X_aug h) (fun a => X_base (extendHist h a))
      = PMF.bind (X_aug h) (fun a => X_base (extendHist h (Restr X_base a))).

This is the population-level form of the book's

    𝓛(X_total(h)) = 𝓛(X_base(h · Restr_{K_b}(X_aug(h)))).

Because it is an *equality* of distributions, the total-variation distance
between them is `0` — strictly stronger than (and hence faithful to) the
`d_TV`-statement of T.34.

Proof: the two functions bound against `X_aug h` agree pointwise by
`T34_per_sample`; `funext` upgrades this to function equality, after which the
`bind`s are equal by congruence. No probabilistic machinery beyond
`PMF.bind` is needed. -/
theorem T34_AEE
    (X_base : Agent α) (X_aug : AugChannel α) (h : Str α)
    (hSpec : RestrSpec (α := α) Ω X_base) :
    PMF.bind (X_aug h) (fun a => X_base (extendHist h a))
      = PMF.bind (X_aug h) (fun a => X_base (extendHist h (Restr X_base a))) := by
  -- The two bound functions agree at every sample `a` by the per-sample form.
  have hfun :
      (fun a => X_base (extendHist h a))
        = (fun a => X_base (extendHist h (Restr X_base a))) :=
    funext (fun a => T34_per_sample (Ω := Ω) X_base h a hSpec)
  -- `PMF.bind` is congruent in its function argument.
  rw [hfun]

end BareAugmented

end MIP
