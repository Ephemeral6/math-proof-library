# E9: CR Depth Lower Bound (Problem 7.9, PARTIAL)

**Path**: `proofs/research/multi-agent/cumulative-reasoning-depth-lower-bound/`
**Source**: Internal — CR-style depth bound (2308.04371)

## Verdict: NOVEL APPLICATION OF YAO + BAYES-ERROR (PARTIAL declared)

## Our claim
- Part (a) PASS: T >= d * log(1/(2 delta)) / log(1/epsilon).
- Part (b) PARTIAL: parallel makespan >= d under Hypothesis 2 (transcript-dependency); gap under
  permissive verifier.
- Part (c) PARTIAL: formula correct, but the originally stated numerical answer "approx 18" is
  arithmetically wrong (correct value: 3.9).

## Literature comparison
CR paper has no formal depth lower bound theorem; it is empirical.

Technique used in (a):
- Yao's minimax principle (standard)
- Bayes-error tail for Bernoulli(1-epsilon) vs Bernoulli(epsilon) hypothesis test:
  Pr[err] >= (1/2) * epsilon^{T_l}. This is a classical fact (e.g., Le Cam's two-point bound).
- Combine across d levels: T >= d log(1/delta)/log(1/epsilon).

Mathematical content:
- (a) is standard information-theoretic LB technique applied to a novel computational model
  (multi-agent verification). Le Cam / Yao for binary testing is textbook-level; the application
  to a chain of verifier-call-budgeted hypothesis tests is the original part.
- (b) is structural (path argument in a DAG); honest about model dependence.
- (c) catches an arithmetic error in the original problem statement. This is praiseworthy
  audit work — the formula derivation is correct, only the numerical evaluation in the
  source claim is wrong.

## Assessment
"Standard technique, novel application" — accurate. The lower bound itself is unsurprising
(d-fold scaling), but a clean derivation in the multi-agent verification context is useful.

The catch on part (c) (correct value 3.9, not 18) is good adversarial auditing.

## Discrepancies
None hidden. PARTIAL is at the top of proof. Both gaps (Hypothesis 2 model dependence, part (c)
numerical mismatch with the source claim) are openly declared.

## Confidence: HIGH on (a) (clean application of standard LB technique).
MEDIUM on (b), (c) — both honestly partial.
