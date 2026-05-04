# Discovery Report — Agent 6 (Learning Theory / Generalization, Part 1)

Scope: NTK + Approximation + Implicit Bias (7 proofs).

---

## Proof 1: NTK Gram Matrix Positive Definiteness

### 1. The Spark
**failure-of-natural-approach** — Du et al. needed a quantitative non-degeneracy condition (`λ_min(H^∞) > 0`) to make their NTK convergence theorem non-vacuous, but standard kernel-PD tools (Schoenberg, RKHS density) do not directly apply to the arc-cosine NTK with finite samples.

### 2. The Key Insight
Rewrite `c^T H^∞ c` as `E_w[‖Σ c_i 1{w^T x_i ≥ 0} x_i‖²]`. The non-obvious leap is recognising that the activation indicator `1{w^T x_i ≥ 0}` is constant on each cell of a hyperplane arrangement, so the integral collapses to a *combinatorial* statement about which subsets `S` of indices can be "switched on simultaneously". Once you see this, the question reduces to: can two adjacent cells differ in exactly one coordinate? That is pure incidence geometry, requiring only that no two `x_i` define the same hyperplane (`x_i ≠ ±x_j`).

### 3. The Technique Chain
- **Stein-style integral representation** (standard, NTK literature) — turn quadratic form into squared norm under expectation.
- **Hyperplane arrangement combinatorics** (non-standard for ML; classical in discrete geometry / Schläfli) — partition `R^d` into sign-pattern cells.
- **Adjacent-cell subtraction trick** (non-standard, Du et al. 2019 ICML) — flip one indicator, subtract, isolate `c_k x_k = 0`.
- **Necessity check via antipodal pairs** (standard sanity).

### 4. The Construction
N/A — no hard-instance construction; the proof is structural. The condition `x_i ≠ ±x_j` is the dual: it is the *minimal* condition forcing adjacency to exist for every coordinate.

### 5. The Failure Modes
- **Direct spectral / Schoenberg attack**: NTK is not a translation-invariant or dot-product kernel on a sphere in the form Schoenberg covers; positivity is non-strict at antipodes.
- **Random-matrix concentration**: gives lower bounds on `λ_min` only with high probability over data; here we want an exact, deterministic statement under a deterministic separation condition.

### 6. The Discovery Path
1. Du et al. write the NTK convergence proof; need `λ_min(H^∞) > 0` to control the convex-like dynamics.
2. They try kernel-positivity classics (arc-cosine kernel of Cho–Saul) — these only give PSD, not strict PD on finite samples.
3. They notice the NTK entry is literally `E_w[1{w^T x_i ≥ 0} 1{w^T x_j ≥ 0}] x_i^T x_j`, so the quadratic form is an `E[‖·‖²]`.
4. They ask: when does the inside vanish a.s.? Cells of constant sign pattern → `Σ_{i∈S} c_i x_i = 0` per cell.
5. The adjacency lemma (one-coordinate flip) drops out from "no two hyperplanes coincide", finishing the argument and revealing the antipodal condition as tight.

### 7. Transferable Patterns
- **"Quadratic form = expectation of squared norm" template**: any time a kernel has a stochastic feature-map representation, PD reduces to "feature vectors don't all live in a hyperplane".
- **Adjacent-cell trick** generalises: whenever indicators of half-spaces appear inside an integral, sign-pattern combinatorics replace analytic continuation.

---

## Proof 2: Transformer Self-Attention is Lipschitz

### 1. The Spark
**gap-in-literature** — Generalisation / robustness bounds for Transformers need a Lipschitz constant for the attention block, but unlike CNNs/MLPs there is no clean composition bound because softmax is non-linear in `X` *twice* (in scores and in values).

### 2. The Key Insight
Decompose by product rule into "value perturbation" + "score (attention) perturbation", then notice that softmax's Jacobian is exactly the Hessian of log-sum-exp, whose spectral norm equals `1/2` (tight, achieved at the two-spike `σ = (1/2,1/2,0,…)`). The non-trivial part is that the bilinear score `X_i M X_j^T / √d_k` makes the dependence on `X` *cubic*, so the Lipschitz constant must scale as `R²`, not `R` — a fact most students miss.

### 3. The Technique Chain
- **Product-rule decomposition** (standard calculus) — split into value-side and score-side.
- **Softmax Jacobian = LSE Hessian = diag(σ) − σσ^T** (standard, statistical physics).
- **Spectral-norm computation via variance of a probability vector** (mildly non-standard) — `v^T J v = Var_σ(v) ≤ 1/2`.
- **Bilinear perturbation `(2√n‖M‖R/√d_k)`** (standard linear algebra).
- **`(a+b)² ≤ 2(a²+b²)`** to combine score perturbations cleanly.

### 4. The Construction
N/A — no hard instance, but the **tightness witness** for softmax Lipschitz (`σ = (1/2,1/2,0,…)`, `v = (1,−1,0,…)/√2`) is the closest thing to a construction; it certifies that `1/2` cannot be improved.

### 5. The Failure Modes
- **Naive bound `1` for softmax**: ignores variance reduction, loses a factor of 2 — but more importantly, ignores that the input to softmax has its *own* perturbation.
- **"Softmax is `1`-Lipschitz so attention is `1`-Lipschitz"**: forgets the bilinear score map and the value aggregation — gives constant independent of `R`, which is wrong (attention is not Lipschitz on unbounded inputs).

### 6. The Discovery Path
1. Someone (Kim, Papyan, Mhammedi, Vuckovic) wants a generalisation bound for a Transformer; needs Lip constant of one block.
2. First attempt: just compose `softmax ∘ linear ∘ linear` as in MLPs → realises softmax depends on `X` through *both* keys and queries.
3. Product rule splits into Term I (value) and Term II (attention).
4. Softmax Jacobian computation reveals `1/2`; tightness witnessed by the two-spike example.
5. Bilinear score perturbation introduces an inevitable `R²` factor → the bound must be quadratic in input norm. Unit-norm/LayerNorm assumption is then introduced to get a usable constant.

### 7. Transferable Patterns
- **"Compose Lipschitz constants of each map then chain via product rule"** is the canonical recipe for any block that aggregates inputs via a learned weighting (attention, mixture-of-experts).
- The **`R²` scaling** is a generic warning sign: any time scores are bilinear in the input, expect quadratic scaling and require boundedness (LayerNorm) for a useful bound.

---

## Proof 3: Denoising Score Matching Equivalence

### 1. The Spark
**failure-of-natural-approach** — Explicit Score Matching `J_ESM` requires the unknown gradient `∇log q_σ(x)` (the score of the data distribution itself), so it cannot be directly minimised. Vincent (2011) asks: is there a tractable surrogate?

### 2. The Key Insight
Both objectives expand into a `θ`-dependent piece `(1/2)E[‖s_θ‖²]`, plus a cross term, plus a `θ`-independent constant. If the cross terms agree, the equivalence is automatic. The cross terms agree because of a single Bayes-rule swap: `∇log q_σ(x) = E_{p(y|x)}[∇log p(x|y)]` (score of a mixture is the posterior expectation of the conditional score). This identity needs Leibniz/DCT under the Gaussian kernel.

### 3. The Technique Chain
- **Quadratic expansion** (standard) — write `‖a-b‖² = ‖a‖² − 2⟨a,b⟩ + ‖b‖²`.
- **Score-of-a-mixture identity** (classical, score-matching/MCMC literature) — derived by `∇` under integral via DCT.
- **Bayes swap** `q_σ(x) p(y|x) = p_data(y) p(x|y)` (textbook).
- **Closed-form conditional score** for Gaussian noise: `∇log p(x|y) = −ε/σ`.

### 4. The Construction
N/A — pure equivalence proof.

### 5. The Failure Modes
- **Try to estimate `∇log q_σ` directly** from samples: this is exactly the problem score matching is designed to avoid.
- **Try integration by parts (Hyvärinen 2005's ESM trick)**: works but introduces second-order derivatives `∇·s_θ`, expensive in high dimensions; misses the cleaner DSM form which only needs first-order targets.

### 6. The Discovery Path
1. Hyvärinen (2005) introduces Score Matching but needs Hessian-trace estimate.
2. Vincent (2011) asks if a noise-conditioned objective can replace the trace.
3. Expansion of both objectives reveals identical quadratic-in-`s_θ` term.
4. Cross terms differ in form but the score-of-mixture identity (a single Bayes swap) identifies them up to sign.
5. The constant `C` collects everything `θ`-independent; equivalence is exact at the gradient level.

### 7. Transferable Patterns
- **"Expand objective; isolate `θ`-dependent part; show two formulations agree there"** is a meta-template for proving estimator equivalences (also used in EM ↔ likelihood, ELBO ↔ KL, etc.).
- **Score-of-a-mixture identity** is one of the most reusable Bayesian tools — appears in diffusion models, denoising autoencoders, and mean-field VI.

---

## Proof 4: NTK Infinite-Width Convergence

### 1. The Spark
**pattern-spotted** — The empirical NTK `Θ̂_m` is a sample average over `m` neurons of rank-one matrices Hadamard-multiplied with a fixed Gram `G`. Concentration of *averages of matrices* should give a `1/√m` rate, but a naive bound has `n²` (entry-wise union bound).

### 2. The Key Insight
The Gram matrix `G` (with unit diagonal, PSD) acts as a Hadamard multiplier that *cannot increase* operator norm: `‖M ∘ G‖_op ≤ ‖M‖_op`. This Schur product lemma absorbs `G` entirely, so the Bernstein bound applies to `(A_k − E[A_1])` — an `n × n` rank-one fluctuation whose norm is just `‖s_k‖² ≤ n‖σ'‖²_∞`. The `n` in the final bound comes from the rank-one outer product, not from `G`.

### 3. The Technique Chain
- **Decomposition** `Θ̂_m − Θ^∞ = (1/m) Σ Z_k` (standard).
- **Schur (Hadamard) product theorem** (classical matrix analysis; here the version with PSD multiplier and unit diagonal) — proved via `v^T(M ∘ G)v = Σ_ℓ q_ℓ^T M q_ℓ`.
- **Matrix Bernstein inequality** (Tropp 2012) — the modern matrix concentration tool of choice; gives `log n` instead of `log n²`.
- **Variance vs. sub-exponential regime selection** (standard tail-bound bookkeeping).

### 4. The Construction
N/A.

### 5. The Failure Modes
- **Entry-wise concentration + union bound**: gives `√(log n²/m) = √(2 log n/m)` — only a constant worse, but the operator-norm bound from this is `n · √(log n/m)` instead of `√(n log n/m)`, costing a factor of `√n`.
- **Bound `‖A_k ∘ G‖ ≤ ‖A_k‖_F · ‖G‖_F`**: both Frobenius norms are `O(n)`, giving `n²` — far too loose.
- **Try matrix Hoeffding instead of Bernstein**: misses the variance proxy improvement.

### 6. The Discovery Path
1. Du/Allen-Zhu/Arora et al. need finite-width approximation of the NTK with explicit `m(n,ε)` rate.
2. First attempt: bound each entry `|Θ̂_{ij} − Θ_{ij}|` by Hoeffding and union-bound — gives `n² log n / m`, suboptimal.
3. Realise the empirical NTK is `(1/m) Σ s_k s_k^T ∘ G`, an *average of matrices* — matrix Bernstein should give `log n`.
4. Schur lemma for unit-diagonal PSD `G` is the cleanest way to peel off `G` without losing factors of `n`.
5. Plug in: `‖Z_k‖ ≤ 2n‖σ'‖²`, variance ≤ `R²`, get `‖Θ̂_m − Θ^∞‖_op = O(n √(log(n/δ)/m))`.

### 7. Transferable Patterns
- **"Hadamard-product peel-off"**: when a fixed PSD/unit-diagonal matrix multiplies a random matrix, treat it as inert in operator norm and concentrate only the random factor.
- **Matrix Bernstein > entry-wise + union** whenever you care about operator norm of a sum of independent matrices — a uniform improvement of `log n` factor.

---

## Proof 5: Quantitative ReLU Universal Approximation

### 1. The Spark
**gap-in-literature** — Cybenko/Hornik (1989) prove ReLU networks are dense in `C([0,1]^d)` but give *no rate*. Practitioners need explicit `N(ε, L, d)`; what is the cost of approximating a Lipschitz `f` to error `ε`?

### 2. The Key Insight
Two-step reduction: (i) any Lipschitz `f` is approximated to `Lδ` by its piecewise-affine interpolant `g` on a fine triangulation; (ii) any continuous piecewise-linear (CPL) function with `P` linear regions equals a one-hidden-layer ReLU network with `≤ P` neurons (Wang–Sun 2005 / Arora et al. 2018). The clever choice of triangulation is **Kuhn (Freudenthal)**: it makes both *conformality* across cube boundaries and *exact piece-count counting* trivial, because each cube splits into `d!` simplices indexed by permutations.

### 3. The Technique Chain
- **Kuhn triangulation** (combinatorial topology, 1960s; standard in PL-topology, used in Brouwer fixed-point algorithms).
- **Barycentric interpolation error bound** (standard finite-element analysis).
- **Conformality across faces via shared sub-triangulation** (PL topology).
- **CPL ↔ ReLU representation theorem** (Arora–Basu–Mianjy–Mukherjee 2018) — cited as a black box.
- **Region count `d! · M^d` from Kuhn** (combinatorial).

### 4. The Construction
The Kuhn triangulation itself is the construction. Why this one and not Delaunay or random?
- Conformality is *automatic* (shared faces have identical sub-triangulations from both sides — proved by the `m ∈ S` vs `m ∉ S'` index trick).
- Region count is exactly `d! · M^d`, matching the metric-entropy lower bound `(L/ε)^d` up to the `d!` prefactor.
- Per-simplex gradient is bounded by `L` directly, giving the weight bound.
If you replace Kuhn with a random triangulation, conformality fails; with Delaunay, region counts are unpredictable.

### 5. The Failure Modes
- **Construct via a single hidden layer of "bumps"** (sigmoid-style proof of Cybenko): doesn't extend cleanly to ReLU and gives no quantitative rate.
- **Approximate via Fourier / polynomials and then convert**: gives suboptimal `(L/ε)^d` with bad constants and requires smoothness.
- **Try a regular grid of d-cubes without triangulating**: the affine-on-each-cube interpolant is *discontinuous* across faces (this is what conformality fixes).

### 6. The Discovery Path
1. Question: how many neurons are needed for `ε`-approximation of an `L`-Lipschitz function?
2. First idea: cover `[0,1]^d` by `(L/ε)^d` boxes, fit a constant on each — gives ReLU realisation but with crude error and no continuity.
3. Realise: need *piecewise affine and continuous*. Triangulating each cube gives both — but generic triangulations don't conform.
4. Find Kuhn / Freudenthal triangulation in PL-topology lit; conformality is built in.
5. Use the CPL→ReLU theorem (Arora et al.) to translate region count into neuron count: `N ≤ d! (L/ε)^d`.

### 7. Transferable Patterns
- **"Approximate target via piecewise-linear interpolation on a structured mesh, then convert to ReLU via CPL representation"**: this template gives quantitative bounds for many other function classes (Hölder, Sobolev) by varying the mesh.
- **Kuhn triangulation** is a hammer for any "I need a conforming simplicial subdivision of `[0,1]^d`" problem.

---

## Proof 6: Implicit Bias of GD — Max-Margin Convergence

### 1. The Spark
**pattern-spotted** — On linearly separable data with logistic loss, GD does not stop (loss never reaches `0`), and `‖w_t‖ → ∞`. Soudry et al. observe empirically that `w_t/‖w_t‖` converges, and the limit *looks like the SVM solution*. Why?

### 2. The Key Insight
The exponential tail of logistic loss `σ(−m) ≈ e^{−m}` makes the gradient an *exponentially weighted* combination of data points: only those with the smallest current margin contribute. As `t → ∞`, this self-bootstrapping selects exactly the support vectors of the hard-margin SVM. The KKT conditions of SVM emerge as the *steady state* of the exponential reweighting. Critically, `‖w_t‖ = Θ(log t)` (margin grows logarithmically) while the angle converges at rate `O(1/log t)` — slow but inevitable.

### 3. The Technique Chain
- **Descent lemma + smoothness** (standard convex analysis) — gives `‖∇L(w_t)‖ → 0`.
- **Conic-hull contradiction** (separability geometry) — no finite minimiser, so `‖w_t‖ → ∞`.
- **Sigmoid asymptotic expansion** `σ(−m) = e^{−m}(1 + O(e^{−m}))` (calculus).
- **Telescoping iterate sum** `w_T = w_0 + Σ_i β_i(T) z_i + r_T` (algebraic).
- **Self-bounding gradient inequality** `L_{t+1} ≤ L_t − cL_t²` → `O(1/t)` decay (a textbook Lyapunov-style trick, used in matrix completion and EM).
- **KKT identification by limit-coefficient normalisation** (Soudry et al.'s key novelty).

### 4. The Construction
N/A — analysis of a fixed dynamics.

### 5. The Failure Modes
- **"Loss `→ 0`, so `w_t` converges by completeness"**: false — loss does decay but `w_t` diverges; the optimisation problem has no minimiser in the separable case.
- **Convex-analysis convergence rates**: standard bounds `L(w_t) ≤ L*/t` give nothing because `L* = 0` is *not attained*.
- **Apply Polyak–Łojasiewicz**: requires a finite minimiser; here PŁ fails, but a *self-bounding* analogue still works because `‖∇L‖ ≥ L/(2‖w*‖)`.

### 6. The Discovery Path
1. Empirical observation: GD on logistic loss converges *in direction* to something resembling SVM.
2. First attempt: standard convergence theory — fails because no finite minimum.
3. Key reframing: instead of asking "where does `w_t` converge?", ask "where does `w_t/‖w_t‖` converge?" — this requires controlling `‖w_t‖`.
4. Self-bounding gradient gives `L_t = O(1/t)`, hence `m_min(t) ≥ log t − C`, i.e., margins grow logarithmically.
5. Telescope `w_T` as a non-negative combination of data; normalise; show only support vectors survive; verify SVM KKT conditions hold for the limit.

### 7. Transferable Patterns
- **"Direction of divergence carries the bias"**: when an unregularised optimiser doesn't converge in norm, study the limit of `w_t/‖w_t‖` — appears in matrix factorisation (Gunasekar), homogeneous nets (Lyu–Li), steepest descent under non-Euclidean norms (Nacson).
- **Self-bounding `L_{t+1} ≤ L_t − cL_t²`** is a workhorse Lyapunov template whenever loss is exponentially-tailed and unbounded below.
- **KKT-as-fixed-point** of an exponentially weighted dynamic: if your reweighting pulls toward the smallest margin, the stationary distribution *is* the dual feasible support.

---

## Proof 7: Depth Separation — Exponential Width for Radial Functions

### 1. The Spark
**question-asked** — Eldan–Shamir (2016) ask whether 2-layer ReLU nets are strictly weaker than 3-layer ones. They construct a radially symmetric function (`1[‖x‖² ≤ d]`) that any 3-layer net handles in poly width but conjecture 2-layer needs `exp(d)`.

### 2. The Key Insight
Two distinct facts collide. (i) The ball indicator, viewed through Hermite expansion, has `Ω(1)` energy at high degrees `2k = Θ(√d)` (because it's a step function of a `χ²_d`). (ii) A single ReLU `ReLU(⟨u,x⟩+b)` has degree-`2k` energy spread over `N(d,2k) = Θ((d/2k)^{2k})` directions in the Hermite basis, but the radial target occupies only **one** of those directions — so by Funk-Hecke, the per-neuron radial projection is attenuated by `1/√N`. With `N` exponentially large, you need exponentially many neurons to add up to the target.

### 3. The Technique Chain
- **Hermite / Gaussian-orthogonal expansion** (classical Gaussian analysis; Eldan–Shamir / Daniely / Safran–Shamir).
- **Funk-Hecke formula** (harmonic analysis on the sphere) — quantifies radial projection of `h_k(⟨u,·⟩)`.
- **Laguerre coefficient lower bound for `1[χ²_d ≤ d]`** (asymptotic analysis of orthogonal polynomials at the median; the most technically demanding piece, cited rather than re-derived).
- **Cauchy-Schwarz "bottleneck"**: `m` neurons in an `N`-dim space have radial projection at most `√(m/N) · ‖h^{=2k}‖` → forces `m ≥ N · β² / ‖h‖²`.
- **Integration-by-parts decay** of ReLU's Hermite coefficients `c_k(b) = O(1/k)`.

### 4. The Construction
The hard instance is `f*(x) = 1[‖x‖² ≤ d]` under standard Gaussian. Why this and not, say, a sinusoid?
- **Radial symmetry** is essential: the Funk-Hecke argument exploits that the target sits in the 1-dimensional radial subspace of each Hermite shell, while neurons sit in random directions.
- **Step at the median**: places the discontinuity where the `χ²_d` density is peaked (`Θ(1/√d)`), guaranteeing slow Laguerre-coefficient decay up to degree `Θ(√d)`. Smoother radial functions would have rapidly decaying coefficients — too few high-degree modes to force exponential width.
- **Why the ball not a sphere**: indicator must be square-integrable under Gaussian; a sphere indicator has measure zero.
- **Why `radius = √d`**: the median of `χ²_d`, maximising density at the discontinuity.
If you simplify to a quadratic (Theorem A), you only get `m = Ω(√d)` — polynomial. The exponential lower bound *requires* high Hermite frequencies, hence the step function.

### 5. The Failure Modes
- **VC-dimension counting**: 2-layer ReLU nets of width `m` have VC-dim `O(m d log m)` — not enough to rule out approximation, only fitting.
- **Volume / packing arguments**: bound the *number* of distinct radial functions representable, not the approximation error.
- **Try a sinusoidal target** (Telgarsky's depth-separation construction): gives separation between depth-`k` and depth-`k²`, but doesn't give 2-vs-3 with exponential gap.
- **Approximation theory in `L^∞`** (instead of `L²(γ_d)`): much harder to control, loses Funk-Hecke.

### 6. The Discovery Path
1. Eldan–Shamir conjecture / construct a 3-layer net for the ball indicator with poly width.
2. Question: must any 2-layer net have super-poly width?
3. First attempt: rank/VC arguments — too weak.
4. Key reframing: work in `L²(γ_d)`, use Hermite basis. Project both target and neurons onto each Hermite shell.
5. Funk-Hecke shows neurons "leak" into `N(d, 2k)` directions while target sits in only `1`. The ratio `1/√N(d,2k)` *is* the per-neuron inefficiency.
6. Prove `f*` has `Ω(1)` energy at some `2k* = Θ(√d)` (Laguerre / step-function asymptotics — the technical heart, requires Plancherel-Rotach or CLT-based arguments).
7. Cauchy-Schwarz bottleneck closes the loop: `m ≥ N(d, 2k*) · |f̂_{2k*}|² = exp(Ω(√d log d))`.

### 7. Transferable Patterns
- **"Frequency analysis of the target vs. expressivity of the basis function"**: depth-separation, depth-vs-width tradeoffs, and lower bounds for Barron-class functions all use this template (Hermite for Gaussian, Fourier for uniform, spherical harmonics for sphere).
- **Funk-Hecke / addition theorem** is the standard tool whenever a function class is rotation-invariant on Gaussian/sphere — the projection onto rotation-invariant targets pays a `1/√(dim of shell)` price per element.
- **"Step function at the median"** is the canonical hard instance for orthogonal-polynomial lower bounds; reused in compressed sensing (RIP lower bounds), random matrix theory, and online learning.

---

## Summary

- File written: `C:\Users\12729\Desktop\Math\workspace\discovery_reports\agent_6.md`
- Proofs analysed: 7 (NTK Gram PD, Transformer Lipschitz, Denoising Score Matching, NTK ∞-width convergence, ReLU quantitative UAT, GD implicit bias, Depth separation).
- Most-interesting cross-cutting observation: **five of the seven proofs (Gram PD, Transformer Lip, NTK convergence, ReLU UAT, depth separation) succeed by reducing a high-dimensional or non-linear question to a quantity that lives in a smaller, structured space — a hyperplane-arrangement cell, a single softmax probability vector, a Hermite shell, a simplex of a triangulation, or a Funk-Hecke radial component — and then exploiting tight elementary inequalities there**. The hard work in modern ML theory is consistently *finding the right low-dimensional / combinatorial reduction*, not deploying heavy machinery.
