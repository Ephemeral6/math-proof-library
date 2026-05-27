/-
Result R.47g — Differential-geometric / convex-geometric structure of the
sublevel set Σ₀(δ) (the B-grade geometric strengthening of R.47t).

Reference: `proofs/derived/A_grade.md` R.47t §"微分几何（保持 B）" — R.47g is
the B-class differential-geometry extension of R.47t (one of the seven
irreducible-hypothesis B results, A_grade.md line 808).  R.47t (already
formalized in `R47t_SigmaTopology.lean`) gives the *topological* properties
(closedness, monotone expansion).  R.47g supplies the genuinely NEW *geometric*
content that needs more than topology: **convexity** of Σ₀(δ) when the
emergence free-energy `Φ₀` is convex, and the **boundary characterisation**
`∂Σ₀(δ) ⊆ {Φ₀ = δ}` (the smooth boundary / level-set structure).

**Statement (geometric fragment).** Model system space as a real vector space
(or normed space) `X` and take `Φ₀ : X → ℝ` as the emergence free-energy
(`Φ₀(A) = -log Pr(A)`).  The `N = 0` sublevel set is

    Σ₀(δ) := { A : Φ₀(A) ≤ δ } .

* **(G1) Convexity.** If `Φ₀` is a convex function, then `Σ₀(δ)` is a convex
  set for every threshold `δ`: the sublevel set of a convex function is convex.
  Geometrically the admissible region has no "holes" or non-convex pockets —
  any convex combination of two admissible systems is admissible.
* **(G2) Convexity of the strict sublevel set** `{Φ₀ < δ}` likewise.
* **(G3) Boundary lies in the level set.** With `Φ₀` continuous, the
  topological boundary satisfies `∂Σ₀(δ) ⊆ {x : Φ₀ x = δ}`: the boundary of the
  admissible region is contained in the `Φ₀ = δ` level set — the locus where
  the smooth-structure / measure-zero analysis of R.47g lives.
* **(G4) Nesting of the boundary level sets** is disjoint across thresholds:
  `δ₁ ≠ δ₂ ⟹ {Φ₀ = δ₁} ∩ {Φ₀ = δ₂} = ∅`, so distinct thresholds have
  disjoint boundaries (the level sets foliate system space).
* **(G5) Star-shapedness fallback.** Even without full convexity, if `Φ₀` is
  *quasi-convex* (sublevel sets convex by hypothesis) the conclusion (G1) is
  recovered; we record the convex-function ⟹ quasi-convex implication via the
  sublevel set.

The convexity hypothesis on `Φ₀` is the bundled B-grade assumption (it is the
"differential-geometric structure beyond the current axioms" flagged in
A_grade.md); everything else is derived.

**This file is `axiom`-free.**  Convexity / continuity of `Φ₀` enter as
explicit hypotheses; Mathlib's convex-analysis and topology library does the
rest.
-/
import Mathlib.Analysis.Convex.Function
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Topology.Instances.Real.Lemmas

namespace MIP

namespace SigmaConvexity

variable {X : Type*}

/-- The `N = 0` sublevel set `Σ₀(δ) = { A : Φ₀(A) ≤ δ }`. -/
def Sigma0 (Φ₀ : X → ℝ) (δ : ℝ) : Set X := {x | Φ₀ x ≤ δ}

/-- The strict sublevel set `{ A : Φ₀(A) < δ }`. -/
def Sigma0Strict (Φ₀ : X → ℝ) (δ : ℝ) : Set X := {x | Φ₀ x < δ}

/-- The `Φ₀ = δ` level set (the candidate boundary of `Σ₀(δ)`). -/
def Level (Φ₀ : X → ℝ) (δ : ℝ) : Set X := {x | Φ₀ x = δ}

/-- **R.47g (G1) — `Σ₀(δ)` is convex when `Φ₀` is convex.**

The sublevel set of a convex emergence free-energy `Φ₀` is a convex region:
any convex combination of two systems each with `Φ₀ ≤ δ` again has `Φ₀ ≤ δ`.
This is the new geometric content beyond R.47t's closedness. -/
theorem R_47g_G1_convex
    [AddCommGroup X] [Module ℝ X] {s : Set X}
    {Φ₀ : X → ℝ} (hΦ : ConvexOn ℝ s Φ₀) (δ : ℝ) :
    Convex ℝ (s ∩ Sigma0 Φ₀ δ) :=
  hΦ.convex_le δ

/-- **R.47g (G1') — global convexity over the whole space.**

When `Φ₀` is convex on all of `X` (`s = univ`), `Σ₀(δ)` itself is convex. -/
theorem R_47g_G1_convex_univ
    [AddCommGroup X] [Module ℝ X]
    {Φ₀ : X → ℝ} (hΦ : ConvexOn ℝ Set.univ Φ₀) (δ : ℝ) :
    Convex ℝ (Sigma0 Φ₀ δ) := by
  have h := hΦ.convex_le δ
  simpa [Sigma0, Set.univ_inter] using h

/-- **R.47g (G2) — the strict sublevel set is convex.**

`{Φ₀ < δ}` is convex for a convex `Φ₀`: the open admissible region is convex. -/
theorem R_47g_G2_convex_strict
    [AddCommGroup X] [Module ℝ X]
    {Φ₀ : X → ℝ} (hΦ : ConvexOn ℝ Set.univ Φ₀) (δ : ℝ) :
    Convex ℝ (Sigma0Strict Φ₀ δ) := by
  have h := hΦ.convex_lt δ
  simpa [Sigma0Strict, Set.univ_inter] using h

/-- **R.47g (G3) — boundary lies in the level set `{Φ₀ = δ}`.**

For continuous `Φ₀`, the topological boundary of the closed sublevel set
`Σ₀(δ)` is contained in the `Φ₀ = δ` level set.  This locates the
smooth-boundary / measure-zero analysis of R.47g on the level set: a point on
the boundary is a limit of admissible (`Φ₀ ≤ δ`) points and of inadmissible
(`Φ₀ > δ`) points, hence `Φ₀ = δ` by continuity. -/
theorem R_47g_G3_boundary_subset_level
    [TopologicalSpace X]
    {Φ₀ : X → ℝ} (hΦ : Continuous Φ₀) (δ : ℝ) :
    frontier (Sigma0 Φ₀ δ) ⊆ Level Φ₀ δ := by
  intro x hx
  -- `Σ₀(δ)` is closed, so its frontier is contained in it: `Φ₀ x ≤ δ`.
  have hclosed : IsClosed (Sigma0 Φ₀ δ) := isClosed_le hΦ continuous_const
  have hx_in : x ∈ Sigma0 Φ₀ δ := hclosed.frontier_subset hx
  have hle : Φ₀ x ≤ δ := hx_in
  -- A frontier point is not in the interior.  The open strict sublevel set
  -- `{Φ₀ < δ}` is contained in `Σ₀(δ)`, hence in its interior; so `x` cannot
  -- satisfy `Φ₀ x < δ`, giving `δ ≤ Φ₀ x`.
  have hnotint : x ∉ interior (Sigma0 Φ₀ δ) := hx.2
  have hge : δ ≤ Φ₀ x := by
    by_contra hcon
    have hlt : Φ₀ x < δ := lt_of_not_ge hcon
    -- `Φ₀ x < δ`, and `{Φ₀ < δ}` is open ⊆ `Σ₀(δ)`, so `x ∈ interior`.
    have hopen : IsOpen (Sigma0Strict Φ₀ δ) := isOpen_lt hΦ continuous_const
    have hsub : Sigma0Strict Φ₀ δ ⊆ Sigma0 Φ₀ δ := by
      intro y hy
      simp only [Sigma0Strict, Set.mem_setOf_eq] at hy
      exact le_of_lt hy
    have hxint : x ∈ interior (Sigma0 Φ₀ δ) :=
      interior_maximal hsub hopen hlt
    exact hnotint hxint
  exact le_antisymm hle hge

/-- **R.47g (G4) — distinct thresholds have disjoint boundary level sets.**

`δ₁ ≠ δ₂ ⟹ {Φ₀ = δ₁} ∩ {Φ₀ = δ₂} = ∅`.  The level sets `{Φ₀ = δ}` foliate
system space: a system cannot have two distinct free-energy values, so the
boundaries of `Σ₀(δ₁)` and `Σ₀(δ₂)` (each ⊆ its level set, by G3) are
disjoint. -/
theorem R_47g_G4_levels_disjoint
    {Φ₀ : X → ℝ} {δ₁ δ₂ : ℝ} (h : δ₁ ≠ δ₂) :
    Level Φ₀ δ₁ ∩ Level Φ₀ δ₂ = (∅ : Set X) := by
  ext x
  simp only [Level, Set.mem_inter_iff, Set.mem_setOf_eq, Set.mem_empty_iff_false,
    iff_false, not_and]
  intro h1 h2
  exact h (h1.symm.trans h2)

/-- **R.47g (G5) — convex `Φ₀` ⟹ quasi-convex (all sublevel sets convex).**

Records that convexity of `Φ₀` already gives the geometric conclusion at every
threshold simultaneously: the indexed family `δ ↦ Σ₀(δ)` is pointwise convex.
This is the "no non-convex admissible pocket at any threshold" statement. -/
theorem R_47g_G5_quasiconvex
    [AddCommGroup X] [Module ℝ X]
    {Φ₀ : X → ℝ} (hΦ : ConvexOn ℝ Set.univ Φ₀) :
    ∀ δ, Convex ℝ (Sigma0 Φ₀ δ) :=
  fun δ => R_47g_G1_convex_univ hΦ δ

/-- **R.47g — combined convex-geometric characterisation.**

For a convex *and* continuous emergence free-energy `Φ₀`, the admissible
family `δ ↦ Σ₀(δ)` is convex at every threshold and each boundary lies in the
corresponding `Φ₀ = δ` level set — the convex-region + smooth-boundary picture
that R.47g adds on top of R.47t's topology. -/
theorem R_47g_geometry
    [TopologicalSpace X] [AddCommGroup X] [Module ℝ X]
    {Φ₀ : X → ℝ} (hconv : ConvexOn ℝ Set.univ Φ₀) (hcont : Continuous Φ₀) :
    (∀ δ, Convex ℝ (Sigma0 Φ₀ δ)) ∧ (∀ δ, frontier (Sigma0 Φ₀ δ) ⊆ Level Φ₀ δ) :=
  ⟨R_47g_G5_quasiconvex hconv, fun δ => R_47g_G3_boundary_subset_level hcont δ⟩

end SigmaConvexity

end MIP
