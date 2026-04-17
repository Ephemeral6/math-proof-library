# Hoeffding's Inequality

## Source
- Paper: Hoeffding 1963, "Probability Inequalities for Sums of Bounded Random Variables"
- Context: Fundamental concentration inequality for sums of bounded independent random variables, widely used in learning theory, statistics, and probability

## Statement

**Theorem (Hoeffding's Inequality).** Let $X_1, \ldots, X_n$ be independent random variables with $X_i \in [a_i, b_i]$ almost surely. Let $S_n = \sum_{i=1}^n X_i$. Then for all $t > 0$:

$$P(S_n - \mathbb{E}[S_n] \geq t) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n (b_i - a_i)^2}\right).$$

**Corollary.** If $X_1, \ldots, X_n$ are i.i.d. with $X_i \in [a, b]$, then:

$$P\left(\bar{X}_n - \mathbb{E}[\bar{X}_n] \geq t\right) \leq \exp\left(-\frac{2nt^2}{(b-a)^2}\right).$$

## Difficulty
research
