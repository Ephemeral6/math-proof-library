/-
Result R.132 — Cognitive-gap conservation law `N + N* = 2 N_bi + Asym`.

Reference: `branches/duality/workspace/new_results.md` R.132
(A 条件 (Ohm regime), 2026-05-16 duality branch).

**Statement.** In the Ohm regime, with per-barrier costs
`u_b := Φ(b)·Z_A(b)`, `v_b := Φ(b)·Z_H(b)`, define

    N      := Σ_b u_b               (H guides A)
    N_star := Σ_b v_b               (A guides H)
    N_bi   := Σ_b min(u_b, v_b)     (bidirectional optimum, T.6)
    Asym   := Σ_b |u_b − v_b|       (cognitive gap, D.4.15)

Then `N + N_star = 2·N_bi + Asym`.

**Proof.** Per-barrier atomic identity `u + v = 2·min(u, v) + |u − v|`
(for real `u, v`); summing over `b ∈ B(p)` gives the global form.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.Ring.Abs

namespace MIP

namespace ConservationLaw

open scoped BigOperators

/-- **Atomic identity (R.132 kernel).**

For reals `u, v`:  `u + v = 2·min(u, v) + |u − v|`.

(Proof by case split on `u ≤ v` vs `v < u`.) -/
theorem R_132_atomic (u v : ℝ) :
    u + v = 2 * min u v + |u - v| := by
  by_cases h : u ≤ v
  · -- u ≤ v ⟹ min = u, |u-v| = v - u
    rw [min_eq_left h, abs_of_nonpos (sub_nonpos.mpr h)]
    ring
  · -- u > v ⟹ min = v, |u-v| = u - v
    have h' : v ≤ u := le_of_not_ge h
    rw [min_eq_right h', abs_of_nonneg (sub_nonneg.mpr h')]
    ring

/-- **R.132 — conservation law (sum form).**

Pointwise application of the atomic identity, summed over a finset `B`. -/
theorem R_132_conservation
    {β : Type} [DecidableEq β]
    (B : Finset β) (u v : β → ℝ)
    (N N_star N_bi Asym : ℝ)
    (h_N : N = ∑ b ∈ B, u b)
    (h_Nstar : N_star = ∑ b ∈ B, v b)
    (h_N_bi : N_bi = ∑ b ∈ B, min (u b) (v b))
    (h_Asym : Asym = ∑ b ∈ B, |u b - v b|) :
    N + N_star = 2 * N_bi + Asym := by
  rw [h_N, h_Nstar, h_N_bi, h_Asym]
  have h_pointwise : ∀ b ∈ B,
      u b + v b = 2 * min (u b) (v b) + |u b - v b| :=
    fun b _ => R_132_atomic (u b) (v b)
  calc (∑ b ∈ B, u b) + (∑ b ∈ B, v b)
      = ∑ b ∈ B, (u b + v b) := (Finset.sum_add_distrib).symm
    _ = ∑ b ∈ B, (2 * min (u b) (v b) + |u b - v b|) :=
        Finset.sum_congr rfl h_pointwise
    _ = (∑ b ∈ B, 2 * min (u b) (v b)) + (∑ b ∈ B, |u b - v b|) :=
        Finset.sum_add_distrib
    _ = 2 * (∑ b ∈ B, min (u b) (v b)) + (∑ b ∈ B, |u b - v b|) := by
        have h_mul : ∑ b ∈ B, 2 * min (u b) (v b)
                       = 2 * ∑ b ∈ B, min (u b) (v b) :=
          (Finset.mul_sum B (fun b => min (u b) (v b)) 2).symm
        linarith

/-- **R.132 duality invariance.**

The conservation law is invariant under the involution `(A, H) ↦ (H, A)`,
which swaps `(u, v)` and fixes `min(u, v)` and `|u − v|`. -/
theorem R_132_duality_invariance
    {β : Type} [DecidableEq β]
    (B : Finset β) (u v : β → ℝ) :
    (∑ b ∈ B, min (u b) (v b) = ∑ b ∈ B, min (v b) (u b)) ∧
    (∑ b ∈ B, |u b - v b| = ∑ b ∈ B, |v b - u b|) := by
  refine ⟨?_, ?_⟩
  · apply Finset.sum_congr rfl
    intro b _
    rw [min_comm]
  · apply Finset.sum_congr rfl
    intro b _
    rw [abs_sub_comm]

end ConservationLaw

end MIP
