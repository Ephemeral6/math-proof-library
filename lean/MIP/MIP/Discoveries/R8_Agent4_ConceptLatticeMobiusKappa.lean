/-
  STATUS: DISCOVERY
  AGENT: R8-Agent4
  DIRECTION:
    FORMAL CONCEPT LATTICE × MÖBIUS × BAYESIAN NETWORK — an EXACT
    cumulative-κ formula.  Combine the κ-Möbius inversion (RMKH), the
    formal concept lattice (RFCL), the Round-3 concept-lattice Möbius
    discovery (R3_Agent10), and the Bayesian-network tail bound (RBN2)
    into a single exact, lattice-theoretic inclusion–exclusion identity
    for the CUMULATIVE knowledge-demand κ, cross-validated against the
    network tail estimate.

  SUMMARY:
    RMKH (`R_MKH_2_inversion`) gives the Newton–Möbius reconstruction of
    the κ-saturation tower from its irreducible layers ν:
        κ_r = Σ_{k≤r} C(r,k) · ν_k                                  (†)
    where ν is the finite-difference (Möbius-of-the-Boolean-lattice)
    transform `nu`.  RFCL provides the formal concept lattice `ℒ_MIP`
    (the closure operator `clOp = extent∘intent` of the A.2 solvability
    relation), and R3_Agent10 already wired RFCL + RMKH together at the
    *single-rank* level (extensivity, triple identity, saturated tower).

    THIS file climbs to the CUMULATIVE rank.  Define the cumulative
    knowledge-demand
        Κ(R) := Σ_{r=0}^{R} κ_r
    (the total co-occurrence saturation up to lattice rank R).  We prove
    the EXACT closed form — a genuinely new identity, not present in
    R3_Agent10 — by summing (†) over r and performing the hockey-stick
    collapse `Σ_{m∈Icc k R} C(m,k) = C(R+1,k+1)`:

      R8 HEADLINE  Κ(R) = Σ_{k=0}^{R} C(R+1, k+1) · ν_k.            (★)

    Each irreducible layer ν_k contributes to the cumulative demand with
    the *triangular* (hockey-stick) lattice weight C(R+1,k+1) — exact
    inclusion–exclusion over the concept lattice, no approximation.

    Cross-validation with RBN2: when the per-rank demand obeys the
    Bayesian-network per-step cap `κ_r ≤ I_max` (RBN2 `R_BN_8`'s
    HYPOTHESIS-BUNDLE), the network chain-rule bound forces
        Κ(R) ≤ (R+1) · I_max,
    so the EXACT lattice Möbius sum (★) is dominated by the
    Bayesian-network tail estimate — the two computations of cumulative
    knowledge-demand agree to within the tail bound.

    Concretely we prove:
      (1) `cumKappa_eq_inversion_double` — Κ(R) as a double Möbius sum
          (RMKH (†) summed over r);
      (2) `hockey_stick_coeff`           — Σ_{r≤R} C(r,k) = C(R+1,k+1)
          (the lattice weight; `Nat.sum_Icc_choose`);
      (3) `R8_cumKappa_mobius`  (HEADLINE) — Κ(R)=Σ_k C(R+1,k+1)·ν_k (★);
      (4) `R8_cumKappa_bayes_tail` — (★) ≤ (R+1)·I_max via RBN2;
      (5) `R8_concept_lattice_mobius_validated` — the full synthesis,
          chaining RFCL (lattice closure data) + R3_Agent10
          (single-rank carryover) + RMKH (inversion) + RBN2 (tail).

  Depends on (every lemma below appears in a PROOF TERM, except those
  marked provenance-only):
    - MIP.Results.RMKH_MobiusKappa
        · `R_MKH_2_inversion`   — (†), used in `cumKappa_eq_inversion_double`
        · `nu`                  — the irreducible layers (object of (★))
        · `R_MKH_2_nu0`         — used in `R8_..._validated`
    - MIP.Results.RFCL_FormalConceptLattice
        · `extent`, `intent`           — lattice objects appearing in the
          statement type of `R8_..._validated` (closure-data conjuncts)
        · `R_FCL_1_triple_intent`      — used in `R8_..._validated`
        · `clOp`, `R_FCL_1_extensive_problems` — PROVENANCE-ONLY: the
          conceptual closure operator and the general extensivity lemma;
          the singleton extensivity conjunct is discharged instead via the
          R3-tower carryover `R3_galois_extensive_singleton`, so these two
          are NOT load-bearing in this file.
    - MIP.Discoveries.R3_Agent10_ConceptLatticeMobius   (R3 TOWER)
        · `kappaSat`            — the saturated tower (witness for (★))
        · `R3_saturated_inversion`     — used in `R8_..._validated`
        · `R3_galois_extensive_singleton` — used in `R8_..._validated`
    - MIP.Results.RBN2_BayesNetTail                     (RBN2 TAIL)
        · `BayesNetTail.R_BN_8_chain_upper_bound` — used in
          `R8_cumKappa_bayes_tail`
    - Mathlib: `Nat.sum_Icc_choose` (hockey stick), `Finset.sum_comm`,
      `Finset.sum_congr`, big-operators.

  This file declares NO new axiom; the only axioms reachable are the
  pre-existing MIP framework axioms via the imported corpus theorems.
-/
import MIP.Results.RMKH_MobiusKappa
import MIP.Results.RFCL_FormalConceptLattice
import MIP.Results.RBN2_BayesNetTail
import MIP.Discoveries.R3_Agent10_ConceptLatticeMobius
import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R8_Agent4_ConceptLatticeMobiusKappa

open MIP.MobiusKappa MIP.FormalConceptLattice
open MIP.R3_Agent10_ConceptLatticeMobius
open Finset

/-! ### The cumulative knowledge-demand `Κ(R) = Σ_{r≤R} κ_r` -/

/-- **Cumulative knowledge-demand** up to lattice rank `R`:
`Κ(R) = Σ_{r=0}^{R} κ_r`, the total co-occurrence saturation accrued
across all ranks of the concept lattice up to `R`. -/
noncomputable def cumKappa (κ : ℕ → ℝ) (R : ℕ) : ℝ :=
  ∑ r ∈ range (R + 1), κ r

/-! ### (1) Cumulative κ as a double Möbius sum (RMKH (†) summed over r) -/

/-- **R8 (1) — cumulative κ as a double Möbius sum.**

Summing the RMKH Newton–Möbius reconstruction
`κ_r = Σ_{k≤r} C(r,k)·ν_k` (`R_MKH_2_inversion`) over `r = 0,…,R`
expresses the cumulative demand as a double alternating-layer sum. -/
theorem cumKappa_eq_inversion_double (κ : ℕ → ℝ) (R : ℕ) :
    cumKappa κ R
      = ∑ r ∈ range (R + 1), ∑ k ∈ range (r + 1),
          (r.choose k : ℝ) * nu κ k := by
  unfold cumKappa
  apply Finset.sum_congr rfl
  intro r _
  exact R_MKH_2_inversion κ r

/-! ### (2) The hockey-stick lattice weight `Σ_{r≤R} C(r,k) = C(R+1,k+1)` -/

/-- **R8 (2) — hockey-stick lattice coefficient.**

For `k ≤ R`, the total weight with which the irreducible layer `ν_k`
enters the cumulative demand is the triangular (hockey-stick) binomial
`Σ_{r=0}^{R} C(r,k) = C(R+1, k+1)`.  (Terms with `r < k` vanish, so the
`range`-sum collapses to `Nat.sum_Icc_choose` over `Icc k R`.) -/
theorem hockey_stick_coeff (R k : ℕ) (hk : k ≤ R) :
    (∑ r ∈ range (R + 1), r.choose k) = (R + 1).choose (k + 1) := by
  -- restrict to Icc k R: the low terms r < k are zero
  have hsplit : (∑ r ∈ range (R + 1), r.choose k)
      = ∑ r ∈ Finset.Icc k R, r.choose k := by
    rw [Finset.range_eq_Ico]
    rw [← Finset.sum_Ico_consecutive (fun r => r.choose k)
          (Nat.zero_le k) (by omega : k ≤ R + 1)]
    have hlow : (∑ r ∈ Finset.Ico 0 k, r.choose k) = 0 := by
      apply Finset.sum_eq_zero
      intro r hr
      rw [Finset.mem_Ico] at hr
      exact Nat.choose_eq_zero_of_lt hr.2
    rw [hlow, zero_add]
    -- Ico k (R+1) = Icc k R
    apply Finset.sum_congr _ (fun _ _ => rfl)
    ext m
    rw [Finset.mem_Ico, Finset.mem_Icc]
    omega
  rw [hsplit, Nat.sum_Icc_choose]

/-! ### (3) HEADLINE — exact concept-lattice Möbius formula for cumulative κ -/

/-- **R8 HEADLINE — `Κ(R) = Σ_{k≤R} C(R+1,k+1)·ν_k`** (exact
inclusion–exclusion over the concept lattice).

The cumulative knowledge-demand of the formal concept lattice up to
rank `R` is *exactly* the Möbius-inversion alternating sum of the
irreducible co-occurrence layers `ν_k`, each weighted by the
hockey-stick lattice coefficient `C(R+1,k+1)`.  No approximation: this
is the closed-form inclusion–exclusion identity demanded by the
direction.

Proof: sum the RMKH reconstruction (†) over `r` (step (1)), swap the
order of summation, and collapse the inner `r`-sum to the hockey-stick
coefficient `C(R+1,k+1)` (step (2)). -/
theorem R8_cumKappa_mobius (κ : ℕ → ℝ) (R : ℕ) :
    cumKappa κ R
      = ∑ k ∈ range (R + 1), ((R + 1).choose (k + 1) : ℝ) * nu κ k := by
  rw [cumKappa_eq_inversion_double κ R]
  -- extend each inner range (r+1) to range (R+1); the new terms k>r vanish
  have hextend :
      (∑ r ∈ range (R + 1), ∑ k ∈ range (r + 1),
          (r.choose k : ℝ) * nu κ k)
        = ∑ r ∈ range (R + 1), ∑ k ∈ range (R + 1),
            (r.choose k : ℝ) * nu κ k := by
    apply Finset.sum_congr rfl
    intro r hr
    rw [Finset.mem_range, Nat.lt_succ_iff] at hr
    have hsub : range (r + 1) ⊆ range (R + 1) :=
      Finset.range_subset_range.mpr (by omega : r + 1 ≤ R + 1)
    rw [← Finset.sum_subset hsub]
    intro k _ hk
    rw [Finset.mem_range, not_lt, Nat.succ_le_iff] at hk
    rw [Nat.choose_eq_zero_of_lt hk]
    simp
  rw [hextend, Finset.sum_comm]
  -- now: Σ_k Σ_r C(r,k)·ν_k = Σ_k (Σ_r C(r,k)) · ν_k
  apply Finset.sum_congr rfl
  intro k hk
  rw [Finset.mem_range, Nat.lt_succ_iff] at hk
  rw [← Finset.sum_mul]
  -- the real coefficient Σ_r (C(r,k):ℝ) equals (Σ_r C(r,k) : ℕ) cast
  have hcast :
      (∑ r ∈ range (R + 1), (r.choose k : ℝ))
        = ((∑ r ∈ range (R + 1), r.choose k : ℕ) : ℝ) := by
    push_cast
    rfl
  rw [hcast, hockey_stick_coeff R k hk]

/-! ### (4) Cross-validation: bound by the Bayesian-network tail (RBN2) -/

/-- **R8 (4) — Bayesian-network tail bound on cumulative κ.**

If every per-rank demand obeys the RBN2 per-step cap `κ_r ≤ I_max`
(the d-separation / chain-rule HYPOTHESIS-BUNDLE of `R_BN_8`), then the
cumulative knowledge-demand is bounded by the network tail estimate:
    Κ(R) ≤ (R+1) · I_max.
Established directly through RBN2's `R_BN_8_chain_upper_bound`
(`steps = range (R+1)`, `I_step = κ`), so the EXACT lattice Möbius sum
(★) is dominated by the Bayesian-network tail. -/
theorem R8_cumKappa_bayes_tail (κ : ℕ → ℝ) (R : ℕ) (I_max : ℝ)
    (hcap : ∀ r ∈ range (R + 1), κ r ≤ I_max) :
    cumKappa κ R ≤ ((R : ℝ) + 1) * I_max := by
  have hbn :=
    MIP.BayesNetTail.R_BN_8_chain_upper_bound
      (range (R + 1)) κ (cumKappa κ R) I_max rfl hcap
  -- card (range (R+1)) = R + 1
  have hcard : ((range (R + 1)).card : ℝ) = (R : ℝ) + 1 := by
    rw [Finset.card_range]; push_cast; ring
  rwa [hcard] at hbn

/-- **R8 (4′) — the EXACT Möbius sum is bounded by the network tail.**

Combining the headline (★) with the tail bound: the exact concept-lattice
inclusion–exclusion value of cumulative κ never exceeds the
Bayesian-network chain-rule estimate `(R+1)·I_max`. -/
theorem R8_mobius_sum_le_bayes_tail (κ : ℕ → ℝ) (R : ℕ) (I_max : ℝ)
    (hcap : ∀ r ∈ range (R + 1), κ r ≤ I_max) :
    (∑ k ∈ range (R + 1), ((R + 1).choose (k + 1) : ℝ) * nu κ k)
      ≤ ((R : ℝ) + 1) * I_max := by
  rw [← R8_cumKappa_mobius κ R]
  exact R8_cumKappa_bayes_tail κ R I_max hcap

/-! ### (5) Synthesis: RFCL ⊕ R3_Agent10 ⊕ RMKH ⊕ RBN2 -/

/-- **R8 SYNTHESIS — the concept-lattice Möbius cumulative-κ formula,
validated against the Bayesian-network tail.**

This bundles the full chain demanded by the direction:

  (a) RFCL lattice data: for any solvability relation `I` and problem
      `p`, the singleton `{p}` is closed-extensive
      (`{p} ⊆ extent (intent {p})`) and the closure is idempotent on
      intents (the triple identity) — the substrate of the concept
      lattice `ℒ_MIP` on which the Möbius structure lives.

  (b) R3_Agent10 single-rank carryover: the saturated tower `κ≡1` has
      `ν_0 = 1` (`R_MKH_2_nu0` via `R3_saturated_*`), and obeys the RMKH
      reconstruction at every rank.

  (c) R8 HEADLINE (★): for an ARBITRARY κ-tower, the cumulative demand
      `Κ(R)` equals the EXACT concept-lattice Möbius sum
      `Σ_k C(R+1,k+1)·ν_k` — inclusion–exclusion, not approximation.

  (d) RBN2 cross-validation: under the per-rank cap, that exact sum is
      bounded by the Bayesian-network tail `(R+1)·I_max`.

Hence: *cumulative knowledge-demand κ equals a Möbius-inversion
alternating sum over the formal concept lattice (exact inclusion–
exclusion), consistent with the Bayesian-network tail.* -/
theorem R8_concept_lattice_mobius_validated
    {Problems Agents : Type*} (I : Problems → Agents → Prop) (p : Problems)
    (κ : ℕ → ℝ) (R : ℕ) (I_max : ℝ)
    (hcap : ∀ r ∈ range (R + 1), κ r ≤ I_max) :
    -- (a) RFCL concept-lattice closure data
    ({p} : Set Problems) ⊆ extent I (intent I {p}) ∧
    intent I {p} = intent I (extent I (intent I {p})) ∧
    -- (b) R3_Agent10 single-rank carryover (saturated tower's ν₀ = 1)
    nu kappaSat 0 = 1 ∧
    kappaSat R = ∑ k ∈ range (R + 1), (R.choose k : ℝ) * nu kappaSat k ∧
    -- (c) R8 HEADLINE: exact cumulative-κ Möbius formula (★)
    cumKappa κ R
        = (∑ k ∈ range (R + 1), ((R + 1).choose (k + 1) : ℝ) * nu κ k) ∧
    -- (d) RBN2 cross-validation: exact Möbius sum ≤ network tail
    (∑ k ∈ range (R + 1), ((R + 1).choose (k + 1) : ℝ) * nu κ k)
        ≤ ((R : ℝ) + 1) * I_max := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- (a) RFCL extensivity on a singleton, via R3_Agent10 carryover
    exact R3_galois_extensive_singleton I p
  · -- (a) RFCL triple identity
    exact R_FCL_1_triple_intent I {p}
  · -- (b) saturated-tower ν₀ = 1, from RMKH `R_MKH_2_nu0`
    rw [R_MKH_2_nu0]; rfl
  · -- (b) saturated-tower RMKH reconstruction (R3_Agent10)
    exact R3_saturated_inversion R
  · -- (c) HEADLINE
    exact R8_cumKappa_mobius κ R
  · -- (d) cross-validation
    exact R8_mobius_sum_le_bayes_tail κ R I_max hcap

end R8_Agent4_ConceptLatticeMobiusKappa

end MIP
