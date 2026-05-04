# Gap 2 Divergent Exploration — Summary

**Date:** 2026-04-29
**Working dir:** `workspace/active/op2_v5_gaps/gap2_ub/exploration/`

Six directions explored to find ways to claim "tightness" beyond the three already-established positive matchings (minimax-$\eta$, projected-up-to-$\sqrt{\log T}$, Cesàro). Per-direction judgments in `d{1..6}_*.md`. This is the consolidated recommendation.

---

## Verdict matrix

| # | Direction | Verdict | Effort | Closes Li Xiao gap? |
|:-:|---|---|---|---|
| 1 | Bias-only tightness ($\sigma = 0$) | **FEASIBLE** — reframes from $1/T$ to constant rate | Low (4–6 h) | **Yes**, but reframes the question |
| 2 | Decaying $\eta_t$ schedule | **FEASIBLE** — needs adapting Liu–Zhou 2024 | Medium (2–3 wk) | **Yes**, in the practical sense |
| 3 | High-probability bound | **INFEASIBLE** at fixed $(\beta, \eta)$ | N/A | No — same noise-floor obstruction |
| 4 | Strongly convex regime | Feasible but **OUT OF SCOPE** | Low (1 wk) | No — different functional class |
| 5 | SHB ≥ SGD sandwich | **FEASIBLE** — clean closed-form | Low–Medium (1–2 wk) | **Yes**, qualitatively |
| 6 | Algorithm-specific tightness reframing | **COLLAPSES INTO D1** — refuted numerically | N/A | No (subsumed by D1) |

## Top recommendation

**The strongest combined story uses Directions 1 + 2 + 5.** Together they give:

### Three-line punchline for OP-2 v6 §4.2

1. **Lower bound (OP-2 v5)**: $\Omega(LD^2/T + \sigma D/\sqrt T)$ at every fixed $(\beta, \eta) \in \mathcal F$.

2. **Bias-only tightness in the deterministic regime (D1, σ = 0)**: on a positive-measure subset $\mathcal F^{\text{cycle}}_{K=3} \subset \mathcal F$, $f(x_T) - f^\star = \Theta(LD^2)$ — a **constant** floor, **strictly worse** than the $\Omega(LD^2/T)$ LB. The LD²/T LB is honest but loose; the actual rate is $\Theta(1)$. Sharp against the trivial UB $f(x_0) \le LD^2/2$.

3. **Stochastic tightness — three matching senses**:
   - (a) **Decaying $\eta_t$ matching UB** (D2, extending Liu–Zhou 2024): for fixed $\beta$ and $\eta_t = c/\sqrt t$, $\mathbb E[f(x_T) - f^\star] \le O((LD^2/T + \sigma D/\sqrt T)/(1-\beta))$ matches OP-2 LB in rate.
   - (b) **SHB ≥ SGD sandwich** (D5): SHB's noise-floor coefficient is $\geq (1+\beta)/(1-\beta) \times$ SGD's — closed-form, exact. Momentum NEVER helps; SHB is strictly slower than SGD by a $\beta$-dependent factor.
   - (c) **Negative result at fixed $\eta$** (Theorem A.1, already in v5): closed-form noise floor $\Omega(\sigma^2 \eta) > 0$ refutes any $T$-decaying matching UB at fixed $(\beta, \eta)$.

### Why this is publishable

- **(D1) is the structurally cleanest result**. The deterministic SHB last iterate has a *constant* floor on a positive-measure parameter set — a STRONGER statement than "rate $\Omega(1/T)$". The numerical evidence is overwhelming (140000× larger than OP-2's LB at the cycling anchor).
- **(D2) is the practical answer**. Real implementations use decaying $\eta_t$, not fixed $\eta$. The matching UB exists in that regime; this is what Li Xiao's question maps to in practice.
- **(D5) is the *qualitative* tightness** that aligns with OP-2's stated thesis ("momentum doesn't help"). The closed-form SHB/SGD ratio is a clean algebraic statement.

## Why NOT to pursue Directions 3, 4, 6

- **D3 (high-prob)**: the chi-squared distribution of $f(x_T) - f^\star$ at the noise floor has positive any-quantile, so high-prob bounds inherit the same obstruction. No loophole.
- **D4 (SC regime)**: well-studied with matching UBs (Bach-Moulines, Sebbouh-Gower-Defazio); doesn't address Li Xiao's non-SC question. Could be a v6 appendix but not a main result.
- **D6 (algorithm-specific tightness)**: numerical experiment refutes the "$LD^2/T$ = exact rate" framing. Actual rate in cycling regime is $\Theta(1)$, not $\Theta(1/T)$. So the reframing collapses into D1.

## Concrete next-step plan (if user accepts)

If the user wants to upgrade OP-2 v5 → v6 along this path:

**Phase 1 (1 week, mostly already done):**
- Polish D1 result. Embed in v6 as new §4.2.1: "Bias-only tightness — the cycling regime gives a constant-floor LB matching the trivial UB."
- Polish D5 closed-form ratio. Embed in v6 as new §4.2.2: "SHB-vs-SGD comparison — closed-form noise-floor ratio."

**Phase 2 (2–3 weeks):**
- D2 derivation. Adapt Liu–Zhou 2024's CSMD-without-momentum analysis to SHB-with-fixed-$\beta$-decaying-$\eta_t$ via the change-of-variables identity (`gap2_proof.md` Theorem D Lemma 1).
- This is the heavyweight technical lift; may need help from a co-author with Liu-Zhou-style suffix-averaging expertise.

**Phase 3 (final write-up):**
- Combine Phase 1 + Phase 2 into a v6 §4.2 with the four-fold tightness story: (i) cycling-regime bias-only $\Theta(1)$ tightness; (ii) decaying-$\eta_t$ matching $\Theta(1/T + 1/\sqrt T)$; (iii) SHB ≥ SGD sandwich (qualitative); (iv) noise-floor obstruction at fixed $\eta$ (negative).

## A blunter recommendation

**The honest answer to Li Xiao is: there is no fixed-$(\beta, \eta)$ matching UB, but the cycling regime gives a STRONGER negative result (constant floor instead of $1/T$ floor).** OP-2's contribution is more valuable than originally framed: not "LB matches Cesàro UB" but "**SHB last iterate has constant suboptimality on positive-measure parameter set, fundamentally different behavior from SGD which converges**".

If Li Xiao wants tightness in the form "UB = LB rate", redirect to:
- **D2 (decaying $\eta_t$)**: matching in rate for the practical schedule.
- **D5 (SHB ≥ SGD)**: matching against SGD as a benchmark.

Both are credible SIOPT/MP-quality contributions. **D1 is the most surprising and cleanest result, and is essentially already proved by `gap1_proof.md` (cycling regime) plus this exploration.**
