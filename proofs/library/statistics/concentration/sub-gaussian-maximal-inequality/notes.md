# Notes: Sub-Gaussian Maximal Inequality

## Proof technique
The winning route uses the **union bound + Chernoff method** for the tail bound and the **log-sum-exp trick + Jensen's inequality** for the expectation bound. This is the standard textbook approach and the only one among three routes that achieves the exact stated constants.

## Key steps
1. **Part (a):** The Chernoff bound $P(X_i > t) \leq \inf_{\lambda>0} e^{\lambda^2\sigma^2/2 - \lambda t}$ with optimal $\lambda = t/\sigma^2$ reduces each individual tail to $e^{-t^2/(2\sigma^2)}$. The union bound then gives the factor of $n$.
2. **Part (b):** The crucial insight is the pointwise inequality $\max_i a_i \leq \frac{1}{\lambda}\log\sum_i e^{\lambda a_i}$, which "softens" the max into a smooth function amenable to expectation bounds. Jensen's inequality (concavity of log) then separates the expectation from the sum, allowing individual MGF bounds. The AM-GM-like optimization $\frac{\log n}{\lambda} + \frac{\lambda\sigma^2}{2} \geq 2\sqrt{\frac{\sigma^2\log n}{2}} = \sigma\sqrt{2\log n}$ gives the tight constant.

## Audit result
**PASS** in Round 1. Every algebraic step verified, including the optimization calculation and edge case $n=1$. Jensen direction confirmed correct. No independence assumption needed.

## Related results
- **Hoeffding's inequality**: Uses similar Chernoff/MGF technique for bounded random variables. Already in library at `proofs/statistics/concentration/hoeffding-inequality/`.
- **Bernstein's inequality**: Related concentration bound using variance information. Already at `proofs/statistics/concentration/bernstein-inequality/`.
- **Sub-Gaussian covariance concentration**: Uses sub-Gaussian tail bounds as input. Already at `proofs/statistics/concentration/sub-gaussian-covariance-concentration/`.
- **McDiarmid's inequality**: Bounded differences concentration, related technique. At `proofs/statistics/concentration/mcdiarmid-bounded-differences-inequality/`.
- **Generic chaining (Talagrand)**: Gives sharper bounds for the expected supremum of Gaussian/sub-Gaussian processes, where the maximum over $n$ points is a special case.
- **Gaussian comparison inequality (Slepian/Gordon)**: Alternative approach to bounding $\mathbb{E}[\max_i X_i]$ for Gaussian vectors using covariance structure.
