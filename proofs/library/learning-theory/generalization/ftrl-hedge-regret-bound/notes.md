# Notes: FTRL/Hedge Regret Bound

## Proof technique
Potential function (exponential weights) approach. Uses unnormalized weights W_t = Σ w_{t,i} as potential, upper-bounds via e^{-x} ≤ 1-x+x², lower-bounds by picking off best expert.

## Key steps
1. Multiplicative update closed form from KKT conditions
2. Potential ratio W_{t+1}/W_t bounded via Lemma A (e^{-x} ≤ 1-x+x²)
3. ln(1+x) ≤ x to convert ratio to sum
4. Lower bound by single expert weight → ln d / η term
5. Second-order term bounded by η·T using ℓ_{t,i}² ≤ 1
6. Optimize η = √(ln d / T) → 2√(T ln d)

## Audit result
Direct verification — proof is textbook-clean, all steps rigorous. 9/10.

## Related results
- OGD regret bound (proofs/library/optimization/convergence/ogd-regret-bound/) — gradient descent counterpart
- Mirror descent online regret (proofs/library/optimization/mirror-descent/mirror-descent-online-regret-bound/) — generalization via Bregman
- Online-to-batch conversion (proofs/library/learning-theory/generalization/online-to-batch-conversion/) — converting online bounds to batch
