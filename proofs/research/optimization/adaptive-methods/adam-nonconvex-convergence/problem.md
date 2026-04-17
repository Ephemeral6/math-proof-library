# Adam Optimizer Non-Convex Convergence

## Source
- Paper: Défossez, Bottou, Bach, Usunier (2022). "A Simple Convergence Proof of Adam and Adagrad." TMLR 2022.
- Context: First simple, clean convergence proof for Adam in the non-convex setting

## Statement
Adam with β₁²≤β₂, L-smooth f, ||∇f||_∞≤G, α_t=α₀t^{-1/2}T^{-1/4} satisfies:
$$\min_{1 \leq t \leq T}\|\nabla f(x_t)\|^2 \leq O\!\left(\frac{d \cdot \log T}{\sqrt{T}}\right)$$

## Difficulty
advanced
