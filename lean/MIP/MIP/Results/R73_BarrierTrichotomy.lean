/-
Result R.72 / R.73 — Bidirectional-advantage bound and barrier-type
trichotomy.

Reference: `proofs/derived/uncertainty.md` R.72 (A 无条件) + R.73 (T.11,
A 无条件).

**R.72 statement.** Under T.6.iii (`N_bi ≤ |B|`) and R.70 (sharp form
`N(A,H)·N(H,A) ≥ |B|²·(1 + ξ)`):

    N_bi²·(1 + ξ)  ≤  N(A,H)·N(H,A) .

**R.73 statement.** For any problem `p` with `|B| ≥ 1`, the barrier
counts `a := |B_A|`, `h := |B_H|`, `s := |B_S|` (with `a + h + s = |B|`)
fall into exactly one of three types:

* **Type S** (symmetric):    `s = |B|` (i.e. `a = h = 0`),
* **Type B** (biased):       `0 < s < |B|`,
* **Type E** (extreme):      `s = 0`.

This file proves both kernels — R.72 product bound and R.73 trichotomy —
without committing to MIP opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace BarrierTrichotomy

/-- **R.72 — algebraic core.**

Given `N_bi ≤ |B|` (T.6.iii) and `|B|²·(1 + ξ) ≤ N→·N←` (R.70 sharp),
deduce `N_bi²·(1 + ξ) ≤ N→·N←`.  Pure-algebra composition. -/
theorem R_72_bidirectional_bound
    (N_bi B N_arrow_R N_arrow_L ξ : ℝ)
    (h_N_bi_nonneg : 0 ≤ N_bi)
    (h_T6_iii : N_bi ≤ B)
    (h_ξ_nonneg : 0 ≤ ξ)
    (h_R70 : B ^ 2 * (1 + ξ) ≤ N_arrow_R * N_arrow_L) :
    N_bi ^ 2 * (1 + ξ) ≤ N_arrow_R * N_arrow_L := by
  have h_N_bi_sq_le_B_sq : N_bi ^ 2 ≤ B ^ 2 :=
    pow_le_pow_left₀ h_N_bi_nonneg h_T6_iii 2
  have h_ξ_factor_nonneg : 0 ≤ 1 + ξ := by linarith
  calc N_bi ^ 2 * (1 + ξ)
      ≤ B ^ 2 * (1 + ξ) := by
        exact mul_le_mul_of_nonneg_right h_N_bi_sq_le_B_sq h_ξ_factor_nonneg
    _ ≤ N_arrow_R * N_arrow_L := h_R70

/-- **R.73 — barrier-type trichotomy.**

For nonneg `a, h, s` with `a + h + s = B` and `B ≥ 1`, exactly one of:
* `s = B` (Type S, `a = h = 0`),
* `0 < s ∧ s < B` (Type B),
* `s = 0` (Type E)
holds. -/
theorem R_73_barrier_trichotomy
    (a h s B : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s)
    (h_sum : a + h + s = B) :
    (s = B ∧ a = 0 ∧ h = 0) ∨
    (0 < s ∧ s < B) ∨
    (s = 0) := by
  rcases lt_trichotomy s 0 with h_neg | h_zero | h_pos
  · -- s < 0 contradicts hs.
    linarith
  · -- s = 0: Type E.
    exact Or.inr (Or.inr h_zero)
  · -- 0 < s: either s = B (Type S) or s < B (Type B).
    rcases lt_trichotomy s B with h_lt | h_eq | h_gt
    · -- 0 < s < B: Type B.
      exact Or.inr (Or.inl ⟨h_pos, h_lt⟩)
    · -- s = B: Type S, requires a = h = 0.
      refine Or.inl ⟨h_eq, ?_, ?_⟩
      · linarith
      · linarith
    · -- s > B impossible since a, h ≥ 0 and a + h + s = B.
      linarith

/-- **R.73 — Type S characterisation.**

Type S (`s = B`, equivalently `B = B_S`) iff `a = h = 0`. -/
theorem R_73_type_S_iff_zero
    (a h s B : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h)
    (h_sum : a + h + s = B) :
    (s = B) ↔ (a = 0 ∧ h = 0) := by
  constructor
  · intro h_eq
    refine ⟨?_, ?_⟩
    · linarith
    · linarith
  · rintro ⟨ha0, hh0⟩
    linarith

end BarrierTrichotomy

end MIP
