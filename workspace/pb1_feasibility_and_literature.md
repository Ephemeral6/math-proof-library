# PB-1 — Combined Feasibility + Literature Analysis (Candidate #6)

**Date**: 2026-04-17
**Direction**: SPS-SGD (Loizou et al. 2021) extended to inexact optimum $f^\star$ — i.e., convergence of SPS-style stepsizes when $f^\star_\xi$ is only known up to error $\delta$ (or only a lower bound is available).

**Prior track record**: 5/5 candidates (C3.4, C1.4, C3.3, R1, R3) killed by literature. User directive: "文献搜索必须极其彻底".

---

## Part 1 — Literature Clearing (highest priority)

### 🔴 Direct subsumer #1: Orvieto–Lacoste-Julien–Loizou 2022 (NeurIPS)

**arXiv:[2205.04583](https://arxiv.org/abs/2205.04583)** — "Dynamics of SGD with Stochastic Polyak Stepsizes: Truly Adaptive Variants and Convergence to Exact Solution"

- Introduces **DecSPS** (Decreasing SPS): converges to the **exact minimizer** in the interpolation-free setting **without knowing any problem parameter, including $f^\star$**.
- Uses surrogate $\ell^\star$ instead of $f^\star_\xi$; surrogate can be set to 0 or to an estimated lower bound.
- Explicitly framed as solving the "unknown $f^\star_\xi$" problem that Loizou 2021 left open.

**Verdict**: this IS the paper PB-1 would be trying to write.

### 🔴 Direct subsumer #2: Jiang & Stich 2023 (NeurIPS)

**arXiv:[2308.06058](https://arxiv.org/abs/2308.06058)** — "Adaptive SGD with Polyak Stepsize and Line-search: Robust Convergence and Variance Reduction"

- Introduces **AdaSPS**: "requires only a *lower bound* of the optimal function value as input."
- Proves convergence in convex + non-interpolation setting under noisy $f^\star$.
- Combined with SVRG-style variance reduction for better rates.

**Verdict**: directly answers PB-1's exact technical question (replace $f^\star_\xi$ with a lower bound / inexact proxy).

### 🔴 Direct subsumer #3 (MOST DAMAGING): Orabona & D'Orazio 2025 (NeurIPS)

**arXiv:[2505.20219](https://arxiv.org/abs/2505.20219)** — "New Perspectives on the Polyak Stepsize: Surrogate Functions and Negative Results"

- Provides a unified surrogate-function framework that recovers SPS, DecSPS, AdaSPS as special cases.
- **Explicitly proves negative results for the unknown-$f^\star$ case**: "the properties of the surrogate functions break if the optimum value is not known, and convergence results cannot be proven but only that the suboptimality gap will converge up to a floor that depends on the surrogate function value at the unknown optimum."
- This is both a **positive subsumption** (the framework covers inexact-$f^\star$ analyses) and a **negative impossibility** (tight floor term cannot be removed without additional structure).

**Verdict**: this paper closes the door on the "clean" version of PB-1 with a formal negative result, and subsumes the clean attempts already made.

### 🔴 Further coverage

- **Schaipp–Gower–Ulbrich 2023** — stochastic proximal Polyak; handles composite objectives with estimated $f^\star$.
- **Sparse Polyak (2025)** — high-dim M-estimation with SPS-like steps under inexact $f^\star$.
- **Level-Value Adjustment (2025)** — online adjustment of the SPS reference level.
- **AdaSLS / AdaSPS nonconvex (arXiv:2511.20207, 2025)** — extends AdaSPS to non-convex smooth, still with lower-bound-only oracle.
- **MomSPSmax / MomDecSPS / MomAdaSPS (2024)** — momentum variants under inexact $f^\star$.

### Coverage table

| Criterion | PB-1 target | Covered by |
|---|---|---|
| SPS with unknown $f^\star$ | core question | Orvieto 2022, Jiang-Stich 2023 |
| Convergence to exact minimizer | yes | Orvieto 2022 (DecSPS) |
| Lower-bound-only oracle | yes | Jiang-Stich 2023 (AdaSPS) |
| Non-convex smooth | stretch goal | AdaSLS 2025 |
| Negative results / impossibility | — | Orabona-D'Orazio 2025 |
| Unified surrogate framework | — | Orabona-D'Orazio 2025 |

**6/6 criteria covered. The technical question PB-1 was meant to address is mathematically answered (both positively, by AdaSPS/DecSPS, and negatively, by Orabona-D'Orazio's floor term).**

---

## Part 2 — Verdict

### 🔴 **RED — FULLY COVERED**

This is the **6th consecutive candidate killed by literature**. The subsumption is tighter than any previous case: PB-1 has been addressed by three NeurIPS papers (2022, 2023, 2025), with the 2025 paper containing explicit negative results.

### Pattern summary (6/6 death by literature)

| # | Candidate | Subsumer |
|---|---|---|
| 1 | C3.4 (OR ⇒ stability) | Kozachkov 2022 |
| 2 | C1.4 (STORM ⇒ MCMC) | Kipnis-Varadhan 1986 (impossibility) |
| 3 | C3.3 (potential-game generalization) | Dontchev-Rockafellar / IFT triviality |
| 4 | R1 (HRS → Markov SGD) | Lei et al. 2022 NeurIPS |
| 5 | R3 (STORM biased oracle) | Jin-Scutari-Xie 2023 (AB-STORM) |
| 6 | PB-1 (SPS inexact $f^\star$) | Orvieto 2022 / Jiang-Stich 2023 / Orabona-D'Orazio 2025 |

**The analogy-generalization methodology has a 0/6 hit rate. This is no longer noise — it's a structural failure.**

---

## Part 3 — Quick judgment on PB-2 (Chambolle-Pock inexact prox), 3 sentences

PB-2 (PDHG with inexact proximal operator) is already addressed by **Rasch & Chambolle 2020** ("Inexact first-order primal-dual algorithms", Computational Optimization and Applications) and its follow-ups (Lorenz-Rasch 2021, Jiang-Vandenberghe 2022), all of which give explicit inexactness-summability conditions for PDHG to retain $O(1/k)$ ergodic rates. The pattern from the previous 6 failures strongly predicts that any "clean" inexact-prox PDHG result is subsumed within 1-2 WebFetches of the Rasch-Chambolle citation graph. **Expected fate: RED — do not invest further effort before executing at minimum a Rasch-Chambolle citation-graph sweep (the same depth we should have started with on candidates 1-6).**

---

## Part 4 — Methodology change proposal

### Diagnosis of the failure

The "analogy-generalization" route takes a published theorem and asks: "what if we generalize assumption X → X'?" This route has two failure modes, both of which we've hit repeatedly:

1. **Horizon 1 subsumption**: the natural generalization is already in a paper citing the base theorem (6/6 of our candidates).
2. **Structural subsumption**: a classical result (Kipnis-Varadhan) makes the generalization provably impossible or trivial.

The route fails because **the natural generalizations of famous theorems are the most obvious targets for follow-up work**, and at least one research group has always gotten there first. Our shallow initial literature scans systematically miss the direct follow-up papers because generalization work often doesn't use the same keywords as the base theorem.

### Proposed new methodology: **Open-Problems-from-Papers (OPP)**

**Core shift**: instead of starting from "a theorem I've proved" and asking "what generalizes", start from **"future work / open problems" sections of the original papers behind the 81 library proofs** and ask "which of these is still open and within my reach?"

**Why this works differently**:

- Open problems in published papers are **already vetted as non-trivial** by the authors and reviewers.
- An open problem flagged in 2020 that's still open in 2026 has **documented 6-year survival against the community** — much stronger evidence of genuine difficulty than any analogy we can spin up.
- The search cost is **bounded**: each paper has a finite "future work" section. 81 papers × ~3 open problems each = ~240 concrete targets, most of which can be checked against arXiv in minutes.
- Finding "not yet solved" is easier than finding "not covered by any similar result" — citation graphs on an explicit open problem are narrow.

**Protocol**:

1. For each of the 81 library proofs, read the original paper's "Open Problems" / "Future Work" / "Discussion" section.
2. Extract each posed open question verbatim.
3. Run a **targeted** literature check: has this specific question been answered?
4. If no answer exists after N years (N ≥ 3 is a soft signal, N ≥ 5 is strong), and we have the technical tools to attempt it, queue it.
5. Rank queued problems by (a) age, (b) technical accessibility from current library, (c) narrowness (narrow = fewer adjacent subsumers).

**This inverts the current pipeline**: literature comes first, technical analysis second, rather than technical idea first, literature second.

---

## Part 5 — Three concrete open problems from the 81 library papers

These are **starting points** — each requires an OPP-protocol pass before committing to proof work. They are selected for (a) explicit open-problem status in the source paper, (b) narrowness, (c) technical reach of the existing library.

### OP-1: Last-iterate convergence of SGD for smooth convex functions

**Source**: Koren & Segal 2020 COLT, "Open Problem: Suboptimality of Last-Iterate Gradient Descent on Convex Functions" — **the paper itself is a posed open problem**, not a theorem paper.

**Question**: Is the $\Omega(\log T / \sqrt T)$ gap between last-iterate and averaged-iterate SGD on convex smooth functions tight, or can one close it?

**Status**: partial progress by Harvey et al. 2019 (non-smooth case resolved), Jain et al. 2019 (strongly convex case tight). **Smooth convex case remains open as of late 2025 to my knowledge** — must verify.

**Accessibility**: our library has HRS 2016 stability, Bach-Moulines 2013 SGD analysis, and Jain-Kakade 2018 variance-reduction tools. The problem lives in exactly this toolset.

**Next action**: run OPP protocol — search arXiv for "last iterate SGD smooth convex" post-2024 to confirm still open.

### OP-2: Stochastic analysis of Heavy Ball / Polyak momentum for general convex functions

**Source**: Lessard–Recht–Packard 2016 "Analysis and Design of Optimization Algorithms via Integral Quadratic Constraints" — explicitly flags in its discussion that the IQC framework does not extend cleanly to the stochastic Heavy Ball case for general (non-quadratic) convex functions.

**Question**: Does stochastic Heavy Ball achieve acceleration over vanilla SGD on smooth convex non-quadratic objectives, or is this impossible (as suggested by Kidambi et al. 2018 for quadratics)?

**Status**: Kidambi et al. 2018 showed non-acceleration for stochastic quadratic case; Sebbouh-Gower-Defazio 2021 gave partial results; general convex smooth stochastic Heavy Ball is **not fully resolved** as of 2025.

**Accessibility**: IQC toolbox in the library + recent Lyapunov techniques (Taylor-Bach 2019) make this tractable if the problem is indeed still open.

**Risk flag**: a literature sweep must check the Sebbouh/Bubeck/d'Aspremont citation graphs carefully — this area has many partial results, and the "open" residue may be narrower than it looks.

### OP-3: Sharpness-Aware Minimization (SAM) convergence under stochastic gradients in non-convex setting

**Source**: Foret–Kleiner–Mobahi–Neyshabur 2021 ICLR, "Sharpness-Aware Minimization" — explicit future work: "rigorous convergence analysis of SAM under stochastic gradients for non-convex objectives".

**Status**: Andriushchenko & Flammarion 2022 provided partial analysis (deterministic smooth non-convex, implicit-bias perspective). Dai–Zhang et al. 2023 gave some stochastic results but under restrictive assumptions. **Tight non-convex stochastic convergence rate with explicit dependence on the ascent radius $\rho$ is, as of 2025, partially open**.

**Accessibility**: our library has SGD non-convex analysis (Ghadimi-Lan 2013), variance-reduction tools (STORM, SPIDER), and bias-oracle tools (Ajalloeian-Stich 2020) — SAM's inner-max gradient is provably a biased oracle, which is a direct connection.

**Risk flag**: this problem is hot (many 2024-2025 papers). Citation sweep essential before committing.

---

## Part 6 — Recommended next action

1. **Do NOT proceed to PB-1 proof work.**
2. **Do NOT proceed to PB-2 without a prior Rasch-Chambolle citation sweep.** Expected: RED.
3. **Adopt OPP methodology**: commit 1-2 sessions to a systematic "future work extraction" pass over the library's 81 papers. This is the highest-expected-value next step.
4. **Prioritize OP-1 (Koren-Segal 2020) as the first OPP target** — it is the safest because the "open problem" status is *explicit and formally published*, not inferred from a future-work paragraph. If OP-1 is still open in 2026, we have our first clean candidate.

---

## Sources

- [arXiv:2205.04583](https://arxiv.org/abs/2205.04583) — Orvieto et al. 2022 NeurIPS, DecSPS.
- [arXiv:2308.06058](https://arxiv.org/abs/2308.06058) — Jiang & Stich 2023 NeurIPS, AdaSPS.
- [arXiv:2505.20219](https://arxiv.org/abs/2505.20219) — Orabona & D'Orazio 2025 NeurIPS, surrogate framework + **negative results**.
- Rasch & Chambolle 2020, COAP — inexact PDHG (for PB-2 quick judgment).
- Koren & Segal 2020 COLT — open problem on last-iterate SGD (OP-1).
- Lessard–Recht–Packard 2016 SIAM J. Optim. — IQC framework, stochastic HB future work (OP-2).
- Foret et al. 2021 ICLR — SAM, stochastic non-convex future work (OP-3).
