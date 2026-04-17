# Notes: Tweedie's Formula and Denoising Score Matching

## Proof technique
Direct computation + Bayes' rule + completing the square.

## Key steps
1. p_σ(x) > 0 everywhere (Gaussian convolution)
2. Leibniz/DCT justification for ∇_x under integral (finite second moment → domination)
3. Gaussian score identity: ∇_x φ_σ(x-y) = -(x-y)/σ² φ_σ(x-y)
4. Bayes' rule: ∇ log p_σ = (E[Y|X=x] - x)/σ² — the core Tweedie identity
5. Noise form: = -(1/σ)E[ε|X=x]
6. Denoising loss = Fisher divergence + constant via completing the square

## Audit result
PASS round 1. All measure-theoretic conditions verified (DCT, Bayes, tower property).

## Related results
- Denoising score matching equivalence (proofs/research/learning-theory/generalization/denoising-score-matching-equivalence/) — proves DSM=ISM, different from Tweedie
- Langevin KL convergence (proofs/library/probability/langevin-kl-convergence-log-sobolev/) — sampling from score
