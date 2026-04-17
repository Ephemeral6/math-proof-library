# Proof: Online-to-Batch Conversion

## Theorem

Let an online learning algorithm produce hypotheses $h_1, \ldots, h_T$ achieving worst-case regret
$$\text{Reg}_T = \sum_{t=1}^T \ell(h_t, z_t) - \min_{h \in \mathcal{H}} \sum_{t=1}^T \ell(h, z_t) \leq R(T)$$
for every sequence $z_1, \ldots, z_T$. When run on i.i.d. data $z_1, \ldots, z_T \sim \mathcal{D}^T$, the randomized predictor $\bar{h}_T = \text{Uniform}(h_1, \ldots, h_T)$ satisfies
$$\mathbb{E}[R(\bar{h}_T)] - R(h^*) \leq \frac{R(T)}{T},$$
where $R(h) = \mathbb{E}_{z \sim \mathcal{D}}[\ell(h, z)]$ and $h^* = \arg\min_{h \in \mathcal{H}} R(h)$.

Moreover, if $\ell(\cdot, z)$ is convex for all $z$ and $\mathcal{H}$ is convex, then the deterministic averaged hypothesis $\hat{h}_T = \frac{1}{T}\sum_{t=1}^T h_t$ also satisfies the same bound.

## Proof

### Part A: General case (randomized predictor)

**Step 1 (Sequential independence).** In the online protocol, the algorithm selects $h_t$ as a deterministic function of $(z_1, \ldots, z_{t-1})$ before observing $z_t$. When the data are i.i.d. with $z_t \sim \mathcal{D}$, the random variable $z_t$ is independent of $(z_1, \ldots, z_{t-1})$ and hence independent of $h_t$. By the tower property of conditional expectation:

$$\mathbb{E}[\ell(h_t, z_t)] = \mathbb{E}\big[\mathbb{E}[\ell(h_t, z_t) \mid z_1, \ldots, z_{t-1}]\big] = \mathbb{E}\big[R(h_t)\big], \tag{1}$$

since conditionally on $(z_1, \ldots, z_{t-1})$, the hypothesis $h_t$ is fixed and $z_t \sim \mathcal{D}$ is a fresh independent draw.

**Step 2 (Applying the regret bound).** The worst-case regret guarantee ensures that for *every* realization of the data:

$$\sum_{t=1}^T \ell(h_t, z_t) - \min_{h \in \mathcal{H}} \sum_{t=1}^T \ell(h, z_t) \leq R(T).$$

Since this holds almost surely, taking expectations and applying (1):

$$\sum_{t=1}^T \mathbb{E}[R(h_t)] - \mathbb{E}\left[\min_{h \in \mathcal{H}} \sum_{t=1}^T \ell(h, z_t)\right] \leq R(T). \tag{2}$$

**Step 3 (Bounding the comparator).** For the fixed hypothesis $h^* \in \mathcal{H}$:

$$\min_{h \in \mathcal{H}} \sum_{t=1}^T \ell(h, z_t) \leq \sum_{t=1}^T \ell(h^*, z_t).$$

Taking expectations and using that $h^*$ is non-random and $z_t \overset{\text{i.i.d.}}{\sim} \mathcal{D}$:

$$\mathbb{E}\left[\min_{h \in \mathcal{H}} \sum_{t=1}^T \ell(h, z_t)\right] \leq T \cdot R(h^*). \tag{3}$$

From (2): $\sum_t \mathbb{E}[R(h_t)] \leq R(T) + \mathbb{E}[\min_h \sum_t \ell(h, z_t)] \leq R(T) + T \cdot R(h^*)$, hence:

$$\sum_{t=1}^T \mathbb{E}[R(h_t)] - T \cdot R(h^*) \leq R(T). \tag{4}$$

**Step 4 (Randomized predictor).** The randomized predictor $\bar{h}_T$ draws an index $I \sim \text{Uniform}\{1, \ldots, T\}$ independently of everything else, and uses $h_I$. Its population risk is:

$$R(\bar{h}_T) = \mathbb{E}_I[R(h_I)] = \frac{1}{T}\sum_{t=1}^T R(h_t). \tag{5}$$

This is an identity — it follows from the definition of a randomized predictor and linearity of expectation.

**Step 5 (Conclusion).** Dividing (4) by $T$ and applying (5):

$$\mathbb{E}[R(\bar{h}_T)] - R(h^*) = \frac{1}{T}\sum_{t=1}^T \mathbb{E}[R(h_t)] - R(h^*) \leq \frac{R(T)}{T}. \quad \blacksquare$$

### Part B: Convex refinement

**Assume additionally** that $h \mapsto \ell(h, z)$ is convex for every $z$ and that $\mathcal{H}$ is a convex subset of a vector space.

Define the deterministic averaged hypothesis $\hat{h}_T = \frac{1}{T}\sum_{t=1}^T h_t$. By convexity of $\mathcal{H}$, $\hat{h}_T \in \mathcal{H}$.

By Jensen's inequality applied to the convex function $h \mapsto \ell(h, z)$:

$$\ell\left(\frac{1}{T}\sum_{t=1}^T h_t, z\right) \leq \frac{1}{T}\sum_{t=1}^T \ell(h_t, z) \quad \text{for all } z. \tag{6}$$

Taking $\mathbb{E}_{z \sim \mathcal{D}}$ on both sides:

$$R(\hat{h}_T) \leq \frac{1}{T}\sum_{t=1}^T R(h_t). \tag{7}$$

Taking expectation over the training data and using (4):

$$\mathbb{E}[R(\hat{h}_T)] \leq \frac{1}{T}\sum_{t=1}^T \mathbb{E}[R(h_t)] \leq R(h^*) + \frac{R(T)}{T}. \quad \blacksquare$$

### Remarks

1. **No convexity needed for Part A.** The "uniform average" is a randomized predictor — we average risks (scalars), not hypotheses (vectors). No structural assumption on $\mathcal{H}$ or $\ell$ is required.

2. **Tightness.** For OGD on convex Lipschitz functions with $R(T) = O(\sqrt{T})$, this gives $O(1/\sqrt{T})$ excess risk, matching the minimax lower bound for stochastic convex optimization.

3. **Interpretation.** This converts any worst-case online guarantee into a statistical learning guarantee, bridging adversarial and stochastic settings with no asymptotic loss.
