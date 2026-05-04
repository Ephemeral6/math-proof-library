# Literature Survey: B1 — Bilevel Optimization Last-Iterate Lower Bound

Survey date: 2026-04-28

---

## Upper-Bound Results (Algorithm Side)

### 1. Ji, Yang, Liang — "Bilevel Optimization: Convergence Analysis and Enhanced Design" (ICML 2021)
- **Setting**: Nonconvex upper / strongly convex lower, stochastic.
- **Result**: stocBiO achieves Õ(κ²ε⁻²) SFO complexity (best-iterate guarantee). First systematized convergence analysis for hypergradient-based bilevel SGD.
- **Relevance**: Canonical baseline UB; the paper that defined the rate landscape OP-2 extends from.

### 2. Kwon, Kim, Yang, Ye — "A Fully First-Order Method for Stochastic Bilevel Optimization" (ICML 2023, F2SA)
- **Setting**: Nonconvex upper / strongly convex lower, stochastic, fully first-order (no Hessian).
- **Result**: F2SA achieves Õ(ε⁻³·⁵) SFO (with noise in both levels) via single-loop penalty + regularization. Best-iterate stationary point.
- **Relevance**: Establishes what first-order methods can do; gap from Ω(ε⁻⁴) lower bound (y\*-aware) remains.

### 3. Chen, Huang, Zhang, et al. — "Near-Optimal Nonconvex-Strongly-Convex Bilevel Optimization" (JMLR 2025, arxiv 2306.14853)
- **Setting**: Nonconvex upper / strongly convex lower, stochastic.
- **Result**: Achieves Õ(κ⁴ε⁻²) and Õ(κ³ε⁻²) under deterministic oracle; near-optimal in ε for the nonconvex-SC regime (best-iterate).
- **Relevance**: Most up-to-date UB result; still best-iterate only, no last-iterate analysis.

### 4. Shen, Chen — "On Penalty-based Bilevel Gradient Descent Method" (ICML 2023)
- **Setting**: Nonconvex / strongly convex, deterministic and stochastic.
- **Result**: PBGD achieves Õ(ε⁻³) complexity for finding ε-stationary point. Best-iterate.
- **Relevance**: Penalty reformulation route; important for understanding landscape of approaches.

### 5. Ji, Liang — "Lower Bounds and Accelerated Algorithms for Bilevel Optimization" (JMLR 2023, arxiv 2102.03926)
- **Setting**: SC-SC and convex-SC bilevel (deterministic).
- **Result**: First lower complexity bounds: Ω̃(√(LyL̃²xy / (μxμ²y))) for SC-SC; Ω̃(1/√ε · min{κy, 1/√ε³}) for convex-SC. Best-iterate / oracle complexity style, NOT last-iterate.
- **Relevance**: Foundational LB result. Covers SC-SC and convex-SC but NOT nonconvex-SC, and is not last-iterate.

---

## Lower-Bound Results (Critical for Early-Exit Check)

### 6. Kwon, Kwon, Lyu — "On the Complexity of First-Order Methods in Stochastic Bilevel Optimization" (arxiv 2402.07101, 2024)
- **Setting**: Nonconvex upper / strongly convex lower. Uses "y\*-aware stochastic first-order oracle" (oracle returns O(ε)-estimate of y\*(x)).
- **Result**: Matching Ω(ε⁻⁶) and Ω(ε⁻⁴) lower bounds (without/with additional smoothness). Oracle-complexity style, NOT last-iterate. The oracle model is stronger than plain SFO.
- **Relevance**: Important LB but restricted to y\*-aware oracle. Leaves open the question for standard SFO models, and says nothing about last-iterate.

### 7. Ji — "Lower Complexity Bounds for Nonconvex-Strongly-Convex Bilevel Optimization with First-Order Oracles" (arxiv 2511.19656, Nov 2025)
- **Setting**: Nonconvex upper / strongly convex lower, deterministic and stochastic standard first-order oracle.
- **Result**:
  - Deterministic: Ω(κ^{3/2}ε⁻²) lower bound.
  - Stochastic: Ω(κ^{5/2}ε⁻⁴) lower bound.
  - Described as "the first lower-bound result for stochastic bilevel optimization under standard first-order oracles."
  - Constructs hard instances (zero-respecting framework). NOT last-iterate — oracle complexity style.
- **Relevance**: Closest existing LB to the OP-2 framework. Uses hard instance construction, not Le Cam. Exposes gap between UB and LB, but last-iterate dimension untouched.

### 8. Chen, Zhang — "On the Condition Number Dependency in Bilevel Optimization" (arxiv 2511.22331, Nov 2025)
- **Setting**: Nonconvex upper / strongly convex lower, deterministic.
- **Result**: New Ω(κ²ε⁻²) lower bound and Õ(κ^{7/2}ε⁻²) upper bound. First provable gap between bilevel and minimax problems on κ-dependence. NOT last-iterate.
- **Relevance**: Very recent, establishes bilevel is strictly harder than minimax in κ-dependence. Good motivation for a last-iterate separation result.

### 9. Shen, Chen — "A Lower Bound and a Near-Optimal Algorithm for Bilevel Empirical Risk Minimization" (arxiv 2302.08766, 2023)
- **Setting**: Bilevel ERM, convex lower.
- **Result**: Provides lower bound for simple bilevel (convex lower, finite-sum structure). Best-iterate / average-iterate style.
- **Relevance**: Narrow scope; motivates more general treatment.

---

## Adjacent / Structural Results

### 10. Chen et al. — "On Finding Small Hyper-Gradients in Bilevel Optimization" (COLT 2024)
- **Setting**: General lower-level convexity (without strong convexity).
- **Result**: Characterizes when hyperobjective can be discontinuous; establishes intractability for non-SC lower level. Hardness arguments based on problem structure, not iterate-level analysis.
- **Relevance**: Shows why SC lower level is the natural regime; hardness of hypergradient estimation is the core technical obstacle.

---

## CRITICAL FINDING: Is there ANY last-iterate LB for bilevel?

**No.** As of April 2026:
- All known lower bounds for bilevel optimization (Ji-Liang 2023, Kwon et al. 2024, Ji 2511.19656, Chen-Zhang 2511.22331) are **oracle-complexity bounds** (total SFO calls to reach ε-stationarity), not last-iterate convergence rate lower bounds.
- None of these papers prove a lower bound on the rate at which any specific iterate sequence (particularly the final output) converges.
- The last-iterate LB literature (for single-level SGD, SHB, etc.) has no counterpart in bilevel optimization.
- **Early-exit condition NOT triggered**: No 2024-2026 paper explicitly proves a bilevel last-iterate LB. The field is open.

---

## Summary Table

| Paper | Year | Setting | Type | Last-Iterate? |
|---|---|---|---|---|
| Ji-Yang-Liang (ICML 2021) | 2021 | NC-SC stochastic | UB | No (best-iterate) |
| Kwon et al. F2SA (ICML 2023) | 2023 | NC-SC stochastic FO | UB | No (best-iterate) |
| Ji-Liang JMLR | 2023 | SC-SC, conv-SC det | LB | No (oracle) |
| Shen-Chen ICML 2023 | 2023 | NC-SC stochastic | UB | No (best-iterate) |
| Chen et al. JMLR 2025 | 2023/2025 | NC-SC stochastic | UB | No (best-iterate) |
| Kwon-Kwon-Lyu 2402.07101 | 2024 | NC-SC y\*-aware | LB | No (oracle) |
| Ji 2511.19656 | 2025 | NC-SC standard FO | LB | No (oracle) |
| Chen-Zhang 2511.22331 | 2025 | NC-SC det κ-dep | LB+UB | No (oracle) |
| Chen et al. COLT 2024 | 2024 | General convex LL | Hardness | No |
| Shen-Chen 2302.08766 | 2023 | Bilevel ERM | LB | No (oracle) |
