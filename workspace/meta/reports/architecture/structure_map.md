# Cross-Problem Structure Map

> Graph of structural relationships between research-level proofs in this library.
>
> Used by the Explorer's Reduction frame: before attempting a domain translation
> (e.g., "this online learning problem looks like a stochastic optimization problem"),
> consult this map for ANALOGY links. The isomorphism description tells you the exact
> mapping to use.
>
> Also useful for: identifying duals (UB ↔ LB pairs), tracking generalization chains,
> and seeing which proofs depend on which.
>
> Confidence legend: HIGH = explicit text in the proofs/discovery reports supports
> the link; MEDIUM = inferred from discovery reports; LOW = plausible but not directly
> evidenced.

---

## Cluster A: SHB Lower Bounds Family

All four SHB lower-bound proofs (restricted, cycling-threshold, interpolation, best-iterate) plus the rescue/contradiction proof (Polyak-Ruppert) and the unrelated divergence proof (heavy-ball-instability) revolve around variants of the Goujaud–Taylor–Dieuleveut 2023 polytope-Moreau hard instance and the question "when does cycling persist / when can it be defeated?"

Members and short paths:
- A1 = `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/`
- A2 = `proofs/research/optimization/lower-bounds/shb-cycling-critical-momentum/`
- A3 = `proofs/research/optimization/lower-bounds/shb-interpolation-regime-lb/`
- A4 = `proofs/research/optimization/lower-bounds/shb-no-acceleration-best-iterate/`
- A5 = `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/`
- A6 = `proofs/research/optimization/convergence/heavy-ball-instability/`

### Structure Link: A1, A2, A3, A4 (4-way SAME_TEMPLATE)

**Members**: shb-no-acceleration-restricted, shb-cycling-critical-momentum, shb-interpolation-regime-lb, shb-no-acceleration-best-iterate.

**Relationship Type**: SAME_TEMPLATE

**What transfers**: All four are evolutionary variants of the *same* 2-D Goujaud K-gon hard instance built from the polytope-Moreau function ψ(x) = (L/2)‖x‖² − ((L−μ)/2) d²_{conv(P)}(x). The shared chassis is: (i) spatial rescaling f₀(x) = D²ψ(x/D); (ii) coordinate decoupling ℝ² ⊕ ℝ where the bias term lives on the cycling 2-D subspace and any noise term lives on an orthogonal 1-D wall; (iii) Le Cam two-point + Pinsker for the variance contribution; (iv) strong-convexity floor f − f* ≥ (μ/2)‖x − x*‖² to convert "stuck at K-gon vertex" into a function-value gap. To reuse: copy ψ, choose K, plug in the variant's specific noise / iterate-type assumption, run the same Le Cam test with the iterate-specific sign-extraction.

**Confidence**: HIGH — Agent 5 report explicitly states "The 4 SHB lower-bound proofs are evolutionary variants of the same hard instance — the Goujaud polytope-Moreau function ψ".

---

### Structure Link: A1 (`shb-no-acceleration-restricted`) ↔ A2 (`shb-cycling-critical-momentum`)

**Relationship Type**: SHARPENING

**What transfers**: A1 introduces the algebraic feasibility region 𝓕 (where the GPT cycling identity holds) but treats the boundary heuristically. A2 sharpens this by deriving the closed-form quadratic Q_K(β) = β² + 2(1−c_K)β − 1 via the polynomial factorization (1+c_K)·Q_K(β), exposing that all c_K-dependence collapses into the single coefficient (1−c_K). Result: the critical momentum threshold is exactly β* = (√13 − 3)/2, attained at K=3 (which minimizes 1−c_K among K ≥ 3). A2's threshold *defines* the inner boundary of A1's 𝓕.

**Confidence**: HIGH — A2 is documented as the "companion to OP-2" in the index, and Agent 5 reports A2 was discovered while computing the cycling feasibility region for A1.

---

### Structure Link: A1 (`shb-no-acceleration-restricted`) ↔ A3 (`shb-interpolation-regime-lb`)

**Relationship Type**: GENERALIZATION (with PARTIAL REFUTATION on the variance side)

**What transfers**: A3 keeps A1's bias half (the deterministic Goujaud cycling argument transfers verbatim — a noiseless oracle is admissible since 0 ≤ σ²ρ(0)) but *refutes* the variance half: under interpolation noise ρ(0)=0, the explicit quadratic counterexample (L/2)‖x‖² with multiplicative noise σ‖x_t‖ε_t achieves second-moment contraction with rate (1+σ²/L²)/4 < 1, exponentially beating any polynomial Ω(σD/√T) floor. The link teaches: when extending an LB to a noise sub-class containing the noiseless oracle, the deterministic part transfers automatically; the stochastic part needs algorithm-existential refutation.

**Confidence**: HIGH — explicit in Agent 5 description of A3.

---

### Structure Link: A1 (`shb-no-acceleration-restricted`) ↔ A4 (`shb-no-acceleration-best-iterate`)

**Relationship Type**: GENERALIZATION (with PARTIAL REFUTATION on the variance side)

**What transfers**: A4 inherits A1's bias bound for free because the Goujaud cycle is *uniform* — every iterate has identical distance D/√2 to the optimum, so min_t f(x_t) = f(x_t) and the bias bound transfers with the same constant. The variance bound *fails*: the Le Cam test ŝ = −sign(y_T) used in A1 cannot be replaced by ŝ = −sign(y_{t*}) for t* = argmin, because y_{t*} is the iterate closest to the wall optimum and the test classification error → 0, voiding Le Cam. The link encodes "min-vs-last asymmetry" as an iteration-type distinction.

**Confidence**: HIGH — explicit in Agent 5 description of A4.

---

### Structure Link: A3 (`shb-interpolation-regime-lb`) ↔ A4 (`shb-no-acceleration-best-iterate`)

**Relationship Type**: SAME_TEMPLATE (algorithm-existential refutation pattern)

**What transfers**: Both proofs share the meta-pattern "deterministic bias half survives; stochastic variance half is refuted by exhibiting one explicit algorithm/instance achieving sub-floor rates." A3 exhibits a quadratic + multiplicative-noise instance with exponential decay; A4 exhibits the OP-2 wall instance simulated to T=1000 showing T⁻² best-iterate decay. The shared technique is "algorithm-existential refutation": kill a putative universal LB by displaying ONE achievable trajectory.

**Confidence**: HIGH — both Agent 5 sections explicitly identify "algorithm-existential refutation" as the transferable pattern.

---

### Structure Link: A1+A2+A3+A4 ↔ A5 (`polyak-ruppert-shb-defeats-cycling`)

**Relationship Type**: CONTRADICTS (downgrade of OP-2)

**What transfers**: A5 *disproves* a putative Ω(LD²/T) Polyak-Ruppert lower bound on Goujaud's hard instance by exhibiting an O(LD²/T²) achievable rate. The proof complexifies ℝ² ≅ ℂ via e_t ↔ ω^t with ω = e^{2πi/K}, then uses the closed-form arithmetico-geometric sum |∑t ω^t| = O(T) against the linear-weight denominator W_T = Θ(T²), giving ‖x̃_T‖ = O(1/T) and f(x̃_T) − f* = O(LD²/T²). This is a strict contradiction with any "linear-weighted-averaging cannot escape OP-2's K-gon cycle" reading. The Goujaud hard instance is shared with A1–A4, but the iterate type (Polyak-Ruppert weighted average vs. last/best) flips the conclusion.

**Confidence**: HIGH — RESEARCH_INDEX.md explicitly tags A5 as "disproof of Ω(1/T) LB" and Agent 2 documents the closed-form complex-exponential argument.

---

### Structure Link: A5 (`polyak-ruppert-shb-defeats-cycling`) ↔ A4 (`shb-no-acceleration-best-iterate`)

**Relationship Type**: SAME_TEMPLATE (iteration-type asymmetry)

**What transfers**: Both proofs instantiate the meta-principle "lower bounds for one iterate type need not transfer to other iterate types." A4: best iterate beats the variance LB on the noise-coordinate wall. A5: PR-averaged iterate beats the bias LB on the K-gon cycle. The shared lesson — different iterate types (last, best, Cesaro, PR-weighted) must be analyzed independently — appears in both reports and matches the Discovery Taxonomy entry "Iteration-type asymmetry" (4 instances).

**Confidence**: HIGH — Agent 2's "iterate-type-matters principle" maps directly onto Agent 5's "min-vs-last asymmetry."

---

### Structure Link: A1–A4 (Goujaud cycling cluster) ↔ A6 (`heavy-ball-instability`)

**Relationship Type**: ANALOGY (counterexample-construction archetype)

**What transfers**: Both lines of work use *constructive* hard instances to refute "Heavy Ball / SHB converges as nicely as people thought." A6 constructs f(x) = (L/2)x² − (L−μ) ln cosh(x), with f''(0)=μ and f''(∞)=L, forcing Heavy Ball into a stable period-4 cycle. A1–A4 construct the 2-D Goujaud K-gon polytope-Moreau function. Both fall under "Construct hard instance via adversarial polytope or sign-rotational geometry" (Section 2(c) #6 of the master report). Both also share the failure-mode lesson: any quadratic Lyapunov V_k = a‖x_k − x*‖² + b‖x_k − x_{k-1}‖² is doomed (Lessard–Recht–Packard IQC analysis is invoked in A6; for A1–A4 the obstruction takes the form "no Lyapunov can certify a contraction at the period-K cycle").

**Isomorphism description**: f's two-curvature structure (μ at center, L at infinity) ↔ Goujaud polytope's two-region structure (interior gradient field vs. cycling vertex map); Heavy-Ball period-4 limit cycle on f ↔ SHB K-gon cycle on Goujaud ψ; ln cosh "soft step" smoothing ↔ Moreau-envelope smoothing of indicator d²_{conv(P)}.

**Confidence**: MEDIUM — both proofs explicitly use period-K limit cycles, but the "ln cosh ↔ Moreau-conv" correspondence is inferred, not stated.

---

## Cluster B: Stability / Hardt-Recht-Singer Derivatives

Members:
- B1 = `proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/` (HRS founder)
- B2 = `proofs/research/learning-theory/stability/dp-implies-generalization/`
- B3 = `proofs/research/learning-theory/stability/sgd-signal-noise-generalization-decomposition/`
- B4 = `proofs/research/learning-theory/stability/adversarial-trajectory-tradeoff/`
- B5 = `proofs/research/learning-theory/stability/heavy-tailed-trajectory-decomposition/`

### Structure Link: B3 (`sgd-signal-noise-generalization-decomposition`) DEPENDS B1 (`sgd-uniform-stability-generalization`)

**Relationship Type**: DEPENDS / SHARPENING

**What transfers**: B3 reuses HRS's coupling-and-track-distance chassis verbatim, then *pushes the gradient decomposition ∇ℓ = ∇L_S + ∇L_N (signal + zero-mean noise) inside the per-step recursion*. The signal part annihilates by exactly the same non-expansiveness HRS used (I − η∇L_S is non-expansive via co-coercivity); only the noise part η(∇L_N − ∇L_N') perturbs the trajectory. This converts HRS's L²-bound into a (G_S² + σ_N²)-bound — strict improvement when σ_N ≪ L. To reuse: take any HRS-style proof, identify the per-step gradient and split it into deterministic + zero-mean parts; the deterministic part inherits non-expansiveness, the noise part contributes variance instead of supremum.

**Confidence**: HIGH — Agent 9 explicitly states "Push the decomposition inside the recursion" as the transferable pattern, and B3 cites HRS as scaffold.

---

### Structure Link: B4 (`adversarial-trajectory-tradeoff`) DEPENDS B3 (`sgd-signal-noise-generalization-decomposition`)

**Relationship Type**: DEPENDS

**What transfers**: B4 inherits B3's signal-noise trajectory framework (specifically the parameter-motion bound ‖θ_T − θ_0‖ ≤ G√(Tη)) and adds two new ingredients: (a) the mixed Hessian H = sup ‖∇_θ∇_x L‖_op as a *bridge* between parameter-space and data-space Lipschitz analyses; (b) the argmin-shift lemma (any strictly-increasing penalty added to a U-shaped curve shifts the optimal stopping time strictly inward). B4 cannot be derived without B3's trajectory-length bound; the "data-gradient growth" claim r·‖∇_x L‖ × √(Tη) is a direct composition.

**Confidence**: HIGH — B4's report explicitly cites the signal-noise trajectory framework (Zhang et al. 2022 ICLR) as input.

---

### Structure Link: B5 (`heavy-tailed-trajectory-decomposition`) DEPENDS B1 (`sgd-uniform-stability-generalization`) + B3

**Relationship Type**: DEPENDS / GENERALIZATION

**What transfers**: B5 generalizes HRS+B3 from L²-moment recursions to L^p-moment recursions for p ∈ (1,2). It (i) raises the HRS distance recursion to the p-th power using (a+b)^p ≤ 2^{p-1}(a^p + b^p), which works because HRS's underlying contractivity is at the *norm* level not the squared-norm level; (ii) replaces classical BDG (variance-based) by Marcinkiewicz-Zygmund / one-sided Burkholder for p ∈ (1,2); (iii) introduces gradient clipping at τ = G·T^{1/p − 1/2} balancing truncation bias G^p/τ^{p-1} against truncated variance G^p τ^{2-p}. The signal/noise split from B3 still applies inside the L^p framework.

**Confidence**: HIGH — Agent 9's transferable-patterns section names "Moment-level coupling: lift any L² recursion to L^p" as the explicit reuse mechanism.

---

### Structure Link: B2 (`dp-implies-generalization`) ↔ B1 (`sgd-uniform-stability-generalization`)

**Relationship Type**: ANALOGY

**What transfers**: B2 is a translation theorem from differential privacy to stability. The (ε,δ) DP guarantee on neighboring datasets is *structurally identical* to the algorithmic-stability requirement from Bousquet-Elisseeff/HRS. Hockey-stick decomposition dμ = min(dμ, e^ε dν) + (dμ − e^ε dν)_+ splits a DP guarantee into a "bounded-likelihood-ratio" piece (controlled by e^ε) and a "rare-leakage" piece (controlled by δ); leave-one-out symmetrization (Bousquet-Elisseeff scaffold reused from B1) immediately gives a generalization bound. To reuse: any algorithm whose output distribution is close in any divergence (TV, KL, Rényi, hockey-stick) on neighboring datasets generalizes by the same template.

**Isomorphism description**: parameter-distance ‖w − w'‖ in B1 ↔ divergence D(P_S ‖ P_{S'}) in B2; co-coercivity (operator non-expansive) in B1 ↔ post-processing closure (divergence non-expansive) in B2; Lipschitz transfer of distance to loss in B1 ↔ DP guarantee on bounded test functions in B2; (n−1)/n shared-randomness step in B1 ↔ the hockey-stick "bounded ratio" piece in B2.

**Confidence**: HIGH — Agent 9's report names "Divergence-based stability is divergence-agnostic" as the explicit transfer principle.

---

### Structure Link: B4 (`adversarial-trajectory-tradeoff`) ↔ B5 (`heavy-tailed-trajectory-decomposition`)

**Relationship Type**: SAME_TEMPLATE (chassis-extension pattern)

**What transfers**: Both proofs demonstrate the *portability* of the HRS coupling chassis: it can absorb structurally novel ingredients without changing its (n−1)/n shared-randomness vs 1/n shock decomposition. B4 absorbs the mixed-Hessian bridge to data-space; B5 absorbs L^p lifting + Marcinkiewicz-Zygmund. The shared discovery pattern is "find the new ingredient that the chassis is missing, plug it into the existing per-step recursion, recover a clean rate." Both share parameter-motion bound ‖θ_T − θ_0‖ = O(√(Tη)) as a structural sub-result.

**Confidence**: HIGH — Agent 9's cross-cutting observation explicitly states "The chassis can absorb entirely new ingredients … without changing the underlying (n−1)/n non-expansive vs 1/n shock decomposition."

---

### Structure Link: B1, B2, B3, B4, B5 (5-way SAME_TEMPLATE — phylogeny)

**Members**: All five HRS-derivative stability proofs.

**Relationship Type**: SAME_TEMPLATE

**What transfers**: All five proofs instantiate the master template "couple-and-track-distance under shared randomness." HRS supplies the chassis (B1); per-sample gradient split goes inside (B3); chassis is portable to data-space adversarial (B4) and to L^p heavy-tail moments (B5); chassis is even *abstractly portable* to any divergence-based notion of "neighboring dataset" (B2). The Discovery Taxonomy lists 8 such "couple-and-track" proofs across the entire library; this cluster is the densest occurrence.

**Confidence**: HIGH — Agent 9 dedicates a paragraph of the cross-cutting observation to this phylogeny; the master report's Insight 4 names this cluster as one of the canonical recipes.

---

## Cluster C: Cancellation Pair Family (MT1)

Master template (MT1): "Write the same quantity two ways then cancel — one identity, one inequality, with one cross-term canceling." This is the dominant meta-strategy in the library (~26% of all proofs; 18 instances across the corpus). The cluster below collects the high-confidence instances.

Members:
- C1 = `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/`
- C2 = `proofs/research/optimization/convergence/sam-convergence-flat-minima/`
- C3 = `proofs/research/optimization/convergence/synchronous-q-learning-finite-time/`
- C4 = `proofs/research/optimization/convergence/ogda-bilinear-last-iterate/`
- C5 = `proofs/research/optimization/convergence/entropy-regularized-value-iteration/`
- C6 = `proofs/research/optimization/convergence/entropy-regularized-npg-linear-convergence-variant/`
- C7 = `proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/`

### Structure Link: C1, C2, C3, C4, C5, C6, C7 (7-way SAME_TEMPLATE — Cancellation Pair)

**Members**: All seven listed cancellation-pair proofs.

**Relationship Type**: SAME_TEMPLATE

**What transfers**: The abstract template, instantiated per proof:
- **C1 (NPG softmax)**: Bregman 3-pt identity gives `−KL(π_{k+1}‖π_k)`; Donsker-Varadhan / Hoeffding gives `+KL(π_{k+1}‖π_k)`. The two KL terms cancel.
- **C2 (SAM)**: Descent lemma gives a `+⟨∇f^SAM, g⟩` cross term; Danskin's theorem + L-smoothness give the bound `‖g_t − ∇f^SAM‖ ≤ 2Lρ`. Young's inequality on the cross term, balanced against the bias bound, makes the deviation absorb cleanly into the O(L/T) + O(L²ρ²) two-term structure.
- **C3 (Synchronous Q-learning)**: Linearization Δ_t = L_t + R_t — the deterministic-but-nonlinear residual R_t cancels with the random-but-linear L_t in the recursion: L_t carries the MDS structure (clean Azuma), R_t carries the contraction (deterministic coupling).
- **C4 (OGDA bilinear)**: Skew-symmetry ⟨z, F(z)⟩ = 0 + linearity F(z_t) − F(z_{t-1}) = F(δ_t) gives identity (E): ‖z_{t+1}‖² = ‖z_t‖² + ‖δ_{t+1} − δ_t‖² − ‖δ_t‖². The cross term ⟨z_t, F(δ_t)⟩ that would normally need Young's instead vanishes via skew-symmetry.
- **C5 (Entropy-reg VI)**: The 1/τ scaling inside LSE pairs with the τ outside; the entropy-regularization "perturbation" cancels in the contraction modulus, leaving γ unchanged.
- **C6 (Entropy-reg NPG variant)**: The state-only normalizer term G^(k)(s) in the log-policy recursion cancels exactly when one chooses the gauge-invariant centered seminorm ‖ξ‖_c = ½ sup_s (max_a ξ − min_a ξ), because state-constants commute with the simplex marginalization in both π and π*.
- **C7 (Softmax PG)**: Sign-robust Cauchy-Schwarz on *squared* advantages — applying CS to squared quantities sidesteps pointwise sign control; the would-be cancellation problem (some advantages are negative) is converted into an aggregate non-negativity statement that closes the recursion.

**The unifying abstract pattern**: identify a quantity φ that the natural identity produces with a "−φ" sign and the natural inequality produces with a "+φ" sign; the proof works by combining them so the φ-terms cancel, leaving a clean telescoping inequality. Discovery procedure: (i) look for a Bregman/three-point/skew-symmetry identity that produces some structural term; (ii) look for a concentration/Young's/Danskin-style inequality that produces the *same* term with opposite sign; (iii) combine and cancel. Antipattern: invoking Young's inequality before checking for cancellation discards exactly the structure that closes the proof.

**Confidence**: HIGH — Agent 1's cross-cutting observation (5/7 proofs) and Agent 2's cross-cutting observation (5/8 proofs) independently identify this pattern; master report Insight 1 names it as the dominant meta-strategy.

---

### Structure Link: C1 (`npg-softmax-tabular-convergence`) ↔ C6 (`entropy-regularized-npg-linear-convergence-variant`)

**Relationship Type**: SHARPENING (with HONEST DOWNGRADE)

**What transfers**: C6 is the gauge-invariant honest version of C1's mirror-descent style analysis under entropy regularization. C1 cancels KL terms between Bregman 3-pt and DV; C6 must additionally handle the log-policy *gauge orbit* (state-constants), which it does by replacing ‖log π − log π*‖_∞ with the centered seminorm ‖·‖_c. C6 honestly proves the rate (1 − ητ(1−γ)) instead of the originally claimed (1 − ητ), documenting that the Cen et al. constant is fragile to gauge choice. Anyone reusing C1 in entropy-regularized settings should adopt C6's gauge-invariant norm.

**Confidence**: HIGH — Agent 2 explicitly documents the gauge-invariance principle as the link.

---

### Structure Link: C5 (`entropy-regularized-value-iteration`) ↔ C6 (`entropy-regularized-npg-linear-convergence-variant`)

**Relationship Type**: ANALOGY (entropy-regularization preservation)

**What transfers**: Both proofs hinge on the principle "smooth-max regularization preserves contraction modulus." C5 shows LSE is exactly 1-Lipschitz in ℓ∞ and the τ-inside / τ-outside scaling preserves γ-contraction. C6 invokes the same soft Bellman operator as a γ-contraction in the gauge-invariant seminorm. To reuse: when introducing entropy regularization to a contraction-based fixed-point analysis, the contraction modulus is preserved provided one chooses the right norm (sup-norm for LSE, gauge-invariant centered seminorm for log-policies).

**Isomorphism description**: τ-scaled LSE in C5 ↔ entropy-regularized soft Bellman 𝒯_τ in C6; ℓ∞ norm in C5 ↔ centered seminorm ‖·‖_c in C6; max(Q) ↔ ⟨π, Q⟩ + τH(π).

**Confidence**: HIGH — both reports name "smooth-max regularization preserves contraction modulus" as the transferable pattern.

---

### Structure Link: C3 (`synchronous-q-learning-finite-time`) ↔ C4 (`ogda-bilinear-last-iterate`)

**Relationship Type**: ANALOGY (linearize-then-couple ≈ skew-symmetric polarization)

**What transfers**: Both proofs decompose a "bad" recursion into a clean linear part + a controllable residual. C3: nonlinear stochastic recursion Δ_t splits into L_t (linear MDS, clean Azuma) + R_t (deterministic coupling residual). C4: nonlinear iterate recursion z_{t+1} splits via identity (E) into ‖z_t‖² (telescope) + ‖δ_{t+1} − δ_t‖² (Tseng-style summable difference) − ‖δ_t‖² (cancels). In both cases the "creative leap" is isolating the structural piece that destroys naive analysis (the max in Q-learning; the cycling cross term in GDA) and proving it can be paid for separately.

**Isomorphism description**: Q-learning max nonlinearity ↔ GDA skew-symmetric coupling matrix B; entry-wise martingale L_t ↔ iterate-norm telescope ‖z_t‖²; deterministic residual R_t ↔ summable-differences term ‖δ_{t+1} − δ_t‖²; Azuma-Hoeffding entry-wise + union bound ↔ weighted-sum-to-last-iterate trick.

**Confidence**: MEDIUM — both reports identify "linearize-then-couple" or "skew-symmetry polarization" as transferable; the abstract correspondence is inferred.

---

### Structure Link: C2 (`sam-convergence-flat-minima`) ↔ C3 (`synchronous-q-learning-finite-time`)

**Relationship Type**: ANALOGY (approximate-gradient + bias-bound + Young)

**What transfers**: Both proofs use a "true gradient is unavailable; we use an approximation and bound the deviation, then pay for the deviation via Young's inequality" template. C2: SAM uses ρ∇f(x)/‖∇f(x)‖ as approximation to the true Danskin maximizer δ*(x); the deviation is bounded by 2Lρ via L-smoothness. C3: tabular Q-learning uses the empirical max as approximation to the population max; the deviation is bounded by the coupling residual R_t. In both, the descent lemma + Young's gives a two-term bound (optimization error + bias²).

**Isomorphism description**: SAM approximate gradient g_t = ∇f(x_t + ρ∇f/‖∇f‖) ↔ Q-learning empirical estimate Q_t; Danskin true gradient ∇f^SAM ↔ Bellman target T*Q*; bias bound 2Lρ ↔ coupling residual ‖R_t‖_∞; diminishing radius ρ_0/√T ↔ polynomial step-size α_t = (H+1)/(H+t).

**Confidence**: MEDIUM — both reports identify "approximate gradient + Young's + telescoping" as transferable; the precise mapping is inferred.

---

## Cluster D: Le Cam / Information-Theoretic Lower Bound Family (MT6)

Master template (MT6): "Construct a hard-instance family parametrized by a hidden adversary; reduce parameter recovery to binary/multi-way hypothesis testing; bound the test error from below via Le Cam / Fano / Assouad / Yang-Barron."

Members:
- D1 = `proofs/research/optimization/lower-bounds/shb-interpolation-regime-lb/` (variance-half uses Le Cam)
- D2 = `proofs/research/learning-theory/generalization/ssl-infonce-minimax-lower-bound/` (Yang-Barron + Fano)
- D3 = `proofs/research/statistics/high-dimensional/lasso-re-prediction-error/` (KKT cone + sub-Gaussian dual-norm)
- D4 = `proofs/research/multi-agent/cumulative-reasoning-depth-lower-bound/` (Yao + Bayes-error per level)
- D5 = `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/` (variance-half uses Le Cam two-point + Pinsker)

### Structure Link: D1, D5, D2, D4 (4-way SAME_TEMPLATE — Le Cam / Hypothesis-Testing LB)

**Members**: shb-interpolation-regime-lb, shb-no-acceleration-restricted, ssl-infonce-minimax-lower-bound, cumulative-reasoning-depth-lower-bound.

**Relationship Type**: SAME_TEMPLATE

**What transfers**: All four proofs reduce a lower bound to a Bayesian/minimax hypothesis test:
- **D5 (SHB restricted, variance half)**: 1-D linear function inside a quadratic wall, two-point hypothesis on sign s ∈ {±1}; Pinsker bounds TV between the two SHB-trajectory laws; Le Cam gives Ω(σD/√T).
- **D1 (SHB interpolation, variance half)**: same Le Cam construction transferred from D5, then *refuted* by exhibiting a multiplicative-noise quadratic that beats the floor exponentially.
- **D2 (SSL InfoNCE minimax)**: pack SO(d) with Riemannian dimension d(d−1)/2 ≍ d²; Fano's inequality on the d²-log packing; Schur-complement amplifies the linear-probe gap by aligning w* with V·e_1 to give an extra factor of d.
- **D4 (CR depth LB)**: per-level Bayes-optimal binary hypothesis test gives all-tail probability ½·min(ε, 1−ε)^{T_ℓ}; Yao's minimax converts deterministic-algorithm bound into randomized-algorithm bound; sum across levels gives T ≥ d log(1/δ)/log(1/ε).

The shared abstract recipe: (i) name the parameter you're trying to estimate or the bit you're trying to test; (ii) construct a δ-packing / two-point family / per-level binary alternative with carefully chosen separation; (iii) apply Pinsker / Fano / Yao to convert the test error into a sample-complexity lower bound. Discovery procedure: pick a packing whose log-cardinality matches the desired rate (sphere → d, SO(d) → d², hypercube → 2^d); then verify that the chosen algorithm cannot resolve the packing without the claimed sample budget.

**Confidence**: HIGH — D5/D1 explicitly use Le Cam two-point + Pinsker per Agent 5; D2 uses Fano + SO(d) packing per Agent 8; D4 uses Yao + per-level Bayes test per Agent 10.

---

### Structure Link: D3 (`lasso-re-prediction-error`) ↔ D2 (`ssl-infonce-minimax-lower-bound`) (REFINED ANALOGY)

**Relationship Type**: ANALOGY (restricted-geometry naming)

**What transfers**: Both proofs identify the *right restricted geometry* on which the desired property holds, instead of demanding nice geometry on all of ℝ^p. D3: KKT-derived cone C(S, 3) = {Δ : ‖Δ_{S^c}‖_1 ≤ 3‖Δ_S‖_1} on which RE κ‖Δ‖² ≤ ‖XΔ‖² suffices. D2: SO(d) sub-manifold of GL(d) on which the joint adversary (V, w*) achieves the d² packing. Both fit the "Restricted-geometry naming" archetype (4 instances in the master taxonomy: D3 = LASSO cone, D2 = SO(d) packing, plus spectral-gap top-k block, plus matrix-Rényi trace-free PSD).

**Isomorphism description**: LASSO error Δ̂ ∈ C(S, 3) ↔ SSL adversary parameter (V, w*) ∈ SO(d) × δ√d·V·e_1; cone constraint ‖Δ_{S^c}‖_1 ≤ 3‖Δ_S‖_1 ↔ orthogonality V V^⊤ = I; RE κ-bound on cone ↔ Schur-complement amplification on aligned-w* sub-family; λ-calibration via dual-norm sub-Gaussian maximal inequality ↔ δ-calibration via Yang-Barron metric entropy.

**Confidence**: MEDIUM — both reports name "restricted-geometry naming" as the meta-pattern (Agent 9, Agent 8); the concrete isomorphism is inferred from the unified description in the master taxonomy.

---

### Structure Link: D1 (`shb-interpolation-regime-lb`) ↔ D5 (`shb-no-acceleration-restricted`)

**Relationship Type**: SHARPENING / RESCUES

**What transfers**: D5 establishes the Le Cam two-point variance LB Ω(σD/√T) on the wall coordinate; D1 inherits the construction but tightens analysis: under interpolation noise (ρ(0)=0), the Le Cam two-point construction *survives* in the sense that the bias half transfers (noiseless oracle is admissible), but the variance half is *refuted* by a multiplicative-noise quadratic. The link teaches: a Le Cam LB is sensitive to the noise model — if the noise vanishes at the optimum, the construction's "linear drift inside a wall" loses its ability to maintain a test-distinguishable separation, and the variance LB collapses.

**Confidence**: HIGH — explicit in Agent 5's discussion of the relationship between A1/D5 and A3/D1.

---

### Structure Link: D2 (`ssl-infonce-minimax-lower-bound`) ↔ D4 (`cumulative-reasoning-depth-lower-bound`)

**Relationship Type**: ANALOGY (joint-adversary / per-level decomposition)

**What transfers**: Both proofs achieve their tight rate by *decomposing the adversary across coordinates / levels* rather than naively packing one dimension. D2: instead of sup over w* alone (gives only d/(nI)), pack SO(d) (gives d²/(nI)) jointly with worst-case w* aligned to V·e_1. D4: instead of one binary test (gives one bit per call), per-level binary test over T_ℓ calls at level ℓ, summed across d levels, gives the full d log(1/δ) lower bound. The shared move: when single-component adversary gives the wrong rate, decompose the parameter space across multiple coordinates and amplify.

**Isomorphism description**: SO(d) packing across rotation matrix entries ↔ per-level Bayes test across levels ℓ = 1,…,d; joint sup over (f*, w*) ↔ joint sup over (level-ℓ alternative, decision rule); Schur-complement amplification of linear-probe gap ↔ all-tail probability aggregation across levels.

**Confidence**: MEDIUM — the "joint-adversary" pattern is named in Agent 8 (D2); the "per-level decomposition" structure is named in Agent 10 (D4); the analogy between them is inferred.

---

## Cluster E: Multi-Agent Verification Cluster

Members (all under `proofs/research/multi-agent/`):
- E1 = `verification/multi-agent-verification-error-propagation/` (Problem 4.1, foundational)
- E2 = `categorical-functorial-error-propagation/` (Problem 7.2, generalizes E1)
- E3 = `cumulative-reasoning-compositional-reuse/` (Problem 7.7)
- E4 = `cumulative-reasoning-depth-lower-bound/` (Problem 7.9)
- E5 = `cumulative-reasoning-nonstationary-verifier/` (Problem 7.4)

### Structure Link: E2 (`categorical-functorial-error-propagation`) GENERALIZES E1 (`multi-agent-verification-error-propagation`)

**Relationship Type**: GENERALIZATION

**What transfers**: E2 is the categorical-functorial lift of E1. The Lawvere [0,∞]-enrichment M = ([0,∞], ≥, +, 0) is engineered so ‖η‖_∞ = d_{[C,D]}(F, G) becomes definitional. Then under the Kleisli construction over the distribution monad (TV-metric on Δ(D)), E2's bound *reduces verbatim to E1*: discrete C with TV-Lawvere D recovers the (1−ε)^T vs (1−ε^k)^T product-form bound. To reuse: any binary verifier pipeline lifts to an enriched-functor pipeline; the (1−ε^k)^T amplification trick is preserved exactly.

**Confidence**: HIGH — Agent 10 explicitly states "discrete reduces to Problem 4.1" as the fundamental link; the index entry for E2 says the same.

---

### Structure Link: E3 (`cumulative-reasoning-compositional-reuse`) DEPENDS E1 (`multi-agent-verification-error-propagation`)

**Relationship Type**: DEPENDS

**What transfers**: E3's per-lemma retry trick (δ → δ^k *before* DAG composition) directly reuses E1's "independence-then-product-then-amplify" mechanism. The new ingredient in E3 is the tree-unfolding count N(d, Δ) = (Δ^{d+1} − 1)/(Δ − 1), which honestly corrects the user-stated Δ^d. Without E1's amplification template, E3's library-first amortization principle has no quantitative bite.

**Confidence**: HIGH — Agent 10 explicitly names "Per-lemma retry as δ → δ^k — direct reuse of the Problem 4.1 amplification trick."

---

### Structure Link: E4 (`cumulative-reasoning-depth-lower-bound`) ↔ E1 (`multi-agent-verification-error-propagation`)

**Relationship Type**: DUAL

**What transfers**: E1 is the upper bound (1 − ε^k)^T on chain reliability; E4 is the matching lower bound T ≥ d log(1/δ) / log(1/ε) on the verifier-call count. Both share the same parametrization (per-round error ε, depth/length T or d, retry count k), and the matching upper/lower bound establishes the rate is tight up to constants. E4 uses Yao's minimax + per-level Bayes-error to achieve the lower bound, while E1 uses Bernoulli independence + product to achieve the upper bound. To reuse: when an upper bound is established via "independence + product," the matching lower bound typically follows from "Yao + per-level binary test."

**Confidence**: HIGH — Agent 10 explicitly motivates E4 by "if (1−ε^k)^T is the upper bound, what's the matching lower bound on the number of verifier calls?"

---

### Structure Link: E5 (`cumulative-reasoning-nonstationary-verifier`) GENERALIZES E1

**Relationship Type**: GENERALIZATION

**What transfers**: E5 generalizes E1 from constant per-round error ε to time-varying ε_t = ε_0(1 + t/T_0)^α. The discrete product log P_T = Σ log(1 − ε_t) is converted to a continuous integral via the integral test, exposing a phase transition at α = 1 (linear decay). Three regimes: α<1 (still survivable), α=1 (critical step T**), α>1 (super-polynomial collapse). Constant-ε is the α=0 special case; E5 reduces to E1 at α=0 with ε_t ≡ ε_0.

**Confidence**: HIGH — Agent 10 explicitly motivates E5 as "Problem 4.1 assumes ε constant across rounds, but in practice verifier accuracy degrades."

---

### Structure Link: E3 (`cumulative-reasoning-compositional-reuse`) ↔ E4 (`cumulative-reasoning-depth-lower-bound`)

**Relationship Type**: ANALOGY (depth–breadth duality)

**What transfers**: Both proofs analyze the depth d of a composition tree, but from opposite directions. E3 (upper bound): depth d composition with branching Δ generates N(d, Δ) = (Δ^{d+1} − 1)/(Δ − 1) tree-unfolded events; using verified library lemmas (each amplified to (1−δ)^N(d,Δ)) beats per-lemma retry by ~700×. E4 (lower bound): depth d requires T ≥ d log(1/δ)/log(1/ε) verifier calls. Composing E3 (UB on cost when libraries help) with E4 (LB on cost in general) gives the explicit value of library-first amortization.

**Confidence**: MEDIUM — both proofs share the depth-d framework and library-first reasoning, but the explicit composition link is inferred.

---

### Structure Link: E5 (`cumulative-reasoning-nonstationary-verifier`) ↔ E4 (`cumulative-reasoning-depth-lower-bound`)

**Relationship Type**: ANALOGY (asymptotic regime analysis)

**What transfers**: Both proofs use asymptotic / scaling arguments to extract phase-transition thresholds. E5: integral-test on log(1 − ε_t) exposes phase transition at α=1; closed-form thresholds T**, T*_β, T_div for sub-linear / linear / super-linear regimes. E4: Yao + Bayes-error per level + sum across levels gives T = d log(1/δ)/log(1/ε), the depth-vs-error rate. Both extract clean closed-form thresholds from a multi-parameter pipeline.

**Confidence**: LOW — both use asymptotic scaling but the analogy is loose.

---

### Structure Link: E2 (`categorical-functorial-error-propagation`) ↔ E1 (categorical-vs-engineering)

**Relationship Type**: ANALOGY (formalism-as-aesthetic vs engineering core)

**What transfers**: E2 wraps the engineering core of E1 in Lawvere-enriched category theory; the Banach contraction in functor space *automatically* yields α^k decay. The "transfer" is that the heavy mathematical machinery (Lawvere 1973 + Kelly enriched cat + Banach fixed-point) genuinely *unifies* E1 with non-discrete settings, but it is **mostly decorative** for the discrete case (a one-line sup-of-sums + one-line iteration). To reuse: the categorical lift is load-bearing for *unification* (E1 falls out as a special case), but for any *concrete* binary-pipeline application, E1's elementary product form is sharper to invoke directly.

**Confidence**: HIGH — Agent 10 explicitly discusses "Decorative-vs-load-bearing test for category theory" as the meta-observation.

---

## Index by Relationship Type

| Type | Count | Example link |
|---|---|---|
| SAME_TEMPLATE | 11 | A1+A2+A3+A4 (4-way SHB Goujaud cluster); C1–C7 (7-way Cancellation Pair); B1–B5 (5-way HRS phylogeny); D1+D5+D2+D4 (4-way Le Cam) |
| ANALOGY | 11 | A1–A4 ↔ A6 (Goujaud ↔ ln-cosh); B2 ↔ B1 (DP ↔ stability); C5 ↔ C6 (entropy preserves contraction); C3 ↔ C4 (linearize-then-couple ≈ skew-symmetric polarization); C2 ↔ C3 (approx-gradient + Young); D3 ↔ D2 (restricted geometry); D2 ↔ D4 (joint adversary / per-level); E3 ↔ E4 (depth–breadth); E5 ↔ E4 (asymptotic regime); E2 ↔ E1 (formalism vs core) |
| GENERALIZATION | 4 | E2 generalizes E1; E5 generalizes E1; A1 → A3 (with PARTIAL refutation); A1 → A4 (with PARTIAL refutation) |
| DEPENDS | 4 | B3 depends B1; B4 depends B3; B5 depends B1+B3; E3 depends E1 |
| SHARPENING | 3 | A1 → A2 (closed-form threshold); C1 → C6 (gauge-invariant); D5 → D1 (rescues / refutes variance) |
| DUAL | 1 | E4 ↔ E1 (UB vs LB on chain reliability) |
| CONTRADICTS | 1 | A1+A2+A3+A4 ↔ A5 (PR-averaged disproves SHB last-iterate Ω(1/T) LB on Goujaud instance) |
| RESCUES | 1 | D5 → D1 (rescues bias half, refutes variance half under interpolation) |

Total Structure Link blocks: 28 (some blocks list multiple members; the row counts above count each block once, except the 7-way cancellation cluster which is split across the SAME_TEMPLATE entry and individual within-cluster sharpening links).

---

## Cross-Cluster Links (BONUS)

Several proofs sit at the intersection of two clusters:

- **`shb-interpolation-regime-lb` (D1 = A3)** — sits in both Cluster A (SHB LB family, as A3) and Cluster D (Le Cam LB family, as D1). The variance half explicitly uses Le Cam two-point + Pinsker; the bias half is the Goujaud cycling argument. Anyone using this proof for the Reduction frame should consult both clusters: Cluster A for the cycling chassis, Cluster D for the hypothesis-testing chassis.

- **`shb-no-acceleration-restricted` (D5 = A1)** — sits in both Cluster A (as the founder A1) and Cluster D (as D5, the Le Cam two-point variance template that A3 inherits and refutes).

- **`cumulative-reasoning-depth-lower-bound` (D4 = E4)** — sits in both Cluster D (Le Cam / hypothesis-testing LB family, as D4) and Cluster E (multi-agent verification, as E4). The "Yao + per-level Bayes-error + sum across levels" template makes it both an information-theoretic LB and a multi-agent-self-referential LB.

- **`sgd-signal-noise-generalization-decomposition` (B3)** — also belongs implicitly to a "trajectory framework" cluster spanning B3, B4, B5 (heavy-tailed, adversarial). All three share the "parameter-motion bound ‖θ_T − θ_0‖ ≤ G√(Tη)" sub-result, suggesting a fourth cluster ("Trajectory Framework Family") could be defined.

- **`heavy-ball-instability` (A6)** — sits in both Cluster A (SHB hard-instance family, as A6) and the broader "Construction search via curvature-transition counterexample" archetype. The ln-cosh construction is a counterpart to the Goujaud polytope-Moreau construction in A1–A4.

- **`entropy-regularized-npg-linear-convergence-variant` (C6)** — sits in both Cluster C (Cancellation Pair, as C6) and a meta-cluster of "Honest-rate / restricted-quantifier rescue" proofs (alongside A1, A3, A4, the SSL conjecture-rescue triple, and DYS variant).

These cross-cluster links suggest the natural follow-up structure-map clusters: (F) Trajectory Framework Family, (G) Conjecture-Rescue / Honest-Variant Family, (H) Restricted-Geometry Family.
