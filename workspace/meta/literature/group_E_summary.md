# Group E Summary — Stability + Multi-Agent (10 proofs)

**Date**: 2026-04-27
**Owner**: Agent 5 (this run)

## Verdict tally

| Code | Theorem | Verdict | Notes |
|---|---|---|---|
| E1 | SGD uniform stability (HRS 2016) | CONFIRMED | Classical, textbook reproduction |
| E2 | DP implies generalization | CONFIRMED | Classical hockey-stick + Bousquet-Elisseeff |
| E3 | SGD signal-noise decomposition (Teng-Ma-Yuan 2022) | CONFIRMED with PARTIAL | Faithful to Teng-Ma-Yuan; Claim 2 strict tightness honestly declined |
| E4 | Adversarial trajectory tradeoff (PARTIAL) | NOVEL SYNTHESIS | Madry is empirical; we build a clean trajectory tradeoff |
| E5 | Heavy-tailed trajectory decomposition | CONFIRMED RATE / **ERROR in citation** | arXiv 2102.04259 is wrong paper (Even-Massoulié, not Wang-Mao) |
| E6 | Multi-agent verification error propagation | NOVEL FRAMING | CR paper has no formal probability bounds |
| E7 | Categorical foundation | NOVEL THEORETICAL LIFT | Lawvere/Kelly machinery; modest math depth |
| E8 | Compositional CR reuse | NOVEL FRAMING | Elementary; corrected (1-delta)^{N(d,Delta)} bound |
| E9 | CR depth lower bound (PARTIAL) | NOVEL APPLICATION | Yao + Bayes-error; (c) catches arithmetic error in source |
| E10 | CR non-stationary verifier (corrected) | NOVEL FRAMING | Calculus + novel parameterization |

**Confirmed (matches established lit):** E1, E2, E3, E5(rate)
**Novel formulation/synthesis:** E4, E6, E7, E8, E9, E10
**Errors flagged:** E5 (citation: arXiv 2102.04259 is misattributed)

## Discrepancies

1. **E5 citation error** (cosmetic, not mathematical): arXiv 2102.04259 is "Concentration of
   Non-Isotropic Random Tensors" by Even-Massoulié, NOT Wang-Mao on heavy-tailed SGD. The
   correct attribution is to the clipped-SGD heavy-tail line (Gorbunov 2020 / Zhang 2020 /
   Wang-Mao at a different arXiv ID). The proof's final RATE G T^{1-1/p}/sqrt(m) is correct
   and matches the established minimax rate, but the derivation contains heuristic
   normalization steps in Stage C.

2. **E3 attribution**: index says "Zhang, Yifan et al. 2022" but actual authors are
   Teng-Ma-Yuan. arXiv ID is correct. Cosmetic.

3. **E9 part (c)**: numerical claim "approx 18" in source statement is wrong (correct: 3.9).
   Proof correctly catches and reports this.

4. **E8 Delta^d**: stated bound (1-delta)^{Delta^d} is too loose; proof correctly tightens to
   (1-delta)^{N(d,Delta)}.

5. **E10 threshold**: source typo T_0^{alpha/(alpha-1)} corrected to T_0^{alpha/(alpha+1)}.

## Multi-Agent (E6-E10): coherent novel theory or scattered observations?

**Assessment: COHERENT NOVEL FRAMING with moderate mathematical depth.**

The five multi-agent proofs (E6-E10) form a unified attempt to mathematize the empirical
Cumulative Reasoning framework (CR, arXiv 2308.04371). They share a common theme:
**"verification reliability of multi-agent reasoning chains, parameterized by per-step
error rate epsilon and depth/length T or d, with auditor-fixer retry as variance reduction."**

**Coherence evidence:**
- E6 (basic (1-eps)^T and (1-eps^k)^T bounds) is the ground level.
- E7 (categorical lift) provides a structural home: verifier errors as natural
  transformations between functors C -> Δ(D), auditor-fixer as Banach contraction.
  E7's part (c) explicitly REDUCES TO E6.
- E8 (compositional reuse) extends E6 to DAG dependency structures, motivating library-first
  design.
- E9 (depth lower bound) gives the matching information-theoretic LB to E6's UB.
- E10 (non-stationary verifier) generalizes E6 to time-varying epsilon_t.

This is genuinely a small theory: ground-level Bernoulli-product reliability bounds, a
categorical lift for structural unification, an UB/LB matched pair (E6 vs E9), and two
generalizations (E8 to DAGs, E10 to non-stationary).

**Limitations:**
- Mathematical depth is modest. Each result is undergraduate-graduate-level technique
  (probability, calculus, basic enriched category theory, Yao's principle). None is a
  publishable standalone theorem in a top-tier venue.
- The CR paper they build on is empirical, so there is no prior art to refute or improve.
  The novelty is "formal modeling" rather than "mathematical breakthrough".
- Independence assumptions (verifier judgments i.i.d., lemma errors independent) are
  strong and may not hold in practice for LLM-based verifiers.

**Conclusion:** E6-E10 constitute a **coherent first-pass theory** of multi-agent verification
reliability — appropriate for a "foundations" chapter in a research monograph or as a
unifying framework for empirical CR-style work. They are NOT scattered observations: the
unifying thread (Bernoulli-product reliability, retry amplification, categorical home) is
clear. Whether this small theory leads to deeper results (e.g., tight UB/LB, non-i.i.d.
verifier models, formal connections to PAC-Bayes for LLM agents) is an open research direction.

## Time spent
~50 min (within budget). Per-proof reads + 6 WebFetches (3 informative, 3 abstract-only) +
write-up.
