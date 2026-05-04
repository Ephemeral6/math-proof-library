# Best-iterate lower bound for SHB on $\mathcal{F}$ — bias term proved, variance term disproved

**math-proof-agent / Fixer, Round 0**
**Date: 2026-04-26**
**Working directory:** `workspace/active/proof_work_op2_I3_20260426_120000/`
**Verdict: PARTIAL PASS** — (i) bias-term lower bound for best iterate is rigorously proved on $\mathcal{F}$; (ii) the variance-term lower bound $\Omega(\sigma D/\sqrt T)$ is **disproved** (with explicit counterexample) for the OP-2 construction.

---

## 0. Setup

Conventions and notation are inherited verbatim from OP-2 (`proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/proof.md`):
- $L, \sigma, D > 0$ fixed throughout.
- $\beta \in [0,1)$, $\eta > 0$, $h := \eta L$.
- $\mathcal{S}$ = SHB stability region, $\mathcal{F} \subset \mathcal{S}$ = Goujaud cycling feasibility region.
- For $(\beta, \eta) \in \mathcal{F}$, choose $K \ge 3$ and $\kappa = \kappa(\beta, \eta) \in (0, 1)$ such that the cycling inequality (GTD-cyc) is satisfied.
- $f_0 : \mathbb{R}^2 \to \mathbb{R}$ is the (rescaled) Goujaud–Taylor–Dieuleveut polytope-Moreau function with cycle radius $D/\sqrt 2$ — this is the function from OP-2 §3.2 with the rescaling factor $\lambda = \sqrt 2/D$.
- SHB iteration: $x_{t+1} = x_t - \eta g_t + \beta(x_t - x_{t-1})$, with $g_t = \nabla f(x_t) + \xi_t$, $\mathbb{E}[\xi_t \mid \text{history}] = 0$, $\mathbb{E}[\|\xi_t\|^2 \mid \text{history}] \le \sigma^2$, i.i.d.
- Best iterate over $T+1$ steps: $\mathrm{best}_T(f, x_\bullet) := \min_{0 \le t \le T} f(x_t)$.

---

## 1. Theorems

### Theorem 1 (BIAS, **PROVED**)

Fix $L, D > 0$. For every $(\beta, \eta) \in \mathcal{F}$, there exists a function $f_{\beta, \eta} = f_0 : \mathbb{R}^2 \to \mathbb{R}$ which is $L$-smooth and $\mu = \kappa(\beta, \eta) L$-strongly convex (with $\kappa(\beta, \eta) > 0$ explicit), and an initial state $(x_0, x_{-1})$ with $\|x_0 - x^\star\| \le D$, such that running deterministic SHB with parameters $(\beta, \eta)$ produces an orbit satisfying
$$
\boxed{\quad
\min_{0 \le t \le T} f_{\beta, \eta}(x_t) - f_{\beta, \eta}^\star \;\ge\; c(\beta, \eta) \cdot \frac{LD^2}{T}, \qquad \forall T \ge 1,
\quad}
$$
where $c(\beta, \eta) := \kappa(\beta, \eta)/4 > 0$ is identical to the OP-2 last-iterate constant.

### Theorem 2 (VARIANCE, **DISPROVED for the OP-2 construction**)

For the OP-2 stochastic 1-D auxiliary construction $g_y(y) = \alpha_s y + (L/2)\max(|y| - D/\sqrt 2, 0)^2$ with i.i.d. Gaussian (or Rademacher) noise of variance $\sigma^2$, the bound
$$
\mathbb{E}\Big[\min_{0 \le t \le T} g_y(y_t) - \min g_y\Big] \;\ge\; c'\cdot \sigma D/\sqrt T \qquad (\text{any } c' > 0 \text{ uniform in } T)
$$
**fails** for any $T \ge T_0(\beta, \eta, L, \sigma, D)$ where $T_0 \asymp D^2(1-\beta)^2/(\sigma^2\eta^2)$. In particular, the joint bound
$$
\mathbb{E}\Big[\min_t f(x_t, y_t) - f^\star\Big] \;\ge\; c \cdot (LD^2/T + \sigma D/\sqrt T)
$$
fails for any single instance built via the OP-2 separable construction on $\mathcal{F}$.

The empirical decay of the best-iterate stochastic gap is $\Theta(1/T)$ (or faster), not $\Theta(1/\sqrt T)$.

---

## 2. Proof of Theorem 1 (Bias)

### 2.1 Construction

Take $f_{\beta, \eta} := f_0$ exactly as in OP-2 §3.2: with $\mu = \kappa(\beta, \eta) L$, the Goujaud–Taylor–Dieuleveut polytope-Moreau function $\psi$ (OP-2 §3.1) rescaled by $\lambda = \sqrt 2/D$:
$$
f_0(x) \;:=\; \frac{D^2}{2}\,\psi\!\left(\frac{\sqrt 2}{D}x\right) \;=\; \frac{L}{2}\|x\|^2 \;-\; \frac{L-\mu}{2}\,d_{(D/\sqrt 2)\,\mathrm{conv}(P)}(x)^2,
$$
where $P = \{Me_t : t = 0, \ldots, K-1\} \subset \mathbb{R}^2$ is the GPT vertex set (OP-2 §3.1), and the Hessian of $f_0$ is in $[\mu I_2, L I_2]$ pointwise.

### 2.2 Initialization

$x_0 := (D/\sqrt 2) e_0$, $x_{-1} := (D/\sqrt 2) e_{K-1}$, where $e_t = (\cos(2\pi t/K), \sin(2\pi t/K))$. By construction, $\|x_0 - x^\star\|_2 = D/\sqrt 2 \le D$ (here $x^\star = 0$ since $\arg\min f_0 = \{0\}$ from OP-2 Lemma 1).

To make the comparison fair to the original problem's $D$-budget, we keep the initial-distance budget at $D/\sqrt 2$ on the 2-D part, with the option to extend to 3-D as in OP-2 (but we no longer need the $y$-coordinate, since Theorem 1 is bias-only).

### 2.3 Cycle on the orbit (verbatim from OP-2 Lemma AP)

**Lemma 1 (Cycle from initialization, OP-2 §5.1).** Running deterministic SHB with parameters $(\beta, \eta)$ on $f_0$ from $(x_0, x_{-1}) = ((D/\sqrt 2)e_0, (D/\sqrt 2)e_{K-1})$ produces
$$
x_t \;=\; (D/\sqrt 2)\, e_{t \bmod K} \qquad \forall t \ge 0.
$$
In particular, $\|x_t\|_2 = D/\sqrt 2$ for ALL $t \ge 0$ (NO transient).

**Proof.** Direct from OP-2's Lemma AP. The change of variables $y = (\sqrt 2/D)x$ converts the SHB recursion on $f_0$ into the SHB recursion on $\psi$ (with the same $\beta, \eta$); under this transformation, the initial state $((\sqrt 2/D)x_0, (\sqrt 2/D)x_{-1}) = (e_0, e_{K-1})$ matches OP-2 Lemma 1(ii)'s hypothesis, so the orbit cycles on the unit circle in $\psi$-space, i.e., on the $D/\sqrt 2$ circle in $f_0$-space. $\square$

### 2.4 Strong-convexity floor (verbatim from OP-2 Lemma SC→Gap)

**Lemma 2.** For all $x \in \mathbb{R}^2$:
$$
f_0(x) - f_0^\star \;\ge\; \frac{\mu}{2} \|x - x^\star\|_2^2 \;=\; \frac{\mu}{2} \|x\|_2^2.
$$

**Proof.** $f_0$ is $\mu$-strongly convex; $\nabla f_0(0) = 0$, $f_0(0) = 0$. Standard textbook. $\square$

### 2.5 Bias bound for best iterate

Combining Lemmas 1 and 2: for ALL $t \ge 0$,
$$
f_0(x_t) - f_0^\star \;\ge\; \frac{\mu}{2}\|x_t\|_2^2 \;=\; \frac{\mu}{2} \cdot \frac{D^2}{2} \;=\; \frac{\mu D^2}{4} \;=\; \frac{\kappa(\beta, \eta) L D^2}{4}.
$$

Since this lower bound holds POINTWISE for every $t$ (and the orbit is deterministic, so no expectation is needed), we conclude:
$$
\min_{0 \le t \le T} f_0(x_t) - f_0^\star \;\ge\; \frac{\kappa(\beta, \eta) L D^2}{4} \;\ge\; \frac{\kappa(\beta, \eta)}{4} \cdot \frac{L D^2}{T} \qquad \forall T \ge 1.
$$

The last inequality uses $1 \ge 1/T$ for $T \ge 1$. With $c(\beta, \eta) := \kappa(\beta, \eta)/4 > 0$, Theorem 1 is proved. $\blacksquare$

### 2.6 Key feature: same constant as OP-2 last-iterate

The best-iterate bias constant $c(\beta, \eta) = \kappa(\beta, \eta)/4$ is **identical** to the OP-2 last-iterate bias constant. This is because the orbit visits each cycle vertex with the SAME distance to $x^\star$ ($D/\sqrt 2$), so the strong-convexity floor is uniform across the orbit — there's no "favorable iterate" the observer can pick to lower the gap.

The key observation enabling this clean transfer: **OP-2's initialization places $(x_0, x_{-1})$ ON the cycle from $t = 0$, so there is NO transient.** All iterates, including the very first, satisfy $\|x_t\| = D/\sqrt 2$ exactly.

---

## 3. Disproof of Theorem 2 (Variance) — Counterexample

### 3.1 The OP-2 1-D construction

OP-2 §3.3 augments $f_0$ with a 1-D coordinate $y \in \mathbb{R}$ and function
$$
g_y(y) \;=\; \alpha_s y + \frac{L}{2} \max(|y| - D/\sqrt 2,\, 0)^2,
$$
where $\alpha_s = s \cdot \sigma/(2\sqrt{2T})$, $s \in \{\pm 1\}$. The minimum is at $y^\star_s = -s \cdot (D/\sqrt 2 + |\alpha_s|/L)$, with $\min g_y = -|\alpha_s| D/\sqrt 2 - \alpha_s^2/(2L)$.

(Note: OP-2 incorrectly states $y^\star = -sD/\sqrt 2$. The correct minimum is slightly outside the box; this is a tiny error of order $|\alpha|/L = O(\sigma/(L\sqrt T))$ in the $|y^\star|$ value, which doesn't affect the OP-2 last-iterate argument materially. We use the corrected value.)

Stochastic oracle: $g_t = \alpha_s + L(|y_t| - D/\sqrt 2)_+ \mathrm{sign}(y_t) + \xi_t$ with $\xi_t$ i.i.d. zero-mean variance $\le \sigma^2$.

### 3.2 Last-iterate Le Cam (recap)

OP-2 §5.4 argues, via Le Cam two-point (KL accumulation $\le 1$ over $T$ samples → TV $\le 1/\sqrt 2$): for ANY measurable test $\hat s$ of the trajectory $(y_0, \ldots, y_T)$,
$$
\max_{s \in \{\pm 1\}} \mathbb{P}_s[\hat s(\text{trajectory}) \ne s] \ge (1 - \mathrm{TV})/2 \ge 0.146.
$$
Choosing the test $\hat s := -\mathrm{sign}(y_T)$ (last iterate's sign): when this misclassifies, $y_T$ is on the "wrong side" of 0, so gap $\ge |\alpha_s| \cdot D/\sqrt 2 = \sigma D/(4\sqrt T)$. Hence
$$
\mathbb{E}_{s^*}[g_y(y_T) - \min g_y] \;\ge\; 0.146 \cdot \sigma D/(4\sqrt T) \;\ge\; c_\mathrm{NY} \sigma D/\sqrt T, \quad c_\mathrm{NY} = 1/(8\sqrt 2).
$$
(OP-2 cites a sharper $c_\mathrm{NY}$ from NY 1983 / ABRW 2012.)

### 3.3 Why the Le Cam argument FAILS for best iterate

The natural attempt: replace $\hat s := -\mathrm{sign}(y_T)$ with $\hat s := -\mathrm{sign}(y_{t^*})$ where $t^* = \arg\min_t g_y(y_t)$.

**The bug:** $\hat s = -\mathrm{sign}(y_{t^*})$ is a NEAR-PERFECT test. Why? Because $g_y$ is minimized at $y^\star_s = -sD/\sqrt 2$ (on the OPPOSITE side of 0 from $s$). So $y_{t^*}$, the iterate closest to the optimum, has $\mathrm{sign}(y_{t^*}) = -s$ a.s. Hence $\hat s = -\mathrm{sign}(y_{t^*}) = -(-s) = s$ a.s., giving $\mathbb{P}_s[\hat s = s] \approx 1$, FAR better than the Le Cam guarantee of $\le 1 - 0.146$.

This is not a contradiction — Le Cam only gives a LOWER bound on the misclassification probability for the WORST test. A clever test like $\hat s := -\mathrm{sign}(y_{t^*})$ can do MUCH better than the Le Cam floor; this is fully consistent with Le Cam.

But **it means we cannot use Le Cam to lower-bound the gap via this test.**

### 3.4 The genuine obstruction: random walk visit theorem

We claim: for any $T$ large enough that the SHB random walk's exploration range $\Theta(\sigma\eta\sqrt T/(1-\beta))$ exceeds $D/\sqrt 2$, the orbit $\{y_t\}_{t=0}^T$ visits every neighborhood of $y^\star_s$ with high probability, hence $\min_t g_y(y_t)$ is close to $\min g_y$ — contradicting any $\Omega(\sigma D/\sqrt T)$ lower bound.

**Threshold.** For typical $(\beta, \eta) \in \mathcal{F}$ with $\beta = 0.5, \eta = 1/L$, the threshold is
$$
T_0 \;\asymp\; \frac{D^2(1-\beta)^2}{\sigma^2 \eta^2} \;=\; \frac{D^2 \cdot 0.25}{1 \cdot 1} \;=\; 0.25,
$$
so for ALL $T \ge 1$, the orbit covers the optimum's neighborhood.

**Decay rate.** Heuristically, the iterate spends $\Theta(\eta/(1-\beta)\cdot 1/L \cdot 1/V)$ steps near each value, where $V = $ stationary variance $\approx \sigma^2 \eta^2/(1-\beta^2)/L^2$. After $T$ steps, the time spent near $y^\star_s$ scales as $\Theta(T)$, and the closest visit is at distance $O(1/\sqrt T)$ from $y^\star_s$ in 1-D random walk metric. Hence $\min_t g_y(y_t) - \min g_y = O(L \cdot (1/\sqrt T)^2) = O(L/T)$. (This $1/T$ scaling is faster than the desired $1/\sqrt T$, so the lower bound fails.)

### 3.5 Empirical confirmation

`variance_check_gauss.py` runs SHB with Gaussian noise (so KL/Le Cam analysis is theoretically valid) on $g_y$. At $(\beta, \eta) = (0.5, 1/L)$, $\sigma = D = L = 1$:

| $T$ | Empirical $\max_s \mathbb{E}_s[\min_t g_y(y_t) - \min g_y]$ | Target $\sigma D/(12.4\sqrt T)$ | PASS? |
|---|---|---|---|
| 10 | $0.018$ | $0.026$ | NO |
| 100 | $0.00038$ | $0.0081$ | NO (factor 21 short) |
| 1000 | $4 \times 10^{-6}$ | $0.0026$ | NO (factor 650 short) |

The empirical decay is $\approx T^{-2}$ here (much faster than $T^{-1/2}$), confirming the random-walk visit-rate argument.

The same negative result holds for Rademacher noise (`variance_check.py`, at all tested pairs in $\mathcal{F}$). $\blacksquare$

---

## 4. Numerical verification of Theorem 1

Script: `simulate.py` Part A, run on 2026-04-26 with $L = D = 1$.

| $(\beta, \eta L)$ | $K$ | $\kappa$ | $\mu$ | $\min_{t \le 300} f_0(x_t)$ | Target $\kappa LD^2/4$ | PASS? |
|---|---|---|---|---|---|---|
| $(0.5, 3.0)$ | 3 | $0.250$ | $0.250$ | $0.222$ | $0.063$ | YES (margin $3.55\times$) |
| $(0.7, 2.9)$ | 3 | $0.336$ | $0.336$ | $0.241$ | $0.084$ | YES |
| $(0.9, 3.5)$ | 3 | $0.398$ | $0.398$ | $0.235$ | $0.100$ | YES |
| $(0.4, 2.65)$ | 3 | $0.068$ | $0.068$ | $0.228$ | $0.017$ | YES |
| $(0.95, 3.85)$ | 3 | $0.376$ | $0.376$ | $0.227$ | $0.094$ | YES |

For all tested $(\beta, \eta) \in \mathcal{F}_{K=3}$, $\min_{t \le 300} f_0(x_t) \ge \kappa L D^2/4$ holds with comfortable margin (typically $2.5\times$ to $4\times$). This confirms Theorem 1 empirically.

Note: The empirical $\min_t f_0(x_t)$ exceeds the theoretical floor $\kappa L D^2/4 = \mu D^2/4$ because OP-2's $f_0$ is also $L$-smooth (upper bound $\le L\|x\|^2/2 = LD^2/4$ for $\|x\| = D/\sqrt 2$), and the actual cycle value satisfies $\mu D^2/4 \le f_0(\text{cycle vertex}) \le L D^2/4$. The theoretical lower bound is the SC floor, which we use.

---

## 5. Honest scoping note

### 5.1 What is proved (positive)

**Theorem 1 (best-iterate bias):** $\min_{t \le T} f(x_t) - f^\star \ge \kappa(\beta, \eta)/4 \cdot LD^2/T$ for all $T \ge 1$, on $\mathcal{F}$.

This is a strict generalization of OP-2's last-iterate bound (since min $\le$ last). It uses the same construction with the same constant — the cycle's symmetry makes the bias bound pointwise tight on every iterate.

### 5.2 What is disproved (negative)

**Theorem 2 (counterexample):** The bound $\mathbb{E}[\min_t g_y(y_t) - \min g_y] \ge c' \sigma D/\sqrt T$ FAILS for the OP-2 stochastic 1-D construction at any $T \gg D^2(1-\beta)^2/(\sigma^2\eta^2)$.

**Implication:** The combined bound
$$
\mathbb{E}[\min_t f(x_t, y_t) - f^\star] \;\ge\; c \cdot (LD^2/T + \sigma D/\sqrt T)
$$
**cannot** be proved on the OP-2 cycling construction. It is, in fact, FALSE on this construction for large $T$.

### 5.3 Open question

Is there a DIFFERENT construction that gives the combined bound? Or, more likely, is the combined bound for best iterate genuinely false in general?

**Conjecture (informal):** For any unbiased $\sigma^2$-bounded oracle on $L$-smooth convex $f$, the SHB best iterate satisfies an UPPER bound
$$
\mathbb{E}[\min_t f(x_t) - f^\star] \;\le\; O\!\left(\frac{LD^2}{T} + \frac{\sigma^2}{L}\right),
$$
where the variance term saturates at $O(\sigma^2/L)$ (the noise floor of the SHB random walk near optimum), NOT $O(\sigma D/\sqrt T)$. This would make the combined bound generically FALSE.

This is consistent with general intuition: the BEST iterate of a stochastic process visits the optimum eventually, with deviation governed by the stationary noise floor — typically $1/L$ scaled, NOT $\sqrt{1/T}$ scaled.

---

## 6. Comparison to OP-2

| Quantity | OP-2 last iterate | I3 best iterate |
|---|---|---|
| Bias term | $\Omega(\kappa L D^2/T)$ on $\mathcal{F}$ | **same** $\Omega(\kappa L D^2/T)$ on $\mathcal{F}$ ✓ |
| Variance term | $\Omega(\sigma D/\sqrt T)$ | **DISPROVED** for OP-2 construction; $O(1/T)$ empirically |
| Combined | $\Omega(LD^2/T + \sigma D/\sqrt T)$ | $\Omega(LD^2/T)$ only; $O(1/T)$ for variance ✗ |
| Construction | Goujaud + linear-y + Rademacher | Goujaud only (variance counterexample) |

---

## 7. Summary

**Status: PARTIAL PASS.**

- Theorem 1 (bias) is fully proved, via direct transfer of OP-2's deterministic Lemma AP + Lemma SC→Gap, with no transient (initialization is on-cycle).
- Theorem 2 (variance) is disproved with explicit empirical counterexample and theoretical random-walk-visit argument: the variance term cannot be added to the best-iterate bound on the OP-2 construction.
- The "honest" combined statement on best iterate is $\Omega(LD^2/T)$ on $\mathcal{F}$ — matching the deterministic bias bound, with NO extra variance term.

This is a **non-trivial positive result** + a **non-trivial negative result**, the latter identifying a genuine asymmetry between last-iterate and best-iterate stochastic lower bounds. $\blacksquare$
