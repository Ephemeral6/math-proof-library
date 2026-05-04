# B6 — Momentum SGD interpolation convergence (split co-coercivity)

**Verdict**: CONFIRMED

**Source**: Vaswani et al. 2019 (1810.07288), Liu-Belkin 2020 (2003.00307). Same source family as B5.

## OUR statement
Convex $L$-smooth $f_i$, $\mu$-SC $f$, $\nabla f_i(x^*)=0$, $\kappa = L/\mu$. Polyak momentum, $\gamma=1/L$, $\beta = \mu^2/(16L^2)$:
$$\mathbb{E}\|x_t - x^*\|^2 \le (1-\mu/(2L))^t \|x_0-x^*\|^2 = (1 - 1/(2\kappa))^t \|x_0-x^*\|^2.$$

## Paper statement
Vaswani et al. (Thm "vanilla"): SGD-momentum under SGC and SC contracts at rate $1 - \Omega(1/\kappa)$ matching vanilla SGD. Liu-Belkin Thm 4: PL* gives $1-\mu/L$.

## Comparison
- Same setup, same algorithm.
- Step size $\gamma = 1/L$ — matches the standard SGD step.
- Momentum $\beta = O(1/\kappa^2)$ — very small (perturbative), explicitly stated in proof's Remark.
- Rate $1-1/(2\kappa)$ is **identical to the published vanilla-momentum SGD rate under interpolation** (factor 1/2 standard).
- The "split co-coercivity" technique with $\alpha=1/2$ is exactly the Vaswani-Bach-Schmidt 2019 variance-absorption mechanism (sometimes called "automatic variance reduction").
- Not an accelerated rate; proof acknowledges this in closing Remark.

## Verdict
**CONFIRMED**: rate $1-1/(2\kappa)$ matches published Vaswani 2019 vanilla momentum result exactly (up to absorbed constants). Technique is the textbook split-co-coercivity Lyapunov used by Vaswani / Liu-Belkin. No errors, no surprises.
