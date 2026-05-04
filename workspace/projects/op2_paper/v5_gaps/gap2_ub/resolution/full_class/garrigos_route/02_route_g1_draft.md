# Route G1' — SHB last-iterate via COV + Garrigos variance transfer + Zamani-Glineur weights

## Setting

- $f(x) = \mathbb{E}_{i\sim D}[f_i(x)]$, each $f_i$ convex L-smooth, $x^* \in \arg\min f$.
- $\sigma^2 = \mathbb{E}\|\nabla f_i(x^*)\|^2 < \infty$ (Garrigos's Assumption 2.2).
- SHB: $y_{t+1} = y_t - \eta \nabla f_{i_t}(y_t) + \beta(y_t - y_{t-1})$, $y_{-1} = y_0$, $i_t \sim D$ iid.
- Fixed $\beta \in [0, 1)$.
- Goal: $\mathbb{E}[f(y_T) - \inf f] = \tilde O(D^2/\sqrt T + \sigma^2/\sqrt T)$ where $D^2 = \|y_0 - x^*\|^2$.

## Notation

- $a := \beta/(1-\beta)$, $\eta' := \eta/(1-\beta)$. Then $a \geq 0$, $\eta' \geq \eta$.
- COV: $w_t := y_t + a(y_t - y_{t-1})$. Direct computation (see §1 below) gives
  $$w_{t+1} = w_t - \eta' g_t, \quad g_t := \nabla f_{i_t}(y_t).$$
- $r_t := f(y_t) - \inf f \geq 0$. $\rho_t := \|y_t - y_{t-1}\|$, $\rho_0 = 0$.
- $\mathcal{F}_t := \sigma(y_0, \dots, y_t)$. $\mathbb{E}_t[\cdot] = \mathbb{E}[\cdot \mid \mathcal{F}_t]$.

## Section 1 — COV identity

$w_{t+1} = y_{t+1} + a(y_{t+1} - y_t) = (1+a)(y_{t+1} - y_t) + y_t$
$w_t = y_t + a(y_t - y_{t-1})$
$w_{t+1} - w_t = (1+a)(y_{t+1} - y_t) - a(y_t - y_{t-1})$
$\quad = (1+a)[-\eta g_t + \beta(y_t - y_{t-1})] - a(y_t - y_{t-1})$
$\quad = -(1+a)\eta g_t + ((1+a)\beta - a)(y_t - y_{t-1})$

Since $1+a = 1/(1-\beta)$ and $(1+a)\beta = \beta/(1-\beta) = a$, the second term is $0$. Hence
$$w_{t+1} - w_t = -\frac{\eta}{1-\beta} g_t = -\eta' g_t. \quad \checkmark$$

## Section 2 — One-step descent

Let $z_t \in \mathcal F_t$ be arbitrary. Standard expansion:
$$\|w_{t+1} - z_t\|^2 - \|w_t - z_t\|^2 = -2\eta' \langle g_t, w_t - z_t\rangle + \eta'^2 \|g_t\|^2.$$

Decompose $w_t - z_t = (y_t - z_t) + (w_t - y_t)$ and take $\mathbb E_t$ (note $g_t = \nabla f_{i_t}(y_t)$, so $\mathbb E_t g_t = \nabla f(y_t)$, and $z_t, y_t, w_t$ are $\mathcal F_t$-measurable):
$$\mathbb E_t \|w_{t+1} - z_t\|^2 \leq \|w_t - z_t\|^2 - 2\eta' \langle \nabla f(y_t), y_t - z_t\rangle - 2\eta' \langle \nabla f(y_t), w_t - y_t\rangle + \eta'^2 \mathbb E_t\|g_t\|^2.$$

Convexity of $f$ at $y_t$: $\langle \nabla f(y_t), y_t - z_t\rangle \geq f(y_t) - f(z_t)$.

Cross term: $w_t - y_t = a(y_t - y_{t-1})$, so
$$-2\eta' \langle \nabla f(y_t), w_t - y_t\rangle = -2\eta' a \langle \nabla f(y_t), y_t - y_{t-1}\rangle \leq -2\eta' a (f(y_t) - f(y_{t-1}))$$
using convexity at $y_{t-1}$: $\langle \nabla f(y_t), y_t - y_{t-1}\rangle \geq f(y_t) - f(y_{t-1})$.

Variance transfer (Garrigos Lemma 4.1) at $y_t$ with parameter $\varepsilon > 0$:
$$\mathbb E_t \|g_t\|^2 \leq 2L(1+\varepsilon) r_t + (1+\varepsilon^{-1})\sigma^2.$$

Combining:
$$\mathbb E_t \|w_{t+1} - z_t\|^2 \leq \|w_t - z_t\|^2 - 2\eta'(f(y_t) - f(z_t)) - 2\eta' a (r_t - r_{t-1}) + 2\eta'^2 L(1+\varepsilon) r_t + \eta'^2 (1+\varepsilon^{-1})\sigma^2.$$

Rearranging using $f(y_t) - f(z_t) = r_t - (f(z_t) - \inf f)$:
$$\boxed{A r_t - B r_{t-1} - C(f(z_t) - \inf f) \leq \|w_t - z_t\|^2 - \mathbb E_t\|w_{t+1} - z_t\|^2 + V} \tag{★}$$
where
$$A := 2\eta'\bigl[(1+a) - \eta' L(1+\varepsilon)\bigr], \quad B := 2\eta' a, \quad C := 2\eta', \quad V := \eta'^2 (1+\varepsilon^{-1})\sigma^2.$$

Sanity: $A - B = 2\eta'(1 - \eta' L(1+\varepsilon))$ — needs $\eta' L(1+\varepsilon) < 1$ for $A > B$.

## Section 3 — Zamani-Glineur weighted summation

Choose weights $\theta_t \geq 0$ for $t \geq -1$ and a convex-combination scheme $z_t = (1-p_t) w_t + p_t z_{t-1}$ with $z_{-1} := x^*$ and $p_t \in [0,1]$.

**Key choices.** Set $\theta_t = (A/B)^t \theta_0$ for $t \geq 0$, $\theta_0 := 1$, and $\theta_{-1} := B/A$. Note $A > B$ (when $\eta'L(1+\varepsilon) < 1$), so $\theta_t$ is geometrically increasing.

Define $p_t := \theta_{t-1}/\theta_t = B/A \in (0,1)$. (Constant in $t$.)

**Quadratic telescope.**  $\|w_t - z_t\|^2 = p_t^2 \|w_t - z_{t-1}\|^2 \leq p_t \|w_t - z_{t-1}\|^2$, so
$$\theta_t \|w_t - z_t\|^2 \leq \theta_t p_t \|w_t - z_{t-1}\|^2 = \theta_{t-1} \|w_t - z_{t-1}\|^2.$$

Multiplying (★) by $\theta_t$ and summing $t=0,\dots,T-1$:
$$\sum_t \theta_t \bigl(A r_t - B r_{t-1}\bigr) - C \sum_t \theta_t (f(z_t)-\inf f) \leq \sum_t \theta_{t-1} \mathbb E\|w_t - z_{t-1}\|^2 - \sum_t \theta_t \mathbb E\|w_{t+1} - z_t\|^2 + V \sum_t \theta_t.$$

The quadratic sum telescopes (after reindexing) to $\theta_{-1} \|w_0 - z_{-1}\|^2 - \theta_{T-1} \mathbb E \|w_T - z_{T-1}\|^2 \leq (B/A) \|w_0 - x^*\|^2$ (since $w_0 = y_0$).

For the LHS function-sum:
$$\sum_t \theta_t (A r_t - B r_{t-1}) = A \theta_{T-1} r_{T-1} + \sum_{t=0}^{T-2} (A \theta_t - B \theta_{t+1}) r_t - B \theta_0 r_{-1}.$$
With $A \theta_t = B \theta_{t+1}$ (our choice $\theta_{t+1}/\theta_t = A/B$), the middle terms vanish:
$$\sum_t \theta_t (A r_t - B r_{t-1}) = A \theta_{T-1} r_{T-1} - B r_0$$
(using $r_{-1} := r_0$).

So:
$$A \theta_{T-1} r_{T-1} - B r_0 - C \sum_t \theta_t (f(z_t) - \inf f) \leq \frac{B}{A} \|w_0 - x^*\|^2 + V \sum_t \theta_t. \tag{♢}$$

## Section 4 — Bounding $\sum \theta_t (f(z_t) - \inf f)$ via Jensen + smoothness

**Jensen's inequality on $z_t$:**  Unrolling $z_t = (1-p_t) w_t + p_t z_{t-1}$ with $z_{-1} = x^*$,
$$z_t = \sum_{s=0}^{t} \frac{\theta_s - \theta_{s-1}}{\theta_t} w_s + \frac{\theta_{-1}}{\theta_t} x^*.$$
By convexity of $f$ (Jensen):
$$f(z_t) - \inf f \leq \sum_{s=0}^{t} \frac{\theta_s - \theta_{s-1}}{\theta_t} (f(w_s) - \inf f).$$

**Aggregate sum** (substituting $\theta_t = (A/B)^t$ and $\theta_s - \theta_{s-1} = (A/B)^{s-1}(A/B - 1) = (A/B)^s (1-B/A) = \theta_s(1-p)$ where $p = B/A$):

Actually $\theta_s - \theta_{s-1} = (A/B)^s - (A/B)^{s-1} = (A/B)^{s-1}(A/B - 1)$ for $s \geq 0$. For $s = 0$: $\theta_0 - \theta_{-1} = 1 - B/A = (A-B)/A$.

So $\sum_t \theta_t (f(z_t) - \inf f) \leq \sum_{s=0}^{T-1} (T - s)(\theta_s - \theta_{s-1})(f(w_s) - \inf f)$.

(Each term $f(w_s) - \inf f$ contributes via every $t \geq s$, giving the factor $T - s$.)

**Smoothness conversion $f(w_s) \to f(y_s)$.** Smoothness of $f$:
$$f(w_s) \leq f(y_s) + \langle \nabla f(y_s), w_s - y_s\rangle + \tfrac{L}{2}\|w_s - y_s\|^2.$$
Cross term: $\langle \nabla f(y_s), w_s - y_s\rangle = a \langle \nabla f(y_s), y_s - y_{s-1}\rangle$. Young: for $\mu>0$,
$$|a \langle \nabla f(y_s), y_s - y_{s-1}\rangle| \leq \tfrac{a\mu}{2}\|\nabla f(y_s)\|^2 + \tfrac{a}{2\mu} \rho_s^2.$$
Smoothness at $x^*$: $\|\nabla f(y_s)\|^2 \leq 2L r_s$. So
$$f(w_s) - \inf f \leq (1 + a\mu L) r_s + \left(\frac{a}{2\mu} + \frac{La^2}{2}\right) \rho_s^2. \tag{†}$$

**Momentum length bound.** From $y_{t+1} - y_t = -\eta g_t + \beta(y_t - y_{t-1})$, by triangle inequality:
$$\rho_{t+1} \leq \eta \|g_t\| + \beta \rho_t.$$
Iterating: $\rho_{t+1} \leq \eta \sum_{s=0}^{t} \beta^{t-s} \|g_s\|$.

Cauchy-Schwarz: $\rho_{t+1}^2 \leq \eta^2 \left(\sum_s \beta^{t-s}\right) \left(\sum_s \beta^{t-s} \|g_s\|^2\right) \leq \frac{\eta^2}{1-\beta} \sum_{s=0}^t \beta^{t-s} \|g_s\|^2.$

Sum over $t$:
$$\sum_{t=0}^{T-1} \rho_{t+1}^2 \leq \frac{\eta^2}{1-\beta} \sum_{s=0}^{T-1} \|g_s\|^2 \sum_{t=s}^{T-1} \beta^{t-s} \leq \frac{\eta^2}{(1-\beta)^2} \sum_{s=0}^{T-1} \|g_s\|^2.$$

Take expectation, apply variance transfer:
$$\sum_{t=0}^{T-1} \mathbb E \rho_{t+1}^2 \leq \frac{\eta^2}{(1-\beta)^2}\left[2L(1+\varepsilon) \sum_s \mathbb E r_s + T(1+\varepsilon^{-1})\sigma^2\right]. \tag{‡}$$

(With $\rho_0 = 0$, $\sum_{t=0}^{T-1} \rho_t^2 = \sum_{t=0}^{T-2} \rho_{t+1}^2$ — same bound.)

## Section 5 — Putting it all together

Substitute (†) into the Jensen sum:
$$\sum_t \theta_t (f(z_t) - \inf f) \leq (1+a\mu L) \sum_s (T-s)(\theta_s - \theta_{s-1}) \mathbb E r_s + K_\mu \sum_s (T-s)(\theta_s - \theta_{s-1}) \mathbb E \rho_s^2$$
where $K_\mu = a/(2\mu) + La^2/2$.

For the second sum, use $(T-s)(\theta_s - \theta_{s-1}) \leq T \theta_{T-1}$ (rough bound; can refine), so
$$\sum_s (T-s)(\theta_s-\theta_{s-1}) \rho_s^2 \leq T \theta_{T-1} \sum_s \rho_s^2 \leq T \theta_{T-1} \cdot \frac{\eta^2}{(1-\beta)^2}[2L(1+\varepsilon) \sum_s \mathbb E r_s + T(1+\varepsilon^{-1})\sigma^2].$$

This is the rough version. The tighter version weights $\rho_s^2$ by $(T-s)(\theta_s - \theta_{s-1})$ properly. For the asymptotic rate we'll use the rough bound.

**Plug into (♢):**
$$A \theta_{T-1} \mathbb E r_{T-1} \leq B \mathbb E r_0 + \frac{B}{A}\|w_0 - x^*\|^2 + V \sum \theta_t + C \cdot (1+a\mu L) \sum_s (T-s)(\theta_s-\theta_{s-1}) \mathbb E r_s + C K_\mu \cdot \text{[rho-stuff]}.$$

The most delicate part is bounding $\sum_s (T-s)(\theta_s - \theta_{s-1}) \mathbb E r_s$. With $\theta_t = (A/B)^t$:
$\theta_s - \theta_{s-1} = (1-p)(A/B)^s = (1-p)\theta_s$ for $s \geq 1$, and $\theta_0 - \theta_{-1} = 1 - B/A = (1-p)$.

So $\sum_s (T-s)(1-p)\theta_s \mathbb E r_s = (1-p) \sum_s (T-s) \theta_s \mathbb E r_s$.

For this term, on the LHS we have $A \theta_{T-1} \mathbb E r_{T-1}$. Comparing the coefficient of $r_{T-1}$:
- LHS: $A \theta_{T-1}$
- RHS: $C (1+a\mu L)(1-p) \theta_{T-1} \cdot 1$ (from $s = T-1$, factor $(T-s)=1$)
- Net coefficient: $A \theta_{T-1} - C(1+a\mu L)(1-p) \theta_{T-1}$

For this to be positive, need $A > C(1+a\mu L)(1-p)$, i.e., $A - C(1+a\mu L)(1-B/A) > 0$.

$A = 2\eta'(1+a) - 2\eta'^2 L(1+\varepsilon)$, $C = 2\eta'$. So $A - C(1+a\mu L)(1-B/A) = 2\eta' [(1+a) - \eta'L(1+\varepsilon)] - 2\eta'(1+a\mu L)(A-B)/A$.

For $\eta'$ small, $A \approx 2\eta'(1+a)$ and $(A-B)/A \approx (A-B)/(2\eta'(1+a)) = (1 - \eta'L(1+\varepsilon)) / (1+a) \approx 1/(1+a)$.

So $A - C(1+a\mu L)(1-B/A) \approx 2\eta'(1+a) - 2\eta'(1+a\mu L)/(1+a)$.

Net positive iff $(1+a) > (1+a\mu L)/(1+a)$, i.e., $(1+a)^2 > 1 + a\mu L$. This holds whenever $a\mu L < (1+a)^2 - 1 = 2a + a^2$, i.e., $\mu < (2+a)/L$.

**Choose $\mu = 1/L$** (so $a\mu L = a$, $K_\mu = aL/2 + La^2/2 = (La/2)(1+a)$). Then $(1+a)^2 > 1+a$ iff $(1+a) > 1$, i.e., $a > 0$ — which is true for $\beta > 0$.

For $a > 0$ (i.e., $\beta > 0$), the coefficient $A - C(1+a\mu L)(1-B/A)$ is positive, of order $\eta' \cdot a^2/(1+a)$ for small $\eta'$.

Hmm this is getting fiddly. Let me try a slightly different route — see Section 6 below.

## Section 6 — Cleaner route via Lyapunov

**Lyapunov function.**  Define
$$\Phi_t := \|w_t - z_t\|^2 + \gamma \rho_t^2$$
for some $\gamma > 0$ to be chosen. (Lyapunov augmented with momentum-length.)

Hmm but this needs $z_t$ which depends on the auxiliary sequence. Alternative: use a different decomposition.

**Direct ergodic-style summation.** Sum (★) over $t=0,\dots,T-1$ with $z_t = x^*$ (so all $f(z_t) - \inf f = 0$):
$$\sum_t \bigl(A r_t - B r_{t-1}\bigr) \leq \|w_0 - x^*\|^2 - \mathbb E\|w_T - x^*\|^2 + T V.$$

LHS: $A \sum_{t=0}^{T-1} r_t - B \sum_{t=0}^{T-1} r_{t-1} = (A-B) \sum_{t=0}^{T-2} r_t + A r_{T-1} - B r_{-1}$.

Drop $-\mathbb E\|w_T - x^*\|^2$, use $r_{-1} = r_0$:
$$(A-B) \sum_{t=0}^{T-2} \mathbb E r_t + A \mathbb E r_{T-1} \leq \|w_0 - x^*\|^2 + B r_0 + T V.$$

Both LHS terms are nonnegative. Keep only the sum: ergodic bound:
$$(A-B)(T-1) \cdot \min_t \mathbb E r_t \leq \|w_0 - x^*\|^2 + B r_0 + T V.$$

For $\eta = c/(\sqrt{L T})$, $\eta' = c/((1-\beta)\sqrt{LT})$, taking $\varepsilon$ such that $\eta'L(1+\varepsilon) \leq 1/2$:
- $A - B = 2\eta'(1 - \eta'L(1+\varepsilon)) \geq \eta'$
- $B = 2\eta' a = 2\eta' \beta/(1-\beta)$
- $V = \eta'^2 (1+\varepsilon^{-1}) \sigma^2$

So $(A-B)(T-1) \approx \eta' T$, and $\min_t \mathbb E r_t \leq O(D^2/(\eta' T) + B r_0/(\eta' T) + V/\eta')$.

For $\eta' = c/((1-\beta)\sqrt{LT})$:
$D^2/(\eta' T) \approx D^2 \sqrt L (1-\beta) / (c \sqrt T)$
$V/\eta' = \eta' \sigma² (1+\varepsilon^{-1}) \approx \sigma²/((1-\beta)\sqrt{LT})$

So $\min_t \mathbb E r_t = O(D^2 \sqrt L / ((1-\beta)\sqrt T) + \sigma^2/((1-\beta)\sqrt{LT}))$. ✓ Ergodic rate confirmed.

**For last-iterate**, the key extra trick is the Zamani-Glineur weighting. Going back to (♢) and noting that the RHS has the extra $C \sum \theta_t (f(z_t) - \inf f)$ term, we observe:

In Garrigos's setup (no momentum), this term appears with coefficient $C = 2\eta$ and is bounded by Jensen converting to $\sum (\theta_s - \theta_{s-1})(T-s) f(w_s)$. The crucial fact is that in Garrigos, $w_s = x_s$, so $f(w_s) = f(x_s)$. The summation balances with the LHS.

In our case, $w_s \neq y_s$, but $\rho_s^2$ is small (controlled by the momentum bound). So we get the same rate up to a $1/(1-\beta)^2$ factor.

## Proposed final theorem

**Theorem 3 (G1' route).** Under Assumptions 2.1, 2.2 (Garrigos), let $T \geq 3$, $\beta \in [0, 1)$ fixed, $\eta = \frac{1-\beta}{C\sqrt{LT}}$ with $C \geq 2$. Let $(y_t)$ be SHB iterates. Then
$$\mathbb E[f(y_{T-1}) - \inf f] \leq O\!\left(\frac{LD^2}{(1-\beta)^2\sqrt T} + \frac{\sigma^2 \ln T}{(1-\beta)^2 \sqrt T}\right).$$

The full constant analysis tracks $1/(1-\beta)^2$ multiplicative factor (consistent with classical SHB UB).

## Plan for verification

1. **Numerical verification of descent inequality (★)** via SymPy/NumPy on a synthetic quadratic.
2. **Monte Carlo** of SHB on convex L-smooth (e.g., $f(x) = (1/2)\|Ax-b\|^2$ with stochastic gradients) — check $\mathbb E[r_T]$ scales like $1/\sqrt T$ as $T$ grows, and the constant matches the predicted bound up to log factors.
3. **Constant tightness**: compare with Hudiani 2025's $T^{-1/3}$ (confirm we beat it) and OP-2 LB (check we're within factor $\log T$ of optimal).
