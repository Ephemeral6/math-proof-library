# Coordinate-wise AdaGrad under (L0,L1)-smoothness with affine noise — improvement over SGD in ℓ1-norm

## Source
- Paper: Jiang–Maladkar–Mokhtari, COLT 2025 (BENCHMARK; we attempt independent proof without reading their paper)
- Context: shows coordinate-wise AdaGrad strictly beats SGD when stationarity is measured in ℓ1-norm under coordinate-wise generalized smoothness and affine noise

## Statement

**Setup.** Let $f:\mathbb{R}^d \to \mathbb{R}$ be differentiable with $f^* := \inf_x f(x) > -\infty$ and $\Delta_0 := f(x_0) - f^* < \infty$.

**Coordinate-wise (L0, L1)-smoothness.** For each coordinate $i \in [d]$ and all $x, y \in \mathbb{R}^d$,
$$
|\partial_i f(x) - \partial_i f(y)| \le (L_0 + L_1\|\nabla f(x)\|)\,\|x - y\|_2.
$$

**Coordinate-wise affine noise.** The stochastic oracle returns $g_t = \nabla f(x_t) + \xi_t$ with $\mathbb{E}[\xi_t \mid x_t] = 0$ and, for each coordinate $i$,
$$
\mathbb{E}[\xi_{t,i}^2 \mid x_t] \le \sigma_0^2 + \sigma_1^2 (\partial_i f(x_t))^2.
$$

**Algorithm (coordinate-wise AdaGrad).** With learning rate $\eta > 0$, smoothing $\varepsilon > 0$, and $v_{0,i} := \varepsilon^2$,
$$
v_{t+1, i} = v_{t, i} + g_{t, i}^2, \qquad x_{t+1, i} = x_{t, i} - \eta \cdot \frac{g_{t, i}}{\sqrt{v_{t+1, i}}}.
$$

**Claim.** There exists a choice of $\eta = \eta(L_0, L_1, \sigma_0, \sigma_1, \Delta_0, T, d)$ such that
$$
\min_{0 \le t \le T-1} \mathbb{E}\bigl[\|\nabla f(x_t)\|_1\bigr] \le \widetilde{O}\!\left(\frac{d^{1/3}\, \sigma_0^{2/3}\, L_0^{1/3}\, \Delta_0^{1/3}}{T^{1/3}}\right) + \text{lower-order},
$$
where $\widetilde{O}$ hides $\mathrm{polylog}(T)$ factors and constants depending only on $\sigma_1, L_1$.

**Comparison with SGD.** Vanilla SGD achieves only
$$
\min_{0 \le t \le T-1} \mathbb{E}\bigl[\|\nabla f(x_t)\|_1\bigr] = \Omega\!\left(\frac{d^{1/2}\, \sigma_0\, L_0^{1/2}\, \Delta_0^{1/2}}{T^{1/2}}\right)
$$
under the same assumptions, so coordinate-wise AdaGrad is strictly better in $T$-rate (1/3 vs 1/2) at the cost of a slightly worse $d$ scaling ($d^{1/3}$ vs $d^{1/2}$ in the leading constant).

## Difficulty
research

## Why the rate is plausible

Heuristic (NOT a proof):
- Per-coordinate AdaGrad accumulator $v_{T,i} \sim T \cdot \mathbb{E}[g_{i}^2] \sim T \cdot (\sigma_0^2 + (\partial_i f)^2)$.
- AdaGrad regret on each coordinate $\sim \sqrt{v_{T,i}}$.
- Sum over coordinates: $\sum_i \sqrt{T \cdot (\sigma_0^2 + (\partial_i f)^2)}$ controls the ℓ1 gradient sum.
- Balancing the descent budget $\Delta_0$ against the accumulator growth, with Hölder over coordinates, gives $T^{-1/3}$ in the worst-case ℓ1 sum.

## Stuck points anticipated by Scout

1. The (L0, L1)-smoothness mixes the gradient norm into the smoothness constant — the standard descent lemma must be re-derived per coordinate with a self-bounding inequality.
2. The affine noise $\sigma_1^2 (\partial_i f)^2$ introduces a multiplicative term that must be absorbed into the descent inequality, not the variance term, otherwise the rate degrades.
3. The $\widetilde{O}$ factor must come from a $\log v_{T,i}$ telescoping — this is the standard AdaGrad logarithm, and must be carried through Hölder over coordinates.
4. Going from $\sum_i \mathbb{E}[\sqrt{v_{T,i}}] $ to a $T^{-1/3}$ rate requires Cauchy–Schwarz/Hölder applied in the right direction (over coordinates, not over time).
