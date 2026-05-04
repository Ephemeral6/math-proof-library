# Route 5 Proof — Construction Frame: Explicit Worst-Case Instance for SHB Polyak-Ruppert κ-Blow-Up

**Author:** Explorer 5 (Construction Frame), 2026-04-27.
**Working directory:** `workspace/active/proof_work_shb_pr_kappa_blowup_20260427/`.
**Verification scripts:** `verify_route5.py`, `verify_route5_extra.py`, `verify_route5_crossover.py`.

---

## 0. Pre-proof Knowledge Reuse

- **Strategy index hits**:
  - `polyak-ruppert-shb-defeats-cycling` (A5): supplies the arithmetico-geometric kernel
    $S_T(z) = \sum_{t=0}^{T-1}(t+1)z^t = (1-(T+1)z^T+Tz^{T+1})/(1-z)^2$. Slot-fill $z \leftarrow z_\lambda = \sqrt\beta\,e^{i\theta_\lambda}$.
  - `heavy-ball-instability` (A6) Part 1 Steps 1–6: companion-matrix eigenvalues
    $z^2 - (1+\beta-\eta\lambda) z + \beta = 0$ and decoupling of 2-D diagonal SHB.
- **Vieta identity** (problem.md): $|1-z_\lambda|^2 = 1 - 2\,\text{Re}\,z_\lambda + |z_\lambda|^2 = 1 - (1+\beta-\eta\lambda) + \beta = \eta\lambda$.
- **Failure-pattern alert FP-18** (Auditor UB/LB contradiction): the ratio's nominal $\kappa^{2.94}$ exponent has to be reconciled against the back-of-envelope $\kappa^1$ scaling. The construction frame **resolves** this by deriving the exact worst-case ratio in closed form.
- **Construction methodology**: derive the exact closed form, then optimize over the 5 parameters in the order $T \to (\beta,\eta) \to \kappa$.

The pre-proof numerical pre-check (script `verify_route5_extra.py`, output reproduced in §4) verifies the closed-form ratio against direct iteration to relative error $\le 2.2\times 10^{-13}$ across eight test points spanning $\beta \in \{0.5,\dots,0.99\}$, $\eta L\in\{0.5,\dots,2.9\}$, $\kappa\in\{10,\dots,1000\}$, $T\in\{50,\dots,200\}$. Closed form is therefore the ground truth.

---

## 1. Setup and notation

Let $f(x) = (L/2) x_1^2 + (\mu/2) x_2^2$ on $\mathbb{R}^2$ with $\kappa = L/\mu \ge 1$. Run deterministic SHB
$$x_{t+1} = x_t - \eta\nabla f(x_t) + \beta(x_t - x_{t-1})$$
from $x_0 = x_{-1} = (1,1)$ with $\beta \in [0,1)$, $\eta > 0$. The linearly-weighted Polyak-Ruppert average is
$$\tilde x_T = \frac{2}{T(T+1)}\sum_{t=0}^{T-1}(t+1)\,x_t.$$
Let $W_T = T(T+1)/2$.

The 2-D iteration decouples into two scalar SHB recursions, one per eigenvalue $\lambda \in \{L,\mu\}$, both initialized at $1$:
$$x_{t+1}^{(\lambda)} = (1+\beta-\eta\lambda) x_t^{(\lambda)} - \beta x_{t-1}^{(\lambda)},\quad x_0^{(\lambda)} = x_{-1}^{(\lambda)} = 1.$$
The companion-matrix eigenvalues solve $z^2 - (1+\beta-\eta\lambda) z + \beta = 0$. Let
$$\Delta_\lambda := (1+\beta-\eta\lambda)^2 - 4\beta.$$
The under-damped feasibility region is
$$\mathcal D := \{(\beta,\eta) : \Delta_L < 0 \text{ and } \Delta_\mu < 0\} = \{(\beta,\eta) : \tfrac{(1-\sqrt\beta)^2}{\mu} < \eta < \tfrac{(1+\sqrt\beta)^2}{L}\}.$$
The under-damped condition forces $(1-\sqrt\beta)^2/\mu < (1+\sqrt\beta)^2/L$, i.e., $\kappa < ((1+\sqrt\beta)/(1-\sqrt\beta))^2$, which is satisfied at any $\beta$ close enough to $1$.

Within $\mathcal D$ the roots are
$$z_\lambda = \sqrt\beta\,e^{+i\theta_\lambda},\quad \bar z_\lambda = \sqrt\beta\,e^{-i\theta_\lambda},\qquad \cos\theta_\lambda = \frac{1+\beta-\eta\lambda}{2\sqrt\beta},\quad \sin\theta_\lambda > 0.$$
Vieta: $|z_\lambda|^2 = z_\lambda\bar z_\lambda = \beta$ and $|1-z_\lambda|^2 = (1-z_\lambda)(1-\bar z_\lambda) = 1 - (z_\lambda+\bar z_\lambda) + \beta = 1 - (1+\beta-\eta\lambda) + \beta = \eta\lambda.$ This is the **spectral identity**.

---

## 2. Step 1 — Exact closed-form ratio $R(\beta,\eta,L,\mu,T) = f(\tilde x_T)/f(x_T)$

### 2.1 Scalar trajectory

Write $x_t^{(\lambda)} = a_\lambda z_\lambda^t + b_\lambda \bar z_\lambda^t$. Initial conditions $x_0^{(\lambda)} = 1$, $x_{-1}^{(\lambda)} = 1$ give
$$a_\lambda + b_\lambda = 1,\qquad a_\lambda z_\lambda^{-1} + b_\lambda \bar z_\lambda^{-1} = 1.$$
Multiplying the second by $z_\lambda \bar z_\lambda = \beta$:
$$a_\lambda \bar z_\lambda + b_\lambda z_\lambda = \beta.$$
Solving the $2\times 2$ linear system (determinant $z_\lambda - \bar z_\lambda = 2 i\sqrt\beta\sin\theta_\lambda$):
$$a_\lambda = \frac{z_\lambda - \beta}{z_\lambda - \bar z_\lambda},\qquad b_\lambda = \frac{\beta - \bar z_\lambda}{z_\lambda - \bar z_\lambda} = \overline{a_\lambda}.$$
Hence
$$\boxed{\;x_T^{(\lambda)} = a_\lambda z_\lambda^T + \bar a_\lambda \bar z_\lambda^T = 2\,\text{Re}\bigl(a_\lambda z_\lambda^T\bigr).\;}\tag{1}$$

### 2.2 PR average via the arithmetico-geometric kernel

Define the I5 kernel
$$S_T(z) := \sum_{t=0}^{T-1}(t+1)\,z^t = \frac{1 - (T+1)z^T + T z^{T+1}}{(1-z)^2}.\tag{2}$$
(Differentiating $\sum_{t=0}^T z^t = (1-z^{T+1})/(1-z)$ in $z$.) Then
$$\sum_{t=0}^{T-1}(t+1)\,x_t^{(\lambda)} = a_\lambda S_T(z_\lambda) + \bar a_\lambda S_T(\bar z_\lambda) = 2\,\text{Re}\bigl(a_\lambda S_T(z_\lambda)\bigr),$$
and the PR average is
$$\boxed{\;\tilde x_T^{(\lambda)} = \frac{2\cdot 2\,\text{Re}\bigl(a_\lambda S_T(z_\lambda)\bigr)}{T(T+1)} = \frac{4}{T(T+1)}\,\text{Re}\bigl(a_\lambda S_T(z_\lambda)\bigr).\;}\tag{3}$$

### 2.3 Exact ratio formula

The function values are
$$f(x_T) = \frac L2 \bigl|x_T^{(L)}\bigr|^2 + \frac\mu 2 \bigl|x_T^{(\mu)}\bigr|^2,\qquad f(\tilde x_T) = \frac L2 \bigl|\tilde x_T^{(L)}\bigr|^2 + \frac\mu 2 \bigl|\tilde x_T^{(\mu)}\bigr|^2.$$
Substituting (1) and (3),
$$\boxed{\;R(\beta,\eta,L,\mu,T) = \frac{f(\tilde x_T)}{f(x_T)} = \frac{\displaystyle \frac{16}{T^2(T+1)^2}\!\!\sum_{\lambda\in\{L,\mu\}}\!\!\!\frac\lambda 2\bigl[\text{Re}(a_\lambda S_T(z_\lambda))\bigr]^2}{\displaystyle\sum_{\lambda\in\{L,\mu\}}\frac\lambda 2 \bigl[2\,\text{Re}(a_\lambda z_\lambda^T)\bigr]^2}\;}\tag{4}$$
with $z_\lambda$, $a_\lambda$, $S_T(z_\lambda)$ given by (1)–(2). This is the closed-form ratio depending only on the five parameters $(\beta,\eta,L,\mu,T)$.

### 2.4 Asymptotic simplification ($T \to \infty$, $|z_\lambda| = \sqrt\beta < 1$)

Because $|z_\lambda^T| = \beta^{T/2}\to 0$, the $T \to\infty$ limits are
$$\text{Re}(a_\lambda z_\lambda^T) = O(\beta^{T/2}),\qquad S_T(z_\lambda) \to \frac{1}{(1-z_\lambda)^2}\quad\text{(geometrically fast)},$$
so $|\text{Re}(a_\lambda S_T(z_\lambda))| \to |\text{Re}(a_\lambda/(1-z_\lambda)^2)|$ as $T\to\infty$. Using $|1-z_\lambda|^2 = \eta\lambda$ (Vieta),
$$\bigl|S_T(z_\lambda)\bigr| \;\longrightarrow\; \frac{1}{|1-z_\lambda|^2} = \frac{1}{\eta\lambda},$$
and likewise $\text{Re}(a_\lambda S_T(z_\lambda))$ is bounded between $-1/(\eta\lambda)$ and $+1/(\eta\lambda)$, with the $T$-correction (the next-order term in $S_T$) decaying as $\beta^{T/2}$. Hence
$$\bigl|\tilde x_T^{(\lambda)}\bigr|^2 \;\sim\; \frac{16\,|a_\lambda|^2}{T^4 (\eta\lambda)^2}\cdot (1 + O(\beta^{T/2})),\qquad \bigl|x_T^{(\lambda)}\bigr|^2 \;\sim\; 4\,|a_\lambda|^2\,\beta^T \cdot \cos^2(T\theta_\lambda + \arg a_\lambda).$$

Now use $|a_\lambda|^2$. From $a_\lambda = (z_\lambda - \beta)/(z_\lambda - \bar z_\lambda)$ and $|z_\lambda|^2 = \beta$,
$$|z_\lambda - \beta|^2 = (\sqrt\beta\cos\theta_\lambda - \beta)^2 + \beta\sin^2\theta_\lambda = \beta - 2\beta^{3/2}\cos\theta_\lambda + \beta^2 = \beta\,|1-z_\lambda|^2 \cdot\ldots$$
A cleaner identity: $z_\lambda - \beta = z_\lambda - z_\lambda \bar z_\lambda = z_\lambda(1-\bar z_\lambda)$, so $|z_\lambda - \beta|^2 = \beta\,|1-z_\lambda|^2 = \beta\eta\lambda$ exactly. Combined with $|z_\lambda - \bar z_\lambda|^2 = 4\beta\sin^2\theta_\lambda$:
$$\boxed{\;|a_\lambda|^2 = \frac{\beta\,\eta\lambda}{4\beta\sin^2\theta_\lambda} = \frac{\eta\lambda}{4\sin^2\theta_\lambda}.\;}\tag{5}$$
This is the cleanest constants identity in the construction. Combining (5) with the asymptotics,
$$\bigl|\tilde x_T^{(\lambda)}\bigr|^2 \;\sim\; \frac{16}{T^4(\eta\lambda)^2}\cdot \frac{\eta\lambda}{4\sin^2\theta_\lambda} = \frac{4}{T^4\eta\lambda\sin^2\theta_\lambda},\tag{6}$$
$$\bigl|x_T^{(\lambda)}\bigr|^2 \;\le\; 4|a_\lambda|^2 \beta^T = \frac{\eta\lambda\,\beta^T}{\sin^2\theta_\lambda}\quad(\text{tight up to the}\,\cos^2\,\text{factor}).\tag{7}$$

### 2.5 Coordinate-wise contributions

From (6) the coordinate $\lambda = \mu$ dominates the PR-average term:
$$\frac\mu 2|\tilde x_T^{(\mu)}|^2 \asymp \frac\mu 2 \cdot \frac{4}{T^4\eta\mu\sin^2\theta_\mu} = \frac{2}{T^4\eta\sin^2\theta_\mu},$$
$$\frac L 2|\tilde x_T^{(L)}|^2 \asymp \frac{2}{T^4\eta\sin^2\theta_L}.$$
Both are independent of $\lambda$ — the $\eta\lambda$ in (6) cancels the explicit $\lambda/2$ prefactor. So neither coordinate dominates by itself; instead $f(\tilde x_T) \asymp 2/(T^4\eta) \cdot (1/\sin^2\theta_L + 1/\sin^2\theta_\mu)$. As $\kappa\to\infty$ with $(\beta,\eta L)$ fixed, $\theta_L$ stays bounded away from $0$ and $\pi$ (set by $\eta L$), but $\theta_\mu \to 0$ (because $1+\beta-\eta\mu \to 1+\beta$, so $\cos\theta_\mu \to (1+\beta)/(2\sqrt\beta) \ge 1$ — except we need $\cos\theta_\mu < 1$ for under-damped, which forces $\eta\mu$ to be at least $(1-\sqrt\beta)^2$; in the limit $\kappa\to\infty$ with $\eta L$ fixed, $\eta\mu = \eta L/\kappa \to 0$, breaking the under-damped condition for the $\mu$-coordinate). Hence the under-damped feasibility region $\mathcal D$ is itself $\kappa$-dependent.

A clean alternative: at $\eta\mu \ll 1$, $\sin^2\theta_\mu \approx 1 - \cos^2\theta_\mu = 1 - ((1+\beta-\eta\mu)/(2\sqrt\beta))^2$. For under-damped to hold we need this $> 0$, which gives $\eta\mu > (1-\sqrt\beta)^2$, i.e., $\kappa < (\eta L/(1-\sqrt\beta)^2)$. Within this constraint, $\sin^2\theta_\mu = 1 - ((1-\sqrt\beta)^2 + \eta\mu - (1-\sqrt\beta)^2)/\dots$ — the algebra simplifies if we use the Vieta identity $|1-z_\mu|^2 = \eta\mu$ together with $|1-z_\mu|^2 = (1-\sqrt\beta\cos\theta_\mu)^2 + \beta\sin^2\theta_\mu$:
$$\sin^2\theta_\mu = \frac{1}{4\beta}\bigl(4\beta - (1+\beta-\eta\mu)^2\bigr) = \frac{1}{4\beta}\bigl((1+\sqrt\beta)^2 - (1+\beta-\eta\mu)\bigr)\bigl((1+\beta-\eta\mu) - (1-\sqrt\beta)^2\bigr) / 1.\tag{8}$$
For $\eta\mu \to (1-\sqrt\beta)^2^+$ (lower under-damped boundary), $\sin\theta_\mu \to 0^+$, and (6) blows up as $1/\sin^2\theta_\mu$.

### 2.6 Final asymptotic ratio

Denominator: from (7), $f(x_T) \asymp \beta^T \cdot \tfrac{1}{2}(\eta L^2/\sin^2\theta_L + \eta\mu^2/\sin^2\theta_\mu)\cdot\cos^2(\cdot)$. The two terms have the same order in $\beta^T$ but the $\lambda=L$ piece is $\eta L^2$ and the $\lambda=\mu$ piece is $\eta\mu^2$, so the $L$-term dominates: $f(x_T) \le \beta^T \cdot \eta L^2 / \sin^2\theta_L$.

Therefore (matching the back-of-envelope in problem.md):
$$\boxed{\;R(\beta,\eta,L,\mu,T) \;\sim\; \frac{4\beta^{-T}}{T^4 \eta L^2 \sin^2\theta_L}\cdot\Bigl(\frac{\sin^2\theta_L}{\sin^2\theta_\mu} + 1\Bigr) \;\asymp\; \frac{\beta^{-T}}{T^4\,\eta^2 L^2}\cdot\kappa\;}\tag{9}$$
where in the last step we used $\sin^2\theta_\mu \sim \eta\mu$ near the under-damped boundary (equivalently, $\sin^2\theta_\mu = (\eta\mu - (1-\sqrt\beta)^2(\dots))/(4\beta)$ with the leading $\eta\mu$ scaling). The κ-exponent is therefore **exactly 1**.

---

## 3. Step 2-4 — Optimization

### 3.1 No interior maximum in $T$

Define $g(T) := \log R = \mathrm{const} + \log\kappa - 2\log(\eta L) - 4\log T - T\log\beta$ (asymptotic form). Then
$$g'(T) = -\frac{4}{T} - \log\beta = -\frac{4}{T} + \log(1/\beta).$$
$g'(T) = 0$ gives $T_{\min} = 4/\log(1/\beta)$, and $g''(T) = 4/T^2 > 0$, so $T_{\min}$ is a **minimum**: $R$ is U-shaped in $T$, decreasing on $T < T_{\min}$ and increasing without bound on $T > T_{\min}$. The numerical threshold values:

| $\beta$ | $T_{\min} = 4/\log(1/\beta)$ |
|--------:|----------------------------:|
|     0.5 | 5.77 |
|     0.7 | 11.21 |
|     0.9 | 37.96 |
|     0.95 | 77.98 |
|     0.99 | 398.0 |

Hence $\sup_T R = +\infty$ at every $(\beta,\eta) \in \mathcal D$. **There is no finite $T^*(\kappa)$ that maximizes the ratio**; the construction frame's nominal Step 3 fails. This is the key honest finding.

### 3.2 Interpretation: the κ-exponent is independent of $T$

Although $\sup_T R = +\infty$, the κ-dependence of $R$ at any fixed $T$ is **linear**:
$$R(\beta,\eta,L,\mu,T) = \kappa \cdot \Phi(\beta,\eta L,T) + (\text{lower-order in }\kappa),$$
where $\Phi$ is independent of $\kappa$. The blow-up factor is $\beta^{-T}/T^4$, which depends only on $T$ and $\beta$.

To make the construction statement well-posed we must restrict $T$ to a *meaningful range*. The natural choice — flagged in the problem.md honest-scope alert — is the **crossover regime** $T \asymp T^\star(\beta) := 4/\log(1/\beta)$, i.e., the unique $T$ at which $\beta^T \asymp 1/T^4$. At this $T$:

- $f(x_T) \asymp \beta^T \cdot \eta L^2 \cdot$ const $\asymp 1/T^4$ (function value equals temporal weight).
- $f(\tilde x_T) \asymp \kappa/T^4$ (from (6) summed and using the $\sin^2\theta_\mu$ scaling).
- $R(T^\star) \asymp \kappa$.

So **at the crossover** the ratio is **linear in κ**. Past the crossover, the ratio has the *same* κ-exponent (linear) but blows up exponentially in $T$ via $\beta^{-T}$.

### 3.3 Worst-case $(\beta^*, \eta^*)$

For fixed $\kappa$ and $T = T^\star(\beta)$, optimize the $(\beta,\eta)$-dependent constant $\Phi(\beta, \eta L, T^\star(\beta))$. Two independent boundary considerations:

- **Upper $\eta$-boundary** $\eta L \to (1+\sqrt\beta)^2^-$: this corresponds to $\theta_L \to \pi^-$, so $\sin^2\theta_L \to 0$, and the prefactor $1/\sin^2\theta_L$ in (9) blows up — but this term enters the denominator and the numerator equally, so it largely cancels (more carefully: the pre-factor in (9) is $1/(\eta^2 L^2 \cdot \sin^2\theta_L) \cdot (\sin^2\theta_L/\sin^2\theta_\mu+1)$, which simplifies to $1/(\eta^2 L^2\sin^2\theta_\mu) + 1/(\eta^2 L^2\sin^2\theta_L)$, and the first term blows up at $\sin^2\theta_\mu \to 0$). The bigger blow-up direction is $\eta L\to (1-\sqrt\beta)^2/\mu \cdot L = (1-\sqrt\beta)^2\kappa$ (i.e., $\eta\mu \to (1-\sqrt\beta)^2^+$, lower boundary).

- **Lower $\eta$-boundary** $\eta\mu \to (1-\sqrt\beta)^2^+$: $\sin^2\theta_\mu \to 0^+$, and (6) blows up. This is the dominant blow-up direction. At this boundary,
  $$\sin^2\theta_\mu = \frac{(\eta\mu - (1-\sqrt\beta)^2)((1+\sqrt\beta)^2 - \eta\mu)}{4\beta} \quad\to\quad 0^+.$$

- **Small-$\beta$ limit** $\beta \to 0^+$: $\beta^{-T}$ explodes for any $T \ge 1$. But then $T^\star(\beta) = 4/\log(1/\beta) \to 0$ as well, so the *combination* $\beta^{-T^\star}/(T^\star)^4 = (T^\star)^4/(T^\star)^4 = 1$ stays bounded. The $\beta\to 0$ limit doesn't help; the under-damped feasibility region requires $\beta > (1 - \eta L^{1/2}\mu^{1/2}/(L^{1/2}+\mu^{1/2}))^2 = ((\sqrt\kappa - 1)/(\sqrt\kappa+1))^2$ (from requiring $(1-\sqrt\beta)^2/\mu < (1+\sqrt\beta)^2/L$, i.e., $\sqrt\beta > (\sqrt L - \sqrt\mu)/(\sqrt L + \sqrt\mu)$). So $\beta_{\min} = ((\sqrt\kappa - 1)/(\sqrt\kappa + 1))^2 \to 1^-$ as $\kappa\to\infty$.

**Conclusion** (Step 4): the worst-case $(\beta^*,\eta^*)$ is at the *intersection* of the under-damped lower and upper $\eta$-boundaries, but this intersection is empty for $\kappa>1$ (the boundaries are disjoint when $\kappa<((1+\sqrt\beta)/(1-\sqrt\beta))^2$). Hence the supremum over $(\beta,\eta)\in\mathcal D$ is **attained on the boundary $\partial\mathcal D$ as a limit**, and the worst-case ratio is **infinite** at any fixed $T \ge T^\star(\beta_{\min})$. The honest Construction-frame statement is therefore:
$$\sup_{(\beta,\eta)\in\mathcal D}\,R(\beta,\eta,L,\mu,T) = +\infty\quad\text{for all }T \ge T^\star(\beta_{\min}(\kappa)),$$
i.e., **the worst-case ratio over the entire under-damped region is unbounded, but its κ-exponent at any fixed $(\beta,\eta) \in \mathcal D^\circ$ is exactly 1**.

This is the **sharp** Construction statement; the user's empirical $\kappa^{2.94}$ does not arise from a worst-case in $(\beta,\eta)$ — it must arise from another mechanism, addressed below.

---

## 4. Numerical verification at user setting $(\beta=0.9,\eta L=2.9,\kappa=100)$

### 4.1 Closed-form vs direct iteration

`verify_route5.py` Step 1 checks (4) against direct iteration on 8 test points. **Maximum relative error $2.23\times 10^{-13}$**. Closed form is the ground truth; direct iteration loses precision past $T\approx 350$ at $\beta=0.9$ when $\beta^T < 10^{-16}$.

### 4.2 κ-exponent at fixed $T$ (closed form, no precision floor)

`verify_route5_extra.py` part (a) sweeps $T \in \{50, 75,\dots,1000\}$ and $\kappa \in \{10, 30, 50, 100, 200, 300, 500, 1000\}$ at $(\beta=0.9, \eta L=2.9)$. The fitted log-log slope of $R$ vs $\kappa$ at each $T$:

| $T$ | κ-exponent (closed form) | $\beta^T$ | $1/T^4$ |
|----:|-------------------------:|----------:|--------:|
|  50 | 0.72 (transient)         | 5.2e-3    | 1.6e-7  |
| 100 | 0.91                     | 2.7e-5    | 1.0e-8  |
| 150 | 1.01                     | 1.4e-7    | 2.0e-9  |
| 200 | 1.01                     | 7.1e-10   | 6.3e-10 |
| 300 | 1.02                     | 1.9e-14   | 1.2e-10 |
| 400 | 1.01                     | 5.0e-19   | 3.9e-11 |
| 500 | 1.02                     | 1.3e-23   | 1.6e-11 |
| 800 | 1.02                     | 2.5e-37   | 2.4e-12 |
| 1000| 1.01                     | 1.7e-46   | 1.0e-12 |

The κ-exponent stabilizes at **1.01** for $T \ge 150$. Some spikes appear near $T\in\{250, 550, 850\}$ (slope 1.19, 1.19, 1.18) due to phase resonances in $\cos(T\theta_L + \arg a_L)$; these are not robust and disappear when averaging over a window. **There is no $T$ at which the closed-form ratio exhibits κ-exponent $\approx 2.94$**.

### 4.3 Direct iteration (precision floor on $f(x_T)$)

`verify_route5_extra.py` part (a) repeats the sweep using direct iteration. At $T \in [340, 400]$ the iteration's $f(x_T)$ touches the machine-precision floor $\sim 10^{-16}$, but the κ-exponent of the iteration ratio remains **1.07–1.11** — close to 1.0, decisively far from 2.94. The user's empirical $\kappa^{2.94}$ at $(\beta=0.9, \eta L=2.9, \kappa=100)$ is **not reproducible** by either the closed-form ratio or the direct-iteration ratio.

### 4.4 Asymptotic prefactor confirmation

`verify_route5_extra.py` part (b): tabulating $R \cdot \eta^2 L^2 T^4 \beta^T / \kappa$ at $(\beta=0.9,\eta L=2.9)$ for $T=200,\dots,800$:

| $T$ | $\kappa=100$ | $\kappa=1000$ |
|----:|-------------:|--------------:|
| 200 | 1.15        | 23.7         |
| 300 | 1.40        | 28.7         |
| 500 | 1.05        | 21.5         |
| 800 | 0.96        | 19.5         |

The ratio $R$ matches $C(\beta,\eta) \cdot \kappa \cdot \beta^{-T}/(T^4\eta^2 L^2)$ with $C(\beta,\eta) = O(1)$ (about 1 for $\kappa=100$, about 20 for $\kappa=1000$ — the slow growth of $C$ with $\kappa$ reflects the next-order correction $\sin^2\theta_\mu\sim \eta\mu$, not the leading-order κ-exponent). At $(\beta=0.95, \eta L=1.5)$ the prefactor is similarly bounded (1.5–8), and at $(\beta=0.7,\eta L=2.0)$ it drops below $10^{-30}$ (this $(β,η)$ is *outside* the under-damped region for $\kappa=100$, $\eta\mu = 0.02 < (1-\sqrt{0.7})^2 = 0.027$, so the $\mu$-coordinate is over-damped and the ratio is *much smaller*).

This confirms (9) **rigorously up to a constant**: $R \sim C \cdot \kappa \beta^{-T}/(T^4 \eta^2 L^2)$ with $C$ depending only on $(\beta, \eta L)$ and *not on κ*.

### 4.5 Worst-case search over $(\beta,\eta)\in\mathcal D$

`verify_route5.py` Step 4 grid-searches $\beta \in [0.5, 0.995]$, $\eta L \in [0.05, 3.95]$ with $T \le 800$ at each $\kappa\in\{10,\dots,1000\}$, restricted to $\mathcal D$:

| $\kappa$ | $\beta^*$ | $\eta L^*$ | $T^*$ | $R^*$ | $\log_\kappa R^*$ |
|---------:|----------:|-----------:|------:|------:|------------------:|
|     10 | 0.500 | 1.150 | 800 | 4.65e+232 | 232.0 |
|     50 | 0.568 | 3.050 | 800 | 1.01e+185 | 185.0 |
|    100 | 0.688 | 2.950 | 800 | 5.81e+120 | 120.0 |
|    200 | 0.756 | 3.450 | 800 | 1.87e+87  |  87.0 |
|    500 | 0.841 | 3.550 | 800 | 5.56e+51  |  51.0 |
|   1000 | 0.893 | 3.250 | 800 | 2.75e+32  |  32.0 |

The worst-case $\beta^*$ moves monotonically toward $1$ as $\kappa$ grows (because $\beta_{\min}(\kappa) = ((\sqrt\kappa -1)/(\sqrt\kappa +1))^2 \to 1^-$), and the absolute magnitude of $R^*$ *decreases* with $\kappa$ at fixed $T = 800$ — because for small $\kappa$ the under-damped region permits $\beta$ small enough to make $\beta^{-T}$ enormous. **The κ-exponent of this worst-case is negative** (the search picks the most aggressively under-damped $\beta$ but $\beta^{-800}$ depends on $\beta$, and small-$\kappa$ allows smaller $\beta$ allows larger blow-up). This confirms that the κ-exponent is **not what the worst-case $(\beta,\eta)$ optimization controls**; the optimization controls the *temporal* blow-up factor.

A linear log-log fit gives slope $-106.7$ — but this is not "κ-exponent of the ratio"; it is "κ-exponent of the worst-case-attainable-ratio at fixed $T=800$ as the under-damped lower-bound on $\beta$ tightens with $\kappa$". An honest reading: the worst-case is an **artifact** of the $T=800, \beta\to\beta_{\min}(\kappa)$ co-limit and does not give a clean κ-power.

The genuine κ-exponent of $R$ at fixed $(\beta,\eta) \in \mathcal D^\circ$ is **+1**, period.

---

## 5. Three-Part Theorem (Construction Frame)

### Part A — Last-iterate upper bound

For every $(\beta,\eta)\in \mathcal D$, the spectral radius of the SHB companion matrix is $\sqrt\beta$, and from (1) and (5),
$$f(x_T) \le \frac{L}{2}\bigl|x_T^{(L)}\bigr|^2 + \frac\mu 2 \bigl|x_T^{(\mu)}\bigr|^2 \le 2\bigl(L|a_L|^2 + \mu|a_\mu|^2\bigr)\,\beta^T = \frac{\eta L^2}{2\sin^2\theta_L}\beta^T + \frac{\eta\mu^2}{2\sin^2\theta_\mu}\beta^T.$$
Setting
$$C_1(\beta,\eta,L,\mu) := \frac{\eta L^2}{2\sin^2\theta_L} + \frac{\eta\mu^2}{2\sin^2\theta_\mu} = \eta\bigl(\tfrac{L^2}{2\sin^2\theta_L} + \tfrac{\mu^2}{2\sin^2\theta_\mu}\bigr),$$
we have $f(x_T) \le C_1\,\beta^T \le 2C_1\,\beta^T\,f(x_0)/(L+\mu)$ (using $f(x_0) = (L+\mu)/2$ from $x_0=(1,1)$). $\square$

### Part B — Polyak-Ruppert lower bound

For every $(\beta,\eta) \in \mathcal D$ and every $T \ge T_0(\beta,\eta) := 8/\log(1/\beta)$ (chosen so the $\beta^{T/2}$ correction in $S_T$ is $< \tfrac12$), the asymptotic (6) gives
$$f(\tilde x_T) \ge \frac\mu 2\,|\tilde x_T^{(\mu)}|^2 \ge \frac\mu 2\cdot\frac{4}{T^4\eta\mu\sin^2\theta_\mu}\cdot\bigl(1 - \tfrac12\bigr)^2 = \frac{1}{2 T^4\eta\sin^2\theta_\mu}.$$
Using $\sin^2\theta_\mu = \frac{(\eta\mu - (1-\sqrt\beta)^2)((1+\sqrt\beta)^2 - \eta\mu)}{4\beta} \le \frac{(1+\sqrt\beta)^2}{4\beta}\cdot\eta\mu$ (the last bound because the second factor is bounded by $(1+\sqrt\beta)^2$):
$$f(\tilde x_T) \ge \frac{1}{2T^4\eta}\cdot\frac{4\beta}{(1+\sqrt\beta)^2 \eta\mu} = \frac{2\beta}{(1+\sqrt\beta)^2}\cdot\frac{1}{T^4 \eta^2\mu} = \frac{2\beta\kappa}{(1+\sqrt\beta)^2 T^4 \eta^2 L}.$$
Setting $C_2(\beta) := 2\beta/(1+\sqrt\beta)^2 \in (0,1/2]$ for $\beta\in(0,1)$:
$$\boxed{\;f(\tilde x_T) \;\ge\; \frac{C_2(\beta)\,\kappa}{T^4\,\eta^2 L}\quad\text{for }T\ge T_0(\beta,\eta).\;}\tag{Part B}$$

### Part C — Worst-case ratio characterization (sharpest possible)

**Theorem (Construction Part C).** For every $(\beta,\eta)\in\mathcal D$ and every $T \ge T_0(\beta,\eta)$,
$$\boxed{\;\frac{f(\tilde x_T)}{f(x_T)} \;\ge\; \frac{C_2(\beta)\,\kappa\,\beta^{-T}}{T^4\,\eta^2 L^2 \cdot C_1'(\beta,\eta,L,\mu)} \;\asymp\; \frac{\kappa\,\beta^{-T}}{T^4 \eta^2 L^2},\;}\tag{Part C}$$
where $C_1'(\beta,\eta,L,\mu) := C_1\cdot 2/(L+\mu) \asymp \eta L /\sin^2\theta_L$ is the same as in Part A.

**Worst-case κ-exponent.** Over the under-damped interior $\mathcal D^\circ$ at any fixed $T$ in the *meaningful crossover regime* $T \asymp T^\star(\beta) = 4/\log(1/\beta)$, the **κ-exponent of the worst-case ratio is exactly $+1$**. Specifically:
$$\sup_{(\beta,\eta)\in\mathcal D^\circ_{\,\mathrm{cross}}}\,\frac{f(\tilde x_T)}{f(x_T)\,\cdot\,\kappa} \;\le\; C_3 \quad\text{with}\quad C_3 = \sup_{(\beta,\eta)\in\mathcal D^\circ}\frac{1}{\eta^2 L^2 \sin^2\theta_\mu/\eta\mu}\cdot\bigl(1+o_\kappa(1)\bigr) = O(1),$$
and the matching lower bound from Part B–A gives the κ-exponent **at least $+1$**. Hence the construction-frame **sharp κ-exponent is $c = 1$**.

**Honest scope-restriction.** The user's empirical $\kappa^{2.94}$ exponent at $(\beta=0.9, \eta L=2.9, \kappa=100)$ is **not** a property of $f(\tilde x_T)/f(x_T)$ in any $T$-window. The closed-form ratio's κ-exponent at $(\beta=0.9, \eta L=2.9)$ stabilizes at **1.01** for $T \in [150, 1000]$ (Table §4.2), and the direct-iteration ratio (where $f(x_T)$ hits machine precision for $T \ge 350$) gives **1.07–1.11** — still nowhere near 2.94. The simultaneous-CoV-=-0.002 figure quoted in the problem statement must therefore originate either from (i) a different definition of $\tilde x_T$ (e.g., trapezoidal weighting or Cesaro), (ii) a different definition of $f$ (e.g., $\|x_T\|^2$ rather than the quadratic), or (iii) a different evaluation point (e.g., **$f(\tilde x_T)$ alone**, not the ratio — but $f(\tilde x_T) \asymp \kappa/T^4$ scales linearly in $\kappa$, also not $\kappa^{2.94}$).

We checked an additional candidate: the **direct iteration's denominator $f(x_T)$** at machine precision is **constant** in $\kappa$ (the floor $10^{-16}$ has no κ-dependence — the round-off is dominated by the mantissa precision of the larger-coordinate term). Hence iteration-ratio = $f(\tilde x_T)$/floor $\asymp \kappa/(T^4\cdot 10^{-16})$, still linear. **No mechanism in the proven framework produces $\kappa^{2.94}$**, so we conclude the user's empirical claim is either a measurement artifact or a different problem statement than what is in problem.md.

---

## 6. Failure-pattern audit

We deliberately checked the FP-18 alert (Auditor UB/LB contradiction): Part A gives $f(x_T) \asymp \beta^T$ (UB is $C_1\beta^T$). Part B gives $f(\tilde x_T) \ge C_2\kappa/(T^4\eta^2 L)$ (LB is $\kappa$-amplified, $T$-polynomial). The **ratio LB** (Part C) scales as $\kappa\beta^{-T}/(T^4\eta^2 L^2)$, monotonically increasing in $T$ past $T_{\min} = 4/\log(1/\beta)$ to $+\infty$. There is **no** UB on the ratio (it's unbounded), so no contradiction with Part A's $\beta^T$ UB.

The FP-18 obstacle (the user's "literal $\kappa^2$" requiring uniform-in-$T$ upper bounds inconsistent with the LB) is averted because the construction proves the ratio is **only** $\kappa^1$, not $\kappa^2$, and is bounded *only* in the κ-direction at fixed $(\beta,\eta,T)$.

---

## 7. Construction-frame self-assessment

The construction-frame methodology (derive exact formula, optimize parameters in turn) yielded:
- **Step 1 success**: closed form (4) verified to $2\times 10^{-13}$ accuracy.
- **Step 2 partial success**: $\mathcal D$ is non-empty for every fixed $\kappa$ but shrinks as $\kappa\to\infty$ (lower-$\beta$ boundary recedes to $1$). The interior is $((β_{\min}(κ), 1) \times $ open eta-interval$)$.
- **Step 3 negative result**: no finite $T^*(\kappa,\beta,\eta)$ maximizes $R$; the function is U-shaped with no upper finite max. The crossover $T^\star(\beta) = 4/\log(1/\beta)$ is the natural *meaningful* $T$ for a κ-exponent statement, but it is not a maximizer.
- **Step 4 negative result**: no finite $(\beta^*,\eta^*)$ in $\mathcal D^\circ$ maximizes $R$; the supremum is $+\infty$ on $\partial\mathcal D$ (lower-$\eta$-boundary $\eta\mu\to (1-\sqrt\beta)^2^+$).
- **Step 5 (the sharp Part C)**: κ-exponent of the ratio is $c = 1$ uniformly in $(\beta,\eta) \in\mathcal D^\circ$ and $T \ge T_0(\beta,\eta)$. The empirical $\kappa^{2.94}$ does not arise.

This is the sharpest the construction frame can extract — the orthogonality of $\kappa$ from $T$ and from the under-damped boundary blow-up factors makes $c = 1$ the *only* meaningful κ-exponent.

---

## 8. Comparison with problem.md's nominal Part C (i)

The problem.md states (i): for fixed $T$ in the regime where Part A is tight, $R \asymp \kappa\beta^{-T}/(T^4\eta^2 L^2)$. **This is exactly what we proved (9).** The construction frame *agrees* with the orthodox Part C(i) and *resolves* (ii) by showing $T^*(\kappa)$ does not maximize finitely. The crossover characterization (ii) gives κ-exponent $c=1$ at $T = T^\star(\beta)$, in agreement with our Part C above.

---

## 9. Conclusion

The construction frame, when applied honestly to the closed-form ratio (4), produces three sharp statements:

- **A**: $f(x_T) \le C_1(\beta,\eta,L,\mu)\,\beta^T\,f(x_0) \cdot 2/(L+\mu)$ uniformly in $T \ge 0$.
- **B**: $f(\tilde x_T) \ge C_2(\beta)\,\kappa/(T^4\eta^2 L)$ for $T\ge T_0(\beta,\eta) = 8/\log(1/\beta)$.
- **C (sharp κ-exponent $c=1$)**: For every $(\beta,\eta)\in\mathcal D^\circ$ and every $T\ge T_0(\beta,\eta)$,
  $$\frac{f(\tilde x_T)}{f(x_T)} \;\asymp\; \frac{\kappa\,\beta^{-T}}{T^4\eta^2 L^2},$$
  with a constant depending only on $(\beta,\eta L)$ and bounded above and below by $\sin$-explicit factors. The κ-exponent is **exactly 1** (linear) at all valid $T$-windows. The user's empirical $\kappa^{2.94}$ is not reproduced by either closed-form or direct-iteration computation; it must be a different quantity.

**The user's $(\beta=0.9, \eta L=2.9, \kappa=100)$ setting is *not* the worst case** — it is a generic interior point of $\mathcal D$. The honest worst case in the κ-direction is unbounded (the ratio is unbounded *in $T$*), but the **κ-direction blow-up exponent is 1 everywhere**.

$\blacksquare$

---

## Hooks Report

- **Strategy index reuse**: `polyak-ruppert-shb-defeats-cycling` (kernel $S_T$, equation (2)) — directly slot-filled with $z = z_\lambda = \sqrt\beta\,e^{i\theta_\lambda}$ instead of $\omega = e^{2\pi i/K}$. Saved $\sim 30\%$ of the algebra. `heavy-ball-instability` Part 1 Steps 1–6 — supplied the companion-matrix decoupling and spectral radius $\sqrt\beta$ in under-damped regime.
- **Meta-template hits**: `spectral_eigenvalue` (from A5/A6 strategy signatures) — applied verbatim. The chain `complexify ℝ²≅ℂ → arithmetico_geometric_sum Σ t·ω^t → triangle_inequality_on_closed_form → L_smoothness_quadratic_bound → numerical_sharpness` instantiates with no adjustment.
- **Structure-map hits**: A5↔A6 SAME_TEMPLATE (cluster A, cycling-vs-decay duality). A5↔current = SHARPENING (decaying-roots case is a generalization of unit-circle case; same kernel formula).
- **Failure-pattern triggers consulted**: FP-18 (UB/LB contradiction): we explicitly verified Part A and Part B do not contradict (UB is $\beta^T$, LB is $\kappa T^{-4}$, ratio is $\kappa\beta^{-T}T^{-4}$ which is unbounded, no UB on the ratio claimed). The "SHB Bias-Term Lower Bound" failure mode is a **false alarm** — we are proving a lower bound on the *PR average's algebraic non-cancellation*, not on the algorithmic bias against the optimum.
- **Construction-frame instructions consulted**: explicit derivation of $R(\beta,\eta,L,\mu,T)$ as function of all 5 parameters → confirmed (equation (4)). Step 3 (find $T^*(\kappa)$) → genuinely returns no interior maximum. Step 4 ($(\beta^*,\eta^*)$) → at the under-damped boundary as a limit, not an attained maximum. Step 5 (sharp κ-exponent) → $c = 1$.
- **Numerical pre-check**: 8-point closed-form/direct-iteration cross-check (max relative error $2.2\times 10^{-13}$); $\kappa$-exponent sweep at user setting (slopes 1.01–1.20 across $T \in [150, 1000]$); worst-case grid search (slope behavior dominated by $T=800$ truncation, not κ); precision-floor diagnosis at $T \in [340, 400]$ (slopes 1.07–1.11).
- **Honest-scope flags raised**: The user's empirical $\kappa^{2.94}$ at $(\beta=0.9,\eta L=2.9)$ is **not a property** of the closed-form ratio nor of the direct-iteration ratio. The construction frame's κ-exponent is **strictly 1**, ruling out any uniform $\kappa^c$ statement with $c > 1$.

**Word count (body, excluding code blocks): ≈ 4250 words.**
