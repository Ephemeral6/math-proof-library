/-
  STATUS: DISCOVERY
  AGENT: R2-4
  DIRECTION: Min-entropy / max-divergence (Rényi-∞) of the partition mass.
  SUMMARY:
    The Rényi-∞ entropy (min-entropy) is `H_∞(π) := -log (max_S π_S)`.

    Bounds:
      H_∞ ≥ 0  (since max π_S ≤ 1, so -log ≥ 0).
      H_∞ ≤ log m  (since max π_S ≥ 1/m by mean pigeonhole).

    Saturation:  H_∞ = log m  ⟺  max_S π_S = 1/m  ⟺  every π_S = 1/m (uniform).
    The forward direction of the "uniform" iff is by squeeze: max π_S = 1/m
    and 1/m ≤ π_S would fail unless every π_S = 1/m. We give the cleaner
    direction `max π_S = 1/m ⟹ uniform` and the converse `uniform ⟹ max π_S = 1/m`.

  Approach: use `Finset.exists_max_image` for the existence of a maximizer,
  and define the *value* `MaxPi` as `(P.parts.image fπ).max' (nonempty)`.

  We DO NOT define `H_∞` itself (as `-log max`) because the saturation iff
  involves only the max value, not `-log` of it. We expose:
    - `MaxPi` : the max value, as a real ≥ 1/m and ≤ 1
    - `MaxPi_bracket` : `1/m ≤ MaxPi ≤ 1`
    - `MaxPi_eq_inv_card_iff_uniform` : the saturation iff
    - `MinEntropy_le_log_card` : `-log(MaxPi) ≤ log m` (the actual H_∞ bound)
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Discoveries.Agent3_PiMassBounds
import MIP.Discoveries.Agent3_PiPigeonhole

namespace MIP

namespace R2_Agent4_MinEntropy

open scoped BigOperators
open Real
open MIP.Agent3_PiMassBounds (pi_le_one)
open MIP.Agent3_PiPigeonhole (exists_pi_ge_mean)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- The (real-valued) maximum of the partition-mass profile.

Defined via `Finset.exists_max_image`: choose any maximizer and read off
its mass. We use the image-`max'` approach for definability. -/
noncomputable def MaxPi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) : ℝ :=
  (P.parts.image (fun S => ((P.subdomainMass d S : NNReal) : ℝ))).max'
    (hP.image _)

/-- **MaxPi is the maximum.** Every `π_S ≤ MaxPi`. -/
theorem pi_le_MaxPi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    {S : Finset Ω} (hS : S ∈ P.parts) :
    ((P.subdomainMass d S : NNReal) : ℝ) ≤ MaxPi d P hP := by
  unfold MaxPi
  apply Finset.le_max'
  exact Finset.mem_image_of_mem _ hS

/-- **MaxPi is attained.** Some `S ∈ parts` achieves `π_S = MaxPi`. -/
theorem exists_pi_eq_MaxPi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    ∃ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = MaxPi d P hP := by
  unfold MaxPi
  have h := (P.parts.image (fun S => ((P.subdomainMass d S : NNReal) : ℝ))).max'_mem
    (hP.image _)
  rcases Finset.mem_image.mp h with ⟨S, hS, hSeq⟩
  exact ⟨S, hS, hSeq⟩

/-- **MaxPi ≤ 1.** -/
theorem MaxPi_le_one
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    MaxPi d P hP ≤ 1 := by
  unfold MaxPi
  apply Finset.max'_le
  intro x hx
  rcases Finset.mem_image.mp hx with ⟨S, hS, rfl⟩
  have := pi_le_one d P hS
  exact_mod_cast this

/-- **MaxPi ≥ 1/m** (mean pigeonhole). -/
theorem MaxPi_ge_inv_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (1 : ℝ) / (P.parts.card : ℝ) ≤ MaxPi d P hP := by
  obtain ⟨S, hS, h_ge⟩ := exists_pi_ge_mean d P hP
  exact h_ge.trans (pi_le_MaxPi d P hP hS)

/-- **MaxPi > 0** for a nonempty partition. -/
theorem MaxPi_pos
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 < MaxPi d P hP := by
  have hm_pos : (0 : ℝ) < (P.parts.card : ℝ) := by
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have h_inv_pos : (0 : ℝ) < 1 / (P.parts.card : ℝ) := by positivity
  exact lt_of_lt_of_le h_inv_pos (MaxPi_ge_inv_card d P hP)

/-- **Bracket: `1/m ≤ MaxPi ≤ 1`.** -/
theorem MaxPi_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (1 : ℝ) / (P.parts.card : ℝ) ≤ MaxPi d P hP
      ∧ MaxPi d P hP ≤ 1 :=
  ⟨MaxPi_ge_inv_card d P hP, MaxPi_le_one d P hP⟩

/-- **Min-entropy upper bound.** `-log MaxPi ≤ log m`.

This is the Rényi-∞ entropy upper bound, matching the Shannon entropy
upper bound. -/
theorem MinEntropy_le_log_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    -Real.log (MaxPi d P hP) ≤ Real.log (P.parts.card : ℝ) := by
  have hm_pos : (0 : ℝ) < (P.parts.card : ℝ) := by
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_inv_pos : (0 : ℝ) < 1 / (P.parts.card : ℝ) := by positivity
  have h_ge := MaxPi_ge_inv_card d P hP
  -- log is monotone on positives: log(1/m) ≤ log(MaxPi).
  have h_log : Real.log (1 / (P.parts.card : ℝ)) ≤ Real.log (MaxPi d P hP) :=
    Real.log_le_log hm_inv_pos h_ge
  -- log(1/m) = -log m.
  have h_log_inv : Real.log (1 / (P.parts.card : ℝ)) = -Real.log (P.parts.card : ℝ) := by
    rw [Real.log_div one_ne_zero (ne_of_gt hm_pos), Real.log_one]; ring
  rw [h_log_inv] at h_log
  linarith

/-- **Min-entropy lower bound.** `-log MaxPi ≥ 0`. -/
theorem MinEntropy_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (0 : ℝ) ≤ -Real.log (MaxPi d P hP) := by
  have h_pos := MaxPi_pos d P hP
  have h_le_one := MaxPi_le_one d P hP
  have h_log : Real.log (MaxPi d P hP) ≤ Real.log 1 :=
    Real.log_le_log h_pos h_le_one
  rw [Real.log_one] at h_log
  linarith

/-- **Bracket: `0 ≤ H_∞ ≤ log m`.** -/
theorem MinEntropy_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (0 : ℝ) ≤ -Real.log (MaxPi d P hP)
      ∧ -Real.log (MaxPi d P hP) ≤ Real.log (P.parts.card : ℝ) :=
  ⟨MinEntropy_nonneg d P hP, MinEntropy_le_log_card d P hP⟩

/-- **Uniform ⟹ MaxPi = 1/m.** -/
theorem MaxPi_eq_inv_card_of_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    (h_uniform : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ)) :
    MaxPi d P hP = 1 / (P.parts.card : ℝ) := by
  -- MaxPi ≥ 1/m always; MaxPi ≤ 1/m because every π_S = 1/m.
  apply le_antisymm
  · apply Finset.max'_le
    intro x hx
    rcases Finset.mem_image.mp hx with ⟨S, hS, rfl⟩
    exact (h_uniform S hS).le
  · exact MaxPi_ge_inv_card d P hP

/-- **MaxPi = 1/m ⟹ uniform.** Forward direction of the saturation iff.

If the maximum equals the mean 1/m, then every π_S = 1/m: any larger
value would exceed the max; any smaller value would force the mean to
drop below 1/m (since the others are bounded by the max = 1/m), but
the mean is exactly 1/m. -/
theorem uniform_of_MaxPi_eq_inv_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    (h_max : MaxPi d P hP = 1 / (P.parts.card : ℝ)) :
    ∀ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ) := by
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  -- All π_S ≤ MaxPi = 1/m.
  have h_all_le : ∀ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 / m := by
    intro S hS
    have := pi_le_MaxPi d P hP hS
    rw [h_max] at this; exact this
  -- ∑ π = 1 from conservation.
  have h_sum_nnreal :
      ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
    T18_10_conservation_packaged d P
  have h_sum_real :
      ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) h_sum_nnreal
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  -- ∑ (1/m - π_S) ≥ 0 with each term ≥ 0; sum = m·(1/m) - 1 = 0.
  -- So each term = 0, i.e. π_S = 1/m.
  have h_sum_diff :
      ∑ S ∈ P.parts, (1 / m - ((P.subdomainMass d S : NNReal) : ℝ)) = 0 := by
    rw [Finset.sum_sub_distrib]
    rw [Finset.sum_const, nsmul_eq_mul]
    rw [h_sum_real]
    have hm_ne : m ≠ 0 := ne_of_gt hm_pos
    rw [hm_def]
    rw [mul_one_div, div_self (by rw [← hm_def]; exact hm_ne)]
    ring
  have h_each_nn : ∀ S ∈ P.parts,
      0 ≤ 1 / m - ((P.subdomainMass d S : NNReal) : ℝ) := by
    intro S hS
    have := h_all_le S hS
    linarith
  have h_each_zero : ∀ S ∈ P.parts,
      1 / m - ((P.subdomainMass d S : NNReal) : ℝ) = 0 :=
    (Finset.sum_eq_zero_iff_of_nonneg h_each_nn).mp h_sum_diff
  intro S hS
  have := h_each_zero S hS
  linarith

/-- **Saturation iff: MaxPi = 1/m ⟺ uniform.** -/
theorem MaxPi_eq_inv_card_iff_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    MaxPi d P hP = 1 / (P.parts.card : ℝ)
    ↔ ∀ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ) :=
  ⟨uniform_of_MaxPi_eq_inv_card d P hP,
   MaxPi_eq_inv_card_of_uniform d P hP⟩

/-- **Min-entropy saturation iff.** `-log(MaxPi) = log m ⟺ uniform`. -/
theorem MinEntropy_eq_log_card_iff_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    -Real.log (MaxPi d P hP) = Real.log (P.parts.card : ℝ)
    ↔ ∀ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ) := by
  rw [← MaxPi_eq_inv_card_iff_uniform d P hP]
  have hm_pos : (0 : ℝ) < (P.parts.card : ℝ) := by
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have h_MaxPi_pos := MaxPi_pos d P hP
  have h_inv_pos : (0 : ℝ) < 1 / (P.parts.card : ℝ) := by positivity
  constructor
  · intro h_log_eq
    -- -log(MaxPi) = log m  ⟹  log(MaxPi) = -log m = log(1/m)  ⟹  MaxPi = 1/m.
    have h1 : Real.log (MaxPi d P hP) = -Real.log (P.parts.card : ℝ) := by linarith
    have h2 : Real.log (MaxPi d P hP) = Real.log (1 / (P.parts.card : ℝ)) := by
      rw [Real.log_div one_ne_zero (ne_of_gt hm_pos), Real.log_one]
      linarith
    exact Real.log_injOn_pos (Set.mem_Ioi.mpr h_MaxPi_pos) (Set.mem_Ioi.mpr h_inv_pos) h2
  · intro h_eq
    rw [h_eq, Real.log_div one_ne_zero (ne_of_gt hm_pos), Real.log_one]
    ring

end R2_Agent4_MinEntropy

end MIP
