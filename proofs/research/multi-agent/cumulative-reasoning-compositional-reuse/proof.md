# Proof: Compositionality of Cumulative Reasoning

## Probabilistic model

Probability space (Ω, F, P). For each lemma L_i (i=1,...,m): A_i := {L_i mathematically correct}.

**Hypotheses**:
- H1 (verified errors): P(A_i^c) ≤ δ_{L_i}.
- H2 (independence): {A_1, ..., A_m} mutually independent.
- H3 (sound composition): ⋂_i A_i ⊆ {T correct}.
- H4 (independent retries, for (c)): k auditor-fixer attempts per lemma are mutually independent, each with failure prob ≤ δ.

---

## Part (a): Independence-based product bound

**Theorem 1**. Under H1–H3:
$$P(T \text{ correct}) \ge \prod_{i=1}^m (1 - \delta_{L_i}) \ge 1 - \sum_{i=1}^m \delta_{L_i}.$$

**Proof**.

(i) By H3 and monotonicity of P:
$$P(T \text{ correct}) \ge P\left(\bigcap_{i=1}^m A_i\right).$$

(ii) By H2 (independence) and H1:
$$P\left(\bigcap_i A_i\right) = \prod_i P(A_i) \ge \prod_i (1 - \delta_{L_i}).$$

(iii) Weierstrass product inequality: for x_1,...,x_m ∈ [0,1],
$$\prod_{i=1}^m (1 - x_i) \ge 1 - \sum_{i=1}^m x_i.$$

Proof by induction on m. Base m=1: trivial. Step:
$$\prod_{i=1}^m(1-x_i) = (1-x_m)\prod_{i=1}^{m-1}(1-x_i) \ge (1-x_m)\Big(1 - \sum_{i<m} x_i\Big)$$
$$= 1 - \sum_{i\le m} x_i + x_m \sum_{i<m} x_i \ge 1 - \sum_{i\le m} x_i,$$
since the last term is ≥ 0. Apply with x_i = δ_{L_i} ∈ [0,1]. ∎

---

## Part (b): DAG tree-unfolding bound

**Setup**. The dependency DAG of T has root T at depth d; every internal node has in-degree ≤ Δ. The "tree unfolding" replaces each in-edge by a fresh independent copy. Each instance fails independently with probability ≤ δ. Total node count in the unfolded tree:
$$N(d, \Delta) = \begin{cases} d+1, & \Delta = 1, \\ \dfrac{\Delta^{d+1}-1}{\Delta-1}, & \Delta \ge 2.\end{cases}$$

**Theorem 2**. Under independence of all unfolded instances,
$$P(T \text{ correct}) \ge (1 - \delta)^{N(d, \Delta)}.$$

**Proof by induction on d**.
- Base d=0: T is a leaf, single instance. P(T correct) ≥ 1 - δ. ✓
- Step: T has parents v_1, ..., v_k with k ≤ Δ at depth d-1, each with its own unfolded subtree of N(d-1, Δ) instances. By H3 and independence:
$$P(T \text{ correct}) \ge P(A_T) \prod_{j=1}^k P(\text{subtree of } v_j \text{ all correct})$$
$$\ge (1-\delta) \prod_{j=1}^k (1-\delta)^{N(d-1, \Delta)} = (1-\delta)^{1 + k N(d-1, \Delta)}.$$
Worst case k=Δ gives exponent 1 + Δ N(d-1, Δ) = N(d, Δ). ∎

**Comparison to user's stated bound (1-δ)^{Δ^d}**:

For Δ ≥ 2 and d ≥ 1:
$$N(d, \Delta) = \sum_{t=0}^d \Delta^t \ge \Delta^d.$$

Since (1-δ) ∈ (0, 1) and x → (1-δ)^x is decreasing:
$$(1-\delta)^{N(d, \Delta)} \le (1-\delta)^{\Delta^d}.$$

Therefore the bound (1-δ)^{Δ^d} cannot be obtained directly from this induction; it is a strictly looser (larger) lower bound than what the proof yields. We adopt (1-δ)^{N(d, Δ)} as the formal statement of (b).

The qualitative claim — "exponentially worse than the library-aware bound (1-δ)^d" — is correct: the exponent grows as Σ_{t=0}^d Δ^t = Θ(Δ^d), exponentially in d.

---

## Part (c): Per-lemma retry bound

**Theorem 3**. Under H1, H3, H4 with k independent retries per lemma:
$$P(T \text{ correct}) \ge (1 - \delta^k)^m.$$

**Proof**. Let A_i^{(j)} for j = 1, ..., k denote the event that retry j of lemma L_i succeeds. By H4, A_i^{(1)}, ..., A_i^{(k)} are independent with P((A_i^{(j)})^c) ≤ δ. The Auditor-Fixer accepts L_i iff some attempt succeeds:
$$\{L_i \text{ accepted}\} = \bigcup_{j=1}^k A_i^{(j)}.$$

Therefore
$$P(L_i \text{ fails}) = P\Big(\bigcap_j (A_i^{(j)})^c\Big) = \prod_j P((A_i^{(j)})^c) \le \delta^k.$$

So the per-lemma error after retries is δ' := δ^k. Apply Theorem 1 with δ_{L_i} = δ^k for all i:
$$P(T \text{ correct}) \ge \prod_{i=1}^m (1 - \delta^k) = (1 - \delta^k)^m. \quad\square$$

---

## Comparison: (b) vs (c)

For δ small:
- (b) error budget: ≈ N(d, Δ) · δ = Θ(Δ^d δ).
- (c) error budget: ≈ m δ^k.

For Δ=2, d=5, δ=0.1, k=3, m=63:
- (b) bound: (0.9)^63 ≈ 0.00131.
- (c) bound: (1-0.001)^63 ≈ 0.939.

The (c) bound is ~700× tighter; the gap grows exponentially in k.

This justifies the design principle (P3, library-first reuse): apply Auditor-Fixer **per-lemma** during library construction, not only at the final theorem.

---

## Verified hypotheses (audit findings)

- Weierstrass inequality: symbolic (SymPy) m=2,3,4 expansions; numerical (10000 samples) m ∈ {2,5,10,20}; min margin ≥ 0.
- N(d,Δ) ≥ Δ^d: Z3-style numeric checks for (Δ,d) up to (5,5).
- Inequality direction (1-δ)^{N_T} ≤ (1-δ)^{Δ^d}: confirmed by monotonicity of x^a in a.
- DAG-specific examples: chain, balanced binary tree, complete bipartite layers — all numerically consistent with theory.
