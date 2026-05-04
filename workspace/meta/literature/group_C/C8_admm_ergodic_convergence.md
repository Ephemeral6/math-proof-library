# C8 — ADMM ergodic O(1/T) (no full-rank)

**Path**: `proofs/research/convex-analysis/subgradient/admm-ergodic-convergence/`
**Verdict**: **MATCH (He-Yuan 2012 framework, no full-rank)**

## Our statement
For ADMM on $\min f(x) + g(z)$ s.t. $Ax + Bz = c$ with augmented Lagrangian penalty $\beta > 0$:
$$
x^{k+1} = \arg\min_x f(x) + (\beta/2)\|Ax + Bz^k - c + \lambda^k/\beta\|^2,
$$
$$
z^{k+1} = \arg\min_z g(z) + (\beta/2)\|Ax^{k+1} + Bz - c + \lambda^k/\beta\|^2,\quad \lambda^{k+1} = \lambda^k + \beta r^{k+1}.
$$
For ergodic averages $\bar x_T = (1/T)\sum x^k$, $\bar z_T = (1/T)\sum z^k$, $\bar\lambda_T = (1/T)\sum \lambda^{k-1}$ (lagged dual), and any feasible test point $(\tilde x, \tilde z, \tilde\lambda)$:
$$
\Phi((\bar x_T, \bar z_T, \bar\lambda_T); (\tilde x, \tilde z, \tilde\lambda)) \le \frac{1}{T}\left[\frac{\beta}{2}\|B(\tilde z - z^0)\|^2 + \frac{1}{2\beta}\|\tilde\lambda - \lambda^0\|^2\right].
$$

## Literature

### He-Yuan 2012 (SIAM J. Numer. Anal.) — "On the O(1/n) Convergence Rate of the Douglas-Rachford Alternating Direction Method"
- Canonical reference for the ergodic O(1/T) ADMM rate via VI / direct Lagrangian analysis.
- Their Theorem 4.1 establishes the bound above (in slightly different notation).
- Does NOT require full row rank of $A$ or $B$.

### He-Yuan 2015, Boyd et al. 2011 (FnTML)
- Extensive ADMM convergence analyses; confirm O(1/T) ergodic rate is canonical.

## Comparison

The bound and the lagged-dual ergodic average $\bar\lambda_T = (1/T)\sum_{k=0}^{T-1}\lambda^k$ exactly match the He-Yuan framework. The constant $\frac{\beta}{2}\|B(\tilde z - z^0)\|^2 + \frac{1}{2\beta}\|\tilde\lambda - \lambda^0\|^2$ is the standard primal-dual potential.

The proof's "Route 3" approach (direct Lagrangian, no VI) is a clean direct derivation; the same bound can be obtained via the He-Yuan VI reformulation.

The "no full-rank" caveat is meaningful: many older ADMM proofs require $A$ to have full column rank (so the $x$-subproblem's quadratic part is strongly convex). The proof here works without this assumption by using the lagged-dual $\bar\lambda_T$ and pairing primals with $\lambda^k$ rather than $\lambda^{k+1}$.

## Verdict

**MATCH.** This is a standard B-class library result, faithfully reconstructed in the He-Yuan 2012 framework without full-rank assumption. The proof is self-contained (Step 1: KKT conditions of subproblems; Step 2: subgradient inequalities; Step 3: lagged-dual gap; Step 4-end: telescoping with Young / cross-term absorption).

The bound holds **for feasible test points** (where $d := A\tilde x + B\tilde z - c = 0$); for arbitrary test points, an extra $\langle\bar\lambda_T, d\rangle$ term appears (the proof flags this scope honestly in the preamble).

No discrepancy with literature; rate, constants, and assumptions match He-Yuan 2012.
