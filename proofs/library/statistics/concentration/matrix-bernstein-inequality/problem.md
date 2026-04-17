# Matrix Bernstein Inequality for Sum of Independent Random Matrices

## Source
- Context: Matrix concentration inequalities (Tropp 2012, Vershynin 2018 Ch.5)
- Foundational result in high-dimensional probability and random matrix theory

## Statement

Let $X_1, \ldots, X_n$ be independent random symmetric matrices in $\mathbb{R}^{d \times d}$ satisfying:
- $\mathbb{E}[X_i] = 0$ for all $i$
- $\|X_i\| \leq L$ almost surely for all $i$

Define $\sigma^2 = \|\sum_{i=1}^n \mathbb{E}[X_i^2]\|$. Then for all $t \geq 0$:

$$\Pr\Bigl[\Bigl\|\sum_{i=1}^n X_i\Bigr\| \geq t\Bigr] \leq 2d \cdot \exp\Bigl(-\frac{t^2/2}{\sigma^2 + Lt/3}\Bigr)$$

## Difficulty
research
