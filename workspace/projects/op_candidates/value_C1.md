# Value Assessment: C1 — Multi-Agent Reasoning Capability Lower Bound

**Date**: 2026-04-28

---

## Impact score: 7/10 (if completed rigorously) | 3/10 (if rushed)

**Why 7/10 potential**: Multi-agent LLM systems are one of the most actively deployed architectures in 2025–2026 (AutoGen, CrewAI, LangGraph are production-scale). A rigorous information-theoretic lower bound on their capabilities would be cited widely across ML systems, theoretical ML, and AI safety communities. The question "how many agents, how many rounds, what probability of success?" is genuinely asked by practitioners. A clean answer to this question in even a restricted formal model would be a landmark result.

**Why the realized impact might be only 3/10**: The model restrictions required for rigorous proofs (hard-attention transformers, fixed precision, restricted task classes) are widely perceived in the ML community as toy models. The disconnect between "theorem in the hard-attention model" and "fact about GPT-4o + Claude in a multi-agent loop" is large. If reviewers and readers perceive the result as not applying to real systems, the citation impact is substantially lower. History: Sanford-Hsu-Telgarsky (NeurIPS 2023) is well-cited precisely because it proved results that *matched* known empirical puzzles. C1 would need the same matching.

---

## Portfolio increment score: 8/10

This is the strongest dimension. The user's current portfolio (OP-2 and neighbors) is concentrated in:
- Convex/non-convex optimization oracle complexity
- Stochastic gradient lower bounds
- Cycling constructions for momentum methods

C1 would add:
- AI4Math / theorem proving theory
- Multi-agent systems theory
- Communication complexity / circuit complexity methods

This is genuine breadth. For a PhD student or junior faculty positioning for a broad theory-of-AI-systems profile, C1 as a working direction (even a 1–2 year project, not 6-week sprint) would be highly differentiating. No member of the BICMR endorser pool is currently publishing in this exact intersection.

---

## Endorser match

**董彬 (BICMR AI4Math lead): Strong match, 8/10**

董彬's group works on automated theorem proving, proof search, and AI4Math infrastructure. C1 is asking a theoretical question about *what automated proof systems can and cannot do*. The connection is direct: "what are the information-theoretic limits of multi-agent proof search?" is exactly the theoretical complement to his empirical/system work. He would likely find the question natural and the pipeline's failure data genuinely interesting as empirical evidence.

Caveat: 董彬's technical strength is likely more in optimization and numerical methods than in communication complexity. He may appreciate the question but not be positioned to give deep technical feedback on the proofs. This is fine for mentorship/endorsement but means the user would need to develop the CC techniques somewhat independently.

**袁洋 (Tsinghua AI theory): Good match, 6/10**

袁洋's focus is on learning theory and optimization theory — closer to the user's current strength. The PAC-Bayes angle of C1 (bounding success probability of agents via their hypothesis class complexity) is more natural for 袁洋 than the CC angle. However, C1 in its current formulation is further from his core interests (generalization bounds for neural networks, statistical learning theory) than a project in the OP-2 family would be.

**陈小杨 (AI4Math): Good match, 7/10**

陈小杨 works on AI-assisted mathematics more broadly. A paper that formalizes limits of AI theorem-proving would be directly in scope.

**李肖, 文再文, 李晨毅 (BICMR optimization/applied math): Weak match, 3/10**

These endorsers are optimization-focused. C1's connection to their work is tenuous. They are better fits for OP-2 and neighboring directions.

---

## Unique asset valuation

The pipeline's failure_patterns.md database is the user's strongest differentiator for this direction. No other researcher (to our knowledge) has a structured, schema'd database of 20+ AI proof-agent failure modes with documented root causes. This data:

1. **Empirically motivates the theoretical question** — the failure modes are not random; they exhibit systematic patterns (Polyak acceleration obstruction, quantifier order errors, circular dependency, common misconception convergence). This suggests there is a *mathematical structure* to the hard task class.

2. **Could anchor a paper that is part empirical, part theoretical** — a "hard task class characterization" paper that (a) defines F_hard operationally via the pipeline's failure rate, (b) proves a theoretical lower bound for the CC model on a proxy for F_hard, and (c) shows empirically that F_hard aligns with theoretically hard task classes.

3. **Is a unique dataset** — this is not something that could be reproduced without running the pipeline for months. It gives the user a 6–12 month head start over competitors who would try to build similar data.

---

## Honest 6-week feasibility assessment

**Verdict: NOT a 6-week full paper. Could be a 6-week workshop paper if scope is aggressively narrowed.**

**Realistic 6-week scope (workshop quality)**:
- Week 1: Nail down the task model. Adopt k-hop reasoning from arXiv 2510.13903 as the task class. This eliminates D1 and D3.
- Week 2: Adopt hard-attention transformer from Merrill-Sabharwal as agent capability model. This eliminates D2.
- Week 3: Prove one probabilistic extension: "In the hard-attention model, k agents running t(n) CoT steps with R communication rounds succeed on k'-hop reasoning only if k × t(n) × R ≥ Ω(k')." This is an extension of arXiv 2510.13903 from exact to probabilistic. May be a 3-page proof.
- Week 4: Connect to failure data. Show empirically that the pipeline's failure rate on k-hop proxies matches the theoretical bound.
- Week 5-6: Write up as a 8-page workshop paper for ML4Math, AI4Math workshop at NeurIPS/ICML 2026.

**Why even this is risky**: The proof in Week 3 may not go through in 1 week. Communication complexity lower bounds for probabilistic protocols (randomized CC) require applying Yao's minimax lemma or discrepancy method. For k-hop reasoning with transformer agents, this may require a non-trivial new argument (why does probabilistic coordination fail?) that could take 3-4 weeks on its own.

**Multi-year program assessment**: C1 is actually a multi-year research direction. The full program would be:
- Year 1: Nail the formal model, prove tight bounds for k-hop reasoning, publish at COLT/NeurIPS
- Year 2: Extend to mathematical proof tasks, validate with Lean, connect to practice
- Year 3+: Build the theory of "formal proof complexity for AI agents" as a new subfield

As a *direction* (not a 6-week project), C1 has real long-term value. As OP-3 (the next single project after OP-2), it is likely too ambitious unless the user is prepared to deliver only a workshop paper.

---

## Recommendation

Do not pursue C1 as "the next project with a 6-week deliverable." Consider instead:

**Option A (recommended)**: Keep C1 as a parallel slow-burn direction. Spend 2–3 hours/week formalizing the definitions and collecting more failure data. After OP-2 is submitted (presumably in 4–6 weeks), revisit with the definitional clarity that time provides.

**Option B**: Pursue a *closely adjacent direction* that has the same portfolio-broadening benefit but is more tractable in 6 weeks: "PAC-Bayes generalization bound for multi-round proof-search chains" — which stays within the user's existing PAC-Bayes toolkit and yields a clean theorem about the generalization cost of multi-step search. This is weaker in novelty but more likely to produce a COLT-quality result in 6 weeks.

**Option C**: Write a 6-week *survey/position paper* that formalizes the question, surveys the 10 papers in literature_C1.md, proposes the four model choices as open problems, and contributes the pipeline's failure data as empirical evidence. Submittable to AI4Math workshop (NeurIPS 2026 deadline is typically July). Incremental but publishable.
