# McDiarmid's Bounded Differences Inequality

## Source
- Paper: McDiarmid 1989
- Context: Fundamental concentration inequality for functions of independent random variables satisfying bounded differences condition. Extends Azuma-Hoeffding from martingales to general Lipschitz-like functions on product spaces.

## Statement

**Theorem.** Let $X_1, X_2, \ldots, X_n$ be independent random variables taking values in a set $\mathcal{X}$, and let $f: \mathcal{X}^n \to \mathbb{R}$ be a measurable function satisfying the bounded differences condition: for each $i \in \{1, \ldots, n\}$, there exists $c_i \geq 0$ such that

$$\sup_{x_1, \ldots, x_n, x_i'} \left| f(x_1, \ldots, x_i, \ldots, x_n) - f(x_1, \ldots, x_i', \ldots, x_n) \right| \leq c_i.$$

Then for all $t > 0$:

$$\Pr\left[ f(X_1, \ldots, X_n) - \mathbb{E}[f(X_1, \ldots, X_n)] \geq t \right] \leq \exp\left( -\frac{2t^2}{\sum_{i=1}^n c_i^2} \right).$$

## Difficulty
research
