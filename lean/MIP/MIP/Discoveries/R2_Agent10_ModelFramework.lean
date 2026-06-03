/-
  STATUS: DISCOVERY
  AGENT: R2-10
  DIRECTION: Axiom independence — framework for explicit `MIPModel`
             constructions that satisfy various subsets of {A.1, A.2, A.3, A.4}.

  SUMMARY:
    The four MIP axioms `A.1`–`A.4` (in `MIP/Axioms.lean`) constrain the
    opaque symbols `N`, `Phi0`, `K`, `R`, `demandFamily`, `expertKnowledge`,
    `Cₑ`, `MetaSet`, `tokenReplace`, `tvDist`. To show that no proper subset
    of the four axioms implies the rest, the standard technique is to
    construct, for each axiom `A_i`, an explicit *model* (a concrete choice
    of all those symbols on small types `α`, `Ω`) satisfying every axiom
    except `A_i`.

    The user requested PAIRWISE independence: for each pair `(A_i, A_j)`,
    a model satisfying the other two but violating both `A_i` and `A_j`.

    Crucially, the project's opaque symbols `MIP.N`, `MIP.Phi0`, … cannot
    be redefined inside the project (doing so would amount to a new
    axiom). So we instead introduce a *model structure* `MIPModel`
    bundling concrete copies of all the relevant symbols, and we
    *re-state* each axiom as a `Prop` on the bundle. Then a concrete
    model is a term of `MIPModel` together with proofs about which
    `satisfies*` propositions hold. No new `axiom` is introduced.

    This file defines:

      * `MIPModel α Ω` — the bundling structure.
      * `MIPModel.satisfiesA1 / satisfiesA2 / satisfiesA3 / satisfiesA4` —
        the axiom statements transposed onto the model.
      * `MIPModel.violatesA1 / violatesA2 / violatesA3 / violatesA4` —
        the negated axiom statements.

    Concrete instances satisfying various subsets are constructed in
    the companion files
      `R2_Agent10_Model_NoA1A2.lean`
      `R2_Agent10_Model_NoA1A4.lean`
      `R2_Agent10_Model_NoA2A4.lean`
    each of which closes one of the three cleanly-doable pairwise
    independences with zero `sorry` and zero new `axiom`.

    The three A.3-involving pairs are addressed in OBSERVATION files
    (see summary) because A.3's existential over meta-cognitive
    sequences with a log-bound is delicate to falsify concretely on
    small types; sketches with partial proofs are recorded.

  NOTE: this is a *meta-theoretic* exercise. The `MIPModel` structure has
  no relationship to the opaque `MIP.N` etc.; it stipulates its own
  fields. The point is to show that the axiom *statements*
  (parametrised by the field values) are consistent with various truth
  assignments — i.e., the axioms are mutually independent.
-/
import MIP.Axioms
import Mathlib.Probability.ProbabilityMassFunction.Constructions

namespace MIP

namespace R2_Agent10_ModelFramework

/-- A `MIPModel` is a concrete choice of all the opaque-symbol-style data
referenced by axioms A.1–A.4, packaged into a single structure. The
types `α` (alphabet) and `Ω` (knowledge universe) are parameters; the
fields are exactly the non-derived opaque symbols of `MIP.Axioms`.

We do NOT include `solnProj` here — it is not referenced by any of the
four axioms A.1–A.4. -/
structure MIPModel (α : Type) (Ω : Type) where
  /-- Per-(problem, agent) emergence degree. -/
  N : Problem α → Agent α → ℕ∞
  /-- Per-(agent, problem) initial emergence potential. -/
  Phi0 : Agent α → Problem α → ENNReal
  /-- Knowledge space of an agent. -/
  K : Agent α → Set Ω
  /-- Demand family of a problem. -/
  demandFamily : Problem α → Set (Set Ω)
  /-- Knowledge content of an expert intervention. -/
  expertKnowledge : Str α → Set Ω
  /-- Knowledge density of an expert intervention. -/
  Cₑ : Str α → NNReal
  /-- Meta-cognitive intervention set. -/
  MetaSet : Set (Str α)
  /-- Token-replacement operator. -/
  tokenReplace : Ω → Str α → Str α
  /-- Total-variation distance between two response distributions. -/
  tvDist : PMF (Str α) → PMF (Str α) → NNReal

namespace MIPModel

variable {α : Type} {Ω : Type}

/-! ## Axiom statements transposed onto a `MIPModel`. -/

/-- The `A.1` statement parametrised by a model:
`∀ p X, N p X = 0 ↔ Phi0 X p = 0`. -/
def satisfiesA1 (M : MIPModel α Ω) : Prop :=
  ∀ (p : Problem α) (X : Agent α), M.N p X = 0 ↔ M.Phi0 X p = 0

/-- The `A.2` statement parametrised by a model:
`∀ p X, N p X ≠ ⊤ ↔ ∃ R' ∈ demandFamily p, R' ⊆ K X`. -/
def satisfiesA2 (M : MIPModel α Ω) : Prop :=
  ∀ (p : Problem α) (X : Agent α),
    M.N p X ≠ ⊤ ↔ ∃ R' ∈ M.demandFamily p, R' ⊆ M.K X

/-- The `A.3` statement parametrised by a model. The (e ∉ MetaSet,
expertKnowledge ⊆ K X, ε > 0) hypotheses are explicit. -/
def satisfiesA3 (M : MIPModel α Ω) : Prop :=
  ∀ (X : Agent α) (e : Str α) (h : Str α) (ε : NNReal) (_ : 0 < ε)
    (_ : e ∉ M.MetaSet) (_ : M.expertKnowledge e ⊆ M.K X),
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ M.MetaSet)
        ∧ (ms.length : ℝ) ≤ (M.Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ M.tvDist (X (extendHist h e))
              (X (extendHist h (ms.foldl List.append []))) ≤ ε

/-- The `A.4` statement parametrised by a model:
`∀ X ω h, ω ∉ K X → X h = X (tokenReplace ω h)`. -/
def satisfiesA4 (M : MIPModel α Ω) : Prop :=
  ∀ (X : Agent α) (ω : Ω) (h : Str α),
    ω ∉ M.K X → X h = X (M.tokenReplace ω h)

/-- Negations: `violatesAi := ¬ satisfiesAi`. -/
def violatesA1 (M : MIPModel α Ω) : Prop := ¬ satisfiesA1 M
def violatesA2 (M : MIPModel α Ω) : Prop := ¬ satisfiesA2 M
def violatesA3 (M : MIPModel α Ω) : Prop := ¬ satisfiesA3 M
def violatesA4 (M : MIPModel α Ω) : Prop := ¬ satisfiesA4 M

end MIPModel

end R2_Agent10_ModelFramework

end MIP
