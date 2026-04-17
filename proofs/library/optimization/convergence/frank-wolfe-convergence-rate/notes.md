# Notes: Frank-Wolfe (Conditional Gradient) O(1/k) Convergence Rate

## Proof technique
The winning route was the **Lyapunov / Recurrence approach** (Route 2). This frames the proof as: (1) derive a one-step recurrence for the suboptimality $h_t$, (2) guess-and-verify the ansatz $h_t \leq 2LD^2/(t+2)$, (3) check the base case, (4) conclude by induction.

This was preferred over direct induction (Route 1) because it avoids messy base case handling, and over the gap-based approach (Route 3) because it is more focused without tangential detours.

## Key steps
1. **Descent lemma + linear minimization + convexity** combine to give the recurrence $h_{t+1} \leq (1 - \gamma_t)h_t + \frac{L\gamma_t^2 D^2}{2}$
2. **The AM-GM-like inequality** $(t+1)(t+3) \leq (t+2)^2$ (equivalently $3 \leq 4$) is the critical algebraic fact that makes the induction close
3. **Base case**: $\gamma_0 = 1$ makes the first iteration give $h_1 \leq LD^2/2$, which has slack compared to $2LD^2/3$

## Audit result
PASS on first round. All 6 proof steps marked VALID. Three LOW-severity observations:
- Bound proved for $t \geq 1$ (not $t \geq 0$); consistent with Jaggi 2013
- Descent lemma cited without proof (standard)
- Iterates remaining in $\mathcal{D}$ used implicitly (convex combination)

Key algebra verified by SymPy: $(t+2)^2 - (t+1)(t+3) = 1$, recurrence simplification exact, base case inequality confirmed.

## Related results
- **Projected gradient descent** achieves $O(1/k)$ for smooth convex but requires projection onto $\mathcal{D}$, which can be expensive. Frank-Wolfe only needs a linear minimization oracle.
- **Frank-Wolfe with line search** (short step variant: $\gamma_t = g_t/(LD^2)$) also achieves $O(1/k)$ with potentially better constants.
- **Strongly convex case**: Frank-Wolfe does NOT achieve linear convergence in general (unlike projected GD). The $O(1/k)$ rate is tight for Frank-Wolfe on smooth convex problems.
- **Away-step Frank-Wolfe** (Lacoste-Julien & Jaggi 2015) achieves linear convergence for strongly convex objectives over polytopes.
- The $O(1/\varepsilon)$ iteration complexity matches the **lower bound** for first-order methods using only linear minimization oracles over compact sets.
- Connection to **mirror descent**: Frank-Wolfe can be viewed through the lens of online learning / follow-the-leader with linearized objectives.
