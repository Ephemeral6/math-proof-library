# Proof Report: AdaGrad-Norm Non-Convex Convergence (Ward-Wu-Bottou 2019)

## 1. Problem Statement

**Setup.** Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth and bounded below by $f^\star$, with $\Delta_0 := f(x_0) - f^\star$. The AdaGrad-Norm algorithm fixes $\eta > 0$, $b_0 > 0$, and iterates:
$$b_k^2 = b_0^2 + \sum_{i=0}^{k-1} \|g_i\|^2, \qquad x_{k+1} = x_k - \frac{\eta}{b_k}\, g_k,$$
where $g_k$ is a stochastic gradient at $x_k$.

**Assumptions.** (A1) Unbiasedness: $\mathbb{E}[g_k \mid \mathcal{F}_k] = \nabla f(x_k)$. (A2) Bounded noise: $\|g_k - \nabla f(x_k)\| \le \sigma$ a.s. (A3) Bounded true gradient: $\|\nabla f(x_k)\| \le G$ a.s. along the trajectory.

**Claim.** There exists an explicit constant $C = C(L, \eta, b_0, \sigma, G, \Delta_0)$ such that for all $T \ge 2$,
$$\mathbb{E}\!\left[\min_{0 \le k < T} \|\nabla f(x_k)\|^2\right] \le C \cdot \frac{\log T}{\sqrt{T}}.$$

---

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed |
| Explorer | Opus | 4 proofs attempted; Routes 1 and 2 fully succeeded, Route 3 collapsed honestly (reduces to Route 1 algebra), Route 4 partially succeeded (regret lemma proved; online-to-batch bridge fails for non-convex $f$) |
| Judge | Sonnet | Route 1 selected, score 38/40 (tie with Route 2 broken by cleaner proof text) |
| Audit | Opus | PASS in 1 round (17/17 VALID, 5/5 numerical checks passed, all issues LOW severity) |
| Fix | — | Not needed (no HIGH or MEDIUM issues) |

---

## 3. Proof Routes Explored

**Route 1 — Surrogate Step-Size via $b_{k+1}$ Substitution (38/40, WINNER)**
The canonical Ward-Wu-Bottou argument. Uses the algebraic identity $1/b_k^2 - 1/b_{k+1}^2 = \|g_k\|^2/(b_k^2 b_{k+1}^2)$ (Lemma 3) to convert the quadratic accumulator $\sum \|g_k\|^2/b_k^2$ into $\sum \|g_k\|^2/b_{k+1}^2$ plus a controlled correction, then applies the logarithmic integral-test bound (Lemma 2) to both pieces. The cross-term $\langle \nabla f_k, \xi_k \rangle / b_k$ vanishes in expectation because $b_k \in \mathcal{F}_k$ and $\mathbb{E}[\xi_k \mid \mathcal{F}_k] = 0$. Final assembly uses the deterministic envelope $b_T \le b_0 + M\sqrt{T}$. All steps complete and correct; explicit constant derived.

**Route 2 — Direct a.s. Bound + Ratio Lemma (38/40)**
An independent route that avoids the decoupling identity. Instead, it uses the a.s. bound $\|g_k\| \le M$ to replace the stochastic quadratic by a deterministic one, and applies a ratio lemma ($b_{k+1}^2/b_k^2 \le 1 + M^2/b_0^2$) to convert $\sum \|g_k\|^2/b_k^2$ via the log-accumulator. Equally rigorous; selected against due to a vestigial Cauchy-Schwarz fragment in the proof text.

**Route 3 — Lyapunov Potential (31/40)**
Defined $V_k = (f(x_k) - f^\star) + \frac{L\eta^2}{2}\sum_{i<k}\|g_i\|^2/b_i^2$ and derived a one-step drift inequality. The proof is complete but (i) the underlying algebra reduces to Route 1's descent-lemma telescoping, (ii) the final constant in the $O(\log T / \sqrt{T})$ bound requires $T \ge 1 + M^2/b_0^2$ (not unconditional $T \ge 2$), and (iii) the Lyapunov framework collapses honestly — the Explorer explicitly flagged this.

**Route 4 — Online-to-Batch via Regret Framework (21/40)**
Established the AdaGrad regret bound (Lemma 1) and the log-accumulator as a sub-lemma. However, the online-to-batch bridge from regret to non-convex convergence fails for general non-convex $f$ (requires convexity or quasi-convexity). The fallback closure in §4 produces a constant dominant term rather than $O(\log T/\sqrt{T})$. The route explicitly defers to Route 1 for the main conclusion. Serves as a useful library lemma for the AdaGrad regret bound.

---

## 4. Final Proof

# Proof of AdaGrad-Norm Non-Convex Convergence — Route 1 (Surrogate Step-Size via $b_{k+1}$ Substitution)

**Theorem.** Under assumptions (A1)–(A3), the iterates of AdaGrad-Norm
$$x_{k+1} = x_k - \frac{\eta}{b_k}\, g_k, \qquad b_k^2 = b_0^2 + \sum_{i=0}^{k-1}\|g_i\|^2,$$
satisfy, for every $T\ge 2$,
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right] \;\le\; C\,\frac{\log T}{\sqrt{T}},$$
for an explicit constant $C = C(\Delta_0,\eta,b_0,L,\sigma,G)$ polynomial in its arguments.

---

### 1. Preliminaries

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

### 2. Lemma 1 (Adaptive Descent Lemma)

**Statement.** For every $k\ge 0$,
$$f(x_{k+1}) \;\le\; f(x_k) \;-\; \frac{\eta}{b_k}\langle \nabla f_k, g_k\rangle \;+\; \frac{L\eta^2}{2\, b_k^2}\,\|g_k\|^2.$$

**Proof.** $L$-smoothness yields the descent inequality
$$f(y) \;\le\; f(x) + \langle \nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2,\qquad \forall x,y\in\mathbb{R}^d. \tag{DL}$$

Apply (DL) with $x=x_k$, $y=x_{k+1}=x_k-\frac{\eta}{b_k} g_k$:
$$f(x_{k+1}) \le f(x_k) + \left\langle \nabla f_k,\, -\tfrac{\eta}{b_k} g_k\right\rangle + \frac{L}{2}\left\|\tfrac{\eta}{b_k} g_k\right\|^2$$
$$= f(x_k) - \frac{\eta}{b_k}\langle \nabla f_k, g_k\rangle + \frac{L\eta^2}{2b_k^2}\|g_k\|^2.\qquad\square$$

---

### 3. Lemma 2 (Log Accumulator)

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

### 4. Lemma 3 (Decoupling Identity)

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

### 5. Main Argument

#### 5.1 Split the cross-term

By (A1), $\mathbb{E}[g_k\mid\mathcal{F}_k]=\nabla f_k$. Decompose $g_k = \nabla f_k + \xi_k$ where $\xi_k:=g_k-\nabla f_k$ satisfies $\mathbb{E}[\xi_k\mid\mathcal{F}_k]=0$ and $\|\xi_k\|\le\sigma$ a.s. Then
$$\langle \nabla f_k, g_k\rangle \;=\; \|\nabla f_k\|^2 + \langle \nabla f_k,\xi_k\rangle.$$

Substituting into Lemma 1 and rearranging,
$$\frac{\eta}{b_k}\|\nabla f_k\|^2 \;\le\; \big(f(x_k)-f(x_{k+1})\big) \;-\; \frac{\eta}{b_k}\langle \nabla f_k,\xi_k\rangle \;+\; \frac{L\eta^2}{2 b_k^2}\|g_k\|^2. \tag{$*$}$$

#### 5.2 Telescope and take expectation

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

#### 5.3 Pass from $1/b_k$ to $1/b_T$ (and then to $1/(b_0+M\sqrt{T})$)

Since $b_k$ is monotone non-decreasing in $k$, $b_k\le b_T$ a.s., hence $1/b_k\ge 1/b_T$ a.s. Therefore
$$\sum_{k=0}^{T-1}\|\nabla f_k\|^2 \;=\; \sum_{k=0}^{T-1} b_k\cdot\frac{\|\nabla f_k\|^2}{b_k} \;\le\; b_T\sum_{k=0}^{T-1}\frac{\|\nabla f_k\|^2}{b_k}. \tag{B}$$

*Finiteness check.* $\sum_{k=0}^{T-1}\|\nabla f_k\|^2/b_k \le \sum_k G^2/b_0 = TG^2/b_0 < \infty$ a.s., so its expectation is finite and multiplication by the a.s. bound $b_T\le b_0+M\sqrt{T}$ passes through expectation:
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f_k\|^2\right] \;\le\; (b_0+M\sqrt{T})\;\mathbb{E}\!\left[\sum_{k=0}^{T-1}\frac{\|\nabla f_k\|^2}{b_k}\right]. \tag{C}$$

#### 5.4 Final rate

Plug (A) into (C):
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f_k\|^2\right] \;\le\; \frac{b_0+M\sqrt{T}}{\eta}\Big(\Delta_0 + \tfrac{L\eta^2}{2}\Lambda_T\Big).$$

The minimum over $k$ is at most the average:
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f_k\|^2\right] \;\le\; \frac{1}{T}\,\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f_k\|^2\right] \;\le\; \frac{b_0+M\sqrt{T}}{\eta\, T}\Big(\Delta_0+\tfrac{L\eta^2}{2}\Lambda_T\Big). \tag{D}$$

#### 5.5 Extracting the $\log T/\sqrt{T}$ shape

Write the RHS of (D) as $\Big(\frac{b_0}{\eta T}+\frac{M}{\eta\sqrt{T}}\Big)\big(\Delta_0+\tfrac{L\eta^2}{2}\Lambda_T\big)$.

For $T\ge 2$, $\frac{1}{T}\le\frac{1}{\sqrt{T}}$, so $\frac{b_0}{\eta T}+\frac{M}{\eta\sqrt{T}}\le \frac{b_0+M}{\eta\sqrt{T}}$. Also,
$$\Lambda_T = \Big(1+\frac{M^2}{b_0^2}\Big)\log\!\frac{b_0^2+TM^2}{b_0^2} \;\le\; \Big(1+\frac{M^2}{b_0^2}\Big)\Big(\log T + \log\!\frac{b_0^2+M^2}{b_0^2}\Big),$$
because for $T\ge 1$, $b_0^2+TM^2 \le T(b_0^2+M^2)$, hence $\log\frac{b_0^2+TM^2}{b_0^2}\le \log T + \log\frac{b_0^2+M^2}{b_0^2}$.

Let
$$\alpha := 1+\frac{M^2}{b_0^2},\qquad \beta := \log\!\frac{b_0^2+M^2}{b_0^2}\ge 0.$$

Then for $T\ge 2$,
$$\Lambda_T \;\le\; \alpha\,\log T + \alpha\beta \;\le\; \Big(\alpha+\frac{\alpha\beta}{\log 2}\Big)\log T =: \gamma\log T,$$
where $\gamma = \alpha\Big(1+\frac{\beta}{\log 2}\Big)$. (At $T=2$: $\gamma\log 2 = \alpha\log 2 + \alpha\beta \ge \Lambda_2$, so the inequality is tight at the boundary.)

Therefore
$$\Delta_0+\tfrac{L\eta^2}{2}\Lambda_T \;\le\; \Delta_0 + \tfrac{L\eta^2\gamma}{2}\log T \;\le\; \Big(\tfrac{\Delta_0}{\log 2}+\tfrac{L\eta^2\gamma}{2}\Big)\log T =: \delta\log T,$$
valid for $T\ge 2$ since $\log T\ge \log 2>0$.

Plugging into (D):
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f_k\|^2\right] \;\le\; \frac{b_0+M}{\eta}\cdot\delta\cdot\frac{\log T}{\sqrt{T}} \;=\; C\cdot\frac{\log T}{\sqrt{T}}. \tag{FINAL}$$

#### 5.6 Explicit constant

$$\boxed{\; C \;=\; \frac{b_0+G+\sigma}{\eta}\left[\frac{\Delta_0}{\log 2}+\frac{L\eta^2}{2}\Big(1+\frac{(G+\sigma)^2}{b_0^2}\Big)\Big(1+\frac{1}{\log 2}\log\!\tfrac{b_0^2+(G+\sigma)^2}{b_0^2}\Big)\right].\;}$$

This is polynomial in $(\Delta_0, 1/\eta, \eta, b_0, 1/b_0, L, \sigma, G)$ together with a single $\log(1+(G+\sigma)^2/b_0^2)$ factor (a $T$-independent constant). Since $\log(1+y)\le y$ for $y\ge 0$, one may further upper-bound the $\log$ factor by $(G+\sigma)^2/b_0^2$ to obtain a strictly polynomial constant.

---

### 6. Verification of the required conclusion

We have shown for all $T\ge 2$,
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right] \;\le\; C\,\frac{\log T}{\sqrt{T}},$$
with $C$ given explicitly above. This establishes the Ward–Wu–Bottou non-convex convergence rate for AdaGrad-Norm. $\blacksquare$

---

### 7. Remarks

1. **Where the route-specific move enters.** The "Surrogate-Step-Size via $b_{k+1}$ Substitution" idea is used in Lemma 3 together with the $\|g_k\|^2\le M^2$ bound to convert $\sum \|g_k\|^2/b_k^2$ (not directly estimable by the integral test because the denominator uses $b_k$, not $b_{k+1}$) into $\sum \|g_k\|^2/b_{k+1}^2$ plus a controllable correction. Lemma 2 then finishes both pieces logarithmically.

2. **Why the cross-term is mean zero here.** The step size $\eta/b_k$ is $\mathcal{F}_k$-measurable (unlike AdaGrad-Coordinate, where one often must decouple $1/\|g_k\|$ from $g_k$). This is the single feature that makes Route 1 work cleanly under A1–A3.

3. **A.s. bounds.** Assumption (A3), $\|\nabla f_k\|\le G$ a.s., lets us bound $\|g_k\|\le M$ a.s. and $b_T\le b_0+M\sqrt{T}$ pathwise on a full-probability event. The expectation pass-through in (C) is therefore a single deterministic multiplication.

4. **Dependence on $\eta$.** $C$ contains both $1/\eta$ and $\eta^2$; the optimum scaling for a given horizon trades these, but the $\tilde O(1/\sqrt T)$ rate holds for any fixed $\eta>0$.

5. **Dimension-free.** No $d$ appears anywhere; all inequalities are scalar.

---

## 5. Audit Result

**Verdict: PASS** (1 round, no revision needed).

**Step validity table: 17/17 VALID, 0 INVALID.**

All major components audited:
- §1 Preliminaries (measurability of $b_k$, $x_k$; a.s. norm bound; envelope (Env)): VALID
- §2 Lemma 1 (Descent): VALID — (DL) follows from $L$-smoothness; substitution is pure algebra
- §3 Lemma 2 (Log accumulator): VALID — integral comparison $\int du/u \ge \Delta u / u_{\max}$; degenerate $a_k=0$ case handled automatically
- §4 Lemma 3 (Decoupling identity): VALID (machine-precision exact, V2); correction bound valid under $\|g_k\|\le M$, $b_k\ge b_0$; (QT) bound VALID
- §5.1–5.2 Cross-term split, telescope, expectation: VALID — tower property applied with $|\langle\nabla f_k,\xi_k\rangle/b_k|\le G\sigma/b_0$ integrability check
- §5.3 Monotone envelope factoring: VALID — finiteness of $\mathbb{E}[\sum\|\nabla f_k\|^2/b_k]$ confirmed ($\le TG^2/b_0$)
- §5.4–5.5 Rate extraction, $T=2$ case: VALID — case split at $T=e$ verified exactly at $T=2$
- §5.6 Boxed constant: VALID — full constant trace through $\alpha, \beta, \gamma, \delta, C$

**Numerical verifications (5/5 PASS):**
- V1: Log accumulator, $T=500$: LHS $= 5.691$, RHS $= 6.480$ (PASS)
- V2: Decoupling identity: max deviation $= 1.11 \times 10^{-16}$ (machine-precision, PASS)
- V3: (QT) bound, $T=1000$/$T=10000$: LHS $\ll$ RHS (PASS)
- V4: Envelope (Env), $T=1000$: $b_T=34.11 \le b_0+M\sqrt T = 48.43$ (PASS)
- V5: Empirical rate on $f(x)=x^2/2$: bound holds for all tested $T\ge 8$; empirical decay much faster than $\log T/\sqrt T$ (consistent with strongly convex setting, PASS)

**Issues found (all LOW severity, no mathematical errors):**
1. "Deterministic a.s." phrasing in §4 — strictly should say "pathwise a.s." [phrasing fix]
2. Library cross-reference in §2 is redundant (inline proof given) [redundancy fix]
3. $T=2$ case at §5.5 — auditor verified $\gamma\log 2 = \alpha\log 2 + \alpha\beta$, tight by definition [clarification]
4. Boxed $C$ contains $\log(1+M^2/b_0^2)$; addressed by $\log(1+y)\le y$ upper bound [explicit note]
5. Finiteness of $\mathbb{E}[X]$ in §5.3 — auditor confirmed $\le TG^2/b_0 < \infty$ [one-line addition]
6. "Cauchy–Schwarz" label in §5.3 is incorrect (step is monotonicity of expectation) [label fix]

---

## 6. Fix History

No fixes needed. All issues are LOW severity (phrasing and clarity). No mathematical revision was required.

---

## 7. Final Rate

$$\mathbb{E}\!\left[\min_{0 \le k < T} \|\nabla f(x_k)\|^2\right] \;\le\; C \cdot \frac{\log T}{\sqrt{T}},$$
where
$$C \;=\; \frac{b_0+G+\sigma}{\eta}\left[\frac{\Delta_0}{\log 2}+\frac{L\eta^2}{2}\Big(1+\frac{(G+\sigma)^2}{b_0^2}\Big)\Big(1+\frac{1}{\log 2}\log\!\frac{b_0^2+(G+\sigma)^2}{b_0^2}\Big)\right].$$

This constant is polynomial in $(\Delta_0, 1/\eta, \eta, b_0, 1/b_0, L, \sigma, G)$ up to a single $T$-independent $\log(1+(G+\sigma)^2/b_0^2)$ factor, which can be further bounded by $(G+\sigma)^2/b_0^2$ to give a strictly polynomial constant.
