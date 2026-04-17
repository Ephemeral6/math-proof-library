# Bernstein's Inequality for Bounded Random Variables

## Source
- Paper: Bernstein 1924; Boucheron, Lugosi, Massart "Concentration Inequalities" 2013
- Context: Classical concentration inequality interpolating between sub-Gaussian (small t) and sub-exponential (large t) tail behavior for sums of independent bounded mean-zero random variables

## Statement

**Theorem (Bernstein's Inequality).** Let $X_1, \ldots, X_n$ be independent random variables with $\mathbb{E}[X_i] = 0$ and $|X_i| \leq M$ almost surely for all $i$. Let $V = \sum_{i=1}^n \mathbb{E}[X_i^2]$. Then for all $t > 0$,

$$P\!\left(\sum_{i=1}^n X_i > t\right) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right).$$

## Difficulty
research
