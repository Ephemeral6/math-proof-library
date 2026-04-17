# Notes: NTK Infinite-Width Convergence

## Proof technique
Route 4 (Schur Product + Matrix Bernstein) won. The key insight is the Schur product lemma: ‖M∘G‖_op ≤ ‖M‖_op for PSD G with unit diagonal, which eliminates the Gram matrix entirely from the operator norm bound. This is proved via the decomposition vᵀ(M∘G)v = Σ_ℓ q_ℓᵀMq_ℓ with the weights summing to 1.

## Key steps
1. Schur product lemma absorbs the Gram matrix G (the structural reason the n factor arises from ‖sₖ‖², not from G)
2. Matrix Bernstein gives log(n) dependence (better than entry-wise union bound's log(n²))
3. The factor n in the bound comes from ‖Aₖ‖_op = ‖sₖ‖² ≤ n‖σ'‖²_∞

## Audit result
PASS on first round. Minor: unstated m ≥ Ω(log(n/δ)) condition, loose variance bound.

## Related results
- Extends proof #2 (NTK Gram matrix positive definiteness): this quantifies HOW FAST the empirical NTK approaches the limit
- Together they form the NTK proof chain: convergence rate (#12) + positive definiteness (#2)
- The O(n/√m) rate shows width m = O(n²/ε²) suffices for ε-approximation
