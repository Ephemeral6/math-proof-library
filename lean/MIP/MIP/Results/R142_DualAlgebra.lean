/-
Result R.142 — Dual-algebra admissible set Ω is a 5-D convex polyhedral
cone (bicone embedding).

Reference: `branches/duality/workspace/new_results.md` R.142
(A 无条件 for parts (i)-(iv), 2026-05-16 duality branch).

**Statement.** The 6-tuple of observables
`q := (N, N*, N_self_A, N_self_H, N_bi, Asym) ∈ ℝ≥0^6` is constrained by:

* **E1 (R.132)**       `N + N* = 2·N_bi + Asym`,
* **R.138 mono.**      `N_self_A ≥ N`,  `N_self_H ≥ N*`,
* **R.140 (ii)**       `|N* − N| ≤ Asym`,
* **Asym ≥ 0**         which (with E1) gives `2·N_bi ≤ N + N*`.

The admissible set `Ω(p)` (set of `q` realised by some `(A, H)`) coincides
with the intersection of these half-spaces with `ℝ≥0^6`.  E1 is a
homogeneous linear equality, so Ω is embedded in a 5-D affine subspace
of ℝ⁶; the other constraints are all homogeneous inequalities (each is
either of the form `f q ≥ 0` or `|f q| ≤ g q` with `f, g` linear), so
the set is a **convex polyhedral cone**.

This file proves the **cone / convexity / duality-involution kernels**.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.Order.Ring.Abs

namespace MIP

namespace DualAlgebra

/-- The 6-vector of dual-algebra observables. -/
structure Obs where
  N         : ℝ
  N_star    : ℝ
  N_self_A  : ℝ
  N_self_H  : ℝ
  N_bi      : ℝ
  Asym      : ℝ

namespace Obs

/-- Componentwise scalar product. -/
def smul (c : ℝ) (q : Obs) : Obs :=
  ⟨c * q.N, c * q.N_star, c * q.N_self_A, c * q.N_self_H,
   c * q.N_bi, c * q.Asym⟩

/-- Componentwise addition. -/
def add (q₁ q₂ : Obs) : Obs :=
  ⟨q₁.N + q₂.N, q₁.N_star + q₂.N_star,
   q₁.N_self_A + q₂.N_self_A, q₁.N_self_H + q₂.N_self_H,
   q₁.N_bi + q₂.N_bi, q₁.Asym + q₂.Asym⟩

/-- The duality involution `𝒟 : (A, H) ↦ (H, A)`. -/
def dual (q : Obs) : Obs :=
  ⟨q.N_star, q.N, q.N_self_H, q.N_self_A, q.N_bi, q.Asym⟩

@[simp] lemma dual_dual (q : Obs) : dual (dual q) = q := rfl

end Obs

/-- **R.142 (i) — admissible-set predicate** (closed half-space form). -/
def inOmega (q : Obs) : Prop :=
  0 ≤ q.N ∧ 0 ≤ q.N_star ∧ 0 ≤ q.N_self_A ∧ 0 ≤ q.N_self_H ∧
  0 ≤ q.N_bi ∧ 0 ≤ q.Asym ∧
  q.N + q.N_star = 2 * q.N_bi + q.Asym ∧
  q.N ≤ q.N_self_A ∧
  q.N_star ≤ q.N_self_H ∧
  |q.N_star - q.N| ≤ q.Asym

/-- **R.142 (i) cone property — `Ω` is closed under nonneg scaling.**

For `c ≥ 0`, `q ∈ Ω ⟹ c · q ∈ Ω`.  The defining constraints are all
homogeneous linear (each either `0 ≤ x` or `x = y` or `|x| ≤ y`), so
scaling by `c ≥ 0` preserves them. -/
theorem R_142_i_cone (c : ℝ) (hc : 0 ≤ c) (q : Obs) (hq : inOmega q) :
    inOmega (Obs.smul c q) := by
  obtain ⟨hN, hNs, hNsA, hNsH, hNbi, hAsym, hE1, hRA, hRH, hT⟩ := hq
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact mul_nonneg hc hN
  · exact mul_nonneg hc hNs
  · exact mul_nonneg hc hNsA
  · exact mul_nonneg hc hNsH
  · exact mul_nonneg hc hNbi
  · exact mul_nonneg hc hAsym
  · -- E1 scales: c·N + c·N* = 2·(c·N_bi) + c·Asym  ⟺  c·(N+N*) = c·(2 N_bi + Asym)
    show c * q.N + c * q.N_star = 2 * (c * q.N_bi) + c * q.Asym
    calc c * q.N + c * q.N_star
        = c * (q.N + q.N_star) := by ring
      _ = c * (2 * q.N_bi + q.Asym) := by rw [hE1]
      _ = 2 * (c * q.N_bi) + c * q.Asym := by ring
  · exact mul_le_mul_of_nonneg_left hRA hc
  · exact mul_le_mul_of_nonneg_left hRH hc
  · -- |c·N* − c·N| = c · |N* − N| ≤ c · Asym
    show |c * q.N_star - c * q.N| ≤ c * q.Asym
    have h_rw : c * q.N_star - c * q.N = c * (q.N_star - q.N) := by ring
    rw [h_rw, abs_mul, abs_of_nonneg hc]
    exact mul_le_mul_of_nonneg_left hT hc

/-- **R.142 (i) convexity — `Ω` is closed under addition.**

`q₁, q₂ ∈ Ω ⟹ q₁ + q₂ ∈ Ω`.  Combined with the cone property
(`R_142_i_cone`), this gives convexity:
`λ q₁ + (1−λ) q₂ ∈ Ω` for `λ ∈ [0,1]`. -/
theorem R_142_i_add (q₁ q₂ : Obs) (h₁ : inOmega q₁) (h₂ : inOmega q₂) :
    inOmega (Obs.add q₁ q₂) := by
  obtain ⟨hN₁, hNs₁, hNsA₁, hNsH₁, hNbi₁, hAsym₁, hE1₁, hRA₁, hRH₁, hT₁⟩ := h₁
  obtain ⟨hN₂, hNs₂, hNsA₂, hNsH₂, hNbi₂, hAsym₂, hE1₂, hRA₂, hRH₂, hT₂⟩ := h₂
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact add_nonneg hN₁ hN₂
  · exact add_nonneg hNs₁ hNs₂
  · exact add_nonneg hNsA₁ hNsA₂
  · exact add_nonneg hNsH₁ hNsH₂
  · exact add_nonneg hNbi₁ hNbi₂
  · exact add_nonneg hAsym₁ hAsym₂
  · show q₁.N + q₂.N + (q₁.N_star + q₂.N_star)
          = 2 * (q₁.N_bi + q₂.N_bi) + (q₁.Asym + q₂.Asym)
    linarith
  · exact add_le_add hRA₁ hRA₂
  · exact add_le_add hRH₁ hRH₂
  · show |q₁.N_star + q₂.N_star - (q₁.N + q₂.N)| ≤ q₁.Asym + q₂.Asym
    have h_rw : q₁.N_star + q₂.N_star - (q₁.N + q₂.N)
                  = (q₁.N_star - q₁.N) + (q₂.N_star - q₂.N) := by ring
    rw [h_rw]
    calc |(q₁.N_star - q₁.N) + (q₂.N_star - q₂.N)|
        ≤ |q₁.N_star - q₁.N| + |q₂.N_star - q₂.N| := abs_add_le _ _
      _ ≤ q₁.Asym + q₂.Asym := by linarith

/-- **R.142 (iii) — Ω is invariant under the duality involution `𝒟`.**

`𝒟(q) := (N* ↔ N, N_self_H ↔ N_self_A, N_bi, Asym fixed)`.  The
defining constraints are all 𝒟-symmetric: E1 is symmetric in
`(N, N*)`; R.138 swaps the two inequalities; `|N* − N|` is symmetric;
nonneg constraints transport. -/
theorem R_142_iii_dual_invariance (q : Obs) (hq : inOmega q) :
    inOmega (Obs.dual q) := by
  obtain ⟨hN, hNs, hNsA, hNsH, hNbi, hAsym, hE1, hRA, hRH, hT⟩ := hq
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact hNs
  · exact hN
  · exact hNsH
  · exact hNsA
  · exact hNbi
  · exact hAsym
  · show q.N_star + q.N = 2 * q.N_bi + q.Asym
    linarith
  · exact hRH
  · exact hRA
  · show |q.N - q.N_star| ≤ q.Asym
    rw [abs_sub_comm]
    exact hT

/-- **R.142 (iii) symmetric subset characterisation.**

`q ∈ Ω^𝒟` (the duality-fixed subset) iff `N = N*` and
`N_self_A = N_self_H`.  Under E1 this gives `Asym = 2(N − N_bi)`,
leaving 3 free parameters (one less than the 4 components
`(N, N_self, N_bi, Asym)` due to one extra equation). -/
theorem R_142_iii_symm_subset (q : Obs) :
    Obs.dual q = q ↔ q.N = q.N_star ∧ q.N_self_A = q.N_self_H := by
  constructor
  · intro h
    -- Project h to each component.  By def of Obs.dual:
    --   (Obs.dual q).N         = q.N_star
    --   (Obs.dual q).N_self_A  = q.N_self_H
    -- So h : Obs.dual q = q gives q.N_star = q.N and q.N_self_H = q.N_self_A.
    have h_eq_N : q.N_star = q.N := congrArg Obs.N h
    have h_eq_NsA : q.N_self_H = q.N_self_A := congrArg Obs.N_self_A h
    exact ⟨h_eq_N.symm, h_eq_NsA.symm⟩
  · rintro ⟨hN, hNs⟩
    cases q with
    | mk N N_star N_self_A N_self_H N_bi Asym =>
      simp only at hN hNs
      -- hN : N = N_star, hNs : N_self_A = N_self_H
      show Obs.mk N_star N N_self_H N_self_A N_bi Asym
            = Obs.mk N N_star N_self_A N_self_H N_bi Asym
      rw [← hN, ← hNs]

end DualAlgebra

end MIP
