# Gradient Descent Ascent (GDA) for Nonconvex-Strongly-Concave Minimax: $O(\kappa^2 \epsilon^{-2})$ Stationarity

## Source
- **Paper**: T. Lin, C. Jin, M. I. Jordan, *"On Gradient Descent Ascent for Nonconvex-Concave Minimax Problems"*, ICML 2020.
- **Context**: Analyzes the simplest minimax algorithm — alternating / simultaneous gradient descent ascent — for the nonconvex-strongly-concave setting. Bridges classical saddle-point theory and modern nonconvex optimization, resolving the question of whether GDA converges without extragradient-style corrections. The bound $O(\kappa^2 \epsilon^{-2})$ shows GDA has the same rate as GDA-with-extragradient up to condition-number factors, for this class.

## Statement

**Setting**. Consider the minimax problem
$$\min_{x \in \mathbb{R}^d} \max_{y \in \mathbb{R}^m} f(x, y),$$
where $f : \mathbb{R}^d \times \mathbb{R}^m \to \mathbb{R}$ satisfies:
- **(A1) $L$-smoothness**: $\nabla f$ is $L$-Lipschitz, i.e., $\|\nabla f(x,y) - \nabla f(x',y')\| \le L \|(x,y) - (x',y')\|$.
- **(A2) $\mu$-strong concavity in $y$**: for each fixed $x$, $y \mapsto f(x,y)$ is $\mu$-strongly concave, i.e., $-f(x, \cdot)$ is $\mu$-strongly convex.
- **(A3) Bounded initial gap**: $\Phi(x_0) - \min_x \Phi(x) \le \Delta$, where $\Phi(x) := \max_y f(x, y)$ is the primal function.

Let $\kappa := L/\mu$ denote the condition number of the inner problem.

**Two-Time-Scale GDA Algorithm**:
$$x_{t+1} = x_t - \eta_x \nabla_x f(x_t, y_t), \qquad y_{t+1} = y_t + \eta_y \nabla_y f(x_t, y_t),$$
with step sizes $\eta_x = \Theta(1/(\kappa^2 L))$ and $\eta_y = \Theta(1/L)$.

**Key quantity**: The *primal function* $\Phi(x) := \max_y f(x, y)$ is well-defined under (A2) and, by Danskin's theorem, smooth with $\nabla \Phi(x) = \nabla_x f(x, y^*(x))$ where $y^*(x) = \arg\max_y f(x, y)$.

**Lemma (Lipschitz smoothness of $\Phi$)**: Under (A1), (A2), $\Phi$ is $\kappa L$-smooth, i.e., $\nabla \Phi$ is $\kappa L$-Lipschitz.

**Target theorem** (simplified version from Lin-Jin-Jordan 2020, Theorem 4.4).

Under (A1), (A2), (A3), let $\{(x_t, y_t)\}_{t=0}^{T-1}$ be the iterates of two-time-scale GDA with $\eta_x = 1/(16 \kappa^2 L)$ and $\eta_y = 1/L$. Then
$$\boxed{\;\frac{1}{T}\sum_{t=0}^{T-1} \mathbb{E}\left[\|\nabla \Phi(x_t)\|^2\right] \le \frac{C_1 \kappa^2 L \Delta}{T} + C_2 \kappa^2 L \cdot \frac{\|y_0 - y^*(x_0)\|^2}{T},\;}$$
for absolute constants $C_1, C_2 > 0$.

**Corollary**: To achieve $\frac{1}{T}\sum_t \|\nabla\Phi(x_t)\|^2 \le \epsilon^2$, it suffices to run
$$T = O\left(\frac{\kappa^2 L \Delta + \kappa^2 L \|y_0 - y^*(x_0)\|^2}{\epsilon^2}\right) = O(\kappa^2 \epsilon^{-2})$$
iterations (absorbing $\Delta, L$ constants). This matches the known lower bound for nonconvex-strongly-concave minimax up to $\kappa$ factors.

**Interpretation**:
- The $\kappa^2$ factor reflects the "two-time-scale" structure: the slow $x$-step (with step $\eta_x = O(1/\kappa^2 L)$) must wait for the fast $y$-step to track $y^*(x_t)$.
- Without extragradient corrections, pure GDA converges to a stationary point of $\Phi$ (not necessarily a saddle point of $f$), hence the bound is on $\|\nabla\Phi\|^2$.
- Tighter $O(\kappa \epsilon^{-2})$ rate is possible with extragradient (Mokhtari-Ozdaglar-Pattathil 2020) but requires additional machinery.

## Difficulty
**research**

## Key intermediate results to prove

1. **Smoothness of $\Phi$**: $\Phi(x) = \max_y f(x, y)$ is $\kappa L$-smooth. Use Danskin's theorem + implicit function theorem, or a direct argument via the proximal / contraction properties of $y^*$.

2. **Contraction of inner maximizer tracking**: Define the "tracking error" $\delta_t := \|y_t - y^*(x_t)\|^2$. Show that one step of $y$-ascent contracts:
$$\|y_{t+1} - y^*(x_t)\|^2 \le (1 - 2\eta_y \mu + \eta_y^2 L^2) \|y_t - y^*(x_t)\|^2.$$
Combined with the bound $\|y^*(x_{t+1}) - y^*(x_t)\| \le \kappa \|x_{t+1} - x_t\|$ (Lipschitzness of $y^*$), this gives a recursion for $\delta_t$.

3. **Descent lemma for $\Phi$**: Using the $\kappa L$-smoothness,
$$\Phi(x_{t+1}) \le \Phi(x_t) - \eta_x \nabla \Phi(x_t)^\top \nabla_x f(x_t, y_t) + \frac{\kappa L \eta_x^2}{2} \|\nabla_x f(x_t, y_t)\|^2.$$
The first-order term is $\eta_x \nabla\Phi(x_t)^\top[\nabla_x f(x_t, y_t) - \nabla\Phi(x_t)] - \eta_x \|\nabla\Phi(x_t)\|^2$. Control the cross-term via $\|y_t - y^*(x_t)\|$.

4. **Combined Lyapunov function**: Define $V_t := \Phi(x_t) + c \cdot \delta_t$ for a suitable constant $c > 0$ (depending on $\kappa$, $L$, $\eta_x$, $\eta_y$). Show $V_{t+1} \le V_t - (\eta_x/2) \|\nabla \Phi(x_t)\|^2 + (\text{lower-order})$.

5. **Telescope and conclude**: Summing the descent inequality over $t = 0, \ldots, T-1$ and using $V_0 - V_T \le \Delta + c\|y_0 - y^*(x_0)\|^2$ gives the final bound.
