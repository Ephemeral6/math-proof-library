# OPP Protocol — Round 1

**Date**: 2026-04-17 (re-verified same day)
**Method**: Open-Problems-from-Papers (OPP) — extract formally-posed open questions from published papers, check current status, assess reach.
**Targets**: OP-1 (Koren-Segal 2020 COLT), OP-2 (Lessard-Recht-Packard 2016 stochastic HB), OP-3 (Foret et al. 2021 SAM stochastic non-convex).

> **Re-verification stamp (2026-04-17)**: fresh arXiv / PMLR sweep confirms all three status judgments below.
> • OP-1 constant-$d$ gap still open; the April-2026 GD last-iterate preprint strengthens the "log factor is intrinsic" direction.
> • OP-2 strongly-convex non-acceleration **formally closed** by "Provable non-accelerations of the heavy-ball method" (Math. Prog., Oct 2025) — general-convex stochastic impossibility angle remains open.
> • OP-3 stochastic non-convex rate established (arXiv:2503.02225, Mar 2025); explicit $\rho$-tightness open.
> • **User note**: the prompt labeled OP-1 "smooth convex" — corrected below. Koren-Segal is **non-smooth Lipschitz convex**.

> **Clarification on OP-1 setting.** Koren-Segal 2020 is about **non-smooth Lipschitz convex** SGD, not smooth convex. The smooth-convex last-iterate question is a *separate* open problem, now essentially resolved by [arXiv:2507.14122](https://arxiv.org/abs/2507.14122) (July 2025) at $\tilde O(1/\sqrt T)$ without variance bound. If the user's intent was the smooth variant, **OP-1 is effectively SOLVED** and should be dropped from the candidate list.

---

## OP-1 — Koren & Segal 2020 COLT, "Open Problem: Tight Convergence of SGD in Constant Dimension"

### Exact problem statement

**Source**: [PMLR vol. 125, Koren & Segal 2020](http://proceedings.mlr.press/v125/koren20a/koren20a.pdf)

- **Setting**: SGD on **non-smooth Lipschitz convex** functions with fixed step-size $\eta = \Theta(1/\sqrt T)$, bounded domain.
- **Current bounds (as of 2020)**:
  - Upper bound: $O(\log T / \sqrt T)$ for the expected excess risk of the last iterate $x_T$ (Harvey et al. 2019).
  - Lower bound: $\Omega(1/\sqrt T)$ — the standard rate.
  - **Gap**: $\log T$ factor.
- **Conjecture**: in constant dimension $d = O(1)$, the correct rate is $\Theta(1/\sqrt T)$, i.e., the $\log T$ is an artifact of the analysis.
- **Sub-conjecture (1-D)**: even for $d=1$, whether the right answer is $1/\sqrt T$ or $\log T/\sqrt T$ is open.

### Post-2020 progress

| Paper | Contribution | Closes gap? |
|---|---|---|
| [Liu & Zhou 2021 (arXiv:2106.14588)](https://arxiv.org/abs/2106.14588) | $\Omega(\log d / \sqrt T)$ lower bound; tight $O(1/\sqrt T)$ for 1-D in a general setting | Partial — growing-$d$ direction closed, constant-$d$ gap remains |
| [Revisiting Last-Iterate (arXiv:2312.08531, ICLR 2024, v4 Mar 2026)](https://arxiv.org/abs/2312.08531) | High-prob $O(\log(1/\delta)\log T/\sqrt T)$ for non-smooth; also smooth convex last-iterate | Does not close non-smooth $\log T$ gap |
| [Last-Iterate SGD for Convex Smooth (arXiv:2507.14122, July 2025)](https://arxiv.org/abs/2507.14122) | $\tilde O(1/\sqrt T)$ for **smooth** convex; no variance-bound assumption | Different setting (smooth, not Koren-Segal's non-smooth) |
| [Gradient Descent's Last Iterate is Often (slightly) Suboptimal (arXiv:2604.13870, April 2026)](https://arxiv.org/html/2604.13870) | **In noiseless GD, impossible to avoid excess poly-log factor without prior knowledge of T** | Suggests the $\log T$ is intrinsic, not an artifact — **partially refutes Koren-Segal's conjecture in the opposite direction** |

### Status: **⚠️ PARTIAL — very active, likely about to close**

- Lower-bound direction in growing $d$: **closed** (Liu-Zhou 2021).
- Constant-$d$, non-smooth case: **technically open** but April 2026 GD-last-iterate paper suggests the $\log T$ is necessary — the conjecture may resolve the "wrong" direction soon.
- Smooth case (adjacent): settled at $\tilde O(1/\sqrt T)$ in 2025.

### Accessibility and risk

- Library fit: **good** — HRS, Harvey et al. 2019, Shamir-Zhang 2013 averaging, Jain-Kakade variance tools all present.
- Competition: **extreme** — at least 4 papers 2021-2026 targeting this. April 2026 preprint is <1 month old.
- **Risk**: any result we prove has 6-week race window before a community group covers it.

### Difficulty

**A-class, HIGH RISK** — estimated 4-8 sessions for an original contribution, with ~60% probability of being scooped mid-work given the April 2026 activity.

---

## OP-2 — Lessard-Recht-Packard 2016, stochastic Heavy Ball on general convex smooth

### Exact question

**Source**: [Lessard-Recht-Packard 2016 SIAM J. Optim.](https://laurentlessard.com/public/siopt16_iqcopt.pdf)

- Does stochastic Heavy Ball (SHB) with Polyak momentum **accelerate** over vanilla SGD on **smooth convex but non-strongly-convex non-quadratic** objectives?
- Known negative results: Kidambi et al. 2018 — no acceleration for stochastic *quadratic* case; Ghadimi-Zhang-Sra 2015 — negative result extends to general strongly-convex non-quadratic (Lessard's counterexample at condition ratio 25).

### Post-2016 progress

| Paper | Contribution | Answers OP-2? |
|---|---|---|
| [Sebbouh-Gower-Defazio 2021](https://arxiv.org/abs/2006.07867) | Convergence to neighborhood for convex smooth SHB | Partial |
| [Schaipp et al. 2024 (arXiv:2406.04142)](https://arxiv.org/abs/2406.04142) | **MomDecSPS / MomAdaSPS: first adaptive SHB with convergence to exact minimizer on convex smooth, no interpolation assumption** | **Substantially yes** |
| [Accelerated Noise-adaptive SHB (arXiv:2401.06738)](https://arxiv.org/abs/2401.06738) | Acceleration for strongly-convex quadratics with large mini-batches; strongly-convex smooth $O(\exp(-T/\kappa) + \sigma^2/T)$ | Strongly-convex case only |
| [AOR-HB (arXiv:2406.09772)](https://arxiv.org/abs/2406.09772) | First HB variant with provable *global accelerated* convergence for strongly convex smooth | Strongly-convex case only |

### Status: **🟡 PARTIAL-LEANING-SOLVED**

- Strongly-convex smooth: essentially closed (2024).
- **General convex smooth (non-strongly-convex)**: MomDecSPS/MomAdaSPS 2024 cover convergence-to-minimizer; remaining residue is whether an *accelerated* $O(1/T^2)$-type rate is attainable or provably not. The negative evidence from Kidambi + Lessard suggests the answer is NO.
- Residual gap: **formal impossibility theorem** for non-acceleration of SHB on general convex smooth stochastic, OR a matching $o(1/T)$ upper bound.

### Accessibility and risk

- Library fit: **good** — IQC framework, Lyapunov techniques, stochastic variance-reduction tools all present.
- Competition: **moderate** — 2024 work is heavy, but the impossibility angle is less crowded.
- Risk: similar to OP-1 — the Schaipp 2024 paper comes very close to claiming the full territory.

### Difficulty

**A-class** if aiming for impossibility theorem; **B/C-class** if just consolidating existing results. 3-6 sessions for impossibility.

---

## OP-3 — Foret et al. 2021, SAM stochastic non-convex convergence with explicit ρ dependence

### Exact question

**Source**: [Foret et al. 2021 ICLR (SAM paper)](https://openreview.net/forum?id=6Tm1mposlrM) — future work explicitly calls for "rigorous convergence analysis of SAM under stochastic gradients for non-convex objectives" with explicit ascent-radius $\rho$ dependence.

### Post-2021 progress

| Paper | Contribution | Answers OP-3? |
|---|---|---|
| [Andriushchenko-Flammarion 2022 ICML](https://arxiv.org/abs/2206.06232) | SAM implicit bias; deterministic smooth non-convex | Partial (non-stochastic) |
| [JMLR 2025, SAM and Edge of Stability](http://jmlr.org/papers/volume25/23-1285/23-1285.pdf) | Stochastic SAM $O(1/t)$ rate | Partial |
| [SAM: General Analysis and Improved Rates (arXiv:2503.02225, March 2025)](https://arxiv.org/abs/2503.02225) | **Unified analysis; $O(1/\varepsilon^2)$ iteration complexity for stochastic non-convex; claims tightness by recovering SGD at ρ=0** | **Largely yes** |
| [Hallucinate Minimizers (arXiv:2509.21818, Sept 2025)](https://arxiv.org/html/2509.21818) | Negative result: SAM can hallucinate minimizers | Orthogonal concern |

### Status: **🟡 PARTIAL — main rate established, ρ-tightness open**

- Stochastic non-convex rate: **established** at $O(1/\varepsilon^2)$.
- Explicit $\rho$ dependence in the rate: **partially embedded** (coupled with step-size choice), not isolated.
- Residual gap: **tight lower bound matching in $\rho$** — i.e., is the $\rho$ coupling in Orabona-style analyses necessary? Or can the rate be proved with $\rho$-independent-dominant terms?

### Accessibility and risk

- Library fit: **moderate** — need Ghadimi-Lan 2013 non-convex, Ajalloeian-Stich 2020 biased oracle, plus SAM-specific tools we don't have.
- Competition: **high** — 2025 has 3+ major SAM-convergence papers.
- Risk: very active empirical deep-learning community chasing this; theoretical gap is narrow.

### Difficulty

**A-class, specialized.** Would require learning SAM-specific machinery. 6-10 sessions. Lower priority than OP-1 or OP-2.

---

## Summary table

| OP | Status | Library fit | Competition | Sessions | Verdict |
|---|---|---|---|---|---|
| OP-1 | PARTIAL (about to close against conjecture) | ★★★ | extreme (2026 activity) | 4-8 | risky |
| OP-2 | PARTIAL-LEANING-SOLVED | ★★★ | moderate | 3-6 | most actionable |
| OP-3 | PARTIAL | ★★ | high | 6-10 | least favorable |

---

## Recommendation

### Primary: **OP-2 (impossibility for SHB on convex smooth stochastic)** as the first OPP-attempt.

**Why**:
1. The question naturally factors into an **impossibility theorem** — this is a narrower, cleaner target than the "prove matching upper bound" version of OP-1/OP-3.
2. Lessard's IQC framework + the existing Kidambi counterexample in the quadratic case gives a **concrete starting point** — likely a one-dimensional non-quadratic construction generalizing Lessard's ratio-25 example to the non-strongly-convex + stochastic setting.
3. Lower competition: the positive-result side is being actively pursued (Schaipp 2024), but the formal impossibility side has had much less activity since 2018.
4. Our library has IQC, stochastic SGD lower bounds (Arjevani et al. 2019), and Lyapunov tools — all the pieces are there.

### Secondary: OP-1 only if a clear angle emerges that the community hasn't tried

- **Do not** attempt the main conjecture (constant-dimension $\Theta(1/\sqrt T)$) — too crowded, too many groups racing.
- **Possible niche**: high-probability versions in constant dimension, or data-dependent last-iterate bounds specific to certain loss families (SVM, logistic). These are narrower and might have residual room.

### Tertiary: Drop OP-3

- The 2025 Orabona-style unified analysis is too recent and too comprehensive. Any contribution here would be a minor refinement.

---

## Meta-observation: OPP protocol finding

**The OPP methodology did NOT find uncrowded territory.**

All three OPs we extracted — from papers that are foundational and whose open problems are explicit — are in active 2024-2026 research cycles. This is not a methodology failure but a **selection bias**: explicit open problems in famous papers naturally attract researchers.

**Refinement to OPP**: in round 2, target open problems from papers that are:
- **Less famous** (fewer than ~500 citations) — reduces community competition.
- **Older** (pre-2015) — lets us filter by "still open after ≥10 years" as a strong signal of real difficulty with less racing.
- **In niche subfields** — e.g., mirror descent under non-standard Bregman distances, Nesterov on manifolds, or stability of non-standard regularizers.

The 81 library proofs cover these niches too; round 2 should explicitly **exclude** papers whose base work is currently trending (SAM, last-iterate SGD, SPS, STORM).

---

## Next action

Execute OP-2 feasibility-to-proof pipeline, specifically targeting:

> **OP-2-sharpened**: Prove that no stochastic Heavy Ball method (with any fixed momentum $\beta \in (0,1)$ and any deterministic step-size schedule) can achieve a convergence rate strictly better than $\Omega(1/T)$ for the expected excess risk on the class of $L$-smooth convex (not strongly convex) objectives with stochastic gradient noise of variance $\sigma^2$, in the absence of interpolation.

If this is indeed open (which needs one final literature check focused on Sebbouh + Schaipp reverse-citation sweep), it is a B-to-A class result directly from library tools.

---

## Sources

- [Koren & Segal 2020, COLT (PMLR 125)](http://proceedings.mlr.press/v125/koren20a/koren20a.pdf)
- [arXiv:2106.14588](https://arxiv.org/abs/2106.14588) — Liu & Zhou, dimension-dependent lower bounds (partial resolution of OP-1)
- [arXiv:2312.08531](https://arxiv.org/abs/2312.08531) — Revisiting Last-Iterate Convergence (ICLR 2024 → Mar 2026 v4)
- [arXiv:2507.14122](https://arxiv.org/abs/2507.14122) — Last-iterate SGD for convex smooth (July 2025)
- [arXiv:2604.13870](https://arxiv.org/html/2604.13870) — GD last-iterate poly-log lower bound (April 2026)
- [Lessard-Recht-Packard 2016 SIAM J. Optim.](https://laurentlessard.com/public/siopt16_iqcopt.pdf) — IQC framework
- [arXiv:2401.06738](https://arxiv.org/abs/2401.06738) — Noise-adaptive SHB 2024
- [arXiv:2406.04142](https://arxiv.org/abs/2406.04142) — Schaipp et al. MomSPS 2024
- [arXiv:2406.09772](https://arxiv.org/abs/2406.09772) — AOR-HB 2024
- [arXiv:2206.06232](https://arxiv.org/abs/2206.06232) — Andriushchenko-Flammarion 2022, SAM implicit bias
- [arXiv:2503.02225](https://arxiv.org/abs/2503.02225) — SAM general analysis (March 2025)
- [arXiv:2509.21818](https://arxiv.org/html/2509.21818) — SAM hallucinates minimizers (Sept 2025)
- [arXiv:1912.02365](https://arxiv.org/abs/1912.02365) — Arjevani et al., non-convex stochastic lower bounds (library-relevant tool for OP-2 impossibility)
