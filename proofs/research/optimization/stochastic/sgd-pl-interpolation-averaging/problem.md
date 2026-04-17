# Optimal Convergence of SGD under Interpolation + PL with Iterate Averaging

## Source
- Context: Two-phase SGD convergence combining linear rate under PL+interpolation with Polyak-Ruppert averaging

## Statement

SGD: $x_{t+1} = x_t - \gamma_t \nabla f_{i_t}(x_t)$, $f = \frac{1}{n}\sum f_i$.

Assumptions: $L$-smooth $f$, $\mu$-PL, each $f_i$ convex $L$-smooth with $\nabla f_i(x^*)=0$ (interpolation), strong growth $\mathbb{E}[\|\nabla f_i(x)\|^2] \leq \rho\|\nabla f(x)\|^2$.

**(a)** $\gamma = 1/(\rho L)$: $\mathbb{E}[f(x_t)-f^*] \leq (1-\mu/(\rho L))^t(f(x_0)-f^*)$

**(b)** $\gamma_t = 2/(\mu(t+t_0))$, $t_0 = 2\rho L/\mu$, averaged iterate: $\mathbb{E}[f(\bar{x}_T)-f^*] \leq O(\rho L/(\mu T) \cdot \epsilon_0)$

## Difficulty
conjecture
