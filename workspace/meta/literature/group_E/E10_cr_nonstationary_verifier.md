# E10: CR Non-Stationary Verifier (Problem 7.4, corrected)

**Path**: `proofs/research/multi-agent/cumulative-reasoning-nonstationary-verifier/`
**Source**: Internal — context-dependent verifier (2308.04371)

## Verdict: NOVEL FRAMING (calculus on monotone error rate)

## Our claim
For verifier error rate epsilon_t = epsilon_0 (1 + t/T_0)^alpha:
- (a) sub-linear alpha < 1: log P_T >= -(3/2) bar S_T.
- (b) linear alpha = 1: P_T strictly decreasing; threshold T** = T_0(1 - 1/e)/epsilon_0.
- (c) super-linear alpha > 1: log P_T <= -epsilon_0 T^{alpha+1}/((alpha+1) T_0^alpha) + const,
  divergence threshold T_div = ((alpha+1) T_0^alpha / epsilon_0)^{1/(alpha+1)}.
- (d) Optimal stopping with proposer benefit beta log T:
  T* asymp (beta T_0^alpha / epsilon_0)^{1/(alpha+1)}.

## Literature comparison
CR paper does NOT model non-stationary verifier error rates. This is wholly novel framing.

Technique:
- Integral test for monotone summands (calculus, undergraduate).
- log(1-x) >= -x - x^2 for x in [0, 1/2] (elementary).
- log(1-x) <= -x for x in [0,1) (elementary).
- Strict concavity of beta log T - integral_eps for unique optimum (calculus).

Mathematical content: undergraduate calculus + elementary inequalities. The novel part is
the FRAMING of LLM verifier reliability degradation as a non-stationary Bernoulli failure rate
and the optimal stopping derivation.

## Assessment
"Calculus, novel framing" — accurate. The integral test, log inequality bookkeeping, and
optimal stopping derivation are all standard. The application to LLM verifier loops is novel.

The CORRECTION of the original problem's threshold formula (T_0^{alpha/(alpha-1)} eps^{-1/(alpha-1)},
which diverges as alpha -> 1+) to T_0^{alpha/(alpha+1)} eps^{-1/(alpha+1)} is good audit work.

## Discrepancies
None. Threshold typo correction is openly noted.

## Confidence: HIGH on the calculus.
MEDIUM on the framing's research significance — the model assumption (epsilon_t = eps_0 (1+t/T_0)^alpha)
is a clean parameterization but not derived from a deeper theory of "context-dependent verifier
failure". It's a useful sandbox model.
