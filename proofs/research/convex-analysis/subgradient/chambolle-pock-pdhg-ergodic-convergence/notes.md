# Notes: Chambolle-Pock PDHG O(1/N) Ergodic Convergence

## Proof technique
Route 2 (Monotone Operator / VI Reformulation) won. The proof reformulates the saddle-point problem as a monotone inclusion 0 ∈ (A+B)(z), views PDHG as a preconditioned proximal-point method, and uses the Schur complement to show M≻0 ⟺ τσL²<1. The per-step bound uses a telescoping cross-term decomposition with Young's inequality (α=σ) to absorb all coupling terms.

## Key steps
1. **Monotone inclusion setup**: A = product subdifferential (maximally monotone), B = skew-symmetric coupling (linear, monotone). Sum is maximally monotone by Rockafellar's theorem.
2. **Schur complement**: M = [[1/τ I, -K*]; [-K, 1/σ I]] ≻ 0 ⟺ τσL² < 1. This makes the step-size condition structural rather than ad hoc.
3. **Coupling decomposition**: S_K^n = ⟨K(x^{n+1}-x̄^n), y-y^{n+1}⟩ decomposes into a telescoping bracket + remainder ⟨K(x^n-x^{n-1}), y^{n+1}-y^n⟩.
4. **Young's with α=σ**: Absorbs the y-squared residual exactly, leaving x-squared terms with coefficient (σL²/2 - 1/(2τ)) < 0.
5. **Boundary term**: BT = ⟨K(x^N-x^{N-1}), y-y^N⟩ bounded by Young's, combined with IT gives -(1-τσL²)/(2τ)Σa_n ≤ 0.

## Audit result
PASS on first round. All 5 steps VALID. Numerical verification passed for all parameter sets.

## Related results
- Closely related to Douglas-Rachford splitting (proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/) — PDHG can be viewed as a primal-dual DR variant
- Extragradient method (proofs/library/convex-analysis/subgradient/extragradient-convex-concave-minimax/) uses similar telescoping + Jensen pattern
- ADMM ergodic convergence (proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/) uses He-Yuan framework, same family of proofs
- Proximal point convergence (proofs/library/convex-analysis/subgradient/proximal-point-convergence-monotone/) is the foundation — PDHG is a preconditioned variant
