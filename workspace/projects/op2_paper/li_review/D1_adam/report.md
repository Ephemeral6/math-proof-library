# D1 — Non-acceleration of fixed-hyperparameter Adam/RMSProp

**Date:** 2026-04-26
**Status:** FAIL — OP-2's bias LB does NOT extend to Adam or RMSProp

## Verdict

**The OP-2 lower bound does NOT extend to fixed-hyperparameter Adam/RMSProp.** Adam systematically circumvents the cycling argument via three independent failure modes. The variance term $\Omega(\sigma D/\sqrt T)$ likely transfers (Le Cam structure on the decoupled $y$-coord is optimizer-agnostic), but the bias term $\Omega(LD^2/T)$ is genuinely SHB-specific.

## Why OP-2's argument breaks for Adam

OP-2's bias term $\kappa LD^2/(4T)$ depends critically on the deterministic identity $\nabla f_0(\lambda e_t) = \lambda\nabla\psi(e_t)$ combined with the SHB recursion to give $x_{t+1} = \lambda e_{t+1}$. Adam destroys this in three independent ways, any one of which suffices:

### 1. Per-coordinate scaling breaks cycle symmetry

On SHB's cycle $(\lambda e_0, \lambda e_1, \lambda e_2)$ at $(\beta=0.5, \eta L=3, \kappa=0.25)$, $\|g_t\|=$ const, but per-coordinate $g_t^2$ rotates:

| Vertex | $g_t^2$ |
|---|---|
| $\lambda e_0$ | $[0.281, 0.010]$ |
| $\lambda e_1$ | $[0.031, 0.260]$ |
| $\lambda e_2$ | $[0.125, 0.167]$ |

Ratio up to **27:1** within a single cycle. Adam reads this as "coord-0 is 27× more sensitive" and applies asymmetric steps that break the rotational structure of the $K=3$ polygon.

Even after $v_t$ stabilizes to per-coord cycle-averaged means $\approx [0.147, 0.145]$ (only $\sim 1\%$ asymmetric in the limit), the path from $t=1$ has already pushed $x_t$ off-manifold.

### 2. Bias-corrected $\hat v_1$ blow-up

At $t=1$, $\hat v_1 = v_1/(1-\beta_2) = (1-\beta_2)g_0^2/(1-\beta_2) = g_0^2$. So the first Adam step is
$$\eta\,\hat m_1/(\sqrt{\hat v_1}+\epsilon) = \eta\,g_0/|g_0| = \eta\,\mathrm{sign}(g_0)\cdot[1,1].$$

For $\eta = 3/L$: step magnitude $= \eta\sqrt 2 \approx 4.24$, jumping from $\|x_0\|=0.71$ to $\|x_1\|\approx 3.78$. **Confirmed numerically.** This unconditional bias-correction blow-up at $t=1$ is independent of the choice of $(\beta_1, \beta_2)$ — only $\epsilon$ and $\eta$ matter, and even small $\eta$ + large $\epsilon$ cannot fully suppress it.

### 3. Scalar-rescaling intuition fails

If $v_t \to v_\infty I$ (isotropic limit), naive intuition says Adam reduces to SHB with $\eta_{\mathrm{eff}} = \eta/\sqrt{v_\infty}$, and OP-2 would apply at $(\beta_1, \eta_{\mathrm{eff}})$. But the matched-eta experiment shows the off-manifold transient from (1) and (2) prevents reentry to the cycle — coord-asymmetry of $g^2$ is order-1 within a cycle, and eta-corrections don't cancel transient.

## Numerical evidence

Setup: rescaled Goujaud $K=3$, $(\beta=0.5, \eta L=3, \kappa=0.25)$, cycling-init.

### Deterministic ($\sigma=0$): OP-2 LB violated

$f_0(x_T)$ values:

| $T$ | OP-2 LB $\kappa LD^2/(4T)$ | SHB | Adam $\eta=0.05$ | Adam $\eta=0.005$ | RMSProp $\eta=0.05$ |
|---|---|---|---|---|---|
| 50 | 0.00125 | **0.222** | 0.000 | 0.108 | 0.000 |
| 100 | 0.00063 | **0.222** | 0.000 | 0.037 | 0.000 |
| 1000 | 0.00006 | **0.222** | 0.0002 | $10^{-5}$ | 0.0004 |

SHB stuck at cycling LB; Adam/RMSProp decay to $\sim 0$ — **OP-2 LB violated by orders of magnitude.**

### Stochastic ($\sigma = 0.5$, $n = 100$ trials)

| Algorithm | $\mathbb{E}[f - f^\star]$ at $T=100$ | Asymptotic exponent (regression $\log L = a + b \log T$) |
|---|---|---|
| SHB | 1.477 | $-0.009$ (constant — cycling floor) |
| Adam $\eta=0.05$ | 0.0104 | $-0.395$ |
| RMSProp $\eta=0.05$ | 0.0103 | $-0.352$ |

OP-2 LB has variance-term exponent $-0.5$. Adam matches the variance scaling (no acceleration beyond Lan's $1/\sqrt T$) but **completely escapes the bias-term cycling floor**.

## Adam variants tested

| Config | $\|x_1\|$ | $\|x_{60}\|$ | $f_0(x_{60})$ | Cycle? |
|---|---|---|---|---|
| SHB baseline | 0.71 | 0.71 | 0.222 | YES |
| Adam typical $(0.5, 0.99, 10^{-8}, \eta=3)$ | 3.78 | 0.95 | 0.357 | NO |
| Adam $(0.5, 0, 0, \eta=3)$ ("normalized SGDM") | 3.78 | 75.9 | 742 (diverges) | NO |
| RMSProp $(0, 0.99, 10^{-8}, \eta=3)$ | 3.78 | 2.19 | 1.06 | NO |
| Adam small $\eta=0.05$ | 0.66 | $\sim 0$ | $\sim 0$ | NO (geom. decay) |
| Adam big $\epsilon=1.0, \eta=3$ | 0.43 | $\sim 0$ | $\sim 0$ | NO |
| Adam $\beta_1=0.9$ | 3.78 | 0.11 | 0.006 | NO |

**No variant tested preserves cycling.**

## Why $\beta_2 = 0, \epsilon = 0$ is *normalized SGDM*, not SHB

With $\beta_2 = 0, \epsilon = 0$: $\sqrt{\hat v_t} + \epsilon = |g_t|$ (per coord), so
$$x_{t+1} = x_t - \eta\,\hat m_t/|g_t|,$$
which is **sign-SGDM** — not SHB. The denominator $|g_t|$ destroys affine-equivariance, breaking $\nabla f_0(\lambda e_t) = \lambda\nabla\psi(e_t)$. Empirically diverges.

## What likely DOES transfer to Adam

The $\Omega(\sigma D/\sqrt T)$ variance LB from Le Cam two-point on the decoupled $y$-coordinate. The Le Cam argument depends only on:
- noise level $\sigma$ on the oracle
- wall structure $\alpha_s y + w(y)$
- the iterate's law under $s = \pm 1$

Adam preserves the linear shift structure of the gradient $\alpha_s + w'(y) + \xi_t$, modulo per-coord scaling. So a modified Le Cam argument should yield $\Omega(\sigma D/\sqrt T)$ for Adam too — but with a worse constant depending on $(\beta_1, \beta_2, \epsilon, \eta)$.

> **Conjecture (Adam variance LB).** For fixed $(\beta_1, \beta_2, \epsilon, \eta)$ with $\epsilon > 0$, there exists an $L$-smooth convex 1D problem and stochastic oracle of variance $\sigma^2$ such that the Adam last-iterate satisfies $\mathbb{E}[f(y_T) - f^\star] \geq c\,\sigma D/\sqrt T$ for some $c = c(\beta_1, \beta_2, \epsilon, \eta L) > 0$.

This is a separate theorem, not OP-2.

## Bottom line

OP-2's $\Omega(LD^2/T)$ bias lower bound is **algorithm-specific** to fixed-momentum SHB. The result does not extend to Adam/RMSProp because Adam's per-coordinate $\hat v_t$ scaling breaks (i) coord-wise homogeneity, (ii) initialization symmetry, and (iii) introduces unavoidable sign-SGD-magnitude transient at $t=1$. The variance LB likely transfers but is a separate proof.

**Practical implication for the paper:** Do NOT title OP-2 as "non-acceleration of fixed-hyperparameter momentum methods" or similar. The bias-term result is **specifically about SHB**.
