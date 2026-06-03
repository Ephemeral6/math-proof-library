/-
  STATUS: DISCOVERY
  AGENT: 2
  DIRECTION: Boundary regime N p X = 1 — the "one-shot solvable" regime.
  SUMMARY:
    `N p X = 1` is positively emergent (N ≠ 0) AND finite (N ≠ ⊤). Via the
    A.1 + A.2 chain, this forces both Phi0 X p ≠ 0 (positive potential) AND
    coverage (some R' ∈ ℛ(p) with R' ⊆ K X). Stated as a clean bundle:
    `N p X = 1 → Phi0 X p ≠ 0 ∧ (∃ R' ∈ ℛ(p), R' ⊆ K X)`.
    Also a generalisation: this holds for ANY finite nonzero `n`, not just 1.
    The N = 1 specialisation drops out as a corollary.
-/
import MIP.Axioms

namespace MIP

namespace Agent2_NOne_Regime

variable {α : Type} {Ω : Type}

/-! ## (1) `N = n` (positive natural) consequences. -/

/-- **Positive-finite N forces nontrivial Phi0 and coverage.**
For any positive natural `n`, `N p X = n` forces both Phi0 ≠ 0 and coverage. -/
theorem phi0_ne_zero_and_coverage_of_N_pos_finite
    (p : Problem α) (X : Agent α) {n : ℕ} (hPos : 0 < n)
    (h : N p X = (n : ℕ∞)) :
    Phi0 X p ≠ 0
      ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) := by
  have hN_ne_top : N p X ≠ ⊤ := by
    rw [h]; exact ENat.coe_ne_top n
  have hN_ne_zero : N p X ≠ 0 := by
    rw [h]
    intro hEq
    have : n = 0 := by exact_mod_cast hEq
    omega
  refine ⟨?_, ?_⟩
  · -- Phi0 ≠ 0: contrapositive of A.1.mp
    intro hPhi
    exact hN_ne_zero ((Axioms.A1 p X).mpr hPhi)
  · -- coverage: A.2.mp
    exact (Axioms.A2 (Ω := Ω) p X).mp hN_ne_top

/-! ## (2) The `N = 1` corollary — headline. -/

/-- **N = 1 forces positive Phi0 and coverage.** Specialisation of the
positive-finite result to `n = 1`. -/
theorem phi0_ne_zero_and_coverage_of_N_one
    (p : Problem α) (X : Agent α) (h : N p X = 1) :
    Phi0 X p ≠ 0
      ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) := by
  have h' : N p X = ((1 : ℕ) : ℕ∞) := by rw [h]; rfl
  exact phi0_ne_zero_and_coverage_of_N_pos_finite (Ω := Ω) p X (by decide) h'

/-! ## (3) Two-sided form: `N p X = 1` is sandwiched between `0` and `⊤`. -/

/-- **N = 1 is in the strict interior of `ℕ∞`.** -/
theorem N_one_strict_interior
    (p : Problem α) (X : Agent α) (h : N p X = 1) :
    0 < N p X ∧ N p X < ⊤ := by
  rw [h]
  refine ⟨?_, ?_⟩ <;> decide

/-! ## (4) Symmetric form (N = 1 vs. coverage and nonzero potential). -/

/-- **N = 1 separator.** `N = 1` is "between" the regimes: not the
trivially-solvable regime (Phi0 = 0, N = 0), and not the
knowledge-deficient regime (no coverage, N = ⊤). -/
theorem N_one_separator
    (p : Problem α) (X : Agent α) (h : N p X = 1) :
    Phi0 X p ≠ 0
      ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
      ∧ 0 < N p X
      ∧ N p X < ⊤ := by
  obtain ⟨hPhi, hCov⟩ := phi0_ne_zero_and_coverage_of_N_one (Ω := Ω) p X h
  obtain ⟨hPos, hLt⟩ := N_one_strict_interior p X h
  exact ⟨hPhi, hCov, hPos, hLt⟩

end Agent2_NOne_Regime

end MIP
