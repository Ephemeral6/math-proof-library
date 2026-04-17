# Notes: SVRG Linear Convergence (ABC Framework)

## Proof technique
**Route 5 — Semi-Stochastic / ABC Framework** (Attempt 3 variant)

The winning approach tracks the distance-to-optimum $\Phi_t = \mathbb{E}\|x_t - x^*\|^2$ as the primary Lyapunov quantity, derives a one-step recursion coupling it with the function gap $\delta_t$, sums over the inner loop, and then converts the accumulated $\sum\Phi_t$ term back into $\sum\delta_t$ using strong convexity. The output averaging then yields the per-epoch contraction.

## Key steps

1. **Variance bound via Nesterov (Lemma 5):** The critical ingredient is bounding $\mathbb{E}\|v_t\|^2 \leq 4L[\delta_t + \delta_0]$ using the convex-smooth inequality $\|\nabla f_i(x) - \nabla f_i(y)\|^2 \leq 2L \cdot D_{f_i}(x,y)$ centered at $x^*$. This avoids introducing κ in the variance bound.

2. **One-step distance recursion:** The expansion of $\|x_{t+1} - x^*\|^2$ combined with strong convexity and Lemma 5 gives a clean recursion with explicit coefficients: contraction $(1 - \frac{1}{10\kappa})$ on distance, descent $-\frac{4}{25L}$ on function gap, and epoch-start error $+\frac{1}{25L}$ per step.

3. **Summation + strong convexity coupling:** After summing, the $\frac{1}{10\kappa}\sum\Phi_t$ term is converted to $\frac{1}{5L}\sum\delta_t$ via $\Phi_t \leq \frac{2}{\mu}\delta_t$, boosting the effective coefficient from $\frac{4}{25L}$ to $\frac{9}{25L}$.

4. **Final arithmetic:** $\frac{50\kappa}{9 \cdot 20\kappa} + \frac{1}{9} = \frac{7}{18} < \frac{1}{2}$.

## Audit result
Proof passed audit. All inequalities verified, numerical coefficients checked, direction of strong convexity bound confirmed correct. The output averaging step uses only linearity of expectation (not Jensen's inequality).

## Related results
- **SVRG l² contraction route** (in this library): Uses direct $\|x_t - x^*\|^2$ contraction without the function-value coupling. Different technique but same conclusion.
- **SVRG Lyapunov route** (in this library): Uses a Lyapunov function combining function gap and distance. More general framework.
- **SAGA (Defazio et al. 2014):** Similar variance reduction with different update rule; analogous linear convergence analysis.
- **Katyusha (Allen-Zhu 2017):** Accelerated SVRG achieving optimal rate $O((n + n^{3/4}\sqrt{\kappa})\log(1/\epsilon))$.

## Why earlier attempts failed
- **Attempt 1 (L²-smoothness bound):** Using $\sigma_t^2 \leq L^2\|x_t - \tilde{x}_s\|^2$ and triangle inequality at $x^*$ introduces $\frac{L}{\mu} = \kappa$ when converting distance back to function gap, making the one-step contraction exceed 1.
- **Attempt 2 (Coupled Lyapunov):** Algebraically valid but the quadratic characteristic equation is messy. The sum-then-average approach is cleaner.
