# Literature Survey: A1 — Adam-style Adaptive Methods Last-Iterate Lower Bound

**Survey date**: 2026-04-28  
**Query scope**: 2023–2026 papers on Adam/AdaGrad/RMSProp last-iterate convergence, algorithm-specific lower bounds, stochastic convex/non-convex settings.

---

## Relevant Papers (2023–2026)

| # | Title | Authors | Venue / Year | Setting | Bound type | Rate | arXiv |
|---|-------|---------|--------------|---------|-----------|------|-------|
| 1 | Closing the Gap Between Upper and Lower Bound of Adam's Iteration Complexity | Zhang et al. (Wang et al.) | NeurIPS 2023 | Non-convex, stochastic, bounded variance | UB (first tight Adam UB) | O(ε⁻⁴) matching LB | [2310.17998](https://arxiv.org/abs/2310.17998) |
| 2 | ADOPT: Modified Adam Can Converge with Any β₂ with the Optimal Rate | Taniguchi et al. | NeurIPS 2024 | Non-convex smooth, stochastic | UB | O(1/√T) — optimal for non-convex | [2411.02853](https://arxiv.org/abs/2411.02853) |
| 3 | On Convergence of Adam for Stochastic Optimization under Relaxed Assumptions | Haochuan Li et al. | NeurIPS 2024 | Non-convex smooth, L-smooth + ABC noise | UB (last-iterate asymptotic) | O(poly(log T)/√T) | [2402.03982](https://arxiv.org/abs/2402.03982) |
| 4 | A Comprehensive Framework for Analyzing the Convergence of Adam: Bridging the Gap with SGD | Jin, Li, Yu, Wang | ICML 2025 | Non-convex, L-smooth + ABC noise | UB (last-iterate, a.s. + L₁) | Same complexity as SGD | [2410.04458](https://arxiv.org/abs/2410.04458) |
| 5 | Convergence Rates for the Adam Optimizer | Dereich, Jentzen | arXiv Jul 2024 | Stochastic quadratics (simple model) | UB (optimal for quadratics) | Convergence to "Adam vector field" zeros, not critical points | [2407.21078](https://arxiv.org/abs/2407.21078) |
| 6 | Convergence Guarantees for RMSProp and Adam in Generalized-smooth Non-convex Optimization with Affine Noise Variance | Liao et al. | ICLR 2025 | Non-convex, (L₀,L₁)-smooth + affine noise variance | UB | O(ε⁻⁴) matching Arjevani et al. 2023 LB | [2404.01436](https://arxiv.org/abs/2404.01436) |
| 7 | Last Iterate Convergence of AdaGrad-Norm for Convex Non-Smooth Optimization | Preobrazhenskaia et al. | arXiv Apr 2026 | Convex non-smooth, stochastic | UB + matching LB | O(1/N^{1/4}) last iterate; O(1/N^{1/2}) average — tight both ways | [2604.10728](https://arxiv.org/abs/2604.10728) |
| 8 | Revisiting the Last-Iterate Convergence of Stochastic Gradient Methods | Liu, Zhou | ICLR 2024 (updated Mar 2026) | Convex smooth + composite + non-Euclidean | UB | O(L/T + (M+σ)/√T) last iterate | [2312.08531](https://arxiv.org/abs/2312.08531) |
| 9 | The Price of Adaptivity in Stochastic Convex Optimization | Carmon, Hinder | COLT 2024 / Math. Prog. 2025 | Non-smooth convex, parameter-free | LB (impossibility) | Log penalty for parameter-free methods; polynomial penalty for doubly-unknown params | [2402.10898](https://arxiv.org/abs/2402.10898) |
| 10 | Provable Complexity Improvement of AdaGrad over SGD: Upper and Lower Bounds in Stochastic Non-Convex Optimization | Wang et al. | arXiv Jun 2024 | Non-convex, stochastic, ℓ₁-stationarity | UB (AdaGrad) + LB (SGD) | d-factor advantage for AdaGrad — first provable separation | [2406.04592](https://arxiv.org/abs/2406.04592) |

---

## State of the Landscape: What Is Closed vs Open

### CLOSED (non-convex setting)

- **Oracle complexity for non-convex smooth stochastic optimization**: The Ω(ε⁻⁴) lower bound (Arjevani et al. 2023, Math. Prog.) applies to all first-order methods including Adam. ADOPT (NeurIPS 2024, #2 above) and Liao et al. (ICLR 2025, #6) match this bound for Adam/RMSProp. This direction is **settled**.

- **Adam-specific upper bound in non-convex**: Paper #1 (NeurIPS 2023) established the first tight O(ε⁻⁴) bound for the original Adam (not a modified version) under standard bounded variance. Combined with Arjevani et al.'s LB, **the non-convex oracle complexity gap is closed**.

- **AdaGrad-Norm last-iterate rate in convex non-smooth**: Paper #7 (Apr 2026) establishes the O(1/N^{1/4}) rate is tight for AdaGrad-Norm's last iterate, and explicitly states that investigating Adam and RMSProp last-iterate rates is **future work**. This closes the AdaGrad-Norm question but leaves Adam open.

### PARTIALLY OPEN (convex smooth setting)

- **Adam last-iterate convergence rate in stochastic smooth convex**: Paper #3 shows Adam achieves O(poly(log T)/√T) last-iterate in high probability (non-convex setting, but log-factor gap remains). For the **convex smooth** setting specifically, no tight last-iterate rate with matching LB is known.

- Paper #7 explicitly lists "investigating the last-iterate convergence of related methods such as RMSProp and Adam" as **open future work** (as of April 2026).

- The AdaGrad-Norm LB (O(1/N^{1/4}) vs O(1/N^{1/2}) average) suggests adaptive methods may suffer a provable last-iterate penalty. Whether Adam shares this or achieves O(1/√T) last-iterate in convex smooth is **not established**.

### THE TARGET GAP

**Core open question (as of April 2026)**:  
For Adam/RMSProp in the stochastic, L-smooth, convex (non-SC) setting:
1. What is the exact last-iterate rate? Is it O(1/√T) or worse?
2. Is there an algorithm-specific LB showing Adam's last iterate is slower than O(1/√T), matching SGD's information-theoretic LB?

No paper in 2023–2026 establishes or refutes an Adam-specific last-iterate LB in convex smooth stochastic setting.

---

## Summary Assessment

The non-convex oracle complexity question is closed. The convex smooth **last-iterate** lower bound for Adam/RMSProp is **open**. The freshest related result (2604.10728, Apr 2026) handles AdaGrad-Norm non-smooth convex and explicitly leaves Adam as future work, making this a well-scoped, timely gap.
