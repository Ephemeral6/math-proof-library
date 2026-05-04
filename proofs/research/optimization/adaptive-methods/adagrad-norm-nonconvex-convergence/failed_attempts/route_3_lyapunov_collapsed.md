# Route 3: Lyapunov Potential Proof of AdaGrad-Norm Non-Convex Convergence

**Problem.** $L$-smooth $f:\mathbb{R}^d\to\mathbb{R}$, $f^\star=\inf f>-\infty$, $\Delta_0=f(x_0)-f^\star$. Algorithm
$$b_k^2 = b_0^2+\sum_{i=0}^{k-1}\|g_i\|^2,\qquad x_{k+1}=x_k-\frac{\eta}{b_k}g_k,$$
with $\mathbb{E}[g_k\mid\mathcal{F}_k]=\nabla f(x_k)$, $\|g_k-\nabla f(x_k)\|\le\sigma$ a.s., $\|\nabla f(x_k)\|\le G$ a.s.; hence $M:=G+\sigma\ge\|g_k\|$ a.s. Goal:
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right]\le C\,\frac{\log T}{\sqrt{T}}.$$

The route assigned here is **Route 3 (Lyapunov potential)**. We will carry out the Lyapunov program honestly and flag where it collapses into the direct telescoping of Route 1.

---

## 1. Preliminaries

**1.1 Descent lemma.** Since $f$ is $L$-smooth, for all $x,y$,
$$f(y)\le f(x)+\langle\nabla f(x),y-x\rangle+\tfrac{L}{2}\|y-x\|^2.$$
Applied at $x=x_k$, $y=x_{k+1}=x_k-(\eta/b_k)g_k$:
$$f(x_{k+1})\le f(x_k)-\frac{\eta}{b_k}\langle\nabla f(x_k),g_k\rangle+\frac{L\eta^2}{2b_k^2}\|g_k\|^2.\tag{1}$$

**1.2 Measurability.** $x_k,\nabla f(x_k),b_k$ are $\mathcal{F}_k$-measurable; $g_k,b_{k+1}$ are not. The step $\eta/b_k$ is $\mathcal{F}_k$-measurable, so the cross term in (1) has conditional mean
$$\mathbb{E}\!\left[\tfrac{\eta}{b_k}\langle\nabla f(x_k),g_k\rangle\,\Big|\,\mathcal{F}_k\right]=\tfrac{\eta}{b_k}\|\nabla f(x_k)\|^2.\tag{2}$$

**1.3 A.s. bounds.** $\|g_k\|\le M$ a.s. gives $b_{k+1}^2\le b_k^2+M^2$, so $b_{k+1}/b_k\le\sqrt{1+M^2/b_0^2}=:\rho$.

**1.4 Envelope.** $b_T^2\le b_0^2+TM^2$, whence $b_T\le b_0+M\sqrt{T}$ and $\log(b_T^2/b_0^2)\le\log(1+TM^2/b_0^2)\le\log T+\log(1+M^2/b_0^2)$ for $T\ge 1$.

**1.5 Logarithmic accumulator.** For any positive $a_k$ and $B_k^2=B_0^2+\sum_{i<k}a_i^2$, since $\log$ is concave,
$$\log\frac{B_{k+1}^2}{B_k^2}=\log\!\left(1+\frac{a_k^2}{B_k^2}\right)\ge\frac{a_k^2/B_k^2}{1+a_k^2/B_k^2}=\frac{a_k^2}{B_{k+1}^2}.$$
Summing telescopes:
$$\sum_{k=0}^{T-1}\frac{a_k^2}{B_{k+1}^2}\le\log\frac{B_T^2}{B_0^2}.\tag{3}$$

**1.6 Key decoupling identity.** Since $b_{k+1}^2=b_k^2+\|g_k\|^2$,
$$\frac{1}{b_k^2}=\frac{1}{b_{k+1}^2}+\frac{\|g_k\|^2}{b_k^2\,b_{k+1}^2}.$$
Multiplying by $\|g_k\|^2$:
$$\frac{\|g_k\|^2}{b_k^2}=\frac{\|g_k\|^2}{b_{k+1}^2}+\frac{\|g_k\|^4}{b_k^2\,b_{k+1}^2}\le\frac{\|g_k\|^2}{b_{k+1}^2}\cdot\left(1+\frac{M^2}{b_0^2}\right)=\rho^2\cdot\frac{\|g_k\|^2}{b_{k+1}^2},\tag{4}$$
using $\|g_k\|^2/b_k^2\le M^2/b_0^2$ and $b_0^2\le b_k^2$.

---

## 2. The Lyapunov Potential

**Definition.** Define the $\mathcal{F}_k$-measurable potential
$$\boxed{\;V_k \;:=\; \bigl(f(x_k)-f^\star\bigr)\;+\;\frac{L\eta^2}{2}\sum_{i=0}^{k-1}\frac{\|g_i\|^2}{b_i^2}\;}\tag{5}$$
with $V_0=\Delta_0$ (empty sum).

**Properties.**
- *Non-negativity.* Both summands are $\ge 0$: $f(x_k)\ge f^\star$, and each $\|g_i\|^2/b_i^2\ge 0$. So $V_k\ge 0$.
- *$\mathcal{F}_k$-measurability.* $f(x_k)$ and $b_i,g_i$ for $i<k$ are all $\mathcal{F}_k$-measurable.
- *Monotone accumulator.* The second term is non-decreasing in $k$; all randomness in its growth is in $\|g_i\|^2$.

**Interpretation.** $V_k$ is the objective gap augmented by a running bookkeeping of the second-order noise-curvature cost. The point is that the $L$-smoothness "tax" $(L\eta^2/2)\|g_k\|^2/b_k^2$ is absorbed into the potential and exposed as a telescoped increment, rather than being reintroduced at every step.

This is formally a Lyapunov function (non-negative, $\mathcal{F}_k$-measurable, derived from the iterate state and history). We now show it decreases in expectation when corrected for the expected gradient progress.

---

## 3. One-Step Inequality

Starting from (1), add and subtract the accumulator increment:
$$V_{k+1}-V_k=\bigl(f(x_{k+1})-f(x_k)\bigr)+\frac{L\eta^2}{2}\cdot\frac{\|g_k\|^2}{b_k^2}.$$
Using (1),
$$V_{k+1}-V_k\le-\frac{\eta}{b_k}\langle\nabla f(x_k),g_k\rangle+\frac{L\eta^2}{2 b_k^2}\|g_k\|^2+\frac{L\eta^2}{2b_k^2}\|g_k\|^2 -\frac{L\eta^2}{2b_k^2}\|g_k\|^2.$$

That is, simply
$$V_{k+1}-V_k\;\le\;-\frac{\eta}{b_k}\langle\nabla f(x_k),g_k\rangle+\frac{L\eta^2}{b_k^2}\|g_k\|^2.\tag{6}$$

Take conditional expectation given $\mathcal{F}_k$; since $b_k$ and $\nabla f(x_k)$ are $\mathcal{F}_k$-measurable and $\mathbb{E}[g_k\mid\mathcal{F}_k]=\nabla f(x_k)$,
$$\mathbb{E}[V_{k+1}\mid\mathcal{F}_k]-V_k\;\le\;-\frac{\eta}{b_k}\|\nabla f(x_k)\|^2+\frac{L\eta^2}{b_k^2}\,\mathbb{E}\!\left[\|g_k\|^2\,\big|\,\mathcal{F}_k\right].\tag{7}$$

Rearranging:
$$\frac{\eta}{b_k}\|\nabla f(x_k)\|^2\;\le\;V_k-\mathbb{E}[V_{k+1}\mid\mathcal{F}_k]+\frac{L\eta^2}{b_k^2}\,\mathbb{E}\!\left[\|g_k\|^2\,\big|\,\mathcal{F}_k\right].\tag{8}$$

**Remark on the Lyapunov status.** Relation (7) is not quite a supermartingale: the drift has a *signed* gradient term $-(\eta/b_k)\|\nabla f(x_k)\|^2\le 0$ (favorable) but also a *positive* contribution $(L\eta^2/b_k^2)\mathbb{E}[\|g_k\|^2\mid\mathcal{F}_k]$. In order to close the Lyapunov argument we must *sum* this positive contribution and use the log-accumulator (3) to show its total is $O(\log T)$. This is where the Lyapunov view merges into Route 1's algebra — the "Lyapunov" does not give us an intrinsically contractive drift, but it does give a clean expectation-level telescoping identity. We will make this honest observation precise in Section 6.

---

## 4. Telescoping and Expectation Handling

**4.1 Taking total expectation in (8).** By the tower property, $\mathbb{E}[\mathbb{E}[V_{k+1}\mid\mathcal{F}_k]]=\mathbb{E}[V_{k+1}]$, so
$$\frac{\eta}{b_k}\,\|\nabla f(x_k)\|^2\text{ (deterministic given }\mathcal{F}_k\text{)}\implies\mathbb{E}\!\left[\tfrac{\eta}{b_k}\|\nabla f(x_k)\|^2\right]\le\mathbb{E}[V_k]-\mathbb{E}[V_{k+1}]+L\eta^2\,\mathbb{E}\!\left[\tfrac{\|g_k\|^2}{b_k^2}\right].$$

Summing $k=0,\dots,T-1$ telescopes the $\mathbb{E}[V_k]$ differences:
$$\eta\sum_{k=0}^{T-1}\mathbb{E}\!\left[\frac{\|\nabla f(x_k)\|^2}{b_k}\right]\;\le\;V_0-\mathbb{E}[V_T]+L\eta^2\sum_{k=0}^{T-1}\mathbb{E}\!\left[\frac{\|g_k\|^2}{b_k^2}\right].\tag{9}$$

Drop $-\mathbb{E}[V_T]\le 0$ (non-negativity) and use $V_0=\Delta_0$:
$$\eta\sum_{k=0}^{T-1}\mathbb{E}\!\left[\frac{\|\nabla f(x_k)\|^2}{b_k}\right]\;\le\;\Delta_0+L\eta^2\sum_{k=0}^{T-1}\mathbb{E}\!\left[\frac{\|g_k\|^2}{b_k^2}\right].\tag{10}$$

**Note.** The *cross-term vanishing* happened at the conditional-expectation step (line (7)): since $b_k^{-1}\nabla f(x_k)$ is $\mathcal{F}_k$-measurable, $\mathbb{E}[(1/b_k)\langle\nabla f(x_k),g_k\rangle\mid\mathcal{F}_k]=(1/b_k)\|\nabla f(x_k)\|^2$. No martingale argument for a vanishing cross-term is needed because we never split $g_k$ into signal + noise — we kept it together.

**4.2 Bounding the quadratic accumulator.** Apply decoupling (4) pathwise:
$$\sum_{k=0}^{T-1}\frac{\|g_k\|^2}{b_k^2}\le\rho^2\sum_{k=0}^{T-1}\frac{\|g_k\|^2}{b_{k+1}^2}\stackrel{(3)}{\le}\rho^2\,\log\!\frac{b_T^2}{b_0^2},\qquad \rho^2=1+\frac{M^2}{b_0^2}.$$
Taking expectation and using the envelope of §1.4 (pathwise $b_T^2\le b_0^2+TM^2$),
$$\sum_{k=0}^{T-1}\mathbb{E}\!\left[\frac{\|g_k\|^2}{b_k^2}\right]\;\le\;\rho^2\,\mathbb{E}\!\left[\log\!\frac{b_T^2}{b_0^2}\right]\;\le\;\rho^2\,\log\!\left(1+\frac{TM^2}{b_0^2}\right).\tag{11}$$

Substituting into (10):
$$\eta\sum_{k=0}^{T-1}\mathbb{E}\!\left[\frac{\|\nabla f(x_k)\|^2}{b_k}\right]\;\le\;\Delta_0+L\eta^2\rho^2\,\log\!\left(1+\frac{TM^2}{b_0^2}\right).\tag{12}$$

**4.3 From $\sum\|\nabla f\|^2/b_k$ to $\sum\|\nabla f\|^2$.** Pathwise $b_k\le b_T$, so $1/b_k\ge 1/b_T$:
$$\sum_{k=0}^{T-1}\frac{\|\nabla f(x_k)\|^2}{b_k}\;\ge\;\frac{1}{b_T}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2.$$

Multiplying both sides of (12) by $1/\eta$ and using this,
$$\mathbb{E}\!\left[\frac{1}{b_T}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\right]\;\le\;\frac{\Delta_0}{\eta}+L\eta\rho^2\,\log\!\left(1+\frac{TM^2}{b_0^2}\right).\tag{13}$$

---

## 5. Final Rate Extraction

**5.1 Cauchy–Schwarz de-pairing.** We have
$$\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2=\left(\frac{1}{b_T}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\right)\cdot b_T.$$
By Cauchy–Schwarz (for non-negative r.v.'s $X=(1/b_T)\sum\|\nabla f\|^2\ge 0$ and $Y=b_T\ge b_0>0$):
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\right]=\mathbb{E}[XY]\le\sqrt{\mathbb{E}[X^2]\,\mathbb{E}[Y^2]}.$$
This path is loose. Use the simpler bound from (13) combined with the envelope $b_T\le b_0+M\sqrt{T}$: *without* Cauchy–Schwarz, bound $\mathbb{E}[XY]$ via
$$\mathbb{E}[X\cdot b_T]\le(b_0+M\sqrt{T})\,\mathbb{E}[X]\qquad\text{??}$$
This is wrong unless we have a high-probability bound on $b_T$. Instead use the direct relation: since $b_T\le b_0+M\sqrt{T}$ pathwise a.s.,
$$\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\le b_T\cdot\frac{1}{b_T}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\le(b_0+M\sqrt{T})\cdot\frac{1}{b_T}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2.$$
The right factor is not bounded above in terms of the other one, but we will use:
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\right]\le\mathbb{E}\!\left[(b_0+M\sqrt{T})\cdot\frac{1}{b_T}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\right]=(b_0+M\sqrt{T})\,\mathbb{E}\!\left[\frac{1}{b_T}\sum_k\|\nabla f(x_k)\|^2\right],\tag{14}$$
valid because $b_0+M\sqrt{T}$ is **deterministic** and $b_T\le b_0+M\sqrt{T}$ a.s. — the inequality $A\cdot\frac{S}{A}\ge \frac{S}{b_T}\cdot b_T=S$ is tautological; the key fact used is $b_T\le b_0+M\sqrt{T}$ a.s. so $S\le (b_0+M\sqrt{T})\cdot S/b_T$.

Combining (13) with (14):
$$\mathbb{E}\!\left[\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2\right]\;\le\;(b_0+M\sqrt{T})\left[\frac{\Delta_0}{\eta}+L\eta\rho^2\,\log\!\left(1+\frac{TM^2}{b_0^2}\right)\right].\tag{15}$$

**5.2 Conclusion.** Since $\min_k\|\nabla f(x_k)\|^2\le(1/T)\sum_k\|\nabla f(x_k)\|^2$,
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right]\;\le\;\frac{b_0+M\sqrt{T}}{T}\left[\frac{\Delta_0}{\eta}+L\eta\rho^2\,\log\!\left(1+\frac{TM^2}{b_0^2}\right)\right].\tag{16}$$

For $T\ge 2$, $(b_0+M\sqrt{T})/T\le(b_0+M)/\sqrt{T}$, and $\log(1+TM^2/b_0^2)\le\log T+\log(1+M^2/b_0^2)\le 2\log T$ when $T\ge (1+M^2/b_0^2)$. Hence
$$\boxed{\;\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right]\;\le\;C\,\frac{\log T}{\sqrt{T}}\;}$$
with
$$C\;=\;(b_0+M)\left(\frac{\Delta_0}{\eta}+2L\eta\rho^2\right),\qquad M=G+\sigma,\quad\rho^2=1+\tfrac{M^2}{b_0^2},\tag{17}$$
for all $T\ge\max\{2,1+M^2/b_0^2\}$. This is polynomial in $L,\eta,b_0,\sigma,G,\Delta_0$, as required.

$\blacksquare$

---

## 6. Honest Assessment of the Lyapunov Interpretation

**Does Route 3 give a genuinely new angle?**

The Lyapunov $V_k = (f(x_k)-f^\star)+\frac{L\eta^2}{2}\sum_{i<k}\|g_i\|^2/b_i^2$ does yield a clean non-negative $\mathcal{F}_k$-measurable potential whose one-step drift (7)–(8) packages the descent lemma into the form
$$\mathbb{E}[V_{k+1}\mid\mathcal{F}_k]-V_k\;\le\;-\frac{\eta}{b_k}\|\nabla f(x_k)\|^2+\frac{L\eta^2}{b_k^2}\,\mathbb{E}\!\left[\|g_k\|^2\,\big|\,\mathcal{F}_k\right].$$

However, the drift is **not** negative without a separate log-accumulator argument on the residual positive term $L\eta^2\|g_k\|^2/b_k^2$. In other words, the potential does not turn AdaGrad-Norm into a supermartingale: the positive noise-curvature term survives and must be bounded by the logarithmic identity (3) — which is precisely the same identity used by Route 1.

**Collapse to Route 1.** Inequality (10) is *algebraically identical* to what Route 1 derives directly from (1) by summing and taking expectations. The Lyapunov $V_k$ merely moves the $L\eta^2/(2b_k^2)\|g_k\|^2$ term from "the RHS of the descent lemma" into "the accumulator part of the potential", but this is a notational rearrangement: when we expand $V_T-V_0$ and use its non-negativity, we recover exactly the descent-plus-log bound of Route 1.

The honest conclusion is that **Route 3's Lyapunov interpretation is real (the function $V_k$ is a genuine non-negative $\mathcal{F}_k$-measurable potential with a decomposition into a decreasing drift plus a summable positive residual), but it does not provide a fundamentally different proof technique**: the critical analytical step — the logarithmic accumulator (3) — is the same in both routes, and the final rate extraction (§5) is Route 1's b_T-envelope argument. This is the kind of Lyapunov coinciding with direct telescoping that the problem anticipated. The value added by Route 3 is *conceptual*: it shows that AdaGrad-Norm's analysis can be organized around a single monotone potential rather than two separate book-keeping sums.

**What would a genuinely different Lyapunov look like?** A truly distinct Lyapunov would need to (i) have strictly negative expected drift without relying on an external log bound, or (ii) produce a contraction factor $<1$ that yields convergence without the $\sum\|g_k\|^2/b_{k+1}^2$ identity. Attempts in that direction — $\Psi_k=(f(x_k)-f^\star)/b_k$, $\Psi_k=(f(x_k)-f^\star)b_k$, $\Psi_k=f(x_k)-f^\star+A\log(b_k^2/b_0^2)$ — all either fail to close (the log-concavity bound $\log(1+x)\le x$ reintroduces the same $\|g_k\|^2/b_k^2$ term one is trying to avoid) or produce potentials that can go negative (violating the non-negativity needed for the $-\mathbb{E}[V_T]\le 0$ drop). So the Lyapunov (5) used here is in fact the "right" one — it is the minimal potential that makes the proof work, and its closure through the log-accumulator is unavoidable for this algorithm.

**Summary.** Route 3 as presented is a valid Lyapunov proof that achieves the target rate $O(\log T/\sqrt{T})$, with all constants explicit in (17). The Lyapunov is well-defined, non-negative, and $\mathcal{F}_k$-adapted, and the one-step inequality (7) is genuine. The proof reduces to Route 1's core algebra at the final telescoping step; this is reported honestly rather than disguised.
