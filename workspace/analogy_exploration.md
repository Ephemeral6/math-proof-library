# Cross-Domain Analogy Exploration

**Date**: 2026-04-17
**Selected proofs** (for structural diversity — variance reduction / saddle-point spectra / coupling):

1. **STORM non-convex convergence** — `proofs/research/optimization/stochastic/storm-nonconvex-convergence/`
2. **OGDA bilinear last-iterate** — `proofs/research/optimization/convergence/ogda-bilinear-last-iterate/`
3. **SGD uniform stability generalization** — `proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/`

Candidate theorems (conjectures not located on arXiv) are flagged with **⭐ CANDIDATE**.

---

## 1. STORM — momentum-corrected gradient estimator

### 1.A Core structure (roles, not steps)

| Role | What it does |
|------|--------------|
| **Init** | Large mini-batch $B = O(\sigma/\varepsilon)$ crushes initial gradient variance so it does not dominate |
| **Iteration** | Rebiased EMA estimator $d_t = (1-a) d_{t-1} + a g_t + (1-a)(g_t - g_{t-1}^{\text{old}})$ — Richardson-style correction keeps drift $O(a)$ while contracting noise $(1-a)^t$ |
| **Error accumulation** | Variance recursion $\mathbb{E}\|e_t\|^2 \le (1-a)\|e_{t-1}\|^2 + 2L^2\eta^2 \|d_{t-1}\|^2 + 2a^2\sigma^2$ — contraction + signal-linked drift + noise floor |
| **Cancellation** | Lyapunov $\Phi_t = f(x_t) + \frac{\eta}{2a}\|e_t\|^2$; polarization identity on descent lemma absorbs the $\|d_t\|^2$ drift term into the negative descent |
| **Termination** | Telescope over $T$, pick uniform-random iterate, get $\mathbb{E}\|\nabla f\|^2 = O(\varepsilon^2)$ at $T = O(\sigma/\varepsilon^3)$ |

### 1.B Cross-domain correspondences

| Structural element | PDE | Stat. physics | Game theory | Probability |
|---|---|---|---|---|
| Momentum-rebiased estimator | Trapezoidal (Crank–Nicolson) time-discretization of a gradient-flow PDE with stochastic forcing | Generalized Langevin equation with exponential memory kernel | Optimistic FTRL with discounted past gradient | Rao–Blackwellized control variate with recursive debias |
| Variance recursion $(1-a)\cdot$ contraction + signal drift | Energy inequality with absorbing lower-order term | Fluctuation–dissipation with memory | Regret recursion with optimism-error term | Martingale difference variance bound |
| Polarization identity in Lyapunov | Integration-by-parts with boundary cancellation | Work–energy theorem: dissipated work = kinetic energy lost | "Cross-term cancellation" in potential-plus-mirror-descent | Doob decomposition equating signal / noise cross-terms |
| Mini-batch warm-start | Initial data regularization for ill-posed PDE | Quenched vs. annealed initial condition | Burn-in for no-regret algorithm | Importance-sampling burn-in |

### 1.C Conjectures and arXiv status

**C1.1 — "Crank–Nicolson for noisy HJ."** Trapezoidal discretization of a noisy Hamilton–Jacobi or gradient-flow PDE with batch-$O(\sigma/\varepsilon)$ initial condition reaches $\varepsilon$-stationary viscosity solutions in $O(\sigma/\varepsilon^3)$ oracle calls.
→ Status: **⭐ CANDIDATE (UNSEEN)**. The HJ-viscosity literature (arXiv:2111.13258, 2401.02240, 2503.11171) handles well-posedness, not STORM-style complexity. Variance-reduced discretization of HJ with a SPIDER/STORM rate is, as far as these searches go, absent.

**C1.2 — "Generalized Langevin beats SGLD."** For $\sigma^2$-noisy GLE with exponential memory kernel of rate $a^{-1}$, sampling complexity is $O(\sigma^2/\varepsilon^3)$ under log-Sobolev, beating plain SGLD's $O(\varepsilon^{-4})$.
→ Status: **PARTIAL**. arXiv:2203.16217, 2102.06759 prove variance-reduced SGLD; arXiv:2512.10256, 2402.11705 handle GLE with memory kernels but for estimation, not optimization. The exact STORM-rate GLE analog is not stated.

**C1.3 — "STORM-FTRL in noisy zero-sum."** Optimistic FTRL with STORM-style recursive gradient rebiasing achieves last-iterate $O(\sigma/\varepsilon^3)$ Nash gap in matrix games with noisy payoff oracle.
→ Status: **PARTIAL**. arXiv:2501.16600 introduces PFTRL-RKL with an estimator that has "unbiasedness and conditional zero variance" — structurally close, but not framed as STORM or proved at the $O(\sigma/\varepsilon^3)$ rate.

**C1.4 — "Momentum MCMC."** Rao–Blackwellized MCMC estimator with STORM-style recursive debias gives variance $O(1/T^2)$ instead of $O(1/T)$ for ergodic averages.
→ Status: **⭐ CANDIDATE (UNSEEN)**. Control-variates MCMC (arXiv:1012.2983, 1903.07373, 2402.07349) uses static control variates, not recursive momentum-correction across the chain.

---

## 2. OGDA bilinear — linear recurrence with skew-symmetric operator

### 2.A Core structure

| Role | What it does |
|------|--------------|
| **Init** | Arbitrary $z_0$; linearity means no special choice matters |
| **Iteration** | $z_{t+1} = z_t - 2\eta F(z_t) + \eta F(z_{t-1})$; linear with skew-symmetric $F$. Block-diagonalizes via SVD of $A$ |
| **Error accumulation** | Energy identity $\|z_{t+1}\|^2 = \|z_t\|^2 + \|\delta_{t+1}-\delta_t\|^2 - \|\delta_t\|^2$ — partially telescopes |
| **Cancellation** | Each 2×2 block has eigenvalues $\lambda_\pm = (1\pm\rho)/2 - i\eta\sigma$; rotation with imaginary part, bounded modulus $|\lambda_\pm|^2 \le 1 - \eta^2\sigma^2$ |
| **Termination** | Worst block = smallest singular value of $A$; overall rate $\kappa(A)^2/T$ |

### 2.B Cross-domain correspondences

| Structural element | PDE | Stat. physics | Game theory | Probability |
|---|---|---|---|---|
| Linear skew-symmetric operator | Damped wave / Klein–Gordon with skew coupling | Hamiltonian dynamics with viscous friction | Cyclic payoff matrix in zero-sum game | Non-reversible Markov generator $L = L_{\text{sym}} + L_{\text{skew}}$ |
| Rotational eigenvalues | Dispersion relation $\omega = \omega_R + i\omega_I$ | Underdamped Langevin / Hamiltonian Monte Carlo | Oscillatory replicator trajectories | Mixing via singular-value gap (non-reversible MC) |
| $\kappa(A)^{-2}$ rate driven by smallest block | Worst dispersive mode | Slowest collective mode | Smallest payoff-matrix singular value $=$ hardest equilibration direction | Smallest singular value of generator = relaxation time |
| Energy identity (skew cancellation) | Poincaré–Wirtinger energy balance | Symplectic invariance | Fenchel coupling telescoping | Reversibility-defect quadratic form |

### 2.C Conjectures and arXiv status

**C2.1 — "Damped wave ↔ OGDA."** The last-iterate $\kappa^2/T$ rate of OGDA on bilinear games coincides with the local-energy-decay rate of a 1-D damped wave $\partial_{tt}u + 2\rho \partial_t u + J u = 0$, $J$ skew, with $\rho$ matching OGDA's extrapolation.
→ Status: **⭐ CANDIDATE (UNSEEN)**. Damped-wave spectral theory (arXiv:2304.05816, 2111.08982) is mature but the explicit correspondence to OGDA rates is not in standard references.

**C2.2 — "Non-reversible Langevin on bilinear potential."** SGLD with skew-symmetric drift perturbation on a bilinear saddle achieves $\kappa(A)^{-2}/T$ Wasserstein convergence to the invariant measure — matching OGDA.
→ Status: **PARTIAL**. arXiv:1812.07725, 2009.12690 study skew-symmetric Langevin for non-convex optimization, and arXiv:2310.10876 uses singular values for non-reversible chain gaps, but the bilinear/saddle specialization with explicit $\kappa^2$ rate isn't explicitly stated.

**C2.3 — "Replicator with extrapolation."** Discrete-time replicator with OGDA-style extrapolation achieves last-iterate $O(1/T)$ Nash gap in two-player zero-sum matrix games.
→ Status: **PROVED / ALREADY KNOWN**. This is essentially OMWU (arXiv:1807.04252) and extensions (arXiv:2406.10605, 2506.03464). The multiplicative-weights variant has been studied in detail.

**C2.4 — "Rotational-drift spectral gap = condition number."** Two-time-scale Markov chain with rotational skew drift and symmetric friction has spectral gap equal to $\lambda_{\min}^2(A)$ where $A$ is the drift operator; analog of OGDA $\kappa^2$.
→ Status: **⭐ CANDIDATE (UNSEEN)**. Non-reversible MC spectral-gap literature (arXiv:2310.10876, 2504.01247) exists but the bilinear/saddle-style $\kappa(A)^{-2}$ isn't there in this form.

---

## 3. SGD uniform stability — coupling with additive error growth

### 3.A Core structure

| Role | What it does |
|------|--------------|
| **Init** | Two SGD copies at the same $w_0$, driven by identical random index sequence, on datasets differing in one datum |
| **Iteration** | Matched updates; with prob $1-1/n$ the gradient step is non-expansive (co-coercivity of convex $\beta$-smooth); with prob $1/n$, $2\alpha L$ drift |
| **Error accumulation** | $\delta_{t+1} \le \delta_t + 2\alpha_t L / n$: additive only (no $(1+c)$ multiplier) — key consequence of convexity |
| **Cancellation** | Convex $\beta$-smooth ⇒ gradient step is 1-Lipschitz in parameter space when $\alpha \le 2/\beta$ — expansion mode inactive |
| **Termination** | $\delta_T \le \frac{2L}{n}\sum \alpha_t$; Lipschitz $\Rightarrow$ stability in function value; Bousquet–Elisseeff $\Rightarrow$ generalization $\le \text{stability}$ |

### 3.B Cross-domain correspondences

| Structural element | PDE | Stat. physics | Game theory | Probability |
|---|---|---|---|---|
| Coupled dynamics, shared noise | Two parabolic PDEs with same boundary data, differing forcing | Synchronous-noise coupling of two Langevin particles | Two replicator dynamics with one perturbed payoff | Synchronous coupling of two Markov chains |
| Non-expansive common step | Monotone operator / comparison principle | Gradient flow on convex potential = contraction in $W_2$ | Contractivity on common payoff bimatrix | Markov chain with non-negative Ollivier–Ricci curvature |
| 1/n-rare drift | Small-measure forcing perturbation | Rare-event rate of diverging trajectories | One-agent perturbation in $n$-player game | Low-probability coupling failure |
| Stability $\Rightarrow$ generalization | PDE well-posedness / Lipschitz data-to-solution map | Gibbs-state perturbation ⇒ bounded free-energy shift | Strategy replacement gap ≤ stability | DP-style distribution-change bound |

### 3.C Conjectures and arXiv status

**C3.1 — "Comparison-principle generalization."** Two solutions of a monotone parabolic PDE whose forcings differ on a set of measure $1/n$ stay $L^2$-close by $O(T/n)$ — the exact analog of additive SGD stability.
→ Status: **PARTIAL**. arXiv:2602.12657 gives quantitative stability for quasilinear parabolic PDEs; Talenti-type comparison principles exist. But stated as a generalization-error bound for a PDE-learning procedure, it appears to be new.

**C3.2 — "Langevin synchronous-coupling stability."** Two SGLD runs on datasets differing in one point stay $O(T\alpha L/n)$ close in $W_2$ via synchronous coupling, yielding an algorithmic-stability generalization bound for SGLD matching the SGD constant.
→ Status: **PROVED**. arXiv:2201.03064 (EFLD stability-generalization) and arXiv:2601.19730 (heavy-tail extension) establish the result; the synchronous-coupling proof route is also explicit in arXiv:1703.01617 for Langevin.

**C3.3 — "Potential-game one-agent stability = generalization."** In $n$-player potential games, changing one player's payoff by $\le \varepsilon$ causes best-response dynamics to produce strategies within $O(T\varepsilon/n)$ in action space — interpreted as a "generalization" bound for learned joint strategies.
→ Status: **⭐ CANDIDATE (UNSEEN)**. arXiv:1707.06465 analyzes perturbation stability of potential-game equilibria, arXiv:2501.16600 uses perturbation in extensive-form games — neither bridges to a learning-theoretic generalization bound with explicit $T/n$ scaling.

**C3.4 — "Non-negative Ollivier–Ricci ⇒ uniform stability."** A Markov chain / SGD with non-negative Ollivier–Ricci curvature (Wasserstein analog of convex β-smooth) admits an additive-only coupling recursion, giving an $O(T/n)$ uniform stability bound and thus a learning-theoretic generalization bound.
→ Status: **⭐ CANDIDATE (UNSEEN)**. Ollivier–Ricci appears in GNN oversmoothing (arXiv:2211.15779) and discrete geometry (arXiv:2512.03968, 2008.01209), but no search result connects it to algorithmic-stability generalization bounds for SGD-like chains. Clean, under-explored bridge.

---

## Summary

| ID | Conjecture (short) | Status |
|----|---|---|
| C1.1 | Crank–Nicolson on noisy HJ gives SPIDER-rate complexity | **⭐ CANDIDATE** |
| C1.2 | Exponential-memory GLE matches STORM rate for optimization | PARTIAL |
| C1.3 | STORM-style FTRL in noisy zero-sum games | PARTIAL |
| C1.4 | Recursive-momentum control variate for MCMC | **⭐ CANDIDATE** |
| C2.1 | Damped-wave spectral decay = OGDA last-iterate $\kappa^2/T$ | **⭐ CANDIDATE** |
| C2.2 | Non-reversible Langevin on bilinear saddle = $\kappa^{-2}/T$ | PARTIAL |
| C2.3 | Replicator with extrapolation = OGDA $O(1/T)$ | PROVED (OMWU) |
| C2.4 | Rotational-drift Markov chain spectral gap = $\kappa^{-2}$ | **⭐ CANDIDATE** |
| C3.1 | Parabolic PDE comparison principle as generalization bound | PARTIAL |
| C3.2 | Synchronous-coupling Langevin stability | PROVED |
| C3.3 | Potential-game one-agent perturbation as generalization | **⭐ CANDIDATE** |
| C3.4 | Non-negative Ollivier–Ricci ⇒ uniform stability bound | **⭐ CANDIDATE** |

### Candidate problems to consider for the proof library

**Highest-leverage (clean statement, obvious route, not located):**

1. **C3.4** — Ollivier–Ricci curvature ⇒ uniform stability. Replace "convex $\beta$-smooth" with "non-negative OR curvature" everywhere in the HRS stability proof. Natural, clean, testable on graph-SGD or discrete chains.
2. **C1.4** — STORM-style recursive debias for MCMC ergodic averages. If the momentum parameter $a$ interpolates between plain averaging and control-variate, a STORM-analog rate should be provable using the same polarization-Lyapunov trick.
3. **C2.1** — Damped-wave ↔ OGDA explicit correspondence. Would connect saddle-point optimization to classical dispersive PDE theory and potentially give a PDE-theoretic way to tighten $\kappa^2$ to $\kappa$.

**Next tier:**

4. **C1.1** — Crank–Nicolson noisy-HJ complexity.
5. **C2.4** — Rotational-drift Markov chain with bilinear $\kappa$-scaling.
6. **C3.3** — Potential-game perturbation stability as generalization bound.

---

## Sources (searched)

- Variance-reduced SGLD / GLE: [2203.16217](https://arxiv.org/abs/2203.16217), [2102.06759](https://arxiv.org/abs/2102.06759), [2512.10256](https://arxiv.org/html/2512.10256), [2402.11705](https://arxiv.org/abs/2402.11705)
- Optimistic / perturbed FTRL noisy payoffs: [2501.16600](https://arxiv.org/html/2501.16600), [2506.16736](https://arxiv.org/abs/2506.16736), [1807.04252](https://arxiv.org/pdf/1807.04252), [2406.10631](https://arxiv.org/pdf/2406.10631)
- MCMC control variates: [1012.2983](https://arxiv.org/abs/1012.2983), [1903.07373](https://arxiv.org/abs/1903.07373), [2402.07349](https://arxiv.org/pdf/2402.07349)
- HJ / controlled gradient flow: [2111.13258](https://arxiv.org/abs/2111.13258), [2401.02240](https://arxiv.org/html/2401.02240v2), [2503.11171](https://arxiv.org/pdf/2503.11171)
- Damped wave spectral: [2304.05816](https://arxiv.org/pdf/2304.05816), [2111.08982](https://arxiv.org/pdf/2111.08982), [2311.08628](https://arxiv.org/html/2311.08628)
- Non-reversible Langevin / skew drift: [1812.07725](https://arxiv.org/abs/1812.07725), [2009.12690](https://arxiv.org/abs/2009.12690)
- Non-reversible MC spectral gap: [2310.10876](https://arxiv.org/abs/2310.10876), [2504.01247](https://arxiv.org/html/2504.01247v1)
- Last-iterate in zero-sum: [1807.04252](https://arxiv.org/pdf/1807.04252), [2406.10605](https://arxiv.org/html/2406.10605v1), [2506.03464](https://arxiv.org/html/2506.03464v2)
- Parabolic PDE stability: [2602.12657](https://arxiv.org/abs/2602.12657)
- Langevin synchronous coupling: [1703.01617](https://arxiv.org/pdf/1703.01617), [2509.00941](https://arxiv.org/html/2509.00941)
- Stability-based generalization: [2201.03064](https://arxiv.org/abs/2201.03064), [2601.19730](https://arxiv.org/html/2601.19730), [2502.12353](https://arxiv.org/pdf/2502.12353)
- Potential-game perturbation: [1707.06465](https://arxiv.org/pdf/1707.06465), [2504.16222](https://arxiv.org/html/2504.16222), [2503.16285](https://arxiv.org/html/2503.16285)
- Ollivier–Ricci: [2210.12048](https://arxiv.org/abs/2210.12048), [2211.15779](https://arxiv.org/pdf/2211.15779), [2008.01209](https://arxiv.org/abs/2008.01209), [2512.03968](https://arxiv.org/pdf/2512.03968)

---

# Deep Literature Review — 2026-04-17 (round 2)

Focused on the 6 CANDIDATE conjectures. Classification below supersedes the round-1 CANDIDATE flags.

## C3.4 — Ollivier–Ricci ⇒ uniform stability (deep dive)

### What was found

| Source | What it establishes | Relation to C3.4 |
|---|---|---|
| Ollivier (math/0701886), Erbar–Maas ([1111.2687](https://arxiv.org/abs/1111.2687)) | Positive coarse Ricci ⇒ **Wasserstein contraction**, spectral gap $\ge \kappa$, Gaussian concentration, modified log-Sobolev | Foundational ingredient — the contraction-per-step, but **no leave-one-out / dataset-substitution interpretation** |
| arXiv:[2305.12056](https://arxiv.org/abs/2305.12056) (NeurIPS 2023) | Uniform-in-time $W_1$-stability bounds for (noisy) SGD with constant step size | **Extremely close in goal** — but hypothesis is *dissipativity + Lyapunov function*, not curvature. Different proof technology. |
| [2201.03064](https://arxiv.org/abs/2201.03064), [2601.19730](https://arxiv.org/html/2601.19730) | Stability-based generalization for SGLD / heavy-tail SGD | Uses contraction of Langevin semigroup (Bakry–Émery-like hypothesis implicit in log-Sobolev), **not** coarse Ricci |
| LLY Ricci reweighting ([2603.11060](https://arxiv.org/html/2603.11060)) | Uses LLY curvature for "iterate stability estimates" in spectral clustering | Uses curvature for a *different* algorithmic-stability notion (spectral reweighting), not HRS uniform stability |
| Ollivier–Ricci on graphs ([2211.15779](https://arxiv.org/pdf/2211.15779), [2512.03968](https://arxiv.org/pdf/2512.03968)) | Curvature ↔ oversmoothing/oversquashing; graph-topological results | Not algorithmic stability |

### Verdict: **TRULY NEW** (specific formulation)

No paper states "non-negative coarse Ricci curvature of the SGD Markov kernel ⇒ HRS-style uniform stability bound with explicit $T/n$ scaling, giving $O(1/n)$ generalization via Bousquet–Elisseeff."

All ingredients exist separately:
- Coarse Ricci ⇒ $W_1$ contraction: **done** (Ollivier 2007).
- $W_1$-stability of SGD ⇒ generalization: **done** (2305.12056).
- Coarse Ricci ⇒ HRS uniform stability: **the missing link**, and the "HRS-style" framing (clean $2\alpha L / n$ recursion + Bousquet–Elisseeff) is not in 2305.12056's technology.

The statement would read: *If the SGD Markov kernel $P_\alpha(\cdot \mid x)$ on $\mathbb{R}^d$ has non-negative coarse Ricci curvature uniformly, then SGD on any dataset has uniform stability $\beta \le 2L \sum_t \alpha_t / n$, hence $\mathbb{E}[R(w_T) - R_S(w_T)] \le 2L \sum \alpha_t / n$.* Proving it is a direct coupling argument: replace "convex + $\alpha \le 2/\beta$ ⇒ 1-Lipschitz gradient step" with "positive coarse Ricci ⇒ 1-Lipschitz in $W_1$" and reuse the rest of HRS.

---

## Other 5 CANDIDATES

### C1.1 — Crank–Nicolson for noisy HJ → SPIDER complexity

Searched "Crank-Nicolson stochastic SDE variance reduction viscosity complexity". No hit combining viscosity solutions with SPIDER/STORM-style oracle complexity. Crank-Nicolson for stochastic Navier–Stokes and SDEs exists with strong-convergence bounds, but complexity is measured in sample paths, not oracle queries.

**Verdict: ADJACENT** (weak analogy). The correspondence "time discretization ↔ iteration count" is not a clean substitution — there is no natural $\sigma/\varepsilon$ oracle model on the PDE side. Lower priority than originally scored.

### C1.4 — STORM-style recursive momentum for MCMC

Searched "STORM variance reduction MCMC Bayesian posterior expectation recursive momentum". Stochastic Gradient Hamiltonian Monte Carlo with SVRG variance reduction (Springer 2019) is close but uses *epoch-based SVRG*, not STORM's recursive momentum. Control-variate MCMC uses *static* variates. Nothing uses the $(1-a) d_{t-1} + g_t + (1-a)(g_t - g_{t-1}^{\text{old}})$ recursion for posterior expectations.

**Verdict: TRULY NEW.** Clean substitution: apply STORM's estimator to $\mathbb{E}_\pi[h]$, with $g_t = h(x_t)$ replaced by $h(x_t) - h(x_{t-1})$ along a chain; the polarization-Lyapunov trick should port because Markov contraction provides the $(1-a)$ role.

### C2.1 — Damped-wave spectral decay ↔ OGDA last-iterate

Searched "extragradient OGDA bilinear damped wave hyperbolic spectral". Found [2110.04261](https://arxiv.org/abs/2110.04261) which develops "a spectral viewpoint on cocoercivity" for EG — spectral analysis of OGDA/EG is known. Damped hyperbolic spectral operator theory (Springer, "Spectral operators generated by damped hyperbolic equations") exists as classical PDE. But **no paper establishes the explicit $z_{t+1} = z_t - 2\eta F(z_t) + \eta F(z_{t-1})$ ↔ damped wave correspondence.**

**Verdict: ADJACENT.** The analogy is real (both have $\lambda = \text{real damping} \pm i\,\text{rotation}$), but writing it as a formal correspondence with matched rates has not been done. Medium value — mostly pedagogical.

### C2.4 — Rotational-drift Markov chain spectral gap $= \kappa(A)^{-2}$

Searched "non-reversible Markov chain singular value generator bilinear skew condition number". [2310.10876](https://arxiv.org/abs/2310.10876) explicitly **defines spectral gap as the second-smallest singular value of the generator**, which is exactly the direction of our conjecture. [2511.02265](https://arxiv.org/pdf/2511.02265) gives non-asymptotic mixing for non-reversible chains. Skew-drift Langevin acceleration ([1812.07725](https://arxiv.org/abs/1812.07725)) establishes the family but not the $\kappa^{-2}$ bilinear specialization.

**Verdict: ADJACENT.** The machinery is in place; the specific "bilinear-saddle Markov kernel has $\sigma_{\min}(A)^2$ spectral gap" statement is a routine specialization but **apparently not written down**. Likely provable in one page from 2310.10876's framework.

### C3.3 — Potential-game one-agent perturbation as generalization bound

Searched "potential game perturbation single player payoff stability learning generalization Hardt Recht". [1707.06465](https://arxiv.org/pdf/1707.06465) establishes perturbation-stability of potential-game equilibria (qualitative). [2501.16600](https://arxiv.org/html/2501.16600) uses perturbation for convergence stabilization, not generalization. No paper bridges to a Bousquet–Elisseeff-style generalization bound.

**Verdict: TRULY NEW,** but the underlying model (what is the "risk" being generalized?) needs construction. Valuable only if one commits to a specific learning model — e.g., each player's empirical-best-response against samples from other players' mixed strategies, then LOO-stability over player-samples.

---

# Revised classification

| ID | Conjecture | Round-1 | Round-2 |
|----|---|---|---|
| C1.1 | Crank–Nicolson on noisy HJ | CANDIDATE | **ADJACENT (weak)** |
| C1.2 | GLE-STORM rate for optimization | PARTIAL | PARTIAL (unchanged) |
| C1.3 | STORM-FTRL in noisy zero-sum | PARTIAL | PARTIAL (unchanged) |
| C1.4 | STORM recursive momentum for MCMC | CANDIDATE | **TRULY NEW** |
| C2.1 | Damped-wave ↔ OGDA | CANDIDATE | **ADJACENT** |
| C2.2 | Non-reversible Langevin on bilinear | PARTIAL | PARTIAL (unchanged) |
| C2.3 | Replicator+extrapolation = OGDA | PROVED | PROVED (unchanged) |
| C2.4 | Rotational-drift MC spectral gap | CANDIDATE | **ADJACENT** |
| C3.1 | Parabolic comparison ⇒ generalization | PARTIAL | PARTIAL (unchanged) |
| C3.2 | Synchronous-coupling Langevin stability | PROVED | PROVED (unchanged) |
| C3.3 | Potential-game perturbation generalization | CANDIDATE | **TRULY NEW** |
| C3.4 | Non-negative OR curvature ⇒ HRS stability | CANDIDATE | **TRULY NEW** |

TRULY NEW count: 3 (C1.4, C3.3, C3.4)
ADJACENT count: 3 (C1.1, C2.1, C2.4)
REDISCOVERED: 0 (nothing downgraded to PROVED)

---

# Final recommendation — top 3 to attempt

Ranked by (feasibility × value):

### 1. **C3.4 — Non-negative coarse Ricci curvature ⇒ HRS-style uniform stability bound** ★ Highest priority

- **Feasibility: very high.** All ingredients in the literature (Ollivier contraction, HRS coupling, Bousquet–Elisseeff). Proof is essentially a direct substitution: replace "convex + $\alpha \le 2/\beta$ gives 1-Lipschitz step" in HRS with "positive coarse Ricci of the noisy SGD kernel gives $W_1$-1-Lipschitz step". The rest ports verbatim.
- **Value: high.** Generalizes HRS to non-convex objectives through a geometric condition, and cleanly separates "why convexity matters for stability" into "it was actually positive curvature of the Markov kernel all along." Opens connections to RCD-spaces, graph Ricci curvature, and possibly neural-network stability via NTK-kernel Ricci.
- **Concrete statement to target:** *Let $P$ be the SGD update kernel with step $\alpha$ and bounded-Lipschitz gradient noise. If $P$ has uniform coarse Ricci curvature $\ge 0$, then SGD has uniform stability $\beta_T \le 2L\sum_{t\le T} \alpha_t / n$ and generalization gap $\le \beta_T$.* Non-convex analog: $\beta_T \le C \prod_{t}(1 - \kappa_t) + 2L\sum \alpha_t / n$ with $\kappa_t$ local curvature.
- **Risk:** The "coarse Ricci of noisy SGD kernel" needs explicit verification on concrete objectives. Without noise injection the coarse Ricci of deterministic SGD is degenerate.

### 2. **C1.4 — STORM-style recursive momentum estimator for MCMC ergodic averages** ★ Second priority

- **Feasibility: high.** The STORM proof template (polarization identity + $\Phi_t = \text{error} + \frac{\eta}{2a}\|e_t\|^2$) is almost drop-in for a variance-recursion where $(1-a)$ comes from Markov-chain contraction rather than from the estimator's parameter. Stationary ergodic theory supplies the replacement of $L^2$-smoothness with total-variation / Poincaré contraction.
- **Value: medium-high.** Would give a new class of low-variance posterior-expectation estimators with rate $O(1/T^2)$ instead of $O(1/T)$, under Poincaré (or log-Sobolev) inequality. Directly useful for stochastic-gradient MCMC and Bayesian deep learning.
- **Concrete statement:** *For an ergodic Markov chain with Poincaré constant $\lambda$ and target $\pi$, the STORM-ified ergodic estimator $\bar h_T = \sum_t d_t / T$ with $d_t = (1-a)d_{t-1} + a h(X_t) + (1-a)(h(X_t) - h(X_{t-1}))$ satisfies $\mathrm{Var}(\bar h_T - \pi(h)) = O(1/T^2)$ when $a = \Theta(1/\sqrt{T})$.*
- **Risk:** "Functional smoothness" in Markov-chain context needs care — the gradient-Lipschitz hypothesis of STORM needs to be replaced with a regularity condition on $h$ relative to the chain geometry.

### 3. **C3.3 — One-agent payoff perturbation in potential games gives generalization bound for learned strategies** ★ Third priority (more speculative)

- **Feasibility: medium.** Requires building the learning-theoretic model (what dataset does each player see; what risk is being minimized). Once the model is fixed the HRS technique should adapt to best-response / replicator dynamics.
- **Value: medium.** Would be the first stability-to-generalization bridge in multi-agent learning, connecting algorithmic game theory to PAC-style bounds. Potentially useful for federated / multi-agent RL generalization.
- **Concrete statement:** *In an $n$-player potential game where player $i$'s payoff is the empirical mean over $m$ i.i.d. samples, the best-response dynamics output $\sigma^*$ satisfies, for each player, $|\mathbb{E}_S[u_i(\sigma^*, \sigma^*_{-i})] - u_i^{\text{pop}}(\sigma^*)| \le O(T \cdot L_i / m)$ where $T$ is the number of best-response rounds.*
- **Risk:** Framing (1) is delicate; wrong framing gives a trivial or vacuous bound. Lower priority than C3.4 and C1.4.

## Sources (round 2)

- [2305.12056](https://arxiv.org/abs/2305.12056) — Uniform-in-time Wasserstein stability for SGD (dissipativity-based, not curvature)
- [1111.2687](https://arxiv.org/abs/1111.2687) — Erbar–Maas, entropic Ricci for finite Markov chains
- [2603.11060](https://arxiv.org/html/2603.11060) — LLY Ricci reweighting, iterate-stability in spectral clustering
- [2110.04261](https://arxiv.org/abs/2110.04261) — Spectral cocoercivity for extragradient
- [2511.02265](https://arxiv.org/pdf/2511.02265) — Non-asymptotic mixing for non-reversible chains
- [1509.01240](https://arxiv.org/abs/1509.01240) — Hardt–Recht–Singer original
- [1905.10018](https://arxiv.org/abs/1905.10018) — Cutkosky–Orabona STORM
- [1707.06465](https://arxiv.org/pdf/1707.06465) — Best-response dynamics in potential games (perturbation stability)

