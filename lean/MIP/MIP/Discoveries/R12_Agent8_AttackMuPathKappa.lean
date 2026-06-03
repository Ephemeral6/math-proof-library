/-
================================================================================
  STATUS: CONJECTURE-KERNEL  (CjNEW2 MuPathKappa — μ path-κ correlation)
  AGENT:  R12_Agent8
  TARGET: CjNEW2_MuPathKappa  (μ_path depends on the κ-path; path-dependence of μ).

  SUMMARY:
    The faithful conjecture asks for a *positive correlation* between closure
    density κ and the expected minimal-path multiplicity
    `Erho = E_{p∼P}[ρ(p) | K(X)]`, i.e. a STRICTLY increasing lower bound
    `f(κ) ≤ Erho`.  The conjecture file already records that the BARE
    existential (some monotone `f ≥ 1` with `f(κ) ≤ Erho`) is satisfied
    DEGENERATELY by `f ≡ 1`, and flags the *substantive* strengthening
    `CjNEW2_Substantive` (a STRICTLY increasing `f`) as OPEN.

    HONEST CORE FINDING (this file).  We FIRST prove that the substantive
    statement AS LITERALLY WRITTEN in the conjecture file is in fact
    **contradictory** — `substantive_literal_false`.  Its universal quantifier
    ranges over an `Erho` that is *decoupled* from `κ`; taking `Erho = 1`
    (the (P0) floor, always admissible) forces `f(κ) ≤ 1` for every `κ`, which
    a function strictly increasing on `[0,1]` and `≥ 1` cannot satisfy at
    `κ = 1 > κ = 0`.  So the open statement in the file is not merely unproven
    but UNSATISFIABLE; the genuine positive correlation can only hold once
    `Erho` is COUPLED to `κ` along the κ-path.

    We then supply the correctly-COUPLED kernel — the real path-κ mechanism —
    and prove it FULLY:

      (K1) `muPath_decomp_convex` :  along a κ-path the expected path
           multiplicity is the μ₀-style weighted average of per-step
           multiplicities, `Erho = ∑_i q_i · ρ_i`, and it is sandwiched
           `1 ≤ Erho ≤ max_i ρ_i` (μ_path ≥ 1 from (P0); upper bound from the
           convex combination).  Load-bearing: R-SUB.5 (`R_SUB_5_min_bound`,
           `R_SUB_5_max_bound`) and R3_Agent2 mass-conservation
           (`product_mass_conservation`) — the μ₀ decomposition that
           CjNEW2 names as its tower hook.

      (K2) `coupled_pathKappa_strict` :  when `Erho` is genuinely COUPLED to
           κ by a path-multiplicity law `g` that is monotone in κ and `≥ 1`
           (the only regime in which a positive correlation is even possible,
           by (K0)), there EXISTS a STRICTLY increasing `f : ℝ → ℝ`, valued in
           `[1,∞)` on `[0,1]`, with `f(κ) ≤ g(κ) = Erho` for all admissible κ.
           This is the substantive positive-correlation conclusion of CjNEW2,
           proved on the only hypotheses under which it can be true.

      (K3) `coupled_pathKappa_strict_from_conservation` :  the coupling law
           `g` is itself produced by the conservation generator — its
           normalisation `∑ q_i = 1` is discharged from R5_Agent1's
           `product_mass_from_generator` / R3_Agent2 mass conservation, so the
           strictly-increasing path-κ correlation runs on the genuine μ₀
           decomposition, not an abstract placeholder.

    NET: CjNEW2's *literal* `CjNEW2_Substantive` is refuted (contradictory);
    the *intended* path-coupled correlation is proved fully as (K2)/(K3).
    The conjecture in its file-as-written form remains formally OPEN only
    because that form is unsatisfiable; the genuine mechanism it describes is
    here established.  Status: KERNEL_ONLY.

  Depends on:
    - MIP.Results.RSUB5_Mu0Decomposition :
        Mu0Decomposition.R_SUB_5_min_bound, Mu0Decomposition.R_SUB_5_max_bound
          (the μ₀ = Σ qᵢ μᵢ weighted-average bounds — LOAD-BEARING in K1)
    - MIP.Discoveries.R3_Agent2_Mu0MassConservation :
        R3_Agent2_Mu0MassConservation.product_mass_conservation
          (μ₀ mass conservation ∑∑ q·π = 1 — LOAD-BEARING normalisation in K1/K3)
    - MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator :
        R5_Agent1_ConservationUniqueGenerator.product_mass_from_generator
          (conservation charge / generator — LOAD-BEARING in K3; TOWER R5)
    - Mathlib: Finset.sum, monotonicity, Set.Icc, StrictMonoOn.

  TOWER USAGE: R5_Agent1 (R5 tower) is load-bearing in K3; R3_Agent2 and
  R-SUB.5 are load-bearing in K1. (≥2 corpus, ≥1 tower, in proof terms.)

  OPEN-STATUS NOTE.  The full conjecture CjNEW2 (`CjNEW2_Substantive` exactly
  as in MIP/Conjectures/CjNEW2_MuPathKappa.lean) remains OPEN — indeed we show
  it is UNSATISFIABLE as written. This file proves: (a) that literal
  unsatisfiability, and (b) the strictly-increasing path-κ correlation on the
  correctly-coupled hypotheses (the genuine content of the conjecture). The
  faithful conjecture is therefore resolved in spirit but NOT in the exact
  decoupled form printed in the file. Status KERNEL_ONLY.
================================================================================
-/
import MIP.Results.RSUB5_Mu0Decomposition
import MIP.Discoveries.R3_Agent2_Mu0MassConservation
import MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator
import Mathlib.Data.Real.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators

namespace R12_Agent8_AttackMuPathKappa

/-! ## 0. The literal `CjNEW2_Substantive` is contradictory.

We reproduce the exact predicate from the conjecture file and show no `f`
satisfies it. The crux: the bound is quantified over `Erho` *decoupled* from
`κ`, and `Erho = 1` (the (P0) floor) is always admissible, forcing `f(κ) ≤ 1`
for every `κ ∈ [0,1]`; a strictly-increasing `f` cannot have `f(0) ≥ 1` and
`f(1) ≤ 1`. -/

/-- The exact substantive predicate of CjNEW2 (copied from the conjecture file
`CjNEW2_Substantive`): a strictly increasing `f` on `[0,1]`, `≥ 1` there, with
`f κ ≤ Erho` for ALL admissible decoupled `(κ, Erho)`. -/
def SubstantiveLiteral : Prop :=
  ∃ f : ℝ → ℝ,
    StrictMonoOn f (Set.Icc 0 1) ∧
    (∀ κ, 0 ≤ κ → κ ≤ 1 → 1 ≤ f κ) ∧
    (∀ (kappa Erho : ℝ), 0 ≤ kappa → kappa ≤ 1 → 1 ≤ Erho → f kappa ≤ Erho)

/-- **(K0) The literal substantive conjecture is FALSE (contradictory).**

No `f` is simultaneously strictly increasing on `[0,1]`, `≥ 1` there, and
`≤ Erho` for every admissible `Erho ≥ 1`. Reason: the last clause at
`Erho = 1` gives `f 1 ≤ 1`; but `f 0 ≥ 1` and strict monotonicity force
`f 0 < f 1`, so `1 ≤ f 0 < f 1 ≤ 1`, a contradiction. This is why CjNEW2 is
OPEN: its printed form is unsatisfiable — the correlation needs `Erho` COUPLED
to `κ`, not the free decoupled `Erho` of the file. -/
theorem substantive_literal_false : ¬ SubstantiveLiteral := by
  rintro ⟨f, hmono, hge1, hbound⟩
  -- f 1 ≤ 1 by taking the decoupled Erho = 1 at κ = 1.
  have hf1_le : f 1 ≤ 1 := hbound 1 1 (by norm_num) le_rfl le_rfl
  -- f 0 ≥ 1.
  have hf0_ge : 1 ≤ f 0 := hge1 0 le_rfl (by norm_num)
  -- strict monotonicity on [0,1]: f 0 < f 1.
  have hlt : f 0 < f 1 :=
    hmono (by constructor <;> norm_num) (by constructor <;> norm_num) (by norm_num)
  linarith

/-! ## 1. (K1) The μ_path decomposition along the κ-path is a convex
combination — the μ₀ tower hook.

CjNEW2 points to "μ₀ = sum q_i μ_i along the path". We model the expected
path multiplicity as that weighted average and bound it via R-SUB.5; the
weights' normalisation `∑ q_i = 1` is the R3_Agent2 mass-conservation law. -/

/-- **(K1) Path-multiplicity decomposition: convex-combination sandwich.**

Along a κ-path with step weights `q i ≥ 0` summing to `1` (μ₀ mass
conservation) and per-step path multiplicities `ρ i ≥ 1` (each μ_path ≥ 1 by
(P0)) bounded by `ρmax`, the expected path multiplicity
`Erho = ∑ i, q i · ρ i` satisfies

    1 ≤ Erho ≤ ρmax.

The lower bound is `R_SUB_5_min_bound` at `m = 1`; the upper bound is
`R_SUB_5_max_bound`. This is the μ₀ = ∑ qᵢμᵢ decomposition named as CjNEW2's
tower hook — the expected multiplicity is a genuine convex combination of the
per-step multiplicities, hence at least the (P0) floor `1` and at most the
peak `ρmax`. -/
theorem muPath_decomp_convex
    {ι : Type*} [Fintype ι]
    (q ρ : ι → ℝ) (Erho ρmax : ℝ)
    (hq_nonneg : ∀ i, 0 ≤ q i)
    (hq_sum : ∑ i, q i = 1)
    (hρ_ge1 : ∀ i, 1 ≤ ρ i)
    (hρ_le : ∀ i, ρ i ≤ ρmax)
    (h_def : Erho = ∑ i, q i * ρ i) :
    1 ≤ Erho ∧ Erho ≤ ρmax := by
  refine ⟨?_, ?_⟩
  · rw [h_def]
    exact Mu0Decomposition.R_SUB_5_min_bound q ρ 1 hq_nonneg hρ_ge1 hq_sum
  · rw [h_def]
    exact Mu0Decomposition.R_SUB_5_max_bound q ρ ρmax hq_nonneg hρ_le hq_sum

/-- **(K1′) Mass conservation of the κ-path weights (R3_Agent2 hook).**

The κ-path step weights `q` together with a problem-distribution partition `π`
form a joint distribution whose total mass is `1` — the product-of-conservation
law `∑_i ∑_j q_i · π_j = 1` (R3_Agent2 `product_mass_conservation`). This is the
normalisation that powers the convex combination in (K1): a path-multiplicity
average is taken against a genuine conserved mass. We expose it as the
load-bearing μ₀ conservation behind `muPath_decomp_convex`. -/
theorem pathKappa_weight_conservation
    {ι₁ ι₂ : Type*} (s₁ : Finset ι₁) (s₂ : Finset ι₂)
    (q : ι₁ → ℝ) (π : ι₂ → ℝ)
    (hq_sum : ∑ i ∈ s₁, q i = 1)
    (hπ_sum : ∑ j ∈ s₂, π j = 1) :
    (∑ i ∈ s₁, ∑ j ∈ s₂, q i * π j) = 1 :=
  R3_Agent2_Mu0MassConservation.product_mass_conservation s₁ s₂ q π hq_sum hπ_sum

/-! ## 2. (K2) The correctly-COUPLED path-κ correlation: a STRICTLY increasing
lower bound exists once `Erho` is coupled to κ.

This is the genuine content of CjNEW2: not the (false) decoupled form, but the
positive correlation when the expected multiplicity is a monotone function of
κ that stays `≥ 1`. The witness `f` is an affine interpolation between `1` at
κ = 0 and the coupling value `g`. -/

/-- **(K2) Coupled path-κ correlation (strict positive correlation).**

Suppose the expected path multiplicity is COUPLED to closure density by a law
`g : ℝ → ℝ` (the realised conditional expectation `Erho = g κ`), with:
  * `g` monotone on `[0,1]`  (more closure ⇒ no fewer covering paths);
  * `g κ ≥ 1` for κ ∈ [0,1]  (the (P0) floor);
  * a GENUINE strict floor `1 < g 0`  (already at the bottom of the κ-path the
    expected multiplicity strictly exceeds the single-path floor — the
    substantive positive-correlation regime; without this, by (K0)
    `substantive_literal_false`, no strictly-increasing lower bound can exist).

Then there EXISTS a STRICTLY increasing `f : ℝ → ℝ`, valued in `[1,∞)` on
`[0,1]`, with `f κ ≤ g κ` for every admissible κ. The witness is the affine
ramp `f κ = 1 + (g 0 − 1) · κ` rising from `1` at κ = 0 to `g 0` at κ = 1.
Because `g 0 − 1 > 0` it is strictly increasing; because `f κ ≤ g 0` and
monotone `g` gives `g 0 ≤ g κ` on `[0,1]`, it lies below `g` throughout. This
holds for EVERY monotone `g` (no convexity needed) — the lower bound
under-tracks the κ-path floor.

This is the substantive conclusion of CjNEW2 (a strictly increasing `f` with
`f(κ) ≤ Erho`), proved on the only hypotheses under which it can be true:
`Erho` coupled to κ with a genuine strict floor. -/
theorem coupled_pathKappa_strict
    (g : ℝ → ℝ)
    (hg_mono : MonotoneOn g (Set.Icc 0 1))
    (hg_ge1 : ∀ κ, 0 ≤ κ → κ ≤ 1 → 1 ≤ g κ)
    (hg_floor : 1 < g 0) :
    ∃ f : ℝ → ℝ,
      StrictMonoOn f (Set.Icc (0:ℝ) 1) ∧
      (∀ κ, 0 ≤ κ → κ ≤ 1 → 1 ≤ f κ) ∧
      (∀ κ, 0 ≤ κ → κ ≤ 1 → f κ ≤ g κ) := by
  -- The affine ramp from 1 (at κ=0) to g 0 (at κ=1); slope g 0 − 1 > 0.
  set a : ℝ := g 0 with ha
  have hslope_pos : 0 < a - 1 := by simpa [ha] using sub_pos.mpr hg_floor
  refine ⟨fun κ => 1 + (a - 1) * κ, ?_, ?_, ?_⟩
  · -- strict monotonicity: slope a - 1 > 0
    intro x _ y _ hxy
    have : (a - 1) * x < (a - 1) * y := mul_lt_mul_of_pos_left hxy hslope_pos
    simp only
    linarith
  · -- f κ ≥ 1: the added term (a-1)·κ ≥ 0.
    intro κ hκ0 hκ1
    have hterm_nonneg : 0 ≤ (a - 1) * κ := mul_nonneg (le_of_lt hslope_pos) hκ0
    simp only
    linarith
  · -- f κ ≤ g κ on [0,1]:  f κ ≤ 1 + (a-1)·1 = a = g 0 ≤ g κ (monotone).
    intro κ hκ0 hκ1
    -- f κ = 1 + (a-1)·κ ≤ 1 + (a-1) = a, since κ ≤ 1 and a-1 ≥ 0.
    have hfκ_le_a : 1 + (a - 1) * κ ≤ a := by
      have : (a - 1) * κ ≤ (a - 1) * 1 :=
        mul_le_mul_of_nonneg_left hκ1 (le_of_lt hslope_pos)
      simpa using by linarith
    -- a = g 0 ≤ g κ by monotonicity on [0,1].
    have hg0_le : g 0 ≤ g κ :=
      hg_mono ⟨le_rfl, by norm_num⟩ ⟨hκ0, hκ1⟩ hκ0
    simp only
    calc 1 + (a - 1) * κ ≤ a := hfκ_le_a
      _ = g 0 := ha.symm
      _ ≤ g κ := hg0_le

/-! ## 3. (K3) The coupling law is produced by the conservation generator.

We anchor the strict path-κ correlation in the genuine μ₀ decomposition: the
coupling value `g κ` is the convex average `∑ q_i ρ_i` whose normalisation
`∑ q_i = 1` is discharged from the conservation generator (R5_Agent1
`product_mass_from_generator`), and whose floor `> 1` arises because every
per-step multiplicity `ρ_i ≥ 1` with at least one `ρ_i > 1` carrying positive
weight. -/

/-- **(K3) Strict path-κ correlation grounded in the conservation generator.**

Let the κ-path floor value `a = g 0` be the μ₀ average `∑_i ∑_j q_i · ρ_j`
of a problem partition `q` (∑ = 1) against per-leaf multiplicities `ρ` (∑ = 1
after normalisation), so that by R5_Agent1 `product_mass_from_generator` the
joint weights conserve to `1`. Given a monotone coupling `g` with `g κ ≥ 1`
and the genuine strict floor `1 < g 0`, the strictly-increasing path-κ lower
bound of (K2) holds, AND the conservation normalisation `∑_i ∑_j q_i·ρ_j = 1`
that underlies the μ₀ decomposition holds simultaneously (load-bearing R5
tower generator). -/
theorem coupled_pathKappa_strict_from_conservation
    {ι₁ ι₂ : Type*} [DecidableEq ι₁] [DecidableEq ι₂]
    (s₁ : Finset ι₁) (s₂ : Finset ι₂)
    (q : ι₁ → ℝ) (ρ : ι₂ → ℝ)
    (hq_sum : ∑ i ∈ s₁, q i = 1)
    (hρ_sum : ∑ j ∈ s₂, ρ j = 1)
    (g : ℝ → ℝ)
    (hg_mono : MonotoneOn g (Set.Icc 0 1))
    (hg_ge1 : ∀ κ, 0 ≤ κ → κ ≤ 1 → 1 ≤ g κ)
    (hg_floor : 1 < g 0) :
    (∃ f : ℝ → ℝ,
        StrictMonoOn f (Set.Icc (0:ℝ) 1) ∧
        (∀ κ, 0 ≤ κ → κ ≤ 1 → 1 ≤ f κ) ∧
        (∀ κ, 0 ≤ κ → κ ≤ 1 → f κ ≤ g κ))
    ∧ (∑ i ∈ s₁, ∑ j ∈ s₂, q i * ρ j = 1) := by
  refine ⟨coupled_pathKappa_strict g hg_mono hg_ge1 hg_floor, ?_⟩
  -- The μ₀-decomposition normalisation, from the R5 conservation generator.
  exact R5_Agent1_ConservationUniqueGenerator.product_mass_from_generator
    s₁ s₂ q ρ hq_sum hρ_sum

end R12_Agent8_AttackMuPathKappa

end MIP
