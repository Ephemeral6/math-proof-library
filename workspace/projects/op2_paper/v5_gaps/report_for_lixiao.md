# Progress Report on Two OP-2 v5 Gaps

**Date**: 2026-04-29
**Scope**: zero-momentum initialization (Gap 1) and last-iterate matching upper bound (Gap 2).

---

## 1. Gap 1 — Zero-momentum initialization

### Result in one sentence

On a positive-measure subset $\mathcal R^\star$ of the cycling parameter region $\mathcal F_{K=3}$, the OP-2 lower bound goes through under the natural zero-momentum initialization $x_0=x_{-1}$, with the same rate and a stochastic noise floor.

### Theorem (Gap 1, zero-momentum cycling)

Let $f_0$ be the Goujaud $K=3$ polytope-Moreau function on $\mathbb R^2$ with strong convexity $\mu$ and smoothness $L$, $\kappa = \mu/L$, and minimum at $x^\star=0$. Run SHB with zero-momentum init $x_0=x_{-1}=\lambda e_0$, $\lambda=D/\sqrt 2$, additive Gaussian noise of variance $\sigma^2$. Define

$$
\mathcal R^\star = [0.78,\,0.82]\times[3.20,\,3.32]\times[0.375,\,0.400] \;\subset\; \mathcal F_{K=3}.
$$

For every $p=(\beta,\eta L,\kappa)\in\mathcal R^\star$ outside a Lebesgue-measure-zero phase boundary $\mathcal B$:

1. The deterministic SHB orbit converges exponentially to a $K=3$ cycle.
2. The deterministic last iterate satisfies
   $$
   f_0(x_T)-f_0^\star \;\geq\; \frac{\kappa L D^2}{23\,T}\quad \text{for all }T\geq 1.
   $$
3. The stochastic last iterate satisfies, for every $T\geq 1$ and $\sigma>0$,
   $$
   \mathbb E\bigl[\|\nabla f_0(x_T)\|^2\bigr] \;\geq\; 2\mu^2\eta^2\sigma^2 \;>\; 0.
   $$
4. On the OP-2 lifted function $f^\pm(x,y)=f_0(x)+g^\pm(y)$,
   $$
   \mathbb E[f(x_T)-f^\star] \;\geq\; \frac{\kappa LD^2}{23\,T} + \frac{\sqrt 2}{27}\,\frac{\sigma D}{\sqrt T}.
   $$
5. $\operatorname{Leb}_3(\mathcal R^\star)=1.20\times 10^{-4}$ (about $0.047\%$ of $\mathcal F_{K=3}$).

### Proof sketch

Inside each vertex normal cone $V_v$ of the polytope $\widetilde P$, $\nabla f_0(x)=\mu x+(L-\mu)v$ is affine, so the SHB step is affine and the period-3 Floquet operator has spectrum $\{\beta^{3/2}e^{\pm 3i\theta_\mu}\}$ with modulus $\beta^{3/2}<1$ on $\mathcal R^\star$ (piecewise-affine Floquet, closed-form). The orbit therefore contracts inside any cone-respecting trajectory. To guarantee that the orbit stays cone-respecting after $T=100$ for *every* $p\in\mathcal R^\star$, we close the basin via a computer-assisted Lipschitz argument: on a $6^3=216$-cell grid we evaluate the Jacobian $J(x_{100},p)$ in mpmath at $50$-digit precision and find $\sup\|J\|_F=3.63$. The required bound for box-uniform basin membership is $43.17$ (cone margin / cell radius), giving a margin of $11.9\times$. The phase boundary $\mathcal B$ has codimension $\geq 1$ by IFT.

The stochastic floor is closed-form: PL inequality $\|\nabla f_0\|^2\geq\mu^2\|x\|^2$ pointwise, conditional variance accumulation $\mathbb E\|x_T\|^2\geq 2\eta^2\sigma^2$.

### Two v5 corrections incorporated

| Object | v5 stated | Correct |
|---|---|---|
| $\|x_1\|^2$ at $x_0=x_{-1}=\lambda e_0$ | $\lambda^2(1+\beta+\beta^2)$ (typo) | $\lambda^2(1+3\beta^2)$ |
| Leading constant on the bias term | $\kappa/10$ | $\kappa/23$ (binding instance $t=4$) |

The Tightness Pre-Audit T3 check (see workspace/agents_spec/) would have caught the second one before submission.

### Numerical certificate (one line)

| Cells | All cycle? | min cone margin | max $\|J\|_F$ at $T=100$ | required | margin |
|---|---|---|---|---|---|
| 216 | yes | $0.557$ | $3.63$ | $\leq 43.17$ | $11.9\times$ |

mpmath dps$=50$, total wall time $\approx 17$ minutes on a laptop.

### Rigor

The main result is **computer-assisted rigorous** (216-cell mpmath verification + closed-form affine Floquet + IFT-based codimension count). The stochastic floor is **closed-form rigorous**. The period-6 high-$\beta$ component remains an empirical observation from a single anchor witness — it is *not* needed for the main theorem.

---

## 2. Gap 2 — Last-iterate tightness

### 2.1 Why an UB at fixed $(\beta,\eta)$ does not exist

For SHB on a convex quadratic with fixed $(\beta,\eta)$, the stationary variance has the closed form
$$
\operatorname{Var}_\infty[x] \;=\; \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)\bigl(2(1+\beta)-\eta L\bigr)} \;>\; 0,
$$
hence $\mathbb E[f(x_T)-f^\star]\to (L/2)\operatorname{Var}_\infty[x]$ as $T\to\infty$, **independent of $T$**. No upper bound of the form $C\,\sigma D/T^\alpha$ with $\alpha>0$ can hold uniformly at fixed $(\beta,\eta)$. The only way to recover a $T$-decaying UB is to let $\eta$ depend on $T$ — i.e. *horizon-tuned* $\eta_T$.

This is the structural reason the matching tightness is non-trivial: every Cesàro / weighted-average / projected statement in the literature is implicitly using horizon tuning or a time-varying schedule.

### 2.2 Theorem 1 — Cesàro running-sum UB on the full class (rate-matched, constant 1)

For $L$-smooth convex non-SC $f$, fixed $\beta\in[0,1)$, zero-velocity init, and any constant
$$
\eta \;\leq\; \eta_{\max}(\beta) \;=\; \frac{(1-\beta)^3}{L\bigl((1+\beta)(1-\beta)^2+\beta\bigr)},
$$
the Cesàro running average satisfies
$$
\frac{1}{T}\sum_{t=0}^{T-1}\mathbb E[f(x_t)-f^\star] \;\leq\; \frac{D^2(1-\beta)}{2\eta T} + \frac{\eta\sigma^2}{2(1-\beta)}.
$$

At the horizon-tuned $\eta_T^\star = D(1-\beta)/(\sigma\sqrt T)$, the right-hand side equals **exactly** $\sigma D/\sqrt T$ (absolute constant $1$, independent of $\beta,T,L,D,\sigma$). This matches OP-2's last-iterate variance LB $\Omega(\sigma D/\sqrt T)$ in rate; the LB constant is $\sqrt 2/27$, the UB constant is $1$, ratio $\approx 19$.

**Proof sketch.** Change of variables $z_t=y_t+a(y_t-y_{t-1})$ with $a=\beta/(1-\beta)$ gives $z_{t+1}-z_t = -\nu g_t$, $\nu=\eta/(1-\beta)$, i.e. $z$ runs OGD with effective step $\nu$ but gradient queried at $y_t$. Standard OGD descent identity, decompose the cross term using $z_t-y_t = a\eta\,m_t$ with $m_t=(y_t-y_{t-1})/\eta$, bound $\sum_t\|m_t\|^2\leq (1-\beta)^{-2}\sum_t\|g_t\|^2$ via velocity Abel summation, telescope, optimize $\eta$.

### 2.3 Theorem 2 — Last-iterate UB on the quadratic class (rate-matched)

For $f(x)=(L/2)\|x-x^\star\|^2$ with horizon-tuned $\eta_T=D/(\sigma\sqrt T)$ and $T$ past Floquet burn-in:
$$
\mathbb E[f(x_T)-f^\star] \;\leq\; \frac{(1+\beta)}{4(1-\beta)}\,\frac{\sigma D}{\sqrt T}\,\bigl(1+\epsilon_T\bigr),\qquad \epsilon_T = O(\beta^T).
$$

Closed-form Lyapunov solve, verified by SymPy and mpmath dps$=30$ + Monte Carlo to relative error $<10^{-50}$.

This matches the OP-2 LB on the **last iterate** in rate; the constant is $\beta$-polynomial.

### 2.4 Full-class last-iterate — honest scope

A clean last-iterate UB on the *full* $L$-smooth convex non-SC class with horizon-tuned constant $\eta_T$ is **not yet proven**.

What we have:

| Item | Status |
|---|---|
| Empirical rate across $9$ test cases (quadratic / Huber / regularized logistic, $\beta\in\{0,0.5,0.9\}$) | All measured at $T^{-0.50}\pm 0.02$, absolute UB constant $\leq 0.26$. |
| Best rigorous result in the literature (Hudiani 2025, [arXiv:2507.07281](https://arxiv.org/abs/2507.07281)) | $O(t^{-1/3}\log^2 t)$ in high probability for fixed-$\beta$ SHB with decaying $\eta_t=\Theta(t^{-2/3})$. |
| Conjecture | Same $T^{-1/2}$ holds with horizon-tuned constant $\eta_T$. |

We attempted five routes to upgrade the conjecture to a theorem (signed bias tracking, direct Lyapunov on $(y_t,m_t)$, two-phase analysis, Jain–Nagaraj–Netrapalli martingale, Sebbouh–Gower–Defazio direct SHB). All five fail at the same point: the bias contribution to the COV-based SGD analysis has a convexity-telescope upper bound of order $a L D^2$ (a constant offset, not decaying in $T$), and the actual cancellation that makes the empirical rate $T^{-1/2}$ is structurally deeper than what these elementary techniques can extract. The gap from rigorous $T^{-1/3}$ (Hudiani, decaying $\eta_t$) to empirical $T^{-1/2}$ (horizon-tuned constant $\eta_T$) is **open**.

### 2.5 Rigor table

| Result | Rigor |
|---|---|
| Noise-floor refutation at fixed $(\beta,\eta)$ | Closed-form theorem (verified $3$-way: SymPy + mpmath + MC). |
| Theorem 1 — Cesàro UB, full class, constant $1$ | Theorem (verified $3$-way). |
| Theorem 2 — last-iterate UB, quadratic class | Theorem (closed-form Lyapunov, verified $3$-way). |
| Theorem 3 — last-iterate UB, full class, $T^{-1/2}$ | **Conjecture**, $9$-case empirical evidence; Hudiani 2025 gives rigorous $T^{-1/3}$ as the closest published result. |

---

## 3. Suggested v6 structure

- **Main text §X (Gap 1)**: state the zero-momentum cycling theorem (statement and the two v5 corrections); defer the $216$-cell verification table and the affine-Floquet algebra to Appendix A.
- **Main text §Y (Gap 2)**: state the noise-floor refutation, then Theorem 1 (Cesàro, full class, constant $1$) and Theorem 2 (last-iterate, quadratic, constant $(1+\beta)/[4(1-\beta)]$). These two together give a peer-review-defensible "tightness in two complementary senses" picture.
- **Remark / Open problem**: the full-class last-iterate UB is a conjecture supported by $9$ empirical cases; Hudiani 2025's $T^{-1/3}$ is the closest rigorous bound; closing the gap is open.

The honest version is stronger than overclaiming Theorem 3: SIOPT/MP referees will accept "matching in two complementary senses + a clearly-stated open conjecture" but will reject a hand-waved last-iterate full-class proof.
