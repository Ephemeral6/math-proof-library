# Notes: Nesterov's First-Order Lower Bound

## Proof technique
Route 1 (Nesterov's original tridiagonal construction) won. The proof constructs an explicit worst-case quadratic function using a tridiagonal Hessian matrix, then exploits the tridiagonal structure to show that first-order methods can only discover one new coordinate direction per gradient query. The Schur complement of the tridiagonal matrix gives the exact optimal value achievable in the restricted subspace.

## Key steps
1. **Tridiagonal construction**: The matrix $A_k = \operatorname{tridiag}(-1, 2, -1)$ of size $2k+1$ creates a function where information propagates slowly — each gradient query reveals at most one new coordinate.
2. **Subspace restriction (induction)**: By induction, $x_t \in \operatorname{span}\{e_1, \ldots, e_t\}$. This is the core mechanism: after $k$ steps, the method has not "seen" coordinates $k+1$ through $2k+1$.
3. **Schur complement computation**: The exact value $v^T S v = \frac{1}{2(k+1)}$ gives the tight lower bound $\frac{L}{16(k+1)}$ on the function gap.
4. **Norm inequality**: The algebraic identity $\|x^*\|^2 \le \frac{2(k+1)}{3}$ converts the absolute gap into the relative form $\frac{3L\|x^*\|^2}{32(k+1)^2}$.

## Audit result
PASS after 1 round. All 7 steps VALID. Three LOW-severity presentation notes only. All key computations numerically verified for $k \in \{1, 2, 3, 5, 10, 20\}$ using NumPy.

## Related results
- **Upper bound**: Nesterov's accelerated gradient descent achieves $f(x_k) - f(x^*) \le \frac{2L\|x_0 - x^*\|^2}{(k+2)^2}$, matching this lower bound up to constants.
- **Strongly convex case**: Nesterov also proves a $\Omega\left(\left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^{2k}\right)$ lower bound for $\mu$-strongly convex, $L$-smooth functions ($\kappa = L/\mu$).
- **Connection to conjugate gradients**: The tridiagonal construction is intimately related to the optimality of CG for quadratics — CG achieves the best Krylov subspace approximation, and the lower bound shows even CG cannot beat $\Omega(1/k^2)$.
- **Modern extensions**: Drori & Teboulle (2017) and Kim & Fessler (2021) use semidefinite programming (performance estimation) to compute exact worst-case rates, generalizing Nesterov's approach.
