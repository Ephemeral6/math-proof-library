# Notes: OFUL Linear Bandit Regret

## Proof technique
Route 4 (Martingale-First) won. Self-normalized bound proved from first principles via mixture martingale method.

Key insight: Define M_t = ∫L_t(θ)p(θ)dθ with Gaussian prior. Completing the square yields closed form. Sub-Gaussian MGF gives exact cancellation in supermartingale step. Ville's inequality gives uniform-in-time bound.

## Key steps
1. **Mixture martingale**: L_t(θ) with A_t (not V_t!), prior N(0,R²/λ·I) adds λI to form V_t
2. **Complete the square**: M_t = (λ^{d/2}/det(V_t)^{1/2}) · exp(‖S_t‖²_{V_t^{-1}}/(2R²))
3. **Supermartingale**: exact cancellation exp(⟨a_t,θ⟩²/(2R²)) from noise MGF
4. **Ville's inequality**: uniform-in-time P(∃t: M_t ≥ 1/δ) ≤ δ
5. **Elliptical potential**: x ≤ 2ln(1+x) for x∈[0,1] under λ ≥ L²

## Audit result
- Round 1 FAIL: β_t simplification wrong for d=1; L_t double-counted λ; λ≥L² undeclared
- Round 2 PASS: all 5 fixes verified

## Related results
- EXP3 adversarial bandit [proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/]
- OGD regret bound [proofs/library/optimization/convergence/ogd-regret-bound/]
- Matrix Bernstein [proofs/library/statistics/concentration/matrix-bernstein-inequality/]
