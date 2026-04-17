# Douglas-Rachford Splitting: Weak Convergence for Monotone Inclusions

## Source
- Paper: Lions & Mercier (1979); Eckstein & Bertsekas (1992)
- Context: Operator splitting for finding zeros of sums of maximal monotone operators

## Statement
For maximal monotone $A, B$ with $\text{zer}(A+B) \neq \emptyset$, the DR iterate $x_{t+1} = x_t + J_B(2J_A x_t - x_t) - J_A x_t$ satisfies:
1. $T_{DR}$ is firmly nonexpansive
2. $\{x_t\}$ converges weakly to $x^* \in \text{Fix}(T_{DR})$
3. Shadow $\{J_A(x_t)\}$ converges weakly to $z^* \in \text{zer}(A+B)$

## Difficulty
advanced
