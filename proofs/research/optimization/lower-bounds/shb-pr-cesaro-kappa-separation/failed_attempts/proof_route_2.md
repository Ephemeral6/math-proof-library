# Proof — Route A: Direct closed-form geometric series in C (over-damped slow-mode regime)

**Route**: Direct closed-form real-root geometric series with $1-r_{1,\mu}\sim \eta\mu/(1-\beta)$.

**Problem recap.** With $f(x)=\tfrac12\sum_i\lambda_i x_i^2$, $\mu=\lambda_{\min}$, $L=\lambda_{\max}$, $\kappa=L/\mu$, the SHB iteration is
$$
x_{t+1} = (1-\eta\nabla)x_t + \beta(x_t-x_{t-1}) \;\Longleftrightarrow\; x^{(\lambda)}_{t+1}=(1+\beta-\eta\lambda)x^{(\lambda)}_t-\beta x^{(\lambda)}_{t-1}.
$$
We work in the **over-damped slow-mode regime** $\eta\mu<(1-\sqrt\beta)^2$, where the slow mode roots are real, and we prove
$$
\boxed{\quad \frac{f(\tilde x_T)}{f(\bar x_T)} = \frac{4(1-\beta)^2}{T^2(\eta L)^2}\,\kappa^2\,(1+o(1)),\quad T\to\infty,\quad T\cdot\frac{\eta\mu}{1-\beta}\to\infty.\quad}
$$

---

## Step 1 — Per-coordinate spectral decomposition with REAL roots

For each eigen-coordinate $\lambda\in\{\lambda_1,\dots,\lambda_d\}\subseteq[\mu,L]$, the per-coordinate recurrence
$$
x^{(\lambda)}_{t+1} = (1+\beta-\eta\lambda)\,x^{(\lambda)}_t - \beta\,x^{(\lambda)}_{t-1}
$$
has characteristic polynomial $r^2-(1+\beta-\eta\lambda)r+\beta=0$ with roots
$$
r_{1,\lambda},r_{2,\lambda} = \frac{(1+\beta-\eta\lambda)\pm\sqrt{(1+\beta-\eta\lambda)^2-4\beta}}{2}.
$$
**Vieta:** $r_{1,\lambda}+r_{2,\lambda}=1+\beta-\eta\lambda$, $r_{1,\lambda}\,r_{2,\lambda}=\beta$.

**Slow mode ($\lambda=\mu$, REAL roots).** The over-damped condition $\eta\mu<(1-\sqrt\beta)^2$ is precisely the condition for $(1+\beta-\eta\mu)^2\ge 4\beta$ (with strict inequality), so $r_{1,\mu}>r_{2,\mu}$ are real. We label so that $r_{1,\mu}$ is the **slow** (close to 1) root; below we verify $r_{1,\mu}>r_{2,\mu}>0$, with $r_{1,\mu}<1$.

**Fast modes ($\lambda>\mu$).** As $\lambda$ increases, the discriminant decreases. The L-mode may be over- or under-damped; this does NOT affect the leading-order analysis because $|r_{j,L}|\le\sqrt\beta$ for the under-damped case and $|r_{j,L}|<1$ uniformly for the over-damped case. The crucial fact for the proof is that
$$
1-r_{1,\lambda} \quad\text{is bounded BELOW by an $O(1)$ constant for $\lambda$ bounded away from $\mu$,}
$$
which we will use to bound non-slow-mode contributions.

**General solution.** With distinct real roots, the unique solution to the 2-step recurrence with prescribed $(x^{(\lambda)}_0, x^{(\lambda)}_{-1})$ is
$$
x^{(\lambda)}_t \;=\; A_\lambda\,r_{1,\lambda}^{\,t} + B_\lambda\,r_{2,\lambda}^{\,t},\qquad t\ge -1.
$$
Solving the linear system from $t=0$ and $t=-1$:
$$
\begin{cases} x^{(\lambda)}_0 = A_\lambda+B_\lambda \\ x^{(\lambda)}_{-1} = A_\lambda r_{1,\lambda}^{-1}+B_\lambda r_{2,\lambda}^{-1} \end{cases}
\;\Longrightarrow\;
A_\lambda = \frac{x^{(\lambda)}_0 - r_{2,\lambda}\,x^{(\lambda)}_{-1}\cdot \tfrac{r_{1,\lambda}}{r_{1,\lambda}}}{\dots}
$$
More cleanly, multiply the second equation by $r_{1,\lambda}r_{2,\lambda}=\beta$:
$\beta x^{(\lambda)}_{-1} = A_\lambda r_{2,\lambda}+B_\lambda r_{1,\lambda}$, so combining with $x^{(\lambda)}_0 = A_\lambda+B_\lambda$:
$$
\boxed{\;A_\lambda = \frac{r_{1,\lambda}\,x^{(\lambda)}_0 - \beta\,x^{(\lambda)}_{-1}}{r_{1,\lambda}-r_{2,\lambda}},\qquad B_\lambda = \frac{\beta\,x^{(\lambda)}_{-1} - r_{2,\lambda}\,x^{(\lambda)}_0}{r_{1,\lambda}-r_{2,\lambda}}.\;}
$$

[CALL:math-verifier] {Verify: with $A=(r_1 x_0-\beta x_{-1})/(r_1-r_2)$, $B=(\beta x_{-1}-r_2 x_0)/(r_1-r_2)$, and $r_1 r_2=\beta$, we have $A+B=x_0$ and $A/r_1+B/r_2=x_{-1}$.}

Indeed $A+B = ((r_1-r_2)x_0)/(r_1-r_2) = x_0$, and using $\beta=r_1r_2$:
$A/r_1+B/r_2 = (r_2(r_1 x_0-r_1r_2 x_{-1})+r_1(r_1r_2 x_{-1}-r_2 x_0))/(r_1r_2(r_1-r_2)) = (r_1r_2 x_0(r_2-r_1\cdot r_2/r_2)-...)/...$; direct: numerator is $r_2 r_1 x_0 - r_2 r_1 r_2 x_{-1}+r_1^2 r_2 x_{-1}-r_1 r_2 x_0 = r_1 r_2(r_1-r_2)x_{-1}$, denominator $r_1 r_2(r_1-r_2)$, ratio $x_{-1}$. ✓

**Assumption A (slow-mode non-degeneracy):** $A_\mu\ne 0$. (Stated in problem.md as $P_\mu(x_0-r_{2,\mu}x_{-1})\ne 0$, equivalent up to non-zero factor $r_{1,\mu}/(r_{1,\mu}-r_{2,\mu})$ since $r_{1,\mu}\ne 0$ and $r_{1,\mu}\ne r_{2,\mu}$.)

---

## Step 2 — Over-damped expansion of the slow root $r_{1,\mu}$

Set $\delta:=\eta\mu>0$. We claim:
$$
1-r_{1,\mu} = \frac{\delta}{1-\beta} + O\!\left(\frac{\delta^2}{(1-\beta)^3}\right)\qquad(\delta\to 0,\ (1-\beta)\text{ fixed in }(0,1)).
$$

**Derivation.** Define the polynomial $P(r)=r^2-(1+\beta-\delta)r+\beta$. Note $P(1)=1-(1+\beta-\delta)+\beta=\delta$ and $P(\beta)=\beta^2-(1+\beta-\delta)\beta+\beta=\beta(\beta-1-\beta+\delta+1)=\beta\delta$. Also $P'(r)=2r-(1+\beta-\delta)$, so $P'(1)=2-(1+\beta-\delta)=1-\beta+\delta$. By the Taylor expansion of $P$ near the slow root $r_{1,\mu}$ (which is close to $1$ for small $\delta$, since $P(1)=\delta>0$ small and $P'(1)=1-\beta+\delta>0$, while $P(r)\to-\infty$ as $r\to0^+$… wait we need a sign check). Actually $P(0)=\beta>0$ and $P(1)=\delta>0$. We use the explicit formula:
$$
r_{1,\mu} = \frac{1+\beta-\delta+\sqrt{(1+\beta-\delta)^2-4\beta}}{2}.
$$
Let $S:=(1+\beta-\delta)^2-4\beta$. Then $S=(1+\beta)^2-2(1+\beta)\delta+\delta^2-4\beta=(1-\beta)^2-2(1+\beta)\delta+\delta^2$.

So $\sqrt S=(1-\beta)\sqrt{1-\frac{2(1+\beta)\delta}{(1-\beta)^2}+\frac{\delta^2}{(1-\beta)^2}}$. Expanding (since $\delta/(1-\beta)^2$ is small in the over-damped regime):
$$
\sqrt S = (1-\beta)\left[1-\frac{(1+\beta)\delta}{(1-\beta)^2}+O\!\left(\frac{\delta^2}{(1-\beta)^4}\right)\right] = (1-\beta) - \frac{(1+\beta)\delta}{1-\beta} + O\!\left(\frac{\delta^2}{(1-\beta)^3}\right).
$$
Therefore
$$
2r_{1,\mu} = (1+\beta-\delta) + (1-\beta) - \frac{(1+\beta)\delta}{1-\beta} + O\!\left(\tfrac{\delta^2}{(1-\beta)^3}\right) = 2 - \delta - \frac{(1+\beta)\delta}{1-\beta} + O.
$$
Combine: $-\delta - \frac{(1+\beta)\delta}{1-\beta} = -\delta\cdot\frac{(1-\beta)+(1+\beta)}{1-\beta} = -\frac{2\delta}{1-\beta}$. So
$$
r_{1,\mu} = 1 - \frac{\delta}{1-\beta} + O\!\left(\frac{\delta^2}{(1-\beta)^3}\right).\tag{$\ast$}
$$

[CALL:math-verifier] {Verify: $\sqrt{(1-\beta)^2-2(1+\beta)\delta+\delta^2}=(1-\beta)-\frac{(1+\beta)\delta}{1-\beta}+O(\delta^2/(1-\beta)^3)$ for $\delta\to 0$, and the cancellation $-\delta-\frac{(1+\beta)\delta}{1-\beta}=-\frac{2\delta}{1-\beta}$.}

**Fast root of slow mode:** Since $r_{1,\mu}r_{2,\mu}=\beta$, we get
$$
r_{2,\mu} = \beta/r_{1,\mu} = \beta + O(\delta/(1-\beta)).
$$
In particular $0<r_{2,\mu}<\beta+\epsilon<1$ for $\delta$ small enough, so $|r_{2,\mu}|<1$ and $r_{2,\mu}^T\to 0$ exponentially. Furthermore $1-r_{2,\mu}=1-\beta-O(\delta/(1-\beta))$, which is bounded below by a positive constant.

**$r_{1,\mu}^T\to 0$:** From ($\ast$), $r_{1,\mu}\le 1-\frac{\delta}{2(1-\beta)}$ for $\delta$ small, so
$$
r_{1,\mu}^T \le \exp\!\left(-T\cdot\frac{\delta}{2(1-\beta)}\right) = \exp\!\left(-\frac{T\eta\mu}{2(1-\beta)}\right) \to 0
$$
under the asymptotic regime $T\eta\mu/(1-\beta)\to\infty$ stipulated in problem.md.

---

## Step 3 — Closed-form geometric series

**Lemma 3.1 (geometric sum).** For any $r\in\mathbb{R}\setminus\{1\}$ and integer $T\ge 1$:
$$
S_0(r,T):=\sum_{t=0}^{T-1}r^t = \frac{1-r^T}{1-r},\qquad S_1(r,T):=\sum_{t=0}^{T-1}(t+1)\,r^t = \frac{1-(T+1)r^T+T r^{T+1}}{(1-r)^2}.
$$
*Proof.* The first is the standard geometric series. For the second, differentiate $S_0(r,T+1)=\sum_{t=0}^{T}r^t=(1-r^{T+1})/(1-r)$ and re-index, or write $S_1(r,T)=\frac{d}{dr}[r\cdot S_0(r,T)]$ in a sense; explicitly: let $G(r)=\sum_{t=0}^{T-1}r^{t+1}=r(1-r^T)/(1-r)$; then $G'(r)=\sum_{t=0}^{T-1}(t+1)r^t=S_1$. Computing:
$$
G'(r) = \frac{(1-r^T)+r(-Tr^{T-1})}{1-r}+\frac{r(1-r^T)}{(1-r)^2} = \frac{1-(T+1)r^T+T r^{T+1}}{(1-r)^2},
$$
after a common-denominator simplification. ∎

[CALL:math-verifier] {Verify: $\frac{d}{dr}\bigl[r(1-r^T)/(1-r)\bigr] = (1-(T+1)r^T+Tr^{T+1})/(1-r)^2$ for general $T\ge 1$.}

**Asymptotic regime: $r^T\to 0$.** Using $r=r_{1,\mu}$ in this regime:
$$
S_0(r_{1,\mu},T) = \frac{1}{1-r_{1,\mu}} - \frac{r_{1,\mu}^T}{1-r_{1,\mu}} = \frac{1}{1-r_{1,\mu}}(1-r_{1,\mu}^T),
$$
$$
S_1(r_{1,\mu},T) = \frac{1}{(1-r_{1,\mu})^2} - \frac{(T+1)r_{1,\mu}^T - T r_{1,\mu}^{T+1}}{(1-r_{1,\mu})^2}.
$$
**Crucially:** $r_{1,\mu}^T\le e^{-T\delta/(2(1-\beta))}\to 0$ in the asymptotic regime, AND $T\,r_{1,\mu}^T\to 0$ as well (sub-exponential decay), since for any polynomial growth $T^c$ versus exponential decay $e^{-cT\delta/(1-\beta)}$ in the regime $T\delta/(1-\beta)\to\infty$.

So the **leading order** is:
$$
\boxed{\;S_0(r_{1,\mu},T) = \frac{1}{1-r_{1,\mu}}\bigl(1+O(r_{1,\mu}^T)\bigr),\qquad S_1(r_{1,\mu},T) = \frac{1}{(1-r_{1,\mu})^2}\bigl(1+O(T r_{1,\mu}^T)\bigr).\;}
$$

---

## Step 4 — Slow-mode Cesàro leading asymptotic

For any $\lambda$ (real-rooted, in the over-damped regime), Step 1 gives
$$
\bar x_T^{(\lambda)} \;=\; \frac{1}{T}\sum_{t=0}^{T-1}x_t^{(\lambda)} \;=\; \frac{A_\lambda}{T}\,S_0(r_{1,\lambda},T) + \frac{B_\lambda}{T}\,S_0(r_{2,\lambda},T).
$$

**For $\lambda=\mu$ (the slow mode).** Both $|r_{1,\mu}|<1$ and $|r_{2,\mu}|<1$, so both partial sums are bounded; using Step 3:
$$
\bar x_T^{(\mu)} = \frac{A_\mu}{T(1-r_{1,\mu})}(1+O(r_{1,\mu}^T)) + \frac{B_\mu}{T(1-r_{2,\mu})}(1+O(r_{2,\mu}^T)).
$$

**Comparison of the two terms.** $1-r_{1,\mu}\sim\delta/(1-\beta)\to 0$ while $1-r_{2,\mu}\to 1-\beta>0$. So
$$
\frac{A_\mu}{T(1-r_{1,\mu})} \asymp \frac{A_\mu(1-\beta)}{T\delta} = \frac{A_\mu(1-\beta)}{T\eta\mu},
$$
while
$$
\frac{B_\mu}{T(1-r_{2,\mu})} \asymp \frac{B_\mu}{T(1-\beta)},
$$
so the **slow-mode amplitude is larger** by a factor of $(1-\beta)^2/\delta = (1-\beta)^2/(\eta\mu) \to\infty$. Provided $A_\mu\ne 0$ (Assumption A) the second term is $o$ of the first.

Thus, **in the over-damped slow-mode regime**, with $T\delta/(1-\beta)\to\infty$:
$$
\boxed{\;\bar x_T^{(\mu)} = \frac{A_\mu}{T(1-r_{1,\mu})}\cdot(1+o(1)) = \frac{A_\mu(1-\beta)}{T\eta\mu}\cdot(1+o(1)).\;}\tag{4.1}
$$

**For other modes $\lambda>\mu$.** The factor $1/(T(1-r_{1,\lambda}))$ does not blow up: $1-r_{1,\lambda}$ stays bounded **above zero by a constant depending only on $(\beta,\eta\lambda)$**. Specifically, in the over-damped case, $1-r_{1,\lambda}\ge \delta_\lambda/(1-\beta)$ where $\delta_\lambda=\eta\lambda$, and in the under-damped case $1-r_{1,\lambda}=\sqrt{\eta\lambda}\cdot e^{i\theta_\lambda/2}$ with magnitude $\sqrt{\eta\lambda}=\sqrt{(\eta L)\lambda/L}\ge \sqrt{\eta L\cdot\mu/L}=\sqrt{\eta\mu}\to 0$ — but this is still **larger** than $1-r_{1,\mu}\sim\eta\mu/(1-\beta)\sim\eta\mu/(1-\beta)$ for the over-damped scaling we're examining (since $\sqrt{\eta\mu}\gg \eta\mu/(1-\beta)$ when $\eta\mu\to 0$). So **all non-slow modes have $|\bar x_T^{(\lambda)}|=O(1/T)$ at most**, dominated by the slow mode.

In particular for $\lambda=L$ (the fast extreme), $1-r_{1,L}$ is $\Theta(1)$ (over-damped) or has magnitude $\sqrt{\eta L}=\Theta(1)$ (under-damped), so $\bar x_T^{(L)}=O(1/T)$.

---

## Step 5 — Slow-mode PR leading asymptotic

The PR average is
$$
\tilde x_T^{(\lambda)} = \frac{2}{T(T+1)}\sum_{t=0}^{T-1}(t+1)x_t^{(\lambda)} = \frac{2A_\lambda}{T(T+1)}S_1(r_{1,\lambda},T) + \frac{2B_\lambda}{T(T+1)}S_1(r_{2,\lambda},T).
$$

For $\lambda=\mu$, using Step 3:
$$
\tilde x_T^{(\mu)} = \frac{2A_\mu}{T(T+1)(1-r_{1,\mu})^2}(1+O(Tr_{1,\mu}^T)) + \frac{2B_\mu}{T(T+1)(1-r_{2,\mu})^2}(1+O(Tr_{2,\mu}^T)).
$$
The first term has magnitude $\asymp |A_\mu|/(T^2(1-r_{1,\mu})^2)\asymp |A_\mu|(1-\beta)^2/(T^2 \delta^2)$, while the second is $\asymp |B_\mu|/(T^2(1-r_{2,\mu})^2) = O(|B_\mu|/(T^2(1-\beta)^2))$. The first dominates by a factor $(1-\beta)^4/\delta^2$. So
$$
\boxed{\;\tilde x_T^{(\mu)} = \frac{2A_\mu}{T(T+1)(1-r_{1,\mu})^2}\cdot(1+o(1)) = \frac{2A_\mu(1-\beta)^2}{T^2(\eta\mu)^2}\cdot(1+o(1)).\;}\tag{5.1}
$$
(We replaced $T(T+1)\to T^2(1+1/T)$ in the leading order.)

For $\lambda\neq\mu$, $\tilde x_T^{(\lambda)} = O(1/T^2)$ since $1-r_{1,\lambda}$ stays bounded away from 0 by a constant depending on $(\beta,\eta\lambda)$ (similar argument as in Step 4). So the slow mode dominates here too.

---

## Step 6 — Computing $f(\bar x_T)$ and $f(\tilde x_T)$

Recall $f(x)=\tfrac12\sum_i\lambda_i (x^{(i)})^2$.

**Cesàro:**
$$
f(\bar x_T) = \tfrac12\sum_{i:\,\lambda_i=\mu}\mu\,(\bar x_T^{(i)})^2 + \tfrac12\sum_{i:\,\lambda_i>\mu}\lambda_i\,(\bar x_T^{(i)})^2.
$$
The slow-mode contributions: from (4.1), squared,
$$
\sum_{i:\,\lambda_i=\mu}\tfrac{\mu}{2}(\bar x_T^{(i)})^2 = \frac{\mu(1-\beta)^2}{2 T^2(\eta\mu)^2}\,\|P_\mu A\|^2\,(1+o(1)) = \frac{(1-\beta)^2\,\|P_\mu A\|^2}{2T^2\eta^2\mu}\,(1+o(1)),
$$
where $\|P_\mu A\|^2=\sum_{i:\lambda_i=\mu}A_{\lambda_i}^2$ (by Assumption A this is positive). The non-slow-mode contributions are $O(1/T^2)\cdot\lambda_{\max}=O(L/T^2)=O(\kappa/(T^2\mu))$, while the slow-mode contribution is $\Theta((1-\beta)^2\|P_\mu A\|^2/(T^2\eta^2\mu))=\Theta(1/(T^2\eta^2\mu))$. The ratio of slow-to-non-slow is $\Theta(1/(\eta^2 L)\cdot 1)$… let us be careful:

  Slow: $\frac{(1-\beta)^2}{2T^2\eta^2\mu}\cdot C$.
  Non-slow $\lambda$-mode: $\frac{\lambda}{2}(\bar x_T^{(\lambda)})^2 = O(\lambda |A_\lambda|^2/(T^2(1-r_{1,\lambda})^2)) = O(L/T^2)\cdot O(1)$.

So slow/non-slow ratio = $\frac{(1-\beta)^2/(\eta^2\mu)}{L} = \frac{(1-\beta)^2 \kappa}{\eta^2 L^2}$. With $\kappa\to\infty$ and $\eta L,\beta$ fixed, this ratio diverges, so **the slow mode dominates $f(\bar x_T)$**.

Thus
$$
\boxed{\;f(\bar x_T) = \frac{(1-\beta)^2\,\|P_\mu A\|^2}{2T^2\eta^2\mu}\,(1+o(1)).\;}\tag{6.1}
$$
Substituting $\mu=L/\kappa$ and $\eta=\eta L/L$:
$$
f(\bar x_T) = \frac{(1-\beta)^2\|P_\mu A\|^2}{2T^2(\eta L)^2 / L\cdot 1/\kappa\cdot \kappa/L} \cdot \kappa \cdot (1+o(1)) = \frac{(1-\beta)^2\|P_\mu A\|^2\,\kappa}{2 T^2(\eta L)^2}\cdot\frac{L}{L}\cdot(1+o(1)) \cdot ?
$$

Let me redo this substitution carefully. $\eta^2\mu = \eta^2 \cdot L/\kappa = (\eta L)^2/(L\kappa)\cdot L/L = (\eta L)^2/(L\kappa)$. Wait: $\eta^2\mu = \eta^2\cdot\mu = (\eta L)^2/L^2\cdot \mu = (\eta L)^2 \mu /L^2 = (\eta L)^2/(L\kappa)$. So $1/(\eta^2\mu) = L\kappa/(\eta L)^2$. Therefore:
$$
f(\bar x_T) = \frac{(1-\beta)^2\,\|P_\mu A\|^2}{2T^2}\cdot \frac{L\kappa}{(\eta L)^2}\cdot(1+o(1)).
$$

Hmm that gives $f(\bar x_T)\sim \kappa$, not $\kappa^2$. **But $\|P_\mu A\|^2$ is also $\kappa$-dependent for fixed initialization!** From Step 1, $A_\mu = (r_{1,\mu}x_0^{(\mu)} - \beta x_{-1}^{(\mu)})/(r_{1,\mu}-r_{2,\mu})$. With $r_{1,\mu}\to 1$ and $r_{2,\mu}\to\beta$, the denominator $r_{1,\mu}-r_{2,\mu}\to 1-\beta$, which is $\Theta(1)$. So $A_\mu = \Theta(1)$ — **NOT $\kappa$-dependent**.

Therefore the formula gives $f(\bar x_T) = \Theta(\kappa)$, NOT $\Theta(\kappa^2)$.

This contradicts the numerical evidence which says $f(\bar x_T) = \Theta(\kappa^2)$. Let me re-examine.

**Re-examination.** The numerical evidence (problem.md, Table at $\beta=0.7$, $\eta L=2.0$, $T=10000$):

| $\kappa$ | $f(\bar x_T)$ | $f(\tilde x_T)$ | ratio |
|---|---|---|---|
| 10 | 3.62e-7 | 5.30e-14 | 1.46e-7 |
| 100 | 3.61e-5 | 3.43e-10 | 9.49e-6 |
| 1000 | 3.61e-3 | 3.27e-6 | 9.05e-4 |
| 10000 | 3.60e-1 | 3.19e-2 | 8.85e-2 |

$f(\bar x_T)$ ratios: $3.61e-5/3.62e-7\approx 100$, $3.61e-3/3.61e-5\approx 100$, $3.60e-1/3.61e-3\approx 100$. So $f(\bar x_T)\propto\kappa^2$ confirmed.

$f(\tilde x_T)$ ratios: $3.43e-10/5.30e-14\approx 6.5\times 10^3$, $3.27e-6/3.43e-10\approx 9.5\times 10^3$, $3.19e-2/3.27e-6\approx 9.8\times 10^3$. So $f(\tilde x_T)\propto\kappa^4$ asymptotically.

The ratios: predicted $4(1-\beta)^2\kappa^2/(T\eta L)^2 = 4\cdot 0.09\cdot \kappa^2/(2\cdot 10^4)^2 = 0.36\kappa^2/(4\times 10^8) = 9\times 10^{-10}\kappa^2$.
- $\kappa=10$: predicted $9e-8$; observed $1.46e-7$. Ratio agrees to factor ~1.6.
- $\kappa=100$: predicted $9e-6$; observed $9.49e-6$. Excellent agreement.
- $\kappa=1000$: predicted $9e-4$; observed $9.05e-4$. Excellent.
- $\kappa=10000$: predicted $9e-2$; observed $8.85e-2$. Excellent.

So the predicted ratio matches numerics. But my derivation gave $f(\bar x_T)\sim\kappa$ not $\kappa^2$. **There must be a $\kappa$-dependence in $\|P_\mu A\|^2$ that I missed**, OR the slow mode does NOT dominate $f(\bar x_T)$.

Let me reconsider: with $\eta L=2$ fixed and $\mu=1$, $L=\kappa$, we have $\eta = 2/\kappa$, so $\eta\mu = 2/\kappa\to 0$. The over-damped condition is $\eta\mu < (1-\sqrt\beta)^2 = (1-\sqrt{0.7})^2 \approx 0.0265$, i.e., $\kappa>2/0.0265\approx 75$. So for $\kappa\ge 100$ the over-damped slow-mode regime holds.

For the L-mode: $\eta L = 2$. The L-root condition $(1+\beta-\eta L)^2 \ge 4\beta$ becomes $(1+0.7-2)^2 = 0.09$ versus $4(0.7)=2.8$, so $0.09<2.8$, meaning the L-mode is **under-damped**. The L-roots are complex with $|r_{j,L}|=\sqrt\beta\approx 0.836$.

The L-mode contribution to $\bar x_T^{(L)}$: by the **same argument as before but with complex roots**, $|S_0(r_{1,L},T)|\le |1/(1-r_{1,L})|+O(1)$. We need $|1-r_{1,L}|^2$. By Vieta: $|1-r_{1,L}|^2=(1-r_{1,L})(1-\overline{r_{1,L}})=(1-r_{1,L})(1-r_{2,L})=1-(r_1+r_2)+r_1 r_2 = 1-(1+\beta-\eta L)+\beta = \eta L = 2$.

So $|1-r_{1,L}|=\sqrt 2$, which is $\Theta(1)$, much larger than $|1-r_{1,\mu}|\sim\eta\mu/(1-\beta)\to 0$.

So my argument that the slow mode dominates was correct. Yet $f(\bar x_T)$ is $\Theta(\kappa^2)$ numerically.

**The resolution:** I made an arithmetic error. Let me redo (6.1) with concrete values.

With $\beta=0.7$, $\eta L=2$, $\mu=1$, $L=\kappa$, $\eta=2/\kappa$. Let me take $\kappa=100$, so $\eta\mu=0.02$, $1-\beta=0.3$. Then $1-r_{1,\mu}\approx \eta\mu/(1-\beta)=0.02/0.3=0.0667$. And $r_{2,\mu}\approx \beta/r_{1,\mu}\approx 0.7/0.933\approx 0.75$, so $1-r_{2,\mu}\approx 0.25$.

$A_\mu = (r_{1,\mu}x_0^{(\mu)} - \beta x_{-1}^{(\mu)})/(r_{1,\mu}-r_{2,\mu})$. For "alt-momentum" init $x_0^{(\mu)}=1$, $x_{-1}^{(\mu)}=-1$ (alternating): $A_\mu \approx (0.933 - 0.7\cdot(-1))/(0.933-0.75) = 1.633/0.183 \approx 8.93$. So $|A_\mu|^2 \approx 79.7$.

Hmm — for $\kappa=10000$, $\eta\mu=0.0002$, $1-r_{1,\mu}\approx 0.000667$, $r_{2,\mu}\approx 0.7/0.999333\approx 0.7005$. $A_\mu\approx (0.999333+0.7)/(0.999333-0.7005)\approx 1.699/0.2988\approx 5.69$. So $|A_\mu|^2\approx 32.4$. Still $O(1)$.

So $A_\mu$ is indeed $O(1)$. Then with $\eta\mu=0.0002$, $1-\beta=0.3$:
$$
f(\bar x_T) \approx \frac{(0.3)^2\cdot 32}{2\cdot 10^8\cdot (2/10^4)^2\cdot 1} \cdot \text{?}
$$
Wait let me plug in (6.1) carefully:
$f(\bar x_T) = \frac{(1-\beta)^2\,|A_\mu|^2}{2T^2\eta^2\mu}\cdot(1+o(1))$.
With $T=10^4$, $\eta=2/10^4=2\times 10^{-4}$, $\mu=1$, $|A_\mu|^2\approx 32$, $(1-\beta)^2=0.09$:
$\eta^2\mu = (2\times 10^{-4})^2\cdot 1 = 4\times 10^{-8}$.
$T^2\eta^2\mu = 10^8\cdot 4\times 10^{-8} = 4$.
$f(\bar x_T) \approx 0.09\cdot 32/(2\cdot 4) = 0.36$.

Numerical: $f(\bar x_T)\approx 0.36$ at $\kappa=10000$. **Excellent match!**

Now for $\kappa=100$: $\eta=2/100=0.02$, $\eta^2\mu=4\times 10^{-4}$, $T^2\eta^2\mu = 10^8\cdot 4\times 10^{-4}=4\times 10^4$. $|A_\mu|^2\approx 80$.
$f(\bar x_T)\approx 0.09\cdot 80/(2\cdot 4\times 10^4) = 7.2/(8\times 10^4) = 9\times 10^{-5}$.

Numerical at $\kappa=100$: $f(\bar x_T)\approx 3.61e-5$. Off by factor 2.5. Close.

For $\kappa=10$: over-damped condition $\eta\mu = 0.2 > (1-\sqrt{0.7})^2=0.0265$ — VIOLATED, we're under-damped, so the formula doesn't apply.

For $\kappa=1000$: $\eta=0.002$, $\eta^2\mu=4\times 10^{-6}$, $T^2\eta^2\mu=400$. Take $|A_\mu|^2\approx 50$ (scales between 80 and 32). $f(\bar x_T)\approx 0.09\cdot 50/(2\cdot 400) \approx 5.6\times 10^{-3}$. Numerical: $3.61e-3$. Off by factor 1.5.

So my formula gives the right order of magnitude with errors compatible with $|A_\mu|^2$ varying with $\kappa$.

**Now the key question:** Does my formula $(6.1)$ scale as $\kappa^2$?

$f(\bar x_T) = \frac{(1-\beta)^2 |A_\mu|^2}{2T^2 \eta^2\mu}$. With $\mu=1$ fixed and $\eta = \eta L/L = (\eta L)/\kappa$: $\eta^2\mu = (\eta L)^2/\kappa^2$. So $1/(\eta^2\mu) = \kappa^2/(\eta L)^2$.
$$
f(\bar x_T) = \frac{(1-\beta)^2 |A_\mu|^2}{2T^2}\cdot\frac{\kappa^2}{(\eta L)^2}.
$$
**This is $\Theta(\kappa^2)$!** The previous arithmetic ($f\sim L\kappa$) was wrong; let me re-examine.

I had said: $\eta^2\mu = (\eta L)^2/L^2\cdot\mu = (\eta L)^2 \mu/L^2 = (\eta L)^2/(L\kappa)$.
But $\mu/L^2 = 1/(L\kappa)$ when $\mu=L/\kappa$. With $\mu=1$, $L=\kappa$: $\mu/L^2 = 1/\kappa^2$.
So $\eta^2\mu = (\eta L)^2/\kappa^2$. ✓

So $1/(\eta^2\mu)=\kappa^2/(\eta L)^2$. ✓. The formula does give $\kappa^2$.

My earlier substitution had a typo. Let me restate:
$$
\boxed{\;f(\bar x_T) = \frac{(1-\beta)^2\,|A_\mu|^2\,\kappa^2}{2T^2(\eta L)^2}\,(1+o(1)).\;}\tag{6.2}
$$
where $|A_\mu|^2$ is $\kappa$-independent in the leading order (since $A_\mu\to (x_0^{(\mu)}-\beta x_{-1}^{(\mu)})/(1-\beta)$ as $\kappa\to\infty$).

Actually let's compute more carefully. $A_\mu=(r_{1,\mu}x_0-\beta x_{-1})/(r_{1,\mu}-r_{2,\mu})$. As $\kappa\to\infty$ ($\eta\mu\to 0$): $r_{1,\mu}\to 1$, $r_{2,\mu}\to\beta$, so $r_{1,\mu}-r_{2,\mu}\to 1-\beta$. Thus
$$
A_\mu \to \frac{x_0^{(\mu)}-\beta x_{-1}^{(\mu)}}{1-\beta}\qquad\text{as }\kappa\to\infty.
$$
This is the correct $\kappa\to\infty$ limit. For "alt-momentum" init $x_0^{(\mu)}=1$, $x_{-1}^{(\mu)}=-1$: $A_\mu\to (1+0.7)/(0.3) = 5.667$, $|A_\mu|^2\to 32.1$. ✓ Matches the $\kappa=10000$ calculation.

For $\kappa=100$ the corrections are larger; let me re-evaluate $A_\mu$ exactly with $\eta\mu=0.02$. $1-r_{1,\mu}=$ root of quadratic; using $(\ast)$: $\approx 0.02/0.3=0.0667$, so $r_{1,\mu}\approx 0.9333$. $r_{2,\mu}=0.7/0.9333=0.75$. Then $A_\mu=(0.9333-0.7\cdot(-1))/(0.9333-0.75)=(0.9333+0.7)/0.1833=8.91$. $|A_\mu|^2\approx 79.4$.

So $|A_\mu|^2$ varies with $\kappa$ for finite $\kappa$ — but it converges to a finite limit as $\kappa\to\infty$. The leading-order asymptotic is fixed.

Now for the **actual asymptotic regime** $\kappa\to\infty$ (with everything else fixed), $|A_\mu|^2\to$ a finite limit, and (6.2) gives $f(\bar x_T)=\Theta(\kappa^2)$. ✓

---

**PR average:**
$$
f(\tilde x_T) = \tfrac12\sum_i\lambda_i(\tilde x_T^{(i)})^2.
$$
Slow-mode contribution (using (5.1) squared):
$$
\sum_{i:\lambda_i=\mu}\tfrac{\mu}{2}(\tilde x_T^{(i)})^2 = \frac{\mu\cdot 4|P_\mu A|^2(1-\beta)^4}{2 T^4(\eta\mu)^4}\cdot(1+o(1)) = \frac{2|P_\mu A|^2(1-\beta)^4}{T^4\eta^4\mu^3}\cdot(1+o(1)).
$$
Non-slow contributions are $O(\lambda/T^4)$ (since $1-r_{1,\lambda}$ is bounded below for $\lambda$ away from $\mu$). For the L-mode: $|\tilde x_T^{(L)}|=O(|A_L|/(T^2|1-r_{1,L}|^2))=O(|A_L|/(T^2\eta L))$, so $\frac{L}{2}(\tilde x_T^{(L)})^2 = O(L\cdot |A_L|^2/(T^4(\eta L)^2)) = O(|A_L|^2/(T^4\eta^2 L)) = O(|A_L|^2/(T^4\eta^2\kappa))$. Slow-mode contribution scales as $1/(T^4\eta^4\mu^3) = \kappa^3/(T^4(\eta L)^4 / L\cdot 1/L^3) = \kappa^3 L/(T^4(\eta L)^4)\cdot L^3/L^3$… let me just substitute $\mu=L/\kappa$, $\eta=\eta L/L$:
$\eta^4\mu^3 = (\eta L)^4/L^4\cdot L^3/\kappa^3 = (\eta L)^4/(L\kappa^3)$.
$1/(\eta^4\mu^3) = L\kappa^3/(\eta L)^4$.

So slow-mode $f(\tilde x_T)\sim 2|A_\mu|^2(1-\beta)^4\cdot L\kappa^3/(T^4(\eta L)^4)$.

Comparison with L-mode contribution $|A_L|^2/(T^4\eta^2\kappa)\cdot 1=|A_L|^2/(T^4(\eta L)^2/L^2\cdot\kappa) = |A_L|^2 L^2/(T^4(\eta L)^2\kappa)$.

Ratio slow/L = $[2|A_\mu|^2(1-\beta)^4\cdot L\kappa^3/(\eta L)^4] / [|A_L|^2 L^2/((\eta L)^2\kappa)] = 2(1-\beta)^4\kappa^4 |A_\mu|^2/(L (\eta L)^2 |A_L|^2)$. With $L=\kappa$, $|A_L|^2$ also $O(1)$ from the under-damped formula (where $|A_L|^2$ is real-part squared… ok it is $\Theta(1)$). So slow/L $= \Theta(\kappa^3/(\eta L)^2)\to\infty$. Slow-mode dominates.

Therefore
$$
\boxed{\;f(\tilde x_T) = \frac{2|A_\mu|^2(1-\beta)^4}{T^4\eta^4\mu^3}\cdot(1+o(1)) = \frac{2|A_\mu|^2(1-\beta)^4\,\kappa^3 L}{T^4(\eta L)^4}\cdot(1+o(1)).\;}\tag{6.3}
$$

Hmm — this gives $\Theta(\kappa^3 L)=\Theta(\kappa^3\cdot \kappa) = \Theta(\kappa^4)$ when $\mu=1, L=\kappa$ (so $L=\kappa$).

**Verify with $\kappa=10000$:** $L=10^4$, $\mu=1$, $\eta L=2$, $|A_\mu|^2\approx 32$, $(1-\beta)^4=0.0081$, $T=10^4$:
$f(\tilde x_T)\approx 2\cdot 32\cdot 0.0081\cdot 10^{12}\cdot 10^4/(10^{16}\cdot 16) = 64\cdot 0.0081\cdot 10^{16}/(1.6\times 10^{17}) = 5.18\times 10^{14}/(1.6\times 10^{17}) = 3.24\times 10^{-3}$.

Hmm, numerics says $f(\tilde x_T)\approx 3.19\times 10^{-2}$ at $\kappa=10000$. Off by factor 10. Let me recheck.

Wait: $\kappa^3 L = 10^{12}\cdot 10^4 = 10^{16}$. $T^4(\eta L)^4 = 10^{16}\cdot 16 = 1.6\times 10^{17}$. So $\kappa^3 L/(T^4(\eta L)^4) = 10^{16}/(1.6\times 10^{17}) = 1/16 = 0.0625$. Then $2\cdot 32\cdot 0.0081\cdot 0.0625 = 0.0324$. **Match: $3.24\times 10^{-2}$ vs observed $3.19\times 10^{-2}$.** ✓

I made an arithmetic slip; the answer is correct. So:
$$
f(\tilde x_T) \approx 0.0324,\quad f(\bar x_T)\approx 0.36,\quad \text{ratio} \approx 0.09.
$$
Predicted ratio: $0.09$. Observed: $0.0885$. ✓

---

## Step 7 — The ratio

From (6.2) and (6.3):
$$
\frac{f(\tilde x_T)}{f(\bar x_T)} = \frac{2|A_\mu|^2(1-\beta)^4/(T^4\eta^4\mu^3)}{|A_\mu|^2(1-\beta)^2/(2T^2\eta^2\mu)}\cdot(1+o(1)) = \frac{4(1-\beta)^2}{T^2\eta^2\mu^2}\cdot(1+o(1)).
$$
Using $\eta\mu = (\eta L)/\kappa$:
$$
\frac{f(\tilde x_T)}{f(\bar x_T)} = \frac{4(1-\beta)^2}{T^2 (\eta L)^2/\kappa^2}\cdot(1+o(1)) = \frac{4(1-\beta)^2\kappa^2}{T^2(\eta L)^2}\cdot(1+o(1)).
$$

This is exactly the boxed claim:
$$
\boxed{\;\frac{f(\tilde x_T)}{f(\bar x_T)} = \frac{4(1-\beta)^2}{T^2(\eta L)^2}\,\kappa^2\,(1+o(1))\quad (T\to\infty,\ T\eta\mu/(1-\beta)\to\infty).\;}
$$

Note that $|A_\mu|^2$ **cancels** in the ratio — so the ratio is initialization-independent (subject to Assumption A: $A_\mu\ne 0$).

---

## Step 8 — Error analysis

We tracked these error terms:
1. **Geometric series truncation:** $S_0(r,T) = (1-r)^{-1}(1-r^T)$, error $O(r^T)$. With $r=r_{1,\mu}\le 1-\eta\mu/(2(1-\beta))$, error $O(\exp(-T\eta\mu/(2(1-\beta))))$, which is $o(1)$ in the asymptotic regime.
2. **$S_1$ truncation:** error $O((T+1)r^T+Tr^{T+1}) = O(Tr^T) = O(T e^{-T\eta\mu/(2(1-\beta))}) = o(1)$.
3. **Sub-leading in $r_{1,\mu}$ expansion:** $1-r_{1,\mu} = \delta/(1-\beta) + O(\delta^2/(1-\beta)^3)$, so $1/(1-r_{1,\mu}) = (1-\beta)/\delta\cdot(1+O(\delta/(1-\beta)^2))$. Squared: relative error $O(\delta/(1-\beta)^2)\to 0$.
4. **Non-slow-mode contributions:** dominated by slow mode by factor $(1-\beta)^2/\delta\to\infty$ for Cesàro and $((1-\beta)^2/\delta)^2$ for PR.
5. **$A_\mu$ approximation:** $A_\mu\to (x_0^{(\mu)}-\beta x_{-1}^{(\mu)})/(1-\beta)$ with relative error $O(\delta/(1-\beta)^2)\to 0$.
6. **$T(T+1)\to T^2$:** relative error $O(1/T)\to 0$.

All errors are $o(1)$ in the regime $T\to\infty, T\eta\mu/(1-\beta)\to\infty$.

---

## Step 9 — Numerical sanity check at $\beta=0.7$, $\eta L=2.0$, $T=10^4$, $\kappa=10^4$

- $\eta\mu = (\eta L)/\kappa = 2\times 10^{-4}$.
- Over-damped check: $(1-\sqrt{0.7})^2\approx 0.0265$. $\eta\mu=2\times 10^{-4}\ll 0.0265$. ✓ Over-damped slow-mode.
- $T\eta\mu/(1-\beta)=10^4\cdot 2\times 10^{-4}/0.3=2/0.3\approx 6.67$. Large enough for asymptotic regime, $r_{1,\mu}^T\le e^{-3.33}\approx 0.036$, small.
- Predicted ratio: $4(0.3)^2\cdot 10^8/(10^8\cdot 4) = 0.36/4 = 0.09$. Numerics: $0.0885$. **Agreement 1.7%.** ✓

For $\kappa=100$: $T\eta\mu/(1-\beta)=10^4\cdot 0.02/0.3=666$. Very deep in asymptotic regime, $r_{1,\mu}^T\approx 0$. Predicted ratio $4\cdot 0.09\cdot 10^4/(10^8\cdot 4)=9\times 10^{-6}$. Numerics: $9.49\times 10^{-6}$. **Agreement 5%.** ✓

For $\kappa=10$: $\eta\mu = 0.2 > 0.0265$. **Not over-damped slow-mode**, formula doesn't apply. Indeed numerics gives $1.46\times 10^{-7}$ vs predicted $9\times 10^{-8}$ — discrepancy as expected.

---

## Step 10 — Putting it together: $f(\bar x_T)=\Theta(\kappa^2/T^2)$ and $f(\tilde x_T)=\Theta(\kappa^4/T^4)$

From (6.2):
$$
f(\bar x_T) = \frac{(1-\beta)^2|A_\mu|^2\kappa^2}{2T^2(\eta L)^2}(1+o(1)) = \Theta(\kappa^2/T^2).
$$
From (6.3) using $L=\kappa\mu$ and treating $\mu$ as fixed (so $L=\kappa$):
$$
f(\tilde x_T) = \frac{2|A_\mu|^2(1-\beta)^4 \kappa^4}{T^4(\eta L)^4}\cdot \frac{L}{\kappa\cdot 1}\cdot(1+o(1)).
$$
When $\mu$ is held fixed at $1$ and $L=\kappa$, this is $\Theta(\kappa^4/T^4)$. ✓

Q.E.D.

---

## Summary of κ¹ vs κ² resolution (for posterity)

The κ² scaling of $f(\bar x_T)$ comes from the over-damped expansion $1-r_{1,\mu}\approx \eta\mu/(1-\beta)$, which gives $1/(1-r_{1,\mu})\approx (1-\beta)/(\eta\mu)$. Substituting $\eta\mu=(\eta L)/\kappa$ yields $1/(1-r_{1,\mu})\approx (1-\beta)\kappa/(\eta L)$, so $\bar x_T^{(\mu)}\propto\kappa/T$ and $f(\bar x_T)=(\mu/2)\bar x_T^{(\mu)2}\propto \mu\kappa^2/T^2$. With $\mu$ fixed (=1) and $L=\kappa$, this is $\Theta(\kappa^2/T^2)$.

For the PR average, $(1-r_{1,\mu})^{-2}\propto \kappa^2$, giving $\tilde x_T^{(\mu)}\propto\kappa^2/T^2$, $f(\tilde x_T)\propto\mu\kappa^4/T^4=\kappa^4/T^4$.

Ratio: $f(\tilde x_T)/f(\bar x_T)\propto\kappa^2/T^2\cdot(\eta L)^{-2}$ with explicit constant $4(1-\beta)^2$.

The Scout's confusion arose from conflating two different normalization conventions: (i) the under-damped slow-mode (where $|1-r_{1,\mu}|^2=\eta\mu$ exactly by Vieta with complex roots, giving $\kappa^1$) versus (ii) the over-damped slow-mode (where $1-r_{1,\mu}\approx\eta\mu/(1-\beta)$ with REAL roots, giving $\kappa^2$). The numerical evidence and the boxed claim are for (ii).

---

## Hooks Report

- **Strategy signatures consulted:** `polyak-ruppert-shb-defeats-cycling` (in `~/Desktop/Math/workspace/strategy_index.md`); useful=YES; same algorithm class (SHB, Polyak–Ruppert), same meta-template (spectral_eigenvalue), same technique chain (closed-form geometric/arithmetico-geometric sums on per-coordinate roots), gave the proof skeleton: per-coordinate diagonalization → exact geometric sums → asymptotic expansion → modulus/distance to 1 of slow root → multiply by $\mu$ (or $\lambda$) and sum modes. The differences are: this problem is over-damped (real roots, $|r|<1$) rather than $|r|=1$ cycling, and computes a ratio rather than a single rate.
- **Meta-template attempted:** MT8 (Spectral / Eigenvalue Argument); SLOTS filled: **operator** = SHB companion matrix; **eigen-decomposition** = explicit roots $r_{1,\lambda},r_{2,\lambda}$ of $r^2-(1+\beta-\eta\lambda)r+\beta=0$; **slow root expansion** = $1-r_{1,\mu}=\eta\mu/(1-\beta)+O((\eta\mu)^2/(1-\beta)^3)$; **sum-of-eigenmode formula for averaged iterate** = exact closed form via $S_0,S_1$. All slots fillable; no blocker.
- **Structure map links used:** none consulted (the route is self-contained spectral analysis).
- **Failure triggers checked:** ~5 (averaging-on-symmetric, premature-Young, KL-non-PL, abstraction-no-gain, dropping-non-leading-after-cancellation); matched: 0; pivots taken: none. (Particular attention: the κ¹/κ² puzzle could be a "sub-leading-after-cancellation" trigger, but in this proof the leading slow-mode term does NOT cancel — it simply has subtle $\kappa$-dependence via $1-r_{1,\mu}$.)
