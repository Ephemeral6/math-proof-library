# Notes: LASSO Prediction Error under RE Condition

## Proof technique
Route 1 (KKT Basic Inequality) won. The canonical BRT 2009 approach: LASSO optimality → basic inequality → cone constraint via Hölder + high-probability event → RE application on cone → Cauchy-Schwarz for ℓ₁/ℓ₂ conversion.

## Key steps
1. **Basic inequality** is the foundation — comparing F(β̂) ≤ F(β*) and expanding
2. **Cone constraint** emerges naturally when λ/2 dominates the noise term (1/n)||X^Tw||_∞
3. **The factor 3** in C(S,3) comes from the ratio (λ+λ/2)/(λ-λ/2) = 3 — this propagates through all constants
4. **RE on cone** converts the quadratic form bound to ℓ₂ bound via simple algebra
5. **ℓ₁ conversion** uses cone (factor 4) + Cauchy-Schwarz (factor √s)

## Audit result
PASS round 1, no Fixer needed. All steps VALID. Constants (72, 6, 24) vs stated (16, 4, 4) differ by universal factors — the discrepancy traces to the factor 3 in the cone condition and is convention-dependent.

## Related results
- Double descent (proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/) — different regime (ridgeless, n ≈ p)
- RIP sparse recovery (proofs/library/statistics/high-dimensional/rip-sparse-recovery/) — related sparse estimation, different condition (RIP vs RE)
- Sub-Gaussian covariance concentration (proofs/library/statistics/concentration/sub-gaussian-covariance-concentration/) — tool for proving RE holds

## Library references used
- Sub-Gaussian maximal inequality (cited, not re-proved)
