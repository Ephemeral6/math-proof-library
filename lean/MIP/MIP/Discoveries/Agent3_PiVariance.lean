/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Tier D — Variance of the partition-mass profile.
  SUMMARY:
    Define the (population) variance of the subdomain-mass profile around
    its mean 1/m:
      Var_π(d, P) := (1/m) ∑_{S ∈ parts} (π_S - 1/m)²
    Two main facts:
      Tier D.13   Var_π = (1/m) · Σ π_S²  -  1/m²       (variance identity)
      Tier D.14   Var_π ≥ 0                              (always)
      Tier D.14b  Var_π = 0  ⟺  all π_S equal 1/m       (uniform-attention)
                   (forward direction only; this is the algebraic kernel)

    The identity in D.13 follows from expanding the square and using
    Σπ_S = 1 (conservation). The nonnegativity is from squares being ≥ 0.
    The Bhatia-Davis upper bound `Var_π ≤ (m-1)/m²` for distributions on
    [0,1] is also derived as Tier D.15.
-/
import MIP.Theorems.T18_10_Conservation

namespace MIP

namespace Agent3_PiVariance

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- Inlined helper: π_S ≤ 1. -/
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

/-- **Population variance of the subdomain-mass profile around the mean 1/m.**

`Var_π(d, P) := (1/m) ∑_{S ∈ parts} (π_S - 1/m)²`.

We use the symmetric 1/m form, with `m := P.parts.card`. -/
noncomputable def Var_pi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
    (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^2

/-- **D.13 — Variance identity.**

`Var_π = (1/m) · ∑ π_S²  -  1/m²`.

Proof: expand `(π - 1/m)² = π² - 2π/m + 1/m²`, sum, use Σ π = 1, Σ 1/m² = m/m² = 1/m. -/
theorem Var_pi_identity
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    Var_pi d P
      = (1 / P.parts.card) * ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ))^2
        - 1 / (P.parts.card : ℝ)^2 := by
  classical
  show (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^2
      = (1 / P.parts.card) * ∑ S ∈ P.parts,
            (((P.subdomainMass d S : NNReal) : ℝ))^2
          - 1 / (P.parts.card : ℝ)^2
  set m : ℝ := (P.parts.card : ℝ) with hm
  have hm_pos : 0 < m := by
    rw [hm]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_ne : m ≠ 0 := ne_of_gt hm_pos
  -- Sum conservation in ℝ.
  have h_sum_one : ∑ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have hpacked := T18_10_conservation_packaged d P
    have := congrArg (fun x : NNReal => (x : ℝ)) hpacked
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  -- Expand the square pointwise.
  have h_expand : ∀ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2
        = (((P.subdomainMass d S : NNReal) : ℝ))^2
          - 2 * ((P.subdomainMass d S : NNReal) : ℝ) / m
          + 1 / m^2 := by
    intro S _
    ring
  rw [Finset.sum_congr rfl h_expand]
  -- Now distribute the sum.
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  -- Compute the three component sums.
  have hB : ∑ S ∈ P.parts,
      2 * ((P.subdomainMass d S : NNReal) : ℝ) / m
      = 2 / m := by
    have : ∀ S ∈ P.parts,
        2 * ((P.subdomainMass d S : NNReal) : ℝ) / m
          = (2 / m) * ((P.subdomainMass d S : NNReal) : ℝ) := by
      intro S _; ring
    rw [Finset.sum_congr rfl this]
    rw [← Finset.mul_sum, h_sum_one]; ring
  have hC : ∑ _S ∈ P.parts, (1 / m^2 : ℝ) = 1 / m := by
    rw [Finset.sum_const]
    rw [show (P.parts.card • (1 / m^2 : ℝ))
          = (P.parts.card : ℝ) * (1 / m^2) by simp [nsmul_eq_mul]]
    rw [← hm]
    field_simp
  rw [hB, hC]
  field_simp
  ring

/-- **D.14 — Variance is nonneg.** Each term is a square. -/
theorem Var_pi_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    0 ≤ Var_pi d P := by
  unfold Var_pi
  apply mul_nonneg
  · -- 1/m ≥ 0
    by_cases hm0 : (P.parts.card : ℝ) = 0
    · rw [hm0]; norm_num
    · have : 0 < (P.parts.card : ℝ) := by
        have h_card_nn : 0 ≤ (P.parts.card : ℝ) := by exact_mod_cast Nat.zero_le _
        exact lt_of_le_of_ne h_card_nn (Ne.symm hm0)
      positivity
  · apply Finset.sum_nonneg
    intro S _
    exact sq_nonneg _

/-- **D.14b — Variance zero ⟹ uniform.**

If `Var_π = 0` (and the partition is nonempty), then every part has mass
exactly `1/m`. -/
theorem Var_pi_eq_zero_imp_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) (h_var : Var_pi d P = 0) :
    ∀ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 1 / P.parts.card := by
  classical
  have h_var' :
      (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^2
        = 0 := h_var
  set m : ℝ := (P.parts.card : ℝ) with hm
  have hm_pos : 0 < m := by
    rw [hm]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_inv_pos : 0 < 1 / m := by positivity
  -- (1/m) * Σ (π - 1/m)² = 0  and  1/m > 0  ⟹  Σ (π - 1/m)² = 0.
  have h_sum_sq_zero :
      ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2 = 0 := by
    by_contra h
    have h_pos : 0 <
        ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2 := by
      apply lt_of_le_of_ne
      · apply Finset.sum_nonneg; intros; exact sq_nonneg _
      · exact Ne.symm h
    have h_prod_pos : 0 < (1 / m) *
        ∑ S ∈ P.parts,
          (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2 :=
      mul_pos hm_inv_pos h_pos
    linarith [h_var']
  -- All squared terms are nonneg; their sum is 0 ⟹ each is 0.
  have h_each_sq_zero : ∀ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ) - 1 / m)^2 = 0 := by
    intro S hS
    apply (Finset.sum_eq_zero_iff_of_nonneg (fun T _ => sq_nonneg _)).mp h_sum_sq_zero S hS
  intro S hS
  -- (x)² = 0 ⟹ x = 0.
  have h_diff_zero :
      ((P.subdomainMass d S : NNReal) : ℝ) - 1 / m = 0 := by
    have := h_each_sq_zero S hS
    exact pow_eq_zero_iff (n := 2) (two_ne_zero) |>.mp this
  linarith

/-- **D.14c — Uniform ⟹ variance zero (converse of D.14b).**

If every part has mass exactly `1/m`, then `Var_π = 0`. -/
theorem Var_pi_eq_zero_of_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (h_uniform : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ)) :
    Var_pi d P = 0 := by
  show (1 / (P.parts.card : ℝ)) * ∑ S ∈ P.parts,
        (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^2
      = 0
  -- Each term `(1/m - 1/m)² = 0`.
  have h_each_zero : ∀ S ∈ P.parts,
      (((P.subdomainMass d S : NNReal) : ℝ) - 1 / (P.parts.card : ℝ))^2 = 0 := by
    intro S hS
    rw [h_uniform S hS]
    ring
  rw [Finset.sum_congr rfl h_each_zero]
  simp

/-- **D.14 (full iff form) — `Var_π = 0 ⟺ uniform attention`.** -/
theorem Var_pi_eq_zero_iff_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    Var_pi d P = 0
    ↔ ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 / (P.parts.card : ℝ) :=
  ⟨Var_pi_eq_zero_imp_uniform d P hP, Var_pi_eq_zero_of_uniform d P⟩

/-- **D.15 (Bhatia–Davis kernel) — Variance is at most `(m-1)/m²`.**

For distributions on [0,1] with mean 1/m (which our `π_S` satisfies via
conservation), the maximum population variance is `(1 - 1/m) · 1/m = (m-1)/m²`,
attained at a vertex (one π_S = 1, others = 0).

Proof (population form): expand the variance identity `Var = (1/m) Σ π² - 1/m²`,
then use `π_S² ≤ π_S` (since 0 ≤ π_S ≤ 1), so `Σ π² ≤ Σ π = 1`, giving
`Var ≤ 1/m - 1/m² = (m-1)/m²`. -/
theorem Var_pi_le_bhatia_davis
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    Var_pi d P ≤ ((P.parts.card : ℝ) - 1) / (P.parts.card : ℝ)^2 := by
  rw [Var_pi_identity d P hP]
  set m : ℝ := (P.parts.card : ℝ) with hm
  have hm_pos : 0 < m := by
    rw [hm]
    have h : 0 < P.parts.card := Finset.card_pos.mpr hP
    exact_mod_cast h
  have hm_ne : m ≠ 0 := ne_of_gt hm_pos
  -- ∑ π_S² ≤ ∑ π_S = 1.
  have h_sum_sq_le_one :
      ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 ≤ 1 := by
    have h_sum_one : ∑ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
      have hpacked := T18_10_conservation_packaged d P
      have := congrArg (fun x : NNReal => (x : ℝ)) hpacked
      simpa [NNReal.coe_sum, NNReal.coe_one] using this
    calc ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2
        ≤ ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) := by
          apply Finset.sum_le_sum
          intro S hS
          have h0 : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
            NNReal.coe_nonneg _
          have h1 : ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 := by
            have := pi_le_one_aux d P hS
            exact_mod_cast this
          nlinarith [sq_nonneg (((P.subdomainMass d S : NNReal) : ℝ))]
      _ = 1 := h_sum_one
  -- Now: (1/m) ∑ π² - 1/m² ≤ (1/m) · 1 - 1/m² = (m-1)/m².
  have hm_inv_nn : 0 ≤ 1 / m := by positivity
  have hstep :
      (1 / m) * ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2
        ≤ (1 / m) * 1 :=
    mul_le_mul_of_nonneg_left h_sum_sq_le_one hm_inv_nn
  have h_eq : (1 / m) * 1 - 1 / m^2 = (m - 1) / m^2 := by
    field_simp
  linarith [h_eq]

/-- **Bracket: `0 ≤ Var_π ≤ (m-1)/m²`.** -/
theorem Var_pi_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ Var_pi d P
      ∧ Var_pi d P ≤ ((P.parts.card : ℝ) - 1) / (P.parts.card : ℝ)^2 :=
  ⟨Var_pi_nonneg d P, Var_pi_le_bhatia_davis d P hP⟩

end Agent3_PiVariance

end MIP
