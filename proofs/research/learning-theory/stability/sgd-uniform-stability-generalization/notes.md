# Notes: SGD Uniform Stability and Generalization

## Proof technique
Recursive coupling (Hardt-Recht-Singer). Run two SGD copies on neighboring datasets with the same random indices. Track expected parameter distance.

## Key steps
1. Co-coercivity of convex β-smooth functions → non-expansive gradient step when α ≤ 2/β
2. Differing data point hit with prob 1/n → drift 2αL per step
3. Additive recurrence δ_{t+1} ≤ δ_t + 2α_tL/n (no multiplicative growth due to convexity)
4. Lipschitz conversion from parameter distance to function value stability
5. Bousquet-Elisseeff symmetrization for stability → generalization

## Audit result
PASS. All 6 steps valid. Classical and clean.

## Related results
- Non-convex extension: multiplicative factor (1-αμ) or (1+αβ) in recurrence
- Strongly convex case: exponential contraction gives O(1/n) stability independent of T
- Feldman-Vondrak (2019): tighter bounds via information-theoretic stability
- Lei-Ying (2020): last-iterate stability bounds
