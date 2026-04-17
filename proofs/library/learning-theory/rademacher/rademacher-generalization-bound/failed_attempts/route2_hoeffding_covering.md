# Proof Route 2: Symmetrization + Hoeffding (Direct Concentration)

**Route**: Hoeffding-based approach with covering numbers

## Proof

Let $\mathcal{F}$ be a class of functions $f: \mathcal{X} \to [0,1]$, $S = (X_1, \ldots, X_n)$ i.i.d. from $\mathcal{D}$.

### Step 1: Finite Function Class Case

First assume $|\mathcal{F}| < \infty$. For a single $f$, by Hoeffding's inequality (since $f(X_i) \in [0,1]$):

$$P\left(\mathbb{E}[f(X)] - \frac{1}{n}\sum_{i=1}^n f(X_i) \geq t\right) \leq \exp(-2nt^2).$$

By union bound over $\mathcal{F}$:
$$P\left(\sup_{f \in \mathcal{F}}\left(\mathbb{E}[f] - \hat{\mathbb{E}}_n[f]\right) \geq t\right) \leq |\mathcal{F}| \cdot \exp(-2nt^2).$$

Setting $|\mathcal{F}|e^{-2nt^2} = \delta$: $t = \sqrt{\frac{\ln(|\mathcal{F}|/\delta)}{2n}}$.

This gives a $\sqrt{\ln|\mathcal{F}|/n}$ rate for finite classes.

### Step 2: Connecting to Rademacher Complexity for Finite Classes

For a finite class, the Rademacher complexity satisfies:
$$\mathfrak{R}_n(\mathcal{F}) \leq \sqrt{\frac{2\ln|\mathcal{F}|}{n}}$$

(by Massart's lemma). So the Hoeffding bound gives a rate of $O(\mathfrak{R}_n(\mathcal{F}))$, consistent with the theorem.

### Step 3: Extending to Infinite Classes via Covering

For infinite $\mathcal{F}$, let $\mathcal{N}_\epsilon$ be an $\epsilon$-cover of $\mathcal{F}$ with respect to the $L_\infty(S)$ norm (i.e., for each $f \in \mathcal{F}$, there exists $\tilde{f} \in \mathcal{N}_\epsilon$ with $\max_i |f(X_i) - \tilde{f}(X_i)| \leq \epsilon$).

For any $f \in \mathcal{F}$ with approximation $\tilde{f} \in \mathcal{N}_\epsilon$:
$$(\mathbb{E}[f] - \hat{\mathbb{E}}_n[f]) \leq (\mathbb{E}[\tilde{f}] - \hat{\mathbb{E}}_n[\tilde{f}]) + |\mathbb{E}[f - \tilde{f}]| + |\hat{\mathbb{E}}_n[f - \tilde{f}]|.$$

The last term is $\leq \epsilon$ by the covering property. The second term requires bounding $|\mathbb{E}[f-\tilde{f}]|$, which involves the population $L_1$ distance — this is harder to control from the empirical covering.

### Obstacle
This route requires controlling covering numbers and produces bounds in terms of covering numbers (metric entropy), not directly in terms of Rademacher complexity. The connection between covering numbers and Rademacher complexity (Dudley's entropy integral) adds an extra layer. This route is **less direct** than the symmetrization approach and does not naturally give the sharp constants in the theorem.

## Route Failure Report
- Route: Symmetrization + Hoeffding
- Failed at: Step 3 — connecting covering-number bounds to the sharp Rademacher bound
- Obstacle: The covering number approach gives bounds involving $\sqrt{\ln N(\epsilon, \mathcal{F})/n}$ integrated over $\epsilon$ (Dudley's integral), which is an upper bound on the Rademacher complexity but typically looser. It does not directly yield the statement with $2\hat{\mathfrak{R}}_n(\mathcal{F})$ as the leading term. The classical symmetrization route is the natural and standard proof for this theorem.
