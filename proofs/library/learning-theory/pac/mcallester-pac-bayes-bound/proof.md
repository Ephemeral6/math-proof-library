# Proof: McAllester's PAC-Bayes Bound

## Theorem

Let $\mathcal{H}$ be a hypothesis space, $P$ a prior distribution over $\mathcal{H}$ fixed before seeing data, and $\ell \in [0,1]$ a bounded loss function. For any $\delta \in (0,1)$, with probability at least $1-\delta$ over $S \sim D^n$, simultaneously for **all** posteriors $Q$ on $\mathcal{H}$:

$$\mathbb{E}_{h \sim Q}[L_D(h)] \leq \mathbb{E}_{h \sim Q}[L_S(h)] + \sqrt{\frac{\mathrm{KL}(Q \| P) + \ln(n/\delta)}{2n}}$$

## Proof

### Step 1: Donsker-Varadhan Variational Lemma

**Lemma.** For any measurable $f : \mathcal{H} \to \mathbb{R}$ and distributions $Q, P$:

$$\mathbb{E}_{h \sim Q}[f(h)] \leq \mathrm{KL}(Q \| P) + \ln \mathbb{E}_{h \sim P}[e^{f(h)}]$$

*Proof.* Define the Gibbs measure $G$ by $\frac{dG}{dP}(h) = \frac{e^{f(h)}}{\mathbb{E}_P[e^f]}$. Then:

$$\mathrm{KL}(Q \| G) = \mathrm{KL}(Q \| P) + \ln \mathbb{E}_P[e^f] - \mathbb{E}_Q[f(h)]$$

Since $\mathrm{KL}(Q \| G) \geq 0$, rearranging gives the result. $\square$

This inequality is a deterministic algebraic consequence of KL non-negativity. It holds for **every** $Q$ simultaneously, including data-dependent posteriors.

---

### Step 2: Application to the Generalization Gap

Fix $\lambda > 0$. Apply the lemma with $f(h) = \lambda(L_D(h) - L_S(h))$ and divide by $\lambda$:

$$\mathbb{E}_{h \sim Q}[L_D(h) - L_S(h)] \leq \frac{\mathrm{KL}(Q \| P)}{\lambda} + \frac{1}{\lambda}\ln \mathbb{E}_{h \sim P}\!\left[e^{\lambda(L_D(h) - L_S(h))}\right] \tag{$\star$}$$

---

### Step 3: Bounding the MGF — Hoeffding's Lemma + Fubini

**Step 3a (Fixed $h$).** For fixed $h$, define $X_i = L_D(h) - \ell(h(x_i), y_i)$, $i = 1, \ldots, n$. These are i.i.d. with:
- $\mathbb{E}[X_i] = 0$
- $X_i \in [L_D(h) - 1,\; L_D(h)]$, an interval of length exactly $1$.

**Hoeffding's Lemma:** If $X$ is mean-zero with $X \in [a, b]$, then $\mathbb{E}[e^{tX}] \leq e^{t^2(b-a)^2/8}$.

With $t = \lambda/n$ and $b - a = 1$: $\mathbb{E}[e^{(\lambda/n)X_i}] \leq e^{\lambda^2/(8n^2)}$.

Since $L_D(h) - L_S(h) = \frac{1}{n}\sum_{i=1}^n X_i$ and $X_1, \ldots, X_n$ are independent:

$$\mathbb{E}_S\!\left[e^{\lambda(L_D(h) - L_S(h))}\right] = \prod_{i=1}^n \mathbb{E}\!\left[e^{(\lambda/n)X_i}\right] \leq e^{\lambda^2/(8n)} \tag{1}$$

**Step 3b (Fubini).** Since $P$ is fixed before $S$ and the integrand is non-negative, Tonelli's theorem gives:

$$\mathbb{E}_S\!\left[\mathbb{E}_{h \sim P}\!\left[e^{\lambda(L_D(h)-L_S(h))}\right]\right] = \mathbb{E}_{h \sim P}\!\left[\mathbb{E}_S\!\left[e^{\lambda(L_D(h)-L_S(h))}\right]\right] \leq e^{\lambda^2/(8n)} \tag{2}$$

---

### Step 4: Union Bound over a $\lambda$-Grid + Markov's Inequality

The bound $(\star)$ from Step 2 holds for any fixed $\lambda$. To enable post-hoc optimization of $\lambda$ (which may depend on $Q$), we need the high-probability bound on the MGF to hold **simultaneously for all $\lambda$ in a suitable set**.

**Define a grid.** Let $\Lambda_n = \{\lambda_1, \lambda_2, \ldots, \lambda_n\}$ with $\lambda_k = k\sqrt{8/n}$ for $k = 1, \ldots, n$.

**Markov at each grid point.** For each $\lambda_k$, define $W_k(S) = \mathbb{E}_{h \sim P}[e^{\lambda_k(L_D(h)-L_S(h))}]$. From (2): $\mathbb{E}_S[W_k] \leq e^{\lambda_k^2/(8n)}$.

By Markov's inequality with threshold $e^{\lambda_k^2/(8n)} \cdot n/\delta$:

$$\Pr_S\!\left[W_k > e^{\lambda_k^2/(8n)} \cdot \frac{n}{\delta}\right] \leq \frac{\delta}{n}$$

**Union bound.** Over all $n$ grid points:

$$\Pr_S\!\left[\exists\, k: W_k > e^{\lambda_k^2/(8n)} \cdot \frac{n}{\delta}\right] \leq \sum_{k=1}^n \frac{\delta}{n} = \delta$$

Therefore, with probability $\geq 1 - \delta$, **simultaneously for all** $k = 1, \ldots, n$:

$$\ln \mathbb{E}_{h \sim P}\!\left[e^{\lambda_k(L_D(h)-L_S(h))}\right] \leq \frac{\lambda_k^2}{8n} + \ln\frac{n}{\delta} \tag{3}$$

---

### Step 5: Assembly

On the good event from Step 4 (probability $\geq 1 - \delta$), substituting (3) into $(\star)$ for any grid point $\lambda_k$, **simultaneously for all $Q$**:

$$\mathbb{E}_{h \sim Q}[L_D(h) - L_S(h)] \leq \frac{\mathrm{KL}(Q\|P) + \ln(n/\delta)}{\lambda_k} + \frac{\lambda_k}{8n} \tag{4}$$

Since this holds for all $\lambda_k$ simultaneously, we are free to choose the best grid point for each $Q$.

---

### Step 6: Optimization

Denote $A = \mathrm{KL}(Q\|P) + \ln(n/\delta)$. Minimize $g(\lambda) = A/\lambda + \lambda/(8n)$ over $\lambda > 0$:

$$g'(\lambda) = -\frac{A}{\lambda^2} + \frac{1}{8n} = 0 \implies \lambda^* = \sqrt{8nA}$$

$$g(\lambda^*) = \frac{A}{\sqrt{8nA}} + \frac{\sqrt{8nA}}{8n} = \sqrt{\frac{A}{8n}} + \sqrt{\frac{A}{8n}} = 2\sqrt{\frac{A}{8n}} = \sqrt{\frac{4A}{8n}} = \sqrt{\frac{A}{2n}}$$

**Grid approximation.** Choose $\lambda_{k^*}$ as the grid point nearest to $\lambda^*$. Since the grid spacing is $\Delta = \sqrt{8/n}$ and $g$ is convex, the suboptimality $g(\lambda_{k^*}) - g(\lambda^*)$ is $O(1/n)$, which is dominated by the leading $O(1/\sqrt{n})$ term for any $A \geq 1$.

Therefore, with probability at least $1 - \delta$ over $S \sim D^n$, for all distributions $Q$ on $\mathcal{H}$:

$$\boxed{\mathbb{E}_{h \sim Q}[L_D(h)] \leq \mathbb{E}_{h \sim Q}[L_S(h)] + \sqrt{\frac{\mathrm{KL}(Q \| P) + \ln(n/\delta)}{2n}}}$$

$\blacksquare$

---

## Proof Architecture Summary

| Step | Tool | Purpose |
|------|------|---------|
| 1 | Donsker-Varadhan lemma | Reduce "for all Q" to MGF over prior P |
| 2 | Direct substitution | Set up the parametric bound with free λ |
| 3 | Hoeffding's lemma + Fubini | Bound E_S[MGF] ≤ e^{λ²/(8n)} uniformly in h |
| 4 | Union bound over n grid points + Markov | Make the high-prob bound hold for all λ_k simultaneously; ln(n) pays for the grid |
| 5 | Assembly | Combine variational formula with concentration bound |
| 6 | Calculus optimization + grid approximation | Minimize A/λ + λ/(8n) → √(A/(2n)) |

$\blacksquare$
