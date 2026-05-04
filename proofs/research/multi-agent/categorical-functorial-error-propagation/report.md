# Final Report — Problem 7.2

**Verdict: PASS** (1 audit round; 1 fixer round for textual clarifications).

## Theorem statements (final)

We work in the framework of **Lawvere generalized metric spaces**: categories enriched over the monoidal poset M = ([0,∞], ≥, +, 0). Equivalently, sets equipped with a (possibly asymmetric, possibly ∞-valued) "distance" satisfying d(x,x) = 0 and triangle inequality. M-functors are exactly *non-expansive maps*. The functor category [C, D] between two M-enriched categories is itself M-enriched, with
$$d_{[C,D]}(F, G) := \sup_{c \in \mathrm{Ob}(C)} d_D(F(c), G(c)).$$

### Theorem (a) — Sup-norm of η equals functor-category distance

Let C, D be Lawvere-metric-enriched categories. Let F, G: C → D be M-functors (non-expansive) and define η: F ⇒ G by its component norms η_c := d_D(F(c), G(c)). Define
$$\|\eta\|_\infty := \sup_{c \in \mathrm{Ob}(C)} d_D(F(c), G(c)).$$
Then
$$\|\eta\|_\infty = d_{[C,D]}(F, G).$$
For any T-step chain σ = (c_0 → c_1 → ... → c_T) in C, the endpoint error satisfies
$$d_D(F(c_T), G(c_T)) \leq \|\eta\|_\infty,$$
and the trajectory error E_T(σ) := max_{0≤i≤T} d_D(F(c_i), G(c_i)) ≤ ||η||_∞.

In particular, in the non-expansive regime ||η^T||_∞ = ||η||_∞ (errors do not grow with T).

### Theorem (b) — Auditor-Fixer near-retraction

Let Φ: [C, D] → [C, D] be the Auditor-Fixer endomorphism, modelled as α-contracting toward G:
$$\|\Phi(F) - G\|_\infty \leq \alpha \cdot \|F - G\|_\infty, \quad \alpha \in [0, 1).$$
Let R_k := Φ^k be the k-fold iterate.

**(b-finite).** R_k satisfies
$$\|R_k(F) - G\|_\infty \leq \alpha^k \cdot \|F - G\|_\infty.$$
Identifying α = ||η||_∞ (per-round residual rate matches per-state error), the projection distance after k retries is bounded by ||η||_∞^k · ||F − G||_∞ ≤ ||η||_∞^{k+1}, and in particular by **||η||_∞^k**. R_k is α^k-near-idempotent: ||R_k ∘ R_k(F) − R_k(F)||_∞ ≤ 2 α^k ||F − G||_∞.

**(b-limit).** R_∞ := lim_{k→∞} Φ^k exists in the Cauchy completion of [C,D] and equals the constant functor G. R_∞ is a true retraction onto V_0 := {G} ⊂ [C,D]: R_∞ ∘ R_∞ = R_∞ and R_∞|_{V_0} = id.

### Theorem (c) — Discrete special case recovers Problem 4.1

When C and D are *discrete* categories (only identity morphisms) and D is equipped with the total-variation metric on Dist(D) extended to F: C → Δ(D), the categorical bounds of (a)–(b) specialize to Problem 4.1's bounds:
- ||η||_∞ = ε := max_c (1 − F(c)(correct_c)) — per-state TV error.
- T-step trajectory error: 1 − (1 − ε)^T ≤ T · ε.
- After k retry rounds: per-state ε^k; trajectory 1 − (1 − ε^k)^T ≤ T · ε^k.

These match the standard CR-chain compounding bound and the verifier-with-k-retries bound of Problem 4.1.

## Proof sketch

**Lemma 1 (Lawvere enrichment of [C, D]).** Triangle: sup_c d_D(F(c), H(c)) ≤ sup_c [d_D(F(c), G(c)) + d_D(G(c), H(c))] ≤ sup d(F,G) + sup d(G,H). Reflexivity trivial. (Kelly, *Basic Concepts of Enriched Category Theory*, §2.1.)

**Theorem (a).** ||η||_∞ = sup_c d_D(F(c), G(c)) = d_{[C,D]}(F, G) by Lemma 1 and definition. The endpoint and trajectory bounds follow by ||η||_∞ being a sup over all c.

**Lemma 2 (Fixer contraction).** Modelling assumption: Verifier detects errors with prob 1−α per round; residual ||Φ(F)−G||_∞ ≤ α · ||F−G||_∞. Standard rejection-sampling.

**Theorem (b).** Iterate Lemma 2: ||Φ^k(F) − G||_∞ ≤ α^k ||F − G||_∞. With α < 1, sequence is Cauchy in symmetrized Lawvere metric, converges to G. R_∞ is a retraction onto {G}.

**Theorem (c).** For discrete C, F is a function; per-state TV-error ε_c. ||η||_∞ = max ε_c. Independence of state-errors gives 1 − (1 − ε)^T for trajectory probability. After k retries, residual rate ε^k per state, giving 1 − (1 − ε^k)^T over T steps. Bernoulli inequality gives the union-bound form T · ε^k.

## Numerical verification (SymPy + Monte Carlo)

Ran in `verify.py` with 100 000 Monte-Carlo samples per case. Results:

| N | ε | T | k | empirical | theory 1−(1−ε^k)^T | union T·ε^k | cat ε^k |
|---|---|---|---|-----------|---------------------|-------------|---------|
| 3 | 0.10 | 5 | 1 | 0.4096 | 0.4095 | 0.500 | 0.100 |
| 3 | 0.10 | 5 | 2 | 0.0490 | 0.0490 | 0.050 | 0.010 |
| 5 | 0.05 | 10 | 1 | 0.4014 | 0.4013 | 0.500 | 0.050 |
| 5 | 0.05 | 10 | 2 | 0.0249 | 0.0247 | 0.025 | 0.0025 |
| 10 | 0.20 | 8 | 3 | 0.0633 | 0.0622 | 0.064 | 0.008 |

Symbolic: SymPy series shows 1 − (1−ε^k)^T = T·ε^k − O(ε^{2k}); union bound T·ε − (1−(1−ε)^T) ≥ 0 verified at sample points (T=5, ε=0.1 → 0.0905; T=10, ε=0.05 → 0.0987).

Lawvere triangle inequality verified on random 5-point instance.

**All checks PASS.**

## Audit summary

- **Round 1 audit**: Lemma 1, Theorems (a)/(b)/(c) all verified. Two textual clarifications flagged (non-expansive regime in (a); retraction terminology in (b)).
- **Round 1 fixer**: applied clarifications.
- **No round 2 needed**: substance was correct.

## Caveats / honest limitations

1. **(b) "retraction" is precise only in the limit k → ∞.** At finite k, R_k is α^k-near-idempotent. The problem statement's ||η||_∞^k bound IS the *projection-distance* bound, which holds at finite k.

2. **Lemma 2 is a modelling assumption.** "Φ is α-contracting" is the standard verifier-rejection-sampling model; it is not derived from C, D structure alone. With this assumption, (b) follows.

3. **(a)'s "F^T" is read as the T-step image functor.** In the non-expansive regime, ||η^T||_∞ = ||η||_∞; in expansive regimes (Lipschitz L > 1), error grows like L^T. The proof flags this regime explicitly. For Markov-kernel Kleisli categories (the natural CR semantics), DPI gives non-expansion automatically.

4. **(c) reduction is exact** in the discrete case; the SymPy + Monte-Carlo agreement is sharp to MC error.

## Verdict

**PASS** with explicit clarifications recorded. The categorical foundation (Lawvere-enriched functor category) provides a clean abstract framework that:
- Makes ||η||_∞ literally the functor-category distance (a).
- Casts the Auditor-Fixer as a Banach-style contraction whose limit is a retraction onto {G} (b).
- Strictly recovers Problem 4.1's bounds 1 − (1 − ε^k)^T as the discrete special case (c).
