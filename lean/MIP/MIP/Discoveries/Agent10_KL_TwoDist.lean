/-
  STATUS: DISCOVERY
  AGENT: 10
  DIRECTION: Group B.5 — KL divergence between two activation
              distributions on the same `Ω`.
  SUMMARY:
    Define
        KL(d1 ‖ d2) := ∑ ω, (d1.p ω : ℝ) · log ((d1.p ω) / (d2.p ω)).

    Three named results:

      • `klDiv_self`              — `KL(d ‖ d) = 0`               (trivial).
      • `klDiv_nonneg_strict_d2`  — `0 ≤ KL(d1 ‖ d2)`              (Gibbs)
                                    *under strict positivity of d2*.
      • `klDiv_eq_zero_of_eq`     — `d1 = d2 ⟹ KL = 0`.

    The Gibbs inequality is proved from the elementary
    "log-sum inequality" reformulated via `log x ≤ x - 1`:

        x · log (x/y) = -x · log (y/x) ≥ -x · ((y/x) - 1)
                       = x - y,                       (for x, y > 0)

    so `∑ x_i log (x_i/y_i) ≥ ∑ (x_i - y_i) = 1 - 1 = 0` when both
    `x` and `y` sum to 1.

    This file is the *distribution-level dual* of Agent 10's
    `Agent10_KLToUniform_Dist`: that file proved `KL(d ‖ uniform) ≥ 0`
    via the closed-form `log m - H_K(d)`; this file gives the general
    pair `KL(d1 ‖ d2)` form under a positivity hypothesis on `d2`.

    For the unrestricted case (where `d2.p ω = 0` is allowed on
    out-of-`d1`-support points), the Lean convention `log 0 = 0` makes
    the sum still well-defined, but the proof of Gibbs requires an
    absolute-continuity hypothesis to avoid 0/0 indeterminacy. We state
    the strict-positivity form as the cleanest version.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent10_CrossEntropy
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

namespace Agent10

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- **Key inequality `log x ≤ x - 1` (for positive `x`).**

This is `Real.log_le_sub_one_of_pos` from Mathlib, packaged here for
local clarity. -/
private lemma log_le_sub_one_pos {x : ℝ} (hx : 0 < x) : Real.log x ≤ x - 1 :=
  Real.log_le_sub_one_of_pos hx

/-- **HEADLINE (Group B.5) — Gibbs' inequality for activation
distributions.**

For any two activation distributions `d1, d2` on `Ω` with **`d2`
strictly positive**, the KL divergence is nonneg:

    0  ≤  KL(d1 ‖ d2).

Proof: pointwise `log (d1.p / d2.p) = -log (d2.p / d1.p) ≥ -(d2.p/d1.p - 1)`
on the `d1`-support (where `d1.p > 0`); multiply through by `d1.p ≥ 0`,
sum, and use `∑ d1 = ∑ d2 = 1`. -/
theorem klDiv_nonneg_strict_d2
    (d1 d2 : ActivationDist Ω)
    (h_d2_pos : ∀ ω, 0 < (d2.p ω : ℝ)) :
    0 ≤ klDiv d1 d2 := by
  classical
  unfold klDiv
  -- Per-term lower bound: d1 ω · log (d1 ω / d2 ω) ≥ d1 ω - d2 ω.
  --   case d1 ω = 0: the term is 0 (log of 0/d2 = log 0 = 0, factored by 0).
  --                  RHS = 0 - d2 ω ≤ 0 (since d2 > 0), so 0 ≥ 0 - d2 ω. OK.
  --   case d1 ω > 0: log (d1/d2) = -log (d2/d1) ≥ -(d2/d1 - 1) = 1 - d2/d1.
  --     Multiplied by d1 ω: d1 ω · log (d1/d2) ≥ d1 ω · (1 - d2/d1) = d1 ω - d2 ω.
  have h_per : ∀ ω,
      (d1.p ω : ℝ) - (d2.p ω : ℝ)
        ≤ (d1.p ω : ℝ) * Real.log ((d1.p ω : ℝ) / (d2.p ω : ℝ)) := by
    intro ω
    by_cases h1 : (d1.p ω : ℝ) = 0
    · rw [h1]
      -- Goal: 0 - d2 ω ≤ 0 · log _ = 0.
      have h2 := h_d2_pos ω
      have h2nn : 0 ≤ (d2.p ω : ℝ) := le_of_lt h2
      have : (0 : ℝ) - (d2.p ω : ℝ) ≤ 0 := by linarith
      simpa using this
    · have h1pos : 0 < (d1.p ω : ℝ) :=
        lt_of_le_of_ne (d1.p ω).coe_nonneg (Ne.symm h1)
      have h2pos := h_d2_pos ω
      -- Reformulate: log (d1/d2) = -log (d2/d1).
      have h_quot_pos : 0 < (d2.p ω : ℝ) / (d1.p ω : ℝ) :=
        div_pos h2pos h1pos
      have h_log_swap :
          Real.log ((d1.p ω : ℝ) / (d2.p ω : ℝ))
            = -Real.log ((d2.p ω : ℝ) / (d1.p ω : ℝ)) := by
        have h1ne : (d1.p ω : ℝ) ≠ 0 := ne_of_gt h1pos
        have h2ne : (d2.p ω : ℝ) ≠ 0 := ne_of_gt h2pos
        rw [Real.log_div h1ne h2ne, Real.log_div h2ne h1ne]; ring
      rw [h_log_swap]
      -- Goal: d1 - d2 ≤ d1 · (-log (d2/d1)).
      -- From log_le_sub_one_pos: log (d2/d1) ≤ d2/d1 - 1.
      have h_log_bound : Real.log ((d2.p ω : ℝ) / (d1.p ω : ℝ))
                          ≤ (d2.p ω : ℝ) / (d1.p ω : ℝ) - 1 :=
        log_le_sub_one_pos h_quot_pos
      -- Multiply by -d1 ω < 0 to flip:
      --   -d1 ω · log (d2/d1) ≥ -d1 ω · (d2/d1 - 1) = -d2 + d1 = d1 - d2.
      have h_mul :
          (d1.p ω : ℝ) * (-Real.log ((d2.p ω : ℝ) / (d1.p ω : ℝ)))
            ≥ (d1.p ω : ℝ) * (-((d2.p ω : ℝ) / (d1.p ω : ℝ) - 1)) := by
        have h_neg_log : -Real.log ((d2.p ω : ℝ) / (d1.p ω : ℝ))
                          ≥ -((d2.p ω : ℝ) / (d1.p ω : ℝ) - 1) := by
          linarith
        exact mul_le_mul_of_nonneg_left h_neg_log (le_of_lt h1pos)
      -- Simplify d1 · (-(d2/d1 - 1)) = d1 - d2.
      have h_simp :
          (d1.p ω : ℝ) * (-((d2.p ω : ℝ) / (d1.p ω : ℝ) - 1))
            = (d1.p ω : ℝ) - (d2.p ω : ℝ) := by
        have h1ne : (d1.p ω : ℝ) ≠ 0 := ne_of_gt h1pos
        field_simp
        ring
      linarith [h_mul, h_simp]
  -- Sum: ∑ (d1 ω - d2 ω) = ∑ d1 - ∑ d2 = 1 - 1 = 0.
  have h_diff_sum :
      ∑ ω, ((d1.p ω : ℝ) - (d2.p ω : ℝ)) = 0 := by
    rw [Finset.sum_sub_distrib]
    have h1 : ∑ ω, (d1.p ω : ℝ) = 1 := by
      have : ((∑ ω, d1.p ω : NNReal) : ℝ) = ∑ ω, (d1.p ω : ℝ) := by
        push_cast; rfl
      rw [← this, d1.normalized]; simp
    have h2 : ∑ ω, (d2.p ω : ℝ) = 1 := by
      have : ((∑ ω, d2.p ω : NNReal) : ℝ) = ∑ ω, (d2.p ω : ℝ) := by
        push_cast; rfl
      rw [← this, d2.normalized]; simp
    rw [h1, h2]; ring
  -- Sum the per-term inequality.
  have h_sum_le :
      ∑ ω, ((d1.p ω : ℝ) - (d2.p ω : ℝ))
        ≤ ∑ ω, (d1.p ω : ℝ) * Real.log ((d1.p ω : ℝ) / (d2.p ω : ℝ)) :=
    Finset.sum_le_sum (fun ω _ => h_per ω)
  linarith

/-- **Trivial corollary.** If `d1 = d2` then `KL(d1 ‖ d2) = 0`. -/
theorem klDiv_eq_zero_of_eq (d : ActivationDist Ω) :
    klDiv d d = 0 := klDiv_self d

/-- **Cross-entropy lower bound, unconditional form.**

Under the strict-positivity hypothesis on `d2`, cross-entropy is at
least the entropy of `d1`:

    knowledgeEntropy d1  ≤  crossEntropy d1 d2.

This is the "no-free-lunch" theorem for codes: any mismatched code
`d2` costs at least `KL(d1 ‖ d2) ≥ 0` extra bits over the optimal
self-code. -/
theorem crossEntropy_ge_entropy_strict_d2
    (d1 d2 : ActivationDist Ω)
    (h_d2_pos : ∀ ω, 0 < (d2.p ω : ℝ)) :
    knowledgeEntropy d1 ≤ crossEntropy d1 d2 := by
  rw [crossEntropy_eq_entropy_add_KL d1 d2 h_d2_pos]
  linarith [klDiv_nonneg_strict_d2 d1 d2 h_d2_pos]

end Agent10

end MIP
