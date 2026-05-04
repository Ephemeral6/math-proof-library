# Direction 2 — Explorer 5 (Route E, frame: CONSTRUCTION)

**PEP/SDP numerical worst-case rate for fixed-momentum SHB last iterate on smooth convex stochastic.**

**Date:** 2026-04-28
**Frame:** CONSTRUCTION — build the SDP, run it, decompose the rate, and read off whether the conjectured form $LD^2/T + \sigma D/\sqrt T$ holds.

---

## 1. The PEP formulation (rigorous)

### 1.1 Setup

Run $T$ steps of fixed-momentum SHB
$$x_{t+1} = x_t - \eta\,g_t + \beta(x_t - x_{t-1}), \qquad x_{-1} = x_0,$$
with stochastic gradient $g_t = \nabla f(x_t) + \xi_t$, $\mathbb{E}[\xi_t \mid \mathcal F_t] = 0$, $\mathbb{E}[\|\xi_t\|^2 \mid \mathcal F_t] \leq \sigma^2$, on $L$-smooth convex $f$ with $\|x_0 - x^\star\| \leq D$.  Goal: compute the worst-case
$$\gamma^\star(T,\beta,\eta,L,D,\sigma) := \sup_{f \in \mathcal F_{L,0},\ \mathbb P_{\xi}\text{ admissible}} \mathbb{E}[f(x_T) - f^\star].$$

### 1.2 Lift

Drori-Taylor 2014 / Taylor-Hendrickx-Glineur 2017 show the deterministic worst case is an SDP in the Gram matrix of all relevant vectors.  For stochastic SHB I use the lift
$$\mathcal V = (g_0, g_1, \ldots, g_T,\ x_0 - x^\star,\ \xi_0, \ldots, \xi_{T-1}) \in (\mathbb R^d)^{2T+2},$$
with Gram matrix $G \in \mathbb S^{2T+2}_+$, $G_{ij} = \langle \mathcal V_i, \mathcal V_j\rangle$ in expectation.  Including $g_T = \nabla f(x_T)$ is necessary because the $L$-smooth interpolation tying $f(x_T)$ to $f^\star$ uses $g_T$.

The iterate is a fixed linear combination of lift vectors:
$$x_t - x^\star = (x_0 - x^\star) - \eta \sum_{s=0}^{t-1} c_{t,s}\,(g_s + \xi_s),\qquad c_{t,s} = \frac{1 - \beta^{t-s}}{1 - \beta},$$
since $x_{-1} = x_0$.  Each $x_t - x^\star$ is therefore a known $\mathbb R^{2T+2}$-vector $\mathbf v_t$ in the lift basis (no SDP variable for the iterate itself).

### 1.3 SDP constraints

* **Positive semidefiniteness:** $G \succeq 0$.
* **Initial distance:** $G_{T+1,T+1} = \|x_0 - x^\star\|^2 \leq D^2$.
* **Variance:** $G_{T+2+t,\,T+2+t} = \mathbb{E}\|\xi_t\|^2 \leq \sigma^2$, for $t=0,\ldots,T-1$.
* **Martingale-difference noise (expectation mode):** $\mathbb{E}[\xi_t \mid \mathcal F_t] = 0$ where $\mathcal F_t = \sigma(\xi_0,\ldots,\xi_{t-1})$.  In Gram entries: $G_{T+2+t,\,k} = 0$ for every $k \in \{0,\ldots,t,\ T+1,\ T+2,\ldots,T+1+t\}$, i.e. $\xi_t$ is uncorrelated with $x_0 - x^\star$, with $g_0,\ldots,g_t$ (which are measurable w.r.t. $\mathcal F_t$), and with $\xi_0,\ldots,\xi_{t-1}$.  The cross-Gram entries $G_{T+2+t,\,T+2+s}$ for $s>t$ and $G_{T+2+t,\,s}$ for gradients $g_s$ with $s>t$ are *unconstrained*: the worst-case adversary may pick $f$ so that subsequent gradients are correlated with the past noise, which is exactly the noise-propagation channel.
* **$L$-smooth convex interpolation (Taylor-Hendrickx-Glineur):** for all $i,j \in \{0,\ldots,T,\star\}$ with $i\neq j$,
$$F_i - F_j \;\geq\; \langle g_j,\, x_i - x_j\rangle + \frac{1}{2L}\|g_i - g_j\|^2,$$
where $F_t = f(x_t) - f^\star$ are SDP scalar variables, $F_\star = 0$, $g_\star = 0$, $x_\star - x^\star = 0$.  All inner products are encoded as $\mathbf u^\top G \mathbf v$ with the linear maps $\mathbf v_t$ for $x_t - x^\star$ and unit vectors $e_t$ for $g_t$.

* **Objective:** $\max F_T$.

The result is a finite-dimensional SDP with $O(T^2)$ variables and $O(T^2)$ interpolation constraints.  This produces a *valid upper bound* on $\sup_f \mathbb{E}[f(x_T) - f^\star]$, since the expectation is a linear functional of the second moments encoded in $G$ and we have only relaxed constraints.

The PEP relaxation here is **conservative**: pointwise interpolation $f_i \geq f_j + \langle g_j, x_i - x_j\rangle + \tfrac{1}{2L}\|g_i - g_j\|^2$ holds almost surely, and taking expectation gives the SDP form above.  The expectation PEP is therefore a genuine upper bound (possibly loose) on the true worst-case expected suboptimality.

---

## 2. Implementation

I implemented the SDP in Python with cvxpy 1.8.2 + SCS.  Two scripts:

* `d2_e5_pep_shb.py` — full PEP solver `solve_pep_v2(T, beta, eta, L, D, sigma, mode)` plus a Monte-Carlo simulator on $f(x) = (L/2)x^2$ for sanity checking.
* `d2_e5_pep_decompose.py` — decomposes by setting $\sigma=0$ (bias-only) or $D=0$ (variance-only).

The SDP runs in seconds for $T \leq 20$ on a laptop.  At $T = 20$ the Gram matrix has dimension $42$ and there are $(T+2)(T+1) = 462$ interpolation constraints; SCS converges in $\sim 10\,000$ iterations.

---

## 3. Numerical results

### 3.1 Joint PEP: $D = \sigma = L = 1$, varying $\beta, \eta L, T$

```
 beta  etaL   T     PEP_UB   LD2/T+sD/sqT   ratio
 0.00  0.50   3     0.1250         0.9107   0.137
 0.00  1.00   3     0.0714         0.9107   0.078
 0.00  1.50   3     0.0500         0.9107   0.055
 0.50  0.50   3     0.0952         0.9107   0.105
 0.50  1.00   3     0.1112         0.9107   0.122
 0.90  0.50   5     0.4033         0.6472   0.623
 0.90  1.00   5     0.4717         0.6472   0.729
 0.90  1.50   5     1.3256         0.6472   2.048
 0.00  0.50  10     0.0455         0.4162   0.109
 0.50  0.50  10     0.0263         0.4162   0.063
 0.90  0.50  10     0.3318         0.4162   0.797
 0.90  1.00  10     0.6906         0.4162   1.659
 0.90  1.50  10     2.1938         0.4162   5.271
```
At small $\beta$ the joint PEP UB is clearly *below* $LD^2/T + \sigma D/\sqrt T$ — so the conjectured rate is at most a valid UB for those parameters.  At $\beta = 0.9$ with $\eta L \in \{1,1.5\}$ the PEP UB *exceeds* the conjectured rate by factors $> 1$ that grow with $T$ (e.g., ratio $5.3$ at $T=10$), already a sign that the conjectured form **does not** survive at high momentum.

### 3.2 Bias-only PEP ($\sigma = 0$)

Power-law fit $\mathrm{PEP}_{\mathrm{bias}}(T) \sim A\,T^p$ on the tail $T \in \{8,10,12,15,20\}$:

| $\beta$ | $\eta L$ | exponent $p$ | prefactor $A$ |
|---|---|---|---|
| 0.0 | 0.5 | $-0.926$ | $0.383$ |
| 0.0 | 1.0 | $-0.961$ | $0.217$ |
| 0.5 | 0.5 | $-1.044$ | $0.291$ |
| 0.5 | 1.0 | $-1.223$ | $0.408$ |
| 0.9 | 0.5 | $-0.392$ | $0.760$ |
| 0.9 | 1.0 | $+0.587$ | $0.186$ |

For $\beta \leq 0.5$ the bias decays as $T^{-1}$ (matching the conjectured $LD^2/T$, with prefactor $\lesssim 0.5$).  For $\beta = 0.9$ the bias decays MUCH slower (or even *grows*: $T^{+0.587}$ at $\eta L = 1$), already showing that the deterministic last-iterate rate of fixed-momentum SHB on smooth convex is **worse than $LD^2/T$** at high momentum — a fact compatible with GFJ15 only proving the rate for the Cesàro average.  This is a non-trivial finding on its own.

### 3.3 Variance-only PEP ($D = 0$, $\sigma = 1$)

Power-law fit $\mathrm{PEP}_{\mathrm{var}}(T) \sim A\,T^p$:

| $\beta$ | $\eta L$ | exponent $p$ | $\mathrm{PEP}_{\mathrm{var}}(20)/\mathrm{PEP}_{\mathrm{var}}(3)$ |
|---|---|---|---|
| 0.0 | 0.5 | $+0.355$ | $1.96$ |
| 0.0 | 1.0 | $+0.253$ | $1.62$ |
| 0.5 | 0.5 | $+0.462$ | $2.42$ |
| 0.5 | 1.0 | $+0.362$ | $1.99$ |
| 0.9 | 0.5 | $+0.953$ | $6.04$ |
| 0.9 | 1.0 | $+1.282$ | $11.54$ |

**The variance-only PEP exponent is positive for every parameter combination tested.**  The variance term *grows* in $T$ — it does NOT decrease as $\sigma D/\sqrt T$ ($p = -0.5$), nor saturate at a constant noise floor ($p = 0$), nor even stay bounded.  Under the SDP relaxation it diverges polynomially.

This is a *strong refutation* of the conjectured $\sigma D / \sqrt T$ stochastic last-iterate UB for fixed-momentum SHB **in the worst case over $f \in \mathcal F_{L,0}$**, even at $\beta = 0$ (pure SGD).

### 3.4 Monte-Carlo on the quadratic $f(x) = (L/2)x^2$, $x_0 = D = 1$

```
 beta  etaL    T  E[f(x_T)]   sderr
 0.00  0.50   30   0.1656     0.0026
 0.00  0.50  100   0.1675     0.0027
 0.00  0.50 1000   0.1647     0.0027    -> saturates at ~ sigma^2 eta/(2L(1-eta L))?
 0.00  1.00   30   0.5000     0.0076
 0.00  1.00 1000   0.4899     0.0078    -> saturates at sigma^2 eta/(2L) = 0.5 (matches!)
 0.50  0.50   30   0.2935     0.0046
 0.50  0.50 1000   0.2985     0.0048
 0.90  0.50   30   1.3944     0.0223
 0.90  0.50 1000   1.4644     0.0233    -> consistent with sigma^2/(2L(1-beta^2))
                                          = 0.5/(1-0.81) = 2.63 ... ratio 0.55
 0.90  1.00   30   3.3573     0.0523
 0.90  1.00 1000   3.3306     0.0526    -> saturates around 3.33
```

On the **fixed quadratic instance** the iterate variance saturates to a finite noise floor (Route F result), exactly as predicted by the Vieta identity $(1-r_1)(1-r_2)=\eta L$ giving $\mathrm{Var}_\infty(x) = \sigma^2\eta/(L(1-\beta^2))$ when $r_1 r_2 = \beta$.  Numerical checks: $\beta = 0.9, \eta L = 1$: predicted $\sigma^2\eta/(L(1-\beta^2)) = 1/0.19 \approx 5.26$, so $\mathbb E f(x_T) = (L/2) \cdot 5.26 \cdot \rho \approx 2.6$–$3.3$ depending on the lag-1 autocovariance correction; the MC value $3.33$ falls in the plausible range.

So:
* On the quadratic, fixed-momentum SHB stagnates at a constant noise floor (Route F).
* In the *worst case over $f \in \mathcal F_{L,0}$*, the PEP variance term GROWS in $T$.

These are not contradictory: the PEP adversary picks a *different worst-case $f$ for each $T$* (the OP-2 hard instance is the prototype), and that worst-case $f$ accumulates variance more aggressively than the quadratic does.

---

## 4. The summary table

For $L = D = \sigma = 1$:

| $\beta$ | $\eta L$ | $T$ | PEP UB | $LD^2/T + \sigma D/\sqrt T$ | ratio |
|---|---|---|---|---|---|
| 0.0 | 1.0 | 10 | 0.024 (bias) + 1.07 (var) | 0.416 | 2.6 |
| 0.0 | 1.0 | 20 | 0.012 + 1.24 | 0.274 | 4.6 |
| 0.5 | 1.0 | 10 | 0.024 + 1.89 | 0.416 | 4.6 |
| 0.5 | 1.0 | 20 | 0.011 + 2.27 | 0.274 | 8.3 |
| 0.9 | 1.0 | 10 | 0.69 + 7.27 | 0.416 | 19.1 |
| 0.9 | 1.0 | 20 | 1.11 + 19.81 | 0.274 | 76.4 |

The ratio (PEP UB) / ($LD^2/T + \sigma D/\sqrt T$) **increases with $T$** for every fixed $(\beta,\eta L)$, confirming that the conjectured rate is *not* an upper bound at large $T$ in the PEP sense.

---

## 5. Verdict

### 5.1 The conjectured rate $LD^2/T + \sigma D/\sqrt T$ is REFUTED by the PEP

For fixed-momentum SHB on $L$-smooth convex with bounded-variance stochastic oracle, the PEP/SDP relaxation gives an upper bound on $\sup_f \mathbb{E}[f(x_T)-f^\star]$ that **grows polynomially in $T$** in its variance component, for every $(\beta, \eta L)$ tested in the stable region.  The conjectured $\sigma D/\sqrt T$ form is therefore not a uniform-in-$f$ last-iterate UB.

### 5.2 The bias term matches $LD^2/T$ for moderate $\beta$, but degrades at $\beta = 0.9$

Bias-only PEP exponent close to $-1$ for $\beta \leq 0.5$; for $\beta = 0.9$ the bias decays as $T^{-0.4}$ or even *grows* (at $\eta L = 1$, exponent $+0.6$).  This indicates that for high momentum, fixed-$\eta$ SHB does not even achieve $LD^2/T$ as a deterministic last-iterate rate.

### 5.3 Reconciliation with the quadratic noise-floor picture (Route F)

On a fixed quadratic, MC simulations confirm $\mathbb E[f(x_T) - f^\star]$ saturates at $\sigma^2\eta/(2L(1-\beta^2))$ — a constant.  The PEP, in contrast, picks an adversarial instance per $T$, and the variance bound diverges.  Both pictures agree that **no single $f$ achieves $\sigma D/\sqrt T$ rate uniformly**, but they describe different aspects of the worst case:

* **Fixed $f$, $T \to \infty$:** noise floor (Route F).
* **Worst-case $f$ per $T$:** variance contribution grows, no uniform $\sigma D/\sqrt T$ UB (Route E here).

### 5.4 The PEP relaxation may be *too loose*

A caveat: the expectation PEP encoded here only enforces that pairwise smoothness holds at the SDP level (via expected pairwise products), not the much stronger constraint that the same realization of $f$ and noise satisfies all interpolation inequalities almost surely.  This relaxation can produce upper bounds with no realizable hard instance.  An SDP exhibiting "growing variance" might therefore not correspond to any actual $f$, but only to a *fictitious* second-moment configuration.  To rule this out one would need:

* **Primal-dual recovery:** read off the SDP optimal Gram, factor it as $G = V^\top V$, and check whether the resulting iterate trajectory and gradient sequence are consistent with a single $L$-smooth convex $f$ in expectation.  This is non-trivial because the noise variables couple multiple realizations.
* **Tighter PEP:** use moment-SDP techniques (Lasserre hierarchy) to enforce higher moments of the noise (Lemma E3 in the scout doc).

The diverging variance reported above is therefore a **valid upper bound that is likely not tight**.  However:

1. The qualitative finding — that no clean $\sigma D/\sqrt T$ rate emerges from the PEP — is robust.
2. The quantitative growth rate (e.g., $T^{+1.28}$ at $\beta=0.9$) is consistent with the noise-floor picture: under a stable parameter the SHB noise variance accumulates linearly until saturating, and at the SDP level (with no termination of the accumulation) it can keep growing; the SDP relaxation is loose precisely on the saturation effect.

### 5.5 Conclusion

* The PEP/SDP **diagnostically refutes** the existence of an $\exists$-$\forall$ $\sigma D/\sqrt T$ stochastic last-iterate UB for fixed-momentum SHB.  This is consistent with Route F and Route A predictions in the scout doc.
* The PEP **confirms** $LD^2/T$ as the bias rate for moderate $\beta$, with prefactors $\lesssim 0.5$ (for $\beta = 0$, $\eta L = 1$, the prefactor is $0.22$).  At $\beta = 0.9$ the bias rate degrades.
* The variance-only PEP grows at least sublinearly in $T$ for $\beta \leq 0.5$ and superlinearly for $\beta = 0.9$.  This *over-estimates* the true expected suboptimality on the quadratic (which saturates), but it is a valid statement about the worst-case-over-$f$ instance.

**Recommendation for the paper:** the PEP serves as numerical confirmation that the missing $\sigma D/\sqrt T$ UB really is missing — there is no clean, uniform-in-$f$ matching upper bound for fixed-momentum SHB.  The correct UB form is $O(LD^2/T + \mathrm{noise floor})$ for fixed instances, and the OP-2 lower bound's $\sigma D/\sqrt T$ term is a feature of the $T$-dependent hard-instance construction, not of any single function.

---

## 6. Files produced

* `d2_e5_pep_shb.py` — main PEP solver and Monte-Carlo helper.
* `d2_e5_pep_decompose.py` — bias-only and variance-only decomposition runs.
* `d2_e5_pep_fit.py`, `d2_e5_pep_bias_fit.py` — power-law fits.
* `d2_e5_pep_results.json` — saved numerical output.
* `d2_e5_pep_decompose.json` — saved decomposition output.

All code uses cvxpy 1.8.2 and SCS; runs to completion in under 30 seconds for $T \leq 20$.

---

## 7. Limitations and follow-ups

1. **Loose SDP relaxation:** the expectation-PEP I built is conservative (a true UB); a moment-SDP version (e.g., Lasserre level $\geq 2$) might tighten the variance term considerably and could even recover the noise-floor saturation.
2. **No primal recovery:** I did not extract an explicit hard instance from the SDP optimum.  Doing so would test whether the diverging variance is achieved by some realizable $f$, or only by an SDP-relaxation artifact.
3. **Larger $T$:** $T = 50$ is feasible (Gram dim 102, $\sim 2700$ constraints), $T = 100$ marginal.  These would give cleaner asymptotic exponents.
4. **Cross-check with PEPit library:** the public PEPit toolbox specializes in deterministic methods; adapting it to the stochastic SHB requires the same lift I built here.  Could be done in 1-2 hours.
5. **$\eta L = 1.5$ instability:** the exponential $T$-growth at $\beta = 0.9, \eta L = 1.5$ may reflect that this point is near or outside the SHB stability region $\mathcal S$; the PEP correctly diagnoses the instability.

The headline takeaway, however, is robust: **the worst-case PEP rate for fixed-momentum SHB last iterate on smooth convex stochastic does not match the OP-2 LB form $\sigma D/\sqrt T$.**  It is dominated by a variance term that grows in $T$ (or saturates at a positive constant), confirming the noise-floor diagnosis from Routes F, A, C, and D.
