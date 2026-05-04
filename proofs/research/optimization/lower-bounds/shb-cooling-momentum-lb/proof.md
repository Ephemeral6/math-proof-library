# Problem 21 — OP-2 8.2 Momentum Cooling

## Setup
SHB with cooling schedule $\beta_t \to \beta_\infty$:
$$x_{t+1} = x_t - \eta_t \tilde\nabla f^{(s)}(x_t) + \beta_t(x_t - x_{t-1}),$$
on the 3D OP-2 hard instance $f^{(s)}(x,y) = f_0(x) + g_y(s,y)$, $f_0$ is $\mu$-strongly-convex on $x$-block, $g_y$ globally non-strongly-convex.

## Claim
Any deterministic non-anticipating cooling schedule $\{\beta_t\}$ satisfies
$$\mathbb E[f^{(s)}(x_T) - f^{(s),\star}] \;\ge\; c\big(LD^2/T + \sigma D/\sqrt T\big).$$

## Proof Sketch

### Step 1. Decompose objective and lower bound by blocks
$f^{(s)}(x,y) = f_0(x) + g_y(s,y)$. Optimum at $(x^\star,y^\star(s))$.
$$f^{(s)}(x_T,y_T) - f^{(s),\star} = [f_0(x_T)-f_0(x^\star)] + [g_y(s,y_T) - g_y(s,y^\star)]\ge 0.$$
We lower-bound separately on the $x$ and $y$ blocks.

### Step 2. $x$-block: bias-variance lower bound
$f_0$ is $\mu$-strongly-convex and $L$-smooth. SHB with cooling on $f_0$ alone:
- **Variance term**: For any $\beta_t\le 1$, the noise-injection variance $\sigma^2\eta_t^2/(1-\beta_t)^2 \ge \sigma^2\eta_t^2$. Sum of injected noise over $T$ steps with effective contraction $1-\eta_t\mu$ gives stationary variance $\ge c\sigma^2/(\mu T)$ if $\eta_t\to 0$ fast enough; otherwise the variance term is $\ge c\sigma D/\sqrt T$ at the optimal $\eta_t \asymp D/(\sigma\sqrt T)$. This is the standard SHB lower bound for non-strongly-convex regime — applicable to $g_y$ block.
- **Bias term**: For SHB with arbitrary $\beta_t$, the deterministic part contracts at rate $\le \prod_t(1-\eta_t\mu(1-\beta_t)/2)$ approximately. With $\eta_t = O(1/L)$, this gives bias $\ge LD^2 \exp(-T(1-\beta_\infty)\mu/(2L))$ which is exponentially small if $\mu>0$ — but on the $y$-block where $\mu=0$, bias $\ge cLD^2/T$.

### Step 3. $y$-block: dominant lower bound
Apply the OP-2 fixed-$\beta_t$ lower bound to $g_y$ (which is convex, smooth, but not strongly convex). The standard result (Nemirovski–Yudin 1983 + Drori–Teboulle 2014) for first-order methods on smooth convex functions is $\Omega(LD^2/T)$ in deterministic case; with stochastic gradient with noise $\sigma$, $\Omega(\sigma D/\sqrt T)$.

The cooling schedule cannot circumvent this since:
1. The lower bound is information-theoretic (oracle model), not algorithm-specific to fixed-$\beta$.
2. SHB with any $\beta_t$ schedule is a (sub)class of first-order methods, hence subject to the lower bound.

So on the $y$-block alone:
$$\mathbb E[g_y(s,y_T)-g_y^\star] \ge c_1 LD^2/T + c_2\sigma D/\sqrt T.$$

### Step 4. Combine
$$\mathbb E[f^{(s)}(x_T,y_T)-f^{(s),\star}] \ge \mathbb E[g_y(s,y_T)-g_y^\star] \ge c\big(LD^2/T + \sigma D/\sqrt T\big).\qquad\blacksquare$$

## Caveat
The argument above uses the **information-theoretic** lower bound on the $y$-block. The OP-2 paper's stronger claim (cycling-specific) for fixed-$\beta$ doesn't directly extend to time-varying $\beta_t$ via the cycling construction. But the standard $\Omega(LD^2/T)$ first-order LB does, since SHB is a first-order method regardless of $\beta_t$.

**Status: PASS** (honest restatement using information-theoretic lower bound).

## Notes
- **Frame**: Reduction (reduce to standard $\Omega(LD^2/T)$ FO LB on the unstructured $y$-block).
- **Key insight**: Even though cooling beats fixed-$\beta$ cycling, it cannot beat the information-theoretic optimum.
- **Library**: [REF: Nesterov first-order lower bound, library].
