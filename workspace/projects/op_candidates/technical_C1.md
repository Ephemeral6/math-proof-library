# Technical Assessment: C1 — Multi-Agent Reasoning Capability Lower Bound

**Date**: 2026-04-28

---

## 1. Technique inventory

### 1a. Communication complexity (Yao 1979 / KN book)
**What it gives**: Lower bounds of the form "any k-party protocol that computes f with probability > 1-δ must send Ω(C) bits, where C depends on the communication complexity of f."

**Fit to C1**: The natural formulation is:
- Fix a *task class* F (e.g., "proofs of theorems requiring ≥ r alternating quantifier blocks")
- Model each agent as a deterministic or randomized function of (private input + received messages)
- The "success probability" bound becomes: P[protocol outputs correct proof of f] ≤ g(#agents, #rounds, message_length)

**Difficulty**: The standard communication complexity model assumes agents have *fixed* (non-adaptive) local computation. LLM agents are themselves Turing-equivalent (given infinite CoT). You must restrict either (a) the CoT depth per agent or (b) work in the hard-attention or log-depth model (à la Merrill-Sabharwal) to make communication complexity arguments bite. Without such restriction, the bound degenerates to: "with enough CoT a single agent solves everything," which is vacuous.

**Useful sub-technique**: Number-on-forehead (NOF) multiparty CC. With k players and a shared blackboard, the communication complexity of k-party AND is Θ(n/2^k). If the task is "verify a proof of length n," this gives a natural Ω(n/2^k) rounds lower bound — but only once "verifying a proof" is framed as a suitable function in the NOF model.

### 1b. PAC-Bayes / VC dimension
**What it gives**: Bounds on generalization error of a hypothesis class H: R(h) ≤ R̂(h) + O(sqrt(VC(H)/n)).

**Fit to C1**: The natural agent model is: agent i implements hypothesis h_i ∈ H_i (a function from proof-state to next-step distribution). The *joint* system is a product hypothesis (h_1,...,h_k) ∈ H^k. The question "what is the success rate on a proof task drawn from distribution P?" is a generalization question.

**Difficulty**: VC/PAC-Bayes bounds are about *generalization from training data*, not about *computational hardness in the online setting*. The bound would say: "if agents are trained, their joint success rate is bounded by their VC dimension." But the relevant question for C1 is about success on *any* proof strategy, not one learned from i.i.d. samples. The two are different; conflating them would be a conceptual error.

**More natural angle**: PAC-Bayes with the KL divergence between agent posterior and prior — this could bound "the information gain per communication round." But it requires defining a natural prior over agent behaviors, which is model-dependent and contentious.

### 1c. Capacity scaling / information-theoretic Shannon channel
**What it gives**: If agents communicate through a channel of capacity C bits/round, then after R rounds the total information transferred is at most C×R bits. If the proof task has Kolmogorov complexity K, then solving it requires exchanging K bits, giving a lower bound on C×R.

**Fit to C1**: This is the cleanest route for a *qualitative* result:
> "If a proof task has description complexity K and agents communicate at most B bits per round over R rounds with k agents, then P[success] ≤ 1 - Ω((K - kBR) / K) for sufficiently complex K."

**Difficulty**: Kolmogorov complexity bounds are typically non-constructive; the "proof task description complexity" is problem-instance specific, not a class parameter. This route gives bounds that are correct but arguably tautological ("you can't communicate more information than you communicate").

### 1d. Circuit complexity / NC framework
**What it gives**: Multi-agent systems with k agents running in parallel with t(n) CoT steps per agent, communicating R rounds, can be modeled as NC^R circuits of depth O(R·t(n)) and width k. Since NC^i ⊊ NC^{i+1} (conjectured, proved for some restricted models), this gives separation results.

**Fit to C1**: Best technical route if working in the hard-attention transformer model (where Merrill-Sabharwal and Li et al. results are known). The multi-agent generalization of "poly steps → P" would be: "k agents each with t(n) steps and R communication rounds can solve exactly the class NC^R_{k,t(n)}."

**Difficulty**: The conjectured separations NC^i ⊊ NC^{i+1} are unproved in general. Results would need to work in a restricted model (hard attention, constant precision) to get unconditional results.

---

## 2. What must be freshly developed

The following are genuine open problems that would need to be solved before a paper could be written:

**D1. Formal task class definition**  
What is the "proof task class" F? Options:
- (a) Theorems expressible in first-order logic of depth ≤ r
- (b) Proof trees of height ≤ h in a fixed formal system
- (c) Mathematical problems whose solutions require Ω(K) bits of information
- (d) The k-hop reasoning tasks from arXiv 2510.13903  

Option (d) is the fastest to work with because arXiv 2510.13903 already established formal results for it — C1 could *extend* their exact-solving framework to probabilistic success.

**D2. Agent capability model**  
How do you formalize "agent i has reasoning capability C_i"? Options:
- Hard-attention transformer with depth d_i and width w_i
- Oracle access to a function class F_i with VC dimension V_i
- Randomized communication complexity player with t(n)-bit local computation

**D3. Communication model**  
Synchronous rounds vs. asynchronous? Shared blackboard vs. point-to-point? Full or partial connectivity? The choice determines which CC results apply.

**D4. Success probability model**  
How is "success" defined? "Outputs a proof that verifies in Lean" vs. "outputs a proof accepted by a human evaluator" have very different formalizability. The Lean-verifiable definition is clean but requires restricting task class to formalized mathematics.

---

## 3. Pipeline reuse assessment

| Component | Reuse? | Notes |
|---|---|---|
| Oracle complexity framework (from OP-2) | **No** | OP-2's oracle is a stochastic gradient oracle; C1's oracle is an agent "turn" oracle — different formalism |
| Cycling-based lower bound constructions | **No** | Not applicable to LLM agents |
| Le Cam method | **Marginal** | Can be repurposed as: distinguishing between "correct proof" and "plausible-but-wrong proof" via TV distance, but this is a stretch |
| The pipeline's failure data | **Yes** — unique asset | 80+ failure entries provide empirical grounding for which task classes are hard; see Section 4 |

**Honest assessment**: This direction starts from near-zero in terms of technical infrastructure. The user would be building a new mathematical framework, not extending an existing one.

---

## 4. Unique asset: the pipeline's failure database

The failure_patterns.md database contains 20+ documented failure modes. Several are directly relevant to formalizing "task difficulty":

- **FP entries on SHB lower bound**: The "no-man's land" construction failure (need ∇²f(x*) = 0 neighborhood + non-quadratic + GD doesn't accelerate) suggests that hard instances have specific structural properties that can be formalized.
- **FP-18 (contradictory UB/LB)**: The auditor failure to detect UB/LB contradiction suggests that multi-agent systems fail systematically when agents share a hypothesis that is internally inconsistent — a potential PAC-Bayes angle.
- **Gradient clipping / implicit bias / STORM failures**: These all exhibit the pattern "the standard technique fails for structural reasons" — which is exactly the data needed to define a "hard task class."

**How to use it**: Operationally, one could define: "Task class F_hard := problems where the pipeline's failure rate exceeds 50% after 3 explorers." Then the empirical claim is: "For tasks in F_hard, no multi-agent system with k agents × R rounds achieves success rate > p*." Making this into a *theorem* requires showing F_hard has a formal complexity-theoretic characterization — which is the hard part (see D1 above).

---

## 5. Verification feasibility

**Empirical verification**: Yes, feasible. The pipeline can be run with k=1,2,3 agents and R=1,2,3 communication rounds on tasks from F_hard and F_easy, producing success rate curves. This provides falsifiable empirical support.

**Formal verification (Lean)**: Not feasible within 6 weeks. The theorems involve communication complexity or circuit complexity, which are not well-formalized in Mathlib4 as of 2026. The lean-formalization-agent in this pipeline would likely fail on these problems.

**Numerical/symbolic verification**: Partial. The circuit complexity route could be verified on toy examples (e.g., k-hop reasoning with small k, small graph).
