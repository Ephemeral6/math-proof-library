# Discovery Report — Agent 8 (SSL Theory)

Five SSL-theory proofs (mostly internal conjectures: Problems 7.1, 7.3, 7.5, 7.8). Three of the five are PARTIAL or had a user-stated form REFUTED, so the discovery paths show the framework's "rescue" pattern in action.

---

## Proof 1 — Spectral Gap and InfoNCE Downstream Bound

### The Spark
**gap-in-literature** — HaoChen 2021 / Tan 2024 reduce InfoNCE to spectral contrastive but never explicitly state the projection-error bound on the InfoNCE optimizer in terms of the augmentation-graph spectral gap δ.

### The Key Insight
The natural Davis–Kahan / sin-Θ machinery is overkill: the spectral contrastive loss is a *quartic polynomial* in F, so you can do the perturbation analysis by hand. The leap is to parameterize F = U_k A + U_⊥ B and **analytically minimize over A at fixed B**, rather than treating both blocks symmetrically. This collapses the quartic into a clean quadratic-growth statement δ‖B‖² because the bare Hessian gives 4δ but the post-A-optimization sharpness is exactly 2δ — a factor only visible after closed-form elimination. Prior knowledge needed: Eckart–Young, basic matrix calculus, and the spectral contrastive surrogate from HaoChen/Tan.

### The Technique Chain
- **Spectral contrastive surrogate (Tan 2024 / HaoChen 2021)** — non-standard but cited as black-box, controls the InfoNCE → spectral reduction with rate η(τ,n,M).
- **Coercivity via SVD + power-mean** — standard convex-analysis trick; gives a-priori bound ‖F*‖_F² ≤ 2n³.
- **Block parameterization F = U_k A + U_⊥ B** — standard sin-Θ-style decomposition, but here used algebraically rather than perturbatively.
- **Analytic A-minimization (closed-form quadratic)** — non-standard step that distinguishes this proof; explicit completing of squares yields the sharpness constant.
- **Quadratic-growth → projection-error inversion** — standard PL-style closure.

### The Construction
N/A (no explicit hard instance constructed; the proof is structural).

### The Failure Modes
- **Direct Davis–Kahan**: a textbook student would invoke sin-Θ on the empirical eigenspaces of W vs. those of F*F*^T. This requires perturbation-norm bounds that have to be re-derived, and gives a worse constant.
- **Bare Hessian bound**: gives 4δ on the B-block, but you over-count because A and B are coupled at the optimum; missing the A-minimization loses the sharp 2δ.
- **Treat InfoNCE directly**: textbook student might try to differentiate the LSE-form InfoNCE; the alignment-uniformity coupling makes Hessian analysis intractable without the spectral surrogate.

### The Discovery Path
1. Notice HaoChen-style proofs give existence of cluster recovery but no quantitative gap-dependent bound on the InfoNCE optimizer's projection error.
2. Try Davis–Kahan; realize you need a perturbation norm you don't have.
3. Realize the spectral contrastive loss is itself a quartic in F — do calculus directly on it. Decompose F into top-k vs. orthogonal blocks.
4. Compute the Hessian; get 4δ. Observe numerically that the actual sharpness in worst-case directions is 2δ. Track down the discrepancy by minimizing analytically over A — the gauge in the top-k block.
5. Patch the boundary case (β² > n²λ) and the small-δ regime by case analysis; verify numerically that worst-direction excess matches 2δ exactly.

### Transferable Patterns
- **"Gauge-fix one block, eliminate analytically"**: when a smooth loss has a flat direction (here the orthogonal rotation in the top-k space), eliminating that direction in closed form often improves the sharpness constant by a factor that bare Hessian analysis cannot see.
- **Black-box reduction + native analysis**: cite the hardest reduction (InfoNCE → spectral) as input, then do the rest from scratch — clean separation of contributions.

---

## Proof 2 — SSL Augmentation Phase Transition

### The Spark
**failure-of-natural-approach** — the conjecture (Problem 7.3) explicitly claimed a *first-order* phase transition in the augmentation strength σ_aug; the natural Gaussian model has a smooth (real-analytic) gap, so the conjecture had to be *refuted* and replaced.

### The Key Insight
For the Dirac-cluster + Gaussian-augmentation model, two Gaussians convolved is again Gaussian with variance τ_eff² = τ² + 2σ_aug²; this single identity reduces the entire kernel matrix to the form (1−ρ)B + ρJ, whose 3-point spectrum is computable by hand. The leap is recognizing that **the regular-simplex cluster geometry collapses K to two-block structure**, allowing closed-form spectrum and exposing that the gap g(σ_aug) = n(1−ρ) is real-analytic — destroying the first-order claim. No prior knowledge beyond Gaussian convolution and elementary linear algebra is required.

### The Technique Chain
- **Gaussian convolution identity** — standard probability tool.
- **Equicorrelated kernel spectrum (1−ρ)I + ρJ pattern** — classical from covariance theory.
- **Block-eigenvector decomposition (constant / between-cluster zero-sum / within-cluster zero-sum)** — standard combinatorial trick, used in stochastic block models.
- **Real-analyticity argument** — used here to *refute* the discontinuity claim, not standard usage.
- **σ_aug · √d ~ Δ_min heuristic** — physics-style scaling argument for the threshold.

### The Construction
The Dirac-on-simplex + isotropic Gaussian augmentation model is chosen because (i) regular simplex makes all pairwise distances equal so K has block-constant off-diagonals, (ii) isotropic Gaussian convolves cleanly. Replace the simplex with arbitrary geometry and the closed form breaks; replace the Gaussian with a heavier-tailed augmentation and τ_eff loses its closed form.

### The Failure Modes
- **Try to prove a first-order transition directly**: a student would look for a non-analytic point of g(σ_aug); none exists in the model, leading to circular failure.
- **Use random-matrix BBP transition**: BBP gives a sharp finite-N transition but it's still second-order in the population parameter, not first-order.
- **Skip the convolution step**: doing the spectrum without τ_eff substitution leaves an n²-by-n² integral nightmare.

### The Discovery Path
1. Read the conjecture: "first-order phase transition with discontinuous gap at some σ_aug*".
2. Set up the natural Gaussian model; compute K explicitly via convolution; get the closed-form spectrum.
3. Observe g(σ_aug) = n(1 − exp(−Δ²/(2d τ_eff²))) — analytic. The first-order claim must be wrong.
4. Verify (a), (b), (d) of the conjecture — these survive. Refute (c) honestly with numerics showing bounded derivative (max 25.88) and 12-config experiment confirming σ_aug ~ Δ/√d with CoV 2.3%.
5. Salvage: state a "second-order" replacement theorem and document where genuine sharpness arises (d → ∞ at fixed SNR).

### Transferable Patterns
- **Conjecture-rescue template**: when the literal statement is wrong, identify which sub-claims survive and which must be weakened. Here (c) was downgraded from "first-order" to "second-order, polynomial decay rate".
- **"Got the scaling right, got the order wrong"**: a common failure mode of physics-style intuition transferred to ML — the Θ(Δ/√d) threshold is correct but doesn't imply discontinuity.

---

## Proof 3 — Matrix Rényi Entropy: Collapse Detection and Gradient-Flow Monotonicity

### The Spark
**analogy-from-other-field** — borrowing Rényi entropy / entropy-PL Lyapunov machinery from classical information theory to diagnose representation collapse on the PSD manifold of contrastive Gram matrices.

### The Key Insight
Parts (a) and (b) are **textbook material in disguise**: spectral reduction maps S_α(K) onto classical Rényi entropy on the simplex, and the rest is x^α-vs-x crossings (a) and Jensen on x ↦ x^α (b). The genuine non-obvious step is in Part (c): writing dS_α/dt as -(2/τ)⟨R(K)F, ∇_F L⟩ where R(K) := ∇_K S_α − (α/(1−α))I is the **trace-free part** of the gradient. The trace-free correction is what makes the entropy-PL inequality G(K) ≤ c_α(ε) ‖R(K) K^{1/2}‖² hold with leading constant 1/(2α).

### The Technique Chain
- **Spectral functional calculus on PSD matrices** — standard.
- **Jensen on x^α** — undergraduate-textbook standard.
- **Frobenius gradient of tr(K^α)** — standard matrix calculus.
- **Trace-free projection R(K)** — non-standard adaptation; analogous to gradient-on-the-sphere projections.
- **Local Taylor expansion around δ_i = 0** — standard, but the matching coefficients (α/(2n) for G, α²/n for the gradient norm) make the PL constant exact at leading order.
- **Polyak–Łojasiewicz framework** — standard from non-convex optimization.

### The Construction
N/A — not a construction problem; the loss L_BT(F) = ½‖K(F) − I/n‖_F² is offered as a *concrete example* satisfying (H1)–(H3), not as an adversarial instance.

### The Failure Modes
- **Try to compute dS_α/dt naively**: student forgets that K(F) = FF^T/τ has the trace-normalization, drops the −(2⟨F,H⟩/τ)K term in dK[H], and gets a wrong gradient.
- **Forget the trace-free projection**: writing dS_α/dt with bare ∇_K S_α gives the wrong sign in some directions; the (α/(1−α))I correction is essential.
- **Try a global PL constant**: the entropy-PL inequality holds only on a neighborhood of K = I/n; a textbook student would attempt a global statement and fail.

### The Discovery Path
1. Question: how does standard collapse-detection metric (Rényi entropy of the Gram matrix) behave under SSL gradient flow?
2. Compute the time derivative of S_α(K(F)) along F flowing under L; messy chain rule.
3. Notice that ∇_K S_α has a "constant component" (α/(1−α))I that cancels via tr(dK · I) = d tr(K) = 0; subtract it explicitly to get R(K).
4. Compute Taylor expansions of G(K) and ‖R K^{1/2}‖² near K = I/n; observe both are O(‖δ‖²) with ratio 1/(2α). This is the entropy-PL inequality.
5. Verify with NumPy on n=4: 0 monotonicity violations across α ∈ {0.5, 2, 3}, 199 steps; Z3 verifies the polynomial PL inequality at α=2 on |δ| ≤ 1/2.

### Transferable Patterns
- **Trace-free projection trick** for any gradient flow on a constrained manifold (here tr(K) = 1): subtract the part of the gradient that lives in the constraint's normal direction.
- **Entropy-PL near maximum-entropy states**: a generic recipe for non-convex Lyapunov analysis — local Taylor expansions of (max-value − functional) and (gradient-norm)² often have matched leading orders, giving an automatic PL constant.

---

## Proof 4 — SSL InfoNCE Minimax Downstream Lower Bound

### The Spark
**failure-of-natural-approach** — initial routes (Routes 1–3) all hit a d/(n·I) ceiling; numerical experiments showed the empirical rate is d²/(n·I), forcing a redesign that distinguishes joint adversary from sup over w* alone.

### The Key Insight
The d² rate doesn't come from sup over w* (which only buys you a single d-factor), nor from sup over f* alone. It comes from packing the **orthogonal group SO(d)** which has Riemannian dimension d(d−1)/2 ≍ d², giving log M ≍ d² log(1/δ) packing entries. Then choosing a worst-case w* aligned with the rotated representation amplifies the packing separation δ² by an extra d. The leap is recognizing that the Yang–Barron metric-entropy lower bound on SO(d), combined with a Schur-complement amplification trick on the linear-probe gap, simultaneously delivers both factors of d.

### The Technique Chain
- **σ-link to squared-loss reduction** — elementary; uses σ'(z) ≥ 1/4 on [−1,1].
- **Schur complement of the optimal-probe gap** — standard from linear regression / minimax estimation.
- **Data Processing Inequality + chain rule for MI** — Yang–Barron / Tsybakov machinery, standard.
- **Metric-entropy packing of SO(d)** — standard but the choice of SO(d) (vs. unit sphere or hypercube) is the crucial design choice.
- **Fano's inequality** — textbook.
- **Hypothesis-testing reduction** — Le Cam / Tsybakov standard.

### The Construction
The hard-instance family is f*_V(x) = V·ψ(x) for V ∈ δ-packing of SO(d), with worst-case w*_V = √d · V·e_1. The orthogonal-group construction is forced by needing log M = Θ(d²): the unit sphere only gives d log(1/δ), and the hypercube gives 2^d (too much, but at the wrong scale). The √d factor in w*_V is the **maximum norm** under the ‖w*‖² ≤ d constraint, and aligning it with V·e_1 ensures the Schur-complement gap λ_max(Δ) gets multiplied by ‖w*‖² rather than averaged.

### The Failure Modes
- **Sup over w* with fixed f***: gives only d/(n·I); textbook student would stop here, miss the d² rate.
- **Use the unit sphere as the f*-packing**: log M = Θ(d log(1/δ)), one factor of d short.
- **Forget the σ-link constant**: students might bound the σ-loss directly and lose the 1/16 reduction.
- **Use Pinsker instead of Fano**: Pinsker gives looser constants and doesn't naturally accommodate the packing structure.

### The Discovery Path
1. Conjecture: minimax downstream risk ≥ d²/(n · I(X;X'|A)).
2. Try standard Le Cam / 2-point lower bound; gets d/(n·I), one d short.
3. Numerical sims: empirical rate is d², not d. Re-examine.
4. Realize: the conjecture's "sup over w*" should be read as joint sup over (f*, w*); pack SO(d) for the f* component (gives d² factor in log M), align worst-case w* for the extra d-amplification.
5. Run Fano; verify Schur-complement gives G ≥ d · δ² when V ≠ V̂; pick δ² = c·d/(n·I); land at d²/(n·I) up to logs. Honestly state that closing the log gap requires Assouad (not attempted).

### Transferable Patterns
- **"Joint adversary" rescue pattern**: when single-component sup gives the wrong rate, the joint sup over multiple parameters can deliver the correct power of d via metric entropy of a richer space (here SO(d)).
- **Choose the right packing space**: dimensional analysis on log M tells you whether to pack a sphere, an orthogonal group, or a hypercube. Match log M to the desired rate of d.

---

## Proof 5 — OT-Contrastive Representation Characterization

### The Spark
**failure-of-natural-approach** — the literal conjecture (argmin L_spec = argmin J_OT, with z_c = rows of U_k) is REFUTED by an explicit 4-vertex counterexample with one inter-cluster edge of weight ε = 0.3.

### The Key Insight
The conjecture is true under block-diagonal W + regular blocks + uniform prior, and false otherwise. The leap is to recognize **three** simultaneous hypotheses needed: (H1) block-diagonal W, (H2) spectral gap, (H3) regular blocks + uniform prior. Each removes a different obstruction: H1 makes A_tilde block-diagonal so Perron–Frobenius applies per block; H2 picks out exactly the cluster eigenvectors; H3 makes the Perron eigenvectors uniform within each cluster, which is what forces F^{spec}_x to depend only on c(x). Without H3, the F^{spec} varies within a cluster and J_OT > 0.

### The Technique Chain
- **Brenier identity for OT to a Dirac** — elementary (one transport plan exists); reduces OT to within-cluster variance.
- **HaoChen et al. (2021) spectral contrastive identity** — cited; L_spec(f) = ‖A_tilde − F̄F̄^T‖_F² + const.
- **Eckart–Young theorem** — textbook; gives the rank-k optimal F̄.
- **Perron–Frobenius per block** — standard; needed because each block has a positive top eigenvector.
- **Explicit numerical counterexample** — non-standard discovery technique; the counterexample is deliberately designed to break H1.

### The Construction
The counterexample is W on n=4 vertices: two cliques connected by a single weight-0.3 cross edge. This minimal structure breaks H1 while keeping H2 and H3, isolating exactly the failure mode. Smaller ε would weaken the counterexample; W non-symmetric or with ε = 0 would not exhibit the failure.

### The Failure Modes
- **Try to prove the literal conjecture**: a textbook student equating L_spec and J_OT minima generically would fail because rotation invariance of L_spec doesn't preserve cluster-constancy of F̄.
- **Forget the prior weighting (H3)**: even with block-diagonal W, if priors are not constant within clusters, F^{spec} varies within a cluster and J_OT > 0.
- **Use Davis–Kahan for the perturbation analysis**: would give a quantitative version but doesn't reveal the qualitative *non-equivalence* without H1.

### The Discovery Path
1. Conjecture: spectral contrastive minimizers are exactly the OT-clustering minimizers with z_c = rows of U_k.
2. Try to prove it directly via Eckart–Young + Brenier; immediately notice the dimensional ambiguity ("rows of U_k" is not well-defined when |C_c| > 1).
3. Realize the equality holds only when U_k is constant on each cluster — this requires Perron eigenvectors to be uniform, i.e., regular blocks + uniform prior + block-diagonal W.
4. Construct a deliberate counterexample: 2-clique graph with one cross edge ε=0.3, compute spectral and cluster-constant solutions, verify L_spec(F^{spec}) = 1.26 < 1.93 = L_spec(F^{alt}) and J_OT(F^{spec}) = 0.65 > 0 = J_OT(F^{alt}).
5. State the refined theorem with explicit (H1)–(H3); verify numerically on n=6 (J_OT = 6.6e−32) and symbolically on n=4.

### Transferable Patterns
- **"Almost-true under hidden hypotheses"**: when an SSL-theory conjecture has a clean intuitive form, the right move is to (i) find the minimal hypothesis set that makes it true, (ii) construct an explicit minimal counterexample for the hypothesis-removal direction.
- **Z3 + SymPy + NumPy three-tier verification**: symbolic for exact identities, Z3 for polynomial inequalities, NumPy for the counterexample. This stack appears across multiple proofs in the SSL set.

---

## Cross-cutting observation

Three of the five proofs (augmentation phase transition, OT-contrastive, InfoNCE minimax) are PARTIAL with REFUTED literal claims. The discovery pattern in all three is the same **"conjecture rescue"** template: numerical or analytic experimentation reveals the literal claim is false, the framework identifies *which dimensional or qualitative feature* the conjecture got right, then re-states a weakened theorem under explicit hypotheses. This is genuinely different from the textbook-paper discovery path, which presents only successful theorems — the SSL set documents the *failure-and-salvage trajectory* explicitly. The InfoNCE minimax case is particularly instructive: numerical experiments showed d² when initial proof routes only delivered d, forcing redesign of the adversary structure (SO(d) packing instead of unit sphere).

---

**Summary**
- File written: `C:\Users\12729\Desktop\Math\workspace\discovery_reports\agent_8.md`
- Proofs analyzed: 5 (spectral-gap-infonce-downstream, ssl-augmentation-phase-transition, matrix-renyi-collapse-detection, ssl-infonce-minimax-lower-bound, ot-contrastive-representation-characterization)
- Most interesting cross-cutting observation: 3/5 SSL conjectures had their literal form REFUTED and were "rescued" by the framework via explicit hypothesis-tightening — a discovery trajectory invisible in textbook-paper proofs but central to autonomous-conjecture-generation pipelines.
