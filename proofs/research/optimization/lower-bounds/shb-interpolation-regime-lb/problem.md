# Theorem (S4): Interpolation-Regime Lower Bound for Stochastic Heavy Ball

## Source
- Direction: noise-model extension of OP-2 (`proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/`).
- Context: OP-2 established the lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$ for SHB last iterate on $L$-smooth convex functions with bounded-variance ($\sigma^2$) stochastic oracle, on the Goujaud feasibility region $\mathcal{F} \subset$ stability region $\mathcal{S}$. This work asks: under the interpolation noise model (variance vanishes at the optimum), what survives?

## Statement

Let $L, D > 0$, $\sigma \geq 0$. Let $\mathcal{F}$ be the Goujaud feasibility region (OP-2 §1.1; contains the explicit $K=3$ region $\{\beta \geq (\sqrt{13}-3)/2,\ Lη \in [\gamma_{\mathrm{crit},3}(\beta), 2(1+\beta)]\}$).

Define the multiplicative-interpolation noise class:
$$\mathcal{N}_{\mathrm{int}}(\sigma^2; \rho) := \{(g_t)_{t\geq 0} : g_t = \nabla f(x_t) + \xi_t,\ \mathbb{E}[\xi_t | x_t] = 0,\ \mathbb{E}[\|\xi_t\|^2 | x_t] \leq \sigma^2\rho(\|x_t - x^\star\|)\}$$
for $\rho:[0,\infty)\to[0,\infty)$ continuous with $\rho(0) = 0$. Standard cases: $\rho_0 \equiv 0$ (noiseless), $\rho_1(r) = r^2$ (multiplicative).

**Theorem (S4).**

**(A) Bias survives.** For every $(\beta, \eta) \in \mathcal{F}$ and every interpolation $\rho$, there exist $L$-smooth convex $f_{\beta,\eta}: \mathbb{R}^2 \to \mathbb{R}$ and oracle $\mathcal{O} \in \mathcal{N}_{\mathrm{int}}(\sigma^2; \rho)$ such that the SHB iterate from $\|x_0 - x^\star\| = D$ satisfies, for all $T \geq 1$:
$$\mathbb{E}[f_{\beta,\eta}(x_T) - f_{\beta,\eta}^\star] \;\geq\; \frac{\kappa(\beta,\eta)}{2}\cdot\frac{LD^2}{T}.$$

**(B) Variance term provably absent.** No constant $c > 0$ achieves
$$\mathbb{E}[f(x_T) - f^\star] \;\geq\; c\cdot\frac{\sigma D}{\sqrt T}\quad\forall T \geq 1$$
for every $\sigma > 0$, every $L$-smooth convex $f$, every $\mathcal{O} \in \mathcal{N}_{\mathrm{int}}(\sigma^2; \rho_1)$, and every $(\beta, \eta) \in \mathcal{S}$. Concretely: $f(x) = (L/2)\|x\|^2$ with multiplicative noise oracle $\xi_t = \sigma\|x_t\|\varepsilon_t$, SHB at $(\beta=0, \eta=1/(2L))$, satisfies for $\sigma < L\sqrt 3$:
$$\mathbb{E}[f(x_T)] \;\leq\; \frac{LD^2}{2}\cdot\left(\frac{1+\sigma^2/L^2}{4}\right)^T,$$
exponential decay — beats any polynomial $\Omega(\sigma D/\sqrt T)$ for $T$ large.

## Difficulty
research (extension of OP-2; clean two-part argument)
