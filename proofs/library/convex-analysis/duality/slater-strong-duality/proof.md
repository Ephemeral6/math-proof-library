# Strong Duality via Slater's Condition — Proof

## Setup

Consider the convex optimization problem:
$$p^* = \inf_{x \in \mathcal{D}} \{f_0(x) : f_i(x) \leq 0,\; i=1,\ldots,m, \quad Ax = b\}$$

where $f_0,\ldots,f_m$ are convex, $\mathcal{D} = \bigcap_{i=0}^m \text{dom}(f_i)$ is nonempty, and $p^* > -\infty$.

**Slater's condition**: $\exists \hat{x} \in \text{relint}(\mathcal{D})$ with $f_i(\hat{x}) < 0$ for $i = 1,\ldots,m$ and $A\hat{x} = b$.

## Step 1: Define the Perturbation Function and Its Epigraph

Define $\phi : \mathbb{R}^m \times \mathbb{R}^p \to \mathbb{R} \cup \{+\infty\}$:
$$\phi(u,v) = \inf\{f_0(x) : x \in \mathcal{D},\; f_i(x) \leq u_i \; \forall i,\; Ax - b = v\}$$

with $\phi(u,v) = +\infty$ if the infimum is over the empty set.

**Properties**:
- $\phi(0,0) = p^*$
- $\phi$ is convex: If $(u^1,v^1)$ and $(u^2,v^2)$ are in dom$(\phi)$ with approximate minimizers $x^1, x^2 \in \mathcal{D}$ (satisfying $f_0(x^k) \leq \phi(u^k, v^k) + \epsilon$), then $x^\theta = \theta x^1 + (1-\theta)x^2 \in \mathcal{D}$ is feasible for $(\theta u^1 + (1-\theta)u^2, \theta v^1 + (1-\theta)v^2)$ by convexity of $f_i$ and linearity of $A$, with $f_0(x^\theta) \leq \theta f_0(x^1) + (1-\theta)f_0(x^2)$. Sending $\epsilon \to 0$ gives convexity of $\phi$.

Let $\text{epi}(\phi) = \{(u,v,t) : \phi(u,v) \leq t\} \subset \mathbb{R}^{m+p+1}$, which is convex.

## Step 2: Slater's Condition Gives Relative Interior Access

The Slater point $\hat{x}$ with $f_i(\hat{x}) < 0$ and $A\hat{x} = b$ certifies that $(\hat{u}, 0) \in \text{dom}(\phi)$ where $\hat{u}_i = f_i(\hat{x}) < 0$.

**Claim**: $(0,0) \in \text{ri}(\text{dom}(\phi))$.

*For the $u$-directions*: Since $\hat{u} < 0$ and $(\hat{u}, 0) \in \text{dom}(\phi)$, and also $(-\hat{u}, 0) \in \text{dom}(\phi)$ (because $-\hat{u} > 0$ relaxes all constraints, so any original feasible point remains feasible), the point $(0,0)$ lies in the relative interior of dom$(\phi)$ along each $u_i$-direction: dom$(\phi)$ contains points with both $u_i < 0$ (via the Slater point) and $u_i > 0$ (via constraint relaxation).

*For the $v$-directions*: Since $\hat{x} \in \text{relint}(\mathcal{D})$ and convex functions are continuous on the relative interior of their domain, there exists $\epsilon > 0$ such that for any direction $d$ in the linear part of $\text{aff}(\mathcal{D})$ and $|\delta| < \epsilon$, $\hat{x} + \delta d \in \mathcal{D}$ with $f_i(\hat{x} + \delta d) < 0$ still holding. Then $A(\hat{x} + \delta d) - b = \delta Ad$, showing $v = \delta Ad$ is achievable. This confirms $(0,0) \in \text{ri}(\text{dom}(\phi))$ within the affine hull of dom$(\phi)$.

## Step 3: Supporting Hyperplane at $(0,0,p^*)$

The point $(0,0,p^*)$ lies on the boundary of $\text{epi}(\phi)$: for all $\epsilon > 0$, $(0,0,p^*+\epsilon) \in \text{epi}(\phi)$ since $\phi(0,0) = p^* \leq p^*+\epsilon$, but $(0,0,p^*-\epsilon) \notin \text{epi}(\phi)$ since $\phi(0,0) = p^* > p^*-\epsilon$.

(If $p^*$ is not attained, $(0,0,p^*)$ lies on the boundary of $\text{cl}(\text{epi}(\phi))$, and the supporting hyperplane theorem applies to the closure; the resulting inequality still holds for all points in $\text{epi}(\phi)$.)

By the supporting hyperplane theorem, there exists a nonzero $(\alpha, \beta, \gamma) \in \mathbb{R}^m \times \mathbb{R}^p \times \mathbb{R}$ such that:

$$\alpha^T u + \beta^T v + \gamma t \leq \gamma p^* \quad \forall (u,v,t) \in \text{epi}(\phi) \qquad (\star)$$

## Step 4: Show $\gamma < 0$

Since $(u,v,t) \in \text{epi}(\phi)$ allows $t$ arbitrarily large (for any fixed $(u,v) \in \text{dom}(\phi)$), $(\star)$ requires $\gamma \leq 0$.

Suppose $\gamma = 0$. Then $\alpha^T u + \beta^T v \leq 0$ for all $(u,v) \in \text{dom}(\phi)$. Since $(0,0) \in \text{ri}(\text{dom}(\phi))$, for any direction $(d_u, d_v)$ within $\text{aff}(\text{dom}(\phi))$, there exists $\epsilon > 0$ with $\pm\epsilon(d_u, d_v) \in \text{dom}(\phi)$. Then:
$$\alpha^T(\epsilon d_u) + \beta^T(\epsilon d_v) \leq 0 \quad \text{and} \quad \alpha^T(-\epsilon d_u) + \beta^T(-\epsilon d_v) \leq 0$$
which forces $\alpha^T d_u + \beta^T d_v = 0$ for all directions in $\text{aff}(\text{dom}(\phi))$. Since $(0,0) \in \text{dom}(\phi)$, this means $(\alpha, \beta)$ vanishes on the linear span of $\text{dom}(\phi)$, hence $(\alpha,\beta)$ is zero on $\text{aff}(\text{dom}(\phi))$. Combined with $\gamma = 0$, this contradicts $(\alpha, \beta, \gamma) \neq 0$ being an effective separating normal for $\text{epi}(\phi)$ (whose affine hull includes the $t$-direction).

Therefore $\gamma < 0$. Normalize by setting $\gamma = -1$. $\square$

## Step 5: Extract Affine Lower Bound

With $\gamma = -1$, $(\star)$ becomes:
$$\alpha^T u + \beta^T v - t \leq -p^*$$

Setting $t = \phi(u,v)$:
$$\phi(u,v) \geq \alpha^T u + \beta^T v + p^* \qquad (\star\star)$$

## Step 6: Show $\alpha \leq 0$

For any index $i$ and any $\delta > 0$: $\phi(\delta e_i, 0) \leq p^*$ (relaxing the $i$-th constraint from $f_i(x) \leq 0$ to $f_i(x) \leq \delta$ can only decrease or maintain the optimal value, since the feasible set grows).

From $(\star\star)$: $p^* \geq \phi(\delta e_i, 0) \geq \alpha_i \delta + p^*$, giving $\alpha_i \delta \leq 0$. Since $\delta > 0$: $\alpha_i \leq 0$. $\square$

## Step 7: Define Dual Variables

Set:
$$\lambda^* = -\alpha \geq 0, \qquad \nu^* = -\beta$$

Then $(\star\star)$ reads:
$$\phi(u,v) \geq -\lambda^{*T} u - \nu^{*T} v + p^* \qquad (\dagger)$$

## Step 8: Show $g(\lambda^*, \nu^*) \geq p^*$

The Lagrangian dual function is:
$$g(\lambda, \nu) = \inf_{x \in \mathcal{D}} \left[f_0(x) + \sum_{i=1}^m \lambda_i f_i(x) + \nu^T(Ax - b)\right]$$

For any $x \in \mathcal{D}$, let $u_i = f_i(x)$, $v = Ax - b$. Then $\phi(u,v) \leq f_0(x)$ (since $x$ is feasible for the perturbed problem $(u,v)$ and achieves value $f_0(x)$).

$$f_0(x) + \lambda^{*T} f(x) + \nu^{*T}(Ax - b) = f_0(x) + \lambda^{*T} u + \nu^{*T} v$$
$$\geq \phi(u,v) + \lambda^{*T} u + \nu^{*T} v$$
$$\geq \left(-\lambda^{*T} u - \nu^{*T} v + p^*\right) + \lambda^{*T} u + \nu^{*T} v \quad \text{(by } (\dagger)\text{)}$$
$$= p^*$$

Since this holds for every $x \in \mathcal{D}$:
$$g(\lambda^*, \nu^*) = \inf_{x \in \mathcal{D}} L(x, \lambda^*, \nu^*) \geq p^*$$

## Step 9: Conclude via Weak Duality

**Weak duality**: For any $\lambda \geq 0$, $\nu$, and any primal feasible $x$ (with $f_i(x) \leq 0$, $Ax = b$):
$$g(\lambda, \nu) \leq L(x,\lambda,\nu) = f_0(x) + \underbrace{\lambda^T f(x)}_{\leq 0 \text{ (since } \lambda \geq 0, f(x) \leq 0)} + \underbrace{\nu^T(Ax-b)}_{= 0} \leq f_0(x)$$

So $g(\lambda,\nu) \leq p^*$ for all dual feasible $(\lambda, \nu)$.

**Combining**: $p^* \leq g(\lambda^*, \nu^*) \leq p^*$, hence $g(\lambda^*, \nu^*) = p^*$.

Therefore:
1. **Strong duality**: $d^* \geq g(\lambda^*, \nu^*) = p^* \geq d^*$, so $\boxed{d^* = p^*}$.
2. **Dual attainment**: $(\lambda^*, \nu^*)$ achieves the dual supremum $d^*$.

$\blacksquare$ **Q.E.D.**
