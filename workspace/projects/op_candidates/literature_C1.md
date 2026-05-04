# Literature Survey: C1 — Multi-Agent Reasoning Capability Lower Bound

**Survey date**: 2026-04-28  
**Evaluator**: Claude Sonnet 4.6 (automated)

---

## Executive finding

There is **NOT** a coherent, self-aware literature on "multi-agent LLM lower bounds" as a named subfield. What exists is a thin but structurally useful constellation: transformer expressivity results (well-developed), CoT complexity class results (rapidly growing, 2023–2025), and multi-agent LLM communication analysis (very new, ~2 papers with formal content). The gap is precisely the opportunity — but it is also the risk.

---

## Core papers

### 1. Merrill & Sabharwal (2024) — The Expressive Power of Transformers with Chain of Thought
- **Venue**: ICLR 2024
- **arXiv**: 2310.07923
- **Content**: Characterizes transformer decoder expressivity as a function of CoT length t(n). With O(log n) steps: slightly beyond TC⁰. With O(n) steps: all regular languages. With poly(n) steps: exactly P (poly-time). Upper bound: CoT(t(n)) ⊆ TIME(n² + t(n)²).
- **Relevance**: This is the cleanest complexity-class framing. C1 would need to extend this to *multi-agent* CoT, i.e., what is the class when k agents each run t(n) CoT steps and communicate R rounds?

### 2. Sanford, Hsu & Telgarsky (NeurIPS 2023) — Representational Strengths and Limitations of Transformers
- **Venue**: NeurIPS 2023
- **arXiv**: 2306.02896
- **Content**: Intrinsic complexity parameters (width, depth, embedding dimension). Positive: transformers solve sparse averaging in O(log n) size vs poly(n) for RNNs. Negative: tight lower bounds by showing certain circuits require exponential size in specific parameters.
- **Relevance**: Methodology. Their technique for proving representational lower bounds (showing exponential blowup under constrained resources) is directly applicable to multi-agent settings where resource = communication budget.

### 3. Li et al. (2024) — Chain of Thought Empowers Transformers to Solve Inherently Serial Problems
- **Venue**: ICLR 2024
- **arXiv**: 2402.12875
- **Content**: Constant-depth transformers with constant-bit precision can only solve problems in AC⁰ without CoT, but with T steps of CoT can solve any problem solvable by Boolean circuits of size T. Provides an exact simulation.
- **Relevance**: Establishes the baseline for single-agent CoT; C1 needs the multi-agent generalization.

### 4. Anonymous / arXiv 2502.02393 (2025) — Lower Bounds for Chain-of-Thought Reasoning in Hard-Attention Transformers
- **Venue**: ICML 2025 (proceedings)
- **Content**: Proves that parity requires Ω(n) CoT length for general hard-attention transformers. Explicit lower bounds for parity and multiplication via problem-specific reductions.
- **Relevance**: The most direct methodological predecessor. Extending their technique from single-agent scratchpad to multi-agent communication is a natural program.

### 5. arXiv 2510.13903 (Oct 2025) — Benefits and Limitations of Communication in Multi-Agent Reasoning
- **Authors**: Unnamed (preprint)
- **Content**: First paper to directly address formal bounds on multi-agent LLM communication. Derives: (i) agent count needed for exact task solving, (ii) communication quantity/structure bounds, (iii) achievable speedups as problem size scales. Key theorems: Any multi-agent protocol converts to single-agent with same size up to constant; depth reduction requires communication increase (depth-communication tradeoff). Validates on three task families: state tracking, recall, k-hop reasoning.
- **Relevance**: HIGHEST — this is the closest existing work to C1. It proves the tradeoff exists but does not give information-theoretic lower bounds on *success probability* as a function of agent×rounds. C1 would need to move from "exact solving" to "probabilistic success rate" framing.

### 6. Wang et al. (ACL 2024) — Rethinking the Bounds of LLM Reasoning: Are Multi-Agent Discussions the Key?
- **Venue**: ACL 2024
- **arXiv**: 2402.18272
- **Content**: Empirical finding that a single LLM with strong prompting matches or beats multi-agent discussion. Multi-agent discussion only helps when no demonstrations are available.
- **Relevance**: Provides the empirical motivation for a negative result. The claim "multi-agent doesn't help beyond strong single-agent" cries out for an information-theoretic explanation.

### 7. Multi-LLM Debate: Framework, Principals, and Interventions (NeurIPS 2024)
- **Venue**: NeurIPS 2024
- **Content**: Formal framework for debate dynamics, showing convergence to majority opinion when agents share training distribution. Characterizes when debate collapses to consensus on common misconceptions.
- **Relevance**: Offers a convergence/impossibility angle: when agents share a hypothesis class, debate cannot escape the shared error region. This is PAC-Bayes-adjacent.

### 8. Transformer Encoder Satisfiability: Complexity and Impact on Formal Reasoning (2024)
- **Venue**: arXiv 2405.18548
- **Content**: trSAT is undecidable for standard transformers; NEXPTIME-hard for quantized fixed-precision versions.
- **Relevance**: Lower bound for *single* transformer formal reasoning. Multi-agent coordination cannot circumvent undecidability — relevant for impossibility framing.

### 9. Sanford, Hsu & Telgarsky (ICML 2024) — Transformers, Parallel Computation, and Logarithmic Depth
- **Venue**: ICML 2024
- **Content**: Connects transformer expressivity to parallel computation depth (NC circuits), showing depth-width tradeoffs.
- **Relevance**: Multi-agent systems are a form of parallel computation; their NC framework may directly apply to k-agent systems running in parallel.

### 10. Emergent Coordination in Multi-Agent Language Models (arXiv 2510.05174, 2025)
- **Content**: Uses partial information decomposition (PID) to analyze emergence in multi-agent LLM coordination. Connects emergence with time-delayed mutual information.
- **Relevance**: Information-theoretic toolkit that could ground the "task difficulty vs. communication budget" tradeoff.

---

## State of the literature: assessment

| Subfield | Papers | Maturity |
|---|---|---|
| Single transformer expressivity | ~20+ | Mature, well-defined |
| CoT complexity classes (single agent) | ~8 (2023–2025) | Rapidly consolidating |
| Multi-agent LLM formal bounds | ~2 | Sparse — near vacuum |
| Multi-agent LLM communication theory | ~1 (arXiv 2510.13903) | Just emerging |
| PAC/VC framing for LLM agents | 0 | None found |

**Conclusion**: The specific formulation C1 targets (agents × rounds × success probability via communication complexity) has at most one partial predecessor (arXiv 2510.13903, which uses a different model: exact solving vs. probabilistic). This is a genuine gap — but "genuine gap" cuts both ways.
