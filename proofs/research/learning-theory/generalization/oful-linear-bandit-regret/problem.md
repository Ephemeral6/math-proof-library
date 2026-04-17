# OFUL Linear Bandit Regret Bound

## Source
- Paper: Abbasi-Yadkori, Pal & Szepesvari, "Improved Algorithms for Linear Stochastic Bandits", NeurIPS 2011
- Context: Optimal regret for linear bandits via optimism + self-normalized concentration

## Statement
Linear bandit with OFUL algorithm achieves, w.p. ≥ 1-δ:
$$\text{Regret}(T) \leq 2\beta_T\sqrt{2Td\ln(1+TL^2/(\lambda d))}$$
where $\beta_T = R\sqrt{d\ln(1+TL^2/(\lambda d)) + 2\ln(1/\delta)} + \sqrt{\lambda}S$.

Rate: $\tilde{O}(d\sqrt{T})$.

## Difficulty
research
