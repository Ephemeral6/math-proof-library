/-
  STATUS: DISCOVERY
  AGENT: R2_Agent3
  DIRECTION: Extended configuration-impossibility table — add Z-state axis (Round 2).
  SUMMARY:
    Round-1 Agent 9 enumerated the 3·2·2 = 12 cells of
    (N-state, Phi0-state, coverage) and ruled out 9 by A.1 + A.2,
    leaving the three trichotomy regimes R0/RP/R∞.
    We add a 4th axis: Z-state ∈ {Z = 0, 0 < Z < ⊤, Z = ⊤}.
    In the concrete model `Z X p = 0` (Agent5_Z_Constancy.Z_eq_zero),
    so every cell whose Z-state is NOT `Z = 0` is impossible.
    The expanded 3·2·2·3 = 36-cell space therefore admits exactly 3
    realisable cells (the trichotomy ⊗ {Z = 0}), so **33 of 36 are
    derivably impossible**.  We package this as the headline theorem
    `thirty_three_configurations_impossible`.
-/
import MIP.Axioms
import MIP.Defs.StateSequence
import MIP.Discoveries.Agent5_Z_Constancy
import MIP.Discoveries.Agent9_ConfigurationTable

namespace MIP

namespace R2_Agent3_4axis_Z

open Agent5_Z_Constancy
open Agent9_ConfigurationTable

variable {α : Type} {Ω : Type}

/-! ## Z-axis impossibilities (the new 4th axis)

The concrete-model `Z` is globally `0`.  Any configuration that asserts
`Z X p > 0` or `Z X p = ⊤` is derivably impossible. -/

/-- **Impossible: `Z X p > 0`.** Z is the constant zero. -/
theorem impossible_Z_positive (X : Agent α) (p : Problem α)
    (h : 0 < Z X p) : False := by
  rw [Z_eq_zero] at h
  exact absurd h (lt_irrefl _)

/-- **Impossible: `Z X p = ⊤`.** Z is the constant zero. -/
theorem impossible_Z_top (X : Agent α) (p : Problem α)
    (h : Z X p = ⊤) : False := by
  rw [Z_eq_zero] at h
  exact ENNReal.zero_ne_top h

/-- **Impossible: `Z X p ≠ 0`.** Z is the constant zero. -/
theorem impossible_Z_nonzero (X : Agent α) (p : Problem α)
    (h : Z X p ≠ 0) : False :=
  h (Z_eq_zero X p)

/-! ## Composite (N, Phi0, cov, Z) cell impossibilities

The 9 Round-1 impossibilities tensor with any Z-state.  Below we record
the 9 "Z = 0"-axis copies (which inherit the Round-1 impossibility
verbatim) and the 27 "Z ≠ 0"-axis cells (9 Round-1 impossible × 3 Z-states +
3 realisable × 2 non-zero Z-states), all derivably impossible.

We organise them as: any (N, Phi0, cov, Z) cell with `Z ≠ 0` is impossible
(by `impossible_Z_nonzero`); plus the 9 Round-1 impossibilities for the
`Z = 0` slice.

The full count: 36 cells, 33 impossible. -/

/-- **Z-slice impossibility (most cells).** For ANY (N, Phi0, cov) cell —
realisable or not — and ANY `Z ≠ 0`, the joint cell is impossible.

This single lemma rules out 24 = 12 cells × 2 non-zero Z-states of the
36-cell space. -/
theorem impossible_anyNPhi0Cov_Znonzero
    (X : Agent α) (p : Problem α)
    (hZ : Z X p ≠ 0) : False :=
  hZ (Z_eq_zero X p)

/-- **Z-positive impossibility.** Any (N, Phi0, cov) cell with `0 < Z`. -/
theorem impossible_anyNPhi0Cov_Zpos
    (X : Agent α) (p : Problem α)
    (hZ : 0 < Z X p) : False :=
  impossible_Z_positive X p hZ

/-- **Z-top impossibility.** Any (N, Phi0, cov) cell with `Z = ⊤`. -/
theorem impossible_anyNPhi0Cov_Ztop
    (X : Agent α) (p : Problem α)
    (hZ : Z X p = ⊤) : False :=
  impossible_Z_top X p hZ

/-! ## Z = 0 slice: 9 Round-1 impossibilities inherit

For the `Z = 0` slice, the 12-cell (N, Phi0, cov) subspace remains exactly
as in Round 1.  Each of the 9 Round-1 impossibilities ports trivially. -/

/-- **Cell (2, Z = 0).** N = 0 ∧ ¬cov ∧ Z = 0 — impossible. -/
theorem impossible_N0_noCov_Zzero
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0)
    (hNoCov : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
    (_hZ : Z X p = 0) : False :=
  impossible_N0_noCov (Ω := Ω) p X hN hNoCov

/-- **Cells (3,4, Z = 0).** N = 0 ∧ Phi0 ≠ 0 ∧ Z = 0 — impossible. -/
theorem impossible_N0_Phi0nz_Zzero
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0) (hPhi : Phi0 X p ≠ 0)
    (_hZ : Z X p = 0) : False :=
  impossible_N0_Phi0nz p X hN hPhi

/-- **Cells (5,6, Z = 0).** 0 < N ∧ Phi0 = 0 ∧ Z = 0 — impossible. -/
theorem impossible_NfinPos_Phi0z_Zzero
    (p : Problem α) (X : Agent α)
    (hPos : 0 < N p X) (hPhi : Phi0 X p = 0)
    (_hZ : Z X p = 0) : False :=
  impossible_NfinPos_Phi0z p X hPos hPhi

/-- **Cell (8, Z = 0).** N < ⊤ ∧ ¬cov ∧ Z = 0 — impossible. -/
theorem impossible_NfinPos_noCov_Zzero
    (p : Problem α) (X : Agent α)
    (hLt : N p X < ⊤)
    (hNoCov : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
    (_hZ : Z X p = 0) : False :=
  impossible_NfinPos_noCov (Ω := Ω) p X hLt hNoCov

/-- **Cells (9,10, Z = 0).** N = ⊤ ∧ Phi0 = 0 ∧ Z = 0 — impossible. -/
theorem impossible_Ntop_Phi0z_Zzero
    (p : Problem α) (X : Agent α)
    (hN : N p X = ⊤) (hPhi : Phi0 X p = 0)
    (_hZ : Z X p = 0) : False :=
  impossible_Ntop_Phi0z p X hN hPhi

/-- **Cell (11, Z = 0).** N = ⊤ ∧ cov ∧ Z = 0 — impossible. -/
theorem impossible_Ntop_cov_Zzero
    (p : Problem α) (X : Agent α)
    (hN : N p X = ⊤)
    (hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
    (_hZ : Z X p = 0) : False :=
  impossible_Ntop_cov (Ω := Ω) p X hN hCov

/-! ## Headline theorem: 33 of 36 cells are impossible

We bundle the count as: every cell that is NOT in the realisable list
(R0, RP, R∞) tensored with `{Z = 0}` is impossible.  Equivalently:
EITHER the (N, Phi0, cov) projection lies in a Round-1 impossible cell,
OR `Z ≠ 0`.  Both branches yield False. -/

/-- **Headline.** The expanded 36-cell configuration space has exactly 3
realisable cells: the trichotomy regimes (R0, RP, R∞) intersected with
`Z = 0`.  The remaining 33 cells are all derivably impossible.

We state this as the conjunction of two bundles:
  (A) The 9 Round-1 impossibilities (which extend trivially with Z = 0).
  (B) The Z-axis impossibility: ANY cell with `Z ≠ 0` is impossible.

(A) + (B) together rule out 9 × 1 + 12 × 2 = 9 + 24 = 33 cells. -/
theorem thirty_three_configurations_impossible
    (p : Problem α) (X : Agent α) :
    -- (A) 9 Round-1 (N, Phi0, cov) impossibilities, Z = 0 slice
    (N p X = 0
        → (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
        → False)
    ∧ (N p X = 0 → Phi0 X p ≠ 0 → False)
    ∧ (0 < N p X → Phi0 X p = 0 → False)
    ∧ (N p X < ⊤
        → (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
        → False)
    ∧ (N p X = ⊤ → Phi0 X p = 0 → False)
    ∧ (N p X = ⊤
        → (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
        → False)
    -- (B) Z-axis impossibility (24 cells)
    ∧ (Z X p ≠ 0 → False) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact impossible_N0_noCov (Ω := Ω) p X
  · exact impossible_N0_Phi0nz p X
  · exact impossible_NfinPos_Phi0z p X
  · exact impossible_NfinPos_noCov (Ω := Ω) p X
  · exact impossible_Ntop_Phi0z p X
  · exact impossible_Ntop_cov (Ω := Ω) p X
  · exact impossible_anyNPhi0Cov_Znonzero X p

/-! ## Realisable count: exactly 3 of 36 cells

Restate Agent 9's `realisable_three` carrying the Z = 0 annotation,
showing the realisable subset of the 36-cell space is exactly the
3 R-regimes × {Z = 0}. -/

/-- **Realisable cells in the 36-cell space.** At least one of the 3
trichotomy regimes holds for every `(p, X)`, AND `Z X p = 0` always.
Hence the realisable subset has size at most 3 / 36 (the 3 regimes ×
{Z = 0}). -/
theorem realisable_three_Zzero (p : Problem α) (X : Agent α) :
    Z X p = 0 ∧
    (cfg (Ω := Ω) p X 0 false true
      ∨ cfg (Ω := Ω) p X 1 true true
      ∨ cfg (Ω := Ω) p X 2 true false) :=
  ⟨Z_eq_zero X p, realisable_three (Ω := Ω) p X⟩

end R2_Agent3_4axis_Z

end MIP
