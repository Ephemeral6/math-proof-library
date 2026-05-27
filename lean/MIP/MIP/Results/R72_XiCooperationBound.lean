/-
Result R.72 — ξ cooperation-asymmetry bound on bidirectional emergence.
Reference: `proofs/derived/uncertainty.md` R.72 (A 无条件).

**Statement.**

    N_bi(p, A, H)² ≤ N(p, A, H) · N(p, H, A) / (1 + ξ(p, A, H))

equivalently

    N_bi / √(N→ · N←) ≤ 1 / √(1 + ξ).

The cooperation-asymmetry parameter `ξ ≥ 0` quantifies how much the
bidirectional protocol beats the geometric mean of the two
unidirectional costs.  Larger `ξ` (more directional asymmetry) gives a
strictly smaller normalized bidirectional cost.  Derived from
T.6.iii (`N_bi ≤ |B|`) and the R.70 tight bound
(`N→·N← ≥ |B|²·(1+ξ)`), which combine to the structural inequality
`N_bi²·(1+ξ) ≤ N→·N←`.

**Kernel formalized here.** The real `Real.sqrt` kernel: from the
structural hypothesis `Nbi²·(1+ξ) ≤ Nf·Nb` (with `Nbi, Nf, Nb > 0`,
`ξ ≥ 0`), conclude

    Nbi / √(Nf·Nb) ≤ 1 / √(1+ξ).

Proven via `Real.le_sqrt`, `Real.sqrt` monotonicity and `div_le_div`.

Axiom-free (only A.1–A.4).
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Tactic.Positivity

namespace MIP

namespace XiCooperationBound

open Real

/-- **R.72 — squared form.**

The structural inequality `N_bi²·(1+ξ) ≤ N→·N←`, restated as the
upper bound on the squared normalized bidirectional cost:

    N_bi² ≤ N→·N← / (1 + ξ).

(With `1 + ξ > 0`.) -/
theorem squared_bound
    (Nbi Nf Nb ξ : ℝ)
    (hξ : 0 ≤ ξ)
    (hStruct : Nbi ^ 2 * (1 + ξ) ≤ Nf * Nb) :
    Nbi ^ 2 ≤ Nf * Nb / (1 + ξ) := by
  have h1pos : 0 < 1 + ξ := by linarith
  rw [le_div_iff₀ h1pos]
  exact hStruct

/-- **R.72 — square-root (normalized) form.**

For `Nbi, Nf, Nb > 0` and `ξ ≥ 0`, the structural hypothesis
`Nbi²·(1+ξ) ≤ Nf·Nb` yields

    Nbi / √(Nf·Nb) ≤ 1 / √(1+ξ). -/
theorem xi_cooperation_bound
    (Nbi Nf Nb ξ : ℝ)
    (hNbi : 0 < Nbi) (hNf : 0 < Nf) (hNb : 0 < Nb)
    (hξ : 0 ≤ ξ)
    (hStruct : Nbi ^ 2 * (1 + ξ) ≤ Nf * Nb) :
    Nbi / Real.sqrt (Nf * Nb) ≤ 1 / Real.sqrt (1 + ξ) := by
  have h1pos : (0 : ℝ) < 1 + ξ := by linarith
  have hP : (0 : ℝ) < Nf * Nb := mul_pos hNf hNb
  have hsP : 0 < Real.sqrt (Nf * Nb) := Real.sqrt_pos.mpr hP
  have hs1 : 0 < Real.sqrt (1 + ξ) := Real.sqrt_pos.mpr h1pos
  -- Cross-multiply: goal ⟺ Nbi · √(1+ξ) ≤ √(Nf·Nb).
  rw [div_le_div_iff₀ hsP hs1, one_mul]
  -- Show Nbi · √(1+ξ) ≤ √(Nf·Nb) via Real.le_sqrt (both sides nonneg).
  have hlhs_nonneg : 0 ≤ Nbi * Real.sqrt (1 + ξ) :=
    mul_nonneg (le_of_lt hNbi) (le_of_lt hs1)
  rw [Real.le_sqrt hlhs_nonneg (le_of_lt hP)]
  -- Goal: (Nbi · √(1+ξ))² ≤ Nf·Nb.
  have hsq : (Nbi * Real.sqrt (1 + ξ)) ^ 2 = Nbi ^ 2 * (1 + ξ) := by
    rw [mul_pow, Real.sq_sqrt (le_of_lt h1pos)]
  rw [hsq]
  exact hStruct

end XiCooperationBound

end MIP
