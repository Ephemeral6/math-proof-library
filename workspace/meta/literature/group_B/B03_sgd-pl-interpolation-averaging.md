# B3 — SGD PL+interpolation two-phase

**Verdict**: CONFIRMED (folklore composite)

**Source**: No single arXiv source — composite of Karimi-Nutini-Schmidt 2016 (PL convergence), Vaswani-Bach-Schmidt 2019 / Schmidt-Le Roux 2013 (strong growth), and standard $1/t$ stepsize $\Rightarrow$ $O(1/t^2)$ Polyak averaging (folklore).

## OUR statement
Convex $L$-smooth $f_i$ with $\nabla f_i(x^*)=0$, $f$ $\mu$-PL, strong growth $\mathbb{E}\|\nabla f_i\|^2\le\rho\|\nabla f\|^2$. Then:
- (a) constant $\gamma=1/(\rho L)$: $e_t \le (1-\mu/(\rho L))^t e_0$.
- (b) decreasing $\gamma_t = 2/(\mu(t+t_0))$, $t_0 = 2\rho L/\mu$, averaging $\bar x_T$: $\mathbb{E}[f(\bar x_T)-f^*] \le 4\rho L/(\mu T)\cdot e_0$.

## Composite source claims
- (a) Vaswani-Bach-Schmidt 2019 Thm 1: under strong growth $\rho$ and $\mu$-strong convexity (or PL), constant step $\eta = 1/(\rho L)$ gives linear rate $1-\mu/(\rho L)$. **Identical**.
- (b) Polyak-Ruppert averaging under PL with $1/(t+t_0)$ step: $O(1/t)$ on the average is folklore. The induction $e_t \le t_0^2/(t+t_0)^2 e_0$ giving $O(1/t^2)$ per-iterate is unusual under pure PL but holds under interpolation+strong-growth (no noise floor); see Bach 2014 / Moulines-Bach 2011 for the SC analogue.

## Comparison
- (a) is essentially a textbook result. **CONFIRMED**.
- (b) The $O(1/t^2)$ per-iterate bound under PL alone is not standard; the proof relies critically on (i) strong growth absorbing the variance; (ii) the recursion $\alpha_t = 1 - 4/s + 2t_0/s^2$ being $\le s^2/(s+1)^2$. Our Step 2 verifies this elementarily. The $O(1/T)$ averaged bound is the standard rate.
- Constants: $4\rho L/(\mu T)$ vs Vaswani et al's $O(\rho L/(\mu T))$ — same big-O.

## Verdict
**CONFIRMED** as folklore composite. Both (a) and (b) match the published Vaswani-Bach-Schmidt 2019 / Bach 2014 framework. The $O(1/t^2)$ per-iterate intermediate bound is internal scaffolding and consistent with PL-EB equivalence under strong growth.
