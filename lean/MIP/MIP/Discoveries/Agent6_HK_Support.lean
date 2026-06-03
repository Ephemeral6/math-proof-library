/-
  STATUS: DISCOVERY
  AGENT: 6
  DIRECTION: Group 3 — support-restricted entropy and the `H_K = H_supp`
             equivalence; sharper bound `H_supp ≤ log |supp|`.
  SUMMARY:
    `H_supp d K := -∑_{ω ∈ K} (d.p ω) · log (d.p ω)`.  Outside the actual
    support `supp d := {ω : d.p ω ≠ 0}`, every summand `-p log p` is `0`
    (`Real.negMulLog 0 = 0`).  Hence:

      (i)  `knowledgeEntropy d = H_supp d (supp d)`     (support equivalence).
      (ii) `H_supp d (supp d) ≤ Real.log (supp d).card` (sharper than
           Group 2's `log |Ω|` bound — uses the *actual* support size).

    Both are clean consequences once we have the support `Finset`.
    The sharper bound proof: restrict the masses to the support, view them
    as a probability vector on `supp d`, and apply Jensen there.

    This is genuinely sharper than the Group 2 bound when `d.p` has
    support strictly smaller than `Ω` (the natural-language D.3.3 K(X)
    "support of p_X" interpretation).
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Conjectures.CjNEW13_HpiMaxAtTStar

namespace MIP

namespace Agent6

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- The (Finset) support of an activation distribution. -/
noncomputable def supp (d : ActivationDist Ω) : Finset Ω :=
  (Finset.univ : Finset Ω).filter (fun ω => d.p ω ≠ 0)

/-- Support-restricted Shannon entropy:
`H_supp d K := -∑_{ω ∈ K} (d.p ω) · log (d.p ω)`. -/
noncomputable def H_supp (d : ActivationDist Ω) (K : Finset Ω) : ℝ :=
  -∑ ω ∈ K, (d.p ω : ℝ) * Real.log ((d.p ω : ℝ))

/-- `H_supp` rewritten via `negMulLog`. -/
lemma H_supp_eq_sum_negMulLog (d : ActivationDist Ω) (K : Finset Ω) :
    H_supp d K = ∑ ω ∈ K, Real.negMulLog ((d.p ω : ℝ)) := by
  unfold H_supp
  rw [← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro ω _
  rw [Real.negMulLog]
  ring

/-- **DISCOVERY (Group 3.6, support equivalence).**

The full Shannon entropy equals the support-restricted sum:

    `knowledgeEntropy d = H_supp d (supp d)`.

Outside the support every summand is `negMulLog 0 = 0`. -/
theorem knowledgeEntropy_eq_H_supp_supp (d : ActivationDist Ω) :
    knowledgeEntropy d = H_supp d (supp d) := by
  rw [knowledgeEntropy_eq_sum_negMulLog, H_supp_eq_sum_negMulLog]
  -- ∑_univ = ∑_supp + ∑_¬supp, and ∑_¬supp = 0.
  rw [← Finset.sum_filter_add_sum_filter_not (s := (Finset.univ : Finset Ω))
        (p := fun ω => d.p ω ≠ 0)]
  have h_out :
      ∑ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => ¬ d.p ω ≠ 0),
        Real.negMulLog ((d.p ω : ℝ)) = 0 := by
    apply Finset.sum_eq_zero
    intro ω hω
    have hp0 : d.p ω = 0 := by
      have := (Finset.mem_filter.mp hω).2
      push_neg at this
      exact this
    rw [hp0]; simp [Real.negMulLog]
  unfold supp
  rw [h_out, add_zero]

/-- The support masses are nonneg in `ℝ`. -/
lemma supp_pR_nonneg (d : ActivationDist Ω) (ω : Ω) (_h : ω ∈ supp d) :
    0 ≤ (d.p ω : ℝ) := (d.p ω).coe_nonneg

/-- The masses summed over the support add to `1` (because outside the
support every mass is `0`). -/
lemma supp_pR_sum (d : ActivationDist Ω) :
    ∑ ω ∈ supp d, (d.p ω : ℝ) = 1 := by
  have h_split :
      ∑ ω, (d.p ω : ℝ)
        = (∑ ω ∈ supp d, (d.p ω : ℝ)) +
          ∑ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => ¬ d.p ω ≠ 0),
            (d.p ω : ℝ) := by
    unfold supp
    rw [← Finset.sum_filter_add_sum_filter_not (s := (Finset.univ : Finset Ω))
        (p := fun ω => d.p ω ≠ 0)]
  have h_out :
      ∑ ω ∈ (Finset.univ : Finset Ω).filter (fun ω => ¬ d.p ω ≠ 0),
        (d.p ω : ℝ) = 0 := by
    apply Finset.sum_eq_zero
    intro ω hω
    have hp0 : d.p ω = 0 := by
      have := (Finset.mem_filter.mp hω).2
      push_neg at this
      exact this
    rw [hp0]; simp
  have h_total : (∑ ω, (d.p ω : ℝ)) = 1 := by
    have h : ((∑ ω, d.p ω : NNReal) : ℝ) = ∑ ω, (d.p ω : ℝ) := by
      push_cast; rfl
    rw [← h, d.normalized]; simp
  linarith [h_split, h_out, h_total]

/-- The support is nonempty whenever the distribution is normalised. -/
lemma supp_nonempty (d : ActivationDist Ω) : (supp d).Nonempty := by
  by_contra h
  rw [Finset.not_nonempty_iff_eq_empty] at h
  have hsum : ∑ ω ∈ supp d, (d.p ω : ℝ) = 1 := supp_pR_sum d
  rw [h, Finset.sum_empty] at hsum
  exact absurd hsum (by norm_num)

/-! ### Sharper max-entropy bound on the actual support. -/

/-- **HEADLINE DISCOVERY (Group 3.5).** Sharper max-entropy bound on the
actual support of `d`:

    `H_supp d (supp d) ≤ Real.log (supp d).card`.

This is sharper than the Group 2 bound `H_K d ≤ log (Fintype.card Ω)`
whenever `(supp d).card < Fintype.card Ω`.

Proof: re-index the masses by the support `Finset` (as a type via the
coe-to-sort), apply `CjNEW13_entropy_le_log` there. -/
theorem H_supp_supp_le_log_card (d : ActivationDist Ω) :
    H_supp d (supp d) ≤ Real.log ((supp d).card : ℝ) := by
  classical
  -- Re-index: define a probability vector on the subtype `{ω // ω ∈ supp d}`.
  set S := supp d with hS
  have hS_ne : S.Nonempty := supp_nonempty d
  letI : Nonempty {x // x ∈ S} := hS_ne.to_subtype
  -- The probability vector `q : S → ℝ` is `fun ⟨ω, _⟩ => (d.p ω : ℝ)`.
  set q : {x // x ∈ S} → ℝ := fun ω => (d.p ω.val : ℝ) with hq
  have hq_nonneg : ∀ ω, 0 ≤ q ω := fun ω => (d.p ω.val).coe_nonneg
  have hq_sum : ∑ ω, q ω = 1 := by
    -- ∑_{ω : S} q ω = ∑_{ω ∈ S} d.p ω (= 1).
    rw [hq]
    have h : ∑ ω : {x // x ∈ S}, (d.p ω.val : ℝ) = ∑ ω ∈ S, (d.p ω : ℝ) := by
      exact Finset.sum_coe_sort (s := S) (fun ω => (d.p ω : ℝ))
    rw [h]
    rw [hS]
    exact supp_pR_sum d
  have hcard_eq : (Fintype.card {x // x ∈ S} : ℝ) = (S.card : ℝ) := by
    push_cast
    rw [Fintype.card_coe]
  -- Apply Jensen on the subtype.
  have jensen := CjNEW13.CjNEW13_entropy_le_log q hq_nonneg hq_sum
  -- Convert `Hpi q` to `H_supp d S` via `sum_attach`.
  have hHpi :
      CjNEW13.Hpi q = H_supp d S := by
    unfold CjNEW13.Hpi
    rw [H_supp_eq_sum_negMulLog]
    rw [hq]
    -- ∑_{ω : S} negMulLog (d.p ω.val) = ∑_{ω ∈ S} negMulLog (d.p ω).
    exact Finset.sum_coe_sort (s := S) (fun ω => Real.negMulLog ((d.p ω : ℝ)))
  rw [hHpi] at jensen
  rw [hcard_eq] at jensen
  exact jensen

/-- **Composite (DISCOVERY).** The original `knowledgeEntropy` is
bounded by `log (supp d).card` — the *actual-support* entropy bound:

    `knowledgeEntropy d ≤ Real.log (supp d).card`.

Sharper than Group 2 when `(supp d).card < Fintype.card Ω`. -/
theorem H_K_le_log_supp_card (d : ActivationDist Ω) :
    knowledgeEntropy d ≤ Real.log ((supp d).card : ℝ) := by
  rw [knowledgeEntropy_eq_H_supp_supp]
  exact H_supp_supp_le_log_card d

end Agent6

end MIP
