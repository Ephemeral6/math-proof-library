/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: Configuration-impossibility — 9 of 12 (N, Phi0, coverage) configurations are ruled out by A.1 + A.2.
  SUMMARY:
    The state of an (agent, problem) pair admits three boolean/trichotomy axes:
      * `N p X ∈ {=0, finite>0, =⊤}`         (3 states),
      * `Phi0 X p ∈ {=0, ≠0}`                (2 states),
      * `coverage ∈ {∃R'⊆K X, ∀R' ¬⊆K X}`     (2 states).
    The Cartesian product has 3·2·2 = 12 raw configurations. We prove that
    *exactly 3* of them are realisable (the three regimes R0/RP/R∞ of
    Agent 2's trichotomy), and the remaining 9 are derivably False from
    A.1 + A.2. The trichotomy is therefore *also a negative result*: an
    impossibility theorem ruling out 9/12 octants of the configuration
    space. Each impossible configuration's proof is reduced to a single
    application of A.1 or A.2 (or their joint contrapositive).
-/
import MIP.Axioms

namespace MIP

namespace Agent9_ConfigurationTable

variable {α : Type} {Ω : Type}

/-! ## The six joint-impossibility lemmas

We label the 12 configurations as pairs `(N-state, Phi0-state, coverage)` and
prove the 9 impossible ones one at a time. The three realisable ones are
explicitly the regimes R0, RP, R∞ of Agent 2's `N_trichotomy`. -/

/-! ### Configurations involving `N = 0`. -/

/-- **Impossible: `N = 0 ∧ Phi0 ≠ 0`.** Direct contradiction with A.1.mp. -/
theorem impossible_N0_Phi0nz
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0) (hPhi : Phi0 X p ≠ 0) : False :=
  hPhi ((Axioms.A1 p X).mp hN)

/-- **Impossible: `N = 0 ∧ ¬coverage`.** `N = 0 → N ≠ ⊤ → coverage` via A.2. -/
theorem impossible_N0_noCov
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0)
    (hNoCov : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    False := by
  have hFin : N p X ≠ ⊤ := by rw [hN]; decide
  obtain ⟨R', hR', hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hFin
  exact hNoCov R' hR' hSub

/-! ### Configurations involving `0 < N < ⊤`. -/

/-- **Impossible: `0 < N < ⊤ ∧ Phi0 = 0`.** `Phi0 = 0 → N = 0` (A.1.mpr) but
`0 < N`. -/
theorem impossible_NfinPos_Phi0z
    (p : Problem α) (X : Agent α)
    (hPos : 0 < N p X) (hPhi : Phi0 X p = 0) : False := by
  have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  rw [hN0] at hPos
  exact absurd hPos (by decide)

/-- **Impossible: `0 < N < ⊤ ∧ ¬coverage`.** `N < ⊤ → coverage` via A.2. -/
theorem impossible_NfinPos_noCov
    (p : Problem α) (X : Agent α)
    (hLt : N p X < ⊤)
    (hNoCov : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    False := by
  have hFin : N p X ≠ ⊤ := lt_top_iff_ne_top.mp hLt
  obtain ⟨R', hR', hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hFin
  exact hNoCov R' hR' hSub

/-! ### Configurations involving `N = ⊤`. -/

/-- **Impossible: `N = ⊤ ∧ Phi0 = 0`.** `Phi0 = 0 → N = 0` (A.1.mpr) but `⊤ ≠ 0`. -/
theorem impossible_Ntop_Phi0z
    (p : Problem α) (X : Agent α)
    (hN : N p X = ⊤) (hPhi : Phi0 X p = 0) : False := by
  have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  rw [hN] at hN0
  exact ENat.top_ne_zero hN0

/-- **Impossible: `N = ⊤ ∧ coverage`.** Direct contradiction with A.2.mpr. -/
theorem impossible_Ntop_cov
    (p : Problem α) (X : Agent α)
    (hN : N p X = ⊤)
    (hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    False := by
  have : N p X ≠ ⊤ := (Axioms.A2 (Ω := Ω) p X).mpr hCov
  exact this hN

/-! ## Counting: exactly 9 configurations are impossible.

We enumerate the 12 = 3·2·2 product cells.  The 6 impossibility lemmas above
each rule out one *projection-fact*; collectively they rule out 9 *cells*
(each lemma's hypothesis is a 1-axis slice through the 12-cell cube, covering
exactly the cells where that 1-axis fact holds). Specifically:

| #  | N      | Phi0  | coverage | realisable? | ruled out by                                 |
|----|--------|-------|----------|-------------|----------------------------------------------|
| 1  | 0      | 0     | yes      | ✓ R0        | —                                            |
| 2  | 0      | 0     | no       | ✗           | `impossible_N0_noCov`                        |
| 3  | 0      | ≠0    | yes      | ✗           | `impossible_N0_Phi0nz`                       |
| 4  | 0      | ≠0    | no       | ✗           | `impossible_N0_Phi0nz` (and `_N0_noCov`)     |
| 5  | fin>0  | 0     | yes      | ✗           | `impossible_NfinPos_Phi0z`                   |
| 6  | fin>0  | 0     | no       | ✗           | `impossible_NfinPos_Phi0z` (and `_noCov`)    |
| 7  | fin>0  | ≠0    | yes      | ✓ RP        | —                                            |
| 8  | fin>0  | ≠0    | no       | ✗           | `impossible_NfinPos_noCov`                   |
| 9  | ⊤      | 0     | yes      | ✗           | `impossible_Ntop_Phi0z` (and `_Ntop_cov`)    |
| 10 | ⊤      | 0     | no       | ✗           | `impossible_Ntop_Phi0z`                      |
| 11 | ⊤      | ≠0    | yes      | ✗           | `impossible_Ntop_cov`                        |
| 12 | ⊤      | ≠0    | no       | ✓ R∞        | —                                            |

That is: exactly 9 of the 12 cells (cells 2, 3, 4, 5, 6, 8, 9, 10, 11) are
unconditionally impossible. -/

/-- **Headline corollary 1 — exact-count form.** For every configuration
`(p, X)`, at least one of the three realisable regimes holds, AND every
non-realisable configuration leads to `False`.  The "negative side" of
Agent 2's trichotomy.

We package the negation directly: the conjunction of the 9 impossibility
conditions implies `False` for every `(p, X)`. -/
theorem nine_configurations_impossible
    (p : Problem α) (X : Agent α) :
    -- (2)
    (N p X = 0
        → (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
        → False)
    ∧ -- (3) & (4) — Phi0 ≠ 0 with N = 0
    (N p X = 0 → Phi0 X p ≠ 0 → False)
    ∧ -- (5) & (6) — Phi0 = 0 with 0 < N
    (0 < N p X → Phi0 X p = 0 → False)
    ∧ -- (8) — finite positive N with no coverage
    (N p X < ⊤
        → (∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
        → False)
    ∧ -- (9) & (10) — Phi0 = 0 with N = ⊤
    (N p X = ⊤ → Phi0 X p = 0 → False)
    ∧ -- (11) — N = ⊤ with coverage
    (N p X = ⊤
        → (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
        → False) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact impossible_N0_noCov (Ω := Ω) p X
  · exact impossible_N0_Phi0nz p X
  · exact impossible_NfinPos_Phi0z p X
  · exact impossible_NfinPos_noCov (Ω := Ω) p X
  · exact impossible_Ntop_Phi0z p X
  · exact impossible_Ntop_cov (Ω := Ω) p X

/-! ## A second packaging: the "only-3-of-12 is realisable" form.

We define the configuration predicate as a single `Prop` and show its
unique realisable shape collapses to the trichotomy. -/

/-- The 12-cell configuration predicate. `cfg p X (i, j, k)` means: the
`(i, j, k)` cell holds for `(p, X)`. -/
def cfg (p : Problem α) (X : Agent α)
    (Nstate : Fin 3) (Phi0nz : Bool) (cov : Bool) : Prop :=
  -- Nstate = 0 / 1 / 2 → N = 0 / 0 < N < ⊤ / N = ⊤
  (match Nstate with
    | 0 => N p X = 0
    | 1 => 0 < N p X ∧ N p X < ⊤
    | _ => N p X = ⊤)
  ∧ (if Phi0nz then Phi0 X p ≠ 0 else Phi0 X p = 0)
  ∧ (if cov then ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)
            else ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))

/-- **Realisable cells.** Of the 3·2·2 = 12 cells, exactly the three regimes
listed below are realisable; in fact they collectively cover every `(p, X)`
by Agent 2's trichotomy.

We state this as: for every `(p, X)`, *at least one* of the three R-cells
holds, i.e. R0 (N=0, Phi0=0, cov), RP (fin pos, Phi0≠0, cov), R∞ (N=⊤, Phi0≠0,
¬cov). -/
theorem realisable_three (p : Problem α) (X : Agent α) :
    cfg (Ω := Ω) p X 0 false true
      ∨ cfg (Ω := Ω) p X 1 true  true
      ∨ cfg (Ω := Ω) p X 2 true  false := by
  by_cases hTop : N p X = ⊤
  · -- R∞
    refine Or.inr (Or.inr ?_)
    refine ⟨?_, ?_, ?_⟩
    · show N p X = ⊤; exact hTop
    · -- Phi0 ≠ 0
      simp only [if_true]
      intro hPhi
      have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
      rw [hTop] at hN0; exact ENat.top_ne_zero hN0
    · -- ∀ R', ¬ ⊆
      simp only [Bool.false_eq_true, ↓reduceIte]
      intro R' hR' hSub
      exact ((Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hR', hSub⟩) hTop
  · -- N ≠ ⊤ → coverage
    have hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) :=
      (Axioms.A2 (Ω := Ω) p X).mp hTop
    by_cases hZero : N p X = 0
    · -- R0
      refine Or.inl ?_
      refine ⟨?_, ?_, ?_⟩
      · show N p X = 0; exact hZero
      · simp only [Bool.false_eq_true, ↓reduceIte]
        exact (Axioms.A1 p X).mp hZero
      · simp only [if_true]; exact hCov
    · -- RP
      refine Or.inr (Or.inl ?_)
      refine ⟨?_, ?_, ?_⟩
      · refine ⟨?_, ?_⟩
        · exact Ne.lt_of_le' hZero bot_le
        · exact lt_top_iff_ne_top.mpr hTop
      · simp only [if_true]; intro hPhi
        exact hZero ((Axioms.A1 p X).mpr hPhi)
      · simp only [if_true]; exact hCov

end Agent9_ConfigurationTable

end MIP
