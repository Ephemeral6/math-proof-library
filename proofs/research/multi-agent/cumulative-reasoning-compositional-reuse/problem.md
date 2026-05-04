# Compositionality of Cumulative Reasoning: When Can Sub-Proofs Be Reused?

## Source
- Paper: User research framework, Problem 7.7 ("Compositionality of CR Reasoning").
- Context: Justifies the library-first reuse pattern (P3) in a multi-agent CR architecture. The proof library is modeled as a DAG of lemmas; an agent invokes proven lemmas via [REF:] markers. We bound the probability that a derived theorem T is correct in terms of the per-lemma verified error δ.

## Statement

Model the proof library as a DAG. Lemma L_i has verified error P(L_i wrong) ≤ δ_{L_i}. Theorem T's [REF:] proof is sound iff every referenced lemma is correct.

**(a)** If lemma failures A_i = {L_i correct} are mutually independent and intersection of all A_i implies T correct, then
$$P(T \text{ correct}) \ge \prod_{i=1}^m (1 - \delta_{L_i}) \ge 1 - \sum_{i=1}^m \delta_{L_i}.$$

**(b)** If the dependency DAG is fully tree-unfolded (no reuse), with maximum in-degree Δ and depth d and uniform error δ, then
$$P(T \text{ correct}) \ge (1 - \delta)^{N(d, \Delta)}, \quad N(d, \Delta) = \frac{\Delta^{d+1}-1}{\Delta-1} \ \text{(for } \Delta \ge 2\text{)}.$$

This corrects the user's stated form (1-δ)^{Δ^d}; the correct exponent is N(d,Δ) ≥ Δ^d (with N(d,Δ)/Δ^d → Δ/(Δ-1) ≤ 2 as d → ∞).

**(c)** If each lemma is verified through k independent Auditor-Fixer retries before being committed to the library, then
$$P(T \text{ correct}) \ge (1 - \delta^k)^m,$$
which is exponentially better in δ than the per-attempt bound.

## Difficulty
Research (multi-agent system theory; probability of compositional verification).
