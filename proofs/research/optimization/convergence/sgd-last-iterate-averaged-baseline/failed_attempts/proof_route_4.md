# Route 4: Suffix Average + Last-Iterate Concentration in 1D

## Route Failure Report (for last-iterate goal)

**Phase A (SUCCESS):** With η = D/(G√T), suffix average x̄ = (2/T)Σ_{t=T/2}^{T-1} x_t satisfies:
E[f(x̄) - f*] ≤ 3DG/(2√T) = O(1/√T)

**Phase B (FAILURE):** Cannot show E[|x_T - x̄|] = O(1/√T). With step size η = D/(G√T), each step changes x_t by O(D/√T), but over T/2 steps the iterates perform a bounded random walk with std dev O(D), so |x_T - x̄| = O(D). The 1D structure does not help because the iterates explore the full domain. Cauchy-Schwarz, domain-splitting, and direct second-moment approaches all give O(D), not O(1/√T).

**Phase C (BLOCKED):** Cannot combine since Phase B failed.

**Obstacle:** The last iterate does not concentrate around the suffix average at rate better than O(D).
