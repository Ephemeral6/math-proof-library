# Master Discovery Report

Synthesis of ten parallel discovery agents covering 69 research-level proofs in the math library. Sections: (1) summary table; (2) frequency analysis (spark, technique, meta-strategy); (3) discovery taxonomy; (4) meta-insights and the single biggest lever for the Math Agent V2 framework.

---

## Section 1: Summary Table (69 proofs)

### Optimization / Convergence (Agent 1, 7 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 1 | NPG Softmax Tabular | NPG-update equals exponentiated mirror descent; old regret bounds should transfer | Bregman 3-pt's `+KL(pi'||pi)` cancels Donsker-Varadhan/Hoeffding's `-KL(pi'||pi)` | Two-bound cancellation: identity gives `-phi`, concentration gives `+phi` |
| 2 | Entropy-Reg Value Iteration | LSE is smooth max; Bellman contraction should survive entropy regularization | LSE is exactly 1-Lipschitz in `linf`, contraction modulus stays `gamma` | Smooth-max regularization preserves contraction modulus |
| 3 | SGD Last-Iterate Averaged | Why does textbook SGD always carry `log T`? Is it intrinsic? | Constant horizon-aware step `eta=D/(G sqrt T)` makes `sum eta^2 = O(1)` | Constant horizon-aware step kills harmonic log factor |
| 4 | Heavy Ball Instability | Polyak HB optimal on quadratics, assumed to extend to smooth strongly convex | Construct `(L/2)x^2 - (L-mu) ln cosh(x)` with `f''(0)=mu, f''(inf)=L`; period-4 cycle | Curvature-transition counterexample via ln cosh smooth step |
| 5 | SAM Convergence Flat Minima | SAM empirically successful but no clean nonconvex rate matching its objective | Normalized-grad surrogate is `2 L rho` away from true Danskin gradient | Approximate gradient + Young's gives `O(L/T)+O(epsilon^2)` two-term bound |
| 6 | Lookahead Optimizer | Lookahead empirically reduces variance; quantify the `alpha^2 k` factor | Outer step is polynomial in symmetric `A`; collapses to scalar `m(lambda)` | Polynomial-in-symmetric-matrix collapses to scalar analysis |
| 7 | Synchronous Q-Learning | Asymptotic convergence known for decades; need tight finite-time `(1-gamma)^{-4}` rate | Linearize `Delta=L+R`; clean Azuma on `L`, deterministic coupling on `R` | Linearize-then-couple template for nonlinear stochastic recursions |

### Optimization / Convergence Part 2 (Agent 2, 8 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 8 | OGDA bilinear last-iterate | Vanilla GDA cycles on bilinear; what is smallest fix that converges? | Identity `||z'||^2 = ||z||^2 + ||delta'-delta||^2 - ||delta||^2` from skew-symmetry + linearity | Skew-symmetry exploitation: iterate-norm + difference-term Lyapunov |
| 9 | TD(0) linear FA finite-time | TD(0) converges asymptotically (1997); finite-time rate open until 2018 | Symmetric part `A_s succeq (1-gamma) Phi^T D_pi Phi succ 0` via stationarity | Symmetric-part PD gives contraction in non-symmetric SA |
| 10 | Entropy-Reg NPG (variant) | Cen et al rate `(1-eta tau)` is fragile to gauge choice in log-policy | Replace `linf` by gauge-invariant centered seminorm `||xi||_c` | Gauge-invariant norms when working modulo group action |
| 11 | GDA NC-strongly-concave | Single-loop GDA on NCSC minimax: what is the iteration complexity? | Descend on envelope `Phi=max_y f`, Lyapunov `Phi(x)+c delta` with `c=L/(4 kappa)` | Envelope-based descent + two-time-scale Lyapunov coupling |
| 12 | Softmax PG sublinear | Softmax PG is non-convex; surprisingly enjoys Lojasiewicz with `c_*=min pi(a*|s)` | Sign-robust Cauchy-Schwarz on squared advantages plus `c_inf>0` hitting-time | Non-uniform Lojasiewicz with state-dependent constant |
| 13 | Q-learning UCB-Hoeffding | Model-free Q-learning thought to need full models for PAC-MDP | Step-size `(H+1)/(H+t)` makes `sum alpha^i_t = 1+1/H` exactly; layer factor `e` | Engineer step size to make cumulative weight identity closed-form |
| 14 | SVRG non-SC last-iterate gap | Does SVRG last iterate inherit snapshot rate or pay log m? | Within-epoch SVRG = SGD with `O(L^2)` non-vanishing variance; HLL-R applies | Last-iterate vs averaged gap is `Theta(log m)` whenever proof needs averaging |
| 15 | Polyak-Ruppert SHB defeats cycling | Does linear-weighted averaging escape SHB's K-gon cycle? | Complexify `R^2 -> C`, sum `t omega^t` is `O(T)` while `W_T = Theta(T^2)` | Complexification of 2D rotational dynamics + arithmetico-geometric sum |

### Optimization / Stochastic (Agent 3, 7 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 16 | SPS-SGD Convergence | Stochastic Polyak step is computable when `f_i^*=0`; does it converge? | SPS makes `gamma_k^2 ||g||^2 = gamma_k f_{i_k}/c`, the quadratic matches descent | Self-tuning step sizes that produce algebraic cancellations |
| 17 | Clipped SGD heavy-tailed | Standard SGD needs bounded variance; what rate when only `p<2` moments exist? | Surrogate `phi_t=min(||g||^2, tau||g||)`; recover `||g||^2` separately when `tau>=2 sigma` | Surrogate-then-recover with conservative threshold gap |
| 18 | SGD PL+Interpolation+Avg | Per-iterate PL-SGD rate `O(1/t)`; does Polyak-Ruppert give polynomial speedup? | Quadratic ansatz `e_t <= t_0^2/(t+t_0)^2` closes under multiplicative noise | Quadratic induction for SGD with multiplicative noise |
| 19 | Momentum SGD Interp v1 | Vanilla SGD-interpolation linear rate; does Polyak momentum preserve it? | Joint `(||e||^2, ||s||^2)` recursion; Perron-Frobenius eigenvector `(1, 1/kappa^2)` | Joint-state Lyapunov + Perron-Frobenius certificate |
| 20 | Momentum SGD Interp v2 | Same theorem; can `alpha=1/2` co-coercivity split kill variance exactly? | At `gamma=1/(4L), alpha=1/2`, variance coefficient `A_S=4 gamma^2 - gamma/L = 0` | alpha-split co-coercivity to zero a target coefficient |
| 21 | Momentum SGD Interp v3 | Push step to `gamma=1/L` (deterministic-GD step); does cancellation survive? | Same alpha-split mechanism; budget-allocate `mu/(8L)` per perturbation Young | Budget-allocation analysis with named per-term Young portions |
| 22 | Momentum SGD Spectral | Lyapunov gives `1/kappa^2`; can spectral analysis recover `1/kappa` GD rate? | Integral-Hessian linearization `nabla f_i = H_i e`; Markov-jump linear systems | Integral Hessian linearization under interpolation |

### Variance Reduction + Adaptive Methods (Agent 4, 7 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 23 | SPIDER Nonconvex | SVRG stuck at `n^{2/3}/eps^2`; chase conjectured `sqrt n/eps^2` lower bound | Polarization (not Young) exposes free `-||v||^2` that absorbs displacement variance | Polarization-over-Young to expose negative absorbers |
| 24 | SPIDER/SARAH (sibling) | Same `sqrt n` rate via Young + self-bounding instead of polarization | Self-bounding `V <= c(G+V)` rearranges when step `eta=O(1/(L sqrt q))` shrinks | Self-bounding inequalities solved by isolate-and-divide |
| 25 | STORM Nonconvex | SPIDER needs known `n` and full gradients; can a streaming version match it? | EMA correction with Lyapunov coupling `c=eta/(2a)` zeros error coefficient exactly | Soft EMA resets + exact-cancellation Lyapunov coupling |
| 26 | PAGE Optimal Complexity | SPIDER/STORM use different machinery; can probabilistic mixing unify? | Bernoulli(`p=1/sqrt n`) reset gives clean geometric variance recursion `1-p` | Randomization-as-simplification: Bernoulli replaces deterministic schedules |
| 27 | Adam Nonconvex | Adam can diverge (Reddi); under what nonconvex conditions does it converge? | `beta_1^2 <= beta_2` implies `hat m^2 <= hat v` so `||D_t||^2 <= d` | Jensen on EMA weights for momentum-vs-second-moment domination |
| 28 | AMSGrad Nonconvex | Adam denominator correlates with numerator; does monotone `hat v` fix it? | Use predictable surrogate `hat v_{t-1}`; correction bounded by monotonicity + `sqrt` subadd | Predictable-surrogate trick to restore martingale structure |
| 29 | AdaGrad-Norm Nonconvex | AdaGrad regret known online-convex; what is nonconvex SGD analog? | `1/b_k^2 - 1/b_{k+1}^2 = ||g||^2/(b_k^2 b_{k+1}^2)` shifts index for free | Algebraic index-shifting via telescoping identities |

### SHB Lower Bounds + Splitting + ULA (Agent 5, 9 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 30 | SHB no-acceleration restricted | Numerical sweep: cycling fails at standard `(beta,eta)` pairs; literal claim false | Restrict quantifier to algebraic feasibility region `F` where Goujaud cycle works | Restricted-quantifier rescue when literal theorem empirically false |
| 31 | SHB cycling critical momentum | Closed-form `gamma_3(beta)` factors unexpectedly cleanly; chase quadratic threshold | All `c_K`-dependence collapses to coefficient `1-c_K`, threshold `(sqrt 13 - 3)/2` | Conjugate-rationalization for hidden monotonicity |
| 32 | SHB interpolation regime LB | Does OP-2 lower bound survive when noise vanishes at optimum? | Noiseless oracle is admissible (transfers bias); quadratic + multiplicative noise kills variance | Algorithm-existential refutation: exhibit one algorithm beating bound |
| 33 | SHB best-iterate LB | Does last-iterate LB transfer to `min_t f(x_t)`? | Cycle is uniform so bias transfers; Le Cam test on `arg min` is near-perfect, voids variance | Min-vs-last asymmetry: Le Cam tests are iterate-specific |
| 34 | Douglas-Rachford O(1/k) | DR operator has telescoping form suggesting averaged structure | `T_DR = (Id + R_A R_B)/2` is averaged, hence firmly nonexpansive automatically | Averaged-operator template `(Id+N)/2` gives Fejer for free |
| 35 | Chambolle-Pock PDHG | Pre-2010 saddle-point lacked tight `O(1/N)` with simple step conditions | `tau sigma L^2 < 1` is Schur condition AND cancels extrapolation cross term | Step-size = positive definiteness = cross-term cancellation |
| 36 | Davis-Yin three-op (variant) | Original DYS uses external averagedness lemma; honest variant with local algebra | Restrict to `gamma <= 1/beta` where residual coefficient auto non-positive | Honest variant when full theorem requires black-box lemma |
| 37 | ADMM ergodic O(1/T) | He-Yuan: ADMM is preconditioned proximal point; find clean Lyapunov | Lagged dual `bar lambda = (1/T) sum_{k=0}^{T-1} lambda^k` aligns Jensen | Lagged-iterate ergodic averaging + perfect-square absorption |
| 38 | ULA KL convergence (LSI) | Wasserstein analyses fail under LSI; need to bound KL directly | Synchronous coupling + Girsanov gives clean path-KL of squared drift difference | Couple + Girsanov + data processing for SDE discretization |

### NTK / Approximation / Implicit Bias (Agent 6, 7 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 39 | NTK Gram PD | Need quantitative `lambda_min(H_inf)>0` for NTK convergence | Quadratic form = `E||sum c_i 1{w^T x_i>=0} x_i||^2`; reduces to hyperplane-cell combinatorics | Quadratic form = expectation of squared norm with feature map |
| 40 | Transformer Self-Attention Lipschitz | Generalization bounds need attention Lip constant; softmax dependence is twice | Softmax Jacobian = LSE Hessian, spectral norm exactly `1/2`; bilinear gives `R^2` scaling | Product-rule decomposition + Jacobian spectral bound |
| 41 | Denoising Score Matching equivalence | Explicit score matching needs unknown `nabla log q_sigma` | Score-of-mixture identity: `nabla log q = E_{p(y|x)}[nabla log p(x|y)]` (Bayes swap) | Reparameterize unknown target as tractable conditional expectation |
| 42 | NTK Infinite-Width Convergence | Empirical NTK = average of rank-one Hadamard; chase tight `1/sqrt m` | Schur lemma: PSD unit-diag `G` doesn't increase op-norm; matrix Bernstein gives `log n` | Hadamard-product peel-off; matrix Bernstein > entry+union |
| 43 | Quantitative ReLU UAT | Cybenko/Hornik give density but no rate; need `N(eps,L,d)` | Kuhn triangulation: conformal across faces, `d! M^d` simplices = `d! (L/eps)^d` neurons | Piecewise-linear interpolation on structured mesh + CPL-to-ReLU |
| 44 | GD Implicit Bias Max-Margin | Empirically `w_t/||w_t||` -> SVM solution with logistic loss | Exponential tail makes gradient self-bootstrap onto support vectors; KKT is steady state | Direction of divergence carries the bias; self-bounding `L^2` Lyapunov |
| 45 | Depth Separation Radial | Eldan-Shamir conjecture: 2-layer needs `exp(d)` width for ball indicator | Funk-Hecke: per-neuron radial projection attenuated by `1/sqrt N(d, sqrt d)` | Frequency analysis of target vs basis-function expressivity |

### Bandits / PAC-Bayes / Diffusion (Agent 7, 7 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 46 | EXP3 Adversarial Bandit | Hedge gives full-info; can it survive bandit feedback? | Importance-weight estimator + forced exploration `gamma/K` keeps `1/p_t` bounded | Deterministic pathwise inequality + take expectation |
| 47 | Tweedie's Formula | Gaussian convolution score has clean form because Gaussian score is linear | Differentiate `p_sigma`, recognize `p(y) phi(x-y)/p_sigma(x)` is posterior `p(y|x)` | Convolution + gradient + Bayes for score of smoothed measure |
| 48 | OFUL Linear Bandit | Auer/DHK gave `d sqrt T log^{3/2} T`; chase tight `tilde O(d sqrt T)` | Method of mixtures: integrate exponential supermartingale against Gaussian prior | Method of mixtures gives uniform-in-parameter Chernoff for free |
| 49 | Catoni PAC-Bayes | McAllester `sqrt(KL/n)` not sharp at small empirical risk | Engineer `phi_S` with sub-Bernoulli correction so `E e^{phi} <= 1` exactly | Engineered exponential moment + Donsker-Varadhan |
| 50 | Thompson Sampling Bernoulli | TS heuristic since 1933, no regret bound; chase `O(sqrt(KT log T))` | Inflation lemma relates pull-bad-arm to pull-best via random `(1-p_t)/p_t` | Decompose by good event x pivot threshold |
| 51 | Xu-Raginsky / BZV MI Gen | Russo-Zou bounds bias; can MI bound general algorithm gap? | Generalization gap = expectation of `joint - product` law; DV + sub-Gaussian transport | Per-sample decomposition + Jensen on sqrt for MI bounds |
| 52 | Matrix CE vs CE Generalization | Empirically MCE pretraining beats CE; what is the mechanism? | MCE is functional of empirical covariance; matrix Bernstein gives `r_eff` not `d` | Intrinsic-dim matrix concentration beats scalar Hoeffding (low-rank) |

### SSL Theory (Agent 8, 5 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 53 | Spectral Gap InfoNCE Downstream | HaoChen/Tan reduce InfoNCE to spectral but no quantitative projection error | Block parameterize `F=U_k A + U_perp B`, analytic `A`-min reveals sharpness `2 delta` (not 4) | Gauge-fix one block, eliminate analytically for sharper constants |
| 54 | SSL Augmentation Phase Transition | Conjecture claimed first-order discontinuity in `sigma_aug` | Gaussian-of-Gaussian gives `tau_eff^2`; gap `g(sigma) = n(1-rho)` is real-analytic, not first-order | Conjecture-rescue: scaling right but order wrong |
| 55 | Matrix Renyi Collapse Detection | Borrow Renyi/PL Lyapunov for representation-collapse diagnosis | Trace-free part `R(K) = nabla S - (alpha/(1-alpha)) I` makes entropy-PL inequality hold | Trace-free projection trick on constrained-manifold gradient flows |
| 56 | SSL InfoNCE Minimax LB | Routes 1-3 hit `d/(nI)` ceiling; numerics show `d^2/(nI)` empirically | Pack `SO(d)` (dim `d^2`) for `f^*`, align `w^*` for extra-`d` Schur amplification | Joint adversary: pack richer parameter space for higher rate |
| 57 | OT-Contrastive Characterization | Conjecture: spectral-contrastive minimizers = OT-cluster minimizers | True only under H1 block-diag W + H2 spectral gap + H3 regular blocks/uniform prior | Almost-true under hidden hypotheses; explicit minimal counterexample |

### Stability + High-Dim Stats (Agent 9, 7 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 58 | SGD Uniform Stability (HRS) | VC bounds say nothing about which algorithm; SGD generalizes far better | Couple SGD on neighbor datasets via shared index; co-coercivity makes step non-expansive on `(n-1)/n` | Couple-and-track distance under shared randomness |
| 59 | DP Implies Generalization | DP `(eps,delta)` looks structurally identical to algorithmic stability | Hockey-stick decomposition splits DP into bounded-ratio + rare-leakage pieces | Divergence-based stability is divergence-agnostic |
| 60 | SGD Signal-Noise Decomp | HRS `L^2 eta T/n` is loose; only noise should drive divergence | Push gradient split `nabla L_S + nabla L_N` inside per-step recursion; signal annihilates | Push decomposition inside the recursion, not at outcome |
| 61 | Adversarial Trajectory Tradeoff | Can stability framework explain why adversarial training stops earlier? | Mixed Hessian bridges parameter motion `sqrt(T eta)` to data-gradient growth; argmin shifts left | Mixed-Hessian as bridge; argmin-shift lemma for U+monotone |
| 62 | Heavy-Tailed Trajectory Decomp | All stability bounds need sub-Gaussian; what if only `p`-th moments? | Lift HRS to `L^p` via `(a+b)^p <= 2^{p-1}(...)`; Marcinkiewicz-Zygmund + clipping | Moment-level coupling + MZ as heavy-tail BDG substitute |
| 63 | Double Descent Threshold | Test error peaks at `n=p` then descends; classical U-curve broken | At `gamma=1` Marchenko-Pastur smallest singular value collapses; `tr((Z^T Z)^{-1}) = d/(n-d-1)` | Closed-form-and-pray on toy linear models for hidden phenomena |
| 64 | LASSO Restricted Eigenvalue | LASSO recovers sparse signals when `p >> n`; what property of `X` works? | KKT generates cone `||Delta_{S^c}||_1 <= 3 ||Delta_S||_1`; need RE only on cone | Restricted-geometry: name the constraint cone, then compute |

### Multi-Agent Verification (Agent 10, 5 proofs)

| # | Proof | Spark (<=15 words) | Key Insight (<=20 words) | Transferable Pattern (<=15 words) |
|---|---|---|---|---|
| 65 | Multi-Agent Verification Error Prop | Single-shot verifier gives 22% reliability; can we cheaply amplify? | k independent retries make per-round residual `eps^k`; product form is tight | Independence-then-product-then-amplify for binary pipelines |
| 66 | Categorical Functorial Error Prop | Verifier as natural transformation invites Lawvere-enriched categories | Lawvere `[0,inf]`-enrichment makes `||eta||_inf = d_{[C,D]}(F,G)` definitional | Choose enrichment so non-expansion = M-functoriality |
| 67 | CR Compositional Reuse | DAG-vs-tree comparison: nobody quantified verified-library reuse | Tree-unfold count `N(d, Delta) = (Delta^{d+1}-1)/(Delta-1)` corrects user's `Delta^d` | Library-first amortisation: verify once at lemma level |
| 68 | CR Depth Lower Bound | Match `(1-eps^k)^T` upper bound with verifier-call lower bound | Yao + per-level Bayes-optimal binary test; all-tail prob `(1/2) eps^{T_l}` | Yao + Bayes-error per level + sum across levels |
| 69 | CR Non-Stationary Verifier | Practice: verifier degrades with chain length; what does `(1-eps_t)` give? | `log(1-eps_t)` -> integral; `t^alpha` integrability gives phase transition at `alpha=1` | Log-product -> integral -> integrability phase transition |

---

## Section 2: Frequency Analysis

### (a) Spark Distribution

Counts and percentages over 69 proofs (each proof tagged with its single primary spark; secondary sparks noted in agent reports but not double-counted).

| Spark Type | Count | % | Notes / Topic Skew |
|---|---|---|---|
| pattern-spotted | 22 | 31.9% | Heavily represented in optimization/convergence (proofs 2, 3, 6, 12, 15, 16, 20, 21) and approximation/NTK (39, 42, 44, 47); the "I noticed an algebraic identity" trigger |
| gap-in-literature | 19 | 27.5% | Dominates research-paper proofs (5, 9, 13, 23, 39 NTK PD, 43, 45, 48, 50, 51, 52, 53, 60, 62, 64, 67); the canonical "best-known result is loose" motivation |
| failure-of-natural-approach | 15 | 21.7% | Concentrates in lower bounds & adversarial settings (4, 8, 17, 25, 27, 28, 30, 36, 41, 49, 54, 57, 58); "tried X, found ~X" |
| question-asked | 8 | 11.6% | Foundational questions about algorithm behavior (7 sync-Q is partial overlap, 11 GDA, 22 spectral momentum, 32, 33, 45 Eldan-Shamir, 61, 68) |
| analogy-from-other-field | 5 | 7.2% | Rare but distinctive: 1 (NPG=mirror descent), 38 (Girsanov from SDE), 46 (Hedge to bandit via importance), 51 (MI to generalization), 59 (DP to stability), 66 (Lawvere) |

**Topic correlations:**
- **Lower bounds** (proofs 14, 30-33, 45, 56, 68): 7/8 are *failure-driven* or *question-asked*; 0 are pure pattern-spotting. Lower bounds *require* the "natural approach must fail" frame.
- **Approximation/structural results** (39, 42, 43, 44, 45): 4/5 use *pattern-spotting* or *analogy*. The "I see a hidden structure" mode dominates.
- **SSL conjectures** (53-57): 3/5 are *failure-of-natural-approach* with literal claims REFUTED. The conjecture-generation regime self-selects for rescue patterns.
- **Multi-agent meta-proofs** (65-69): 1 of each type, plus all five share an empirical-observation-of-own-system origin.

### (b) Technique Frequency

The 12 most-recurring mathematical techniques, with example proof numbers.

| Technique | Count | Example Proofs |
|---|---|---|
| Lyapunov function (joint, weighted, scaled) | 28 | 4, 5, 8, 9, 11, 14, 15, 19-22, 25, 27-29, 31, 35-38, 58, 60-62, 65-69 |
| Telescoping (descent / variance / Lyapunov) | 26 | 1, 3, 5, 11, 16-29, 34, 35, 37, 38, 49 |
| Polarization / 3-point identity | 18 | 1, 8, 23, 25-29, 35-37, 53, 60 |
| Donsker-Varadhan / variational formula | 9 | 1, 2, 13 (DV-flavor), 48, 49, 51, 55, 67, 69 |
| Coupling argument (synchronous / shared-noise) | 8 | 7, 19-22, 38, 58, 60, 62 |
| Exponential supermartingale + Markov / Ville | 7 | 46, 48, 49, 51, 52, 67, 68 |
| Descent lemma (smoothness) | 21 | 5, 7, 11, 16-29, 60 |
| Bregman / KL three-point identity | 8 | 1, 2, 10, 13 (NPG-mirror), 49 |
| Eckart-Young / spectral / Schur PSD | 9 | 6, 9, 39, 42, 53, 55, 57, 63, 64 |
| Matrix Bernstein (with intrinsic dim) | 4 | 42, 52, 63 (Wishart adjacent), 69 (compositional adjacent) |
| Fixed-point iteration / Banach contraction | 7 | 2, 9, 28, 34-37, 66 |
| Marchenko-Pastur / random-matrix asymptotics | 3 | 56 (SO(d) packing adjacent), 63, 42 |
| Sub-Gaussian / Hoeffding / Azuma concentration | 16 | 1, 7, 13, 17, 23-26, 27-28, 46, 49, 50, 51, 64 |
| Danskin's theorem / envelope | 4 | 5, 11, 35 (PDHG envelope), 50 (envelope adjacent) |
| Funk-Hecke / harmonic analysis on sphere | 1 | 45 |
| Girsanov / Itô / SDE coupling | 2 | 38, 7 (SA limit) |

(Counts overlap because most proofs braid 3-5 techniques; the table reports primary uses.)

### (c) Meta-Strategy Frequency

The most-recurring "moves" — what the human actually *did*, irrespective of which technique they invoked. Eight strategies cover ~85% of the 69 proofs.

| Meta-Strategy | Count | Example Proofs |
|---|---|---|
| **Write the same quantity two ways then cancel** (one identity, one inequality, with one cross-term canceling) | 18 | 1 (KL), 5 (gradient mismatch), 7 (linearize-then-couple), 8 (skew-symmetry), 16 (SPS), 20-22 (alpha-split), 23 (polarization-over-Young), 25 (STORM exact c), 28 (predictable surrogate), 29 (index-shift), 35 (PDHG cancellation), 37 (perfect-square ADMM), 53 (gauge-fix block) |
| **Engineer exponential supermartingale, apply Markov/Ville** | 7 | 46, 48 (mixture method), 49 (Catoni), 51 (Xu-Raginsky), 52 (matrix Bernstein adjacent), 67, 68 |
| **Couple-and-track-distance under shared randomness** | 8 | 7, 38 (synchronous SDE), 58 (HRS), 60 (signal-noise inside coupling), 61, 62 (heavy-tailed coupling), 19, 22 |
| **Reduce to low-dim / structured / combinatorial space** | 11 | 6 (poly in symmetric matrix), 15 (complexify R^2), 39 (hyperplane cells), 40 (softmax variance), 42 (Hadamard peel), 43 (Kuhn simplex), 45 (Hermite shell), 53 (block decomposition), 55 (trace-free PSD), 64 (cone), 39 |
| **Design step-size / parameter so identity becomes closed-form** | 9 | 3 (constant `eta`), 7, 13 ((H+1)/(H+t) gives `1+1/H`), 20-22 (alpha=1/2), 25 (c=eta/(2a)), 27 (`alpha=alpha_0 T^{-1/4}`), 35 (`tau sigma L^2 < 1`), 38 (`h=alpha/(4L^2)`), 47 |
| **Restricted-quantifier rescue / honest-variant** (refute literal, prove what holds) | 8 | 10 (gauge-invariant rate), 30-33 (SHB lower-bound variants), 36 (DYS), 54-57 (SSL rescues), 68 |
| **Construct hard instance via adversarial polytope or sign-rotational geometry** | 6 | 4 (ln cosh curvature transition), 14 (SVRG Huber), 30-33 (Goujaud K-gon), 45 (radial step-at-median), 56 (SO(d) packing) |
| **Algorithm-design-as-proof-simplification** (the cleaner the algorithm the cleaner the proof) | 7 | 23 (recursive), 25 (EMA reset), 26 (Bernoulli reset), 28 (`hat v_{t-1}`), 29 (scalar `b_k`), 36 (DYS variant), 50 (TS pivot threshold) |

The first strategy alone covers 26% of all 69 proofs; the union of all eight covers approximately 85%.

---

## Section 3: Discovery Taxonomy

All 69 proofs are classified into the eight starting archetypes plus three new archetypes that emerged. A proof can fit multiple archetypes; multi-classification is noted.

### Gap-filling (count: 19)
Upper bound exists, no lower bound (or vice versa) — fill the missing direction or close the constant gap.
- 5 (SAM nonconvex rate), 9 (TD finite time), 13 (Q-learning UCB), 23 (SPIDER chasing `sqrt n`), 24 (sibling), 39 (NTK Gram PD), 41 (DSM), 43 (UAT quantitative), 45 (Eldan-Shamir 2 vs 3 layer), 48 (OFUL tight `d sqrt T`), 50 (TS regret), 51 (XR MI), 52 (matrix CE), 53 (InfoNCE projection error), 60 (signal-noise tighter than HRS), 62 (heavy-tail extension), 64 (LASSO RE), 67 (CR reuse quantification), 68 (CR depth LB to match UB)

### Analogy transfer (count: 8)
A technique from field A applied to field B for the first time.
- 1 (NPG = mirror descent from OCO), 38 (Girsanov from SDE to ULA), 46 (Hedge importance-weight from MC integration to bandits), 47 (Tweedie: Bayes + convolution to score matching), 48 (method of mixtures from self-normalized empirical-process to bandits), 51 (MI from adaptive data analysis to generalization), 59 (DP -> stability), 66 (Lawvere enriched categories to verifier semantics)

### Failure-driven (count: 15)
Tried to prove X, discovered ~X (or that the natural approach gives a strictly worse bound).
- 4 (heavy ball doesn't converge on smooth strongly convex), 8 (vanilla GDA cycles), 14 (SVRG last iterate has log m gap), 17 (clipped SGD discovery), 25 (SPIDER's rigidity), 28 (Adam's noise correlation), 30 (cycling fails outside `F`), 36 (DYS algebra fails for `gamma > 1/beta`), 49 (McAllester not sharp), 54 (no first-order transition), 56 (`d/(nI)` ceiling), 57 (literal OT-contrastive false), 58 (uniform convergence vacuous), 63 (U-curve broken), 64 (no full RE possible)

### Construction search (count: 11)
Find specific object with desired properties (counterexample, hard instance, Lyapunov template).
- 4 (`(L/2)x^2 - (L-mu) ln cosh`), 14 (Huber + decoupled `c_i`), 30-33 (Goujaud polytope variants), 43 (Kuhn triangulation), 45 (radial step at `chi^2_d` median), 54 (Dirac+Gaussian model), 56 (SO(d) packing), 57 (4-vertex two-clique counterexample)

### Generalization (count: 7)
Extend known result to broader setting.
- 2 (entropy regularization preserves Bellman contraction), 11 (GDA two-time-scale extends GD), 18 (Polyak-Ruppert under PL+interp), 26 (PAGE unifies SPIDER/STORM), 51 (BZV per-sample tightens XR), 60 (signal-noise generalizes HRS), 62 (heavy-tail generalization)

### Sharpening (count: 9)
Improve constants, weaken assumptions, or shift from average-iterate to last-iterate analyses.
- 3 (constant step removes `log T`), 10 (gauge-invariant honest rate), 12 (non-uniform Lojasiewicz sharpens softmax PG), 20-22 (alpha-split sharpens Lyapunov constants), 49 (Catoni sharpens McAllester), 53 (sharpness `2 delta` not `4 delta`)

### Self-referential (count: 5)
Theorem about the framework producing it.
- 65, 66, 67, 68, 69 (all five multi-agent proofs in agent 10's set)

### Calculation discovery (count: 6)
The "spark" is an algebraic identity nobody noticed before.
- 6 (`alpha^2/k` clean factor decomposition), 8 (identity (E)), 13 (`sum alpha^i_t = 1+1/H`), 16 (SPS cancellation), 29 (`1/b_k^2 - 1/b_{k+1}^2` shift), 47 (Tweedie's formula one-line emergence)

### NEW: Conjecture-rescue / hypothesis-tightening (count: 7)
Author of the work-stream restated the question after empirical refutation; the salvaged theorem is meaningfully weaker but still substantive.
- 10 (rate downgrade), 30, 33 (SHB variant restrictions), 36 (DYS variant), 54, 56 (joint adversary salvage), 57 (3 hypotheses)

### NEW: Restricted-geometry naming (count: 4)
Identify the smaller subset (cone, manifold, gauge orbit, polytope) on which the property holds.
- 39 (hyperplane cells), 64 (LASSO cone), 53 (top-k block), 55 (trace-free PSD subspace)

### NEW: Iteration-type asymmetry (count: 4)
Last-iterate vs averaged-iterate vs best-iterate behave qualitatively differently.
- 14 (last vs average gap), 15 (Polyak-Ruppert vs last on K-gon), 18 (averaging speedup under interp), 33 (best-iterate kills Le Cam)

**Cross-archetype overlaps (notable cases):**
- Proof 4 (Heavy Ball) is both *failure-driven* (proved divergence) and *construction search* (the `ln cosh` instance). The construction is the proof.
- Proofs 30-33 (SHB variants) are simultaneously *failure-driven* (numerical refutation), *construction search* (Goujaud variants), and *conjecture-rescue* (restricted quantifiers).
- Proof 56 (InfoNCE minimax) is *failure-driven* (initial routes hit `d/nI` ceiling), *construction search* (SO(d) packing), and *conjecture-rescue* (joint-adversary reinterpretation).
- Proof 38 (ULA) is both *analogy transfer* (Girsanov) and *gap-filling* (no direct Wasserstein analysis works under LSI alone).

Total accounting: every one of 69 proofs sits in at least one archetype; 41 sit in exactly one, 22 in two, 6 in three.

---

## Section 4: Meta-Insights for the Agent Framework

**Insight 1: The dominant meta-strategy across the library is "two bounds with cancelling cross-terms" (~26% of all proofs).** Proof 1 cancels `KL(pi'||pi)` between Bregman 3-pt and Donsker-Varadhan; SPIDER cancels `||v||^2` between descent lemma and polarization; STORM cancels error coefficient by tuning `c=eta/(2a)`; AMSGrad cancels noise correlation by predictable-surrogate substitution; PDHG cancels extrapolation cross-term by `tau sigma L^2 < 1`. The "creative leap" in convergence-rate proofs is almost never which Lyapunov template — it is identifying the *single algebraic identity* that lets two named bounds cancel cleanly, and Young's inequality is consistently the wrong move (it discards exactly the structure the identity would exploit).
**Implication for the Explorer agent:** maintain an explicit "Cancellation Patterns" library: each entry is a pair `(identity I, inequality J, shared term phi)` such that `I − J` telescopes. Before invoking Young's (the path of least resistance), the Explorer should run a search over this library and try cancellation-first. The Auditor should flag any use of Young's that *follows* a polarization-eligible inner product as a likely unforced loss.

**Insight 2: Lower bounds and adversarial-construction proofs are *uniformly* failure-driven and rely on a small number of canonical hard-instance templates** — Goujaud polytope (cycling), Huber + decoupled component (variance reduction), `ln cosh` (curvature transition), step-at-median radial (orthogonal-polynomial high-frequency), SO(d) packing (metric entropy `d^2`), and adversarial-alternative two-point binary tests. Construction was the proof for 11/69 entries; for lower bounds specifically, *every* proof either builds an adversarial polytope/cone or argues algorithm-existential refutation.
**Implication for the Scout:** when generating lower-bound or counterexample problems, the Scout should explicitly propose problems from a library of "adversarial-polytope archetypes" tagged by what they break (cycling, variance reduction, curvature, frequency, packing entropy). Generic problem-generation will systematically under-sample lower-bound instances because they are inherently failure-driven; the corpus shows that human researchers find them by stress-testing existing upper bounds, not by free generation.

**Insight 3: "Conjecture-rescue" emerged as a distinct discovery archetype (10% of proofs), invisible in textbook-paper aesthetics.** All five SSL proofs and three of four SHB lower-bound variants required the agent to refute the literal user-stated claim, then identify the maximal sub-region or hypothesis-set on which a related theorem holds. This is a *meta-substantive* contribution — not a failure mode — but the framework currently treats refutation as "PARTIAL" with no mechanical reward signal.
**Implication for the Auditor:** add a *honest-rescue score* axis distinct from pass/fail. Specifically: (a) was the literal claim verified? (b) if not, what minimal hypothesis-set was identified? (c) does the rescued theorem subsume a weakened version of the original numerically? Only rescues that satisfy all three should be filed in the research catalog, with the original conjecture explicitly listed as falsified. This converts the rescue trajectory from a defect into a publishable contribution.

**Insight 4: 7/69 proofs use the "engineered exponential supermartingale + Markov/Ville" template** (OFUL, Catoni, XR, Thompson Sampling adjacent, matrix-CE, both depth-related multi-agent proofs). Importantly, this template is *not* discoverable by trying generic Lyapunov candidates; it requires choosing the test function `phi_S(h)` so `E e^{phi} <= 1` exactly — an inverse-engineering problem. The corresponding template "couple-and-track distance under shared randomness" (8/69) is even more concentrated: proofs 7, 38, 58, 60, 61, 62 all instantiate the same chassis (Hardt-Recht-Singer 2016).
**Implication for the Explorer:** maintain *canonical proof templates* as first-class objects, not just techniques. The current architecture treats Lyapunov, polarization, etc. as flat techniques; instead, encode "couple + Girsanov + data-processing" or "Catoni MGF correction + Fubini + Markov" as *named meta-recipes* with slot-filling. The Explorer should try slot-filling against the top-10 recipes *before* attempting novel-structure search. Rough estimate: this would short-circuit at least 20-30 of the 69 proofs in the current library.

**Insight 5: A consistent pattern is "design-the-algorithm-for-proof-simplicity" (7 proofs in the VR/adaptive arc plus several others).** The variance-reduction quartet (SPIDER -> SARAH -> STORM -> PAGE) and the adaptive trio (Adam -> AMSGrad -> AdaGrad-Norm) are both *sequences of algorithmic simplifications driven by proof simplicity* rather than empirical performance. AdaGrad-Norm's scalar predictable `b_k` "solves the problem upstream" — the algorithm itself zeros the noise correlation. PAGE's Bernoulli reset replaces SPIDER's epoch boundaries to produce a clean geometric variance recursion.
**Implication for the Scout/Constructor:** when scouting research-grade problems, also generate *algorithm-design problems* explicitly: "find an algorithm A that has property P and admits a proof using only template T." This inverts the usual direction (algorithm given, prove rate) and lets the Scout chase clean proofs. Many of the most-cited modern optimization algorithms exist *because* a particular proof template (martingale, EMA, Bernoulli reset) made them analyzable.

**Insight 6: The technique-frequency tail is dominated by Lyapunov (28), descent lemma (21), telescoping (26), and polarization (18) — not by exotic machinery.** Funk-Hecke, Girsanov, and matrix Bernstein each appear in 1-4 proofs. The library's lesson: *deep results emerge from elementary tools applied to the right reduction*, not from exotic tools. Five of the seven approximation/NTK proofs (39, 40, 42, 43, 45) succeed by reducing high-dimensional questions to a structured low-dimensional space (cell, vector, shell, simplex) and then using elementary inequalities.
**Implication for the Fixer:** when a proof attempt fails, the Fixer's first move should not be "swap in a heavier technique" but "find a tighter reduction to a structured subspace." Add a "reduction search" step that asks: which of (combinatorial cells, harmonic shells, matrix subspaces, gauge orbits, restricted cones) captures the geometry of the iterate sequence? The data shows this is where 5/7 modern ML-theory results actually live.

---

**The single biggest lever.** If the Math Agent V2 framework adopts only one architectural change, it should be: **maintain a curated "canonical recipe library" of named meta-templates (cancellation pairs, exponential-supermartingale + Markov, couple-and-track, restricted-geometry-cone, alpha-split co-coercivity, Lagged-iterate ergodic averaging, gauge-invariant Lyapunov) and have the Explorer agent attempt slot-filling against this library *before* performing free Lyapunov search.** The frequency analysis is unambiguous: 7-8 named recipes account for ~85% of the 69 proofs, and the rest are either *new* recipes (genuine research) or hybrid combinations of existing ones. Currently the Explorer rediscovers the same template cold for each proof. A library-first Explorer would (i) short-circuit ~50 of the 69 proofs in seconds, (ii) free compute for the genuinely-novel 10-15, and (iii) automatically flag when a proof is "yet another Catoni-style application" versus "a genuinely new template" — surfacing exactly the discoveries worth A-class archival. Every other lever (better Auditor scoring, adversarial-construction Scout templates, refute-and-rescue scoring) is downstream of this one change.
