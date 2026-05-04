# Literature Survey: C2 — Failure Mode Classification for AI Proof Systems

> Search queries: "proof search complexity", "neural theorem prover analysis", "LLM theorem proving limits", "automated theorem proving lower bound"
> Date: 2026-04-28

---

## Foundational Proof Complexity

### 1. Haken (1985) — Resolution is Exponential for PHP
- **Title**: "The intractability of resolution"
- **Source**: Theoretical Computer Science 39, 1985
- **Core result**: Exponential lower bound on resolution proof size for the pigeonhole principle (PHP_n). First exponential LB for a natural propositional proof system.
- **Relevance**: Establishes the template for "proof system X cannot efficiently prove formula class Y" — exactly the shape needed for a failure-mode LB.
- **Note**: Often attributed to "Razborov 1985" in informal citation, but the 1985 breakthrough is Haken; Razborov's major resolution-complexity contributions came 1987–2005.

### 2. Krajicek (1995) — Bounded Arithmetic and Proof Complexity
- **Title**: *Bounded Arithmetic, Propositional Logic and Complexity Theory*
- **Source**: Cambridge University Press, Encyclopedia of Mathematics and Its Applications vol. 60
- **Core content**: Comprehensive framework connecting bounded arithmetic, propositional proof systems (Frege, Extended Frege, Resolution), and circuit complexity. Provides tools for separating proof systems and establishing lower bounds.
- **Relevance**: The canonical reference for the technical machinery (size/width/depth measures, polynomial simulations) needed to formalize failure classes.

### 3. Atserias and Müller (2019/2020) — Automating Resolution is NP-Hard
- **Title**: "Automating resolution is NP-hard"
- **Source**: FOCS 2019; J. ACM 2020
- **Core result**: Resolution is not automatable unless P = NP. Proof via "refutation statements" Ref_s(φ): given a CNF φ, Ref_s(φ) has no subexponential Resolution refutation of size < 2^{Ω(s/n)}.
- **Relevance**: Directly relevant — proves that one specific failure mode (proof search in Resolution) is computationally characterized. This is the closest existing work to a "one failure class with one LB."

### 4. de Rezende, Goos, Nordstrom et al. (2021) — Automating Algebraic Proof Systems is NP-Hard
- **Title**: "Automating algebraic proof systems is NP-hard"
- **Source**: STOC 2021
- **Core result**: NP-hardness of automating Nullstellensatz, Polynomial Calculus, and Sherali–Adams. Goos's "The Aftermath" (2020 workshop) gives a unified framework.
- **Relevance**: Extends the Atserias–Müller pattern. Shows the failure-mode LB approach generalizes across proof system families.

### 5. Goos, Koroth, Mertz, Pitassi (2020) — Automating Cutting Planes is NP-Hard
- **Title**: "Automating cutting planes is NP-hard"
- **Source**: STOC 2020
- **Core result**: NP-hardness of finding Cutting Planes refutations of size polynomial in the optimal refutation size.
- **Relevance**: Extends the automating-is-hard template to geometric/LP-based proof systems.

---

## Modern AI-Side Literature

### 6. Polu and Han (2020/2022) — GPT-f and Formal Mathematics
- **Title**: "Generative Language Modeling for Automated Theorem Proving" (2020, arXiv:2009.03393); "Formal Mathematics Statement Curriculum Learning" (ICLR 2023)
- **Source**: OpenAI technical reports
- **Core content**: First demonstration of GPT-scale transformers proving Metamath theorems. Uses best-first search over tactic tree. Identifies empirically that search depth, tactic distribution shift, and lack of lemma reuse are key failure drivers.
- **Relevance**: Establishes the empirical failure vocabulary for neural provers; provides a target system for theoretical characterization.

### 7. Li et al. (COLM 2024) — Survey on Deep Learning for Theorem Proving
- **Title**: "A Survey on Deep Learning for Theorem Proving"
- **Source**: COLM 2024, arXiv:2404.09939, GitHub: zhaoyu-li/DL4TP
- **Core content**: Systematic survey of failure modes: (a) out-of-domain generalization, (b) whole-proof generators cannot reuse lemmas, (c) step generators do not scale, (d) tight coupling to specific proof assistant grammars, (e) error localization from formal checker to human-readable form.
- **Relevance**: Closest to a taxonomy of failure modes in the existing literature, but entirely descriptive — no theorems, no lower bounds.

### 8. DeepSeek-Prover-V1.5 (ICLR 2025) and V2 (2025)
- **Title**: "DeepSeek-Prover-V1.5: Harnessing Proof Assistant Feedback for Reinforcement Learning and Monte-Carlo Tree Search" (ICLR 2025); "DeepSeek-Prover-V2" (arXiv:2504.21801)
- **Source**: DeepSeek AI, 2024–2025
- **Core content**: V1.5 uses MCTS + RL with Lean 4 feedback. V2 achieves 88.9% on MiniF2F at Pass@8192 using recursive subgoal decomposition. Known issues: possible misformalization of examples; PutnamBench proofs reported to contain implicit sorry.
- **Relevance**: State-of-the-art system with documented failure modes (sorry smuggling, subgoal decomposition failures on deeply nested quantifiers) that are empirically observable but not theoretically characterized.

### 9. NeurIPS 2024 PUTNAMBENCH — Neural Prover Benchmarking
- **Title**: "PUTNAMBENCH: Evaluating Neural Theorem-Provers on the Putnam Mathematical Competition"
- **Source**: NeurIPS 2024 Datasets and Benchmarks Track
- **Core content**: Evaluates neural provers on Putnam-level problems. Identifies systematic failure on problems requiring multi-step quantifier reasoning and non-constructive existence proofs.
- **Relevance**: Provides empirical evidence that quantifier-alternation-heavy statements are a distinct failure class — supporting the "one specific failure mode" re-scoping.

### 10. Arteche, Atserias, de Rezende, Khaniki (June 2025) — The Proof Analysis Problem
- **Title**: "The Proof Analysis Problem"
- **Source**: arXiv:2506.16956, June 2025
- **Core result**: Introduces the "Proof Analysis Problem" (PAP): given a CNF formula and a proof of a Resolution lower bound for it, is the formula satisfiable? PAP for Extended Frege is NP-complete; PAP for Resolution is in P.
- **Relevance**: Very recent foundational work that directly links proof complexity analysis to computational hardness — the cleanest theoretical connection between "understanding why a proof system fails" and complexity-theoretic lower bounds.

---

## Gap Analysis: Is There a Classification Theorem?

**No.** The existing literature contains:
- Empirical failure taxonomies (Li et al. survey, PUTNAMBENCH) — descriptive, no theorems
- Hardness-of-automation results for classical proof systems (Atserias–Müller, Goos et al.) — theorems, but about classical Resolution/PC/CP, not about AI/LLM agents
- System-specific analyses of neural provers — no unified classification

**The gap**: There is no work that (a) formally defines failure mode classes for AI proof agents, (b) proves per-class lower bounds, or (c) connects the empirical failure patterns of LLM/hybrid agents to proof complexity hardness results. This is the contribution C2 targets.
