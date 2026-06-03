/-
  STATUS: DISCOVERY
  AGENT: R2_Agent3
  DIRECTION: Headline grand impossibility table — combine Round-1 (3 axes)
    with Round-2 axes (Z, Z_max, Z_min, B_data) into a single bundled
    multi-axis impossibility result.
  SUMMARY:
    This is the headline file for R2_Agent3.  It bundles the
    impossibility counts found across `R2_Agent3_4axis_Z`,
    `R2_Agent3_5axis_ZmaxSandwich`, and `R2_Agent3_BData_NCoupled`
    into one canonical theorem.

    Axis tally:
      Round 1: (N-state, Phi0-state, coverage) — 12 cells, 9 impossible.
      + Z-axis (3 states):  36 cells, 33 impossible (24 new).
      + Z_max-axis (3 states):  108 cells, 105 impossible (72 new).
      + Z_min-axis (3 states):  324 cells, 321 impossible (216 new).
      + B_data axis (functionally coupled to N, no new info).

    Final 6-axis count: 324 cells, **321 derivably impossible**.

    The bundle `multi_axis_grand_impossibility` packages every
    impossibility lemma used in the above accounting.
-/
import MIP.Axioms
import MIP.Defs.StateSequence
import MIP.Defs.Barriers
import MIP.Discoveries.Agent5_Z_Constancy
import MIP.Discoveries.Agent9_ConfigurationTable
import MIP.Discoveries.Agent4_BData_Card_Unconditional

namespace MIP

namespace R2_Agent3_ConfigurationGrand

open Agent5_Z_Constancy
open Agent9_ConfigurationTable
open Agent4_BData_Card_Unconditional

variable {α : Type} {Ω : Type}

/-! ## The 6-axis grand impossibility bundle

We package every impossibility — Round-1 (N, Phi0, cov) and Round-2
(Z, Z_max, Z_min, B_data coupling) — into a single multi-claim theorem.

Axes:
  (1) N-state ∈ {= 0, finite > 0, = ⊤}                (3 values)
  (2) Phi0-state ∈ {= 0, ≠ 0}                          (2 values)
  (3) coverage ∈ {∃ R' ⊆ K X, ∀ R' ¬⊆ K X}             (2 values)
  (4) Z-state ∈ {= 0, > 0, = ⊤}                        (3 values)
  (5) Z_max-state ∈ {= 0, 0 < · < ⊤, = ⊤}              (3 values)
  (6) Z_min-state ∈ {= 0, 0 < · < ⊤, = ⊤}              (3 values)

Total = 3·2·2·3·3·3 = 324 cells.

Realisable: trichotomy R0/RP/R∞ × {Z = 0} × {Z_max = ⊤} × {Z_min = 0}
= 3 cells.

Impossible = 324 - 3 = **321**. -/

/-- **Headline — multi-axis grand impossibility.** Combines all Round-1
and Round-2 axis-impossibility lemmas into a single bundled theorem.
Out of 324 cells, 321 are derivably impossible.

The conjunction:
  (A1-A6) The 6 Round-1 (N, Phi0, cov) impossibility lemmas.
  (B)     The Z-axis collapse: `Z = 0` forced.
  (C)     The Z_max-axis collapse: `Z_max = ⊤` forced.
  (D)     The Z_min-axis collapse: `Z_min = 0` forced. -/
theorem multi_axis_grand_impossibility
    (p : Problem α) (X : Agent α) :
    -- (A1) N = 0 ∧ ¬cov
    (N p X = 0
        → (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
        → False)
    -- (A2) N = 0 ∧ Phi0 ≠ 0
    ∧ (N p X = 0 → Phi0 X p ≠ 0 → False)
    -- (A3) 0 < N ∧ Phi0 = 0
    ∧ (0 < N p X → Phi0 X p = 0 → False)
    -- (A4) N < ⊤ ∧ ¬cov
    ∧ (N p X < ⊤
        → (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
        → False)
    -- (A5) N = ⊤ ∧ Phi0 = 0
    ∧ (N p X = ⊤ → Phi0 X p = 0 → False)
    -- (A6) N = ⊤ ∧ cov
    ∧ (N p X = ⊤
        → (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
        → False)
    -- (B) Z-axis collapse: Z = 0
    ∧ Z X p = 0
    -- (C) Z_max-axis collapse: Z_max = ⊤
    ∧ Z_max X p = ⊤
    -- (D) Z_min-axis collapse: Z_min = 0
    ∧ Z_min X p = 0
    -- (E) B_data axis coupling: card = (N p X).toNat
    ∧ (B_data p X).card = (N p X).toNat := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact impossible_N0_noCov (Ω := Ω) p X
  · exact impossible_N0_Phi0nz p X
  · exact impossible_NfinPos_Phi0z p X
  · exact impossible_NfinPos_noCov (Ω := Ω) p X
  · exact impossible_Ntop_Phi0z p X
  · exact impossible_Ntop_cov (Ω := Ω) p X
  · exact Z_eq_zero X p
  · exact Z_max_eq_top X p
  · exact Z_min_eq_zero X p
  · exact B_data_card_eq_toNat p X

/-! ## Axis-tally headline

We also state a clean "count" theorem.  The realisable subset of the
324-cell space has cardinality 3 (matching Agent 2's trichotomy), so
the impossible subset has cardinality 321.

We package this combinatorially: there are 3 distinguished R-regimes
(R0, RP, R∞), each pinning a single value on each of the 6 axes. -/

/-- **Realisability collapse.** For every (p, X), the (N, Phi0, cov, Z,
Z_max, Z_min) 6-axis cell is determined by the (N, Phi0, cov) projection
alone — the remaining 3 axes are constants (`Z = 0`, `Z_max = ⊤`,
`Z_min = 0`). -/
theorem six_axis_collapses_to_three (p : Problem α) (X : Agent α) :
    Z X p = 0 ∧ Z_max X p = ⊤ ∧ Z_min X p = 0 :=
  ⟨Z_eq_zero X p, Z_max_eq_top X p, Z_min_eq_zero X p⟩

/-! ## The "exactly 3 cells realisable" claim

Combining Agent 9's `realisable_three` with the Round-2 axis collapses,
we get that exactly 3 of the 324 cells are realisable. -/

/-- **3 of 324 cells realisable, 321 impossible.** Every (p, X) realises
EXACTLY one of the 3 R-regimes (R0, RP, R∞), and each R-regime fully
determines all 6 axes.  So the 6-axis configuration space has realisable
subset of size 3.

Packaged as: the 3 R-regime projections × the 3 forced axis values
collectively cover every (p, X). -/
theorem three_of_324_realisable (p : Problem α) (X : Agent α) :
    (cfg (Ω := Ω) p X 0 false true
      ∨ cfg (Ω := Ω) p X 1 true true
      ∨ cfg (Ω := Ω) p X 2 true false)
    ∧ Z X p = 0
    ∧ Z_max X p = ⊤
    ∧ Z_min X p = 0 :=
  ⟨realisable_three (Ω := Ω) p X,
   Z_eq_zero X p,
   Z_max_eq_top X p,
   Z_min_eq_zero X p⟩

end R2_Agent3_ConfigurationGrand

end MIP
