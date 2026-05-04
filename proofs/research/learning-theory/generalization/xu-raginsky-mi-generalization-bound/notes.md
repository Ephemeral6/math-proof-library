# Notes: Xu–Raginsky MI Generalization Bound (incl. BZV per-sample refinement)

## Proof technique

**Route D won** (39/40), with Route E as runner-up (38/40).

Route D proves the **Bu–Zou–Veeravalli (BZV 2020) per-sample bound first**, then derives Xu–Raginsky 2017 as a corollary. This is the most insightful structure because it makes explicit which steps are lossy relaxations (Jensen on $\sqrt{\cdot}$ and the chain-rule inequality $\sum_i I(W;Z_i) \le I(W;S)$) and characterizes exactly when they are strict.

Core tools: Donsker–Varadhan variational formula (upper bound only) → sub-Gaussian transport lemma → per-sample ghost decomposition → KL joint convexity for the chain-rule direction.

## Key steps

1. **Per-sample ghost decomposition (§1.4).** Write $\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)] = \frac{1}{n}\sum_i (\mathbb{E}_Q[\ell] - \mathbb{E}_{P_i}[\ell])$ where $P_i = \mathbb{P}_{W,Z_i}$ and $Q = \mathbb{P}_W \otimes \mathcal{D}$. Each summand is a difference between the *same* functional integrated against two measures whose KL is $I(W;Z_i)$.

2. **Sub-Gaussian transport (Lemma 2).** $|\mathbb{E}_P[f] - \mathbb{E}_Q[f]| \le \sqrt{2\sigma^2 D_{\mathrm{KL}}(P\|Q)}$. The single-pass proof: apply DV to $\lambda(f-\mathbb{E}_Q f)$ for all $\lambda \in \mathbb{R}$, giving $\lambda\Delta - \lambda^2\sigma^2/2 \le D_{\mathrm{KL}}$; maximize over $\lambda$ (optimizer $\Delta/\sigma^2$) to get $\Delta^2/(2\sigma^2) \le D_{\mathrm{KL}}$.

3. **Chain rule direction (Lemma 3).** The critical inequality is $I(W;Z_i|Z_{1:i-1}) \ge I(W;Z_i)$, which holds because (i) iid forces $\mathbb{P}_{Z_i|Z_{1:i-1}} = \mathcal{D}$ (Ind), and (ii) joint convexity of $(P,Q) \mapsto D_{\mathrm{KL}}(P\|Q)$ + Jensen then gives $\mathbb{E}_{Z_{1:i-1}}[D_{\mathrm{KL}}(\mu_y\|\nu_y)] \ge D_{\mathrm{KL}}(\mathbb{P}_{W,Z_i}\|\mathbb{P}_W\otimes\mathcal{D})$.

4. **BZV → XR corollary.** Jensen on $\sqrt{\cdot}$ (concave) + Lemma 3. Both steps can be strict; strictness characterization in §7 of proof.md.

## Audit result

**PASS, Round 1.** 20/20 atomic claims VALID. 3/3 numerical examples passed (including Example 3, parity function, BZV/gap ratio = 1.02 — very tight). Constants $2\sigma^2$ propagate without slip. Four LOW-severity exposition issues, all resolved in final_proof.md. No mathematical errors.

## Related results

- **Catoni PAC-Bayes bound** (`proofs/research/learning-theory/generalization/catoni-pac-bayes-bound/`): same $\sqrt{\mathrm{KL}/n}$ rate; $I(W;S)$ plays the role of expected-KL-from-prior. The connection: $I(W;S) = \mathbb{E}_S[D_{\mathrm{KL}}(\mathbb{P}_{W|S}\|\mathbb{P}_W)]$, so Xu–Raginsky is the expectation version of PAC-Bayes.

- **DP implies generalization** (`proofs/research/learning-theory/stability/dp-implies-generalization/`): uses the same ghost-sample per-sample decomposition (§1.4); the two proofs share the symmetrization structure; DP controls the per-sample TV divergence instead of the per-sample MI.

- **SGD uniform stability** (`proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/`): stability-based generalization proofs are complementary; MI-based bounds are sharper when information leakage is measurably small (e.g., noisy SGD or DP-SGD), while stability bounds apply in the deterministic/small-stepsize regime.

- **Thompson Sampling** (`proofs/research/learning-theory/generalization/thompson-sampling-bernoulli-regret/`): uses MI chain rule in the information-theoretic regret decomposition; identical chain-rule inequality direction to Lemma 3 here.

- **BZV 2020 paper:** Bu, Zou, Veeravalli, "Tightening Mutual Information-Based Bounds on Generalization Error," IEEE JSAIT 2020. The per-sample bound is the main contribution; Xu–Raginsky follows as a corollary, as replicated here.

- **Negrea et al. 2019:** CMI (conditional MI) bounds using $I(W;Z_i|Z_{1:i-1})$ directly (the conditional per-sample MI, rather than the marginal); this is tighter than BZV in some regimes (uses information revealed about $Z_i$ given past data).

- **Steinke–Zakynthinou 2020:** Supersample / conditional MI framework; uses a ghost sample construction closely related to the per-sample decomposition in §1.4.
