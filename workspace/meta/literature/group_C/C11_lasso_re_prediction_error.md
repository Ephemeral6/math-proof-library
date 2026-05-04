# C11 — LASSO RE prediction error

**Path**: `proofs/research/statistics/high-dimensional/lasso-re-prediction-error/`
**Verdict**: **MATCH (Bickel-Ritov-Tsybakov 2009, canonical bound)**

## Our statement
For LASSO $\hat\beta = \arg\min_\beta (1/2n)\|y - X\beta\|_2^2 + \lambda\|\beta\|_1$ with $y = X\beta^* + w$, $w \sim \mathcal{N}(0, \sigma^2 I_n)$, normalized columns $\|X_j\|_2 \le \sqrt n$:

On the event $\mathcal{E} = \{(1/n)\|X^\top w\|_\infty \le \lambda/2\}$ (which has probability $\ge 1 - 2/p$ for $\lambda = 2\sigma\sqrt{2\log p / n}$):

1. $\hat\Delta := \hat\beta - \beta^* \in \mathcal{C}(S, 3) = \{\Delta : \|\Delta_{S^c}\|_1 \le 3\|\Delta_S\|_1\}$.
2. Under restricted eigenvalue (RE) condition $\kappa^2 := \min_{\Delta\in\mathcal{C}(S,3)} (1/n)\|X\Delta\|_2^2/\|\Delta_S\|_2^2 > 0$, the prediction error satisfies
$$
\frac{1}{n}\|X(\hat\beta - \beta^*)\|_2^2 \le \frac{9\lambda^2 s}{\kappa^2}.
$$

## Literature

### Bickel-Ritov-Tsybakov 2009 (Ann. Stat., arXiv:0801.1095) — "Simultaneous analysis of Lasso and Dantzig selector"
- **Main theorem (Theorem 7.1 + 7.2)**: Under RE($s, 3$), with $\lambda \asymp \sigma\sqrt{\log p/n}$:
$$
\frac{1}{n}\|X(\hat\beta - \beta^*)\|^2 \lesssim \frac{\sigma^2 s \log p}{n \kappa^2}, \quad \|\hat\beta - \beta^*\|_1 \lesssim \frac{\sigma s\sqrt{\log p/n}}{\kappa^2}.
$$
- The exact constant 9 (or 16 in BRT) depends on the cone constant (3 here, vs 1+c in BRT for Dantzig).

### Wainwright 2019 textbook ("High-Dimensional Statistics", Ch. 7)
- Standard reference for the "9$\lambda^2 s/\kappa^2$" form of the prediction error bound.

### Bühlmann-van de Geer 2011 (book)
- Same bound; constant may differ slightly depending on RE definition.

## Comparison

| Aspect | BRT 2009 | OUR C11 |
|---|---|---|
| Cone | $\mathcal{C}(S, c_0)$ where $c_0 = (1-\eta)/(1+\eta)$ | $\mathcal{C}(S, 3)$ |
| RE constant | $\kappa(s, c_0)$ | $\kappa$ (with $c_0 = 3$) |
| Prediction error | $C\sigma^2 s\log p/(n\kappa^2)$ | $9\lambda^2 s/\kappa^2 = 9\cdot 8\sigma^2 s\log p/(n\kappa^2)$ |
| Probability | $1 - O(p^{-c})$ | $1 - 2/p$ |
| Choice of $\lambda$ | $A\sigma\sqrt{\log p/n}$, $A > 2\sqrt 2$ | $\lambda = 2\sigma\sqrt{2\log p/n}$ |

The cone $\mathcal{C}(S, 3)$ corresponds to BRT's $c_0 = 3$ (which arises from the basic-inequality argument with $\lambda \ge 2\|X^Tw\|_\infty/n$). This matches Wainwright Chapter 7 exactly.

## Verdict

**MATCH.** Faithful reproduction of the canonical Bickel-Ritov-Tsybakov 2009 / Wainwright Ch.7 LASSO prediction error bound under RE. The proof:

1. **Step 1**: Basic inequality from optimality of $\hat\beta$ → $\frac{1}{2n}\|X\hat\Delta\|^2 \le \frac{1}{n}\|X^Tw\|_\infty\|\hat\Delta\|_1 + \lambda(\|\beta^*\|_1 - \|\hat\beta\|_1)$.
2. **Step 2**: On event $\mathcal{E} = \{\|X^Tw\|_\infty/n \le \lambda/2\}$, derive cone $\hat\Delta \in \mathcal{C}(S, 3)$.
3. **Step 3**: Sub-Gaussian maximal inequality → $\Pr(\mathcal{E}) \ge 1 - 2/p$ for $\lambda = 2\sigma\sqrt{2\log p/n}$ (with the union bound calculation worked through carefully — the proof file shows multiple rounds of getting the constant right).
4. **Final**: RE inequality $\|X\Delta\|^2/n \ge \kappa^2\|\Delta_S\|^2$ + Cauchy-Schwarz $\|\Delta_S\|_1 \le \sqrt s\|\Delta_S\|_2$ → bound.

No discrepancy. This is a B-class textbook reproduction of a foundational result. The constant 9 = $(3/(\kappa))^2$ matches the standard Wainwright-style form.
