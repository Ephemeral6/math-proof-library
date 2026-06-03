/-
  STATUS: DISCOVERY
  AGENT: 10
  DIRECTION: Group H.12 — Inverse Boltzmann correspondence: every
              activation distribution is a Boltzmann distribution
              with energy `E(ω) := -log (p ω)`, temperature `T = 1`,
              partition function `Z = 1`.
  SUMMARY:
    T.35 (`MIP/Theorems/T35_PartitionFunction.lean`) builds the partition
    function in the forward direction (Z = Σ exp(-Φ)). The information-
    theoretic dual is the *inverse* direction: given any normalised
    distribution `d`, we can manufacture a Boltzmann-form representation

        d.p ω = exp(-E(ω)) / Z,
        E(ω) := -log ((d.p ω : ℝ)),
        Z    := 1,

    that recovers `d` exactly on its support.  The construction is
    tautological — it says nothing physical about the energy levels —
    but it is the formal bridge that lets every probabilistic statement
    about `d` be re-read as a statement about a (degenerate) Gibbs
    ensemble.  This is the "free-energy bridge" alluded to in the
    Theorem T.31 commentary.

    Two formulations:

      • `boltzmann_inverse_at_support`     — pointwise on the support,
                                            `d.p ω = exp(-E(ω))`.
      • `boltzmann_inverse_partition`     — the corresponding partition
                                            function is `Z = 1`
                                            (i.e. `∑ exp(-E ω) = 1`)
                                            on the support of `d`.

    Off-support points (`d.p ω = 0`) get `E(ω) = -log 0 = 0` in Lean's
    convention, and `exp 0 = 1 ≠ 0`, so we cannot recover the mass
    pointwise without a support hypothesis. Hence the statements are
    parametrised by `Finset.filter (d.p ω > 0)`.

    The "free energy at thermal equilibrium" identity `F = E - T·H`
    reduces to a trivial rearrangement in this gauge; we record it as
    `boltzmann_free_energy_at_T1`.
-/
import MIP.Defs.Knowledge

namespace MIP

namespace Agent10

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- **Inverse Boltzmann energy** assigned to a distribution.

`boltzmannEnergy d ω := -log ((d.p ω : ℝ))`.

By Lean's `Real.log 0 = 0` convention, `boltzmannEnergy d ω = 0` at
off-support points; on the support we recover `d.p ω = exp(-E(ω))`.
This is the gauge with `T = 1, Z = 1`. -/
noncomputable def boltzmannEnergy (d : ActivationDist Ω) (ω : Ω) : ℝ :=
  -Real.log ((d.p ω : ℝ))

/-- **HEADLINE (Group H.12).** On the support of `d`, every
mass is recovered as `exp(-E(ω))` with `E := boltzmannEnergy d`.

This is the "every distribution is Boltzmann" identity in the gauge
`T = 1, Z = 1`.  No physical content — it is the algebraic dual of the
forward partition-function construction in T.35. -/
theorem boltzmann_inverse_at_support
    (d : ActivationDist Ω) {ω : Ω} (h_pos : 0 < (d.p ω : ℝ)) :
    (d.p ω : ℝ) = Real.exp (-(boltzmannEnergy d ω)) := by
  unfold boltzmannEnergy
  rw [neg_neg]
  exact (Real.exp_log h_pos).symm

/-- **Partition function = 1 on the support.**

When we restrict the sum to the support `supp d := {ω : d.p ω > 0}`,
the inverse-Boltzmann sum `∑ exp(-E(ω)) = ∑ p(ω) = 1`.  The choice
`Z = 1` is therefore consistent with normalisation. -/
theorem boltzmann_inverse_partition_support
    [DecidableEq Ω] (d : ActivationDist Ω) :
    ∑ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => 0 < (d.p ω : ℝ)),
        Real.exp (-(boltzmannEnergy d ω)) = 1 := by
  -- On the support, exp(-E ω) = d.p ω; on the off-support both `d.p ω = 0`
  -- and the term contributes 0 to ∑ d.p ω. So the support-restricted
  -- exp-sum equals the full ∑ d.p ω = 1.
  have h_each : ∀ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => 0 < (d.p ω : ℝ)),
      Real.exp (-(boltzmannEnergy d ω)) = (d.p ω : ℝ) := by
    intro ω hω
    have h_pos : 0 < (d.p ω : ℝ) := (Finset.mem_filter.mp hω).2
    exact (boltzmann_inverse_at_support d h_pos).symm
  rw [Finset.sum_congr rfl h_each]
  -- ∑ (over support) (d.p ω : ℝ) = ∑ (over univ) (d.p ω : ℝ) since
  -- off-support contributes 0.
  have h_off : ∀ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => ¬ (0 < (d.p ω : ℝ))),
      (d.p ω : ℝ) = 0 := by
    intro ω hω
    have hnpos : ¬ (0 < (d.p ω : ℝ)) := (Finset.mem_filter.mp hω).2
    have h_nonneg : 0 ≤ (d.p ω : ℝ) := (d.p ω).coe_nonneg
    linarith
  have h_split :
      ∑ ω, (d.p ω : ℝ)
        = (∑ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => 0 < (d.p ω : ℝ)),
            (d.p ω : ℝ))
          + ∑ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => ¬ (0 < (d.p ω : ℝ))),
              (d.p ω : ℝ) := by
    rw [Finset.sum_filter_add_sum_filter_not]
  have h_off_sum :
      ∑ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => ¬ (0 < (d.p ω : ℝ))),
          (d.p ω : ℝ) = 0 := by
    apply Finset.sum_eq_zero
    intro ω hω
    exact h_off ω hω
  rw [h_off_sum, add_zero] at h_split
  rw [← h_split]
  -- ∑ ω, (d.p ω : ℝ) = 1 by normalisation.
  have : ((∑ ω, d.p ω : NNReal) : ℝ) = ∑ ω, (d.p ω : ℝ) := by
    push_cast; rfl
  rw [← this, d.normalized]; simp

/-- **Free energy at `T = 1` in the inverse-Boltzmann gauge.**

In thermodynamics, `F = E - T·H` (Helmholtz free energy).  Under the
inverse-Boltzmann gauge `T = 1, Z = 1`, the *expected energy* is

  ⟨E⟩  =  ∑ p(ω) · E(ω)
        =  -∑ p(ω) · log p(ω)
        =  H_K(d),

so `F = ⟨E⟩ - 1 · H_K(d) = 0`.  The free energy of a distribution in
its own self-induced ensemble is identically zero.  This is the
"inverse free-energy bridge" — it certifies that no thermodynamic
information is generated by writing `d` as its own Gibbs ensemble. -/
theorem boltzmann_free_energy_at_T1 (d : ActivationDist Ω) :
    (∑ ω, (d.p ω : ℝ) * boltzmannEnergy d ω) - knowledgeEntropy d = 0 := by
  unfold boltzmannEnergy knowledgeEntropy
  -- ⟨E⟩ = ∑ p · (-log p) = -∑ p · log p; H_K = -∑ p · log p; so ⟨E⟩ - H_K = 0.
  have h_avg :
      ∑ ω, (d.p ω : ℝ) * (-(Real.log ((d.p ω : ℝ))))
        = -∑ ω, (d.p ω : ℝ) * Real.log ((d.p ω : ℝ)) := by
    rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro ω _; ring
  rw [h_avg]
  ring

end Agent10

end MIP
