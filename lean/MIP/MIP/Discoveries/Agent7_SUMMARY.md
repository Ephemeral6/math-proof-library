# Agent 7 — Summary: Training-dynamics constraints on N(t)

**Direction:** Investigate what constraints A.1–A.4 place on the
*temporal* behaviour of the emergence sequence `t ↦ N p (Xs t)` along a
training trajectory `Xs : ℕ → Agent α`. The book interprets training as
producing `Xs t` that improves over time; we ask which of those informal
claims are formally derivable from A.1–A.4 alone.

**Approach:** The four axioms refer to agents *pointwise* — they don't
mention sequence indices. So every per-index property of `Xs t` is just
the pointwise property at that index. The interesting structural content
comes from (a) chaining A.1 and A.2 at each index to get phase
classification, (b) noting that transitions between phases at adjacent
indices force constraints on Phi0 and coverage, and (c) documenting the
central obstruction: A.1–A.4 are blind to the temporal order, so no
"monotone improvement" can be derived without an additional axiom.

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `Agent7_ConstantTrajectory.lean` | DISCOVERY | Constant trajectory `Xs t = X` gives constant N-sequence — Group A trivia made explicit |
| `Agent7_CycleDetection.lean` | DISCOVERY | Cycle and eventual-periodicity congruence: `Xs (t+T) = Xs t → N p (Xs (t+T)) = N p (Xs t)`; iteration; period-k transport |
| `Agent7_PhaseMarkers.lean` | DISCOVERY | **HEADLINE**: per-index trichotomy into Phase I (N=⊤) / Phase II (0 < N < ⊤) / Phase III (N=0); pairwise disjoint, exhaustive, classically decidable |
| `Agent7_PhaseTransitionTime.lean` | DISCOVERY | `firstFiniteStep` and `firstSolvedStep` as well-defined `Nat.find` (classical decidability); uniqueness of the Phase I→II transition point |
| `Agent7_SolvedIndices.lean` | DISCOVERY | Trajectory-indexed reformulation of A.1: `{t | N p (Xs t) = 0} = {t | Phi0 (Xs t) p = 0}` — clean indexed form |
| `Agent7_BarrierTrajectory.lean` | DISCOVERY | Sequence `t ↦ (B_data p (Xs t)).card = (N p (Xs t)).toNat`; Phase III tightening: `N=0 ↔ B_data=∅ ∧ Phi0=0` (resolves Agent 2's `B_data=∅` ambiguity) |
| `Agent7_PhaseChain.lean` | DISCOVERY | Step-wise transition constraints: Phase II→III forces Phi0 drop; Phase I→¬I requires coverage acquisition; Phase III→I requires coverage loss |
| `Agent7_DiscreteDerivative.lean` | OBSERVATION | `dN Xs p t := (N p (Xs (t+1))).toNat - (N p (Xs t)).toNat` in ℤ; algebra (telescoping, triangle bound); **CENTRAL OBSTRUCTION**: monotone improvement (`dN ≤ 0`) is NOT derivable from A.1–A.4 |
| `Agent7_ConstantNoPhaseTransition.lean` | OBSERVATION | `PhaseTransitionPrereq` forces 3 pairwise-distinct crossover times; transport under `crossover_times`-equality; the prereq is structurally impossible for stationary dynamics (opaque, so cannot be directly refuted) |

**Total:** 7 DISCOVERY + 2 OBSERVATION = 9 files. Zero sorry, zero new axiom, all compile.

---

## Headline result

**`Agent7_PhaseMarkers.phase_trichotomy`**: Along any training trajectory
`Xs : ℕ → Agent α` and any problem `p`, every time step `t` is in
exactly one of three phases:

```lean
def InPhaseI   Xs p t := N p (Xs t) = ⊤            -- knowledge-deficient
def InPhaseII  Xs p t := 0 < N p (Xs t) ∧ N p (Xs t) < ⊤   -- emergent
def InPhaseIII Xs p t := N p (Xs t) = 0            -- solved
```

The trichotomy is exhaustive and pairwise disjoint, and each phase is
classically decidable. Combined with `Nat.find` (in
`PhaseTransitionTime.lean`), we get a well-defined "first finite step"
and "first solved step" as canonical phase boundaries — the formal
counterparts of `t_cov` and `t_aut` in T.30's NL informal interpretation.

---

## Central obstruction — un-derivable claim

**`Agent7_DiscreteDerivative`**: The book-level claim "training improves
emergence" — formalised as

```
def MonotoneImprovement (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ∀ t, dN Xs p t ≤ 0
```

— is **NOT a theorem of A.1–A.4**.

**Why.** A.1–A.4 are entirely *pointwise* axioms: A.1 relates `N p X`
to `Phi0 X p` at a single agent; A.2 relates `N p X` to `K X`; A.3 / A.4
relate to agent behaviour at a single agent. None of the four axioms
references a sequence of agents. So any permutation of a trajectory's
agent set preserves the truth of A.1–A.4 — monotonicity is a property of
the *order*, not the *multiset* of agents.

**What's missing.** A "knowledge growth" axiom of the form

```
∀ t, K (Xs t) ⊆ K (Xs (t+1))
```

(or its Phi0-side counterpart `Phi0 (Xs (t+1)) p ≤ Phi0 (Xs t) p`) would
close the gap. Until such an axiom is added, the formal system is
agnostic about temporal direction. We record this honestly as the
central obstruction to a "training improves emergence" theorem.

The conditional theorems `dN_nonpos_of_toNat_monotone` and the symmetric
`dN_nonneg_of_toNat_antimonotone` document the exact missing-axiom
form: assuming a `toNat`-level monotonicity hypothesis, monotonicity of
N follows by pure arithmetic. The caller supplying the hypothesis is
supplying the missing axiom.

---

## Other notable findings

### Trajectory-indexed reformulations of A.1 / A.2

`Agent7_SolvedIndices`: the set-level identity
`{t | N p (Xs t) = 0} = {t | Phi0 (Xs t) p = 0}` is the clean *indexed*
form of A.1. Never previously stated in the codebase, despite A.1 being
used pointwise in many places. Similarly, `coverage_at_finite_index`
is the indexed A.2.

### Step-wise transition constraints (`Agent7_PhaseChain`)

Real structural content derivable from A.1+A.2 even without a knowledge-
growth axiom: any *individual* phase transition between adjacent indices
forces a *single-step* constraint:

* Phase II → Phase III: Phi0 must have been nonzero at `t` and is zero
  at `t+1` (a strict drop is forced).
* Phase I → ¬I: at `t`, no demand was covered; at `t+1`, some demand
  is covered (coverage is acquired between `t` and `t+1`).
* Phase III → Phase I: at `t`, coverage existed; at `t+1`, all coverage
  is lost (K-loss is required to backslide from solved to deficient).

These are honest constraints on *adjacent* indices, derivable from
A.1+A.2 alone, even though no global monotonicity follows.

### Phase III tightening (`Agent7_BarrierTrajectory`)

Agent 2 noted that in the concrete model, `B_data p X = ∅` does NOT
distinguish `N = 0` from `N = ⊤`. We tighten this to the conjunction:
`N p (Xs t) = 0 ↔ B_data p (Xs t) = ∅ ∧ Phi0 (Xs t) p = 0`. The
Phi0-tag is the missing piece, supplied by A.1.

### `Nat.find` for transition time

`firstFiniteStep` and `firstSolvedStep` give well-defined transition
times (Phase I→II and II→III respectively) under the existence
hypothesis. Uses classical decidability since `N p (Xs t) ≠ ⊤` is not
constructively decidable.

---

## Non-findings / dead ends avoided

* Did NOT attempt to *refute* PhaseTransitionPrereq for constant
  trajectories — `crossover_times` is opaque, so consistency-style
  refutation is not in scope.
* Did NOT attempt a knowledge-growth axiom — the explicit goal of this
  exploration is to *document* what's not derivable from A.1–A.4, not
  to add new axioms.
* Did NOT redo Agent 2's `N_trichotomy` (pointwise) or Agent 4's
  `B_data_card_eq_toNat` (unconditional) — explicitly cross-referenced
  in our docstrings and used as building blocks.
* Did NOT attempt Phi0-side adjacent-step monotonicity — same
  obstruction as N-monotonicity, would require a Phi0-growth axiom.
