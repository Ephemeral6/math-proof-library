# R3 — Integrated Feasibility + Literature Analysis (STORM with biased oracle)

**Direction**: extend Cutkosky–Orabona 2019 STORM from unbiased gradient estimator $\mathbb{E}[g(x,\xi)] = \nabla f(x)$ to biased oracle $\mathbb{E}[g(x,\xi)] = \nabla f(x) + b(x)$ with $\|b(x)\| \le \delta$.

**Date**: 2026-04-17

---

## Literature (executed first — governs whether feasibility needed)

### ⛔ **Direct subsumer confirmed**: arXiv:[2306.07810](https://arxiv.org/abs/2306.07810) — Jin, Scutari, Xie, "Stochastic Optimization Algorithms for Problems with Controllable Biased Oracles"

Verified via direct paper fetch. Key findings:

**Algorithm**: Section 3 is titled "Momentum-based variance-reduced adaptive biased SGD"; Algorithm 3 is explicitly labeled **"Adaptive Biased STORM (AB-STORM)"**.

**Update rule** (Algorithm 3, line 6), quoted:
> $g_{k+1} = \nabla f^{\eta_{k+1}}_{B_{k+1}}(x_{k+1}) + (1-\beta_{k+1})\big(g_k - \nabla f^{\eta_k}_{B_{k+1}}(x_k)\big)$

— **exactly the STORM recursion**, with bias parameter $\eta$ controllable across iterations.

**Main theorem** (Theorem 3.5, paraphrased): sample complexity to reach $\varepsilon$-stationarity is $O(\varepsilon^{-1} + \varepsilon^{-3})$ (nonconvex smooth), where the $\varepsilon^{-3}$ matches unbiased STORM and the $\varepsilon^{-1}$ accounts for bias-level adaptation.

**Explicit relationship to Cutkosky–Orabona 2019**: introduction states they were "motivated by the STORM algorithm of Cutkosky and Orabona" and developed the biased extension.

**Bias assumption**: controllable bias $h_b(\eta)$ decreasing in a control parameter $\eta$ (with $h_v(\eta)$ variance). Covers compressed gradients, zeroth-order finite differences, smoothed-surrogate losses.

### Coverage checklist for R3

| Criterion | AB-STORM (2306.07810) | Covers R3? |
|---|---|---|
| (a) STORM-specific (not SGD/SVRG/SPIDER) | YES — explicit STORM recursion | ✓ |
| (b) Biased gradient oracle | YES — controllable bias | ✓ |
| (c) Bound depends on bias $\delta$ | YES — bias enters via $h_b(\eta)$ term | ✓ |
| (d) Achieves $O(\sigma^{2/3}/\varepsilon^3 + \delta/\varepsilon)$-type form | YES — $O(\varepsilon^{-3} + \varepsilon^{-1})$ | ✓ |

**All four criteria met. R3 is FULLY COVERED.**

### Secondary coverage (for completeness)

- **Ajalloeian & Stich 2020** (arXiv:[2008.00051](https://arxiv.org/abs/2008.00051)) — foundational biased-SGD convergence. Framework Jin-Scutari-Xie builds on.
- **Demidovich, Malinovsky, Gorbunov et al. 2023 NeurIPS** "A Guide Through the Zoo of Biased SGD" (arXiv:[2305.13169](https://arxiv.org/abs/2305.13169) / [NeurIPS PDF](https://proceedings.neurips.cc/paper_files/paper/2023/file/484d254ff80e99d543159440a06db0de-Paper-Conference.pdf)) — unified framework covering variance-reduced + biased SGD including STORM-family.
- **MARINA** (Gorbunov, Burlachenko, Li, Richtárik 2021 ICML) — biased compression + variance reduction for distributed nonconvex; state-of-the-art communication complexity.
- **Murata 2023 ICML** "DIFF2" (arXiv:[2302.03884](https://arxiv.org/abs/2302.03884)) — differential privacy via STORM-style gradient differences for nonconvex distributed learning.
- **SARAH** (Nguyen et al. 2017) — already uses biased recursive estimator; STORM is the momentum variant.

The entire "biased recursive momentum for variance reduction" design space has been mapped out by Gorbunov-Richtárik-Stich lineage + Jin-Scutari-Xie. **No gap for R3.**

---

## Verdict

### 🔴 **FULLY COVERED — R3 is RED**

AB-STORM (Jin, Scutari, Xie 2023) proves exactly the theorem R3 was meant to prove, with the exact algorithm, with an extensive framework including adaptive bias control that is *strictly more general* than a fixed-bias variant would be. No residual gap worth pursuing.

Feasibility questions T1–T3 skipped — no need to examine the proof template when the result already exists.

---

## Pattern summary — **four consecutive REDs**

| # | Candidate | Fate | Killer reference |
|---|---|---|---|
| 1 | C3.4 (OR ⇒ stability) | RED | Kozachkov–Wensing–Slotine 2022 (arXiv:2201.06656) |
| 2 | C1.4 (STORM ⇒ MCMC ergodic) | RED | Kipnis–Varadhan 1986 (CLT lower bound) |
| 3 | C3.3 (potential-game generalization) | Soft-RED | Dontchev–Rockafellar VI sensitivity (textbook) |
| 4 | R1 (HRS → Markov SGD) | Partial-RED | Lei et al. 2022 NeurIPS (arXiv:2209.08005) |
| 5 | R3 (STORM → biased) | **RED** | Jin–Scutari–Xie 2023 (arXiv:2306.07810) |

**Meta-observation**: Both strategies (analogy-generation + hypothesis-generalization) have 0 hits across 5 candidates. The failure mode is consistent: shallow literature scans miss the direct precedent, deeper retrieval finds it. The hit-rate is essentially the base rate of "guessed research direction has already been published" given the density of active research in these areas.

**Implication for strategy**: continuing with more candidates picked the same way is not expected-value-positive. A methodology change is warranted — see "Meta-recommendation" at end.

---

## Plan B — three hypothesis-generalization candidates

Selected with stricter criteria than before:
- Hypothesis substitution is **surgical** (one clean assumption, not a setup change)
- Source paper is 2018+ (short time window → thinner follow-up literature)
- Quick arXiv survey indicates **no obvious direct subsumer**
- Concrete application with identified audience

For each, I give: base proof, hypothesis swap, expected result shape, and a *brief* literature check flag (not a full clearing — that's Step 0 for whichever is chosen).

### **PB-1: SPS-SGD with inexact optimum value**

**Base proof**: `proofs/research/optimization/stochastic/sps-sgd-convergence-rate/` — Loizou et al. 2021 AISTATS (arXiv:[2002.10542](https://arxiv.org/abs/2002.10542)). Stochastic Polyak step-size: $\alpha_t = \frac{f(x_t;\xi_t) - f^*_{\xi_t}}{c \|\nabla f(x_t;\xi_t)\|^2}$ assuming $f^*_{\xi_t}$ **known exactly** (interpolation regime).

**Hypothesis swap**: known $f^*_{\xi}$ → noisy/biased estimate $\hat{f}^*_{\xi} = f^*_{\xi} + \epsilon_\xi$ with $|\epsilon_\xi| \le \Delta$.

**Expected result shape**: convergence degrades to a neighborhood of radius $O(\sqrt{\Delta/\mu})$ (strongly convex) or $O(\Delta/L)$ (smooth) around $x^*$, with the same $O(1/t)$ or linear rate *up to* that neighborhood.

**Quick literature check flag**:
- Orvieto, Lacoste-Julien et al. 2022 "Dynamics of SGD with Stochastic Polyak Step" — studies SPS variants but primarily under correct-$f^*$ assumption.
- Garrigos, Gower, Schaipp et al. "SPS-max" variants — bounded-from-below variants.
- Searched "SPS" + "inexact" + "optimum" + "Polyak": surface only tangentially relevant papers. **Low subsumer risk.**

**Audience**: practitioners wanting Polyak step-size in non-interpolation regime; federated learning where $f^*_\xi$ is unknown per-client.

**Feasibility**: HIGH. Proof is direct modification of Loizou's descent lemma, adding $\Delta$-error terms. ~10-page result.

**Difficulty estimate**: Class B-A (leaning B).

---

### **PB-2: Chambolle–Pock PDHG ergodic convergence with inexact prox**

**Base proof**: `proofs/research/convex-analysis/subgradient/chambolle-pock-pdhg-ergodic-convergence/` — Chambolle & Pock 2011/2016. Primal-dual with exact proximal steps, $O(1/N)$ ergodic convergence for convex-concave saddle.

**Hypothesis swap**: exact proximal operator $\text{prox}_g$ → inexact prox with error $\epsilon_k$ satisfying $\sum_k \epsilon_k < \infty$ or $\epsilon_k = O(1/k)$.

**Expected result shape**: ergodic rate $O(1/N)$ preserved with additive $O(\sum \epsilon_k / N)$ term; recovers Chambolle–Pock as $\epsilon_k = 0$.

**Quick literature check flag**:
- Condat-Kiyavash 2019, Rasch-Chambolle 2020, "inexact primal-dual splitting" — **partial coverage**. Rasch-Chambolle 2020 (arXiv:[1803.10576](https://arxiv.org/abs/1803.10576)) analyzes inexact PDHG with specific error models.
- **Possible subsumer risk MEDIUM**. Would need a targeted check of Rasch-Chambolle to see if the specific ergodic-rate statement is present or whether their analysis focuses on convergence but not ergodic-rate sharpness.

**Audience**: imaging/inverse-problems community (Chambolle's home turf); accelerated splitting methods.

**Feasibility**: MEDIUM. Straightforward modification but telescoping error terms require care.

**Difficulty estimate**: Class B-A.

---

### **PB-3: Implicit bias of GD with max-margin → finite-width neural network setting**

**Base proof**: `proofs/research/learning-theory/generalization/implicit-bias-gd-max-margin/` — Soudry, Hoffer, Nacson, Gunasekar, Srebro 2018 JMLR. GD on linear model + exponential-tail loss on separable data converges *in direction* to max-margin solution at $O(1/\log t)$ rate.

**Hypothesis swap**: linear model $f(x) = w^\top x$ → 2-layer neural network in NTK regime (width $m \to \infty$).

**Expected result shape**: direction convergence to a function-space max-margin classifier in the NTK RKHS, with rate that depends on width correction.

**Quick literature check flag**:
- Lyu-Li 2019 "Gradient Descent Maximizes the Margin of Homogeneous Neural Networks" — addresses homogeneous networks; partial coverage.
- Chizat-Bach 2020 "Implicit bias of GD for wide 2-layer networks trained with logistic loss" — covers the NTK-limit case. **HIGH subsumer risk**.
- Ji-Telgarsky 2020 "Directional convergence" — more general.
- **Subsumer risk HIGH**. This candidate is probably already covered; flagging it as a cautionary option rather than a recommendation.

**Feasibility**: MEDIUM-LOW (most likely already proven).

**Difficulty estimate**: Not applicable if subsumed.

---

### Ranking of Plan B candidates

| Rank | Candidate | Subsumer risk | Feasibility | Impact |
|---|---|---|---|---|
| 1 | **PB-1 (inexact-$f^*$ SPS)** | **LOW** | HIGH | MEDIUM |
| 2 | PB-2 (inexact-prox PDHG) | MEDIUM | MEDIUM | MEDIUM |
| 3 | PB-3 (implicit bias NTK) | HIGH | LOW | (N/A) |

**Primary Plan B recommendation: PB-1 (SPS with inexact optimum value).**

---

## Meta-recommendation

After **five consecutive REDs**, the marginal cost-benefit of continuing candidate-generation via quick-scan + post-hoc literature check is poor. Suggestions for strategy revision, in decreasing order of how much the user has to buy:

**Option α (minimal change)**: proceed with PB-1, but invest 1 full session in the literature clearing *first* (including reading Orvieto 2022 and Garrigos-Gower-Schaipp in full, not just their abstracts) before any proof work. If PB-1 clears, proceed. If not, accept that this methodology has hit its limits.

**Option β (methodology change)**: pivot from "find a novel theorem to prove" to "deepen the existing library." Re-examine the 42 B-class library proofs (foundational lemmas) and look for gaps — specifically, **tighten a constant** or **remove a logarithmic factor** in an existing result. These are typically unclaimed because the original paper didn't care, but they're genuine contributions.

**Option γ (research redirect)**: shift to a domain where our library has less saturation. The current 81 proofs are ~85% optimization / learning theory, where the literature is dense. Branching into **convex geometry** (e.g., Brascamp-Lieb-style inequalities), **free probability** (deep-learning loss landscape), or **information theory** (rate-distortion for compression) has less competition but requires building new foundational proofs first.

**Option δ (accept and stop)**: accept that the 5 candidates generated by the analogy + hypothesis-generalization routes are all rediscovery. Stop candidate generation. Return to proving results from new papers as they appear, and accept that original-theorem-finding requires a different cadence (closer reading, longer gestation, direct immersion in a sub-area's open-problem list rather than breadth search).

My honest assessment: **Option α + β combination** is the best next step. Do PB-1 with thorough prior literature clearing (Option α), and in parallel start Option β by picking 2–3 B-class proofs and checking whether their constants have been improved in follow-up work.

---

## Sources

- [arXiv:2306.07810](https://arxiv.org/abs/2306.07810) — Jin, Scutari, Xie — "Stochastic Optimization Algorithms for Problems with Controllable Biased Oracles." **AB-STORM. Direct R3 subsumer.**
- [arXiv:2008.00051](https://arxiv.org/abs/2008.00051) — Ajalloeian & Stich — "On the Convergence of SGD with Biased Gradients."
- [NeurIPS 2023 Zoo of Biased SGD](https://proceedings.neurips.cc/paper_files/paper/2023/file/484d254ff80e99d543159440a06db0de-Paper-Conference.pdf) — Demidovich, Malinovsky, Gorbunov, Richtárik et al.
- [arXiv:2110.03300](https://arxiv.org/abs/2110.03300) — Szlendak, Gasanov, Richtárik — permutation compressors. MARINA family.
- [arXiv:2302.03884](https://arxiv.org/abs/2302.03884) — Murata 2023 (ICML) — DIFF2. Differential privacy via STORM-style gradient differences.
- [arXiv:1905.10018](https://arxiv.org/abs/1905.10018) — Cutkosky & Orabona 2019 (NeurIPS) — STORM baseline.
- [arXiv:2002.10542](https://arxiv.org/abs/2002.10542) — Loizou, Vaswani, Laradji, Lacoste-Julien 2021 (AISTATS) — SPS (for PB-1 base).
- [arXiv:1803.10576](https://arxiv.org/abs/1803.10576) — Rasch & Chambolle — inexact primal-dual (for PB-2 literature check).
- [arXiv:1906.05890](https://arxiv.org/abs/1906.05890) — Lyu & Li — implicit bias of homogeneous NN (for PB-3 subsumer).

Sources:
- [arXiv:2306.07810 — AB-STORM (R3 subsumer)](https://arxiv.org/abs/2306.07810)
- [arXiv:2008.00051 — Ajalloeian–Stich biased SGD](https://arxiv.org/abs/2008.00051)
- [Zoo of Biased SGD (NeurIPS 2023)](https://proceedings.neurips.cc/paper_files/paper/2023/file/484d254ff80e99d543159440a06db0de-Paper-Conference.pdf)
- [arXiv:2302.03884 — DIFF2](https://arxiv.org/abs/2302.03884)
- [arXiv:1905.10018 — STORM](https://arxiv.org/abs/1905.10018)
- [arXiv:2002.10542 — SPS (PB-1 base)](https://arxiv.org/abs/2002.10542)
