/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: Strongest A.1+A.2 octant exclusion — joint triple impossibility on (N, Phi0, coverage).
  SUMMARY:
    Of the 2·2·2 = 8 octants in the boolean cube
      ((N = 0)?,  (Phi0 = 0)?,  coverage?),
    A.1 alone (`N=0 ↔ Phi0=0`) kills 4 (the two off-diagonals of the
    (N, Phi0) face, each at both coverage values).  A.2 alone
    (`N≠⊤ ↔ coverage`) is *not* sharp enough to kill cells on the
    (N=0 ?)-axis (since `N = 0 → N ≠ ⊤` so coverage always exists at
    `N = 0`); but combined with the A.1-eliminated cells it sharpens
    the remaining 4 octants down to 3 realisable ones.  In particular,
    the *single octant* `(N = 0, Phi0 ≠ 0, ¬coverage)` is killed by both
    axioms simultaneously (A.1 turns `N = 0 → Phi0 = 0`, A.2 turns
    `N = 0 → coverage`); but this is just the strongest A.1+A.2
    impossibility — it requires both axioms to fire.

    The headline triple-impossibility is the asymmetric octant:
      "`N p X = 0 ∧ Phi0 X p ≠ 0 ∧ ¬ coverage` is impossible"
    — refuted by A.1 alone (the `Phi0 ≠ 0` claim contradicts `N = 0`)
    but the *coverage* failure is independently refuted by A.2 alone.
    This is the canonical "double refutation" octant — both axioms
    independently rule it out.

    Bonus: the all-affirmative "everything fails" octant
      `(N = ⊤, Phi0 = 0, ¬coverage)` is also doubly refuted (A.1
    rules out `N=⊤ ∧ Phi0=0`, A.2 rules out `N=⊤ ∧ coverage`
    contrapositive).

    We state both as `False`-conclusion lemmas and the bundled "8 → 3"
    cube enumeration.
-/
import MIP.Axioms

namespace MIP

namespace Agent9_TripleImpossibility

variable {α : Type} {Ω : Type}

/-! ## (1) The single strongest triple-impossible octant.

`N = 0 ∧ Phi0 ≠ 0 ∧ ¬ coverage` is refutable by either axiom alone — the
"doubly impossible" octant.  We prove it both ways for completeness. -/

/-- **Triple impossibility (route 1: via A.1).** -/
theorem triple_impossible_via_A1
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0) (hPhi : Phi0 X p ≠ 0)
    (_hNoCov : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    False :=
  hPhi ((Axioms.A1 p X).mp hN)

/-- **Triple impossibility (route 2: via A.2).** -/
theorem triple_impossible_via_A2
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0) (_hPhi : Phi0 X p ≠ 0)
    (hNoCov : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    False := by
  have hFin : N p X ≠ ⊤ := by rw [hN]; decide
  obtain ⟨R', hR', hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hFin
  exact hNoCov R' hR' hSub

/-! ## (2) The dual doubly-impossible octant: `N = ⊤ ∧ Phi0 = 0 ∧ coverage`. -/

/-- **Dual triple impossibility (route 1: via A.1).** -/
theorem dual_triple_impossible_via_A1
    (p : Problem α) (X : Agent α)
    (hN : N p X = ⊤) (hPhi : Phi0 X p = 0)
    (_hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    False := by
  have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  rw [hN] at hN0
  exact ENat.top_ne_zero hN0

/-- **Dual triple impossibility (route 2: via A.2).** -/
theorem dual_triple_impossible_via_A2
    (p : Problem α) (X : Agent α)
    (hN : N p X = ⊤) (_hPhi : Phi0 X p = 0)
    (hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    False := by
  have : N p X ≠ ⊤ := (Axioms.A2 (Ω := Ω) p X).mpr hCov
  exact this hN

/-! ## (3) Boolean-cube enumeration: 8 octants, only 3 realisable.

We define the 8 = 2·2·2 cube using booleans `(b_N, b_Phi0, b_cov)` and
package the impossibility map. The realisable cells are exactly:
  * `(true, true, true)`     — R0    (N=0, Phi0=0, coverage)
  * `(false, false, true)`   — RP    (N≠0, Phi0≠0, coverage)
  * `(false, false, false)`  — R∞    (N≠0, Phi0≠0, ¬coverage)

(Here `b_N` = "N=0?", `b_Phi0` = "Phi0=0?", `b_cov` = "coverage?".) -/

/-- Boolean-cube cell predicate. `cell p X b_N b_Phi0 b_cov` asserts the
joint truth values of the three booleans at `(p, X)`. -/
def cell (p : Problem α) (X : Agent α)
    (b_N b_Phi0 b_cov : Bool) : Prop :=
  ((N p X = 0) ↔ b_N = true)
    ∧ ((Phi0 X p = 0) ↔ b_Phi0 = true)
    ∧ ((∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) ↔ b_cov = true)

/-! ### Impossibilities for the 5 non-realisable cells.

The 5 impossible cells are:
* `(true,  false, true)`   — N=0 ∧ Phi0≠0 ∧ cov     [A.1.mp]
* `(true,  false, false)`  — N=0 ∧ Phi0≠0 ∧ ¬cov    [doubly: A.1.mp + A.2]
* `(true,  true,  false)`  — N=0 ∧ Phi0=0 ∧ ¬cov    [A.2: N=0 ⇒ ¬⊤ ⇒ cov]
* `(false, true,  true)`   — N≠0 ∧ Phi0=0 ∧ cov     [A.1.mpr]
* `(false, true,  false)`  — N≠0 ∧ Phi0=0 ∧ ¬cov    [A.1.mpr]
* `(false, false, true)`   — N≠0 ∧ Phi0≠0 ∧ cov     ✓ RP-cell
* `(false, false, false)`  — N≠0 ∧ Phi0≠0 ∧ ¬cov    ✓ R∞-cell
* `(true,  true,  true)`   — N=0 ∧ Phi0=0 ∧ cov     ✓ R0-cell

So 5 impossible + 3 realisable = 8 total. -/

/-- Helper: in cell `(true, false, _)` the `b_Phi0 = false` axis means
`Phi0 X p ≠ 0`. Unfold the iff.  -/
private lemma phi0_ne_of_false (p : Problem α) (X : Agent α)
    (h : (Phi0 X p = 0) ↔ false = true) : Phi0 X p ≠ 0 := by
  intro hPhi
  exact Bool.false_ne_true (h.mp hPhi)

/-- Helper: `(N p X = 0) ↔ true = true` simplifies to `N p X = 0`. -/
private lemma N_zero_of_true (p : Problem α) (X : Agent α)
    (h : (N p X = 0) ↔ true = true) : N p X = 0 :=
  h.mpr rfl

/-- Helper: in cell `(_, true, _)` the `b_Phi0 = true` axis means `Phi0 X p = 0`. -/
private lemma phi0_zero_of_true (p : Problem α) (X : Agent α)
    (h : (Phi0 X p = 0) ↔ true = true) : Phi0 X p = 0 :=
  h.mpr rfl

/-- Helper: `(N p X = 0) ↔ false = true` simplifies to `N p X ≠ 0`. -/
private lemma N_ne_zero_of_false (p : Problem α) (X : Agent α)
    (h : (N p X = 0) ↔ false = true) : N p X ≠ 0 := by
  intro hN; exact Bool.false_ne_true (h.mp hN)

/-- Helper: `(∃ R', _) ↔ true = true` simplifies to coverage. -/
private lemma cov_of_true (p : Problem α) (X : Agent α)
    (h : (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) ↔ true = true) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) :=
  h.mpr rfl

/-- Helper: `(∃ R', _) ↔ false = true` simplifies to no coverage. -/
private lemma no_cov_of_false (p : Problem α) (X : Agent α)
    (h : (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) ↔ false = true) :
    ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω) := by
  intro R' hR' hSub
  exact Bool.false_ne_true (h.mp ⟨R', hR', hSub⟩)

/-- **Cell `(true, false, true)` impossible.** `N = 0 ∧ Phi0 ≠ 0 ∧ cov`. -/
theorem cell_TFT_impossible (p : Problem α) (X : Agent α) :
    ¬ cell (Ω := Ω) p X true false true := by
  rintro ⟨hN, hPhi, _⟩
  exact phi0_ne_of_false p X hPhi ((Axioms.A1 p X).mp (N_zero_of_true p X hN))

/-- **Cell `(true, false, false)` impossible.** `N = 0 ∧ Phi0 ≠ 0 ∧ ¬cov`. -/
theorem cell_TFF_impossible (p : Problem α) (X : Agent α) :
    ¬ cell (Ω := Ω) p X true false false := by
  rintro ⟨hN, hPhi, _⟩
  exact phi0_ne_of_false p X hPhi ((Axioms.A1 p X).mp (N_zero_of_true p X hN))

/-- **Cell `(true, true, false)` impossible.** `N = 0 ∧ Phi0 = 0 ∧ ¬cov`. -/
theorem cell_TTF_impossible (p : Problem α) (X : Agent α) :
    ¬ cell (Ω := Ω) p X true true false := by
  rintro ⟨hN, _, hCov⟩
  have h0 : N p X = 0 := N_zero_of_true p X hN
  have hFin : N p X ≠ ⊤ := by rw [h0]; decide
  obtain ⟨R', hR', hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hFin
  exact no_cov_of_false (Ω := Ω) p X hCov R' hR' hSub

/-- **Cell `(false, true, true)` impossible.** `N ≠ 0 ∧ Phi0 = 0 ∧ cov`. -/
theorem cell_FTT_impossible (p : Problem α) (X : Agent α) :
    ¬ cell (Ω := Ω) p X false true true := by
  rintro ⟨hN, hPhi, _⟩
  exact N_ne_zero_of_false p X hN ((Axioms.A1 p X).mpr (phi0_zero_of_true p X hPhi))

/-- **Cell `(false, true, false)` impossible.** `N ≠ 0 ∧ Phi0 = 0 ∧ ¬cov`. -/
theorem cell_FTF_impossible (p : Problem α) (X : Agent α) :
    ¬ cell (Ω := Ω) p X false true false := by
  rintro ⟨hN, hPhi, _⟩
  exact N_ne_zero_of_false p X hN ((Axioms.A1 p X).mpr (phi0_zero_of_true p X hPhi))

/-! ## (4) Headline bundle.

For each `(p, X)`, exactly one of the 3 realisable cells holds.  This is
the *positive* shape of "8 cells → 3 realisable". -/

/-- **Cube reduction: 8 cells → 3 realisable.** For every `(p, X)`, the
joint cell of `(N=0?, Phi0=0?, coverage?)` lies in
`{(true,true,true), (false,false,true), (false,false,false)}`. -/
theorem cube_reduces_to_three (p : Problem α) (X : Agent α) :
    cell (Ω := Ω) p X true true true
      ∨ cell (Ω := Ω) p X false false true
      ∨ cell (Ω := Ω) p X false false false := by
  by_cases hTop : N p X = ⊤
  · -- N = ⊤ → N ≠ 0, Phi0 ≠ 0 (A.1), ¬coverage (A.2). Cell (false, false, false).
    refine Or.inr (Or.inr ?_)
    refine ⟨?_, ?_, ?_⟩
    · constructor
      · intro hN0; rw [hN0] at hTop; exact absurd hTop (by decide)
      · intro h; exact absurd h Bool.false_ne_true
    · constructor
      · intro hPhi
        have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
        rw [hTop] at hN0; exact absurd (ENat.top_ne_zero hN0) (fun x => x)
      · intro h; exact absurd h Bool.false_ne_true
    · constructor
      · rintro ⟨R', hR', hSub⟩
        exact absurd ((Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hR', hSub⟩) (fun x => x hTop)
      · intro h; exact absurd h Bool.false_ne_true
  · -- N ≠ ⊤ → coverage by A.2.
    have hCov : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) :=
      (Axioms.A2 (Ω := Ω) p X).mp hTop
    by_cases hZero : N p X = 0
    · -- R0
      refine Or.inl ?_
      refine ⟨?_, ?_, ?_⟩
      · exact ⟨fun _ => rfl, fun _ => hZero⟩
      · exact ⟨fun _ => rfl, fun _ => (Axioms.A1 p X).mp hZero⟩
      · exact ⟨fun _ => rfl, fun _ => hCov⟩
    · -- RP
      refine Or.inr (Or.inl ?_)
      refine ⟨?_, ?_, ?_⟩
      · constructor
        · intro hN0; exact absurd hN0 hZero
        · intro h; exact absurd h Bool.false_ne_true
      · constructor
        · intro hPhi; exact absurd ((Axioms.A1 p X).mpr hPhi) hZero
        · intro h; exact absurd h Bool.false_ne_true
      · exact ⟨fun _ => rfl, fun _ => hCov⟩

end Agent9_TripleImpossibility

end MIP
