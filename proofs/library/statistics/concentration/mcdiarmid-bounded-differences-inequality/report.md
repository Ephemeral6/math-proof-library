# Proof Report: McDiarmid's Bounded Differences Inequality

## 1. Problem Statement

**Theorem (McDiarmid).** Let $X_1, \ldots, X_n$ be independent random variables taking values in $\mathcal{X}$, and let $f: \mathcal{X}^n \to \mathbb{R}$ satisfy the bounded differences condition with constants $c_1, \ldots, c_n$. Then for all $t > 0$:

$$\Pr[f(X) - \mathbb{E}[f(X)] \geq t] \leq \exp\!\left(-\frac{2t^2}{\sum_{i=1}^n c_i^2}\right).$$

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed |
| Explorer | Opus | 4 proofs attempted, 4 succeeded |
| Judge | Sonnet | Route 4 (Exponential Supermartingale) selected (score: 27/40) |
| Audit | Opus | PASS (1 round, 0 issues HIGH/MEDIUM) |
| Fix | — | Not needed |

## 3. Proof Routes Explored

1. **Doob Martingale + Azuma-Hoeffding** (23/40): Standard canonical route. Complete but had a constant self-correction.
2. **Direct MGF Peeling** (25/40): Clean iterative conditioning approach, well-executed.
3. **Entropy / Log-Sobolev** (25/40): Most intellectually rich route via tensorization + Herbst argument.
4. **Exponential Supermartingale** (27/40): Winner. Clean supermartingale framework with exact cancellation.

## 4. Final Proof

**Phase 1: Doob Martingale.** $Z_k = \mathbb{E}[f(X) \mid X_1, \ldots, X_k]$ is a martingale with $Z_0 = \mathbb{E}[f]$, $Z_n = f(X)$. Differences $D_k = Z_k - Z_{k-1}$ satisfy $\mathbb{E}[D_k \mid \mathcal{F}_{k-1}] = 0$.

**Phase 2: Bounded Differences.** Via $g_k(x_1,\ldots,x_k) = \mathbb{E}[f(x_1,\ldots,x_k,X_{k+1},\ldots,X_n)]$, each $D_k$ lies in an interval of length $\leq c_k$ given $\mathcal{F}_{k-1}$.

**Phase 3: Hoeffding's Lemma.** For centered $Y \in [a,b]$: $\mathbb{E}[e^{sY}] \leq \exp(s^2(b-a)^2/8)$. Proved via convexity + $\varphi''(h) = q(1-q) \leq 1/4$.

**Phase 4: Supermartingale.** $M_k = \exp(\lambda Z_k - \frac{\lambda^2}{8}\sum_{j \leq k} c_j^2)$ is a supermartingale by Hoeffding's lemma (exact cancellation).

**Phase 5: Optimize.** $\mathbb{E}[e^{\lambda(F-\mu)}] \leq \exp(\lambda^2 C/8)$. Chernoff + $\lambda^* = 4t/C$ yields $\exp(-2t^2/C)$. $\blacksquare$

## 5. Audit Result

PASS on first round. All 5 steps VALID. Only 4 LOW-severity presentational issues (notation, implicit assumptions). No mathematical errors.

## 6. Fix History

No fixes needed.
