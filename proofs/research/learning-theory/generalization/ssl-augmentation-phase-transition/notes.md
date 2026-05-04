# Notes: SSL Augmentation Phase Transition

## Proof technique

Direct eigen-decomposition of the block-structured population kernel matrix
K = (1-ρ)B + ρJ on regular-simplex cluster geometry. Block structure gives a
3-eigenvalue spectrum: n[1+(k-1)ρ], n(1-ρ) (mult k-1), 0 (mult k(n-1)).

The "magic" of the simplex setup: pairwise distances are all equal,
so off-diagonal blocks of K are constant, allowing the very clean eigen-decomposition.

## Key steps

1. **Convolution identity.** E_{ξ,ξ'}[exp(-||μ-μ'+ξ-ξ'||²/(2dτ²))] ∝ exp(-||μ-μ'||²/(2dτ_eff²))
   with τ_eff² = τ² + 2σ_aug². This gives the Gaussian kernel a clean σ_aug dependence.

2. **Block decomposition.** Splitting K-eigenvectors into:
   - constant vector (cluster-mean direction): largest eigenvalue n[1+(k-1)ρ].
   - between-cluster zero-sum: eigenvalue n(1-ρ), multiplicity k-1.
   - within-cluster zero-sum: eigenvalue 0.

3. **σ_aug* via threshold criterion.** g(σ_aug*) = const ⇒ τ_eff*² = Δ_min²/(2d·c)
   ⇒ σ_aug* = Θ(Δ_min/√d). The key √d enters through the d-normalized kernel
   bandwidth (or equivalently the typical norm σ_aug√d of d-dim isotropic noise).

4. **Honest refutation of (c).** The gap g(σ_aug) is real-analytic, so no jump.
   The numerical experiments confirm bounded derivatives.

## Audit result

- SymPy spectrum match: PASS.
- Numerical continuity: PASS (gap is smooth).
- Scaling confirmation: ratio mean 0.601, std 0.014 across 12 (d, Δ_min) pairs (CoV 2.3%).
- Rank at extremes: PASS (k at small σ, 1 at large σ).

No fixer round needed. Verdict: PARTIAL — (a),(b),(d) PASS; (c) REFUTED.

## Related results

- **HaoChen, Wei, Gaidon, Ma 2021** ("Provable Guarantees for Self-Supervised
  Deep Learning with Spectral Contrastive Loss"): justifies the connection
  between optimal contrastive representation and top eigenvectors of the
  augmentation graph adjacency matrix.
- **Wang & Isola 2020** ("Understanding Contrastive Representation Learning
  through Alignment and Uniformity"): related order parameters, but
  no phase transition analysis.
- **Baik, Ben Arous, Péché 2005** (BBP transition): used in Route 2 to confirm
  finite-sample analog; also second-order.
- **Spectral gap of equicorrelated Gaussian kernel matrix**: a special case of
  the (1-ρ)I + ρJ structure, classical in covariance-matrix analysis.

## Honest takeaway

The conjecture's "first-order phase transition" framing is wrong for the
natural Gaussian model. The honest result is:
- Smooth second-order spectral transition.
- σ_aug* = Θ(Δ_min/√d), correctly identified by the conjecture.
- True first-order transition requires either d → ∞ scaling limit, or
  non-analytic structures not present in the original model.

This kind of "the conjecture got the scaling right but the order wrong"
finding is itself a useful research output.
