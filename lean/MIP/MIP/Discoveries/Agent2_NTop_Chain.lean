/-
  STATUS: DISCOVERY
  AGENT: 2
  DIRECTION: Boundary regime N p X = ⊤ — full characterisation chain.
  SUMMARY:
    The "knowledge-deficient" regime N = ⊤ is characterised by:
      (a) N p X = ⊤            (degree-side, the definition)
      (b) ∀ R' ∈ ℛ(p), R' ⊄ K X (coverage-side, via A.2 contrapositive)
    The equivalence (a) ↔ (b) is direct from A.2 — `Agent1_A1A2_Phi0Coverage`
    already proved (b → a) [`N_top_of_no_coverage`] and (a → b) is C.2's
    kernel. We package the iff explicitly here as a discovery. Then we use
    A.1 to add Phi0 ≠ 0 as a consequence of N = ⊤. Headline iff:
    `N p X = ⊤ ↔ ∀ R' ∈ ℛ(p), ¬ R' ⊆ K X`.
-/
import MIP.Axioms

namespace MIP

namespace Agent2_NTop_Chain

variable {α : Type} {Ω : Type}

/-! ## (1) The `N = ⊤ ↔ no coverage` biconditional. -/

/-- **Headline: N=⊤ iff no demand covered.** Direct iff form of A.2's
contrapositive, packaging both directions. -/
theorem N_top_iff_no_coverage (p : Problem α) (X : Agent α) :
    N p X = ⊤
      ↔
    ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω) := by
  constructor
  · intro hTop
    intro R' hR' hSub
    have : N p X ≠ ⊤ := (Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hR', hSub⟩
    exact this hTop
  · intro hNoCov
    by_contra hNe
    obtain ⟨R', hR', hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hNe
    exact hNoCov R' hR' hSub

/-! ## (2) `N = ⊤ → N ≠ 0 → Phi0 ≠ 0`. -/

/-- **N=⊤ implies N ≠ 0.** Trivial in `ℕ∞`. -/
theorem N_top_imp_N_ne_zero
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    N p X ≠ 0 := by
  rw [h]; decide

/-- **N=⊤ implies Phi0 X p ≠ 0.** Via A.1's contrapositive. -/
theorem phi0_ne_zero_of_N_top
    (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    Phi0 X p ≠ 0 := by
  intro hPhi
  have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  rw [h] at hN0
  exact ENat.top_ne_zero hN0

/-! ## (3) Strong consequence pack — everything you can say about
N = ⊤ from A.1 + A.2 alone. -/

/-- **N=⊤ consequence bundle.** All A.1 + A.2 consequences in one package. -/
theorem N_top_consequences (p : Problem α) (X : Agent α) (h : N p X = ⊤) :
    (Phi0 X p ≠ 0)
      ∧ (N p X ≠ 0)
      ∧ (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :=
  ⟨phi0_ne_zero_of_N_top p X h,
   N_top_imp_N_ne_zero p X h,
   (N_top_iff_no_coverage (Ω := Ω) p X).mp h⟩

/-! ## (4) Inverse: forward direction of A.2 packaged as "no coverage → N=⊤".

Already proved by Agent 1 (`N_top_of_no_coverage`); we re-state in the more
symmetric (∀ R', ¬ ...) form that pairs with `N_top_iff_no_coverage`. -/

/-- **Universal-no-coverage form of `N = ⊤` direction.** -/
theorem N_top_of_universal_no_coverage
    (p : Problem α) (X : Agent α)
    (hNoCov : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    N p X = ⊤ :=
  (N_top_iff_no_coverage (Ω := Ω) p X).mpr hNoCov

end Agent2_NTop_Chain

end MIP
