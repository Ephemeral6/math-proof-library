/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: Joint impossibilities involving `B_data` (concrete-model barrier set) and Phi0 / N.
  SUMMARY:
    Combining Agent 4/2's `B_data` characterisations with A.1, we get
    several joint impossibility theorems:
      (i)  No agent can have `Phi0 = 0` AND `B_data` non-empty
           (since `Phi0 = 0 → N = 0 → B_data = ∅`).
      (ii) No agent can have `Phi0 = 0` AND `|B_data| ≥ 1`.
      (iii)No agent can have `B_data` non-empty AND `N = 0`.
      (iv) No agent can simultaneously have `B_data = ∅` AND
           `0 < N p X ∧ N p X < ⊤` (the concrete-model truncation rules
           this out: at finite positive N, |B_data| = N ≥ 1).
    All from A.1 + the concrete-model `B_data` definition.

    The headline reformulation:
      "the concrete-model `B_data p X = ∅` characterises the union
       of the trivially-solvable regime AND the knowledge-deficient
       regime (Agent 2's `B_data_empty_iff`); so any `Phi0 = 0` agent
       lives in the trivially-solvable side of that union — its
       `B_data` is empty for *both* reasons (`N=0` directly, and
       `N=0 → N≠⊤` rules out the ⊤-truncation cause)."
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent9_BData_Phi0_Impossibilities

variable {α : Type}

/-! ## (1) `Phi0 = 0` + `B_data` non-empty is impossible. -/

/-- **Impossibility: `Phi0 X p = 0 ∧ B_data p X ≠ ∅`.**

`Phi0 = 0 → N = 0` (A.1.mpr) → `B_data = ∅` (Agent 2's chain). -/
theorem impossible_Phi0_zero_B_data_nonempty
    (p : Problem α) (X : Agent α)
    (hPhi : Phi0 X p = 0) (h_ne : B_data p X ≠ ∅) :
    False := by
  have hN : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  have h_emp : B_data p X = ∅ := by
    unfold B_data; rw [hN]; simp
  exact h_ne h_emp

/-- **Equivalent biconditional form.** Coverage of the no-go: if `Phi0 = 0`
then `B_data p X = ∅`.  Direct consequence of A.1 + concrete `B_data`. -/
theorem B_data_empty_of_Phi0_zero
    (p : Problem α) (X : Agent α) (hPhi : Phi0 X p = 0) :
    B_data p X = ∅ := by
  have hN : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  unfold B_data; rw [hN]; simp

/-! ## (2) `|B_data| ≥ 1 → Phi0 ≠ 0`. -/

/-- **Cardinality lower bound forces `Phi0 ≠ 0`.** Contrapositive of (1) in
cardinality form. -/
theorem Phi0_ne_zero_of_B_data_card_pos
    (p : Problem α) (X : Agent α)
    (h_card : 1 ≤ (B_data p X).card) :
    Phi0 X p ≠ 0 := by
  intro hPhi
  have h_emp : B_data p X = ∅ := B_data_empty_of_Phi0_zero p X hPhi
  rw [h_emp, Finset.card_empty] at h_card
  exact absurd h_card (by decide)

/-! ## (3) `B_data` non-empty → `N ≠ 0`. -/

/-- **`B_data` non-empty ⟹ `N ≠ 0`.** Direct from the definition: if `N = 0`
then `B_data = ∅`. -/
theorem N_ne_zero_of_B_data_nonempty
    (p : Problem α) (X : Agent α)
    (h_ne : B_data p X ≠ ∅) : N p X ≠ 0 := by
  intro hN
  have h_emp : B_data p X = ∅ := by unfold B_data; rw [hN]; simp
  exact h_ne h_emp

/-! ## (4) `B_data` empty AT finite positive N is impossible.

The concrete-model bridge `B_data_card_eq_N` (when `N ≠ ⊤`) gives
`|B_data| = N` in ℕ∞. So if `0 < N < ⊤` then `|B_data| ≥ 1`, ruling out
`B_data = ∅` at finite positive N. -/

/-- **`B_data = ∅` at finite positive N is impossible.** Combine the
`B_data_card_eq_N` bridge with `Finset.card_eq_zero`. -/
theorem impossible_B_data_empty_at_finite_positive_N
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) (h_fin : N p X ≠ ⊤)
    (h_emp : B_data p X = ∅) : False := by
  have h_card_eq : ((B_data p X).card : ℕ∞) = N p X := B_data_card_eq_N p X h_fin
  rw [h_emp, Finset.card_empty] at h_card_eq
  -- h_card_eq : (0 : ℕ∞) = N p X
  rw [← h_card_eq] at h_pos
  exact absurd h_pos (by decide)

/-! ## (5) Headline: `B_data = ∅` characterises `N ∈ {0, ⊤}`.

This is Agent 2's `B_data_empty_iff` — we re-state it in joint-impossibility
form as the corollary "B_data non-empty + (N = 0 ∨ N = ⊤)" is impossible. -/

/-- **Joint impossibility: `B_data non-empty AND N ∈ {0, ⊤}`.**

If `N = 0` then `B_data = ∅` directly.  If `N = ⊤` then the truncation
`(⊤ : ℕ∞).toNat = 0` gives `B_data = ∅` as well.  So `B_data` non-empty
rules out both endpoints. -/
theorem impossible_B_data_nonempty_at_N_endpoints
    (p : Problem α) (X : Agent α)
    (h_ne : B_data p X ≠ ∅)
    (h_endpoint : N p X = 0 ∨ N p X = ⊤) : False := by
  rcases h_endpoint with h | h
  · exact h_ne (by unfold B_data; rw [h]; simp)
  · exact h_ne (by unfold B_data; rw [h]; simp)

end Agent9_BData_Phi0_Impossibilities

end MIP
