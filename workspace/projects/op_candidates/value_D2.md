# Value Assessment: D2 — Symbolic Regression Sample Complexity Lower Bound

**Date**: 2026-04-28

---

## Impact score: 7.5 / 10

**Justification**:

SR is one of the most active AI4Science directions in 2024–2026. The ACM Computing Surveys 2025 SR survey explicitly identifies statistical learning theory as an open gap. NeurIPS, ICLR, and ICML all have active SR workshops. A minimax sample complexity lower bound for SR would be:

- The first formal LB for this class of problems
- Immediately relevant to practitioners (explains the empirically observed data-hungry behavior of SR methods)
- Connective tissue between two communities (ML theory and equation discovery) that have not yet communicated formally

Deductions from 10:
- (-1.0) Result will likely be restricted to a specific class S — not universal enough for a "grand theorem" designation
- (-0.5) Matching upper bound may be left open, weakening the paper
- (-1.0) Venue fit: COLT and ALT are natural venues but have smaller impact than NeurIPS/ICML for applied communities; bridging requires more framing work

**Closest comparable published work**: oracle complexity lower bounds for sparse recovery (Candes-Tao LASSO). D2 is to SR what LASSO lower bounds were to compressed sensing — it says "here is the fundamental limit." That work was high impact.

---

## Portfolio increment score: 8.5 / 10

**Justification**:

OP-2 was: stochastic optimization, momentum, last-iterate convergence, oracle complexity. The technique was Le Cam / information-theoretic oracle LB.

D2 is: symbolic regression, PAC learnability, Fano LB applied to combinatorial expression classes. The overlap is:
- Same high-level tool family (information-theoretic LB)
- **Different domain** (equation discovery vs. convex optimization)
- **Different combinatorial content** (expression tree enumeration is new to the pipeline)
- **Different community** (AI4Science vs. optimization theory)

Portfolio effect: D2 adds an entirely new sub-field to the proof library (learning-theory/symbolic-regression — currently absent), and creates a natural connection between the existing learning-theory/generalization/ proofs and a hot applied domain.

Score 8.5 because:
- (+2.0 vs. baseline) Genuinely new branch
- (+1.5) AI4Math relevance opens new endorser relationships
- (-1.0) Partial reuse of Fano means less proof-method novelty than if a completely new technique were required

---

## Endorser assessment

### 陈小杨 (AI4Math discovery) — PRIMARY — STRONG MATCH

陈小杨's research sits at the intersection of AI for mathematical discovery and ML theory. SR sample complexity is a direct, named application of AI4Math: the question "how much data does an equation discovery system need?" is precisely the theoretical foundation of her area.

**Match strength**: 9/10

Specific pitch angle: "We provide the first formal answer to the fundamental question of SR: what is the minimax sample complexity to recover a symbolic formula? The result explains why AI Feynman and PySR need 10^3–10^4 data points to recover depth-4 equations."

**Expected endorser response**: Strong positive. This directly supports the theoretical foundations of AI4Math work. The result is citable from applied SR papers.

**One risk**: if 陈小杨 has ongoing work on SR theory, this could be competitive rather than complementary. Recommend a pre-submission conversation to identify any direct overlap.

### 袁洋 (AI theory) — SECONDARY — GOOD MATCH

袁洋 works on AI theory broadly. Sample complexity lower bounds are core to AI theory. SR is a concrete application of learning theory machinery.

**Match strength**: 7/10

Pitch angle: "Extension of PAC learning theory to the symbolic regression setting, proving tight minimax rates in terms of expression tree parameters."

**Expected endorser response**: Positive, but more moderate — SR may be too applied for 袁洋's primary interest in theoretical properties of learning algorithms. The connection is clean but not as direct as for 陈小杨.

### 李肖, 文再文, 李晨毅, 董彬 — WEAK MATCH for D2

These endorsers are primarily in optimization (李肖, 文再文, 李晨毅) and computational imaging/math (董彬). D2 does not touch optimization theory or imaging. These endorsers are better matched to OP-2 (stochastic optimization). Not recommended as primary endorsers for D2.

---

## Recommended class S to maximize tractability + interest

**Recommendation**: S = S(d=4, s=20, Σ_Feynman)

where Σ_Feynman = {+, ×, ÷, sqrt, sin, cos, exp, log} and constants are drawn from a compact set.

**Rationale**:

1. **Tractability**: d=4, s=20 gives |S| ≥ exp(40) formally but the packing argument only needs M = exp(Ω(s)) = exp(Ω(20)) = ~10^8 well-separated functions. The packing construction is manageable.

2. **Interest**: The Feynman benchmark (Udrescu-Tegmark 2020) uses exactly this class. The 100 Feynman equations all lie in this class. This makes the result immediately interpretable: "you need at least Ω(20 × log 8) = Ω(60) samples just to identify the operator structure" — and with real-valued constants, much more.

3. **Avoid over-restriction**: Using Σ = {+, ×} only (polynomial-like) would make S too similar to existing sparse polynomial results and reduce novelty. Using Σ that includes transcendental functions (sin, exp) introduces the genuinely novel component.

4. **Avoid over-complexity**: Σ including all elementary functions (tan, cosh, special functions) would make the separation lemma much harder and the result less clean.

**Alternative (more radical, higher impact if it works)**: Study the threshold behavior in |Σ|. Show there is a phase transition in sample complexity as |Σ| crosses a threshold — analogous to phase transitions in compressed sensing. This would be a genuinely striking result but requires more analysis time.

---

## Overall recommendation

D2 is a strong candidate for the next project. It is:
- **Open** (literature survey confirms no existing LB)
- **Tractable** (6-week timeline achievable for minimum viable result)
- **Impactful** (first formal result for an important AI4Science problem)
- **Endorser-aligned** (direct match to 陈小杨, good match to 袁洋)
- **Portfolio-expanding** (adds new branch to proof library)

The main judgment call: D2 requires positioning work (choosing S well, framing for two audiences). It is a better "outward-facing" paper than OP-2 and would diversify the portfolio. If the goal is community visibility in AI4Math, D2 dominates. If the goal is pure optimization theory depth, a different direction is better.

**Suggested scope for submission**: COLT 2027 or NeurIPS 2026 theory track. Timeline: core proof in 6 weeks, write-up + experiments in 4 additional weeks.
