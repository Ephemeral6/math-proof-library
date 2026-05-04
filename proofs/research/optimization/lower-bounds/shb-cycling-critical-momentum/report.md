# Final Report — Problem M3: Sharp Phase Transition at β* = (√13 − 3)/2

## Status

**PASS**, audit rounds = 0.

## Five-phase summary

### Phase 1 — Scout
Strategic plan: reduce to the algebraic inequality $(\dagger_K)$ via the small-κ envelope of GTD-cyc, factor the polynomial $G(\beta, c) = 2(\beta-c)(1+\beta) - (1-c)(1+\beta^2-2\beta c)$, parametrize by $u = 1 - c$, prove monotonicity of $\varphi(u) = \sqrt{u^2+1} - u$, and minimize over the discrete set $\{c_K : K \geq 3\}$.

### Phase 2 — Explorer
Single algebraic route: factor $G(\beta, c) = (1+c)[\beta^2 + 2(1-c)\beta - 1]$, solve the quadratic, monotonicity argument. Verified by SymPy. No alternative route needed since the problem reduces to a polynomial identity plus monotonicity of one variable.

### Phase 3 — Judge
Single coherent route, no contradiction with literature, all reductions justified. Approved for audit.

### Phase 4 — Auditor
15 attack vectors checked (factorization, sign analysis, quadratic root selection, monotonicity in two variables, K=2 exclusion, boundary singleton, negative control sweep K=3..1000, etc.). All pass. Match with OP-2's existing K=3 derivation confirmed (`proof.md` line 102: $\beta^2 + 3\beta - 1 \geq 0$, root $(\sqrt{13}-3)/2$).

### Phase 5 — Fixer
Not invoked (audit PASS in round 0).

## Core technique

Polynomial factorization $G = (1+c)\cdot Q_c$, separating the sign-controlling factor from the discriminant-controlling factor; then minimize $\beta_+(c) = \sqrt{(1-c)^2+1} - (1-c)$ over the discrete set $\{c_K\}_{K \geq 3}$ via monotonicity of $\varphi(u) = 1/(\sqrt{u^2+1}+u)$.

## Result

$$
\beta^\star \;=\; \inf_{K \geq 3, \eta \in \mathcal{S}_\beta} \{\beta : (\beta, \eta) \in \mathcal{F}_K\} \;=\; \frac{\sqrt{13} - 3}{2} \;\approx\; 0.3027756377,
$$
attained uniquely at $K = 3$, $\eta = 2(1 + \beta^\star)/L$ (single boundary point at the upper edge of the SHB stability region).

For $\beta > \beta^\star$: $K = 3$ realizes a non-degenerate $\eta$-interval $[\gamma_3(\beta)/L, 2(1+\beta)/L]$ with $\gamma_3(\beta) = 3(1+\beta+\beta^2)/(1+2\beta)$.

For $\beta < \beta^\star$: no $K \geq 3$ admits any feasible $\eta$, since $\beta_{\min}(c_K) > \beta^\star > \beta$ for all $K$.

## Numerical verification

Script `verify.py` (committed alongside proof). All 7 checks pass:

1. Symbolic factorization (SymPy): `G − (1+c)[β² + 2(1−c)β − 1] = 0` ✓
2. Quadratic root formula matches `sympy.solve` output ✓
3. Monotonicity of $\varphi$: $\varphi'(u) = u/\sqrt{u^2+1} - 1 < 0$, alt form $-1/[\sqrt{u^2+1}(\sqrt{u^2+1}+u)]$ ✓
4. $\beta_{\min}(K)$ for $K = 3, 4, \ldots, 1000$: minimum at $K = 3$, value matches $(\sqrt{13}-3)/2$ to $2.2 \times 10^{-16}$ ✓
5. Boundary equality at $\beta^\star$, K=3, $\eta = 2(1+\beta^\star)/L$: LHS − RHS = $-4.4 \times 10^{-16}$ ✓
6. Negative control: $\beta = \beta^\star - 10^{-8}$ infeasible at every $K \in \{3, \ldots, 1000\}$ ✓
7. Positive control: $\beta = \beta^\star + 10^{-6}$ feasible at $K = 3$ with margin $+2.25 \times 10^{-6}$ ✓

## Time used

~25 minutes (well under 1.5 h budget).

## Honest assessment

This is an algebraic identity at heart: factor a degree-2 polynomial in (β, c), recognize that one factor sign-controls and the other minimizes via a basic monotonicity. The K=3 special case was already explicit in OP-2 (the quadratic $\beta^2 + 3\beta - 1 \geq 0$ appears in OP-2 `proof.md` line 102), but **was never proved sharp over $K \geq 3$**: OP-2 only stated that $\mathcal{F}$ contains the K=3 region for $\beta \geq \beta^\star$ and remarked that "at higher K, $\mathcal{F}$ expands" — without verifying that this expansion never reaches below $\beta^\star$. M3 closes this gap rigorously: K=3 is the unique witnessing K and $\beta^\star$ is therefore a sharp threshold.

## Archive plan

- Class: A (research-level meta-result on a 2023 paper's construction; novel sharpness claim absent from the original GTD23 work).
- Branch: `optimization/lower-bounds`.
- Folder: `proofs/research/optimization/lower-bounds/shb-cycling-critical-momentum/`.
- Files: `problem.md`, `proof.md`, `report.md`, `notes.md`, `verify.py`, `audit.md`.
