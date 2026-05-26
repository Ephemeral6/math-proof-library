/-
Result R-SUB.14 — Training cost dominates subdomain-attention drift
(`C_train ≥ KL(π^{t+1} ‖ π^t)` via a data-processing inequality bridge).

Reference: `workspace/subdomain_competition.md` §6.14 (B 条件).

**Statement.** The MIP post-training cost dominates the KL drift of the
subdomain-attention distribution:

    C_train  =  KL_response(p^{t+1} ‖ p^t)  ≥  KL(π^{t+1} ‖ π^t),

because the `K(X) → response` map is a Markov kernel, so the
data-processing inequality (DPI) makes the response-distribution drift an
upper bound for the coarse-grained subdomain-attention drift.

The Markov structure that justifies the DPI step is opaque at the
MIP-axiom level (it needs the `K → response` kernel formalized), so we
take the **DPI inequality** `KL_response ≥ KL_attention` and the
**definition** `C_train := KL_response` as hypotheses, and prove the
crisp algebraic consequence:

    DPI hypothesis  ⟹  C_train ≥ KL(π^{t+1} ‖ π^t).

We additionally provide the **Gibbs nonnegativity** of the
subdomain-attention KL (`KL ≥ 0`) from the elementary convexity inequality
`log x ≤ x − 1`, for two normalised distributions on a finite index set —
this shows the bound `C_train ≥ KL_attention ≥ 0` is informative.

The KL functional here is `KL(a‖b) := Σ_i a_i · log (a_i / b_i)` with the
convention `0 · log 0 = 0` (via `Real.log 0 = 0`).

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace CtrainKLBound

variable {ι : Type*}

/-- Discrete KL divergence `KL(a‖b) := Σ_i a_i · log (a_i / b_i)` over a
finite index set `s`. Convention `0 · log 0 = 0`. -/
noncomputable def KL (s : Finset ι) (a b : ι → ℝ) : ℝ :=
  ∑ i ∈ s, a i * Real.log (a i / b i)

/-- **R-SUB.14 — DPI bound (the crisp content).**

Given the training-cost definition `C_train = KL_response` and the
data-processing inequality `KL_response ≥ KL_attention` (which holds
because the `K → response` map is a Markov kernel), the training cost
dominates the subdomain-attention drift. -/
theorem R_SUB_14_Ctrain_ge_attention
    (Ctrain KL_response KL_attention : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ KL_attention) :
    Ctrain ≥ KL_attention := by
  rw [hdef]; exact hDPI

/-- Specialisation: with `KL_attention` instantiated as the concrete KL of
the subdomain-attention distributions `π^{t+1}` (`a`) against `π^t` (`b`)
on the subdomain index set `s`. -/
theorem R_SUB_14_Ctrain_ge_KL
    (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ KL s a b) :
    Ctrain ≥ KL s a b :=
  R_SUB_14_Ctrain_ge_attention Ctrain KL_response (KL s a b) hdef hDPI

/-- **Gibbs' inequality (nonnegativity of KL).** For two probability mass
functions `a, b` on the finite index set `s` (`a, b ≥ 0`, both summing to
1) with `b` strictly positive on `s`, the KL divergence is nonnegative.

Proof via the elementary bound `log x ≤ x − 1` applied to `x = b_i / a_i`,
which gives `a_i log (a_i/b_i) ≥ a_i − b_i`; summing yields
`KL ≥ Σ a_i − Σ b_i = 1 − 1 = 0`. -/
theorem KL_nonneg
    (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i)
    (hsa : ∑ i ∈ s, a i = 1) (hsb : ∑ i ∈ s, b i = 1) :
    0 ≤ KL s a b := by
  unfold KL
  -- For each i: a i − b i ≤ a i * log (a i / b i).
  have hterm : ∀ i ∈ s, a i - b i ≤ a i * Real.log (a i / b i) := by
    intro i hi
    by_cases hai : a i = 0
    · -- term is 0 on the LHS factor; need -b i ≤ 0, true since b i > 0.
      rw [hai]
      simp only [zero_sub, zero_mul]
      linarith [hb i hi]
    · have haipos : 0 < a i := lt_of_le_of_ne (ha i hi) (Ne.symm hai)
      have hbipos : 0 < b i := hb i hi
      -- log (b i / a i) ≤ b i / a i − 1.
      have hlog : Real.log (b i / a i) ≤ b i / a i - 1 :=
        Real.log_le_sub_one_of_pos (by positivity)
      -- multiply by a i > 0 and rearrange.
      have hmul : a i * Real.log (b i / a i) ≤ a i * (b i / a i - 1) :=
        mul_le_mul_of_nonneg_left hlog (le_of_lt haipos)
      have hrw : a i * (b i / a i - 1) = b i - a i := by
        field_simp
      rw [hrw] at hmul
      -- log (a i / b i) = − log (b i / a i).
      have hneg : Real.log (a i / b i) = - Real.log (b i / a i) := by
        rw [← Real.log_inv]
        congr 1
        rw [inv_div]
      rw [hneg, mul_neg]
      linarith
  -- Sum the per-term bound.
  have hsum : ∑ i ∈ s, (a i - b i) ≤ ∑ i ∈ s, a i * Real.log (a i / b i) :=
    Finset.sum_le_sum hterm
  have hlhs : ∑ i ∈ s, (a i - b i) = 0 := by
    rw [Finset.sum_sub_distrib, hsa, hsb]; ring
  rw [hlhs] at hsum
  exact hsum

/-- **R-SUB.14 — full informative bound.** Combining the DPI bridge with
Gibbs' inequality: the training cost dominates the (nonnegative)
subdomain-attention drift,

    C_train  ≥  KL(π^{t+1} ‖ π^t)  ≥  0. -/
theorem R_SUB_14_Ctrain_ge_KL_nonneg
    (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ KL s a b)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i)
    (hsa : ∑ i ∈ s, a i = 1) (hsb : ∑ i ∈ s, b i = 1) :
    Ctrain ≥ KL s a b ∧ 0 ≤ KL s a b :=
  ⟨R_SUB_14_Ctrain_ge_KL s a b Ctrain KL_response hdef hDPI,
   KL_nonneg s a b ha hb hsa hsb⟩

end CtrainKLBound

end MIP
