# 失败模式数据库

### Coordinate Descent O(nL̄/ε) Rate — Route 1: Direct Descent + Telescoping (Euclidean norm)
- 技巧: Descent Lemma + Cauchy-Schwarz + Euclidean norm Lyapunov
- 卡在: Step 9: Converting weighted norm bound to Euclidean norm
- 原因: The natural Lyapunov analysis produces $\|x_0-x^*\|_L^2$ (weighted norm), and converting to $\|x_0-x^*\|^2$ via $\sum L_i(x_{0,i}-x_i^*)^2 \leq n\bar{L}\|x_0-x^*\|^2$ introduces an extra factor of $n$, yielding $n^2\bar{L}$ instead of $n\bar{L}$.
- 教训: For coordinate descent with non-uniform $L_i$, the natural bound is in the $L$-weighted norm; Euclidean norm results require importance sampling or accepting the $n$ factor loss.
- 日期: 2026-04-11

### Coordinate Descent O(nL̄/ε) Rate — Route 3: Nesterov Estimate Sequence
- 技巧: Estimate sequence + separable upper bound construction
- 卡在: Step 5: Setting up the estimate sequence with correct parameters
- 原因: The estimate sequence framework is over-complicated for this problem; the Lyapunov approach from Route 2/4 achieves the same result more directly.
- 教训: Estimate sequences are powerful but sometimes a direct Lyapunov function is both simpler and tighter for standard convergence rate proofs.
- 日期: 2026-04-11

### Implicit Bias of GD Max Margin — Route 3: Gradient Alignment + Norm Divergence
- 技巧: Gradient direction analysis + norm divergence + inner product growth comparison
- 卡在: Step 4: Linking gradient direction convergence to iterate direction convergence
- 原因: The gradient direction at $w_t$ depends on the margins, which depend on $w_t$ itself, creating a circular dependency. The gradient direction converging does not directly imply the cumulative iterate direction converges without tracking individual margin dynamics.
- 教训: For implicit bias proofs, aggregate gradient direction analysis is insufficient — must track per-data-point margin dynamics to break the coupling between iterate direction and gradient direction.
- 日期: 2026-04-12

### Implicit Bias of GD Max Margin — Route 4: Lyapunov / Potential Function
- 技巧: Angular potential $\cos\theta_t = \langle w_t, \hat{w}\rangle/\|w_t\|$ + growth rate comparison
- 卡在: Step 6: Tightening $\cos\theta_T \geq \gamma^*/R$ to $\cos\theta_T \to 1$
- 原因: The norm upper bound $\|w_{t+1}\| - \|w_t\| \leq \eta R S_t$ is too loose — it doesn't account for the alignment improving over time. Tightening requires analyzing the orthogonal gradient component, which needs the same per-data-point margin analysis.
- 教训: Simple Lyapunov functions on the angle/cosine give constant lower bounds but not convergence for implicit bias problems; the exponential weighting structure of the loss is essential and requires margin-level analysis.
- 日期: 2026-04-12

### Implicit Bias of GD Max Margin — Route 2: Dual Convergence via Implicit Regularization
- 技巧: Dual variable interpretation + implicit regularization path
- 卡在: Step 4: Margin equalization argument incomplete
- 原因: The dual perspective requires proving $C_i = \alpha_i^*$ (cumulative gradient contributions equal SVM dual variables), but the argument is circular without first establishing margin growth from the primal analysis.
- 教训: Dual-based implicit bias arguments are elegant for intuition but not self-contained — they ultimately require the primal KKT analysis from Route 1.
- 日期: 2026-04-12

### Fenchel Smoothness-Strong Convexity Duality — Route 1: Direct Duality via Surjectivity
- 技巧: Fenchel conjugate definition + surjectivity of $\nabla f$
- 卡在: Step 3: Proving surjectivity of $\nabla f$ for general L-smooth convex functions
- 原因: $\nabla f$ is not surjective in general (counterexample: $f(x_1,x_2) = \frac{L}{2}x_1^2$ has range $\{(Lx_1, 0)\}$). The route assumed strict convexity implicitly.
- 教训: When proving conjugate duality, always check if $\nabla f$ is surjective — this fails without strict convexity. The correct statement restricts to $\text{dom}(f^*)$.
- 日期: 2026-04-12

### Fenchel Smoothness-Strong Convexity Duality — Route 3: Domain Analysis
- 技巧: Domain restriction + structural analysis of $f^*$
- 卡在: Step 5: Completing the proof on $\text{int}(\text{dom}(f^*))$
- 原因: Correctly identified that $f^*$ may fail to be differentiable everywhere, but couldn't close the argument for strong convexity on the restricted domain.
- 教训: Domain issues in Fenchel duality are subtle — the key tool is cocoercivity of $\nabla f$ (proved from two-point quadratic upper bound), not direct domain analysis.
- 日期: 2026-04-12

### Bernstein's Inequality — Route 1: Bennett's Lemma Approach
- 技巧: Bennett's inequality → Bernstein as corollary
- 卡在: Step 3: Computing the Bennett function and simplifying
- 原因: Bennett's function $h(u) = (1+u)\log(1+u) - u$ is correct but the simplification to Bernstein's form via $h(u) \geq u^2/(2+2u/3)$ was attempted with false starts and algebraic confusion.
- 教训: Bennett → Bernstein is a valid route but the elementary bound on Bennett's function requires careful Taylor expansion or convexity argument — don't try to "eyeball" it.
- 日期: 2026-04-12

### Bernstein's Inequality — Route 3: Independent Approach (Collapsed)
- 技巧: Attempted novel approach, collapsed into Route 2
- 卡在: Step 2: Finding an independent proof strategy
- 原因: The explorer couldn't find a genuinely different approach and ended up reproducing Route 2's MGF analysis.
- 教训: For classical concentration inequalities, the MGF/Chernoff route is essentially unique — don't waste an explorer on "finding a different approach" when the standard route is already optimal.
- 日期: 2026-04-12

### SAM Convergence — Route 2: Lyapunov via $f(\tilde{x}_t)$
- 技巧: Lyapunov function $f(\tilde{x}_t)$ where $\tilde{x}_t = x_t + \rho\nabla f(x_t)/\|\nabla f(x_t)\|$
- 卡在: Step 4: Bounding $\|\hat{g}_{t+1} - \hat{g}_t\|$
- 原因: The crude bound $\|\hat{g}_{t+1} - \hat{g}_t\| \leq 2$ is correct but extremely loose, leading to constants 10-20x worse than Route 1.
- 教训: Lyapunov functions involving the SAM perturbation point $\tilde{x}_t$ suffer from loose gradient direction change bounds — the direct descent on $f^{SAM}$ via approximate Danskin gives much tighter constants.
- 日期: 2026-04-12

### Gradient Clipping Heavy-Tail — All Routes (Initial Attempt)
- 技巧: Multiple approaches attempted for clipped SGD under heavy-tail noise
- 卡在: Initial scout/explore phase — all routes failed in first attempt
- 原因: The problem requires careful case analysis (small vs large gradient) and a non-standard proxy stationarity measure $\phi = \min(\|\nabla f\|^2, \tau\|\nabla f\|)$, which none of the initial routes identified.
- 教训: Heavy-tail clipping proofs require a proxy stationarity measure — standard descent lemma + telescoping fails because the clipping bias doesn't telescope cleanly.
- 日期: 2026-04-04

### NTK Infinite-Width Convergence — Routes 1-3 (before Route 4 won)
- 技巧: Direct entry-wise analysis (Route 1), Markov/Chebyshev (Route 2), epsilon-net (Route 3)
- 卡在: Various steps — entry-wise doesn't give operator norm, Markov too loose, epsilon-net over-complicated
- 原因: Routes 1-3 failed to find the key insight: Schur product lemma $\|M \circ G\|_{op} \leq \|M\|_{op}$ absorbs the Gram matrix structure entirely, reducing to standard Matrix Bernstein.
- 教训: For NTK concentration, the Schur product lemma is essential — it's the structural insight that separates a clean O(n/√m) bound from a mess. Always check if matrix structure can be absorbed by known product inequalities.
- 日期: 2026-04-07

### PAC-Bayes Bound — Route 1 (First Attempt, Failed Audit)
- 技巧: Donsker-Varadhan + MGF + direct posterior optimization
- 卡在: Step 6: Making the posterior optimization uniform over all Q
- 原因: Without the λ-grid union bound trick, optimizing λ for each Q separately doesn't give a uniform bound. The fix requires discretizing λ on a grid and paying a union bound over grid points.
- 教训: PAC-Bayes proofs that optimize a free parameter (λ) for each posterior Q need a union bound over a grid of λ values — this is the key trick that makes the bound data-dependent yet uniform.
- 日期: 2026-04-07

### SGD PL+Interpolation Averaging — Routes 1-4 (before Route 5 won)
- 技巧: Various standard SGD analysis routes (descent lemma + averaging, Lyapunov, epoch doubling, etc.)
- 卡在: Separating the two phases (exponential decay then 1/t^2)
- 原因: Standard SGD analysis treats the entire trajectory uniformly, but the PL+interpolation setting has a natural phase transition: early exponential convergence (when f(x)-f* is large relative to noise) transitions to polynomial 1/t^2 convergence. Routes 1-4 couldn't capture this two-phase behavior.
- 教训: Under PL+interpolation, the noise is multiplicative (proportional to f(x)-f*), which creates a phase transition. The key is a direct recursive inequality with polynomial induction, not the standard Lyapunov approach.
- 日期: 2026-04-08

### STORM Non-Convex Convergence — Route 1: Lyapunov + Young's Inequality
- 技巧: Lyapunov V_t + Young's inequality on cross-term ⟨∇f, e⟩
- 卡在: Coefficient optimization — c=8L₁² is 2x larger than needed
- 原因: Young's inequality discards the structure of ⟨∇f, d⟩; expanding ‖d‖² then using Young's wastes the negative ‖d‖² from descent
- 教训: When descent retains -‖d‖², use polarization identity instead of Young's to avoid discarding it
- 日期: 2026-04-16

### STORM Non-Convex Convergence — Route 2: Direct Variance Recursion
- 技巧: Sum variance recursion separately, then combine with descent via coefficient absorption
- 卡在: Step 5: G ≤ ... + G coefficient absorption requires μ/4 < 1, forces c=16L₁² and messy constants
- 原因: Two-stage approach (sum S_e first, then combine) creates circular G dependency that needs careful absorption
- 教训: Joint Lyapunov approach is cleaner than separate recursion summation for coupled variance-descent systems
- 日期: 2026-04-16

### STORM Non-Convex Convergence — Route 3: Biased SGD Framework
- 技巧: Generic biased SGD framework with Lyapunov closure
- 卡在: Gradient coefficient only η/40 due to inflated c=20L̃² from mixing L and L₁
- 原因: Using L̃²=4(L₁²+L²) as a single constant is over-conservative; the L and L₁ contributions have different roles
- 教训: For STORM-type estimators, keep L₁ (mean-squared smoothness) separate from L (smoothness); don't lump them
- 日期: 2026-04-16

## FP-18: Auditor fails to detect contradiction between upper-bound claim and lower-bound claim

**发现日期**: 2026-04-17
**来源**: AdaGrad-Norm last-iterate 盲测（workspace/active/proof_work_20260417_adagrad_norm_last_iterate）

**症状**:
- problem.md 同时要求 UB = O(1/N^{1/4}) 和 LB = Ω(1/N^{1/4})
- Explorer Route 3 证出"更强"的 UB = O(log N / sqrt(N))
- Judge 把 Route 3 选为最佳（21/30）
- Auditor 对 Route 3 做了数值验证并通过
- 全流程没有任何阶段发现：O(log N / sqrt(N)) < Ω(1/N^{1/4}) 是一个渐近矛盾

**根本原因**:
1. Auditor 的数值验证是"正向"的——只检查算法是否收敛、bound 是否成立
2. Auditor 没有做"反向一致性检查"——即 agent 证出的结论是否与 problem.md 的其他陈述（尤其是 LB）在逻辑上兼容
3. Auditor 没有跑"adversarial sanity check"——即构造一个理论上应当 violate agent's bound 的最坏情形例子来反证
4. Judge 缺少 REJECT_ALL 选项，被迫在 5 条互相都有问题的路线中选"相对最好"

**具体的技术错误**:
Route 3 把 Shamir-Zhang suffix averaging（给的是 averaged iterate 的 bound）错误地应用于 last iterate。这是一个经典陷阱——suffix averaging 的 bound 只对 iterate average 有效，不能直接迁移到 last iterate。

**修复**:
- Auditor prompt 新增 Step 0.5 "反向一致性检查"（见 auditor.md）
- Judge prompt 新增 "Pre-Selection Gate" 和 REJECT_ALL 分支（见 judge.md）

**测试样本**（复现此失败的最小例子）:
problem.md 包含:
  - UB: f(x_N) - f* = O(1/N^{1/4})
  - LB: f(x_N) - f* = Ω(1/N^{1/4})
  - tightness: 两者匹配
Agent 证出:
  - UB': O(log N / sqrt(N))
期望行为（修复后）:
  - Auditor 应返回 FAIL_CONTRADICTION
  - Judge 应返回 REJECT_ALL

**影响范围**:
任何问题陈述同时含有 UB + LB + tightness 的研究级定理，都存在此风险。应用到库中：检查所有 research/ 证明是否经过了反向一致性检查。（建议后续做一次 library sweep）
- 日期: 2026-04-17

### SHB Bias-Term Lower Bound Ω(LD²/T) — Route C Arjevani + Nesterov tridiagonal
- 技巧: Resisting-oracle + Nesterov zero-chain tridiagonal quadratic
- 卡在: Step 3' claim Ω(LD²/T) on quadratic worst-case
- 原因: Polyak 1964 says HB with optimal fixed β achieves O(LD²/T²) by Chebyshev acceleration on *any* quadratic. So quadratic instances cannot witness a Ω(LD²/T) lower bound for the fixed-β SHB class. Empirical simulation (β=0.5, η=1/L) confirms gap·T² = O(1).
- 教训: Never use quadratics to witness a non-acceleration lower bound against fixed momentum — Chebyshev polynomials make quadratics too easy for HB. Need ∇²f(x*)=0 AND non-quadratic AND not-too-easy-for-plain-GD.
- 日期: 2026-04-17

### SHB Bias-Term Lower Bound Ω(LD²/T) — Route A hyperbola / log-cosh potential
- 技巧: Smooth convex potential Φ̃_D(u) = LD²(√(1+(u/D)²)−1) as non-quadratic 2D hard instance
- 卡在: Empirical SHB simulation reaches machine zero by T=100
- 原因: Φ̃''(0) = L — the potential is locally strongly convex near the optimum. Once iterates enter the region of curvature, Polyak's local Chebyshev acceleration kicks in and SHB accelerates at O(1/T²) locally. Any convex L-smooth function with ∇²f(x*) ≻ 0 admits this local acceleration.
- 教训: "Flat at the origin" is not enough — need ∇²f(x*) = 0 globally in a neighborhood, not just at the single point x*. Second-order Taylor expansion reveals the local strong convexity.
- 日期: 2026-04-17

### SHB Bias-Term Lower Bound Ω(LD²/T) — Goujaud cycling at μ → 0
- 技巧: Goujaud-Pedregosa-Taylor 2023 cycling construction ψ = (L/2)‖x‖² − ((L−μ)/2)·d(x, conv(P))² taken to μ = 0
- 卡在: Two independent failures:
  (1) Quantifier order: Goujaud proves ∀(β, γ) ∃f_{β,γ} cycling; the target theorem needs ∃f ∀(β, γ). The operator M in the construction depends on (β, γ).
  (2) Plain GD with η=1/L annihilates the function in one step in the interior-of-conv(P) regime (f(x_100) = 2.6×10⁻¹³¹), so the lower bound fails even against non-momentum methods.
- 原因: ∇²ψ(0) = L·I in the interior-of-conv(P) regime — same local Polyak-Chebyshev obstruction. Plus the quantifier-order gap is fundamental: Goujaud's adversarial function is method-specific.
- 教训: Cycling constructions from the strongly-convex setting do not pass to μ→0 in a quantifier-stable way. A uniform-over-β hard instance requires a fundamentally different idea than Goujaud's.
- 日期: 2026-04-17

### SHB Bias-Term — Meta-failure (all three routes)
- 共同技术障碍: Need a function in the "no-man's-land":
  (i) non-quadratic (so Polyak's global Chebyshev analysis fails),
  (ii) ∇²f(x*) = 0 in a neighborhood (so no local Chebyshev acceleration),
  (iii) plain GD itself does not beat Ω(LD²/T).
  No such explicit smooth convex function is known in the literature.
- 替代方向:
  (a) 弱化为 ∀-∃ 版本: ∀β ∃f_β. Goujaud cycling + μ→0 应可直接证明。
  (b) 算法类进一步限制: 固定 η_t ≡ η. 变为 LTI 滤波器的低频响应问题，PEP/IQC 可处理。
  (c) 利用 stochastic oracle 的非确定性: 重尾-方差-σ² 噪声阻止 Chebyshev 精确消除。
- 日期: 2026-04-17

### Benign Overfitting (Bartlett-Long-Lugosi-Tsigler 2020) — Meta-failure (all 5 routes)
- 技巧: Route 1 Matrix Bernstein | Route 2 whitening + Hanson-Wright | Route 3 Weyl + Woodbury | Route 4 Leave-One-Out/Sherman-Morrison | Retry: Gordon comparison
- 卡在: 所有路线都能证出 variance 半部 σ²(k*/n + n/R_{k*}(Σ))，但 bias 半部 ||β*||_Σ² · max{√(r_0/n), r_0/n, √(log n/n)} 全部失败
- 原因: bias bound 需要 Gordon-Slepian Gaussian comparison 不等式 (BLLT 2020 Lemma 11)。核心障碍: ξ = G β̃* 与 A = G Λ Gᵀ **coupled**，Hanson-Wright 不能直接应用；operator-norm bounds 只给出 B² (丢了 √(r_0/n) 因子)。
- 教训: **min-norm interpolator 的 bias bound 在各向异性 Σ 下本质需要 Gordon/Slepian 比较**。仅靠 concentration (Bernstein/Hanson-Wright) + whitening + Weyl interlacing + LOO 都无法复现 √(r_0/n) 因子。Route 4 的 leverage score 在 $p \ge n$ 下还 dimensionally ill-posed ($x_i \in \mathbb{R}^p$, $(XX^\top)^{-1} \in \mathbb{R}^{n \times n}$)。
- 可行重启方向: (a) 把 Gordon's theorem 作为黑箱引理引入 library/；(b) 弱化题目为 isotropic $\Sigma = I$ 情形；(c) 只证 variance 半部作为独立定理。
- 日期: 2026-04-17
