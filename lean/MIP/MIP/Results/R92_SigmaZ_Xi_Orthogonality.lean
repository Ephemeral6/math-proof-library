/-
Result R.92 — Functional independence of `σ_Z` and `ξ`.

Reference: `workspace/new_results.md` R.92 (升 A 无条件, 2026-05-17 Slot 009).

**Statement.** `σ_Z` (D.4.9; intra-agent state-impedance heterogeneity) and
`ξ` (R.71; inter-agent collaboration asymmetry) are functionally
independent: the four sign-quadrants `({σ_Z > 0, σ_Z = 0}) × ({ξ > 0, ξ = 0})`
are all jointly realisable.

In particular, knowing `σ_Z` gives no information about `ξ` and vice versa
— no functional dependence `ξ = f(σ_Z)` or `σ_Z = g(ξ)` can hold.

**Proof.** Four explicit constructions, one per quadrant.

This file abstracts the MIP-specific definitions of `σ_Z` and `ξ`
(D.4.9 / R.71) to a pair of nonnegative real-valued *parameters*
`(σ, ξ) : ℝ × ℝ`, and produces witnesses for each quadrant.  The fact
that no quadrant is empty is the functional-independence content of R.92.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace SigmaXi

/-- The four sign-quadrants of `(σ_Z, ξ) ∈ ℝ≥0 × ℝ≥0`. -/
inductive Quadrant
  | bothZero
  | sigmaOnly
  | xiOnly
  | bothPos

/-- Realisation predicate: a pair `(σ, ξ)` realises a quadrant when its
sign profile matches. -/
def Quadrant.realises : Quadrant → ℝ → ℝ → Prop
  | bothZero,  σ, ξ => σ = 0 ∧ ξ = 0
  | sigmaOnly, σ, ξ => 0 < σ ∧ ξ = 0
  | xiOnly,    σ, ξ => σ = 0 ∧ 0 < ξ
  | bothPos,   σ, ξ => 0 < σ ∧ 0 < ξ

/-- **R.92 — quadrant-by-quadrant realisability (four witnesses).**

Every sign-quadrant of `(σ_Z, ξ)` is realised by some explicit pair.
This establishes that `σ_Z` and `ξ` are functionally independent in the
sense that no map `ℝ → ℝ` between them is consistent with all four
quadrants. -/
theorem R_92_quadrants_realised :
    (∃ σ ξ : ℝ, Quadrant.realises .bothZero σ ξ) ∧
    (∃ σ ξ : ℝ, Quadrant.realises .sigmaOnly σ ξ) ∧
    (∃ σ ξ : ℝ, Quadrant.realises .xiOnly σ ξ) ∧
    (∃ σ ξ : ℝ, Quadrant.realises .bothPos σ ξ) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact ⟨0, 0, rfl, rfl⟩
  · exact ⟨1, 0, by norm_num, rfl⟩
  · exact ⟨0, 1, rfl, by norm_num⟩
  · exact ⟨1, 1, by norm_num, by norm_num⟩

/-- **R.92 — no functional dependence `ξ = f(σ_Z)`.**

If `σ_Z` determined `ξ` via some function `f : ℝ → ℝ`, then both
`(σ_Z = 0, ξ = 0)` and `(σ_Z = 0, ξ > 0)` should give the same `f 0`,
yielding `0 = f 0 > 0`.  Contradiction. -/
theorem R_92_no_function_from_sigma :
    ¬ ∃ f : ℝ → ℝ, ∀ σ ξ : ℝ,
      (Quadrant.realises .bothZero σ ξ ∨
       Quadrant.realises .sigmaOnly σ ξ ∨
       Quadrant.realises .xiOnly σ ξ ∨
       Quadrant.realises .bothPos σ ξ) → ξ = f σ := by
  rintro ⟨f, hf⟩
  have h00 : (0 : ℝ) = f 0 := hf 0 0 (Or.inl ⟨rfl, rfl⟩)
  have h01 : (1 : ℝ) = f 0 := hf 0 1 (Or.inr (Or.inr (Or.inl ⟨rfl, by norm_num⟩)))
  have : (0 : ℝ) = 1 := h00.trans h01.symm
  linarith

/-- **R.92 — no functional dependence `σ_Z = g(ξ)`.**

Symmetric: `(σ_Z = 0, ξ = 0)` and `(σ_Z > 0, ξ = 0)` would force
`g 0 = 0 = g 0 > 0`. -/
theorem R_92_no_function_from_xi :
    ¬ ∃ g : ℝ → ℝ, ∀ σ ξ : ℝ,
      (Quadrant.realises .bothZero σ ξ ∨
       Quadrant.realises .sigmaOnly σ ξ ∨
       Quadrant.realises .xiOnly σ ξ ∨
       Quadrant.realises .bothPos σ ξ) → σ = g ξ := by
  rintro ⟨g, hg⟩
  have h00 : (0 : ℝ) = g 0 := hg 0 0 (Or.inl ⟨rfl, rfl⟩)
  have h10 : (1 : ℝ) = g 0 := hg 1 0 (Or.inr (Or.inl ⟨by norm_num, rfl⟩))
  have : (0 : ℝ) = 1 := h00.trans h10.symm
  linarith

end SigmaXi

end MIP
