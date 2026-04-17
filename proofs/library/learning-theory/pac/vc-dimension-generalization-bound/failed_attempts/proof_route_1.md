# Route 1: Symmetrization + Growth Function + Chernoff

## Setup and Notation

Let $\mathcal{H}$ be a hypothesis class with VC dimension $d < \infty$. Let $S = (z_1, \ldots, z_n)$ be $n$ i.i.d. samples from distribution $\mathcal{D}$ over $\mathcal{Z}$. For $h \in \mathcal{H}$, define:
- True risk: $R(h) = \mathbb{E}_{z \sim \mathcal{D}}[\ell(h, z)]$
- Empirical risk: $\hat{R}_S(h) = \frac{1}{n}\sum_{i=1}^n \ell(h, z_i)$

We assume the loss is bounded: $\ell(h, z) \in [0, 1]$ for all $h, z$.

We aim to show:
$$\Pr\left[\sup_{h \in \mathcal{H}} |R(h) - \hat{R}_S(h)| > \epsilon\right] \leq C \cdot \left(\frac{en}{d}\right)^d \cdot e^{-n\epsilon^2/8}$$

from which the stated bound follows by inverting.

---

## Step 1: Symmetrization Lemma

**Lemma 1 (Symmetrization).** Let $S' = (z_1', \ldots, z_n')$ be an independent ghost sample from $\mathcal{D}$. For $n \geq 2/\epsilon^2$:

$$\Pr_S\left[\sup_{h \in \mathcal{H}} |R(h) - \hat{R}_S(h)| > \epsilon\right] \leq 2 \Pr_{S, S'}\left[\sup_{h \in \mathcal{H}} |\hat{R}_S(h) - \hat{R}_{S'}(h)| > \frac{\epsilon}{2}\right]$$

**Proof of Lemma 1.** Fix any $h^* \in \mathcal{H}$ such that $|R(h^*) - \hat{R}_S(h^*)| > \epsilon$. We show that with probability at least $1/2$ over $S'$, we also have $|\hat{R}_S(h^*) - \hat{R}_{S'}(h^*)| > \epsilon/2$.

Since $\mathbb{E}_{S'}[\hat{R}_{S'}(h^*)] = R(h^*)$, by Chebyshev's inequality:
$$\Pr_{S'}\left[|\hat{R}_{S'}(h^*) - R(h^*)| > \frac{\epsilon}{2}\right] \leq \frac{\text{Var}(\hat{R}_{S'}(h^*))}{\epsilon^2/4} \leq \frac{1/(4n)}{\epsilon^2/4} = \frac{1}{n\epsilon^2}$$

where we used $\text{Var}(\hat{R}_{S'}(h^*)) \leq 1/(4n)$ since losses are in $[0,1]$.

For $n \geq 2/\epsilon^2$, this probability is at most $1/2$. So with probability $\geq 1/2$ over $S'$:
$$|\hat{R}_{S'}(h^*) - R(h^*)| \leq \frac{\epsilon}{2}$$

By triangle inequality, on this event:
$$|\hat{R}_S(h^*) - \hat{R}_{S'}(h^*)| \geq |R(h^*) - \hat{R}_S(h^*)| - |\hat{R}_{S'}(h^*) - R(h^*)| > \epsilon - \frac{\epsilon}{2} = \frac{\epsilon}{2}$$

Since $\sup_h |\hat{R}_S(h) - \hat{R}_{S'}(h)| \geq |\hat{R}_S(h^*) - \hat{R}_{S'}(h^*)|$, we get:

$$\Pr_S\left[\sup_h |R(h) - \hat{R}_S(h)| > \epsilon\right] \leq 2\Pr_{S,S'}\left[\sup_h |\hat{R}_S(h) - \hat{R}_{S'}(h)| > \frac{\epsilon}{2}\right]$$

$\blacksquare$

---

## Step 2: Rademacher Symmetrization

**Lemma 2 (Rademacher Symmetrization).** Let $\sigma_1, \ldots, \sigma_n$ be i.i.d. Rademacher random variables ($\pm 1$ with equal probability). Then:

$$\Pr_{S,S'}\left[\sup_h |\hat{R}_S(h) - \hat{R}_{S'}(h)| > \frac{\epsilon}{2}\right] \leq 2\Pr_{S,\sigma}\left[\sup_h \left|\frac{1}{n}\sum_{i=1}^n \sigma_i \ell(h, z_i)\right| > \frac{\epsilon}{4}\right]$$

**Proof of Lemma 2.** Write:
$$\hat{R}_S(h) - \hat{R}_{S'}(h) = \frac{1}{n}\sum_{i=1}^n [\ell(h, z_i) - \ell(h, z_i')]$$

Conditional on the multiset $\{(z_i, z_i')\}_{i=1}^n$, the pairs $(z_i, z_i')$ are exchangeable. For each $i$, swapping $z_i \leftrightarrow z_i'$ changes the sign of $\ell(h, z_i) - \ell(h, z_i')$. Therefore:

$$\frac{1}{n}\sum_{i=1}^n [\ell(h, z_i) - \ell(h, z_i')] \stackrel{d}{=} \frac{1}{n}\sum_{i=1}^n \sigma_i [\ell(h, z_i) - \ell(h, z_i')]$$

Taking supremum over $h$ on both sides:

$$\Pr_{S,S'}\left[\sup_h |\hat{R}_S(h) - \hat{R}_{S'}(h)| > \frac{\epsilon}{2}\right] = \Pr_{S,S',\sigma}\left[\sup_h \left|\frac{1}{n}\sum_{i=1}^n \sigma_i[\ell(h,z_i) - \ell(h,z_i')]\right| > \frac{\epsilon}{2}\right]$$

By the triangle inequality on the supremum:
$$\sup_h \left|\frac{1}{n}\sum_{i=1}^n \sigma_i[\ell(h,z_i) - \ell(h,z_i')]\right| \leq \sup_h \left|\frac{1}{n}\sum_{i=1}^n \sigma_i \ell(h,z_i)\right| + \sup_h \left|\frac{1}{n}\sum_{i=1}^n \sigma_i \ell(h,z_i')\right|$$

By a union bound and the fact that $S$ and $S'$ are identically distributed:
$$\Pr\left[\sup_h |\hat{R}_S - \hat{R}_{S'}| > \frac{\epsilon}{2}\right] \leq 2\Pr_{S,\sigma}\left[\sup_h \left|\frac{1}{n}\sum_{i=1}^n \sigma_i \ell(h,z_i)\right| > \frac{\epsilon}{4}\right]$$

$\blacksquare$

---

## Step 3: Reduction via Growth Function and Sauer-Shelah

**Key observation.** Conditional on the sample $S = (z_1, \ldots, z_n)$, the function $h \mapsto (\ell(h, z_1), \ldots, \ell(h, z_n))$ takes at most $\Pi_{\mathcal{H}}(n)$ distinct values, where $\Pi_{\mathcal{H}}(n)$ is the growth function of $\mathcal{H}$.

More precisely, for binary classification with 0-1 loss, the vector $(\ell(h, z_1), \ldots, \ell(h, z_n)) \in \{0,1\}^n$ is determined by the classification pattern $(h(x_1), \ldots, h(x_n))$, and the number of distinct classification patterns on $n$ points is exactly $\Pi_{\mathcal{H}}(n)$.

**Sauer-Shelah Lemma.** If $\text{VCdim}(\mathcal{H}) = d$ and $n \geq d$, then:
$$\Pi_{\mathcal{H}}(n) \leq \sum_{i=0}^d \binom{n}{i} \leq \left(\frac{en}{d}\right)^d$$

(We take this as established; it is proved elsewhere in this library.)

Therefore, we can replace the supremum over the infinite class $\mathcal{H}$ with a maximum over at most $(en/d)^d$ distinct functions:

$$\Pr_{S,\sigma}\left[\sup_h \left|\frac{1}{n}\sum_{i=1}^n \sigma_i \ell(h,z_i)\right| > \frac{\epsilon}{4}\right] = \Pr_{\sigma}\left[\max_{j=1,\ldots,\Pi_{\mathcal{H}}(n)} \left|\frac{1}{n}\sum_{i=1}^n \sigma_i v_i^{(j)}\right| > \frac{\epsilon}{4}\right]$$

where $v^{(1)}, \ldots, v^{(\Pi_{\mathcal{H}}(n))}$ are the distinct loss vectors in $\{0,1\}^n$.

---

## Step 4: Hoeffding + Union Bound

For each fixed $j$, $\frac{1}{n}\sum_{i=1}^n \sigma_i v_i^{(j)}$ is a sum of independent bounded random variables (each $\sigma_i v_i^{(j)} \in [-1, 1]$). By Hoeffding's inequality:

$$\Pr_\sigma\left[\left|\frac{1}{n}\sum_{i=1}^n \sigma_i v_i^{(j)}\right| > t\right] \leq 2\exp\left(-\frac{n t^2}{2}\right)$$

By union bound over at most $\Pi_{\mathcal{H}}(n) \leq (en/d)^d$ vectors:

$$\Pr_\sigma\left[\max_j \left|\frac{1}{n}\sum_{i=1}^n \sigma_i v_i^{(j)}\right| > \frac{\epsilon}{4}\right] \leq 2\left(\frac{en}{d}\right)^d \exp\left(-\frac{n\epsilon^2}{32}\right)$$

---

## Step 5: Combining Everything

Combining Steps 1-4:

$$\Pr\left[\sup_h |R(h) - \hat{R}_S(h)| > \epsilon\right] \leq 2 \cdot 2 \cdot 2 \cdot \left(\frac{en}{d}\right)^d \exp\left(-\frac{n\epsilon^2}{32}\right) = 8\left(\frac{en}{d}\right)^d \exp\left(-\frac{n\epsilon^2}{32}\right)$$

Set this equal to $\delta$:
$$8\left(\frac{en}{d}\right)^d \exp\left(-\frac{n\epsilon^2}{32}\right) = \delta$$

Solving for $\epsilon$:
$$\frac{n\epsilon^2}{32} = d\log\frac{en}{d} + \log\frac{8}{\delta}$$

$$\epsilon^2 = \frac{32d\log(en/d) + 32\log(8/\delta)}{n}$$

$$\epsilon = O\left(\sqrt{\frac{d\log(n/d) + \log(1/\delta)}{n}}\right)$$

where we absorbed constant factors. Note $\log(en/d) = 1 + \log(n/d) = \Theta(\log(n/d))$ for $n/d \geq e$, and $\log(8/\delta) = \log 8 + \log(1/\delta) = O(\log(1/\delta))$ for $\delta < 1$.

---

## Conclusion

With probability at least $1 - \delta$ over the draw of $n$ i.i.d. samples:

$$\sup_{h \in \mathcal{H}} |R(h) - \hat{R}_S(h)| \leq O\left(\sqrt{\frac{d\log(n/d) + \log(1/\delta)}{n}}\right)$$

$\blacksquare$

---

## Conditions and Remarks

- **Requirement:** $n \geq 2/\epsilon^2$ for the symmetrization step, which is satisfied when $\epsilon$ is not too large (certainly when $\epsilon < 1$ and $n \geq 2$).
- **Loss boundedness:** We assumed $\ell \in [0,1]$. For 0-1 loss in classification, this holds automatically.
- **The $\log(n/d)$ term:** This is not an artifact; it appears naturally from the Sauer-Shelah bound. However, it can be removed using more sophisticated chaining arguments (yielding the tighter $\sqrt{d/n}$ rate), though this is not needed for the stated result.
