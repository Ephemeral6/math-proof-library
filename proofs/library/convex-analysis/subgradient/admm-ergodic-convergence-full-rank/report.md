# Proof Report: ADMM Ergodic O(1/K) Convergence Rate

## 1. Problem Statement

Consider the convex optimization problem:
$$\min_{x \in \mathbb{R}^n, z \in \mathbb{R}^m} f(x) + g(z) \quad \text{s.t.} \quad Ax + Bz = c$$

where $f, g$ are proper, closed, convex functions, $A \in \mathbb{R}^{p \times n}$, $B \in \mathbb{R}^{p \times m}$ with $B$ having full column rank, $c \in \mathbb{R}^p$.

**Prove:** The ADMM ergodic averages $\bar{x}^K = \frac{1}{K}\sum_{k=1}^K x^k$, $\bar{z}^K = \frac{1}{K}\sum_{k=1}^K z^k$ satisfy:
$$|f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star)| \leq \frac{C}{K}, \qquad \|A\bar{x}^K + B\bar{z}^K - c\| \leq \frac{C}{K}$$

**Source:** He & Yuan 2012, Boyd et al. 2011 (ADMM survey)
**Difficulty:** Research

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed (Lyapunov+telescoping, dual ascent, VI formulation, direct primal-dual gap) |
| Explorer | Opus | 4 proofs attempted, 4 succeeded (Route 1 most detailed) |
| Judge | Sonnet | Route 1 selected (score: 35/40) |
| Audit | Opus | PASS (1 round, 0 INVALID steps, 3 LOW issues) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

### Route 1: Lyapunov Function + Telescoping (Standard Variational Approach)
- **Outcome:** SUCCESS
- **Approach:** Construct Lyapunov function $V^k = \frac{1}{\rho}\|\lambda^k - \lambda^\star\|^2 + \rho\|B(z^k - z^\star)\|^2$, derive per-step variational inequality, telescope, and apply Jensen's inequality.
- **Score:** 35/40 (Completeness 9, Correctness 9, Elegance 8, Gaps minimal)
- **Note:** The proof explores multiple sub-approaches before converging on the definitive version via the KEY per-step inequality that telescopes perfectly.

### Route 2: Dual Ascent / Augmented Lagrangian Subgradient Bound
- **Outcome:** COMPLETED (listed in routes.md)
- **Approach:** Interpret dual update as gradient ascent, use strong duality for primal bounds.

### Route 4: Variational Inequality Formulation + Ergodic Rate
- **Outcome:** COMPLETED (listed in routes.md)
- **Approach:** Write ADMM as VI, show per-step VI gap bound, average for O(1/K).

### Route 5: Direct Primal-Dual Gap Bounding via Optimality Conditions
- **Outcome:** COMPLETED (listed in routes.md)
- **Approach:** Extract first-order optimality, use subgradient inequality, telescope.

## 4. Final Proof

### Notation
- Unscaled dual: $\lambda^k = \rho u^k$, primal residual: $r^{k+1} = Ax^{k+1} + Bz^{k+1} - c$
- Dual update: $\lambda^{k+1} = \lambda^k + \rho r^{k+1}$
- Lyapunov: $V^0 = \frac{1}{\rho}\|\lambda^\star - \lambda^0\|^2 + \rho\|B(z^\star - z^0)\|^2$

### Step 1: Subproblem Optimality
From the $x$-update: $0 \in \partial f(x^{k+1}) + A^\top\lambda^{k+1} + \rho A^\top B(z^k - z^{k+1})$.
From the $z$-update: $0 \in \partial g(z^{k+1}) + B^\top\lambda^{k+1}$.

### Step 2: Variational Inequality
For any feasible $(x,z)$ with $Ax + Bz = c$ and any $\lambda$:
$$\mathcal{L}(x^{k+1}, z^{k+1}, \lambda) - \mathcal{L}(x, z, \lambda^{k+1}) \leq \langle \lambda - \lambda^{k+1}, r^{k+1}\rangle + \rho\langle B(z^k - z^{k+1}), A(x - x^{k+1})\rangle$$

### Step 3: KEY Per-Step Inequality
Using the three-point identity on dual terms, polarization identity on primal terms, and the crucial cancellation $-\frac{\rho}{2}\|r^{k+1}\|^2 - \frac{\rho}{2}\|B(z^k - z^{k+1})\|^2 - \rho\langle B(z^k - z^{k+1}), r^{k+1}\rangle = -\frac{\rho}{2}\|s^{k+1}\|^2$ where $s^{k+1} = Ax^{k+1} + Bz^k - c$:

$$\mathcal{L}(x^{k+1}, z^{k+1}, \lambda) - \mathcal{L}(x, z, \lambda^{k+1}) \leq \frac{1}{2\rho}(\|\lambda - \lambda^k\|^2 - \|\lambda - \lambda^{k+1}\|^2) + \frac{\rho}{2}(\|B(z - z^k)\|^2 - \|B(z - z^{k+1})\|^2) - \frac{\rho}{2}\|s^{k+1}\|^2$$

### Step 4: Telescope and Average
Summing over $K$ iterations, dropping non-positive terms, dividing by $K$, and applying Jensen:
$$f(\bar{x}^K) + g(\bar{z}^K) - f(x) - g(z) + \langle \lambda, \bar{r}^K\rangle \leq \frac{1}{2\rho K}\|\lambda - \lambda^0\|^2 + \frac{\rho}{2K}\|B(z - z^0)\|^2$$

### Step 5: Extract Rates
- **Feasibility:** Set $\lambda = \lambda^0 + \rho K\bar{r}^K$ and use saddle-point lower bound to get quadratic in $\|\bar{r}^K\|$, yielding $\|\bar{r}^K\| \leq C_1/K$.
- **Objective:** Set $\lambda = \lambda^\star$ and combine with feasibility bound, yielding $|f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star)| \leq C_2/K$.

### Constants
$$C_1 = \frac{2\|\lambda^0 - \lambda^\star\|}{\rho} + \|B(z^0 - z^\star)\|$$
$$C_2 = \frac{\|\lambda^\star - \lambda^0\|^2}{2\rho} + \frac{\rho\|B(z^\star - z^0)\|^2}{2} + \|\lambda^\star\|\Bigl(\frac{2\|\lambda^0 - \lambda^\star\|}{\rho} + \|B(z^0 - z^\star)\|\Bigr)$$

## 5. Audit Result

**Conclusion: PASS** (Round 1)

All 10 proof steps verified as VALID. Three LOW-severity observations:
1. The role of $B$'s full column rank could be more explicitly invoked (used for well-posedness and Lyapunov validity)
2. Constants depend on unknown saddle-point values (standard in the literature)
3. The inequality $\sqrt{a^2 + b^2} \leq a + b$ could be briefly justified

No correctness issues found.

## 6. Fix History

No fixes needed. The proof passed audit on the first round.
