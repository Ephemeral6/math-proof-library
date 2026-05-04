# Technical Route: D2 — Symbolic Regression Sample Complexity Lower Bound

**Date**: 2026-04-28

---

## Problem formulation

**Setting**: Let S(d, s, Σ) denote the class of symbolic expressions of depth at most d, size (number of nodes) at most s, over operator set Σ ⊆ {+, −, ×, ÷, sin, exp, log, sqrt, const}. Given n i.i.d. samples {(x_i, f(x_i))}_{i=1}^n with x_i ~ P_X (some fixed input distribution) and f ∈ S(d, s, Σ), define:

- **Exact recovery**: output f̂ such that f̂ = f (as a function, a.e. under P_X)
- **ε-recovery**: output f̂ such that E_{x~P_X}[(f̂(x) − f(x))^2] ≤ ε^2

**Core question**: What is the minimax sample complexity n*(ε, d, s, Σ, δ) for (δ-probably) ε-recovering f ∈ S?

---

## Primary route: Fano lower bound via packing

### Step 1 — Enumerate the hypothesis class

For fixed (d, s, Σ), the number of syntactically distinct expression trees is:

N(d, s, Σ) ≥ exp(Ω(s · log|Σ|))

This is because a depth-d binary tree with s nodes has Catalan(s/2) ≈ 4^{s/2}/s^{3/2} structural shapes, and each internal node can be labeled by any operator from Σ. The combinatorial enumeration is standard (Sedgewick-Flajolet analytic combinatorics for labeled trees).

**For D2**: fix d = 4, s = 15, Σ = {+, ×, sin, exp} (4 binary operators). Then N ≥ 4^7 / polylog ≈ 16000 candidate functions. For Fano, we need a subset of N pairwise separated functions.

### Step 2 — Construct a packing set

Find M functions f_1, ..., f_M ∈ S(d, s, Σ) such that for all i ≠ j:

E_{x~P_X}[(f_i(x) − f_j(x))^2] ≥ Δ^2   (well-separated in L^2(P_X))

**Construction strategy**: Take expressions that differ only in the outermost unary operator (sin vs. exp applied to the same subtree). For input distribution P_X = Uniform[0,1]^k with k ≥ 1, sin(t) and exp(t) differ by at least Ω(1) in L^2 norm when t has bounded range — this can be verified numerically with PySR/gplearn.

Setting Δ = Ω(1) (constant separation) and M ≥ exp(Ω(s log|Σ|)) gives a packing set of exponential size.

### Step 3 — Apply Fano's inequality

Standard Fano lower bound (see cover-thomas, or the pipeline's xu-raginsky approach):

**Fano**: If M hypotheses are uniformly distributed and any estimator must identify the correct one from n samples, then the probability of error ≥ 1 − (I(f; x^n) + log 2) / log M, where I(f; x^n) is the mutual information between the selected hypothesis and the observations.

For noiseless observations y_i = f(x_i): with M well-separated hypotheses and n samples,

I(f; x^n) ≤ n · log(M) · KL(single obs distinguishability)

Key computation: if f_i, f_j differ by Δ in L^2(P_X), and x is uniform on [0,1]^k, the KL divergence between P_{y|f=f_i} and P_{y|f=f_j} under additive Gaussian noise N(0,σ^2) is:

KL(P_i || P_j) = Δ^2 / (2σ^2)

So for M = exp(Ω(s log|Σ|)) and mutual info ≤ n Δ^2/(2σ^2):

n* = Ω(s · log|Σ| · σ^2 / Δ^2)

This gives **n* = Ω(s · log|Σ|)** as the minimax lower bound for exact identification (up to noise-dependent constants).

### Step 4 — Noiseless case (exact recovery)

For noiseless observations y_i = f(x_i): two functions f_i, f_j in the packing set are distinguishable after seeing exactly one point x where they differ. The lower bound argument must use a packing with "local" indistinguishability — functions that agree on a large fraction of P_X but differ on ε-measure sets.

Construction: take f_i, f_j that differ only on an ε-measure region (via a sin/const switch in a leaf). Then distinguishing them requires seeing at least one x in that region, which takes Ω(1/ε) samples. This recovers a lower bound of Ω(1/ε) for ε-recovery, matching the parametric case but with a class-size multiplier.

---

## Alternative route: PAC realizability lower bound

For exact recovery (ε = 0, noiseless), use a reduction-based argument:

- Show that any algorithm that recovers f ∈ S with probability 1−δ on n samples must "solve" a hypothesis selection problem over |S| candidates.
- The information-theoretic lower bound for hypothesis selection with |S| = M gives n* = Ω(log M / log(1/δ)) = Ω(s · log|Σ| / log(1/δ)).
- This is the standard VC lower bound for finite classes (Blumer et al.).

For continuous parameter families (leaf constants ∈ R), the class is infinite and VC dimension bounds apply — VC dimension of S(d,s,Σ) with real constants is at least Ω(s) (each real constant is one free parameter), giving n* = Ω(s) by standard VC lower bounds.

---

## Pipeline reuse

| Component | Existing proof in pipeline | Reuse path |
|---|---|---|
| Fano's lemma | xu-raginsky-mi-generalization-bound (proofs/research/learning-theory/generalization/) | Direct — the Fano argument is a sub-step there |
| Hypothesis class packing | ssl-infonce-minimax-lower-bound | Packing construction technique is reusable |
| VC dimension lower bound | catoni-pac-bayes-bound (infrastructure) | Standard VC lower bound argument |
| Separation in L^2(P_X) | ot-contrastive-representation-characterization | Function-space metric tools |

The pipeline has 4 directly relevant proof infrastructure pieces. D2 adds the **combinatorial enumeration of expression trees** as a genuinely new component not previously used.

---

## New mathematical content required

1. **Combinatorial enumeration of S(d, s, Σ)**: counting labeled binary trees of depth ≤ d and size ≤ s with operator labels from Σ. Uses Catalan numbers + generating functions. Analytic combinatorics reference: Flajolet-Sedgewick.

2. **L^2 separation lemma for expression tree perturbations**: showing that replacing one operator in an expression tree creates Δ-separated functions in L^2(P_X). Requires a nontrivial computation depending on input distribution and operator semantics. Can be made rigorous for P_X = Uniform[0,1]^k.

3. **Upper bound matching**: to make D2 complete, an UB showing O(s · log|Σ|) samples suffice (via ERM over S) would complete the picture. This requires a Rademacher complexity or covering-number bound for S.

---

## Empirical verification strategy

1. **PySR**: run PySR on SR tasks with known f ∈ S(d=3, s=10, Σ small); measure empirical recovery rate as a function of n. Predicted: phase transition at n ≈ s · log|Σ| (= ~30 for s=10, |Σ|=4).

2. **gplearn**: symbolic regression via genetic programming. Run on same benchmark. Compare empirical n* to the theoretical lower bound.

3. **Brute-force enumeration**: for tiny d=2, s=5, enumerate all expressions in S explicitly, verify packing construction numerically in Python.
