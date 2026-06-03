/-
  STATUS: DISCOVERY
  AGENT: 7
  DIRECTION: Forward-only phase movement structure — what A.1+A.2 say about phase changes.
  SUMMARY:
    Even without a knowledge-growth axiom, A.1 + A.2 force a STRUCTURAL
    coupling between consecutive phases. We prove:
      (1) Once in Phase III at any index, the trajectory's Phi0 is zero
          at that index (A.1).
      (2) Whenever the trajectory has N finite at some index, coverage
          exists at THAT index (A.2) — pointwise indexed.
      (3) Phase II → Phase III transitions: if at step t we're in Phase II
          and at step t+1 we're in Phase III, then Phi0 strictly decreased
          (from nonzero to zero).
      (4) Phase III → Phase I transitions are formally possible only if
          K shrinks (`K (Xs (t+1)) ⊉ R'` for every demand R').
    The third item is a genuine constraint linking value transitions to
    Phi0-behaviour. The fourth is a structural necessary condition.
-/
import MIP.Axioms

namespace MIP

namespace Agent7_PhaseChain

variable {α : Type}

/-! ## (1) Phase III implies Phi0=0 (indexed A.1). -/

/-- **Indexed A.1**: at any step where `N = 0`, also `Phi0 = 0`. -/
theorem Phi0_zero_at_solved
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : N p (Xs t) = 0) :
    Phi0 (Xs t) p = 0 :=
  (Axioms.A1 p (Xs t)).mp h

/-! ## (2) Finite-N implies coverage (indexed A.2). -/

/-- **Indexed A.2**: at any step where `N` is finite, coverage holds. -/
theorem coverage_at_finite
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : N p (Xs t) ≠ ⊤) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω) :=
  (Axioms.A2 (Ω := Ω) p (Xs t)).mp h

/-! ## (3) Step-wise Phase II → Phase III: Phi0 dropped to zero. -/

/-- **Phase II → Phase III transition forces Phi0 drop**: if at step `t`
    we have `0 < N < ⊤` (Phase II) and at step `t+1` we have `N = 0`
    (Phase III), then `Phi0 (Xs t) p ≠ 0` while `Phi0 (Xs (t+1)) p = 0`.
    This is the cleanest "trajectory transition forces Phi0 change"
    constraint derivable from A.1 alone. -/
theorem phaseII_to_phaseIII_forces_Phi0_drop
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (hII : 0 < N p (Xs t) ∧ N p (Xs t) < ⊤)
    (hIII : N p (Xs (t + 1)) = 0) :
    Phi0 (Xs t) p ≠ 0 ∧ Phi0 (Xs (t + 1)) p = 0 := by
  refine ⟨?_, (Axioms.A1 p (Xs (t + 1))).mp hIII⟩
  intro hPhi
  -- Phi0 = 0 → N = 0 by A.1, contradicting 0 < N
  have hN0 : N p (Xs t) = 0 := (Axioms.A1 p (Xs t)).mpr hPhi
  rw [hN0] at hII
  exact absurd hII.1 (by decide)

/-! ## (4) Step-wise Phase I → Phase II/III: coverage acquired. -/

/-- **Phase I → Phase II/III transition requires acquiring coverage**:
    if at step `t` we have `N = ⊤` and at step `t+1` we have `N ≠ ⊤`,
    then at step `t+1` some demand is covered (by A.2). And at step `t`,
    no demand is covered (contrapositive of A.2). -/
theorem phaseI_to_nonI_acquires_coverage
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (hI : N p (Xs t) = ⊤)
    (hExit : N p (Xs (t + 1)) ≠ ⊤) :
    (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K (Xs t) : Set Ω))
      ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs (t + 1)) : Set Ω)) := by
  refine ⟨?_, (Axioms.A2 (Ω := Ω) p (Xs (t + 1))).mp hExit⟩
  intro R' hR' hSub
  have hNeTop : N p (Xs t) ≠ ⊤ := (Axioms.A2 (Ω := Ω) p (Xs t)).mpr ⟨R', hR', hSub⟩
  exact hNeTop hI

/-! ## (5) Phase III → Phase I requires coverage loss. -/

/-- **Phase III → Phase I requires losing coverage**: if at step `t`
    we have `N = 0` (Phase III) and at step `t+1` we have `N = ⊤`
    (Phase I), then at step `t`, coverage exists (A.2 via A.1), but at
    step `t+1`, no demand is covered (contrapositive of A.2). This is
    the formal "backsliding requires K-shrinkage" statement. -/
theorem phaseIII_to_phaseI_requires_K_loss
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (hIII : N p (Xs t) = 0)
    (hI : N p (Xs (t + 1)) = ⊤) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))
      ∧ (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K (Xs (t + 1)) : Set Ω)) := by
  refine ⟨?_, ?_⟩
  · -- Coverage at solved step via N=0 → N≠⊤ → A.2
    apply (Axioms.A2 (Ω := Ω) p (Xs t)).mp
    rw [hIII]; decide
  · intro R' hR' hSub
    have : N p (Xs (t + 1)) ≠ ⊤ :=
      (Axioms.A2 (Ω := Ω) p (Xs (t + 1))).mpr ⟨R', hR', hSub⟩
    exact this hI

/-! ## (6) Conservation: once Phi0 stays zero, N stays zero. -/

/-- **Phi0-zero conservation forces N-zero conservation**: if a window
    `t₀ ≤ t ≤ t₁` has Phi0 zero at every step, then N is zero at every
    step in the same window. -/
theorem N_zero_window_of_Phi0_zero_window
    (Xs : ℕ → Agent α) (p : Problem α) (t₀ t₁ : ℕ)
    (hPhi : ∀ t, t₀ ≤ t → t ≤ t₁ → Phi0 (Xs t) p = 0) :
    ∀ t, t₀ ≤ t → t ≤ t₁ → N p (Xs t) = 0 := by
  intro t hLo hHi
  exact (Axioms.A1 p (Xs t)).mpr (hPhi t hLo hHi)

/-- **N-zero conservation forces Phi0-zero conservation** (the converse). -/
theorem Phi0_zero_window_of_N_zero_window
    (Xs : ℕ → Agent α) (p : Problem α) (t₀ t₁ : ℕ)
    (hN : ∀ t, t₀ ≤ t → t ≤ t₁ → N p (Xs t) = 0) :
    ∀ t, t₀ ≤ t → t ≤ t₁ → Phi0 (Xs t) p = 0 := by
  intro t hLo hHi
  exact (Axioms.A1 p (Xs t)).mp (hN t hLo hHi)

end Agent7_PhaseChain

end MIP
