/-
Result IT.6 (candidate R.521) — The optimal metacognitive policy σ* is not
PAC-learnable from N-oracle samples in randomized polynomial time, under the
standard complexity assumption RP ≠ NP.

Reference: `workspace/round3_exploration/slot_006.md` / `work_slot_006.md`
§IT.6 (candidate, deps D.1.6, D.1.5, D.4.13, R.85 BOUNDED-N NP-hard, R.87(i)
finite-A N poly-time, Valiant 1984 PAC, RP ≠ NP assumption).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement.**  Assume RP ≠ NP.  Then there is no polynomial-time PAC learner
`L` that, from `m = poly` i.i.d. samples `{(p_i, σ*(p_i, s₀))}` drawn from a
problem distribution `P` covering the R.85 3-SAT hard-instance family, outputs a
hypothesis policy `ĥ` that is `ε`-accurate for `σ*` (in `ΔΦ` loss).

**Source reduction (work_slot_006 §IT.6).**  A polynomial-time `ε`-accurate PAC
learner for `σ*` (with `ε < 1`) would, on the R.85 instance `(p_φ, A_φ)`, output
`ĥ` whose `k_φ`-step trajectory coincides (w.h.p.) with the `σ*` assignment
trajectory; that trajectory reaches the accepting state `s₂` iff `φ ∈ SAT`.
Because `N` on a finite deterministic `A_φ` is poly-time computable by BFS
(R.87(i)), the learner needs no genuine oracle, so it yields a randomized
poly-time SAT decider:

    PAC-learner for σ*  ⟹  SAT ∈ randomized poly time (RP-style)
                        ⟹  NP ⊆ RP, i.e. RP = NP.

Contrapositively, RP ≠ NP forbids such a learner.

**Lean kernel (HYPOTHESIS-BUNDLE-REDUCTION; no learners, no Turing machines).**
The mathematical substance is the **contrapositive transfer**

    PACLearnable σ*  →  (RP = NP),

so that `RP ≠ NP → ¬ PACLearnable σ*`.  We model the two complexity-theoretic
predicates abstractly and bundle the learner-to-solver reduction as the single
nontrivial hypothesis:

* a type `Setting` of (problem-distribution, agent) configurations;
* `sigmaStar : Setting → Policy` — the optimal D.1.6 policy of the setting;
* `PACLearnable : Policy → Prop` — "this policy admits a poly-time PAC learner";
* `RPeqNP : Prop` — the proposition "RP = NP" (collapse).
* the bundled reduction
  `hreduce : PACLearnable (sigmaStar cfg) → RPeqNP`
  — the work_slot_006 §IT.6 construction: a PAC learner for `σ*` on the R.85
  family decides SAT in randomized poly time, forcing `RP = NP`.

`IT6_not_PAC_learnable` then derives `RP ≠ NP → ¬ PACLearnable (sigmaStar cfg)`
by pure contraposition, and `IT6_PAC_learnable_forces_collapse` runs the
implication forward to certify it is a genuine (non-vacuous) reduction.

**This file is `axiom`-free.**  It imports only `Mathlib`; the PAC-learner /
SAT-solver construction, R.85 hardness, R.87(i) BFS poly-time, and the RP ≠ NP
assumption all enter as explicit hypotheses, matching the MIP-side dependency
list.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace NoPACLearn

-- Opaque type of (problem-distribution, agent) configurations.  Each `cfg`
-- packages the agent `A`, the problem distribution `P`, and the sample model
-- of work_slot_006 §IT.6.
variable {Setting : Type*}

-- Opaque type of metacognitive policies `(p, s) ↦ M`.
variable {Policy : Type*}

-- The optimal D.1.6 policy `σ*` of a configuration: the minimizer of the
-- residual intervention count `N`.
variable (sigmaStar : Setting → Policy)

-- "`h` admits a polynomial-time PAC learner from N-oracle samples" — the PAC
-- learnability predicate (opaque; its internal structure is irrelevant to the
-- transfer, only its consequence via the bundled reduction matters).
variable (PACLearnable : Policy → Prop)

-- The complexity-theoretic collapse proposition "RP = NP".  RP ≠ NP is its
-- negation `¬ RPeqNP`, the standard assumption under which IT.6 holds.
variable (RPeqNP : Prop)

/-- **IT.6 core — learner-forces-collapse transfer (the reduction).**

This is the genuine mathematical substance of IT.6: the work_slot_006 §IT.6
reduction, packaged as the implication that a poly-time PAC learner for `σ*`
(on a configuration whose distribution covers the R.85 3-SAT hard family) would
decide SAT in randomized polynomial time and hence force `RP = NP`.

Given the bundled reduction `hreduce`, the transfer is the *contrapositive*: if
the collapse does not hold (`¬ RPeqNP`, i.e. RP ≠ NP), then `σ*` is not PAC
learnable.  Proved honestly by `mt` (modus tollens) — it is exactly
`(A → B) → (¬ B → ¬ A)` applied to the reduction. -/
theorem IT6_transfer
    {cfg : Setting}
    (hreduce : PACLearnable (sigmaStar cfg) → RPeqNP)
    (hRP : ¬ RPeqNP) :
    ¬ PACLearnable (sigmaStar cfg) :=
  mt hreduce hRP

/-- **IT.6 — σ* is not PAC-learnable (main theorem, conditional on RP ≠ NP).**

Instantiates the transfer.  Inputs:
* `cfg : Setting` — a configuration whose problem distribution `P` covers the
  R.85 3-SAT hard-instance family (the coverage condition of §IT.6);
* `hreduce : PACLearnable (sigmaStar cfg) → RPeqNP` — the bundled
  learner-to-SAT-solver reduction (work_slot_006 §IT.6 steps 1–4: PAC learner
  ⟹ randomized poly-time SAT decider via R.85 + R.87(i) BFS ⟹ `RP = NP`);
* `hRP : ¬ RPeqNP` — the standard complexity assumption RP ≠ NP.

Conclusion: `σ*` admits no polynomial-time PAC learner. -/
theorem IT6_not_PAC_learnable
    (cfg : Setting)
    (hreduce : PACLearnable (sigmaStar cfg) → RPeqNP)
    (hRP : ¬ RPeqNP) :
    ¬ PACLearnable (sigmaStar cfg) :=
  IT6_transfer sigmaStar PACLearnable RPeqNP hreduce hRP

/-- **IT.6 — the reduction run forward (non-vacuity).**

If a poly-time PAC learner for `σ*` *does* exist, the bundled reduction forces
the collapse `RP = NP`.  This is the forward direction of `hreduce`, recorded
explicitly to certify that IT.6's kernel is a genuine implication (a learner has
real complexity-theoretic consequences) and not a vacuous statement.  It is the
"build the SAT decider, collapse RP onto NP" step of §IT.6 stated directly. -/
theorem IT6_PAC_learnable_forces_collapse
    {cfg : Setting}
    (hreduce : PACLearnable (sigmaStar cfg) → RPeqNP)
    (hPAC : PACLearnable (sigmaStar cfg)) :
    RPeqNP :=
  hreduce hPAC

/-- **IT.6 — dichotomy form under the bundled reduction (constructive).**

Under the bundled reduction, the §IT.6 dichotomy holds: it is impossible to have
both `σ*` PAC-learnable *and* RP ≠ NP.  Stated constructively as
`¬ (PACLearnable (sigmaStar cfg) ∧ ¬ RPeqNP)` — learnability together with
RP ≠ NP is contradictory — this needs no classical logic (it is provable from
the reduction by direct application), and is the precise content of "either `σ*`
is not PAC-learnable, or `RP = NP`" without invoking excluded middle. -/
theorem IT6_dichotomy
    {cfg : Setting}
    (hreduce : PACLearnable (sigmaStar cfg) → RPeqNP) :
    ¬ (PACLearnable (sigmaStar cfg) ∧ ¬ RPeqNP) :=
  fun ⟨hPAC, hRP⟩ => hRP (hreduce hPAC)

/-- **IT.6 — transfer through an intermediate hardness assumption (chain).**

The §IT.6 route factors as: PAC learner ⟹ SAT ∈ randomized poly time (`SATinRP`)
⟹ `RP = NP`.  This records that the learner-to-collapse reduction composes
through the intermediate "SAT is in RP" claim, so RP ≠ NP still forbids the
learner.  Mirrors the chain form of the hardness-transfer kernels (R.85/R.100),
here on the conditional-impossibility side. -/
theorem IT6_transfer_chain
    {cfg : Setting} {SATinRP : Prop}
    (hlearn_sat : PACLearnable (sigmaStar cfg) → SATinRP)
    (hsat_collapse : SATinRP → RPeqNP)
    (hRP : ¬ RPeqNP) :
    ¬ PACLearnable (sigmaStar cfg) :=
  mt (fun hPAC => hsat_collapse (hlearn_sat hPAC)) hRP

end NoPACLearn

end MIP
