# Proof of AdaGrad-Norm Non-Convex Convergence — Route 1 (Surrogate Step-Size via $b_{k+1}$ Substitution)

**Theorem.** Under assumptions (A1)–(A3), the iterates of AdaGrad-Norm
$$x_{k+1} = x_k - \frac{\eta}{b_k}\, g_k, \qquad b_k^2 = b_0^2 + \sum_{i=0}^{k-1}\|g_i\|^2,$$
satisfy, for every $T\ge 2$,
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right] \;\le\; C\,\frac{\log T}{\sqrt{T}},$$
for an explicit constant $C = C(\Delta_0,\eta,b_0,L,\sigma,G)$ polynomial in its arguments.

---

## 1. Preliminaries

**Notation.** $\nabla f_k := \nabla f(x_k)$. $\mathcal{F}_k := \sigma(g_0,\dots,g_{k-1})$. Both $x_k$ and
$$b_k^2 = b_0^2 + \sum_{i=0}^{k-1}\|g_i\|^2$$
are $\mathcal{F}_k$-measurable (they depend only on $g_0,\dots,g_{k-1}$). Note $b_k > 0$ and monotone: $b_0 \le b_1 \le b_2 \le \cdots$.

**A.s. bound on $\|g_k\|$.** By (A2) and (A3), and the triangle inequality,
$$\|g_k\| \;\le\; \|g_k-\nabla f_k\| + \|\nabla f_k\| \;\le\; \sigma + G \qquad\text{a.s.}$$
Write $M := G+\sigma$. Hence $\|g_k\|^2 \le M^2$ a.s.

**Envelope for $b_T$.** Telescoping the recursion for $b_k^2$ and using $\|g_i\|^2 \le M^2$,
$$b_T^2 \;=\; b_0^2 + \sum_{i=0}^{T-1}\|g_i\|^2 \;\le\; b_0^2 + TM^2,$$
so (using $\sqrt{a+b}\le \sqrt{a}+\sqrt{b}$ for $a,b\ge 0$)
$$b_T \;\le\; b_0 + M\sqrt{T}\qquad\text{a.s.} \tag{Env}$$

Also $b_k\ge b_0$ for all $k$.

---

## 2. Lemma 1 (Adaptive Descent Lemma)

**Statement.** For every $k\ge 0$,
$$f(x_{k+1}) \;\le\; f(x_k) \;-\; \frac{\eta}{b_k}\langle \nabla f_k, g_k\rangle \;+\; \frac{L\eta^2}{2\, b_k^2}\,\|g_k\|^2.$$

**Proof.** $L$-smoothness yields (see library proof `gd-nonconvex-stationary-point/proof.md`, eq. (1)) the descent inequality
$$f(y) \;\le\; f(x) + \langle \nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2,\qquad \forall x,y\in\mathbb{R}^d. \tag{DL}$$

Apply (DL) with $x=x_k$, $y=x_{k+1}=x_k-\frac{\eta}{b_k} g_k$:
$$f(x_{k+1}) \le f(x_k) + \left\langle \nabla f_k,\, -\tfrac{\eta}{b_k} g_k\right\rangle + \frac{L}{2}\left\|\tfrac{\eta}{b_k} g_k\right\|^2$$
$$= f(x_k) - \frac{\eta}{b_k}\langle \nabla f_k, g_k\rangle + \frac{L\eta^2}{2b_k^2}\|g_k\|^2.\qquad\square$$

---

## 3. Lemma 2 (Log Accumulator)

**Statement.** Let $B_0>0$ and let $a_0,\dots,a_{T-1}\ge 0$. Define
$$B_k^2 \;:=\; B_0^2 + \sum_{i=0}^{k-1} a_i^2.$$
Then
$$\sum_{k=0}^{T-1} \frac{a_k^2}{B_{k+1}^2} \;\le\; \log\!\frac{B_T^2}{B_0^2}.$$

**Proof.** The map $u\mapsto 1/u$ is decreasing on $(0,\infty)$, so for each $k$,
$$\int_{B_k^2}^{B_{k+1}^2} \frac{du}{u} \;\ge\; \frac{B_{k+1}^2 - B_k^2}{B_{k+1}^2} \;=\; \frac{a_k^2}{B_{k+1}^2},$$
where the equality uses $B_{k+1}^2-B_k^2 = a_k^2$. Summing $k=0,\dots,T-1$ and using telescoping of the integral,
$$\sum_{k=0}^{T-1}\frac{a_k^2}{B_{k+1}^2} \;\le\; \sum_{k=0}^{T-1}\int_{B_k^2}^{B_{k+1}^2}\frac{du}{u} \;=\; \int_{B_0^2}^{B_T^2}\frac{du}{u} \;=\; \log\!\frac{B_T^2}{B_0^2}.\qquad\square$$

**Corollary (applied to our setting).** With $a_k = \|g_k\|$ and $B_k=b_k$,
$$\sum_{k=0}^{T-1}\frac{\|g_k\|^2}{b_{k+1}^2} \;\le\; \log\!\frac{b_T^2}{b_0^2} \;\le\; \log\!\frac{b_0^2+TM^2}{b_0^2}. \tag{LogA}$$

---

## 4. Lemma 3 (Decoupling Identity)

**Statement.** For every $k\ge 0$,
$$\frac{1}{b_k^2} - \frac{1}{b_{k+1}^2} \;=\; \frac{\|g_k\|^2}{b_k^2\, b_{k+1}^2}.$$
Consequently
$$\frac{\|g_k\|^2}{b_k^2} \;=\; \frac{\|g_k\|^2}{b_{k+1}^2} \;+\; \frac{\|g_k\|^4}{b_k^2\, b_{k+1}^2}. \tag{DC}$$

**Proof.** Directly,
$$\frac{1}{b_k^2}-\frac{1}{b_{k+1}^2} \;=\; \frac{b_{k+1}^2 - b_k^2}{b_k^2\, b_{k+1}^2} \;=\; \frac{\|g_k\|^2}{b_k^2\, b_{k+1}^2},$$
using $b_{k+1}^2-b_k^2=\|g_k\|^2$. Multiplying both sides by $\|g_k\|^2$ gives (DC). $\square$

**Use.** Applying Lemma 2 again to the "correction" term,
$$\frac{\|g_k\|^4}{b_k^2\, b_{k+1}^2} \;=\; \|g_k\|^2\cdot\frac{\|g_k\|^2}{b_k^2\, b_{k+1}^2} \;\le\; M^2\cdot\frac{\|g_k\|^2}{b_k^2\, b_{k+1}^2} \;\le\; \frac{M^2}{b_0^2}\cdot \frac{\|g_k\|^2}{b_{k+1}^2},$$
where we used $\|g_k\|^2\le M^2$ a.s. and $b_k\ge b_0$. Summing,
$$\sum_{k=0}^{T-1}\frac{\|g_k\|^4}{b_k^2\, b_{k+1}^2} \;\le\; \frac{M^2}{b_0^2}\sum_{k=0}^{T-1}\frac{\|g_k\|^2}{b_{k+1}^2} \;\stackrel{(LogA)}{\le}\; \frac{M^2}{b_0^2}\,\log\!\frac{b_0^2+TM^2}{b_0^2}. \tag{Corr}$$

Combining (DC), (LogA), (Corr),
$$\sum_{k=0}^{T-1}\frac{\|g_k\|^2}{b_k^2} \;\le\; \Big(1+\frac{M^2}{b_0^2}\Big)\,\log\!\frac{b_0^2+TM^2}{b_0^2}. \tag{QT}$$

The bound (QT) holds almost surely (pathwise on the full-probability event $\{\|g_i\|\le M\ \forall i\}$).

---

## 5. Main Argument

### 5.1 Split the cross-term

By (A1), $\mathbb{E}[g_k\mid\mathcal{F}_k]=\nabla f_k$. Decompose $g_k = \nabla f_k + \xi_k$ where $\xi_k:=g_k-\nabla f_k$ satisfies $\mathbb{E}[\xi_k\mid\mathcal{F}_k]=0$ and $\|\xi_k\|\le\sigma$ a.s. Then
$$\langle \nabla f_k, g_k\rangle \;=\; \|\nabla f_k\|^2 + \langle \nabla f_k,\xi_k\rangle.$$

Substituting into Lemma 1 and rearranging,
$$\frac{\eta}{b_k}\|\nabla f_k\|^2 \;\le\; \big(f(x_k)-f(x_{k+1})\big) \;-\; \frac{\eta}{b_k}\langle \nabla f_k,\xi_k\rangle \;+\; \frac{L\eta^2}{2 b_k^2}\|g_k\|^2. \tag{$*$}$$

### 5.2 Telescope and take expectation

Summing ($*$) over $k=0,\dots,T-1$:
$$\eta\sum_{k=0}^{T-1}\frac{\|\nabla f_k\|^2}{b_k} \;\le\; \big(f(x_0)-f(x_T)\big) \;-\; \eta\sum_{k=0}^{T-1}\frac{\langle\nabla f_k,\xi_k\rangle}{b_k} \;+\; \frac{L\eta^2}{2}\sum_{k=0}^{T-1}\frac{\|g_k\|^2}{b_k^2}. \tag{$**$}$$

Bound $f(x_0)-f(x_T)\le f(x_0)-f^\star=\Delta_0$ and take expectations of both sides of $(**)$.

**Cross-term is mean zero.** For each $k$, $\nabla f_k/b_k$ is $\mathcal{F}_k$-measurable (since $x_k,b_k\in\mathcal{F}_k$), and $\mathbb{E}[\xi_k\mid\mathcal{F}_k]=0$. By the tower property,
$$\mathbb{E}\!\left[\frac{\langle \nabla f_k,\xi_k\rangle}{b_k}\right] \;=\; \mathbb{E}\!\left[\Big\langle\tfrac{\nabla f_k}{b_k},\,\mathbb{E}[\xi_k\mid\mathcal{F}_k]\Big\rangle\right] \;=\; 0.$$

*Integrability check.* $|\langle\nabla f_k,\xi_k\rangle/b_k|\le G\sigma/b_0$ a.s., so all conditional expectations are finite and the tower step is valid.

**Quadratic term.** By (QT), almost surely,
$$\sum_{k=0}^{T-1}\frac{\|g_k\|^2}{b_k^2} \;\le\; \Big(1+\frac{M^2}{b_0^2}\Big)\,\log\!\frac{b_0^2+TM^2}{b_0^2}=:\Lambda_T.$$

Taking expectation of $(**)$,
$$\eta\,\mathbb{E}\!\left[\sum_{k=0}^{T-1}\frac{\|\nabla f_k\|^2}{b_k}\right] \;\le\; \Delta_0 \;+\; \frac{L\eta^2}{2}\,\Lambda_T. \tag{A}$$

### 5.3 Pass from $1/b_k$ to $1/b_T$ (and then to $1/(b_0+M\sqrt{T})$)

Since $b_k$ is monotone non-decreasing in $k$, $b_k\le b_T$ a.s., hence $1/b_k\ge 1/b_T$ a.s. Therefore
$$\sum_{k=0}^{T-1}\|\nabla f_k\|^2 \;=\; \sum_{k=0}^{T-1} b_k\cdot\frac{\|\nabla f_k\|^2}{b_k} \;\le\; b_T\sum_{k=0}^{T-1}\frac{\|\nabla f_k\|^2}{b_k}. \tag{B}$$

Taking expectation of (B) and using Cauchy–Schwarz,
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f_k\|^2\right] \;\le\; \mathbb{E}\!\left[b_T\sum_{k=0}^{T-1}\frac{\|\nabla f_k\|^2}{b_k}\right].$$

To combine with (A) cleanly we use the deterministic envelope (Env), $b_T\le b_0+M\sqrt{T}$ a.s. Then $b_T\cdot\sum_k \|\nabla f_k\|^2/b_k$ is $\le (b_0+M\sqrt{T})\cdot\sum_k\|\nabla f_k\|^2/b_k$ a.s., and
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f_k\|^2\right] \;\le\; (b_0+M\sqrt{T})\;\mathbb{E}\!\left[\sum_{k=0}^{T-1}\frac{\|\nabla f_k\|^2}{b_k}\right]. \tag{C}$$

### 5.4 Final rate

Plug (A) into (C):
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f_k\|^2\right] \;\le\; \frac{b_0+M\sqrt{T}}{\eta}\Big(\Delta_0 + \tfrac{L\eta^2}{2}\Lambda_T\Big).$$

The minimum over $k$ is at most the average:
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f_k\|^2\right] \;\le\; \frac{1}{T}\,\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f_k\|^2\right] \;\le\; \frac{b_0+M\sqrt{T}}{\eta\, T}\Big(\Delta_0+\tfrac{L\eta^2}{2}\Lambda_T\Big). \tag{D}$$

### 5.5 Extracting the $\log T/\sqrt{T}$ shape

Write the RHS of (D) as $\Big(\frac{b_0}{\eta T}+\frac{M}{\eta\sqrt{T}}\Big)\big(\Delta_0+\tfrac{L\eta^2}{2}\Lambda_T\big)$.

For $T\ge 2$, $\frac{1}{T}\le\frac{1}{\sqrt{T}}$, so $\frac{b_0}{\eta T}+\frac{M}{\eta\sqrt{T}}\le \frac{b_0+M}{\eta\sqrt{T}}$. Also,
$$\Lambda_T = \Big(1+\frac{M^2}{b_0^2}\Big)\log\!\frac{b_0^2+TM^2}{b_0^2} \;\le\; \Big(1+\frac{M^2}{b_0^2}\Big)\Big(\log T + \log\!\frac{b_0^2+M^2}{b_0^2}\Big),$$
because for $T\ge 1$, $b_0^2+TM^2 \le T(b_0^2+M^2)$, hence $\log\frac{b_0^2+TM^2}{b_0^2}\le \log T + \log\frac{b_0^2+M^2}{b_0^2}$.

Let
$$\alpha := 1+\frac{M^2}{b_0^2},\qquad \beta := \log\!\frac{b_0^2+M^2}{b_0^2}\ge 0.$$

Then $\Lambda_T\le \alpha(\log T + \beta) \le \alpha(1+\beta)\log T$ for $T\ge e$ (since $\log T\ge 1$). For $2\le T<e$ there are only finitely many values ($T=2$), for which the bound holds by enlarging the constant (below we just absorb $\beta$ additively). To be fully explicit, for $T\ge 2$,
$$\Lambda_T \;\le\; \alpha\,\log T + \alpha\beta \;\le\; \Big(\alpha+\frac{\alpha\beta}{\log 2}\Big)\log T =: \gamma\log T,$$
where $\gamma = \alpha\Big(1+\frac{\beta}{\log 2}\Big)$.

Therefore
$$\Delta_0+\tfrac{L\eta^2}{2}\Lambda_T \;\le\; \Delta_0 + \tfrac{L\eta^2\gamma}{2}\log T \;\le\; \Big(\tfrac{\Delta_0}{\log 2}+\tfrac{L\eta^2\gamma}{2}\Big)\log T =: \delta\log T,$$
valid for $T\ge 2$ since $\log T\ge \log 2>0$.

Plugging into (D):
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f_k\|^2\right] \;\le\; \frac{b_0+M}{\eta}\cdot\delta\cdot\frac{\log T}{\sqrt{T}} \;=\; C\cdot\frac{\log T}{\sqrt{T}}. \tag{FINAL}$$

### 5.6 Explicit constant

$$\boxed{\; C \;=\; \frac{b_0+G+\sigma}{\eta}\left[\frac{\Delta_0}{\log 2}+\frac{L\eta^2}{2}\Big(1+\frac{(G+\sigma)^2}{b_0^2}\Big)\Big(1+\frac{1}{\log 2}\log\!\tfrac{b_0^2+(G+\sigma)^2}{b_0^2}\Big)\right].\;}$$

This is polynomial in $(\Delta_0, 1/\eta, \eta, b_0, 1/b_0, L, \sigma, G)$ together with a single $\log(1+(G+\sigma)^2/b_0^2)$ factor (a constant independent of $T$), which is polynomial in the stated parameters once $b_0>0$.

---

## 6. Verification of the required conclusion

We have shown for all $T\ge 2$,
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right] \;\le\; C\,\frac{\log T}{\sqrt{T}},$$
with $C$ given explicitly above. This establishes the Ward–Wu–Bottou non-convex convergence rate for AdaGrad-Norm. $\blacksquare$

---

## 7. Remarks

1. **Where the route-specific move enters.** The "Surrogate-Step-Size via $b_{k+1}$ Substitution" idea is used in Lemma 3 together with the $\|g_k\|^2\le M^2$ bound to convert $\sum \|g_k\|^2/b_k^2$ (not directly estimable by the integral test because the denominator uses $b_k$, not $b_{k+1}$) into $\sum \|g_k\|^2/b_{k+1}^2$ plus a controllable correction. Lemma 2 then finishes both pieces logarithmically.

2. **Why the cross-term is mean zero here.** The step size $\eta/b_k$ is $\mathcal{F}_k$-measurable (unlike AdaGrad-Coordinate, where one often must decouple $1/\|g_k\|$ from $g_k$). This is the single feature that makes Route 1 work cleanly under A1–A3.

3. **A.s. vs. high-probability.** Assumption (A3), $\|\nabla f_k\|\le G$ a.s., lets us bound $\|g_k\|\le M$ a.s. and $b_T\le b_0+M\sqrt{T}$ **deterministically**. No martingale high-probability argument is needed. The expectation pass-through in (C) is therefore a single deterministic multiplication.

4. **Dependence on $\eta$.** $C$ contains both $1/\eta$ and $\eta^2$; the optimum scaling for a given horizon trades these, but the $\tilde O(1/\sqrt T)$ rate holds for any fixed $\eta>0$.

5. **Dimension-free.** No $d$ appears anywhere; all inequalities are scalar.
