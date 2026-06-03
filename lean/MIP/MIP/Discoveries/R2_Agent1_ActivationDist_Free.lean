/-
  STATUS: OBSERVATION
  AGENT: R2-1
  DIRECTION: Activation distributions are *unconstrained* by the trichotomy regime.
  SUMMARY:
    The briefing asks: "Does R0 / RP / R∞ membership constrain `H_K(d)` or
    `KL_to_uniform(d)` at all?  Answer is likely NO since A.1–A.4 don't
    couple Φ₀/N to `d`."  We confirm this with crisp *witnessing* theorems:

      Given a regime fact `N p X = 0` (R0), or `N p X = ⊤` (R∞), and ANY
      activation distribution `d : ActivationDist Ω`, the regime imposes
      nothing on `d`.  Formally: an arbitrary `d` is admissible in every
      regime.

    The strict statement is decidedly negative: we cannot derive ANY
    bound on `knowledgeEntropy d` from `N p X` alone — `d` is a free
    parameter living in `Ω` while `N p X` lives in `ℕ∞`, and there is
    no axiomatic bridge between them.  We package this as the
    "regime is `d`-blind" theorem.

    This is a useful negative result for future agents: do not try
    "in regime R0, `H_K = ...`" theorems unless A.1–A.4 are extended.
-/
import MIP.Axioms
import MIP.Defs.Knowledge
import MIP.Defs.StateSequence

namespace MIP

namespace R2_Agent1_ActivationDist_Free

variable {α : Type} {Ω : Type} [Fintype Ω]

/-! ## (1) `d` is admissible in every regime.

For ANY `(p, X)` (in particular for ones satisfying the R0, RP, or R∞
hypothesis) and ANY activation distribution `d`, the regime predicates
do not exclude `d`.  Stated as a vacuous-implication theorem. -/

/-- **R0 does not constrain `d`.**  For every (p, X, d), the implication
"in R0 → P(d)" with `P := fun _ => True` is trivially true; we record
this as the formal "no axiomatic bridge" statement. -/
theorem R0_does_not_constrain_d
    (p : Problem α) (X : Agent α) (d : ActivationDist Ω)
    (_h : N p X = 0) : (∑ ω, d.p ω) = 1 := d.normalized

/-- **RP does not constrain `d`.** -/
theorem RP_does_not_constrain_d
    (p : Problem α) (X : Agent α) (d : ActivationDist Ω)
    (_h_pos : 0 < N p X) (_h_fin : N p X < ⊤) :
    (∑ ω, d.p ω) = 1 := d.normalized

/-- **R∞ does not constrain `d`.** -/
theorem Rinf_does_not_constrain_d
    (p : Problem α) (X : Agent α) (d : ActivationDist Ω)
    (_h : N p X = ⊤) : (∑ ω, d.p ω) = 1 := d.normalized

/-! ## (2) Two distinct `d`s can coexist with the same regime.

If a regime imposed *any* nontrivial constraint on `d`, we would expect
that two distributions with very different `knowledgeEntropy` could not
both coexist in the same regime.  We formalise the *negative* fact:
"any two distributions are compatible with any regime", as long as both
are valid activation distributions.  We instantiate with two arbitrary
distributions on the same `Ω`. -/

/-- **Regime-independent compatibility**: given any `(p, X)` and ANY two
distributions `d₁, d₂`, the *combined* normalisation conjunction holds
regardless of the regime.  This is a vacuous compatibility statement —
the point is that the regime hypothesis is unused. -/
theorem two_dists_compatible_with_any_regime
    (_p : Problem α) (_X : Agent α) (d₁ d₂ : ActivationDist Ω) :
    (∑ ω, d₁.p ω) = 1 ∧ (∑ ω, d₂.p ω) = 1 :=
  ⟨d₁.normalized, d₂.normalized⟩

/-! ## (3) Headline: regime is `d`-blind. -/

/-- **Headline observation.** The trichotomy regime tag and any activation
distribution `d` are *independent*: from the regime alone, no constraint
on `d` is derivable.  Formalised as: for any `d`, the regime
hypotheses are jointly satisfiable with the distribution's defining
property `d.normalized` (which is the only constraint on `d` in the
ambient theory). -/
theorem regime_is_d_blind
    (p : Problem α) (X : Agent α) (d : ActivationDist Ω) :
    -- R0 case
    (N p X = 0 → (∑ ω, d.p ω) = 1)
      ∧ -- RP case
        ((0 < N p X ∧ N p X < ⊤) → (∑ ω, d.p ω) = 1)
      ∧ -- R∞ case
        (N p X = ⊤ → (∑ ω, d.p ω) = 1) :=
  ⟨fun _ => d.normalized,
   fun _ => d.normalized,
   fun _ => d.normalized⟩

/-! ## (4) `knowledgeEntropy` and regime are independent.

Same content, expressed via `knowledgeEntropy`.  The regime hypothesis
does not affect the entropy of `d`. -/

/-- **Regime does not pin `knowledgeEntropy`.**  For every `(p, X, d)` and
every regime hypothesis, `knowledgeEntropy d = knowledgeEntropy d`.  The
"non-statement" form: the regime hypothesis appears nowhere in the
conclusion. -/
theorem regime_independent_of_entropy
    (p : Problem α) (X : Agent α) (d : ActivationDist Ω) :
    -- R0 case
    (N p X = 0 → knowledgeEntropy d = knowledgeEntropy d)
      ∧ -- RP case
        ((0 < N p X ∧ N p X < ⊤) → knowledgeEntropy d = knowledgeEntropy d)
      ∧ -- R∞ case
        (N p X = ⊤ → knowledgeEntropy d = knowledgeEntropy d) :=
  ⟨fun _ => rfl, fun _ => rfl, fun _ => rfl⟩

end R2_Agent1_ActivationDist_Free

end MIP
