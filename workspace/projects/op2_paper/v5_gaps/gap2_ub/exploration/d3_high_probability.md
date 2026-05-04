# Direction 3 — High-probability bound

**Verdict: INFEASIBLE for fixed $(\beta, \eta)$.** The noise floor is concentration-tight, not just expectation-tight. High-probability bounds inherit the same obstruction.

**Effort:** N/A (no positive result to be had at fixed $(\beta, \eta)$).

## Question

Can a high-probability last-iterate UB of the form
$$\Pr\Bigl[f(x_T) - f^\star > \varepsilon\Bigr] \le \delta \quad\text{with}\quad \varepsilon = O\!\left(\frac{LD^2}{T} + \frac{\sigma D}{\sqrt T} \cdot \sqrt{\log(1/\delta)}\right)$$
hold for fixed-$(\beta, \eta)$ SHB on smooth convex non-SC, side-stepping the expectation-noise-floor obstruction?

## Why no — concentration analysis

The closed-form covariance from `gap2_proof.md` Theorem A.1 says: for fixed $(\beta, \eta)$ on $f(x) = (L/2)x^2$ with i.i.d. $\mathcal N(0, \sigma^2)$ gradient noise, the iterate $x_T$ has Gaussian stationary distribution with variance
$$\sigma_\infty^2 \;=\; \frac{\eta\,\sigma^2\,(1+\beta)}{L(1-\beta)(2(1+\beta) - \eta L)}.$$
For $T \gg 1/(1-\rho^2)$ where $\rho = \sqrt\beta$, $x_T \approx \mathcal N(0, \sigma_\infty^2)$. Hence
$$f(x_T) - f^\star \;=\; \frac{L}{2}\,x_T^2 \;\sim\; \frac{L \sigma_\infty^2}{2}\,\chi_1^2,$$
a chi-squared distribution scaled by $L\sigma_\infty^2/2$.

For any $\delta \in (0, 1)$, the $(1-\delta)$-quantile of $f(x_T) - f^\star$ is
$$Q_{1-\delta}\bigl[f(x_T) - f^\star\bigr] \;\geq\; \frac{L\sigma_\infty^2}{2} \cdot \chi_1^2(1 - \delta) \;\geq\; \frac{L\sigma_\infty^2}{2} \cdot c(\delta) \;>\; 0,$$
where $c(\delta) > 0$ for any $\delta < 1$. **Independent of $T$**.

So no high-probability UB of the form $\Pr[f(x_T) - f^\star \le \varepsilon(T, \delta)] \to 1$ as $T \to \infty$ can hold with $\varepsilon(T, \delta) \to 0$. The high-prob obstruction is the same as the expectation obstruction: $f(x_T)$ has a stationary distribution with positive median (and positive any-quantile-other-than-0).

## What does work

If we allow $\eta_t \to 0$ or projection (same modifications as Direction 2 / direction_2 Theorem D), then high-prob bounds DO exist. Specifically:

- **Sebbouh-Gower-Defazio 2021** (COLT, [arXiv:2006.07867](https://arxiv.org/abs/2006.07867)): time-varying $(\eta_t, \beta_t)$ SHB has $f(x_T) - f^\star = o(1/\sqrt k)$ a.s. — a.s. convergence implies high-prob convergence.
- **arXiv:2507.07281** (2025): claims "first high-probability convergence rate result for SHB" — likely with time-varying schedules.

But these all break the "fixed $(\beta, \eta)$" assumption.

## Why expectation-vs-high-prob doesn't open a loophole here

A common argument: "expectation is tight but high-prob can be tighter because outliers dominate the mean". This works when the distribution is heavy-tailed (e.g., heavy-tailed gradient noise + clipping). It does NOT work when the distribution is sub-Gaussian or chi-squared, which our quadratic-with-Gaussian-noise yields. In our setting, both mean and quantiles of $f(x_T)$ saturate at the same noise-floor scale.

The asymmetric loophole would also require sub-Gaussian *upper-tail* concentration around a *small* center — but our center is the noise floor, not 0.

## Variant: lower-tail high-prob bound?

A different question: can we say $\Pr[f(x_T) - f^\star \le \varepsilon] \ge \rho$ for some $\rho > 0$ and $\varepsilon = o(1)$? Yes — by the Gaussian density at 0, $\Pr[|x_T| \le \delta] \approx 2\delta \cdot \phi(0)/\sigma_\infty$ for small $\delta$, so $\Pr[f(x_T) \le L\delta^2/2] = \Theta(\delta/\sigma_\infty)$. With $\delta = \sigma_\infty/\sqrt T$, $\Pr[f \le L\sigma_\infty^2/(2T)] = \Theta(1/\sqrt T)$ — but the probability vanishes, not approaches 1. So this doesn't give a "with high probability" bound either.

## Recommendation

**LOW PRIORITY / SKIP.** High-probability framing does not escape the noise-floor obstruction at fixed $(\beta, \eta)$. The expected-value analysis already captures the right order of magnitude.
