# Douglas-Rachford Splitting: O(1/k) Convergence for Monotone Inclusions

## Source
- Paper: Lions & Mercier (1979), "Splitting Algorithms for the Sum of Two Nonlinear Operators"
- Modern analysis: Bauschke & Combettes (2017), "Convex Analysis and Monotone Operator Theory"
- Rate analysis: Davis & Yin (2016), "Convergence Rate Analysis of Several Splitting Schemes"
- Context: Douglas-Rachford splitting is a fundamental algorithm for solving 0 ∈ (A+B)x where A and B are maximal monotone operators. The O(1/k) ergodic convergence rate for the operator residual was established in the modern splitting literature.

## Statement

Let $\mathcal{H}$ be a real Hilbert space. Let $A, B: \mathcal{H} \rightrightarrows \mathcal{H}$ be maximal monotone operators such that $\mathrm{zer}(A+B) \neq \emptyset$ (the set of solutions to $0 \in Ax + Bx$ is nonempty).

**Douglas-Rachford Splitting (DRS)**: Given step size $\gamma > 0$ and initial point $z_0 \in \mathcal{H}$, iterate:

$$x_k = J_{\gamma B}(z_k), \quad y_k = J_{\gamma A}(2x_k - z_k), \quad z_{k+1} = z_k + y_k - x_k$$

where $J_{\gamma A} = (\mathrm{Id} + \gamma A)^{-1}$ is the resolvent (proximal) operator.

Equivalently, defining the **DRS operator** $T_{\mathrm{DR}} = \mathrm{Id} + J_{\gamma A}(2J_{\gamma B} - \mathrm{Id}) - J_{\gamma B}$, the iteration is $z_{k+1} = T_{\mathrm{DR}}(z_k)$.

**Theorem (O(1/k) Ergodic Convergence)**: Under the above assumptions:

1. $T_{\mathrm{DR}}$ is **firmly nonexpansive** (FNE), i.e., for all $z, z' \in \mathcal{H}$:
$$\|T_{\mathrm{DR}}(z) - T_{\mathrm{DR}}(z')\|^2 + \|(z - T_{\mathrm{DR}}(z)) - (z' - T_{\mathrm{DR}}(z'))\|^2 \leq \|z - z'\|^2$$

2. The **fixed-point residual** converges at rate $O(1/k)$:
$$\|z_k - z_{k-1}\|^2 = \|T_{\mathrm{DR}}(z_{k-1}) - z_{k-1}\|^2 \leq \frac{\mathrm{dist}(z_0, \mathrm{Fix}(T_{\mathrm{DR}}))^2}{k}$$

3. The sequence $\{x_k\}$ converges weakly to a point in $\mathrm{zer}(A+B)$.

## Difficulty
research

## Key Intermediate Results to Prove

1. **Resolvent properties**: $J_{\gamma A}$ is firmly nonexpansive for any maximal monotone $A$ and $\gamma > 0$. [Can reference proofs/library/convex-analysis/subgradient/proximal-point-convergence-monotone/ for related results]

2. **DRS operator is FNE**: Compose the resolvents and reflections to show $T_{DR}$ inherits firm nonexpansiveness.

3. **Fejér monotonicity**: $\|z_{k+1} - z^*\|^2 \leq \|z_k - z^*\|^2 - \|z_{k+1} - z_k\|^2$ for any fixed point $z^* \in \mathrm{Fix}(T_{DR})$.

4. **Telescoping for O(1/k) rate**: Sum the Fejér inequality to get $\sum_{k=0}^{K-1} \|z_{k+1}-z_k\|^2 \leq \|z_0 - z^*\|^2$, then use the minimum to extract the $O(1/k)$ rate.

5. **Connection to primal problem**: Show $\mathrm{Fix}(T_{DR}) \neq \emptyset$ iff $\mathrm{zer}(A+B) \neq \emptyset$, and the primal iterates $x_k = J_{\gamma B}(z_k)$ converge weakly to a solution.
