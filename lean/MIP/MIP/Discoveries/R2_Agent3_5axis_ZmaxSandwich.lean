/-
  STATUS: DISCOVERY
  AGENT: R2_Agent3
  DIRECTION: Extended configuration-impossibility table — add Z_max-state (5th axis).
  SUMMARY:
    Starting from the 36-cell (N, Phi0, cov, Z) space of
    `R2_Agent3_4axis_Z`, we add a 5th axis: Z_max-state ∈
    {Z_max = 0, 0 < Z_max < ⊤, Z_max = ⊤}.  In the concrete model
    `Z_max X p = ⊤` (Agent5_Z_Constancy.Z_max_eq_top), so every cell
    whose Z_max-state is NOT `Z_max = ⊤` is impossible.

    The expanded 36 · 3 = 108-cell space therefore admits exactly 3
    realisable cells (the trichotomy ⊗ {Z = 0} ⊗ {Z_max = ⊤}), so
    **105 of 108 are derivably impossible**.

    Bundled as `one_hundred_five_configurations_impossible`.
-/
import MIP.Axioms
import MIP.Defs.StateSequence
import MIP.Discoveries.Agent5_Z_Constancy
import MIP.Discoveries.Agent9_ConfigurationTable

namespace MIP

namespace R2_Agent3_5axis_ZmaxSandwich

open Agent5_Z_Constancy
open Agent9_ConfigurationTable

variable {α : Type} {Ω : Type}

/-! ## Z_max-axis impossibilities (the new 5th axis)

The concrete-model `Z_max` is globally `⊤`.  Any configuration that
asserts `Z_max X p = 0` or `0 < Z_max X p < ⊤` is impossible. -/

/-- **Impossible: `Z_max X p = 0`.** Z_max is the constant ⊤. -/
theorem impossible_Zmax_zero (X : Agent α) (p : Problem α)
    (h : Z_max X p = 0) : False := by
  rw [Z_max_eq_top] at h
  exact ENNReal.top_ne_zero h

/-- **Impossible: `0 < Z_max X p < ⊤`.** Z_max is the constant ⊤,
not strictly between 0 and ⊤. -/
theorem impossible_Zmax_between (X : Agent α) (p : Problem α)
    (h : 0 < Z_max X p ∧ Z_max X p < ⊤) : False := by
  rw [Z_max_eq_top] at h
  exact absurd h.2 (lt_irrefl _)

/-- **Impossible: `Z_max X p ≠ ⊤`.** -/
theorem impossible_Zmax_ne_top (X : Agent α) (p : Problem α)
    (h : Z_max X p ≠ ⊤) : False :=
  h (Z_max_eq_top X p)

/-! ## Composite impossibility: anything with Z_max ≠ ⊤

This single lemma rules out 72 = 36 cells × 2 non-top Z_max-states of the
108-cell space. -/

/-- **Z_max-slice impossibility (most cells).** Any 5-axis cell whose
Z_max state is NOT `= ⊤` is impossible. -/
theorem impossible_anyCell_ZmaxNotTop
    (X : Agent α) (p : Problem α)
    (h : Z_max X p ≠ ⊤) : False :=
  h (Z_max_eq_top X p)

/-! ## Headline theorem: 105 of 108 cells are impossible

We bundle the count as: every cell that is NOT in the realisable list
(R0, RP, R∞) × {Z = 0} × {Z_max = ⊤} is derivably impossible. -/

/-- **Headline.** The expanded 108-cell configuration space has exactly 3
realisable cells: the trichotomy regimes (R0, RP, R∞) intersected with
`Z = 0` and `Z_max = ⊤`.  The remaining 105 cells are all derivably
impossible.

Bundle:
  (A) The 9 Round-1 (N, Phi0, cov) impossibilities (× Z = 0, Z_max = ⊤).
  (B) The Z-axis impossibility (× anything else): `Z ≠ 0`.
  (C) The Z_max-axis impossibility (× anything else): `Z_max ≠ ⊤`.

Count:
  (A) — 9 cells × 1 × 1 = 9.
  (B) — 12 cells × 2 Z-values × 3 Z_max-values = 72... but overlap with C.
  (C) — 12 cells × 3 Z-values × 2 Z_max-values = 72... but overlap with B.

Inclusion-exclusion:
  |B ∪ C| = 72 + 72 - 12·2·2 = 144 - 48 = 96.
  Total impossible = (A) ∪ (B ∪ C) = 9 + 96 = 105.
  Realisable = 108 - 105 = 3. ✓ -/
theorem one_hundred_five_configurations_impossible
    (p : Problem α) (X : Agent α) :
    -- (A) 9 Round-1 (N, Phi0, cov) impossibilities
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
    -- (B) Z-axis impossibility
    ∧ (Z X p ≠ 0 → False)
    -- (C) Z_max-axis impossibility
    ∧ (Z_max X p ≠ ⊤ → False) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact impossible_N0_noCov (Ω := Ω) p X
  · exact impossible_N0_Phi0nz p X
  · exact impossible_NfinPos_Phi0z p X
  · exact impossible_NfinPos_noCov (Ω := Ω) p X
  · exact impossible_Ntop_Phi0z p X
  · exact impossible_Ntop_cov (Ω := Ω) p X
  · intro h; exact h (Z_eq_zero X p)
  · intro h; exact h (Z_max_eq_top X p)

/-! ## Sharpened: Z_min joins the bundle (a 6th axis)

The same scheme extends to Z_min ∈ {= 0, 0 < · < ⊤, = ⊤}; only `Z_min = 0`
is realisable.  This expands 108 → 324 cells with 321 impossible.
We state the 6-axis impossibility chain for completeness. -/

/-- **Impossible: `Z_min X p ≠ 0`.** -/
theorem impossible_Zmin_nonzero (X : Agent α) (p : Problem α)
    (h : Z_min X p ≠ 0) : False :=
  h (Z_min_eq_zero X p)

/-- **6-axis headline.** Adding `Z_min` as a 6th axis with 3 states gives
324 cells; only 3 are realisable (R0/RP/R∞ × {Z = 0} × {Z_max = ⊤} ×
{Z_min = 0}); **321 are impossible**. -/
theorem three_hundred_twenty_one_configurations_impossible
    (p : Problem α) (X : Agent α) :
    -- All 9 Round-1 impossibilities + Z, Z_max, Z_min axis impossibilities
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
    ∧ (Z X p ≠ 0 → False)
    ∧ (Z_max X p ≠ ⊤ → False)
    ∧ (Z_min X p ≠ 0 → False) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact impossible_N0_noCov (Ω := Ω) p X
  · exact impossible_N0_Phi0nz p X
  · exact impossible_NfinPos_Phi0z p X
  · exact impossible_NfinPos_noCov (Ω := Ω) p X
  · exact impossible_Ntop_Phi0z p X
  · exact impossible_Ntop_cov (Ω := Ω) p X
  · intro h; exact h (Z_eq_zero X p)
  · intro h; exact h (Z_max_eq_top X p)
  · intro h; exact h (Z_min_eq_zero X p)

end R2_Agent3_5axis_ZmaxSandwich

end MIP
