# Notes: Matrix Bernstein Inequality

## Proof technique
Route 3 (Lieb's Theorem, Lemma-based architecture) won. The proof is organized as 5 self-contained lemmas (A-E) plus the main theorem. The key innovation vs the Golden-Thompson route is using Lieb's concavity theorem for iterative peeling, which preserves the full matrix variance structure and achieves the sharp σ² = ||Σ E[X_i²]|| bound.

## Key steps
1. **Scalar Bernstein MGF** (Lemma A): Uses Taylor integral remainder + factorial bound k! ≥ 2·3^{k-2} to get E[e^{θY}] ≤ exp(θ²E[Y²]/(2(1-θL/3)))
2. **Matrix MGF lift** (Lemma B): Spectral functional calculus transfers scalar bound to Loewner order, with I+M ⪯ e^M for M ⪰ 0
3. **Lieb's transfer rule** (Lemma C): Lieb's concavity (A → tr exp(H + log A) is concave) + Jensen gives E[tr exp(H+Y)] ≤ tr exp(H + log E[e^Y])
4. **Iterative peeling** (Lemma D): Peel off X_n, ..., X_1 one by one using Lemma C, then use trace-exp monotonicity (proved via derivative argument) and operator monotonicity of log
5. **Chernoff optimization** (Lemma E): θ* = t/(σ²+Lt/3), yielding exponent -t²/(2(σ²+Lt/3))

## Audit result
PASS. No logical errors. Minor polish: added Loewner/Bhatia citations for operator monotonicity of log, cleaned false starts in Lemma A, added Lieb 1973 reference.

## Related results
- Sub-Gaussian covariance concentration (already in library) — Matrix Bernstein is the key tool for that result
- Scalar Bernstein inequality is the d=1 special case
- Matrix Hoeffding is the special case where X_i are bounded symmetric (weaker than Bernstein)
- User-friendly corollary: ||Σ X_i|| ≤ σ√(2 log(2d/δ)) + (2L/3)log(2d/δ) with probability ≥ 1-δ
- Applications: random matrix theory, compressed sensing (RIP), covariance estimation, graph sparsification
