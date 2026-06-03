/-
  STATUS: DISCOVERY
  AGENT: 4
  DIRECTION: Unconditional cardinality `(B_data p X).card = (N p X).toNat`,
    and a `Phi0`-side characterisation of empty barrier set.
  SUMMARY:
    `B_data_card_eq_N` in `Barriers.lean` is stated with the hypothesis
    `N p X ≠ ⊤`. But the underlying `Finset.card_image_of_injective` +
    `Finset.card_range` chain has NO such hypothesis — when `N = ⊤` the
    `.toNat` collapse means `card = 0 = (⊤ : ℕ∞).toNat`, so the
    statement `(B_data p X).card = (N p X).toNat` holds UNCONDITIONALLY.
    This is the "right" cardinality lemma. We additionally extract the
    `Phi0 X p = 0 → B_data p X = ∅` chain (via A.1 + Agent 2's
    `B_data_eq_empty_of_N_zero`) — never previously stated as a one-shot
    lemma despite being implicit in T18.2's NP-hard proof.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent4_BData_Card_Unconditional

variable {α : Type}

/-! ## (1) Unconditional cardinality. -/

/-- **Unconditional cardinality**: `(B_data p X).card = (N p X).toNat`,
no finiteness hypothesis needed. -/
theorem B_data_card_eq_toNat (p : Problem α) (X : Agent α) :
    (B_data p X).card = (N p X).toNat := by
  unfold B_data
  rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
  exact Finset.card_range _

/-- **`(N p X).toNat = 0 ↔ B_data p X = ∅`**: an equivalent reformulation
of Agent 2's `B_data_empty_iff` but phrased on the `toNat` side. -/
theorem B_data_empty_iff_toNat_zero (p : Problem α) (X : Agent α) :
    B_data p X = ∅ ↔ (N p X).toNat = 0 := by
  rw [← Finset.card_eq_zero, B_data_card_eq_toNat]

/-! ## (2) Phi0 chain: `Phi0 = 0 → B_data = ∅`. -/

/-- **`N = 0` forces empty barrier set** (inlined from Agent 2). -/
private theorem B_data_eq_empty_of_N_zero_local
    (p : Problem α) (X : Agent α) (h : N p X = 0) :
    B_data p X = ∅ := by
  unfold B_data
  rw [h]
  simp

/-- **`Phi0 = 0 → B_data = ∅`**: directly chaining A.1 with the N=0
collapse. The trivially-solvable-by-potential regime has no barriers. -/
theorem B_data_eq_empty_of_Phi0_zero
    (p : Problem α) (X : Agent α) (h : Phi0 X p = 0) :
    B_data p X = ∅ := by
  have hN : N p X = 0 := (Axioms.A1 p X).mpr h
  exact B_data_eq_empty_of_N_zero_local p X hN

/-- **Always-true problem has empty barrier set, for every agent.**
Headline corollary: combine `Phi0_always_true` with the chain above. -/
theorem B_data_always_true_empty (X : Agent α) :
    B_data (fun _ : Str α => true) X = ∅ :=
  B_data_eq_empty_of_Phi0_zero _ X (Phi0_always_true X)

/-- **Card-form of the always-true result.** -/
theorem B_data_card_always_true_zero (X : Agent α) :
    (B_data (fun _ : Str α => true) X).card = 0 := by
  rw [B_data_always_true_empty]
  exact Finset.card_empty

/-! ## (3) Card-side trichotomy. -/

/-- **Card-side dichotomy**: either `B_data` is empty (`card = 0`,
covering both the trivially solvable and knowledge-deficient regimes) or
its card equals `(N p X).toNat ≥ 1` (the positively-emergent regime). -/
theorem B_data_card_dichotomy (p : Problem α) (X : Agent α) :
    (B_data p X).card = 0 ∨ 1 ≤ (B_data p X).card := by
  rcases Nat.eq_zero_or_pos (B_data p X).card with h | h
  · exact Or.inl h
  · exact Or.inr h

end Agent4_BData_Card_Unconditional

end MIP
