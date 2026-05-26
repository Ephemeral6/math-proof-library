/-
Result R-SUB.12 — `K(X)` carries a discrete probability-space structure.

Reference: `workspace/subdomain_competition.md` §6.12 (A 无条件，整理性).

**Statement.** `(K(X), 2^{K(X)}, p_X)` is a discrete probability space:
the σ-algebra is the full power set `2^{K(X)}`, and the activation
distribution `p_X` (normalised per D.1.3.b v2) defines a probability
measure on it, with support boundary supplied by A.4.

**Organizational content (the crisp part).** On a finite knowledge
universe `Ω` with the discrete σ-algebra, the assignment
`mass(S) := Σ_{ω ∈ S} p_X(ω)` is a genuine finitely-additive probability
content:

* `mass ∅ = 0`                                   (empty set),
* `mass Finset.univ = 1`                          (total mass, from D.1.3.b),
* `mass` is **monotone**: `S ⊆ T ⟹ mass S ≤ mass T`,
* `mass` is **finitely additive**: `Disjoint S T ⟹
   mass (S ∪ T) = mass S + mass T`,
* `mass S ≤ 1` for every event `S`,
* (countable→finite) additivity over a disjoint `biUnion`.

These are exactly the Kolmogorov axioms in the discrete setting; together
with the support condition from A.4 they pin down the probability space.
We use the existing `ActivationDist Ω` structure and its `mass` field from
`MIP.Defs.Knowledge`.

**This file is `sorry`-free; the only imported `axiom`s are Lean's
standard `propext / Classical.choice / Quot.sound` (via `MIP.Defs.Knowledge`,
which introduces no `axiom` of its own).**
-/
import MIP.Defs.Knowledge
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators

namespace KnowledgeMeasureSpace

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

omit [DecidableEq Ω] in
/-- **Empty event has zero mass.** -/
@[simp] theorem mass_empty (d : ActivationDist Ω) :
    d.mass (∅ : Finset Ω) = 0 := by
  unfold ActivationDist.mass
  simp

omit [DecidableEq Ω] in
/-- **Total mass is one** (Kolmogorov normalisation; restatement of
`ActivationDist.mass_univ`). -/
theorem mass_univ (d : ActivationDist Ω) :
    d.mass (Finset.univ : Finset Ω) = 1 :=
  d.mass_univ

/-- **Finite additivity over a disjoint union.** For disjoint events
`S, T`, mass is additive. -/
theorem mass_union_of_disjoint (d : ActivationDist Ω)
    {S T : Finset Ω} (h : Disjoint S T) :
    d.mass (S ∪ T) = d.mass S + d.mass T := by
  unfold ActivationDist.mass
  exact Finset.sum_union h

omit [DecidableEq Ω] in
/-- **Monotonicity.** A sub-event has no greater mass. -/
theorem mass_mono (d : ActivationDist Ω)
    {S T : Finset Ω} (h : S ⊆ T) :
    d.mass S ≤ d.mass T := by
  unfold ActivationDist.mass
  exact Finset.sum_le_sum_of_subset h

omit [DecidableEq Ω] in
/-- **Every event has mass at most one** (the measure is a probability,
not just a content). -/
theorem mass_le_one (d : ActivationDist Ω) (S : Finset Ω) :
    d.mass S ≤ 1 := by
  rw [← mass_univ d]
  exact mass_mono d (Finset.subset_univ S)

/-- **Complement rule.** `mass(Sᶜ) = 1 − mass S`, valid in `ℝ` after
casting (in `ℝ≥0` the subtraction is truncated, so we phrase it as the
partition identity `mass S + mass Sᶜ = 1`). -/
theorem mass_add_compl (d : ActivationDist Ω) (S : Finset Ω) :
    d.mass S + d.mass Sᶜ = 1 := by
  rw [← mass_union_of_disjoint d (disjoint_compl_right)]
  rw [Finset.union_compl]
  exact mass_univ d

/-- **σ-additivity in the finite/discrete setting.** Mass distributes
over a disjoint `biUnion` of a family of events. This is the discrete
analogue of countable additivity. -/
theorem mass_biUnion (d : ActivationDist Ω)
    (I : Finset (Finset Ω))
    (h : (I : Set (Finset Ω)).PairwiseDisjoint id) :
    d.mass (I.biUnion id) = ∑ S ∈ I, d.mass S := by
  unfold ActivationDist.mass
  rw [Finset.sum_biUnion h]
  simp only [id]

/-- **R-SUB.12 — the discrete probability-space structure of `K(X)`.**

Bundling the Kolmogorov axioms: `p_X` (via `d.mass`) is a normalised,
monotone, finitely-additive probability content on the discrete
σ-algebra `2^Ω`. -/
theorem R_SUB_12_probability_space (d : ActivationDist Ω) :
    d.mass (∅ : Finset Ω) = 0
    ∧ d.mass (Finset.univ : Finset Ω) = 1
    ∧ (∀ S T : Finset Ω, Disjoint S T →
        d.mass (S ∪ T) = d.mass S + d.mass T)
    ∧ (∀ S T : Finset Ω, S ⊆ T → d.mass S ≤ d.mass T)
    ∧ (∀ S : Finset Ω, d.mass S ≤ 1) :=
  ⟨mass_empty d, mass_univ d,
    fun _ _ h => mass_union_of_disjoint d h,
    fun _ _ h => mass_mono d h,
    mass_le_one d⟩

end KnowledgeMeasureSpace

end MIP
