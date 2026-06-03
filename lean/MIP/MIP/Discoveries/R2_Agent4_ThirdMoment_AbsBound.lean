/-
  STATUS: DISCOVERY
  AGENT: R2-4
  DIRECTION: Closed-form upper bound on the signed third central moment.
  SUMMARY:
    We bound the third absolute moment by the variance, using the simple
    pointwise bound `|π_S - 1/m| ≤ 1` (from `0 ≤ π_S ≤ 1` and
    `0 ≤ 1/m ≤ 1`). Concretely:

      `|π_S - 1/m|³ = |π_S - 1/m| · (π_S - 1/m)²  ≤  1 · (π_S - 1/m)²`

    Summing and dividing by m:

      `(1/m) Σ |π_S - 1/m|³  ≤  (1/m) Σ (π_S - 1/m)²  =  Var_π`

    Then `|M_3| ≤ M_3^abs` (triangle):

      `|M_3|  ≤  Var_π  ≤  (m - 1) / m²`

    using Agent 3's Bhatia-Davis bound `Var_π ≤ (m - 1) / m²`
    (Agent3_PiVariance.Var_pi_le_bhatia_davis).

    The looser bound `1` (vs. the tighter `1 - 1/m`) is used because the
    tighter bound fails for `m = 1` (then `π_S = 1, 1/m = 1, |π_S - 1/m| = 0`
    holds but only because conservation pins `π_S = 1`, requiring a less
    clean proof). The `1` bound is uniform across `m ≥ 1`.
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Discoveries.Agent3_PiVariance

namespace MIP

namespace R2_Agent4_ThirdMoment_AbsBound

open scoped BigOperators
open MIP.Agent3_PiVariance (Var_pi Var_pi_le_bhatia_davis)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- Inlined helper: `π_S ≤ 1` for any part `S ∈ parts`. -/
private lemma pi_le_one_aux
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    {K_i : Finset Ω} (hK_i : K_i ∈ P.parts) :
    P.subdomainMass d K_i ≤ 1 := by
  show (∑ ω ∈ K_i, d.p ω) ≤ 1
  have h_sum :
      ∑ S ∈ P.parts, ∑ ω ∈ S, d.p ω = 1 :=
    T18_10_conservation d.p d.normalized P.parts
      P.pairwise_disjoint P.cover
  have h_split :
      ∑ S ∈ P.parts, ∑ ω ∈ S, d.p ω
        = (∑ ω ∈ K_i, d.p ω)
          + ∑ S ∈ P.parts.erase K_i, ∑ ω ∈ S, d.p ω :=
    (Finset.add_sum_erase P.parts (fun S => ∑ ω ∈ S, d.p ω) hK_i).symm
  have h_rest_nn :
      (0 : NNReal) ≤ ∑ S ∈ P.parts.erase K_i, ∑ ω ∈ S, d.p ω :=
    zero_le _
  calc (∑ ω ∈ K_i, d.p ω)
      ≤ (∑ ω ∈ K_i, d.p ω)
          + ∑ S ∈ P.parts.erase K_i, ∑ ω ∈ S, d.p ω :=
        le_add_of_nonneg_right h_rest_nn
    _ = ∑ S ∈ P.parts, ∑ ω ∈ S, d.p ω := h_split.symm
    _ = 1 := h_sum

/-- **Per-part deviation bound by 1.** For any part `S`, with `π_S ∈ [0, 1]`
and `1/m ∈ [0, 1]`, the absolute deviation is at most 1. -/
theorem abs_pi_sub_inv_le_one
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    {S : Finset Ω} (hS : S ∈ P.parts) :
    |((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ)| ≤ 1 := by
  have hm_pos : (0 : ℝ) < (P.parts.card : ℝ) := by
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_ge_one : (1 : ℝ) ≤ (P.parts.card : ℝ) := by
    have h : 1 ≤ P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have h0 : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
    NNReal.coe_nonneg _
  have h1 : ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 := by
    have := pi_le_one_aux d P hS
    exact_mod_cast this
  have h_inv_nn : (0 : ℝ) ≤ 1 / (P.parts.card : ℝ) := by positivity
  have h_inv_le_one : (1 : ℝ) / (P.parts.card : ℝ) ≤ 1 := by
    rw [div_le_one hm_pos]; exact hm_ge_one
  rw [abs_le]
  refine ⟨?_, ?_⟩
  · linarith
  · linarith

/-- Auxiliary: `|x|³ ≤ K · x²` when `|x| ≤ K`. -/
private lemma abs_cube_le_sq_mul
    (x K : ℝ) (_hK : 0 ≤ K) (h : |x| ≤ K) :
    |x|^3 ≤ K * x^2 := by
  have habs_nn : 0 ≤ |x| := abs_nonneg _
  have : |x|^3 = |x| * |x|^2 := by ring
  rw [this]
  have hx_sq : |x|^2 = x^2 := sq_abs _
  rw [hx_sq]
  have hx2_nn : (0 : ℝ) ≤ x^2 := sq_nonneg _
  exact mul_le_mul_of_nonneg_right h hx2_nn

/-- **Per-term cube bound.** `|π_S - 1/m|³ ≤ (π_S - 1/m)²`. -/
theorem each_term_cube_le_sq
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty)
    {S : Finset Ω} (hS : S ∈ P.parts) :
    |((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ)|^3
      ≤ (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^2 := by
  have h := abs_pi_sub_inv_le_one d P hP hS
  have h_step :
      |((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ)|^3
        ≤ 1 * (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^2 :=
    abs_cube_le_sq_mul _ 1 zero_le_one h
  simpa using h_step

/-- **Third absolute moment bound.**

`(1/m) Σ |π_S - 1/m|³ ≤ Var_π`. -/
theorem ThirdAbsoluteMoment_le_var
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
        |((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ)|^3
      ≤ Var_pi d P := by
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_inv_nn : (0 : ℝ) ≤ 1 / m := by positivity
  -- Pointwise: each |.|³ ≤ (.)².
  have h_each : ∀ S ∈ P.parts,
      |((P.subdomainMass d S : NNReal) : ℝ) - 1 / m|^3
        ≤ (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2 := by
    intro S hS
    exact each_term_cube_le_sq d P hP hS
  have h_sum :
      ∑ S ∈ P.parts,
        |((P.subdomainMass d S : NNReal) : ℝ) - 1 / m|^3
      ≤ ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2 :=
    Finset.sum_le_sum h_each
  -- Multiply by (1/m) ≥ 0.
  have h_mul := mul_le_mul_of_nonneg_left h_sum hm_inv_nn
  -- RHS = Var_π (by Var_pi definition).
  have h_var_form :
      (1 / m) *
        ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2
      = Var_pi d P := by
    unfold Var_pi
    rfl
  rw [h_var_form] at h_mul
  exact h_mul

/-- **|M_3| signed bound via triangle inequality.** -/
theorem abs_ThirdCentralMoment_le_var
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    |(1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^3|
      ≤ Var_pi d P := by
  set m : ℝ := (P.parts.card : ℝ) with hm_def
  have hm_pos : 0 < m := by
    rw [hm_def]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_inv_nn : (0 : ℝ) ≤ 1 / m := by positivity
  -- Triangle: |Σ x_S³| ≤ Σ |x_S|³.
  have h_triangle :
      |∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^3|
        ≤ ∑ S ∈ P.parts,
            |((P.subdomainMass d S : NNReal) : ℝ) - 1 / m|^3 := by
    calc |∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^3|
        ≤ ∑ S ∈ P.parts,
            |(((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^3| :=
              Finset.abs_sum_le_sum_abs _ _
      _ = ∑ S ∈ P.parts,
            |((P.subdomainMass d S : NNReal) : ℝ) - 1 / m|^3 := by
              apply Finset.sum_congr rfl
              intro S _
              rw [abs_pow]
  have h_abs_form : |(1 / m) *
      ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^3|
      = (1 / m) * |∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^3| := by
    rw [abs_mul, abs_of_nonneg hm_inv_nn]
  rw [h_abs_form]
  have h_mul := mul_le_mul_of_nonneg_left h_triangle hm_inv_nn
  exact h_mul.trans (ThirdAbsoluteMoment_le_var d P hP)

/-- **Closed-form bound.** `|M_3| ≤ (m - 1) / m²`. -/
theorem abs_ThirdCentralMoment_closed_form
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    |(1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^3|
      ≤ ((P.parts.card : ℝ) - 1) / (P.parts.card : ℝ)^2 :=
  (abs_ThirdCentralMoment_le_var d P hP).trans (Var_pi_le_bhatia_davis d P hP)

end R2_Agent4_ThirdMoment_AbsBound

end MIP
