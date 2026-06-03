/-
  STATUS: DISCOVERY
  AGENT: R2-4
  DIRECTION: Rényi-2 (collision) divergence to uniform.
  SUMMARY:
    The Rényi-α divergence of `π` from the uniform distribution `U_i = 1/m`
    is `D_α(π ‖ U) = (1/(α-1)) log Σ π_S^α / U_S^{α-1}
                  = (1/(α-1)) log (m^{α-1} · Σ π_S^α)`.

    For α = 2 (collision divergence):
      `D_2(π ‖ U) := log (m · Σ_S π_S²)`.

    Values:
      - At uniform (π_S = 1/m): Σ π² = m·(1/m)² = 1/m, so D_2 = log(m · 1/m) = log 1 = 0.
      - At vertex (one π = 1, rest 0): Σ π² = 1, so D_2 = log m.

    Bracket: `0 ≤ D_2(π ‖ U) ≤ log m`. Lower bound from Σ π² ≥ 1/m
    (Agent3_PiSqBounds.sum_pi_sq_ge_inv_card); upper bound from Σ π² ≤ 1
    (Agent3_PiSqBounds.sum_pi_sq_le_one).
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Discoveries.Agent3_PiSqBounds

namespace MIP

namespace R2_Agent4_RenyiKL_alpha2

open scoped BigOperators
open Real
open MIP.Agent3_PiSqBounds (sum_pi_sq_le_one sum_pi_sq_ge_inv_card)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Rényi-2 (collision) divergence of `π` to uniform.**

`D_2(π ‖ U) := log (m · Σ_S π_S²)`. -/
noncomputable def RenyiKL_alpha2
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  Real.log ((P.parts.card : ℝ)
    * ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2)

/-- Helper: `m · Σ π² > 0` for a nonempty partition.

Proof: conservation gives `∑ π = 1 > 0`, so some `π_S > 0`, so `π_S² > 0`,
so `Σ π² > 0`. m > 0 from nonempty. -/
private lemma m_sum_sq_pos
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 < (P.parts.card : ℝ)
      * ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := by
  have hm_pos : 0 < (P.parts.card : ℝ) := by
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  -- Sum positivity.
  have h_sum_one : ∑ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have hpacked := T18_10_conservation_packaged d P
    have := congrArg (fun x : NNReal => (x : ℝ)) hpacked
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  have h_sum_pos : 0 < ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := by
    by_contra h_le
    push Not at h_le
    have h_each_nn : ∀ S ∈ P.parts,
        (0 : ℝ) ≤ (((P.subdomainMass d S : NNReal) : ℝ))^2 :=
      fun S _ => sq_nonneg _
    have h_sum_zero : ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ))^2 = 0 := by
      apply le_antisymm h_le
      exact Finset.sum_nonneg h_each_nn
    have h_each_zero : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 0 := by
      intro S hS
      have h_sq_zero := (Finset.sum_eq_zero_iff_of_nonneg h_each_nn).mp h_sum_zero S hS
      exact pow_eq_zero_iff (n := 2) (two_ne_zero) |>.mp h_sq_zero
    have h_sum_pi_zero : ∑ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 0 :=
      Finset.sum_eq_zero h_each_zero
    linarith [h_sum_one]
  exact mul_pos hm_pos h_sum_pos

/-- **At uniform, D_2 = 0.** -/
theorem RenyiKL_alpha2_eq_zero_of_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    (h_uniform : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ)) :
    RenyiKL_alpha2 d P = 0 := by
  unfold RenyiKL_alpha2
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_ne : m ≠ 0 := ne_of_gt hm_pos
  -- Σ π² = m · (1/m)² = 1/m.
  have h_sum :
      ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 = 1 / m := by
    have h_each : ∀ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ))^2 = (1 / m)^2 := by
      intro S hS
      rw [h_uniform S hS]
    rw [Finset.sum_congr rfl h_each]
    rw [Finset.sum_const, nsmul_eq_mul, ← hm_def]
    field_simp
  rw [h_sum]
  rw [mul_one_div, div_self hm_ne]
  exact Real.log_one

/-- **At vertex (point-mass), D_2 = log m.** -/
theorem RenyiKL_alpha2_eq_log_card_of_vertex
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    (h_vertex : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 0
        ∨ ((P.subdomainMass d S : NNReal) : ℝ) = 1) :
    RenyiKL_alpha2 d P = Real.log (P.parts.card : ℝ) := by
  unfold RenyiKL_alpha2
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  -- Σ π² = Σ π for π ∈ {0, 1} pointwise (since 0² = 0, 1² = 1).
  have h_sum_sq_eq_sum_pi :
      ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2
        = ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) := by
    apply Finset.sum_congr rfl
    intro S hS
    rcases h_vertex S hS with h0 | h1
    · rw [h0]; ring
    · rw [h1]; ring
  -- Σ π = 1.
  have h_sum_pi : ∑ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have hpacked := T18_10_conservation_packaged d P
    have := congrArg (fun x : NNReal => (x : ℝ)) hpacked
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  rw [h_sum_sq_eq_sum_pi, h_sum_pi, mul_one]

/-- **Lower bound: D_2 ≥ 0.** -/
theorem RenyiKL_alpha2_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ RenyiKL_alpha2 d P := by
  unfold RenyiKL_alpha2
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  -- Σ π² ≥ 1/m, so m · Σ π² ≥ 1, so log ≥ 0.
  have h_ge_inv := sum_pi_sq_ge_inv_card d P hP
  have h_ge_inv' : (1 : ℝ) / m
      ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := h_ge_inv
  have h_one_le :
      (1 : ℝ) ≤ m * ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := by
    have hm_nn : (0 : ℝ) ≤ m := le_of_lt hm_pos
    have := mul_le_mul_of_nonneg_left h_ge_inv' hm_nn
    have h_eq : m * (1 / m) = 1 := by field_simp
    rw [h_eq] at this; exact this
  have h_pos := m_sum_sq_pos d P hP
  have := Real.log_le_log (by norm_num : (0:ℝ) < 1) h_one_le
  rw [Real.log_one] at this
  exact this

/-- **Upper bound: D_2 ≤ log m.** -/
theorem RenyiKL_alpha2_le_log_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    RenyiKL_alpha2 d P ≤ Real.log (P.parts.card : ℝ) := by
  unfold RenyiKL_alpha2
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  -- Σ π² ≤ 1, so m · Σ π² ≤ m, so log ≤ log m.
  have h_le_one := sum_pi_sq_le_one d P
  have h_m_sum_le_m :
      m * ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 ≤ m := by
    have hm_nn : (0 : ℝ) ≤ m := le_of_lt hm_pos
    have := mul_le_mul_of_nonneg_left h_le_one hm_nn
    rw [mul_one] at this; exact this
  have h_pos := m_sum_sq_pos d P hP
  exact Real.log_le_log h_pos h_m_sum_le_m

/-- **Bracket: `0 ≤ D_2(π ‖ U) ≤ log m`.** -/
theorem RenyiKL_alpha2_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ RenyiKL_alpha2 d P ∧ RenyiKL_alpha2 d P ≤ Real.log (P.parts.card : ℝ) :=
  ⟨RenyiKL_alpha2_nonneg d P hP, RenyiKL_alpha2_le_log_card d P hP⟩

end R2_Agent4_RenyiKL_alpha2

end MIP
