/-
Conjecture Cj.NEW-8 — `μ₀(X, P) ≤ 1 − ρ` tightness.

Source: `~/Desktop/MIP/conjectures/index.md` lines ~575-601;
supporting derivation `workspace/mu0_measurement_theory.md` §1, §3
(bias/variance), §7 (V-1.3), §13.

Natural-language conjecture
---------------------------
Property (ρ-3) of D.3.16 gives `μ₀(X, P) ≤ 1 − γ_X(ε)` for all `ε > 0`,
where (writing `ρ := γ_X(ε)`)

* `μ₀(X, P) = Pr_P[p_X(p) = 1]`          — "absolutely reliable" segment,
* `ρ        = Pr_P[1 − ε < p_X(p) < 1]`  — grey band (eigen-reliability),
* and       `Pr_P[p_X(p) ≤ 1 − ε]`       — "far from 1" segment.

The motivation (index l.583) is the three-way decomposition

    μ₀ + ρ + Pr_P[p_X ≤ 1−ε] = 1                                   (★)

("absolutely reliable / grey band / far from 1").  The conjecture then
asks:
  (a) WHEN is the inequality `μ₀ ≤ 1 − ρ` an equality? — equivalent to
      "the far-from-1 segment has measure 0";
  (b) is there a subclass `𝒞_tight` of agents where equality holds
      `P`-a.e.?;
  (c) can the gap `1 − ρ − μ₀` be expressed by a combination of the 5D
      phase-space quantities (`σ_Z`, …)?

Formalization choices
---------------------
We work in a faithful finite model.  `P` is a finite index type `ι`
(the problems), `w : ι → ℝ≥0` is the probability weight `Pr_P` (so
`∑ w = 1`), and `pX : ι → ℝ` is the per-problem reliability `p_X(p) ∈
[0,1]`.  For a fixed band parameter `ε > 0` we define the three segment
masses exactly as above as sums of `w` over the corresponding index
subsets.  This is faithful: the segments are disjoint and exhaust `ι`
(every `p_X(p) ∈ [0,1]` is `=1`, in the open band, or `≤ 1−ε`, provided
`0 < ε`), so (★) holds, and nonnegativity of every weight yields the
bound.

VERDICT
=======
* **PROVED** — the bound `μ₀ ≤ 1 − ρ` (Theorem `CjNEW8_bound`), via the
  three-part partition (★) (Theorem `CjNEW8_decomposition`) and weight
  nonnegativity.  This is the substantive content of property (ρ-3) and
  is not a trivial weakening: it is the exact inequality stated in the
  conjecture, in the faithful finite model.
* **OPEN** — the equality characterization (a)/(b)/(c).  We prove the
  clean structural equivalence `μ₀ = 1 − ρ  ⟺  far-from-1 mass = 0`
  (Theorem `CjNEW8_equality_iff`), which settles the *abstract* form of
  (a): equality ⟺ the far-from-1 segment vanishes.  What remains OPEN is
  the *characterization* of which agents `X` / distributions `P` make
  that segment vanish (subclass `𝒞_tight`, part (b)) and the 5D
  phase-space expression of the gap (part (c)); both require the
  σ_Φ / σ_Z structure that the present knowledge layer does not expose.

This file is `sorry`-free and `axiom`-free (no new axioms; only the
ambient Lean/Mathlib axioms).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.NNReal.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith

namespace MIP
namespace CjNEW8

open scoped BigOperators NNReal

/-- A finite reliability profile: a problem index type `ι`, a probability
weight `w` on it (`∑ w = 1`), and a per-problem reliability `pX ∈ [0,1]`. -/
structure Profile (ι : Type) [Fintype ι] [DecidableEq ι] where
  /-- `Pr_P` over the (finite) problem index. -/
  w : ι → NNReal
  /-- `∑_p Pr_P[p] = 1`. -/
  w_sum : ∑ i, w i = 1
  /-- Per-problem reliability `p_X(p)`. -/
  pX : ι → ℝ
  /-- `0 ≤ p_X(p)`. -/
  pX_nonneg : ∀ i, 0 ≤ pX i
  /-- `p_X(p) ≤ 1`. -/
  pX_le_one : ∀ i, pX i ≤ 1

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- `μ₀(X, P) = Pr_P[p_X(p) = 1]`: mass of the absolutely-reliable segment. -/
noncomputable def mu0 (Pr : Profile ι) : NNReal :=
  ∑ i ∈ Finset.univ.filter (fun i => Pr.pX i = 1), Pr.w i

/-- `ρ = γ_X(ε) = Pr_P[1 − ε < p_X(p) < 1]`: grey-band mass. -/
noncomputable def rho (Pr : Profile ι) (ε : ℝ) : NNReal :=
  ∑ i ∈ Finset.univ.filter (fun i => 1 - ε < Pr.pX i ∧ Pr.pX i < 1), Pr.w i

/-- The "far from 1" segment mass `Pr_P[p_X(p) ≤ 1 − ε]`. -/
noncomputable def far (Pr : Profile ι) (ε : ℝ) : NNReal :=
  ∑ i ∈ Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε), Pr.w i

/-- **Three-part decomposition (★).** For any band parameter `ε > 0`,

    μ₀ + ρ + far = 1 .

The three index predicates `{pX = 1}`, `{1−ε < pX < 1}`, `{pX ≤ 1−ε}`
are pairwise disjoint and (using `0 < ε` so that `1` itself is not in the
far segment, and `pX ≤ 1`) exhaust `ι`, so the masses sum to `∑ w = 1`. -/
theorem CjNEW8_decomposition (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    mu0 Pr + rho Pr ε + far Pr ε = 1 := by
  classical
  -- The three filtered finsets cover `univ`.
  have key :
      (Finset.univ.filter (fun i => Pr.pX i = 1))
        ∪ (Finset.univ.filter (fun i => 1 - ε < Pr.pX i ∧ Pr.pX i < 1))
        ∪ (Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε)) = Finset.univ := by
    apply Finset.eq_univ_iff_forall.mpr
    intro i
    have hx1 := Pr.pX_le_one i
    simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
    -- Trichotomy on pX i versus 1 and 1 - ε.
    rcases lt_or_eq_of_le hx1 with hlt | heq
    · -- pX i < 1 : either in the grey band or far.
      rcases lt_or_ge (1 - ε) (Pr.pX i) with hgt | hle
      · exact Or.inl (Or.inr ⟨hgt, hlt⟩)
      · exact Or.inr hle
    · -- pX i = 1.
      exact Or.inl (Or.inl heq)
  -- Disjointness pairwise.
  have dAB : Disjoint (Finset.univ.filter (fun i => Pr.pX i = 1))
                      (Finset.univ.filter (fun i => 1 - ε < Pr.pX i ∧ Pr.pX i < 1)) := by
    rw [Finset.disjoint_filter]
    intro i _ ha hb
    exact (lt_irrefl (1 : ℝ)) (ha ▸ hb.2)
  have dAC : Disjoint (Finset.univ.filter (fun i => Pr.pX i = 1))
                      (Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε)) := by
    rw [Finset.disjoint_filter]
    intro i _ ha hc
    -- pX i = 1 and pX i ≤ 1 - ε ⟹ 1 ≤ 1 - ε ⟹ ε ≤ 0, contradiction.
    rw [ha] at hc; linarith
  have dBC : Disjoint (Finset.univ.filter (fun i => 1 - ε < Pr.pX i ∧ Pr.pX i < 1))
                      (Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε)) := by
    rw [Finset.disjoint_filter]
    intro i _ hb hc
    -- 1 - ε < pX i and pX i ≤ 1 - ε : contradiction.
    linarith [hb.1, hc]
  have dABC : Disjoint
      ((Finset.univ.filter (fun i => Pr.pX i = 1))
        ∪ (Finset.univ.filter (fun i => 1 - ε < Pr.pX i ∧ Pr.pX i < 1)))
      (Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε)) := by
    rw [Finset.disjoint_union_left]
    exact ⟨dAC, dBC⟩
  -- Sum over univ splits into the three filtered sums.
  have hsplit : ∑ i, Pr.w i
      = (∑ i ∈ Finset.univ.filter (fun i => Pr.pX i = 1), Pr.w i)
        + (∑ i ∈ Finset.univ.filter (fun i => 1 - ε < Pr.pX i ∧ Pr.pX i < 1), Pr.w i)
        + (∑ i ∈ Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε), Pr.w i) := by
    conv_lhs => rw [← key]
    rw [Finset.sum_union dABC, Finset.sum_union dAB]
  rw [Pr.w_sum] at hsplit
  -- Conclude.
  show mu0 Pr + rho Pr ε + far Pr ε = 1
  unfold mu0 rho far
  exact hsplit.symm

/-- **Cj.NEW-8 bound — PROVED.** `μ₀(X, P) ≤ 1 − ρ` for every `ε > 0`.

Immediate from the three-part decomposition `μ₀ + ρ + far = 1` and
`far ≥ 0`: indeed `μ₀ + ρ = 1 − far ≤ 1`, so `μ₀ ≤ 1 − ρ`. -/
theorem CjNEW8_bound (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    (mu0 Pr : ℝ) ≤ 1 - (rho Pr ε : ℝ) := by
  have hdec := CjNEW8_decomposition Pr hε
  -- Push to ℝ.
  have hdecR : (mu0 Pr : ℝ) + (rho Pr ε : ℝ) + (far Pr ε : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) hdec
    push_cast at this ⊢
    linarith [this]
  have hfar : (0 : ℝ) ≤ (far Pr ε : ℝ) := (far Pr ε).coe_nonneg
  linarith

/-- **Cj.NEW-8 equality — abstract form of (a).** `μ₀ = 1 − ρ` (as reals)
iff the far-from-1 segment has zero mass.

This is the structural equivalence the conjecture isolates as part (a):
equality in `μ₀ ≤ 1 − ρ` holds exactly when `Pr_P[p_X ≤ 1−ε] = 0`.  It
does **not** characterize *which* `(X, P)` achieve this (the OPEN parts
(b),(c)). -/
theorem CjNEW8_equality_iff (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    (mu0 Pr : ℝ) = 1 - (rho Pr ε : ℝ) ↔ far Pr ε = 0 := by
  have hdec := CjNEW8_decomposition Pr hε
  have hdecR : (mu0 Pr : ℝ) + (rho Pr ε : ℝ) + (far Pr ε : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) hdec
    push_cast at this ⊢
    linarith [this]
  constructor
  · intro heq
    have hfarR : (far Pr ε : ℝ) = 0 := by linarith
    exact_mod_cast hfarR
  · intro hfar0
    have : (far Pr ε : ℝ) = 0 := by exact_mod_cast hfar0
    linarith

/-- Faithful `Prop`-level statement of the Cj.NEW-8 *bound* (the part the
conjecture's property (ρ-3) asserts): for every reliability profile and
every band width `ε > 0`, `μ₀ ≤ 1 − ρ`. -/
def CjNEW8_Statement : Prop :=
  ∀ (ι : Type) [Fintype ι] [DecidableEq ι] (Pr : Profile ι) (ε : ℝ),
    0 < ε → (mu0 Pr : ℝ) ≤ 1 - (rho Pr ε : ℝ)

/-- The bound statement holds. -/
theorem CjNEW8_Statement_holds : CjNEW8_Statement := by
  intro ι _ _ Pr ε hε
  exact CjNEW8_bound Pr hε

end CjNEW8
end MIP
