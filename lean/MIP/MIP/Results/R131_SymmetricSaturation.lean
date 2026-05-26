/-
Result R.131 — Symmetric saturation condition `N = N* ⟺ M_A = M_H`.

Reference: `branches/duality/workspace/new_results.md` R.131
(A 无条件, 2026-05-18 v2.0 升 after L.F upgrade).

**Statement.** In the Ohm regime, decompose the barrier set
`B(p) = B_A ⊔ B_H ⊔ B_S` and write per-barrier costs `u_b := Φ(b)·Z_A(b)`,
`v_b := Φ(b)·Z_H(b)`.  Define the impedance moments

    M_A := Σ_{b ∈ B_A} (v_b − u_b)   (H's extra cost on A-dominant barriers)
    M_H := Σ_{b ∈ B_H} (u_b − v_b)   (A's extra cost on H-dominant barriers)

Then with `N := Σ_b u_b`, `N* := Σ_b v_b`:

    N = N*  ⟺  M_A = M_H .

**Proof.** Pure algebraic identity:
`N − N* = M_H − M_A` once one decomposes the sum over the disjoint union
`B_A ⊔ B_H ⊔ B_S` and uses `u_b = v_b` on `B_S`.  Then `N = N* ⟺ N − N* = 0
⟺ M_H = M_A`.

This file proves the **algebraic core** without committing to the MIP
opaques.  Per-barrier costs `u, v : β → ℝ` are arbitrary; the partition
`B = B_A ⊔ B_H ⊔ B_S` is encoded as three disjoint finsets covering
the universe.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

namespace SymmetricSaturation

open scoped BigOperators

/-- **R.131 — algebraic kernel.**

`N − N* = M_H − M_A` under the disjoint-partition `B(p) = B_A ⊔ B_H ⊔ B_S`
and the per-barrier sign constraint `u_b = v_b` on `B_S`. -/
theorem R_131_diff_identity
    {β : Type} [DecidableEq β]
    (B_A B_H B_S : Finset β) (u v : β → ℝ)
    (h_BS_eq : ∀ b ∈ B_S, u b = v b) :
    ((∑ b ∈ B_A, u b) + (∑ b ∈ B_H, u b) + (∑ b ∈ B_S, u b))
      - ((∑ b ∈ B_A, v b) + (∑ b ∈ B_H, v b) + (∑ b ∈ B_S, v b))
      = (∑ b ∈ B_H, (u b - v b)) - (∑ b ∈ B_A, (v b - u b)) := by
  have h_BS_cancel : ∑ b ∈ B_S, u b = ∑ b ∈ B_S, v b :=
    Finset.sum_congr rfl (fun b hb => h_BS_eq b hb)
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, h_BS_cancel]
  ring

/-- **R.131 (clean N − N* form).**

If the barriers `B(p) = B_A ⊔ B_H ⊔ B_S` partition (disjoint cover),
with `B_S` containing tied barriers, then

    N − N* = M_H − M_A

where `N := Σ_b u_b`, `N* := Σ_b v_b`, `M_A := Σ_{b∈B_A}(v_b − u_b)`,
`M_H := Σ_{b∈B_H}(u_b − v_b)`. -/
theorem R_131_diff_M_form
    {β : Type} [DecidableEq β]
    (B_A B_H B_S : Finset β) (u v : β → ℝ)
    (N N_star M_A M_H : ℝ)
    (h_disj_AH : Disjoint B_A B_H)
    (h_disj_AS : Disjoint B_A B_S)
    (h_disj_HS : Disjoint B_H B_S)
    (h_N : N = ∑ b ∈ B_A ∪ B_H ∪ B_S, u b)
    (h_Nstar : N_star = ∑ b ∈ B_A ∪ B_H ∪ B_S, v b)
    (h_M_A : M_A = ∑ b ∈ B_A, (v b - u b))
    (h_M_H : M_H = ∑ b ∈ B_H, (u b - v b))
    (h_BS_eq : ∀ b ∈ B_S, u b = v b) :
    N - N_star = M_H - M_A := by
  have h_sum_u : ∑ b ∈ B_A ∪ B_H ∪ B_S, u b
                  = (∑ b ∈ B_A, u b) + (∑ b ∈ B_H, u b) + (∑ b ∈ B_S, u b) := by
    rw [Finset.sum_union (Finset.disjoint_union_left.mpr ⟨h_disj_AS, h_disj_HS⟩)]
    rw [Finset.sum_union h_disj_AH]
  have h_sum_v : ∑ b ∈ B_A ∪ B_H ∪ B_S, v b
                  = (∑ b ∈ B_A, v b) + (∑ b ∈ B_H, v b) + (∑ b ∈ B_S, v b) := by
    rw [Finset.sum_union (Finset.disjoint_union_left.mpr ⟨h_disj_AS, h_disj_HS⟩)]
    rw [Finset.sum_union h_disj_AH]
  rw [h_N, h_Nstar, h_sum_u, h_sum_v, h_M_A, h_M_H]
  exact R_131_diff_identity B_A B_H B_S u v h_BS_eq

/-- **R.131 — `N = N* ⟺ M_A = M_H`.**

Symmetric-saturation theorem in equivalence form, immediate corollary
of the difference identity. -/
theorem R_131_symmetric_saturation
    {β : Type} [DecidableEq β]
    (B_A B_H B_S : Finset β) (u v : β → ℝ)
    (N N_star M_A M_H : ℝ)
    (h_disj_AH : Disjoint B_A B_H)
    (h_disj_AS : Disjoint B_A B_S)
    (h_disj_HS : Disjoint B_H B_S)
    (h_N : N = ∑ b ∈ B_A ∪ B_H ∪ B_S, u b)
    (h_Nstar : N_star = ∑ b ∈ B_A ∪ B_H ∪ B_S, v b)
    (h_M_A : M_A = ∑ b ∈ B_A, (v b - u b))
    (h_M_H : M_H = ∑ b ∈ B_H, (u b - v b))
    (h_BS_eq : ∀ b ∈ B_S, u b = v b) :
    N = N_star ↔ M_A = M_H := by
  have h_diff := R_131_diff_M_form B_A B_H B_S u v N N_star M_A M_H
                  h_disj_AH h_disj_AS h_disj_HS h_N h_Nstar h_M_A h_M_H h_BS_eq
  constructor
  · intro h_NN
    linarith
  · intro h_MM
    linarith

end SymmetricSaturation

end MIP
