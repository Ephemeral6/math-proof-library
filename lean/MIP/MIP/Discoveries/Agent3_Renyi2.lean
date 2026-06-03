/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Tier B+ — Renyi-2 (collision) entropy bounds on the partition mass.
  SUMMARY:
    Define the Renyi-2 / collision entropy
      H₂(π) := -log (∑_{S ∈ parts} π_S²)
    From Agent3_PiSqBounds we have `1/m ≤ ∑ π² ≤ 1`, so:
      0 ≤ H₂(π) ≤ log m
    matching the range of Shannon entropy. The lower bound is from
    `∑ π² ≤ 1` (log nonpositive), the upper is from `∑ π² ≥ 1/m`
    (log of 1/m is -log m).

    This is the "collision-probability" / 2nd-order Renyi entropy of the
    subdomain-mass profile. Not stated anywhere in the existing R-SUB or
    Conjectures corpus.

    Plus: a "Renyi-2 attainment" — H₂ = log m iff `∑ π² = 1/m`, which is
    the Cauchy-Schwarz equality case (uniform π).
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Discoveries.Agent3_PiSqBounds

namespace MIP

namespace Agent3_Renyi2

open scoped BigOperators
open Real
open MIP.Agent3_PiSqBounds (sum_pi_sq_le_one sum_pi_sq_ge_inv_card)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Renyi-2 (collision) entropy of the partition-mass profile.**

`H₂(d, P) := -log (∑_S π_S²)`.

By convention, when `∑ π² = 0` the log is `0` (since `Real.log 0 = 0`),
so `H₂ = 0` in that degenerate case as well.  In practice the
conservation law (∑π = 1 ⟹ some π > 0 ⟹ ∑π² > 0) ensures the sum is
strictly positive whenever the partition is nonempty. -/
noncomputable def Renyi2
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  -Real.log (∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2)

/-- Helper: `∑ π² > 0` for a nonempty partition.

Proof: conservation gives `∑ π = 1 > 0`, so some `π_S > 0`, so `(π_S)² > 0`. -/
private lemma sum_pi_sq_pos
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (_hP : P.parts.Nonempty) :
    0 < ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := by
  -- ∑ π = 1, so some π_S0 > 0.
  have h_sum_one : ∑ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have hpacked := T18_10_conservation_packaged d P
    have := congrArg (fun x : NNReal => (x : ℝ)) hpacked
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  -- If all π_S = 0, then ∑ = 0 ≠ 1. So some π_S0 ≠ 0; nonneg ⟹ > 0.
  by_contra h_le_zero
  push Not at h_le_zero
  have h_each_zero : ∀ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ))^2 = 0 := by
    have h_sum_le : ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ))^2 ≤ 0 := h_le_zero
    have h_nonneg : ∀ S ∈ P.parts,
        (0 : ℝ) ≤ (((P.subdomainMass d S : NNReal) : ℝ))^2 :=
      fun S _ => sq_nonneg _
    have h_sum_zero : ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ))^2 = 0 :=
      le_antisymm h_sum_le (Finset.sum_nonneg h_nonneg)
    intro S hS
    exact (Finset.sum_eq_zero_iff_of_nonneg h_nonneg).mp h_sum_zero S hS
  -- Then each π_S = 0.
  have h_each_pi_zero : ∀ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 0 := by
    intro S hS
    have := h_each_zero S hS
    exact pow_eq_zero_iff (n := 2) (two_ne_zero) |>.mp this
  -- Then ∑ π = 0 ≠ 1.
  have h_sum_zero : ∑ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 0 :=
    Finset.sum_eq_zero h_each_pi_zero
  linarith [h_sum_one]

/-- **B+ — Renyi-2 entropy nonnegativity.**

For a nonempty partition, `H₂(d, P) ≥ 0`.

Proof: `∑ π² ≤ 1` (Agent3_PiSqBounds.sum_pi_sq_le_one), so
`log (∑ π²) ≤ log 1 = 0`, so `H₂ = -log ≥ 0`. -/
theorem Renyi2_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ Renyi2 d P := by
  unfold Renyi2
  have h_pos := sum_pi_sq_pos d P hP
  have h_le_one := sum_pi_sq_le_one d P
  have h_log_le : Real.log (∑ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ))^2) ≤ Real.log 1 := by
    exact Real.log_le_log h_pos h_le_one
  rw [Real.log_one] at h_log_le
  linarith

/-- **B+ — Renyi-2 entropy upper bound.**

For a nonempty partition, `H₂(d, P) ≤ log m`.

Proof: `∑ π² ≥ 1/m` (Cauchy-Schwarz, Agent3_PiSqBounds.sum_pi_sq_ge_inv_card),
so `log (∑ π²) ≥ log (1/m) = -log m`, so `H₂ = -log ≤ log m`. -/
theorem Renyi2_le_log_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    Renyi2 d P ≤ Real.log (P.parts.card : ℝ) := by
  unfold Renyi2
  set m : ℝ := (P.parts.card : ℝ) with hm
  have hm_pos : 0 < m := by
    rw [hm]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have h_inv_pos : 0 < 1 / m := by positivity
  have h_ge_inv := sum_pi_sq_ge_inv_card d P hP
  -- Rewrite `(P.parts.card : ℝ)` to `m`:
  have h_ge_inv' : 1 / m
      ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := h_ge_inv
  have h_log_ge : Real.log (1 / m)
      ≤ Real.log (∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ))^2) :=
    Real.log_le_log h_inv_pos h_ge_inv'
  -- log (1/m) = -log m.
  have h_log_inv : Real.log (1 / m) = -Real.log m := by
    rw [Real.log_div one_ne_zero (ne_of_gt hm_pos), Real.log_one]
    ring
  rw [h_log_inv] at h_log_ge
  linarith

/-- **Bracket: `0 ≤ H₂ ≤ log m`.** Renyi-2 entropy lies in the same range
as Shannon entropy. -/
theorem Renyi2_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ Renyi2 d P ∧ Renyi2 d P ≤ Real.log (P.parts.card : ℝ) :=
  ⟨Renyi2_nonneg d P hP, Renyi2_le_log_card d P hP⟩

/-- **Helper: H₂ attains its max iff `∑ π² = 1/m`.**

`H₂ = log m  ⟺  log (∑ π²) = -log m  ⟺  ∑ π² = 1/m` (the Cauchy-Schwarz
equality case, equivalent to π uniform).  We give the forward direction
algebraically. -/
theorem Renyi2_eq_log_card_iff_sum_eq_inv
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    Renyi2 d P = Real.log (P.parts.card : ℝ)
    ↔ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2
        = 1 / (P.parts.card : ℝ) := by
  unfold Renyi2
  set m : ℝ := (P.parts.card : ℝ) with hm
  have hm_pos : 0 < m := by
    rw [hm]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have h_pos := sum_pi_sq_pos d P hP
  have h_inv_pos : 0 < 1 / m := by positivity
  constructor
  · intro h
    -- -log (∑) = log m  ⟹  log (∑) = -log m = log (1/m)  ⟹  ∑ = 1/m.
    have h1 : Real.log (∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ))^2) = -Real.log m := by
      linarith
    have h2 : Real.log (∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ))^2) = Real.log (1 / m) := by
      rw [Real.log_div one_ne_zero (ne_of_gt hm_pos), Real.log_one]
      linarith
    exact Real.log_injOn_pos (Set.mem_Ioi.mpr h_pos) (Set.mem_Ioi.mpr h_inv_pos) h2
  · intro h
    rw [h, Real.log_div one_ne_zero (ne_of_gt hm_pos), Real.log_one]
    ring

end Agent3_Renyi2

end MIP
