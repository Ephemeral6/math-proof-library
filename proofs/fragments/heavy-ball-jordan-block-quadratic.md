# Fragment: heavy-ball-jordan-block-quadratic

## Statement
Consider the Heavy Ball iteration $x_{k+1} = (1+\beta - \alpha\lambda)x_k - \beta x_{k-1}$ on a quadratic eigendirection with eigenvalue $\lambda$. With **optimal parameters** $\alpha = 4/(\sqrt{L}+\sqrt{\mu})^2$ and $\beta = ((\sqrt{\kappa}-1)/(\sqrt{\kappa}+1))^2$, the state-transition matrix
$$M = \begin{pmatrix} 1+\beta-\alpha\lambda & -\beta \\ 1 & 0 \end{pmatrix}$$
has a **double eigenvalue** $r = (\sqrt{\kappa}-1)/(\sqrt{\kappa}+1)$ at $\lambda = \mu$ (and $-r$ at $\lambda = L$), with non-trivial Jordan structure. The convergence rate is therefore
$$\|x_k - x^*\| \le C(k+1)\,r^k, \qquad \limsup_{k\to\infty}\|x_k - x^*\|^{1/k} = r.$$

## Proof
The characteristic polynomial of $M$ is $\sigma^2 - (1+\beta-\alpha\lambda)\sigma + \beta = 0$. With the optimal parameters and $\lambda = \mu$ one computes:
$$1 + \beta - \alpha\mu = 1 + r^2 - \tfrac{4}{(\sqrt{\kappa}+1)^2} = \tfrac{2(\sqrt{\kappa}-1)(\sqrt{\kappa}+1)}{(\sqrt{\kappa}+1)^2} = 2r,$$
so the discriminant is $(2r)^2 - 4r^2 = 0$, yielding double root $\sigma = r$. Similarly at $\lambda = L$ one gets double root $-r$.

The matrix $M_1 - rI = \begin{pmatrix} r & -r^2 \\ 1 & -r \end{pmatrix}$ has rank 1 (row 1 = $r \cdot$ row 2), so the eigenspace is 1-dimensional, confirming a non-trivial Jordan block. For such a block, $J^k = \begin{pmatrix} \sigma^k & k\sigma^{k-1} \\ 0 & \sigma^k \end{pmatrix}$ with $\|J^k\| = O(k|\sigma|^k)$. Conjugating back gives the bound. $\square$

## Source
- `proofs/research/optimization/convergence/heavy-ball-instability/proof.md` — Part 1, Steps 4-6.

## Status
- **Correctness**: VERIFIED (algebraic, numerically reproducible)
- **Used in final proof**: YES (proves the optimal rate side of the Heavy-Ball quadratic theorem)
- **Potential applications**:
  - Heavy Ball / Polyak momentum analysis on quadratics
  - Analyzing why momentum methods are "second-order" linear recursions
  - Constructing Jordan-block-based counterexamples to first-iterate convergence rates
  - Spectral analysis of any 2-step linear recursion at the critical-damping limit
  - Showing the slack factor $k$ in the standard rate $O(k r^k)$

## Tags
heavy-ball, jordan-block, spectral, momentum, quadratic, convergence-rate
