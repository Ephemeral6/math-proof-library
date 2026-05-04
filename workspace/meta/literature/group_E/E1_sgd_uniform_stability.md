# E1: SGD Uniform Stability Generalization

**Path**: `proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/`
**Source**: Hardt-Recht-Singer 2016 (arXiv 1509.01240)

## Verdict: CONFIRMED

## Our claim
For convex L-smooth losses, step sizes alpha_t <= 2/beta:
- epsilon_stab <= (2 L^2 / n) * sum_{t=1}^T alpha_t
- |E[R(w_T)] - E[R_S(w_T)]| <= 2 L^2 alpha T / n  (constant step size)

## Literature comparison
HRS Theorem 3.7 (convex case) gives precisely this bound. The proof uses:
- Co-coercivity / Baillon-Haddad: I - eta * grad g is non-expansive when g convex L-smooth, eta <= 2/L
- Recursive coupling on (S, S^(j))
- Bousquet-Elisseeff (2002) stability => generalization

Our 6-step proof matches HRS line-by-line. Step-size condition (alpha_t <= 2/beta), the perturbation
inequality at swap step (2 alpha_t L), and the telescoping sum are all standard.

## Discrepancies
None. This is a verbatim reconstruction of the canonical HRS argument.

## Confidence: HIGH
Classical result, proof is textbook-level and correct.
