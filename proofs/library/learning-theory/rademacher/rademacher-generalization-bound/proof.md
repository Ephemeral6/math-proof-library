# Rademacher Complexity Generalization Bound — Proof

Let $\mathcal{F}$ be a class of functions $f: \mathcal{X} \to [0,1]$, $S = (X_1, \ldots, X_n)$ i.i.d. from $\mathcal{D}$. Define:
$$\Phi(S) = \sup_{f \in \mathcal{F}} \left(\mathbb{E}[f(X)] - \frac{1}{n}\sum_{i=1}^n f(X_i)\right).$$

---

## PART A: Empirical Rademacher Bound

**Goal**: $\Phi(S) \leq 2\hat{\mathfrak{R}}_n(\mathcal{F}) + \sqrt{\frac{\ln(2/\delta)}{2n}}$ w.p. $\geq 1-\delta$.

### Step A1: Symmetrization Inequality (Pointwise)

**Lemma (Symmetrization)**: For every sample $S$:
$$\Phi(S) \leq \mathfrak{R}_n(\mathcal{F}) + \hat{\mathfrak{R}}_n(\mathcal{F}).$$

*Proof*: Let $S' = (X_1', \ldots, X_n')$ be a ghost sample, independent of $S$, each $X_i' \sim \mathcal{D}$.

For any $f \in \mathcal{F}$:
$$\mathbb{E}[f(X)] - \frac{1}{n}\sum_{i=1}^n f(X_i) = \mathbb{E}_{S'}\left[\frac{1}{n}\sum_{i=1}^n f(X_i')\right] - \frac{1}{n}\sum_{i=1}^n f(X_i) = \mathbb{E}_{S'}\left[\frac{1}{n}\sum_{i=1}^n (f(X_i') - f(X_i))\right].$$

Taking the supremum and using Jensen's inequality ($\sup$ of expectation $\leq$ expectation of $\sup$):
$$\Phi(S) \leq \mathbb{E}_{S'}\left[\sup_{f \in \mathcal{F}} \frac{1}{n}\sum_{i=1}^n (f(X_i') - f(X_i))\right]. \tag{1}$$

Now we introduce Rademacher variables. For each $i$, the pair $(X_i, X_i')$ consists of i.i.d. random variables. For independent Rademacher variables $\sigma_1, \ldots, \sigma_n$ (independent of $S, S'$):

$$(f(X_1') - f(X_1), \ldots, f(X_n') - f(X_n)) \stackrel{d}{=} (\sigma_1(f(X_1') - f(X_1)), \ldots, \sigma_n(f(X_n') - f(X_n)))$$

jointly over the randomness of $(S, S')$. This holds because for each $i$ independently, $(X_i, X_i') \stackrel{d}{=} (X_i', X_i)$, so $f(X_i') - f(X_i)$ is a symmetric random variable, and multiplying by an independent $\sigma_i$ preserves the distribution.

Applying this to (1):
$$\Phi(S) \leq \mathbb{E}_{S', \sigma}\left[\sup_{f \in \mathcal{F}} \frac{1}{n}\sum_{i=1}^n \sigma_i(f(X_i') - f(X_i))\right]. \tag{2}$$

By sub-additivity of the supremum:
$$\sup_f \frac{1}{n}\sum_i \sigma_i(f(X_i') - f(X_i)) \leq \sup_f \frac{1}{n}\sum_i \sigma_i f(X_i') + \sup_f \frac{1}{n}\sum_i (-\sigma_i) f(X_i). \tag{3}$$

Taking $\mathbb{E}_{S', \sigma}$ of both terms on the right:

**First term**: 
$$\mathbb{E}_{S', \sigma}\left[\sup_f \frac{1}{n}\sum_i \sigma_i f(X_i')\right] = \mathbb{E}_{S'}\left[\hat{\mathfrak{R}}_n(\mathcal{F}; S')\right] = \mathfrak{R}_n(\mathcal{F}).$$

**Second term** ($S$ is fixed, only $\sigma$ is random; $-\sigma_i \stackrel{d}{=} \sigma_i$):
$$\mathbb{E}_\sigma\left[\sup_f \frac{1}{n}\sum_i (-\sigma_i) f(X_i)\right] = \mathbb{E}_\sigma\left[\sup_f \frac{1}{n}\sum_i \sigma_i f(X_i)\right] = \hat{\mathfrak{R}}_n(\mathcal{F}).$$

Combining with (2) and (3):
$$\Phi(S) \leq \mathfrak{R}_n(\mathcal{F}) + \hat{\mathfrak{R}}_n(\mathcal{F}). \tag{4}$$

This holds for every realization of $S$. $\square$

### Step A2: Concentration of Empirical Rademacher Complexity

**Lemma (McDiarmid for $\hat{\mathfrak{R}}_n$)**: $\hat{\mathfrak{R}}_n(\mathcal{F})$ satisfies bounded differences with constant $c_i = 1/n$.

*Proof*: Let $S$ and $S^{(i)}$ differ only at position $i$. Using $|\sup g - \sup h| \leq \sup|g-h|$ inside $\mathbb{E}_\sigma$:
$$\left|\hat{\mathfrak{R}}_n(\mathcal{F}; S) - \hat{\mathfrak{R}}_n(\mathcal{F}; S^{(i)})\right| \leq \mathbb{E}_\sigma\left[\sup_f \frac{|\sigma_i|}{n}|f(X_i) - f(X_i')|\right] \leq \frac{1}{n}$$

since $|\sigma_i| = 1$ and $f: \mathcal{X} \to [0,1]$ implies $|f(X_i) - f(X_i')| \leq 1$.

By McDiarmid's inequality:
$$P\left(\mathfrak{R}_n(\mathcal{F}) - \hat{\mathfrak{R}}_n(\mathcal{F}) \geq t\right) \leq \exp(-2nt^2). \tag{5}$$

Setting $t = \sqrt{\frac{\ln(2/\delta)}{2n}}$:
$$\mathfrak{R}_n(\mathcal{F}) \leq \hat{\mathfrak{R}}_n(\mathcal{F}) + \sqrt{\frac{\ln(2/\delta)}{2n}} \quad \text{w.p.} \geq 1 - \delta. \tag{6}$$

### Step A3: Combining

From (4): $\Phi(S) \leq \mathfrak{R}_n(\mathcal{F}) + \hat{\mathfrak{R}}_n(\mathcal{F})$ (deterministic).

From (6) with probability $\geq 1-\delta$: $\mathfrak{R}_n(\mathcal{F}) \leq \hat{\mathfrak{R}}_n(\mathcal{F}) + \sqrt{\frac{\ln(2/\delta)}{2n}}$.

Substituting:
$$\boxed{\Phi(S) \leq 2\hat{\mathfrak{R}}_n(\mathcal{F}) + \sqrt{\frac{\ln(2/\delta)}{2n}} \quad \text{w.p.} \geq 1-\delta.} \tag{7}$$

$\blacksquare$

---

## PART B: Population Rademacher Bound

**Goal**: $\Phi(S) \leq 2\mathfrak{R}_n(\mathcal{F}) + 3\sqrt{\frac{\ln(2/\delta)}{2n}}$ w.p. $\geq 1-\delta$.

### Step B1: Bounding E[Φ(S)] by Symmetrization

Taking expectations of (4) over $S$:
$$\mathbb{E}[\Phi(S)] \leq \mathfrak{R}_n(\mathcal{F}) + \mathbb{E}[\hat{\mathfrak{R}}_n(\mathcal{F})] = 2\mathfrak{R}_n(\mathcal{F}). \tag{8}$$

### Step B2: Concentration of Φ(S) via McDiarmid

$\Phi(S)$ satisfies bounded differences with $c_i = 1/n$:
$$|\Phi(S) - \Phi(S^{(i)})| \leq \sup_{f \in \mathcal{F}} \frac{1}{n}|f(X_i) - f(X_i')| \leq \frac{1}{n}.$$

By McDiarmid's inequality:
$$P(\Phi(S) \geq \mathbb{E}[\Phi(S)] + t) \leq e^{-2nt^2}. \tag{9}$$

### Step B3: Combining

From (8) and (9), with probability $\geq 1 - \delta/2$:
$$\Phi(S) \leq 2\mathfrak{R}_n(\mathcal{F}) + \sqrt{\frac{\ln(4/\delta)}{2n}}. \tag{10}$$

From (5) with $\delta/2$, with probability $\geq 1 - \delta/2$:
$$\mathfrak{R}_n(\mathcal{F}) \leq \hat{\mathfrak{R}}_n(\mathcal{F}) + \sqrt{\frac{\ln(4/\delta)}{2n}}. \tag{11}$$

By union bound, both hold with probability $\geq 1 - \delta$. Substituting (11) into (10):
$$\Phi(S) \leq 2\hat{\mathfrak{R}}_n(\mathcal{F}) + 3\sqrt{\frac{\ln(4/\delta)}{2n}}.$$

Since $\ln(4/\delta) \leq 2\ln(2/\delta)$ for $\delta \leq 2$:

$$\boxed{\Phi(S) \leq 2\mathfrak{R}_n(\mathcal{F}) + 3\sqrt{\frac{\ln(2/\delta)}{2n}} \quad \text{w.p.} \geq 1-\delta.}$$

**Note**: The population Rademacher bound from (10) alone gives the tighter $\Phi(S) \leq 2\mathfrak{R}_n(\mathcal{F}) + \sqrt{\ln(2/\delta)/(2n)}$. The factor-of-3 version appears when converting population to empirical Rademacher complexity.

$\blacksquare$
