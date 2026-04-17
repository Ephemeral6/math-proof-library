# OGD Regret Bounds — Clean Proof

**Theorem.** Consider OGD over convex compact $K \subseteq \mathbb{R}^d$ with $\text{diam}(K) = D$, convex losses $f_t$ with $\|\nabla f_t\| \le G$, and update $x_{t+1} = \Pi_K(x_t - \eta_t g_t)$. Then:

(i) $\eta = D/(G\sqrt{T}) \implies R_T \le DG\sqrt{T}$

(ii) $\eta_t = D/(G\sqrt{t}) \implies R_T \le \tfrac{3}{2}DG\sqrt{T}$

(iii) $\exists$ adversary: $\forall$ algorithm, $\mathbb{E}[R_T] \ge DG\sqrt{T}/(2\sqrt{2})$

---

**Lemma 1** (Projection). $\|\Pi_K(y) - x^*\| \le \|y - x^*\|$ for $x^* \in K$.

*Proof.* Let $z = \Pi_K(y)$. The projection characterization gives $\langle y-z, x^*-z\rangle \le 0$. Expand $\|y-x^*\|^2 = \|y-z\|^2 + 2\langle y-z, z-x^*\rangle + \|z-x^*\|^2 \ge \|z-x^*\|^2$. $\blacksquare$

---

### Part (i)

By convexity and Lemma 1: $\langle g_t, x_t - x^*\rangle \le \frac{\|x_t-x^*\|^2 - \|x_{t+1}-x^*\|^2}{2\eta} + \frac{\eta}{2}\|g_t\|^2$. Telescope, use $\|x_1-x^*\| \le D$ and $\|g_t\| \le G$:

$$R_T \le \frac{D^2}{2\eta} + \frac{\eta G^2 T}{2}$$

Set $\eta = D/(G\sqrt{T})$: both terms equal $DG\sqrt{T}/2$, giving $R_T \le DG\sqrt{T}$. $\blacksquare$

---

### Part (ii)

With $\eta_t$ decreasing, regroup the telescoping sum by Abel summation. The coefficient of each $\|x_t - x^*\|^2$ is non-negative (since $1/\eta_t$ increases), so bound by $D^2$. The first two terms telescope to $D^2/(2\eta_T)$:

$$R_T \le \frac{D^2}{2\eta_T} + \frac{G^2}{2}\sum_{t=1}^T \eta_t = \frac{DG\sqrt{T}}{2} + \frac{DG}{2}\sum_{t=1}^T \frac{1}{\sqrt{t}}$$

Since $1/\sqrt{t} \le 2(\sqrt{t}-\sqrt{t-1})$ (rationalize: equivalent to $\sqrt{t-1}\le\sqrt{t}$), the sum telescopes to $\le 2\sqrt{T}$. Thus $R_T \le \frac{3}{2}DG\sqrt{T}$. $\blacksquare$

---

### Lemma 2 (Khintchine $L^1$)

$\mathbb{E}[|\sum_{t=1}^T \varepsilon_t|] \ge \sqrt{T/2}$ for Rademacher $\varepsilon_t$.

*Proof.* **Exact formulas.** Using the absorption identity $j\binom{2m}{j} = 2m\binom{2m-1}{j-1}$ and binomial symmetry:

$$\mathbb{E}[|S_{2m}|] = \frac{2m\binom{2m}{m}}{4^m}, \qquad \mathbb{E}[|S_{2m+1}|] = \frac{(2m+1)\binom{2m}{m}}{4^m}$$

(The odd formula uses $\frac{1}{2}(|a+1|+|a-1|) = \max(|a|,1)$ and $\Pr(S_{2m}=0) = \binom{2m}{m}/4^m$.)

**Key bound.** $\binom{2m}{m} \ge 4^m/(2\sqrt{m})$ for $m \ge 1$, by induction: base $m=1$ gives $2 \ge 2$; the step uses $\binom{2m+2}{m+1} = \frac{2(2m+1)}{m+1}\binom{2m}{m}$ and reduces to $(2m+1)^2 \ge 4m(m+1)$, i.e., $1 \ge 0$.

**Even $T=2m$:** $\frac{2m\binom{2m}{m}}{4^m} \ge \frac{2m}{2\sqrt{m}} = \sqrt{m} = \sqrt{T/2}$.

**Odd $T=2m+1$:** $\frac{2m+1}{2\sqrt{m}} \ge \sqrt{(2m+1)/2}$ reduces to $2 \ge 0$. $\blacksquare$

---

### Part (iii)

**Construction.** $K = \{x : \|x\| \le D/2\}$, $f_t(x) = G\varepsilon_t e_1^\top x$ with Rademacher $\varepsilon_t$.

- Gradient bound: $\|\nabla f_t\| = G$. Diameter: $D$.
- $x_t \perp \varepsilon_t$ (depends only on $\varepsilon_1,\ldots,\varepsilon_{t-1}$), so $\mathbb{E}[\sum f_t(x_t)] = 0$.
- Offline optimum: $\min_K \sum f_t(x) = -\frac{GD}{2}|S|$ where $S = \sum \varepsilon_t$.
- $\mathbb{E}[R_T] = \frac{GD}{2}\mathbb{E}[|S|] \ge \frac{GD}{2}\sqrt{T/2} = \frac{GD\sqrt{T}}{2\sqrt{2}}$.

Derandomization: the bound holds against any algorithm, so a deterministic adversary achieving this exists by averaging. $\blacksquare$
