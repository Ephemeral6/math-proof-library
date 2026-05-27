/-
Result R.704 — Cooperative-merge intervention-count upper bound
(slot 007, EKI — tail of the R.700 entropy-power family).

Reference: `workspace/round3_exploration/slot_007.md` (R.704) and
`workspace/round3_exploration/work_slot_007.md` §5.2 (R.7.E,
"Cooperative Composition N 上界", B 条件).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement.**  In the Ohm regime, a cooperative-merge agent `X ⊞_λ Y`
solving a problem `p` admits the intervention-count (N) upper bound

    N(p, X ⊞_λ Y)  ≤  (Φ_0 · Z) / (c·H_K(X) + (1-c)·H_K(Y)),

where `c = λ Z_X / (λ Z_X + (1-λ) Z_Y)` is the EPI-K mixing weight and the
merged knowledge entropy `H_merge ≥ c·H_K(X) + (1-c)·H_K(Y)` (Shannon
concavity, R.700).  The bound rests on the **per-step potential
decrement** heuristic `ΔΦ ≳ 1/H_K`: each metacognitive intervention
dissipates at least the entropy-scaled amount of the total emergent
potential `Φ_0·Z`, so the count of steps needed to dissipate it all is at
most the ratio.

**Bundled fact (entered as an explicit hypothesis).**

* **(B-heuristic per-step ΔΦ)** `δ ≤ ΔΦ_min`, the guaranteed per-step
  decrement of the (scaled) potential, with `δ := c·H_K(X) + (1-c)·H_K(Y)`
  the harmonic-style entropy floor (work_slot_007 §5.2).  The deep
  identification of `δ` with the per-step intervention efficiency is
  *heuristic* (B-conditional in the source), so it is bundled.

We prove two crisp forms: the **division bound** (`N ≤ Φ_0·Z / δ` from a
single per-step decrement `δ`), and the **telescoping bound** (if `N`
steps each drop the potential by at least `δ`, the total drop `N·δ` is
bounded by the budget `Φ_0·Z`, hence `N ≤ Φ_0·Z / δ`).

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace EntropyPowerTail

open scoped BigOperators

/-- The cooperative-merge entropy floor
`δ := c·H_K(X) + (1-c)·H_K(Y)` — the Shannon-concavity lower bound on the
merged knowledge entropy `H_merge`, which is the per-step decrement scale
in the N bound. -/
noncomputable def mergeFloor (Hx Hy c : ℝ) : ℝ := c * Hx + (1 - c) * Hy

/-- **R.704 — cooperative-merge N upper bound (division form).**

Given the merged-budget `Φ_0·Z` (`= budget`) and the strictly positive
per-step potential decrement `δ` with the bundled heuristic
`N · δ ≤ budget` (every one of the `N` intervention steps dissipates at
least `δ` of the `Φ_0·Z` budget), the intervention count obeys

    N  ≤  budget / δ  =  (Φ_0 · Z) / δ. -/
theorem R_704_merge_N_bound
    (N budget δ : ℝ)
    (hδ : 0 < δ)
    (hbudget : N * δ ≤ budget) :
    N ≤ budget / δ := by
  rw [le_div_iff₀ hδ]
  exact hbudget

/-- **R.704 — telescoping form.**

If the metacognitive descent runs for the steps indexed by a finite set
`s`, each step `i` dropping the potential by `drop i ≥ δ > 0`, and the
cumulative drop is bounded by the emergent budget
`Σ_i drop i ≤ Φ_0·Z`, then the number of steps is at most the ratio:

    |s|  ≤  (Φ_0 · Z) / δ.

This is the genuine telescoping content: the per-step floor `δ` summed
over `s` gives `|s|·δ ≤ Σ drop ≤ budget`. -/
theorem R_704_merge_N_telescope
    {ι : Type*} (s : Finset ι) (drop : ι → ℝ)
    (budget δ : ℝ)
    (hδ : 0 < δ)
    (hstep : ∀ i ∈ s, δ ≤ drop i)
    (htotal : ∑ i ∈ s, drop i ≤ budget) :
    (s.card : ℝ) ≤ budget / δ := by
  -- |s|·δ = Σ_i δ ≤ Σ_i drop i ≤ budget.
  have hfloor : (s.card : ℝ) * δ ≤ ∑ i ∈ s, drop i := by
    have : ∑ _i ∈ s, δ ≤ ∑ i ∈ s, drop i := Finset.sum_le_sum hstep
    simpa [Finset.sum_const, nsmul_eq_mul] using this
  have hle : (s.card : ℝ) * δ ≤ budget := le_trans hfloor htotal
  exact R_704_merge_N_bound (s.card : ℝ) budget δ hδ hle

/-- **R.704 — integrated entropy form.**

Specialising the budget to `Φ_0·Z` and the per-step decrement to the
cooperative-merge entropy floor `δ = c·H_K(X) + (1-c)·H_K(Y)` (positive,
since the merged alphabet is non-trivial), with the bundled per-step
heuristic `N·δ ≤ Φ_0·Z`, the EPI-K merge improves the intervention bound:

    N(p, X ⊞_λ Y)  ≤  (Φ_0 · Z) / (c·H_K(X) + (1-c)·H_K(Y)). -/
theorem R_704_merge_N_entropy
    (N Φ₀ Z Hx Hy c : ℝ)
    (hδ : 0 < mergeFloor Hx Hy c)
    (hbudget : N * mergeFloor Hx Hy c ≤ Φ₀ * Z) :
    N ≤ (Φ₀ * Z) / mergeFloor Hx Hy c :=
  R_704_merge_N_bound N (Φ₀ * Z) (mergeFloor Hx Hy c) hδ hbudget

end EntropyPowerTail

end MIP
