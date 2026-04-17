# ADMM Ergodic O(1/K) Convergence Rate

## Source
- Paper: He & Yuan 2012, Boyd et al. 2011 (ADMM survey)
- Context: Fundamental convergence rate result for ADMM in convex optimization

## Statement

Consider the convex optimization problem:
$$\min_{x \in \mathbb{R}^n, z \in \mathbb{R}^m} f(x) + g(z) \quad \text{s.t.} \quad Ax + Bz = c$$
where $f: \mathbb{R}^n \to \mathbb{R} \cup \{+\infty\}$ and $g: \mathbb{R}^m \to \mathbb{R} \cup \{+\infty\}$ are proper, closed, convex functions, $A \in \mathbb{R}^{p \times n}$, $B \in \mathbb{R}^{p \times m}$, $c \in \mathbb{R}^p$.

The ADMM iterates with penalty parameter $\rho > 0$ are:
$$x^{k+1} = \arg\min_x \left\{ f(x) + \frac{\rho}{2} \|Ax + Bz^k - c + u^k\|^2 \right\}$$
$$z^{k+1} = \arg\min_z \left\{ g(z) + \frac{\rho}{2} \|Ax^{k+1} + Bz - c + u^k\|^2 \right\}$$
$$u^{k+1} = u^k + Ax^{k+1} + Bz^{k+1} - c$$

**Assumptions (Version A — full column rank):**
1. A saddle point $(x^\star, z^\star, u^\star)$ of the augmented Lagrangian exists
2. $B$ has full column rank

**Assumptions (Version B — general):**
1. $f$ and $g$ are closed proper convex functions
2. The unaugmented Lagrangian has a saddle point $(x^*, z^*, y^*)$
3. The ADMM subproblems are solvable

Define the ergodic averages $\bar{x}^K = \frac{1}{K}\sum_{k=1}^K x^k$, $\bar{z}^K = \frac{1}{K}\sum_{k=1}^K z^k$.

**Prove (both versions):**
$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) \leq \frac{C}{K}$$
$$\|A\bar{x}^K + B\bar{z}^K - c\| \leq \frac{C}{K}$$

where $C > 0$ depends on the initial point and problem data.

**Note:** Version A provides a cleaner Lyapunov argument (the full-rank assumption ensures unique $z$-subproblem solutions and a genuine distance metric $\|B(z-z^k)\|$). Version B is more general but requires explicit solvability of subproblems as an assumption.

## Difficulty
research
