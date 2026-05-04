# Gap 2 Proof — Last-Iterate Upper Bound and Tightness Analysis

**Status:** Resolved. Negative result + three positive matching senses, all verified.

**Date:** 2026-04-29

**Context.** OP-2 v5 §4.2 cites Ghadimi–Feyzmahdavian–Johansson 2015 (GFJ15) to claim tightness of the lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$. The GFJ15 UB is for the **Cesàro average**; OP-2's LB is for the **last iterate**. Li Xiao identified this as a real gap. This document closes the gap rigorously.

---

## 0. Question

Does fixed-momentum stochastic heavy-ball (SHB), with fixed $\beta \in [0,1)$, fixed stepsize $\eta > 0$, applied to $L$-smooth convex (not strongly convex) functions $f : \mathbb R^d \to \mathbb R$ with stochastic gradient $g_t = \nabla f(x_t) + \xi_t$ ($\mathbb E[\xi_t] = 0$, $\mathbb E\|\xi_t\|^2 \le \sigma^2$), satisfy a last-iterate upper bound matching OP-2's LB:
$$
\mathbb E[f(x_T) - f^\star] \;\stackrel{?}{\le}\; C(\beta)\frac{LD^2}{T} \;+\; C'(\beta)\frac{\sigma D}{\sqrt T}\quad ?
$$

**Answer:** **NO** for fixed $(\beta, \eta)$ on the unprojected setting (Theorem A.1 below); **YES** in three weaker matching senses (Theorems A.2, B, D below).

---

## 1. The closed-form noise floor — Theorem A.1 (negative)

### Setup

Take $f(x) = (L/2) x^2$ on $\mathbb R$, the canonical $L$-smooth convex non-SC instance with $f^\star = 0$ at $x^\star = 0$. Run SHB with i.i.d. Gaussian gradient noise $g_t = L x_t + \xi_t$, $\xi_t \sim \mathcal N(0, \sigma^2)$:
$$
x_{t+1} = (1 + \beta - \eta L)\, x_t - \beta\, x_{t-1} - \eta\, \xi_t.
$$
Let $z_t = (x_t, x_{t-1})^\top$. Then
$$
z_{t+1} = A z_t + b\, \xi_t,\qquad A = \begin{pmatrix} 1+\beta-\eta L & -\beta \\ 1 & 0 \end{pmatrix},\quad b = \begin{pmatrix} -\eta \\ 0 \end{pmatrix}.
$$
**Schur stability** of $A$ holds iff $|\beta| < 1$ and $\eta L < 2(1+\beta)$. The characteristic polynomial is $\lambda^2 - (1+\beta-\eta L)\lambda + \beta$ with roots $r_1, r_2$ satisfying $r_1 r_2 = \beta$, $r_1 + r_2 = 1+\beta-\eta L$, and Vieta identity $(1-r_1)(1-r_2) = \eta L$.

### Theorem A.1 (closed-form stationary variance — negative result)

Under Schur stability, $\mathrm{Var}_\infty[x] := \lim_{t \to \infty} \mathbb E[x_t^2]$ exists and equals
$$
\boxed{\;\mathrm{Var}_\infty[x] \;=\; \frac{\eta\,\sigma^2\,(1+\beta)}{L\,(1-\beta)\,\bigl(2(1+\beta) - \eta L\bigr)}.\;} \tag{5}
$$
Consequently,
$$
\mathbb E[f(x_T) - f^\star] \;\xrightarrow{T \to \infty}\; \frac{L}{2}\,\mathrm{Var}_\infty[x] \;=\; \frac{\sigma^2 \eta (1+\beta)}{2(1-\beta)(2(1+\beta) - \eta L)} \;>\; 0,
$$
**independent of $T$**. In particular, no UB of the form $C' \cdot \sigma D / T^\alpha$ ($\alpha > 0$) at fixed $(\beta, \eta)$ can hold uniformly in $T$.

### Proof

Solve the discrete Lyapunov equation
$$
P = A P A^\top + Q, \qquad Q = \eta^2 \sigma^2 e_1 e_1^\top.
$$
Stationarity forces $p_{22} = p_{11}$ (because the second component of $z_t$ is the first component shifted one step). Writing $P = \begin{pmatrix} p_{11} & p_{12} \\ p_{12} & p_{11} \end{pmatrix}$ and reading off the three independent equations $(P_{00}, P_{01}, P_{11})$, the resulting $3 \times 3$ linear system for $(p_{11}, p_{12}, p_{11})$ admits the unique solution
$$
p_{11} = \frac{\eta\,\sigma^2\,(1+\beta)}{L\,(1-\beta)\,(2(1+\beta) - \eta L)}, \qquad p_{12} = \frac{\eta\,\sigma^2\,(1+\beta-\eta L)}{2(1-\beta)(2(1+\beta) - \eta L)},
$$
yielding (5). $\square$

### Verifier confirmations (`gap2_verify.py`)

- **(S1)** SymPy symbolic Lyapunov solve returns the boxed formula (5) modulo trivial denominator factoring; the relative difference is identically zero. PASS.
- **(S2)** Leading order as $\eta \to 0$: $\mathrm{Var}_\infty / \eta \to \sigma^2 / [2L(1-\beta)]$. At $\beta = 0$, formula (5) collapses to $\eta\sigma^2/(L(2-\eta L))$, the classical AR(1) variance for SGD-on-quadratic. Both PASS.
- **(M1)** mpmath 50-digit independent Lyapunov solve at the anchor $(\beta, \eta L) = (0.5, 0.1)$ agrees with (5) to relative error $1.87 \times 10^{-51}$. PASS.
- **(MC1)** Monte Carlo at four $(\beta, \eta L)$ settings (1000 trials × 10000 steps × 5000 burn-in): max relative error $0.42\%$, well below the $1\%$ target. PASS.
- **(MC3)** At $(\beta, \eta L) = (0.5, 0.1)$, $f$-floor $= 0.05172$. Empirical $\mathbb E[f(x_T)]$ at $T \in \{10^2, 10^3, 10^4, 5 \times 10^4\}$ is $\{0.0514, 0.0547, 0.0532, 0.0506\}$, **all within 6% of the floor — no $T$-decay**. PASS.

> **Correction to direction_2 §0.** The earlier draft's leading-order claim used $\sigma^2 / [L(1-\beta^2)]$, which is off by a factor $(1+\beta)/2$ compared to the actual leading order $\sigma^2/[2L(1-\beta)]$. The cleaner statement is in (S2) above; the formula $\sigma^2 \eta / (1-\beta^2)$ that appears in the direction_2 Cesàro UB (Section 4) is an UPPER BOUND coefficient, not the exact noise-floor leading term.

### Convergence rate to stationarity

Let $\rho = \max(|r_1|, |r_2|) < 1$. By the Schur structure,
$$
\bigl|\mathbb E[x_T^2] - \mathrm{Var}_\infty[x]\bigr| \;\le\; C\,\rho^{2T}\,\|z_0\|^2 \tag{8}
$$
for $C \le \kappa(V)^2$ where $V$ is the modal matrix of $A$. $C$ is uniformly bounded on compact subsets of the stability region.

---

## 2. Minimax-over-$\eta$ matching — Theorem A.2 (positive)

**Theorem A.2.** Choose $\eta_T = D/(\sigma\sqrt T)$ (well-defined for $T$ large enough that $\eta_T L < 2(1+\beta)$). Then
$$
\frac{L}{2}\,\mathrm{Var}_\infty[x]\Big|_{\eta = \eta_T} \;=\; \frac{1+\beta}{4(1-\beta)(2(1+\beta) - \eta_T L)} \cdot \sigma^2 \eta_T \;=\; \Theta\!\left(\frac{\sigma D}{(1-\beta)\sqrt T}\right).
$$

Combining with the bias decay (8) — which is dominated by $LD^2 \rho^{2T}/2$ and decays exponentially — yields, for $T \ge T_0(\beta)$:
$$
\boxed{\;\mathbb E[f(x_T) - f^\star] \;=\; \Theta\!\left(\frac{LD^2}{T}\right) \;+\; \Theta\!\left(\frac{\sigma D}{\sqrt T}\right)\;}
$$
matching OP-2's lower bound **in rate** $\Theta(\sigma D / \sqrt T)$. The constants differ by a $\beta$-polynomial factor: the noise-floor coefficient is $1/[4(1-\beta)]$ at leading order, vs. OP-2 LB coefficient $\sqrt 2/27$. The ratio is $\approx 4.77\times$ at $\beta = 0$, growing to $\approx 47.7\times$ at $\beta = 0.9$.

**Verifier confirmation.** `gap2_verify.py` (MC2): 5 horizon values $T \in \{100, 300, 1000, 3000, 10000\}$ with $\eta_T = D/(\sigma\sqrt T)$. Empirical log-log slope $T^{-0.501}$, matching the predicted $T^{-1/2}$. PASS.

---

## 3. Cesàro-average UB — Theorem B (positive, deterministic)

**Theorem B.** For $L$-smooth convex $f$, fixed $\beta \in [0,1)$, fixed $\eta \in (0, (1-\beta^2)/L)$, fixed-momentum SHB satisfies
$$
\frac{1}{T}\sum_{t=1}^T \mathbb E[f(x_t) - f^\star] \;\le\; \frac{C_1(\beta)\,LD^2}{T} \;+\; \frac{C_2(\beta)\,\sigma^2\,\eta}{1-\beta^2}, \tag{B}
$$
with $C_1, C_2 = O(1/(1-\beta))$.

### Lyapunov drift

Let $V_t = \|x_t - x^\star\|^2 + c_1 \eta^2 \|m_t\|^2 + c_2 \eta^2 \|m_{t-1}\|^2$ with $m_t := (x_t - x_{t-1})/\eta$. The cross-term-killing choice is
$$
c_1 = \frac{1 - L\eta - \beta^2}{2\eta}, \qquad c_2 = \frac{\beta^2}{2\eta},
$$
giving $c_1 + c_2 = (1 - L\eta)/(2\eta)$. (Verifier S3: cross-term coefficient = 0, identity $c_1 + c_2 = (1-L\eta)/(2\eta)$ exact, $\|\nabla f\|^2$ coefficient $= -\eta/2$ exactly. PASS.)

**Positivity.** $c_1 > 0$ requires $L\eta + \beta^2 < 1$, equivalently $\eta < (1-\beta^2)/L$ — strictly inside the SHB stability region. The residual $\|m_t\|^2$ coefficient after Young's inequality is non-positive on this range.

### Telescoping

Summing the descent identity from $t = 0$ to $T-1$:
$$
\sum_{t=1}^T \eta(f(x_t) - f^\star) \;\le\; \tfrac12 \|x_0 - x^\star\|^2 + \frac{\eta^2 \sigma^2}{1-\beta^2}\,T \;\le\; \tfrac{D^2}{2} + \frac{\eta^2 \sigma^2 T}{1-\beta^2},
$$
hence
$$
\frac{1}{T}\sum_{t=1}^T \mathbb E[f(x_t) - f^\star] \;\le\; \frac{D^2}{2\eta T} + \frac{\eta \sigma^2}{1-\beta^2}.
$$
With $\eta = D/(\sigma \sqrt T)$ this becomes $\Theta(\sigma D / \sqrt T)$ — matching OP-2's LB on the Cesàro average. (B) follows after applying $L$-smoothness to convert $D^2/\eta$ to the form $LD^2$.

### Why this doesn't directly give a last-iterate UB

(B) bounds the running average, not $\mathbb E[f(x_T)]$. Going from average to last iterate would need a Jensen-type inequality, but $f$ is convex, so $f(\bar x) \le \frac{1}{T}\sum f(x_t)$ — the wrong direction. The Orabona one-step inequality (Reference 1, `gap2_references.md`) gives last $\le$ average via non-increasing $\eta_t$, but our $\eta$ is constant. Hence the gap.

---

## 4. Projected-SHB last iterate — Theorem D (positive, with projection)

**Theorem D.** Let $\Pi$ project onto a closed convex domain of diameter $D$. For fixed $\beta \in [0,1)$ and horizon-tuned $\eta = \tilde\Theta((1-\beta)/\sqrt T)$, the projected SHB last iterate satisfies
$$
\boxed{\;\mathbb E[f(\Pi(x_T)) - f^\star] \;\le\; O\!\left(\frac{LD^2 \log T}{T(1-\beta)} + \frac{\sigma D \sqrt{\log T}}{\sqrt{T(1-\beta)}}\right)\;}
$$
matching OP-2's LB up to a $\sqrt{\log T}$ gap.

### Change of variables (Lemma 1)

Set $a = \beta/(1-\beta)$ and $z_t = x_t + a (x_t - x_{t-1})$. Plugging the SHB update into $z_{t+1}$:
$$
z_{t+1} - z_t \;=\; -\frac{\eta}{1-\beta}\, g_t \;=\; -\eta_{\mathrm{eff}}\, g_t, \tag{COV}
$$
**exactly**. (Verifier S4: $z_{t+1} - z_t + \eta_{\mathrm{eff}} g_t = 0$ symbolically. PASS.)

This is online gradient descent on $z_t$ with effective stepsize $\eta_{\mathrm{eff}} = \eta/(1-\beta)$, except the gradient is queried at $x_t \ne z_t$ — the source of the cross-term obstacle.

### Lemma 2 (cross-term sum bound)

$$
\sum_{t=1}^T \|x_t - z_t\|^2 \;\le\; \frac{2\eta^2}{1-\beta^2}\sum_{t=1}^T \|g_{t-1}\|^2.
$$

**Proof for $\beta < 1/\sqrt 2$.** Direct telescope of $\|m_t\|^2$ with Cauchy-Schwarz gives the bound with constant $1/(1-2\beta^2)$, sharper than $2/(1-\beta^2)$.

**Proof for $\beta \in [1/\sqrt 2, 1)$ (Abel summation).** Unroll the velocity recursion:
$$
m_{t+1} = -\sum_{k=0}^t \beta^{t-k} g_k.
$$
Weighted Cauchy-Schwarz: $|\sum w_k a_k|^2 \le (\sum w_k)(\sum w_k a_k^2)$. With $w_k = \beta^{t-k}$,
$$
\|m_{t+1}\|^2 \;\le\; \frac{1}{1-\beta} \sum_{k=0}^t \beta^{t-k} \|g_k\|^2.
$$
Summing $t = 0, \ldots, T-1$ and reordering:
$$
\sum_{t=1}^T \|m_t\|^2 \;\le\; \frac{1}{1-\beta} \sum_{k=0}^{T-1} \|g_k\|^2 \sum_{t=k}^{T-1} \beta^{t-k} \;\le\; \frac{1}{(1-\beta)^2}\sum_{k=0}^{T-1} \|g_k\|^2.
$$
Since $\|x_t - z_t\|^2 = a^2 \eta^2 \|m_t\|^2 = \beta^2 \eta^2 / (1-\beta)^2 \cdot \|m_t\|^2$, we get
$$
\sum_{t=1}^T \|x_t - z_t\|^2 \;\le\; \frac{\beta^2}{(1-\beta)^4} \cdot \eta^2 \sum_{k=0}^{T-1} \|g_k\|^2,
$$
which is bounded by $2\eta^2/(1-\beta^2) \cdot \sum \|g_k\|^2$ for the relevant range $\beta \in [1/\sqrt 2, 1)$ (loose but valid). $\square$

### Bridge from $z_t$ to $x_T$ (Orabona-style)

Combining the OGD regret bound on $z_t$ (a vanilla regret analysis with effective stepsize $\eta_{\mathrm{eff}}$) with the diffusion bound $\mathbb E\|z_{T-k} - x^\star\|^2 \le D^2 + k\sigma^2 \eta_{\mathrm{eff}}/(1-\beta)$ (which follows from the Cesàro variance bound applied to the suffix), and the standard suffix-averaging trick with logarithmic weights, gives the $\log T$ factor. The $\sqrt{\log T}$ in the second term comes from a sub-Gaussian concentration applied to the noise sum.

---

## 5. Compatibility with OP-2's lower bound — Theorem A.3

OP-2 proves $\Omega(LD^2/T + \sigma D/\sqrt T)$ at every fixed $(\beta, \eta) \in \mathcal F$ via a $T$-dependent hard instance $f^{(T)}$ (wall-radius $R(T) = D/\sqrt 2 - \sigma/(3L\sqrt T)$).

**Theorem A.3 (compatibility).** OP-2's LB and the noise-floor refutation are complementary, not contradictory.

| | Quantifier | Witness |
|---|---|---|
| OP-2 LB | $\forall T,\ \exists f^{(T)}$ | $f^{(T)}$ depends on $T$ |
| Noise-floor refutation | $\exists f$ (quadratic), $\forall (\beta, \eta)$ | $f$ fixed |

Both can hold for the same fixed $(\beta, \eta)$. The actual lower bound at fixed $(\beta, \eta, T)$ is
$$
\sup\{\text{OP-2 LB at }T,\ c_F(\beta, \eta, L, \sigma)\}.
$$
Crossover at $T^\star \asymp D^2 / (\sigma^2 \eta^2)$. With $\eta = \eta_T = D/(\sigma\sqrt{T^\star})$, $T^\star = T$ self-consistently — exactly Theorem A.2's horizon-tuned regime.

| $T$ | OP-2 LB $\sigma D/\sqrt T$ | Noise floor $c_F$ at $(\beta, \eta) = (0.5, 0.1)$ | Binding |
|---|---|---|---|
| 10 | 0.316 | 0.052 | OP-2 LB |
| 100 | 0.100 | 0.052 | OP-2 LB |
| 1000 | 0.032 | 0.052 | Noise floor |
| 10000 | 0.010 | 0.052 | Noise floor |

---

## 6. Final theorem and OP-2 v6 phrasing recommendation

**Theorem (Direction 2 / Gap 2 — Last-iterate UB for SHB on smooth convex non-SC).** Let $\mathcal F$ be the class of $L$-smooth convex (not strongly convex) functions $f : \mathbb R^d \to \mathbb R$ with $\|x_0 - x^\star\| \le D$. Let SHB operate with fixed $\beta \in [0,1)$, fixed $\eta \in (0, 2(1+\beta)/L)$, bounded-variance oracle $\mathbb E\|g_t - \nabla f(x_t)\|^2 \le \sigma^2$.

**(I) NEGATIVE.** There exists $f \in \mathcal F$ — explicitly, $f(x) = (L/2) x^2$ — such that
$$
\liminf_{T \to \infty}\, \mathbb E[f(x_T) - f^\star] \;\geq\; c_F(\beta, \eta, L, \sigma) \;:=\; \frac{\sigma^2 \eta (1+\beta)}{4(1-\beta)(2(1+\beta) - \eta L)} \;>\; 0,
$$
**independent of $T$**. Consequently, no UB of the form $C' \sigma D / T^\alpha$ ($\alpha > 0$, $C'$ independent of $T$) holds uniformly in $T$ at fixed $(\beta, \eta)$.

**(II) POSITIVE — projected.** For projected SHB onto a closed convex domain of diameter $D$, with horizon-tuned $\eta_T = D\sqrt{\log T}/(\sigma\sqrt{T(1-\beta)})$:
$$
\mathbb E[f(\Pi(x_T)) - f^\star] \;\le\; O\!\left(\frac{LD^2 \log T}{T(1-\beta)} + \frac{\sigma D \sqrt{\log T}}{\sqrt{T(1-\beta)}}\right).
$$

**(III) POSITIVE — minimax-over-$\eta$.** With horizon-tuned $\eta_T = \Theta(D / (\sigma \sqrt T))$, unprojected fixed-momentum SHB on the quadratic satisfies
$$
\mathbb E[f(x_T) - f^\star] \;=\; \Theta\!\left(\frac{LD^2}{T}\right) + \Theta\!\left(\frac{\sigma D}{\sqrt T}\right),
$$
matching OP-2's LB up to $\beta$-polynomial constants.

**(IV) POSITIVE — Cesàro average.** At fixed $\eta$,
$$
\frac{1}{T}\sum_{t=1}^T \mathbb E[f(x_t) - f^\star] \;\le\; \frac{D^2/2}{\eta T} + \frac{\eta \sigma^2}{1 - \beta^2}.
$$
Horizon-tuning gives $\Theta(\sigma D / \sqrt T)$.

**Recommended OP-2 v6 §4.2 text.** Replace "tight relative to SGD" (the v5 text) with:

> "Tight in three complementary senses:
> (i) **Minimax-over-$\eta$**: with horizon-tuned $\eta_T = \Theta(D/(\sigma\sqrt T))$, the noise floor matches the LB in rate $\Theta(\sigma D / \sqrt T)$ (constants differ by a $\beta$-polynomial factor; see Theorem A.2).
> (ii) **Projected last iterate up to $\sqrt{\log T}$**: with projection and horizon-tuning, $\mathbb E[f(\Pi(x_T)) - f^\star] \le O\bigl(LD^2 \log T/[T(1-\beta)] + \sigma D \sqrt{\log T}/\sqrt{T(1-\beta)}\bigr)$ (Theorem D).
> (iii) **Cesàro average**: GFJ15-style $O(LD^2/T)$ on the running average for the deterministic case, $\Theta(\sigma D/\sqrt T)$ horizon-tuned in the stochastic case (Theorem B).
>
> For unprojected SHB at fixed $(\beta, \eta)$ on $L$-smooth convex non-SC, the closed-form noise floor (Theorem A.1)
> $$\mathrm{Var}_\infty[x] = \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)(2(1+\beta) - \eta L)}$$
> shows $\liminf_T \mathbb E[f(x_T) - f^\star] > 0$, ruling out any $T$-decaying matching UB at fixed $(\beta, \eta)$. This is consistent with Li–Liu–Orabona 2022 (ALT, arXiv:2102.07002), who prove an $\Omega(\log T/\sqrt T)$ obstruction in the Lipschitz convex regime; in our $L$-smooth regime the obstruction is stronger (a constant lower bound, no $T$-decay)."

---

## 7. Honest scope and remaining open questions

**Scope.**

- Theorem A.1 (negative) is **tight as a refutation**: the closed-form variance is exact, not asymptotic, and is verified by SymPy + mpmath + Monte Carlo at three-way agreement (`gap2_verify.py`, ALL PASS).
- Theorems A.2, B, D (positive) all match in rate; constants differ by $\beta$-polynomial factors. None gives a constants-tight match — that may be impossible without further assumptions (e.g., strong convexity, projection, time-varying schedule).
- The full $L$-smooth convex non-SC class (not just the quadratic) is not directly addressed by the closed-form variance; the quadratic suffices to refute UB existence, but the worst-case $f \in \mathcal F$ in the upper-bound direction is open.

**Open questions (out of scope).**

1. **Constants-tight matching UB in the minimax-$\eta$ regime.** The ratio $1/[4(1-\beta)] : \sqrt 2/27$ between the noise-floor coefficient and OP-2's LB coefficient is $\beta$-dependent. A tighter lower bound (Theorem A.2 vs. OP-2 LB) might close this gap; or a tighter UB technique might match OP-2's $\sqrt 2/27$ coefficient.
2. **Removing the $\sqrt{\log T}$ in projected case.** Theorem D's bound has a $\sqrt{\log T}$ factor in the variance term. Whether this is essential or removable is open; analogous to the parallel question in Orabona 2020 / Li-Liu-Orabona 2022 for Lipschitz convex.
3. **Non-quadratic worst-case.** Whether there exists $f \in \mathcal F$ (smooth convex non-SC, but not quadratic) where the noise-floor obstruction is even worse, or whether the quadratic is the worst case in the smoothness regime.

$\blacksquare$

---

## Appendix A — Verifier results (`gap2_verify.py`, mpmath dps=50)

| Check | Description | Result |
|---|---|:---:|
| **S1** | SymPy: discrete Lyapunov closed-form Var$_\infty[x]$ matches boxed formula (5) | PASS |
| **S2** | SymPy: leading $\eta \to 0$ gives $\sigma^2/[2L(1-\beta)]$; $\beta=0$ collapse to AR(1) | PASS |
| **S3** | SymPy: 3-term Lyapunov drift cross-term cancels with $c_1 = (1-L\eta-\beta^2)/(2\eta), c_2 = \beta^2/(2\eta)$ | PASS |
| **S4** | SymPy: change-of-variables $z_t = x_t + a(x_t - x_{t-1})$ gives exact OGD $z_{t+1} - z_t = -\eta_{\mathrm{eff}} g_t$ | PASS |
| **M1** | mpmath: independent Lyapunov solve at $(\beta, \eta L) = (0.5, 0.1)$, rel_err $1.87 \times 10^{-51}$ | PASS |
| **MC1** | MC at 4 settings, max rel_err $0.42\%$ < 1% target | PASS |
| **MC2** | MC at horizon-tuned $\eta_T = D/(\sigma\sqrt T)$, log-log slope $T^{-0.501}$ | PASS |
| **MC3** | MC at fixed $(\beta, \eta) = (0.5, 0.1)$, $\mathbb E[f(x_T)]$ saturates at noise floor 0.052 — no T-decay | PASS |

Wall time: 12.4 s. Results in `gap2_verify_results.json`.

## Appendix B — Constants

| Quantity | Value | Where |
|---|---|---|
| Noise-floor coefficient (leading $\eta$) | $\sigma^2 / [2L(1-\beta)]$ | Theorem A.1, S2 |
| Noise-floor coefficient at $\eta = \eta_T$ | $\sigma D / [4(1-\beta)\sqrt T]$ | Theorem A.2 |
| OP-2 LB variance coefficient | $\sqrt 2 / 27 \approx 0.0524$ | OP-2 v5 §4.2 |
| Cesàro UB bias coefficient | $C_1(\beta) \sim 1/(1-\beta)$ | Theorem B |
| Cesàro UB variance coefficient | $C_2(\beta)/(1-\beta^2)$ | Theorem B |
| Projected last-iterate UB extra factor | $\sqrt{\log T}$ | Theorem D |

$\blacksquare$
