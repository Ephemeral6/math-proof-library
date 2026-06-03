/-
  STATUS: DISCOVERY
  AGENT: 7
  DIRECTION: Trajectory in barrier space — B_data card sequence and Phase III tightening.
  SUMMARY:
    Combining Agent 4's unconditional cardinality `(B_data p X).card =
    (N p X).toNat` with a training trajectory, the sequence
    `t ↦ (B_data p (Xs t)).card` is a non-negative-integer sequence
    completely determined by `t ↦ N p (Xs t)`. We also tighten Agent 2's
    `B_data_boundary` observation that `B_data = ∅` doesn't distinguish
    N=0 from N=⊤: at any trajectory index, the conjunction
    `B_data p (Xs t) = ∅ ∧ Phi0 (Xs t) p = 0` characterises exactly
    Phase III (solved). The "Phi0 = 0" tag is the missing piece that
    cardinality alone cannot provide.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent7_BarrierTrajectory

variable {α : Type}

/-! ## (1) The barrier-card sequence equals the N.toNat sequence. -/

/-- **Barrier card sequence equals N.toNat sequence.** Pointwise version
    of Agent 4's unconditional cardinality, lifted to the trajectory. -/
theorem barrierCard_eq_NtoNat
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    (B_data p (Xs t)).card = (N p (Xs t)).toNat := by
  unfold B_data
  rw [Finset.card_image_of_injective _ (b_synth_injective (Xs t) p)]
  exact Finset.card_range _

/-- **Sequence-level identity**: the two sequences are equal as functions. -/
theorem barrierCard_seq_eq
    (Xs : ℕ → Agent α) (p : Problem α) :
    (fun t => (B_data p (Xs t)).card) = (fun t => (N p (Xs t)).toNat) := by
  funext t
  exact barrierCard_eq_NtoNat Xs p t

/-! ## (2) Non-negativity (trivial — but document for completeness). -/

/-- **Non-negativity** of the barrier-card sequence (trivial, but
    documenting the structural fact that the trajectory lives in ℕ). -/
theorem barrierCard_nonneg
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    0 ≤ (B_data p (Xs t)).card :=
  Nat.zero_le _

/-! ## (3) Empty barrier set at a trajectory index. -/

/-- **B_data is empty at index t iff `N p (Xs t).toNat = 0`.** -/
theorem barrier_empty_iff_toNat_zero
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    B_data p (Xs t) = ∅ ↔ (N p (Xs t)).toNat = 0 := by
  rw [← Finset.card_eq_zero, barrierCard_eq_NtoNat]

/-- **N=0 at index t forces empty barrier set.** -/
theorem barrier_empty_of_N_zero
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : N p (Xs t) = 0) :
    B_data p (Xs t) = ∅ := by
  rw [barrier_empty_iff_toNat_zero, h]
  rfl

/-- **N=⊤ at index t forces empty barrier set** (concrete-model
    truncation artefact). -/
theorem barrier_empty_of_N_top
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : N p (Xs t) = ⊤) :
    B_data p (Xs t) = ∅ := by
  rw [barrier_empty_iff_toNat_zero, h]
  rfl

/-! ## (4) Phase III tightening: empty B_data + Phi0=0 iff N=0. -/

/-- **TIGHTENING DISCOVERY (Group G item 12)**: At any trajectory index,
    "solved" (`N = 0`) is equivalent to the conjunction
    `B_data = ∅ ∧ Phi0 = 0`. Agent 2 noted that `B_data = ∅` alone is
    ambiguous (covers both N=0 and N=⊤); A.1 gives the missing tag. -/
theorem solved_iff_empty_barrier_and_Phi0_zero
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    N p (Xs t) = 0 ↔ (B_data p (Xs t) = ∅ ∧ Phi0 (Xs t) p = 0) := by
  constructor
  · intro hN
    refine ⟨barrier_empty_of_N_zero Xs p hN, (Axioms.A1 p (Xs t)).mp hN⟩
  · rintro ⟨_, hPhi⟩
    exact (Axioms.A1 p (Xs t)).mpr hPhi

/-! ## (5) Trajectory-wide form. -/

/-- **Trajectory-wide solved characterisation**: the set of indices where
    `N p (Xs t) = 0` equals the set of indices where both
    `B_data p (Xs t) = ∅` and `Phi0 (Xs t) p = 0`. -/
theorem solvedIndices_eq_emptyBarrier_and_phi0Zero
    (Xs : ℕ → Agent α) (p : Problem α) :
    { t | N p (Xs t) = 0 }
      = { t | B_data p (Xs t) = ∅ ∧ Phi0 (Xs t) p = 0 } := by
  ext t
  exact solved_iff_empty_barrier_and_Phi0_zero Xs p t

/-! ## (6) Phase II (emergent) iff positive card. -/

/-- **Phase II via barrier cardinality**: at index t, the trajectory is in
    Phase II (0 < N < ⊤) iff `(B_data p (Xs t)).card ≥ 1`. -/
theorem phaseII_iff_barrier_card_pos
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    (0 < N p (Xs t) ∧ N p (Xs t) < ⊤)
      ↔ 1 ≤ (B_data p (Xs t)).card := by
  rw [barrierCard_eq_NtoNat]
  constructor
  · rintro ⟨hPos, hLtTop⟩
    have hNeTop : N p (Xs t) ≠ ⊤ := ne_of_lt hLtTop
    have hNeZero : N p (Xs t) ≠ 0 := ne_of_gt hPos
    -- (N p (Xs t)).toNat > 0 from N ≠ 0 and N ≠ ⊤
    have hCoe : ((N p (Xs t)).toNat : ℕ∞) = N p (Xs t) := ENat.coe_toNat hNeTop
    have hToNatNeZero : (N p (Xs t)).toNat ≠ 0 := by
      intro h0
      rw [h0, Nat.cast_zero] at hCoe
      exact hNeZero hCoe.symm
    omega
  · intro hCard
    -- (N p (Xs t)).toNat ≥ 1 means it's a positive nat — N is finite and positive
    have hNeZero : (N p (Xs t)).toNat ≠ 0 := by omega
    -- So N ≠ ⊤ (because (⊤ : ℕ∞).toNat = 0)
    have hNeTop : N p (Xs t) ≠ ⊤ := by
      intro hTop
      rw [hTop] at hNeZero
      exact hNeZero rfl
    refine ⟨?_, lt_top_iff_ne_top.mpr hNeTop⟩
    -- 0 < N from .toNat > 0 and N ≠ ⊤
    have hCoe : ((N p (Xs t)).toNat : ℕ∞) = N p (Xs t) := ENat.coe_toNat hNeTop
    have hPosN : (0 : ℕ∞) < ((N p (Xs t)).toNat : ℕ∞) := by
      have : (0 : ℕ) < (N p (Xs t)).toNat := by omega
      exact_mod_cast this
    rw [hCoe] at hPosN
    exact hPosN

end Agent7_BarrierTrajectory

end MIP
