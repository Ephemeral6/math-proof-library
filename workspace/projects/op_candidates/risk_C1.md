# Risk Assessment: C1 — Multi-Agent Reasoning Capability Lower Bound

**Date**: 2026-04-28

---

## Summary verdict: HIGH RISK

This direction fails the "6-week crisp theorem" test on definitional grounds alone. The risks below are ordered from most fundamental to most tactical.

---

## Risk 1 (Definitional): The problem is not yet theorem-shaped

**Description**: Before any technical work begins, four definition problems must be solved (see technical_C1.md §2: D1–D4). Each one has genuine optionality — there are multiple reasonable choices, and the choice of model determines whether a result is:
- (a) interesting and new
- (b) a restatement of known CC results in new notation
- (c) technically true but empirically irrelevant to actual LLM systems

**Concrete example of the risk**: Suppose the user defines "agent capability" as "hard-attention transformer with depth d." Then the main theorem becomes a corollary of Merrill-Sabharwal: "k agents each with O(1) depth can solve at most AC⁰ tasks regardless of communication rounds." This is formally correct but not new.

Suppose instead the user defines "agent capability" via VC dimension. Then the theorem becomes a PAC-Bayes bound that says "multi-agent generalization error is bounded by VC/n" — which is not a lower bound on success rate for any *fixed* proof task, just an average-case learnability statement.

Neither formulation delivers the intended result: "there exist inherently hard tasks for which agents × rounds × success_probability is bounded."

**Mitigation**: Restrict immediately to the k-hop reasoning task class from arXiv 2510.13903 (already formalized) and extend their exact-solving results to probabilistic statements. This collapses the definitional problem — but also narrows the contribution to "an extension of one specific 2025 preprint."

**Risk level**: CRITICAL. Cannot be circumvented, only managed.

---

## Risk 2 (Technical): Bounds may be unfalsifiable or vacuously true

**Description**: The proposed bound "agents × rounds × success_probability ≤ f(communication_complexity(task))" has two failure modes:

**Mode A — Vacuous**: Communication complexity lower bounds work by showing any protocol must send Ω(C) bits. For LLM agents with long contexts and multi-turn dialogue, the "bits communicated" in practice is enormous (each agent outputs thousands of tokens per turn). The bound fires only when communication is *constrained*. Without an explicit constraint (B bits per message), the theorem says: "if agents can send unlimited messages, they can solve the task" — which is true but trivially so.

**Mode B — Untestable model**: If the agent model is "hard-attention transformer with fixed precision," the bound is formally rigorous but empirically disconnected from GPT-4/Claude-class agents, which are substantially more expressive. Critics can dismiss the result as "true for a toy model but irrelevant to real systems." This is the same problem faced by circuit complexity results in classical TCS — they are technically correct but have been partially ignored in practice because the models don't match real hardware.

**Mitigation**: Explicitly declare the model as a "computational model lower bound, not an empirical bound" and frame results as "necessary conditions" rather than "empirical predictions." This is honest but substantially reduces the paper's impact for ML-audience venues.

**Risk level**: HIGH.

---

## Risk 3 (Audience): Wrong venue for this user's career stage

**Description**: There are two natural venues for C1:

**CS theory venues** (STOC, FOCS, CCC): Would require the full rigor of a communication complexity or circuit complexity paper. Reviewers will ask: does the hard-attention transformer model apply? Is the task class natural? Are the bounds tight (matching upper and lower)? These are very high bars. The user's background (optimization, oracle complexity) is adjacent but not directly in this community's main techniques (algebraic lower bounds, polynomial method, multilinear extensions). 6-week timeline is completely unrealistic for this target.

**ML theory venues** (COLT, NeurIPS, ICML): More accepting of models that are partially empirically motivated. But the results would need to be: (a) novel beyond the 2510.13903 preprint, which appeared only 6 months ago, and (b) connected to actual LLM practice, which is hard given the model restrictions needed for rigorous lower bounds.

**AI/NLP venues** (ACL, EMNLP): The empirical finding (failure_patterns.md) could be written as a position/analysis paper, but this would not be a "proof" in any rigorous sense and would not leverage the user's comparative advantage.

**Endorser mismatch**: 董彬's AI4Math work at BICMR focuses on formalization and automated theorem proving (Lean, formal verification). He would appreciate C1's connection to proof-search limits, but would likely want the results formalized — which connects back to the Lean formalization problem. 袁洋 (Tsinghua AI theory) is closer to optimization/learning theory and might find the communication complexity framing more natural, but the direction is far from his core research on learning algorithms. Neither endorser is a communication complexity specialist, which matters if the paper is going to a TCS venue.

**Risk level**: HIGH. The user has strong comparative advantage in oracle-complexity/cycling lower bounds (OP-2 territory), and moving to communication complexity/circuit lower bounds requires ~1 year of background building to be competitive at top venues.

---

## Risk 4 (Timeline): 6-week deliverable is almost certainly not achievable

**Why**: The definitional work alone (D1-D4 in technical_C1.md) typically takes 2-4 weeks of focused work in a new subfield. After definitions are settled, proving a non-trivial lower bound requires:
- Either an algebraic construction (hard, requires new techniques)
- Or a reduction from a known hard problem (requires knowing which hard problem maps cleanly)
- Plus: writing a clean paper, which for a CS theory submission is often 4-8 weeks of work by itself

**What could be done in 6 weeks**: A well-written *position paper* or *research proposal* that:
- Formalizes the four model choices and shows they are non-trivially different
- States the main conjecture precisely
- Proves one lemma: e.g., "in the hard-attention model, the exact-solving framework of arXiv 2510.13903 extends to give P[success] ≤ f(k, R, B) for k-hop tasks"
- Provides empirical evidence from the pipeline's failure data

This is publishable at a workshop (LLM Reasoning, ML4Math, etc.) but not at COLT/STOC as a main-conference paper.

---

## Comparison to OP-2 risk profile

| Dimension | OP-2 (SHB lower bound) | C1 (multi-agent LB) |
|---|---|---|
| Problem crisp at start? | Yes — last-iterate LB for SHB, non-SC | No — four open definitional choices |
| Existing framework reusable? | Yes — cycling + oracle complexity | No — new framework needed |
| Literature gap clear? | Yes — explicit open problem | Partially (arXiv 2510.13903 just appeared) |
| 6-week deliverable? | Likely (2-3 core lemmas, tight bound) | Unlikely (definitional phase alone is 2-4 weeks) |
| Venue fit | COLT/NeurIPS optimization theory | TCS (hard) or workshop |

**Bottom line**: C1 is OP-2's risk profile squared: same "new territory" factor, but without the crisp oracle-model framework that made OP-2 tractable within 6 weeks.
