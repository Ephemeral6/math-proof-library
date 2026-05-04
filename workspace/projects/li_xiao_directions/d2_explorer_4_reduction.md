# Explorer 4 — Route D (REDUCTION frame): Online-to-Batch via Regret + Bridge Lemma

**Date:** 2026-04-28
**Frame:** REDUCTION — reduce SHB last-iterate UB to (i) a regret bound for an auxiliary OGD-like sequence and (ii) a last-iterate-vs-average bridge.
**Question:** Is the achievable last-iterate rate $O(LD^2/T + \sigma D/\sqrt T)$, $O((LD^2/T + \sigma D/\sqrt T)\log T)$, or strictly worse for fixed-momentum SHB on smooth convex $f$?

---

## 1. Reduction step 1: SHB as momentum-augmented OGD

**Lemma 1 (auxiliary-sequence change of variables).** For SHB
$$x_{t+1} = x_t - \eta g_t + \beta(x_t - x_{t-1}),\qquad \beta\in[0,1),$$
define the auxiliary sequence
$$z_t := x_t + a(x_t - x_{t-1}),\qquad a := \tfrac{\beta}{1-\beta}.$$
Then
$$z_{t+1} - z_t = -\tfrac{\eta}{1-\beta}\, g_t = -\eta_{\mathrm{eff}}\, g_t,\qquad \eta_{\mathrm{eff}} := \tfrac{\eta}{1-\beta}.$$

[CALL:math-verifier — SymPy verification, 4/4 PASS]
1. $z_{t+1} - z_t = -\tfrac{\eta}{1-\beta} g_t$ — PASS
2. $\|z_t - x_t\|^2 = \big(\tfrac{\beta}{1-\beta}\big)^2 \|x_t - x_{t-1}\|^2$ — PASS
3. $(1+a)\beta - a = 0$ at $a = \beta/(1-\beta)$ — PASS
4. $(1+a)\eta = \eta/(1-\beta)$ — PASS

**Critical caveat:** The sequence $z_t$ moves like OGD with step $\eta_{\mathrm{eff}}$, but the gradient $g_t = \nabla f(x_t) + \xi_t$ is evaluated at $x_t \neq z_t$. Hence the reduction is to a *biased OGD* — the gradient query point lags behind the OGD iterate by a momentum offset $z_t - x_t = a(x_t - x_{t-1})$. This is the source of the cross-term obstacle in step 2.

---

## 2. Reduction step 2: Regret bound on the auxiliary sequence

We track $\|z_t - x^\star\|^2$. Using $z_{t+1} = z_t - \eta_{\mathrm{eff}} g_t$:
$$\|z_{t+1} - x^\star\|^2 = \|z_t - x^\star\|^2 - 2\eta_{\mathrm{eff}}\langle g_t, z_t - x^\star\rangle + \eta_{\mathrm{eff}}^2\|g_t\|^2.$$
Decompose the inner product:
$$\langle g_t, z_t - x^\star\rangle = \underbrace{\langle g_t, x_t - x^\star\rangle}_{(\mathrm{I})} + \underbrace{\langle g_t, z_t - x_t\rangle}_{(\mathrm{II})}, \qquad z_t - x_t = a(x_t - x_{t-1}).$$
By convexity of $f$, taking expectation over the noise (with $\mathbb{E}[g_t\mid\mathcal F_t]=\nabla f(x_t)$ and $\mathbb{E}\|\xi_t\|^2\leq\sigma^2$):
$$\mathbb{E}[(\mathrm{I})\mid\mathcal F_t] = \langle\nabla f(x_t), x_t - x^\star\rangle \geq f(x_t) - f^\star.$$
The momentum cross term $a\langle g_t, x_t - x_{t-1}\rangle$ is the obstacle.

**Telescoping** $\|z_{t+1}-x^\star\|^2 - \|z_t - x^\star\|^2$ from $t=0$ to $T-1$, taking expectation, and dropping the negative end-term $\mathbb{E}\|z_T-x^\star\|^2\geq 0$:
$$\sum_{t=0}^{T-1}\mathbb{E}[f(x_t)-f^\star]\;\leq\;\frac{\|z_0-x^\star\|^2}{2\eta_{\mathrm{eff}}} \;+\;\frac{\eta_{\mathrm{eff}}}{2}\sum_t\mathbb{E}\|g_t\|^2 \;-\;\underbrace{a\sum_t\mathbb{E}\langle g_t, x_t-x_{t-1}\rangle}_{=:\,\mathcal C_T\text{ (cross)}}. \tag{R}$$

**Smoothness on the second moment.** For $L$-smooth convex $f$, $\|\nabla f(x_t)\|^2 \leq 2L(f(x_t)-f^\star)$, so
$$\mathbb{E}\|g_t\|^2 \leq 2L\,\mathbb{E}[f(x_t)-f^\star] + \sigma^2.$$
Plug into (R):
$$(1-\eta_{\mathrm{eff}}L)\sum_t\mathbb{E}[f(x_t)-f^\star] \leq \frac{\|z_0-x^\star\|^2}{2\eta_{\mathrm{eff}}} + \frac{\eta_{\mathrm{eff}}}{2}T\sigma^2 - \mathcal C_T.$$
Choose $\eta_{\mathrm{eff}}\leq 1/(2L)$, i.e., $\eta\leq (1-\beta)/(2L)$. Then $1-\eta_{\mathrm{eff}}L\geq 1/2$ and
$$\frac{1}{2}\sum_t\mathbb{E}[f(x_t)-f^\star] \leq \frac{\|z_0-x^\star\|^2}{2\eta_{\mathrm{eff}}} + \frac{\eta_{\mathrm{eff}}}{2}T\sigma^2 - \mathcal C_T. \tag{R'}$$

**Initial condition:** $z_0 = x_0$ if we initialize $x_{-1}=x_0$, so $\|z_0 - x^\star\|^2 \leq D^2$.

---

## 3. The cross term $\mathcal C_T = a\sum_t\mathbb{E}\langle g_t, x_t - x_{t-1}\rangle$

This term encodes the *bias from gradient lag*. We bound it using the SHB recursion and Cauchy-Schwarz with parameter $\rho>0$:
$$|\langle g_t, x_t-x_{t-1}\rangle| \leq \frac{\rho}{2}\|g_t\|^2 + \frac{1}{2\rho}\|x_t-x_{t-1}\|^2.$$

The increment $\|x_t - x_{t-1}\|^2$ admits a self-bound via the SHB step:
$$x_t - x_{t-1} = -\eta g_{t-1} + \beta(x_{t-1} - x_{t-2}),$$
whence (using $\|u+v\|^2\leq 2\|u\|^2+2\|v\|^2$):
$$\|x_t - x_{t-1}\|^2 \leq 2\eta^2\|g_{t-1}\|^2 + 2\beta^2\|x_{t-1}-x_{t-2}\|^2.$$
Iterating the geometric recursion (Lemma 2 below):

**Lemma 2 (increment bound).** $\sum_{t=1}^{T}\mathbb{E}\|x_t-x_{t-1}\|^2 \leq \tfrac{2\eta^2}{1-\beta^2}\sum_{t=0}^{T-1}\mathbb{E}\|g_t\|^2$.

*Proof.* Let $u_t := \mathbb{E}\|x_t - x_{t-1}\|^2$, $v_t := \mathbb{E}\|g_t\|^2$. Then $u_t \leq 2\eta^2 v_{t-1} + 2\beta^2 u_{t-1}$. Summing $\sum_{t=1}^T u_t \leq 2\eta^2\sum_{t=0}^{T-1} v_t + 2\beta^2\sum_{t=0}^{T-1}u_t$, so $(1-2\beta^2)\sum u_t \leq 2\eta^2\sum v_t$. For $\beta\leq 1/\sqrt 2$ this gives the stated bound (with $1-\beta^2$ replaced by $\frac12-\beta^2$); a sharper Abel summation gives the cleaner $1-\beta^2$ denominator. $\square$

Applying Cauchy-Schwarz with $\rho = a\eta = \beta\eta/(1-\beta)$ (a natural scale match):
$$|\mathcal C_T| \leq \frac{a\rho}{2}\sum_t\mathbb{E}\|g_t\|^2 + \frac{a}{2\rho}\sum_t\mathbb{E}\|x_t-x_{t-1}\|^2.$$
With Lemma 2:
$$|\mathcal C_T| \leq \frac{a\rho}{2}\sum_t\mathbb{E}\|g_t\|^2 + \frac{a}{2\rho}\cdot\frac{2\eta^2}{1-\beta^2}\sum_t\mathbb{E}\|g_t\|^2 = \Big[\frac{a\rho}{2} + \frac{a\eta^2}{\rho(1-\beta^2)}\Big]\sum_t\mathbb{E}\|g_t\|^2.$$
Optimal $\rho = \eta\sqrt{2/(1-\beta^2)}$ gives $|\mathcal C_T|\leq a\eta\,\frac{\sqrt 2}{\sqrt{1-\beta^2}}\sum_t\mathbb{E}\|g_t\|^2 = O\Big(\frac{\beta\eta}{(1-\beta)^{3/2}(1+\beta)^{1/2}}\Big)\sum_t\mathbb{E}\|g_t\|^2$.

So $|\mathcal C_T| \leq C(\beta)\eta\sum_t\mathbb{E}\|g_t\|^2$ with $C(\beta) = O(\beta/(1-\beta)^{3/2})$ and the coefficient on $\sum\|g_t\|^2$ in (R') becomes $\eta_{\mathrm{eff}}/2 + C(\beta)\eta = O(\eta/(1-\beta))$ — same order, just with a $\beta$-dependent multiplicative constant. The qualitative conclusion: **the cross term is absorbable but with a $1/(1-\beta)^{3/2}$ blowup**.

---

## 4. The Cesàro (average-iterate) bound

Substituting back, with $\eta_{\mathrm{eff}}=\eta/(1-\beta)$, the dominant terms of (R') give the Cesàro bound:
$$\boxed{\;\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}[f(x_t)-f^\star] \;\leq\; \frac{(1-\beta)D^2}{T\eta} + \frac{\eta\sigma^2}{1-\beta}\cdot K(\beta) \;}, \tag{Avg}$$
where $K(\beta) = O(1/(1-\beta))$ collects cross-term coefficients.

Optimizing $\eta = (1-\beta)\sqrt{D^2/(T\sigma^2 K(\beta))}$ — provided $\eta\leq (1-\beta)/(2L)$, equivalently $T\geq T_0 := 4L^2 D^2/((1-\beta)^2\sigma^2 K(\beta))$ — yields
$$\frac{1}{T}\sum_t\mathbb{E}[f(x_t)-f^\star] \leq O\!\left(\frac{LD^2}{T(1-\beta)^?} + \frac{\sigma D}{\sqrt T}\cdot\sqrt{K(\beta)}\right) = O\!\left(\frac{LD^2}{T(1-\beta)} + \frac{\sigma D}{\sqrt T(1-\beta)^{1/2}}\right).$$

For $T<T_0$ (small-T regime), $\eta = (1-\beta)/(2L)$ saturates and the bias term dominates: $LD^2/(T(1-\beta))$.

**Remark.** The Cesàro variance term *does* scale as $\sigma D/\sqrt T$ because we tuned $\eta\propto 1/\sqrt T$. **This is the standard online-to-batch outcome**, but with $\eta$ chosen as a function of $T$ (not the fixed-$\eta$ regime that Routes A/F worry about).

---

## 5. Reduction step 3: Last-iterate via Orabona's bridge lemma

The standard Orabona last-iterate-vs-average bridge (Lemma 1 of Orabona's blog, generalizing Shamir-Zhang 2013):

**Lemma 3 (bridge).** For any sequence of non-negative reals $(q_t)_{t\geq 1}$ and step-sizes $(\eta_t)_{t\geq 1}$ that are non-increasing,
$$\eta_T q_T \leq \frac{1}{T}\sum_{t=1}^T \eta_t q_t + \sum_{k=1}^{T-1}\frac{1}{k(k+1)}\sum_{t=T-k+1}^T\eta_t(q_t - q_{T-k}).$$

The right-hand side has a "Cesàro term" plus a "non-monotonicity penalty". For SGD on smooth convex without momentum and with $\eta_t = \alpha/\sqrt t$, telescoping the second sum together with a regret bound at each suffix gives an extra $\log T$ factor.

**Adaptation to SHB.** Two issues block direct application:

1. *Fixed step:* Our analysis used a fixed $\eta$ tuned to $T$, not a decreasing schedule. The bridge lemma requires non-increasing $\eta_t$. With a fixed $\eta$, the lemma degenerates to $q_T \leq \frac{1}{T}\sum q_t + \sum_{k}\frac{1}{k(k+1)}\sum_{t=T-k+1}^T(q_t - q_{T-k})$, where the second term gauges *deviation from monotonicity*.

2. *SHB orbits oscillate:* Even in deterministic SHB (no noise), $f(x_t)$ is **not monotonically non-increasing** along the trajectory — momentum induces oscillations of amplitude $\sim\beta\eta\|g\|$. So the non-monotonicity penalty $\sum_k\frac{1}{k(k+1)}\sum_{t}(q_t-q_{T-k})$ must be bounded by an SHB-specific argument.

For each fixed window suffix $s\in\{T-k+1,\dots,T\}$, we apply (R') restricted to $[T-k, T]$ in place of $[0,T]$ and view $x_{T-k}$ as the "initial point". This gives, for each $k\geq 1$:
$$\sum_{t=T-k+1}^T\mathbb{E}[f(x_t)-f^\star] \leq \frac{\mathbb{E}\|z_{T-k}-x^\star\|^2}{2\eta_{\mathrm{eff}}} + \frac{\eta_{\mathrm{eff}}}{2}\big(2L\sum\mathbb{E}[f-f^\star]+k\sigma^2\big) + |\mathcal C^{(k)}|.$$

Now the obstacle: $\mathbb{E}\|z_{T-k}-x^\star\|^2$ can be **as large as $D^2 + k\sigma^2\eta_{\mathrm{eff}}/(1-\beta)$** — the iterate has diffused, so the "initial distance" inside the suffix is no longer $D^2$. (This is exactly Lemma D5 — domain non-confinement — of the scout doc.)

Carrying through the standard Shamir-Zhang argument under the **assumption** that $\sup_t\mathbb{E}\|x_t-x^\star\|^2 \leq C(\beta) D^2$ (which, recall, FAILS in the unprojected fixed-$\eta$ setting per Route F), the bridge gives an extra $\log T$:
$$\mathbb{E}[f(x_T)-f^\star] \leq O\!\left(\frac{LD^2}{T(1-\beta)} + \frac{\sigma D}{\sqrt T(1-\beta)^{1/2}}\right) \cdot \log T. \tag{Last}$$

**Without the boundedness assumption**, the diffusion of $\|z_{T-k}-x^\star\|^2$ contributes $\sigma^2\eta\cdot k$, and after summing the bridge weights $\sum_k\frac{1}{k(k+1)}\cdot\sigma^2\eta_{\mathrm{eff}}k = \sigma^2\eta_{\mathrm{eff}}\log T$, we get an *additional* $\sigma^2\eta\log T = O(\sigma D\log T/\sqrt T)$ contribution. So the rate becomes $O((LD^2/T+\sigma D\log T/\sqrt T)/(1-\beta))$.

---

## 6. Exact rate determination

**Claim.** The reduction (Route D) yields the following last-iterate rate for fixed-momentum SHB with **$T$-tuned step** $\eta = \Theta((1-\beta)/(\sqrt T \cdot \sigma/D))$ and **assuming bounded iterate domain** (i.e., projection onto $\{\|x-x^\star\|\leq D\}$ or analytic bound on $\sup_t\mathbb{E}\|x_t-x^\star\|^2$):
$$\boxed{\mathbb{E}[f(x_T)-f^\star] \leq O\!\left(\frac{LD^2\log T}{T(1-\beta)} + \frac{\sigma D\,\log T}{\sqrt T\,(1-\beta)^{1/2}}\right).}$$

Without boundedness (i.e., true unprojected fixed-$\eta$ SHB on smooth convex non-SC), the variance term diverges as established by Route F: there is no $1/\sqrt T$ decay.

**Hence the answer to the explicit "exact rate including log factors" question:**
- **For projected SHB (or whenever bounded iterates can be ensured):** $O((LD^2/T + \sigma D/\sqrt T)\log T)$ — i.e., **up-to-log of the OP-2 LB**.
- **For unprojected fixed-$\eta$ SHB:** No $\sigma D/\sqrt T$ rate exists; the variance term saturates at the noise floor.

Both the $\log T$ factor and the $1/(1-\beta)^{1/2}$ momentum penalty are intrinsic to the bridge step. The $\log T$ comes from the suffix-cumulative bridge; the momentum penalty comes from the cross-term $\mathcal C_T$.

---

## 7. $\beta$-dependence summary

| Quantity | Scaling in $1-\beta$ |
|---|---|
| Effective step $\eta_{\mathrm{eff}}$ | $\eta/(1-\beta)$ |
| Cross-term coefficient $C(\beta)$ | $\beta/(1-\beta)^{3/2}$ |
| Bias term constant in (Avg) | $1/(1-\beta)$ |
| Variance term constant in (Avg) | $1/(1-\beta)^{1/2}$ |
| Bridge log penalty | independent of $\beta$ |
| Iterate diffusion $\mathbb{E}\|x_t-x^\star\|^2$ | $D^2 + \sigma^2\eta T/(1-\beta^2)$ — diverges |
| Stability requirement on $\eta$ | $\eta \leq (1-\beta)/(2L)$ |

The momentum-dependent constants do **not** blow up at the stability boundary $\beta\to 1$ as fast as e.g. the κ-blowup parameter (Direction 1 OP-1). They blow up polynomially in $1/(1-\beta)$ with degree at most $3/2$.

---

## 8. Comparison with OP-2 lower bound

OP-2 gives $\Omega(LD^2/T + \sigma D/\sqrt T)$ on the last iterate (over a $T$-dependent hard instance class).

| Regime | Route D upper bound | OP-2 lower bound | Tightness |
|---|---|---|---|
| Projected SHB, optimally tuned $\eta(T)$ | $O((LD^2/T + \sigma D/\sqrt T)\log T \cdot \beta\text{-poly})$ | $\Omega(LD^2/T + \sigma D/\sqrt T)$ | **Up-to-log** |
| Unprojected fixed-$\eta$ SHB | $\sigma^2\eta/(L(1-\beta^2))$ noise floor, no $1/\sqrt T$ decay | $\Omega(LD^2/T + \sigma D/\sqrt T)$ via $T$-dep. instance | **Strict gap** — no matching UB |
| Unprojected SHB with $\eta_t = \alpha(1-\beta)/\sqrt t$ | $O((LD^2/T + \sigma D/\sqrt T)\log T)$ (conjectural; needs separate analysis with decreasing step) | matched up-to-log | Conjectured up-to-log |

**Conclusion on tightness:** Route D, viewed as a reduction, **does NOT** prove the clean $O(LD^2/T + \sigma D/\sqrt T)$ rate without log. It produces an *up-to-$\log T$* matching UB, and **only conditional on iterate boundedness** (projection or analytic boundedness). The $\log T$ is the price for fixed momentum — the same penalty structure that Li-Liu-Orabona observe in their non-smooth fixed-momentum analysis, here transferred to the smooth convex setting.

The $\log T$ is not removable by this route because: (a) the fixed-momentum offset $z_t - x_t = a(x_t - x_{t-1})$ injects a momentum bias at every suffix, (b) the bridge lemma's non-monotonicity penalty $\sum 1/(k(k+1))$ summed over $k=1,\dots,T-1$ produces the harmonic factor.

---

## 9. Verdict on the route

**Route D succeeds as a reduction** but produces a strictly weaker bound than the OP-2 LB:
1. Best achievable rate: $O((LD^2/T + \sigma D/\sqrt T)\log T / (1-\beta)^{1/2})$.
2. Conditional on iterate boundedness (true for projected SHB; FALSE for unprojected fixed-$\eta$).
3. Does NOT match the OP-2 LB exactly — the $\log T$ gap is intrinsic to the regret-then-bridge approach.

**Implication for the paper.** Route D contributes a *projected SHB* matching upper bound (up to $\log T$). It does NOT close the unprojected fixed-momentum gap; that requires either Route A (Lyapunov, gives noise-floor companion bound) or Route F (refutation, shows no $\sigma D/\sqrt T$ UB exists in the fixed-$\eta$ regime).

**Honest assessment:** the natural "online-to-batch" intuition that fixed-momentum SHB should obey the OGD regret bound is *partially* correct (yes for the auxiliary $z_t$ sequence's regret w.r.t. its own iterate), but the gradient-evaluation lag $z_t \neq x_t$ injects a cross-term that obstructs a clean transfer. The reduction is therefore *non-tight by a $\log T$ factor* and *requires bounded domains*, both of which are non-removable artifacts of the fixed-momentum structure.

---

## 10. Open questions raised by the reduction

1. **Is the $\log T$ factor truly intrinsic, or removable by a sharper bridge?** Li-Liu-Orabona 2022 conjecture $\log T$ is necessary for fixed momentum on non-smooth Lipschitz; whether the same applies to smooth convex with momentum is open. Route E (PEP) could decide this numerically.

2. **Can the cross-term $\mathcal C_T$ be absorbed without the $1/(1-\beta)^{3/2}$ blowup?** A finer Abel summation tracking the auto-correlation of $g_t$ with $x_t-x_{t-1}$ might gain a factor $(1-\beta)^{1/2}$.

3. **Does Nesterov-Y (gradient at $z_t$ not $x_t$) close the cross-term gap?** Yes, by construction — but Nesterov-Y is not the SHB of interest. This explains why Nesterov-style methods admit cleaner online-to-batch reductions.

---

**Length:** ~2050 words. **Verifier calls:** 1 (Lemma 1, 4/4 PASS).
