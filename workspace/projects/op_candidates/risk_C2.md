# Risk Assessment: C2 — Failure Mode Classification for AI Proof Systems

> Date: 2026-04-28

---

## Overall Risk Profile

**6-week feasibility (full classification)**: LOW
**6-week feasibility (one class + one LB)**: MEDIUM
**Long-term research value**: HIGH (if definitions land cleanly)

---

## Top 3 Risks

### Risk 1: "Too Descriptive" — the Non-Theorem Shape Problem

**Description**: The direction is at serious risk of producing a paper that is a well-organized empirical taxonomy with no theorem. The failure is: after 6 weeks, the output is "we observed 4 failure modes and here is a complexity argument for why each is hard" — but the complexity arguments are informal, not genuine lower bounds.

**Probability**: High (60–70%) if not disciplined from day 1.

**Why it happens**: Proof complexity lower bounds require a precisely defined formula family, a precisely defined proof system (or oracle model), and a rigorously proved separation. Each of these requires weeks of work independently. A 6-week timeline with all three is tight even for experienced proof complexity researchers.

**Mitigation**: Hard constraint — commit to one formula family and one oracle model before week 2. Do not attempt to classify all failure modes; prove one bound rigorously.

**Example of failure**: Paper ends with "Theorem 1 (informal): Quantifier-alternation traps are hard for tactic-oracle agents" followed by a proof that is essentially "because the tactic oracle has limited information." This is not a theorem.

---

### Risk 2: Model Validity — The Agent Model Does Not Match Real Systems

**Description**: The tactic-oracle model (Step 1 in technical assessment) may be a poor abstraction of actual LLM proof agents. Specifically:
- Real LLMs do not query a tactic oracle discretely; they generate tactics from internal weights trained on the entire Lean/Mathlib corpus
- The oracle model assumes the agent is a "query machine" but real agents have massive prior knowledge baked into parameters
- A lower bound against the oracle model does not imply anything about LLMs unless model validity is argued carefully

**Probability**: Medium (40–50%)

**Why it matters**: If the model is not valid, the LB is a formal exercise with no connection to the real phenomenon. The paper title promises "AI proof systems" but the theorem is about a toy oracle model.

**Mitigation**: Spend explicit effort arguing model validity. One route: show that the oracle model is at least as strong as Lean tactic evaluation (which is computable and does not have the benefit of cross-training). Lower bounds against the oracle model are then lower bounds for any agent that uses tactic evaluation as a subroutine.

---

### Risk 3: Proof Complexity Reduction Does Not Close

**Description**: The proposed technical route requires a reduction from an NP-hard (or PSPACE-hard) search problem to the tactic query problem. This reduction may fail to close for the specific formula family F_n chosen, due to:
- The oracle model is too powerful (can simulate the adversary argument in fewer queries)
- The formula family F_n does not have the right "depth" structure needed for the adversary method
- The query complexity bound achieved is Ω(1) or Ω(log n) — too weak to be interesting

**Probability**: Medium (35–45%)

**Why it happens**: Query complexity lower bound proofs are technically demanding. The adversary method requires identifying a "hard input pair" (x, y) and a "adversary relation" R that satisfies specific properties. For formula families motivated by empirical failure patterns (rather than combinatorially designed hard instances), the required structure may not be present.

**Mitigation**: Have a fallback theorem. If the Ω(n^{1/2}) query LB does not close, aim for an NP-hardness or undecidability result in a weaker oracle model. Even showing "finding a proof of F_n is NP-hard in the refutation-statement sense (Atserias–Müller style)" is a publishable contribution.

---

## Secondary Risks

### Risk 4: Scope Creep
The direction naturally expands from "one class with one LB" to "four classes with four LBs" as work progresses. Each additional class requires its own model, formula family, and proof. 6 weeks is insufficient for more than one end-to-end.

**Mitigation**: Define scope boundaries in week 1 and treat any additional class as future work in the paper.

### Risk 5: Endorser Appetite
The proof complexity community (Atserias, Krajicek, Nordstrom) has high standards for what constitutes a legitimate complexity lower bound. A paper that is primarily "AI-inspired" may be viewed skeptically by that community. Conversely, the ML theory community (董彬, 陈小杨) may not evaluate the proof complexity contribution correctly.

**Mitigation**: Frame as "AI4Math foundational theory" — specifically, position the result as a rigorous version of the empirically known phenomenon that AI provers fail on certain formula classes. 董彬 and 陈小杨 are the right endorsers for this framing.

---

## 6-Week Timeline (Realistic)

| Week | Goal |
|---|---|
| 1 | Define tactic-oracle model. Formalize "Class QA" from failure_patterns.md. Write problem.md. |
| 2 | Literature review complete. Identify closest existing LB (Atserias–Müller or query complexity). |
| 3 | Attempt proof via adversary method. Identify whether reduction closes. |
| 4 | Iterate on formula family F_n or pivot to fallback (NP-hardness argument). |
| 5 | Draft full proof. Internal audit. |
| 6 | Write up. Submit to arXiv or workshop (e.g., ICLR workshop on AI for Math). |

**Honest assessment**: Week 4 is the crux. If the adversary method does not yield a tight bound by end of week 4, the paper must pivot to an NP-hardness argument, which is weaker but still publishable. A clean Ω(n^{1/2}) query LB would be a strong result; an NP-hardness result in the Atserias–Müller style is solid but less novel.
