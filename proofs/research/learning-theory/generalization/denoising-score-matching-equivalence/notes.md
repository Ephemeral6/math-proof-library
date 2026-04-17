# Notes: Denoising Score Matching Equivalence

## Proof technique
Expand both objectives, show θ-dependent terms match via score-of-mixture identity (Bayes' rule).

## Key steps
1. Both objectives share A(θ) = (1/2)E[||s_θ||²] 
2. Cross terms B(θ) and D(θ) related by ∇log q_σ = E_{p(y|x)}[∇log p(x|y)]
3. Bayes swap: q_σ(x)p(y|x) = p_data(y)p(x|y) converts integration order

## Related results
- Foundation of score-based diffusion models (Song & Ermon 2019, Ho et al. 2020)
- Vincent (2011) original denoising score matching
- Tweedie's formula: E[y|x] = x + σ²∇log q_σ(x)
