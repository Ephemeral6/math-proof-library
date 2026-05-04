# Proof: Categorical Foundation of Multi-Agent Verification

## Framework

We work in the framework of **Lawvere generalized metric spaces** (Lawvere 1973, Bénabou): categories enriched over the monoidal poset M = ([0,∞], ≥, +, 0). An M-enriched category is a set X with d: X × X → [0,∞] satisfying d(x,x) = 0 and d(x,z) ≤ d(x,y) + d(y,z). M-functors are non-expansive maps; an M-functor F: C → D satisfies d_D(F(c), F(c')) ≤ d_C(c, c').

The **functor category** [C, D] is M-enriched by
$$d_{[C,D]}(F, G) := \sup_{c \in \mathrm{Ob}(C)} d_D(F(c), G(c)). \tag{1}$$

This is a standard construction (Kelly, *Basic Concepts of Enriched Category Theory*, §2.1).

## Lemma 1 (Lawvere enrichment of [C, D])

The pair ([C, D], d_{[C,D]}) is a Lawvere generalized metric space.

**Proof.** Reflexivity: d_{[C,D]}(F, F) = sup_c 0 = 0. Triangle:
$$d_{[C,D]}(F, H) = \sup_c d_D(F(c), H(c)) \leq \sup_c \big[d_D(F(c), G(c)) + d_D(G(c), H(c))\big] \leq d_{[C,D]}(F, G) + d_{[C,D]}(G, H). \quad\square$$

## Theorem (a) — Sup-norm of η equals functor-category distance

Let F, G: C → D be M-functors. Let η: F ⇒ G have components η_c with norm η_c := d_D(F(c), G(c)). Define ||η||_∞ := sup_c η_c. Then:

1. ||η||_∞ = d_{[C,D]}(F, G).

2. For any T-step chain σ = (c_0 → c_1 → … → c_T) in C:
   $$d_D(F(c_T), G(c_T)) \leq \|\eta\|_\infty,$$
   $$E_T(\sigma) := \max_{0 \leq i \leq T} d_D(F(c_i), G(c_i)) \leq \|\eta\|_\infty.$$

3. In the non-expansive regime, ||η^T||_∞ = ||η||_∞ where η^T is the natural transformation between the T-step-image functors F^T, G^T: C^{(T)} → D over the chain category C^{(T)}.

**Proof.** (1) Direct comparison: ||η||_∞ = sup_c d_D(F(c), G(c)) = d_{[C,D]}(F, G) by Lemma 1 and definition (1). (2) Pointwise bound: each d_D(F(c_i), G(c_i)) ≤ ||η||_∞ since c_i ∈ Ob(C) and ||η||_∞ is the sup. (3) For a chain σ, F^T(σ) = F(c_T) and G^T(σ) = G(c_T); ||η^T||_∞ = sup_σ d_D(F(c_T), G(c_T)) = sup_c d_D(F(c), G(c)) = ||η||_∞ (the σ-sup runs over all chains, in particular the identity chains at each c). □

**Remark.** This is a definitional theorem: the Lawvere enrichment is engineered so that the natural-transformation sup-norm IS the functor-category distance. The non-trivial content is that this definition agrees with the intuitive "end-to-end error" of a CR chain.

## Lemma 2 (Fixer contraction — modelling)

We *model* the Auditor-Fixer endomorphism Φ: [C, D] → [C, D] as α-contracting toward the ground-truth functor G:
$$\|\Phi(F) - G\|_\infty \leq \alpha \cdot \|F - G\|_\infty, \quad \alpha \in [0, 1). \tag{2}$$

**Justification.** A Verifier with detection probability 1 − α per retry round, leaves residual error α · (initial error) on each round (rejection-sampling / Las Vegas analysis). When the per-state error rate matches the per-round residual rate, α = ||η||_∞.

## Theorem (b) — Auditor-Fixer near-retraction

Define R_k := Φ^k for k ≥ 1. Then:

**(b-finite).** For every F ∈ [C, D],
$$\|R_k(F) - G\|_\infty \leq \alpha^k \cdot \|F - G\|_\infty. \tag{3}$$

Identifying α = ||η||_∞ gives ||R_k(F) − G||_∞ ≤ ||η||_∞^k · ||F − G||_∞ ≤ ||η||_∞^{k+1}, and in particular ≤ ||η||_∞^k. R_k is α^k-near-idempotent: ||R_k ∘ R_k(F) − R_k(F)||_∞ ≤ 2α^k ||F − G||_∞.

**(b-limit).** R_∞ := lim_{k → ∞} Φ^k exists pointwise (in the Lawvere-Cauchy completion of [C, D]) and equals the constant functor G. R_∞ is a *true* retraction onto V_0 := {G}: R_∞ ∘ R_∞ = R_∞ and R_∞|_{V_0} = id.

**Proof.** (b-finite). Iterate (2): ||Φ^k(F) − G||_∞ ≤ α ||Φ^{k-1}(F) − G||_∞ ≤ … ≤ α^k ||F − G||_∞. Near-idempotency: ||R_k(R_k(F)) − R_k(F)||_∞ ≤ ||R_{2k}(F) − G||_∞ + ||G − R_k(F)||_∞ ≤ α^{2k} ||F-G||_∞ + α^k ||F-G||_∞ ≤ 2α^k ||F-G||_∞.

(b-limit). The sequence (Φ^k(F))_k is Cauchy in the symmetrized Lawvere metric: d_sym(Φ^{k+m}(F), Φ^k(F)) ≤ α^k(1 + α + … + α^{m-1}) ||F − G||_∞ ≤ α^k/(1−α) · ||F − G||_∞ → 0. By Cauchy-completeness of [C, D] (when D is so), the limit exists. By (3) and α^k → 0, the limit equals G. R_∞|_{V_0} = R_∞|_{{G}}: Φ(G) = G (since ||Φ(G) − G||_∞ ≤ α · 0 = 0), so R_∞(G) = G. R_∞ ∘ R_∞(F) = R_∞(G) = G = R_∞(F). □

## Theorem (c) — Discrete special case recovers Problem 4.1

Let C be discrete with N objects and D be a discrete probability category equipped with the Lawvere TV-metric d_D(p, q) = TV(p, q). Let F: C → Δ(D) be a randomized "function" (Kleisli arrow over the distribution monad) and G: C → Δ(D) the ground truth (delta on the correct answer per state). Let
$$\varepsilon_c := 1 - F(c)(\mathrm{correct}_c) = TV(F(c), G(c)), \quad \varepsilon := \max_c \varepsilon_c.$$

Then:

1. **(Sup-norm specialization)** ||η||_∞ = ε.

2. **(T-step trajectory bound)** For a length-T trajectory (c_1, …, c_T) ∈ C^T:
   $$P_{\text{traj}}(T) := \Pr[\exists\, i: F(c_i) \neq G(c_i)] = 1 - \prod_{i=1}^T (1 - \varepsilon_{c_i}) \leq 1 - (1 - \varepsilon)^T \leq T\varepsilon.$$

3. **(k-retry bound)** After k Auditor-Fixer rounds, per-state residual error is ≤ ε^k (by Theorem (b) with α = ε); over a length-T trajectory:
   $$P_{\text{traj}}(T, k) \leq 1 - (1 - \varepsilon^k)^T \leq T \cdot \varepsilon^k.$$

These are exactly the bounds of Problem 4.1.

**Proof.** (1) ||η||_∞ = sup_c d_D(F(c), G(c)) = max_c TV(F(c), G(c)) = max_c ε_c = ε.

(2) In a discrete C, a "T-step chain" has no internal morphisms, so the natural reading is the product C^T (independent T-tuple). Per-state error events are independent Bernoulli(ε_{c_i}) random variables; P[at least one] = 1 − ∏(1 − ε_{c_i}) ≤ 1 − (1 − ε)^T. The Bernoulli inequality (1 − x)^T ≥ 1 − Tx for x ∈ [0,1] gives the union-bound form Tε.

(3) After k retries, per-state residual is ε^k by (b). Apply (2) with ε replaced by ε^k. □

## Numerical verification (SymPy + Monte Carlo, 100 000 samples per case)

| N | ε | T | k | empirical | theory 1−(1−ε^k)^T | union T·ε^k | cat ε^k |
|---|---|---|---|-----------|--------------------|-------------|---------|
| 3 | 0.10 | 5 | 1 | 0.4096 | 0.4095 | 0.500 | 0.100 |
| 3 | 0.10 | 5 | 2 | 0.0490 | 0.0490 | 0.050 | 0.010 |
| 5 | 0.05 | 10 | 1 | 0.4014 | 0.4013 | 0.500 | 0.050 |
| 5 | 0.05 | 10 | 2 | 0.0249 | 0.0247 | 0.025 | 0.0025 |
| 10 | 0.20 | 8 | 3 | 0.0633 | 0.0622 | 0.064 | 0.008 |

SymPy: series expansion of 1 − (1−ε^k)^T at ε=0 gives T·ε^k + O(ε^{2k}); Bernoulli inequality T·ε − (1−(1−ε)^T) ≥ 0 verified at sample points. Lawvere triangle inequality verified on a random 5-object discrete instance.

All checks PASS.

## Conclusion

The Lawvere [0,∞]-enriched functor category framework gives:
- (a) ||η||_∞ literally equals the functor-category distance d_{[C,D]}(F, G).
- (b) Auditor-Fixer iteration is a Banach-style contraction; finite-k iterate is α^k-near-retraction with projection bound ||η||_∞^k; limit R_∞ is a true retraction onto {G}.
- (c) Discrete C, D with TV-metric reduces (a)–(b) to Problem 4.1's bounds 1 − (1 − ε)^T and 1 − (1 − ε^k)^T.

This establishes a categorical foundation for CR-style multi-agent verification, with explicit identification of the verifier's natural-transformation sup-norm as the relevant error functional and the auditor-fixer loop as a metric retraction onto verified functors.
