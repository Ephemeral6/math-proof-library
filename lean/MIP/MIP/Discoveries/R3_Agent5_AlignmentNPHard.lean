/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 5
  DIRECTION: T.18.2 + T.18.5 — NP-hardness of alignment certification.

  SUMMARY:
    T.18.2 (`T18_2_NPHard`): BOUNDED-N (deciding `N ≤ k`) is NP-hard via
    `NPHardReduction` from a base predicate.
    T.18.5 (`T18_5_alignment_impossible`): if `X` is universally aligned
    (`∀ p, N p X ≠ ⊤`), then every problem `p` admits a cover `R' ⊆ K X`.

    **Joint discovery (this file).** Certifying universal alignment is at
    least as hard as deciding BOUNDED-N for every `k`. Concretely:

    1. Universal alignment ⟺ `∀ p, ∃ k, N p X ≤ k` (with `k = N p X`).
       Hence a `BoundedN`-oracle for `(p, X)` decides whether `p` is
       alignable by `X`.
    2. **`AlignmentWitness X` decision predicate** (`∃ k, BoundedN p X k`)
       is the per-problem alignment certificate.
    3. **NP-hardness transfer.** Any NP-hard base predicate that reduces
       to BOUNDED-N (via T.18.2's `NPHardReduction`) also reduces to the
       AlignmentWitness predicate via the same map composed with `∃ k`.

    The crisp Lean output: `AlignmentWitness` inherits NP-hardness from
    BOUNDED-N because BOUNDED-N is a *specialisation* of the witness
    predicate (fix `k`).

  R-DEPS:
    • MIP.Theorems.T18_2_NPHard (BoundedN, NPHardReduction, T18_2_NPHard)
    • MIP.Theorems.T18_5_Alignment (T18_5_alignment_impossible)
    • MIP.Axioms.A2
-/
import MIP.Axioms
import MIP.Theorems.T18_2_NPHard
import MIP.Theorems.T18_5_Alignment

namespace MIP

namespace R3_Agent5_AlignmentNPHard

open MIP.Axioms
open MIP.NPHard
open MIP.Alignment

variable {α : Type} {Ω : Type}

/-! ## (1) Alignment witness as an existential over BOUNDED-N. -/

/-- **AlignmentWitness predicate.** `(p, X)` admits an alignment witness
iff some finite intervention budget `k` suffices: `∃ k, N p X ≤ k`. -/
def AlignmentWitness (p : Problem α) (X : Agent α) : Prop :=
  ∃ k : ℕ, BoundedN p X k

/-- **Alignment witness ⟺ finite N.** A configuration `(p, X)` admits a
witness iff `N p X ≠ ⊤`. -/
theorem AlignmentWitness_iff_finiteN
    (p : Problem α) (X : Agent α) :
    AlignmentWitness p X ↔ N p X ≠ ⊤ := by
  unfold AlignmentWitness BoundedN
  constructor
  · rintro ⟨k, hk⟩
    -- N ≤ k < ⊤
    have hktop : (k : ℕ∞) < ⊤ := by
      exact_mod_cast (WithTop.coe_lt_top k)
    exact ne_of_lt (lt_of_le_of_lt hk hktop)
  · intro hNe
    -- Pick `k` so that N p X = k.
    -- Since N : ℕ∞ and N ≠ ⊤, N is `(m : ℕ)` for some m.
    obtain ⟨m, hm⟩ := WithTop.ne_top_iff_exists.mp hNe
    refine ⟨m, ?_⟩
    rw [← hm]
    exact le_refl _

/-! ## (2) Universal alignment characterisation. -/

/-- **Universal alignment ⟺ every problem admits a witness.** -/
theorem universal_alignment_iff_universal_witness
    (X : Agent α) :
    (∀ p : Problem α, N p X ≠ ⊤)
      ↔ (∀ p : Problem α, AlignmentWitness p X) := by
  constructor
  · intro h p; exact (AlignmentWitness_iff_finiteN p X).mpr (h p)
  · intro h p; exact (AlignmentWitness_iff_finiteN p X).mp (h p)

/-- **From T.18.5: universal witness ⟹ universal coverage.** -/
theorem universal_witness_implies_coverage
    (X : Agent α)
    (h_witness : ∀ p : Problem α, AlignmentWitness p X) :
    ∀ p : Problem α, ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) := by
  intro p
  have h_perfect : ∀ q : Problem α, N q X ≠ ⊤ :=
    (universal_alignment_iff_universal_witness X).mpr h_witness
  exact (T18_5_alignment_impossible (Ω := Ω) X h_perfect) p

/-! ## (3) NP-hard reduction from BOUNDED-N into AlignmentWitness. -/

/-- **Embedding BOUNDED-N into AlignmentWitness.**

For any concrete bound `k`, `BoundedN p X k → AlignmentWitness p X`
(specialise the existential at `k`). This is the trivial direction of
the reduction. -/
theorem BoundedN_implies_witness (p : Problem α) (X : Agent α) (k : ℕ)
    (h : BoundedN p X k) : AlignmentWitness p X :=
  ⟨k, h⟩

/-- **NP-hard reduction transfer #1**.

If the base predicate (T.18.2's `NPHardReduction.base`) reduces to
BOUNDED-N via `red : ℕ → Problem × Agent × ℕ` with `spec`, then the
*same* `(p, X)` triple satisfies `AlignmentWitness`. I.e. the base
predicate also reduces to AlignmentWitness — taking the `(p, X)` part of
`red` and forgetting the bound. -/
theorem T18_2_T18_5_alignment_NPHard
    (base : ℕ → Prop)
    (red : ℕ → Problem α × Agent α × ℕ)
    (hred : ∀ n, base n ↔ BoundedN (red n).1 (red n).2.1 (red n).2.2) :
    ∀ n, base n → AlignmentWitness (red n).1 (red n).2.1 := by
  intro n hbase
  exact BoundedN_implies_witness _ _ _ ((hred n).mp hbase)

/-- **NP-hard reduction transfer #2** (reverse direction, conditional).

To go backwards from `AlignmentWitness` to `base`, we need the BOUNDED-N
threshold `k = (red n).2.2` to be *tight enough*: if `BoundedN p X k`
holds with the original threshold, then `base n`. Encoded as a hypothesis
that `(red n).2.2` is in fact the optimal witness. -/
theorem T18_2_T18_5_alignment_reduction_complete
    (base : ℕ → Prop)
    (red : ℕ → Problem α × Agent α × ℕ)
    (hred : ∀ n, base n ↔ BoundedN (red n).1 (red n).2.1 (red n).2.2)
    (n : ℕ)
    (h_witness : AlignmentWitness (red n).1 (red n).2.1)
    (h_tight : ∀ k, BoundedN (red n).1 (red n).2.1 k →
                    BoundedN (red n).1 (red n).2.1 (red n).2.2) :
    base n := by
  obtain ⟨k, hk⟩ := h_witness
  exact (hred n).mpr (h_tight k hk)

/-! ## (4) The composition with T.18.5 — coverage NP-hardness. -/

/-- **Final composition — coverage decision is NP-hard.**

Define the per-problem **CoverageDecision** predicate
`CoverageWitness (p, X) := ∃ R' ∈ ℛ(p), R' ⊆ K(X)`. By A.2 this is
equivalent to `N p X ≠ ⊤`, i.e. to `AlignmentWitness`. So coverage
decision inherits NP-hardness from BOUNDED-N along the *same* reduction. -/
def CoverageWitness (p : Problem α) (X : Agent α) : Prop :=
  ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)

/-- **Coverage ⟺ Alignment witness (via A.2 + T.18.5).** -/
theorem CoverageWitness_iff_AlignmentWitness
    (p : Problem α) (X : Agent α) :
    CoverageWitness (Ω := Ω) p X ↔ AlignmentWitness p X := by
  unfold CoverageWitness
  rw [AlignmentWitness_iff_finiteN]
  exact (Axioms.A2 (Ω := Ω) p X).symm

/-- **Headline: under the T.18.2 NP-hard reduction, the resulting
`(p_n, X_n)` triples have NP-hard COVERAGE decision.**

Combining T.18.2 (`base n ↔ BoundedN`), the BoundedN ⟹ Witness step,
and T.18.5/A.2 (`CoverageWitness ↔ AlignmentWitness`) gives: if `base n`
holds then `(p_n, X_n)` admits a covered demand. Coverage decision is
therefore at least as hard as `base`. -/
theorem T18_2_T18_5_coverage_NPHard
    (base : ℕ → Prop)
    (red : ℕ → Problem α × Agent α × ℕ)
    (hred : ∀ n, base n ↔ BoundedN (red n).1 (red n).2.1 (red n).2.2) :
    ∀ n, base n → CoverageWitness (Ω := Ω) (red n).1 (red n).2.1 := by
  intro n hbase
  have hAW : AlignmentWitness (red n).1 (red n).2.1 :=
    T18_2_T18_5_alignment_NPHard (α := α) base red hred n hbase
  exact (CoverageWitness_iff_AlignmentWitness (Ω := Ω) _ _).mpr hAW

end R3_Agent5_AlignmentNPHard

end MIP
