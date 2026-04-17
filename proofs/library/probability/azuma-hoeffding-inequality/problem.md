# Azuma-Hoeffding Inequality

## Source
- Paper: Azuma 1967; Hoeffding 1963
- Context: Extension of Hoeffding's inequality to martingale difference sequences. Fundamental concentration inequality for martingales with bounded differences.

## Statement

**Theorem (Azuma-Hoeffding).** Let $(M_k)_{k=0}^n$ be a martingale with respect to filtration $(\mathcal{F}_k)$ such that the differences are bounded:

$$|M_k - M_{k-1}| \leq c_k \quad \text{a.s.}, \quad k = 1, \ldots, n$$

for constants $c_1, \ldots, c_n > 0$. Then for all $t > 0$:

$$P(M_n - M_0 \geq t) \leq \exp\left(-\frac{t^2}{2\sum_{k=1}^n c_k^2}\right).$$

By symmetry (applying to $-M$):

$$P(|M_n - M_0| \geq t) \leq 2\exp\left(-\frac{t^2}{2\sum_{k=1}^n c_k^2}\right).$$

## Difficulty
research
