# Notes: GD Non-Convex Stationary Point Convergence

## Proof technique
Route 1 — Descent Lemma + Direct Telescoping won. This is the canonical "套路 A" (Pattern A) from the proof library: L-smoothness descent lemma provides per-step decrease, telescoping aggregates, min-leq-average extracts the result.

## Key steps
1. **Descent Lemma derivation**: FTC + Cauchy-Schwarz + L-smoothness gives the quadratic upper bound $f(y) \leq f(x) + \langle \nabla f(x), y-x\rangle + (L/2)\|y-x\|^2$.
2. **Step size substitution**: With $\eta = 1/L$, the per-step decrease is exactly $1/(2L)\|\nabla f(x_k)\|^2$ — this comes from $-1/L + 1/(2L) = -1/(2L)$.
3. **Telescoping**: The sum $\sum [f(x_k) - f(x_{k+1})]$ collapses to $f(x_0) - f(x_T)$.
4. **min $\leq$ average**: Converts sum bound to minimum bound.

## Audit result
PASS on round 1. All 6 steps validated, 4 numerical checks passed, all constants traceable. No fixer needed.

## Related results
- **GD strongly convex linear convergence** (in this library): Uses the same descent lemma but adds strong convexity to get linear rate on function values.
- **GD Polyak-Lojasiewicz linear rate** (in this library): Same descent lemma, but PL condition converts gradient bound back to function value bound.
- **Nesterov AGD O(1/k^2)** (in this library): Accelerated version for convex case, different proof structure (estimate sequences).
- **Proximal gradient O(1/T)** (in this library): Extends this framework to composite $f + h$ with non-smooth $h$.
- **SGD non-convex convergence**: Stochastic extension adds variance terms; same telescoping structure.
- **Frank-Wolfe O(1/k)** (in this library): Different algorithm for constrained case, also uses smoothness + telescoping.
