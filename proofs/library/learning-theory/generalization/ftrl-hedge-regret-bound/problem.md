# FTRL/Hedge Regret Bound: O(√(T ln d)) for Online Linear Optimization

## Source
- Paper: Vovk (1990); Littlestone & Warmuth (1994); Freund & Schapire (1997)
- Context: Foundational result in online learning / expert prediction

## Statement

The Multiplicative Weights / Hedge algorithm (FTRL with negative entropy regularizer) with $\eta = \sqrt{\ln d / T}$ achieves regret:
$$R_T \leq 2\sqrt{T \ln d}$$
for online linear optimization over the $d$-simplex against adaptive adversaries with $\ell_t \in [0,1]^d$.

## Difficulty
advanced
