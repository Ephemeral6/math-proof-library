/-
  STATUS: DISCOVERY
  AGENT: R2-1
  DIRECTION: Regime R∞ (`N = ⊤ ∧ Phi0 ≠ 0 ∧ ¬ coverage`) — joint forced facts.
  SUMMARY:
    Starting from R∞'s hypothesis `N p X = ⊤`, we package the consequences:
      (1) Phi0 X p ≠ 0                                 (A.1 contrapositive)
      (2) (B_data p X).card = 0                        (Agent 4 + ⊤.toNat)
      (3) B_data p X = ∅                               (Agent 2 truncation)
      (4) Phi0 X p * Z X p = 0  but  N p X = ⊤         — T.8 Ohm fails maximally
      (5) ⌈Phi0 · Z⌉ < N p X (=⊤)                       (vacuous lower side)
      (6) ¬ coverage: ∀ R' ∈ ℛ(p), ¬ R' ⊆ K X            (A.2 contrapositive)

    Headline observation (cross-regime):  In both R0 and R∞ we have
    `B_data p X = ∅` and `(B_data p X).card = 0`.  But in R0 this is for
    the *honest* reason (no barrier exists, problem trivially solved) and
    in R∞ it is the *truncation artefact* of `(⊤ : ℕ∞).toNat = 0`.  The
    *separation* between the two `B_data = ∅` regimes is read off `Phi0`:
    in R0, `Phi0 = 0`; in R∞, `Phi0 ≠ 0`.  We package this as the
    crisp `B_data_empty_split` theorem.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Defs.StateSequence

namespace MIP

namespace R2_Agent1_Rinf_JointFacts

variable {α : Type} {Ω : Type}

/-! ## (1) `Phi0 ≠ 0` from `N = ⊤`. -/

/-- **R∞ forces `Phi0 ≠ 0`** (A.1 contrapositive on `N ≠ 0`). -/
theorem Rinf_phi0_ne_zero
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    Phi0 X p ≠ 0 := by
  intro hPhi
  have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  rw [h] at hN0
  exact ENat.top_ne_zero hN0

/-! ## (2)–(3) `B_data` truncation. -/

/-- **R∞ forces `(B_data p X).card = 0`** (concrete-model truncation). -/
theorem Rinf_bdata_card_zero
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    (B_data p X).card = 0 := by
  unfold B_data
  rw [Finset.card_image_of_injective _ (b_synth_injective X p), Finset.card_range, h]
  rfl

/-- **R∞ forces `B_data p X = ∅`** (Agent 2 truncation). -/
theorem Rinf_bdata_empty
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    B_data p X = ∅ := by
  unfold B_data
  rw [h]
  simp

/-! ## (4)–(5) T.8 Ohm-law maximal failure. -/

/-- **R∞: `Phi0 * Z = 0` but `N = ⊤`** — the T.8 Ohm-law product
collapses while `N` is infinite. -/
theorem Rinf_PhiZ_eq_zero_but_N_top
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    Phi0 X p * Z X p = 0 ∧ N p X = ⊤ := by
  refine ⟨?_, h⟩
  show Phi0 X p * (0 : ENNReal) = 0
  exact mul_zero _

/-- **R∞: T.8 Ohm strict undershoot is `< ⊤`** — predictably absurd, but
records the maximal failure mode. -/
theorem Rinf_T8_Ohm_strict_undershoot
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    ceilENat (Phi0 X p * Z X p) < N p X := by
  show ceilENat (Phi0 X p * (0 : ENNReal)) < N p X
  rw [mul_zero, ceilENat_zero, h]
  exact ENat.coe_lt_top 0

/-- **R∞: T.8 Ohm-law equation FAILS**. -/
theorem Rinf_T8_Ohm_not_eq
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    N p X ≠ ceilENat (Phi0 X p * Z X p) := by
  show N p X ≠ ceilENat (Phi0 X p * (0 : ENNReal))
  rw [mul_zero, ceilENat_zero, h]
  exact ENat.top_ne_zero

/-! ## (6) No-coverage. -/

/-- **R∞ forces no coverage** (A.2 contrapositive). -/
theorem Rinf_no_coverage
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω) := by
  intro R' hR' hSub
  have : N p X ≠ ⊤ := (Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hR', hSub⟩
  exact this h

/-! ## Headline bundle. -/

/-- **R∞ joint bundle.** -/
theorem Rinf_bundle
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    Phi0 X p ≠ 0
      ∧ (B_data p X).card = 0
      ∧ B_data p X = ∅
      ∧ Phi0 X p * Z X p = 0
      ∧ ceilENat (Phi0 X p * Z X p) < N p X
      ∧ N p X ≠ ceilENat (Phi0 X p * Z X p)
      ∧ (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :=
  ⟨Rinf_phi0_ne_zero p X h,
   Rinf_bdata_card_zero p X h,
   Rinf_bdata_empty p X h,
   (Rinf_PhiZ_eq_zero_but_N_top p X h).1,
   Rinf_T8_Ohm_strict_undershoot p X h,
   Rinf_T8_Ohm_not_eq p X h,
   Rinf_no_coverage (Ω := Ω) p X h⟩

/-! ## Headline cross-regime: `B_data = ∅` ambiguity, split by Phi0. -/

/-- **The `B_data = ∅` regime is the union R0 ∪ R∞**, separated by Phi0.
Given `B_data p X = ∅`, either we are in R0 (`Phi0 = 0`, `N = 0`) or in
R∞ (`Phi0 ≠ 0`, `N = ⊤`).  Crisp formulation of the "two reasons for
empty barriers" observation. -/
theorem B_data_empty_split
    (p : Problem α) (X : Agent α) (h_emp : B_data p X = ∅) :
    (Phi0 X p = 0 ∧ N p X = 0) ∨ (Phi0 X p ≠ 0 ∧ N p X = ⊤) := by
  -- B_data = ∅ → (N p X).toNat = 0 → N = 0 or N = ⊤ (Agent 2).
  have hCard : (B_data p X).card = 0 := by rw [h_emp]; exact Finset.card_empty
  have hCardEq : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  rw [hCardEq] at hCard
  -- Either N = 0 or N = ⊤.
  by_cases hTop : N p X = ⊤
  · right
    refine ⟨?_, hTop⟩
    intro hPhi
    have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
    rw [hTop] at hN0
    exact ENat.top_ne_zero hN0
  · left
    -- N ≠ ⊤ and toNat = 0 → N = 0.
    have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat hTop
    rw [hCard, Nat.cast_zero] at hCoe
    refine ⟨(Axioms.A1 p X).mp hCoe.symm, hCoe.symm⟩

end R2_Agent1_Rinf_JointFacts

end MIP
