# Proof: VC Dimension Generalization Bound

## Setup and Notation

Let $\mathcal{H}$ be a hypothesis class with VC dimension $d$. Consider binary classification with 0-1 loss: $\ell(h, z) = \mathbf{1}[h(x) \neq y] \in \{0, 1\}$. Let $S = (z_1, \ldots, z_n)$ be $n$ i.i.d. samples from distribution $\mathcal{D}$.

Define:
- $R(h) = \Pr_{z \sim \mathcal{D}}[h(x) \neq y]$ (true risk)
- $\hat{R}_S(h) = \frac{1}{n}\sum_{i=1}^n \mathbf{1}[h(x_i) \neq y_i]$ (empirical risk)

**Theorem.** With probability $\geq 1 - \delta$:
$$\sup_{h \in \mathcal{H}} |R(h) - \hat{R}_S(h)| \leq O\left(\sqrt{\frac{d\log(n/d) + \log(1/\delta)}{n}}\right)$$

**Proof.** We establish the tail bound
$$\Pr\left[\sup_{h \in \mathcal{H}} |R(h) - \hat{R}_S(h)| > \epsilon\right] \leq 8\left(\frac{2en}{d}\right)^d \exp\left(-\frac{n\epsilon^2}{8}\right)$$
and then invert.

---

## Step 1: Symmetrization via Double Sampling

Let $S' = (z_1', \ldots, z_n')$ be an independent copy of $S$.

**Lemma (Symmetrization).** For $n\epsilon^2 \geq 2$:
$$\Pr_S\left[\sup_h (R(h) - \hat{R}_S(h)) > \epsilon\right] \leq 2\Pr_{S,S'}\left[\sup_h (\hat{R}_S(h) - \hat{R}_{S'}(h)) > \frac{\epsilon}{2}\right]$$

*Proof.* Fix any $h^*$ with $R(h^*) - \hat{R}_S(h^*) > \epsilon$, i.e., $\hat{R}_S(h^*) < R(h^*) - \epsilon$. Since $\mathbb{E}_{S'}[\hat{R}_{S'}(h^*)] = R(h^*)$ and $\text{Var}(\hat{R}_{S'}(h^*)) \leq 1/(4n)$, Chebyshev gives:
$$\Pr_{S'}\left[|\hat{R}_{S'}(h^*) - R(h^*)| > \frac{\epsilon}{2}\right] \leq \frac{1}{n\epsilon^2} \leq \frac{1}{2}$$

So with probability $\geq 1/2$ over $S'$, we have $\hat{R}_{S'}(h^*) \geq R(h^*) - \epsilon/2$. On this event:
$$\hat{R}_{S'}(h^*) - \hat{R}_S(h^*) > (R(h^*) - \epsilon/2) - (R(h^*) - \epsilon) = \epsilon/2$$

Hence $\sup_h |\hat{R}_S(h) - \hat{R}_{S'}(h)| > \epsilon/2$ with conditional probability $\geq 1/2$, giving:
$$\Pr[\text{bad}] \leq 2\Pr[\sup_h |\hat{R}_S - \hat{R}_{S'}| > \epsilon/2] \qquad \blacksquare$$

For the two-sided bound ($\sup_h |R - \hat{R}| > \epsilon$), we apply the one-sided lemma to both directions and take a union bound:
$$\Pr\left[\sup_h |R(h) - \hat{R}_S(h)| > \epsilon\right] \leq 4\Pr_{S,S'}\left[\sup_h |\hat{R}_S(h) - \hat{R}_{S'}(h)| > \frac{\epsilon}{2}\right]$$

---

## Step 2: Conditioning on Pooled Sample

Let $T = S \cup S'$ be the pooled multiset of $2n$ points. Conditional on $T$, the split $(S, S')$ is a uniformly random partition of $T$ into two halves of size $n$.

On $T$, $\mathcal{H}$ induces at most $\Pi_{\mathcal{H}}(2n)$ distinct error patterns. By the **Sauer-Shelah Lemma**:
$$\Pi_{\mathcal{H}}(2n) \leq \left(\frac{2en}{d}\right)^d$$

For each pattern $h_j$, let $a_j = \sum_{i=1}^{2n} \mathbf{1}[h_j \text{ errs on } t_i]$ be the total errors on $T$.

---

## Step 3: Hypergeometric Concentration

Under the random partition, $n\hat{R}_S(h_j) \sim \text{Hypergeometric}(2n, a_j, n)$.

Since $n\hat{R}_S(h_j) + n\hat{R}_{S'}(h_j) = a_j$:
$$\hat{R}_S(h_j) - \hat{R}_{S'}(h_j) = 2\left(\hat{R}_S(h_j) - \frac{a_j}{2n}\right)$$

By **Hoeffding's inequality for sampling without replacement** (applied to $\hat{R}_S(h_j)$ as an average of $n$ values drawn without replacement from $\{0,1\}^{2n}$ with mean $a_j/(2n)$):

$$\Pr\left[|\hat{R}_S(h_j) - \hat{R}_{S'}(h_j)| > t\right] = \Pr\left[\left|\hat{R}_S(h_j) - \frac{a_j}{2n}\right| > \frac{t}{2}\right] \leq 2\exp\left(-\frac{nt^2}{2}\right)$$

---

## Step 4: Union Bound

By a union bound over $\leq (2en/d)^d$ distinct patterns:

$$\Pr_{S|T}\left[\sup_h |\hat{R}_S(h) - \hat{R}_{S'}(h)| > t\right] \leq 2\left(\frac{2en}{d}\right)^d \exp\left(-\frac{nt^2}{2}\right)$$

Since this holds for every realization of $T$, it holds unconditionally.

---

## Step 5: Assembly

Combining Steps 1 and 4 with $t = \epsilon/2$:

$$\Pr\left[\sup_h |R(h) - \hat{R}_S(h)| > \epsilon\right] \leq 4 \cdot 2\left(\frac{2en}{d}\right)^d \exp\left(-\frac{n\epsilon^2}{8}\right) = 8\left(\frac{2en}{d}\right)^d \exp\left(-\frac{n\epsilon^2}{8}\right)$$

Setting the right-hand side equal to $\delta$ and solving:

$$\frac{n\epsilon^2}{8} = d\log\frac{2en}{d} + \log\frac{8}{\delta}$$

$$\epsilon = \sqrt{\frac{8d\log(2en/d) + 8\log(8/\delta)}{n}}$$

Since $\log(2en/d) = O(\log(n/d))$ for $n \geq d$ and $\log(8/\delta) = O(\log(1/\delta))$:

$$\epsilon = O\left(\sqrt{\frac{d\log(n/d) + \log(1/\delta)}{n}}\right)$$

$\blacksquare$
