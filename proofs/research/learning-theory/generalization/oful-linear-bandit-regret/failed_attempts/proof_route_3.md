# Route 3: Potential-First / Bottom-Up (Log-Det Telescoping)

## Proof

Built entirely from elliptical potential as central object:

**Lemma 1 (Matrix Determinant Lemma):** det(V_t)/det(V_{t-1}) = 1 + ‖a_t‖²_{V_{t-1}^{-1}}. Proved via rank-1 update eigenvalue.

**Lemma 2 (Log-Det Telescoping):** ∑_t ln(1+‖a_t‖²_{V_{t-1}^{-1}}) = ln det(V_T) - ln det(V_0). Telescoping.

**Lemma 3 (Log-Det Upper Bound):** ln det(V_T) - ln det(V_0) ≤ d ln(1+TL²/(λd)). By Jensen/AM-GM on eigenvalues with tr(V_T) ≤ λd + TL².

**Lemma 4 (Elliptical Potential):** ∑_t min(1, ‖a_t‖²_{V_{t-1}^{-1}}) ≤ 2d ln(1+TL²/(λd)). Key inequality: min(x,1) ≤ 2ln(1+x) for x≥0, proved case-by-case.

**Corollary:** ∑_t min(1, ‖a_t‖_{V_{t-1}^{-1}}) ≤ √(2Td ln(1+TL²/(λd))) via Cauchy-Schwarz.

**Confidence Ellipsoid (Lemma 5):** Self-normalized bound + triangle inequality → ‖θ̂_t - θ*‖_{V_t} ≤ β_t.

**Optimism (Lemma 6):** UCB ≥ true optimal value via confidence set containment.

**Assembly:** reg_t ≤ 2β_t‖a_t‖_{V_{t-1}^{-1}}, monotonicity β_t ≤ β_T, Cauchy-Schwarz + potential.

Under λ ≥ L² (so ‖a_t‖²_{V_{t-1}^{-1}} ≤ 1): ∑f_t ≤ 2ln(det(V_T)/det(V_0)) directly.

Result: Regret(T) ≤ 2β_T√(2Td ln(1+TL²/(λd)))
