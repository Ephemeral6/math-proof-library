# D1 Value Assessment: Counterexample Construction Query-Complexity Lower Bound

## Date: 2026-04-28

---

## Impact Score: 7 / 10

**Justification:**

The framing — query complexity lower bounds for counterexample-finding algorithms on parametric conjecture families — is genuinely novel. No existing paper directly addresses this problem in the TCS literature. The result, if clean, would appear in:
- STOC / FOCS / CCC (if LBs are tight and model is convincing)
- More realistically: SODA / APPROX / RANDOM given 6-week scope and Boolean model scope

Impact ceiling is constrained by:
- The Boolean unstructured model's LB is relatively easy (the hard work is the definition, not the proof).
- The result must generalize beyond Boolean to reach STOC-level impact.
- However, a clean paper with a rigorous oracle model, Omega(n) lower bound, and matching UB that explicitly positions itself relative to FunSearch/AlphaProof would attract significant attention from the AI4Math community.

**Upgrade path to 8-9/10:** Prove LBs for the *adaptive* vs. *oblivious* separation in the graph conjecture model. This is harder (10-12 weeks) but would be a genuinely surprising result.

---

## Portfolio Increment Score: 8.5 / 10

**Justification:**

This direction provides maximum differentiation from the OP-2 (SHB stochastic non-SC last-iterate lower bound) portfolio:

| Dimension | OP-2 (SHB lower bound) | D1 (conjecture-refutation LB) |
|---|---|---|
| Problem type | Optimization convergence | Query/search complexity |
| Technique | Arjevani oracle + Le Cam | Yao minimax + decision-tree |
| Application domain | ML training (SGD) | Mathematical discovery (AI4Math) |
| Proof tools | Markov chain / information theory | Combinatorics / polynomial method |
| Endorser match | 文再文, 李晨毅, 袁洋 | 陈小杨, 董彬, 李肖 |

The portfolio increment is high because:
1. **Cross-area bridge:** Connects the user's established optimization-LB skills (oracle complexity, Le Cam) to a new domain (query complexity for mathematical discovery). This is portfolio-expanding, not just portfolio-deepening.
2. **AI4Math positioning:** The FunSearch/AlphaProof wave (2023-2025) has generated enormous interest in the theoretical foundations of AI-driven math discovery. D1 is one of the first papers to ask "what are the information-theoretic limits of these systems?" — a question that will be asked by the field regardless.
3. **OP-2 skill reuse:** The Le Cam / Yao minimax tools transfer directly, so the marginal technical investment is lower than starting from scratch.

---

## Endorser Match Assessment

### Primary target: 陈小杨 (Chen Xiaoyang) — AI4Math, math discovery

**Strength of match: 9 / 10**

陈小杨's group focuses on AI for mathematics: automated theorem proving, conjecture generation, AI-assisted discovery. D1 directly addresses the theoretical limits of AI conjecture-refutation systems (FunSearch, MCTS-based approaches). The connection is not superficial:
- D1 proves that no oracle-model algorithm (regardless of whether it is an LLM, MCTS, or deterministic search) can refute a conjecture from a given class with fewer than Omega(T) queries.
- This is a *negative result* that sharpens our understanding of where AI-discovery tools can and cannot work efficiently.
- The paper's introduction can explicitly frame the result as: "We prove that FunSearch-style systems face fundamental query-complexity barriers for a natural class of conjectures."

**陈小杨 endorsement scenario:** High likelihood of interest if the paper's introduction is written with the AI4Math framing front-and-center. The result is novel from his perspective because his group produces UB algorithms; a rigorous LB paper is complementary and publishable.

### Secondary targets:

**董彬 (Dong Bin) — mathematical AI, scientific discovery: 7 / 10**
- Works on AI for scientific discovery (physics, chemistry). The oracle model for counterexample finding maps to experimental design (each "query" is an experiment). D1's LBs imply limits on how efficiently any experimental-design algorithm can find a counterexample to a physical conjecture. This is a stretch but a publishable framing for a second paper.

**李肖 — AI theory, generalization: 6 / 10**
- Less direct match. Li Xiao's interests are more in generalization theory. D1 is not about generalization bounds. Match is weak.

**文再文, 李晨毅, 袁洋 — optimization: 5 / 10**
- The connection is via oracle complexity (shared technique), but D1 is not an optimization paper. These endorsers would be secondary references, not primary.

---

## Cross-Area Appeal

### AI4Math community:
- **Appeal: VERY HIGH.** FunSearch (Nature, 2023), AlphaProof (DeepMind, 2024), and MCTS-based conjecture falsifiers (arXiv:2306.07956, 2024) have created enormous interest. The field has been producing UBs for 3 years with no LB theory. D1 fills this gap.
- Likely target venues from AI4Math side: NeurIPS 2026 (theory track), ICML 2026 (theory/foundations), or a dedicated AI4Math workshop.

### TCS complexity theory community:
- **Appeal: MEDIUM.** The result is novel but the LB technique (Yao minimax in the Boolean model) is not surprising to complexity theorists. Appeal increases significantly if the graph or polynomial model is tackled.
- Target venues: CCC, STACS, or APPROX.

### Optimization community:
- **Appeal: MEDIUM-LOW.** Optimization theorists are familiar with oracle LBs (Arjevani style) but the conjecture-finding framing is outside the usual application domain. The connection is via oracle complexity as a shared framework.

---

## Overall Recommendation

**PROCEED with D1 at restricted scope (Boolean model, 6 weeks).**

The risk-adjusted value calculation:
- Novel framing with no direct competition in 2023-2026 literature: confirmed.
- Technical feasibility for Boolean model in 6 weeks: confirmed (tight but doable).
- Endorser match (陈小杨): strong.
- Portfolio differentiation from OP-2: high.
- Cross-area bridge (optimization LB skills → AI4Math): unique and timely.

The main caveat: the Boolean model result alone is unlikely to reach STOC/FOCS. The 6-week deliverable would be a strong workshop paper or second-tier theory venue paper with a clearly stated agenda for the harder graph/polynomial model as future work. This is appropriate for a 6-week research sprint.

**Decision: GO (scoped to Boolean model)**
