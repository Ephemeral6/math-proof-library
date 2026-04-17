# TD(0) with Linear Function Approximation: O(1/T) Convergence Rate

## Source
- Paper: Bhandari, Russo, Singal (2018); Srikant & Ying (2019)
- Context: Finite-time analysis of temporal difference learning with function approximation

## Statement
TD(0) with linear features ||φ(s)|| ≤ 1, i.i.d. sampling, step size α_t = c/(c+t):
$$\mathbb{E}[\|\theta_T - \theta^*\|^2] \leq \frac{C}{T}$$
where C = O(σ²/μ²), μ = (1-γ)λ_min(Φ^T D_π Φ).

## Difficulty
research
