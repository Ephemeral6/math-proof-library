# Literature Review: Direction A2
# SHB Non-Convex Stochastic Lower Bound for ε-Stationary Point
# Generated: 2026-04-28

---

## Core Literature Table

| Title | Authors | Year | Setting | Bound type | Rate | Link |
|---|---|---|---|---|---|---|
| Lower Bounds for Non-Convex Stochastic Optimization | Arjevani, Carmon, Duchi, Foster, Srebro, Woodworth | 2023 (Math. Prog.; preprint 2019) | smooth non-convex, unbiased SFO, bounded variance σ² | minimax LB over ALL SFO algorithms | Ω(ε⁻⁴) queries for E‖∇f‖≤ε; Ω(ε⁻³) under mean-sq-smooth oracle with K=2 queries | [arxiv:1912.02365](https://arxiv.org/abs/1912.02365) |
| New Lower Bounds for Stochastic Non-Convex Optimization through Divergence Decomposition | Saad, Lee, Orabona | 2025 (COLT) | smooth non-convex + structured classes (QC, QG, RSI), unbiased SFO | minimax LB via divergence decomposition (function identification formulation) | tight LBs in all parameters up to log for each function class | [arxiv:2502.14060](https://arxiv.org/abs/2502.14060) |
| Provable non-accelerations of the heavy-ball method | Goujaud, Taylor, Dieuleveut | 2023 (arXiv), 2025 (Math. Prog.) | smooth strongly convex, deterministic first-order oracle | algorithm-specific LB for SHB via cycling | SHB fails to accelerate: no (1−O(√κ/L)) rate; cycling at fixed (β,η) on GTD polytope-Moreau function | [arxiv:2307.11291](https://arxiv.org/abs/2307.11291) |
| Nonsmooth Nonconvex Stochastic Heavy Ball | Le | 2023 (arXiv), 2024 (JOTA) | nonsmooth non-convex, stochastic subgradient, semialgebraic f | convergence analysis (UB only, no LB) | convergence to Clarke critical points a.s.; no quantitative ε⁻⁴ rate proved | [arxiv:2304.13328](https://arxiv.org/abs/2304.13328) |
| (Accelerated) Noise-adaptive Stochastic Heavy-Ball Momentum | Varre, Pillaud-Vivien, Flammarion | 2024–2025 (arxiv:2401.06738) | smooth strongly convex, stochastic, mini-batch SHB | algorithm-specific LB on mini-batch threshold b*; UB for adaptive multi-stage SHB | O(exp(−T/√κ) + σ/√T) with b≥b*(κ); LB shows κ-dependence in b* is necessary | [arxiv:2401.06738](https://arxiv.org/abs/2401.06738) |
| Exploring the Inefficiency of Heavy Ball as Momentum Parameter Approaches 1 | (various) | 2024 (IJCAI) | smooth, non-convex, stochastic, large β | partial LB argument; UB + LB on β-regime | momentum β→1 provably hurts: complexity degrades as β→1 for non-convex | [IJCAI 2024](https://www.ijcai.org/proceedings/2024/431) |
| The Marginal Value of Momentum for Small Learning Rate SGD | Wang, Malladi, Wang, Lyu, Li | 2024 (ICLR) | smooth non-convex, stochastic, small LR regime | continuous-time equivalence proof; informal LB | SGD with and without momentum are equivalent in small-η limit; no acceleration from momentum | [arxiv:2307.15196](https://arxiv.org/abs/2307.15196) |
| On the Provable Suboptimality of Momentum SGD in Nonstationary Stochastic Optimization | (various) | 2026 (arxiv:2601.12238) | smooth strongly convex, nonstationary (time-varying optima) | minimax LB (information-theoretic, drift-dominated regime) | momentum-SGD provably worse than SGD by drift-amplification factor; β→1 diverges | [arxiv:2601.12238](https://arxiv.org/abs/2601.12238) |
| Momentum-Based Variance Reduction in Non-Convex SGD (STORM) | Cutkosky, Orabona | 2019 (NeurIPS) | smooth non-convex, online, no large batch | UB: momentum for variance reduction | O(ε⁻³) gradient queries (matching LB under mean-sq-smooth model); does NOT fix β | [arxiv:1905.10018](https://arxiv.org/pdf/1905.10018) |
| SGD with memory: fundamental properties and stochastic acceleration | Yarotsky, Velikanov | 2025 (ICLR) | smooth (power-law spectrum quadratics), stochastic, memory-M algorithms | UB + structural LB for stationary memory-M algorithms | stationary memory-M algorithms keep exponent ξ of plain GD; LB on exponent — no acceleration from SHB in stationary regime | [arxiv:2410.04228](https://arxiv.org/abs/2410.04228) |

---

## Gap Assessment: SHB-Specific Non-Convex Stochastic LB

### What Arjevani et al. 2023 covers and does NOT cover

Arjevani et al. 2023 is a **class-level (minimax) LB**: it proves that no SFO algorithm can find an ε-stationary point of a smooth non-convex f in fewer than Ω(ε⁻⁴) oracle queries. This applies to SHB by inclusion (SHB is an SFO algorithm), so SHB trivially inherits the Ω(ε⁻⁴) lower bound.

However:
1. The paper does **not** construct an SHB-specific hard instance. The construction is a hard function for the entire algorithm class; it does not show that SHB specifically (with fixed β) requires more than Ω(ε⁻⁴) or cannot match the Ω(ε⁻⁴) rate.
2. The paper does **not** address whether SHB with fixed β achieves the matching O(ε⁻⁴) upper bound. In fact, no paper to date proves that fixed-β SHB achieves E‖∇f‖²≤ε² in O(ε⁻⁴) for smooth non-convex f (the convergence results for SHB in non-convex settings are qualitative or restricted to specialized settings).
3. The paper does **not** provide a β-dependent constant, i.e., it does not show whether the implied constant in the LB for SHB degrades as β→0 (recovering SGD) or β→1.

### Status of the gap

**PARTIAL GAP**: The minimax Ω(ε⁻⁴) is settled. The SHB-specific gap — whether:
(a) fixed-β SHB achieves O(ε⁻⁴) at all (upper bound open), and
(b) there exists a hard instance for SHB that is SHB-specific (i.e., SGD can find ε-stationary point faster on the same instance) — is **OPEN**.

The IJCAI 2024 paper and the marginal-value paper show SHB cannot accelerate beyond ε⁻⁴ in the non-convex stochastic setting, but they do not provide a tight, quantitative, SHB-specific LB with explicit β-dependence.

**No paper** has proved a cycling-based or construction-based SHB-specific LB for the non-convex smooth stochastic setting. The GTD cycling technique (in the user's library) is entirely in the convex/SC setting. Extending it to non-convex is the proposed A2 contribution.
