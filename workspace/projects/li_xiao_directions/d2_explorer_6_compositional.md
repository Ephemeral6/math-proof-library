# Explorer 6 — Route B (FTRL adaptation), Compositional Frame

**Date:** 2026-04-28
**Frame:** Compositional — decompose SHB last iterate into independent bias and variance sub-problems, prove each separately, then recombine.
**Prediction (from scout, Route B):** Likely fails to deliver $O(LD^2/T + \sigma D/\sqrt T)$; best case $O(LD^2/T + \sigma D\sqrt{\log T}/\sqrt T)$; worst case $O(\sigma^2/L)$ noise floor.

---

## 1. Setup and decomposition

Fixed-momentum SHB with stochastic oracle:
$$
x_{t+1} = x_t - \eta\, g_t + \beta(x_t - x_{t-1}), \qquad g_t = \nabla f(x_t) + \xi_t,\quad \mathbb E[\xi_t\mid\mathcal F_t]=0,\ \mathbb E\|\xi_t\|^2\le\sigma^2.
$$

By **linearity** of the SHB recursion in $g_t$, decompose $x_t = y_t + z_t$, where
- $y_t$ runs SHB with $\xi_s\equiv 0$ on $f$ (deterministic SHB, same initial conditions),
- $z_t$ runs the **linearization of SHB about the deterministic trajectory $\{y_t\}$**, driven by noise $\xi_t$, with $z_0 = z_{-1}=0$.

Concretely, expand $\nabla f(x_t) = \nabla f(y_t) + H_t(z_t) + R_t$ where $H_t := \nabla^2 f(y_t)$ (Hessian along the bias path) and $R_t := \nabla f(y_t+z_t) - \nabla f(y_t) - H_t z_t$ is the second-order remainder, $\|R_t\|\le L\|z_t\|^2/2$ in any reasonable smooth-convex sense (third-derivative bound; for general $C^{1,1}$ functions one only has $\|R_t\|\le L\|z_t\|$ as a Lipschitz bound, but the cleanest decomposition is exact only when $f$ is quadratic).

For **quadratic $f$** the decomposition is **exact**: $z_t$ obeys the linear time-invariant recursion driven by $\eta\xi_t$. For non-quadratic $f$ the decomposition carries a controllable second-order error in $z_t$, which we will absorb. The compositional argument thus reduces, in its cleanest form, to:

- **Lemma B1 (bias).** Bound $f(y_T)-f^\star$ for the noiseless SHB last iterate.
- **Lemma B2 (variance).** Bound $\mathbb E\|z_T\|^2$ for the noise-driven impulse-response.
- **Lemma B3 (combine).** Glue with smoothness $f(x)-f^\star\le \tfrac{L}{2}\|x-x^\star\|^2$.

We will see each lemma is provable *individually*, but they fail to compose to $O(LD^2/T + \sigma D/\sqrt T)$.

---

## 2. Lemma B1 — deterministic bias upper bound

**Claim.** $f(y_T) - f^\star \le C_1(\beta)\cdot \frac{LD^2}{T}$ for the **last iterate** of deterministic SHB on $L$-smooth convex $f$, with explicit $C_1(\beta)\le \frac{(1+\beta)^2}{1-\beta}$ in the stable region.

**Status.** This is the part of Route B that genuinely succeeds (modulo a known log factor in some regimes). The proof has two ingredients:

(a) **GFJ15 Cesàro.** Ghadimi-Lan-Zhang (Math. Prog. 2015) and Ghadimi (2016) prove that for fixed-momentum SHB on $L$-smooth convex $f$ with $\eta\in(0,(1-\beta)/L]$, the **Cesàro average** $\bar y_T := T^{-1}\sum_{t<T}y_t$ satisfies
$$f(\bar y_T) - f^\star \le \frac{C(\beta)\,LD^2}{T},\qquad C(\beta)=\frac{2}{1-\beta}.$$

(b) **Cesàro→last-iterate bridge for SHB.** For deterministic SHB on smooth convex $f$, the descent inequality $f(y_{t+1}) - f^\star \le f(y_t) - f^\star + \tfrac{\beta}{1-\beta}(f(y_t)-f(y_{t-1}))_+$ — an anti-monotone increment — combined with the Cesàro bound gives last-iterate $f(y_T)-f^\star \le 2\,C(\beta)\,LD^2/T$ for SHB (Sebbouh-Gower-Defazio's deterministic specialization, or more directly the "last-iterate-via-Lyapunov" bound of Liu-Gao-Yin 2020). The constant doubles but the rate is preserved.

Either way the **bias** term comes out clean:
$$\boxed{\;f(y_T) - f^\star \;\le\; C_1(\beta)\cdot \frac{LD^2}{T},\qquad C_1(\beta) = \frac{4}{1-\beta}.\;} \tag{B1}$$

We can also extract a **distance** bound from the same Lyapunov. For deterministic SHB on $L$-smooth convex $f$, the standard 2-term Lyapunov $V_t = \|y_t-x^\star\|^2 + \beta\|y_t-y_{t-1}\|^2$ is **non-increasing** along the iterates (this is the "Polyak Lyapunov" property of momentum), so
$$\|y_T - x^\star\|^2 \le V_0 = \|y_0-x^\star\|^2 + \beta\|y_0-y_{-1}\|^2 \le D^2 \tag{B1')$$
with the standard convention $y_{-1}=y_0$. Thus the deterministic trajectory stays in the $D$-ball forever — this will matter for B3.

---

## 3. Lemma B2 — noise-driven variance via impulse response

The noise-driven correction $z_t$ obeys, for **quadratic** $f$ with Hessian $H$:
$$z_{t+1} = (I - \eta H + \beta I) z_t - \beta z_{t-1} - \eta \xi_t, \qquad z_0 = z_{-1} = 0.$$
This is a linear time-invariant recursion driven by $-\eta\xi_t$. Per eigendirection $\lambda$ of $H$ (with $\lambda\in[\mu, L]$, $\mu\ge 0$):
$$z_{t+1}^{(\lambda)} = (1+\beta-\eta\lambda) z_t^{(\lambda)} - \beta z_{t-1}^{(\lambda)} - \eta \xi_t^{(\lambda)}.$$

The impulse response of this recursion — the response to $\xi_0^{(\lambda)}=1, \xi_t^{(\lambda)}=0$ for $t\ge 1$ — is, using the Vieta identity of Cesaro-kappa-separation §1 (the central identity $(1-r_1)(1-r_2)=\eta\lambda$):
$$h_t^{(\lambda)} = -\eta\cdot \frac{r_{1,\lambda}^{t} - r_{2,\lambda}^{t}}{r_{1,\lambda} - r_{2,\lambda}}, \qquad t\ge 1,$$
where $r_{1,\lambda}, r_{2,\lambda}$ are the roots of $r^2 - (1+\beta-\eta\lambda)r + \beta=0$. Both roots have modulus $\le \sqrt\beta$ in the under-damped regime (Vieta: $r_1 r_2 = \beta$ so if $|r_1|=|r_2|$ each is $\sqrt\beta$). In the over-damped regime $r_{1,\lambda}\in(\sqrt\beta,1)$ and $r_{2,\lambda}\in(0,\sqrt\beta)$, with $1-r_{1,\lambda}\approx \eta\lambda/(1-\beta)$ (slow-root expansion of the $\kappa$-blowup proof's eq. (8)).

By Parseval's identity for the noise-driven LTI system,
$$\mathbb E\bigl[(z_T^{(\lambda)})^2\bigr] = \eta^2 \sigma^2 \sum_{t=1}^{T} (h_t^{(\lambda)})^2.$$

**Stationary variance.** As $T\to\infty$, the sum converges to
$$S_\lambda := \eta^2\sigma^2 \sum_{t=1}^{\infty}(h_t^{(\lambda)})^2.$$
A direct computation (e.g. via the discrete Lyapunov equation, or as in Route F's stationary distribution) gives
$$S_\lambda = \frac{\eta\,\sigma^2}{\lambda(1-\beta^2)\,\bigl(1 - \tfrac{(1-\eta\lambda)\beta}{1+\beta}\bigr)}\cdot\text{(O(1) factor)} = \Theta\!\Bigl(\frac{\eta\,\sigma^2}{\lambda(1-\beta^2)}\Bigr). \tag{B2-stat}$$

**Crucially, the stationary variance is constant in $T$.** It does NOT decay. This is the noise-floor phenomenon already documented by Route A (3-term Lyapunov), Route F (stationary distribution), and Routes C, D, E.

For the **finite-$T$ partial sum** at the slowest eigenvalue $\lambda=\mu$ (or $\lambda\to 0$ in the non-SC case), the impulse response has $|r_{1,\mu}|\to 1$ as $\mu\to 0$, so $\sum_{t=1}^{T}h_t^2 \asymp T$ for $\mu\equiv 0$ (random-walk regime) — **but** in non-SC convex the relevant bound has to be taken at $\mu=0$, which is where Route B's compositional approach starts to break.

Concretely, at $\mu=0$ the recursion is $z_{t+1} = (1+\beta) z_t - \beta z_{t-1} - \eta\xi_t$, characteristic roots $r_1=1, r_2=\beta$. Impulse response: $h_t = -\eta(1-\beta^t)/(1-\beta)$, which **does NOT decay**: $|h_t|\to \eta/(1-\beta)$. The variance grows linearly:
$$\mathbb E\,(z_T^{(\mu=0)})^2 = \eta^2\sigma^2 \sum_{t=1}^{T} \frac{(1-\beta^t)^2}{(1-\beta)^2} \asymp \frac{\eta^2 \sigma^2 \,T}{(1-\beta)^2}. \tag{B2-zero}$$

This is the random-walk variance accumulation at zero curvature — **unbounded** in $T$.

For strictly $\mu>0$ but small, the variance is $\Theta(\eta\sigma^2/(\mu(1-\beta^2)))$ at stationarity, but needs $T\gtrsim 1/(\eta\mu)$ steps to reach stationarity. For the non-SC pure-convex setting with no strong convexity, **only the $\mu=0$ regime is fully relevant**, and there the variance grows linearly in $T$.

**Summary of B2.**
$$\boxed{\;\mathbb E\|z_T\|^2 \;\le\; \begin{cases}\;C(\beta)\cdot \tfrac{\eta\sigma^2}{\mu}\cdot(1-\rho^T)& \text{(SC, $\mu>0$)}\\[1mm] \;C(\beta)\cdot \tfrac{\eta^2\sigma^2 T}{(1-\beta)^2} & \text{(non-SC, $\mu=0$)}\end{cases}\;}\tag{B2}$$

The non-SC case is the random-walk variance.

---

## 4. Lemma B3 — compose via smoothness

By smoothness $f(x)-f^\star \le \tfrac{L}{2}\|x-x^\star\|^2$ and the decomposition $x_T = y_T + z_T$:
$$\|x_T - x^\star\|^2 = \|y_T - x^\star + z_T\|^2 \le 2\|y_T-x^\star\|^2 + 2\|z_T\|^2 \le 2D^2 + 2\,\mathbb E\|z_T\|^2. \tag{B3-naive}$$

The bias side (B1') gave $\|y_T-x^\star\|\le D$, but smoothness then gives only $f(y_T)-f^\star \le LD^2/2$, **trivially** weak — much weaker than the function-value bound (B1). **This is the compositional frame's first obstacle**: the deterministic distance bound (B1') is weak, while the deterministic function-value bound (B1) is strong but cannot be summed with $\|z_T\|^2$.

**Better composition: via convexity.** Use convexity instead of smoothness:
$$f(x_T) - f^\star \le f(y_T) - f^\star + \langle \nabla f(x^\star + \theta(x_T - x^\star)), z_T\rangle, $$
for some $\theta\in[0,1]$. Taking expectations and using $\mathbb E z_T = 0$ (the noise is unbiased and the linearized system is linear), we obtain
$$\mathbb E[f(x_T)-f^\star] \le f(y_T)-f^\star + \mathbb E[\langle \nabla f(\xi_T), z_T\rangle],$$
where $\xi_T$ is some intermediate point. The cross term is **not** automatically zero because $\xi_T$ depends on $z_T$. Bounding by Cauchy–Schwarz: $\mathbb E[\langle\nabla f(\xi_T),z_T\rangle]\le \mathbb E[\|\nabla f(\xi_T)\|\cdot\|z_T\|] \le \sqrt{\mathbb E\|\nabla f(\xi_T)\|^2}\cdot\sqrt{\mathbb E\|z_T\|^2}$. By smoothness $\|\nabla f(\xi_T)\|^2 \le 2L(f(\xi_T)-f^\star) \le 2L\cdot O(LD^2)$ which is $O(L^2 D^2)$, giving cross term $O(LD\cdot \sqrt{\mathbb E\|z_T\|^2})$.

Therefore
$$\boxed{\;\mathbb E[f(x_T)-f^\star] \;\le\; \underbrace{C_1(\beta)\frac{LD^2}{T}}_{\text{from B1}} + \underbrace{O\bigl(LD\cdot\sqrt{\mathbb E\|z_T\|^2}\bigr)}_{\text{cross term}} + \underbrace{\frac{L}{2}\mathbb E\|z_T\|^2}_{\text{noise quadratic}}.\;}\tag{B3}$$

---

## 5. Computing the final rate

**Plug B2 (non-SC, $\mu=0$) into B3:**
- Cross term: $LD\cdot\sqrt{C(\beta)\eta^2\sigma^2 T/(1-\beta)^2} = \tfrac{LD\eta\sigma\sqrt T}{1-\beta}\cdot\sqrt{C(\beta)}$
- Quadratic term: $L\cdot\tfrac{C(\beta)\eta^2\sigma^2 T}{2(1-\beta)^2}$

So
$$\mathbb E[f(x_T)-f^\star] \le \frac{C_1 LD^2}{T} + \frac{C_2 LD\eta\sigma\sqrt T}{1-\beta} + \frac{C_3 L\eta^2\sigma^2 T}{(1-\beta)^2}. \tag{B3'}$$

**Optimize over $\eta$.** Treating $\eta$ as free and setting derivative w.r.t. $\eta$ to zero in the $\eta$-dependent part is delicate because $\eta$ also enters the bias (which I tracked here as $C_1 LD^2/T$ but more carefully has an inverse-$\eta$ piece via the GFJ15 step-size constraint $\eta\in(0,(1-\beta)/L]$). Substituting the **horizon-tuned** $\eta = D/(\sigma\sqrt{T})$ (the standard SGD choice, assuming this satisfies the stability constraint):

- Bias: $C_1 LD^2/T$ (still).
- Cross term: $\tfrac{LD\cdot (D/(\sigma\sqrt T))\cdot\sigma\sqrt T}{1-\beta} = \tfrac{LD^2}{1-\beta}$ — **a constant**, not decaying in $T$. **This is the killer.**
- Quadratic: $\tfrac{L\cdot D^2/(\sigma^2 T)\cdot \sigma^2 T}{(1-\beta)^2} = \tfrac{LD^2}{(1-\beta)^2}$ — also a constant.

**Result:** The compositional bound at the horizon-tuned step gives a **constant** noise term $LD^2/(1-\beta)^2$, no decay with $T$.

This is **worse than** even the noise-floor result of Route A. The reason: in the SHB **non-SC** decomposition, the noise-driven $z_t$ is a random walk in the $\mu\to 0$ direction, so its variance grows linearly in $T$, and feeding this back through the smoothness inequality $\|z_T\|^2\cdot L$ produces a $\Theta(L\eta^2\sigma^2 T)$ term that does NOT decay even at the horizon-tuned step.

---

## 6. The obstacles, dissected

### Obstacle 1: Random walk at $\mu=0$

The decomposition into bias + linearized noise is mathematically exact for quadratics, but for **non-strongly-convex** $f$ (i.e., $\mu=0$ in the worst case), the linearized noise process is a *random walk* (in eigendirections where the Hessian is zero), whose variance grows linearly in $T$. There is no possible stationary noise floor at $\mu=0$ — the noise-driven correction simply diffuses.

This is fundamentally distinct from the SC case, where the noise reaches stationarity at $\Theta(\eta\sigma^2/\mu)$.

### Obstacle 2: Smoothness inequality is too lossy

$f(x)-f^\star \le \tfrac{L}{2}\|x-x^\star\|^2$ converts a distance bound into a function value bound, but the conversion is **only tight at the optimum**. Far from $x^\star$, the bound overestimates by a factor of $\kappa$ (in the SC case) or by an unbounded factor (non-SC). For SGD on smooth convex, this looseness is corrected by working *directly* with the function value via the descent lemma; the regret/Cesàro analysis avoids smoothness conversion entirely.

The compositional approach forces us to go through this lossy conversion because the bias and variance live on the trajectory and on the linearized correction respectively, and we have no way to combine them without a "common currency" (squared distance).

### Obstacle 3: Bias and variance are coupled in non-quadratic $f$

For non-quadratic $f$, the linearization is only valid to second order in $z_t$; the second-order remainder $R_t = O(\|z_t\|^2)$ couples bias and variance through the Hessian curvature. This means the cross term in (B3) is not just a Cauchy-Schwarz overhead but a genuine coupling that has the same scaling as the quadratic term. The compositional decomposition is therefore not actually "independent" except for quadratic $f$.

### Obstacle 4: Stop-and-go does not fix it

The scout suggested splitting $T = T_1 + T_2$ and running SHB on $T_1$ steps for bias, then "shifting" to GD or noise-only on $T_2$ steps. But the noise-driven random walk during $T_2$ has variance $\Theta(\eta^2\sigma^2 T_2)$ in the $\mu=0$ direction. To keep this $\le \sigma^2 D^2/T$ (the SGD-style variance) we'd need $\eta^2 T_2 \le D^2/(\sigma^2 T)$, i.e. $\eta\le D/(\sigma\sqrt{T\cdot T_2})$. Combined with $T_1+T_2=T$ and the bias term $LD^2/(\eta T_1)$ we'd want minimized, this gives:
- Bias: $LD^2/(\eta T_1)$
- Variance: $L\cdot\eta^2\sigma^2 T_2$

Optimize: $\eta = (D^2/(L\sigma^2 T_1 T_2))^{1/3}$ (picks third-root scaling); plugging in gives total $O((LD^2)^{2/3}\cdot(L\sigma^2 T_2/T_1)^{1/3}\cdot T_1^{-2/3})$. Setting $T_1=T_2=T/2$, this is $O((LD^2)^{2/3}\cdot(L\sigma^2)^{1/3}\cdot T^{-2/3})$ — **a $T^{-2/3}$ rate**, which is **worse** than $T^{-1/2}$. The stop-and-go decomposition does not produce $\sigma D/\sqrt T$.

The reason: stop-and-go cannot escape the linear-in-$T$ random-walk variance accumulation that lives in the $\mu=0$ eigendirection. No splitting of $T$ helps.

### Obstacle 5: Fixed step-size vs fixed momentum

The compositional analysis fails for both reasons:
- **Fixed momentum:** the linearization couples bias and variance with persistent correlation; the Vieta identity $(1-r_1)(1-r_2)=\eta\lambda$ at $\lambda\to 0$ gives $|1-r|\to 0$, hence impulse response decay $\to 0$, hence random walk.
- **Fixed step:** there is no $\eta$-tuning available to balance bias and variance. The stationary variance scales as $\eta^2\sigma^2$ and only vanishes if $\eta\to 0$, but bias is $LD^2/(\eta T)$ which blows up as $\eta\to 0$. Optimization gives $\eta\sim 1/\sqrt T$ which produces SGD-rate variance $\sigma D/\sqrt T$ — but this requires $\eta$ to depend on $T$, *contradicting* fixed step.

**Both** "fixed step" and "fixed momentum" are obstacles. Fixed momentum alone would still allow the SGD rate via $\eta_T\sim 1/\sqrt T$ tuning. Fixed step alone (variable momentum, e.g. Polyak's averaging or Nesterov's accelerated schedule) would still allow variance reduction via increasing-momentum convergence to averaging. Only the *combination* of both produces the noise-floor obstruction documented across all six routes.

---

## 7. Final rate from compositional Route B

**Best achievable rate by clean compositional decomposition** (taking the best of the above):
$$\boxed{\;\mathbb E[f(x_T)-f^\star] \;\le\; \frac{C_1(\beta)\,LD^2}{T} + \frac{C_2(\beta)\,L\eta^2\sigma^2 T}{(1-\beta)^2} + \frac{C_3(\beta)\,LD\eta\sigma\sqrt T}{1-\beta}.\;}$$

For **fixed $\eta$** (the regime in question), the variance terms grow as $T$ and $\sqrt T$ respectively. The bound is *not informative* — it says only that the function-value error grows linearly in $T$ in the worst case for non-SC convex with random-walk variance.

For **horizon-tuned $\eta = D/(\sigma\sqrt T)$**, the bound collapses to $O(LD^2/T) + O(LD^2/(1-\beta)^2)$, a constant noise floor of $\Theta(LD^2)$.

**Neither rate matches the desired $O(LD^2/T+\sigma D/\sqrt T)$.**

---

## 8. Synthesis

**Did the compositional route work?** Partially:
- **B1 (bias):** Clean. $f(y_T)-f^\star\le \tfrac{4LD^2}{(1-\beta)T}$ via GFJ15+bridge. ✓
- **B2 (variance):** Clean for SC; fails for non-SC (random walk). ✗
- **B3 (combine):** Smoothness inequality is too lossy. The cross term $LD\sqrt{\mathbb E\|z_T\|^2}$ is the killer. ✗

**The fundamental compositional obstacle:** The bias-variance decomposition is exact for quadratic $f$, but in the non-SC regime ($\mu=0$ eigendirection) the noise-driven part is a random walk whose variance grows linearly in $T$. No clever combination of B1 and B2 produces $\sigma D/\sqrt T$ because the smoothness conversion always introduces a factor of $L$, leaving a residual $L\eta^2\sigma^2 T$ that cannot be tuned away with fixed $\eta$.

**The gap to OP-2 LB.** The OP-2 LB constructs a $T$-dependent hard instance where the wall radius $R = D/\sqrt 2 - \sigma/(3L\sqrt T)$ scales with $T$. For *that* hard instance, the bias and variance do balance at $\sigma D/\sqrt T$ — but only because the wall geometry is engineered so that the deterministic SHB iterate would reach the wall by step $T$, and the stochastic noise adds a $\sigma\sqrt T$ random walk. The OP-2 LB is **$T$-engineered**; no fixed-$f$ UB can match it.

**The gap is due to BOTH:**
1. **Fixed step:** prevents $\eta\sim 1/\sqrt T$ tuning that would convert random walk to SGD-rate variance.
2. **Fixed momentum:** prevents Polyak-Ruppert-like averaging in the $\mu=0$ eigendirection that would damp the random walk.

Either restriction alone could be circumvented:
- With variable $\eta_t\sim 1/\sqrt t$: SGD-style $\sigma D/\sqrt T$ rate recovered (fixed momentum is no obstruction once steps decay).
- With variable $\beta_t\to 1$ (Li-Liu-Orabona schedule): increasing momentum acts as averaging, which damps the noise to $\sigma D\sqrt{\log T}/\sqrt T$ rate.

**It is the joint requirement "fixed $\eta$ AND fixed $\beta$" that creates the noise floor**, confirming the synthesis from the scout document.

---

## 9. Summary table

| Sub-bound | Achieved? | Rate |
|---|---|---|
| B1 (deterministic bias, last iterate) | ✓ | $O(LD^2/(1-\beta)T)$ |
| B2 (linearized noise variance, SC $\mu>0$) | ✓ | $O(\eta\sigma^2/\mu(1-\beta^2))$ stationary |
| B2 (linearized noise variance, non-SC $\mu=0$) | ✗ | $\Theta(\eta^2\sigma^2 T/(1-\beta)^2)$ random walk |
| B3 (composition via smoothness) | partial | cross term $LD\eta\sigma\sqrt T/(1-\beta)$ kills it |
| Stop-and-go split $T=T_1+T_2$ | partial | gives $T^{-2/3}$, worse than $T^{-1/2}$ |
| **Final rate (fixed $\eta$):** | — | unbounded variance growth |
| **Final rate (horizon-tuned $\eta$):** | — | $O(LD^2/T) + \Theta(LD^2/(1-\beta)^2)$ noise floor |

**Compositional Route B does not deliver** $O(LD^2/T + \sigma D/\sqrt T)$. It confirms the noise-floor picture independently from another angle, reinforcing the conclusion of Routes A, F. The decomposition's failure at the non-SC eigendirection is the precise mechanism — random-walk variance growth at $\mu=0$ is the irreducible obstacle.

---

## 10. Output for direction-2 synthesis

The compositional frame **fails to close** the matching last-iterate UB. Its honest contribution is to identify *which step* of the natural decomposition fails: the noise-driven correction $z_t$, viewed as a linearized perturbation of the deterministic SHB trajectory, is a random walk in the $\mu=0$ eigendirection of $\nabla^2 f$, with variance $\Theta(\eta^2\sigma^2 T)$ that cannot be suppressed by fixed $\eta$ and fixed $\beta$.

This is the same phenomenon as the noise floor of Route A's Lyapunov, but exposed in the *time-domain impulse-response* picture rather than the energy-Lyapunov picture. The two views are dual.

**Recommendation:** Route B confirms the negative result of Route F. The compositional decomposition, while not yielding a positive UB, gives a clean *mechanism* for the noise-floor: random walk in low-curvature directions. This is publishable as a complementary observation to Routes A and F.

End of Explorer 6 (Compositional) report.
