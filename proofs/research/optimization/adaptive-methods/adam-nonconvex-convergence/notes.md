# Notes: Adam Non-Convex Convergence

## Proof technique
Descent lemma + polarization identity + horizon-dependent learning rate. The polarization identity elegantly decomposes the adaptive inner product into gradient norm minus momentum error.

## Key steps
1. β₁²≤β₂ ensures |[D_t]_i|≤1, giving ||D_t||²≤d (dimension factor origin)
2. Polarization identity avoids messy momentum decomposition
3. L-smoothness bounds momentum error ||g_t-m̂_t||² via path length
4. log T from harmonic series Σ1/t and momentum error's ln(T) factor
5. α=α₀T^{-1/4} (horizon-dependent) absorbs momentum bias

## Audit result
PASS on first round. All steps valid.

## Related results
- AdaGrad convergence (same paper, simpler case)
- AMSGrad (Reddi et al. 2018) — different fix for Adam's issues
- β₁²≤β₂ condition first identified by Reddi et al. 2018
