/-
Result R.807 — RAG indistinguishability correction (RAG-IND).

Reference: `proofs/derived/A4_grade.md` R.807 (A 无条件, inherits R.800 + R.804).

**Statement.** Let `X_base` satisfy the R.800 (IBΦ) setup, and let a
Retriever-based modular augmentation induce an equivalence relation on the
`k` projection-homogeneous questions.  With `k_residual` the maximum size of
an equivalence class of questions indistinguishable under the retriever
projection, R.800 applied to the `k_residual` identical (indistinguishable)
questions of one class gives `k_residual · e^{−Φ₀} ≤ 1`, hence

    Φ₀^RAG(X, pᵢ) ≥ log k_residual .

**Pure-math kernel.** This file states the algebraic step "`k · e^{−Φ} ≤ 1`
⟹ `Φ ≥ log k`" (for `k ≥ 1`), which is exactly the third step of the
R.800 / R.807 argument.  The probabilistic content of R.800 (Boole + A.4
indistinguishability, formalized as `R_800_…` in
`R800_BoundaryLowerBound.lean`) supplies the hypothesis `k · e^{−Φ} ≤ 1`;
here we derive the log lower bound.

**Dependency.** R.800 (IBΦ) — supplies `(k : ℝ) * Real.exp (-Φ) ≤ 1`.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

namespace RAGIndistinguishability

/-- **R.807 — log lower bound from the R.800 inequality.**

If `k ≥ 1` and `(k : ℝ) · e^{−Φ} ≤ 1`, then `log k ≤ Φ`.

This is the closing step of R.807: R.800 applied to a residual equivalence
class of size `k = k_residual` gives `k · e^{−Φ} ≤ 1`; rearranging yields
`Φ ≥ log k`. -/
theorem R_807_log_lower_bound
    (k : ℕ) (hk : 1 ≤ k) (Φ : ℝ)
    (h : (k : ℝ) * Real.exp (-Φ) ≤ 1) :
    Real.log k ≤ Φ := by
  have hk_pos : (0 : ℝ) < k := by exact_mod_cast hk
  -- From k · e^{−Φ} ≤ 1 get e^{−Φ} ≤ 1/k.
  have h_exp_le : Real.exp (-Φ) ≤ 1 / (k : ℝ) := by
    rw [le_div_iff₀ hk_pos] -- 0 < k ; goal: exp(-Φ) * k ≤ 1
    calc Real.exp (-Φ) * (k : ℝ) = (k : ℝ) * Real.exp (-Φ) := by ring
      _ ≤ 1 := h
  -- Take logs: -Φ ≤ log (1/k) = - log k.
  have h_exp_pos : (0 : ℝ) < Real.exp (-Φ) := Real.exp_pos _
  have h_log_le : -Φ ≤ Real.log (1 / (k : ℝ)) := by
    have := Real.log_le_log h_exp_pos h_exp_le
    rwa [Real.log_exp] at this
  rw [Real.log_div one_ne_zero (ne_of_gt hk_pos), Real.log_one] at h_log_le
  -- -Φ ≤ 0 - log k = - log k  ⟹  log k ≤ Φ.
  linarith

/-- **R.807 — RAG-IND lower bound (named restatement).**

`Φ₀^RAG(X, pᵢ) ≥ log k_residual`, the R.807 conclusion, given the R.800
inequality `k_residual · e^{−Φ₀^RAG} ≤ 1` for a residual class of size
`k_residual ≥ 1`. -/
theorem R_807_rag_ind
    (k_residual : ℕ) (hk : 1 ≤ k_residual) (Φ_RAG : ℝ)
    (h_R800 : (k_residual : ℝ) * Real.exp (-Φ_RAG) ≤ 1) :
    Real.log k_residual ≤ Φ_RAG :=
  R_807_log_lower_bound k_residual hk Φ_RAG h_R800

end RAGIndistinguishability

end MIP
