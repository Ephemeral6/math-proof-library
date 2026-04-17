# Quantitative Universal Approximation for ReLU Networks

## Source
- Paper: Yarotsky 2017 ("Error bounds for approximations with deep ReLU networks"), Bach 2017 ("Breaking the Curse of Dimensionality with Convex Neural Networks")
- Context: Quantitative version of the universal approximation theorem for ReLU networks. Establishes explicit neuron count scaling for approximating Lipschitz functions.

## Statement

Let $f: [0,1]^d \to \mathbb{R}$ be Lipschitz with constant $L$: $|f(x) - f(y)| \leq L\|x-y\|_\infty$.

There exists a two-layer ReLU network $\hat{f}(x) = \sum_{j=1}^N a_j \sigma(w_j^\top x + b_j)$ with $\sigma(z) = \max(0,z)$ and $N = O((L/\varepsilon)^d)$ neurons such that:

$$\sup_{x \in [0,1]^d} |f(x) - \hat{f}(x)| \leq \varepsilon$$

Moreover, the network weights satisfy $\|w_j\|_\infty = O(L)$ and $|b_j| = O(L)$.

## Difficulty
research
