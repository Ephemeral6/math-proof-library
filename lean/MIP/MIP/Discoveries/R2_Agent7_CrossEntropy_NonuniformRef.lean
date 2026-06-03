/-
  STATUS: DISCOVERY
  AGENT: R2-7
  DIRECTION: Generalised H_K + KL identity for a non-uniform reference
              distribution.
  SUMMARY:
    Round 1 (Agent 10) proved the headline identity at the uniform
    reference:
        knowledgeEntropy d + KL_to_uniform_dist d = log |Ω|.

    The natural generalisation is: for an arbitrary strictly-positive
    reference distribution `q`, the rearrangement
        crossEntropy d q = knowledgeEntropy d + klDiv d q
    (Agent10_CrossEntropy.crossEntropy_eq_entropy_add_KL) becomes the
    statement of the H_K-plus-KL identity, except that the "constant
    log |Ω|" right-hand side is replaced by `crossEntropy d q`, which
    *depends on d* in general.

    Key results of this file:

      • `H_K_plus_KL_to_q_eq_crossEntropy` — the general identity, a
        direct restatement of Agent 10's decomposition with all three
        terms on the same side. This is the cleanest single-equation
        bridge to an arbitrary positive reference distribution `q`.

      • `crossEntropy_uniform_const` — when `q = uniformDist Ω`, the
        cross-entropy is the constant `log |Ω|`, recovering Round 1's
        headline as a special case.

      • `H_K_plus_KL_to_uniform_via_crossEntropy` — bridge: combining
        the general identity at `q = uniformDist Ω` with the cross-
        entropy collapse gives back Agent 10's `H_K + KL_to_uniform =
        log |Ω|` via the strictly-positive `q` route. This is a
        cross-check between the two formalisations.

      • `crossEntropy_uniform_is_d_independent` — the characterising
        property of the uniform reference: `crossEntropy d (uniform)`
        does not depend on `d`. We package this as a transport lemma
        between any two `d1, d2`.

    The reverse direction "constant cross-entropy ⟹ q is uniform" is
    deliberately *not* attempted: it requires Jensen-equality-type
    arguments at the "varying d" level (you need to pick d concentrated
    at any ω₀ and observe `log q ω₀` constant in ω₀), and the
    `Real.log` injectivity step requires a strict-positivity hypothesis
    on `q` that complicates the statement. We record the forward
    implication as the main DISCOVERY.

    No new Mathlib infrastructure; everything is algebraic rearrangement
    of the Round 1 identities.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard
import MIP.Discoveries.Agent10_CrossEntropy
import MIP.Discoveries.Agent10_KLToUniform_Dist

namespace MIP

namespace R2_Agent7_CrossEntropy_NonuniformRef

open scoped BigOperators
open MIP.Agent10 (crossEntropy klDiv crossEntropy_eq_entropy_add_KL
  crossEntropy_uniform_eq_log_card KL_to_uniform_dist
  H_K_plus_KL_to_uniform_eq_log_card)

variable {Ω : Type} [Fintype Ω]

/-- **HEADLINE (generalised identity).**

For any normalised activation distribution `d` and any strictly-positive
reference distribution `q`, the cross-entropy decomposes as the entropy
plus KL divergence — but stated as an *identity* on the H_K + KL side:

    knowledgeEntropy d + klDiv d q  =  crossEntropy d q.

This is the H_K + KL = (reference-dependent constant) form. When `q` is
strictly positive (otherwise log 0 indeterminacy intrudes), the right-
hand side is a well-defined quantity. -/
theorem H_K_plus_KL_to_q_eq_crossEntropy
    (d q : ActivationDist Ω)
    (h_q_pos : ∀ ω, 0 < (q.p ω : ℝ)) :
    knowledgeEntropy d + klDiv d q = crossEntropy d q := by
  have := crossEntropy_eq_entropy_add_KL d q h_q_pos
  linarith

/-- **Uniform-reference cross-entropy is the constant `log |Ω|`.**

This is the rephrasing of Agent10.crossEntropy_uniform_eq_log_card: when
`q` is the uniform distribution, `crossEntropy d (uniformDist Ω)` is
independent of `d` and equals `log (Fintype.card Ω)`. -/
theorem crossEntropy_uniform_const
    [Nonempty Ω] (d : ActivationDist Ω) :
    crossEntropy d (Agent6.uniformDist Ω) = Real.log (Fintype.card Ω : ℝ) :=
  crossEntropy_uniform_eq_log_card d

/-- **Uniform-reference H_K + KL = log |Ω| via the cross-entropy route.**

Combining the general identity (`H_K_plus_KL_to_q_eq_crossEntropy`) with
the cross-entropy collapse at the uniform (`crossEntropy_uniform_const`)
gives Round 1's headline identity via an alternative derivation.

Verification: the Round 1 file `Agent10_KLToUniform_Dist` defines
`KL_to_uniform_dist d := log |Ω| - knowledgeEntropy d` algebraically (not
as `∑ p log (p / (1/m))`), so this is a *cross-check* between the two
formalisations of "KL to uniform" — the two-sum form `klDiv d (uniformDist)`
and the algebraic form `KL_to_uniform_dist d`. -/
theorem H_K_plus_KL_to_uniform_via_crossEntropy
    [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω) :
    knowledgeEntropy d + klDiv d (Agent6.uniformDist Ω)
      = Real.log (Fintype.card Ω : ℝ) := by
  have h_q_pos : ∀ ω, 0 < ((Agent6.uniformDist Ω).p ω : ℝ) := by
    intro ω
    show ((Agent6.uniformMass Ω : NNReal) : ℝ) > 0
    rw [Agent6.uniformMass_coe]
    have : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
    positivity
  have h1 : knowledgeEntropy d + klDiv d (Agent6.uniformDist Ω)
              = crossEntropy d (Agent6.uniformDist Ω) :=
    H_K_plus_KL_to_q_eq_crossEntropy d (Agent6.uniformDist Ω) h_q_pos
  rw [h1, crossEntropy_uniform_const d]

/-- **Two-distribution KL-to-uniform equals the algebraic Round 1 form.**

The two-sum KL-divergence `klDiv d (uniformDist Ω)` and the algebraic
`KL_to_uniform_dist d := log |Ω| - knowledgeEntropy d` agree. This is a
cross-check between Agent 10's two formalisations. -/
theorem klDiv_to_uniform_eq_KL_to_uniform_dist
    [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω) :
    klDiv d (Agent6.uniformDist Ω) = KL_to_uniform_dist d := by
  have h1 := H_K_plus_KL_to_uniform_via_crossEntropy d
  have h2 := H_K_plus_KL_to_uniform_eq_log_card d
  linarith

/-- **Uniform-reference cross-entropy is d-independent (transport form).**

For any two activation distributions `d1, d2` and the uniform reference,
the two cross-entropies coincide. This is the defining property of the
uniform reference: it gives a *d-independent* cross-entropy.

Sharpened theorem ("characterisation of uniform-yielding-const") is
deliberately *not* attempted — the reverse implication requires
Jensen-equality manipulations that complicate the proof beyond clean
Mathlib reach. -/
theorem crossEntropy_uniform_is_d_independent
    [Nonempty Ω] (d1 d2 : ActivationDist Ω) :
    crossEntropy d1 (Agent6.uniformDist Ω)
      = crossEntropy d2 (Agent6.uniformDist Ω) := by
  rw [crossEntropy_uniform_const d1, crossEntropy_uniform_const d2]

/-- **Per-distribution gap reads as KL.**

The gap `crossEntropy d q  -  knowledgeEntropy d` equals the KL
divergence `klDiv d q` under positivity of `q`. This is the
information-theoretic reading: the "mismatch cost" of using code `q`
when the source is `d`. -/
theorem crossEntropy_sub_entropy_eq_KL
    (d q : ActivationDist Ω)
    (h_q_pos : ∀ ω, 0 < (q.p ω : ℝ)) :
    crossEntropy d q - knowledgeEntropy d = klDiv d q := by
  have := H_K_plus_KL_to_q_eq_crossEntropy d q h_q_pos
  linarith

end R2_Agent7_CrossEntropy_NonuniformRef

end MIP
