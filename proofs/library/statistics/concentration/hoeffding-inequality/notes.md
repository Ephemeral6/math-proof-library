# Notes: Hoeffding's Inequality

## Proof technique
Route 1 (Classical MGF + Chernoff Bound) was selected. The proof follows the standard three-part strategy: (1) Hoeffding's Lemma (sub-Gaussian MGF bound for bounded RVs), (2) Chernoff bound with independence factorization, (3) optimization over the tilting parameter. The key technical step is the phi-function analysis showing phi(u) = -pu + ln(1-p+pe^u) <= u^2/8 via Taylor's theorem and the bound q(1-q) <= 1/4.

## Key steps
1. **Centering**: Reduce to zero-mean variables Y_i = X_i - E[X_i] without loss of generality
2. **Hoeffding's Lemma**: Use convexity of exp to get a chord bound, then analyze the phi-function. The critical insight is that phi''(u) = q(1-q) <= 1/4 where q is a logistic-type function, combined with phi(0) = phi'(0) = 0 and Taylor's theorem
3. **Chernoff + Independence**: Markov's inequality on the exponential, factor the MGF by independence
4. **Optimization**: Minimize the quadratic in s to get the optimal tilting parameter s* = 4t/sum(c_i^2)

## Audit result
PASS on first round. All 7 steps marked VALID with 0 issues. Three confirmation points verified:
- Boundary cases (alpha=0 or beta=0) handled correctly
- phi is C-infinity (Taylor applicable)
- Optimal s* > 0 confirmed
Numerical verification (10^6 samples) confirmed the lemma, the phi bound, and the full inequality.

## Related results
- **McDiarmid's inequality** (bounded differences): Generalization where X_i need not be independent but the function satisfies a bounded differences condition. Already proved in this library at proofs/statistics/concentration/mcdiarmid-bounded-differences-inequality/
- **Bernstein's inequality**: Sharper bound when variance is known (improves on Hoeffding for small-variance cases)
- **Matrix Bernstein inequality**: Matrix extension, already proved at proofs/statistics/concentration/matrix-bernstein-inequality/
- **Sub-Gaussian covariance concentration**: Uses Hoeffding-type bounds, already at proofs/statistics/concentration/sub-gaussian-covariance-concentration/
- **Azuma-Hoeffding inequality**: Extension to martingale differences
- **Bennett's inequality**: Related concentration bound using variance information
