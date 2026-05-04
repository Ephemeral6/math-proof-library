# Cumulative Reasoning: Depth Lower Bound for Compositional Tasks

## Source
- Paper: Cumulative Reasoning (CR) framework, Problem 7.9.
- Context: Lower bound on the number of Proposer–Verifier steps required to solve a compositional reasoning task with depth-$d$ derivation tree.

## Statement

A CR-style agent has a Proposer that emits one proposition per step and a Verifier with error rate $\varepsilon$. A compositional reasoning task has $m$ primitive facts and a target conclusion that requires combining all $m$ facts through a depth-$d$ logical derivation tree. Let $\delta$ denote the target failure probability.

**(a)** Any correct-with-high-probability solution requires at least
$$T \;\ge\; d \cdot \frac{\log(1/\delta)}{\log(1/\varepsilon)}\,.$$

**(b)** The depth $d$ cannot be parallelized: even with unlimited parallel Proposers, the sequential depth of the derivation tree is a hard lower bound on reasoning time.

**(c)** For $\varepsilon = 0.14$, retry $k=3$, depth $d=5$, target confidence $99\%$ ($\delta = 0.01$):
$$T \;\ge\; \frac{5 \cdot \log(100)}{\log(1/0.14^3)} \;\approx\; 18 \text{ steps}\,.$$

## Difficulty

Conjecture-level (research). Honesty disclosures required:
- Computational model must be specified (Proposer prior, Verifier error distribution, what counts as "one step").
- Part (b) requires a parallel model with sequential dependency.
- Part (c)'s $\varepsilon^k$ effective error must be consistent with the bound's derivation.
