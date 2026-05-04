# OP-2 Deep Dive — Final Summary (10 Parallel Agents)

**Date:** 2026-04-26
**Process:** 10 parallel Explore agents (opus model), each with self-contained OP-2 context, ~5–15 min depth each. All 10 returned with substantive analytical content.

---

## Final scoreboard

| Problem | Topic | Difficulty | Status | Core Finding |
|---|---|---|---|---|
| **8.1** | Cycling period distribution $\mathcal{F}_K$ | research | **PASS** | $\bigcup_K \mathcal{F}_K = \mathcal{F}_3$ (nested family). Closed form $\gamma_\mathrm{crit}^{(K)}(\beta) = (1-c_K)(1+\beta^2 - 2\beta c_K)/(\beta - c_K)$, $\beta_\min^{(K)} = \sqrt{(1-c_K)^2+1} - (1-c_K)$. **$K=3$ is measure-optimal.** |
| **8.2** | Momentum cooling | conjecture | UNCERTAIN | Cycling identity exactly breaks for time-varying $\beta_t \neq \beta_c$. Per-step deviation $|\beta_t-\beta_c|\lambda\sqrt 3$. Nesterov $(t-1)/(t+2)$ achieves $T^{-3}$ on $f_0$ but only because $f_0$ is $\mu$-SC; not a true non-SC separation. |
| **8.3** | Stochastic cycling stability | research | **PASS** | Cycle is **geometrically stable**, Lyapunov exponent $= \tfrac{1}{2}\log\beta < 0$, contraction rate $\sqrt\beta$. No critical $\sigma_x^\star$. Stationary variance $\Sigma_\infty = \eta^2(1+\beta)/((1-\beta)(\cdot))\sigma_x^2 \approx 16\sigma_x^2$. **OP-2 bias term is robust to small x-noise**, $O(\sigma_x^2)$ second-order correction. |
| **8.4** | Exact minimax rate (stochastic UB) | conjecture | PARTIAL | Clean Lyapunov UB $\mathbb{E}[f(\bar x_T) - f^\star] \le (1-\beta)D^2/(2\eta T) + \eta\sigma^2/(2(1-\beta))$ on $\mathcal{S}_\mathrm{Lyap} = \{\eta \le (1-\beta^2)/L\}$. **Critical obstruction:** $\mathcal{S}_\mathrm{Lyap} \cap \mathcal{F} = \emptyset$. UB and OP-2 LB cover disjoint regions. Closing the gap on $\mathcal{F}$ requires IQC/PEP. |
| **8.5** | Implicit bias on linreg | research | **PASS (negative)** | Row-space invariant: $x_t \in \mathrm{range}(A^\top)$ for all $t$. Restricted, $f$ is $\sigma_\min(A)^2$-SC. SHB converges geometrically to $x_\mathrm{MN}$. **Cycling needs flat directions reachable from trajectory** — overparameterized linreg with $x_0 = 0$ violates reachability. |
| **8.6** | $K_\min$ vs condition number | research | **PASS** | $K_\min(\kappa) \equiv 3$ on $(0, 1)$. Closed form: $\kappa_-(\beta) = [4\beta^2+\beta+4 - 2\sqrt 3(1-\beta)\sqrt{\beta^2+\beta+1}]/(\beta+2)^2$. As $\kappa \to 1$: measure $\to 0$, **but period stays at 3**. Hypothesis "$K_\min \to \infty$" rejected. |
| **8.7** | Finite-sum extension | research | **PASS** | OP-2 LB transfers to finite-sum oracle via Gaussian-mollified construction $\alpha_{s,i} = s\alpha + \epsilon_i$. Per-step KL bounded by $2\alpha^2/\sigma^2$ (KL convexity). **Variance reduction does not rescue fixed-momentum SHB.** Interpolation regime: bias term survives, variance term collapses (forces $\epsilon_i = 0$). |
| **8.8** | k-step memory methods | research | **PASS (with one open step)** | Closed-form $k$-step cycling identity: $\eta\nabla f(e_t) = (I-R)[I - \sum_j \beta_j R^{-j}]e_t$. $M^{(k)}$ formula. $\mathcal{F}^{(2)}$ verified non-empty (4/4 configs cycle at machine precision over $T=1000$). **Highest-value direction.** |
| **8.9** | Geometric / Riemannian | conjecture | **PASS (negative)** | No Riemannian-geodesic interpretation. Cycling is Euclidean-algebraic. Continuous-limit ODE has Lyapunov $\dot E < 0$ → no cycle. Hessian is piecewise discontinuous. Velocity-linear damping cannot match Christoffel symbols. **Right framework: discrete equivariant dynamics + convex analysis on polytopes.** |
| **8.10** | Communication complexity | research | **PASS** | OP-2 verification is $\Theta(\log(1/\epsilon))$ bits — exponentially cheaper than Nesterov $\Omega(T\log(1/\epsilon))$. **Constant-dimensional witness** is the structural payoff of algorithm-specific LBs. PCP-like compactness. |

**Net:** 7 clean PASSes (8.1, 8.3, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10 — counting negative results as PASSes since they're definitive), 1 PARTIAL (8.4), 1 UNCERTAIN (8.2), 0 FAILs.

---

## Highest-value findings

### Tier 1 — publishable as standalone notes / OP-2 §4 remarks

1. **8.1 closed forms.** $\gamma_\mathrm{crit}^{(K)}(\beta)$ and $\beta_\min^{(K)}$ in clean closed form, generalizing OP-2 §2.7 from $K=3$ to arbitrary $K$. **OP-2's $K=3$ choice is provably measure-optimal.**

2. **8.3 stability theorem.** Lyapunov exponent $\tfrac{1}{2}\log\beta < 0$. Cycling is geometrically attractive under x-noise. **Robustness result for OP-2 bias term.**

3. **8.6 $K_\min(\kappa) \equiv 3$ theorem.** Closed-form $\kappa_\pm(\beta)$. Settles the $\kappa$-dependence of cycling period.

4. **8.10 communication compactness.** Constant-dimensional witness ($d=3$) vs Nesterov's $d = T$. Exponential gap in spec size.

5. **8.5 row-space invariant.** Clean negative result for linreg implicit bias. Identifies the structural reason why cycling fails.

6. **8.9 negative geometric result.** Save geometers' time: don't search for Riemannian framework.

### Tier 2 — requires more work to be standalone

7. **8.7 finite-sum LB.** OP-2 transfers cleanly via Gaussian mollification. Strengthens OP-2's scope to ML-relevant oracles. Open: interpolation regime.

8. **8.8 k-step generalization.** Highest-potential. Cycling identity generalizes to all $k$. Numerical verification for $k=2$ at machine precision. Closed-form analog of (★) at $k=2$ is the open step. **A full k-step lower-bound theorem is feasible follow-up (~ 1-2 person-month).**

### Tier 3 — open / requires new ideas

9. **8.2 momentum cooling.** OP-2 LB doesn't transfer to scheduled momentum, but test case has $\mu$-SC inner $f_0$ so test is inconclusive. Need a non-SC instance where all schedules fail to accelerate.

10. **8.4 minimax rate.** Lyapunov UB region disjoint from $\mathcal{F}$. Closing the UB on $\mathcal{F}$ requires IQC (Lessard-Recht-Packard 2016) or PEP (Taylor-Bach 2019).

---

## Combined view: what's settled, what remains open

### Settled (positive)
- $K=3$ is measure-optimal (8.1, 8.6).
- Cycling is geometrically stable under x-noise (8.3).
- OP-2 transfers to finite-sum (8.7).
- Cycling identity generalizes to k-step (8.8).
- OP-2 has constant-dimensional witnesses (8.10).

### Settled (negative)
- No Riemannian interpretation (8.9).
- No implicit-bias deviation on linreg (8.5).

### Open
- Stochastic UB matching OP-2 LB on $\mathcal{F}$ (8.4).
- Non-acceleration under arbitrary momentum schedules (8.2).
- Closed-form $\mathcal{F}^{(k)}$ at $k \ge 2$ (8.8).
- Interpolation-regime LB (8.7).

---

## Recommended actions

| Priority | Action |
|---|---|
| **HIGH** | Add **Remark 4.1.X (Cycling region structure)** to OP-2 v4 §4: cite 8.1 closed forms + measure-optimality. ~2 paragraphs. |
| **HIGH** | Add **Remark 4.1.Y (Robustness)** to OP-2 v4 §4: cite 8.3 Lyapunov stability of cycling under x-noise. ~1 paragraph. |
| **MEDIUM** | Pursue **8.8 k-step generalization** as a follow-up paper. The cycling identity is clean; the open step is closed-form $\mathcal{F}^{(k)}$ characterization. Strong publication target. |
| **MEDIUM** | Add **§0.6 caveat** about row-space invariant (8.5): "Not claimed for problems where the iterate's reachable set is strongly-convex (e.g., overparameterized linreg with $x_0 = 0$)." |
| **LOW** | Cite 8.10 compactness in §4 as a structural feature distinguishing OP-2 from Nesterov-style LBs. |
| **OPEN** | 8.4 stochastic UB on $\mathcal{F}$, 8.2 schedule extension — both require new tools (IQC/PEP for 8.4; non-SC hard instance with no SC inner factor for 8.2). |

---

## Files archived

All 10 reports under `C:/Users/12729/Desktop/Math/workspace/op2_li_review/8_deepdive/`:

- `8.1_cycling_distribution/report.md`
- `8.2_momentum_cooling/report.md`
- `8.3_stochastic_cycling/report.md`
- `8.4_minimax_rate/report.md`
- `8.5_implicit_bias/report.md`
- `8.6_K_vs_kappa/report.md`
- `8.7_finite_sum/report.md`
- `8.8_kstep/report.md`
- `8.9_geometric/report.md`
- `8.10_communication/report.md`
- `summary.md` (this file)
