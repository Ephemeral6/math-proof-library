/-
  STATUS: DISCOVERY
  AGENT: R2-4
  DIRECTION: Rényi-3 sum bracket: `1/m² ≤ Σ π_S³ ≤ 1`.
  SUMMARY:
    For a partition mass profile `π : parts → [0,1]` summing to 1 (T.18.10),
    we bracket the cubic sum:

      `1/m²  ≤  Σ π_S³  ≤  1`

    Upper bound:  π_S³ = π_S² · π_S ≤ π_S² · 1 = π_S², so
      `Σ π_S³ ≤ Σ π_S² ≤ 1` (using Agent3_PiSqBounds.sum_pi_sq_le_one).

    Lower bound:  Mathlib's `pow_sum_le_card_mul_sum_pow` (a special case
    of Jensen's inequality / power-mean) with exponent `n + 1 = 3` gives:
      `(Σ π_S)^3 ≤ m^2 · Σ π_S^3`
    i.e. `1 ≤ m² · Σ π_S³`, so `Σ π_S³ ≥ 1/m²`. Equality at uniform.
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Discoveries.Agent3_PiMassBounds
import MIP.Discoveries.Agent3_PiSqBounds
import Mathlib.Algebra.Order.Chebyshev

namespace MIP

namespace R2_Agent4_RenyiSum3

open scoped BigOperators
open MIP.Agent3_PiMassBounds (pi_le_one)
open MIP.Agent3_PiSqBounds (sum_pi_sq_le_one)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Sum of cubes is nonneg.** Each `π_S³` is a cube of a nonneg, hence nonneg. -/
theorem sum_pi_cube_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    (0 : ℝ) ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^3 := by
  apply Finset.sum_nonneg
  intro S _
  have h0 : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
    NNReal.coe_nonneg _
  positivity

/-- **Cubic sum is bounded above by quadratic sum.**

`Σ π_S³ ≤ Σ π_S²` (since `π_S ≤ 1`, so `π_S³ = π_S² · π_S ≤ π_S²`). -/
theorem sum_pi_cube_le_sum_pi_sq
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^3
      ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := by
  apply Finset.sum_le_sum
  intro S hS
  have h0 : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
    NNReal.coe_nonneg _
  have h1 : ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 := by
    have := pi_le_one d P hS
    exact_mod_cast this
  nlinarith [sq_nonneg (((P.subdomainMass d S : NNReal) : ℝ)),
             pow_nonneg h0 3]

/-- **R2-4.upper — Σ π_S³ ≤ 1.**

Compose `Σ π_S³ ≤ Σ π_S² ≤ 1`. -/
theorem sum_pi_cube_le_one
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^3 ≤ 1 :=
  (sum_pi_cube_le_sum_pi_sq d P).trans (sum_pi_sq_le_one d P)

/-- **R2-4.lower — Σ π_S³ ≥ 1/m².**

By Jensen's inequality (special case `pow_sum_le_card_mul_sum_pow` in Mathlib),
with `n + 1 = 3` so `n = 2`:
  `(Σ π_S)^3 ≤ m^2 · Σ π_S^3`
Substituting `Σ π_S = 1` from conservation:
  `1 ≤ m^2 · Σ π_S^3`,
which rearranges to `Σ π_S^3 ≥ 1/m^2`. Equality at uniform. -/
theorem sum_pi_cube_ge_inv_card_sq
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (1 : ℝ) / (P.parts.card : ℝ)^2
      ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^3 := by
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_sq_pos : 0 < m^2 := by positivity
  -- Conservation: Σ π = 1.
  have h_sum_nnreal :
      ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
    T18_10_conservation_packaged d P
  have h_sum_real :
      ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) h_sum_nnreal
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  -- Apply pow_sum_le_card_mul_sum_pow with n = 2.
  have h_nonneg : ∀ S ∈ P.parts, (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
    fun S _ => NNReal.coe_nonneg _
  have h_jensen :
      (∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ)) ^ (2 + 1)
        ≤ (P.parts.card : ℝ) ^ 2
          * ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ)) ^ (2 + 1) :=
    pow_sum_le_card_mul_sum_pow h_nonneg 2
  -- The "2 + 1" simplifies to 3.
  have h_jensen' : (1 : ℝ)
      ≤ m^2 * ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^3 := by
    have h := h_jensen
    rw [h_sum_real] at h
    simp at h
    convert h using 1
  -- 1 / m² ≤ Σ π³.
  rw [div_le_iff₀ hm_sq_pos, mul_comm]
  linarith

/-- **Bracket: `1/m² ≤ Σ π_S³ ≤ 1`.** -/
theorem sum_pi_cube_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (1 : ℝ) / (P.parts.card : ℝ)^2
        ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^3
      ∧ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^3 ≤ 1 :=
  ⟨sum_pi_cube_ge_inv_card_sq d P hP, sum_pi_cube_le_one d P⟩

end R2_Agent4_RenyiSum3

end MIP
