# Notes: Douglas-Rachford Splitting Convergence

## Proof technique
Operator-theoretic: firm nonexpansivity of resolvents → averaged operator structure of T_DR → Fejér monotonicity → Opial's weak convergence theorem.

## Key steps
1. Resolvent J_A is firmly nonexpansive (from monotonicity of A)
2. Reflected resolvent R_A = 2J_A - I is nonexpansive
3. T_DR = (I + R_B R_A)/2 is averaged, hence firmly nonexpansive
4. Fix(T_DR) ↔ zer(A+B) via resolvent unwinding
5. Weak convergence via Fejér monotonicity + demiclosedness + Opial

## Audit result
8.5/10 — all five parts rigorous, clean operator-theoretic argument.

## Related results
- ADMM ergodic convergence (proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/) — ADMM is dual DR splitting
- Proximal point convergence (proofs/library/convex-analysis/subgradient/proximal-point-convergence-monotone/) — special case A=0
- Moreau envelope smoothness (proofs/library/convex-analysis/subgradient/moreau-envelope-smoothness/) — resolvent properties
