/-
Result R.501 — Diversity-redundancy decomposition (Diversity Decomposition).
Reference: branches/collective/workspace/new_results.md (old collective R.142).

**Statement.** Under the fully-connected communication graph, the
collective cost is set entirely by the *best novel contributor*: writing
`Δ_i := max_{m ∈ M_{A_i} ∩ M^*_{A_s}} ΔΦ^*(m)` for each agent, the team's
best achievable gain is `max(Δ_s, max_{i≠s} Δ_i)`.  Agents with `Δ_i ≤
Δ_s` are *redundant* (they do not improve `N`); the team accelerates iff
some `Δ_i > Δ_s`, and then `N_full = N(p, A_s | best diverse contributor)`.
A "team" of clones of `A_s` gives no acceleration.

**Kernel formalized here.**

* **Inclusion–exclusion / redundancy split.** Total coverage equals the
  sum of individual coverages minus the redundancy (overlap):
  `|⋃_i K_i| = Σ_i |K_i| − redundancy`, with `redundancy ≥ 0`
  (`Finset.card_biUnion_le`); equality `|⋃| = Σ` iff pairwise disjoint
  (no redundancy).
* **Diversity = max decomposition.** `best gain over ⋃ M_i = max_i (best
  gain over M_i)` (`Finset.sup'_biUnion`), and splitting off the solver
  gives `max(Δ_s, max_{i≠s} Δ_i)`.
* **Domination / redundancy criterion.** If every `Δ_i ≤ Δ_s` (all
  redundant) the team max equals `Δ_s` — no acceleration; if some
  `Δ_{i*} > Δ_s` the team max is `Δ_{i*}`, set by the single best novel
  contributor; deleting redundant agents leaves the max unchanged.

**Bridge.** `M_{A_i}`, `ΔΦ^*` are MIP opaques; the decomposition is the
`Finset.card`/`sup'` algebra above, so we formalize that combinatorial
kernel with `ΔΦ` and the `M_i` as concrete `Finset`/function data.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Finset.Lattice.Union
import Mathlib.Data.Finset.Card
import Mathlib.Tactic.Linarith

namespace MIP

namespace R501_DiversityRedundancy

open scoped BigOperators

/-! ## Inclusion–exclusion: total coverage = sum of parts − redundancy. -/

/-- **R.501 (i) — sub-additivity of coverage (redundancy ≥ 0).**

The cardinality of the union coverage is at most the sum of individual
coverages: `|⋃_{i∈s} K i| ≤ Σ_{i∈s} |K i|`.  The gap
`redundancy := Σ|K_i| − |⋃ K_i| ≥ 0` measures the overlap. -/
theorem R_501_coverage_subadditive
    {ι Ω : Type} [DecidableEq Ω]
    (s : Finset ι) (K : ι → Finset Ω) :
    (s.biUnion K).card ≤ ∑ i ∈ s, (K i).card :=
  Finset.card_biUnion_le

/-- **R.501 (i') — redundancy is non-negative.**

Define `redundancy := (Σ_i |K i|) − |⋃_i K i|` over `ℤ`.  Then
`redundancy ≥ 0`, i.e. the decomposition `|⋃ K_i| = Σ|K_i| − redundancy`
has a non-negative redundancy term. -/
theorem R_501_redundancy_nonneg
    {ι Ω : Type} [DecidableEq Ω]
    (s : Finset ι) (K : ι → Finset Ω) :
    (0 : ℤ) ≤ ((∑ i ∈ s, (K i).card : ℕ) : ℤ) - ((s.biUnion K).card : ℤ) := by
  have h := R_501_coverage_subadditive s K
  have hcast : ((s.biUnion K).card : ℤ) ≤ ((∑ i ∈ s, (K i).card : ℕ) : ℤ) := by
    exact_mod_cast h
  linarith

/-- **R.501 (i'') — diversity = unique coverage (disjoint ⟹ no redundancy).**

If the agents' coverages are pairwise disjoint (pure diversity, zero
overlap) then the inequality is an equality: `|⋃_i K_i| = Σ_i |K_i|`. -/
theorem R_501_diverse_equality
    {ι Ω : Type} [DecidableEq Ω]
    (s : Finset ι) (K : ι → Finset Ω)
    (hdisj : (s : Set ι).PairwiseDisjoint K) :
    (s.biUnion K).card = ∑ i ∈ s, (K i).card :=
  Finset.card_biUnion (fun _ hi _ hj hij => hdisj hi hj hij)

/-! ## Diversity = `max` decomposition (Step 1–2). -/

/-- **R.501 (ii) — best team gain is the per-agent max (Step 1).**

The best achievable emergence gain over the union tool set
`⋃_{i∈s} M_i` equals the maximum over agents of each agent's best gain:
`max_{m ∈ ⋃ M_i} ΔΦ m = max_i (max_{m ∈ M_i} ΔΦ m)`. -/
theorem R_501_team_gain_eq_max
    {ι Ω : Type} [DecidableEq Ω]
    (s : Finset ι) (M : ι → Finset Ω) (ΔΦ : Ω → ℝ)
    (hs : s.Nonempty) (hM : ∀ i, (M i).Nonempty) :
    (s.biUnion M).sup' (hs.biUnion fun b _ => hM b) ΔΦ
      = s.sup' hs (fun i => (M i).sup' (hM i) ΔΦ) :=
  Finset.sup'_biUnion ΔΦ hs hM

/-- **R.501 (ii') — solver/contributor split (Step 2).**

Splitting the team gain over `{s} ∪ rest` into the solver's own best gain
`Δ_s` and the best contributor gain `max_{i∈rest} Δ_i`:
`max over {s}∪rest = max(Δ_s, max_{i∈rest} Δ_i)`. -/
theorem R_501_solver_contributor_split
    {ι : Type} [DecidableEq ι]
    (sIdx : ι) (rest : Finset ι) (Δ : ι → ℝ) (hrest : rest.Nonempty) :
    (insert sIdx rest).sup' (Finset.insert_nonempty sIdx rest) Δ
      = max (Δ sIdx) (rest.sup' hrest Δ) := by
  rw [Finset.sup'_insert]

/-! ## Domination / redundancy criterion (Step 3–4). -/

/-- **R.501 (iii) — all redundant ⟹ no acceleration (Step 3).**

If every contributor is redundant (`Δ_i ≤ Δ_s` for all `i ∈ rest`), then
the team's best gain equals the solver's own best gain `Δ_s`: the team
provides no acceleration (`Z_q = Z(A_s)`, `N_full = N(p, A_s)`). -/
theorem R_501_all_redundant
    {ι : Type} [DecidableEq ι]
    (sIdx : ι) (rest : Finset ι) (Δ : ι → ℝ) (hrest : rest.Nonempty)
    (hred : ∀ i ∈ rest, Δ i ≤ Δ sIdx) :
    (insert sIdx rest).sup' (Finset.insert_nonempty sIdx rest) Δ = Δ sIdx := by
  rw [R_501_solver_contributor_split sIdx rest Δ hrest]
  apply max_eq_left
  exact Finset.sup'_le hrest Δ hred

/-- **R.501 (iv) — best novel contributor dominates (Step 4).**

If there is a novel contributor `i* ∈ rest` whose gain dominates the
solver and all others (`Δ_s ≤ Δ_{i*}` and `Δ_i ≤ Δ_{i*}` for all
`i ∈ rest`), then the team's best gain equals `Δ_{i*}`: the single best
novel contributor sets the collective rate, and removing the (redundant)
others does not change it. -/
theorem R_501_best_contributor_dominates
    {ι : Type} [DecidableEq ι]
    (sIdx : ι) (rest : Finset ι) (Δ : ι → ℝ) (hrest : rest.Nonempty)
    (iStar : ι) (hiStar : iStar ∈ rest)
    (hdomS : Δ sIdx ≤ Δ iStar)
    (hdomRest : ∀ i ∈ rest, Δ i ≤ Δ iStar) :
    (insert sIdx rest).sup' (Finset.insert_nonempty sIdx rest) Δ = Δ iStar := by
  rw [R_501_solver_contributor_split sIdx rest Δ hrest]
  have hrest_max : rest.sup' hrest Δ = Δ iStar :=
    le_antisymm (Finset.sup'_le hrest Δ hdomRest) (Finset.le_sup' Δ hiStar)
  rw [hrest_max]
  exact max_eq_right hdomS

/-- **R.501 (counterexample) — clone team is equivalent to the original.**

If all agents in `rest` are clones with the same gain as the solver
(`Δ_i = Δ_s`), then the team gain is exactly `Δ_s`: `k` clones are
equivalent to the lone solver — team size alone gives no acceleration. -/
theorem R_501_clones_no_speedup
    {ι : Type} [DecidableEq ι]
    (sIdx : ι) (rest : Finset ι) (Δ : ι → ℝ) (hrest : rest.Nonempty)
    (hclone : ∀ i ∈ rest, Δ i = Δ sIdx) :
    (insert sIdx rest).sup' (Finset.insert_nonempty sIdx rest) Δ = Δ sIdx :=
  R_501_all_redundant sIdx rest Δ hrest (fun i hi => le_of_eq (hclone i hi))

end R501_DiversityRedundancy

end MIP
