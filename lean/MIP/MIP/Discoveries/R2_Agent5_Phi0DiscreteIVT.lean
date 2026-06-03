/-
  STATUS: DISCOVERY
  AGENT: R2-5
  DIRECTION: Discrete intermediate-value-style uniqueness for the Φ₀ phase
             transition along a training trajectory.
  SUMMARY:
    Round-1 Agent 7 gave a `Nat.find` packaging of the first solved /
    finite-N step.  The next natural question (Round 2): given that Φ₀
    transitions from nonzero to zero (or vice versa) between two indices
    `t ≤ t'`, can we always locate a *single* adjacent step where the
    change happens?  This is the discrete analogue of the intermediate-
    value theorem applied to the Prop-valued sequence
        `b t := Phi0 (Xs t) p = 0`.
    We prove the two crossing-step witnesses:
      (a) If `Phi0 (Xs t) p = 0` and `Phi0 (Xs t') p ≠ 0` with `t < t'`,
          there exists `s` with `t ≤ s < t'`,
          `Phi0 (Xs s) p = 0` and `Phi0 (Xs (s+1)) p ≠ 0`
          ("first nonzero step after a zero step");
      (b) Symmetric: from `≠ 0` to `= 0`, there exists a unique adjacent
          drop `Phi0 (Xs s) p ≠ 0`, `Phi0 (Xs (s+1)) p = 0`.
    By A.1 the same statements transfer verbatim to `N`.  Contrapositive:
    if Φ₀ never changes status across any adjacent step in `[t, t']`,
    then the phase is the same at every point of the interval.  These
    are honest derivable facts about ANY function ℕ → Prop combined with
    A.1 — no monotonicity is assumed or claimed.
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent5_Phi0DiscreteIVT

variable {α : Type}

/-! ## (1) Generic discrete IVT for Prop-valued sequences.

We work with `b : ℕ → Prop` and prove the crossing-step lemma.  Then
we instantiate at `b t := Phi0 (Xs t) p = 0`. -/

/-- **Discrete IVT, generic form.** If `b t` and `¬ b t'` and `t < t'`,
    there exists `s` with `t ≤ s < t'`, `b s` and `¬ b (s+1)`.
    Classical decidability of `b` is required. -/
theorem discrete_IVT_false_after_true
    (b : ℕ → Prop) [∀ n, Decidable (b n)]
    {t t' : ℕ} (hLt : t < t') (hT : b t) (hT' : ¬ b t') :
    ∃ s, t ≤ s ∧ s < t' ∧ b s ∧ ¬ b (s + 1) := by
  -- Strong induction on the gap `k = t' - t`, generalising `t, t'`.
  -- We rephrase: for every `k`, every pair `t t'` with `t' - t = k`,
  -- `t < t'`, `b t`, `¬ b t'` yields a witness.
  suffices h : ∀ k : ℕ, ∀ t t' : ℕ, t' - t = k →
      t < t' → b t → ¬ b t' →
      ∃ s, t ≤ s ∧ s < t' ∧ b s ∧ ¬ b (s + 1) by
    exact h (t' - t) t t' rfl hLt hT hT'
  intro k
  induction k with
  | zero =>
      intro t t' hGap hLt _ _
      -- gap = 0 means t' ≤ t, contradicting t < t'.
      omega
  | succ k ih =>
      intro t t' hGap hLt hT hT'
      -- Consider b (t+1).
      by_cases hNext : b (t + 1)
      · -- Continue from t+1. Need (t+1) < t' and gap (t'-(t+1)) = k.
        rcases Nat.lt_or_ge (t + 1) t' with hLt' | hGe
        · have hGap' : t' - (t + 1) = k := by omega
          rcases ih (t + 1) t' hGap' hLt' hNext hT' with
            ⟨s, hLo, hHi, hbs, hbsNext⟩
          exact ⟨s, by omega, hHi, hbs, hbsNext⟩
        · -- t' ≤ t+1 combined with t < t' gives t' = t+1, but then ¬ b t' = ¬ b (t+1) contradicts hNext.
          have hEq : t' = t + 1 := by omega
          rw [hEq] at hT'
          exact absurd hNext hT'
      · -- Found it: s = t.
        exact ⟨t, le_refl _, by omega, hT, hNext⟩

/-- **Discrete IVT, symmetric form.** From `¬ b t` to `b t'`, there's an
    adjacent index pair `(s, s+1)` with `¬ b s` and `b (s+1)`. -/
theorem discrete_IVT_true_after_false
    (b : ℕ → Prop) [∀ n, Decidable (b n)]
    {t t' : ℕ} (hLt : t < t') (hT : ¬ b t) (hT' : b t') :
    ∃ s, t ≤ s ∧ s < t' ∧ ¬ b s ∧ b (s + 1) := by
  -- Apply the dual via `b' := ¬ b`.
  have := discrete_IVT_false_after_true (fun n => ¬ b n)
            (t := t) (t' := t') hLt hT (by simpa using hT')
  rcases this with ⟨s, hLo, hHi, hbs, hbsNext⟩
  refine ⟨s, hLo, hHi, hbs, ?_⟩
  by_contra h
  exact hbsNext h

/-! ## (2) Specialisation to Φ₀ along a trajectory. -/

/-- Auxiliary: classical decidability of `Phi0 (Xs t) p = 0`. -/
noncomputable instance instDecidablePhi0Zero
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (Phi0 (Xs t) p = 0) := Classical.dec _

/-- **Phi0 discrete IVT — first rise.** If at index `t` the agent is
    Phi0-zero and at index `t' > t` it is not, then there is a single
    adjacent step `(s, s+1)` inside `[t, t')` where Phi0 jumps from
    zero to nonzero. -/
theorem Phi0_first_rise
    (Xs : ℕ → Agent α) (p : Problem α)
    {t t' : ℕ} (hLt : t < t')
    (hZero : Phi0 (Xs t) p = 0)
    (hNonZero : Phi0 (Xs t') p ≠ 0) :
    ∃ s, t ≤ s ∧ s < t' ∧ Phi0 (Xs s) p = 0 ∧ Phi0 (Xs (s + 1)) p ≠ 0 :=
  discrete_IVT_false_after_true
    (fun n => Phi0 (Xs n) p = 0) hLt hZero hNonZero

/-- **Phi0 discrete IVT — first drop.** If at index `t` Phi0 is nonzero
    and at index `t' > t` it is zero, then there is a single adjacent
    step `(s, s+1)` inside `[t, t')` where Phi0 drops from nonzero to
    zero. -/
theorem Phi0_first_drop
    (Xs : ℕ → Agent α) (p : Problem α)
    {t t' : ℕ} (hLt : t < t')
    (hNonZero : Phi0 (Xs t) p ≠ 0)
    (hZero : Phi0 (Xs t') p = 0) :
    ∃ s, t ≤ s ∧ s < t' ∧ Phi0 (Xs s) p ≠ 0 ∧ Phi0 (Xs (s + 1)) p = 0 :=
  discrete_IVT_true_after_false
    (fun n => Phi0 (Xs n) p = 0) hLt hNonZero hZero

/-! ## (3) Contrapositive: no adjacent change ⇒ no global change. -/

/-- **Φ₀ stationarity within a window.** If `Phi0 (Xs n) p = 0` is the
    same at every adjacent pair `(n, n+1)` with `t ≤ n < t'`, then it is
    the same at `t` and `t'`. -/
theorem Phi0_zero_status_stationary
    (Xs : ℕ → Agent α) (p : Problem α)
    {t t' : ℕ} (hLe : t ≤ t')
    (hStable : ∀ n, t ≤ n → n < t' →
                  (Phi0 (Xs n) p = 0 ↔ Phi0 (Xs (n + 1)) p = 0)) :
    Phi0 (Xs t) p = 0 ↔ Phi0 (Xs t') p = 0 := by
  -- Induct on `t' - t`, generalising t, t'.
  suffices h : ∀ k : ℕ, ∀ t t' : ℕ, t' - t = k →
      t ≤ t' →
      (∀ n, t ≤ n → n < t' →
            (Phi0 (Xs n) p = 0 ↔ Phi0 (Xs (n + 1)) p = 0)) →
      (Phi0 (Xs t) p = 0 ↔ Phi0 (Xs t') p = 0) by
    exact h (t' - t) t t' rfl hLe hStable
  intro k
  induction k with
  | zero =>
      intro t t' hGap _ _
      have : t = t' := by omega
      rw [this]
  | succ k ih =>
      intro t t' hGap hLe hStab
      have hLt : t < t' := by omega
      have hEq1 : (Phi0 (Xs t) p = 0) ↔ (Phi0 (Xs (t + 1)) p = 0) :=
        hStab t (le_refl _) hLt
      have hRest : (Phi0 (Xs (t + 1)) p = 0) ↔ (Phi0 (Xs t') p = 0) := by
        apply ih (t + 1) t'
        · omega
        · omega
        · intro n hLo hHi
          exact hStab n (by omega) hHi
      exact hEq1.trans hRest

/-! ## (4) Transferring to N via A.1. -/

/-- **N discrete IVT — first rise.** Same as Phi0 version, transported by A.1. -/
theorem N_first_rise
    (Xs : ℕ → Agent α) (p : Problem α)
    {t t' : ℕ} (hLt : t < t')
    (hZero : N p (Xs t) = 0)
    (hNonZero : N p (Xs t') ≠ 0) :
    ∃ s, t ≤ s ∧ s < t' ∧ N p (Xs s) = 0 ∧ N p (Xs (s + 1)) ≠ 0 := by
  have hZPhi : Phi0 (Xs t) p = 0 := (Axioms.A1 p (Xs t)).mp hZero
  have hNPhi : Phi0 (Xs t') p ≠ 0 := by
    intro h
    exact hNonZero ((Axioms.A1 p (Xs t')).mpr h)
  rcases Phi0_first_rise Xs p hLt hZPhi hNPhi with ⟨s, hLo, hHi, hbs, hbsNext⟩
  refine ⟨s, hLo, hHi, (Axioms.A1 p (Xs s)).mpr hbs, ?_⟩
  intro hZ
  exact hbsNext ((Axioms.A1 p (Xs (s + 1))).mp hZ)

/-- **N discrete IVT — first drop.** -/
theorem N_first_drop
    (Xs : ℕ → Agent α) (p : Problem α)
    {t t' : ℕ} (hLt : t < t')
    (hNonZero : N p (Xs t) ≠ 0)
    (hZero : N p (Xs t') = 0) :
    ∃ s, t ≤ s ∧ s < t' ∧ N p (Xs s) ≠ 0 ∧ N p (Xs (s + 1)) = 0 := by
  have hNPhi : Phi0 (Xs t) p ≠ 0 := by
    intro h
    exact hNonZero ((Axioms.A1 p (Xs t)).mpr h)
  have hZPhi : Phi0 (Xs t') p = 0 := (Axioms.A1 p (Xs t')).mp hZero
  rcases Phi0_first_drop Xs p hLt hNPhi hZPhi with ⟨s, hLo, hHi, hbs, hbsNext⟩
  refine ⟨s, hLo, hHi, ?_, (Axioms.A1 p (Xs (s + 1))).mpr hbsNext⟩
  intro hZ
  exact hbs ((Axioms.A1 p (Xs s)).mp hZ)

end R2_Agent5_Phi0DiscreteIVT

end MIP
