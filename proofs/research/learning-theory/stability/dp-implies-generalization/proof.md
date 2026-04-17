# Proof: Differential Privacy Implies Generalization

**Route**: DP → Uniform Stability → Generalization via Hockey-Stick Divergence

---

## Setup

Let $S = (z_1, \ldots, z_n)$ be $n$ i.i.d. samples from $\mathcal{D}$ over $\mathcal{Z}$. Let $\mathcal{A}: \mathcal{Z}^n \to \mathcal{H}$ be $(\varepsilon, \delta)$-DP with $\varepsilon \leq 1$, and $\ell: \mathcal{H} \times \mathcal{Z} \to [0,1]$.

## Step 1: Key Lemma — DP post-processing for expectations

**Lemma 1.** Let $\mu, \nu$ be probability measures with $\mu(E) \leq e^{\varepsilon}\nu(E) + \delta$ for all measurable $E$. Then for any $f: \mathcal{H} \to [0,1]$:
$$\mathbb{E}_\mu[f] - \mathbb{E}_\nu[f] \leq (e^{\varepsilon} - 1) + \delta$$

*Proof.* Define the hockey-stick decomposition:
$$d\mu_1 = \min(d\mu, \, e^{\varepsilon} d\nu), \qquad d\mu_2 = (d\mu - e^{\varepsilon} d\nu)_+$$

Then $\mu = \mu_1 + \mu_2$, with $d\mu_1 \leq e^{\varepsilon} d\nu$ pointwise, and:
$$\mu_2(\mathcal{H}) = \int (d\mu - e^{\varepsilon} d\nu)_+ = \sup_E[\mu(E) - e^{\varepsilon}\nu(E)] \leq \delta$$

Therefore:
$$\mathbb{E}_\mu[f] = \int f \, d\mu_1 + \int f \, d\mu_2 \leq e^{\varepsilon}\mathbb{E}_\nu[f] + \delta$$

Subtracting $\mathbb{E}_\nu[f]$ and using $\mathbb{E}_\nu[f] \leq 1$:
$$\mathbb{E}_\mu[f] - \mathbb{E}_\nu[f] \leq (e^{\varepsilon} - 1)\mathbb{E}_\nu[f] + \delta \leq (e^{\varepsilon} - 1) + \delta \qquad \square$$

**Corollary** (symmetric). Since DP holds in both directions: $|\mathbb{E}_\mu[f] - \mathbb{E}_\nu[f]| \leq (e^{\varepsilon} - 1) + \delta$.

## Step 2: Stability implies generalization

[REF: proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/proof.md — Bousquet-Elisseeff leave-one-out symmetrization]

**Step 2a.** For each $i$, let $z_i' \sim \mathcal{D}$ be independent, $S^{(i)} = (z_1, \ldots, z_{i-1}, z_i', z_{i+1}, \ldots, z_n)$.

Since $z_i'$ is independent of $S$: $\mathbb{E}_{z \sim \mathcal{D}}[\ell(\mathcal{A}(S), z)] = \mathbb{E}_{z_i'}[\ell(\mathcal{A}(S), z_i')]$.

$$\Delta_{\mathrm{gen}} = \left|\frac{1}{n}\sum_{i=1}^n \mathbb{E}\left[\ell(\mathcal{A}(S), z_i') - \ell(\mathcal{A}(S), z_i)\right]\right| \qquad (1)$$

**Step 2b.** By exchangeability of $(z_i, z_i')$: the joint law of $(S, z_i')$ equals that of $(S^{(i)}, z_i)$.

$$\mathbb{E}[\ell(\mathcal{A}(S), z_i')] = \mathbb{E}[\ell(\mathcal{A}(S^{(i)}), z_i)] \qquad (2)$$

Substituting into (1):
$$\Delta_{\mathrm{gen}} = \left|\frac{1}{n}\sum_{i=1}^n \mathbb{E}\left[\ell(\mathcal{A}(S^{(i)}), z_i) - \ell(\mathcal{A}(S), z_i)\right]\right| \qquad (3)$$

**Step 2c.** For each $i$, $S$ and $S^{(i)}$ are neighboring. Apply the Corollary of Lemma 1 with $\mu = \mathrm{Law}(\mathcal{A}(S^{(i)}) \mid S_{-i}, z_i, z_i')$, $\nu = \mathrm{Law}(\mathcal{A}(S) \mid S_{-i}, z_i, z_i')$, $f = \ell(\cdot, z_i)$:

$$\left|\mathbb{E}_{\mathcal{A}}\left[\ell(\mathcal{A}(S^{(i)}), z_i) - \ell(\mathcal{A}(S), z_i) \mid S_{-i}, z_i, z_i'\right]\right| \leq (e^{\varepsilon} - 1) + \delta$$

Taking full expectations and applying triangle inequality to (3):
$$\Delta_{\mathrm{gen}} \leq \frac{1}{n}\sum_{i=1}^n \left[(e^{\varepsilon} - 1) + \delta\right] = (e^{\varepsilon} - 1) + \delta$$

## Result

$$\boxed{\left|\mathbb{E}_S\left[\frac{1}{n}\sum_{i=1}^n \ell(\mathcal{A}(S), z_i) - \mathbb{E}_{z \sim \mathcal{D}}[\ell(\mathcal{A}(S), z)]\right]\right| \leq (e^{\varepsilon} - 1) + \delta \leq 2\varepsilon + \delta}$$

for $\varepsilon \leq 1$.

**Q.E.D.**
