# R1 — Literature Clearing (Step 0 gate before proof start)

**Objective**: determine whether "Markovian SGD uniform stability bound" has been published. Verdict governs whether R1 proof work begins or we pivot to R3.

**Date**: 2026-04-17

---

## Primary finding

### ⚠️ arXiv:[2209.08005](https://arxiv.org/abs/2209.08005) — "Stability and Generalization for Markov Chain Stochastic Gradient Methods" (Lei et al., NeurIPS 2022)

**This is the direct subsumer candidate for R1.** Paper details from abstract + multiple secondary search confirmations:

- **Self-describes as "first-ever-known work on stability and generalization of SGD and SGDA under the Markov chain setting."**
- **Theorem 1 (as summarized in the paper and in other sources)**: argument stability bound $O(T\eta/n)$ — **matches HRS rate exactly**, and explicitly **without any assumption on the Markov chain** (no mixing-time factor).
- Uses **on-average argument stability**, NOT uniform stability.
- Covers smooth AND non-smooth loss.
- For minimax (SGDA) problems, develops connection between on-average argument stability and generalization error "which extends existing results for uniform stability."

### Crucial methodological quote (reconstructed from secondary sources)

The authors explicitly state they chose on-average argument stability *because uniform stability is hard in the Markov setting*: 

> "With uniform stability, one needs to consider neighboring datasets differing by the $i$-th element, which depends on the transition matrix $P$ and is not easy to control."

So they **deliberately avoided exactly the technical difficulty R1 was meant to address**, by switching to a weaker stability notion that sidesteps the chain-propagation issue.

---

## Evaluation against R1's coverage checklist

| Criterion | 2209.08005 (Lei et al.) | Covers R1? |
|---|---|---|
| (a) Analyzes SGD specifically (not ERM/SVM/kernel) | YES — explicit SGD iterate analysis | ✓ |
| (b) Uses uniform stability (not on-average / hypothesis / loss stability) | **NO — uses on-average argument stability** | ✗ |
| (c) Handles Markov chain dependence (not i.i.d. + noise) | YES — explicit Markov sampling | ✓ |
| (d) Bound depends on mixing time $\tau_{\text{mix}}$ | **NO — bound is $O(T\eta/n)$ without mixing factor** | ✗ |
| (e) Degenerates to HRS when i.i.d. | YES — same $O(T\eta/n)$ rate | ✓ |

**Summary**: 3/5 criteria met. Not a full subsumer, but a **major obstacle**: the paper has staked the "first SGD-Markov stability" claim and proven a result that's **in one sense stronger than R1's tentative bound** (no mixing factor!) and **in another sense weaker** (on-average vs uniform).

---

## Adjacent / companion work found

**arXiv:[2302.14428](https://arxiv.org/abs/2302.14428)** — Even 2023 (ICML), "SGD under Markov-Chain Sampling Schemes."
- **Convergence** analysis (not stability/generalization). Removes bounded-iterate assumptions; decentralized-setting focus.
- Does NOT overlap with R1's stability claim.

**NeurIPS 2023 "First Order Methods with Markovian Noise"** (Sadiev et al., arXiv:[2305.15938](https://arxiv.org/abs/2305.15938)).
- Convergence (not stability) with Markov noise; includes acceleration. Oracle complexity linear in $\tau_{\text{mix}}$.
- Does NOT overlap with R1.

**arXiv:[2306.02939](https://arxiv.org/abs/2306.02939)** — "Improved Stability and Generalization of D-SGD" (2023).
- Decentralized SGD with i.i.d. sampling; graph-topology effects. Not Markov.

**JMLR [Mohri & Rostamizadeh 2010](https://www.jmlr.org/papers/v11/mohri10a.html)** — "Stability Bounds for $\varphi$-mixing / $\beta$-mixing."
- ERM/SVM under $\beta$-mixing. Not SGD iterates. Partial predecessor for the Bousquet-Elisseeff bridge, NOT for the SGD analysis.

**[Yunwen Lei 2022+](https://leiyw.github.io/)** corpus — author of 2209.08005; has a strong track record in SGD stability (Lei-Ying 2020 fine-grained, Lei 2023 non-smooth non-convex, etc.). Active researcher; any follow-up to 2209.08005 in uniform-stability direction would be by this group.

---

## The specific "gap" R1 might fill

After Lei et al. 2022, the residual uncovered territory is:

**Uncovered Question**: *Prove a* **uniform stability** *bound for SGD under Markov-chain samples with an explicit mixing-time dependence.*

### Is this gap real?

YES — Lei et al. explicitly avoided uniform stability because of the chain-propagation difficulty. The question is technically open.

### Is this gap worth filling?

**Three reasons to be skeptical**:

1. **Possible impossibility or triviality**: if Lei et al.'s on-average bound is $O(T\eta/n)$ (no $\tau_{\text{mix}}$), the analogous uniform bound either (a) also avoids $\tau_{\text{mix}}$ by a similar trick, making R1 a minor improvement, or (b) genuinely requires $\tau_{\text{mix}}$ because uniform stability propagates worst-case. Without doing the proof, I can't tell which — but either outcome is a **quantitatively small** result, not a qualitatively new one.

2. **Community positioning**: the canonical reference for "SGD-Markov stability" will be Lei et al. 2022. Any R1 paper reads as "uniform-stability version of Lei et al." — an *incremental follow-up*, not a foundational result. Reviewers will ask "but we already have the on-average version; why do we need uniform?" The answer — "uniform stability gives high-probability generalization bounds (Feldman-Vondrak 2019 style)" — is narrow.

3. **Precedent pattern**: this is the third literature check to reveal a direct precedent I hadn't surfaced:
   - C3.4: Kozachkov 2022 subsumes
   - C1.4: Kipnis-Varadhan (1986!) lower-bounds
   - R1: Lei et al. 2022 largely covers
   
   The cumulative evidence is that we are operating in well-trodden terrain where our shallow initial scans miss key references. Investing proof-effort in a "narrow gap" behind a recent foundational paper has a bad expected value.

### Is there a sharper sub-question?

Possibly: **High-probability uniform stability of SGD on Markov data with non-convex smooth loss**, applicable to deep-learning-on-time-series. Lei et al. 2022 does smooth ERM convex; non-convex extension would need different technical tools (Bassily-Feldman-Guzman-Talwar 2020 style, + mixing). This is a genuine gap but is a specialized result.

---

## Verdict

### 🔴 **PARTIALLY_COVERED → leaning RED**

**Reasoning**:
- Lei et al. 2022 (NeurIPS) proved SGD-Markov stability with a bound *not worse than* what R1 would achieve.
- The residual gap (uniform vs on-average) exists but is (a) technically narrow, (b) may not yield a meaningfully different bound, (c) positions R1 as incremental-follow-up rather than foundational contribution.
- Pattern matching with C3.4 and C1.4: the analogy/generalization route has now surfaced direct precedents in three consecutive candidates. The shallow-literature-scan → proof-work pipeline has a **0/3 hit rate** so far.

### Recommendation: **pivot to R3 (STORM with biased oracle)**

**Why R3 is the better bet**:
1. STORM's polarization-identity Lyapunov structure is specific and not shared by standard analyses; a biased-oracle modification is a clean Lyapunov perturbation exercise.
2. Ajalloeian-Stich 2020 covers biased SGD but not biased STORM specifically; the variance-reduction machinery has to be redone.
3. Applications (compressed-gradient FL, DP-SGD with clipping, sign-SGD) have clear practitioner demand.
4. Feasibility is HIGH (mechanical Lyapunov modification) rather than research-level-coupling-heavy.

### If pivot is declined: minimal R1 variant

If the user insists on pursuing R1 despite this finding, the only defensible target is:

> **R1-minimal**: Prove a *high-probability* uniform stability bound for SGD on Markov samples in the *non-convex smooth* setting, with explicit $\tau_{\text{mix}}$ dependence, aimed at deep-learning-on-time-series application.

**Feasibility**: Class A, specialized. Would require combining Lei et al. 2022 + Bassily-Feldman-Guzman-Talwar 2020 (non-convex uniform stability) + Yu 1994 blocking. **Still incremental** relative to Lei et al., but narrower target makes the positioning defensible.

---

## Final recommendation: **DROP R1, PROCEED TO R3 FEASIBILITY ANALYSIS**

### Summary of the 4 candidates' fates

| # | Candidate | Fate | Cause of death |
|---|---|---|---|
| 1 | C3.4 (OR ⇒ stability) | RED | Kozachkov 2022 subsumes |
| 2 | C1.4 (STORM ⇒ MCMC ergodic) | RED | Kipnis-Varadhan CLT lower bound |
| 3 | C3.3 (potential-game generalization) | Soft-RED | IFT + HRS = two-line textbook corollary |
| 4 | R1 (HRS → Markov SGD) | Partial-RED | Lei et al. 2022 first-ever already on record; residual gap (uniform vs on-average) is narrow |

### Next action

Run feasibility analysis for **R3 (STORM → biased oracle)** following the same structure as r1_feasibility_analysis.md:
- Q1: precise statement
- Q2: which step of STORM proof depends on zero bias
- Q3: literature clearing upfront this time — specifically check Ajalloeian-Stich 2020, any STORM/SPIDER/SARAH biased-oracle follow-ups, any DP-STORM or compressed-STORM papers
- Q4: technical path for Lyapunov modification
- Q5: applications (compressed FL, DP-SGD)

Given the 0/3 track record on pre-proof checks, **combine feasibility + literature clearing into one pass for R3**, rather than doing feasibility first and literature check second.

---

## Sources

- [arXiv:2209.08005](https://arxiv.org/abs/2209.08005) — Lei et al. 2022 (NeurIPS) — **Primary subsumer for R1's core direction.** First SGD-Markov stability paper, on-average argument stability.
- [OpenReview page](https://openreview.net/forum?id=P7TayMSBhnV) for the NeurIPS 2022 review record.
- [NeurIPS 2022 supplementary PDF](https://proceedings.neurips.cc/paper_files/paper/2022/file/f61538f83b0f19f9306d9d801c15f41c-Supplemental-Conference.pdf) (binary, not fully parsed, but exists).
- [arXiv:2302.14428](https://arxiv.org/abs/2302.14428) — Even 2023 (ICML). SGD-Markov convergence (not stability).
- [arXiv:2305.15938](https://arxiv.org/abs/2305.15938) — Sadiev et al. 2023 (NeurIPS). First-order with Markovian noise (convergence, acceleration).
- [arXiv:2306.02939](https://arxiv.org/abs/2306.02939) — Improved D-SGD stability (i.i.d. decentralized, not Markov).
- [JMLR 11 (2010) 789-814](https://www.jmlr.org/papers/v11/mohri10a.html) — Mohri & Rostamizadeh. $\beta$-mixing stability for ERM/SVM.
- [Yunwen Lei homepage](https://leiyw.github.io/) — active researcher; primary author of SGD-stability literature 2020-2024.
- [arXiv:1509.01240](https://arxiv.org/abs/1509.01240) — HRS 2016 baseline.
- [arXiv:1703.01678](https://arxiv.org/abs/1703.01678) — Kuzborskij-Lampert 2018, data-dependent SGD stability (i.i.d.).
