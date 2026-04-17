# Notes: EXP3 Adversarial Bandit Regret

## Proof technique
Direct potential + importance weighting. Single route, no alternatives needed.

## Key steps
1. Importance-weighted estimates are unbiased: E[ℓ̂_t(i)] = ℓ_t(i)
2. Exponential weights potential telescoping: log(W_{t+1}/W_t) ≤ -η⟨p̃_t, ℓ̂_t⟩ + η²/2⟨p̃_t, ℓ̂_t²⟩
3. Variance ≤ K/(1-γ) from p̃_t(i)/p_t(i) ≤ 1/(1-γ) — the key structural bound
4. Mixing cost γT from switching p_t to p̃_t
5. Three-term bound: ln(K)/η + ηKT + γT, each = √(KT ln K) at optimal params

## Audit result
PASS round 1, no Fixer needed. All algebraic steps verified. Constants 3 = 1+1+1.

## Related results
- OGD regret bound (proofs/library/optimization/convergence/ogd-regret-bound/) — full-information online learning analog
- Mirror descent regret (proofs/library/optimization/mirror-descent/mirror-descent-online-regret-bound/) — full-info, Bregman framework
- McAllester PAC-Bayes (proofs/library/learning-theory/pac/mcallester-pac-bayes-bound/) — also uses exponential weights + Donsker-Varadhan
