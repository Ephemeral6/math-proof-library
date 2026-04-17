# Notes: TD(0) Linear Approximation O(1/T) Rate

## Proof technique
Stochastic approximation with non-symmetric Hurwitz matrix. Key: A_s = (A+A^T)/2 ≥ (1-γ)Φ^T D_π Φ gives the effective strong convexity. Lyapunov w_t = (c+t)v_t proves O(1/T).

## Key steps
1. A_s positive definite via Cauchy-Schwarz on transition operator
2. Error recursion with i.i.d. independence
3. Scalar MSE recursion v_{t+1} ≤ (1-2αμ+α²L²)v_t + α²σ²
4. Lyapunov w_t = (c+t)v_t bounded → v_T = O(1/T)

## Audit result
8.5/10 — all four lemmas rigorous. The A_s lower bound and Lyapunov argument are clean.

## Related results
- Q-learning convergence (proofs/research/optimization/convergence/synchronous-q-learning-finite-time/) — control (max) version
- SGD convergence rates (proofs/library/optimization/stochastic/sgd-convex-convergence-rate/) — similar SA structure
- Policy gradient theorem (proofs/library/optimization/convergence/policy-gradient-theorem/) — RL optimization
