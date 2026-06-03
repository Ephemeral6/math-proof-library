/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Tier A — Bounds on Σ π_i² ("collision probability").
  SUMMARY:
    For a normalised distribution and a SubdomainPartition with `m := parts.card`
    parts, the sum of squares of the subdomain masses satisfies:
      1/m  ≤  Σ_i π_i²  ≤  1
    Upper bound: each π_i ≤ 1 (Agent3_PiMassBounds), so π_i² ≤ π_i, so Σπ_i² ≤ Σπ_i = 1.
    Lower bound (Cauchy-Schwarz): (Σ π_i)² ≤ m · Σ π_i² ⟹ 1 ≤ m · Σ π_i².

    Equality on the right ⟺ vertex (one part has all the mass).
    Equality on the left ⟺ uniform (all parts have mass 1/m).

    Σ π_i² is the "collision probability" / Renyi-2 entropy exp(-H_2(π)).
    This is the partition-level analogue of `inner_mul_le_norm_mul_norm`,
    not stated in any existing R-SUB file.
-/
import MIP.Theorems.T18_10_Conservation
import Mathlib.Algebra.Order.Chebyshev

namespace MIP

namespace Agent3_PiSqBounds

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- Inlined helper: `π_S ≤ 1` (proof of the upper unit-interval bound). -/
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

/-- **A.5 (algebraic kernel) — ∑ π_i² ≤ 1.**

If `f : ι → ℝ` is nonneg, pointwise ≤ 1, and `∑ f i = 1`, then `∑ (f i)² ≤ 1`.

Proof: each `(f i)² ≤ f i` (since `0 ≤ f i ≤ 1`), so `∑ (f i)² ≤ ∑ f i = 1`. -/
theorem sum_sq_le_one_of_sum_one
    {ι : Type*} (s : Finset ι) (f : ι → ℝ)
    (h_nonneg : ∀ i ∈ s, 0 ≤ f i)
    (h_le_one : ∀ i ∈ s, f i ≤ 1)
    (h_sum : ∑ i ∈ s, f i = 1) :
    ∑ i ∈ s, (f i)^2 ≤ 1 := by
  calc ∑ i ∈ s, (f i)^2
      ≤ ∑ i ∈ s, f i := by
        apply Finset.sum_le_sum
        intro i hi
        -- (f i)² ≤ f i since f i ∈ [0,1].
        have h0 := h_nonneg i hi
        have h1 := h_le_one i hi
        nlinarith [sq_nonneg (f i)]
    _ = 1 := h_sum

/-- **A.6 (algebraic kernel) — Σ f_i² ≥ 1/n  (Cauchy-Schwarz).**

If `s : Finset ι` is nonempty and `∑_{i ∈ s} f i = 1`, then
`(1)² = (∑ f_i)² ≤ s.card · ∑ f_i²`, i.e. `Σ f_i² ≥ 1 / s.card`.

This is the Cauchy-Schwarz inequality applied to (f_i, 1). -/
theorem inv_card_le_sum_sq
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (f : ι → ℝ)
    (h_sum : ∑ i ∈ s, f i = 1) :
    (1 : ℝ) / s.card ≤ ∑ i ∈ s, (f i)^2 := by
  have h_card_pos : (0 : ℝ) < s.card := by
    exact_mod_cast Finset.card_pos.mpr hs
  -- Cauchy-Schwarz / Chebyshev: (∑ f_i)² ≤ s.card · ∑ f_i².
  have h_cs : (∑ i ∈ s, f i)^2 ≤ s.card * ∑ i ∈ s, (f i)^2 :=
    sq_sum_le_card_mul_sum_sq
  -- LHS = 1² = 1.
  rw [h_sum] at h_cs
  simp at h_cs
  -- 1 ≤ s.card · ∑ f_i²  ⟹  1 / s.card ≤ ∑ f_i².
  rw [div_le_iff₀ h_card_pos]
  linarith

/-- **A.5 — Σ π_i² ≤ 1 (packaged form).**

For any normalised activation distribution and any `SubdomainPartition`,
`Σ_S π_S² ≤ 1`. -/
theorem sum_pi_sq_le_one
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 ≤ 1 := by
  -- Pointwise: each π_S ∈ [0,1] (Agent3_PiMassBounds).
  have h_nonneg :
      ∀ S ∈ P.parts, (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
    fun S _ => NNReal.coe_nonneg _
  have h_le_one :
      ∀ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 := by
    intro S hS
    have h := pi_le_one_aux d P hS
    exact_mod_cast h
  -- Sum conservation.
  have h_sum_nnreal :
      ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
    T18_10_conservation_packaged d P
  have h_sum :
      ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) h_sum_nnreal
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  exact sum_sq_le_one_of_sum_one P.parts
    (fun S => ((P.subdomainMass d S : NNReal) : ℝ))
    h_nonneg h_le_one h_sum

/-- **A.6 — Σ π_S² ≥ 1/m (packaged form, Cauchy-Schwarz).**

For a nonempty `SubdomainPartition` with `m := P.parts.card`,
`Σ_S π_S² ≥ 1/m`.  Equality iff `π_S = 1/m` for all `S`. -/
theorem sum_pi_sq_ge_inv_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (1 : ℝ) / P.parts.card
      ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 := by
  have h_sum_nnreal :
      ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
    T18_10_conservation_packaged d P
  have h_sum :
      ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
    have := congrArg (fun x : NNReal => (x : ℝ)) h_sum_nnreal
    simpa [NNReal.coe_sum, NNReal.coe_one] using this
  exact inv_card_le_sum_sq P.parts hP
    (fun S => ((P.subdomainMass d S : NNReal) : ℝ)) h_sum

/-- **Bracketing form: `1/m ≤ Σ π_S² ≤ 1`.** Both inequalities packaged
together. -/
theorem sum_pi_sq_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    (1 : ℝ) / P.parts.card
        ≤ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2
      ∧ ∑ S ∈ P.parts, (((P.subdomainMass d S : NNReal) : ℝ))^2 ≤ 1 :=
  ⟨sum_pi_sq_ge_inv_card d P hP, sum_pi_sq_le_one d P⟩

end Agent3_PiSqBounds

end MIP
