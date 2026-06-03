/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Tier A — max/min pigeonhole bounds on subdomain mass profile.
  SUMMARY:
    For a normalised activation distribution and a SubdomainPartition with
    `m := parts.card` parts:
      max_S π_S ≥ 1 / m   (some part has at least the mean mass)
      min_S π_S ≤ 1 / m   (some part has at most the mean mass)
    Both are immediate consequences of the conservation law (Σ π_S = 1)
    combined with `Finset.exists_le_sum_div_card` / `Finset.exists_le_sum_div_card`.
    The first is the partition-level pigeonhole; the second is its dual.

    These are foundational corollaries of conservation, not stated in any
    existing R-SUB file.
-/
import MIP.Theorems.T18_10_Conservation

namespace MIP

namespace Agent3_PiPigeonhole

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Pigeonhole on real-valued partition masses.**

For any nonempty Finset `s : Finset ι` of indices and any real-valued
mass function `f : ι → ℝ` with `∑_{i ∈ s} f i = 1`, there exists some
`i ∈ s` with `f i ≥ 1 / s.card`.  Pure averaging argument. -/
theorem exists_ge_inv_card_of_sum_one
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (f : ι → ℝ)
    (h_sum : ∑ i ∈ s, f i = 1) :
    ∃ i ∈ s, (1 : ℝ) / s.card ≤ f i := by
  by_contra h_all
  push Not at h_all
  have h_card_pos : (0 : ℝ) < s.card := by
    exact_mod_cast Finset.card_pos.mpr hs
  -- Sum is strictly less than card · (1/card) = 1.
  have h_sum_lt :
      ∑ i ∈ s, f i < ∑ _i ∈ s, (1 / s.card : ℝ) := by
    apply Finset.sum_lt_sum_of_nonempty hs
    intro i hi
    exact h_all i hi
  rw [Finset.sum_const, nsmul_eq_mul, mul_one_div] at h_sum_lt
  -- s.card / s.card = 1, contradicting h_sum.
  have h_eq : (s.card : ℝ) / s.card = 1 := by
    field_simp
  linarith [h_sum, h_eq]

/-- **Dual pigeonhole — some part has at most the mean mass.** -/
theorem exists_le_inv_card_of_sum_one
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (f : ι → ℝ)
    (h_sum : ∑ i ∈ s, f i = 1) :
    ∃ i ∈ s, f i ≤ (1 : ℝ) / s.card := by
  by_contra h_all
  push Not at h_all
  have h_card_pos : (0 : ℝ) < s.card := by
    exact_mod_cast Finset.card_pos.mpr hs
  -- Sum is strictly more than 1.
  have h_sum_gt :
      ∑ _i ∈ s, (1 / s.card : ℝ) < ∑ i ∈ s, f i := by
    apply Finset.sum_lt_sum_of_nonempty hs
    intro i hi
    exact h_all i hi
  rw [Finset.sum_const, nsmul_eq_mul, mul_one_div] at h_sum_gt
  have h_eq : (s.card : ℝ) / s.card = 1 := by
    field_simp
  linarith

/-- **A.3 — Some part carries at least the mean mass `1/m`.**

For a normalised activation distribution and a nonempty
`SubdomainPartition` with `m := P.parts.card`, at least one part has
π_S ≥ 1/m.  Coerced to ℝ for downstream use. -/
theorem exists_pi_ge_mean
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    ∃ S ∈ P.parts,
      (1 : ℝ) / P.parts.card ≤ ((P.subdomainMass d S : NNReal) : ℝ) := by
  -- Conservation in real form.
  have h_sum_nnreal :
      ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
    T18_10_conservation_packaged d P
  have h_sum_real :
      ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) h_sum_nnreal
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  exact exists_ge_inv_card_of_sum_one P.parts hP
    (fun S => ((P.subdomainMass d S : NNReal) : ℝ)) h_sum_real

/-- **A.4 — Some part carries at most the mean mass `1/m`.** Dual of A.3. -/
theorem exists_pi_le_mean
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    ∃ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) ≤ (1 : ℝ) / P.parts.card := by
  have h_sum_nnreal :
      ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
    T18_10_conservation_packaged d P
  have h_sum_real :
      ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) h_sum_nnreal
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  exact exists_le_inv_card_of_sum_one P.parts hP
    (fun S => ((P.subdomainMass d S : NNReal) : ℝ)) h_sum_real

/-- **Combined dichotomy form.** For a nonempty partition there always
exists a part above-or-at the uniform level *and* a part below-or-at it.
The uniform distribution is the only one where these two parts can
coincide. -/
theorem pi_mean_dichotomy
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (∃ S ∈ P.parts,
        (1 : ℝ) / P.parts.card ≤ ((P.subdomainMass d S : NNReal) : ℝ))
    ∧ (∃ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) ≤ (1 : ℝ) / P.parts.card) :=
  ⟨exists_pi_ge_mean d P hP, exists_pi_le_mean d P hP⟩

end Agent3_PiPigeonhole

end MIP
