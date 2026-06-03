/-
  STATUS: DISCOVERY
  AGENT: 10
  DIRECTION: Group A.1 — paper-bridge name `shannonEntropy` for the
              activation mass function, definitionally equal to MIP's
              `knowledgeEntropy`.
  SUMMARY:
    The MIP manuscript labels `H_K(X) := -∑ p log p` as *knowledge
    entropy*; the information-theory literature calls the same quantity
    the *Shannon entropy* of `p`. We introduce
        `shannonEntropy p := -∑ ω, (p ω : ℝ) * log (p ω : ℝ)`
    as a standalone function on `Ω → NNReal` and prove the bridge
    `knowledgeEntropy d = shannonEntropy d.p`. The lemma is definitional
    after unfolding both names but worth being explicit since it gives a
    canonical entry point for downstream information-theoretic
    statements that do not want to carry an `ActivationDist` bundle.

    Headline: `knowledgeEntropy_eq_shannonEntropy`.

    As a side-product we record `shannonEntropy_nonneg` (lifted from
    Agent 6) and `shannonEntropy_le_log_card` (lifted from Agent 6 +
    CjNEW13), both packaged at the bare `p`-level so they can be used
    without constructing an `ActivationDist` first.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard

namespace MIP

namespace Agent10

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- **Shannon entropy of a mass function `p : Ω → NNReal`.**

The bare-`p` version of `MIP.knowledgeEntropy`: the paper-bridge name
used in classical information theory.  No normalisation is enforced at
this level — the function is defined for any `p`, and equals the MIP
`knowledgeEntropy` whenever `p` comes from an `ActivationDist`. -/
noncomputable def shannonEntropy (p : Ω → NNReal) : ℝ :=
  -∑ ω, (p ω : ℝ) * Real.log ((p ω : ℝ))

/-- **HEADLINE BRIDGE (Group A.1).** Knowledge entropy is exactly the
Shannon entropy of the underlying mass function.

This is definitional after unfolding both names: it certifies that
`knowledgeEntropy` is *not* a separate quantity from the information-
theoretic Shannon entropy.  Downstream theorems can use either name
without conversion. -/
theorem knowledgeEntropy_eq_shannonEntropy (d : ActivationDist Ω) :
    knowledgeEntropy d = shannonEntropy d.p := rfl

/-- Shannon entropy is nonnegative on any **normalised** mass function.

Lifted from `Agent6.H_K_nonneg` by wrapping `p` into an `ActivationDist`
and unfolding the bridge. -/
theorem shannonEntropy_nonneg
    (p : Ω → NNReal) (hp : ∑ ω, p ω = 1) :
    0 ≤ shannonEntropy p := by
  have h : 0 ≤ knowledgeEntropy ({ p := p, normalized := hp }) :=
    Agent6.H_K_nonneg _
  simpa [knowledgeEntropy_eq_shannonEntropy] using h

/-- Shannon entropy is bounded by `log (Fintype.card Ω)` on any
normalised mass function.  Same lifting as `shannonEntropy_nonneg`. -/
theorem shannonEntropy_le_log_card
    [Nonempty Ω] [DecidableEq Ω]
    (p : Ω → NNReal) (hp : ∑ ω, p ω = 1) :
    shannonEntropy p ≤ Real.log (Fintype.card Ω : ℝ) := by
  have h : knowledgeEntropy ({ p := p, normalized := hp })
              ≤ Real.log (Fintype.card Ω : ℝ) :=
    Agent6.H_K_le_log_card _
  simpa [knowledgeEntropy_eq_shannonEntropy] using h

end Agent10

end MIP
