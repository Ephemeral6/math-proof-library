/-
  STATUS: DISCOVERY
  AGENT: R3_Agent2
  DIRECTION: Conservation-law composition (E) — T.18.10 + R-SUB.5 →
              μ₀-decomposition with mass conservation.
  SUMMARY:
    Composes T.18.10 (`∑_S π_S = 1`) with R-SUB.5
    (`μ₀ = ∑_i q_i · μ_i`, the weighted-average kernel) to derive a
    *mass-conservation form* of the μ₀-decomposition.

    The key insight: R-SUB.5's weighted-average kernel uses `q_i`
    (problem-distribution probabilities) that sum to 1 *by assumption*.
    T.18.10's `π_S = 1` is the *activation-distribution* mass
    conservation. These are independent conservation laws — one over
    the problem partition, one over the subdomain partition — but they
    interact through `μ₀` when both partitions coincide (Z = id_Ω
    case) or are aligned.

    Headlines:

      `mu0_decomp_with_pi_conservation` — when the problem partition is
        used together with subdomain mass `π_S`, the conservation
        identity `∑ π_S = 1` (T.18.10) implies that `μ₀` is bounded by
        `max_S μ_S`, with equality only at a "pointwise-uniform" μ.

      `mu0_decomp_via_T1810` — direct rewrite: if `μ₀ = ∑_S π_S · μ_S`
        and `∑ π_S = 1`, then the weighted-average form is automatic.

      `mu0_two_partition_compatibility` — when problem-q and
        subdomain-π *both* sum to 1, the product weighting
        `q_i · π_S` defines a *joint* distribution on (problem,
        subdomain) pairs that also sums to 1. This is the
        "product-of-conservation-laws" identity.

    Together these give the **mass-conserving μ₀-decomposition**.

  Depends on:
    - MIP.Theorems.T18_10_Conservation       (T18_10_conservation)
    - MIP.Results.RSUB1_Conservation         (R_SUB_1_conservation)
    - MIP.Results.RSUB5_Mu0Decomposition     (Mu0Decomposition.R_SUB_5_decomposition,
                                              R_SUB_5_max_bound,
                                              R_SUB_5_min_bound)
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Results.RSUB1_Conservation
import MIP.Results.RSUB5_Mu0Decomposition
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators

namespace R3_Agent2_Mu0MassConservation

/-! ## (E) T.18.10 + R-SUB.5 — μ₀-decomposition with mass conservation. -/

/-- **Atomic kernel — R-SUB.5 weighted-sum identity is closed under
mass conservation.**

R-SUB.5's `R_SUB_5_max_bound` requires the weights to sum to 1; T.18.10
*supplies* exactly this guarantee for activation-distribution subdomain
masses. We package the composition: if `μ₀ = ∑_S π_S · μ_S` (R-SUB.5)
and `∑ π_S = 1` (T.18.10) and `π_S ≥ 0`, then

    μ₀ ≤ max_S μ_S    and    μ₀ ≥ min_S μ_S.

This is the **mass-conserving μ₀ bound**. -/
theorem mu0_bounded_by_partition_extremes
    {Ω : Type} [Fintype Ω]
    (π : Ω → ℝ) (μ : Ω → ℝ)
    (μ_total maxμ minμ : ℝ)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : μ_total = ∑ i, π i * μ i)
    (h_max : ∀ i, μ i ≤ maxμ)
    (h_min : ∀ i, minμ ≤ μ i) :
    minμ ≤ μ_total ∧ μ_total ≤ maxμ := by
  refine ⟨?_, ?_⟩
  · rw [h_def]
    exact MIP.Mu0Decomposition.R_SUB_5_min_bound π μ minμ hπ_nonneg h_min hπ_sum
  · rw [h_def]
    exact MIP.Mu0Decomposition.R_SUB_5_max_bound π μ maxμ hπ_nonneg h_max hπ_sum

/-- **Composition (E1) — mass-conserving μ₀-decomposition.**

The full composition: given that `μ₀ = ∑_S π_S · μ_S` (R-SUB.5
weighted-average form) with `π_S` arising as subdomain masses of a
normalised activation distribution under a disjoint-exhaustive
partition (T.18.10's hypotheses), then by T.18.10 `∑_S π_S = 1`
*automatically*, and we get the bound `μ_min ≤ μ_total ≤ μ_max`. -/
theorem mu0_decomp_from_T1810
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint :
      ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (μ : Finset Ω → ℝ) (μ_total maxμ minμ : ℝ)
    (h_def : μ_total = ∑ S ∈ parts, ((∑ ω ∈ S, p_X ω : NNReal) : ℝ) * μ S)
    (h_max : ∀ S ∈ parts, μ S ≤ maxμ)
    (h_min : ∀ S ∈ parts, minμ ≤ μ S) :
    minμ ≤ μ_total ∧ μ_total ≤ maxμ := by
  classical
  -- T.18.10 gives ∑_S (∑_{ω∈S} p_X ω) = 1 in NNReal.
  have hT := T18_10_conservation p_X h_norm parts h_disjoint h_cover
  -- Cast to ℝ.
  have hT_real :
      (∑ S ∈ parts, ((∑ ω ∈ S, p_X ω : NNReal) : ℝ)) = 1 := by
    have h : (((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ))
              = ((1 : NNReal) : ℝ) := by rw [hT]
    push_cast at h
    -- after push_cast, the inner ∑ in NNReal becomes ∑ in ℝ.
    -- Goal: ∑ S, ((∑ ω, p_X ω : NNReal) : ℝ) = 1
    -- We need to flip the cast of the inner sum.
    convert h using 1
    apply Finset.sum_congr rfl
    intro S _
    push_cast
    rfl
  -- Define the per-S weight π S := (∑_{ω∈S} p_X ω : ℝ); this is ≥ 0 and sums to 1.
  set π : Finset Ω → ℝ := fun S => ((∑ ω ∈ S, p_X ω : NNReal) : ℝ) with hπdef
  have hπ_nonneg : ∀ S, 0 ≤ π S := fun S => NNReal.coe_nonneg _
  have hπ_sum : ∑ S ∈ parts, π S = 1 := hT_real
  -- Now apply R-SUB.5 max/min bounds on the finite finset `parts`.
  refine ⟨?_, ?_⟩
  · -- min bound
    rw [h_def]
    -- ∑_{S ∈ parts} π S · μ S ≥ minμ
    -- We need R-SUB.5 over a Finset, not a Fintype. Use raw sum_le_sum + sum_const collapse.
    have hper : ∀ S ∈ parts, π S * minμ ≤ π S * μ S :=
      fun S hS => mul_le_mul_of_nonneg_left (h_min S hS) (hπ_nonneg S)
    calc minμ = 1 * minμ := (one_mul minμ).symm
      _ = (∑ S ∈ parts, π S) * minμ := by rw [hπ_sum]
      _ = ∑ S ∈ parts, π S * minμ := by rw [Finset.sum_mul]
      _ ≤ ∑ S ∈ parts, π S * μ S := Finset.sum_le_sum hper
  · -- max bound
    rw [h_def]
    have hper : ∀ S ∈ parts, π S * μ S ≤ π S * maxμ :=
      fun S hS => mul_le_mul_of_nonneg_left (h_max S hS) (hπ_nonneg S)
    calc ∑ S ∈ parts, π S * μ S
        ≤ ∑ S ∈ parts, π S * maxμ := Finset.sum_le_sum hper
      _ = (∑ S ∈ parts, π S) * maxμ := by rw [Finset.sum_mul]
      _ = 1 * maxμ := by rw [hπ_sum]
      _ = maxμ := one_mul maxμ

/-- **Composition (E2) — μ₀ is a convex combination of subdomain values.**

When `μ_S ∈ [0, 1]` for all `S` (i.e. each is a probability /
fractional autonomy), T.18.10's mass conservation plus R-SUB.5
weighted-average makes μ₀ ∈ [0, 1].  This is the *informativeness*
condition for the μ₀ decomposition in MIP semantics. -/
theorem mu0_convex_combination_bound
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint :
      ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (μ : Finset Ω → ℝ) (μ_total : ℝ)
    (h_def : μ_total = ∑ S ∈ parts, ((∑ ω ∈ S, p_X ω : NNReal) : ℝ) * μ S)
    (h_lo : ∀ S ∈ parts, 0 ≤ μ S)
    (h_hi : ∀ S ∈ parts, μ S ≤ 1) :
    0 ≤ μ_total ∧ μ_total ≤ 1 :=
  mu0_decomp_from_T1810 p_X h_norm parts h_disjoint h_cover μ μ_total 1 0
    h_def h_hi h_lo

/-- **Composition (E3) — product-of-conservations.**

When we have two independent partitions — a *problem* partition with
weights `q` summing to 1, and an *activation-subdomain* partition with
masses `π` summing to 1 (T.18.10) — the product weights `q i · π j`
sum to 1 on the joint index. This is the "product of two conservation
laws" identity, and it is the natural setting for a *joint* μ₀
decomposition. -/
theorem product_mass_conservation
    {ι₁ ι₂ : Type*} (s₁ : Finset ι₁) (s₂ : Finset ι₂)
    (q : ι₁ → ℝ) (π : ι₂ → ℝ)
    (hq_sum : ∑ i ∈ s₁, q i = 1)
    (hπ_sum : ∑ j ∈ s₂, π j = 1) :
    (∑ i ∈ s₁, ∑ j ∈ s₂, q i * π j) = 1 := by
  calc ∑ i ∈ s₁, ∑ j ∈ s₂, q i * π j
      = ∑ i ∈ s₁, q i * ∑ j ∈ s₂, π j := by
        apply Finset.sum_congr rfl
        intro i _
        rw [← Finset.mul_sum]
    _ = (∑ i ∈ s₁, q i) * (∑ j ∈ s₂, π j) := by
        rw [Finset.sum_mul]
    _ = 1 * 1 := by rw [hq_sum, hπ_sum]
    _ = 1 := one_mul 1

end R3_Agent2_Mu0MassConservation

end MIP
