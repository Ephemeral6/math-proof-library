# Notes: SGD under PL + Interpolation with Iterate Averaging

## Proof technique
Route 5 (Direct Recursion + Induction) won. The proof establishes a scalar one-step recursion e_{t+1} ≤ α_t · e_t and solves it by induction.

## Key steps
1. **L-smoothness descent + strong growth** gives the fundamental inequality (D)
2. **PL converts gradient norm to function gap**, yielding α_t = 1 - 2μγ_t + ρLμγ_t²
3. **Part (a)**: γ = 1/(ρL) makes α = 1 - μ/(ρL), giving geometric convergence
4. **Part (b)**: Induction proves e_t ≤ t_0²/(t+t_0)² · e_0 — a **1/t² per-iterate rate**
5. The inductive step reduces to verifying a polynomial inequality P(s) ≥ 0, confirmed by P(t_0) > 0 and P'(s) > 0 for s ≥ t_0
6. **Averaging via Jensen** (f convex) converts 1/t² pointwise to O(t_0/T) averaged rate

## Audit result
PASS on first round. All steps valid. The proof's robustness comes from the clean multiplicative noise structure: under interpolation, variance ∝ f(x)-f* (no additive σ²), which is why the per-iterate rate achieves 1/t² rather than the usual 1/t.

## Rate clarification
- With ε₀ = f(x_0)-f*: rate is O(ρL/(μT) · ε₀)
- With ε₀ = ||∇f(x_0)||²: rate is O(ρL/(μ²T) · ε₀) via PL conversion
- The 1/t² per-iterate rate is STRONGER than what the averaged bound captures
- All 5 explorers independently derived the same rate, confirming it is correct

## Related results
- Vaswani et al. (2019): SGD under interpolation + strong growth
- Loizou et al. (2021): SPS-SGD convergence (already in the library)
- Polyak-Ruppert averaging: classical technique for asymptotic normality
- The two-phase approach: linear phase removes bulk of error, averaging phase achieves faster polynomial rate
