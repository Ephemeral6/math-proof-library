# Notes — First-order convergence to general (non-strict) local minimax optima

## Verdict

**PARTIAL.** The literal Chae–Kim–Kim COLT 2023 open problem is **NOT FULLY RESOLVED**. The pipeline delivers Outcome 3 (Partial) of `problem.md` only: convergence to a (general, possibly non-strict) local minimax optimum **under the additional assumption that the inner problem $f(x, \cdot)$ satisfies a Polyak–Łojasiewicz inequality** (with separation gap, in the sense of Karimi–Nutini–Schmidt 2016).

## Proof technique

**Winning route**: Orthodox (Frame 4). Two-timescale GDA with the Lyapunov $V_t = \Phi(x_t) + c \delta_t$, $c = 1/2$, $\delta_t = \Phi(x_t) - f(x_t, y_t)$, step ratio $\eta_x / \eta_y = 1/(32\kappa^2 L)$ where $\kappa = L/\mu$.

## Key steps

1. **Lemma 1**: Under inner-PL ($\mu > 0$), $y \mapsto f(x, y)$ has a $\kappa$-Lipschitz argmax map $y^*(\cdot)$ via Karimi–Nutini–Schmidt 2016 (Theorem 2 + Proposition 4). This **REPLACES** the implicit-function-theorem argument that requires strict-Hessian non-degeneracy.
2. **Lemma 2**: Danskin's theorem still gives $\Phi(x) := f(x, y^*(x))$ as $2\kappa L$-smooth.
3. **Descent inequality**: $V_{t+1} \le V_t - (\eta_x / 8) \|\nabla \Phi(x_t)\|^2 - 2 \eta_x L \kappa \delta_t$ (the boxed (LD*); the descent constant is $2\eta_x L\kappa$, NOT the typo $4\eta_x L\kappa$).
4. **Telescoping**: $\frac{1}{T} \sum_{t < T} \|\nabla \Phi(x_t)\|^2 \le 256\kappa^2 L (\Delta + \delta_0) / T$, i.e., $\varepsilon$-stationarity in $T = O(L^3 / (\mu^2 \varepsilon^2))$ gradient queries.
5. **Linear rate** under additional outer-PL: $V_T \le \rho^T V_0$ with $\rho = 1 - \mu_x / (128 \kappa^2 L)$.
6. **Quantitative basin radius**: $r := \min\{r_0, \sqrt{(V^* - \Phi^*)/(\kappa L)}, \sqrt{2(V^* - \Phi^*)/\mu}\}$.

## Audit result

- **Round 1**: Mixed verdict.
  - Part A (Construction with $f(x,y) = \frac12 x^2 y^2 - \frac14 y^4$ as a putative impossibility witness) **FAILED**. Direct numerical integration of the GDA flow from initial conditions in the cusp set $T = \{|y_0| < c x_0^2, x_0 \neq 0\}$ shows trajectories converging to $(0, 0)$ at sub-geometric rate $\|z_t\| \sim t^{-1/2}$. The proof's load-bearing claim "$\int_0^\infty y_s^2 \, ds < \infty$" was unjustified and is in fact violated: $y_s^2 \sim t^{-1}$ asymptotically, so the integral diverges.
  - Part B (Orthodox PARTIAL POSITIVE under inner-PL) **PASSED** with one typo fix ($2\eta_x L \kappa$ vs $4\eta_x L \kappa$ in the descent constant).
- **Round 2**: PASS PARTIAL. Part A genuinely removed, Part B verified self-consistently. F4 progress check passes.

## Six-frame outcome summary

| Frame | Verdict | Contribution |
|---|---|---|
| Construction | FAIL (numerically refuted in audit) | Cusp-set trajectory converges to $(0,0)$; only measure-zero failure on the axis |
| Naive | FAIL (predicted) | Lemma C contraction rate collapses when inner Hessian = 0 |
| Adversarial | PARTIAL (proves stronger statement) | Le Cam $f^\pm$ pair: TV = 0, Bayes-error $1/2$; but proves "converge AND certify second minimax" — strictly stronger than CKK literal |
| **Orthodox** | **WINNER (PARTIAL POSITIVE)** | $T = O(L^3 / (\mu^2 \varepsilon^2))$ under inner-PL |
| Reduction | PARTIAL | Moreau-Yosida regularization; structural assumption $(\dagger)$ fails on $f = x^2 y$ |
| Compositional | FAIL | Three-timescale FD-Hessian fails on $f = x^2 y$ |

## Why CKK 2023 remains open

- The Construction explicit-instance impossibility was only valid measure-zero (the axis-stuck argument), insufficient for "generic initialization" CKK formulation.
- The Adversarial Le Cam impossibility proves a strictly stronger statement (an algorithm that always outputs $(0,0)$ on the indistinguishable pair $\{f^+, f^-\}$ would still satisfy CKK literal).
- The Orthodox PARTIAL POSITIVE works only under inner-PL, which is violated by canonical examples like $f(x, y) = x^2 y$.

The literal CKK question — whether ANY first-order method converges to ANY general (non-strict) local minimax under bare $C^2$ regularity — remains OPEN.

## Knowledge Reuse Hooks fired

- Layer 1: ogda-bilinear-last-iterate, gda-nonconvex-strongly-concave-convergence — chassis transferred for Part B.
- Layer 2: FP-GDA-NONSTRICTNESS (confirmed on Naive route), FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE (TRIGGER-CONFIRMED on Construction route), FP-IFT-BREAK (avoided in Part B by PL+QG-based Lipschitzness).
- Layer 4: Cluster D Le Cam family informed Adversarial route.
- Layer 5: MT3 (Couple-and-Track) fits Part B chassis.

## Related results

- `proofs/research/optimization/convergence/ogda-bilinear-last-iterate/` — sibling saddle-point Lyapunov.
- `proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/` — chassis for the strongly-concave inner case.
- Karimi–Nutini–Schmidt 2016 "Linear Convergence of Gradient and Proximal-Gradient Methods Under the Polyak–Łojasiewicz Condition" — external citation for PL+QG.

## Failure-pattern entries (new)

Two new failure-trigger candidates extracted in this run:
- `FP-COMP-FD-HESSIAN-NOISY-FLOOR`: finite-difference Hessian-vector product carries an irreducible error floor under any noisy oracle.
- `FP-CUSP-SET-CONVERGES-DESPITE-LOCAL-REPULSION`: a vector field that locally repels from a critical line can globally still drain to the critical point at sub-geometric rate.
