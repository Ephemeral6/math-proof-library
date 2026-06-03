/-
  STATUS: DISCOVERY
  AGENT: 7
  DIRECTION: Trajectory-indexed reformulation of A.1 — solved indices = Phi0-zero indices.
  SUMMARY:
    Along a training trajectory `Xs : ℕ → Agent α`, the set of "solved
    indices" `{t | N p (Xs t) = 0}` coincides exactly with the set of
    `Phi0`-zero indices `{t | Phi0 (Xs t) p = 0}`. This is the
    trajectory-indexed reformulation of A.1, never previously stated.
    We give: (a) the pointwise equivalence at each index `t`, (b) the
    Set-level equality of the two index sets, and (c) the "ever-solved
    iff ever-Phi0-zero" existential form.
-/
import MIP.Axioms

namespace MIP

namespace Agent7_SolvedIndices

variable {α : Type}

/-! ## (1) Pointwise: at any index, N=0 iff Phi0=0. -/

/-- **Indexed A.1**: at any training step `t`, `N p (Xs t) = 0 ↔ Phi0 (Xs t) p = 0`. -/
theorem indexed_A1
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    N p (Xs t) = 0 ↔ Phi0 (Xs t) p = 0 :=
  Axioms.A1 p (Xs t)

/-- **At a solved index**, Phi0 vanishes. -/
theorem Phi0_zero_of_N_zero_at_index
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : N p (Xs t) = 0) :
    Phi0 (Xs t) p = 0 :=
  (Axioms.A1 p (Xs t)).mp h

/-- **At a Phi0-zero index**, N vanishes. -/
theorem N_zero_of_Phi0_zero_at_index
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : Phi0 (Xs t) p = 0) :
    N p (Xs t) = 0 :=
  (Axioms.A1 p (Xs t)).mpr h

/-! ## (2) Set-level: the solved and Phi0-zero index sets coincide. -/

/-- The set of solved indices. -/
def solvedIndices (Xs : ℕ → Agent α) (p : Problem α) : Set ℕ :=
  { t | N p (Xs t) = 0 }

/-- The set of Phi0-zero indices. -/
def phi0ZeroIndices (Xs : ℕ → Agent α) (p : Problem α) : Set ℕ :=
  { t | Phi0 (Xs t) p = 0 }

/-- **HEADLINE**: the solved-index set equals the Phi0-zero-index set. -/
theorem solvedIndices_eq_phi0ZeroIndices
    (Xs : ℕ → Agent α) (p : Problem α) :
    solvedIndices Xs p = phi0ZeroIndices Xs p := by
  ext t
  exact indexed_A1 Xs p t

/-! ## (3) Existential / universal forms. -/

/-- **Ever-solved iff ever-Phi0-zero**. -/
theorem ever_solved_iff_ever_phi0_zero
    (Xs : ℕ → Agent α) (p : Problem α) :
    (∃ t, N p (Xs t) = 0) ↔ (∃ t, Phi0 (Xs t) p = 0) := by
  constructor
  · rintro ⟨t, ht⟩
    exact ⟨t, (Axioms.A1 p (Xs t)).mp ht⟩
  · rintro ⟨t, ht⟩
    exact ⟨t, (Axioms.A1 p (Xs t)).mpr ht⟩

/-- **Never-solved iff never-Phi0-zero** (contrapositive). -/
theorem never_solved_iff_never_phi0_zero
    (Xs : ℕ → Agent α) (p : Problem α) :
    (∀ t, N p (Xs t) ≠ 0) ↔ (∀ t, Phi0 (Xs t) p ≠ 0) := by
  constructor
  · intro h t hPhi
    exact h t ((Axioms.A1 p (Xs t)).mpr hPhi)
  · intro h t hN
    exact h t ((Axioms.A1 p (Xs t)).mp hN)

/-! ## (4) Coverage at every finite-N index (via A.2). -/

/-- **At any finite-N index, coverage holds.** Indexed reformulation of A.2. -/
theorem coverage_at_finite_index
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : N p (Xs t) ≠ ⊤) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω) :=
  (Axioms.A2 (Ω := Ω) p (Xs t)).mp h

/-- **At any solved index, coverage holds.** Combining A.1 and A.2. -/
theorem coverage_at_solved_index
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : N p (Xs t) = 0) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω) := by
  apply coverage_at_finite_index (Ω := Ω) Xs p
  rw [h]; decide

end Agent7_SolvedIndices

end MIP
