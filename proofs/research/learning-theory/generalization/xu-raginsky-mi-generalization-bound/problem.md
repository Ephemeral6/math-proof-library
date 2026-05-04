# Information-Theoretic Generalization Bound via Mutual Information (Xu-Raginsky 2017)

## Source
- Paper: Xu & Raginsky, "Information-theoretic analysis of generalization capability of learning algorithms", NeurIPS 2017.
- Follow-ups: Bu-Zou-Veeravalli 2020 (individual-sample MI refinement); Negrea et al. 2019; Steinke-Zakynthinou 2020 (conditional MI).

## Statement

**Setup.** Let $Z$ be a data space with distribution $\mathcal{D}$. A learning algorithm $A$ is a (possibly randomized) map $Z^n \to \mathcal{W}$ (hypothesis space). Write $W := A(S)$ for the random output given input sample $S = (Z_1, \dots, Z_n) \stackrel{\text{iid}}{\sim} \mathcal{D}^n$.

Let $\ell: \mathcal{W} \times Z \to \mathbb{R}$ be a loss function. Define
$$R_\mathcal{D}(w) := \mathbb{E}_{z \sim \mathcal{D}}[\ell(w, z)], \qquad R_S(w) := \frac{1}{n} \sum_{i=1}^n \ell(w, Z_i).$$

**Sub-Gaussian assumption (A1).** Under the product measure $W \otimes Z \sim \mathbb{P}_W \times \mathcal{D}$ (i.e., $W$ and $Z$ drawn independently from the marginals of the joint $(W, Z_i)$), the random variable $\ell(W, Z)$ is $\sigma$-sub-Gaussian:
$$\mathbb{E}\!\left[\exp\!\big(\lambda(\ell(W, Z) - \mathbb{E}[\ell(W, Z)])\big)\right] \;\le\; \exp\!\big(\lambda^2 \sigma^2 / 2\big), \quad \forall \lambda \in \mathbb{R}.$$

**Claim.** The expected generalization gap satisfies
$$\big|\,\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]\,\big| \;\le\; \sqrt{\frac{2 \sigma^2 \cdot I(W; S)}{n}},$$
where $I(W; S) := D_{\mathrm{KL}}(\mathbb{P}_{W, S} \,\|\, \mathbb{P}_W \otimes \mathbb{P}_S)$ is the Shannon mutual information between the algorithm output and the input sample.

## Difficulty

**research** — the proof combines:
1. A change-of-measure lemma via Donsker-Varadhan variational representation of KL divergence.
2. A sub-Gaussian transport bound: for any two distributions $P \ll Q$ on a space where a random variable $f$ is $\sigma$-sub-Gaussian under $Q$,
 $$\big|\mathbb{E}_P[f] - \mathbb{E}_Q[f]\big| \le \sqrt{2 \sigma^2 \cdot D_{\mathrm{KL}}(P \| Q)}.$$
3. A reduction from the generalization gap to per-sample KL via iid structure: $I(W; S) = \sum_{i=1}^n I(W; Z_i \mid Z_{1:i-1})$ (chain rule) and convexity.

The full argument requires careful handling of the difference between "algorithm output distribution" and "data distribution", which is the exact gap measured by mutual information.

## Key intermediate results to prove

1. **Donsker-Varadhan variational formula.** For any two probability measures $P$, $Q$ on the same space with $P \ll Q$:
 $$D_{\mathrm{KL}}(P \| Q) \;=\; \sup_{f: \mathbb{E}_Q[e^f] < \infty} \big\{ \mathbb{E}_P[f] - \log \mathbb{E}_Q[e^f] \big\}.$$

2. **Sub-Gaussian transport lemma.** If $f$ is $\sigma$-sub-Gaussian under $Q$ (i.e., $\log \mathbb{E}_Q[e^{\lambda(f - \mathbb{E}_Q[f])}] \le \lambda^2 \sigma^2/2$ for all $\lambda$), then for any $P \ll Q$:
 $$\big|\mathbb{E}_P[f] - \mathbb{E}_Q[f]\big| \;\le\; \sqrt{2 \sigma^2 \cdot D_{\mathrm{KL}}(P \| Q)}.$$
 (Apply Donsker-Varadhan to $\pm \lambda f$ and optimize in $\lambda$.)

3. **Decomposition of the generalization gap.** Using iid structure of $S$:
 $$\mathbb{E}[R_\mathcal{D}(W) - R_S(W)] \;=\; \frac{1}{n} \sum_{i=1}^n \big(\mathbb{E}_{W, Z_i'}[\ell(W, Z_i')] - \mathbb{E}_{W, Z_i}[\ell(W, Z_i)]\big),$$
 where $Z_i' \sim \mathcal{D}$ is an independent copy (so $(W, Z_i')$ has distribution $\mathbb{P}_W \otimes \mathcal{D}$, independent product).

4. **Per-sample KL bound via sub-Gaussian transport.** Apply Lemma 2 with $P = \mathbb{P}_{W, Z_i}$ and $Q = \mathbb{P}_W \otimes \mathcal{D}$, $f = \ell$:
 $$\big|\mathbb{E}_{W, Z_i}[\ell(W, Z_i)] - \mathbb{E}_{W, Z_i'}[\ell(W, Z_i')]\big| \;\le\; \sqrt{2 \sigma^2 \cdot I(W; Z_i)}.$$

5. **Assembly via Jensen / Cauchy-Schwarz.** Combine:
 $$\big|\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]\big| \;\le\; \frac{1}{n} \sum_i \sqrt{2 \sigma^2 \cdot I(W; Z_i)} \;\le\; \sqrt{\frac{2 \sigma^2}{n} \sum_i I(W; Z_i)} \;\le\; \sqrt{\frac{2 \sigma^2 I(W; S)}{n}}$$
 where the last inequality uses $\sum_i I(W; Z_i) \le I(W; S)$ from the iid assumption (via chain rule and $I(W; Z_i | Z_{1:i-1}) \ge I(W; Z_i)$ — note direction of inequality requires care).

   **Caveat:** The inequality $\sum_i I(W; Z_i) \le I(W; S)$ in general requires a proof via chain rule + conditional independence of $Z_i$'s. Provide this carefully.

## Notation summary

- All expectations are over the joint distribution $\mathbb{P}_{W, S}$ unless otherwise noted.
- $D_{\mathrm{KL}}(P \| Q) = \int \log(dP/dQ) \, dP$.
- $I(X; Y) = D_{\mathrm{KL}}(\mathbb{P}_{X, Y} \| \mathbb{P}_X \otimes \mathbb{P}_Y)$.
- Sub-Gaussianity: $\log \mathbb{E}[e^{\lambda(X - \mathbb{E}[X])}] \le \lambda^2 \sigma^2/2$ for all $\lambda \in \mathbb{R}$.
- Bounded losses in $[0, L]$ are $\sigma$-sub-Gaussian with $\sigma = L/2$ (Hoeffding's lemma).
