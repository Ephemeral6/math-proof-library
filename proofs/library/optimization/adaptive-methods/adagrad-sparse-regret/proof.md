# AdaGrad Regret Bound for Sparse Gradients

**Theorem.** Consider online convex optimization on $\mathcal{X} \subseteq \mathbb{R}^d$ with $\ell_\infty$-diameter $D$. AdaGrad with step size parameter $\eta = D/\sqrt{2}$ and coordinate-wise update $x_{t+1,i} = \Pi_{\mathcal{X},i}(x_{t,i} - \eta g_{t,i}/\sqrt{\sum_{s=1}^t g_{s,i}^2})$ achieves:

$$\text{Regret}_T \leq D\sqrt{2} \sum_{i=1}^d \sqrt{\sum_{t=1}^T g_{t,i}^2}$$

> **Remark.** The exact constant 1 (i.e., $D\sum_i \sqrt{\sum_t g_{t,i}^2}$) is achieved by the FTRL/dual-averaging formulation (Duchi et al. 2011, Theorem 5). The OGD analysis inherently yields constant $\sqrt{2}$ due to the AM-GM split. The asymptotic rate is identical.

---

## Proof

**Step 1: Convexity decomposition.**

By the subgradient inequality: $f_t(x_t) - f_t(x^*) \leq \langle g_t, x_t - x^*\rangle = \sum_{i=1}^d g_{t,i}(x_{t,i} - x_i^*)$.

It suffices to bound $\sum_{t=1}^T g_{t,i}(x_{t,i} - x_i^*)$ for each coordinate $i$.

**Step 2: Per-coordinate OGD bound.**

Fix coordinate $i$. Define $S_{t,i} = \sum_{s=1}^t g_{s,i}^2$ and step size $\eta_{t,i} = \eta/\sqrt{S_{t,i}}$. By projection non-expansiveness:

$$g_{t,i}(x_{t,i} - x_i^*) \leq \frac{(x_{t,i}-x_i^*)^2 - (x_{t+1,i}-x_i^*)^2}{2\eta_{t,i}} + \frac{\eta_{t,i}}{2}g_{t,i}^2 \quad (\star)$$

**Step 3: Bound the distance term via Abel summation.**

Let $\beta_t = (x_{t,i} - x_i^*)^2$ and $c_t = 1/(2\eta_{t,i}) = \sqrt{S_{t,i}}/(2\eta)$ (non-decreasing). By summation by parts:

$$\sum_{t=1}^T c_t(\beta_t - \beta_{t+1}) = c_1\beta_1 + \sum_{t=2}^T \beta_t(c_t - c_{t-1}) - c_T\beta_{T+1}$$

Using $\beta_t \leq D^2$ and dropping $-c_T\beta_{T+1} \leq 0$:

$$\leq D^2 c_T = \frac{D^2\sqrt{S_{T,i}}}{2\eta}$$

**Step 4: Key Lemma.**

**Lemma.** $\displaystyle\sum_{t=1}^T \frac{a_t}{\sqrt{\sum_{s=1}^t a_s}} \leq 2\sqrt{\sum_{t=1}^T a_t}$ for non-negative $a_t$.

*Proof.* Let $S_t = \sum_{s=1}^t a_s$. Then $\frac{S_t - S_{t-1}}{\sqrt{S_t}} \leq 2(\sqrt{S_t} - \sqrt{S_{t-1}})$ since $\sqrt{S_t} + \sqrt{S_{t-1}} \leq 2\sqrt{S_t}$. Telescoping gives $2\sqrt{S_T}$. $\square$

Applied: $\sum_t \frac{\eta_{t,i}}{2}g_{t,i}^2 = \frac{\eta}{2}\sum_t g_{t,i}^2/\sqrt{S_{t,i}} \leq \eta\sqrt{S_{T,i}}$.

**Step 5: Combine and optimize.**

$$\sum_{t=1}^T g_{t,i}(x_{t,i} - x_i^*) \leq \left(\frac{D^2}{2\eta} + \eta\right)\sqrt{S_{T,i}}$$

Optimize: $\eta^* = D/\sqrt{2}$, giving coefficient $D\sqrt{2}$.

**Step 6: Aggregate.**

$$\boxed{\text{Regret}_T \leq D\sqrt{2}\sum_{i=1}^d \sqrt{\sum_{t=1}^T g_{t,i}^2}}$$

---

## Corollary 1: Worst-case $O(DGd\sqrt{T})$

Cauchy-Schwarz: $\sum_i \sqrt{S_{T,i}} \leq \sqrt{d\sum_i S_{T,i}}$. Under $\|g_t\|_\infty \leq G$: $\sum_i S_{T,i} \leq dTG^2$, so $\text{Regret}_T = O(DGd\sqrt{T})$.

## Corollary 2: Sparse $O(DGs\sqrt{T})$

$s$-sparse gradients → at most $s$ active coordinates → $\text{Regret}_T \leq D\sqrt{2}\cdot sG\sqrt{T} = O(DGs\sqrt{T})$.

**Q.E.D.**
