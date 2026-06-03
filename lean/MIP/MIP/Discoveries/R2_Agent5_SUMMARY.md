# R2 Agent 5 — Summary: Derivable trajectory facts WITHOUT new axioms

**Direction.** Round-1 Agent 7 established that A.1–A.4 do not derive
training-monotonicity of `N` or `Phi0`. R2 Agent 5 asks: what *is*
derivable about the trajectory structure of `Xs : ℕ → Agent α` without
adding new axioms? We push three threads:
discrete intermediate-value / first-crossing structure on Φ₀,
stationarity criteria under fixed points and observable equality, and
cross-trajectory coupling lemmas. We also document the dead-end of
Φ₀ shape constraints and the partially-blocked stopping-time
monotonicity.

Zero `sorry`, zero new `axiom`, all six files compile.

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `R2_Agent5_Phi0DiscreteIVT.lean` | DISCOVERY | Discrete IVT for `Phi0`-zero status: any `0 → ≠0` (or `≠0 → 0`) transition over an interval forces an adjacent crossing step; transferred to `N` via A.1; stationarity lemma. |
| `R2_Agent5_StationarityCriterion.lean` | DISCOVERY | Single-step and eventual fixed-point of `Xs` propagate to `N`, `Phi0`, `K`, and all three phase markers; "(Phi0, coverage)-stationarity" pins down Phase III and Phase I (but not the cardinal value in Phase II). |
| `R2_Agent5_PhaseChangePoints.lean` | DISCOVERY | `phaseChangePoints Xs p` as a Set ℕ; classically decidable; **forced observable change** theorem: at any phase-change point, `(phi0IsZero, coverageAcquired)` changes. Phase III ↔ Phi0=0, Phase I ↔ ¬coverage. |
| `R2_Agent5_TrajectoryCoupling.lean` | DISCOVERY | Two-trajectory coupling: pointwise Phi0-zero match ⇒ Phase III set equality; pointwise coverage match ⇒ Phase I set equality; `firstSolvedStep` matches across coupled trajectories. |
| `R2_Agent5_Phi0Freedom_DeadEnd.lean` | DEAD END | `Phi0MonotoneDown`, `Phi0MonotoneUp` (and shape constraints) are NOT derivable from A.1–A.4; constant trajectories trivially satisfy both; conditional implications recorded. |
| `R2_Agent5_StoppingTimeBlocked.lean` | OBSERVATION | `firstFiniteStep` IS monotone under K-inclusion (derivable from A.2). `firstSolvedStep` is NOT — missing "Phi0-K-monotonicity" axiom. Full table of derivable vs blocked. |

**Total:** 4 DISCOVERY + 1 OBSERVATION + 1 DEAD END = 6 files.

---

## Headline derivable theorems

### Discrete IVT for Φ₀

`Phi0_first_rise`, `Phi0_first_drop`: if `Phi0 (Xs t) p = 0` and
`Phi0 (Xs t') p ≠ 0` with `t < t'`, there is an adjacent step
`(s, s+1)` with `t ≤ s < t'` where Phi0 jumps from zero to nonzero
(and symmetric for the drop). Transferred to `N` via A.1 as
`N_first_rise`, `N_first_drop`.

**Stationarity**: if Phi0-zero status is the same at every adjacent
pair `(n, n+1)` with `t ≤ n < t'`, then it is the same at `t` and
`t'`. Pure contrapositive of the IVT.

### Forced observable change at phase changes

`phase_stable_of_obs_stable` (R2_Agent5_PhaseChangePoints): at any
adjacent pair `(t, t+1)`, if both `phi0IsZero` AND `coverageAcquired`
are unchanged, then all three phase markers are unchanged.
Equivalently: **the phase function factors through the
(Phi0-zero, coverage-acquired) signature** — A.1 + A.2 pin down each
phase marker purely as a Boolean function of those two observables.

`obs_change_of_phase_change`: the contrapositive — at any phase-change
point, at least one observable must change.

### Two-trajectory coupling

`firstSolvedStep_eq_of_phi0_match`: if two trajectories have matching
Phi0-zero status pointwise, their `firstSolvedStep`s are equal.

`firstFiniteStep_eq_of_coverage_pointwise_match`: same for `firstFiniteStep`
under matching coverage status.

### Stationarity criterion

`N_phase_class_eq_of_observables_eq` (R2_Agent5_StationarityCriterion):
if `Phi0 (Xs s) = Phi0 (Xs t)` and coverage agrees as a predicate,
then `N = 0 ↔` and `N = ⊤ ↔` agree (Phase III and Phase I class
membership match). The Phase II cardinal value is NOT pinned down.

### K-inclusion ⇒ `firstFiniteStep` monotonicity

`firstFiniteStep_le_of_K_pointwise_subset`: if `K (Xs t) ⊆ K (Ys t)`
pointwise, then `firstFiniteStep Ys ≤ firstFiniteStep Xs`. Derivable
from A.2 alone (covered demands transfer through K-inclusion).

---

## Blocked / dead-end findings

### Φ₀ shape constraints (DEAD END)

`Phi0MonotoneDown`, `Phi0MonotoneUp`, convexity, concavity — none
derivable. The four axioms are pointwise on agents, so any sequence
of `Phi0` values satisfying A.1 is consistent. Trivial witnesses
exist (constant trajectories satisfy both monotonicity predicates
vacuously); neither is forced.

### `firstSolvedStep` monotonicity from K-inclusion (BLOCKED)

K-inclusion forces `firstFiniteStep` monotonicity (Phase I exit) but
NOT `firstSolvedStep` monotonicity (Phase III entry). Reason: A.1
ties `N = 0 ↔ Phi0 = 0`, and no axiom says K-growth forces Phi0 to
decrease. The missing axiom would be
`Phi0KMonotone : K X ⊆ K Y → Phi0 Y p ≤ Phi0 X p`,
equivalent to a "more knowledge can only help" postulate. Without
it, a larger K leaves Phi0 free.

### Phase II cardinal-value determination (BLOCKED)

Even when both `Phi0`-zero and coverage signatures match across two
agents, `N p X = N p Y` is NOT forced in the Phase II regime
`0 < N < ⊤`. This mirrors Agent 8's cross-agent obstruction at the
trajectory level. Only the class membership `= 0` and `= ⊤` (Phase III
and Phase I) is determined.

### `coverageAcquired` not upward-closed in t (RECORDED)

A.1–A.4 do not contain a "knowledge growth" axiom
`K (Xs t) ⊆ K (Xs (t+1))`. The set of "coverage-acquired" indices
need not be upward-closed; coverage can be lost. Recorded as a Prop
`CoverageUpwardClosed` which is satisfiable (vacuously for constant
trajectories) but not forced.

---

## Summary table — what's derivable vs blocked under A.1–A.4

| Hypothesis | Derivable conclusion |
|---|---|
| Pointwise Phi0-zero match (Xs vs Ys) | `firstSolvedStep` equality; Phase III set equality |
| Pointwise coverage match (Xs vs Ys) | `firstFiniteStep` equality; Phase I set equality |
| `K (Xs t) ⊆ K (Ys t)` ∀ t | `firstFiniteStep Ys ≤ firstFiniteStep Xs` |
| `Xs (t+1) = Xs t` | `N`, `Phi0`, `K`, all phase markers agree at `t` and `t+1` |
| Stable Phi0-zero status across `(t, t+1)` AND stable coverage | Phase doesn't change |
| Phi0 zero at t, nonzero at t' > t | Adjacent crossing step exists in `[t, t')` |

| Hypothesis | **Blocked** conclusion |
|---|---|
| (anything pointwise that doesn't include sequence order) | `Phi0`-monotonicity, `N`-monotonicity in `t` |
| `K (Xs t) ⊆ K (Ys t)` ∀ t (alone) | `firstSolvedStep Ys ≤ firstSolvedStep Xs` |
| Matching observables (Phi0 + coverage) | Cardinal `N` equality in Phase II |
| (anything trajectory-internal) | "Coverage is upward-closed in t" |

All blocked rows trace to a single missing-axiom kernel: A.1–A.4 are
sequence-order-blind and K↔Phi0 are loosely coupled. The honest
formal record is: **the four axioms pin down phase class (III, I)
purely via observables, but neither the Phase II cardinal value nor
any temporal monotonicity follows**.
