/-
  STATUS: OBSERVATION
  AGENT: R2-5
  DIRECTION: Stopping-time (`firstSolvedStep`, `firstFiniteStep`)
             cross-trajectory monotonicity — what's blocked and what's
             derivable.
  SUMMARY:
    Round-1 Agent 7 defined `firstFiniteStep` and `firstSolvedStep` as
    `Nat.find` over classically decidable predicates.  The natural
    Round 2 question: under what cross-trajectory hypothesis does one
    of these stopping times *dominate* the other?

    **Blocked direction.** Pure `K`-inclusion `K (Xs t) ⊆ K (Ys t)`
    does NOT force `Phi0 (Xs t) p ≥ Phi0 (Ys t) p` (no order
    relationship between K and Φ₀ is derivable from A.1+A.2).
    Symmetrically, Phi0-pointwise dominance does NOT give cross-agent
    N-comparison in Phase II.  Agent 8's cross-agent obstruction
    applies verbatim at the trajectory level.

    **Derivable direction.** Under matching `Phi0`-zero status
    pointwise, `firstSolvedStep` agrees exactly (proved in R2 Agent
    5's `TrajectoryCoupling` file).  Under matching coverage
    status pointwise, `firstFiniteStep` agrees exactly.

    This file states the blocked claim explicitly (as a Prop that is
    NOT a theorem of A.1–A.4) and proves the derivable matching
    versions for `firstFiniteStep`.  No new axioms.
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent5_StoppingTimeBlocked

variable {α : Type}

/-! ## (1) Classical decidability instances. -/

noncomputable instance instDecidableNFinite
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (N p (Xs t) ≠ ⊤) := Classical.dec _

noncomputable instance instDecidableNZero
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (N p (Xs t) = 0) := Classical.dec _

/-! ## (2) Derivable: matching coverage ⇒ `firstFiniteStep` agrees. -/

/-- **`firstFiniteStep` agrees across trajectories with matching
    coverage status pointwise.**  Pure consequence of A.2 indexed at
    every step. -/
theorem firstFiniteStep_eq_of_coverage_pointwise_match
    {Ω : Type} (Xs Ys : ℕ → Agent α) (p : Problem α)
    (h : ∀ t,
      (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))
        ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Ys t) : Set Ω)))
    (hX : ∃ t, N p (Xs t) ≠ ⊤)
    (hY : ∃ t, N p (Ys t) ≠ ⊤) :
    Nat.find hX = Nat.find hY := by
  -- Both `find`s are over the same predicate via A.2 + h.
  have hPair : ∀ t, N p (Xs t) ≠ ⊤ ↔ N p (Ys t) ≠ ⊤ := by
    intro t
    rw [Axioms.A2 (Ω := Ω) p (Xs t), Axioms.A2 (Ω := Ω) p (Ys t)]
    exact h t
  apply Nat.le_antisymm
  · apply Nat.find_le
    exact (hPair _).mpr (Nat.find_spec hY)
  · apply Nat.find_le
    exact (hPair _).mp (Nat.find_spec hX)

/-! ## (3) Blocked: `K`-inclusion does NOT give `firstFiniteStep`-
    inequality.

The hypothetical claim: "if `K (Xs t) ⊆ K (Ys t)` for all `t`, then
`firstFiniteStep Ys p ≤ firstFiniteStep Xs p`" — that is, Ys solves
no-later than Xs.

This is intuitively correct under a "more knowledge is better" reading
of `K`, but A.1–A.4 do not assert any such monotonicity:

  - A.2 gives `N p X ≠ ⊤ ↔ ∃ R' ∈ ℛ(p), R' ⊆ K X`.
  - From `K X ⊆ K Y`, if `R' ⊆ K X` then `R' ⊆ K Y` — so coverage
    for `X` implies coverage for `Y`.
  - So the implication "X has finite N → Y has finite N" IS derivable.

So actually the K-inclusion blocked claim *is* derivable for
`N ≠ ⊤` (Phase ≠ I).  The result is: K-inclusion pointwise ⇒
firstFiniteStep ≤ for Ys.  We state and prove this. -/

/-- **Coverage monotonicity from K-inclusion.**  If `K (Xs t) ⊆ K (Ys t)`
    then any covered demand for `Xs` is covered for `Ys`. -/
theorem coverage_mono_of_K_subset
    {Ω : Type} (Xs Ys : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (h : (K (Xs t) : Set Ω) ⊆ (K (Ys t) : Set Ω)) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))
      → (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Ys t) : Set Ω)) := by
  rintro ⟨R', hR', hSub⟩
  exact ⟨R', hR', hSub.trans h⟩

/-- **`N ≠ ⊤` monotonicity from K-inclusion** (via A.2 in both
    directions). -/
theorem N_finite_mono_of_K_subset
    {Ω : Type} (Xs Ys : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (h : (K (Xs t) : Set Ω) ⊆ (K (Ys t) : Set Ω))
    (hFin : N p (Xs t) ≠ ⊤) :
    N p (Ys t) ≠ ⊤ := by
  have hCovX : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω) :=
    (Axioms.A2 (Ω := Ω) p (Xs t)).mp hFin
  have hCovY : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Ys t) : Set Ω) :=
    coverage_mono_of_K_subset (Ω := Ω) Xs Ys p t h hCovX
  exact (Axioms.A2 (Ω := Ω) p (Ys t)).mpr hCovY

/-- **`firstFiniteStep` is monotone in K-inclusion**: if Xs has K
    contained in Ys's K at every step, then Ys reaches finite-N at or
    before Xs does.  Existence of hY is forced by hK and hX. -/
theorem firstFiniteStep_le_of_K_pointwise_subset
    {Ω : Type} (Xs Ys : ℕ → Agent α) (p : Problem α)
    (hK : ∀ t, (K (Xs t) : Set Ω) ⊆ (K (Ys t) : Set Ω))
    (hX : ∃ t, N p (Xs t) ≠ ⊤) :
    ∃ hY : ∃ t, N p (Ys t) ≠ ⊤, Nat.find hY ≤ Nat.find hX := by
  -- First produce hY from hX via the implication direction (kept around hX).
  have hY : ∃ t, N p (Ys t) ≠ ⊤ := by
    obtain ⟨tX, htX⟩ := hX
    exact ⟨tX, N_finite_mono_of_K_subset (Ω := Ω) Xs Ys p tX (hK tX) htX⟩
  refine ⟨hY, ?_⟩
  apply Nat.find_le
  exact N_finite_mono_of_K_subset (Ω := Ω) Xs Ys p (Nat.find hX) (hK _)
        (Nat.find_spec hX)

/-! ## (4) Blocked direction: Phi0-zero (solved) is NOT monotone in
K-inclusion.

The dual claim — "K-inclusion ⇒ Ys-solves-at-or-before Xs" — would
follow if we could derive `N p (Xs t) = 0 → N p (Ys t) = 0` from
`K (Xs t) ⊆ K (Ys t)`.  But A.1 ties `N = 0` to `Phi0 = 0`, and we have
NO axiom saying Phi0 decreases as K grows.  This is the missing
"K-monotonicity of Φ₀" axiom (≈ "more knowledge can only help")
that A.1–A.4 do not include.

We record this as the central stopping-time obstruction. -/

/-- **Hypothetical Phi0-K-monotonicity** (NOT a theorem of A.1–A.4):
    larger K forces smaller Phi0.  Stated as a Prop that a caller can
    supply (equivalent to assuming a new axiom). -/
def Phi0KMonotone {Ω : Type} (p : Problem α) (X Y : Agent α) : Prop :=
  (K X : Set Ω) ⊆ (K Y : Set Ω) → Phi0 Y p ≤ Phi0 X p

/-- **Conditional**: under the hypothetical Phi0-K-monotonicity, the
    "solved" predicate is upward-monotone in K-inclusion. -/
theorem N_zero_mono_of_Phi0KMonotone
    {Ω : Type} (X Y : Agent α) (p : Problem α)
    (hMono : Phi0KMonotone (Ω := Ω) p X Y)
    (hK : (K X : Set Ω) ⊆ (K Y : Set Ω))
    (h : N p X = 0) :
    N p Y = 0 := by
  have hPhi : Phi0 X p = 0 := (Axioms.A1 p X).mp h
  have hPhi' : Phi0 Y p ≤ 0 := by rw [← hPhi]; exact hMono hK
  have hPhi'' : Phi0 Y p = 0 := nonpos_iff_eq_zero.mp hPhi'
  exact (Axioms.A1 p Y).mpr hPhi''

/-- **Trivial instance**: Phi0KMonotone holds when X = Y. -/
theorem Phi0KMonotone_self
    {Ω : Type} (X : Agent α) (p : Problem α) :
    Phi0KMonotone (Ω := Ω) p X X := by
  intro _; exact le_refl _

/-! ## (5) Summary of derivable vs blocked.

|  Hypothesis (pointwise)                                        | Derivable conclusion (stopping time)                              |
|----------------------------------------------------------------|-------------------------------------------------------------------|
|  `K (Xs t) ⊆ K (Ys t)` ∀ t                                     | `firstFiniteStep Ys ≤ firstFiniteStep Xs`   (proven above)        |
|  `(∃ R'∈ℛ, R'⊆K(Xs t)) ↔ (∃ R'∈ℛ, R'⊆K(Ys t))` ∀ t              | `firstFiniteStep Xs = firstFiniteStep Ys`  (proven above)         |
|  `Phi0 (Xs t) p = 0 ↔ Phi0 (Ys t) p = 0` ∀ t                   | `firstSolvedStep Xs = firstSolvedStep Ys`  (TrajectoryCoupling)   |
|  `K (Xs t) ⊆ K (Ys t)` ∀ t (alone)                             | `firstSolvedStep Ys ≤ firstSolvedStep Xs`  **BLOCKED**            |
|  `Phi0 (Xs t) p ≤ Phi0 (Ys t) p` ∀ t                           | `firstSolvedStep Ys ≤ firstSolvedStep Xs`  **BLOCKED** (Phase II) |

The two blocked rows are the central stopping-time obstructions
under A.1–A.4. -/

end R2_Agent5_StoppingTimeBlocked

end MIP
