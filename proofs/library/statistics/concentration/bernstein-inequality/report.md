# Final Report: Bernstein's Inequality for Bounded Random Variables

## Result: PASS

## Theorem

Let $X_1, \ldots, X_n$ be independent random variables with $\mathbb{E}[X_i] = 0$ and $|X_i| \leq M$ a.s. Let $V = \sum_{i=1}^n \mathbb{E}[X_i^2]$. Then for all $t > 0$:

$$P\!\left(\sum_{i=1}^n X_i > t\right) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right).$$

## Phase Summary

### Phase 1: Route Design
Three routes considered:
1. **MGF + Bennett's Lemma** — Classical approach via Bennett's exponential inequality
2. **Direct Taylor Series + Moment Bounds** — Self-contained Taylor expansion approach
3. **Convexity + Hoeffding variant** — Attempted pure convexity approach

### Phase 2: Proof Writing
All three routes written. Route 3 failed to produce an independent approach and degenerated into Route 2.

### Phase 3: Evaluation
**Route 2 selected** as the best proof. Clean, self-contained, linearly structured with nine clearly labeled steps.

### Phase 4: Audit
Line-by-line verification passed. Key checks:
- Chernoff bound application: correct
- Moment bound $|\mathbb{E}[X_i^k]| \leq \sigma_i^2 M^{k-2}$: correct
- Inequality direction for odd moments: verified (uses $|\mathbb{E}[X_i^k]|$ bound)
- Factorial inequality $k! \geq 2 \cdot 3^{k-2}$: proved by induction, correct
- Geometric series convergence condition $\lambda < 3/M$: verified
- Choice $\lambda^* = t/(V + Mt/3)$: verified to be in $(0, 3/M)$
- Final algebra: all intermediate computations checked
- Edge cases ($V=0$, $M \to 0$, $t \to 0$, $t \to \infty$): all consistent

### Phase 5: This report

## Proof Technique

The proof follows the standard Chernoff bound framework:
1. Exponentiate and apply Markov's inequality
2. Bound individual MGFs via Taylor expansion and moment bounds
3. Use $k! \geq 2 \cdot 3^{k-2}$ to reduce to geometric series
4. Apply $1 + x \leq e^x$ to make bounds multiplicative
5. Choose $\lambda^* = t/(V + Mt/3)$ to obtain the Bernstein denominator

## Difficulty Assessment
**Research level.** While the result is classical, the proof requires:
- Careful treatment of inequality directions for odd moments
- A non-trivial factorial inequality with inductive proof
- Explicit optimization calculation with multiple intermediate steps
- Understanding of the connection between moment conditions and tail behavior

## FINAL VERDICT: PASS
