# OGD Regret Theorem — Final Proof

## Theorem Statement

**Setting.** Online Convex Optimization (OCO) over a convex compact set $K \subseteq \mathbb{R}^d$ with diameter $D = \max_{x,y \in K} \|x - y\|_2$. An adversary selects convex loss functions $f_t : K \to \mathbb{R}$ with $\|\nabla f_t(x)\|_2 \le G$ for all $x \in K$. The Online Gradient Descent (OGD) algorithm plays:

$$x_{t+1} = \Pi_K(x_t - \eta_t \nabla f_t(x_t))$$

where $\Pi_K$ denotes Euclidean projection onto $K$.

**Regret** is defined as $R_T = \sum_{t=1}^T f_t(x_t) - \min_{x \in K} \sum_{t=1}^T f_t(x)$.

**Claims:**

**(i)** Fixed step size $\eta = \frac{D}{G\sqrt{T}}$ yields $R_T \le DG\sqrt{T}$.

**(ii)** Decreasing step size $\eta_t = \frac{D}{G\sqrt{t}}$ yields $R_T \le \frac{3}{2} DG\sqrt{T}$.

**(iii)** Lower bound: There exists an adversary such that for any (possibly randomized) algorithm, $\mathbb{E}[R_T] \ge \frac{DG\sqrt{T}}{2\sqrt{2}}$.

---

## Preliminary Lemma: Projection Non-Expansiveness

**Lemma 1.** For any convex closed set $K \subseteq \mathbb{R}^d$ and any $y \in \mathbb{R}^d$, $x^* \in K$:
$$\|\Pi_K(y) - x^*\|_2 \le \|y - x^*\|_2.$$

*Proof.* Let $z = \Pi_K(y)$. By the characterization of Euclidean projection, $\langle y - z, x^* - z \rangle \le 0$ for all $x^* \in K$. Then:

$$\|y - x^*\|_2^2 = \|y - z + z - x^*\|_2^2 = \|y - z\|_2^2 + 2\langle y - z, z - x^*\rangle + \|z - x^*\|_2^2$$

Since $\langle y - z, z - x^* \rangle = -\langle y - z, x^* - z \rangle \ge 0$, we get $\|y - x^*\|_2^2 \ge \|z - x^*\|_2^2$. $\blacksquare$

---

## Part (i): Fixed Step Size — $R_T \le DG\sqrt{T}$

**Proof.** Let $x^* = \arg\min_{x \in K} \sum_{t=1}^T f_t(x)$. By convexity of $f_t$:

$$f_t(x_t) - f_t(x^*) \le \langle \nabla f_t(x_t), x_t - x^* \rangle$$

We bound $\langle \nabla f_t(x_t), x_t - x^* \rangle$ using the potential function $\Phi_t = \|x_t - x^*\|_2^2$.

**Step 1: One-step descent.**

Let $g_t = \nabla f_t(x_t)$. Since $x_{t+1} = \Pi_K(x_t - \eta g_t)$, by Lemma 1:

$$\|x_{t+1} - x^*\|_2^2 \le \|x_t - \eta g_t - x^*\|_2^2 = \|x_t - x^*\|_2^2 - 2\eta \langle g_t, x_t - x^* \rangle + \eta^2 \|g_t\|_2^2$$

Rearranging:

$$\langle g_t, x_t - x^* \rangle \le \frac{\|x_t - x^*\|_2^2 - \|x_{t+1} - x^*\|_2^2}{2\eta} + \frac{\eta}{2}\|g_t\|_2^2$$

**Step 2: Telescope.**

Summing over $t = 1, \ldots, T$:

$$\sum_{t=1}^T \langle g_t, x_t - x^* \rangle \le \frac{\|x_1 - x^*\|_2^2 - \|x_{T+1} - x^*\|_2^2}{2\eta} + \frac{\eta}{2}\sum_{t=1}^T \|g_t\|_2^2$$

**Step 3: Bound.**

Since $x_1, x^* \in K$, we have $\|x_1 - x^*\|_2 \le D$. Drop the non-positive term $-\|x_{T+1} - x^*\|_2^2$. Use $\|g_t\|_2 \le G$:

$$R_T \le \frac{D^2}{2\eta} + \frac{\eta G^2 T}{2}$$

**Step 4: Optimize.**

With $\eta = \frac{D}{G\sqrt{T}}$:

$$R_T \le \frac{D^2}{2 \cdot \frac{D}{G\sqrt{T}}} + \frac{D \cdot G^2 T}{2G\sqrt{T}} = \frac{DG\sqrt{T}}{2} + \frac{DG\sqrt{T}}{2} = DG\sqrt{T}$$

$\blacksquare$

---

## Part (ii): Decreasing Step Size — $R_T \le \frac{3}{2}DG\sqrt{T}$

**Proof.** With time-varying step sizes $\eta_t$, the one-step bound (Step 1 of Part (i)) gives:

$$\langle g_t, x_t - x^* \rangle \le \frac{\|x_t - x^*\|_2^2 - \|x_{t+1} - x^*\|_2^2}{2\eta_t} + \frac{\eta_t}{2}\|g_t\|_2^2$$

**Step 1: Abel-type summation.**

Summing over $t = 1, \ldots, T$:

$$R_T \le \sum_{t=1}^T \frac{\|x_t - x^*\|_2^2 - \|x_{t+1} - x^*\|_2^2}{2\eta_t} + \frac{G^2}{2}\sum_{t=1}^T \eta_t$$

Regroup the telescoping terms. For $t = 1, \ldots, T-1$, the term $\|x_{t+1} - x^*\|_2^2$ appears with coefficient $-\frac{1}{2\eta_t}$ from the $t$-th summand and $+\frac{1}{2\eta_{t+1}}$ from the $(t+1)$-th summand. Therefore:

$$R_T \le \frac{\|x_1 - x^*\|_2^2}{2\eta_1} + \sum_{t=2}^{T} \|x_t - x^*\|_2^2 \left(\frac{1}{2\eta_t} - \frac{1}{2\eta_{t-1}}\right) - \frac{\|x_{T+1} - x^*\|_2^2}{2\eta_T} + \frac{G^2}{2}\sum_{t=1}^T \eta_t$$

Since $\eta_t$ is decreasing, $\frac{1}{\eta_t} - \frac{1}{\eta_{t-1}} \ge 0$. Using $\|x_t - x^*\|_2^2 \le D^2$ and dropping $-\frac{\|x_{T+1} - x^*\|_2^2}{2\eta_T} \le 0$:

$$R_T \le \frac{D^2}{2\eta_1} + \frac{D^2}{2}\sum_{t=2}^{T}\left(\frac{1}{\eta_t} - \frac{1}{\eta_{t-1}}\right) + \frac{G^2}{2}\sum_{t=1}^T \eta_t$$

The first two terms telescope:

$$\frac{D^2}{2\eta_1} + \frac{D^2}{2}\left(\frac{1}{\eta_T} - \frac{1}{\eta_1}\right) = \frac{D^2}{2\eta_T}$$

So:

$$R_T \le \frac{D^2}{2\eta_T} + \frac{G^2}{2}\sum_{t=1}^T \eta_t$$

**Step 2: Substitute $\eta_t = \frac{D}{G\sqrt{t}}$.**

$$\frac{D^2}{2\eta_T} = \frac{D^2}{2 \cdot \frac{D}{G\sqrt{T}}} = \frac{DG\sqrt{T}}{2}$$

$$\frac{G^2}{2}\sum_{t=1}^T \eta_t = \frac{G^2}{2}\sum_{t=1}^T \frac{D}{G\sqrt{t}} = \frac{DG}{2}\sum_{t=1}^T \frac{1}{\sqrt{t}}$$

**Step 3: Bound $\sum_{t=1}^T \frac{1}{\sqrt{t}} \le 2\sqrt{T}$.**

We claim $\frac{1}{\sqrt{t}} \le 2(\sqrt{t} - \sqrt{t-1})$ for all $t \ge 1$. To verify, rationalize the right side:

$$2(\sqrt{t} - \sqrt{t-1}) = \frac{2}{\sqrt{t} + \sqrt{t-1}}$$

So the inequality becomes $\frac{1}{\sqrt{t}} \le \frac{2}{\sqrt{t} + \sqrt{t-1}}$, i.e., $\sqrt{t} + \sqrt{t-1} \le 2\sqrt{t}$, i.e., $\sqrt{t-1} \le \sqrt{t}$, which is true.

Therefore:

$$\sum_{t=1}^T \frac{1}{\sqrt{t}} \le 2\sum_{t=1}^T (\sqrt{t} - \sqrt{t-1}) = 2\sqrt{T}$$

**Step 4: Final bound.**

$$R_T \le \frac{DG\sqrt{T}}{2} + \frac{DG}{2} \cdot 2\sqrt{T} = \frac{DG\sqrt{T}}{2} + DG\sqrt{T} = \frac{3}{2}DG\sqrt{T}$$

$\blacksquare$

---

## Preliminary for Part (iii): Khintchine's $L^1$ Lower Bound

**Lemma 2.** Let $\varepsilon_1, \ldots, \varepsilon_T$ be independent Rademacher random variables ($\Pr(\varepsilon_t = \pm 1) = 1/2$). Then:

$$\mathbb{E}\left[\left|\sum_{t=1}^T \varepsilon_t\right|\right] \ge \sqrt{\frac{T}{2}}$$

**Proof of Lemma 2.** Let $S_T = \sum_{t=1}^T \varepsilon_t$. We proceed in three stages: derive exact formulas for $\mathbb{E}[|S_T|]$, prove a binomial coefficient lower bound, then combine.

### Stage 1: Exact formula for $\mathbb{E}[|S_{2m}|]$

For even $T = 2m$, the random variable $S_{2m}$ takes values in $\{-2m, -2m+2, \ldots, 2m-2, 2m\}$ with $\Pr(S_{2m} = 2k) = \binom{2m}{m+k}/4^m$. By symmetry:

$$\mathbb{E}[|S_{2m}|] = \frac{4}{4^m} \sum_{k=1}^{m} k \binom{2m}{m+k}$$

We evaluate the sum $\sum_{k=1}^m k\binom{2m}{m+k}$. Substituting $j = m+k$:

$$k\binom{2m}{m+k} = (j-m)\binom{2m}{j} = j\binom{2m}{j} - m\binom{2m}{j} = 2m\binom{2m-1}{j-1} - m\binom{2m}{j}$$

where we used the absorption identity $j\binom{2m}{j} = 2m\binom{2m-1}{j-1}$.

Summing from $j = m+1$ to $2m$:

**First piece:** $2m\sum_{j=m+1}^{2m}\binom{2m-1}{j-1} = 2m\sum_{i=m}^{2m-1}\binom{2m-1}{i}$. By symmetry of $\binom{2m-1}{\cdot}$ around $(2m-1)/2$, the terms $i = m, \ldots, 2m-1$ constitute exactly half of $2^{2m-1}$, so this sum equals $2m \cdot 2^{2m-2} = m \cdot 2^{2m-1}$.

**Second piece:** $m\sum_{j=m+1}^{2m}\binom{2m}{j} = m \cdot \frac{2^{2m} - \binom{2m}{m}}{2} = m \cdot 2^{2m-1} - \frac{m}{2}\binom{2m}{m}$.

Subtracting: $m \cdot 2^{2m-1} - m \cdot 2^{2m-1} + \frac{m}{2}\binom{2m}{m} = \frac{m}{2}\binom{2m}{m}$.

Therefore:

$$\mathbb{E}[|S_{2m}|] = \frac{4}{4^m} \cdot \frac{m}{2}\binom{2m}{m} = \frac{2m\binom{2m}{m}}{4^m}$$

### Stage 1b: Exact formula for $\mathbb{E}[|S_{2m+1}|]$

For odd $T = 2m+1$, we condition on $S_{2m}$:

$$\mathbb{E}[|S_{2m+1}|] = \frac{1}{2}\mathbb{E}[|S_{2m} + 1|] + \frac{1}{2}\mathbb{E}[|S_{2m} - 1|]$$

For any real $a$: $\frac{1}{2}(|a+1| + |a-1|) = \max(|a|, 1)$. (Check: if $|a| \ge 1$, both terms contribute $|a|$; if $|a| < 1$, the sum is 2, so the average is 1.)

Therefore $\mathbb{E}[|S_{2m+1}|] = \mathbb{E}[\max(|S_{2m}|, 1)]$.

Since $S_{2m}$ is always even, $|S_{2m}| \in \{0, 2, 4, \ldots\}$, so $\max(|S_{2m}|, 1) = |S_{2m}| + \mathbf{1}_{S_{2m} = 0}$. Thus:

$$\mathbb{E}[|S_{2m+1}|] = \mathbb{E}[|S_{2m}|] + \Pr(S_{2m} = 0) = \frac{2m\binom{2m}{m}}{4^m} + \frac{\binom{2m}{m}}{4^m} = \frac{(2m+1)\binom{2m}{m}}{4^m}$$

### Stage 2: Binomial coefficient lower bound

**Claim.** $\binom{2m}{m} \ge \frac{4^m}{2\sqrt{m}}$ for all $m \ge 1$.

*Proof by induction.*

*Base case ($m = 1$):* $\binom{2}{1} = 2$ and $\frac{4}{2} = 2$. Equality holds.

*Inductive step.* Assume $\binom{2m}{m} \ge \frac{4^m}{2\sqrt{m}}$. Using the recurrence:

$$\binom{2m+2}{m+1} = \frac{2(2m+1)}{m+1}\binom{2m}{m}$$

By the induction hypothesis:

$$\binom{2m+2}{m+1} \ge \frac{2(2m+1)}{m+1} \cdot \frac{4^m}{2\sqrt{m}} = \frac{(2m+1) \cdot 4^m}{(m+1)\sqrt{m}}$$

We need this to be $\ge \frac{4^{m+1}}{2\sqrt{m+1}}$. Dividing by $4^m$ and rearranging:

$$\frac{2m+1}{(m+1)\sqrt{m}} \ge \frac{2}{\sqrt{m+1}}$$

Cross-multiplying (all quantities positive) and squaring:

$$(2m+1)^2(m+1) \ge 4(m+1)^2 m \iff (2m+1)^2 \ge 4m(m+1)$$

$$\iff 4m^2 + 4m + 1 \ge 4m^2 + 4m \iff 1 \ge 0 \quad \checkmark$$

$\blacksquare$

### Stage 3: Combining the bounds

**Even case ($T = 2m$):**

$$\mathbb{E}[|S_{2m}|] = \frac{2m\binom{2m}{m}}{4^m} \ge \frac{2m}{2\sqrt{m}} = \sqrt{m} = \sqrt{T/2}$$

**Odd case ($T = 2m+1$):**

$$\mathbb{E}[|S_{2m+1}|] = \frac{(2m+1)\binom{2m}{m}}{4^m} \ge \frac{2m+1}{2\sqrt{m}}$$

We need $\frac{2m+1}{2\sqrt{m}} \ge \sqrt{(2m+1)/2}$. Squaring: $\frac{(2m+1)^2}{4m} \ge \frac{2m+1}{2}$, i.e., $\frac{2m+1}{4m} \ge \frac{1}{2}$, i.e., $2(2m+1) \ge 4m$, i.e., $2 \ge 0$. $\checkmark$

**Case $T = 0$:** Trivially $0 \ge 0$.

This completes the proof of Lemma 2. $\blacksquare$

---

## Part (iii): Lower Bound — $\mathbb{E}[R_T] \ge \frac{DG\sqrt{T}}{2\sqrt{2}}$

**Proof.**

**Step 1: Adversarial construction.**

Let $K = \{x \in \mathbb{R}^d : \|x\|_2 \le D/2\}$ (a ball of radius $D/2$, so $\text{diam}(K) = D$). Define:

$$f_t(x) = G \varepsilon_t \cdot e_1^\top x$$

where $e_1 = (1, 0, \ldots, 0)$ is the first standard basis vector, and $\varepsilon_1, \ldots, \varepsilon_T$ are i.i.d. Rademacher random variables (the adversary's randomization).

*Verify the setup:*
- Each $f_t$ is linear, hence convex.
- $\nabla f_t(x) = G \varepsilon_t e_1$, so $\|\nabla f_t(x)\|_2 = G$ for all $x$.
- The diameter of $K$ is $D$.

**Step 2: Algorithm's expected cumulative loss is 0.**

Let $\mathcal{A}$ be any (possibly randomized) online algorithm. At round $t$, the algorithm chooses $x_t \in K$ based on $f_1, \ldots, f_{t-1}$ and its internal randomness, which are all independent of $\varepsilon_t$. Therefore $x_t \perp \varepsilon_t$, and:

$$\mathbb{E}\left[\sum_{t=1}^T f_t(x_t)\right] = G \sum_{t=1}^T \mathbb{E}[\varepsilon_t \cdot e_1^\top x_t] = G \sum_{t=1}^T \mathbb{E}[\varepsilon_t] \cdot \mathbb{E}[e_1^\top x_t] = 0$$

**Step 3: The offline optimum.**

Let $S = \sum_{t=1}^T \varepsilon_t$. The offline problem is:

$$\min_{\|x\|_2 \le D/2} G \cdot S \cdot e_1^\top x$$

This is a linear minimization over a ball. The minimizer is $x^* = -\frac{D}{2} \cdot \text{sign}(S) \cdot e_1$, yielding value $-\frac{GD}{2}|S|$.

**Step 4: Expected regret.**

$$\mathbb{E}[R_T] = \mathbb{E}\left[\sum_{t=1}^T f_t(x_t)\right] - \mathbb{E}\left[\min_{x \in K}\sum_{t=1}^T f_t(x)\right] = 0 - \left(-\frac{GD}{2}\mathbb{E}[|S|]\right) = \frac{GD}{2}\mathbb{E}[|S|]$$

**Step 5: Apply Lemma 2.**

By Lemma 2, $\mathbb{E}[|S|] \ge \sqrt{T/2}$. Therefore:

$$\mathbb{E}[R_T] \ge \frac{GD}{2} \cdot \sqrt{\frac{T}{2}} = \frac{GD\sqrt{T}}{2\sqrt{2}}$$

**Step 6: Derandomization.**

The above holds for any algorithm $\mathcal{A}$ against the randomized adversary. Since $\mathbb{E}_\varepsilon[R_T(\mathcal{A}, \varepsilon)] \ge \frac{GD\sqrt{T}}{2\sqrt{2}}$ for every $\mathcal{A}$, there exists a deterministic sequence $(\varepsilon_1^*, \ldots, \varepsilon_T^*)$ achieving at least this regret against any fixed algorithm. (For randomized algorithms, the randomized adversary itself guarantees the bound in expectation over both sources of randomness.)

$\blacksquare$

---

## Summary

| Part | Bound | Step Size | Key Technique |
|------|-------|-----------|---------------|
| (i) | $R_T \le DG\sqrt{T}$ | $\eta = D/(G\sqrt{T})$ | Potential function + telescope |
| (ii) | $R_T \le \frac{3}{2}DG\sqrt{T}$ | $\eta_t = D/(G\sqrt{t})$ | Abel summation + $\sum 1/\sqrt{t} \le 2\sqrt{T}$ |
| (iii) | $\mathbb{E}[R_T] \ge \frac{DG\sqrt{T}}{2\sqrt{2}}$ | Any algorithm | Stochastic adversary + Khintchine $L^1$ |

**Interpretation:** OGD with fixed step size achieves $O(DG\sqrt{T})$ regret, and no algorithm can do better than $\Omega(DG\sqrt{T})$, so OGD is **minimax optimal** up to constants.
