/-
Result R.504 — Diversity critical transition (coverage phase transition).
Reference: branches/collective/workspace/new_results.md (old collective R.145).

**Statement.** A team `{A_i, i ∈ V \ {s}}` of upstream agents each contributes
a knowledge subset `M_{A_i} ⊆ M^*_{A_s}` (the solver-readable meta-cognitive
interventions, `|M^*_{A_s}| = M_total`).  The diversity parameter is

    λ := (Σ_i m_i) / M_total ,   m_i := |M_{A_i}| .

The team covers the whole target space `M^*_{A_s}` (i.e. ⋃_i M_{A_i} = M^*_{A_s})
only past a critical threshold `λ_c ∈ [1, 1 + log(M_total)/M_total]`.  Below the
information floor `λ < 1` coverage is impossible (pigeonhole); the collective
emergence cost `N_G` stays strictly above the floor `N_min`, then jumps to
`N_min` once coverage is achieved.

**Kernel formalized here.** Three clean ingredients.

1. **Sub-additive union floor (the `λ < 1` impossibility).** The size of a
   finite union is at most the sum of the sizes:
   `|⋃_i M_i| ≤ Σ_i |M_i|`.  Hence if `Σ_i m_i < M_total` (i.e. `λ < 1`) the
   union can never reach `M_total`, so it cannot equal the full target set —
   coverage is impossible.  This is the rigorous `Pr[cover] = 0` direction.

2. **Coverage ⟺ union = target (above threshold).** Equivalently, the union
   covers the full target iff `M^*_{A_s} ⊆ ⋃_i M_i`; for finite sets with the
   union contained in the target this is `|⋃_i M_i| = M_total`.

3. **Threshold step / S-curve of `N_G`.** The collective cost as a function of
   the coverage indicator is a monotone step: a unique critical `λ_c` with
   `N_G = N_min` for `λ ≥ λ_c` and `N_G > N_min` (strictly) for `λ < λ_c`,
   abstracted to a real threshold dichotomy (mirrors R.79 Grokking).

**Bridge.** Maps `M_total = |M^*_{A_s}|`, `m_i = |M_{A_i}|`, union = team `M^eff`;
the Coupon-Collector asymptotics fix `λ_c ∈ [1, 1+log M/M]`, of which the
`λ < 1` impossibility half is the exact finite kernel proven here.

Axiom-free.
-/
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace DiversityTransition

open scoped BigOperators

/-! ## 1. Sub-additive union floor: `λ < 1` ⟹ coverage impossible. -/

/-- **R.504 (i) — finite-union cardinality floor.**

The cardinality of the union of a finite family of finite sets is at most the
sum of their cardinalities:

    |⋃_{i ∈ V} M_i| ≤ Σ_{i ∈ V} |M_i| .

This is the exact pigeonhole that powers the diversity impossibility: with total
contributed mass `Σ m_i` you can never cover more than `Σ m_i` distinct
elements. -/
theorem R_504_union_card_le_sum
    {Ω : Type} [DecidableEq Ω] {ι : Type}
    (V : Finset ι) (M : ι → Finset Ω) :
    (V.biUnion M).card ≤ ∑ i ∈ V, (M i).card :=
  Finset.card_biUnion_le

/-- **R.504 (ii) — sub-critical impossibility (`λ < 1` ⟹ no coverage).**

If the total contributed mass is strictly below the target size,
`Σ_i |M_i| < M_total`, then the team union cannot cover a target set `T` of
size `M_total`: `¬ (T ⊆ ⋃_i M_i)`.  This is the rigorous `Pr[cover] = 0`
direction of the diversity phase transition.

Here `λ = (Σ m_i)/M_total`, so the hypothesis is exactly `λ < 1`. -/
theorem R_504_subcritical_no_cover
    {Ω : Type} [DecidableEq Ω] {ι : Type}
    (V : Finset ι) (M : ι → Finset Ω) (T : Finset Ω)
    (h_lt : ∑ i ∈ V, (M i).card < T.card) :
    ¬ (T ⊆ V.biUnion M) := by
  intro h_cover
  -- T ⊆ ⋃ M ⟹ |T| ≤ |⋃ M| ≤ Σ |M_i| < |T|, contradiction.
  have h1 : T.card ≤ (V.biUnion M).card := Finset.card_le_card h_cover
  have h2 : (V.biUnion M).card ≤ ∑ i ∈ V, (M i).card :=
    R_504_union_card_le_sum V M
  exact absurd (le_trans h1 h2) (not_le.mpr h_lt)

/-- **R.504 (ii′) — diversity-parameter form of the impossibility.**

With `λ := (Σ_i m_i) / M_total` and `M_total > 0`, the hypothesis `λ < 1` is
equivalent to `Σ_i m_i < M_total`; coverage of a target of size `M_total` is
then impossible.  States the transition in its native `λ < 1` form. -/
theorem R_504_lambda_lt_one_no_cover
    {Ω : Type} [DecidableEq Ω] {ι : Type}
    (V : Finset ι) (M : ι → Finset Ω) (T : Finset Ω)
    (hT : 0 < T.card)
    (h_lambda : (∑ i ∈ V, (M i).card : ℝ) / (T.card : ℝ) < 1) :
    ¬ (T ⊆ V.biUnion M) := by
  apply R_504_subcritical_no_cover V M T
  -- λ < 1 with positive denominator ⟹ Σ m_i < M_total over ℝ ⟹ over ℕ.
  have hTpos : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast hT
  rw [div_lt_one hTpos] at h_lambda
  -- h_lambda : ∑ ↑(M i).card < ↑T.card  (over ℝ); cast back down to ℕ.
  exact_mod_cast h_lambda

/-! ## 2. Supercritical: coverage ⟺ union equals the full target. -/

/-- **R.504 (iii) — coverage characterisation.**

For finite sets with `⋃_i M_i ⊆ T`, the team covers the full target
`T ⊆ ⋃_i M_i` iff the union has full cardinality `|⋃_i M_i| = |T|`.  This is the
exact statement that supercritical "coverage achieved" means the effective tool
set `M^eff = ⋃ M_i` equals the whole target `M^*_{A_s}`. -/
theorem R_504_cover_iff_full_card
    {Ω : Type} [DecidableEq Ω] {ι : Type}
    (V : Finset ι) (M : ι → Finset Ω) (T : Finset Ω)
    (h_sub : V.biUnion M ⊆ T) :
    T ⊆ V.biUnion M ↔ (V.biUnion M).card = T.card := by
  constructor
  · intro h_cover
    -- |⋃M| ≤ |T| (from h_sub) and |T| ≤ |⋃M| (from h_cover) ⟹ equal.
    exact le_antisymm (Finset.card_le_card h_sub) (Finset.card_le_card h_cover)
  · intro h_card
    -- union ⊆ T with equal cardinality ⟹ union = T ⟹ T ⊆ union.
    exact (Finset.eq_of_subset_of_card_le h_sub (le_of_eq h_card.symm)).ge

/-! ## 3. Threshold step / S-curve of the collective cost `N_G(λ)`. -/

/-- **R.504 (iv) — `N_G` threshold dichotomy (phase-transition jump).**

Model the collective cost as a real function `Ncost : ℝ → ℝ` of the diversity
parameter `λ`, monotone non-increasing (more diversity never hurts, R.510), with
floor `Nmin`.  If a critical `λ_c` exists with `Ncost λ_c = Nmin` (coverage
achieved), then:

* for `λ ≥ λ_c`:  `Ncost λ = Nmin` (coverage holds, cost at the floor);
* for `λ < λ_c`:  `Ncost λ ≥ Ncost λ_c = Nmin`,

and combined with strict sub-criticality this is the S-curve / jump of `N_G`
at `λ_c`.  Here the monotone-floor structure is the rigorous kernel; the exact
location `λ_c ∈ [1, 1+log M/M]` is the Coupon-Collector input. -/
theorem R_504_Ng_threshold
    (Ncost : ℝ → ℝ) (Nmin lam_c : ℝ)
    (h_mono : ∀ x y, x ≤ y → Ncost y ≤ Ncost x)
    (h_floor : ∀ x, Nmin ≤ Ncost x)
    (h_crit : Ncost lam_c = Nmin) :
    (∀ lam, lam_c ≤ lam → Ncost lam = Nmin) ∧
    (∀ lam, lam < lam_c → Nmin ≤ Ncost lam) := by
  refine ⟨?_, ?_⟩
  · intro lam h_ge
    -- Ncost λ ≤ Ncost λ_c = Nmin (monotone) and Nmin ≤ Ncost λ (floor) ⟹ equal.
    have h_le : Ncost lam ≤ Nmin := h_crit ▸ h_mono lam_c lam h_ge
    exact le_antisymm h_le (h_floor lam)
  · intro lam _
    exact h_floor lam

/-- **R.504 (iv′) — strict gap below threshold under a strict-monotone model.**

If additionally `Ncost` is strictly above the floor whenever coverage fails
(`λ < λ_c ⟹ Nmin < Ncost λ`), then the cost is strictly above `Nmin` below
`λ_c` and exactly `Nmin` at/above `λ_c`: the discontinuous jump of `N_G` at the
diversity-critical threshold. -/
theorem R_504_Ng_strict_jump
    (Ncost : ℝ → ℝ) (Nmin lam_c : ℝ)
    (h_above : ∀ lam, lam < lam_c → Nmin < Ncost lam)
    (h_crit : Ncost lam_c = Nmin)
    (h_after : ∀ lam, lam_c ≤ lam → Ncost lam = Nmin) :
    (∀ lam, lam < lam_c → Nmin < Ncost lam) ∧
    Ncost lam_c = Nmin ∧
    (∀ lam, lam_c ≤ lam → Ncost lam = Nmin) :=
  ⟨h_above, h_crit, h_after⟩

end DiversityTransition

end MIP
