# Fragment: lyapunov-bounded-iteration-SA

## Statement (Stochastic-approximation $O(1/T)$ via Lyapunov function)
Consider the scalar mean-squared-error recursion $v_{t+1} \le (1 - 2\mu\alpha_t + L^2\alpha_t^2)\,v_t + \sigma^2 \alpha_t^2$ with step size $\alpha_t = c/(c+t)$ where $c > 1/(2\mu)$. Define the Lyapunov candidate $w_t := (c+t)\,v_t$. Then:
$$w_{t+1} \;\le\; \Bigl(1 - \frac{2c\mu - 1}{c+t} + O\bigl(\tfrac{1}{(c+t)^2}\bigr)\Bigr)\,w_t \;+\; \frac{2 c^2 \sigma^2}{c+t}.$$
In particular, for $c+t$ large enough that the $O(1/(c+t)^2)$ term is dominated by half of the linear coefficient, $w_t$ has the **invariant set** $w_t \le W := 4c^2\sigma^2/(2c\mu - 1)$ (entered in finite time, never left). Hence:
$$v_T \;\le\; \frac{C}{T+1}, \qquad C \approx \frac{4c^2 \sigma^2}{2c\mu - 1}.$$

## Proof
Multiply the MSE recursion by $c+t+1$:
$$w_{t+1} = (c+t+1)v_{t+1} \le \tfrac{c+t+1}{c+t}\Bigl(1 - \tfrac{2c\mu}{c+t}\Bigr) w_t + \tfrac{c+t+1}{(c+t)^2}\bigl(c^2 L^2 w_t /(c+t) + c^2\sigma^2\bigr).$$
Expand $\tfrac{c+t+1}{c+t}(1 - \tfrac{2c\mu}{c+t}) = 1 + \tfrac{1}{c+t} - \tfrac{2c\mu}{c+t} - \tfrac{2c\mu}{(c+t)^2} = 1 - \tfrac{2c\mu - 1}{c+t} + O(1/(c+t)^2)$.

The $O(1/(c+t)^2)$ residue is dominated by half the negative linear term once $c+t \ge n_0 := \tfrac{2(2c^2 L^2 + 2c\mu)}{2c\mu - 1}$. For such $c+t$, if $w_t \le W$ then
$$w_{t+1} \le \bigl(1 - \tfrac{(2c\mu-1)/2}{c+t}\bigr) W + \tfrac{2c^2\sigma^2}{c+t} = W,$$
so $W$ is invariant. The transient phase contributes a bounded constant. Hence $v_T = w_T/(c+T) \le C/(T+1)$. $\square$

## Source
- `proofs/research/optimization/convergence/td0-linear-approximation-convergence/proof.md` — Phase 4, Lemma 4.

## Status
- **Correctness**: LIKELY-CORRECT (standard SA template)
- **Used in final proof**: YES (drives $O(1/T)$ rate of TD(0) with linear FA)
- **Potential applications**:
  - TD($\lambda$), Q-learning with FA finite-time analysis
  - Linear stochastic approximation under contractive operators
  - SGD on strongly convex $L$-smooth functions with diminishing step
  - GTD, SGD with state-dependent noise (Markov chain samples)
  - Two-timescale SA convergence rates

## Tags
stochastic-approximation, lyapunov, harmonic-step, TD, invariant-set, convergence-rate
