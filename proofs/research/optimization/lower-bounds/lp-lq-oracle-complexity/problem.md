# Oracle complexity of smooth convex optimization in ℓp/ℓq settings (Guzmán 2015 conjecture)

## Source
- Paper: Guzmán, COLT 2015 (open conjecture)

## Statement

**Setup.** Fix $1 \le p \le 2$ and let $q$ satisfy $1/p + 1/q = 1$ (so $q \ge 2$). Let $B_p := \{x \in \mathbb{R}^d : \|x\|_p \le 1\}$.

A function $f : B_p \to \mathbb{R}$ is **$(L, p, q)$-smooth convex** if it is convex and
$$
\|\nabla f(x) - \nabla f(y)\|_q \le L\,\|x - y\|_p \qquad \forall x, y \in B_p.
$$

Define $\mathrm{Comp}_{p,q}(L, \varepsilon, d) :=$ minimax oracle complexity (number of first-order queries) to find $\hat x \in B_p$ with $f(\hat x) - \min_{B_p} f \le \varepsilon$ in the worst case over the class of $(L, p, q)$-smooth convex $f$.

**Known cases.**
- $p = q = 2$: $\mathrm{Comp}_{2,2}(L, \varepsilon, d) = \Theta(\sqrt{L/\varepsilon})$, dimension-free (Nesterov 1983).
- $p = 1, q = \infty$: $\mathrm{Comp}_{1,\infty}(L, \varepsilon, d) = \Theta(\sqrt{d \cdot L/\varepsilon})$ (folklore: the $\sqrt{d}$ factor is unavoidable).

**Guzmán's conjecture.** For all $1 \le p \le 2$,
$$
\mathrm{Comp}_{p, q}(L, \varepsilon, d) = \Theta\!\left( d^{(2-p)/(3p-2)} \cdot \sqrt{L/\varepsilon} \right).
$$

The exponent $(2-p)/(3p-2)$ interpolates: at $p = 2$ it is $0$ (matching dimension-free Nesterov); at $p = 1$ it is $1/2$ (matching the $\sqrt{d}$ rate).

**Open status.** The conjecture is verified at the two endpoints $p = 1$ and $p = 2$ but OPEN for all $1 < p < 2$.

**Required outcome.** Prove ONE of the following partial results:
1. A tighter LOWER bound $\Omega(d^{\alpha(p)} \cdot \sqrt{L/\varepsilon})$ for some $p \in (1, 2)$ with $\alpha(p) > 0$ that improves on the trivial $\sqrt{L/\varepsilon}$ floor.
2. A better UPPER bound (faster algorithm) for some $p \in (1, 2)$ that gets closer to Guzmán's conjectured rate.
3. A FULL proof or disproof of the conjecture for any specific $p^* \in (1, 2)$ — e.g., $p^* = 4/3$ or $p^* = 3/2$.

## Difficulty
conjecture

## Why this is hard

1. **Acceleration in non-Euclidean geometry.** Mirror descent and accelerated mirror descent give upper bounds, but the optimal rate as a function of $p$ is sensitive to the strong-convexity / smoothness constants of the regularizer in the matched ℓp-geometry, and these are not naturally $\Theta(1)$.
2. **Lower bounds via Le Cam / Yao** typically require constructing a hard sub-class of functions whose level sets sit inside $B_p$ in a way that prevents any algorithm from learning them quickly. The "right" hard class for $1 < p < 2$ is unknown.
3. **Interpolation.** The Riesz-Thorin interpolation theorem suggests an interpolation argument should work, but the function class is not convex in $p$ — Riesz-Thorin acts on linear operators, not algorithms.
4. The exponent $(2-p)/(3p-2)$ has the suggestive denominator $3p - 2$ — this likely arises from balancing three quantities, which hints at a specific tension in the optimization argument.

## Stuck points anticipated by Scout

1. Defining the "right" packing for the lower bound that respects the ℓp-ball geometry.
2. The Bregman divergence on $B_p$ for $1 < p < 2$ behaves badly near the boundary; standard mirror-descent analyses give worse-than-conjectured rates.
3. Connecting the dimension-dependence of mirror-descent constants to the $(2-p)/(3p-2)$ exponent.
