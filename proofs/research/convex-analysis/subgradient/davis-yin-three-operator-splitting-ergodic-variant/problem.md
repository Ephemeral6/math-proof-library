# Davis-Yin Three-Operator Splitting: Ergodic O(1/K) Rate

## Source
- **Paper**: Damek Davis & Wotao Yin, *"A Three-Operator Splitting Scheme and its Optimization Applications"*, Set-Valued and Variational Analysis / SIAM J. Optim. 2017.
- **Context**: Generalizes Douglas-Rachford splitting to three operators, enabling solution of $\min_x f(x) + g(x) + h(x)$ where $f,g$ have easy proximal operators and $h$ is smooth.

## Target Statement (ORIG — not fully proved here)

Let $(\mathcal{H}, \langle\cdot,\cdot\rangle)$ be a real Hilbert space. Consider
$$\min_{x\in\mathcal H}\; F(x) := f(x) + g(x) + h(x)$$
under:
- (A1) $f:\mathcal H\to\mathbb R\cup\{+\infty\}$ proper closed convex
- (A2) $g:\mathcal H\to\mathbb R\cup\{+\infty\}$ proper closed convex
- (A3) $h:\mathcal H\to\mathbb R$ convex, $\beta$-smooth
- (A4) $X^*:=\arg\min F\ne\emptyset$; $\exists x^*\in X^*,\;u^*\in\partial f(x^*),\;v^*\in\partial g(x^*)$ with $u^*+v^*+\nabla h(x^*)=0$

For $\gamma\in(0,2/\beta)$, $z^0\in\mathcal H$, the **DYS iteration** is
$$
y^k = \mathrm{prox}_{\gamma g}(z^k),\quad
x^k = \mathrm{prox}_{\gamma f}(2y^k - z^k - \gamma\nabla h(y^k)),\quad
z^{k+1} = z^k + x^k - y^k.
$$

Let $\bar x^K := \frac{1}{K}\sum_{k=0}^{K-1} x^k$, $\alpha := 2-\gamma\beta\in(0,2)$. Claim:
$$F(\bar x^K)-F(x^*) \le \frac{\|z^0-z^*\|^2}{2\gamma\alpha K}$$
where $z^*$ is a fixed point of the DYS operator.

## Proved Statement (VAR — the actual content of proof.md)

The archived proof establishes a rigorous **variant** for the restricted regime $\gamma\in(0,1/\beta]$:
$$\widetilde F(\bar x^K,\bar y^K) - F(x^*) \le \frac{\|z^0-x^*\|^2}{2\gamma K}$$
where $\widetilde F(\bar x^K,\bar y^K) := f(\bar x^K)+g(\bar y^K)+h(\bar x^K)$ and $\bar y^K := \frac1K\sum_{k=0}^{K-1} y^k$.

## Discrepancies (VAR vs ORIG)

| Aspect | ORIG | VAR |
|---|---|---|
| Objective | $F(\bar x^K)$ | $\widetilde F(\bar x^K, \bar y^K)$ |
| Initial norm | $\|z^0 - z^*\|^2$ | $\|z^0 - x^*\|^2$ |
| Step size range | $\gamma\in(0,2/\beta)$ | $\gamma\in(0,1/\beta]$ |
| Leading constant | $1/(2\gamma\alpha)$ | $1/(2\gamma)$ |

All four gaps require Davis-Yin's averagedness machinery (Prop 2.1 + Thm 3.1 in the original paper) to close, which is outside the scope of the purely local algebraic framework used in the archived proof.

## Difficulty
**research**
