# AdaGrad-Norm Non-Convex Convergence — Route 2 (Direct a.s. Bound)

**Route.** Use the almost-sure bound $M := G + \sigma \ge \|g_k\|$ to convert the stochastic quadratic $\|g_k\|^2 / b_k^2$ into a controllable deterministic quantity. The correlation between $g_k$ and $b_k$ is handled by noting $b_k \in \mathcal{F}_k$, so the cross-term vanishes in conditional expectation. The quadratic term is bounded using a **ratio lemma** $b_{k+1}^2 / b_k^2 \le 1 + M^2 / b_0^2$ together with the canonical logarithmic accumulator for $b_{k+1}$.

---

## 1. Preliminaries

**Setting.** $f:\mathbb{R}^d \to \mathbb{R}$ is $L$-smooth with $f^\star := \inf_x f(x) > -\infty$, and $\Delta_0 := f(x_0) - f^\star \ge 0$. AdaGrad-Norm iterates
$$
b_k^2 \;=\; b_0^2 + \sum_{i=0}^{k-1} \|g_i\|^2, \qquad x_{k+1} \;=\; x_k - \frac{\eta}{b_k}\, g_k, \qquad b_0 > 0, \; \eta > 0.
$$
We write $\nabla f_k := \nabla f(x_k)$ and $\xi_k := g_k - \nabla f_k$. The filtration $\mathcal{F}_k := \sigma(g_0, \dots, g_{k-1})$ satisfies $x_k, b_k \in \mathcal{F}_k$, while $g_k, \xi_k \notin \mathcal{F}_k$.

**Assumptions.**
- **(A1)** $\mathbb{E}[g_k \mid \mathcal{F}_k] = \nabla f_k$, equivalently $\mathbb{E}[\xi_k \mid \mathcal{F}_k] = 0$.
- **(A2)** $\|\xi_k\| \le \sigma$ a.s.
- **(A3)** $\|\nabla f_k\| \le G$ a.s. along the trajectory.

**A.s. bound on $\|g_k\|$.** By the triangle inequality,
$$
\|g_k\| \;=\; \|\nabla f_k + \xi_k\| \;\le\; \|\nabla f_k\| + \|\xi_k\| \;\le\; G + \sigma \;=:\; M \quad \text{a.s.}
$$
Therefore $\|g_k\|^2 \le M^2$ a.s. for every $k \ge 0$.

**Monotonicity / envelope for $b_k$.** By construction, $b_{k+1}^2 = b_k^2 + \|g_k\|^2 \ge b_k^2$, so $(b_k)_{k \ge 0}$ is non-decreasing, and in particular $b_k \ge b_0$ for all $k$. Summing $\|g_i\|^2 \le M^2$ yields
$$
b_T^2 \;\le\; b_0^2 + T M^2, \qquad b_T \;\le\; b_0 + M\sqrt{T}. \tag{1.1}
$$

---

## 2. Lemma 1 (Descent Lemma)

**Lemma 1.** For every $k \ge 0$, almost surely,
$$
f(x_{k+1}) \;\le\; f(x_k) - \frac{\eta}{b_k}\, \langle \nabla f_k, g_k \rangle + \frac{L \eta^2}{2 b_k^2}\, \|g_k\|^2.
$$

**Proof.** By $L$-smoothness of $f$, for any $x, y$:
$$
f(y) \;\le\; f(x) + \langle \nabla f(x), y - x \rangle + \frac{L}{2} \|y - x\|^2.
$$
Apply this with $x = x_k$, $y = x_{k+1} = x_k - (\eta / b_k) g_k$:
$$
f(x_{k+1}) \;\le\; f(x_k) + \Big\langle \nabla f_k, -\frac{\eta}{b_k} g_k \Big\rangle + \frac{L}{2}\, \Big\| \frac{\eta}{b_k} g_k \Big\|^2
= f(x_k) - \frac{\eta}{b_k} \langle \nabla f_k, g_k \rangle + \frac{L \eta^2}{2 b_k^2} \|g_k\|^2. \qquad \square
$$

---

## 3. Lemma 2 (Logarithmic Accumulator for $b_{k+1}$)

**Lemma 2.** Let $B_0 > 0$ and let $a_0, a_1, \dots$ be any non-negative reals. Define $B_k^2 := B_0^2 + \sum_{i=0}^{k-1} a_i^2$. Then for every $T \ge 1$,
$$
\sum_{k=0}^{T-1} \frac{a_k^2}{B_{k+1}^2} \;\le\; \log\!\left(\frac{B_T^2}{B_0^2}\right).
$$

**Proof.** Fix $k$. Since $B_{k+1}^2 = B_k^2 + a_k^2 \ge B_k^2 > 0$, and the function $t \mapsto 1/t$ is decreasing on $(0,\infty)$, we have for all $t \in [B_k^2, B_{k+1}^2]$:
$$
\frac{1}{B_{k+1}^2} \;\le\; \frac{1}{t}.
$$
Integrate both sides over $t \in [B_k^2, B_{k+1}^2]$ (a non-empty interval when $a_k > 0$; both sides vanish when $a_k = 0$):
$$
\frac{a_k^2}{B_{k+1}^2} \;=\; \frac{B_{k+1}^2 - B_k^2}{B_{k+1}^2} \;=\; \int_{B_k^2}^{B_{k+1}^2} \frac{dt}{B_{k+1}^2} \;\le\; \int_{B_k^2}^{B_{k+1}^2} \frac{dt}{t} \;=\; \log B_{k+1}^2 - \log B_k^2.
$$
Summing over $k = 0, 1, \dots, T-1$ (telescoping),
$$
\sum_{k=0}^{T-1} \frac{a_k^2}{B_{k+1}^2} \;\le\; \log B_T^2 - \log B_0^2 \;=\; \log\!\left( \frac{B_T^2}{B_0^2} \right). \qquad \square
$$

Applying Lemma 2 with $a_k = \|g_k\|$ and $B_k = b_k$, and using (1.1),
$$
\sum_{k=0}^{T-1} \frac{\|g_k\|^2}{b_{k+1}^2} \;\le\; \log\!\left( \frac{b_T^2}{b_0^2} \right) \;\le\; \log\!\left( 1 + \frac{T M^2}{b_0^2} \right) \quad \text{a.s.} \tag{3.1}
$$

---

## 4. Lemma 3 (Ratio Bound)

**Lemma 3.** For all $k \ge 0$, almost surely,
$$
\frac{b_{k+1}^2}{b_k^2} \;\le\; 1 + \frac{M^2}{b_0^2}.
$$
Equivalently, $1/b_k^2 \le (1 + M^2/b_0^2) \cdot 1/b_{k+1}^2$.

**Proof.** By definition,
$$
b_{k+1}^2 \;=\; b_k^2 + \|g_k\|^2.
$$
Dividing by $b_k^2$ (which is $\ge b_0^2 > 0$ by monotonicity),
$$
\frac{b_{k+1}^2}{b_k^2} \;=\; 1 + \frac{\|g_k\|^2}{b_k^2}.
$$
Since $\|g_k\|^2 \le M^2$ a.s. and $b_k^2 \ge b_0^2$,
$$
\frac{\|g_k\|^2}{b_k^2} \;\le\; \frac{M^2}{b_0^2},
$$
which gives $b_{k+1}^2 / b_k^2 \le 1 + M^2 / b_0^2$. Taking reciprocals (both sides positive) yields $1/b_k^2 \le (1 + M^2/b_0^2)/b_{k+1}^2$. $\quad\square$

**Corollary (quadratic a.s. bound).** Combining Lemma 3 with (3.1):
$$
\sum_{k=0}^{T-1} \frac{\|g_k\|^2}{b_k^2}
\;\le\; \left(1 + \frac{M^2}{b_0^2}\right) \sum_{k=0}^{T-1} \frac{\|g_k\|^2}{b_{k+1}^2}
\;\le\; \left(1 + \frac{M^2}{b_0^2}\right) \log\!\left(1 + \frac{T M^2}{b_0^2}\right) \quad \text{a.s.} \tag{4.1}
$$

Define the deterministic constant (the upper bound in (4.1) is almost sure, not random)
$$
\Lambda_T \;:=\; \left(1 + \frac{M^2}{b_0^2}\right) \log\!\left(1 + \frac{T M^2}{b_0^2}\right). \tag{4.2}
$$

---

## 5. Main Argument

**Rewriting the inner product.** Decompose
$$
\langle \nabla f_k, g_k \rangle \;=\; \|\nabla f_k\|^2 + \langle \nabla f_k, \xi_k \rangle. \tag{5.1}
$$

Substituting (5.1) into Lemma 1 and rearranging,
$$
\frac{\eta}{b_k}\, \|\nabla f_k\|^2 \;\le\; f(x_k) - f(x_{k+1}) - \frac{\eta}{b_k}\, \langle \nabla f_k, \xi_k \rangle + \frac{L\eta^2}{2 b_k^2}\, \|g_k\|^2. \tag{5.2}
$$

Summing (5.2) for $k = 0, 1, \dots, T-1$ and telescoping the first two terms on the right,
$$
\sum_{k=0}^{T-1} \frac{\eta\, \|\nabla f_k\|^2}{b_k}
\;\le\; \bigl( f(x_0) - f(x_T) \bigr)
\;-\; \eta \sum_{k=0}^{T-1} \frac{\langle \nabla f_k, \xi_k \rangle}{b_k}
\;+\; \frac{L \eta^2}{2} \sum_{k=0}^{T-1} \frac{\|g_k\|^2}{b_k^2}. \tag{5.3}
$$

Since $f(x_T) \ge f^\star$, we have $f(x_0) - f(x_T) \le \Delta_0$. Together with (4.1),
$$
\sum_{k=0}^{T-1} \frac{\eta\, \|\nabla f_k\|^2}{b_k}
\;\le\; \Delta_0
\;-\; \eta \sum_{k=0}^{T-1} \frac{\langle \nabla f_k, \xi_k \rangle}{b_k}
\;+\; \frac{L \eta^2}{2}\, \Lambda_T \quad \text{a.s.} \tag{5.4}
$$

**Taking expectation — cross-term vanishes.** Both $\nabla f_k$ and $b_k$ are $\mathcal{F}_k$-measurable, while $\mathbb{E}[\xi_k \mid \mathcal{F}_k] = 0$ by (A1). Therefore
$$
\mathbb{E}\!\left[ \frac{\langle \nabla f_k, \xi_k \rangle}{b_k} \,\Big|\, \mathcal{F}_k \right]
\;=\; \frac{1}{b_k} \Big\langle \nabla f_k, \mathbb{E}[\xi_k \mid \mathcal{F}_k] \Big\rangle
\;=\; 0. \tag{5.5}
$$
Each term is integrable: $\|\xi_k\| \le \sigma$, $\|\nabla f_k\| \le G$, and $b_k \ge b_0 > 0$, so $|\langle \nabla f_k, \xi_k \rangle / b_k| \le G\sigma/b_0$. By the tower property, $\mathbb{E}[\langle \nabla f_k, \xi_k \rangle / b_k] = 0$ for every $k$. Taking expectation in (5.4) and invoking (5.5) term-by-term (there are finitely many terms, so linearity applies):
$$
\mathbb{E}\!\left[\sum_{k=0}^{T-1} \frac{\eta\, \|\nabla f_k\|^2}{b_k}\right]
\;\le\; \Delta_0 + \frac{L \eta^2}{2}\, \Lambda_T.
$$
Dividing by $\eta > 0$,
$$
\mathbb{E}\!\left[\sum_{k=0}^{T-1} \frac{\|\nabla f_k\|^2}{b_k}\right]
\;\le\; \frac{\Delta_0}{\eta} + \frac{L \eta}{2}\, \Lambda_T. \tag{5.6}
$$

**Converting $1/b_k$ to the convergence rate.** By monotonicity $b_k \le b_T$ for $0 \le k \le T-1$, hence $1/b_k \ge 1/b_T$. Multiplying the summand in (5.6) term-by-term:
$$
\sum_{k=0}^{T-1} \frac{\|\nabla f_k\|^2}{b_k} \;\ge\; \frac{1}{b_T} \sum_{k=0}^{T-1} \|\nabla f_k\|^2 \;\ge\; \frac{T}{b_T} \cdot \min_{0 \le k < T} \|\nabla f_k\|^2. \tag{5.7}
$$

**Handling the random denominator $b_T$.** We use the Cauchy–Schwarz inequality in the form $\mathbb{E}[X] \le \sqrt{\mathbb{E}[X Y]\, \mathbb{E}[1/Y]}$ for $X,Y>0$, applied to $X := \min_k \|\nabla f_k\|^2$ and $Y := b_T$. That gives
$$
\Big(\mathbb{E}[X]\Big)^2 \;\le\; \mathbb{E}\!\left[ \frac{X}{b_T^{-1}} \cdot \frac{1}{b_T^{-1}} \cdot b_T^{-1} \right] \cdots
$$
— but more transparently, we directly use $b_T \le b_0 + M\sqrt{T}$ from (1.1), which holds **almost surely** (not only in expectation). Therefore $1/b_T \ge 1/(b_0 + M\sqrt{T})$ a.s., and (5.7) gives, a.s.,
$$
\sum_{k=0}^{T-1} \frac{\|\nabla f_k\|^2}{b_k}
\;\ge\; \frac{T}{b_0 + M\sqrt{T}}\, \min_{0\le k<T} \|\nabla f_k\|^2. \tag{5.8}
$$
Taking expectation of (5.8) and combining with (5.6):
$$
\frac{T}{b_0 + M\sqrt{T}}\, \mathbb{E}\!\left[\min_{0\le k<T} \|\nabla f_k\|^2\right]
\;\le\; \mathbb{E}\!\left[\sum_{k=0}^{T-1} \frac{\|\nabla f_k\|^2}{b_k}\right]
\;\le\; \frac{\Delta_0}{\eta} + \frac{L \eta}{2}\, \Lambda_T.
$$
Rearranging,
$$
\boxed{\;\mathbb{E}\!\left[\min_{0\le k<T} \|\nabla f_k\|^2\right]
\;\le\; \frac{b_0 + M\sqrt{T}}{T}\, \left[\frac{\Delta_0}{\eta} + \frac{L \eta}{2}\, \Lambda_T\right].\;} \tag{5.9}
$$

---

## 6. Final Rate and Explicit Constants

Expanding (5.9) using (4.2), with $M = G + \sigma$:
$$
\mathbb{E}\!\left[\min_{0\le k<T} \|\nabla f_k\|^2\right]
\;\le\; \frac{b_0 + M\sqrt{T}}{T}\cdot \frac{\Delta_0}{\eta}
\;+\; \frac{b_0 + M\sqrt{T}}{T}\cdot \frac{L\eta}{2}\left(1+\frac{M^2}{b_0^2}\right)\log\!\left(1+\frac{T M^2}{b_0^2}\right). \tag{6.1}
$$

**Asymptotic rate.** For $T \ge 2$ we have $b_0 + M\sqrt{T} \le (b_0 + M)\sqrt{T}$ (when $b_0 \le b_0 \sqrt{T}$, which holds since $\sqrt{T} \ge 1$; more precisely $b_0 \le b_0\sqrt{T}$ and $M\sqrt{T}=M\sqrt T$, so the sum is $\le (b_0+M)\sqrt T$). Therefore
$$
\frac{b_0 + M\sqrt{T}}{T} \;\le\; \frac{b_0 + M}{\sqrt{T}}.
$$
Also $\log(1 + TM^2/b_0^2) \le \log(T) + \log(1 + M^2/b_0^2)$ for $T \ge 1$ (since $1 + TM^2/b_0^2 \le T(1+M^2/b_0^2)$ when $T \ge 1$). For $T \ge 2$,
$$
\log\!\left(1+\frac{TM^2}{b_0^2}\right) \;\le\; \left[1 + \frac{\log(1 + M^2/b_0^2)}{\log 2}\right] \log T.
$$
Define
$$
\kappa \;:=\; 1 + \frac{\log(1 + M^2/b_0^2)}{\log 2}, \qquad
C_1 \;:=\; (b_0 + M)\cdot\frac{\Delta_0}{\eta}, \qquad
C_2 \;:=\; (b_0+M)\cdot\frac{L\eta}{2}\left(1+\frac{M^2}{b_0^2}\right)\kappa. \tag{6.2}
$$
Then from (6.1),
$$
\mathbb{E}\!\left[\min_{0\le k<T} \|\nabla f_k\|^2\right] \;\le\; \frac{C_1}{\sqrt{T}} + C_2\cdot\frac{\log T}{\sqrt{T}} \;\le\; (C_1 + C_2)\cdot \frac{\log T}{\sqrt{T}}
$$
for all $T \ge 2$ (using $1 \le \log T / \log 2 \le \log T \cdot 1.45$; simply $1 \le \log T / \log 2$ for $T\ge 2$, so $C_1 \le C_1 \log T$). The explicit final constant is
$$
\boxed{\;C \;=\; C_1 + C_2 \;=\; (b_0 + M)\left[\frac{\Delta_0}{\eta} + \frac{L\eta}{2}\left(1+\frac{M^2}{b_0^2}\right)\kappa\right],\quad M = G+\sigma,\quad \kappa = 1 + \tfrac{\log(1+M^2/b_0^2)}{\log 2}.\;}
$$
This $C$ is polynomial in $L, \eta, b_0, G, \sigma, \Delta_0$ (up to a single $\log$ factor in $M/b_0$ inside $\kappa$), as claimed in the statement. We conclude
$$
\mathbb{E}\!\left[\min_{0\le k<T} \|\nabla f_k\|^2\right] \;\le\; C\, \frac{\log T}{\sqrt{T}} \qquad \forall\, T\ge 2.
$$

Moreover, (5.9) with (5.6) additionally shows
$$
\frac{1}{T}\sum_{k=0}^{T-1}\mathbb{E}[\|\nabla f_k\|^2] \;\le\; \frac{b_0+M\sqrt T}{T}\cdot\Big[\tfrac{\Delta_0}{\eta}+\tfrac{L\eta}{2}\Lambda_T\Big] \;=\; O\!\left(\frac{\log T}{\sqrt T}\right),
$$
giving the averaged form quoted in the problem statement. $\quad\blacksquare$

---

## Summary of the Route 2 Mechanism

| Step | Randomness handled | Tool |
|------|-------------------|------|
| Lemma 1 | pathwise (deterministic per path) | $L$-smoothness |
| Cross-term $\langle\nabla f_k,\xi_k\rangle/b_k$ | $b_k \in \mathcal F_k$, $\mathbb E[\xi_k\mid\mathcal F_k]=0$ | Tower property |
| Quadratic $\|g_k\|^2/b_k^2$ | $\|g_k\|\le M$ a.s., bypass stochasticity | Lemma 3 ratio + Lemma 2 log accumulator |
| Convert $\sum\|\nabla f_k\|^2/b_k$ to rate | $b_T \le b_0 + M\sqrt T$ a.s. | Envelope (1.1) |

The distinctive feature of Route 2: **no decoupling identity $1/b_k = 1/b_{k+1} + \text{corr}$ is needed**. Instead, the a.s. boundedness (A2)+(A3) gives a constant multiplicative ratio between $1/b_k^2$ and $1/b_{k+1}^2$, which absorbs the "shift" into a single factor $(1+M^2/b_0^2)$.
