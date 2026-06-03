/-
  STATUS: DISCOVERY
  AGENT: 6
  DIRECTION: Group 1.1 — `H_K(d) ≥ 0` for every activation distribution.
  SUMMARY:
    The Shannon entropy `knowledgeEntropy d = -∑_ω p(ω) log p(ω)` is
    nonnegative on every `ActivationDist Ω`.  Each summand
    `-p(ω) · log p(ω)` is `Real.negMulLog (p ω)` and is nonneg on `[0,1]`
    (Mathlib `Real.negMulLog_nonneg`).  Since `p ω : NNReal` and
    `p ω ≤ ∑ ω, p ω = 1`, every term qualifies.  We rewrite
    `knowledgeEntropy` as `∑ negMulLog ∘ p` and conclude by
    `Finset.sum_nonneg`.
    Stated as `H_K_nonneg`.  Trivial after the rewrite but worth being
    explicit since the file `Defs/Knowledge.lean` only defines
    `knowledgeEntropy` without any pinned-down sign.
-/
import MIP.Defs.Knowledge
import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog

namespace MIP

namespace Agent6

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- `knowledgeEntropy d = ∑ ω, Real.negMulLog (d.p ω)`. The structural
identity behind the H_K ≥ 0 proof. -/
lemma knowledgeEntropy_eq_sum_negMulLog (d : ActivationDist Ω) :
    knowledgeEntropy d = ∑ ω, Real.negMulLog ((d.p ω : ℝ)) := by
  unfold knowledgeEntropy
  rw [← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro ω _
  rw [Real.negMulLog]
  ring

/-- Every mass `(d.p ω : ℝ)` lies in `[0, 1]`. -/
lemma p_coe_mem_unit_interval (d : ActivationDist Ω) (ω : Ω) :
    0 ≤ (d.p ω : ℝ) ∧ (d.p ω : ℝ) ≤ 1 := by
  refine ⟨(d.p ω).coe_nonneg, ?_⟩
  -- Use the NNReal sum to bound a single term by 1.
  have hsum : ((∑ ω', d.p ω' : NNReal) : ℝ) = 1 := by
    rw [d.normalized]; simp
  have h_le_sum : (d.p ω : ℝ) ≤ (∑ ω', d.p ω' : NNReal) := by
    have h := Finset.single_le_sum
      (f := fun ω' => (d.p ω' : ℝ))
      (s := (Finset.univ : Finset Ω))
      (fun ω' _ => (d.p ω').coe_nonneg)
      (Finset.mem_univ ω)
    have hcoe : ((∑ ω', d.p ω' : NNReal) : ℝ) = ∑ ω', (d.p ω' : ℝ) := by
      push_cast; rfl
    rw [hcoe]
    exact h
  linarith [h_le_sum, hsum]

/-- **DISCOVERY (Group 1.1).** Knowledge entropy is nonnegative for every
activation distribution. -/
theorem H_K_nonneg (d : ActivationDist Ω) : 0 ≤ knowledgeEntropy d := by
  rw [knowledgeEntropy_eq_sum_negMulLog]
  apply Finset.sum_nonneg
  intro ω _
  obtain ⟨h0, h1⟩ := p_coe_mem_unit_interval d ω
  exact Real.negMulLog_nonneg h0 h1

end Agent6

end MIP
