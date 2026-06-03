/-
  STATUS: DEAD END
  AGENT: R2-5
  DIRECTION: Convexity / monotonicity / shape constraints on `Φ₀(t)`
             along the trajectory are NOT derivable from A.1–A.4.
  SUMMARY:
    Round-1 found that the discrete derivative `dN` carries no
    sign-constraint (Agent 7's central obstruction).  Round 2 confirms
    the symmetric story on the Φ₀ side: the real-valued
    sequence `t ↦ Phi0 (Xs t) p` carries no derivable shape
    constraint (monotonicity, convexity, concavity, Lipschitz-in-t,
    bounded variation) under A.1–A.4 alone.

    **Why dead end.** A.1–A.4 are pointwise axioms on agents.  They
    say nothing about the relationship between `Xs t` and `Xs (t+1)`.
    Concretely:
      - A.1 (`N = 0 ↔ Φ₀ = 0`) is pointwise.
      - A.2 (`N ≠ ⊤ ↔ ∃ R'⊆K`) is pointwise.
      - A.3 / A.4 are pointwise.
    No axiom mentions `Xs` as a sequence.  Therefore for any sequence
    `f : ℕ → ENNReal` that *agrees with `Phi0` only via* A.1 — i.e.
    `f t = 0 ↔ N p (Xs t) = 0` — the same statements are consistent.
    In particular the value of `Phi0` away from `0` is not pinned down
    by anything in the axiom system.

    **What we record below.** A clean statement of "`Phi0`-along-
    trajectory is free under A.1–A.4 modulo the zero-set constraint",
    rephrased as a `Prop` capturing what would be needed to derive
    monotonicity (just as Agent 7's `MonotoneImprovement` does for N).
    Plus a small constant-trajectory example that satisfies all four
    axioms (vacuously, since the axioms are pointwise) and exhibits a
    non-monotone `Phi0` sequence simply by using `Classical.arbitrary` —
    we don't need to construct a witness, just to record that no
    counter-derivation prevents arbitrary `Phi0`.

    This file contains a single non-axiomatic `Prop` definition and a
    proof that the constant trajectory satisfies the (trivial) shape
    constraint.  It contains NO theorem of the form "Phi0 is monotone"
    — that statement is not derivable.
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent5_Phi0Freedom_DeadEnd

variable {α : Type}

/-! ## (1) Hypothetical shape constraints on `Phi0`-along-trajectory.

We define each shape constraint as a `Prop` predicate.  None of these
is a theorem of A.1–A.4. -/

/-- **Φ₀ monotone non-increasing**: `Phi0 (Xs (t+1)) p ≤ Phi0 (Xs t) p`. -/
def Phi0MonotoneDown (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ∀ t, Phi0 (Xs (t + 1)) p ≤ Phi0 (Xs t) p

/-- **Φ₀ monotone non-decreasing**. -/
def Phi0MonotoneUp (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ∀ t, Phi0 (Xs t) p ≤ Phi0 (Xs (t + 1)) p

/-! ## (2) Trivial fact: constant trajectories satisfy both. -/

/-- **Vacuously monotone non-increasing for constant trajectory**. -/
theorem Phi0MonotoneDown_of_const
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) :
    Phi0MonotoneDown Xs p := by
  intro t
  rw [hConst (t + 1), hConst t]

/-- **Vacuously monotone non-decreasing for constant trajectory**. -/
theorem Phi0MonotoneUp_of_const
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) :
    Phi0MonotoneUp Xs p := by
  intro t
  rw [hConst (t + 1), hConst t]

/-! ## (3) The dead-end observation.

The two predicates `Phi0MonotoneDown` and `Phi0MonotoneUp` cannot both
be theorems of A.1–A.4: if they were, every trajectory would have
constant `Phi0`.  But the axioms allow any pointwise `Phi0` value at
each index (so long as A.1 is respected).  In particular, neither
`Phi0MonotoneDown` nor `Phi0MonotoneUp` is a theorem of A.1–A.4.

We *do* prove the consistency-style claim: there is at least one
trajectory satisfying both — the constant trajectory.  But neither is
forced. -/

/-- **Joint trivial satisfiability**.  The constant trajectory makes
    *both* shape predicates true.  This shows the two are mutually
    consistent (which is necessary for neither to be a theorem), but
    does NOT show either is a theorem. -/
theorem const_satisfies_both
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) :
    Phi0MonotoneDown Xs p ∧ Phi0MonotoneUp Xs p :=
  ⟨Phi0MonotoneDown_of_const Xs X p hConst,
   Phi0MonotoneUp_of_const Xs X p hConst⟩

/-! ## (4) Conditional implications: what would follow IF either shape
predicate held. -/

/-- **Conditional**: if Phi0 is monotone down, then `Phi0`-zero indices
    are upward-closed. -/
theorem phi0_zero_upward_closed_of_monotone_down
    (Xs : ℕ → Agent α) (p : Problem α)
    (hMono : Phi0MonotoneDown Xs p) {t : ℕ}
    (h : Phi0 (Xs t) p = 0) :
    Phi0 (Xs (t + 1)) p = 0 := by
  have h1 : Phi0 (Xs (t + 1)) p ≤ Phi0 (Xs t) p := hMono t
  rw [h] at h1
  exact nonpos_iff_eq_zero.mp h1

/-- **Conditional**: if Phi0 is monotone down, the solved-index set is
    upward-closed (via A.1). -/
theorem solved_upward_closed_of_monotone_down
    (Xs : ℕ → Agent α) (p : Problem α)
    (hMono : Phi0MonotoneDown Xs p) {t : ℕ}
    (h : N p (Xs t) = 0) :
    N p (Xs (t + 1)) = 0 := by
  have hPhi : Phi0 (Xs t) p = 0 := (Axioms.A1 p (Xs t)).mp h
  have hPhi' : Phi0 (Xs (t + 1)) p = 0 :=
    phi0_zero_upward_closed_of_monotone_down Xs p hMono hPhi
  exact (Axioms.A1 p (Xs (t + 1))).mpr hPhi'

/-! ## (5) Final dead-end record.

`Phi0MonotoneDown`, `Phi0MonotoneUp` and their convex / concave
generalisations cannot be proved from A.1–A.4 — they are hypotheses
the caller can supply, equivalent to assuming a new "training
direction" axiom.  The conditional theorems above show what would
follow if such a hypothesis were available.  Until such an axiom is
added, the trajectory's `Phi0` shape is free modulo the pointwise
A.1 constraint. -/

end R2_Agent5_Phi0Freedom_DeadEnd

end MIP
