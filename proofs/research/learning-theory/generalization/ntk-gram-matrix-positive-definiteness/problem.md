# NTK Gram Matrix Positive Definiteness

## Source
- Paper: Du, Zhai, Poczos, Singh (2019). "Gradient Descent Finds Global Minima of Deep Neural Networks." ICML 2019.
- Context: Foundation for proving GD convergence on overparameterized neural networks

## Statement
For a two-layer ReLU network with $n$ training points $\|x_i\| = 1$, $x_i \neq \pm x_j$, the infinite-width NTK Gram matrix $H^\infty_{ij} = \mathbb{E}_{w \sim N(0,I)}[x_i^T x_j \cdot \mathbf{1}\{w^T x_i \geq 0, w^T x_j \geq 0\}]$ is positive definite.

## Difficulty
research
