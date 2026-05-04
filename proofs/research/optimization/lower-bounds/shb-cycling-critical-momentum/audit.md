# Audit Report — Proof of M3 Sharp Threshold

**Auditor mode**: adversarial line-by-line.
**Date**: 2026-04-26.
**Target**: `proof.md`.

## Scope

Verify that the proof of $\beta^\star = (\sqrt{13} - 3)/2$ is rigorous, with no logical gaps, computational errors, sign errors, or unjustified assumptions.

## Attack 1 — Algebraic factorization (Lemma 1)

**Claim**: $2(\beta - c)(1 + \beta) - (1 - c)(1 + \beta^2 - 2\beta c) = (1 + c)[\beta^2 + 2(1 - c)\beta - 1]$.

**Check**:
- LHS expansion: $2\beta + 2\beta^2 - 2c - 2c\beta - 1 - \beta^2 + 2c\beta + c + c\beta^2 - 2c^2\beta = (1+c)\beta^2 + 2\beta(1 - c^2) - (1 + c) - $ wait, let me redo carefully.
  - Term-by-term: $2(\beta - c)(1 + \beta) = 2\beta + 2\beta^2 - 2c - 2c\beta$.
  - $(1 - c)(1 + \beta^2 - 2\beta c) = (1 + \beta^2 - 2\beta c) - c(1 + \beta^2 - 2\beta c) = 1 + \beta^2 - 2\beta c - c - c\beta^2 + 2\beta c^2$.
  - Subtract: $[2\beta + 2\beta^2 - 2c - 2c\beta] - [1 + \beta^2 - 2\beta c - c - c\beta^2 + 2\beta c^2]$
    $= 2\beta + 2\beta^2 - 2c - 2c\beta - 1 - \beta^2 + 2\beta c + c + c\beta^2 - 2\beta c^2$.
  - Combine: $\beta^2$ coeff: $2 - 1 + c = 1 + c$. $\beta$ coeff: $2 - 2c + 2c - 2c^2 = 2 - 2c^2 = 2(1-c)(1+c)$. Constant: $-2c - 1 + c = -1 - c = -(1 + c)$.
  - So LHS $= (1+c)\beta^2 + 2(1-c)(1+c)\beta - (1+c) = (1+c)[\beta^2 + 2(1-c)\beta - 1]$. ✓
- SymPy in `verify.py` step 1: `G − (1+c)[β² + 2(1−c)β − 1] = 0`. ✓

**Verdict**: Factorization correct.

## Attack 2 — Sign of $1 + c_K$ for $K \geq 3$

**Claim**: $1 + c_K > 0$ for all $K \geq 3$.

**Check**: $c_K = \cos(2\pi/K)$. For $K = 3$, $c_3 = -1/2$, $1 + c_3 = 1/2 > 0$. For $K \geq 3$, $2\pi/K \in (0, 2\pi/3]$, so $c_K \geq c_3 = -1/2$, so $1 + c_K \geq 1/2 > 0$. ✓

(The proof requires $1 + c_K \neq 0$ to divide; we have $1 + c_K \geq 1/2$.)

**Verdict**: Sign assumption justified.

## Attack 3 — Direction of inequality preserved when dividing by $1 + c_K$

The factorization gives $G(\beta, c) = (1+c) \cdot Q_c(\beta)$. We have $G(\beta, c) \geq 0 \Leftrightarrow Q_c(\beta) \geq 0$ since $1 + c > 0$. ✓

**Verdict**: Direction preserved correctly.

## Attack 4 — Solving the quadratic $Q_c(\beta) = 0$

**Claim**: Roots are $\beta_\pm = -(1 - c) \pm \sqrt{(1-c)^2 + 1}$, with $\beta_- < 0 < \beta_+$.

**Check**:
- Discriminant: $4(1-c)^2 + 4 = 4[(1-c)^2 + 1] > 0$. ✓ Two real roots.
- $\beta_+ \cdot \beta_- = -1 < 0$ (Vieta: product of roots = constant term = $-1$). So one positive, one negative. ✓
- $\beta_+ = -(1-c) + \sqrt{(1-c)^2 + 1} > 0$ since $\sqrt{(1-c)^2 + 1} > |1-c| \geq 1 - c$ (taking $u = 1 - c$, this is $\sqrt{u^2 + 1} > u$ for $u > 0$, and for $c \geq 1$ we'd need $1 - c \leq 0$ which is fine too). ✓
- For $\beta \geq 0$ and parabola opening upward, $Q_c(\beta) \geq 0 \Leftrightarrow \beta \leq \beta_-$ or $\beta \geq \beta_+$. Since $\beta_- < 0 \leq \beta$, the first option is impossible, so $Q_c(\beta) \geq 0 \Leftrightarrow \beta \geq \beta_+$. ✓

**Verdict**: Quadratic analysis correct.

## Attack 5 — Monotonicity of $\varphi(u) = \sqrt{u^2+1} - u$

**Claim**: $\varphi$ strictly decreasing on $(0, \infty)$.

**Check**: $\varphi(u) = 1/(\sqrt{u^2+1} + u)$ via rationalization. The denominator is the sum of two strictly increasing functions $u \mapsto \sqrt{u^2+1}$ (positive derivative) and $u \mapsto u$ (positive derivative), hence strictly increasing. Reciprocal of a strictly positive strictly increasing function is strictly decreasing. ✓

Also confirmed numerically: $\varphi(0.1) = 0.905$, $\varphi(1.0) = 0.414$, $\varphi(1.5) = 0.303$, $\varphi(5.0) = 0.099$, $\varphi(100) = 0.005$ — monotonically down. ✓

**Verdict**: Monotonicity correct.

## Attack 6 — Monotonicity of $K \mapsto u_K = 1 - c_K$

**Claim**: For $K \geq 3$, $u_K$ is strictly decreasing in $K$.

**Check**: $u_K = 1 - \cos(2\pi/K)$. Let $g(K) := 2\pi/K$ for $K \geq 3$, $g$ strictly decreasing in $K$, $g(K) \in (0, 2\pi/3] \subset (0, \pi)$. On $(0, \pi)$, cosine is strictly decreasing, so $\cos(g(K))$ is strictly increasing in $K$, so $u_K = 1 - \cos(g(K))$ is strictly decreasing. ✓

**Hence**: $u_3 > u_4 > u_5 > \ldots > 0$, with $u_K \to 0$ as $K \to \infty$.

Numerical: $u_3 = 1.5, u_4 = 1.0, u_5 \approx 0.691, u_6 = 0.5, u_{10} \approx 0.191, u_{100} \approx 0.00197$. ✓

**Verdict**: Monotonicity in K verified.

## Attack 7 — Combined: $\beta_{\min}(c_K) = \varphi(u_K)$ is strictly increasing in K

By Lemma 3 ($\varphi \downarrow$) composed with $K \mapsto u_K$ (strictly $\downarrow$), $K \mapsto \varphi(u_K)$ is strictly increasing.

**Hence**: $\inf_K \beta_{\min}(c_K) = \beta_{\min}(c_3)$, attained uniquely at $K = 3$.

Numerical confirmation: K=3 gives 0.3028, K=4 gives 0.4142, K=5 gives 0.5245, ..., K=1000 gives 0.99998. Strictly increasing in K. ✓

**Verdict**: K=3 is the global minimizer over K ≥ 3.

## Attack 8 — Does $K = 2$ give a smaller minimum?

The problem restricts $K \geq 3$. But let's check what would happen at $K = 2$: $c_2 = \cos\pi = -1$, $1 + c_2 = 0$, so the factorization $G = (1+c) Q_c$ becomes $G(\beta, -1) = 0$ trivially. The original inequality $(\dagger_2)$: $(1 - (-1))(1 + \beta^2 - 2\beta(-1)) = 2(1 + \beta + \beta)^2 = 2(1 + \beta)^2 \leq 2(\beta - (-1))(1 + \beta) = 2(1+\beta)^2$. Equality holds for ALL $\beta$, which would suggest $K = 2$ "feasibility" for all $\beta$. But $K = 2$ is a 2-cycle (degenerate, just oscillation between two points), not the polygonal cycle GTD23 constructs (their construction requires $K \geq 3$ to define a non-degenerate simplex). Hence $K = 2$ is correctly excluded by the problem statement.

**Verdict**: $K = 2$ exclusion is consistent with GTD23 and the problem statement; doesn't affect $\beta^\star$.

## Attack 9 — Boundary point $\beta = \beta^\star$ and its unique $\eta$

At $\beta = \beta^\star$ and $K = 3$, $\eta_{\min}(\beta^\star, 3) = 2(1 + \beta^\star)/L = $ stability upper bound. So the feasible $\eta$-interval is the singleton $\{2(1+\beta^\star)/L\}$. This is a closed interval (single point) included in $\mathcal{S}$ since $\eta \leq 2(1+\beta)/L$ is non-strict. ✓

Numerical: at $\beta^\star = 0.3028$, $\gamma_3(\beta^\star) = 2.6056 = 2(1+\beta^\star)$. ✓ (Match to 4 decimals.)

**Verdict**: Boundary point handled correctly.

## Attack 10 — Negative control

`verify.py` step 6: For $\beta \in \{\beta^\star - 10^{-3}, \beta^\star - 10^{-4}, \beta^\star - 10^{-6}, \beta^\star - 10^{-8}\}$, no $K \in \{3, \ldots, 1000\}$ yields feasibility. ✓

**Verdict**: Empirical infeasibility below $\beta^\star$ confirmed up to K = 1000. The analytic argument extends to all K ≥ 3 since $\beta_{\min}(c_K) \uparrow 1$.

## Attack 11 — $\beta_{\min}(c) > c$ aside used in Section 7

**Claim** (used in §7 of proof): $\beta_{\min}(c) > c$ for all $c \in (-1, 1)$.

**Check**: At $\beta = c$, $Q_c(c) = c^2 + 2(1-c)c - 1 = c^2 + 2c - 2c^2 - 1 = -c^2 + 2c - 1 = -(c-1)^2 = -(1-c)^2 \leq 0$. Equality iff $c = 1$. For $c \in (-1, 1)$, $Q_c(c) < 0$. Since $Q_c$ is a parabola with positive leading coefficient and $Q_c(\beta_+) = 0$ with $\beta_+ > 0$, the inequality $Q_c(c) < 0$ implies $c$ lies strictly between the two roots, hence $c < \beta_+$. ✓

**Verdict**: Justified.

## Attack 12 — $\beta < 1$ requirement (stability region restricts $\beta \in [0, 1)$)

For $K = 3$, $\beta^\star \approx 0.3028 < 1$. ✓

For $K \to \infty$, $\beta_{\min}(c_K) \to \varphi(0^+) = 1$ from below. So all $\beta_{\min}(c_K) < 1$ for $K < \infty$. ✓ The infimum over $K$ is attained at $K = 3$ at $\beta^\star < 1$.

**Verdict**: Compatible with stability region.

## Attack 13 — Alternative reduction (sanity)

Verify the K=3 algebraic derivation (problem statement gave it explicitly):
- RHS $= (3/2)(1 + \beta + \beta^2)$.
- LHS bound $= 2(\beta + 1/2)(1 + \beta) = 2\beta^2 + 3\beta + 1$.
- Difference: $2\beta^2 + 3\beta + 1 - (3/2)(1 + \beta + \beta^2) = (2 - 3/2)\beta^2 + (3 - 3/2)\beta + (1 - 3/2) = (1/2)\beta^2 + (3/2)\beta - 1/2$.
- Multiply by 2: $\beta^2 + 3\beta - 1$.
- Roots: $\beta = (-3 \pm \sqrt{13})/2$. Positive root $\beta^\star = (\sqrt{13} - 3)/2 \approx 0.3028$. ✓

Matches Section 7 of OP-2's `proof.md` (line 102) and the problem statement's K=3 derivation. ✓

**Verdict**: K=3 reduction matches OP-2 paper and problem statement exactly.

## Attack 14 — Did the proof avoid the $\kappa \to 0^+$ limit assumption issue?

The original GTD-cyc inequality is at general $\kappa \in (0, 1)$. The "smallest β" inf is taken over all $(\kappa, \eta, K)$. Taking $\kappa \to 0^+$ recovers (β−c)Lη ≥ (1−c)(1+β²−2βc) (the small-κ limit). This is the LEAST RESTRICTIVE form: any $(\beta, \eta)$ satisfying GTD-cyc at some $\kappa > 0$ also satisfies the small-κ limit (the inequality becomes weaker as κ ↓ 0; equivalently, the κ-thresholds shrink the feasible set). Hence the small-κ limit is a NECESSARY condition for GTD-cyc to hold at any κ > 0. So if we show $(\star_K)$ has no solution for $\beta < \beta^\star$, then no $\kappa > 0$ instance does either.

Conversely, for $\beta > \beta^\star$ the small-κ limit is feasible, and OP-2 §2.1 shows that for such (β, η) there exists a positive measure of $\kappa$ values that satisfy the full GTD-cyc inequality (the κ-feasibility interval is non-empty whenever (β, η) lies in the κ↓0 limit interior). So our inf is indeed achieved by the small-κ limit, and the threshold β* coincides for both formulations.

**Verdict**: The reduction to the small-κ limit is a valid envelope: $\bigcup_{\kappa > 0} \mathcal{F}_K(\kappa) = \mathcal{F}_K(\kappa = 0^+)$ (relative interior; at boundary, equality up to closure). The threshold β* is invariant.

## Attack 15 — Have we used the SHB stability bound η ≤ 2(1+β)/L correctly?

Yes: the question asks for the smallest β such that there exists $\eta \in (0, 2(1+\beta)/L]$ satisfying $(\star_K)$ at some $K \geq 3$. Without the upper bound on η, any β > c_K would be trivially feasible (just take η large enough). The stability bound is what creates the non-trivial threshold β*.

**Verdict**: Stability bound essential and correctly applied.

## Summary of audit

| Attack | Status |
|---|---|
| 1. Algebraic factorization | PASS |
| 2. Sign $1 + c_K > 0$ | PASS |
| 3. Direction of inequality preserved | PASS |
| 4. Quadratic roots | PASS |
| 5. Monotonicity of $\varphi$ | PASS |
| 6. Monotonicity of $K \mapsto u_K$ | PASS |
| 7. K=3 minimizes | PASS |
| 8. K=2 exclusion | PASS |
| 9. Boundary point | PASS |
| 10. Negative control | PASS |
| 11. $\beta_{\min}(c) > c$ aside | PASS |
| 12. $\beta < 1$ compatibility | PASS |
| 13. K=3 sanity vs OP-2 paper | PASS |
| 14. Small-κ limit reduction | PASS |
| 15. Stability bound usage | PASS |

## Verdict

**PASS** — no gaps found.

The proof is correct, complete, and minimal. All algebraic steps are verified symbolically (SymPy). All monotonicity claims are verified analytically AND numerically. The boundary point and edge cases are handled. The final value $\beta^\star = (\sqrt{13} - 3)/2$ is sharp, achieved uniquely at $K = 3$, with the unique witnessing $\eta = 2(1 + \beta^\star)/L$ at the boundary of the SHB stability region.

No fixer round needed.
