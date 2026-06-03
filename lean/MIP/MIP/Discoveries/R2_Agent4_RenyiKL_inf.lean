/-
  STATUS: DISCOVERY
  AGENT: R2-4
  DIRECTION: Max-divergence (Rényi-∞) to uniform.
  SUMMARY:
    The Rényi-∞ (max) divergence of `π` from the uniform distribution
    `U_i = 1/m` is:
      `D_∞(π ‖ U) := log(m · max_S π_S)`.

    Values:
      - At uniform (π_S = 1/m for all S): max = 1/m, so D_∞ = log(m · 1/m) = log 1 = 0.
      - At vertex (some π_S = 1, rest 0): max = 1, so D_∞ = log m.

    Bracket: `0 ≤ D_∞(π ‖ U) ≤ log m`.
      - Lower: max π_S ≥ 1/m (Agent3_PiPigeonhole.exists_pi_ge_mean), so
        m · max ≥ 1, log ≥ 0.
      - Upper: max π_S ≤ 1 (Agent3_PiMassBounds.pi_le_one), so m · max ≤ m,
        log ≤ log m.

    Saturation iff: D_∞ = 0 ⟺ max π_S = 1/m ⟺ uniform (uses
    R2_Agent4_MinEntropy.MaxPi_eq_inv_card_iff_uniform).
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Discoveries.Agent3_PiMassBounds
import MIP.Discoveries.Agent3_PiPigeonhole
import MIP.Discoveries.R2_Agent4_MinEntropy

namespace MIP

namespace R2_Agent4_RenyiKL_inf

open scoped BigOperators
open Real
open MIP.R2_Agent4_MinEntropy
  (MaxPi MaxPi_le_one MaxPi_ge_inv_card MaxPi_pos MaxPi_eq_inv_card_iff_uniform)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Max-divergence of `π` to uniform.**

`D_∞(π ‖ U) := log (m · MaxPi)`. -/
noncomputable def RenyiKL_inf
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) : ℝ :=
  Real.log ((P.parts.card : ℝ) * MaxPi d P hP)

/-- Helper: `m · MaxPi > 0`. -/
private lemma m_MaxPi_pos
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 < (P.parts.card : ℝ) * MaxPi d P hP := by
  have hm_pos : 0 < (P.parts.card : ℝ) := by
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  exact mul_pos hm_pos (MaxPi_pos d P hP)

/-- **D_∞ ≥ 0** (max ≥ 1/m, so m·max ≥ 1, so log ≥ 0). -/
theorem RenyiKL_inf_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ RenyiKL_inf d P hP := by
  unfold RenyiKL_inf
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have h_ge := MaxPi_ge_inv_card d P hP
  have h_m_max_ge_one : 1 ≤ m * MaxPi d P hP := by
    have hm_nn : 0 ≤ m := le_of_lt hm_pos
    have := mul_le_mul_of_nonneg_left h_ge hm_nn
    have h_eq : m * (1 / m) = 1 := by field_simp
    rw [h_eq] at this; exact this
  have h_pos := m_MaxPi_pos d P hP
  have := Real.log_le_log (by norm_num : (0:ℝ) < 1) h_m_max_ge_one
  rw [Real.log_one] at this
  exact this

/-- **D_∞ ≤ log m** (max ≤ 1, so m·max ≤ m, so log ≤ log m). -/
theorem RenyiKL_inf_le_log_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    RenyiKL_inf d P hP ≤ Real.log (P.parts.card : ℝ) := by
  unfold RenyiKL_inf
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have h_le := MaxPi_le_one d P hP
  have h_m_max_le_m : m * MaxPi d P hP ≤ m := by
    have hm_nn : 0 ≤ m := le_of_lt hm_pos
    have := mul_le_mul_of_nonneg_left h_le hm_nn
    rw [mul_one] at this; exact this
  have h_pos := m_MaxPi_pos d P hP
  exact Real.log_le_log h_pos h_m_max_le_m

/-- **Bracket: `0 ≤ D_∞(π ‖ U) ≤ log m`.** -/
theorem RenyiKL_inf_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ RenyiKL_inf d P hP ∧ RenyiKL_inf d P hP ≤ Real.log (P.parts.card : ℝ) :=
  ⟨RenyiKL_inf_nonneg d P hP, RenyiKL_inf_le_log_card d P hP⟩

/-- **At uniform, D_∞ = 0.** -/
theorem RenyiKL_inf_eq_zero_of_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    (h_uniform : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ)) :
    RenyiKL_inf d P hP = 0 := by
  unfold RenyiKL_inf
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_ne : m ≠ 0 := ne_of_gt hm_pos
  -- MaxPi = 1/m (saturation iff, ⟸ direction).
  have h_max_eq : MaxPi d P hP = 1 / m := by
    have h_iff := MaxPi_eq_inv_card_iff_uniform d P hP
    rw [← hm_def] at h_iff
    exact h_iff.mpr h_uniform
  rw [h_max_eq, mul_one_div, div_self hm_ne]
  exact Real.log_one

/-- **D_∞ = 0 ⟺ uniform.** -/
theorem RenyiKL_inf_eq_zero_iff_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    RenyiKL_inf d P hP = 0
    ↔ ∀ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ) := by
  constructor
  · intro h_zero
    -- D_∞ = 0 ⟺ log(m · MaxPi) = 0 ⟺ m · MaxPi = 1 ⟺ MaxPi = 1/m.
    unfold RenyiKL_inf at h_zero
    set m : ℝ := (P.parts.card : ℝ) with hm_def
    have hm_pos : 0 < m := by
      rw [hm_def]
      have h : 0 < P.parts.card := Finset.card_pos.mpr hP
      exact_mod_cast h
    have hm_ne : m ≠ 0 := ne_of_gt hm_pos
    have h_pos := m_MaxPi_pos d P hP
    have h_log_eq_zero : Real.log (m * MaxPi d P hP) = 0 := h_zero
    have h_m_max_eq_one : m * MaxPi d P hP = 1 := by
      have h_log_one : Real.log 1 = 0 := Real.log_one
      have h1 : Real.log (m * MaxPi d P hP) = Real.log 1 := by
        rw [h_log_one, h_log_eq_zero]
      exact Real.log_injOn_pos (Set.mem_Ioi.mpr h_pos)
        (Set.mem_Ioi.mpr (by norm_num : (0:ℝ) < 1)) h1
    have h_max_eq : MaxPi d P hP = 1 / m := by
      field_simp at h_m_max_eq_one ⊢
      linarith
    -- Apply saturation iff.
    have h_iff := MaxPi_eq_inv_card_iff_uniform d P hP
    rw [← hm_def] at h_iff
    exact h_iff.mp h_max_eq
  · exact RenyiKL_inf_eq_zero_of_uniform d P hP

/-- **At vertex, D_∞ = log m.** -/
theorem RenyiKL_inf_eq_log_card_of_vertex
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    (h_vertex_attained : ∃ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1) :
    RenyiKL_inf d P hP = Real.log (P.parts.card : ℝ) := by
  unfold RenyiKL_inf
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  -- MaxPi = 1 since max ≥ 1 (some π_S = 1) and max ≤ 1.
  have h_max_eq : MaxPi d P hP = 1 := by
    apply le_antisymm
    · exact MaxPi_le_one d P hP
    · obtain ⟨S, hS, h_eq⟩ := h_vertex_attained
      have h_le := MIP.R2_Agent4_MinEntropy.pi_le_MaxPi d P hP hS
      rw [h_eq] at h_le; exact h_le
  rw [h_max_eq, mul_one]

end R2_Agent4_RenyiKL_inf

end MIP
