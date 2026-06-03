/-
  STATUS: DISCOVERY
  AGENT: 6
  DIRECTION: Group 2.3 — `H_K(d) ≤ log (Fintype.card Ω)` (max-entropy bound).
  SUMMARY:
    Jensen for `Real.negMulLog` (concave on `[0, ∞)`).  Mathlib provides
    `Real.concaveOn_negMulLog`; project sibling `CjNEW13_entropy_le_log`
    already executes the Jensen argument for arbitrary probability
    vectors `q : ι → ℝ`.  We lift it to `knowledgeEntropy` by
    `knowledgeEntropy d = Hpi (fun ω => (d.p ω : ℝ))`.

    Headline: `H_K_le_log_card`.

    Auxiliary reverse direction (Group 2.4 reverse): the *uniform*
    distribution attains the bound.  We state this as a separate clean
    lemma; the forward equality direction of the iff is the hard Jensen
    equality case which is left as an OBSERVATION in
    `Agent6_HK_Uniform_Saturation.lean`.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Conjectures.CjNEW13_HpiMaxAtTStar

namespace MIP

namespace Agent6

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- The activation-distribution masses, lifted to `ℝ`. -/
noncomputable def pR (d : ActivationDist Ω) : Ω → ℝ := fun ω => (d.p ω : ℝ)

/-- `knowledgeEntropy` equals `CjNEW13.Hpi` applied to the masses. -/
lemma knowledgeEntropy_eq_Hpi [DecidableEq Ω] (d : ActivationDist Ω) :
    knowledgeEntropy d = CjNEW13.Hpi (pR d) := by
  rw [knowledgeEntropy_eq_sum_negMulLog]
  rfl

/-- The lifted masses are nonneg. -/
lemma pR_nonneg (d : ActivationDist Ω) : ∀ ω, 0 ≤ pR d ω := by
  intro ω; exact (d.p ω).coe_nonneg

/-- The lifted masses sum to `1` in `ℝ`. -/
lemma pR_sum (d : ActivationDist Ω) : ∑ ω, pR d ω = 1 := by
  unfold pR
  have : ((∑ ω, d.p ω : NNReal) : ℝ) = ∑ ω, (d.p ω : ℝ) := by
    push_cast; rfl
  rw [← this, d.normalized]; simp

/-- **HEADLINE DISCOVERY (Group 2.3).** Knowledge entropy is bounded by
the log of the ambient cardinality:

    `knowledgeEntropy d ≤ Real.log (Fintype.card Ω)`.

Proof: concave Jensen on `Real.negMulLog`, packaged in
`CjNEW13_entropy_le_log`.
-/
theorem H_K_le_log_card [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω) :
    knowledgeEntropy d ≤ Real.log (Fintype.card Ω : ℝ) := by
  rw [knowledgeEntropy_eq_Hpi d]
  exact CjNEW13.CjNEW13_entropy_le_log (pR d) (pR_nonneg d) (pR_sum d)

/-! ## Reverse direction (Group 2.4 reverse): uniform attains the bound. -/

/-- The uniform mass as an NNReal. -/
noncomputable def uniformMass (Ω : Type) [Fintype Ω] : NNReal :=
  (1 : NNReal) / (Fintype.card Ω : NNReal)

omit [Fintype Ω] in
lemma uniformMass_coe [Fintype Ω] [Nonempty Ω] :
    ((uniformMass Ω : NNReal) : ℝ) = 1 / (Fintype.card Ω : ℝ) := by
  unfold uniformMass
  rw [NNReal.coe_div]
  simp

/-- The uniform distribution on `Ω`. -/
noncomputable def uniformDist (Ω : Type) [Fintype Ω] [Nonempty Ω] :
    ActivationDist Ω where
  p := fun _ => uniformMass Ω
  normalized := by
    have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
      exact_mod_cast Fintype.card_pos
    apply NNReal.coe_injective
    push_cast
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    rw [uniformMass_coe]
    field_simp

/-- The lifted mass of `uniformDist` is the uniform value `1/|Ω|`. -/
lemma pR_uniformDist [Nonempty Ω] (ω : Ω) :
    pR (uniformDist Ω) ω = 1 / (Fintype.card Ω : ℝ) := by
  unfold pR uniformDist
  exact uniformMass_coe

/-- **DISCOVERY (Group 2.4, reverse).** The uniform distribution attains
the max-entropy bound: `knowledgeEntropy (uniformDist Ω) = log |Ω|`. -/
theorem H_K_uniform_eq_log_card [Nonempty Ω] [DecidableEq Ω] :
    knowledgeEntropy (uniformDist Ω) = Real.log (Fintype.card Ω : ℝ) := by
  rw [knowledgeEntropy_eq_Hpi]
  have h_eq : pR (uniformDist Ω) = fun _ => 1 / (Fintype.card Ω : ℝ) := by
    funext ω
    exact pR_uniformDist ω
  rw [h_eq]
  exact CjNEW13.CjNEW13_uniform_attains

end Agent6

end MIP
