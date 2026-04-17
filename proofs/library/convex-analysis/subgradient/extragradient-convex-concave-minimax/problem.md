# Extragradient O(1/K) Convergence for Convex-Concave Minimax Problems

## Source
- Context: Convergence analysis of the extragradient method for saddle point problems
- Related work: Korpelevich 1976, Nemirovski 2004, Mokhtari et al. 2020

## Statement

Consider the minimax problem:
$$\min_{x \in \mathcal{X}} \max_{y \in \mathcal{Y}} f(x, y)$$

where $\mathcal{X} \subseteq \mathbb{R}^{d_x}$, $\mathcal{Y} \subseteq \mathbb{R}^{d_y}$ are closed convex sets, $f$ is convex in $x$ for each fixed $y$, concave in $y$ for each fixed $x$, and $L$-smooth (i.e., $\nabla f$ is $L$-Lipschitz continuous).

The **Extragradient (EG) method** with step size $\eta > 0$:

**Extrapolation step:**
$$\bar{x}^{k} = \Pi_{\mathcal{X}}(x^k - \eta \nabla_x f(x^k, y^k)), \quad \bar{y}^{k} = \Pi_{\mathcal{Y}}(y^k + \eta \nabla_y f(x^k, y^k))$$

**Update step:**
$$x^{k+1} = \Pi_{\mathcal{X}}(x^k - \eta \nabla_x f(\bar{x}^k, \bar{y}^k)), \quad y^{k+1} = \Pi_{\mathcal{Y}}(y^k + \eta \nabla_y f(\bar{x}^k, \bar{y}^k))$$

**Notation:**
- $z = (x, y) \in \mathcal{Z} := \mathcal{X} \times \mathcal{Y}$
- $F(z) = (\nabla_x f(x,y), -\nabla_y f(x,y))$ is the "gradient operator"
- $\Pi_{\mathcal{Z}}$ is the Euclidean projection onto $\mathcal{Z}$
- $(x^*, y^*)$ is a saddle point: $f(x^*, y) \leq f(x^*, y^*) \leq f(x, y^*)$ for all $x \in \mathcal{X}, y \in \mathcal{Y}$

**Theorem.** With step size $\eta = \frac{1}{2L}$, define the averaged iterates:
$$\hat{x}^K = \frac{1}{K}\sum_{k=0}^{K-1}\bar{x}^k, \quad \hat{y}^K = \frac{1}{K}\sum_{k=0}^{K-1}\bar{y}^k.$$

Then the duality gap satisfies:
$$\mathrm{Gap}(\hat{x}^K, \hat{y}^K) := \max_{y \in \mathcal{Y}} f(\hat{x}^K, y) - \min_{x \in \mathcal{X}} f(x, \hat{y}^K) \leq \frac{2L \cdot D^2}{K}$$

where $D^2 = \|x^0 - x^*\|^2 + \|y^0 - y^*\|^2$.

## Required intermediate results

1. **Monotone operator formulation**: Show $F$ is monotone ($\langle F(z) - F(z'), z - z'\rangle \geq 0$) and $L$-Lipschitz.

2. **One-step distance decrease**: Prove
   $$\|z^{k+1} - z^*\|^2 \leq \|z^k - z^*\|^2 - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2 + 2\eta\langle F(\bar{z}^k), z^* - \bar{z}^k\rangle$$

3. **Monotonicity gives sign**: Since $F$ is monotone and $z^*$ is a saddle point (so $\langle F(z^*), z - z^*\rangle \geq 0$ for all $z \in \mathcal{Z}$), bound $\langle F(\bar{z}^k), z^* - \bar{z}^k\rangle \leq 0$, yielding $\|z^{k+1} - z^*\|^2 \leq \|z^k - z^*\|^2$.

4. **Duality gap bound per step**: For any $u = (x_u, y_u) \in \mathcal{Z}$, show
   $$2\eta[f(\bar{x}^k, y_u) - f(x_u, \bar{y}^k)] \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 + \eta^2 L^2 \|\bar{z}^k - z^k\|^2 - \|\bar{z}^k - z^k\|^2$$

5. **Telescoping and averaging**: Sum over $k$, use convexity/concavity for Jensen on the averaged iterates, optimize over $u$ to extract the duality gap.

## Difficulty
research
