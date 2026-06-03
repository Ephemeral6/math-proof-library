/-
  STATUS: DISCOVERY
  AGENT: R2-4
  DIRECTION: Higher central moments of π — third central moment at uniform.
  SUMMARY:
    Define `ThirdCentralMoment_pi := (1/m) Σ_S (π_S - 1/m)³` (signed) and
    `ThirdAbsoluteMoment_pi := (1/m) Σ_S |π_S - 1/m|³`. At the uniform
    distribution every π_S equals 1/m so each term `(π_S - 1/m)^k = 0`,
    giving the central / absolute third moment both equal 0.

    The reverse direction (third central moment zero ⟹ uniform) is FALSE
    in general (any symmetric-around-mean distribution has M3 = 0), so we
    state only the forward direction. The absolute-moment forward direction
    is recorded too (and its iff form is true because |x|³ ≥ 0 with equality
    iff x = 0, so the sum is zero iff every term is zero iff every π = 1/m).
-/
import MIP.Theorems.T18_10_Conservation

namespace MIP

namespace R2_Agent4_ThirdMoment_Uniform

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Third central moment of the partition-mass profile.**

`M₃(d, P) := (1/m) ∑_{S ∈ parts} (π_S - 1/m)³`. -/
noncomputable def ThirdCentralMoment_pi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
    (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^3

/-- **Third absolute moment of the partition-mass profile.**

`M₃ᵃ(d, P) := (1/m) ∑_{S ∈ parts} |π_S - 1/m|³`. -/
noncomputable def ThirdAbsoluteMoment_pi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
    |((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ)|^3

/-- **Uniform ⟹ M₃ = 0.** If every part has mass exactly `1/m`, the
signed third central moment vanishes. -/
theorem ThirdCentralMoment_pi_eq_zero_of_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (h_uniform : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ)) :
    ThirdCentralMoment_pi d P = 0 := by
  unfold ThirdCentralMoment_pi
  have h_each_zero : ∀ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^3 = 0 := by
    intro S hS
    rw [h_uniform S hS]
    ring
  rw [Finset.sum_congr rfl h_each_zero]
  simp

/-- **Uniform ⟹ |M₃| = 0.** -/
theorem ThirdAbsoluteMoment_pi_eq_zero_of_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (h_uniform : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ)) :
    ThirdAbsoluteMoment_pi d P = 0 := by
  unfold ThirdAbsoluteMoment_pi
  have h_each_zero : ∀ S ∈ P.parts,
      |((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ)|^3 = 0 := by
    intro S hS
    rw [h_uniform S hS]
    simp
  rw [Finset.sum_congr rfl h_each_zero]
  simp

end R2_Agent4_ThirdMoment_Uniform

end MIP
