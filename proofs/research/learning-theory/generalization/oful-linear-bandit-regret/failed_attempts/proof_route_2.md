# Route 2: Ridge Error Decomposition

## Proof

Decomposes θ̂_t - θ* = V_t^{-1}S_t - λV_t^{-1}θ* (noise + bias). Self-normalized bound as black-box gives ‖S_t‖_{V_t^{-1}} ≤ R√(d ln((1+tL²/λ)/δ)). Bias bounded by √λS via V_t ≥ λI. Triangle inequality gives confidence ellipsoid.

Optimism: UCB(a_t) ≥ UCB(a*_t) ≥ ⟨a*_t, θ*⟩. Instantaneous regret ≤ 2β_t‖a_t‖_{V_{t-1}^{-1}}.

Elliptical potential: Struggled with ∑‖a_t‖²_{V_{t-1}^{-1}} ≤ 2 ln det(V_T/V_0) — requires x ≤ 2ln(1+x) which holds for x ≤ 1. Noted need for λ ≥ L² or min-clipping. Eventually resolved with standard approach under λ ≥ L².

Result: Regret(T) ≤ 2β_T√(2Td ln(1+TL²/(λd)))
