# Value Assessment: C2 — Failure Mode Classification for AI Proof Systems

> Date: 2026-04-28

---

## Impact Score: 7 / 10

**Reasoning (with ceiling and floor)**:

**Floor (5/10)**: If the result is only an NP-hardness argument in the Atserias–Müller style for a tactic-oracle model, the contribution is incremental — it extends known proof complexity machinery to a slightly different model. The AI community will view it as theoretical, the proof complexity community will view it as applied. Neither community will regard it as a top-tier standalone result.

**Ceiling (9/10)**: If the result includes (a) a clean, formally justified tactic-oracle model that the community accepts as the right model for LLM-based provers, (b) a genuine query-complexity lower bound (not just NP-hardness), and (c) a connection between the bound and empirically observed failure behavior, the paper is a landmark. "The first lower bound for AI theorem proving systems" is a headline result with immediate community impact.

**Realistic estimate (7/10)**: The result will likely be a clean NP-hardness result (following Atserias–Müller) for one specific failure class, with a well-motivated oracle model and empirical grounding from the failure database. This is above average for the intersection of AI4Math and proof complexity.

**What makes 7 rather than 8**: The ceiling requires a query complexity LB (not just NP-hardness), which is technically harder and may not close in 6 weeks.

---

## Portfolio Increment Score: 9 / 10

**Reasoning**: This direction leverages the single most unique asset in the user's portfolio — the empirically grounded failure database. No other researcher has:
1. A working AI proof agent pipeline (Math Agent) that has accumulated 40+ structured failure patterns
2. The optimization-theory background to recognize which failure patterns correspond to known complexity phenomena
3. The proof-writing infrastructure (Math library with 85+ verified proofs) to credibly write up the theoretical result

The failure database is the differentiator that makes this a contribution only this user can write authentically. If the direction is abandoned or delayed, another researcher could formalize "quantifier-alternation traps" in AI provers without the empirical grounding, but the result would be less compelling.

**Unique portfolio value**: This is also the only direction in the candidate set that creates a feedback loop with the existing pipeline — the theoretical result, once written, can be used to generate harder test problems for the agent and improve the failure database.

---

## Endorser Match

### 董彬 (AI4Math) — Match: 9 / 10

董彬's group is explicitly positioned at the intersection of AI systems and mathematical foundations. This paper is directly in their wheelhouse:
- "AI4Math" framing: rigorous analysis of when and why AI proof systems fail
- The result provides foundational theoretical grounding for the empirical benchmarking work that dominates the AI4Math community

**Caveat**: 董彬's group is more comfortable with learning-theory and optimization-theory analyses than with proof complexity per se. The paper needs to be written so that a reader who does not know Frege/Resolution can still understand the model and the result. The oracle model framing (rather than purely proof-system framing) helps here.

**Recommendation**: Primary endorser. Frame the paper as "AI4Math foundations" rather than "proof complexity."

### 陈小杨 (AI for math discovery) — Match: 7 / 10

陈小杨's focus on AI for math discovery makes this relevant — the result characterizes the inherent limits of AI math discovery on certain problem types. However:
- 陈小杨's group is more interested in what AI can do than in formal lower bounds on what it cannot
- The negative result framing ("AI provers cannot efficiently find proofs of class QA") is less aligned with a group focused on pushing the frontier

**Caveat**: Could be a strong match if the paper includes a constructive component — e.g., "Here is the hard formula class, and here is a modified agent that beats the lower bound on a slightly easier class." This turns the LB into a positive result (algorithm design insight).

**Recommendation**: Secondary endorser. Include a constructive discussion of what the LB implies for agent design.

---

## Honest Scope Assessment: What to Cut

The full direction ("classify all failure modes") is a 3–5 year research program, not a 6-week project. The only viable 6-week slice is:

**Recommended scope: One specific failure class + one lower bound**

Specifically:

> **Theorem**: Let M be any deterministic tactic-oracle agent (formal definition in paper). Let F_n denote the family of Lean 4 theorems of the form "∃y, ∀x ∈ [n], f(x,y) ≤ g(x)" where f, g are computed by circuits of size n. Then any M that produces a valid Lean 4 proof of a theorem in F_n must make at least Ω(R(F_n)) tactic oracle queries, where R(F_n) is the refutation complexity of the encoding of F_n in propositional Resolution.

**Why this slice**:
1. It is theorem-shaped (single quantified statement with a proof)
2. It directly corresponds to the most common failure class in the user's database (witness construction = ∀∃ failures)
3. It connects to the existing proof complexity literature (Atserias–Müller, Ben-Sasson–Wigderson width method)
4. It is empirically motivated (failure_patterns.md has multiple entries of this type across optimization, learning theory, convex analysis)

**What to leave out**:
- Classification of all 4 failure classes → future work
- Randomized agents → extension; focus on deterministic first
- Full complexity landscape of different formula families → one family is enough

---

## Summary Table

| Criterion | Score | Notes |
|---|---|---|
| Impact | 7/10 | High ceiling (9) if query LB closes; floor (5) if only NP-hardness |
| Portfolio increment | 9/10 | Unique empirical asset (failure DB) cannot be replicated by competitors |
| Endorser: 董彬 | 9/10 | Primary match; AI4Math foundational framing is perfect |
| Endorser: 陈小杨 | 7/10 | Good match IF constructive discussion included |
| 6-week feasibility (full) | LOW | Research program, not a single paper |
| 6-week feasibility (one class) | MEDIUM | Achievable with disciplined scope, significant technical risk at week 4 |
| Recommended action | **Pursue, re-scoped** | One class (QA), one LB, tactic-oracle model |
