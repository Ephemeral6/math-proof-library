# Matrix Rényi Entropy and Representation Collapse Detection

## Source

- Paper: SSL representation collapse / Matrix-SSL line (e.g., Matrix Information Theory for SSL, 2023+).
- Context: Diagnosing representation collapse in self-supervised learning (SimCLR, Barlow-Twins) via spectral entropy of the kernel matrix K = F F^T / tr(F F^T).

## Statement

For α > 0, α ≠ 1 and PSD K ∈ R^{n×n} with tr(K) = 1, define the **matrix Rényi entropy of order α**:

S_α(K) = (1/(1-α)) log tr(K^α).

**(a)** S_α(K) = 0 iff rank(K) = 1 (complete representation collapse).

**(b)** S_α(K) ≤ log n with equality iff K = I_n / n.

**(c)** Under hypotheses (H1)–(H3) on the SSL loss L_MSSL — namely that L_MSSL has a critical point F* with K(F*) = I_n/n, is locally μ-strongly convex with μ = λ_min(∇²L_MSSL) > 0, and its gradient is aligned with the entropy-ascent direction R(K) F (with constant κ > 0) — the gradient flow Ḟ = -∇_F L_MSSL satisfies, on a neighborhood of F*,

dS_α(K(F))/dt ≥ c · (log n - S_α(K(F))) · μ

with explicit c = c(α, ε, κ/μ) > 0 (asymptotically c → 2(κ/μ)/(α) as the neighborhood ε → 0).

## Difficulty

research

## Conventions

- log: natural logarithm.
- ||·||_*: nuclear norm. For PSD M, ||M||_* = tr(M).
- For α < 1, an additional regularity (H4) is needed: K(F(t)) full-rank along the trajectory.
