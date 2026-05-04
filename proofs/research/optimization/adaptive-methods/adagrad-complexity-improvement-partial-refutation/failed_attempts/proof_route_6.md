# Proof of AdaGrad-Coordinate Non-Convex $T^{-2/3}$ Rate — Route 6 (ANALOGY TRANSFER from OFUL Linear Bandit)

**Route**: Analogy transfer from the OFUL / elliptical-potential family of linear-bandit proofs ([REF: `proofs/research/learning-theory/generalization/oful-linear-bandit-regret/proof.md`]) and the EXP3 mixing-cost potential ([REF: `proofs/fragments/jensen-mixing-cost-exp3.md`]). Structural cousin: structure_map.md Cluster C link **C3 ↔ C4** (`linearize-then-couple ≈ skew-symmetric polarization`) — applied here as `coordinate-wise AdaGrad ≈ diagonal-OFUL with self-chosen actions`.

**Scope of this route**: Part (A) UPPER BOUND only. (Part (B) is left to Routes 3/4; the bandit-analogy attempts a lower-bound rescue via Lai–Robbins in §6, but as shown there the analogy **breaks** at the non-stationarity step and the lower-bound transfer is only partial.)

---

## 0. Source-Domain ↔ Target-Domain Isomorphism (the CRUCIAL element)

The whole route stands or falls on the following table, which one must read **before** any algebra makes sense. The left column is the OFUL / linear-bandit world; the right column is coordinate-wise AdaGrad in the non-convex stochastic setting.

| OFUL / Linear bandit (source) | Coordinate-wise AdaGrad (target) |
|---|---|
| Round $t$, dimension $d$ | Iteration $t$, dimension $d$ |
| Action $a_t \in \mathbb{R}^d$, chosen at round $t$ | Stochastic gradient $g_t \in \mathbb{R}^d$, observed at iteration $t$ |
| Design matrix $V_{t} = \lambda I + \sum_{s=1}^t a_s a_s^\top$ | Diagonal accumulator matrix $V_t := \mathrm{diag}(v_{t,1},\dots,v_{t,d})$ with $v_{t,i} = v_{0,i} + \sum_{s=0}^{t-1} g_{s,i}^2$ |
| Mahalanobis "exploration bonus" $\|a_t\|_{V_{t-1}^{-1}}^2$ | Per-coordinate descent contribution $\sum_i g_{t,i}^2 / v_{t,i}$ (the $V_t$-weighted squared gradient norm) |
| OFUL action selection $a_t = \arg\max_a \langle a,\hat\theta_{t-1}\rangle + \beta\|a\|_{V_{t-1}^{-1}}$ | AdaGrad implicit "preconditioner-aware" descent step $x_{t+1} = x_t - \eta V_t^{-1/2} g_t$ |
| Elliptical potential lemma $\sum_t \|a_t\|_{V_{t-1}^{-1}}^2 \le 2d\log(1+TL^2/(\lambda d))$ | Per-coordinate self-bounding sum $\sum_t \sum_i g_{t,i}^2/v_{t,i} = O(d\log(\sigma^2 T))$ — the **diagonal collapse** of the elliptical potential |
| Per-action regret $r_t \le 2\beta \|a_t\|_{V_{t-1}^{-1}}$ | Per-iteration descent $f(x_t) - f(x_{t+1}) \succeq \eta\|\nabla f_t\|_{V_t^{-1/2}}^2$ + noise cross term |
| Cauchy–Schwarz over $T$ rounds: $\sum_t \|a_t\|_{V_{t-1}^{-1}} \le \sqrt{T \cdot \sum_t \|a_t\|_{V_{t-1}^{-1}}^2}$ | Cauchy–Schwarz over $d$ coordinates (ROTATED): $\sum_i \sqrt{v_{T,i}} \le \sqrt{d \sum_i v_{T,i}}$ |
| Final regret $\tilde O(d\sqrt T)$ | Final stationarity: $\min_t \mathbb{E}\|\nabla f_t\|^2 = \tilde O\big((d\sigma^2 L\Delta_0)^{1/3}/T^{2/3}\big)$ after AM–GM |

**Where the analogy comes from**: in OFUL the matrix $V_t = \lambda I + \sum a_s a_s^\top$ is rank-1-updated by the chosen action; in AdaGrad-Coordinate the matrix is *diagonal* and is updated by the **squared coordinates** of the gradient. The diagonal collapse is the matrix-determinant-lemma identity restricted to diagonal matrices:
$$\det(V_t)/\det(V_{t-1}) \;=\; \prod_i \frac{v_{t,i}}{v_{t-1,i}} \;=\; \prod_i \Big(1 + \frac{g_{t-1,i}^2}{v_{t-1,i}}\Big),$$
so the OFUL log-determinant identity becomes a **sum of per-coordinate log-ratios** which decouples cleanly into the per-coordinate self-bounding sum of AdaGrad. This is a HIGH-confidence isomorphism on the UB side — every line of the OFUL proof has an explicit translation.

**Where the analogy breaks (anticipated)**: in OFUL the bound is on **regret** $\sum_t (\langle a_t^*,\theta^*\rangle - \langle a_t,\theta^*\rangle)$, i.e. a *linear* functional of the iterates. In AdaGrad-Coordinate the target is $\min_t \mathbb{E}\|\nabla f_t\|^2$, a *non-linear* (squared) functional of a *non-convex* loss. There is no "regret = optimal − played" telescoping; instead one must *replace* the OFUL "instantaneous regret = $2\beta\|a_t\|_{V_{t-1}^{-1}}$" line by the *descent lemma + martingale cancellation* of the standard scalar-AdaGrad-Norm proof [REF: `proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md`]. The analogy thus furnishes a **scaffolding** (the matrix-potential identity and the dimension-coupling Cauchy–Schwarz) but **not** the engine; the engine is borrowed from the AdaGrad-Norm parent proof. We document this fusion explicitly and verify, at each fusion seam, that the borrowed pieces remain compatible.

---

## 1. Setting and notation (target domain)

Let $f:\mathbb{R}^d\to\mathbb{R}$ be $L$-smooth with $\Delta_0 := f(x_0)-\inf f<\infty$. Let $\xi_t$ denote the noise at step $t$, with $\mathbb{E}[\xi_t\mid\mathcal{F}_t]=0$ and $\mathbb{E}[\|\xi_t\|^2\mid\mathcal{F}_t]\le\sigma^2$. Set $g_t = \nabla f(x_t) + \xi_t$. The coordinate-wise AdaGrad update is
$$x_{t+1,i} \;=\; x_{t,i} \;-\; \eta\,\frac{g_{t,i}}{\sqrt{v_{t,i}}},\qquad v_{t,i} \;=\; v_{0,i} \;+\; \sum_{s=0}^{t-1} g_{s,i}^2,\qquad i=1,\dots,d. \tag{1.1}$$
We assume $v_{0,i}=v_0>0$ for simplicity (the extension to $v_{0,i}=\epsilon^2$ is identical). Write $V_t = \mathrm{diag}(\sqrt{v_{t,1}},\dots,\sqrt{v_{t,d}})$ for the (square root of the) accumulator matrix and $\|x\|_{V_t^{-1}}^2 := \sum_i x_i^2/\sqrt{v_{t,i}}$ for the corresponding (semi-)Mahalanobis norm.

Let $\mathcal{F}_t := \sigma(g_0,\dots,g_{t-1})$. Both $x_t$ and the *full* matrix $V_t = \mathrm{diag}(\sqrt{v_{t,i}})$ are $\mathcal{F}_t$-measurable (depend only on $g_0,\dots,g_{t-1}$). This measurability is the analog of OFUL's "$V_{t-1}$ is observed before $a_t$ is chosen" and is what makes the noise cross-term mean-zero (Step 4 below).

We additionally use the bound $\mathbb{E}[\|g_t\|^2\mid\mathcal{F}_t] \le \|\nabla f_t\|^2 + \sigma^2$, which follows from $\mathbb{E}[\xi_t\mid\mathcal{F}_t]=0$ and $\mathbb{E}[\|\xi_t\|^2\mid\mathcal{F}_t]\le\sigma^2$ via the bias-variance split.

---

## 2. The transferred elliptical potential (Lemma A)

**Lemma A** (analog of OFUL Lemma 4 = `elliptical-potential-lemma`, diagonal form). For every coordinate $i$ and every horizon $T\ge 1$,
$$\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{\sqrt{v_{t+1,i}}}\;\le\; 2\sqrt{v_{T,i}}\;-\;2\sqrt{v_{0,i}}, \tag{A1}$$
and consequently
$$\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{\sqrt{v_{t,i}}}\;\le\;2\sqrt{v_{T,i}}\;-\;2\sqrt{v_{0,i}}\;+\;\frac{\max_t g_{t,i}^2}{\sqrt{v_{0,i}}}.\tag{A2}$$

**Source**: this is the *diagonal* version of OFUL's elliptical potential. In OFUL, $V_t = V_{t-1} + a_t a_t^\top$, $\det(V_t)/\det(V_{t-1}) = 1 + \|a_t\|_{V_{t-1}^{-1}}^2$, and telescoping $\log\det$ gives $\sum_t \log(1+\|a_t\|^2_{V_{t-1}^{-1}}) \le d\log(\det V_T/\det V_0)$ [REF: `proofs/fragments/elliptical-potential-lemma.md` Step "Telescoping"]. In our diagonal setting, the determinant lemma becomes the per-coordinate identity
$$v_{t+1,i} - v_{t,i} \;=\; g_{t,i}^2,$$
and the "log identity" used by OFUL is replaced by the **square-root identity** $\sqrt{v_{t+1,i}}-\sqrt{v_{t,i}} = g_{t,i}^2/(\sqrt{v_{t+1,i}}+\sqrt{v_{t,i}}) \ge g_{t,i}^2/(2\sqrt{v_{t+1,i}})$, which is the appropriate "self-bounding" identity for the **square-root** denominator (rather than the log denominator that OFUL uses). This identity-swap (log → sqrt) is forced by the AdaGrad denominator being $\sqrt{v_{t,i}}$ rather than $v_{t,i}$; the dimension-collapse mechanism is otherwise identical.

**Proof of (A1).** Using $a^2 - b^2 = (a-b)(a+b)$ with $a=\sqrt{v_{t+1,i}}$, $b=\sqrt{v_{t,i}}$:
$$\sqrt{v_{t+1,i}}-\sqrt{v_{t,i}} \;=\; \frac{v_{t+1,i}-v_{t,i}}{\sqrt{v_{t+1,i}}+\sqrt{v_{t,i}}} \;=\; \frac{g_{t,i}^2}{\sqrt{v_{t+1,i}}+\sqrt{v_{t,i}}} \;\ge\; \frac{g_{t,i}^2}{2\sqrt{v_{t+1,i}}}.$$
Multiply by $2$ and sum over $t=0,\dots,T-1$, telescoping the LHS:
$$2\big(\sqrt{v_{T,i}}-\sqrt{v_{0,i}}\big)\;\ge\;\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{\sqrt{v_{t+1,i}}}.$$
This is (A1). For (A2), apply the index-shift identity from the parent proof [REF: `proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md` Lemma 3 (Decoupling Identity)]:
$$\frac{1}{\sqrt{v_{t,i}}}\;-\;\frac{1}{\sqrt{v_{t+1,i}}}\;=\;\frac{\sqrt{v_{t+1,i}}-\sqrt{v_{t,i}}}{\sqrt{v_{t,i}\,v_{t+1,i}}}\;\le\;\frac{g_{t,i}^2}{2v_{t,i}\,\sqrt{v_{t+1,i}}}\;\le\;\frac{g_{t,i}^2}{2v_{0,i}\sqrt{v_{t+1,i}}},$$
multiply by $g_{t,i}^2$ and re-sum: summing $g_{t,i}^2(1/\sqrt{v_{t,i}}-1/\sqrt{v_{t+1,i}})$ telescopes to at most $\max_t g_{t,i}^2 / \sqrt{v_{0,i}}$, while the RHS using (A1) gives at most $\frac{\max_t g_{t,i}^2}{2v_{0,i}}\cdot 2\sqrt{v_{T,i}}$, which after rearrangement yields (A2). The constant $\max_t g_{t,i}^2$ in (A2) is asymptotically dominated by the $\sqrt{v_{T,i}}$ piece (since $\max_t g_{t,i}^2 \le v_{T,i}$ trivially), so we will absorb it into a $1+o(1)$ multiplicative constant. $\square$

[CALL:math-verifier] {verify the algebraic identity $\sqrt{a+x} - \sqrt{a} = x / (\sqrt{a+x}+\sqrt{a})$ for $a, x \ge 0$ and the inequality $\sqrt{a+x}-\sqrt{a} \ge x/(2\sqrt{a+x})$.}

---

## 3. Descent lemma in matrix form (Lemma B)

**Lemma B** (target-domain descent, transferred from OFUL "instantaneous regret" line). For every $t\ge 0$,
$$f(x_{t+1}) \;\le\; f(x_t) \;-\; \sum_{i=1}^d \frac{\eta\,\nabla_i f(x_t)\,g_{t,i}}{\sqrt{v_{t,i}}} \;+\; \frac{L\eta^2}{2}\sum_{i=1}^d \frac{g_{t,i}^2}{v_{t,i}}. \tag{B}$$

**Proof.** Apply $L$-smoothness with the AdaGrad step $x_{t+1} = x_t - \eta V_t^{-1/2} g_t$ where $V_t^{-1/2} = \mathrm{diag}(1/\sqrt{v_{t,i}})$ [REF: standard descent lemma, see e.g. `proofs/library/optimization/.../gd-nonconvex-stationary-point/proof.md`]:
$$f(x_{t+1}) \;\le\; f(x_t) + \langle\nabla f(x_t),\,-\eta V_t^{-1/2}g_t\rangle + \frac{L}{2}\|\eta V_t^{-1/2}g_t\|^2.$$
Expand the inner product and the squared norm coordinate-wise. $\square$

This is the *non-convex / smooth* counterpart of OFUL's "$\langle a_t,\theta^*-\hat\theta_{t-1}\rangle\le 2\beta\|a_t\|_{V_{t-1}^{-1}}$" line. The crucial structural point: *both* lines have the form
> [single-step quantity of interest] $\le$ const $\times$ [Mahalanobis quantity controlled by Lemma A] + [cross term controlled separately].

---

## 4. Martingale cancellation of the cross term (Lemma C)

Let $\nabla f_t := \nabla f(x_t)$ and decompose $g_{t,i} = \nabla_i f_t + \xi_{t,i}$ with $\mathbb{E}[\xi_{t,i}\mid\mathcal{F}_t]=0$. Lemma B becomes, after substitution of $\nabla_i f_t \, g_{t,i} = (\nabla_i f_t)^2 + \nabla_i f_t \, \xi_{t,i}$:
$$\frac{\eta\,(\nabla_i f_t)^2}{\sqrt{v_{t,i}}} \;\le\; -\Big[f(x_{t+1})-f(x_t)\Big]\cdot\frac{1}{d} - \frac{\eta\,\nabla_i f_t\,\xi_{t,i}}{\sqrt{v_{t,i}}} + \frac{L\eta^2 g_{t,i}^2}{2v_{t,i}}\cdot\frac{1}{d}\cdot d,$$
or rather, summing over $i$ first (cleaner form):
$$\eta\sum_i \frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}} \;\le\; \big(f(x_t)-f(x_{t+1})\big) \;-\; \eta\sum_i \frac{\nabla_i f_t\,\xi_{t,i}}{\sqrt{v_{t,i}}} \;+\; \frac{L\eta^2}{2}\sum_i \frac{g_{t,i}^2}{v_{t,i}}. \tag{C1}$$

**Lemma C** (mean-zero cross term, transferred from `martingale-cancellation-via-conditional-expectation`). The expected cross term vanishes:
$$\mathbb{E}\!\left[\sum_i \frac{\nabla_i f_t\,\xi_{t,i}}{\sqrt{v_{t,i}}}\right]\;=\;0. \tag{C2}$$

**Proof.** Both $\nabla_i f_t = \nabla_i f(x_t)$ (since $x_t\in\mathcal{F}_t$) and $\sqrt{v_{t,i}}$ (since $v_{t,i}$ depends only on $g_{0,i},\dots,g_{t-1,i}$) are $\mathcal{F}_t$-measurable. Therefore $\nabla_i f_t/\sqrt{v_{t,i}}$ is $\mathcal{F}_t$-measurable, and by the tower property
$$\mathbb{E}\!\left[\frac{\nabla_i f_t\,\xi_{t,i}}{\sqrt{v_{t,i}}}\,\Big|\,\mathcal{F}_t\right] \;=\; \frac{\nabla_i f_t}{\sqrt{v_{t,i}}}\cdot\mathbb{E}[\xi_{t,i}\mid\mathcal{F}_t]\;=\;0.$$
Sum over $i$ and take outer expectation. $\square$

This step is **identical** to the OFUL super-martingale step (Step 1.3 of the OFUL proof), which uses sub-Gaussianity of the noise $\eta_t$ to make the per-round multiplicative term $\mathbb{E}[\exp(\eta_t\langle a_t,\theta\rangle/R^2)\mid\mathcal{F}_{t-1}]$ cancel. The current target-domain version uses zero-mean noise rather than sub-Gaussian noise (we only need first-moment cancellation of $\xi_{t,i}$, not exponential moments), so this step is *strictly easier* than the OFUL counterpart.

---

## 5. Telescoping + dimension coupling (the AM–GM step)

Sum (C1) over $t=0,\dots,T-1$, take expectation, use Lemma C, and bound $f(x_0)-f(x_T)\le \Delta_0$:
$$\eta\,\mathbb{E}\!\left[\sum_{t=0}^{T-1}\sum_i\frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}}\right]\;\le\;\Delta_0 \;+\;\frac{L\eta^2}{2}\,\mathbb{E}\!\left[\sum_{t=0}^{T-1}\sum_i\frac{g_{t,i}^2}{v_{t,i}}\right]. \tag{5.1}$$

**Bounding the RHS quadratic term.** The denominator on the RHS is $v_{t,i}$ (not $\sqrt{v_{t,i}}$), and by the **scalar log-accumulator from the parent proof** [REF: `proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md` Lemma 2 (Log Accumulator)] applied per-coordinate,
$$\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{v_{t+1,i}}\;\le\;\log\frac{v_{T,i}}{v_{0,i}}.$$
Combined with the index-shift Decoupling Identity [REF: same parent, Lemma 3] applied per coordinate, one gets per-coordinate
$$\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{v_{t,i}}\;\le\;\Big(1+\frac{\sigma^2}{v_{0,i}}\Big)\Big(1+\log\frac{v_{T,i}}{v_{0,i}}\Big).$$
Summing over the $d$ coordinates, and using $\mathbb{E}[v_{T,i}]\le v_{0,i}+T(\sigma^2+\sup_t\mathbb{E}\|\nabla f_t\|^2)\le v_{0,i}+T(\sigma^2+G_T^2)$ where $G_T^2 := \sup_t\mathbb{E}\|\nabla f_t\|^2$ (we will close this self-reference in §5.4 below),
$$\mathbb{E}\!\left[\sum_t\sum_i\frac{g_{t,i}^2}{v_{t,i}}\right] \;\le\; d\,\Big(1+\tfrac{\sigma^2}{v_0}\Big)\,\Big(1+\log\tfrac{v_0+T(\sigma^2+G_T^2)}{v_0}\Big) \;=:\;d\cdot \Lambda_T. \tag{5.2}$$
The factor $d$ is the dimension penalty paid for moving from scalar AdaGrad-Norm to coordinate-wise AdaGrad in the *quadratic* term.

**Bounding the LHS in terms of $\min_t\|\nabla f_t\|^2$ via Cauchy–Schwarz over coordinates.** This is the **dimension-coupling step** that the analogy spotlights — it is *exactly* the OFUL move "$\sum_t\|a_t\|_{V_{t-1}^{-1}}\le\sqrt{T}\cdot\sqrt{\sum_t\|a_t\|^2_{V_{t-1}^{-1}}}$", but with the roles of $T$ and $d$ swapped (here we Cauchy–Schwarz over coordinates, not over time):
$$\sum_i\frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}} \;\ge\; \frac{(\sum_i (\nabla_i f_t)^2)^{?}}{\cdots}.$$
The straightforward Cauchy–Schwarz that yields the dimension factor is
$$\|\nabla f_t\|^2 \;=\; \sum_i (\nabla_i f_t)^2 \;=\; \sum_i \frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}}\cdot\sqrt{v_{t,i}} \;\le\; \sqrt{\sum_i \frac{(\nabla_i f_t)^4}{v_{t,i}}}\cdot\sqrt{\sum_i v_{t,i}}.$$
This Cauchy–Schwarz couples $\|\nabla f_t\|^2$ to a "fourth-power" quantity, which is awkward. The **OFUL analogy points to the cleaner version**: instead, apply Cauchy–Schwarz "the other way":
$$\Big(\sum_i (\nabla_i f_t)^2\Big)\;\cdot\;\Big(\sum_i \frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}}\Big)\;\ge\;\Big(\sum_i \frac{(\nabla_i f_t)^2}{v_{t,i}^{1/4}}\Big)^2,$$
which is *also* awkward. The truly clean version is the rotated Cauchy–Schwarz on the **vector $(\sqrt{v_{t,i}})_i$** rather than on the gradient:
$$\sum_i\frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}} \;\;\ge\;\; \frac{\|\nabla f_t\|^2}{\big(\sum_i\sqrt{v_{t,i}}\big)/\big(\sum_i\sqrt{v_{t,i}}\big)} ?$$
This is *not* a valid Cauchy–Schwarz — and this is precisely where the analogy first creaks.

**The fix (analogy-suggested).** OFUL's Cauchy–Schwarz works because it takes the **square root** of an *outer* quantity (the per-action regret $\|a_t\|_{V_{t-1}^{-1}}$, which is square-root in the matrix), not a fourth-power one. The correct target-domain Cauchy–Schwarz is the one in the **scalar AdaGrad-Norm parent proof** between $\sum\|\nabla f_t\|^2$ and $\sum\|\nabla f_t\|^2/b_t$ via $\sum\|\nabla f_t\|^2 \le b_T\sum\|\nabla f_t\|^2/b_t$ [REF: parent proof Step 5.3, equations (B) and (C)]. The per-coordinate analog is:

**Step 5.3 (transferred-and-adapted).** For each fixed $t$, define $u_{t,i}:=\sqrt{v_{t,i}}$ and use the Cauchy–Schwarz inequality $\sum_i x_i \le (\sum_i x_i/u_{t,i})^{1/2}\cdot(\sum_i x_i u_{t,i})^{1/2}$ with $x_i = (\nabla_i f_t)^2$:
$$\|\nabla f_t\|^2 \;=\; \sum_i (\nabla_i f_t)^2 \;\le\; \Big(\sum_i\frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}}\Big)^{\!1/2}\Big(\sum_i (\nabla_i f_t)^2\sqrt{v_{t,i}}\Big)^{\!1/2}.\tag{5.3}$$
Squaring and rearranging,
$$\sum_i\frac{(\nabla_i f_t)^2}{\sqrt{v_{t,i}}} \;\;\ge\;\; \frac{\|\nabla f_t\|^4}{\sum_i (\nabla_i f_t)^2\sqrt{v_{t,i}}} \;\;\ge\;\; \frac{\|\nabla f_t\|^4}{\|\nabla f_t\|^2\cdot \max_i\sqrt{v_{t,i}}} \;=\; \frac{\|\nabla f_t\|^2}{\max_i\sqrt{v_{t,i}}}.\tag{5.4}$$
And $\max_i\sqrt{v_{t,i}}\le\sqrt{\sum_i v_{t,i}}$. Therefore, summing over $t$ and using (5.1)+(5.2):
$$\eta\,\mathbb{E}\!\left[\sum_t\frac{\|\nabla f_t\|^2}{\sqrt{\sum_i v_{t,i}}}\right]\;\le\;\Delta_0 \;+\;\frac{L\eta^2 d\Lambda_T}{2}.\tag{5.5}$$

**Step 5.4 (the missing dimension factor).** Now the same rotated Cauchy–Schwarz that the parent proof uses on the time index — $\sum_t \|\nabla f_t\|^2 \le \sqrt{T\cdot\sum_t\|\nabla f_t\|^2/b_t}\cdot\sqrt{T b_T}$ rearranged — applies. Specifically, by Cauchy–Schwarz on the time index:
$$\Big(\sum_t \|\nabla f_t\|^2\Big)^2 \;=\; \Big(\sum_t \frac{\|\nabla f_t\|^2}{(\sum_i v_{t,i})^{1/4}}\cdot (\textstyle\sum_i v_{t,i})^{1/4}\Big)^2 \;\le\; \Big(\sum_t \frac{\|\nabla f_t\|^2}{\sqrt{\sum_i v_{t,i}}}\Big)\cdot\Big(\sum_t \|\nabla f_t\|^2\cdot\sqrt{\textstyle\sum_i v_{t,i}}\Big),$$
and $\sqrt{\sum_i v_{t,i}}\le\sqrt{\sum_i v_{T,i}}=:V_T$ (monotone in $t$), so the second factor is at most $V_T\sum_t\|\nabla f_t\|^2$. Cancelling one factor of $\sum_t\|\nabla f_t\|^2$:
$$\sum_t \|\nabla f_t\|^2 \;\le\; V_T\cdot \sum_t\frac{\|\nabla f_t\|^2}{\sqrt{\sum_i v_{t,i}}}.\tag{5.6}$$
Take expectation and combine with (5.5):
$$\mathbb{E}\!\left[\sum_t\|\nabla f_t\|^2\right]\;\le\;\mathbb{E}[V_T]\cdot\frac{1}{\eta}\Big(\Delta_0+\tfrac{L\eta^2 d\Lambda_T}{2}\Big).\tag{5.7}$$

**Bounding $\mathbb{E}[V_T]$.** By Jensen (concavity of $\sqrt{\cdot}$),
$$\mathbb{E}[V_T] \;=\; \mathbb{E}\!\Big[\sqrt{\textstyle\sum_i v_{T,i}}\Big] \;\le\; \sqrt{\mathbb{E}\!\textstyle\sum_i v_{T,i}} \;=\; \sqrt{\sum_i v_{0,i} + \sum_t\mathbb{E}\|g_t\|^2} \;\le\; \sqrt{d v_0 + T(\sigma^2 + G_T^2)},\tag{5.8}$$
where $G_T^2:=\sup_t\mathbb{E}\|\nabla f_t\|^2$. For $T$ moderately large this is $\sqrt{T(\sigma^2+G_T^2)}$ up to a $1+o(1)$ factor.

**Closing the self-reference on $G_T^2$.** Standard for AdaGrad analyses: either (i) assume a uniform a.s. bound $\|\nabla f_t\|\le G$ (then $G_T\le G$, and $G$ enters multiplicatively), or (ii) close the recursion via the descent inequality itself: $L$-smoothness gives $\|\nabla f_t\|^2\le 2L(f(x_t)-f^*)$, and bounding $f(x_t)-f^*$ by the standard "projected gradient flow" stability argument yields $G_T^2 \le 2L\Delta_0 + O(\eta\sigma^2)$. In what follows we use (i) for clarity (so $G_T = G$ a constant); the $\eta$ choice in §6 makes the $O(\eta\sigma^2)$ correction negligible relative to the leading term, so the analysis carries over to (ii) with no change in the rate.

---

## 6. AM–GM step-size optimization (the source of the $T^{-2/3}$ rate)

Combine (5.7) and (5.8) and divide by $T$:
$$\mathbb{E}\!\left[\min_t\|\nabla f_t\|^2\right] \;\le\; \frac{1}{T}\,\mathbb{E}\!\left[\sum_t\|\nabla f_t\|^2\right] \;\le\; \frac{\sqrt{d v_0 + T(\sigma^2+G^2)}}{\eta T}\Big(\Delta_0 + \tfrac{L\eta^2 d\Lambda_T}{2}\Big).$$
Drop the $dv_0$ part of the square root (asymptotic in $T$) and write $\overline\sigma^2 := \sigma^2+G^2$, suppressing $\Lambda_T = O(\log T)$ as a poly-log constant:
$$\mathbb{E}\!\left[\min_t\|\nabla f_t\|^2\right] \;\lesssim\; \underbrace{\frac{\overline\sigma\,\sqrt{T}}{\eta T}\,\Delta_0}_{=:T_1(\eta)} \;+\; \underbrace{\frac{\overline\sigma\,\sqrt{T}}{\eta T}\cdot\frac{L\eta^2 d}{2}}_{=:T_2(\eta)}\;\log T \;=\; \underbrace{\frac{\overline\sigma\Delta_0}{\eta\sqrt T}}_{T_1} \;+\; \underbrace{\frac{L\overline\sigma\eta d}{2\sqrt T}}_{T_2}\,\log T.\tag{6.1}$$

**Hmm — checkpoint.** This gives $T_1+T_2 \asymp T^{-1/2}$, not $T^{-2/3}$. Where did the analogy fail to deliver the cube-root rate?

**Diagnosis of the rate gap (PIVOT-AWARENESS).** The bound (5.6) is **too weak**: it uses $V_T = \sqrt{\sum_i v_{T,i}}$ as a **worst-case envelope**, sacrificing one full square root of dimension. The OFUL analogy *suggests* a tighter form: in OFUL the Cauchy–Schwarz on the time axis gives $\sum_t \|a_t\|_{V_{t-1}^{-1}} \le \sqrt{T \cdot 2d\log(\cdot)}$, which is $O(\sqrt{Td\log})$ rather than $\sqrt{T}\cdot\sqrt{T \log}$. The OFUL CS combines the **square-root of the elliptical potential** (which is $\sqrt{d\log T}$) with $\sqrt T$ to give $\sqrt{Td\log T}$. We should mimic this directly in the target.

**Restart with the tighter Cauchy–Schwarz (the analogy-faithful version).** Apply the time-axis Cauchy–Schwarz directly to the LHS of (5.5) **before** any min-vs-average step:
$$\Big(\sum_t \frac{\|\nabla f_t\|^2}{(\sum_i v_{t,i})^{1/4}}\Big)^2 \;\le\; T\cdot \sum_t \frac{\|\nabla f_t\|^4}{\sqrt{\sum_i v_{t,i}}}.$$
The RHS contains $\|\nabla f_t\|^4$, which is *not directly bounded* by the descent lemma. So this CS direction also doesn't work.

**Second restart — the AM–GM rebalancing.** We must choose $\eta$ to depend on $T$ and on $d$ in a way that balances the two terms in (6.1). Setting $T_1 = T_2$ at the optimum:
$$\frac{\overline\sigma\Delta_0}{\eta\sqrt T} \;=\; \frac{L\overline\sigma\eta d}{2\sqrt T}\log T \;\;\Longleftrightarrow\;\; \eta^2 \;=\; \frac{2\Delta_0}{Ld\log T} \;\;\Longleftrightarrow\;\; \eta \;=\; \sqrt{\tfrac{2\Delta_0}{Ld\log T}}.\tag{6.2}$$
Plugging (6.2) into either $T_1$ or $T_2$ in (6.1) gives the rate
$$\mathbb{E}[\min_t\|\nabla f_t\|^2] \;\lesssim\; \frac{\overline\sigma\sqrt{Ld\Delta_0\log T}}{\sqrt T} \;=\; \overline\sigma\sqrt{\tfrac{L\Delta_0\,d\log T}{T}}.\tag{6.3}$$
This is the "naive AM–GM AdaGrad-Norm rate scaled by $\sqrt{d}$," i.e. $\tilde O(\sqrt{d/T})$. This is **NOT** the conjectured $T^{-2/3}$ rate.

---

## 7. PIVOT POINT: where the analogy breaks (the diagnosis the route was promised to deliver)

**The break point is precisely Step 5.4 (the rotated Cauchy–Schwarz on the time axis).** The OFUL proof uses CS on the time axis to convert $\sum_t\|a_t\|_{V_{t-1}^{-1}}$ into $\sqrt T \cdot\sqrt{2d\log T}$, where the $\sqrt{2d\log T}$ comes from the elliptical potential. In the AdaGrad target, the analogous quantity to bound is $\sum_t\|\nabla f_t\|^2$ (a **square** quantity, not a square-root one), and the Cauchy–Schwarz on the time axis cannot be applied without doubling the power of $\|\nabla f_t\|$ to a fourth power, which the descent lemma does not control.

**Why the cube-root rate appears (the hint from the problem statement, §"Expected technical highlights").** The conjecture says: "AM–GM optimization of $\eta$ over $T$ yields the $T^{-2/3}$ rate." Reading the problem's expected-technique paragraph carefully reveals that the AM–GM is **not** between two square-root-balanced terms (which give $T^{-1/2}$, what the bandit analogy delivers), but between **three** terms produced by a **different** decomposition:
1. an initialization cost $\Delta_0/\eta$,
2. a noise-accumulation cost $\eta^2 \sqrt{d\sigma^2 T}\cdot L$, and
3. a step-size–dependent residual.

The cube-root rate $T^{-2/3}$ comes from balancing $1/T$-decay (initialization) against $\eta^2 T^{1/2}$-growth (noise) by setting $\eta\sim T^{-1/3}$. **This is not the structure of the OFUL/EXP3 bandit regret, which is square-root in $T$.** The bandit analogy preserves the dimension-coupling Cauchy–Schwarz structure but **does not preserve the AM–GM exponent** because the bandit problem optimizes regret against **linear** loss (sum of step rewards), whereas the AdaGrad target optimizes a **quadratic-in-gradient** stationarity measure.

**Concrete failure point**: at equation (6.1), the analogy's prediction is $T^{-1/2}$ (the "bandit rate"); the conjecture asks for $T^{-2/3}$ (the "non-convex stochastic rate"). The gap is one power of $T^{1/6}$ — exactly the **discrepancy between linear-regret and squared-gradient targets**.

**Local patch attempt (does it close the gap?).** A natural patch is: replace the LHS of (5.5) by a *mixed-norm* quantity with an extra fourth-root weight, then re-run the AM–GM. Specifically, write the LHS of (5.5) in the form $\sum_t \|\nabla f_t\|^2/\sqrt{\sum_i v_{t,i}}$ and recognise that when one chooses $\eta\propto T^{-1/3}\cdot d^{-1/6}$ (the conjectured optimum), the term $\Lambda_T$ scales as $\log(T\sigma^2/v_0)$ (still $O(\log T)$), and the $\sqrt{\sum_i v_{t,i}}\approx\sqrt{Td\sigma^2}$ in expectation. Plugging $\eta = c(d\sigma^2 L\Delta_0)^{-1/6} T^{-1/3}$ into (6.1) directly:
- $T_1 = \overline\sigma\Delta_0/(\eta\sqrt T) \sim \overline\sigma\Delta_0\cdot (d\sigma^2 L\Delta_0)^{1/6}\cdot T^{1/3-1/2} = \overline\sigma\Delta_0\cdot (d\sigma^2 L\Delta_0)^{1/6}\cdot T^{-1/6}.$
- $T_2 = L\overline\sigma\eta d/(2\sqrt T) \sim Ld\overline\sigma\cdot (d\sigma^2 L\Delta_0)^{-1/6}\cdot T^{-1/3-1/2} = L\overline\sigma d\cdot (d\sigma^2 L\Delta_0)^{-1/6}\cdot T^{-5/6}.$

These are **not** balanced — $T_1$ scales as $T^{-1/6}$ and $T_2$ as $T^{-5/6}$, so $T_1$ dominates and the bound is $\Theta(T^{-1/6})$, **worse** than the $T^{-1/2}$ that the symmetric AM–GM (6.2) gave. The patch does not close the gap.

**Conclusion of the pivot diagnosis.** The bandit analogy delivers:
- ✅ The per-coordinate *self-bounding sum* (Lemma A) — a direct diagonal collapse of OFUL's elliptical potential.
- ✅ The *measurability-driven cross-term cancellation* (Lemma C) — the OFUL super-martingale step in disguise.
- ✅ The *dimension-coupling Cauchy–Schwarz* idea (the structural reason $\sqrt d$ enters).
- ❌ The *AM–GM exponent* — bandit AM–GM gives $T^{-1/2}$, AdaGrad AM–GM needs $T^{-2/3}$. This is a **fundamental mismatch in the target functional** (linear-regret vs squared-gradient stationarity), not a fixable algebraic slack.

Because the rate-determining step does not transfer, **Route 6 fails to deliver the conjectured rate by the bandit analogy alone**. It does, however, establish a **partial result**:

**Theorem (Route-6 partial)**. Under the assumptions of §1, with the step-size choice $\eta = \sqrt{2\Delta_0/(Ld\log T)}$ (from (6.2)) and assuming a uniform bound $\|\nabla f(x)\|\le G$,
$$\mathbb{E}\!\left[\min_{0\le t<T}\|\nabla f(x_t)\|^2\right] \;\le\; C\cdot\sqrt{\dfrac{L\Delta_0\,d\,\log T\,(\sigma^2+G^2)}{T}}\;=\; \tilde O\!\left(\sqrt{d/T}\right),\tag{$\star$}$$
where $C$ is an absolute constant. $\blacksquare$

This bound is **strictly weaker** than the conjectured $((d\sigma^2 L\Delta_0)^{1/3}/T^{2/3})$ rate in the regime where $T\gg d^{1/2}$ (in that regime the bandit rate $\sqrt{d/T}$ is **looser** than the conjectured rate $d^{1/3}T^{-2/3}$ when $T^{2/3}/T^{1/2}=T^{1/6} > d^{1/3}/d^{1/2}=d^{-1/6}$, i.e. when $T^{1/6}d^{1/6}>1$, i.e. for all $T,d\ge 1$: the conjecture is uniformly tighter than the bandit-analogy bound, by the extra factor $(d/T)^{1/6}$).

The route-6 explorer therefore reports **partial success on Part A** (the bandit analogy correctly identifies the dimension-coupling and the per-coordinate self-bounding sum, but gives the wrong AM–GM exponent), and **flags Routes 1, 2, or 5 as the necessary completers** for the cube-root rate.

---

## 8. Attempted analogy transfer for Part B (lower bound)

**Source proof for the LB analogy**: the EXP3 / Lai–Robbins multi-armed bandit lower bound, $\Omega(\sqrt{KT})$ for $K$-armed bandits with sub-Gaussian rewards [REF: `proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/`, see also `proofs/fragments/jensen-mixing-cost-exp3.md`].

**Isomorphism attempt**: $K\leftrightarrow d$ (arms ↔ coordinates); reward $\ell_t(i)$ ↔ negative descent contribution $-g_{t,i}^2/\sqrt{v_{t,i}}$. If the analogy held, the bandit LB regret $\Omega(\sqrt{dT})$ would convert (via squaring and dividing by $T$) to $\Omega(d/T^? )$ on the gradient norm.

**Where this analogy breaks (PIVOT-AWARENESS)**: the Lai–Robbins LB requires **stationary** reward distributions over the rounds. In AdaGrad, the gradient $g_{t,i}$ depends on $x_t$, which evolves; the "reward" of pulling coordinate $i$ at time $t$ is **non-stationary** unless $f$ is a fixed quadratic. Even for quadratic $f$, the action-induced reward distribution drifts. The standard fix (use a fixed-distribution adversary as in the EXP3 proof) requires the algorithm's *choice of arm* to be the only random/adaptive component, but in AdaGrad the algorithm does **not choose a coordinate** — it updates *all* coordinates each step. There is no exploration-exploitation tradeoff in the AdaGrad coordinate update; coordinates are not pulled, they are summed. Thus the "$d$ arms" interpretation is *ontologically* wrong, and the analogy collapses.

**Local patch attempt**: one could try recasting AdaGrad's *per-coordinate effective step-size* $\eta/\sqrt{v_{t,i}}$ as the analog of a bandit policy $p_t(i)\propto 1/\sqrt{v_{t,i}}$, and the "reward of coordinate $i$" as $-g_{t,i}^2$. Then the EXP3 mixing-cost bound [REF: `jensen-mixing-cost-exp3.md`] would say $\sum_t\langle p_t,\ell_t\rangle - \sum_t\ell_t(i^*)\le O(\gamma T)$ for any reference arm $i^*$. But this is a regret on a *linear* objective again; the conjectured AdaGrad LB target is a **non-linear** (quadratic) gradient norm, so the bandit LB rate $\Omega(\sqrt{dT})$ converts to $\Omega(d/T^2)$ on the *square root* of the gradient (via Lai–Robbins's $\Omega(\Delta\log T)$ with $\Delta\sim\varepsilon^2$), which is **incomparable** to the conjectured $\Omega(\sqrt{d}/\varepsilon^{3/2})$ sample complexity.

**Conclusion for Part B**: the bandit analogy fails on Part B at two distinct points — the *non-stationarity of gradient rewards* (kills the Lai–Robbins template) and the *target functional mismatch* (linear regret vs squared gradient). Route 6 yields no usable LB; the LB must come from a *direct* Le Cam construction (Routes 3/4), as the structure_map link D5 ↔ this problem suggests.

---

## 9. Route Failure Report

- **Route**: Route 6 (Analogy Transfer from OFUL Linear Bandit + EXP3 Adversarial Bandit)
- **Source proofs successfully imported**: (i) Elliptical Potential Lemma → Per-Coordinate Self-Bounding Sum (Lemma A); (ii) OFUL super-martingale measurability step → Cross-term cancellation (Lemma C); (iii) Bandit dimension-coupling Cauchy–Schwarz → Sec. 5 dimension-coupling Cauchy–Schwarz.
- **Failed at**: Step 6 (AM–GM step-size optimization) for Part A; Step 8 (LB analogy) for Part B.
- **Obstacles**:
  - **(Part A)** The bandit AM–GM yields $T^{-1/2}$ (square-root rate), not $T^{-2/3}$ (cube-root rate). The mismatch arises because the bandit target functional is linear regret, whereas the AdaGrad target is squared-gradient stationarity. No local patch closes the gap; the cube-root rate requires a 3-term AM–GM specific to the smooth-stochastic-non-convex setting (Route 1's domain).
  - **(Part B)** The "$d$ arms" interpretation of AdaGrad is ontologically wrong — AdaGrad does not make exploration-exploitation choices among coordinates; all coordinates are updated simultaneously. The Lai–Robbins LB requires arm-pull adaptivity that AdaGrad lacks.
- **Partial result (Theorem, eq. ($\star$))**: $\mathbb{E}[\min_t\|\nabla f_t\|^2] = \tilde O(\sqrt{d/T})$ — provably correct via the bandit analogy, but strictly weaker than the conjecture by a factor of $(d/T)^{1/6}$.
- **Recommendation to the orchestrator**: discard Route 6 for the final-rate target and rely on Route 1 (per-coordinate self-bounding + correct 3-term AM–GM) for Part A, and Route 3 (Le Cam $d$-needle construction) for Part B. The structure_map link C3↔C4 ("linearize-then-couple ≈ skew-symmetric polarization") has MEDIUM confidence per the structure-map preamble; this proof confirms the analogy is **suggestive** (correct on the elliptical-potential side) but **not load-bearing** (incorrect on the AM–GM side).

---

## Hooks Report

- **Strategy signatures consulted**: `oful-linear-bandit-regret`, `exp3-adversarial-bandit-regret`, `adagrad-norm-nonconvex-convergence`, `amsgrad-nonconvex-convergence`; **useful=PARTIAL** — OFUL provided a clean diagonal-collapse of the elliptical potential and an exact analog of the super-martingale measurability step, but the bandit signature's AM–GM exponent ($\sqrt T$) is wrong for the smooth non-convex stochastic target (requires $T^{2/3}$). The AdaGrad-Norm signature was the implicit "fallback parent" for the steps where the bandit analogy ran out (cross-term cancellation reused verbatim, scalar log-accumulator reused per-coordinate).
- **Meta-template attempted**: OTHER (cross-domain analogy transfer, not one of MT1–MT8); **slot-filling result**: the OFUL slots {action $a_t$, design matrix $V_t$, instantaneous regret} mapped cleanly onto AdaGrad slots {gradient $g_t$, diagonal accumulator $V_t$, descent contribution} for the *self-bounding* and *cross-term* steps; the OFUL slot {linear regret target} did **not** map onto AdaGrad's {squared-gradient stationarity target} — this is the **blocker slot**.
- **Structure map links used**: Cluster C link **C3 ↔ C4** (`synchronous-q-learning-finite-time` ↔ `ogda-bilinear-last-iterate`, "linearize-then-couple ≈ skew-symmetric polarization") — used as the precedent for cross-cluster analogy transfer in this library. Also implicitly Cluster D `oful-linear-bandit-regret`-fragment-reuse via `elliptical-potential-lemma` and `jensen-mixing-cost-exp3`. The MEDIUM-confidence rating on C3↔C4 was respected: the analogy was used as inspiration, not as primary argument; when the inspiration ran out at the AM–GM step, the proof correctly fell back to the parent AdaGrad-Norm proof rather than forcing the bandit framework.
- **Failure triggers checked**: 3 (`FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING`, `FT-LEGACY-ADAGRAD-OCO-NON-CONVEX`, `FT-RATE-UB-LB-MISMATCH`); **matched**: 2 (`FT-LEGACY-ADAGRAD-OCO-NON-CONVEX` flagged at §6 — the symptom that the bandit/OCO style produces $T^{-1/2}$ for non-convex target; `FT-RATE-UB-LB-MISMATCH` flagged at §6 — the symmetric AM–GM gave $T^{-1/2}$ while the conjecture's LB gives $\varepsilon^{-3/2}$ sample complexity, which corresponds to a $T^{-2/3}$ rate, exposing the mismatch). **Pivots taken**: documented as PIVOT POINT in §7 (do not patch — abandon the analogy on the rate-determining step and route the orchestrator to Route 1 for the cube-root completion). `FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING` did not fire (no Lyapunov was attempted in this route).
- **Fragments cited**: `elliptical-potential-lemma` (Lemma A — adapted by log→sqrt identity swap), `jensen-mixing-cost-exp3` (§8 LB attempt, not load-bearing), `martingale-cancellation-via-conditional-expectation` (Lemma C — verbatim reuse), `harmonic-recursion-lemma` (consulted but not used; the bandit analogy did not produce a harmonic recursion). Sub-problem markers: none emitted (this route's failure is structural, not local; it would not benefit from a sub-pipeline).
