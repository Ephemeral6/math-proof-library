# O(1/K) Convergence of the Extragradient Method for Convex-Concave Minimax Problems

## Setup and Notation

**Problem.** $\min_{x \in \mathcal{X}} \max_{y \in \mathcal{Y}} f(x, y)$ where $\mathcal{X}, \mathcal{Y}$ are closed convex sets, $Z = \mathcal{X} \times \mathcal{Y}$ is compact, $f$ is convex in $x$, concave in $y$, and has $L$-Lipschitz continuous gradients.

**Operator.** $F(z) = (\nabla_x f(x,y),\; -\nabla_y f(x,y))$ for $z = (x,y)$.

**Extragradient method.** With step size $\eta > 0$:
- Extrapolation: $\bar{z}^k = \Pi_Z(z^k - \eta F(z^k))$
- Update: $z^{k+1} = \Pi_Z(z^k - \eta F(\bar{z}^k))$

**Ergodic iterate.** $\hat{z}^K = \frac{1}{K}\sum_{k=0}^{K-1} \bar{z}^k$, with components $\hat{x}^K = \frac{1}{K}\sum_k \bar{x}^k$, $\hat{y}^K = \frac{1}{K}\sum_k \bar{y}^k$.

**Primal-dual gap.** $\mathrm{Gap}(\hat{z}) = \max_{y' \in \mathcal{Y}} f(\hat{x}, y') - \min_{x' \in \mathcal{X}} f(x', \hat{y})$.

---

### Theorem

Let $\eta = \frac{1}{2L}$ and $D^2 = \sup_{u \in Z}\|z^0 - u\|^2$. Then:

**(a) Per-comparator bound.** For any $u = (x', y') \in Z$:

$$f(\hat{x}^K, y') - f(x', \hat{y}^K) \leq \frac{\|z^0 - u\|^2}{2\eta K} = \frac{L\|z^0 - u\|^2}{K}$$

**(b) Full duality gap.** If $Z$ is bounded:

$$\mathrm{Gap}(\hat{z}^K) \leq \frac{2LD^2}{K}$$

**(c) Saddle-point residual.** If $z^* = (x^*, y^*)$ is a saddle point:

$$f(\hat{x}^K, y^*) - f(x^*, \hat{y}^K) \leq \frac{L\|z^0 - z^*\|^2}{K}$$

---

## Part 0: Foundational Facts

### Fact 1 (Monotonicity of $F$)

$\langle F(z) - F(z'), z - z' \rangle \geq 0$ for all $z, z' \in Z$.

*Proof.* Let $z = (x,y)$, $z' = (x',y')$. By convexity of $f(\cdot, y')$ and $f(\cdot, y)$:

$$f(x, y') \geq f(x', y') + \langle \nabla_x f(x', y'), x - x' \rangle \tag{i}$$
$$f(x', y) \geq f(x, y) + \langle \nabla_x f(x, y), x' - x \rangle \tag{ii}$$

By concavity of $f(x, \cdot)$ and $f(x', \cdot)$:

$$f(x, y') \leq f(x, y) + \langle \nabla_y f(x, y), y' - y \rangle \tag{iii}$$
$$f(x', y) \leq f(x', y') + \langle \nabla_y f(x', y'), y - y' \rangle \tag{iv}$$

Summing (i)+(ii)+(iii)+(iv), all function values cancel, yielding:

$$0 \leq \langle \nabla_x f(x,y) - \nabla_x f(x',y'), x - x' \rangle + \langle -\nabla_y f(x,y) + \nabla_y f(x',y'), y - y' \rangle = \langle F(z) - F(z'), z - z' \rangle \quad \blacksquare$$

### Fact 2 (Lipschitz continuity)

$\|F(z) - F(z')\| \leq L\|z - z'\|$, which follows directly from $L$-smoothness of $f$.

### Fact 3 (Projection properties)

For $p = \Pi_Z(w)$ and any $u \in Z$:

**(a)** $\langle w - p, u - p \rangle \leq 0$.

**(b)** $\|p - u\|^2 \leq \|w - u\|^2 - \|w - p\|^2$.

*Proof of (b).* $\|w - u\|^2 = \|w - p\|^2 + 2\langle w - p, p - u \rangle + \|p - u\|^2 \geq \|w - p\|^2 + \|p - u\|^2$, where the inequality uses $\langle w - p, p - u \rangle = -\langle w - p, u - p\rangle \geq 0$ by (a). $\blacksquare$

### Polarization identity

We use the identity $2\langle a, b \rangle = \|a + b\|^2 - \|a\|^2 - \|b\|^2$ repeatedly below.

---

## Part I: Per-Iteration Telescoping Inequality

**Proposition.** For any $u \in Z$ and $k \geq 0$, with $\eta L \leq 1$:

$$2\eta \langle F(\bar{z}^k), \bar{z}^k - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1 - \eta L)\|\bar{z}^k - z^k\|^2 - (1 - \eta L)\|\bar{z}^k - z^{k+1}\|^2$$

In particular, for $\eta = 1/(2L)$, the last two terms are non-positive and may be dropped:

$$2\eta \langle F(\bar{z}^k), \bar{z}^k - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 \tag{$\star$}$$

### Proof

The key idea is to decompose $\langle F(\bar{z}^k), \bar{z}^k - u \rangle$ into three inner products, each handled by a different tool: (1) the update projection VI, (2) the extrapolation projection VI, and (3) the Lipschitz error. The extrapolation step produces a $+\|z^k - z^{k+1}\|^2$ term that exactly cancels the $-\|z^k - z^{k+1}\|^2$ from the update step — this cancellation is the central mechanism that makes extragradient work.

**Step 1: Upper bound from the update projection.**

Apply Fact 3(a) to $z^{k+1} = \Pi_Z(z^k - \eta F(\bar{z}^k))$ with comparator $u \in Z$:

$$\langle z^k - \eta F(\bar{z}^k) - z^{k+1}, \; u - z^{k+1} \rangle \leq 0$$

Rearranging: $\eta\langle F(\bar{z}^k), u - z^{k+1} \rangle \leq \langle z^k - z^{k+1}, u - z^{k+1} \rangle$.

Apply the polarization identity with $a = z^k - z^{k+1}$, $b = u - z^{k+1}$, so $a + b = z^k + u - 2z^{k+1}$ and we use $2\langle a, b\rangle = \|a\|^2 + \|b\|^2 - \|a - b\|^2$ with $a - b = z^k - u$:

$$2\langle z^k - z^{k+1}, u - z^{k+1} \rangle = \|z^k - z^{k+1}\|^2 + \|u - z^{k+1}\|^2 - \|z^k - u\|^2$$

Therefore:

$$2\eta\langle F(\bar{z}^k), z^{k+1} - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - \|z^k - z^{k+1}\|^2 \tag{U}$$

**Step 2: Upper bound from the extrapolation projection.**

Apply Fact 3(a) to $\bar{z}^k = \Pi_Z(z^k - \eta F(z^k))$ with comparator $z^{k+1} \in Z$:

$$\langle z^k - \eta F(z^k) - \bar{z}^k, \; z^{k+1} - \bar{z}^k \rangle \leq 0$$

Rearranging: $\langle z^k - \bar{z}^k, z^{k+1} - \bar{z}^k \rangle \leq \eta\langle F(z^k), z^{k+1} - \bar{z}^k \rangle$, hence:

$$\eta\langle F(z^k), \bar{z}^k - z^{k+1} \rangle \leq \langle z^k - \bar{z}^k, \bar{z}^k - z^{k+1} \rangle$$

Apply the polarization identity with $a = z^k - \bar{z}^k$, $b = \bar{z}^k - z^{k+1}$, so $a + b = z^k - z^{k+1}$:

$$2\langle z^k - \bar{z}^k, \bar{z}^k - z^{k+1} \rangle = \|z^k - z^{k+1}\|^2 - \|z^k - \bar{z}^k\|^2 - \|\bar{z}^k - z^{k+1}\|^2$$

Therefore:

$$2\eta\langle F(z^k), \bar{z}^k - z^{k+1} \rangle \leq \|z^k - z^{k+1}\|^2 - \|z^k - \bar{z}^k\|^2 - \|\bar{z}^k - z^{k+1}\|^2 \tag{E}$$

**Step 3: Lipschitz error bound.**

By Cauchy-Schwarz, Fact 2, and Young's inequality ($2ab \leq a^2 + b^2$):

$$2\eta\langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^{k+1} \rangle \leq 2\eta L\|\bar{z}^k - z^k\| \cdot \|\bar{z}^k - z^{k+1}\| \leq \eta L\bigl(\|\bar{z}^k - z^k\|^2 + \|\bar{z}^k - z^{k+1}\|^2\bigr) \tag{L}$$

**Step 4: Combine via the EG decomposition.**

Decompose the target inner product:

$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u \rangle = \underbrace{2\eta\langle F(\bar{z}^k), z^{k+1} - u \rangle}_{\text{bounded by (U)}} + \underbrace{2\eta\langle F(z^k), \bar{z}^k - z^{k+1} \rangle}_{\text{bounded by (E)}} + \underbrace{2\eta\langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^{k+1} \rangle}_{\text{bounded by (L)}}$$

Substituting (U), (E), and (L):

$$\leq \bigl[\|z^k - u\|^2 - \|z^{k+1} - u\|^2 \underbrace{- \|z^k - z^{k+1}\|^2}_{\text{from (U)}}\bigr] + \bigl[\underbrace{+ \|z^k - z^{k+1}\|^2}_{\text{from (E)}} - \|\bar{z}^k - z^k\|^2 - \|\bar{z}^k - z^{k+1}\|^2\bigr] + \bigl[\eta L\|\bar{z}^k - z^k\|^2 + \eta L\|\bar{z}^k - z^{k+1}\|^2\bigr]$$

**The EG cancellation:** The terms $-\|z^k - z^{k+1}\|^2$ from (U) and $+\|z^k - z^{k+1}\|^2$ from (E) cancel exactly. This cancellation is specific to the extragradient structure — the extrapolation step evaluates $F$ at $z^k$ (not $\bar{z}^k$), producing a three-point identity whose positive term matches the negative term from the update step.

Collecting the remaining terms:

$$= \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1 - \eta L)\|\bar{z}^k - z^k\|^2 - (1 - \eta L)\|\bar{z}^k - z^{k+1}\|^2$$

With $\eta = \frac{1}{2L}$: the coefficient is $1 - \eta L = \frac{1}{2} > 0$, so the last two terms are non-positive:

$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 \tag{$\star$}$$

$\blacksquare$

---

## Part II: Operator-Gap Inequality

**Lemma.** For any $\bar{z} = (\bar{x}, \bar{y}) \in Z$ and $u = (x', y') \in Z$:

$$\langle F(\bar{z}), \bar{z} - u \rangle \geq f(\bar{x}, y') - f(x', \bar{y})$$

*Proof.* Expand the inner product:

$$\langle F(\bar{z}), \bar{z} - u \rangle = \langle \nabla_x f(\bar{x}, \bar{y}), \bar{x} - x' \rangle + \langle -\nabla_y f(\bar{x}, \bar{y}), \bar{y} - y' \rangle$$

By convexity of $f(\cdot, \bar{y})$: $f(x', \bar{y}) \geq f(\bar{x}, \bar{y}) + \langle \nabla_x f(\bar{x}, \bar{y}), x' - \bar{x} \rangle$, hence:

$$\langle \nabla_x f(\bar{x}, \bar{y}), \bar{x} - x' \rangle \geq f(\bar{x}, \bar{y}) - f(x', \bar{y}) \tag{G1}$$

By concavity of $f(\bar{x}, \cdot)$: $f(\bar{x}, y') \leq f(\bar{x}, \bar{y}) + \langle \nabla_y f(\bar{x}, \bar{y}), y' - \bar{y} \rangle$, hence $\langle \nabla_y f(\bar{x}, \bar{y}), y' - \bar{y} \rangle \geq f(\bar{x}, y') - f(\bar{x}, \bar{y})$. Negating both sides and the direction:

$$\langle -\nabla_y f(\bar{x}, \bar{y}), \bar{y} - y' \rangle \geq f(\bar{x}, y') - f(\bar{x}, \bar{y}) \tag{G2}$$

Adding (G1) and (G2):

$$\langle F(\bar{z}), \bar{z} - u \rangle \geq [f(\bar{x}, \bar{y}) - f(x', \bar{y})] + [f(\bar{x}, y') - f(\bar{x}, \bar{y})] = f(\bar{x}, y') - f(x', \bar{y}) \quad \blacksquare$$

---

## Part III: Telescoping, Averaging, and Final Bounds

**Step 1: Telescope.** Sum $(\star)$ over $k = 0, \ldots, K-1$ for fixed $u = (x', y') \in Z$:

$$2\eta\sum_{k=0}^{K-1}\langle F(\bar{z}^k), \bar{z}^k - u \rangle \leq \|z^0 - u\|^2 - \|z^K - u\|^2 \leq \|z^0 - u\|^2$$

**Step 2: Apply the operator-gap inequality.** By Part II, $\langle F(\bar{z}^k), \bar{z}^k - u \rangle \geq f(\bar{x}^k, y') - f(x', \bar{y}^k)$ for each $k$. Therefore:

$$\frac{1}{K}\sum_{k=0}^{K-1}\bigl[f(\bar{x}^k, y') - f(x', \bar{y}^k)\bigr] \leq \frac{\|z^0 - u\|^2}{2\eta K}$$

**Step 3: Jensen's inequality.** By convexity of $f(\cdot, y')$:

$$f(\hat{x}^K, y') \leq \frac{1}{K}\sum_k f(\bar{x}^k, y')$$

By concavity of $f(x', \cdot)$:

$$f(x', \hat{y}^K) \geq \frac{1}{K}\sum_k f(x', \bar{y}^k)$$

Subtracting and combining with the telescoping bound:

$$f(\hat{x}^K, y') - f(x', \hat{y}^K) \leq \frac{\|z^0 - (x', y')\|^2}{2\eta K} \quad \forall\, (x', y') \in Z \tag{Per-Comp}$$

This is the **per-comparator bound** — the master inequality from which all three results follow.

**Step 4: Derive the three results.**

**(a)** Statement (a) is exactly (Per-Comp) with $\eta = 1/(2L)$.

**(c)** Set $(x', y') = (x^*, y^*)$ in (Per-Comp):

$$f(\hat{x}^K, y^*) - f(x^*, \hat{y}^K) \leq \frac{\|z^0 - z^*\|^2}{2\eta K} = \frac{L\|z^0 - z^*\|^2}{K}$$

**(b)** For the full gap, let $y^\dagger = \arg\max_{y \in \mathcal{Y}} f(\hat{x}^K, y)$ and $x^\dagger = \arg\min_{x \in \mathcal{X}} f(x, \hat{y}^K)$ (these exist by compactness of $Z$). Apply (Per-Comp) twice:

- With $(x', y') = (x^*, y^\dagger)$: $\;\;\max_y f(\hat{x}^K, y) - f(x^*, \hat{y}^K) \leq \frac{\|z^0 - (x^*, y^\dagger)\|^2}{2\eta K} \leq \frac{D^2}{2\eta K}$

- With $(x', y') = (x^\dagger, y^*)$: $\;\;f(\hat{x}^K, y^*) - \min_x f(x, \hat{y}^K) \leq \frac{\|z^0 - (x^\dagger, y^*)\|^2}{2\eta K} \leq \frac{D^2}{2\eta K}$

Adding:

$$\mathrm{Gap}(\hat{z}^K) + \underbrace{\bigl[f(\hat{x}^K, y^*) - f(x^*, \hat{y}^K)\bigr]}_{\geq\, 0} \leq \frac{D^2}{\eta K}$$

The bracketed term is non-negative because $f(\hat{x}^K, y^*) \geq f(x^*, y^*)$ (since $x^*$ minimizes $f(\cdot, y^*)$) and $f(x^*, \hat{y}^K) \leq f(x^*, y^*)$ (since $y^*$ maximizes $f(x^*, \cdot)$). Dropping it:

$$\mathrm{Gap}(\hat{z}^K) \leq \frac{D^2}{\eta K} = \frac{2LD^2}{K} \quad \blacksquare$$

---

## Summary of Proof Architecture

| Step | Content | Key Tool |
|------|---------|----------|
| Part 0 | Monotonicity, Lipschitz, projection facts | Convex-concave first-order conditions |
| Part I, Step 1 | Bound on $\langle F(\bar{z}^k), z^{k+1} - u\rangle$ | Update projection VI + polarization |
| Part I, Step 2 | Bound on $\langle F(z^k), \bar{z}^k - z^{k+1}\rangle$ | Extrapolation projection VI + polarization |
| Part I, Step 3-4 | Lipschitz error control; **EG cancellation** of $\|z^k - z^{k+1}\|^2$ | Young's inequality |
| Part II | $\langle F(\bar{z}), \bar{z} - u\rangle \geq f(\bar{x}, y') - f(x', \bar{y})$ | Convexity + concavity |
| Part III | Telescope + Jensen + comparator optimization | Telescoping, Jensen, compactness |

**Key insight.** The extragradient method evaluates $F$ at two points per iteration: $z^k$ (for extrapolation) and $\bar{z}^k$ (for the update). The projection VIs from these two steps produce squared-distance terms of opposite sign — specifically $-\|z^k - z^{k+1}\|^2$ from (U) and $+\|z^k - z^{k+1}\|^2$ from (E) — that cancel exactly. The residual error from using $F(\bar{z}^k)$ instead of $F(z^k)$ in the update is controlled by L-Lipschitz continuity and Young's inequality, leaving a net negative contribution of $-\frac{1}{2}(\|\bar{z}^k - z^k\|^2 + \|\bar{z}^k - z^{k+1}\|^2)$ that can be dropped.

---

## Final Result

$$\boxed{\mathrm{Gap}(\hat{z}^K) \leq \frac{2L \cdot D^2}{K}, \qquad D^2 = \sup_{u \in Z}\|z^0 - u\|^2, \quad \eta = \frac{1}{2L}}$$

This establishes $O(1/K)$ convergence of the Extragradient method for convex-concave minimax optimization, which is optimal among first-order methods in this setting. $\blacksquare$
