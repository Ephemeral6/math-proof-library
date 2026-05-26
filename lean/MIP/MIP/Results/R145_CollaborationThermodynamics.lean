/-
Result R.145 — Collaboration thermodynamics: second law (emergence-entropy
monotonicity) + emergence temperature.

Reference: `branches/duality/workspace/new_results.md` R.145 (terminal-3
local R.072, A 条件性, 2026-05-16 duality branch).

**Statement interpretation used.**  R.145 builds the dictionary
"collaboration ↔ statistical thermodynamics":

* **emergence entropy**  `S_emerge(H_t) := H(K(H_t))` (Shannon entropy
  of H's knowledge space),
* **emergence energy**   `E_emerge := Φ₀(H) + Φ₀(A) − 2·Φ₀^common ≥ 0`,
* **emergence temperature** `T_emerge := dE_emerge / dS_emerge`, with the
  closed form `T_emerge = Φ₀ / (α_H · log|M_eff|)`.

The structural / arithmetic cores formalized here:

* **(i) second law** `dS_emerge ≥ 0`: the entropy increment decomposes as
  `dS = newTerm + reallocTerm` with `newTerm ≥ 0` (new knowledge atoms)
  and `reallocTerm ≥ 0` (Jensen/concavity of the reallocation), so
  `dS ≥ 0`; **equality** holds iff both are zero (`dK = 0`, i.e.
  `M_A ∩ M_H* = ∅`, collaboration ineffective).
* **(ii) Clausius relation** `δQ_teach = T_emerge · dS_emerge`
  (the defining relation `T_emerge := δQ / dS`).
* **(iii) temperature formula** `T_emerge = Φ₀ / (α_H · log|M_eff|)` and
  its non-negativity `T_emerge ≥ 0` (R.145.c: no negative temperature).
* **(iv) golden window = lowest-temperature region**: `T_emerge` is
  strictly *decreasing* in `log|M_eff|` (for `Φ₀, α_H > 0`), so the
  argmax of `|M_eff|` (= `t*`, R.134) is the argmin of `T_emerge`.

All MIP dependencies enter as explicit real-valued bundle hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace CollaborationThermodynamics

/-- **R.145 (i) — emergence-entropy second law (`dS ≥ 0`).**

The single-step entropy increment splits as `dS = newTerm + reallocTerm`,
with `newTerm ≥ 0` (Shannon contribution of newly-introduced knowledge
atoms) and `reallocTerm ≥ 0` (the old-mass reallocation, non-negative by
concavity/Jensen).  Hence `dS_emerge ≥ 0`. -/
theorem R_145_i_second_law
    (dS newTerm reallocTerm : ℝ)
    (h_dS : dS = newTerm + reallocTerm)
    (h_new : 0 ≤ newTerm) (h_realloc : 0 ≤ reallocTerm) :
    0 ≤ dS := by
  rw [h_dS]; linarith

/-- **R.145 (i) — equality case (`dS = 0` ⟺ no new knowledge).**

With both increments non-negative, `dS = 0` iff `newTerm = 0` *and*
`reallocTerm = 0`.  The vanishing of `newTerm` (no `k_new`) is exactly
`dK = 0`, i.e. `M_A ∩ M_H* = ∅`: collaboration is fully ineffective. -/
theorem R_145_i_equality_iff
    (dS newTerm reallocTerm : ℝ)
    (h_dS : dS = newTerm + reallocTerm)
    (h_new : 0 ≤ newTerm) (h_realloc : 0 ≤ reallocTerm) :
    dS = 0 ↔ newTerm = 0 ∧ reallocTerm = 0 := by
  rw [h_dS]
  constructor
  · intro h; constructor <;> linarith
  · rintro ⟨h1, h2⟩; rw [h1, h2]; ring

/-- **R.145 (ii) — Clausius relation `δQ_teach = T_emerge · dS_emerge`.**

The emergence temperature is *defined* as `T_emerge := δQ_teach / dS`
(for `dS ≠ 0`); the Clausius relation `δQ_teach = T_emerge · dS` is then
an identity. -/
theorem R_145_ii_clausius
    (δQ T_emerge dS : ℝ) (h_dS : dS ≠ 0)
    (h_T : T_emerge = δQ / dS) :
    δQ = T_emerge * dS := by
  rw [h_T, div_mul_cancel₀ δQ h_dS]

/-- **R.145 (iii) — emergence-temperature non-negativity (R.145.c).**

`T_emerge = Φ₀ / (α_H · log|M_eff|) ≥ 0` whenever the numerator `Φ₀ ≥ 0`
and the denominator factors `α_H ≥ 0`, `log|M_eff| ≥ 0` (so `|M_eff| ≥ 1`).
There is **no negative temperature** in emergence thermodynamics. -/
theorem R_145_iii_temp_nonneg
    (T_emerge Φ₀ αH logMeff : ℝ)
    (h_T : T_emerge = Φ₀ / (αH * logMeff))
    (h_Φ₀ : 0 ≤ Φ₀) (h_αH : 0 ≤ αH) (h_log : 0 ≤ logMeff) :
    0 ≤ T_emerge := by
  rw [h_T]
  exact div_nonneg h_Φ₀ (mul_nonneg h_αH h_log)

/-- **R.145 (iv) — golden window = lowest-temperature region.**

For fixed `Φ₀ > 0` and `α_H > 0`, the emergence temperature
`T_emerge(L) = Φ₀ / (α_H · L)` is strictly *decreasing* in `L = log|M_eff|`
on `L > 0`.  Hence where `|M_eff|` is maximal (`t*`, R.134), `T_emerge`
is minimal: the teaching golden window is the lowest-temperature region. -/
theorem R_145_iv_temp_decreasing_in_Meff
    (Φ₀ αH L₁ L₂ : ℝ) (h_Φ₀ : 0 < Φ₀) (h_αH : 0 < αH)
    (h_L₁ : 0 < L₁) (h_lt : L₁ < L₂) :
    Φ₀ / (αH * L₂) < Φ₀ / (αH * L₁) := by
  have hd₁ : 0 < αH * L₁ := mul_pos h_αH h_L₁
  have hd₂ : 0 < αH * L₂ := mul_pos h_αH (lt_trans h_L₁ h_lt)
  apply div_lt_div_of_pos_left h_Φ₀ hd₁
  exact (mul_lt_mul_iff_of_pos_left h_αH).mpr h_lt

end CollaborationThermodynamics

end MIP
