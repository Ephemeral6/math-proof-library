# NTK Infinite-Width Convergence Rate

## Source
- Paper: Du et al. 2019 / Arora et al. 2019 (NTK theory)
- Context: Quantitative convergence of empirical NTK to infinite-width limit

## Statement

For a two-layer network f(x;θ) = (1/√m)Σⱼ aⱼσ(wⱼᵀx) with aⱼ ~ Uniform({±1}) fixed,
wⱼ ~ N(0,I_d), and σ Lipschitz with bounded derivative, define:

  Θ̂ₘ(xᵢ,xⱼ) = (1/m) Σₖ σ'(wₖᵀxᵢ) σ'(wₖᵀxⱼ) (xᵢᵀxⱼ)
  Θ∞(xᵢ,xⱼ) = E_w[σ'(wᵀxᵢ) σ'(wᵀxⱼ)] (xᵢᵀxⱼ)

For ‖xᵢ‖=1, with probability ≥ 1-δ:

  ‖Θ̂ₘ - Θ∞‖_op ≤ C · ‖σ'‖²_∞ · n · √(log(n/δ)/m)

## Difficulty
research
