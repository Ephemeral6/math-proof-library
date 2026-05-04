# Fragments Library Index

> Harvested intermediate lemmas. Each fragment is a small, reusable result proved during
> a research proof attempt — typically a sub-lemma, sharp identity, or technical inequality
> with standalone reuse value beyond its parent proof.
>
> Search workflow: grep tags or browse by tag-cluster below.

## By tag cluster

### Convex analysis & inequalities
- [polarization-identity-gradient-error](polarization-identity-gradient-error.md) — exact decomposition $\langle\nabla f, v\rangle = \tfrac{1}{2}(\|v\|^2 + \|\nabla f\|^2 - \|e\|^2)$ that retains the negative $\|v\|^2$ term in the descent lemma (engine of SPIDER/STORM/PAGE)
- [bregman-three-point-kl](bregman-three-point-kl.md) — three-point identity $\sum(p-r)(\log q - \log r) = \mathrm{KL}(p\|r) - \mathrm{KL}(p\|q) + \mathrm{KL}(r\|q)$ for the negative entropy
- [cocoercivity-of-smooth-convex](cocoercivity-of-smooth-convex.md) — Baillon-Haddad: $\nabla g$ for convex $\beta$-smooth $g$ is $1/\beta$-cocoercive; gradient step is non-expansive for $\alpha \le 2/\beta$
- [softmax-jacobian-half-lipschitz](softmax-jacobian-half-lipschitz.md) — softmax is $1/2$-Lipschitz in $\ell_2$; Jacobian = $\mathrm{diag}(\sigma) - \sigma\sigma^\top$ has spectral norm $\le 1/2$
- [log-sum-exp-contraction](log-sum-exp-contraction.md) — LSE is 1-Lipschitz in $\ell_\infty$ (consequence: entropy-regularized Bellman is $\gamma$-contractive)
- [gibbs-variational-entropy](gibbs-variational-entropy.md) — $\mathrm{LSE}(z) = \max_\pi\{\langle\pi,z\rangle + H(\pi)\}$ with Gibbs maximizer; DV form for change of measure

### Probability / concentration / information theory
- [donsker-varadhan-variational](donsker-varadhan-variational.md) — variational characterization of KL: $\mathbb{E}_P[f] \le \log\mathbb{E}_Q[e^f] + \mathrm{KL}(P\|Q)$
- [sub-gaussian-transport-via-DV](sub-gaussian-transport-via-DV.md) — change-of-measure transport bound $|\mathbb{E}_P f - \mathbb{E}_Q f| \le \sqrt{2\sigma^2\mathrm{KL}(P\|Q)}$
- [hockey-stick-DP-expectation](hockey-stick-DP-expectation.md) — $(\varepsilon,\delta)$-DP indistinguishability $\Rightarrow$ expectation gap $\le (e^\varepsilon - 1) + \delta$
- [sub-bernoulli-mgf-chord-bound](sub-bernoulli-mgf-chord-bound.md) — $\mathbb{E}[e^{-uX}] \le 1 - \mu(1 - e^{-u})$ for $X \in [0,1]$ with mean $\mu$ (drives Catoni PAC-Bayes)
- [self-normalized-martingale-mixture](self-normalized-martingale-mixture.md) — Robbins' method of mixtures + Ville $\Rightarrow$ self-normalized concentration for ridge regression with adversarial design
- [beta-binomial-duality](beta-binomial-duality.md) — $\Pr(\mathrm{Beta}(s+1,f+1) \le y) = \Pr(\mathrm{Binom}(n+1, y) \ge s+1)$, plus Hoeffding-style Beta concentration
- [martingale-cancellation-via-conditional-expectation](martingale-cancellation-via-conditional-expectation.md) — kill SGD noise via $Z_t = -2\eta\xi_t\delta_t$ being a martingale-difference; canonical averaged-iterate proof template

### Optimization / Lyapunov / convergence
- [harmonic-recursion-lemma](harmonic-recursion-lemma.md) — $a_{t+1} \le a_t(1 - c a_t)$ implies $a_t \le 1/(ct)$ via $1/a_{t+1} - 1/a_t \ge c$
- [non-uniform-lojasiewicz-softmax](non-uniform-lojasiewicz-softmax.md) — softmax PG: $\|\nabla V\| \ge c_*(1-\gamma)\rho_{\min}/\sqrt{|\mathcal{S}|} \cdot \delta_t$ (sign-robust Cauchy-Schwarz)
- [lyapunov-bounded-iteration-SA](lyapunov-bounded-iteration-SA.md) — for SA recursion $v_{t+1} \le (1-2\mu\alpha_t + L^2\alpha_t^2)v_t + \sigma^2\alpha_t^2$, $w_t = (c+t)v_t$ has invariant set; $v_T = O(1/T)$
- [monotone-residual-O-1-over-k-FNE](monotone-residual-O-1-over-k-FNE.md) — FNE iteration $\Rightarrow$ Fejér + monotone residuals + telescope $\Rightarrow$ $\|z_k - z_{k-1}\|^2 \le D^2/k$
- [firmly-nonexpansive-implies-FNE-of-convex-combo](firmly-nonexpansive-implies-FNE-of-convex-combo.md) — averaging Id with a nonexpansive map gives FNE (parallelogram identity)
- [opial-weak-convergence](opial-weak-convergence.md) — Opial's weak convergence theorem + Browder demiclosedness (template for FNE iterations in Hilbert space)
- [heavy-ball-jordan-block-quadratic](heavy-ball-jordan-block-quadratic.md) — at optimal $(\alpha, \beta)$, the Heavy-Ball state matrix has a non-trivial Jordan block at $r = (\sqrt{\kappa}-1)/(\sqrt{\kappa}+1)$
- [storm-variance-recursion](storm-variance-recursion.md) — STORM error recursion $\mathbb{E}\|e_t\|^2 \le (1-a)\|e_{t-1}\|^2 + 2L^2\eta^2\|d_{t-1}\|^2 + 2a^2\sigma^2$
- [spider-variance-recursion](spider-variance-recursion.md) — SPIDER/SARAH error recursion $\mathbb{E}\|e_{t+1}\|^2 = \|e_t\|^2 + L^2\eta^2/b \cdot \|v_t\|^2$
- [bernoulli-reset-variance](bernoulli-reset-variance.md) — PAGE Bernoulli-reset variance recursion: $V_{t+1} \le (1-p)V_t + L^2\eta^2/b' \cdot \mathbb{E}\|g_t\|^2$
- [clipping-bias-positive-part](clipping-bias-positive-part.md) — clipping residual bound via sub-additivity of $(\cdot)_+$, used for heavy-tailed SGD

### Reinforcement learning / dynamic programming
- [performance-difference-lemma](performance-difference-lemma.md) — Kakade-Langford: $V^{\pi'}(\rho) - V^\pi(\rho) = \tfrac{1}{1-\gamma}\mathbb{E}_{s\sim d^{\pi'}_\rho}\sum_a\pi'(a|s)A^\pi(s,a)$
- [value-iteration-monotone-bracket](value-iteration-monotone-bracket.md) — soft Bellman fixed point bracket: $V^* \le V_\tau^* \le V^* + \tau\log A/(1-\gamma)\mathbf{1}$ via supersolution argument
- [symmetric-design-matrix-PD-cauchy](symmetric-design-matrix-PD-cauchy.md) — TD design matrix $A = \Phi^\top D_\pi\Phi - \gamma\Phi^\top D_\pi P_\pi\Phi$ has $A_s \succeq (1-\gamma)\Phi^\top D_\pi\Phi$ (stationarity + Cauchy-Schwarz)
- [posterior-dominance-thompson](posterior-dominance-thompson.md) — Thompson Sampling inflation: $\Pr(I_t = k, \theta_k < y_k) \le ((1-p_t)/p_t)\Pr(I_t = 1)$
- [jensen-mixing-cost-exp3](jensen-mixing-cost-exp3.md) — EXP3 $\gamma$-mixing cost bound + importance ratio $\tilde p_t/p_t \le 1/(1-\gamma)$

### SDE / sampling / score-based methods
- [langevin-KL-contraction-LSI](langevin-KL-contraction-LSI.md) — under $\alpha$-LSI: $\mathrm{KL}(\mu_t\|\pi) \le e^{-2\alpha(t-s)}\mathrm{KL}(\mu_s\|\pi)$ via de Bruijn + Grönwall
- [girsanov-path-KL](girsanov-path-KL.md) — path-space KL between two SDEs with shared noise: $\mathrm{KL}(P_{\tilde X}\|P_Y) = \tfrac{1}{4}\mathbb{E}\int\|b^{(1)} - b^{(2)}\|^2 dt$
- [score-of-mixture-via-leibniz](score-of-mixture-via-leibniz.md) — Tweedie/score-of-mixture identity: $\nabla_x\log q_\sigma(x) = \mathbb{E}_{p(y|x)}[\nabla_x\log p_\sigma(x|y)]$

### Random matrices / high-dimensional statistics
- [haar-invariant-projection-mean](haar-invariant-projection-mean.md) — for rotation-invariant random $X \in \mathbb{R}^{n\times d}$, $\mathbb{E}[I - P_X] = ((d-n)/d)I_d$
- [inverse-wishart-mean-trace](inverse-wishart-mean-trace.md) — $\mathbb{E}[W^{-1}] = I/(n-d-1)$ for $W \sim W_d(n, I_d)$, $n > d+1$
- [bias-variance-projection-min-norm](bias-variance-projection-min-norm.md) — orthogonal bias-variance decomposition for the min-norm pseudoinverse estimator
- [schur-product-hadamard-norm](schur-product-hadamard-norm.md) — for symmetric $M$ and PSD $G$ with unit diagonal: $\|M\circ G\|_{\mathrm{op}} \le \|M\|_{\mathrm{op}}$
- [transverse-sharpness-spectral-loss](transverse-sharpness-spectral-loss.md) — spectral contrastive loss has $\delta$-sharpness transverse to top-$k$ eigenspace under spectral gap $\delta$

### Linear bandits / regret analysis
- [elliptical-potential-lemma](elliptical-potential-lemma.md) — $\sum_t \|a_t\|_{V_{t-1}^{-1}}^2 \le 2d\log(1 + TL^2/(\lambda d))$ via $\det$-telescope + linearization on $[0,1]$

### Approximation theory / network expressivity
- [hyperplane-arrangement-adjacency](hyperplane-arrangement-adjacency.md) — for distinct hyperplanes, can flip any single coordinate of activation pattern while staying in positive-measure cells
- [kuhn-triangulation-CPL-relu](kuhn-triangulation-CPL-relu.md) — Kuhn triangulation $\Rightarrow$ piecewise-affine interpolant with $L\delta$ error and $d!\cdot M^d$ regions; basis for $O((L/\varepsilon)^d)$ ReLU width

## By source proof
| Source proof | Fragments harvested |
|---|---|
| `proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/` | polarization-identity-gradient-error, spider-variance-recursion |
| `proofs/research/optimization/stochastic/storm-nonconvex-convergence/` | storm-variance-recursion (also reuses polarization) |
| `proofs/research/optimization/stochastic/page-optimal-gradient-complexity/` | bernoulli-reset-variance (also reuses polarization & spider-recursion) |
| `proofs/research/optimization/stochastic/clipped-sgd-heavy-tail-convergence/` | clipping-bias-positive-part |
| `proofs/research/optimization/stochastic/spider-variance-reduction-nonconvex/` | (covered by spider-variance-recursion + polarization) |
| `proofs/research/optimization/convergence/sgd-last-iterate-averaged-baseline/` | martingale-cancellation-via-conditional-expectation |
| `proofs/research/optimization/convergence/heavy-ball-instability/` | heavy-ball-jordan-block-quadratic |
| `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/` | bregman-three-point-kl, performance-difference-lemma, gibbs-variational-entropy |
| `proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/` | non-uniform-lojasiewicz-softmax, harmonic-recursion-lemma, performance-difference-lemma |
| `proofs/research/optimization/convergence/td0-linear-approximation-convergence/` | symmetric-design-matrix-PD-cauchy, lyapunov-bounded-iteration-SA |
| `proofs/research/optimization/convergence/entropy-regularized-value-iteration/` | log-sum-exp-contraction, gibbs-variational-entropy, value-iteration-monotone-bracket |
| `proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/` | firmly-nonexpansive-implies-FNE-of-convex-combo, monotone-residual-O-1-over-k-FNE, opial-weak-convergence |
| `proofs/research/learning-theory/generalization/oful-linear-bandit-regret/` | self-normalized-martingale-mixture, elliptical-potential-lemma |
| `proofs/research/learning-theory/generalization/thompson-sampling-bernoulli-regret/` | beta-binomial-duality, posterior-dominance-thompson |
| `proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/` | jensen-mixing-cost-exp3 |
| `proofs/research/learning-theory/generalization/xu-raginsky-mi-generalization-bound/` | donsker-varadhan-variational, sub-gaussian-transport-via-DV |
| `proofs/research/learning-theory/generalization/catoni-pac-bayes-bound/` | sub-bernoulli-mgf-chord-bound, donsker-varadhan-variational |
| `proofs/research/learning-theory/generalization/transformer-attention-lipschitz/` | softmax-jacobian-half-lipschitz |
| `proofs/research/learning-theory/generalization/ntk-gram-matrix-positive-definiteness/` | hyperplane-arrangement-adjacency |
| `proofs/research/learning-theory/generalization/ntk-infinite-width-convergence/` | schur-product-hadamard-norm |
| `proofs/research/learning-theory/generalization/relu-universal-approximation-quantitative/` | kuhn-triangulation-CPL-relu |
| `proofs/research/learning-theory/generalization/spectral-gap-infonce-downstream/` | transverse-sharpness-spectral-loss |
| `proofs/research/learning-theory/generalization/denoising-score-matching-equivalence/` | score-of-mixture-via-leibniz |
| `proofs/research/learning-theory/generalization/tweedies-formula-diffusion-score/` | score-of-mixture-via-leibniz |
| `proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/` | cocoercivity-of-smooth-convex |
| `proofs/research/learning-theory/stability/dp-implies-generalization/` | hockey-stick-DP-expectation |
| `proofs/research/probability/sampling/ula-kl-convergence-lsi/` | langevin-KL-contraction-LSI, girsanov-path-KL |
| `proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/` | haar-invariant-projection-mean, inverse-wishart-mean-trace, bias-variance-projection-min-norm |

## Statistics
- **Total fragments**: 40
- **Verified** (passed Auditor in source proof): 38 | **Likely-correct** (clean derivation, no audit): 2 | **Unverified**: 0
- **Distinct source proofs**: 28
- **Top tag clusters by size**:
  1. Optimization / Lyapunov / convergence — 11 fragments
  2. Probability / concentration / information theory — 7 fragments
  3. Convex analysis & inequalities — 6 fragments
  4. Reinforcement learning / dynamic programming — 5 fragments
  5. Random matrices / high-dimensional statistics — 5 fragments

## Cross-reference notes
- **polarization-identity-gradient-error** is reused in **3** distinct proof families (SPIDER, STORM, PAGE).
- **donsker-varadhan-variational** appears as a lemma in **3** distinct proofs (Xu-Raginsky, NPG, Catoni).
- **performance-difference-lemma** appears in **2** softmax-PG proofs (sublinear and linear-rate).
- **score-of-mixture-via-leibniz** is the same identity in two diffusion proofs (DSM equivalence and Tweedie).
- **gibbs-variational-entropy** appears in soft-Q (entropy-reg VI) and NPG (Donsker-Varadhan form).
