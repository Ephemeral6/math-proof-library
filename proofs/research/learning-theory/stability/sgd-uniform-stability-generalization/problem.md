# SGD Uniform Stability and Generalization Bound

## Source
- Paper: Hardt, Recht, Singer (2016/2021). "Train faster, generalize better: Stability of stochastic gradient descent." ICML 2016.
- Context: Foundational result connecting SGD optimization speed to generalization via algorithmic stability

## Statement
SGD on convex, β-smooth, L-Lipschitz loss with α_t ≤ 2/β satisfies:
- Uniform stability: ε_stab ≤ (2L²/n) Σ_{t=1}^T α_t
- Generalization gap: |E[R(w_T)] - E[R_S(w_T)]| ≤ 2L²αT/n (constant step size)

## Difficulty
advanced
