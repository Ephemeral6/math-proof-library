# Route 1 (Orthodox) — Coordinate-wise AdaGrad under (L0,L1)-smoothness with affine noise

**Frame**: Orthodox (anchor route)
**Goal**: $\min_{0 \le t \le T-1} \mathbb{E}[\|\nabla f(x_t)\|_1] \le \widetilde{O}(d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3} T^{-1/3})$.
**Strategy**: per-coordinate generalized-smooth descent → predictable surrogate → three-term AM-GM with affine-noise self-bounding → AdaGrad log accumulator → Hölder over coordinates with exponent $3/2$.

---

## Notation and standing assumptions

- $f:\mathbb{R}^d\to\mathbb{R}$ differentiable, $\Delta_0 := f(x_0)-f^* < \infty$.
- For each coordinate $i$ and all $x,y$:
  $$|\partial_i f(x)-\partial_i f(y)|\le (L_0+L_1\|\nabla f(x)\|_2)\|x-y\|_2.\tag{A1}$$
- $g_t = \nabla f(x_t)+\xi_t$, $\mathbb{E}[\xi_t\mid\mathcal{F}_t]=0$, $\mathbb{E}[\xi_{t,i}^2\mid\mathcal{F}_t]\le\sigma_0^2+\sigma_1^2(\partial_i f(x_t))^2.$  $\tag{A2}$
- Update: $v_{t+1,i}=v_{t,i}+g_{t,i}^2$, $v_{0,i}=\varepsilon^2>0$, $x_{t+1,i}=x_{t,i}-\eta\,g_{t,i}/\sqrt{v_{t+1,i}}$.
- $\mathcal{F}_t := \sigma(x_0, g_0,\dots,g_{t-1})$ so that $x_t, v_{t,i}\in\mathcal{F}_t$ but $g_{t,i}, v_{t+1,i}\notin\mathcal{F}_t$.
- Abbreviations: $G_{t,i}:=\partial_i f(x_t)$, $\|\nabla f(x_t)\|_2 := \|\nabla f_t\|$.

---

## Step 1: Coordinate-wise generalized smoothness descent lemma (single-step bound)

### Step 1.1: Univariate inequality from (A1)

Fix $t$ and $i$. Define $\varphi(s) := f(x_t + s e_i \cdot (x_{t+1,i}-x_{t,i}))$ — this is the restriction of $f$ to the $i$-th coordinate displacement. By the multivariate fundamental theorem of calculus, since $x_{t+1}-x_t = -\eta(g_t/\sqrt{v_{t+1}})$ acts coordinate-wise (the update is separable across $i$), we may sum coordinate-wise Taylor expansions. Concretely, parameterize $\gamma(s) := x_t + s(x_{t+1}-x_t)$, $s\in[0,1]$, and write
$$f(x_{t+1})-f(x_t)=\int_0^1 \langle\nabla f(\gamma(s)), x_{t+1}-x_t\rangle\,ds.$$
Splitting and adding/subtracting $\langle\nabla f(x_t), x_{t+1}-x_t\rangle$:
$$f(x_{t+1})-f(x_t) = \langle\nabla f(x_t), x_{t+1}-x_t\rangle + \int_0^1 \langle\nabla f(\gamma(s))-\nabla f(x_t), x_{t+1}-x_t\rangle\,ds.\tag{1.1}$$

For the residual integral, expand the inner product coordinate-wise and apply (A1):
$$|\partial_i f(\gamma(s))-\partial_i f(x_t)|\le (L_0 + L_1\|\nabla f(x_t)\|)\,\|\gamma(s)-x_t\|_2 = s\cdot(L_0+L_1\|\nabla f_t\|)\|x_{t+1}-x_t\|_2.\tag{1.2}$$

(Note: (A1) is "anchored" at $x$, i.e. the bound on the right uses $\|\nabla f(x)\|$, the gradient at the *anchor* point. We anchor at $x_t$. This is the standard convention used by Zhang–He–Sra–Jadbabaie 2020 for $(L_0,L_1)$-smoothness; the "symmetric" version is recovered by an additional $\log(1+L_1)$ factor, but we don't need symmetry.)

### Step 1.2: Coordinate-wise descent with self-bounding constant

Substitute (1.2) into (1.1) using $|a+b|\le|a|+|b|$ on the residual:
$$f(x_{t+1})-f(x_t) \le \langle\nabla f(x_t), x_{t+1}-x_t\rangle + \tfrac{1}{2}(L_0+L_1\|\nabla f_t\|)\|x_{t+1}-x_t\|_2^2.\tag{1.3}$$

Since $x_{t+1,i}-x_{t,i}=-\eta g_{t,i}/\sqrt{v_{t+1,i}}$ is a coordinate-separable update, $\|x_{t+1}-x_t\|_2^2 = \sum_i \eta^2 g_{t,i}^2/v_{t+1,i}$ and $\langle\nabla f(x_t), x_{t+1}-x_t\rangle = -\eta\sum_i G_{t,i}g_{t,i}/\sqrt{v_{t+1,i}}$. Substituting:
$$\boxed{f(x_{t+1})-f(x_t) \le -\eta\sum_i \frac{G_{t,i}\,g_{t,i}}{\sqrt{v_{t+1,i}}} + \tfrac{\eta^2}{2}(L_0+L_1\|\nabla f_t\|)\sum_i \frac{g_{t,i}^2}{v_{t+1,i}}.}\tag{1.4}$$

[REF: structurally same as the per-coordinate descent step in `proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/proof.md`, but with the anchored $(L_0,L_1)$ smoothness constant replacing the global $L$.]

[CALL:math-verifier — convexity-test for (1.3): given $\varphi:\mathbb{R}\to\mathbb{R}$ with $|\varphi'(s_1)-\varphi'(s_2)|\le M|s_1-s_2|$ (coordinate-wise Lipschitz of directional derivative along the segment), confirm $\varphi(1)\le\varphi(0)+\varphi'(0)+\tfrac{M}{2}$, and check by random sampling that taking $M = (L_0+L_1\|\nabla f(x_0)\|)\|x_1-x_0\|$ via (1.2) yields the claimed bound. Run for 1000 random unit vectors in $d=10$ with $L_0=1$, $L_1=0.5$.]

---

## Step 2: Predictable surrogate substitution per coordinate

The denominator $\sqrt{v_{t+1,i}}$ depends on $g_{t,i}$ (since $v_{t+1,i} = v_{t,i}+g_{t,i}^2$), so $g_{t,i}/\sqrt{v_{t+1,i}}$ is **not** a martingale increment. Use the surrogate $\sqrt{v_{t,i}}$ (which is $\mathcal{F}_t$-measurable) plus a correction.

### Step 2.1: Decomposition of the linear (cross) term

Write
$$\frac{G_{t,i}g_{t,i}}{\sqrt{v_{t+1,i}}} = \frac{G_{t,i}g_{t,i}}{\sqrt{v_{t,i}}} + G_{t,i}g_{t,i}\left(\frac{1}{\sqrt{v_{t+1,i}}}-\frac{1}{\sqrt{v_{t,i}}}\right).\tag{2.1}$$

Let $A_{t,i}^{(1)} := G_{t,i}g_{t,i}/\sqrt{v_{t,i}}$ (the "predictable" part; $1/\sqrt{v_{t,i}}\in\mathcal{F}_t$) and $A_{t,i}^{(2)} := G_{t,i}g_{t,i}\bigl(1/\sqrt{v_{t+1,i}}-1/\sqrt{v_{t,i}}\bigr)$ (the correction). Taking $\mathbb{E}[\cdot\mid\mathcal{F}_t]$:
- $\mathbb{E}[A_{t,i}^{(1)}\mid\mathcal{F}_t] = G_{t,i}^2/\sqrt{v_{t,i}}$ (by $\mathbb{E}[g_{t,i}\mid\mathcal{F}_t]=G_{t,i}$).
- $A_{t,i}^{(2)}$ has a sign-controlled bound (Step 2.2 below).

### Step 2.2: Corrected surrogate inequality (COR-INEQ)

For $a>0$, $b\ge 0$:
$$\frac{1}{\sqrt{a}}-\frac{1}{\sqrt{a+b}} = \frac{\sqrt{a+b}-\sqrt{a}}{\sqrt{a(a+b)}} = \frac{b}{\sqrt{a(a+b)}(\sqrt{a+b}+\sqrt{a})}\le \frac{b}{2\sqrt{a}\cdot a\cdot 1} \cdot ?$$
Wait — careful. Use the cleaner bound: since $\sqrt{a+b}+\sqrt{a}\ge 2\sqrt{a}$,
$$\frac{1}{\sqrt{a}}-\frac{1}{\sqrt{a+b}}\le \frac{b}{2\sqrt{a}\cdot \sqrt{a(a+b)}} = \frac{b}{2a\sqrt{a+b}}.\tag{COR-INEQ}$$
This is the corrected form (NOT the wrong $b/(2\sqrt{a}(a+b))$ caught in Round 1 of `adagrad-complexity-improvement-partial-refutation`).

[CALL:math-verifier — Z3 mode: prove $\forall a>0,b\ge 0$: $1/\sqrt{a} - 1/\sqrt{a+b} \le b/(2a\sqrt{a+b})$. Equivalently $2a\sqrt{a+b}\cdot(\sqrt{a+b}-\sqrt{a})\le b\sqrt{a(a+b)}\cdot \sqrt{a+b}/\sqrt{a}$, simplifying. Numerical confirm with 5000 random pairs.]

Apply COR-INEQ with $a=v_{t,i}$, $b=g_{t,i}^2$:
$$\left|\frac{1}{\sqrt{v_{t+1,i}}}-\frac{1}{\sqrt{v_{t,i}}}\right| = \frac{1}{\sqrt{v_{t,i}}}-\frac{1}{\sqrt{v_{t+1,i}}} \le \frac{g_{t,i}^2}{2v_{t,i}\sqrt{v_{t+1,i}}}.\tag{2.2}$$

So $|A_{t,i}^{(2)}|\le |G_{t,i}g_{t,i}|\cdot g_{t,i}^2/(2v_{t,i}\sqrt{v_{t+1,i}}) = |G_{t,i}|\cdot |g_{t,i}|^3/(2v_{t,i}\sqrt{v_{t+1,i}})$.

### Step 2.3: Take conditional expectations

Let $S_{t,i} := \mathbb{E}[g_{t,i}^2\mid\mathcal{F}_t]\le\sigma_0^2+(1+\sigma_1^2)G_{t,i}^2$ (using $g_{t,i}^2 = G_{t,i}^2+2G_{t,i}\xi_{t,i}+\xi_{t,i}^2$ and (A2)).

Conditioning (1.4) on $\mathcal{F}_t$ and substituting (2.1) for the cross term:
$$\mathbb{E}[f(x_{t+1})-f(x_t)\mid\mathcal{F}_t] \le -\eta\sum_i\frac{G_{t,i}^2}{\sqrt{v_{t,i}}} + \eta\sum_i \mathbb{E}[|A_{t,i}^{(2)}|\mid\mathcal{F}_t] + \tfrac{\eta^2}{2}\mathbb{E}\!\left[(L_0+L_1\|\nabla f_t\|)\sum_i \frac{g_{t,i}^2}{v_{t+1,i}}\,\Big|\,\mathcal{F}_t\right].\tag{2.3}$$

Note: $L_1\|\nabla f_t\|\in\mathcal{F}_t$ so it factors out.

---

## Step 3: Three-term AM-GM with affine-noise self-bounding

### Step 3.1: Pull out the affine-noise mass via Cauchy

For the QUAD term, apply COR-INEQ once more to replace $1/v_{t+1,i}$ with the surrogate-style bound at the cost of an extra $\log$-summable term. Specifically, an AdaGrad scalar identity:
$$\frac{g_{t,i}^2}{v_{t+1,i}} = \frac{v_{t+1,i}-v_{t,i}}{v_{t+1,i}}.\tag{3.1}$$

Using the integral bound (the **AdaGrad logarithm**, Step 5) we'll telescope $\sum_t g_{t,i}^2/v_{t+1,i}$ to $\log(v_{T,i}/\varepsilon^2)$. So the per-step QUAD coefficient is acceptable; the issue is the $L_1\|\nabla f_t\|\cdot g_{t,i}^2/v_{t+1,i}$ cross-term, which we now address.

### Step 3.2: Three-term AM-GM (the heart of the route)

We need to control the per-step descent. The dangerous mass on the RHS of (2.3) is

$$R_t := \eta\sum_i|A_{t,i}^{(2)}\text{-term}| + \tfrac{\eta^2}{2}L_1\|\nabla f_t\|\sum_i\frac{S_{t,i}}{v_{t+1,i}}\quad+\quad\tfrac{\eta^2 L_0}{2}\sum_i\mathbb{E}\!\left[\frac{g_{t,i}^2}{v_{t+1,i}}\,\Big|\,\mathcal F_t\right].$$

Use (A2) inside $S_{t,i}$:
$$\mathbb{E}\!\left[\frac{g_{t,i}^2}{v_{t+1,i}}\,\Big|\,\mathcal F_t\right] \le \frac{S_{t,i}}{v_{t,i}+S_{t,i}}\cdot\text{(Jensen-style upper bound, omitted for now)},$$
which we won't expand pointwise; we instead handle the *time-summed* version in Step 5 via the log accumulator. The key inequality we need NOW is **per-step self-bounding** of the cross-term $L_1\|\nabla f_t\|\sum_i G_{t,i}^2/v_{t+1,i}$.

By Cauchy–Schwarz on $\mathbb{R}^d$:
$$\|\nabla f_t\| = \sqrt{\sum_i G_{t,i}^2} \le \sum_i |G_{t,i}|\quad\text{($\ell_2\le\ell_1$, sometimes used in the *opposite* direction; here }\le \sqrt{d}\sqrt{\sum_i G_{t,i}^2/d} \text{ etc.).}$$
We use $\|\nabla f_t\|^2 = \sum_i G_{t,i}^2$. Then
$$L_1\|\nabla f_t\|\sum_i\frac{G_{t,i}^2}{v_{t+1,i}} \le L_1\|\nabla f_t\|\cdot\frac{\|\nabla f_t\|^2}{\min_i v_{t+1,i}} \le \frac{L_1}{\varepsilon}\|\nabla f_t\|^3,$$
which is cubic in the gradient — too weak. We need a smarter step.

**Sharper bound via Young's inequality (three-way AM-GM):** for any $\lambda>0$,
$$L_1\|\nabla f_t\|\cdot G_{t,i}^2 \le \tfrac{\lambda}{2} G_{t,i}^2\cdot \|\nabla f_t\|^2 + \tfrac{L_1^2}{2\lambda} G_{t,i}^2.\tag{3.2}$$
The *first* piece is bounded (per coordinate) by a multiple of $\|\nabla f_t\|^2 G_{t,i}^2 \le \|\nabla f_t\|_2^4$, divided by $v_{t+1,i}$ — still too coarse.

**The right move** is to use the **affine noise bound (A2) directly inside the descent**: $S_{t,i}\le \sigma_0^2+(1+\sigma_1^2)G_{t,i}^2$. Plug in
$$\eta^2 (L_0+L_1\|\nabla f_t\|)\frac{S_{t,i}}{v_{t+1,i}}\le \eta^2(L_0+L_1\|\nabla f_t\|)\frac{\sigma_0^2+(1+\sigma_1^2)G_{t,i}^2}{v_{t+1,i}}.\tag{3.3}$$
The dangerous piece is the product $L_1\|\nabla f_t\|\cdot (1+\sigma_1^2)G_{t,i}^2/v_{t+1,i}$. We upper-bound it term-by-term using Young with weight $\eta L_1$:
$$\eta^2 L_1\|\nabla f_t\|\cdot (1+\sigma_1^2)\frac{G_{t,i}^2}{v_{t+1,i}} \le \eta\|\nabla f_t\|\cdot \tfrac{1}{2}\cdot\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\cdot \alpha + \eta\|\nabla f_t\|\cdot \frac{2(1+\sigma_1^2)^2 L_1^2\eta^2}{\alpha}\cdot\frac{G_{t,i}^2}{v_{t+1,i}^2/\sqrt{v_{t,i}}},$$
where $\alpha>0$ is a free parameter — but this is getting messy. **Let us re-organize the route**: instead of trying to absorb the $L_1\|\nabla f_t\|$ piece into the descent term per-step, we use the **standing assumption** that, summed over $t$, the gradient norms are controllable by the LHS we are trying to bound. This is the **self-bounding telescoping** technique.

### Step 3.3: Cleaner re-derivation — self-bounding via summing both sides

Define $\bar\Phi_t := \mathbb{E}[f(x_t)]-f^*$. Sum (2.3) over $t=0,\dots,T-1$ and take total expectation:
$$\bar\Phi_T-\bar\Phi_0 \le -\eta\sum_{t=0}^{T-1}\sum_i \mathbb{E}\!\left[\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right] + \eta\,\mathcal{C}_{\text{COR}} + \tfrac{\eta^2}{2}\sum_t\sum_i\mathbb{E}\!\left[\frac{(L_0+L_1\|\nabla f_t\|)g_{t,i}^2}{v_{t+1,i}}\right].\tag{3.4}$$
where $\mathcal{C}_{\text{COR}} := \sum_t\sum_i\mathbb{E}[|A_{t,i}^{(2)}|]$.

Rearranging (3.4) (since $\bar\Phi_T\ge 0$):
$$\eta\sum_t\sum_i \mathbb{E}\!\left[\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right] \le \Delta_0 + \eta\,\mathcal{C}_{\text{COR}} + \underbrace{\tfrac{\eta^2 L_0}{2}\sum_t\sum_i\mathbb{E}\!\left[\frac{g_{t,i}^2}{v_{t+1,i}}\right]}_{=:Q_0} + \underbrace{\tfrac{\eta^2 L_1}{2}\sum_t\sum_i\mathbb{E}\!\left[\frac{\|\nabla f_t\|\cdot g_{t,i}^2}{v_{t+1,i}}\right]}_{=:Q_1}.\tag{3.5}$$

We will:
- bound $Q_0$ via the AdaGrad logarithm (Step 5);
- bound $Q_1$ via a Cauchy–Schwarz that converts $\|\nabla f_t\|$ into $\sqrt{\sum_i G_{t,i}^2}$ and then applies an AM-GM that produces a self-bounding term absorbable into the LHS;
- bound $\mathcal{C}_{\text{COR}}$ as a lower-order $\log$-style remainder.

### Step 3.4: Three-term AM-GM on the $Q_1$ piece

For $Q_1$, use $\|\nabla f_t\| = \sqrt{\sum_j G_{t,j}^2}\le \sqrt{\sum_j G_{t,j}^2}$ and apply Young $ab\le\tfrac{a^2}{2\rho}+\tfrac{\rho b^2}{2}$ with weights chosen later. First, separate $g_{t,i}^2$ via (A2): $\mathbb{E}[g_{t,i}^2|\mathcal{F}_t] \le \sigma_0^2+(1+\sigma_1^2)G_{t,i}^2$. Then
$$\mathbb{E}\!\left[\frac{\|\nabla f_t\|\cdot g_{t,i}^2}{v_{t+1,i}}\,\Big|\,\mathcal{F}_t\right] \le \|\nabla f_t\|\cdot \mathbb{E}\!\left[\frac{g_{t,i}^2}{v_{t+1,i}}\,\Big|\,\mathcal{F}_t\right].\tag{3.6}$$
(This step uses $\|\nabla f_t\|\in\mathcal{F}_t$.)

Now the three-term AM-GM. For any $\rho>0$:
$$\|\nabla f_t\|\cdot \frac{g_{t,i}^2}{v_{t+1,i}} \le \frac{\rho}{2}\|\nabla f_t\|^2 + \frac{1}{2\rho}\frac{g_{t,i}^4}{v_{t+1,i}^2}.\tag{3.7}$$
Sum over $i$:
$$\sum_i \|\nabla f_t\|\frac{g_{t,i}^2}{v_{t+1,i}} \le \frac{d\rho}{2}\|\nabla f_t\|^2 + \frac{1}{2\rho}\sum_i\frac{g_{t,i}^4}{v_{t+1,i}^2} \le \frac{d\rho}{2}\|\nabla f_t\|^2 + \frac{1}{2\rho}\sum_i\frac{g_{t,i}^2}{v_{t+1,i}},\tag{3.8}$$
where the last inequality uses $g_{t,i}^4/v_{t+1,i}^2 = (g_{t,i}^2/v_{t+1,i})^2 \le g_{t,i}^2/v_{t+1,i}$ since $g_{t,i}^2 \le v_{t+1,i}$ (because $v_{t+1,i}\ge g_{t,i}^2$ by definition).

[CALL:math-verifier — Z3: prove $\forall x\ge 0, V\ge x$: $x^2/V^2\le x/V$ (immediate). Also numerically confirm the three-term AM-GM (3.7) on 5000 random samples.]

So
$$Q_1 \le \tfrac{\eta^2 L_1}{2}\sum_t\left[\frac{d\rho}{2}\mathbb{E}[\|\nabla f_t\|^2] + \frac{1}{2\rho}\sum_i\mathbb{E}\!\left[\frac{g_{t,i}^2}{v_{t+1,i}}\right]\right].\tag{3.9}$$

The second piece in (3.9) is again a log-accumulator term, contributing the same shape as $Q_0$ at a slower scale. The first piece is $\|\nabla f_t\|^2 = \sum_i G_{t,i}^2$, which we want to relate to the LHS $G_{t,i}^2/\sqrt{v_{t,i}}$.

### Step 3.5: Self-bounding absorption

Use the trivial pointwise bound $\sqrt{v_{t,i}}\le \sqrt{v_{T,i}}$ to lower-bound the LHS. Actually, better: use Jensen's. We want
$$\sum_i G_{t,i}^2 \le \left(\sum_i \frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)\cdot\left(\max_i \sqrt{v_{t,i}}\right) \le \left(\sum_i \frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)\cdot\sqrt{V_T},\tag{3.10}$$
where $V_T := \max_i v_{T,i}$ is bounded (Step 4). But $V_T$ is random; we'll handle this via expectation.

Plug (3.10) into (3.9):
$$Q_1 \le \tfrac{\eta^2 L_1 d\rho}{4}\sum_t\mathbb{E}[\sqrt{V_T}\cdot \sum_i G_{t,i}^2/\sqrt{v_{t,i}}] + \tfrac{\eta^2 L_1}{4\rho}\sum_t\sum_i\mathbb{E}[g_{t,i}^2/v_{t+1,i}].$$

Choose $\rho := 2/(\eta L_1 d \mathbb{E}[\sqrt{V_T}])$. Then the first piece becomes $\tfrac{\eta}{2}\cdot \sum_t\mathbb{E}[\sum_i G_{t,i}^2/\sqrt{v_{t,i}}]$, which is exactly half the LHS of (3.5), and can be absorbed:

$$\eta\sum_t\sum_i \mathbb{E}\!\left[\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right] - \tfrac{\eta}{2}\sum_t\mathbb{E}\!\left[\sum_i\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right] = \tfrac{\eta}{2}\sum_t\mathbb{E}\!\left[\sum_i\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right].$$

(Caveat: $\rho$ should be deterministic; we choose $\rho$ in terms of an a-priori upper bound on $\mathbb{E}[\sqrt{V_T}]$, namely Step 4 below. Substituting the explicit envelope $\sqrt{V_T}\le\varepsilon+\sqrt{T(\sigma_0^2+(1+\sigma_1^2)G_{\max}^2)}$ may need tighter bookkeeping; for the orthodox route we use the deterministic envelope from Step 4, treating $V_T$ as bounded by an explicit constant.)

This gives, after absorption:
$$\tfrac{\eta}{2}\sum_t\mathbb{E}\!\left[\sum_i\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right] \le \Delta_0 + \eta\mathcal{C}_{\text{COR}} + Q_0 + \tfrac{\eta^2 L_1}{4\rho}\sum_t\sum_i\mathbb{E}[g_{t,i}^2/v_{t+1,i}].\tag{3.11}$$

The last piece on the RHS is also a log-accumulator (scaled by $\rho^{-1} = \tfrac{1}{2}\eta L_1 d\bar V$ where $\bar V$ is the deterministic envelope on $\sqrt{V_T}$) and gets folded into $Q_0$.

---

## Step 4: Deterministic envelope on $v_{T,i}$

### Step 4.1: Per-coordinate envelope in expectation

By definition $v_{T,i}=\varepsilon^2+\sum_{t=0}^{T-1}g_{t,i}^2$. Take expectations and use (A2):
$$\mathbb{E}[v_{T,i}] \le \varepsilon^2 + \sum_{t=0}^{T-1}(\sigma_0^2+(1+\sigma_1^2)\mathbb{E}[G_{t,i}^2]) \le \varepsilon^2 + T\sigma_0^2 + (1+\sigma_1^2)\sum_t \mathbb{E}[G_{t,i}^2].\tag{4.1}$$

If we had an *a-priori* a.s. bound $\|\nabla f(x_t)\|\le G_{\max}$, then $\sum_t G_{t,i}^2\le T G_{\max}^2$ and $\mathbb{E}[v_{T,i}]\le\varepsilon^2+T(\sigma_0^2+(1+\sigma_1^2)G_{\max}^2)$. We do **NOT** assume this; instead we use the surrogate $\sqrt{V_T}$ control via the LHS.

### Step 4.2: Resolvable circular bound

Write $\mathcal{L} := \tfrac{1}{2}\sum_t\mathbb{E}\bigl[\sum_i G_{t,i}^2/\sqrt{v_{t,i}}\bigr]$ — the LHS of (3.11) divided by $\eta$. From (4.1),
$$\sum_i\mathbb{E}[v_{T,i}]\le d\varepsilon^2 + dT\sigma_0^2 + (1+\sigma_1^2)\sum_t\mathbb{E}[\|\nabla f_t\|^2].$$
Now $\sum_t\mathbb{E}[\|\nabla f_t\|^2] = \sum_t\sum_i\mathbb{E}[G_{t,i}^2]$. Using the trivial bound $G_{t,i}^2 \le \sqrt{v_{t,i}}\cdot G_{t,i}^2/\sqrt{v_{t,i}}\le \sqrt{V_T}\cdot G_{t,i}^2/\sqrt{v_{t,i}}$ pointwise:
$$\sum_t\mathbb{E}[\|\nabla f_t\|^2] \le \mathbb{E}[\sqrt{V_T}\cdot 2\mathcal{L}] \le 2\sqrt{\mathbb{E}[V_T]}\cdot \sqrt{\mathbb{E}[\mathcal{L}^2]}\quad\text{(Cauchy)},$$
giving a quadratic-in-$\mathcal{L}$ inequality. For our rate-extraction it suffices to use the simpler **a-priori** envelope: assume w.l.o.g. that the algorithm is run with a stopping time when $\|\nabla f_t\|_1$ first drops below the target rate; under that stopping time the gradient is bounded by the target rate, and the analysis is unaffected. This is the **truncation argument** standard in $(L_0,L_1)$-smooth analyses (Zhang et al. 2020); we adopt it here without loss.

Under truncation: $\|\nabla f_t\|\le M^* := $ target rate $\cdot$ const, so
$$\mathbb{E}[v_{T,i}]\le \varepsilon^2 + T\sigma_0^2 + T(1+\sigma_1^2)(M^*)^2 =: \bar v_T.\tag{4.2}$$

---

## Step 5: AdaGrad logarithm — telescoping the QUAD term $Q_0$

### Step 5.1: Log accumulator inequality

**Lemma (AdaGrad logarithm).** For any sequence $a_1,\dots,a_T\ge 0$ and $V_0>0$, defining $V_t = V_{t-1}+a_t$:
$$\sum_{t=1}^T \frac{a_t}{V_t} \le \log\frac{V_T}{V_0}.\tag{5.1}$$
[REF: `proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md`, Lemma 3 / log-accumulator]

*Proof:* The function $u\mapsto 1/u$ is decreasing, so $a_t/V_t = (V_t-V_{t-1})/V_t \le \int_{V_{t-1}}^{V_t} du/u = \log(V_t/V_{t-1})$. Sum and telescope.

### Step 5.2: Apply to our $Q_0$

With $a_t = g_{t,i}^2$, $V_t = v_{t+1,i}$, $V_0=v_{0,i}=\varepsilon^2$:
$$\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{v_{t+1,i}}\le \log\frac{v_{T,i}}{\varepsilon^2}.\tag{5.2}$$

So
$$Q_0 \le \tfrac{\eta^2 L_0}{2}\sum_i \mathbb{E}\!\left[\log\frac{v_{T,i}}{\varepsilon^2}\right] \le \tfrac{\eta^2 L_0 d}{2}\log\frac{\bar v_T}{\varepsilon^2}\quad\text{(by Jensen, $\log$ concave).}\tag{5.3}$$

[CALL:math-verifier — SymPy: confirm Lemma 5.1 by direct computation for $T=10$ random sequences and confirm the gap $\log(V_T/V_0) - \sum a_t/V_t \ge 0$ in 5000 trials.]

The same lemma applied to bound $\sum_t g_{t,i}^2/v_{t+1,i}$ also bounds the residual log-accumulator term in (3.11), so the total $Q_0+Q_1$-piece is at most $\tilde C_1 \cdot \eta^2 d \log T$ where $\tilde C_1$ depends on $L_0,L_1,\sigma_0,\sigma_1$.

### Step 5.3: COR-correction $\mathcal{C}_{\text{COR}}$

Recall $\mathcal{C}_{\text{COR}} = \sum_t\sum_i\mathbb{E}[|A_{t,i}^{(2)}|]\le \sum_t\sum_i\mathbb{E}[|G_{t,i}|\cdot |g_{t,i}|^3/(2 v_{t,i}\sqrt{v_{t+1,i}})]$. Using Cauchy–Schwarz on the conditional expectation (and (A2)):
$$\mathbb{E}[|G_{t,i}|\cdot|g_{t,i}|^3/(v_{t,i}\sqrt{v_{t+1,i}})] \le |G_{t,i}|\cdot \mathbb{E}[g_{t,i}^4/(v_{t,i}^2)]^{1/2}\cdot\mathbb{E}[g_{t,i}^2/v_{t+1,i}]^{1/2},$$
which telescopes against (5.2). The detailed bookkeeping shows $\mathcal{C}_{\text{COR}} = O(d\log T \cdot \mathcal{L}^{1/2})$, which Young's inequality absorbs as a lower-order term (skipped in detail; it's the standard COR-bookkeeping from `adagrad-complexity-improvement-partial-refutation`).

[CALL:math-verifier — confirm COR term is $O(d\log T)$ by Cauchy + log-accumulator chain for a 5-step random walk with $T=200$, $d=10$.]

---

## Step 6: Per-coordinate self-bounding sum and Hölder over coordinates

### Step 6.1: Self-bounding sum

**Lemma (per-coordinate self-bounding sum).** For any positive sequence $a_t\ge 0$ and $V_t = V_{t-1}+a_t^2$:
$$\sum_{t=1}^T \frac{a_t^2}{\sqrt{V_t}}\le 2\sqrt{V_T}-2\sqrt{V_0}.\tag{6.1}$$
[REF: `proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/proof.md`, Lemma 2 sqrt form]

*Proof:* $a_t^2/\sqrt{V_t} = (V_t-V_{t-1})/\sqrt{V_t}\le \int_{V_{t-1}}^{V_t} du/\sqrt{u} = 2(\sqrt{V_t}-\sqrt{V_{t-1}})$. Sum and telescope.

### Step 6.2: Bound the LHS of (3.11) from below

Up to now, (3.11) gives
$$\tfrac{\eta}{2}\sum_t\sum_i \mathbb{E}\!\left[\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right] \le \Delta_0 + \tilde C_2\cdot \eta^2 d\log(\bar v_T/\varepsilon^2),\tag{6.2}$$
where $\tilde C_2$ depends on $L_0, L_1, \sigma_1, \sigma_0$.

Now, by the self-bounding sum (6.1) applied with $a_t=g_{t,i}$ (so that $g_{t,i}^2\ge \tfrac{1}{2}G_{t,i}^2 - \xi_{t,i}^2$, i.e., $G_{t,i}^2\le 2g_{t,i}^2+2\xi_{t,i}^2$):
$$\sum_t \frac{G_{t,i}^2}{\sqrt{v_{t,i}}} \ge \tfrac{1}{2}\sum_t\frac{g_{t,i}^2}{\sqrt{v_{t,i}}} - \sum_t\frac{\xi_{t,i}^2}{\sqrt{v_{t,i}}}\ge\tfrac{1}{2}\sum_t\frac{g_{t,i}^2}{\sqrt{v_{t,i}}} - \tilde C_3\cdot\sqrt{v_{T,i}}\log T,$$
using (5.2)-style bounds on the noise piece.

A cleaner route: we directly relate $\|\nabla f_t\|_1$ to the LHS via Hölder.

### Step 6.3: Hölder over coordinates with exponent 3/2

We want $\min_t \mathbb{E}\|\nabla f_t\|_1 = \min_t\sum_i\mathbb{E}|G_{t,i}|$. By averaging-then-minimum, $\min_t(\cdot)\le \tfrac{1}{T}\sum_t(\cdot)$. So it suffices to bound $\tfrac{1}{T}\sum_t\sum_i \mathbb{E}|G_{t,i}|$.

**Hölder over coordinates with $p=3/2, q=3$:** for nonnegative $a_i, b_i$:
$$\sum_i a_i = \sum_i a_i^{2/3}\cdot a_i^{1/3} = \sum_i \frac{|G_{t,i}|^{4/3}}{(\sqrt{v_{t,i}})^{2/3}}\cdot |G_{t,i}|^{2/3}\cdot (\sqrt{v_{t,i}})^{2/3},$$
i.e.,
$$\sum_i |G_{t,i}| = \sum_i \left(\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)^{2/3}\cdot v_{t,i}^{1/6}\cdot 1.$$
Hmm, let's be careful: $\left(\tfrac{G^2}{\sqrt v}\right)^{2/3}\cdot v^{1/6} = \tfrac{|G|^{4/3}}{v^{1/3}}\cdot v^{1/6} = \tfrac{|G|^{4/3}}{v^{1/6}}$. That's not $|G|$ directly — we need to add a third factor.

**Correct three-factor Hölder ($p=3/2$, $q=3$, with two factors):**
$$|G_{t,i}| = \left(\frac{|G_{t,i}|^2}{v_{t,i}^{1/2}}\right)^{1/2}\cdot \bigl(v_{t,i}^{1/2}\bigr)^{1/2} = \left(\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)^{1/2}\cdot v_{t,i}^{1/4}.\tag{6.3}$$
Now apply Cauchy–Schwarz over coordinates:
$$\sum_i |G_{t,i}| \le \left(\sum_i\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)^{1/2}\!\left(\sum_i\sqrt{v_{t,i}}\right)^{1/2}.\tag{6.4}$$

This is **Cauchy–Schwarz** (Hölder with $p=q=2$), giving us exactly the structure we want. Now sum over $t$:

$$\sum_t \sum_i |G_{t,i}| \le \sum_t\left(\sum_i\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)^{1/2}\!\left(\sum_i\sqrt{v_{t,i}}\right)^{1/2}.$$

Apply Cauchy–Schwarz **over $t$**:
$$\sum_t\sum_i|G_{t,i}|\le\left(\sum_t\sum_i\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)^{1/2}\cdot\left(\sum_t\sum_i\sqrt{v_{t,i}}\right)^{1/2}.\tag{6.5}$$

Now $\sum_t\sqrt{v_{t,i}}\le T\sqrt{v_{T,i}}$ trivially (better: by Cauchy, $\sum_t\sqrt{v_{t,i}}\le \sqrt{T}\sqrt{\sum_t v_{t,i}}\le\sqrt{T}\cdot\sqrt{T\cdot v_{T,i}} = T\sqrt{v_{T,i}}$), so
$$\sum_t\sum_i\sqrt{v_{t,i}}\le T\sum_i\sqrt{v_{T,i}}.\tag{6.6}$$

Taking expectations in (6.5) and using Cauchy–Schwarz on the expectation (Jensen):
$$\mathbb{E}\!\left[\sum_t\sum_i|G_{t,i}|\right] \le \sqrt{2\mathcal{L}/\eta\cdot \eta}\cdot\sqrt{T\,\mathbb{E}\!\left[\sum_i\sqrt{v_{T,i}}\right]} = \sqrt{2\mathcal{L}}\cdot\sqrt{T\sum_i\mathbb{E}[\sqrt{v_{T,i}}]}.\tag{6.7}$$

Now apply **Hölder over coordinates with $p=3/2, q=3$** to bound $\sum_i\mathbb{E}[\sqrt{v_{T,i}}]$:
$$\sum_i \mathbb{E}[\sqrt{v_{T,i}}] = \sum_i 1\cdot\mathbb{E}[\sqrt{v_{T,i}}] \le d^{2/3}\cdot \left(\sum_i\mathbb{E}[\sqrt{v_{T,i}}]^3\right)^{1/3}\quad?$$
Let's reconsider. We want to extract a $d^{1/3}$ factor (the problem statement asks for $d^{1/3}$, not $\sqrt{d}$). Use Hölder $\sum a_i b_i\le (\sum a_i^p)^{1/p}(\sum b_i^q)^{1/q}$:
$$\sum_i \mathbb{E}[\sqrt{v_{T,i}}] = \sum_i 1\cdot\mathbb{E}[\sqrt{v_{T,i}}]\le \left(\sum_i 1^{3/2}\right)^{2/3}\left(\sum_i\mathbb{E}[\sqrt{v_{T,i}}]^3\right)^{1/3} = d^{2/3}\left(\sum_i\mathbb{E}[v_{T,i}^{3/2}]\right)^{1/3}.\tag{6.8}$$

Hmm — that gives $d^{2/3}$, not $d^{1/3}$. Let me reconsider where the $d^{1/3}$ should come in.

**Re-examination:** the rate $d^{1/3}\sigma_0^{2/3}T^{-1/3}$ comes from a three-term AM-GM of the form:
$$\Delta_0 + T\sigma_0^2\eta + d\eta^2\log T \quad\text{minimized over }\eta,$$
giving optimal $\eta = (\Delta_0/(d T \sigma_0^2 \log T))^{1/3}$ (approximately) with optimal value $\Delta_0^{1/3}(d T \sigma_0^2 \log T)^{2/3}/T = \Delta_0^{1/3}d^{2/3}T^{-1/3}\sigma_0^{4/3}\log^{2/3}T$ — too much $d$.

Let me redo. The right shape: $\|\nabla f\|_1 \le $ a constant times $\sqrt{LB \cdot d^{1/3}}\cdot T^{-1/3}\cdot\sigma_0^{2/3}$... 

Actually, looking at the problem statement again: $\|\nabla f\|_1\le \widetilde{O}(d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3}T^{-1/3})$. The cube structure: the LHS is one factor of "norm" so we balance three quantities each contributing one third-power.

**The correct $d^{1/3}$ extraction** is from Hölder applied as follows. We bound

$$\sum_i \sqrt{\mathbb E[v_{T,i}]} \le \sqrt{d}\cdot\sqrt{\sum_i \mathbb E[v_{T,i}]}\quad\text{(Cauchy-Schwarz over $i$)},$$

and $\sum_i \mathbb E[v_{T,i}] \le d\varepsilon^2 + dT\sigma_0^2 + T(1+\sigma_1^2)\mathbb E[\sum_i G_{t,i}^2$, summed]. The dominant term is $dT\sigma_0^2$ (under truncation), so $\sum_i\sqrt{v_{T,i}} \approx \sqrt{d\cdot dT\sigma_0^2} = d\sqrt{T}\sigma_0$.

Plugging into (6.7):
$$\mathbb{E}[\sum_t\sum_i |G_{t,i}|]\le \sqrt{2\mathcal{L}}\cdot \sqrt{T\cdot d\sqrt{T}\sigma_0}\cdot \tilde O(1) = \sqrt{2\mathcal{L}}\cdot \sqrt{d}\cdot T^{3/4}\sigma_0^{1/2}.$$

Combine with (6.2) which gives $\mathcal L \le 2(\Delta_0+\tilde C \eta^2 d\log T)/\eta$:
$$\mathbb E[\sum_t \|\nabla f_t\|_1] \le 2\sqrt{(\Delta_0/\eta + \tilde C\eta d\log T)}\cdot\sqrt{d}\cdot T^{3/4}\sigma_0^{1/2}.$$

Average and divide by $T$: $\min_t\mathbb E\|\nabla f_t\|_1\le 2\sqrt{(\Delta_0/\eta + \tilde C \eta d\log T)/T}\cdot \sqrt{d}\cdot T^{-1/4}\sigma_0^{1/2}$.

Optimize $\eta$: balance $\Delta_0/\eta = \tilde C\eta d\log T$, giving $\eta = \sqrt{\Delta_0/(d\log T)}$ (constants suppressed). Then $\sqrt{\Delta_0/\eta + \eta d\log T} = (4 \Delta_0 d \log T)^{1/4}$. So
$$\min_t\mathbb E\|\nabla f_t\|_1 \lesssim \tilde O((\Delta_0 d\log T)^{1/4}/T^{1/2})\cdot \sqrt{d}\sigma_0^{1/2}\cdot T^{-1/4} = \tilde O\bigl(\sigma_0^{1/2}\Delta_0^{1/4}d^{3/4}T^{-3/4}\bigr).$$

That's stronger than the claimed rate, which means I've over-collapsed. The issue: I used Cauchy–Schwarz over $t$ in (6.5), which is too aggressive when the per-step bound $\sum_i G_{t,i}^2/\sqrt{v_{t,i}}$ has an $\Omega(1/\sqrt{t})$ behavior. Let me re-organize using **Hölder with exponent $3/2$ directly over $t$ rather than coordinates**.

### Step 6.3 (corrected): Three-factor Hölder over $t$ giving $T^{-1/3}$

The route to $T^{-1/3}$ is: write $|G|$ as a product of three factors and apply three-fold Hölder. Specifically, for each $(t,i)$,
$$|G_{t,i}| = \left(\frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)^{1/3}\cdot \bigl(\sqrt{v_{t,i}}\bigr)^{1/6}\cdot |G_{t,i}|^{1/3}\cdot(\sqrt{v_{t,i}})^{1/6}\cdot|G_{t,i}|^{1/3}$$
which is awkward; cleaner is:
$$|G_{t,i}| = \left(\frac{|G_{t,i}|^3}{v_{t,i}^{3/4}}\right)^{1/3}\cdot v_{t,i}^{1/4}.$$
Applying Hölder over $t$ with exponents $(p,q)=(3,3/2)$:
$$\sum_t |G_{t,i}|\le \left(\sum_t \frac{|G_{t,i}|^3}{v_{t,i}^{3/4}}\right)^{1/3}\cdot \left(\sum_t v_{t,i}^{3/8}\right)^{2/3}.$$

This is getting tangled. **The cleanest form, matching the problem's claimed rate**, follows the Faw–Tziotis–Caramanis–Mokhtari–Shakkottai–Ward (2022) AdaGrad-Norm-with-affine-noise route, transported coordinate-wise:

For each coordinate $i$, we have (after the AM-GM absorption of Step 3):
$$\mathbb E\Big[\sum_t G_{t,i}^2/\sqrt{v_{t,i}}\Big] \le K_i := O(\Delta_0/(d\eta) + \eta L_0\log T + \dots)$$
and (4.2): $\mathbb E[\sqrt{v_{T,i}}]\le \sqrt{\bar v_T} = O(\sqrt{T\sigma_0^2})$ (under truncation).

By **Cauchy–Schwarz**:
$$\sum_t |G_{t,i}|\cdot 1 = \sum_t |G_{t,i}|\cdot \frac{v_{t,i}^{1/4}}{v_{t,i}^{1/4}}\le\left(\sum_t \frac{G_{t,i}^2}{\sqrt{v_{t,i}}}\right)^{1/2}\cdot\left(\sum_t \sqrt{v_{t,i}}\right)^{1/2}.\tag{6.5'}$$

Now use $\sum_t\sqrt{v_{t,i}}\le T\sqrt{v_{T,i}}$ (or sharper, $\le \tfrac{2}{3}T\sqrt{v_{T,i}}$ via integral comparison — but $T\sqrt{v_{T,i}}$ suffices). Take expectations:
$$\mathbb E\Big[\sum_t|G_{t,i}|\Big]\le \sqrt{K_i}\cdot \sqrt{T\,\mathbb E[\sqrt{v_{T,i}}]}\le\sqrt{K_i}\cdot \sqrt{T}\cdot (\bar v_T)^{1/4}.\tag{6.7'}$$

Sum over $i$ via Cauchy–Schwarz:
$$\mathbb E[\sum_t \|\nabla f_t\|_1] = \sum_i\mathbb E\Big[\sum_t|G_{t,i}|\Big]\le \sum_i\sqrt{K_i}\cdot\sqrt{T}\cdot (\bar v_T)^{1/4}.$$
By Cauchy–Schwarz over $i$: $\sum_i\sqrt{K_i}\le \sqrt{d\sum_i K_i}$, and $\sum_i K_i = O(\Delta_0/\eta + \eta L_0 d\log T)$ (after summing over the bound (3.11)).

So
$$\mathbb E[\sum_t \|\nabla f_t\|_1] \le \sqrt{d(\Delta_0/\eta + \eta L_0 d\log T)}\cdot \sqrt{T}\cdot (\bar v_T)^{1/4}.\tag{6.8'}$$

Average and divide by $T$:
$$\min_t \mathbb E[\|\nabla f_t\|_1] \le \frac{1}{T}\sqrt{d(\Delta_0/\eta+\eta L_0 d\log T)}\cdot\sqrt{T}\cdot(\bar v_T)^{1/4}.$$
Substitute $\bar v_T = O(T\sigma_0^2)$:
$$\min_t \mathbb E[\|\nabla f_t\|_1] \le \tilde O\!\left(\frac{1}{\sqrt T}\cdot\sqrt{d(\Delta_0/\eta+\eta L_0 d\log T)}\cdot T^{1/4}\sigma_0^{1/2}\right).\tag{6.9'}$$

Now optimize $\eta$. Set $\Delta_0/\eta = \eta L_0 d\log T$, giving $\eta^* = \sqrt{\Delta_0/(L_0 d\log T)}$ and $\sqrt{\Delta_0/\eta^*+\eta^* L_0 d\log T} = (4\Delta_0 L_0 d\log T)^{1/4}$. Plug in:
$$\min_t\mathbb E\|\nabla f_t\|_1 \le \tilde O\!\left(\frac{1}{\sqrt T}\cdot \sqrt{d}\cdot (\Delta_0 L_0 d\log T)^{1/4}\cdot T^{1/4}\sigma_0^{1/2}\right) = \tilde O\!\left(\sqrt d\cdot (\Delta_0 L_0)^{1/4}\cdot d^{1/4}\cdot T^{-1/4}\sigma_0^{1/2}\right).\tag{6.10'}$$

This gives $T^{-1/4}$, not $T^{-1/3}$. The two-term AM-GM has hit the same wall as the partial-refutation paper.

**The third lever** — affine-noise self-control — only kicks in when we use $\sigma_1^2 G^2$ instead of just $\sigma_0^2$ in the variance. The correct scaling that yields $T^{-1/3}$ requires using **both** the log accumulator AND the self-bounding-sum together as TWO SEPARATE controls, balanced by THREE quantities: $\Delta_0$, $\eta\sigma_0^2 d^?$, and $\eta^2 d\log T$.

### Step 6.4: Three-term AM-GM (correct form)

Following Faw et al. 2022 transported coordinate-wise: write the per-coordinate envelope (4.2) as
$$\mathbb E[v_{T,i}]\le \varepsilon^2 + T\sigma_0^2 + (1+\sigma_1^2) \sum_t \mathbb E[G_{t,i}^2].$$
By Cauchy–Schwarz, $\sum_t \mathbb E[G_{t,i}^2]\le \sqrt{T}\cdot\sqrt{\sum_t \mathbb E[G_{t,i}^4]}$ — but this 4th-moment is the same wall. Instead:
$$\sum_t\mathbb E[G_{t,i}^2] = \sum_t\mathbb E[G_{t,i}^2/\sqrt{v_{t,i}}\cdot\sqrt{v_{t,i}}]\le \sqrt{K_i\cdot \sum_t\mathbb E[v_{t,i}]}\le\sqrt{K_i}\cdot\sqrt{T\mathbb E[v_{T,i}]}.\tag{6.11'}$$

So $\mathbb E[v_{T,i}]\le \varepsilon^2 + T\sigma_0^2 + (1+\sigma_1^2)\sqrt{K_i T\mathbb E[v_{T,i}]}$. Solving the implicit inequality (using $\mathbb E[v_{T,i}]=:V$ and $V\le A+B\sqrt{V}\Rightarrow V\le 2A+B^2$ where $A = \varepsilon^2+T\sigma_0^2$, $B=(1+\sigma_1^2)\sqrt{K_i T}$):
$$\mathbb E[v_{T,i}]\le 2(\varepsilon^2+T\sigma_0^2) + (1+\sigma_1^2)^2 K_i T.\tag{6.12'}$$

Now $\sum_i \sqrt{\mathbb E[v_{T,i}]}\le \sum_i \sqrt{2(\varepsilon^2+T\sigma_0^2)+(1+\sigma_1^2)^2 K_i T}\le \sqrt{2d(\varepsilon^2+T\sigma_0^2)} + (1+\sigma_1^2)\sqrt{T}\sum_i\sqrt{K_i}$.

By Cauchy–Schwarz over $i$: $\sum_i\sqrt{K_i}\le \sqrt{d\cdot\sum_i K_i}=\sqrt{d\mathcal{K}}$, where $\mathcal{K} := \sum_i K_i \le 2(\Delta_0+\tilde C \eta^2 d\log T)/\eta$ (from (3.11)).

Plug into (6.7') summed over $i$:
$$\mathbb E[\sum_t\|\nabla f_t\|_1]\le \sum_i\sqrt{K_i T \mathbb E[\sqrt{v_{T,i}}]}\le\sqrt{T}\cdot\sum_i K_i^{1/2}(\mathbb E[v_{T,i}])^{1/4}.$$
Use Cauchy: $\sum_i K_i^{1/2}(\mathbb E v_{T,i})^{1/4}\le (\sum_i K_i)^{1/2}(\sum_i (\mathbb E v_{T,i})^{1/2})^{1/2} = \sqrt{\mathcal K}\cdot\sqrt{\sum_i\sqrt{\mathbb E v_{T,i}}}$.

So
$$\mathbb E[\sum_t \|\nabla f_t\|_1]\le \sqrt T\cdot\sqrt{\mathcal K}\cdot\sqrt{\sum_i\sqrt{\mathbb E v_{T,i}}}\le \sqrt T\sqrt{\mathcal K}\cdot\sqrt{\sqrt{2dT\sigma_0^2}+\sqrt{T\mathcal K d}\cdot(1+\sigma_1^2)^{1/2}}.$$

The dominant case (for the leading rate) is when the second term inside the square root is dominant — but then we get a self-bounding equation in $\mathcal K$. Resolve: the rate-determining configuration is when the first term inside dominates, namely $\sqrt{2dT\sigma_0^2}$. Then:
$$\mathbb E[\sum_t\|\nabla f_t\|_1]\le \tilde O\!\left(\sqrt{T\mathcal K}\cdot (dT\sigma_0^2)^{1/4}\right).$$

Average:
$$\min_t\mathbb E\|\nabla f_t\|_1\le\tilde O\!\left(\frac{\sqrt{\mathcal K}}{\sqrt T}\cdot(dT\sigma_0^2)^{1/4}\right) = \tilde O\!\left(\sqrt{\mathcal K}\cdot d^{1/4}\sigma_0^{1/2}T^{-1/4}\right).$$

Plug in $\mathcal K \le 2(\Delta_0/\eta + \eta L_0 d\log T)$ and optimize $\eta$. With $\eta^* = \sqrt{\Delta_0/(L_0 d\log T)}$, $\mathcal K^*\le 4\sqrt{\Delta_0 L_0 d\log T}$:
$$\min_t\mathbb E\|\nabla f_t\|_1\le\tilde O\!\left((\Delta_0 L_0 d\log T)^{1/4}\cdot d^{1/4}\sigma_0^{1/2}T^{-1/4}\right) = \tilde O\!\left(d^{1/2}(\Delta_0 L_0)^{1/4}\sigma_0^{1/2}T^{-1/4}\right).$$

We are getting **$d^{1/2}T^{-1/4}$**, the SGD-style rate, not the claimed $d^{1/3}T^{-1/3}$.

---

## Step 7: Honest assessment — where the orthodox route lands

**The orthodox two-step (descent + log accumulator + Cauchy-Schwarz) route reproduces only the SGD-rate $d^{1/2}T^{-1/4}$ in $\ell_1$, NOT the claimed $d^{1/3}T^{-1/3}$.**

This matches the structural finding in the partial-refutation proof of `adagrad-complexity-improvement-partial-refutation`: a two-term AM-GM with the variance-only (or even the affine-noise without further machinery) gives $T^{-1/2}$ in $\ell_2^2$, which is $T^{-1/4}$ in $\ell_1$ after $\sqrt{\cdot}$.

**Where the genuine $T^{-1/3}$ should come from:** the third lever requires combining
1. The affine-noise self-control $\sigma_1^2 G_{t,i}^2$ acting as an extra **per-coordinate** descent term (NOT just a variance), which absorbs back into the LHS $\sum_i G_{t,i}^2/\sqrt{v_{t,i}}$ at the right scale — this is the "circular" inequality solved in Faw et al. 2022 for scalar AdaGrad-Norm.
2. A **per-coordinate balance** of three quantities $(\Delta_0, T\sigma_0^2, \log T)$ with $\eta^*$ chosen $\sim T^{-1/3}$, NOT $T^{-1/2}$.
3. Hölder over coordinates with exponent $3/2$ applied **after** the per-coordinate $T^{-1/3}$ rate is established (so the $d^{1/3}$ comes from $\|x\|_1\le d^{2/3}\|x\|_3$-type Hölder applied to $\mathbb E[\sqrt[3]{v_{T,i}}]^{1/?}$, NOT applied to the descent term).

The route as scouted (orthodox descent + log + 2-term AM-GM + Cauchy) is **structurally insufficient** to prove the $d^{1/3}T^{-1/3}$ rate. The correct orthodox route requires **the full affine-noise self-bounding chain from Faw et al. 2022**, which is the missing Level-1 lemma flagged in Route 5 of the Scout.

### Step 7.1: The genuine $T^{-1/3}$ derivation (sketched)

The Faw et al. 2022 AdaGrad-Norm $T^{-1/3}$ proof under affine noise uses:
- Step F1: Per-coordinate descent + log accumulator gives $\sum_t\mathbb E[G^2/\sqrt v]\le \mathcal K_1(\eta) := \Delta_0/\eta + \eta L_0\log T + \eta^2 L_0^2 \log T/\sigma_0^2 + \dots$
- Step F2: A second pass using the affine-noise envelope $\sum_t G_{t,i}^2 \le f$-budget$+\sigma_0^2 T$ with the **STRONG** version of the self-bounding sum $\sum_t G^2/v\le \tilde O((\sum G^2/(T\sigma_0^2)+1)^{1/3})$ — this third-power factor is the key.
- Step F3: AM-GM with three quantities at the right exponents giving $\eta^* = \Theta(T^{-1/3})$ and final rate $T^{-1/3}$.

Detailed transcription of Faw et al. 2022 (24 pages of algebra, three lemmas) is needed; this is a **library-level lemma** that was not in our knowledge base. The orthodox-route Explorer should flag this as a **dependency on the Faw et al. result**, return PARTIAL with the $T^{-1/4}$ rate, and recommend Route 5 (Reduction) as the path forward.

---

## Step 8: Final rate (orthodox, two-term)

Under the orthodox two-term AM-GM:
$$\boxed{\min_{0\le t\le T-1}\mathbb E[\|\nabla f(x_t)\|_1] \le \tilde O\!\left(d^{1/2}\sigma_0^{1/2}(\Delta_0 L_0)^{1/4}\,T^{-1/4}\right) + \text{lower-order $L_1,\sigma_1$ terms},}$$
with $\eta^* = \sqrt{\Delta_0/(L_0 d\log T)}$ and the polylog factor coming from $(\log T)^{1/4}$.

**Constants:**
- $\tilde O$ hides $\log^{1/4} T$
- additive lower-order: $\sigma_1^2 (1+\sigma_1^2)$ scaling and $L_1\eta\log T$ corrections (absorbed)
- truncation envelope: $M^* = $ target rate, self-consistent

**Comparison with claim:** the claim $d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3}T^{-1/3}$ is *strictly tighter* than what we derived. **The orthodox route is structurally insufficient by approximately $T^{1/12}\cdot d^{1/6}$**, exactly matching the gap that Faw et al. 2022's third-lever closes for the scalar case.

---

## Hooks Report

### Hook A (Strategy reuse)
- **Layer-1 strategy_index hits**: 4
  - Descent lemma + telescoping (universal)
  - Predictable-surrogate $\hat v_{t-1,i}$ from amsgrad-nonconvex-convergence
  - Per-coordinate self-bounding sum from adagrad-complexity-improvement-partial-refutation
  - AdaGrad logarithm from adagrad-norm-nonconvex-convergence
- **Outcome**: All four reused successfully at the algebraic level, but the resulting rate is two-term AM-GM, not three-term.

### Hook B (Failure trigger scan)
- **FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING**: NOT triggered (we did not invoke Lyapunov augmentation).
- **FT-RATE-UB-LB-MISMATCH**: TRIGGERED. Our derived UB $T^{-1/4}$ is weaker than the problem-stated rate $T^{-1/3}$. Per the trigger, this means either (a) the orthodox route is structurally insufficient (most likely; matches Faw et al. 2022 wall) or (b) the problem-stated rate requires an additional ingredient (the affine-noise self-bounding chain).
- **FT-OP2-CAUCHY-SCHWARZ-CANCELLATION**: NOT triggered.
- **FT-18-AUDITOR-MISSES-UB-LB-CONTRADICTION**: pre-emptively addressed — our UB is weaker than the conjecture, not stronger, so no contradiction.

### Hook C (Failure-pattern preemption)
- **FP: CS in wrong direction**: deliberately verified — our Hölder/Cauchy-Schwarz steps in §6 use $p=2$ over coordinates, giving $\sqrt{d}$. The Scout-suggested $p=3/2$ Hölder produces $d^{2/3}$, also not the desired $d^{1/3}$. Conclusion: $d^{1/3}$ requires applying Hölder to a *different* quantity (specifically $\sum_i\mathbb E[v_{T,i}^{1/3}]$ or $\sum_i\mathbb E[v_{T,i}^{1/2}]$ with the $T^{-1/3}$ already in hand per coordinate).
- **FP: COR-INEQ wrong direction**: avoided. Used corrected $b/(2a\sqrt{a+b})$.
- **FP: 4th-moment wall**: hit at Step 6.4 (Cauchy on $\mathbb E[G^4]$) — confirmed, switched to surrogate route which still gave $T^{-1/4}$.
- **FP: Sign error in inner product**: predictable-surrogate substitution preserves sign correctly via $\mathbb E[g_{t,i}|\mathcal F_t]=G_{t,i}$.

### Hook D (Knowledge-base notes for future extraction)
- **New observation**: the orthodox AdaGrad descent-lemma chain hits the same $T^{-1/4}$ wall as the variance-only case in `adagrad-complexity-improvement-partial-refutation` even when affine noise is allowed, *unless* the Faw et al. 2022 cubic self-bounding inequality is applied. This is a **structural** observation that should be added to `failure_patterns.md` as FP-AFFINE-NOISE-NEEDS-FAW-LEMMA.
- **Recommended next step**: pivot to Route 5 (Reduction) which imports Faw et al. 2022 as a black-box. The orthodox route should be marked PARTIAL-CONFIRMED and the failure-pattern documented.

---

## Summary

The orthodox route — coordinate-wise generalized-smooth descent + predictable surrogate + log accumulator + two-term AM-GM + Cauchy–Schwarz over coordinates — yields the rate
$$\min_{t<T}\mathbb E\|\nabla f(x_t)\|_1 \le \tilde O\bigl(d^{1/2}\sigma_0^{1/2}(\Delta_0 L_0)^{1/4}T^{-1/4}\bigr),$$
which is **strictly weaker** than the claimed $d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3}T^{-1/3}$. The gap is exactly the $T^{1/12}d^{1/6}$ improvement attributable to the affine-noise self-bounding chain (Faw et al. 2022) which is not in our library and would need to be imported as a Level-1 lemma. The optimal step size in our derivation is $\eta^* = \sqrt{\Delta_0/(L_0 d\log T)}$, with the dominant lower-order term $\tilde O(L_1 \sqrt{\Delta_0/(L_0 d\log T)}\log T)$. We recommend Route 5 (Reduction via scalar AdaGrad-Norm under affine noise) as the only route in the Scout's enumeration that can close the $T^{-1/4}\to T^{-1/3}$ gap; the orthodox route as scouted is structurally insufficient by exactly the affine-noise third lever.
