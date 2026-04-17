# Frank-Wolfe (Conditional Gradient) O(1/k) Convergence Rate

## Source
- Paper: Frank & Wolfe 1956; Jaggi 2013 (ICML) "Revisiting Frank-Wolfe: Projection-Free Sparse Convex Optimization"
- Context: Projection-free optimization over compact convex sets; the Frank-Wolfe algorithm replaces projections with linear minimization oracles

## Statement

**Theorem.** Let $f: \mathbb{R}^d \to \mathbb{R}$ be convex and $L$-smooth (i.e., $\nabla f$ is $L$-Lipschitz), and let $\mathcal{D} \subset \mathbb{R}^d$ be a compact convex set with diameter $\text{diam}(\mathcal{D}) = \max_{x,y \in \mathcal{D}} \|x - y\| \leq D$.

The Frank-Wolfe algorithm with step size $\gamma_t = \frac{2}{t+2}$:

$$s_t = \arg\min_{s \in \mathcal{D}} \langle \nabla f(x_t), s \rangle$$
$$x_{t+1} = x_t + \gamma_t (s_t - x_t)$$

satisfies:

$$f(x_t) - f(x^*) \leq \frac{2LD^2}{t+2}, \quad \forall t \geq 1$$

where $x^* = \arg\min_{x \in \mathcal{D}} f(x)$.

## Difficulty
research
