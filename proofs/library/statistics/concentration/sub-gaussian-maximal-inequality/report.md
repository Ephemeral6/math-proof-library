# Final Report: Sub-Gaussian Maximal Inequality

## Status: PASS

## Problem Statement

Let $X_1, \ldots, X_n$ be sub-Gaussian with parameter $\sigma$ (i.e., $\mathbb{E}[e^{\lambda X_i}] \leq e^{\lambda^2\sigma^2/2}$ for all $\lambda \in \mathbb{R}$). Prove:

1. $P(\max_{1\leq i\leq n} X_i > t) \leq n\exp(-t^2/(2\sigma^2))$ for all $t > 0$.
2. $\mathbb{E}[\max_{1\leq i\leq n} X_i] \leq \sigma\sqrt{2\log n}$.

Source: Vershynin 2018 (HDP Ch.2); Boucheron et al. 2013. Difficulty: research.

---

## Routes Explored

| Route | Method | Part (a) | Part (b) | Exact Constants |
|-------|--------|----------|----------|-----------------|
| 1 | Union bound + Chernoff + Log-sum-exp/Jensen | ✓ | ✓ | ✓ |
| 2 | Tail integration | ✓ | Weaker bound | ✗ |
| 3 | Orlicz $\psi_2$ norm | ✓ | Up to constants | ✗ |

**Winner: Route 1.**

---

## Proof Summary (Route 1)

### Part (a): Tail Bound
1. **Union bound**: $P(\max_i X_i > t) \leq \sum_i P(X_i > t)$.
2. **Chernoff bound**: For each $i$, $P(X_i > t) \leq \inf_{\lambda > 0} e^{\lambda^2\sigma^2/2 - \lambda t}$.
3. **Optimize** at $\lambda^* = t/\sigma^2$: $P(X_i > t) \leq e^{-t^2/(2\sigma^2)}$.
4. **Sum**: $P(\max_i X_i > t) \leq ne^{-t^2/(2\sigma^2)}$.

### Part (b): Expectation Bound
1. **Log-sum-exp**: $\max_i X_i \leq \frac{1}{\lambda}\log\sum_i e^{\lambda X_i}$ (pointwise).
2. **Jensen**: $\mathbb{E}[\log\sum_i e^{\lambda X_i}] \leq \log\sum_i \mathbb{E}[e^{\lambda X_i}]$.
3. **MGF bound**: $\leq \log(ne^{\lambda^2\sigma^2/2}) = \log n + \lambda^2\sigma^2/2$.
4. **Divide by $\lambda$**: $\mathbb{E}[\max_i X_i] \leq \frac{\log n}{\lambda} + \frac{\lambda\sigma^2}{2}$.
5. **Optimize** at $\lambda^* = \sqrt{2\log n}/\sigma$: bound $= \sigma\sqrt{2\log n}$.

### Key Features
- **No independence required.** Only individual sub-Gaussian MGF conditions are used.
- **Exact constants.** The constant $\sqrt{2}$ is tight (achieved by i.i.d. Gaussians).
- **Elementary tools.** Only uses Markov's inequality, Jensen's inequality, and calculus optimization.

---

## Audit Result

**Round 1: PASS.** Every step verified line by line. No errors, gaps, or unjustified assumptions found. Optimization algebra double-checked. Edge case $n=1$ verified. Jensen direction confirmed correct (concavity of $\log$).

---

## Failed Routes

- **Route 2** (tail integration): Achieves $\sigma\sqrt{2\log n} + \sigma/\sqrt{2\log n}$, strictly weaker than stated bound.
- **Route 3** (Orlicz norm): Only achieves $C\sigma\sqrt{\log n}$ with unspecified constant $C$.

Both routes successfully prove Part (a) but fail to achieve the exact constant in Part (b).

---

## Final Verdict: **PASS**

The proof is complete, rigorous, and achieves both stated bounds with exact constants.
