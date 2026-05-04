# Blind Test Post-Mortem: AdaGrad-Norm Last-Iterate Convergence

**Test Date**: 2026-04-17
**Target Paper**: Preobrazhenskaia, Sidorov, Preobrazhenskii, Gorbunov (2026).
"Last Iterate Convergence of AdaGrad-Norm for Convex Non-Smooth Optimization."
arXiv:2604.10728, submitted 2026-04-12 (5 days before test).

**Blind Test Design**: Agent forbidden from web-searching, fetching the paper,
or using any keywords linking to it. Only theorem statement given.

## 1. Expected Outcome Categories

- **MATCH**: Same techniques, independently reproduced
- **STRONGER**: Different/better methods, same conclusion
- **WEAKER**: Weaker version proved
- **PARTIAL**: Right conclusion, missing steps
- **FAIL**: Honest failure

## 2. Actual Outcome

**Classification: FAIL**

Breakdown:

- **Upper bound: FAILED.** Agent claimed O(log N / sqrt(N)), which is strictly
  stronger than the paper's O(1/N^{1/4}). This "stronger" bound **CONTRADICTS**
  the paper's matching Ω(1/N^{1/4}) lower bound. Since LB and UB must both hold
  and must be consistent in asymptotic order, an agent UB strictly smaller than
  the stated LB implies the proof has a bug. The agent did not notice this.

- **Lower bound: FAILED.** Agent could not close the Ω(1/N^{1/4}) lower bound;
  8 adversarial constructions across five Explorer routes and one Fixer round
  all yielded gaps decaying **faster** than N^{−1/4}, with worst-case observed
  slope N^{−4.66} (Idea B, frozen-step adversary).

The two failures interlock: the spurious UB (O(log N / sqrt(N))) is what
convinced the numerical tests that the LB construction was impossible.
In reality, the true UB is O(1/N^{1/4}) and the LB construction lives
in the power-law-stepsize regime that the agent never explored.

## 3. Root Cause Analysis

### Technical Error in Route 3 (winner)

Route 3 applied **Shamir-Zhang suffix-averaging + Harvey-Liaw-Plan-Randhawa
regret-to-last-iterate reduction** to derive the UB. This reduction gives
the correct bound for the iterate **average**, not the **last** iterate.
The agent silently conflated the two — a textbook trap when the technique
is read from a regret-analysis context and applied verbatim to last-iterate
settings.

The actual paper uses **horizon-dependent stepsize h = R/N^γ** with
Zamani-Glineur 2025's last-iterate inequality. Agent's library has no template
for "horizon-dependent power-law stepsize," so it defaulted to suffix averaging,
which happens to produce the cleaner-looking but wrong bound.

### Systemic Failure: Reverse Consistency Not Checked

Even though Route 3's UB was strictly stronger than the theorem's LB, **no stage**
flagged this as a contradiction:

- **Explorer** does not compare its output to other parts of problem.md; each
  Explorer is given a single route and writes within its scope.
- **Judge** has no REJECT_ALL option; its prompt forces it to pick a winner
  from available routes, even when all are inconsistent with the theorem.
- **Auditor** only does *forward* numerical verification on synthetic instances
  (does the algorithm satisfy the proved UB on example f?), not *reverse*
  checks against the problem's own LB claim (is the proved UB compatible with
  the stated LB?).

The three stages were each doing their nominal job correctly. The failure was
**the absence of a cross-statement consistency check** anywhere in the pipeline.

### Library Gap

`proof_techniques_summary.md` has entries for:

- fixed stepsize
- O(1/sqrt(t)) stepsize
- doubling trick

But **NOT** for:

- h = R/N^γ (horizon-dependent power law)
- last-iterate inequalities (Zamani-Glineur 2025)

Agent could not recover these because they're too new — 2025 technique applied
to a 2026-04-12 paper, neither plausibly in training cutoff.

## 4. Lower Bound Failure Details

Constructions attempted (all failed):

1. 1D sign oracle on f = G|x|
2. 1D zigzag on f = G|x|
3. Shifted kink f = G|x − a|
4. Huber-type (flat around 0)
5. Nemirovski max of d = sqrt(N) coordinates
6. Adaptive frozen-step adversary (Idea B)
7. Online moving kink (emulating online sequence via single f)
8. Max-composite on d = 10 coordinates

Worst-case gap observed: **~N^{−4.66}** (Idea B). Paper's claimed LB is **N^{−1/4}**.
Gap of **3+ orders of magnitude** in the exponent.

Most likely cause: paper uses h = R/N^γ parameterization in its construction.
Agent tried constant-h and geometric-h variants only. **Without h as a free
parameter to balance against N, the adversary loses the degree of freedom
needed to hit N^{−1/4}.** The optimal γ in the paper's construction is exactly
what creates the 1/N^{1/4} rate.

## 5. Systemic Fixes Implemented

### Fix 1: Auditor Reverse Consistency Check
(see `~/.claude/skills/math-proof-agent/prompts/auditor.md`)
New **Step 0.5** runs before validating proof steps: if problem.md contains
multiple quantitative claims (UB + LB + tightness), Auditor extracts agent's
proved UB/LB and compares asymptotic orders against problem.md claims. Any
agent-UB strictly smaller than problem-LB (or vice-versa) returns
`FAIL_CONTRADICTION` and blocks archival. Also adds an explicit
"adversarial sanity check": pick the agent's optimal stepsize, construct a
worst-case small example, run the algorithm, and check if observed gap
violates the agent's bound.

### Fix 2: Judge REJECT_ALL Branch
(see `~/.claude/skills/math-proof-agent/prompts/judge.md`)
New **Pre-Selection Gate** runs before scoring: each route is classified as
ELIGIBLE / ELIGIBLE_WITH_GAP / INELIGIBLE / PARTIAL based on consistency with
problem.md. If all routes are INELIGIBLE, Judge returns `REJECT_ALL` with
per-route conflict reasons and loops back to Explorer with amended
instructions. REJECT_ALL is now a legitimate Judge output that does not
require picking a route number.

### Fix 3: Failure Pattern Recorded
FP-18 added to `workspace/failure_patterns.md` with full symptoms, root cause,
specific technical error, and reproduction recipe. Future Scout phases will
pull this pattern and warn Explorers against the suffix-averaging-for-last-
iterate trap.

## 6. What This Test Revealed About the System

### Capabilities (confirmed)

- Full 5-stage pipeline runs to completion without manual intervention
- Fixer honestly reports failure rather than fabricating a closed proof
- System can explicitly label "LB_MISSING" in final report and halt archival
  (the working dir stayed in `workspace/active/` — no auto-archive to
  `proofs/research/` was triggered)

### Limitations (now measured)

- **Proof correctness cannot be trusted when stated UB is "stronger than
  needed."** The heuristic "stronger = better" is wrong when the stronger
  bound contradicts other stated claims.
- **Auditor numerical verification is one-directional.** Forward tests
  confirmed "UB holds empirically" but never asked "does the LB also hold
  under this bound?"
- **Judge lacks a reject-all safety valve.** Forced to pick a winner from a
  set of flawed options.
- **Library gap in "new parameterizations"** (horizon-dependent, 2024+
  techniques) blocks frontier papers. The Scout phase's library lookup
  cannot surface what isn't there.

### Meta-learning

The system's **scoping capability** (feasibility analysis, route diversity,
self-pacing) is stronger than its **proof-correctness-verification
capability**. This is the single most important calibration signal from
this test. Before the test the two were implicitly assumed to be equally
robust; the test revealed the verification layer is the weaker link.

## 7. Concrete Meta-Result

**Before this test**: "My agent can prove 81 research-level theorems."

**After this test**: "My agent can prove 81 research-level theorems **from its
training distribution**. When faced with a paper 5 days old outside this
distribution, it produces a plausible but incorrect upper bound and fails
to construct the required lower bound. The system honestly reports the
lower-bound failure but fails to detect its upper-bound error. Three
specific prompt-level fixes (implemented 2026-04-17) close the detection
gap; the library-gap remains."

This is a more honest and more useful characterization of the system's
ability than the pre-test claim. The 81-count is still a defensible figure,
but it's now framed correctly: in-distribution, detection-layer-unverified
as of pre-2026-04-17.

## 8. Recommended Follow-up (for AITP workshop paper)

This post-mortem is a complete worked example of:

- Multi-agent failure modes in theorem proving
- Why "forward verification" is insufficient for theorem statements with
  multiple quantitative claims
- A cheap fix (prompt-level reverse consistency) that closes the detection
  gap without touching the verifier backend

Candidate title: **"Failure Modes of Multi-Agent Natural-Language Theorem
Proving on Research-Level Mathematics: An Ablation Study via Blind Tests
on Recent arXiv Submissions."**

Venue: AITP 2026 workshop (submission typically August).

Proposed structure:

1. Motivation — multi-agent TP on frontier math
2. Pipeline overview (5 stages)
3. Blind-test protocol (this test as worked example)
4. Observed failure modes (FP-18 style catalog)
5. Ablation: with vs without reverse consistency check
6. Ablation: Judge with vs without REJECT_ALL
7. Library-gap as an orthogonal axis — what cannot be fixed by prompts alone
8. Discussion: scoping ≫ verification, why this matters for deployment
