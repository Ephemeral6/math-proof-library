# Proof Route 2: McDiarmid's Inequality + DP Sensitivity

**Route**: McDiarmid-based approach

## Proof

**Setup.** Let $S = \{z_1, \ldots, z_n\} \sim \mathcal{D}^n$. Let $\mathcal{A}$ be $(\varepsilon, \delta)$-DP with $\varepsilon \leq 1$. Let $\ell: \mathcal{H} \times \mathcal{Z} \to [0,1]$.

**Step 1: Define the generalization gap as a function of S.**

For a fixed realization of $\mathcal{A}$'s internal randomness $\omega$, define:
$$G(S, \omega) = \mathbb{E}_{z \sim \mathcal{D}}[\ell(\mathcal{A}_\omega(S), z)] - \frac{1}{n}\sum_{i=1}^n \ell(\mathcal{A}_\omega(S), z_i)$$

We want to bound $|\mathbb{E}_{S, \omega}[G(S, \omega)]|$.

**Step 2: Attempt to apply McDiarmid's inequality.**

[REF: proofs/library/statistics/concentration/mcdiarmid-bounded-differences-inequality/proof.md]

McDiarmid's inequality requires: for each $i$, replacing $z_i$ with $z_i'$ changes $G$ by a bounded amount. However, $G$ depends on $S$ both through $\mathcal{A}_\omega(S)$ (the algorithm's output) and through the empirical sum $\frac{1}{n}\sum \ell(\cdot, z_i)$.

The empirical sum part: changing $z_i$ to $z_i'$ changes the sum by at most $|\ell(\mathcal{A}_\omega(S), z_i') - \ell(\mathcal{A}_\omega(S), z_i)|/n \leq 1/n$.

The algorithm output part: changing $z_i$ to $z_i'$ changes $\mathcal{A}_\omega(S)$ to $\mathcal{A}_\omega(S^{(i)})$. For a fixed $\omega$, this is a deterministic change, but the DP guarantee is about the distribution over $\omega$, not pointwise.

**Problem**: For a fixed $\omega$, the algorithm is deterministic, and replacing one sample could change the output arbitrarily. DP only guarantees statistical closeness across the randomness of $\omega$.

**Step 3: Condition on $\omega$ and use DP.**

Let's instead work with $\bar{G}(S) = \mathbb{E}_\omega[G(S, \omega)]$.

$$\bar{G}(S) = \mathbb{E}_\omega\left[\mathbb{E}_z[\ell(\mathcal{A}_\omega(S), z)] - \frac{1}{n}\sum_{i=1}^n \ell(\mathcal{A}_\omega(S), z_i)\right]$$

Now, $\bar{G}$ is a function of $S$ only. Let's check its bounded differences property.

Replace $z_i$ with $z_i'$:
$$\bar{G}(S) - \bar{G}(S^{(i)}) = \mathbb{E}_\omega\left[\mathbb{E}_z[\ell(\mathcal{A}(S), z) - \ell(\mathcal{A}(S^{(i)}), z)] + \frac{1}{n}\ell(\mathcal{A}(S^{(i)}), z_i') - \frac{1}{n}\ell(\mathcal{A}(S), z_i) + \frac{1}{n}\sum_{j \neq i}[\ell(\mathcal{A}(S^{(i)}), z_j) - \ell(\mathcal{A}(S), z_j)]\right]$$

This is messy. The DP-dependent terms satisfy:
$$|\mathbb{E}_\omega[\ell(\mathcal{A}(S), z) - \ell(\mathcal{A}(S^{(i)}), z)]| \leq (e^{\varepsilon} - 1) + \delta$$

for each fixed $z$ (from the layer cake argument in Route 1).

But the bounded-differences condition requires a **worst-case** (over $z_i, z_i'$) bound, not an average bound. Since DP is inherently an average (over $\omega$) guarantee, McDiarmid's inequality cannot be applied directly to get the in-expectation generalization bound we seek.

**Step 4: What McDiarmid gives.**

If we could establish bounded differences for $\bar{G}(S)$:
$$|\bar{G}(S) - \bar{G}(S^{(i)})| \leq c_i$$

then McDiarmid would give concentration of $\bar{G}(S)$ around $\mathbb{E}_S[\bar{G}(S)]$, which is useful for high-probability bounds but doesn't directly give us the expectation bound.

However, from the DP stability:
$$|\bar{G}(S) - \bar{G}(S^{(i)})| \leq \underbrace{|(e^{\varepsilon} - 1) + \delta|}_{\text{population risk diff}} + \underbrace{1/n}_{\text{empirical sum diff}} + \underbrace{(n-1)[(e^{\varepsilon} - 1) + \delta]/n}_{\text{other training losses}}$$

Wait, the last term is wrong because DP applies to the whole output, not term by term.

Actually:
$$\bar{G}(S) - \bar{G}(S^{(i)}) = \mathbb{E}_\omega\left[\underbrace{\mathbb{E}_z[\ell(\mathcal{A}(S), z)] - \mathbb{E}_z[\ell(\mathcal{A}(S^{(i)}), z)]}_{\leq (e^\varepsilon - 1) + \delta}\right] + \frac{1}{n}\mathbb{E}_\omega\left[\ell(\mathcal{A}(S^{(i)}), z_i') - \ell(\mathcal{A}(S^{(i)}), z_i) + \ell(\mathcal{A}(S), z_i) - \ell(\mathcal{A}(S), z_i')\right] + \text{cross terms}$$

This approach is not leading to a clean result.

## Route Failure Report
- **Route**: McDiarmid's Inequality + DP Sensitivity
- **Failed at**: Step 3-4
- **Obstacle**: McDiarmid's inequality requires **deterministic** bounded differences, but the DP guarantee is inherently **probabilistic** (averaged over the algorithm's randomness). For a fixed realization of the algorithm's randomness, replacing one sample can change the output arbitrarily. The approach could potentially work for high-probability generalization bounds (via a two-step argument: first use DP to show approximate bounded differences, then apply McDiarmid), but it does not lead to a clean expected generalization gap bound of $\varepsilon + \delta$. The direct stability approach (Route 1/3) is much more natural for this problem.
