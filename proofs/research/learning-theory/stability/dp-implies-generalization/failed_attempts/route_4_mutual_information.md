# Proof Route 4: Information-Theoretic Approach via Mutual Information

**Route**: DP → Bounded Mutual Information → Generalization

## Proof

**Setup.** Let $S = (z_1, \ldots, z_n) \sim \mathcal{D}^n$. Let $\mathcal{A}$ be $(\varepsilon, \delta)$-DP with $\varepsilon \leq 1$. Let $\ell: \mathcal{H} \times \mathcal{Z} \to [0,1]$.

**Step 1: DP implies bounded mutual information (per-sample).**

For each $i \in [n]$, define the *conditional mutual information*:
$$I_i = I(z_i; \mathcal{A}(S) | S_{-i})$$

where $S_{-i} = (z_1, \ldots, z_{i-1}, z_{i+1}, \ldots, z_n)$.

**Claim**: $I_i \leq \varepsilon^2/2 + \varepsilon\delta$ for $(\varepsilon, \delta)$-DP.

*Proof of Claim*: Fix $S_{-i}$. The conditional distribution of $\mathcal{A}(S)$ given $z_i = z$ is some $P_z$. For any two values $z, z'$, $(S_{-i}, z)$ and $(S_{-i}, z')$ are neighboring datasets, so by DP:

$$D_{KL}(P_z \| P_{z'}) \leq \varepsilon(e^{\varepsilon} - 1) + \delta \cdot \varepsilon / (1-\delta)$$

... actually, the standard bound is:

For $(\varepsilon, \delta)$-DP: $D_{KL}(P_z \| P_{z'}) \leq \varepsilon(e^{\varepsilon} - 1) + \delta \log(e^{\varepsilon}/\delta)$ when $\delta > 0$.

This is getting unwieldy. Let me use the simpler pure DP case first.

**For pure $\varepsilon$-DP** ($\delta = 0$): For all $z, z'$:
$$D_{KL}(P_z \| P_{z'}) \leq \varepsilon(e^{\varepsilon} - 1) \leq 2\varepsilon^2 \text{ for } \varepsilon \leq 1$$

Then: $I_i = \mathbb{E}_{z_i}[D_{KL}(P_{z_i} \| P_{\bar{z}})]$ where $P_{\bar{z}} = \mathbb{E}_{z_i}[P_{z_i}]$ is the mixture, and:
$$I_i \leq \mathbb{E}_{z_i, z_i'}[D_{KL}(P_{z_i} \| P_{z_i'})] \leq 2\varepsilon^2$$

**Step 2: Information-theoretic generalization bound.**

By the result of Xu and Raginsky (2017), for bounded loss $\ell \in [0,1]$:
$$|\Delta_{gen}| \leq \sqrt{\frac{2}{n}\sum_{i=1}^n I_i}$$

[This follows from the Donsker-Varadhan variational formula and sub-Gaussian properties of bounded random variables.]

[Related: REF: proofs/library/learning-theory/pac/mcallester-pac-bayes-bound/proof.md — uses Donsker-Varadhan]

For pure $\varepsilon$-DP: $I_i \leq 2\varepsilon^2$, so:
$$|\Delta_{gen}| \leq \sqrt{\frac{2 \cdot n \cdot 2\varepsilon^2}{n}} = 2\varepsilon$$

This gives $O(\varepsilon)$ but with a constant of 2 and using a different mechanism (square root of MI vs. direct).

**Step 3: Difficulty with $(\varepsilon, \delta)$-DP.**

For approximate DP with $\delta > 0$, the KL divergence bound is:
$$D_{KL}(\mu \| \nu) \leq \varepsilon(e^{\varepsilon} - 1) + (1 + e^{\varepsilon})\delta\log\left(\frac{1}{\delta}\right) + \delta$$

This depends on $\log(1/\delta)$, which means the mutual information bound also has $\log(1/\delta)$ dependence, yielding:
$$|\Delta_{gen}| \leq O\left(\varepsilon\sqrt{\log(1/\delta)/n} + \delta\log(1/\delta)/n\right)$$

... which is a different type of bound (depending on $n$) and does not directly give $\varepsilon + \delta$.

**Step 4: Comparison with target.**

The information-theoretic route gives:
- Pure DP: $|\Delta_{gen}| \leq 2\varepsilon$ (matches up to constant)
- Approximate DP: bound depends on $n$ and $\log(1/\delta)$, which is a different regime

This is a valid generalization bound but of a different nature than the stability-based $\varepsilon + \delta$ bound. The MI-based bound can be tighter when $n$ is large (since it scales as $1/\sqrt{n}$), but it doesn't directly yield the $n$-independent bound of $\varepsilon + \delta$.

## Route Partial Success Report
- **Route**: Information-Theoretic via Mutual Information
- **Result**: Partial success — obtains a valid generalization bound of $O(\varepsilon)$ for pure DP, but the bound has different structure ($\varepsilon$ vs $\varepsilon + \delta$) and the approximate DP case introduces $\log(1/\delta)$ factors
- **Obstacle**: The mutual information framework naturally gives $\sqrt{I/n}$-type bounds that scale with sample size, whereas the target bound $\varepsilon + \delta$ is sample-size independent
- **Conclusion**: This route proves DP implies generalization (which is the qualitative claim) but with different quantitative dependence. The stability-based Route 1/3 is the correct approach for the specific bound $\varepsilon + \delta$.

Q.E.D. (for the weaker bound $|\Delta_{gen}| \leq 2\varepsilon$ under pure DP)
