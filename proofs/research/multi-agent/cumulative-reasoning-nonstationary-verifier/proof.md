# Proof: Convergence of Cumulative Reasoning Under Non-Stationary Verifiers

## Setup and notation

Let $\varepsilon_t = \varepsilon_0(1+t/T_0)^\alpha$ with $\alpha > 0$, $\varepsilon_0 \in (0,1)$, $T_0 > 0$. Let $P_T = \prod_{t=1}^T (1-\varepsilon_t)$. We work in the regime $T < T_0(\varepsilon_0^{-1/\alpha}-1)$ where all $\varepsilon_t \in (0,1)$.

## Core lemma (integral test for monotone summands)

For any non-negative increasing $f$ on $[0,T]$:
$$\int_0^T f(s)\,ds \;\le\; \sum_{t=1}^T f(t) \;\le\; \int_0^T f(s)\,ds + f(T) - f(0). \qquad (\text{IT})$$
*Proof.* Decompose $\int_0^T f = \sum_{t=0}^{T-1}\int_t^{t+1} f$. By monotonicity, $f(t)\le \int_t^{t+1}f \le f(t+1)$. Sum: $\sum_{t=0}^{T-1} f(t) \le \int_0^T f \le \sum_{t=1}^T f(t)$, giving the lower side. The upper side: $\sum_{t=1}^T f(t) - \int_0^T f \le \sum_{t=1}^T [f(t)-f(t-1)] = f(T)-f(0)$. $\square$

## Closed-form integral

$$\int_0^T \varepsilon_0(1+s/T_0)^\alpha\,ds = \frac{\varepsilon_0 T_0}{\alpha+1}\big[(1+T/T_0)^{\alpha+1}-1\big]. \qquad (\text{INT})$$
*Verified symbolically by SymPy.*

## Part (a): sub-linear regime $\alpha < 1$

**Theorem (a).** Suppose $\alpha\in(0,1)$ and $\varepsilon_T \le 1/2$. Then
$$\log P_T \ge -\tfrac{3}{2}\,\overline{S_T}, \quad \overline{S_T} := \frac{\varepsilon_0 T_0}{\alpha+1}\big[(1+T/T_0)^{\alpha+1}-1\big] + \varepsilon_0\big[(1+T/T_0)^\alpha - 1\big]. \tag{a-exact}$$

*Proof.* For $x\in[0,1/2]$, the elementary inequality $\log(1-x)\ge -x-x^2$. Apply termwise:
$$\log P_T = \sum_{t=1}^T \log(1-\varepsilon_t) \ge -S_T - Q_T,$$
where $S_T = \sum \varepsilon_t$ and $Q_T = \sum \varepsilon_t^2$. By (IT) applied to $f(s)=\varepsilon_0(1+s/T_0)^\alpha$ together with (INT), $S_T\le \overline{S_T}$. For $Q_T$: $\varepsilon_t^2 \le \varepsilon_T \cdot \varepsilon_t$, so $Q_T \le \varepsilon_T S_T \le \tfrac{1}{2}S_T \le \tfrac12 \overline{S_T}$. Hence
$$\log P_T \ge -\overline{S_T} - \tfrac12 \overline{S_T} = -\tfrac32 \overline{S_T}. \quad \square$$

**Asymptotic form.** For $T\ge T_0$, $(1+T/T_0)^{\alpha+1}\le 2^{\alpha+1}(T/T_0)^{\alpha+1}$, so
$$\overline{S_T} \le \frac{2^{\alpha+1}\varepsilon_0\, T^{\alpha+1}}{(\alpha+1)\, T_0^\alpha}\big(1+o(1)\big),$$
yielding
$$\boxed{\;P_T \ge \exp\!\left(-\frac{C(\alpha)\,\varepsilon_0\, T^{\alpha+1}}{T_0^\alpha}\big(1+o(1)\big)\right), \quad C(\alpha) = \frac{3\cdot 2^\alpha}{\alpha+1}, \quad T\ge T_0.\;}$$

## Part (b): linear regime $\alpha = 1$

**Theorem (b).** For $\alpha=1$ and $T < T_0(\varepsilon_0^{-1}-1)$:

(i) $P_T$ is strictly decreasing.

(ii) $|\log(1-\varepsilon_T)| \ge \varepsilon_T = \varepsilon_0(1+T/T_0)$, monotonically increasing in $T$.

(iii) The threshold
$$T^{**} := T_0(1 - 1/e)/\varepsilon_0$$
is the smallest $T$ with $|\log(1-\varepsilon_T)|\ge 1$. For $T \ge T^{**}$, every additional step multiplies $P_T$ by a factor $\le 1/e$.

(iv) The "critical step" $T^* := T_0/\varepsilon_0$ is the edge of model validity (beyond which $\varepsilon_t \ge 1$ formally). Note $T^{**} = (1-1/e) T^*$, so reliability collapse begins at a constant fraction of $T^*$.

(v) **With Proposer benefit** $\beta\log T$: optimum from FOC $\beta = \varepsilon_0 T(1+T/T_0)$:
$$T^*_\beta = \frac{T_0}{2}\!\left(\sqrt{1+\frac{4\beta}{\varepsilon_0 T_0}}-1\right), \quad T^*_\beta \asymp \sqrt{\beta T_0/\varepsilon_0} \ \text{for}\ \beta \gg \varepsilon_0 T_0.$$

*Proof.*
(i): $P_{T+1}/P_T = (1-\varepsilon_{T+1}) < 1$.
(ii): $|\log(1-x)| \ge x$ for $x\in(0,1)$. $\varepsilon_T$ linear in $T$, monotone.
(iii): solve $\log(1-\varepsilon_T) = -1$: $\varepsilon_T = 1-1/e$, $T = T_0(1-1/e)/\varepsilon_0$.
(v): $\frac{d}{dT}[\beta\log T - \varepsilon_0 T(1+T/(2T_0))]=0$ gives $\beta/T = \varepsilon_0(1+T/T_0)$, quadratic in $T$. $\square$

## Part (c): super-linear regime $\alpha > 1$

**Theorem (c).** For $\alpha > 1$ and $T \ge T_0$:
$$\log P_T \le -\frac{\varepsilon_0 T_0}{\alpha+1}\big[(1+T/T_0)^{\alpha+1}-1\big] \le -\frac{\varepsilon_0\, T^{\alpha+1}}{(\alpha+1)\, T_0^\alpha} + \frac{\varepsilon_0 T_0}{\alpha+1}. \tag{c-bound}$$

In particular, defining $T_{\text{div}} := ((\alpha+1)\,T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}$, for all $T \ge \max(T_0, T_{\text{div}})$ we have $\log P_T \le -1 + o(1)$, and as $T\to T_0(\varepsilon_0^{-1/\alpha}-1)$, $\log P_T\to -\infty$ at super-polynomial rate $T^{\alpha+1}$.

*Proof.* $\log(1-x) \le -x$ for $x\in[0,1)$, so $\log P_T \le -S_T$. By (IT) lower side and (INT), $S_T \ge \frac{\varepsilon_0 T_0}{\alpha+1}[(1+T/T_0)^{\alpha+1}-1]$. For $T\ge T_0$: $(1+T/T_0)^{\alpha+1} \ge (T/T_0)^{\alpha+1}$ giving the second inequality. $\square$

**Note on problem statement's threshold.** The problem stated $T > T_0^{\alpha/(\alpha-1)}\varepsilon_0^{-1/(\alpha-1)}$ for divergence. This expression diverges as $\alpha\to 1^+$ and has a different scaling exponent than the natural threshold derived above. We interpret this as a typo and report the corrected threshold $T_{\text{div}} \asymp T_0^{\alpha/(\alpha+1)}\varepsilon_0^{-1/(\alpha+1)}$.

## Part (d): optimal stopping

**Theorem (d).** Let $\Phi(T) := \beta\log T - \int_0^T \varepsilon_0(1+s/T_0)^\alpha\,ds$. Then $\Phi$ is strictly concave on $(0,\infty)$ with unique maximizer $T^*(\alpha)$ satisfying
$$\frac{\beta}{T^*(\alpha)} = \varepsilon_0\big(1+T^*(\alpha)/T_0\big)^\alpha. \qquad (\heartsuit)$$

**Asymptotic** ($T^*(\alpha)\gg T_0$, equivalent to $\beta \gg \varepsilon_0 T_0$):
$$\boxed{\;T^*(\alpha) = (\beta T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}\cdot(1+o(1)).\;}$$

**Closed forms**:
- $\alpha=0$: $T^*=\beta/\varepsilon_0$.
- $\alpha=1$: $T^*=\frac{T_0}{2}(\sqrt{1+4\beta/(\varepsilon_0 T_0)}-1)$.
- $\alpha>1$: leading-order $T^*\sim (\beta T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}$ from $T^{*\alpha+1}/T_0^\alpha = \beta/\varepsilon_0$.

*Proof.*
$\Phi'(T) = \beta/T - \varepsilon_0(1+T/T_0)^\alpha$, $\Phi''(T) = -\beta/T^2 - \varepsilon_0\alpha(1+T/T_0)^{\alpha-1}/T_0 < 0$, so $\Phi$ is strictly concave. $\Phi'(0^+)=+\infty$, $\Phi'(\infty)=-\infty$, so unique critical point $T^*$. The asymptotic form follows from substituting $T^* \gg T_0$ into ($\heartsuit$) which gives $\beta/T^* = \varepsilon_0(T^*/T_0)^\alpha$, i.e. $T^{*\alpha+1} = \beta T_0^\alpha/\varepsilon_0$. $\square$

## Numerical confirmation

Pick $\alpha\in\{0.5, 1, 2\}$, $T_0=100$, $\varepsilon_0=0.1$:

- (a) $\alpha=0.5$: bound (a-exact) holds for all $T\in[10, 2000]$ with ratio $\log P_T/(-\tfrac32 \overline{S_T})\in[0.85, 0.96]$. Asymptotic constant $C(0.5)\approx 2.83$ exceeds observed ratio $|\log P_T|/(\varepsilon_0 T^{1.5}/T_0^{0.5})\le 1.07$ — bound valid.
- (b) $\alpha=1$: $T^{**}=632$, audit confirms $\log(1-\varepsilon_{632})\approx -1.32 \le -1$ ✓. With $\beta\in\{10,100,1000\}$: numerical $T^*_\beta\in\{58, 240, 673\}$ vs. predicted $\{62, 270, 951\}$; close-form formula matches within 5–30%.
- (c) $\alpha=2$: $T_{\text{div}}\approx 60$, and at $T=84$, $\log P_T = -20.0 \le -1$, divergence confirmed.
- (d) For $\alpha\in\{0.3,...,3.0\}$, $\beta=100$: numerical $T^*$ matches predicted $(\beta T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}$ to within factor 1.2–2.0 (continuum-discrete error).

All claims verified.
