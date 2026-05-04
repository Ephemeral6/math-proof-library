# E8: Compositional CR Reuse (Problem 7.7, corrected)

**Path**: `proofs/research/multi-agent/cumulative-reasoning-compositional-reuse/`
**Source**: Internal — CR multi-agent compositionality (2308.04371)

## Verdict: NOVEL FRAMING (CR paper has no compositional reliability theorem)

## Our claim
- Part (a): Independence-based product bound P(T correct) >= prod (1 - delta_{L_i}) >= 1 - sum delta_{L_i}.
- Part (b): DAG tree-unfolding bound P(T correct) >= (1 - delta)^{N(d, Delta)} where
  N(d, Delta) = (Delta^{d+1} - 1)/(Delta - 1).
- Part (c): Per-lemma retry bound P(T correct) >= (1 - delta^k)^m.

## Literature comparison
CR paper does NOT contain compositional reliability bounds; it is empirical.

Mathematical content:
- (a): Weierstrass product inequality + independence. Undergraduate probability.
- (b): DAG tree-unfolding with worst-case fan-in. Standard counting (geometric series).
- (c): Combine (a) with (1 - delta^k) per-lemma residual. Standard.

The proof CORRECTLY identifies that the user's stated bound (1 - delta)^{Delta^d} is too
loose by a factor (1-delta)^{N(d,Delta) - Delta^d}, and replaces it with the tight
(1-delta)^{N(d,Delta)}. This is good craftsmanship.

The Comparison: (b) vs (c) numerical example (Delta=2, d=5, delta=0.1, k=3, m=63: 0.001 vs 0.94)
is illuminating — the per-lemma retry strategy is ~700x tighter, motivating "library-first"
design. This conclusion is NOT in CR.

## Assessment
"Basic counting + product, but the framing is novel" — accurate self-description. The proof
is correctly executed and the comparison is genuinely informative for system design.

## Discrepancies
None. The honest correction of (1-delta)^{Delta^d} -> (1-delta)^{N(d,Delta)} is appropriate.

## Confidence: HIGH (within elementary scope)
