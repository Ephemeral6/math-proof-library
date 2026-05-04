# Fragment: beta-binomial-duality

## Statement
For non-negative integers $s, f$ and $y \in [0, 1]$:
$$\Pr\bigl(\mathrm{Beta}(s+1, f+1) \le y\bigr) \;=\; \Pr\bigl(\mathrm{Binom}(s+f+1, y) \ge s+1\bigr).$$
Equivalently:
$$\Pr\bigl(\mathrm{Beta}(s+1, f+1) > y\bigr) \;=\; \Pr\bigl(\mathrm{Binom}(s+f+1, y) \le s\bigr).$$

## Proof
Let $n = s + f + 1$. The incomplete Beta function is $I_y(s+1, f+1) = \frac{1}{B(s+1, f+1)}\int_0^y u^s (1-u)^f du$. Differentiate both sides of the claimed identity in $y$:
- LHS derivative: $\frac{y^s (1-y)^f}{B(s+1, f+1)} = n \binom{n-1}{s} y^s (1-y)^{n-1-s}$.
- RHS derivative: $\sum_{j=s+1}^n [j \binom{n}{j} y^{j-1}(1-y)^{n-j} - (n-j)\binom{n}{j} y^j (1-y)^{n-j-1}]$. Using $j\binom{n}{j} = n\binom{n-1}{j-1}$ and $(n-j)\binom{n}{j} = n\binom{n-1}{j}$, the sum telescopes to $n\binom{n-1}{s} y^s (1-y)^{n-1-s}$.

The derivatives match, both sides are $0$ at $y = 0$ and $1$ at $y = 1$, so they agree on $[0, 1]$. $\square$

**Corollary** (Beta concentration via Hoeffding): for any $\varepsilon > 0$ and $n = s + f \ge 1$,
$$\Pr\bigl(\mathrm{Beta}(s+1, f+1) \ge s/n + \varepsilon\bigr) \le \exp(-n\varepsilon^2),$$
$$\Pr\bigl(\mathrm{Beta}(s+1, f+1) \le s/n - \varepsilon\bigr) \le \exp(-n\varepsilon^2).$$
(Apply duality, then Hoeffding to the binomial.)

## Source
- `proofs/research/learning-theory/generalization/thompson-sampling-bernoulli-regret/proof.md` — Lemma 1.1 and 2.1.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (foundational for Thompson Sampling regret)
- **Potential applications**:
  - Thompson Sampling regret analysis (Bernoulli rewards)
  - Bayesian credible-interval bounds for binomial parameters
  - Conjugate-prior Bayesian bandits
  - Translating between order-statistic identities (used e.g. in PAC-Bayes for Bernoulli losses)
  - Rank-based concentration bounds

## Tags
beta-binomial, duality, thompson-sampling, concentration, bayesian
