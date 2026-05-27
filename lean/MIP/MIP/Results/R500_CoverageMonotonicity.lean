/-
Result R.500 — M-coverage monotonicity (Collective Monotonicity).
Reference: branches/collective/workspace/new_results.md (old collective R.141).

**Statement.** Let `G₁ = (V, E₁)` and `G₂ = (V, E₂)` be two communication
graphs on the same agent set with `E₁ ⊆ E₂`.  Then the effective
intervention-generation set is monotone:
`M^eff_{G₁}(s) ⊆ M^eff_{G₂}(s)`, the collective dual impedance is antitone
`Z_q(G₁) ≥ Z_q(G₂)`, and (Ohm regime) the collective emergence cost is
antitone `N_{G₁} ≥ N_{G₂}`.  Intuition: adding communication edges only
ever lowers `N` — "more information never hurts".

**Kernel formalized here.** The graph-theoretic / set-theoretic monotone
core, with the Ohm-regime cost law bundled as a hypothesis:

* (i) `Reach` monotone: a larger upstream index set `S ⊆ T` gives a larger
  union coverage `S.biUnion K ⊆ T.biUnion K` (`Finset.biUnion`).
* (ii) `M^eff ∩ M^*` monotone, hence the `max ΔΦ^*` over the larger set is
  not smaller (`Finset.sup'` monotone / `le_sup'`).
* (iii) Reciprocal antitone: `0 < d₁ ≤ d₂ ⟹ d₂⁻¹ ≤ d₁⁻¹`, so the
  impedance `Z_q = (max ΔΦ^*)⁻¹` is antitone in coverage.
* (iv) Ohm-regime cost `N = Φ₀ · Z_q` (bundled), hence `N` antitone in
  coverage; an `ℕ∞` `inf`-antitonicity consequence for the discrete count.
* Corollaries: empty graph is worst (coverage = `K s` only), full graph is
  best (coverage = `⋃_i K_i`).

**Bridge.** `MIP.K`/`MIP.N`/`MIP.R` are opaque; the monotonicity is purely
the `Finset.biUnion`/`sup'`/reciprocal facts above, so we formalize that
combinatorial kernel directly and bundle the D.M.4 reciprocal law and the
D.M.4-P3 Ohm cost law as hypotheses, matching the paper's dependence on
D.3.9 / T.8.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.ENat.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace R500_CoverageMonotonicity

open scoped BigOperators

/-! ## (i) Coverage monotonicity: `S ⊆ T ⟹ ⋃_{i∈S} K_i ⊆ ⋃_{i∈T} K_i`. -/

/-- **R.500 (i) — union coverage is monotone in the upstream index set.**

If `S ⊆ T` are upstream agent-index sets (e.g. `Reach^{-1}_{G₁}(s) ⊆
Reach^{-1}_{G₂}(s)` for `E₁ ⊆ E₂`), then the union coverage grows:
`⋃_{i∈S} K i ⊆ ⋃_{i∈T} K i`.  This is `M^eff` monotonicity (Step 1). -/
theorem R_500_coverage_mono
    {ι Ω : Type} [DecidableEq Ω]
    (S T : Finset ι) (K : ι → Finset Ω) (hST : S ⊆ T) :
    S.biUnion K ⊆ T.biUnion K :=
  Finset.biUnion_subset_biUnion_of_subset_left K hST

/-- **R.500 (i') — Reach-inverse monotonicity packaged.**

Given the graph fact `Reach^{-1}_{G₁}(s) ⊆ Reach^{-1}_{G₂}(s)` (denser
graph ⟹ larger reachable-to-`s` set), the effective generation sets
satisfy `M^eff_{G₁}(s) ⊆ M^eff_{G₂}(s)`. -/
theorem R_500_Meff_mono
    {ι Ω : Type} [DecidableEq Ω]
    (reachInv₁ reachInv₂ : Finset ι) (M : ι → Finset Ω)
    (hreach : reachInv₁ ⊆ reachInv₂) :
    reachInv₁.biUnion M ⊆ reachInv₂.biUnion M :=
  R_500_coverage_mono reachInv₁ reachInv₂ M hreach

/-! ## (ii) The `max ΔΦ^*` over a larger admissible set is not smaller. -/

/-- **R.500 (ii) — best per-element gain is monotone in the candidate set.**

Let `ΔΦ : Ω → ℝ` be the per-intervention emergence-potential gain.  If the
admissible meta-intervention set grows `A ⊆ B` (both nonempty), then the
best achievable gain `max_{m ∈ A} ΔΦ m ≤ max_{m ∈ B} ΔΦ m`. -/
theorem R_500_best_gain_mono
    {Ω : Type}
    (A B : Finset Ω) (ΔΦ : Ω → ℝ)
    (hAB : A ⊆ B) (hA : A.Nonempty) :
    A.sup' hA ΔΦ ≤ B.sup' (hA.mono hAB) ΔΦ := by
  apply Finset.sup'_le hA ΔΦ
  intro m hm
  exact Finset.le_sup' ΔΦ (hAB hm)

/-! ## (iii) Reciprocal antitonicity: `Z_q = (best gain)⁻¹` is antitone. -/

/-- **R.500 (iii) — impedance antitone in the best gain.**

With `Z_q := (best gain)⁻¹` (D.M.4), a larger best gain `0 < d₁ ≤ d₂`
yields a smaller impedance `d₂⁻¹ ≤ d₁⁻¹`.  Combined with (ii): a denser
graph has `Z_q(G₁) ≥ Z_q(G₂)` (Step 2). -/
theorem R_500_impedance_antitone
    (d₁ d₂ : ℝ) (hd₁ : 0 < d₁) (hd : d₁ ≤ d₂) :
    d₂⁻¹ ≤ d₁⁻¹ := by
  rw [← one_div, ← one_div]
  exact one_div_le_one_div_of_le hd₁ hd

/-! ## (iv) Ohm-regime cost antitonicity (real and `ℕ∞` forms). -/

/-- **R.500 (iv, real) — collective cost antitone (Ohm regime).**

In the Ohm regime `N_G = Φ₀ · Z_q(G)` (D.M.4 P3).  With `Φ₀ ≥ 0` and the
impedance ordering `Z_q(G₂) ≤ Z_q(G₁)` from (ii)+(iii), the collective
cost is antitone: `N_{G₂} ≤ N_{G₁}` (Step 3). -/
theorem R_500_cost_antitone
    (Φ₀ Zq₁ Zq₂ : ℝ) (hΦ : 0 ≤ Φ₀) (hZ : Zq₂ ≤ Zq₁) :
    Φ₀ * Zq₂ ≤ Φ₀ * Zq₁ :=
  mul_le_mul_of_nonneg_left hZ hΦ

/-- **R.500 — end-to-end real chain (denser graph ⟹ no larger cost).**

Bundling the three steps: from `E₁ ⊆ E₂` (encoded as `reachInv₁ ⊆
reachInv₂` and the best-gain ordering), with `0 < d₁ ≤ d₂` the gains,
`Z_q i := d_i⁻¹` the impedances and `Φ₀ ≥ 0` the Ohm coefficient, the
collective costs satisfy `N_{G₂} ≤ N_{G₁}`. -/
theorem R_500_collective_antitone
    (Φ₀ d₁ d₂ : ℝ) (hΦ : 0 ≤ Φ₀) (hd₁ : 0 < d₁) (hd : d₁ ≤ d₂) :
    Φ₀ * d₂⁻¹ ≤ Φ₀ * d₁⁻¹ :=
  R_500_cost_antitone Φ₀ d₁⁻¹ d₂⁻¹ hΦ (R_500_impedance_antitone d₁ d₂ hd₁ hd)

/-- **R.500 (iv, ℕ∞) — discrete cost antitone via the `Antitone` interface.**

Modelling the collective cost as an antitone function `Ncost : Finset ι →
ℕ∞` of the upstream index set (more upstream agents ⟹ no larger cost),
`S ⊆ T ⟹ Ncost T ≤ Ncost S`.  This is the `ℕ∞`-valued statement
`N_{G₁} ≥ N_{G₂}` of the result. -/
theorem R_500_Ncost_antitone
    {ι : Type} (Ncost : Finset ι → ℕ∞) (hanti : Antitone Ncost)
    (S T : Finset ι) (hST : S ⊆ T) :
    Ncost T ≤ Ncost S :=
  hanti hST

/-! ## Corollaries: empty graph worst, full graph best. -/

/-- **C.500.1 — empty graph: coverage is the solver alone.**

If `Reach^{-1}_G(s) = {s}` (`s`-isolated, empty communication), the
effective coverage is exactly `K s`: no external aid. -/
theorem R_500_empty_graph_coverage
    {ι Ω : Type} [DecidableEq Ω]
    (s : ι) (K : ι → Finset Ω) :
    ({s} : Finset ι).biUnion K = K s := by
  simp

/-- **C.500.2 — full graph is best: solver coverage ⊆ full coverage.**

With `Reach^{-1}_{G_full}(s) = V`, the full-graph coverage `V.biUnion K`
contains the empty-graph coverage `K s` for any `s ∈ V`.  Hence the full
graph never has larger cost (combine with `R_500_coverage_mono`). -/
theorem R_500_full_graph_best
    {ι Ω : Type} [DecidableEq Ω] [Fintype ι]
    (s : ι) (K : ι → Finset Ω) :
    K s ⊆ (Finset.univ : Finset ι).biUnion K := by
  rw [← R_500_empty_graph_coverage s K]
  exact R_500_coverage_mono {s} Finset.univ K (Finset.subset_univ _)

end R500_CoverageMonotonicity

end MIP
