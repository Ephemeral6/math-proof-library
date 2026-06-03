/-
  STATUS: DISCOVERY
  AGENT: R2-1
  DIRECTION: Regime-conditional behaviour of `Phi_state` along the canonical
             `(X, p, k)` chain.
  SUMMARY:
    `Phi_state ⟨X, p, k⟩ = if (k : ℕ∞) ≥ N p X then 0 else Phi0 X p`.
    Each regime collapses this to a uniform value:

      R0  (N = 0):    Phi_state ⟨X, p, k⟩ = 0           for every k
      RP  (0<N<⊤):    Phi_state ⟨X, p, k⟩ = Phi0 X p    iff k < N
                      Phi_state ⟨X, p, k⟩ = 0            iff k ≥ N
      R∞  (N = ⊤):    Phi_state ⟨X, p, k⟩ = Phi0 X p    for every k

    The R0 and R∞ cases are particularly clean — both regimes collapse
    the if-then-else to a constant.  R0 collapses to the "always-success"
    constant 0, R∞ to the "never-success" constant `Phi0 X p`.  Neither
    was stated before in this regime-conditional form.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Defs.StateSequence

namespace MIP

namespace R2_Agent1_PhiState_Regime

variable {α : Type}

/-! ## (1) R0 case: Phi_state collapses to 0. -/

/-- **R0: `Phi_state ⟨X, p, k⟩ = 0` for every k.** -/
theorem PhiState_eq_zero_in_R0
    (p : Problem α) (X : Agent α) (h : N p X = 0) (k : ℕ) :
    Phi_state (⟨X, p, k⟩ : InternalState α) = 0 := by
  unfold Phi_state
  show (if (k : ℕ∞) ≥ N p X then 0 else Phi0 X p) = 0
  rw [h, if_pos (by exact bot_le)]

/-! ## (2) R∞ case: Phi_state stays at `Phi0`. -/

/-- **R∞: `Phi_state ⟨X, p, k⟩ = Phi0 X p` for every k.**

When `N p X = ⊤`, the success threshold `k ≥ ⊤` is never reached by any
natural number, so `Phi_state` stays at `Phi0`. -/
theorem PhiState_eq_phi0_in_Rinf
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) (k : ℕ) :
    Phi_state (⟨X, p, k⟩ : InternalState α) = Phi0 X p := by
  unfold Phi_state
  show (if (k : ℕ∞) ≥ N p X then 0 else Phi0 X p) = Phi0 X p
  rw [h]
  rw [if_neg]
  -- ¬ (k : ℕ∞) ≥ ⊤ : finite naturals are < ⊤.
  intro hLe
  have : (k : ℕ∞) < ⊤ := ENat.coe_lt_top k
  exact absurd hLe (not_le.mpr this)

/-! ## (3) RP case: two-sided split at the threshold. -/

/-- **RP below threshold**: `k < (N p X).toNat → Phi_state ⟨X, p, k⟩ = Phi0 X p`. -/
theorem PhiState_eq_phi0_below_threshold_RP
    (p : Problem α) (X : Agent α) (h_fin : N p X ≠ ⊤)
    (k : ℕ) (h_below : k < (N p X).toNat) :
    Phi_state (⟨X, p, k⟩ : InternalState α) = Phi0 X p := by
  unfold Phi_state
  show (if (k : ℕ∞) ≥ N p X then 0 else Phi0 X p) = Phi0 X p
  rw [if_neg]
  intro hLe
  have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat h_fin
  rw [← hCoe] at hLe
  have : (N p X).toNat ≤ k := by exact_mod_cast hLe
  omega

/-- **RP at-or-above threshold**: `(N p X).toNat ≤ k → Phi_state ⟨X, p, k⟩ = 0`. -/
theorem PhiState_eq_zero_at_threshold_RP
    (p : Problem α) (X : Agent α) (h_fin : N p X ≠ ⊤)
    (k : ℕ) (h_above : (N p X).toNat ≤ k) :
    Phi_state (⟨X, p, k⟩ : InternalState α) = 0 := by
  unfold Phi_state
  show (if (k : ℕ∞) ≥ N p X then 0 else Phi0 X p) = 0
  rw [if_pos]
  have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat h_fin
  rw [← hCoe]
  exact_mod_cast h_above

/-! ## (4) Headline: `Phi_state` is regime-constant in R0 ∪ R∞. -/

/-- **`Phi_state` is constant in `k` in R0 and R∞.**  Both extreme regimes
collapse the if-then-else to a single branch:
* R0 → constant 0,
* R∞ → constant `Phi0 X p`.
The interior regime RP is the *only* regime in which `Phi_state` is
non-constant in `k`. -/
theorem PhiState_constant_in_extreme_regimes
    (p : Problem α) (X : Agent α) :
    (N p X = 0 → ∀ k : ℕ,
        Phi_state (⟨X, p, k⟩ : InternalState α) = 0)
      ∧ (N p X = ⊤ → ∀ k : ℕ,
        Phi_state (⟨X, p, k⟩ : InternalState α) = Phi0 X p) :=
  ⟨PhiState_eq_zero_in_R0 p X, PhiState_eq_phi0_in_Rinf p X⟩

/-! ## (5) `Phi_decrement` regime-conditional collapse. -/

/-- **R0: every `Phi_decrement` is `0`.**  Both `Phi_state` values
involved in the decrement are 0, so the difference is 0. -/
theorem PhiDecrement_zero_in_R0
    (p : Problem α) (X : Agent α) (h : N p X = 0) (k : ℕ) (m : Str α) :
    Phi_decrement m (⟨X, p, k⟩ : InternalState α) = 0 := by
  unfold Phi_decrement
  rw [PhiState_eq_zero_in_R0 p X h k]
  -- T_m m ⟨X, p, k⟩ = ⟨X, p, k+1⟩ in concrete model.
  show (0 : ENNReal) - Phi_state (T_m m _) = 0
  rw [zero_tsub]

/-- **R∞: every `Phi_decrement` between two `(X, p, k)`-states is `0`.**
Both `Phi_state` values are `Phi0`, so the difference is 0. -/
theorem PhiDecrement_zero_in_Rinf
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) (k : ℕ) (m : Str α) :
    Phi_decrement m (⟨X, p, k⟩ : InternalState α) = 0 := by
  unfold Phi_decrement
  rw [PhiState_eq_phi0_in_Rinf p X h k]
  -- T_m m ⟨X, p, k⟩ = ⟨X, p, k+1⟩, also at `Phi0 X p`.
  show Phi0 X p - Phi_state (T_m m _) = 0
  have : Phi_state (T_m m (⟨X, p, k⟩ : InternalState α)) = Phi0 X p := by
    -- T_m m ⟨X, p, k⟩ = ⟨X, p, k+1⟩
    show Phi_state (⟨X, p, k + 1⟩ : InternalState α) = Phi0 X p
    exact PhiState_eq_phi0_in_Rinf p X h (k + 1)
  rw [this, tsub_self]

end R2_Agent1_PhiState_Regime

end MIP
