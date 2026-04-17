# Proof Report: Johnson-Lindenstrauss Lemma

## 1. Problem Statement

**Theorem (Johnson-Lindenstrauss).** For any $0 < \varepsilon < 1$ and any finite set $\mathcal{X} \subset \mathbb{R}^d$ of $n$ points, there exists a map $f: \mathbb{R}^d \to \mathbb{R}^k$ with $k = O(\log n / \varepsilon^2)$ such that for all $u, v \in \mathcal{X}$:

$$(1 - \varepsilon)\|u - v\|_2^2 \le \|f(u) - f(v)\|_2^2 \le (1 + \varepsilon)\|u - v\|_2^2.$$

The map $f(x) = \frac{1}{\sqrt{k}} A x$ with i.i.d. $N(0,1)$ entries works with probability $\ge 1 - 1/n$.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed |
| Explorer | Opus | 4 proofs attempted, 4 succeeded |
| Judge | Sonnet | Route 1 selected (score: 36/40) |
| Audit | Opus | PASS (1 round, 0 INVALID steps, 4 LOW issues) |
| Fix | — | Not needed |

## 3. Proof Routes Explored

1. **Sub-Gaussian MGF + Union Bound** (36/40) — Classical approach via χ² MGF and Chernoff. Tightest constant k ≥ 36 ln(n)/ε². **Selected.**
2. **Gaussian Concentration / Lipschitz** (27/40) — Via TIS inequality on ‖Ax‖ with Lipschitz constant 1. Requires norm-to-squared-norm transfer. Constant k ≥ 96 ln(n)/ε².
3. **Sub-Exponential / Bernstein** (30/40) — Centers χ² as sub-exponential, applies Bernstein. Same constant as Route 1 but heavier framework.
4. **Rademacher / Achlioptas** (29/40) — Replaces Gaussians with ±1 Rademacher variables. Uses cosh ≤ exp(s²/2). Constant k ≥ 48 ln(n)/ε².

## 4. Final Proof

### Step 1: Reduction to a fixed unit vector via Gaussian rotational invariance

Let $u, v \in X$. Define $w = u - v$. Since $f(x) = \frac{1}{\sqrt{k}}Ax$, we have $f(u) - f(v) = \frac{1}{\sqrt{k}}Aw$, so $\|f(u)-f(v)\|^2 = \frac{1}{k}\|Aw\|^2$.

Write $w = \|w\| \cdot x$ where $x = w/\|w\|$ is a unit vector. Then $\|Aw\|^2 = \|w\|^2 \cdot \|Ax\|^2$, and the JL condition is equivalent to:

$$1-\varepsilon \le \frac{\|Ax\|^2}{k} \le 1+\varepsilon. \tag{*}$$

Since $A$ has i.i.d. $N(0,1)$ entries and $x$ is a fixed unit vector, $(Ax)_i = \sum_j A_{ij} x_j \sim N(0,1)$ independently. So $Y := \|Ax\|^2 \sim \chi^2(k)$.

It suffices to show $\Pr[|Y/k - 1| > \varepsilon] \le 2/n^3$, because then a union bound over $\binom{n}{2} \le n^2/2$ pairs gives failure probability $\le 1/n$.

### Step 2: MGF of the chi-squared distribution

For $Z \sim N(0,1)$ and $t < 1/2$:

$$\mathbb{E}[e^{tZ^2}] = (1-2t)^{-1/2}.$$

By independence: $\mathbb{E}[e^{tY}] = (1-2t)^{-k/2}$ for $t < 1/2$.

### Step 3: Upper tail bound

By Chernoff: for $t^* = \varepsilon/(2(1+\varepsilon)) \in (0, 1/2)$:

$$\Pr[Y \ge k(1+\varepsilon)] \le [(1+\varepsilon)e^{-\varepsilon}]^{k/2}.$$

Using $\ln(1+\varepsilon) \le \varepsilon - \varepsilon^2/2 + \varepsilon^3/3$ (alternating series truncation) and $\varepsilon^3/3 < \varepsilon^2/3$ for $\varepsilon < 1$:

$$\ln(1+\varepsilon) - \varepsilon \le -\varepsilon^2/6.$$

Thus: $\Pr[Y \ge k(1+\varepsilon)] \le e^{-k\varepsilon^2/12}$.

### Step 4: Lower tail bound

For $\mu^* = \varepsilon/(2(1-\varepsilon))$:

$$\Pr[Y \le k(1-\varepsilon)] \le [(1-\varepsilon)e^{\varepsilon}]^{k/2}.$$

Using $\ln(1-\varepsilon) \le -\varepsilon - \varepsilon^2/2$:

$$\ln(1-\varepsilon) + \varepsilon \le -\varepsilon^2/2.$$

Thus: $\Pr[Y \le k(1-\varepsilon)] \le e^{-k\varepsilon^2/4}$.

### Step 5: Two-sided bound

$$\Pr\left[\left|\frac{Y}{k} - 1\right| > \varepsilon\right] \le e^{-k\varepsilon^2/12} + e^{-k\varepsilon^2/4} \le 2e^{-k\varepsilon^2/12}.$$

### Step 6: Union bound

Setting $2e^{-k\varepsilon^2/12} \le 2/n^3$ and multiplying by $\binom{n}{2} \le n^2/2$:

$$k \ge \frac{36\ln n}{\varepsilon^2}.$$

### Step 7: Conclusion

Choose $k = \lceil 36\ln n / \varepsilon^2 \rceil = O(\log n / \varepsilon^2)$. With probability $\ge 1 - 1/n$, all pairs satisfy the JL condition. **Q.E.D.** $\blacksquare$

## 5. Audit Result

**PASS** — All 7 steps marked VALID. Four LOW-severity presentation issues identified (constant tracking, compressed justifications), no mathematical errors.

## 6. Fix History

No fixes needed — proof passed audit on first round.
