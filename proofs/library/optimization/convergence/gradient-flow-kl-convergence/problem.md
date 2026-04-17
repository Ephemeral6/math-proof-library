# Gradient Flow Convergence under Kurdyka-Łojasiewicz Inequality

## Source
- Paper: Bolte, Daniilidis, Lewis (2007) "Clarke subgradients of stratifiable functions"; Kurdyka (1998) "On gradients of functions definable in o-minimal structures"
- Context: Classification of gradient flow convergence rates by KL desingularizing exponent

## Statement

Consider the gradient flow ODE:
$$\dot{x}(t) = -\nabla f(x(t))$$
where $f: \mathbb{R}^n \to \mathbb{R}$ is $C^1$ and satisfies the Kurdyka-Łojasiewicz inequality with desingularizing function $\varphi(s) = cs^{1-\theta}$ for $\theta \in [0,1)$, i.e., near any critical point $x^*$ with $f(x^*) = f^*$:
$$c(1-\theta)(f(x)-f^*)^{-\theta} \|\nabla f(x)\| \geq 1 \quad \text{whenever } f(x) > f^*.$$

Prove the convergence trichotomy:

1. **$\theta = 0$**: The trajectory has finite length and converges in finite time.
2. **$\theta \in (0, 1/2]$**: Linear (exponential) convergence: $f(x(t)) - f^* \leq Ce^{-\alpha t}$.
3. **$\theta \in (1/2, 1)$**: Polynomial convergence: $f(x(t)) - f^* \leq Ct^{-1/(2\theta-1)}$.

## Difficulty
research
