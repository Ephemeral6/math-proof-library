/-
  STATUS: DISCOVERY
  AGENT: R2-4
  DIRECTION: Higher central moments of π — fourth central moment at uniform.
  SUMMARY:
    Define `FourthCentralMoment_pi := (1/m) Σ_S (π_S - 1/m)⁴`. At the
    uniform distribution every π_S equals 1/m so each term vanishes,
    giving M₄ = 0.

    Unlike the third central moment, the fourth has an iff form: since
    (x)⁴ ≥ 0 with equality iff x = 0, the sum is zero iff every π_S = 1/m.
    We prove both directions (algebraic kernel; the converse is similar to
    Agent3_PiVariance.Var_pi_eq_zero_imp_uniform).

    NOTE on kurtosis: kurtosis := M₄ / σ⁴ is degenerate at uniform because
    σ = 0; the ratio is undefined. We document this honestly and prove
    only the unnormalised statement M₄ = 0.
-/
import MIP.Theorems.T18_10_Conservation

namespace MIP

namespace R2_Agent4_FourthMoment_Uniform

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Fourth central moment of the partition-mass profile.**

`M₄(d, P) := (1/m) ∑_{S ∈ parts} (π_S - 1/m)⁴`. -/
noncomputable def FourthCentralMoment_pi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
    (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^4

/-- **M₄ is nonneg.** Each term is a fourth power. -/
theorem FourthCentralMoment_pi_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    0 ≤ FourthCentralMoment_pi d P := by
  unfold FourthCentralMoment_pi
  apply mul_nonneg
  · by_cases hm0 : (P.parts.card : ℝ) = 0
    · rw [hm0]; norm_num
    · have : 0 < (P.parts.card : ℝ) := by
        have h_card_nn : 0 ≤ (P.parts.card : ℝ) := by exact_mod_cast Nat.zero_le _
        exact lt_of_le_of_ne h_card_nn (Ne.symm hm0)
      positivity
  · apply Finset.sum_nonneg
    intro S _
    positivity

/-- **Uniform ⟹ M₄ = 0.** -/
theorem FourthCentralMoment_pi_eq_zero_of_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (h_uniform : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ)) :
    FourthCentralMoment_pi d P = 0 := by
  unfold FourthCentralMoment_pi
  have h_each_zero : ∀ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^4 = 0 := by
    intro S hS
    rw [h_uniform S hS]
    ring
  rw [Finset.sum_congr rfl h_each_zero]
  simp

/-- **M₄ = 0 ⟹ uniform.** Forward direction. Since the sum of fourth-powers
is zero with `(1/m) > 0`, each fourth-power is zero, so each `π_S - 1/m = 0`. -/
theorem FourthCentralMoment_pi_eq_zero_imp_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) (h_m4 : FourthCentralMoment_pi d P = 0) :
    ∀ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ) := by
  classical
  have h_m4' :
      (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^4
        = 0 := h_m4
  set m : ℝ := (P.parts.card : ℝ) with hm
  have hm_pos : 0 < m := by
    rw [hm]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_inv_pos : 0 < 1 / m := by positivity
  have h_sum_pow_zero :
      ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^4 = 0 := by
    by_contra h
    have h_pos : 0 <
        ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^4 := by
      apply lt_of_le_of_ne
      · apply Finset.sum_nonneg; intros; positivity
      · exact Ne.symm h
    have h_prod_pos : 0 < (1 / m) *
        ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^4 :=
      mul_pos hm_inv_pos h_pos
    linarith [h_m4']
  have h_each_pow_zero : ∀ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^4 = 0 := by
    intro S hS
    exact (Finset.sum_eq_zero_iff_of_nonneg (fun T _ => by positivity)).mp h_sum_pow_zero S hS
  intro S hS
  have h_diff_zero :
      ((P.subdomainMass d S : NNReal) : ℝ) - 1 / m = 0 := by
    have h := h_each_pow_zero S hS
    exact pow_eq_zero_iff (n := 4) (by norm_num) |>.mp h
  linarith

/-- **Full iff: `M₄ = 0 ⟺ uniform attention`.** -/
theorem FourthCentralMoment_pi_eq_zero_iff_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    FourthCentralMoment_pi d P = 0
    ↔ ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ) :=
  ⟨FourthCentralMoment_pi_eq_zero_imp_uniform d P hP,
   FourthCentralMoment_pi_eq_zero_of_uniform d P⟩

end R2_Agent4_FourthMoment_Uniform

end MIP
