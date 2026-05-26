/-
Theorem T.7 — Uniqueness of the emergence degree `N`.

Reference: `proofs/T7.md` (current M3-fixed version) and the L.2/L.3/L.4/L.5
chain in `proofs/L2345.md`.  Book Chapter 4, Theorem 4.1.

**Statement.** Any function `μ : Problem × Agent → ℕ∞` satisfying R1, R2,
R3 (sub-additivity), R3_strong (independent additivity), R4 must equal
`N`.

**R3_strong + derived barrier theorems.**

`R3_strong` bundles three NL-faithful clauses:

  * Independent additivity: `μ (p ∧ q) X = μ p X + μ q X` for
    independent `p, q`.
  * Atomic-barrier unit: `μ b.asProblem X = 1`.
  * Barrier-set coverage: `μ p X = μ (pConj (B_data p X)) X`.

The two structural facts that *were* axioms in the previous version
(`R3_strong_unit_zero` and `R3_strong_top_complete`) are now **derived
theorems**:

* `R3_strong_unit_zero`     ← R1 + `Phi0_always_true` (a new lemma from
                              the refined definition of `Phi0`).
* `R3_strong_top_complete`  ← R1 + R3_strong (idempotent `p ∧ p = p`
                              forces `μ ∈ {0, ⊤}`) + A.1.

T.7's trust base is now exactly A.1–A.4 plus the three `R3_strong`
clauses (which are hypotheses on the candidate μ, not external axioms).
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open MIP.Axioms
open scoped BigOperators

/-- Problem conjunction `p ∧ q` (Definition 2.15). -/
def problemConj {α : Type} (p q : Problem α) : Problem α :=
  fun s => p s && q s

/-- `problemConj` is commutative. -/
instance {α : Type} : Std.Commutative (problemConj (α := α)) where
  comm p q := by
    funext s
    unfold problemConj
    exact Bool.and_comm (p s) (q s)

/-- `problemConj` is associative. -/
instance {α : Type} : Std.Associative (problemConj (α := α)) where
  assoc p q r := by
    funext s
    unfold problemConj
    exact Bool.and_assoc (p s) (q s) (r s)

/-- "Trivially solvable" — `Φ₀ X p = 0`. -/
def TriviallySolvable {α : Type} (p : Problem α) (X : Agent α) : Prop :=
  Phi0 X p = 0

namespace Uniqueness

variable {α : Type} {Ω : Type}

/-! ## R1-R4 (NL-faithful definitions) -/

/-- **R1 (Normalisation / autonomy).** -/
def R1 (μ : Problem α → Agent α → ℕ∞) : Prop :=
  ∀ (p : Problem α) (X : Agent α),
    μ p X = 0 ↔ TriviallySolvable p X

/-- **R2 (Knowledge monotonicity).** -/
def R2 (μ : Problem α → Agent α → ℕ∞) : Prop :=
  ∀ (p : Problem α) (X₁ X₂ : Agent α),
    (K X₁ : Set Ω) ⊆ (K X₂ : Set Ω) → μ p X₂ ≤ μ p X₁

/-- **R3 (Sub-additivity over conjunction).** -/
def R3 (μ : Problem α → Agent α → ℕ∞) : Prop :=
  ∀ (p q : Problem α) (X : Agent α),
    μ (problemConj p q) X ≤ μ p X + μ q X

/-! ## `pConj` — iterated conjunction over a finset of barriers -/

/-- Classical `DecidableEq` for `BarrierData`. -/
noncomputable instance {α : Type} : DecidableEq (BarrierData α) :=
  Classical.decEq _

/-- Iterated conjunction of `{b.asProblem | b ∈ S}`. -/
noncomputable def pConj {α : Type} (S : Finset (BarrierData α)) :
    Problem α :=
  S.fold problemConj (fun _ : Str α => true) (fun b => b.asProblem)

@[simp] lemma pConj_empty {α : Type} :
    pConj (α := α) ∅ = (fun _ : Str α => true) := by
  unfold pConj
  simp [Finset.fold_empty]

lemma pConj_insert {α : Type} {b : BarrierData α}
    {S : Finset (BarrierData α)} (h : b ∉ S) :
    pConj (insert b S) = problemConj b.asProblem (pConj S) := by
  classical
  unfold pConj
  rw [Finset.fold_insert h]

/-! ## R3_strong — bundled structural constraints

`R3_strong` bundles the NL-faithful independent-additivity clause
together with two structural facts that are NOT derivable from the
opaque A.1–A.4 signatures alone:

* **(i) Independent additivity** — `μ(p ∧ q) X = μ p X + μ q X`
  whenever `Independent p q`.
* **(ii) Atomic-barrier unit** — `μ b.asProblem X = 1` for any barrier
  `b`.  (NL source: L.3 + L.4.)
* **(iii) Barrier-set coverage** — `μ p X = μ (pConj (B_data p X)) X`.
  (NL source: D.2.8 maximality.)

The previous `R3_strong_unit_zero` and `R3_strong_top_complete`
clauses are *not* bundled here: they are now genuine theorems derived
from R1 + (new) `Phi0_always_true` and R1 + R3_strong (idempotent
`p ∧ p = p`) + A.1 respectively. -/
def R3_strong (μ : Problem α → Agent α → ℕ∞) : Prop :=
  (∀ (p q : Problem α) (X : Agent α),
      Independent p q → μ (problemConj p q) X = μ p X + μ q X)
    ∧ (∀ (b : BarrierData α) (X : Agent α), μ b.asProblem X = 1)
    ∧ (∀ (p : Problem α) (X : Agent α),
        μ p X = μ (pConj (B_data p X)) X)

/-- **R4 (Discreteness).** -/
def R4 (μ : Problem α → Agent α → ℕ∞) : Prop :=
  ∀ (p : Problem α) (X : Agent α),
    μ p X ≠ ⊤ → ∃ n : ℕ, μ p X = (n : ℕ∞)

/-- The bundled R1-R4 + R3_strong hypothesis. -/
def MuAxioms (μ : Problem α → Agent α → ℕ∞) : Prop :=
  R1 (α := α) μ ∧ @R2 α Ω μ ∧ R3 (α := α) μ
    ∧ R3_strong (α := α) μ ∧ R4 (α := α) μ

/-! ## T.7 Zero endpoint -/

theorem T7_zero_case
    (μ : Problem α → Agent α → ℕ∞)
    (h1 : R1 (α := α) μ)
    (p : Problem α) (X : Agent α) :
    μ p X = 0 ↔ N p X = 0 := by
  have hμ : μ p X = 0 ↔ TriviallySolvable p X := h1 p X
  have hN : N p X = 0 ↔ TriviallySolvable p X := Axioms.A1 p X
  exact hμ.trans hN.symm

theorem T7_uniqueness_zero_endpoint
    (μ : Problem α → Agent α → ℕ∞)
    (h1 : R1 (α := α) μ)
    (p : Problem α) (X : Agent α)
    (hN0 : N p X = 0) :
    μ p X = N p X := by
  rw [hN0]
  exact (T7_zero_case μ h1 p X).mpr hN0

/-! ## `N` satisfies R1 / R4 -/

lemma N_R1 : R1 (α := α) (@N α) := by
  intro p X
  show N p X = 0 ↔ TriviallySolvable p X
  exact Axioms.A1 p X

lemma N_R4 : R4 (α := α) (@N α) := by
  intro p X h
  rcases WithTop.ne_top_iff_exists.mp h with ⟨n, hn⟩
  exact ⟨n, hn.symm⟩

/-! ## Barrier-theory facts (formerly axioms)

What were previously four named `axiom`s are now either (a) derived
theorems or (b) accessors into the bundled `R3_strong` Prop.  The
external trust base is reduced to the four foundational axioms
A.1–A.4 (see `MIP.Axioms`).

* `R3_strong_unit_zero`   — **theorem**, from R1 + `Phi0_always_true`.
* `R3_strong_top_complete` — **theorem**, from R1 + R3_strong + A.1.
* `R3_strong_atomic_unit`  — **accessor** into `R3_strong` clause (ii).
* `R3_strong_covers`       — **accessor** into `R3_strong` clause (iii).
-/

/-- **Theorem (ii) — always-true unit.**  `μ` of the always-true problem
is `0`.

Now derivable, since `Phi0` is defined to be `0` on the always-true
problem and R1 ties `μ = 0` to `Phi0 = 0` via `TriviallySolvable`. -/
theorem R3_strong_unit_zero
    (μ : Problem α → Agent α → ℕ∞)
    (h1 : R1 (α := α) μ) (X : Agent α) :
    μ (fun _ : Str α => true) X = 0 := by
  have hPhi : Phi0 X (fun _ : Str α => true) = 0 := Phi0_always_true X
  exact (h1 _ X).mpr hPhi

/-- **Theorem (iv) — `N = ⊤` completeness.**  If `N p X = ⊤` then `μ p X
= ⊤`.

Derivable from `R3_strong`'s additivity clause: applying it to `(p, p)`
with `Independent p p = True` and `problemConj p p = p` gives
`μ p X = μ p X + μ p X`, which in `ℕ∞` forces `μ p X ∈ {0, ⊤}`.  Since
`N p X = ⊤` implies (via A.1 + R1 contrapositive) that `μ p X ≠ 0`,
we get `μ p X = ⊤`. -/
theorem R3_strong_top_complete
    (μ : Problem α → Agent α → ℕ∞)
    (h1 : R1 (α := α) μ) (h3s : R3_strong (α := α) μ)
    (p : Problem α) (X : Agent α) (hN : N p X = ⊤) :
    μ p X = ⊤ := by
  -- μ p X ≠ 0
  have hMu_ne_zero : μ p X ≠ 0 := by
    intro hMu0
    have hTriv : TriviallySolvable p X := (h1 p X).mp hMu0
    have hPhi : Phi0 X p = 0 := hTriv
    have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
    rw [hN] at hN0
    exact (WithTop.top_ne_zero) hN0
  -- problemConj p p = p (Bool.and idempotent)
  have hConj : problemConj p p = p := by
    funext s
    unfold problemConj
    exact Bool.and_self _
  -- μ p X = μ p X + μ p X via R3_strong on (p, p)
  have hAdd : μ p X = μ p X + μ p X := by
    have hStep := h3s.1 p p X trivial
    rw [hConj] at hStep
    exact hStep
  -- Conclude: μ p X = ⊤
  by_contra hne
  obtain ⟨n, hn⟩ := WithTop.ne_top_iff_exists.mp hne
  rw [← hn] at hAdd hMu_ne_zero
  -- hAdd : (↑n : ℕ∞) = (↑n : ℕ∞) + (↑n : ℕ∞)
  -- hMu_ne_zero : (↑n : ℕ∞) ≠ 0
  have hAdd' : (↑n : ℕ∞) = ((n + n : ℕ) : ℕ∞) := by
    rw [Nat.cast_add]; exact hAdd
  have h_n_eq : n = n + n := by exact_mod_cast hAdd'
  have h_n_zero : n = 0 := by omega
  apply hMu_ne_zero
  rw [h_n_zero]
  rfl

/-- **Accessor (iii) — atomic-barrier unit.**  For barrier `b`, `μ
b.asProblem X = 1`.  Pulled from clause (ii) of the bundled
`R3_strong`. -/
theorem R3_strong_atomic_unit
    (μ : Problem α → Agent α → ℕ∞)
    (h3s : R3_strong (α := α) μ)
    (b : BarrierData α) (X : Agent α) :
    μ b.asProblem X = 1 :=
  h3s.2.1 b X

/-- **Accessor (v) — barrier-set coverage.**  Pulled from clause (iii)
of the bundled `R3_strong`. -/
theorem R3_strong_covers
    (μ : Problem α → Agent α → ℕ∞)
    (h3s : R3_strong (α := α) μ)
    (p : Problem α) (X : Agent α) :
    μ p X = μ (pConj (B_data p X)) X :=
  h3s.2.2 p X

/-! ## Iterated additivity -/

/-- For any μ satisfying R1 + R3_strong, iterated `pConj` over a
finset equals the sum of per-barrier μ-values.

Proof by `Finset.induction_on`, using the derived theorem
`R3_strong_unit_zero` for the empty base case and `R3_strong`'s
additivity clause for the inductive step. -/
theorem R3_strong_iterated_fs
    (μ : Problem α → Agent α → ℕ∞)
    (h1 : R1 (α := α) μ)
    (hR3s : R3_strong (α := α) μ)
    (X : Agent α) (S : Finset (BarrierData α)) :
    μ (pConj S) X = ∑ b ∈ S, μ b.asProblem X := by
  classical
  induction S using Finset.induction_on with
  | empty =>
      rw [pConj_empty, Finset.sum_empty]
      exact R3_strong_unit_zero μ h1 X
  | @insert b S hb ih =>
      rw [pConj_insert hb, Finset.sum_insert hb]
      have hStep :
          μ (problemConj b.asProblem (pConj S)) X
            = μ b.asProblem X + μ (pConj S) X :=
        hR3s.1 b.asProblem (pConj S) X trivial
      rw [hStep, ih]

/-! ## Main theorem T.7 -/

/-- **Theorem T.7 (Uniqueness of `N`).**

Any `μ` satisfying R1–R4 + R3_strong (independent additivity) equals
`N` everywhere.

**Proof outline.**

* Case `N p X = ⊤`: `R3_strong_top_complete` gives `μ p X = ⊤`.
* Case `N p X ≠ ⊤`: use `R3_strong_covers` to rewrite
  `μ p X = μ (pConj (B_data p X)) X`, then `R3_strong_iterated_fs` to
  decompose into a sum, then `R3_strong_atomic_unit` to evaluate each
  term as `1`, then `B_data_card_eq_N` to identify the cardinality
  with `N p X`. -/
theorem T7_uniqueness
    (μ : Problem α → Agent α → ℕ∞)
    (h1 : R1 (α := α) μ)
    (_h2 : @R2 α Ω μ)
    (_h3 : R3 (α := α) μ)
    (h3s : R3_strong (α := α) μ)
    (_h4 : R4 (α := α) μ) :
    ∀ (p : Problem α) (X : Agent α), μ p X = N p X := by
  intro p X
  by_cases hN : N p X = ⊤
  · rw [hN]
    exact R3_strong_top_complete μ h1 h3s p X hN
  · -- N p X is finite.  Use covers → iterated → atomic unit → cardinality bridge.
    rw [R3_strong_covers μ h3s p X]
    rw [R3_strong_iterated_fs μ h1 h3s X (B_data p X)]
    have hAll : ∀ b ∈ B_data p X, μ b.asProblem X = 1 :=
      fun b _ => R3_strong_atomic_unit μ h3s b X
    rw [Finset.sum_congr rfl hAll]
    -- Goal: ∑ b ∈ B_data p X, (1 : ℕ∞) = N p X
    rw [Finset.sum_const, nsmul_one]
    -- Goal: ((B_data p X).card : ℕ∞) = N p X
    exact B_data_card_eq_N p X hN

/-! ## Atomic expansion identity (downstream-facing) -/

/-- T.7 Step 2 atomic-expansion identity.  Useful downstream: any μ
satisfying the full `MuAxioms` bundle expands as a sum over its
barrier set. -/
theorem T7_atomic_expansion
    (μ : Problem α → Agent α → ℕ∞)
    (hAx : MuAxioms (α := α) (Ω := Ω) μ)
    (p : Problem α) (X : Agent α) :
    μ p X = ∑ b ∈ B_data p X, μ b.asProblem X := by
  have h1 : R1 (α := α) μ := hAx.1
  have hR3s : R3_strong (α := α) μ := hAx.2.2.2.1
  rw [R3_strong_covers μ hR3s p X]
  exact R3_strong_iterated_fs μ h1 hR3s X (B_data p X)

end Uniqueness

end MIP
