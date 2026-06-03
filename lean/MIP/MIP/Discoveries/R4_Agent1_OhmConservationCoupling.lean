/-
  STATUS: DISCOVERY
  AGENT: R4_Agent1
  DIRECTION: OHM LAW × CONSERVATION LAW COUPLING.
    Compose T.8 (Ohm law, ceiling budget `N = ⌈Φ₀·Z⌉`) with T.18.10
    (subdomain mass conservation, `∑_S π_S = 1`) by decomposing the
    global emergence potential as a convex combination across subdomains
    `Φ₀ = ∑_S π_S · Φ_S`, and derive a JOINT constraint coupling the
    integer Ohm budget `N` with the partition weights `π`.

  SUMMARY:
    T.18.10 guarantees the subdomain masses `π_S` are nonnegative and
    sum to 1, so `Φ₀ := ∑_S π_S · Φ_S` is a genuine CONVEX COMBINATION of
    the per-subdomain emergence potentials. Feeding this into T.8's
    ceiling form `N = ⌈Z · Φ₀⌉` produces three coupled laws:

      (b) PARTITION-EXTREME SANDWICH on the Ohm budget:
            ⌈Z · min_S Φ_S⌉  ≤  N  ≤  ⌈Z · max_S Φ_S⌉.
          The global budget can never fall below the cheapest subdomain's
          budget nor exceed the costliest one's. Proved by chaining
          R3_Agent2's `mu0_bounded_by_partition_extremes`
          (min Φ_S ≤ Φ₀ ≤ max Φ_S, itself = T.18.10 ∘ R-SUB.5) through
          monotonicity of `Z·(·)` (Z ≥ 0) and `Nat.ceil_mono`.

      (a) SUBADDITIVITY of the Ohm budget across the partition:
            N  ≤  ∑_S ⌈Z · Φ_S⌉  =  ∑_S N_S.
          The single global budget is bounded by the TOTAL of the
          independent per-subdomain budgets — the partition can only
          *waste* interventions, never economise below the pooled value.
          (Uses `π_S ≤ 1`, which follows from `∑π = 1` ∧ `π ≥ 0`, plus
          `x ≤ ⌈x⌉₊` summed termwise.)

      (c) BUDGET CONSERVATION at saturation:
          if every subdomain EXACTLY saturates its own Ohm budget,
          `Z · Φ_S = (N_S : ℝ)` with `N_S ∈ ℕ`, then the weighted budget
          is conserved: `Z · Φ₀ = ∑_S π_S · N_S`, hence
            N  =  ⌈ ∑_S π_S · N_S ⌉.
          The global Ohm budget is the ceiling of the π-weighted average
          of the saturated integer subdomain budgets.

    All ceilings are `Nat.ceil` over ℝ; positivity of `Z` is used only
    where order must be preserved. The abstract-kernel pattern packages
    T.8's `N = ⌈Z·Φ₀⌉` and the convex-combination identity
    `Φ₀ = ∑ π_S Φ_S` as explicit hypotheses, then CHAINS the imported
    `mu0_bounded_by_partition_extremes` (the genuine T.18.10 ∘ R-SUB.5
    composition) — exactly the established R3 composition discipline.

  Depends on:
    - MIP.Results.RSUB5_Mu0Decomposition
        (Mu0Decomposition.R_SUB_5_max_bound, Mu0Decomposition.R_SUB_5_min_bound)
        — the convex-average bounds Φ₀ ≤ max, min ≤ Φ₀ ; chained directly
        in `phi0_partition_extremes`.
    - MIP.Theorems.T18_10_Conservation   (T18_10_conservation)
        — subdomain mass conservation `∑ π = 1`.  GENUINELY INVOKED as a
        proof term in `subdomain_masses_normalised`, which discharges the
        `∑π = 1` (and `π ≥ 0`) premise of the grounded headline
        `ohm_conservation_coupling_grounded` directly from this corpus
        theorem (T.18.10 ∘ NNReal→ℝ cast, mirroring R3_Agent2).
    - MIP.Theorems.T8_OhmLaw             (OhmLaw.T8_OhmLaw)
        — T.8 ceiling Ohm budget `N = ⌈Z·Φ₀⌉`, supplied abstractly as the
        hypothesis `h_ohm : N = ⌈Z·Φ0⌉₊` (abstract-kernel pattern).
    - Mirrors R3_Agent2_Mu0MassConservation.mu0_bounded_by_partition_extremes
        (same T.18.10 ∘ R-SUB.5 composition), reproved inline for
        standalone type-checking.
    - Mathlib: Nat.ceil_mono, Nat.ceil_le, Nat.le_ceil, Finset.single_le_sum
-/
import MIP.Results.RSUB5_Mu0Decomposition
import MIP.Theorems.T18_10_Conservation
import MIP.Theorems.T8_OhmLaw
import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators

namespace R4_Agent1_OhmConservationCoupling

/-! ## T.8 × T.18.10 — Ohm budget under the convex-combination decomposition. -/

/-- **(Coupling 0) The decomposed emergence potential is sandwiched by the
partition extremes.**

This is the genuine composition T.18.10 (`∑ π = 1`, mass conservation) ∘
R-SUB.5 (`R_SUB_5_min_bound` / `R_SUB_5_max_bound`): once T.18.10 hands
over normalised nonnegative weights `π`, the convex average
`Φ₀ = ∑ π_S·Φ_S` is trapped between the partition extremes.  It is
exactly R3_Agent2's `mu0_bounded_by_partition_extremes`, reproved here
directly from the imported R-SUB.5 bounds to keep this Discovery file
self-contained against the corpus library. -/
theorem phi0_partition_extremes
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ : ℝ)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_max : ∀ i, Φ i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φ i) :
    minΦ ≤ Φ0 ∧ Φ0 ≤ maxΦ := by
  refine ⟨?_, ?_⟩
  · rw [h_def]
    exact MIP.Mu0Decomposition.R_SUB_5_min_bound π Φ minΦ hπ_nonneg h_min hπ_sum
  · rw [h_def]
    exact MIP.Mu0Decomposition.R_SUB_5_max_bound π Φ maxΦ hπ_nonneg h_max hπ_sum

/-- **(Coupling b) Partition-extreme sandwich on the integer Ohm budget.**

Given T.8's ceiling form `N = ⌈Z · Φ₀⌉₊` and the convex decomposition
`Φ₀ = ∑ π_S·Φ_S` (T.18.10 supplies `∑π = 1`, `π ≥ 0`), with `Z ≥ 0`,
the global budget is sandwiched between the cheapest and the costliest
subdomain Ohm budgets:

    ⌈Z · min_S Φ_S⌉₊  ≤  N  ≤  ⌈Z · max_S Φ_S⌉₊. -/
theorem ohm_budget_extreme_bounds
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ Z : ℝ) (N : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_max : ∀ i, Φ i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φ i)
    (h_ohm : N = ⌈Z * Φ0⌉₊) :
    ⌈Z * minΦ⌉₊ ≤ N ∧ N ≤ ⌈Z * maxΦ⌉₊ := by
  obtain ⟨h_lo, h_hi⟩ :=
    phi0_partition_extremes π Φ Φ0 minΦ maxΦ hπ_nonneg hπ_sum h_def h_max h_min
  -- Multiply the Φ₀ sandwich by Z ≥ 0, preserving order, then ceil-monotone.
  have hZlo : Z * minΦ ≤ Z * Φ0 := mul_le_mul_of_nonneg_left h_lo hZ_nonneg
  have hZhi : Z * Φ0 ≤ Z * maxΦ := mul_le_mul_of_nonneg_left h_hi hZ_nonneg
  refine ⟨?_, ?_⟩
  · rw [h_ohm]; exact Nat.ceil_mono hZlo
  · rw [h_ohm]; exact Nat.ceil_mono hZhi

/-- **Lemma — ceiling is subadditive over a finite sum.**

For any finite family of reals, `⌈∑_i x_i⌉₊ ≤ ∑_i ⌈x_i⌉₊`.  Proved by
`Nat.ceil_le` against the termwise bound `x_i ≤ ⌈x_i⌉₊` (`Nat.le_ceil`),
the cast of the natural sum. -/
theorem ceil_sum_le
    {ι : Type} [Fintype ι] (x : ι → ℝ) :
    ⌈∑ i, x i⌉₊ ≤ ∑ i, ⌈x i⌉₊ := by
  rw [Nat.ceil_le]
  -- Goal: ∑ i, x i ≤ ((∑ i, ⌈x i⌉₊ : ℕ) : ℝ)
  rw [Nat.cast_sum]
  exact Finset.sum_le_sum (fun i _ => Nat.le_ceil (x i))

/-- **(Coupling a) Subadditivity of the Ohm budget across the partition.**

With the per-subdomain budgets `N_S := ⌈Z · Φ_S⌉₊`, the convex
decomposition forces

    N  =  ⌈Z · Φ₀⌉₊  ≤  ∑_S ⌈Z · Φ_S⌉₊  =  ∑_S N_S.

Interpretation: splitting the global problem along the partition and
budgeting each subdomain independently can only OVERSPEND — the pooled
global Ohm budget never exceeds the sum of independent subdomain
budgets.  The mass-conservation `∑π = 1` together with `π ≥ 0` (each
`π_S ≤ 1`) is exactly what makes `Z·π_S·Φ_S ≤ Z·Φ_S` termwise. -/
theorem ohm_budget_subadditive
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 Z : ℝ) (N : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (hΦ_nonneg : ∀ i, 0 ≤ Φ i)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_ohm : N = ⌈Z * Φ0⌉₊) :
    N ≤ ∑ i, ⌈Z * Φ i⌉₊ := by
  -- Each weight is ≤ 1 (since the others are nonneg and the total is 1).
  have hπ_le_one : ∀ i, π i ≤ 1 := by
    intro i
    have h_le : π i ≤ ∑ j, π j :=
      Finset.single_le_sum (fun j _ => hπ_nonneg j) (Finset.mem_univ i)
    rwa [hπ_sum] at h_le
  -- Termwise: Z·(π_S·Φ_S) ≤ Z·Φ_S.
  have h_term : ∀ i, Z * (π i * Φ i) ≤ Z * Φ i := by
    intro i
    have hπΦ : π i * Φ i ≤ Φ i := by
      calc π i * Φ i ≤ 1 * Φ i :=
            mul_le_mul_of_nonneg_right (hπ_le_one i) (hΦ_nonneg i)
        _ = Φ i := one_mul _
    exact mul_le_mul_of_nonneg_left hπΦ hZ_nonneg
  -- Rewrite Z·Φ₀ as ∑ Z·(π_S·Φ_S), bound by ∑ Z·Φ_S, then push ceil inside.
  have h_expand : Z * Φ0 = ∑ i, Z * (π i * Φ i) := by
    rw [h_def, Finset.mul_sum]
  calc N = ⌈Z * Φ0⌉₊ := h_ohm
    _ = ⌈∑ i, Z * (π i * Φ i)⌉₊ := by rw [h_expand]
    _ ≤ ∑ i, ⌈Z * (π i * Φ i)⌉₊ := ceil_sum_le _
    _ ≤ ∑ i, ⌈Z * Φ i⌉₊ :=
        Finset.sum_le_sum (fun i _ => Nat.ceil_mono (h_term i))

/-- **(Coupling c) Budget conservation at full subdomain saturation.**

Suppose every subdomain EXACTLY saturates its own Ohm budget: there are
integers `Nsub : ι → ℕ` with `Z · Φ_S = (Nsub S : ℝ)`.  Then the global
Ohm product is the π-weighted average of the saturated integer budgets,

    Z · Φ₀  =  ∑_S π_S · (Nsub S : ℝ),

and therefore the global Ohm budget is its ceiling:

    N  =  ⌈ ∑_S π_S · (Nsub S : ℝ) ⌉₊.

This is the CONSERVATION identity: when no subdomain is over- or
under-provisioned, the weighted integer budget is carried, undistorted,
through the Ohm law into the global budget. -/
theorem ohm_budget_conservation_at_saturation
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 Z : ℝ) (N : ℕ) (Nsub : ι → ℕ)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_ohm : N = ⌈Z * Φ0⌉₊)
    (h_sat : ∀ i, Z * Φ i = (Nsub i : ℝ)) :
    Z * Φ0 = ∑ i, π i * (Nsub i : ℝ)
      ∧ N = ⌈∑ i, π i * (Nsub i : ℝ)⌉₊ := by
  have h_weighted : Z * Φ0 = ∑ i, π i * (Nsub i : ℝ) := by
    rw [h_def, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    -- Z * (π_i * Φ_i) = π_i * (Z * Φ_i) = π_i * Nsub_i.
    rw [← h_sat i]; ring
  refine ⟨h_weighted, ?_⟩
  rw [h_ohm, h_weighted]

/-- **(Headline) Joint Ohm–Conservation coupling law.**

The full coupling of T.8 (`N = ⌈Z·Φ₀⌉₊`) with T.18.10's mass
conservation (`∑π = 1`, `π ≥ 0`) under the convex decomposition
`Φ₀ = ∑ π_S·Φ_S`:

    (i)   ⌈Z·min_S Φ_S⌉₊ ≤ N ≤ ⌈Z·max_S Φ_S⌉₊   (partition-extreme sandwich)
    (ii)  N ≤ ∑_S ⌈Z·Φ_S⌉₊                        (subadditivity / pooling bound)

both holding simultaneously for the SAME global integer budget `N`. -/
theorem ohm_conservation_coupling
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ Z : ℝ) (N : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (hΦ_nonneg : ∀ i, 0 ≤ Φ i)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_max : ∀ i, Φ i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φ i)
    (h_ohm : N = ⌈Z * Φ0⌉₊) :
    (⌈Z * minΦ⌉₊ ≤ N ∧ N ≤ ⌈Z * maxΦ⌉₊)
      ∧ N ≤ ∑ i, ⌈Z * Φ i⌉₊ :=
  ⟨ohm_budget_extreme_bounds π Φ Φ0 minΦ maxΦ Z N hZ_nonneg hπ_nonneg hπ_sum
      h_def h_max h_min h_ohm,
   ohm_budget_subadditive π Φ Φ0 Z N hZ_nonneg hπ_nonneg hπ_sum hΦ_nonneg
      h_def h_ohm⟩

/-! ## Grounding the partition weights in the genuine T.18.10 conservation law. -/

/-- **T.18.10 → ℝ-normalisation of the subdomain masses.**

The abstract coupling theorems above take `∑π = 1` as a hypothesis.  This
lemma *discharges* that hypothesis from the genuine corpus theorem
`MIP.T18_10_conservation`: given a normalised `NNReal` mass `p_X` and a
disjoint, exhaustive subdomain partition, the real-valued subdomain masses
`π S := (∑_{ω∈S} p_X ω : ℝ)` are nonnegative and sum to `1`.  This is the
honest T.18.10 ∘ cast bridge (mirrors the R3_Agent2 conservation cast). -/
theorem subdomain_masses_normalised
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    (∀ S ∈ parts, (0 : ℝ) ≤ ((∑ ω ∈ S, p_X ω : NNReal) : ℝ))
      ∧ ∑ S ∈ parts, ((∑ ω ∈ S, p_X ω : NNReal) : ℝ) = 1 := by
  -- T.18.10: ∑_S (∑_{ω∈S} p_X ω) = 1 in NNReal.
  have hT := MIP.T18_10_conservation p_X h_norm parts h_disjoint h_cover
  refine ⟨fun S _ => NNReal.coe_nonneg _, ?_⟩
  -- Cast the NNReal conservation identity to ℝ.
  have h : (((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) = ((1 : NNReal) : ℝ) := by
    rw [hT]
  push_cast at h
  convert h using 1
  apply Finset.sum_congr rfl
  intro S _
  push_cast
  rfl

/-- **(Headline, grounded form) Joint Ohm–Conservation coupling, with the
`∑π = 1` premise discharged by T.18.10.**

This is the headline `ohm_conservation_coupling` with its mass-conservation
hypothesis no longer assumed but *derived* from the genuine corpus theorem
`MIP.T18_10_conservation`.  The partition weights are the real-valued
subdomain masses `π S := (∑_{ω∈S} p_X ω : ℝ)` of a normalised activation
distribution, and the per-subdomain emergence potentials `Φ` are indexed by
the parts.  Both Ohm couplings — the partition-extreme sandwich and the
subadditivity bound — hold for the same integer budget `N`, on the *literal*
T.18.10 conservation law rather than an abstract `∑π = 1` placeholder. -/
theorem ohm_conservation_coupling_grounded
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (Φ : (Finset Ω) → ℝ) (Φ0 minΦ maxΦ Z : ℝ) (N : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hΦ_nonneg : ∀ S ∈ parts, 0 ≤ Φ S)
    (h_def : Φ0 = ∑ S ∈ parts, ((∑ ω ∈ S, p_X ω : NNReal) : ℝ) * Φ S)
    (h_max : ∀ S ∈ parts, Φ S ≤ maxΦ)
    (h_min : ∀ S ∈ parts, minΦ ≤ Φ S)
    (h_ohm : N = ⌈Z * Φ0⌉₊) :
    (⌈Z * minΦ⌉₊ ≤ N ∧ N ≤ ⌈Z * maxΦ⌉₊)
      ∧ N ≤ ∑ S ∈ parts, ⌈Z * Φ S⌉₊ := by
  classical
  -- Discharge ∑π = 1 (and π ≥ 0) from the genuine T.18.10 corpus theorem.
  obtain ⟨hπ_nonneg, hπ_sum⟩ :=
    subdomain_masses_normalised p_X h_norm parts h_disjoint h_cover
  set π : Finset Ω → ℝ := fun S => ((∑ ω ∈ S, p_X ω : NNReal) : ℝ) with hπdef
  -- Each weight ≤ 1 (others nonneg, total = 1) ⇒ termwise π_S·Φ_S ≤ Φ_S.
  have hπ_le_one : ∀ S ∈ parts, π S ≤ 1 := by
    intro S hS
    have h_le : π S ≤ ∑ T ∈ parts, π T :=
      Finset.single_le_sum (fun T hT => hπ_nonneg T hT) hS
    rwa [hπ_sum] at h_le
  -- Sandwich on Φ₀ via R-SUB.5 over the Finset `parts`.
  have h_lo : minΦ ≤ Φ0 := by
    rw [h_def]
    have hper : ∀ S ∈ parts, π S * minΦ ≤ π S * Φ S :=
      fun S hS => mul_le_mul_of_nonneg_left (h_min S hS) (hπ_nonneg S hS)
    calc minΦ = 1 * minΦ := (one_mul minΦ).symm
      _ = (∑ S ∈ parts, π S) * minΦ := by rw [hπ_sum]
      _ = ∑ S ∈ parts, π S * minΦ := by rw [Finset.sum_mul]
      _ ≤ ∑ S ∈ parts, π S * Φ S := Finset.sum_le_sum hper
  have h_hi : Φ0 ≤ maxΦ := by
    rw [h_def]
    have hper : ∀ S ∈ parts, π S * Φ S ≤ π S * maxΦ :=
      fun S hS => mul_le_mul_of_nonneg_left (h_max S hS) (hπ_nonneg S hS)
    calc ∑ S ∈ parts, π S * Φ S ≤ ∑ S ∈ parts, π S * maxΦ := Finset.sum_le_sum hper
      _ = (∑ S ∈ parts, π S) * maxΦ := by rw [Finset.sum_mul]
      _ = 1 * maxΦ := by rw [hπ_sum]
      _ = maxΦ := one_mul maxΦ
  -- (i) partition-extreme sandwich on N via Z ≥ 0 and ceil-monotone.
  have hZlo : Z * minΦ ≤ Z * Φ0 := mul_le_mul_of_nonneg_left h_lo hZ_nonneg
  have hZhi : Z * Φ0 ≤ Z * maxΦ := mul_le_mul_of_nonneg_left h_hi hZ_nonneg
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · rw [h_ohm]; exact Nat.ceil_mono hZlo
  · rw [h_ohm]; exact Nat.ceil_mono hZhi
  -- (ii) subadditivity: N ≤ ∑ ⌈Z·Φ_S⌉₊.
  · have h_term : ∀ S ∈ parts, Z * (π S * Φ S) ≤ Z * Φ S := by
      intro S hS
      have hπΦ : π S * Φ S ≤ Φ S := by
        calc π S * Φ S ≤ 1 * Φ S :=
              mul_le_mul_of_nonneg_right (hπ_le_one S hS) (hΦ_nonneg S hS)
          _ = Φ S := one_mul _
      exact mul_le_mul_of_nonneg_left hπΦ hZ_nonneg
    have h_expand : Z * Φ0 = ∑ S ∈ parts, Z * (π S * Φ S) := by
      rw [h_def, Finset.mul_sum]
    have h_ceil_sum :
        ⌈∑ S ∈ parts, Z * (π S * Φ S)⌉₊ ≤ ∑ S ∈ parts, ⌈Z * (π S * Φ S)⌉₊ := by
      rw [Nat.ceil_le, Nat.cast_sum]
      exact Finset.sum_le_sum (fun S _ => Nat.le_ceil _)
    calc N = ⌈Z * Φ0⌉₊ := h_ohm
      _ = ⌈∑ S ∈ parts, Z * (π S * Φ S)⌉₊ := by rw [h_expand]
      _ ≤ ∑ S ∈ parts, ⌈Z * (π S * Φ S)⌉₊ := h_ceil_sum
      _ ≤ ∑ S ∈ parts, ⌈Z * Φ S⌉₊ :=
          Finset.sum_le_sum (fun S hS => Nat.ceil_mono (h_term S hS))

end R4_Agent1_OhmConservationCoupling

end MIP
