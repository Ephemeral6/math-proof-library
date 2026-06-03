/-
  STATUS: DISCOVERY
  AGENT: 2
  DIRECTION: Barrier set cardinality at boundary N values — concrete-model facts.
  SUMMARY:
    The concrete-model `B_data p X := (Finset.range (N p X).toNat).image (b_synth X p)`
    has predictable behaviour at the boundary:
      * `N = 0 → B_data = ∅`        (the trivially-solvable regime has no barriers)
      * `N = ⊤ → B_data = ∅`        (the "infinite-barrier truncation" — model
                                     collapses the unbounded barrier set to ∅)
      * `N = 1 ↔ (B_data p X).card = 1` (using the bridge `B_data_card_eq_N`)
    These give the explicit `B_data ↔ N`-value characterisations at the
    boundary, never stated directly in `Barriers.lean`. The two N = 0 / N = ⊤
    cases of "B_data = ∅" make the model's truncation behaviour explicit:
    cardinality alone CANNOT distinguish trivially-solvable from
    knowledge-deficient regimes.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent2_BData_Boundary

variable {α : Type}

/-! ## (1) `N = 0` collapse. -/

/-- **`N p X = 0` forces `B_data p X = ∅`.** Since `(0 : ℕ∞).toNat = 0` and
`Finset.range 0 = ∅`, the image is empty. -/
theorem B_data_eq_empty_of_N_zero
    (p : Problem α) (X : Agent α) (h : N p X = 0) :
    B_data p X = ∅ := by
  unfold B_data
  rw [h]
  simp

/-! ## (2) `N = ⊤` collapse — the "truncation" observation. -/

/-- **`N p X = ⊤` forces `B_data p X = ∅`.** Concrete-model artefact:
`(⊤ : ℕ∞).toNat = 0`, so the range is empty.

This means the concrete-model `B_data` does NOT faithfully represent the
NL "infinite barrier set" in the knowledge-deficient regime — it truncates
to `∅`. This is a known limitation of the concrete-model choice, noted
implicitly in `Barriers.lean`'s definition. -/
theorem B_data_eq_empty_of_N_top
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    B_data p X = ∅ := by
  unfold B_data
  rw [h]
  simp

/-! ## (3) Card = 0 characterisation. -/

/-- **`(B_data p X).card = 0 ↔ B_data p X = ∅`** — Mathlib triviality, restated. -/
theorem B_data_card_zero_iff (p : Problem α) (X : Agent α) :
    (B_data p X).card = 0 ↔ B_data p X = ∅ :=
  Finset.card_eq_zero

/-- **`B_data p X = ∅ ↔ N p X = 0 ∨ N p X = ⊤`** — full characterisation
of the empty-barrier regime in the concrete model. -/
theorem B_data_empty_iff (p : Problem α) (X : Agent α) :
    B_data p X = ∅ ↔ (N p X = 0 ∨ N p X = ⊤) := by
  constructor
  · intro hEmp
    -- B_data = ∅ → range (N.toNat) image is ∅ → range (N.toNat) = ∅
    -- → N.toNat = 0 → N = 0 or N = ⊤.
    unfold B_data at hEmp
    have hRangeEmp : Finset.range (N p X).toNat = ∅ := by
      rcases Finset.image_eq_empty.mp hEmp with h
      exact h
    have hToNat : (N p X).toNat = 0 := by
      have := Finset.card_range (N p X).toNat
      rw [hRangeEmp] at this
      simp at this
      omega
    -- (N p X).toNat = 0 ↔ N p X = 0 ∨ N p X = ⊤
    by_cases hTop : N p X = ⊤
    · exact Or.inr hTop
    · refine Or.inl ?_
      have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat hTop
      rw [hToNat, Nat.cast_zero] at hCoe
      exact hCoe.symm
  · rintro (h | h)
    · exact B_data_eq_empty_of_N_zero p X h
    · exact B_data_eq_empty_of_N_top p X h

/-! ## (4) Card = 1 characterisation: `N = 1` corner. -/

/-- **`N p X = 1 → (B_data p X).card = 1`.** Via the `B_data_card_eq_N`
bridge and `N ≠ ⊤`. -/
theorem B_data_card_eq_one_of_N_one
    (p : Problem α) (X : Agent α) (h : N p X = 1) :
    (B_data p X).card = 1 := by
  have hFin : N p X ≠ ⊤ := by rw [h]; decide
  have hBridge : ((B_data p X).card : ℕ∞) = N p X := B_data_card_eq_N p X hFin
  rw [h] at hBridge
  exact_mod_cast hBridge

/-- **`(B_data p X).card = 1 → N p X = 1`.** Converse: card = 1 rules out
`N = ⊤` (where B_data = ∅), so the bridge applies. -/
theorem N_eq_one_of_B_data_card_eq_one
    (p : Problem α) (X : Agent α) (h : (B_data p X).card = 1) :
    N p X = 1 := by
  -- card = 1 → B_data ≠ ∅ → ¬(N = 0 ∨ N = ⊤).
  have hNeEmp : B_data p X ≠ ∅ := by
    intro hEmp
    rw [hEmp, Finset.card_empty] at h
    exact one_ne_zero h.symm
  have hNot : ¬ (N p X = 0 ∨ N p X = ⊤) := fun hDisj =>
    hNeEmp ((B_data_empty_iff p X).mpr hDisj)
  have hNeTop : N p X ≠ ⊤ := fun hTop => hNot (Or.inr hTop)
  have hBridge : ((B_data p X).card : ℕ∞) = N p X := B_data_card_eq_N p X hNeTop
  rw [h] at hBridge
  exact_mod_cast hBridge.symm

/-- **Biconditional**: `N p X = 1 ↔ (B_data p X).card = 1`. The headline
characterisation of the "one-shot solvable" regime in concrete-model
barrier terms. -/
theorem N_eq_one_iff_B_data_card_eq_one (p : Problem α) (X : Agent α) :
    N p X = 1 ↔ (B_data p X).card = 1 :=
  ⟨B_data_card_eq_one_of_N_one p X, N_eq_one_of_B_data_card_eq_one p X⟩

end Agent2_BData_Boundary

end MIP
