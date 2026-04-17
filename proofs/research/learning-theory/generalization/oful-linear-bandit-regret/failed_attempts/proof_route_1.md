# Route 1: Four-Step OFUL

## Proof Summary
Four-lemma chain: (1) Confidence ellipsoid via mixture martingale, (2) Optimism from UCB, (3) Cauchy-Schwarz on regret sum, (4) Elliptical potential lemma.

Key: Mixture martingale M_t = ∫L_t(θ)p(θ)dθ with Gaussian prior, completing the square yields M_t = (det(λI)/det(V_t))^{1/2} exp(‖S_t‖²_{V_t^{-1}}/(2R²)). Supermartingale by sub-Gaussian MGF cancellation. Ville's inequality gives uniform-in-time bound.

Result: Regret(T) ≤ 2β_T√(2Td ln(1+TL²/(λd)))

Note: Explorer wrote proof to a separate file path. Core proof structure is complete.
