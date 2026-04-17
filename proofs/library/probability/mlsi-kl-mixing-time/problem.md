# MLSI Implies Exponential KL Decay for Reversible Markov Chains

## Source
- Paper: Diaconis & Saloff-Coste (1996); Martinelli (1999)
- Context: Fundamental inequality connecting log-Sobolev constants to MCMC mixing times

## Statement
If μ satisfies MLSI with constant α for a reversible chain, then:
$$D_{\text{KL}}(\nu P_t \| \mu) \leq e^{-2\alpha t} D_{\text{KL}}(\nu \| \mu)$$
Mixing time: $t_{\text{mix}}(\epsilon) \leq \frac{1}{2\alpha}\left(\ln\ln\frac{1}{\mu_{\min}} + \ln\frac{1}{\epsilon}\right)$.

## Difficulty
advanced
