# Notes: SHB best-iterate lower bound on F (OP-2 / I3)

## Proof technique

**Bias term (PROVED):** Direct transfer from OP-2's deterministic Lemma AP + Lemma SC→Gap. Key insight: OP-2's initialization $((D/\sqrt 2)e_0, (D/\sqrt 2)e_{K-1})$ is on-cycle from $t=0$ with NO transient. Hence $f_0(x_t) = $ cycle vertex value $\ge \kappa LD^2/4$ pointwise, and min over $t$ inherits the bound trivially. Same constant as OP-2 last-iterate.

**Variance term (DISPROVED):** Counterexample via random-walk-visit argument. SHB random walk on linear-with-wall function $g_y$ has stationary variance $\Theta(\sigma^2\eta^2/((1-\beta^2)L^2))$ (independent of $T$). Over $T$ steps, the iterate visits the optimum's neighborhood $\Theta(T)$ times; closest visit at distance $O(1/\sqrt T)$ gives $\min_t g_y(y_t) - \min g_y = O(L \cdot V/T) = O(1/T)$, NOT $\Omega(\sigma D/\sqrt T)$.

The natural Le Cam test $\hat s = -\mathrm{sign}(y_{t^*})$ achieves NEAR-PERFECT classification (because $y_{t^*}$ is by definition near the optimum, on the side $-s$). This is fully consistent with Le Cam's worst-case lower bound, but blocks using Le Cam to derive the gap lower bound.

## Key steps

1. **No transient observation**: Initialization on cycle gives $\|x_t\| = D/\sqrt 2$ for ALL $t \ge 0$.
2. **Pointwise bias bound**: $f_0(x_t) \ge \mu D^2/4 = \kappa LD^2/4$ via SC floor.
3. **Min inherits**: $\min_t f_0(x_t) \ge \kappa LD^2/4 \ge \kappa/(4) \cdot LD^2/T$ for $T \ge 1$.
4. **Variance counterexample numerics**: $T = 1000$: empirical $\min_t \mathrm{gap} \approx 4 \times 10^{-6}$, vs target $\sigma D/(56\sqrt T) \approx 6 \times 10^{-4}$. Ratio 0.007.
5. **Variance theoretical explanation**: stationary variance + visit-rate argument gives $O(1/T)$ scaling, not $O(1/\sqrt T)$.
6. **Le Cam bug**: $-\mathrm{sign}(y_{t^*})$ test is near-perfect, can't be lower-bounded.

## Audit result

**Round 0 PASS** for both Theorem 1 (bias proved) and Theorem 2 (variance disproved with counterexample). 9 gap checks (G1-G6 + V1-V3) all passed cleanly. No fixer round invoked.

## Related results

- **OP-2 (last-iterate)**: bias $\Omega(\kappa LD^2/T)$ + variance $\Omega(\sigma D/\sqrt T)$ on $\mathcal{F}$. Best-iterate inherits bias verbatim, but variance term FAILS — fundamental asymmetry between best/last iterate.
- **Goujaud-Taylor-Dieuleveut 2023** (arXiv:2307.11291): cycling theorem on $\mathcal{F}$ with $\mu > 0$.
- **Nemirovski-Yudin 1983 / Agarwal-Bartlett-Ravikumar-Wainwright 2012**: variance lower bound $\Omega(\sigma D/\sqrt T)$ for ALGORITHM OUTPUT (not best iterate). Our result clarifies that this CANNOT extend to best iterate.
- **Lan 2012 (AC-SA)**: upper bound $O(LD^2/T^2 + \sigma D/\sqrt T)$ for accelerated stochastic approximation. Our $\Omega(LD^2/T)$ best-iterate lower bound is a factor $T$ slower than the ACC accelerated bias rate, confirming "SHB does not accelerate" on $\mathcal{F}$ even for best iterate.

## What's left open

**Conjecture (informal)**: For ANY unbiased $\sigma^2$-bounded oracle on $L$-smooth convex $f$, the SHB best iterate satisfies the UPPER bound
$$
\mathbb{E}[\min_t f(x_t) - f^\star] \le O(LD^2/T + \sigma^2/L).
$$
The variance term saturates at the noise floor $O(\sigma^2/L)$, NOT $O(\sigma D/\sqrt T)$. If this conjecture holds, the original I3 problem (combined bias + variance) is generically FALSE for best iterate, not just for the OP-2 construction.

Proving this upper-bound conjecture would close the picture: on $\mathcal{F}$, last-iterate has rate $\Omega(LD^2/T + \sigma D/\sqrt T)$ while best-iterate has rate $\Theta(LD^2/T + \sigma^2/L)$ — different in the variance regime.

## Historical context

This is the second extension of OP-2 (after OP-2 itself was proved with $\beta > \beta^\star \approx 0.303$ restricted to $\mathcal{F}$). The result identifies a FUNDAMENTAL asymmetry between last-iterate and best-iterate stochastic lower bounds, which appears not to have been previously articulated in the literature. The negative result (variance disproof) is itself a contribution.
