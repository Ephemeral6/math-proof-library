# Unadjusted Langevin Algorithm: KL Convergence under Log-Sobolev Inequality

## Source
- **Paper**: S. Vempala & A. Wibisono, *"Rapid Convergence of the Unadjusted Langevin Algorithm: Isoperimetry Suffices"*, NeurIPS 2019.
- **Context**: Establishes that ULA converges in KL divergence to a biased stationary distribution at a geometric rate, under only a log-Sobolev inequality (LSI) on the target — no strong log-concavity required. This extends Dalalyan 2017's result (which assumed strong convexity, equivalent to LSI plus log-concavity) to the much weaker LSI assumption.

## Statement

**Setting.** Let $\pi(x) \propto \exp(-f(x))$ be a target probability density on $\mathbb{R}^d$ with potential $f : \mathbb{R}^d \to \mathbb{R}$ satisfying:

- (A1) **Smoothness**: $f$ is $L$-smooth, i.e., $\nabla f$ is $L$-Lipschitz:
$$\|\nabla f(x) - \nabla f(y)\| \le L\|x-y\| \qquad \forall x, y \in \mathbb{R}^d.$$

- (A2) **Log-Sobolev inequality (LSI)**: $\pi$ satisfies LSI with constant $\alpha > 0$, i.e., for every probability density $\rho$ with $\rho \ll \pi$,
$$\mathrm{KL}(\rho \| \pi) \le \frac{1}{2\alpha} \, \mathrm{FI}(\rho \| \pi), \qquad \mathrm{FI}(\rho \| \pi) := \int \rho(x) \left\|\nabla \log \frac{\rho(x)}{\pi(x)}\right\|^2 dx.$$

**No assumption of log-concavity or strong log-concavity.**

**ULA iteration.** For step size $h > 0$, $x_0 \sim \rho_0$:
$$x_{k+1} = x_k - h \nabla f(x_k) + \sqrt{2h}\, \xi_k, \qquad \xi_k \sim \mathcal{N}(0, I_d) \text{ i.i.d.}$$
Let $\rho_k$ denote the law of $x_k$.

**Target theorem.** Fix a step size $h \in \bigl(0, \tfrac{\alpha}{4L^2}\bigr]$. Then for every $k \ge 0$:

$$\boxed{\;\mathrm{KL}(\rho_k \| \pi) \;\le\; e^{-\alpha h k}\, \mathrm{KL}(\rho_0 \| \pi) \;+\; \frac{8 h d L^2}{\alpha}.\;}$$

Equivalently, $\rho_k$ converges geometrically to within a bias region of size $O(h d L^2 / \alpha)$ of $\pi$ in KL. The bias vanishes as $h \to 0$.

## Difficulty
**research**

## Key intermediate results to prove

1. **Continuous-time Langevin diffusion dissipation**: For the overdamped Langevin SDE $dX_t = -\nabla f(X_t) dt + \sqrt{2}\, dB_t$ with law $\rho_t$, the entropy dissipation identity
$$\frac{d}{dt} \mathrm{KL}(\rho_t \| \pi) = -\mathrm{FI}(\rho_t \| \pi).$$
Combined with LSI, this gives $\frac{d}{dt}\mathrm{KL}(\rho_t \| \pi) \le -2\alpha \mathrm{KL}(\rho_t\|\pi)$, hence exponential decay in continuous time.

2. **Interpolated Langevin process**: Define the continuous-time interpolation of ULA between steps $k h$ and $(k+1) h$ as
$$\tilde x_t = x_k - (t - kh) \nabla f(x_k) + \sqrt{2}(B_t - B_{kh}), \qquad t \in [kh, (k+1)h].$$
Then $\tilde x_t$ satisfies an SDE with a drift that uses the *frozen* gradient $\nabla f(x_k)$ instead of $\nabla f(\tilde x_t)$.

3. **Discretization error bound**: The difference between the true Langevin drift $-\nabla f(\tilde x_t)$ and the ULA's frozen drift $-\nabla f(x_k)$ produces a discretization error. Under $L$-smoothness, for $t \in [kh, (k+1)h]$,
$$\mathbb{E}\|\nabla f(\tilde x_t) - \nabla f(x_k)\|^2 \le C \cdot h (L^2 \cdot \mathrm{(trace)} + L^4 \cdot h \cdot \mathbb{E}\|\nabla f(x_k)\|^2)$$
for an explicit constant $C$. The key bound is $O(h L^2 d)$ for the second-moment error.

3. **One-step KL decrease for ULA**: Show that along one step of ULA from time $kh$ to $(k+1)h$ in the interpolated process, we get a recursion of the form
$$\mathrm{KL}(\rho_{(k+1)h} \| \pi) \le e^{-\alpha h} \mathrm{KL}(\rho_{kh} \| \pi) + \epsilon(h)$$
where $\epsilon(h) = O(h^2 d L^2)$ is the one-step discretization bias.

4. **Telescoping / geometric series**: Iterating the one-step recursion gives the final bound
$$\mathrm{KL}(\rho_{Nh} \| \pi) \le e^{-\alpha h N} \mathrm{KL}(\rho_0 \| \pi) + \frac{\epsilon(h)}{1 - e^{-\alpha h}} \le e^{-\alpha h N} \mathrm{KL}(\rho_0 \| \pi) + \frac{O(h d L^2)}{\alpha}.$$

5. **Step-size restriction**: Verify that $h \le \alpha/(4L^2)$ is the right regime to ensure the discretization error bound absorbs cleanly (i.e., the error does not dominate the contraction).
