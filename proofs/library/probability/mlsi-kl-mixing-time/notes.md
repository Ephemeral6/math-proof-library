# Notes: MLSI → KL Mixing Time

## Proof technique
Continuous-time semigroup analysis: compute d/dt D_KL via generator, apply MLSI to get differential inequality, solve via Gronwall.

## Key steps
1. f_t = dν_t/dμ satisfies ∂_t f_t = Lf_t (reversibility)
2. d/dt D_KL = -E_D(f_t, ln f_t) (detailed balance symmetrization)
3. MLSI: E_D(f, ln f) ≥ 2α · Ent_μ(f) = 2α · D_KL
4. Gronwall → exponential decay

## Audit result
9/10 — clean, self-contained proof with all steps justified.

## Related results
- Langevin KL convergence (proofs/library/probability/langevin-kl-convergence-log-sobolev/) — continuous-space analogue
- Hoeffding inequality (proofs/library/statistics/concentration/hoeffding-inequality/) — used in discrete analysis
