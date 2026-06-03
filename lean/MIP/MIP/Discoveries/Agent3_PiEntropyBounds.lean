/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Tier B — Partition-mass entropy bounds (subdomain dispersion).
  SUMMARY:
    The Shannon entropy of the subdomain-mass vector
      H_π(d, P) := -∑_{S ∈ P.parts} ((π_S : ℝ)) · log ((π_S : ℝ))
    satisfies:
      Tier B.7   0 ≤ H_π                          (nonnegativity)
      Tier B.8   H_π ≤ log m   (m := |parts|)    (max entropy = uniform)

    The bound H ≤ log m is the *static geometric core* of CjNEW13's
    headline conjecture, but CjNEW13 only proves it abstractly for
    `q : ι → ℝ`. We *specialise* it to a SubdomainPartition, plugging in
    the actual subdomain masses via the conservation law. The nonneg
    bound is novel as a packaged statement.

    Plus: entropy-zero vertex characterisation (Tier B.10).
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Conjectures.CjNEW13_HpiMaxAtTStar
import MIP.Results.RSUB8_EntropyExtremum

namespace MIP

namespace Agent3_PiEntropyBounds

open scoped BigOperators
open Real

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Partition-mass entropy.**

`H_π(d, P) := -∑_{S ∈ P.parts} (π_S : ℝ) · log (π_S : ℝ)`,

with `π_S := P.subdomainMass d S`.  The Shannon entropy of the coarse-
grained subdomain-mass vector. -/
noncomputable def Hpi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  -∑ S ∈ P.parts,
    ((P.subdomainMass d S : NNReal) : ℝ)
      * Real.log ((P.subdomainMass d S : NNReal) : ℝ)

/-- Inlined helper from `Agent3_PiSqBounds`: π_S ≤ 1. -/
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

/-- **B.7 — Partition-mass entropy is nonneg.**

`0 ≤ H_π(d, P)`.

Proof: each term `π_S · log π_S ≤ 0` since `0 ≤ π_S ≤ 1` (Result R-SUB.8
`x_log_x_nonpos`), so the negation `-Σ ≥ 0`. -/
theorem Hpi_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    0 ≤ Hpi d P := by
  unfold Hpi
  have h_each : ∀ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ)
        * Real.log ((P.subdomainMass d S : NNReal) : ℝ) ≤ 0 := by
    intro S hS
    have h0 : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
      NNReal.coe_nonneg _
    have h1 : ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 := by
      have := pi_le_one_aux d P hS
      exact_mod_cast this
    exact MIP.EntropyExtremum.x_log_x_nonpos _ h0 h1
  have h_sum_nonpos :
      ∑ S ∈ P.parts,
          ((P.subdomainMass d S : NNReal) : ℝ)
            * Real.log ((P.subdomainMass d S : NNReal) : ℝ) ≤ 0 :=
    Finset.sum_nonpos h_each
  linarith

/-- **B.8 — Partition-mass entropy is bounded by `log m`.**

For a nonempty `SubdomainPartition` with `m := P.parts.card`,
`H_π(d, P) ≤ log m`.

Proof: apply `CjNEW13_entropy_le_log` to the partition's index Finset,
viewed as a Fintype with the canonical projection. The mass values
satisfy `0 ≤ π_S` and `∑ π_S = 1`. -/
theorem Hpi_le_log_card
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    Hpi d P ≤ Real.log (P.parts.card : ℝ) := by
  -- Use `Finset.sum_attach` to convert ∑ over P.parts to ∑ over its
  -- Fintype-attach.
  -- Let ι := { S // S ∈ P.parts } (a Fintype), q : ι → ℝ : (S, _) ↦ π_S.
  classical
  -- Build the abstract uniform-bound: apply CjNEW13_entropy_le_log to
  -- the subtype.
  -- Step 1: define π_S as a function on the attached subtype.
  set ι := { S // S ∈ P.parts } with hι_def
  haveI : Fintype ι := Finset.Subtype.fintype _
  -- Card of ι equals card of P.parts.
  have h_card : Fintype.card ι = P.parts.card := by
    simp [ι, Fintype.card_coe]
  -- Nonemptyness:
  haveI : Nonempty ι := by
    obtain ⟨S, hS⟩ := hP
    exact ⟨⟨S, hS⟩⟩
  -- The mass function on ι.
  let q : ι → ℝ := fun s => ((P.subdomainMass d s.val : NNReal) : ℝ)
  have h_nonneg : ∀ s, 0 ≤ q s := fun s => NNReal.coe_nonneg _
  -- Sum of q over Finset.univ = sum of π over P.parts = 1.
  have h_sum_one : ∑ s, q s = 1 := by
    have hpacked := T18_10_conservation_packaged d P
    have hpacked_real :
        ∑ S ∈ P.parts, ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
      have := congrArg (fun x : NNReal => (x : ℝ)) hpacked
      simpa [NNReal.coe_sum, NNReal.coe_one] using this
    -- Fintype-univ-sum over { S // S ∈ P.parts } = attach-sum.
    have h_univ_eq_attach :
        (Finset.univ : Finset ι) = P.parts.attach := by
      ext x
      simp [ι]
    show ∑ s : ι, ((P.subdomainMass d s.val : NNReal) : ℝ) = 1
    rw [h_univ_eq_attach]
    rw [P.parts.sum_attach
      (f := fun S => ((P.subdomainMass d S : NNReal) : ℝ))]
    exact hpacked_real
  -- Apply CjNEW13.
  have hjensen :=
    MIP.CjNEW13.CjNEW13_entropy_le_log (ι := ι) q h_nonneg h_sum_one
  -- hjensen : Hpi q ≤ Real.log (Fintype.card ι) ≤ Real.log (P.parts.card).
  rw [h_card] at hjensen
  -- Now relate Hpi q to our Hpi d P.
  -- MIP.CjNEW13.Hpi q = ∑ s, negMulLog (q s) = -∑ s, q s · log (q s).
  rw [MIP.CjNEW13.Hpi_eq q] at hjensen
  -- ∑ s, q s · log (q s) = ∑ S ∈ P.parts, π_S · log π_S (via attach).
  have h_sum_eq :
      ∑ s : ι, q s * Real.log (q s)
        = ∑ S ∈ P.parts,
            ((P.subdomainMass d S : NNReal) : ℝ)
              * Real.log ((P.subdomainMass d S : NNReal) : ℝ) := by
    have h_univ_eq_attach :
        (Finset.univ : Finset ι) = P.parts.attach := by
      ext x
      simp [ι]
    show ∑ s : ι,
          ((P.subdomainMass d s.val : NNReal) : ℝ)
            * Real.log ((P.subdomainMass d s.val : NNReal) : ℝ)
        = _
    rw [h_univ_eq_attach]
    rw [P.parts.sum_attach
      (f := fun S => ((P.subdomainMass d S : NNReal) : ℝ)
        * Real.log ((P.subdomainMass d S : NNReal) : ℝ))]
  rw [h_sum_eq] at hjensen
  -- hjensen : -∑ ... ≤ log card.
  exact hjensen

/-- **Bracket: `0 ≤ H_π ≤ log m`.** -/
theorem Hpi_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ Hpi d P ∧ Hpi d P ≤ Real.log (P.parts.card : ℝ) :=
  ⟨Hpi_nonneg d P, Hpi_le_log_card d P hP⟩

/-- **B.10 — Entropy zero ⟺ vertex (point-mass partition).**

`H_π(d, P) = 0` iff every part either has all the mass (`π_S = 1`) or
none (`π_S = 0`). Combined with conservation `Σ π_S = 1`, this forces
*exactly one* part to have mass 1 and all others mass 0.

We use the per-term form of R-SUB.8. -/
theorem Hpi_zero_iff_vertex
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    Hpi d P = 0 ↔
      ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 0
        ∨ ((P.subdomainMass d S : NNReal) : ℝ) = 1 := by
  unfold Hpi
  constructor
  · intro h_neg_sum
    -- -∑ = 0 ⟹ ∑ = 0.
    have h_sum_zero :
        ∑ S ∈ P.parts,
            ((P.subdomainMass d S : NNReal) : ℝ)
              * Real.log ((P.subdomainMass d S : NNReal) : ℝ) = 0 := by
      linarith
    intro S hS
    -- Each term is nonpos; if any term is < 0, the whole sum is < 0,
    -- contradiction. So each term is = 0.
    have h_each_nonpos : ∀ T ∈ P.parts,
        ((P.subdomainMass d T : NNReal) : ℝ)
          * Real.log ((P.subdomainMass d T : NNReal) : ℝ) ≤ 0 := by
      intro T hT
      have h0 : (0 : ℝ) ≤ ((P.subdomainMass d T : NNReal) : ℝ) :=
        NNReal.coe_nonneg _
      have h1 : ((P.subdomainMass d T : NNReal) : ℝ) ≤ 1 := by
        have := pi_le_one_aux d P hT
        exact_mod_cast this
      exact MIP.EntropyExtremum.x_log_x_nonpos _ h0 h1
    have h_term_zero :
        ((P.subdomainMass d S : NNReal) : ℝ)
          * Real.log ((P.subdomainMass d S : NNReal) : ℝ) = 0 := by
      by_contra h_ne
      have h_strict :
          ((P.subdomainMass d S : NNReal) : ℝ)
            * Real.log ((P.subdomainMass d S : NNReal) : ℝ) < 0 :=
        lt_of_le_of_ne (h_each_nonpos S hS) h_ne
      have h_others_nonpos :
          ∑ T ∈ P.parts.erase S,
              ((P.subdomainMass d T : NNReal) : ℝ)
                * Real.log ((P.subdomainMass d T : NNReal) : ℝ) ≤ 0 :=
        Finset.sum_nonpos
          (fun T hT => h_each_nonpos T (Finset.mem_of_mem_erase hT))
      have h_split :
          ∑ T ∈ P.parts,
              ((P.subdomainMass d T : NNReal) : ℝ)
                * Real.log ((P.subdomainMass d T : NNReal) : ℝ)
          = ((P.subdomainMass d S : NNReal) : ℝ)
              * Real.log ((P.subdomainMass d S : NNReal) : ℝ)
            + ∑ T ∈ P.parts.erase S,
                ((P.subdomainMass d T : NNReal) : ℝ)
                  * Real.log ((P.subdomainMass d T : NNReal) : ℝ) := by
        rw [← Finset.add_sum_erase _ _ hS]
      linarith
    have h0 : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
      NNReal.coe_nonneg _
    have h1 : ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 := by
      have := pi_le_one_aux d P hS
      exact_mod_cast this
    exact (MIP.EntropyExtremum.x_log_x_zero_iff _ h0 h1).mp h_term_zero
  · intro h_vertex
    -- Each term is zero, so the sum is zero, so -sum is zero.
    have h_sum_zero :
        ∑ S ∈ P.parts,
            ((P.subdomainMass d S : NNReal) : ℝ)
              * Real.log ((P.subdomainMass d S : NNReal) : ℝ) = 0 := by
      apply Finset.sum_eq_zero
      intro S hS
      have h0 : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
        NNReal.coe_nonneg _
      have h1 : ((P.subdomainMass d S : NNReal) : ℝ) ≤ 1 := by
        have := pi_le_one_aux d P hS
        exact_mod_cast this
      exact (MIP.EntropyExtremum.x_log_x_zero_iff _ h0 h1).mpr (h_vertex S hS)
    rw [h_sum_zero]; ring

end Agent3_PiEntropyBounds

end MIP
