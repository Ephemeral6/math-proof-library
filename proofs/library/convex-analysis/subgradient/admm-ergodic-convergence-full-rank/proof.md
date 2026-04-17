# ADMM Ergodic O(1/K) Convergence Rate — Complete Proof

## Theorem

Consider the convex optimization problem:
$$\min_{x \in \mathbb{R}^n, z \in \mathbb{R}^m} f(x) + g(z) \quad \text{s.t.} \quad Ax + Bz = c$$

where $f, g$ are proper, closed, convex functions, $A \in \mathbb{R}^{p \times n}$, $B \in \mathbb{R}^{p \times m}$, $c \in \mathbb{R}^p$.

The ADMM iterates with penalty parameter $\rho > 0$ are:
$$x^{k+1} = \arg\min_x \left\{ f(x) + \frac{\rho}{2} \|Ax + Bz^k - c + u^k\|^2 \right\}$$
$$z^{k+1} = \arg\min_z \left\{ g(z) + \frac{\rho}{2} \|Ax^{k+1} + Bz - c + u^k\|^2 \right\}$$
$$u^{k+1} = u^k + Ax^{k+1} + Bz^{k+1} - c$$

**Assumptions:**
1. A saddle point $(x^\star, z^\star, u^\star)$ of the augmented Lagrangian exists.
2. $B$ has full column rank.

**Conclusion.** The ergodic averages $\bar{x}^K = \frac{1}{K}\sum_{k=1}^K x^k$, $\bar{z}^K = \frac{1}{K}\sum_{k=1}^K z^k$ satisfy:

$$\left|f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star)\right| \leq \frac{C}{K}, \qquad \|A\bar{x}^K + B\bar{z}^K - c\| \leq \frac{C}{K}$$

where $C > 0$ depends on $\rho$, $\|\lambda^0 - \lambda^\star\|$, $\|B(z^0 - z^\star)\|$, and $\|\lambda^\star\|$.

---

## Notation and Setup

- Unscaled dual variable: $\lambda^k = \rho u^k$, saddle-point dual: $\lambda^\star = \rho u^\star$.
- Primal residual: $r^{k+1} = Ax^{k+1} + Bz^{k+1} - c$.
- Dual update (unscaled): $\lambda^{k+1} = \lambda^k + \rho r^{k+1}$.
- Saddle-point (KKT) conditions:

$$0 \in \partial f(x^\star) + A^\top \lambda^\star \tag{S1}$$
$$0 \in \partial g(z^\star) + B^\top \lambda^\star \tag{S2}$$
$$Ax^\star + Bz^\star = c \tag{S3}$$

- Lagrangian: $\mathcal{L}(x, z, \lambda) = f(x) + g(z) + \langle \lambda, Ax + Bz - c\rangle$.
- Lyapunov quantity: $V^0 := \frac{1}{\rho}\|\lambda^\star - \lambda^0\|^2 + \rho\|B(z^\star - z^0)\|^2$.

---

## Step 1: Subproblem Optimality Conditions

**$x$-subproblem.** The optimality condition for the $x$-update is:
$$0 \in \partial f(x^{k+1}) + \rho A^\top(Ax^{k+1} + Bz^k - c + u^k) \tag{2}$$

Using the dual update $u^{k+1} = u^k + r^{k+1}$, we derive:
$$Ax^{k+1} + Bz^k - c + u^k = u^{k+1} + B(z^k - z^{k+1}) \tag{3}$$

Therefore:
$$0 \in \partial f(x^{k+1}) + A^\top \lambda^{k+1} + \rho A^\top B(z^k - z^{k+1}) \tag{4'}$$

**$z$-subproblem.** The optimality condition is:
$$0 \in \partial g(z^{k+1}) + \rho B^\top(Ax^{k+1} + Bz^{k+1} - c + u^k)$$

Since $Ax^{k+1} + Bz^{k+1} - c + u^k = u^{k+1}$:
$$0 \in \partial g(z^{k+1}) + B^\top \lambda^{k+1} \tag{6}$$

---

## Step 2: Per-Iteration Variational Inequality

By convexity of $f$ and the subgradient from (4'), for any $x$:
$$f(x) - f(x^{k+1}) \geq \langle -A^\top \lambda^{k+1} - \rho A^\top B(z^k - z^{k+1}),\; x - x^{k+1}\rangle$$

By convexity of $g$ and the subgradient from (6), for any $z$:
$$g(z) - g(z^{k+1}) \geq \langle -B^\top \lambda^{k+1},\; z - z^{k+1}\rangle$$

Adding these, for any $(x, z)$ with $Ax + Bz = c$:

$$f(x) + g(z) - f(x^{k+1}) - g(z^{k+1}) \geq -\langle \lambda^{k+1}, c - Ax^{k+1} - Bz^{k+1}\rangle - \rho\langle B(z^k - z^{k+1}), A(x - x^{k+1})\rangle$$

$$= \langle \lambda^{k+1}, r^{k+1}\rangle - \rho\langle B(z^k - z^{k+1}), A(x - x^{k+1})\rangle$$

Equivalently, for any $\lambda$ (introducing $\mathcal{L}$):

$$\mathcal{L}(x^{k+1}, z^{k+1}, \lambda) - \mathcal{L}(x, z, \lambda^{k+1}) \leq \langle \lambda - \lambda^{k+1}, r^{k+1}\rangle + \rho\langle B(z^k - z^{k+1}), A(x - x^{k+1})\rangle \tag{$\star$}$$

---

## Step 3: Algebraic Identities Yield Telescoping

**Term 1: $\langle \lambda - \lambda^{k+1}, r^{k+1}\rangle$.**

Using $r^{k+1} = \frac{1}{\rho}(\lambda^{k+1} - \lambda^k)$ and the three-point identity $\langle a - b, b - c\rangle = \frac{1}{2}(\|a - c\|^2 - \|a - b\|^2 - \|b - c\|^2)$:

$$\langle \lambda - \lambda^{k+1}, \lambda^{k+1} - \lambda^k\rangle = \frac{1}{2}\bigl(\|\lambda - \lambda^k\|^2 - \|\lambda - \lambda^{k+1}\|^2 - \|\lambda^{k+1} - \lambda^k\|^2\bigr)$$

Therefore:
$$\langle \lambda - \lambda^{k+1}, r^{k+1}\rangle = \frac{1}{2\rho}\bigl(\|\lambda - \lambda^k\|^2 - \|\lambda - \lambda^{k+1}\|^2\bigr) - \frac{\rho}{2}\|r^{k+1}\|^2 \tag{$\star\star$}$$

**Term 2: $\rho\langle B(z^k - z^{k+1}), A(x - x^{k+1})\rangle$.**

Using feasibility $Ax = c - Bz$ and $Ax^{k+1} = r^{k+1} + c - Bz^{k+1}$:

$$A(x - x^{k+1}) = B(z^{k+1} - z) - r^{k+1}$$

By the polarization identity with $p = B(z^k - z^{k+1})$, $q = B(z^{k+1} - z)$, $p + q = B(z^k - z)$:

$$\rho\langle B(z^k - z^{k+1}), B(z^{k+1} - z)\rangle = \frac{\rho}{2}\bigl(\|B(z^k - z)\|^2 - \|B(z^k - z^{k+1})\|^2 - \|B(z^{k+1} - z)\|^2\bigr)$$

$$= \frac{\rho}{2}\bigl(\|B(z - z^k)\|^2 - \|B(z - z^{k+1})\|^2\bigr) - \frac{\rho}{2}\|B(z^k - z^{k+1})\|^2 \tag{$\star\star\star$}$$

**Combining with the cross term involving $r^{k+1}$:**

$$-\frac{\rho}{2}\|r^{k+1}\|^2 - \frac{\rho}{2}\|B(z^k - z^{k+1})\|^2 - \rho\langle B(z^k - z^{k+1}), r^{k+1}\rangle = -\frac{\rho}{2}\|r^{k+1} + B(z^k - z^{k+1})\|^2 = -\frac{\rho}{2}\|s^{k+1}\|^2$$

where $s^{k+1} = Ax^{k+1} + Bz^k - c$.

---

## Step 4: KEY Per-Step Inequality

Substituting ($\star\star$) and ($\star\star\star$) into ($\star$):

$$\boxed{\mathcal{L}(x^{k+1}, z^{k+1}, \lambda) - \mathcal{L}(x, z, \lambda^{k+1}) \leq \frac{1}{2\rho}\bigl(\|\lambda - \lambda^k\|^2 - \|\lambda - \lambda^{k+1}\|^2\bigr) + \frac{\rho}{2}\bigl(\|B(z - z^k)\|^2 - \|B(z - z^{k+1})\|^2\bigr) - \frac{\rho}{2}\|s^{k+1}\|^2} \tag{KEY}$$

The first two terms on the RHS are **perfectly telescoping**, and the last term $-\frac{\rho}{2}\|s^{k+1}\|^2 \leq 0$ is non-positive.

---

## Step 5: Telescoping Sum

Sum (KEY) over $k = 0, \ldots, K-1$ (iterate index $1$ to $K$), dropping the non-positive $-\frac{\rho}{2}\|s^{k+1}\|^2$ and the non-positive final Lyapunov terms:

$$\sum_{k=1}^{K}\bigl[\mathcal{L}(x^k, z^k, \lambda) - \mathcal{L}(x, z, \lambda^k)\bigr] \leq \frac{1}{2\rho}\|\lambda - \lambda^0\|^2 + \frac{\rho}{2}\|B(z - z^0)\|^2 \tag{SUM}$$

---

## Step 6: Jensen's Inequality for Ergodic Averages

Since $f$ and $g$ are convex, by Jensen's inequality:
$$f(\bar{x}^K) + g(\bar{z}^K) \leq \frac{1}{K}\sum_{k=1}^K \bigl[f(x^k) + g(z^k)\bigr]$$

The Lagrangian inner product is linear: $\frac{1}{K}\sum_{k=1}^K \langle \lambda, r^k\rangle = \langle \lambda, A\bar{x}^K + B\bar{z}^K - c\rangle$.

Therefore, dividing (SUM) by $K$ and applying Jensen:

$$f(\bar{x}^K) + g(\bar{z}^K) - f(x) - g(z) + \langle \lambda, A\bar{x}^K + B\bar{z}^K - c\rangle - \frac{1}{K}\sum_{k=1}^K \langle \lambda^k, Ax + Bz - c\rangle$$

Since $Ax + Bz = c$, the last term vanishes:

$$f(\bar{x}^K) + g(\bar{z}^K) - f(x) - g(z) + \langle \lambda, \bar{r}^K\rangle \leq \frac{1}{2\rho K}\|\lambda - \lambda^0\|^2 + \frac{\rho}{2K}\|B(z - z^0)\|^2 \tag{GEN}$$

where $\bar{r}^K = A\bar{x}^K + B\bar{z}^K - c$.

---

## Step 7: Non-negativity from Saddle-Point Conditions

From (S1) and (S2), by convexity:
$$f(x^k) - f(x^\star) \geq -\langle \lambda^\star, A(x^k - x^\star)\rangle$$
$$g(z^k) - g(z^\star) \geq -\langle \lambda^\star, B(z^k - z^\star)\rangle$$

Summing: $f(x^k) + g(z^k) - f(x^\star) - g(z^\star) \geq -\langle \lambda^\star, r^k\rangle$.

By Jensen's inequality applied to the convex functions and linearity:
$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) + \langle \lambda^\star, \bar{r}^K\rangle \geq 0 \tag{21}$$

---

## Step 8: Feasibility Bound

From (GEN) with $(x, z) = (x^\star, z^\star)$ and $\lambda = \lambda^0 + \rho K \bar{r}^K$:

$$\|\lambda - \lambda^0\|^2 = \rho^2 K^2 \|\bar{r}^K\|^2, \qquad \langle \lambda, \bar{r}^K\rangle = \langle \lambda^0, \bar{r}^K\rangle + \rho K\|\bar{r}^K\|^2$$

Substituting into (GEN):

$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) + \langle \lambda^0, \bar{r}^K\rangle + \rho K\|\bar{r}^K\|^2 \leq \frac{\rho K}{2}\|\bar{r}^K\|^2 + \frac{\rho}{2K}\|B(z^\star - z^0)\|^2$$

$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) + \langle \lambda^0, \bar{r}^K\rangle + \frac{\rho K}{2}\|\bar{r}^K\|^2 \leq \frac{\rho}{2K}\|B(z^\star - z^0)\|^2$$

From (21): $f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) \geq -\langle \lambda^\star, \bar{r}^K\rangle$, so:

$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) + \langle \lambda^0, \bar{r}^K\rangle \geq \langle \lambda^0 - \lambda^\star, \bar{r}^K\rangle \geq -\|\lambda^0 - \lambda^\star\|\cdot\|\bar{r}^K\|$$

Therefore:
$$-\|\lambda^0 - \lambda^\star\|\cdot\|\bar{r}^K\| + \frac{\rho K}{2}\|\bar{r}^K\|^2 \leq \frac{\rho}{2K}\|B(z^\star - z^0)\|^2$$

Let $\phi = \|\bar{r}^K\|$. The quadratic inequality $\frac{\rho K}{2}\phi^2 - \|\lambda^0 - \lambda^\star\|\phi - \frac{\rho}{2K}\|B(z^\star - z^0)\|^2 \leq 0$ gives:

$$\phi \leq \frac{\|\lambda^0 - \lambda^\star\| + \sqrt{\|\lambda^0 - \lambda^\star\|^2 + \rho^2\|B(z^\star - z^0)\|^2}}{\rho K} \leq \frac{2\|\lambda^0 - \lambda^\star\|/\rho + \|B(z^0 - z^\star)\|}{K}$$

Therefore:
$$\|\bar{r}^K\| = \|A\bar{x}^K + B\bar{z}^K - c\| \leq \frac{C_1}{K} \tag{FEAS}$$

where $C_1 = \frac{2\|\lambda^0 - \lambda^\star\|}{\rho} + \|B(z^0 - z^\star)\|$.

---

## Step 9: Objective Bound

**Upper bound.** From (GEN) with $(x, z) = (x^\star, z^\star)$ and $\lambda = \lambda^\star$:

$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) + \langle \lambda^\star, \bar{r}^K\rangle \leq \frac{V^0}{2K}$$

Therefore:
$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) \leq \frac{V^0}{2K} - \langle \lambda^\star, \bar{r}^K\rangle \leq \frac{V^0}{2K} + \|\lambda^\star\|\cdot\|\bar{r}^K\| \leq \frac{V^0}{2K} + \frac{\|\lambda^\star\| C_1}{K}$$

**Lower bound.** From (21): $f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) \geq -\|\lambda^\star\|\cdot\|\bar{r}^K\| \geq -\frac{\|\lambda^\star\| C_1}{K}$.

Combining:
$$\left|f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star)\right| \leq \frac{C_2}{K} \tag{OBJ}$$

where $C_2 = \frac{V^0}{2} + \|\lambda^\star\| C_1 = \frac{\|\lambda^\star - \lambda^0\|^2}{2\rho} + \frac{\rho\|B(z^\star - z^0)\|^2}{2} + \|\lambda^\star\|\Bigl(\frac{2\|\lambda^0 - \lambda^\star\|}{\rho} + \|B(z^0 - z^\star)\|\Bigr)$.

---

## Summary

Setting $C = \max(C_1, C_2)$, we obtain:
$$\left|f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star)\right| \leq \frac{C}{K}, \qquad \|A\bar{x}^K + B\bar{z}^K - c\| \leq \frac{C}{K}$$

The constant $C$ depends on $\rho$, $\|\lambda^0 - \lambda^\star\|$, $\|B(z^0 - z^\star)\|$, and $\|\lambda^\star\|$, confirming the $O(1/K)$ ergodic convergence rate. $\blacksquare$

---

## Note on the Role of $B$ Having Full Column Rank

The full column rank of $B$ ensures:
1. The $z$-subproblem has a unique minimizer (the quadratic term $\frac{\rho}{2}\|Bz + d\|^2$ is strictly convex in $z$).
2. The Lyapunov term $\rho\|B(z - z^k)\|^2$ is a genuine measure of distance in $z$-space (controlling $\|z - z^k\|$ up to the smallest singular value of $B$).
3. The constant $C_1$ involving $\|B(z^0 - z^\star)\|$ is meaningful and finite.

In the proof above, the full column rank assumption is used to ensure the $z$-subproblem is well-posed and the Lyapunov function $V^0$ is a proper measure of the initial distance to the saddle point.

---

## Alternative Proof: General Case (Version B — no full-rank assumption)

When $B$ does not have full column rank, the same $O(1/K)$ rate holds under the weaker assumptions that a saddle point exists and the subproblems are solvable. The proof below uses direct summation via optimality conditions instead of the He-Yuan variational inequality framework.

**Notation.** Let $r^{k+1} = Ax^{k+1} + Bz^{k+1} - c$, $y^k = \rho u^k$, and $(x^*, z^*, y^*)$ a saddle point.

**Step 1: Optimality conditions.** From the x-update: $\xi_f^{k+1} = -A^\top(y^{k+1} + \rho B(z^k - z^{k+1})) \in \partial f(x^{k+1})$. From the z-update: $\xi_g^{k+1} = -B^\top y^{k+1} \in \partial g(z^{k+1})$. By convexity at the optimal point and $A(x^* - x^{k+1}) + B(z^* - z^{k+1}) = -r^{k+1}$:

$$f(x^*) + g(z^*) \geq f(x^{k+1}) + g(z^{k+1}) + \langle y^{k+1}, r^{k+1}\rangle - \rho\langle B(z^k - z^{k+1}), A(x^* - x^{k+1})\rangle.$$

**Step 2: Lyapunov decomposition.** Define $W^k = \frac{1}{2\rho}\|y^k - y^*\|^2 + \frac{\rho}{2}\|B(z^k - z^*)\|^2$. Using $y^{k+1} = y^k + \rho r^{k+1}$ and polarization identities to decompose both inner product terms, all cross terms assemble into a non-negative perfect square $\frac{\rho}{2}\|r^{k+1} + B(z^k - z^{k+1})\|^2 \geq 0$, yielding:

$$f(x^{k+1}) + g(z^{k+1}) + \langle y^*, r^{k+1}\rangle - f(x^*) - g(z^*) \leq W^k - W^{k+1}. \tag{*}$$

**Step 3: Telescope and average.** Sum (*) from $k=0$ to $K-1$, apply Jensen's inequality (convexity of $f$, $g$) and linearity to the ergodic averages:

$$f(\bar{x}^K) + g(\bar{z}^K) - f(x^*) - g(z^*) + \langle y^*, \bar{r}^K\rangle \leq \frac{W^0}{K}.$$

**Step 4: Extract rates.** Primal feasibility: $\bar{r}^K = (u^K - u^0)/K$ and $\|u^K - u^*\| \leq \sqrt{2W^0/\rho}$ from $W^K \leq W^0$. Objective sub-optimality: the saddle-point inequality gives $f(\bar{x}^K) + g(\bar{z}^K) - f(x^*) - g(z^*) \geq -\|y^*\|\|\bar{r}^K\|$, combined with the upper bound.

$$\|A\bar{x}^K + B\bar{z}^K - c\| \leq \frac{C_0}{K}, \qquad |f(\bar{x}^K) + g(\bar{z}^K) - f(x^*) - g(z^*)| \leq \frac{C_0}{K}.$$

The constant $C_0$ depends on $W^0$, $\|y^*\|$, $\|u^0\|$. The argument uses $\|B(z-z^*)\|$ only as a semi-norm in the Lyapunov function — no full-rank assumption is needed. $\blacksquare$
