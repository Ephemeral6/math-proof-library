# SGD with Stochastic Polyak Step-size Convergence Rate

## Source
- Paper: Loizou, Vaswani, Laradji, Lacoste-Julien (2021). "Stochastic Polyak Step-size for SGD: An Adaptive Learning Rate for Fast Convergence." AISTATS 2021.
- Context: Convergence rate of SGD with adaptive Polyak step-size under interpolation

## Statement
Consider $\min_x f(x) = \mathbb{E}[f_i(x)]$ where each $f_i$ is convex, $L$-smooth, and interpolation-consistent ($f_i(x^*) = 0$ for all $i$). With $\gamma_k = \frac{f_{i_k}(x_k)}{c \|\nabla f_{i_k}(x_k)\|^2}$, $c \geq 1$, SGD satisfies:

$$\mathbb{E}[f(\bar{x}_T)] \leq \frac{2cL \|x_0 - x^*\|^2}{T}$$

## Difficulty
advanced
