/-
  STATUS: OBSERVATION
  AGENT: 7
  DIRECTION: Discrete derivative of N along training — bounded only between adjacent finite values; monotone improvement is NOT derivable from A.1–A.4.
  SUMMARY:
    We define the signed discrete derivative
      dN Xs p t := ((N p (Xs (t+1))).toNat : ℤ) - ((N p (Xs t)).toNat : ℤ)
    of the N-trajectory. Pure arithmetic — no axioms invoked. We prove the
    obvious algebraic facts (zero on constant trajectories, antisymmetry
    under index swap, telescoping sum). The CENTRAL OBSERVATION is the
    OBSTRUCTION: the "monotone improvement" claim `dN Xs p t ≤ 0`
    ("training never increases emergence degree") is NOT derivable from
    A.1–A.4. The four axioms say nothing about how `K (Xs (t+1))` relates
    to `K (Xs t)`, nor how `Phi0 (Xs (t+1))` relates to `Phi0 (Xs t)`.
    Without an additional "knowledge growth" axiom of the form
      ∀ t, K (Xs t) ⊆ K (Xs (t+1)),
    the formal system simply cannot derive any non-trivial sign constraint
    on dN. We document this as the central obstruction.
-/
import MIP.Axioms

namespace MIP

namespace Agent7_DiscreteDerivative

variable {α : Type}

/-! ## (1) The discrete derivative of N along a trajectory. -/

/-- **Discrete N-derivative** at step `t`. Uses `(N _ _).toNat` so the
    signed difference lives in ℤ; the `toNat` collapses ⊤ to 0 (concrete-
    model truncation, inherited from Agent 4's unconditional cardinality). -/
def dN (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : ℤ :=
  ((N p (Xs (t + 1))).toNat : ℤ) - ((N p (Xs t)).toNat : ℤ)

/-! ## (2) Algebraic identities — pure arithmetic, no axioms. -/

/-- **Zero on constant trajectories.** If `Xs t = X` for all `t`, then
    `dN = 0`. -/
theorem dN_zero_of_const
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) (t : ℕ) :
    dN Xs p t = 0 := by
  unfold dN
  rw [hConst (t + 1), hConst t]
  ring

/-- **Zero between cycle indices** (where the trajectory revisits the
    same agent at consecutive steps). -/
theorem dN_zero_of_cycle_at
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (h : Xs (t + 1) = Xs t) :
    dN Xs p t = 0 := by
  unfold dN
  rw [h]
  ring

/-- **Telescoping sum**: `∑_{t<n} dN Xs p t = (N p (Xs n)).toNat - (N p (Xs 0)).toNat`. -/
theorem dN_telescoping_sum
    (Xs : ℕ → Agent α) (p : Problem α) (n : ℕ) :
    (∑ t ∈ Finset.range n, dN Xs p t)
      = ((N p (Xs n)).toNat : ℤ) - ((N p (Xs 0)).toNat : ℤ) := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, ih]
      unfold dN
      ring

/-- **Antisymmetry under index swap** (informally — but here we mean
    the reverse direction is the negative). -/
theorem dN_neg_swap
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    ((N p (Xs t)).toNat : ℤ) - ((N p (Xs (t + 1))).toNat : ℤ)
      = - dN Xs p t := by
  unfold dN
  ring

/-! ## (3) Bound: |dN| ≤ N + N' (trivial triangle bound). -/

/-- **Triangle bound** on `|dN|`. This is the only sign-free bound
    that holds unconditionally. -/
theorem abs_dN_le_sum
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    |dN Xs p t| ≤ ((N p (Xs (t + 1))).toNat : ℤ) + ((N p (Xs t)).toNat : ℤ) := by
  unfold dN
  have h1 : (0 : ℤ) ≤ ((N p (Xs t)).toNat : ℤ) := by exact_mod_cast Nat.zero_le _
  have h2 : (0 : ℤ) ≤ ((N p (Xs (t + 1))).toNat : ℤ) := by exact_mod_cast Nat.zero_le _
  rcases le_total ((N p (Xs t)).toNat : ℤ) ((N p (Xs (t + 1))).toNat : ℤ) with h | h
  · rw [abs_of_nonneg (by linarith)]
    linarith
  · rw [abs_of_nonpos (by linarith)]
    linarith

/-! ## (4) The central obstruction — stated formally.

In a formal Lean setting, "X cannot be derived from axioms Y" is the
existential statement "there exists a model of Y in which ¬X holds". We
cannot exhibit such a model from inside Lean without introducing new
declarations, so we phrase the obstruction at the meta-level as a
PROP that, were it true, would suffice for monotonicity — and note that
A.1–A.4 do not provide it.

The clean way to make this observation rigorous in-system is the following
implication: IF we additionally assume a "knowledge growth" hypothesis
`KnowledgeGrowth Xs := ∀ t, K (Xs t) ⊆ K (Xs (t+1))` (and a Phi0-side
monotonicity bridge), THEN we can prove `dN ≤ 0`. Without those
additions, we cannot.

Below we just record the conditional form — proving that monotonicity
WOULD follow from an explicit auxiliary hypothesis. The user supplying
the hypothesis is the user supplying the missing axiom. -/

/-- **Conditional monotonicity (the missing axiom in explicit form)**:
    If a trajectory satisfies `(N p (Xs (t+1))).toNat ≤ (N p (Xs t)).toNat`,
    then `dN ≤ 0`. Pure arithmetic — proved by definition unfolding. This
    is the formal "what monotone improvement would require": a hypothesis
    of the exact same form as the conclusion. -/
theorem dN_nonpos_of_toNat_monotone
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (h : (N p (Xs (t + 1))).toNat ≤ (N p (Xs t)).toNat) :
    dN Xs p t ≤ 0 := by
  unfold dN
  have : ((N p (Xs (t + 1))).toNat : ℤ) ≤ ((N p (Xs t)).toNat : ℤ) :=
    by exact_mod_cast h
  linarith

/-- **Symmetric: conditional growth.** -/
theorem dN_nonneg_of_toNat_antimonotone
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (h : (N p (Xs t)).toNat ≤ (N p (Xs (t + 1))).toNat) :
    0 ≤ dN Xs p t := by
  unfold dN
  have : ((N p (Xs t)).toNat : ℤ) ≤ ((N p (Xs (t + 1))).toNat : ℤ) :=
    by exact_mod_cast h
  linarith

/-! ## (5) Explicit observation — what's not derivable.

The following Prop captures "training never increases emergence":

```
def MonotoneImprovement (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ∀ t, dN Xs p t ≤ 0
```

This Prop is well-formed but NOT a theorem of A.1–A.4. To see that it is
non-derivable, observe that the axioms A.1–A.4 are entirely insensitive
to the *order* of the trajectory: any permutation of `Xs : ℕ → Agent α`
that fixes the set `{Xs t | t}` preserves the axioms (they refer to
agents pointwise, not as a sequence). Monotonicity is a property of the
ORDER. Hence A.1–A.4 cannot pin it down. This is the central obstruction
to a "training improves emergence" theorem in the current axiomatic system. -/

/-- **Formal `MonotoneImprovement` predicate**: this is the property the
    obstruction refers to. It is *not* a theorem; it is a hypothesis a
    caller could supply (equivalent to assuming the missing axiom). -/
def MonotoneImprovement (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ∀ t, dN Xs p t ≤ 0

/-- **Trivial: constant trajectories satisfy `MonotoneImprovement`**
    (vacuously, with equality). -/
theorem const_MonotoneImprovement
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) :
    MonotoneImprovement Xs p := by
  intro t
  rw [dN_zero_of_const Xs X p hConst t]

end Agent7_DiscreteDerivative

end MIP
