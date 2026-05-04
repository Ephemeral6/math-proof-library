# 失败模式数据库

> Schema updated 2026-04-20 to add a `domain` tag.  Single file, grep by tag.

## Entry template (v2.1)

Every new entry SHOULD follow this shape. Existing entries (before 2026-04-20) are grandfathered and may lack the `domain` field — grep will miss them for `domain: <x>` queries but they remain valid records.

```
## FP-N
**domain**: optimization | learning-theory | convex-analysis | statistics | probability | linear-algebra | low-dimensional-topology | ...
**subdomain**: stochastic | convergence | knot-theory | mapping-class-groups | ...
**theorem-context**: {brief identifier of the theorem being proved when failure occurred}
**technique**: {the specific technique attempted, e.g. "Lyapunov on perturbation", "Jones via skein from trefoil"}
**step-stuck**: Step N: {one-line description of where the attempt broke}
**reason**: {why it broke: missing structural insight, circular dependency, constant blow-up, etc.}
**lesson**: {the takeaway that future Scout/Explorer should use}
**date**: YYYY-MM-DD
```

Grep usage:
- All LDT failures: `grep -A6 "domain: low-dimensional-topology" failure_patterns.md`
- Failures in a subdomain: `grep -A6 "subdomain: knot-theory" failure_patterns.md`
- Failures involving a technique: `grep -B1 -A6 "technique: Lyapunov" failure_patterns.md`

---

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
- 技巧: Goujaud-Taylor-Dieuleveut 2023 cycling construction ψ = (L/2)‖x‖² − ((L−μ)/2)·d(x, conv(P))² taken to μ = 0
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

### Softmax PG O(1/t) Convergence — Route 2: PDL + Mean-Value
- 技巧: Performance Difference Lemma + mean-value theorem (claimed to avoid NU-Łojasiewicz)
- 卡在: Step 7: Sign-nonnegativity sub-lemma
- 原因: The "independence from NU-Łojasiewicz" is illusory — the Cauchy–Schwarz computation in Steps 6–7 is algebraically equivalent to the NU-Ł inequality of Route 1. The defer-to-Mei-Lemma-9 for sign nonnegativity is the same hard part Route 1 defers.
- 教训: Claims of a "new route" that still depend on the same external reference for the same hard step are not independent; they are relabelings. Check algebraic equivalence before declaring novelty.
- 日期: 2026-04-18

### Softmax PG O(1/t) Convergence — Route 3: KL Potential
- 技巧: KL divergence Lyapunov $\Psi_t = \mathrm{KL}(\pi^* \| \pi_t)$ + Pinsker-style lower bound
- 卡在: Step 6: Cannot close the Lyapunov loop $-\dot\Psi \ge \alpha\delta^2$
- 原因: Three simultaneous obstacles: (a) $A^\pi(s,a^*(s))$ can be negative pointwise, breaking the potential-decrease inequality; (b) Pinsker bounds KL from below by TV², NOT above by value gap — wrong direction for closing the loop; (c) vanilla PG lacks the Fisher-information preconditioning that makes the NPG Lyapunov closure work.
- 教训: KL-potential Lyapunov approach is intrinsically for NPG, not vanilla PG. Vanilla PG's geometry requires a gradient-norm-based Łojasiewicz inequality, not a distance-based Lyapunov.
- 日期: 2026-04-18

### Softmax PG O(1/t) Convergence — Route 4: Mirror Descent + NPG Comparison
- 技巧: Fisher-information spectral lower bound $\|\nabla V\|^2 \ge \lambda_{\min}^+(F) \|w^{\mathrm{NPG}}\|_F^2$ + NPG rate transfer
- 卡在: Step 4: Spectral comparison does not transfer NPG rate to PG
- 原因: Fisher-spectral comparison bounds the gradient norm by the NPG direction AT THE SAME ITERATE, but PG and NPG trajectories diverge over time. Route 4 ends up re-deriving NU-Łojasiewicz in Steps 6–7, identical to Route 1.
- 教训: Spectral comparison between two algorithms only transfers rates when the iterate trajectories coincide. Two algorithms sharing one-step geometry does not mean they share asymptotic convergence.
- 日期: 2026-04-18

### Softmax PG O(1/t) Convergence — Route 1 Fix Round 1: Step-9 constant redefinition
- 技巧: Rename $c_\infty' := c_\infty \cdot \rho_{\min} \cdot \sqrt{1-\gamma}$ to absorb ρ-dependence into the target $c_\infty^2 (1-\gamma)^6$ form
- 卡在: Algebra check: $(c_\infty')^2(1-\gamma)^6 = c_\infty^2\rho_{\min}^2(1-\gamma)^7$, but honest bound has $(1-\gamma)^5$ — off by $(1-\gamma)^2$
- 原因: The fixer tried to match problem.md's target form via constant redefinition without checking the algebra. SymPy verification in audit round 2 caught the $(1-\gamma)^2$ discrepancy.
- 教训: When restating a bound via renamed constants, always verify the algebraic equivalence symbolically. "Absorb ρ_min into c_∞" is a handwave that must be checked literally before use. Honest restatement (Option A) is almost always safer than renamed-constant (Option B) when target and derivation don't match naturally.
- 日期: 2026-04-18

### AdaGrad-Norm O(log T/√T) — Route 3: Lyapunov Potential $V_k = W_k + (L\eta^2/2) \sum_{i<k}\|g_i\|^2/b_i^2$
- 技巧: Lyapunov 势函数 + 一步不等式 + telescoping
- 卡在: Step 4: 建立势函数的一步下降不等式
- 原因: 势函数的 drift 不是内禀负的 — 仍需要通过 decoupling identity + log accumulator 来控制残余的 noise-curvature 项，这与 Route 1 的代数完全相同。诚实换汤不换药。
- 教训: 对于具有 $\mathcal{F}_k$-可测步长 $\eta/b_k$ 的 adaptive 算法，Lyapunov 重组并不带来新的分析能力，因为 cross-term 本来就自动零期望。Lyapunov 在这里只是记账方式不同。
- 日期: 2026-04-18

### AdaGrad-Norm O(log T/√T) — Route 4: Online-to-Batch via AdaGrad Regret
- 技巧: AdaGrad regret bound + online-to-batch reduction
- 卡在: Step 3: 从 regret 桥接到非凸 $f$ 的收敛
- 原因: 非凸 $f$ 下，$f(x_k)-f(u) \le \langle \nabla f(x_k), x_k-u\rangle$ 不成立（反例 $f=-Lx^2/2$）。descent-step comparator $u_k = x_k - (\eta/b_k)\nabla f(x_k)$ 随 $k$ 变化破坏了 regret lemma 的单 comparator telescoping。
- 教训: Online-to-batch reduction 本质依赖凸性（或至少 PL 条件）。非凸设定下应直接走 descent lemma，regret 框架只能作为副产品（adagrad-norm regret bound）存档。
- 日期: 2026-04-18

### Xu-Raginsky MI Bound — Route C: PAC-Bayes Reduction
- 技巧: McAllester/Catoni PAC-Bayes + I(W;S) = E_S[KL(P_{W|S}||P_W)]
- 卡在: Step 3: 从 joint sub-Gaussian 假设推出 joint MGF bound
- 原因: 题目只假设 P_W ⊗ D 下的 sub-Gaussianity，这并不等价于 "对固定 W，ℓ(W,Z) 在 Z 上 sub-Gaussian"。PAC-Bayes 的 joint MGF 需要后者。
- 教训: PAC-Bayes reduction 要求 per-hypothesis 的条件 MGF bound；当假设只是 joint 时，必须退回到 DV per-sample，此时 Route C 退化为 Route A/D。
- 日期: 2026-04-18

### ADMM ergodic O(1/T) (He-Yuan 2012) — Route 2 (DR-on-dual equivalence)
- 技巧: 把 ADMM 等价为对偶问题上的 Douglas-Rachford splitting（Gabay 1983 correspondence），用 DR 的 ergodic O(1/T) 证原命题
- 卡在: Stage D telescope 之后，对于**不可行**测试点，$H$-Lyapunov 吸收后留下 $-\tfrac{\beta}{T}\langle B(z^T-z^0),\tilde r\rangle$ 和一个 indexing-shift 项
- 原因: DR 的自然度量在对偶侧是 $\beta^{-1}I$ 上的欧氏度量，对原始侧的 $B$-加权残差不敏感
- 教训: 对偶等价路线能捕捉 DR 的 $\lambda$ 部分但天然缺 $B$ 部分；对任意测试点，原始 VI 路线比对偶等价路线更紧（它的 $-\tfrac12\|v^{k+1}-v^k\|_H^2$ 残差直接杀死 indexing-shift 项）
- 日期: 2026-04-18

### ADMM ergodic O(1/T) (He-Yuan 2012) — Route 4 (proximal-point in semi-norm)
- 技巧: 把 ADMM 一步看作 $H$-semi-norm 下的 proximal-point 步骤，调用抽象的 ergodic PP 定理
- 卡在: 不是 fail，但比 Route 3 长出一个抽象层；没有新的数学洞察
- 原因: 抽象 PP 框架要独立证明（因为 $H$ 只是 PSD 不是 PD，标准 PP ergodic 定理假设 PD），证完之后发现抽象定理和 Route 3 的"telescope + Jensen + skew-affine"是等价的
- 教训: 把 PP 抽象化这件事本身没错，但对单个问题没有复用价值（抽象定理的 `θ` 需要满足的假设在 ADMM 之外很少有非平凡例子）；仅当 proof library 中有 3+ 个 PSD-semi-norm PP 应用时才值得做这个抽象
- 日期: 2026-04-18

### Problem 3 meta-lesson — 4 个独立 Explorer 一致发现题面错误
- 观察: ADMM 原问题陈述对**任意**测试点声称 bound 成立，但 4 个 Explorer 独立给出同一个结论："需要 feasibility $A\tilde x+B\tilde z=c$"，Route 3 还给出了显式反例
- 教训: 并行 4 路 Explorer 的价值不只是找最强证明，还能靠"独立收敛"来发现 problem.md 的 bug；如果只跑一路，Route 1 的 VI 框架可能因为套用成熟模板而没注意到 feasibility 条件是藏在模板里的隐式假设。**一致性反馈比单路鲁棒性更难得。**
- 日期: 2026-04-18

### UCB-Hoeffding Q-learning regret (JABJ 2018) — Route B (Martingale-first / concentration-before-analysis)
- 技巧: 先建立全局 Azuma-Hoeffding 高概率事件 $\mathcal E$（覆盖所有 $(s,a,h,t)$ 的加权鞅），再在 $\mathcal E$ 上做纯 pathwise 的 Optimism 归纳和 regret decomposition
- 卡在: 最后的 $R_h$ 递推需要 $\sum_h$ 展开，缺少 visit-count exchange 带来的 $(1+1/H)$ 系数（identity L4），导致比 Route A 多出一个 $\sqrt H$
- 原因: Pathwise regret decomposition $\delta_h^k \le \phi_h^k + \delta_{h+1}^k + \eta_h^k$ 必须以显式 $\sum_h$ 形式展开；而 Route A 是把 Azuma 浓度直接插入 recursive Q-error expansion（Lemma A）里面，等于每一层都让 bonus 去吃噪声，这样层间传播只乘 $(1+1/H)$ 而不是 $H$
- 教训: "先浓度后确定性分析"这个漂亮的结构原则在 RL 里会付出一个 $\sqrt H$ 的代价；想拿 JABJ 最优率必须接受 Azuma 和 backward induction 的交织（pointwise 可读性差但技术上不可绕开）
- 日期: 2026-04-18

### UCB-Hoeffding Q-learning regret (JABJ 2018) — Route C (Advantage decomposition)
- 技巧: $\delta_h^k = \phi_h^k + A_h^{\pi_k,*}$ 分解，先用 optimism 把 $A\ge 0$ 消掉，再用 Bellman 展开 $A = \mathbb P_h(V_{h+1}^* - V_{h+1}^{\pi_k})$
- 卡在: Bellman 展开之后回到 $\delta_h^k \le \phi_h^k + \delta_{h+1}^k + \zeta_h^k$，与 Route A 的 value-difference identity 一字不差
- 原因: Advantage framing 没有引入新的代数结构；visit-count exchange 这一步是在 $\phi_h^k$ 的递归展开里发生的，与 outer $\delta_h^k$ 分解无关
- 教训: 改名字（advantage vs. value-difference）不改变底层代数；如果 winning route 的关键招在 inner loop（这里是 $\phi_h^k$ 展开的 visit exchange），那么 outer framing 再漂亮也救不回率；Softmax PG Routes 2-4 是同类失败模式
- 日期: 2026-04-18

### UCB-Hoeffding Q-learning regret (JABJ 2018) — Route D (Online-to-batch / expert reduction)
- 技巧: 把 Q-learning 的 $(s,a,h)$ cell 看作 OCO 的 expert，或者把 Bellman 残差看作 OCO loss
- 卡在: $H\ge 2$ 时四种还原路径（per-cell OGD / adversarial $V_{h+1}$ / 全局 Bellman-error OCO / expert advice）都失败
- 原因: Bellman 方程 $V_{h+1}(s) = \min\{H, \max_a Q_{h+1}(s,a)\}$ 中嵌套的 $\max$ 使得任何整体 OCO loss 非凸；online-to-batch 要求凸性（AdaGrad-Norm Route 4 同样卡在这里）
- 教训: RL 的 horizon 结构不能还原为 bandit + OCO；bandit ($H=1$) 可以，但 $H\ge 2$ 立刻失败；这是 RL 理论作为独立领域存在的根本技术原因
- 日期: 2026-04-18

### Problem 4 meta-lesson — Problem.md 的 bonus scale 错了
- 观察: 原 problem.md 写 $b_t = cH\sqrt{\iota/t}$，想证 $\sqrt{H^4 SAT}$；Routes B 和 C 独立发现这个 bonus 太小（至少需要 $cH^{3/2}\sqrt{\iota/t}$ = JABJ 2018 的实际设置）
- 教训: 这是第二次（第一次 ADMM）多路 Explorer 独立收敛发现 problem.md bug 的案例；"并行 4 路 + 看一致性"作为 problem-statement validation 手段正在变成一个可靠的模式
- 日期: 2026-04-18

## FP-KAUFFMAN-CONVENTION-2026-04-20
**domain**: low-dimensional-topology
**subdomain**: knot-invariants
**theorem-context**: TSV-Knot `kauffman_bracket` deriving <D> from a stored Jones polynomial V(q) for named knots
**technique**: Kauffman-Jones identity `<D> = (-A)^{3w(D)} V_L(t)|_{t = A^{-4}}`, substituted into the stored q-convention polynomial
**step-stuck**: Derivation substitution: code used `V.subs(q, A^{-4})` on a table whose Jones polynomial is stored in the q-convention (q = t^{-1}), so the correct substitution is `q = A^{+4}`. With the wrong sign, `kauffman_bracket("trefoil")` returned $A^{25} - A^{21} - A^{13}$ (marked `confidence=high`) instead of the textbook $-A^5 - A^{-3} + A^{-7}$.
**reason**: Two invariants (Jones and Kauffman bracket) related by a convention-sensitive identity — the table stores one in the q-convention while the derivation silently assumed the t-convention. No explicit contract between the table's convention and the derivation formula. The high-confidence tag reflects the code path executing cleanly, not the numerical correctness of the answer, so downstream callers (V2 Auditor cross-checks) trusted the wrong value.
**lesson**: When deriving invariant X from stored invariant Y via a convention-sensitive identity, (a) write an explicit convention contract in both docstrings, (b) verify against one worked textbook example (here: Kauffman 1987's 3_1 calculation or Lickorish Ch. 3's 4_1), and (c) gate the module with an assert-based self-test covering every stored entry. The high-confidence tag must reflect answer-correctness, not path-correctness — otherwise a silent convention bug propagates as "verified".
**date**: 2026-04-20

## FP-SPIRAL-BLOCK-CIRCULANT-BASIS-2026-04-20
**domain**: low-dimensional-topology
**subdomain**: knot-invariants
**theorem-context**: Alexander polynomial factorization for spiral knots S(p,q,ε) = closure of (σ_1^{ε_1}···σ_{p-1}^{ε_{p-1}})^q via direct Seifert-matrix computation
**technique**: Seifert's algorithm on braid-closure diagram, then exploit cyclic symmetry of the q-fold periodic braid to make the Seifert form block-circulant
**step-stuck**: Basis choice: in the natural "tree basis" α_{k,i} = b_{k,i} − b_{1,i} (rooted at iteration 1), singling out one iteration breaks the cyclic symmetry of the q-fold braid and produces an all-to-all coupling, not block-circulant. The alternative difference basis β_{k,i} = b_{k,i} − b_{k+1,i} is cyclically symmetric, but push-off conventions for off-diagonal blocks require an extra Reidemeister-style calculation that was not completed in one Explorer pass.
**reason**: Cyclic symmetry at the diagram level does not automatically lift to cyclic symmetry at the $H_1$(Seifert-surface)-basis level — a cyclically-symmetric basis has to be chosen explicitly. The tree basis is the "obvious" one (Seifert-matrix pedagogy always picks a spanning tree) but it is not the one that makes the block structure emerge.
**lesson**: When a diagrammatic symmetry (here: cyclic $\mathbb{Z}/q$) is present, check at the start whether the chosen $H_1$ basis respects that symmetry. If the basis requires singling out one element (as any tree/rooted basis does), the symmetry will not survive. For the spiral-knot genus formula, the algebraic Burau route (Route A) sidesteps this obstacle entirely by working in $\mathbb{Z}[t,t^{-1}]^{p-1}$ where the full $B_p$-action is available without basis choice.
**date**: 2026-04-20

## FP-SPIRAL-SKEIN-LEAVES-FAMILY-2026-04-20
**domain**: low-dimensional-topology
**subdomain**: knot-invariants
**theorem-context**: Spiral knots S(p,q,ε); attempted induction on q via the Conway/Alexander skein relation
**technique**: Apply skein $\Delta_{L_+} - \Delta_{L_-} = (t^{1/2} - t^{-1/2}) \Delta_{L_0}$ at a seam crossing of the q-fold braid word w_ε^q
**step-stuck**: Induction closure: at a skein at any seam crossing of w_ε^q, the resolution L_- has braid word that is no longer periodic (one σ_i^{ε_i} gets removed or flipped, destroying the q-fold structure), and L_0 has one fewer crossing which splits the underlying p-cycle into (p-1)-cycle + fixed point, yielding a 2-component link rather than a spiral knot. Neither L_- nor L_0 lies in the spiral-knot family, so the inductive hypothesis does not apply.
**reason**: Skein induction requires the resolution to land in the same family (or a well-parametrized super-family). For spiral knots, the family is defined by two constraints: (a) the braid word is the q-fold power of a fixed word, and (b) the braid closure is a knot (i.e., $\gcd(p,q)=1$ combined with the braid-strand permutation being a p-cycle). Skein at the seam crossings violates both constraints simultaneously.
**lesson**: For tightly-structured periodic knot families, skein induction on the period is unlikely to close. Either (i) widen the family to the "all closures of words of length pq in B_p" super-family (loses nearly all structure), or (ii) abandon skein and use representation-theoretic methods like Burau that respect the periodic structure. This is an LDT-native analogue of the optimization-side "OCO loss is non-convex" obstruction (see UCB-Hoeffding Route D, 2026-04-18).
**date**: 2026-04-20

## FP-SPIRAL-PRINCIPAL-MINOR-MISFRAMING-2026-04-20
**domain**: low-dimensional-topology
**subdomain**: knot-invariants
**theorem-context**: Spiral-knot key identity $\det(I - y B_\epsilon) = t^{e(\epsilon)} C_{p-1}(y,t)$
**technique**: Explorer 1's initial induction variable D_k := det(I_k − y·B_ε^{[k]}), where B_ε^{[k]} is the leading k×k principal minor of the full (p−1)×(p−1) matrix B_ε in the full braid group B_p
**step-stuck**: Base/induction fails: at p=4, ε=(+,+,+), D_1 = D_2 = 1 (not t^0·C_1 and t^0·C_2) but D_3 = 1 + yt + y²t² + y³t³ = t³·C_3. The D_k sequence hits the target only at k=p-1 and is wrong for smaller k, so no induction on k can close.
**reason**: The "principal minor of the full matrix" is not the same object as "the full matrix in the smaller braid group". Right-multiplication by reduced-Burau ρ̄(σ_k^{±1}) modifies three columns of B_ε (not two, as Explorer 1 claimed) when σ_k is an interior generator in B_p, because the Burau generator acts on three consecutive coordinates except when it is the last generator σ_{p-1}. Fixer Round 1 corrected this by using the intrinsic F_k := det(I_k − y·A'_k) with A'_k ∈ B_{k+1} (the partial word viewed in the smaller braid group), where last-row preservation holds and the Block Structure Lemma works.
**lesson**: For induction on the size of a Burau matrix, the induction variable must be "the same word but in the smaller braid group", not "the first k rows/columns of the full matrix". The two coincide only at k = p-1. This is a general trap: whenever a proof seeks to reduce "word in B_{p}" to "word in B_{p-1}" by discarding the last strand, the matrix representation must be reset into the smaller group, not restricted by principal minor. The correct framing comes out via a "Block Structure Lemma": the full-matrix image of a word using only σ_1,...,σ_k (for k ≤ p-2) has block form ((A'_k, c_k); (0, 1)), where A'_k is the intrinsic B_{k+1} image.
**date**: 2026-04-20

## FP-SPIRAL-PARAMSWAP-MIXED-CASE-LEVEL1-GAP-2026-04-21
**domain**: low-dimensional-topology
**subdomain**: knot-invariants
**theorem-context**: Blackwell et al. arXiv:2506.17889 Theorem 4.4 — $S(p,q,\epsilon) \cong S(q,p,\epsilon')$ iff $S(p,q,\epsilon)$ is torus (V2.3 Stage 2 regression test)
**technique**: Two parallel Explorer routes — Route 1 Alexander cite-chain via [REF:level1:corollary_3_10] + [REF:level1:proposition_4_3]; Route 2 Seifert genus dichotomy via [REF:level1:theorem_3_5](i) plus block-cyclic Seifert matrix
**step-stuck**: Both routes STRATEGIC-STUCK at the "both $\epsilon$ mixed" subcase. Route 1: Alexander-polynomial equality alone does not distinguish two sub-maximal-genus mixed spiral knots across $(p,q) \leftrightarrow (q,p)$ swap. Route 2: block-cyclic Seifert matrices have mismatched sizes $q(p-1)$ vs $p(q-1)$ but S-equivalence permits stabilization, so the size argument does NOT give a contradiction; no $\det(V_\epsilon)$ or $\sigma(S(p,q,\epsilon))$ closed-form in the registered level1 lib.
**reason**: Level-1 library registered only Theorem 3.5 (Seifert structure), Corollary 3.10 (Δ-invariance forward), and Proposition 4.3 (torus Δ uniqueness at fixed $(p,q)$). The paper's §4 Lemma 4.1 / 4.2 — which supplies the refined Alexander-polynomial classification for MIXED spiral knots across parameter swap, or the spiral-signature formula — was NOT registered. The pipeline correctly SURFACED this gap via [REUSABLE-FRAGMENT: status=verified-as-counterexample] rather than hallucinating closure.
**lesson**: For paper-chained research theorems whose proof uses more internal lemmas than were pre-registered, V2.3's honest PARTIAL verdict is the right output. **Prerequisite for re-attempt**: populate level1_lemmas/ with Blackwell §4 Lemma 4.1/4.2 before retry. The 3 cross-pollination fragments (uniform-arm handler, asymmetric-case elimination via genus, Seifert-matrix dimension hook) provide concrete re-entry points once the missing lemma is registered. **Meta-observation**: this is a successful exercise of the U3 + U4 + U5 trio — U4 (level1 library) made the gap surfacable as a specific missing-citation, U3 (cross-pollination) preserved reusable pieces, U5 (STRATEGIC classification) correctly routed to FIXER-REFUSED instead of a futile patch attempt.
**date**: 2026-04-21


## FP-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE-2026-04-26
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: OP-2 Downgraded — $\Omega(LD^2/T)$ bias LB on averaged iterate $\bar x_T$ for fixed-momentum SHB
**technique**: Reuse Goujaud rotational K-cycling identity (★) and try to recover bias term on $\bar x_T = (1/T)\sum x_t$ via stochastic noise structure (A3) or non-periodic orbit (A1)
**step-stuck**: For Goujaud cycling, $\sum_{t=0}^{K-1} e_t = 0$ exactly (regular polygon vertex sum vanishes). Hence $\bar x_T \to 0$ deterministically as $T \to \infty$, and $f_0(\bar x_T) \leq L D^2/T^2$ — exactly AC-SA's bias rate, not $\Omega(LD^2/T)$.
**reason**: Birkhoff ergodic theorem + rotational symmetry. Any orbit on a $\mu$-strongly-convex Goujaud polytope is contained in a rotation-invariant set with barycenter at $x^\star = 0$. Time averages converge to spatial average (= barycenter). Adding stochastic noise (A3) only gives $\Omega(\sigma_x^2/T)$ rate, dominated by the standard variance term $\sigma D/\sqrt T$.
**lesson**: Cycling-style hard instances cannot be averaged-iterate-extended without breaking rotational symmetry — but the cycling identity (★) is rotation-equivariant, so breaking symmetry breaks cycling. To get $\Omega(LD^2/T)$ on $\bar x_T$, a fundamentally non-cycling lower-bound technique (e.g., HB-vs-AC-SA information separation in d=T) is required. No such technique is currently in the toolbox; even Nesterov's classical worst-case LB is algorithm-uniform and does not separate HB from AC-SA. **Practical implication**: OP-2's $\Omega(LD^2/T)$ is intrinsically a last-iterate bound; do not retitle as 'oracle complexity LB'.
**date**: 2026-04-26

## FP-OP2-CYCLING-INIT-BASIN-DEPENDENCE-2026-04-26
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: OP-2 Downgraded — extension to standard zero-momentum init $x_0 = x_{-1}$
**technique**: Run zero-momentum SHB on Goujaud hard instance and check if cycling orbit is attractive (B4)
**step-stuck**: Numerical grid sweep over 9×5 = 45 $(\beta, \eta L) \in \mathcal{F}_{K=3}$ pairs shows three regimes: (1) DECAY 26/45 — orbit converges geometrically to $x^\star = 0$, LB fails; (2) ATTRACT 4/45 — orbit converges to $K=3$ cycling at $\|x_T\| = D/\sqrt 2$, LB holds; (3) OTHER 15/45 — orbit settles on non-cycling but bounded-away-from-0 trajectory, LB holds. Decay regime dominates at low $\beta$ and $\eta L$ near $\gamma_{\mathrm{crit}}$.
**reason**: The cycling orbit is a periodic limit cycle of the SHB dynamics, which may or may not be attracting depending on the spectral structure of the linearization at the origin (zero-momentum equilibrium) vs the cycle. At $(\beta, \eta L) = (0.7, 2.9)$: linearization at origin has eigenvalues with $|\lambda| < 1$ (geometric decay attractor); cycling orbit is unstable. At $(\beta, \eta L) = (0.7, 3.39)$: linearization at origin has $|\lambda| > 1$ along some direction, so origin is repelling and cycling becomes attracting.
**lesson**: For LB constructions that rely on orbit-cycling, attractiveness of the cycle under generic initialization is **not automatic**. The 'attractive subset' $\mathcal{F}_{\mathrm{usable}} \subsetneq \mathcal{F}$ must be characterized separately — likely via Lyapunov function or eigenvalue analysis. Numerical pattern: high $\beta \geq 0.7$ and $\eta L$ near upper stability boundary tend to give attract/other (LB holds); low $\beta$ or $\eta L$ near $\gamma_{\mathrm{crit}}$ tend to give decay (LB fails). Practical recommendation: state OP-2 with $\forall\exists$ initialization (mathematically correct) AND state a weaker version on $\mathcal{F}_{\mathrm{usable}}$ with zero-momentum init as a conjecture or partial result.
**date**: 2026-04-26

## FP-PEP-WITNESS-INEXPLICITNESS-2026-04-26
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: General — extracting explicit hard-instance constructions from Drori–Taylor PEP-tight bounds
**technique**: Use PEP (performance estimation problem, semidefinite-program-based worst-case analysis) to construct an explicit witness function for HB-with-zero-momentum-init achieving $\Omega(LD^2/T)$ (B2)
**step-stuck**: PEP gives algorithm-tight worst-case bounds via a convex SDP whose optimal solution corresponds to an *implicit* worst-case function (parameterized by the SDP dual variables). Extracting an *explicit, simple, named function family* — e.g., quadratic, piecewise-quadratic, or polynomial with closed-form gradient — that realizes the PEP-tight bound is a non-trivial reverse-engineering problem.
**reason**: PEP optimizes over the cone of co-coercive gradient sequences, finding a worst-case sequence at SDP precision. The corresponding function (recoverable via interpolation through the gradient sequence) generally has many discontinuous gradient pieces and lacks a clean parametric form. For algorithms with non-trivial state (like HB, where $x_t$ depends on $x_{t-1}$ and $x_{t-2}$), the witness sequence is high-dimensional and difficult to express in closed form.
**lesson**: When trying to use PEP-tight rates as the basis for a publishable lower-bound theorem, expect to spend substantial effort reverse-engineering the witness into an explicit construction. This is a separate research project from the PEP analysis itself. **Existing examples** of successful reverse-engineering: Drori–Teboulle's worst-case quadratic for gradient descent. **Counterexamples**: most non-symmetric algorithms' PEP witnesses lack clean form. For OP-2's HB-zero-init case, no reverse-engineered witness has been published.
**date**: 2026-04-26



## FP-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING-2026-04-26
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: D1 — Extending OP-2 ($\Omega(LD^2/T)$ for fixed-momentum SHB) to fixed-hyperparameter Adam/RMSProp
**technique**: Run Adam on the OP-2 hard instance (rescaled Goujaud K=3) with cycling-init and cycling-compatible $(\beta, \eta) \in \mathcal{F}$; check whether the SHB cycling identity persists under Adam's per-coordinate scaling
**step-stuck**: Cycling broken at iteration 1 in three independent ways: (i) per-coord $g_t^2$ rotates around the cycle with up to 27:1 ratio between coordinates within a single $K=3$ cycle, breaking coord-wise homogeneity; (ii) bias-corrected $\hat v_1 = g_0^2$ at $t=1$ regardless of $\beta_2$, so first Adam step has magnitude $\eta\sqrt 2 = 4.24$ regardless of $(\beta_1, \beta_2)$, jumping from cycle radius $0.71$ to $\|x_1\| \approx 3.78$; (iii) $\beta_2 = 0, \epsilon = 0$ gives normalized SGDM (denominator $|g_t|$) which destroys affine-equivariance entirely.
**reason**: OP-2's bias term proof (Lemma 2.6) requires the deterministic identity $\nabla f_0(\lambda e_t) = \lambda\nabla\psi(e_t)$ combined with the SHB recursion, which presumes (a) the same step on every coordinate and (b) a clean SHB recursion. Adam's $\hat v_t$-denominator scaling violates (a) per-coord because cycle gradients have asymmetric per-coord squared magnitudes. The bias correction at small $t$ produces an unavoidable order-1 sign-SGD-magnitude transient regardless of hyperparameters. After this transient, even though $v_t$ stabilizes to a near-isotropic limit (per-coord asymmetry $\sim 1\%$ at $K=3$ on average), the off-manifold position prevents reentry to the cycle.
**lesson**: OP-2's $\Omega(LD^2/T)$ bias lower bound is **algorithm-specific to fixed-momentum SHB**. Do NOT title or claim it as "non-acceleration of fixed-hyperparameter momentum methods" — the bias-term mechanism is the deterministic algebraic cycling identity, which is structurally tied to SHB's affine-equivariant update. The $\Omega(\sigma D/\sqrt T)$ variance term likely transfers to Adam/RMSProp via the decoupled $y$-coordinate Le Cam construction, but is a separate theorem with constants depending on $(\beta_1, \beta_2, \epsilon, \eta L)$. **Useful side observation**: Adam in the deterministic setting on OP-2's instance achieves $f_0(x_T) \to 0$, so the OP-2 LB is not just hard to extend — it is genuinely false for Adam in this regime.
**date**: 2026-04-26

## FP-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM-2026-04-26
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: D4 — Extending OP-2's variance term from $\Omega(\sigma D/\sqrt T)$ to $\Omega(\sigma D \sqrt{d-2}/\sqrt T)$ in dimension $d \geq 3$
**technique**: Product extension $f^{(s)}(x, y_1, \ldots, y_{d-2}) = f_0(x) + \sum_i [\alpha_{s_i} y_i + w_i(y_i)]$ with $d-2$ independent Le Cam two-point tests on the y-coordinates, allocate variance budget $\sum \sigma_i^2 \leq \sigma^2$ across coords, decode via direct sum / Fano on $\{\pm 1\}^{d-2}$ / Gilbert-Varshamov packing
**step-stuck**: For all decoders attempted, the per-coord Le Cam expected gap $\alpha_i D_i$ summed (or averaged via Hamming distance) is bounded by Cauchy-Schwarz: $\sum_i \alpha_i D_i \leq \|\alpha\|_2 \|D\|_2 = (\sigma/(2\sqrt{2T})) \cdot (D/\sqrt 2) = \sigma D/(4\sqrt T)$. The bound is **dimension-independent** because the $\sqrt{d-2}$ from $d-2$ tests cancels exactly with $1/\sqrt{d-2}$ from per-coord variance dilution under the global budget constraint $\sum \sigma_i^2 \leq \sigma^2$.
**reason**: Under OP-2's §0.2 oracle model, the variance budget is $\ell_2$-bounded ($\mathbb{E}\|\xi_t\|^2 \leq \sigma^2$) globally, not per-coordinate. Distributing the budget across $d-2$ coordinates as $\sigma_i = \sigma/\sqrt{d-2}$ to enable independent tests forces per-coord signal $\alpha_i = \sigma_i/(2\sqrt{2T}) \propto \sigma/\sqrt{T(d-2)}$. Either Cauchy-Schwarz directly bounds the sum, or Fano with Hamming-distance decoding gives expected misidentification count $\Theta(d-2)$ but each correct coord contributes only $\alpha_i D_i \propto \sigma D/((d-2)\sqrt T)$, total still constant. The $\sqrt{\log d}$ Nemirovski-Yudin / Agarwal 2012 (arXiv:1009.0571) bound exists but is algorithm-agnostic and uses *coupled* (non-product) hypothesis tests not realizable as separable walls.
**lesson**: Under $\ell_2$-bounded variance oracles, naive product extensions of single-coordinate Le Cam variance LBs do NOT scale with dimension. To get $\sqrt{d-2}$ scaling, the oracle must be $\ell_\infty$-bounded ($\|\xi_t\|_\infty \leq \sigma$ uniformly), which is a strictly more permissive noise model (allowing total variance $d\sigma^2$). The $\sqrt{\log d}$ NY/Agarwal bound requires coupled hypothesis classes, fundamentally incompatible with OP-2's separable wall structure. **Practical implication**: high-dimensional extensions of cycling-style LBs need to redesign the wall to couple all coordinates, not just replicate the 1-D Le Cam in parallel.
**date**: 2026-04-26

## FP-OP2-NESTEROV-LOOKAHEAD-OFF-VERTEX-2026-04-26
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: D5 — Polyak-vs-Nesterov rate separation: showing Nesterov accelerates on the OP-2 hard instance where Polyak is stuck at $\Omega(1/T)$
**technique**: Run Nesterov $y_t = x_t + \beta(x_t - x_{t-1}), x_{t+1} = y_t - \eta\nabla f(y_t)$ on OP-2's rescaled Goujaud $f_0$ with the same cycling-init as Polyak; check whether (a) Nesterov satisfies a cycling identity at vertices, or (b) Nesterov accelerates / converges geometrically (giving a clean rate separation)
**step-stuck**: At step (a), Nesterov's lookahead $y_t = \lambda[(1+\beta)e_t - \beta e_{t-1}]$ is **NOT** a vertex of the rescaled polytope $\widetilde P$ — it lies far outside (e.g., $\|y_0\| = 1.275$ vs vertex norm $\approx 0.49$ at $\beta=0.5, \eta L=3$). GTD23's projection identity $P_C(e_t) = M e_t$ holds only at vertices; for non-vertex $y_t$, $P_{\widetilde C}(y_t)$ is a generic boundary point chosen by KKT, and the gradient is **not** a clean linear combination of $e_t, e_{t\pm 1}$. Cycling closure fails. At step (b), Nesterov on $f_0$ does NOT converge geometrically either: numerically it has its own non-zero attractor (period-2 orbit at $(\beta=0.5, 3)$, fixed point at $\|x\|=1.09$ at $(\beta=0.7, 2.9)$, divergence at $(\beta=0.9, 3.5)$). $\liminf_t f_0(x_t) > 0$ in cases A and B, so bias is also $\Omega(1)$ asymptotically — no clean rate separation.
**reason**: Polyak's cycling identity uses two specific algebraic ingredients that are tightly coupled to Polyak's update form: (i) gradient is queried at $x_t$, which is a vertex by induction; (ii) the GTD23 vertex projection identity $P_C(e_t) = M e_t$ then applies, giving a clean linear combination of cycle points. Nesterov's lookahead structure breaks both: gradient is queried at $y_t$, a non-vertex linear combination of $e_t, e_{t-1}$, where the projection identity has no closed form. The cycling identity is fundamentally Polyak-specific. However, this does NOT mean Nesterov *converges* on the same instance — Nesterov has its own dynamical behavior (different attractors at different $(\beta, \eta)$) that also fails to reach the optimum.
**lesson**: Cycling-style lower bounds via Goujaud's projection identity are **inherently algorithm-specific to the gradient query point being a vertex of the polytope**. Methods that query gradient at non-vertex points (Nesterov, AC-SA, look-ahead variants) cannot inherit the bound directly. **Two corollaries**: (1) The Polyak-vs-Nesterov gap is qualitatively visible in the structure of cycling itself — a clean qualitative observation worth a remark in the paper. (2) But "cycling-instance-X is hard for Polyak" does NOT imply "instance-X is easy for Nesterov" — Nesterov may have its own non-cycling-but-non-converging behavior on the same instance. To establish a clean rate separation, one needs either a positive convergence proof for Nesterov on the same instance, or a different cycling instance designed for Nesterov's lookahead structure.
**date**: 2026-04-26

## FP-OP2-I4-SUFFIX-AVG-RESONANCE-2026-04-26
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: I4 — Suffix average lower bound for SHB: does the OP-2 last-iterate $\Omega(LD^2/T)$ bound survive when replacing $x_T$ with $\widehat y_{T,\sqrt T} = (1/\sqrt T)\sum_{t=T-\sqrt T+1}^T x_t$, for every $(\beta,\eta) \in \mathcal F$?
**technique**: Goujaud K-gon polytope-Moreau cycling construction, with three sub-routes: (a) take $K = K(T)$ growing with $T$ so $k = \sqrt T \ll K$ keeps the suffix in a sub-arc near a single vertex; (b) take $K = \sqrt T$ exactly; (c) take continuous orbit on a smooth circle.
**step-stuck**: Step 1: Route (a) blocked by analytical limit of GPT cycling inequality — as $K \to \infty$, $c_K \to 1$ and the LHS $\to z^2 + 2(1-\beta)(1-\kappa)z > 0$, so cycling fails. Empirically $K_{\max}(0.5,3/L) = 4$, $K_{\max}(0.9,3/L) = 13$, $K_{\max}(0.99,3.9/L) = 44$ — bounded for every fixed $(\beta,\eta) \in \mathcal F$. Routes (b), (c) trivially fail. Then for fixed $K$, the cycle sum over a multiple of $K$ vertices is exactly $0$ (geometric sum of $K$-th roots of unity), so at $T = (jK)^2$ for $j=1,2,\ldots$ the suffix average $\widehat y_{T,\sqrt T} = 0 = x^\star$, giving $f(\widehat y) - f^\star = 0$ exactly. Numerical: at $(\beta,\eta,K)=(0.9,3/L,3)$, suffix-avg norm at $T \in \{9,36,81,144,225,900\}$ is at machine-precision zero ($\sim 10^{-16}$).
**reason**: SHB cycling on a $K$-gon is a periodic orbit of period $K$. Any averaging window whose length is a multiple of $K$ collapses to $x^\star$ by rotational symmetry of the regular polygon. The choice $k = \sqrt T$ hits this resonance at $T = (jK)^2$, an infinite subsequence with positive lower density $1/K$. Resonance is independent of vertex phase, starting position, or any Goujaud-internal parameter. Since $K$ is bounded above by the cycling inequality, no escape is possible within the GTD23 framework.
**lesson**: Cycling lower bounds with bounded period $K$ are **structurally killed by any averaging window of length $\geq K$**: full-period-multiple windows annihilate the displacement by symmetry. This is the same mechanism that kills Cesàro averages in OP-2 (failure A in the OP-2 research map), now extended to suffix averages of length $\sqrt T$. The non-trivial finding is that resonance happens not just for windowed averages of length divisible by $K$ but for ALL windows hitting the resonance subsequence $T = (jK)^2$. **Corollary**: any "iterate-type extension" of OP-2 — Cesàro, suffix, exponential moving average with decay $> 1/K$ — that uses an averaging horizon comparable to or larger than the cycle period is killed by the same resonance mechanism. To get a genuine averaging lower bound, one needs either (i) a non-cycling, non-Goujaud hard instance (open since 2015+), or (ii) restrict the averaging window to $k < K$ (i.e. $T < K^2$, a finite-$T$ regime, defeating the asymptotic interpretation). **Tip for future Scout**: when extending an OP-2-style cycling lower bound to averaged iterates, check the resonance condition $k = \lceil$averaging-horizon$\rceil \in K\mathbb{N}$ FIRST; this rules out the route in $O(1)$ work.
**date**: 2026-04-26

---

## FP-ADAGRAD-COORDWISE-PREDICTABLE-SURROGATE-COSMETIC-2026-04-27
**domain**: optimization
**subdomain**: adaptive-methods
**theorem-context**: AdaGrad coordinate-wise complexity (COLT 2025 conjecture, refuted)
**technique**: AMSGrad-style $v_{t,i} \to v_{t-1,i}$ surrogate substitution to enable cancellation of the noise cross-term in the MT1 cancellation pair
**step-stuck**: Step IDENTITY/INEQ slot of MT1 cancellation pair — the surrogate correction term $S_t^{(2)}$ has the same order as the descent term $\sum_t\sum_i \nabla_{t,i}^2/\sqrt{v_{t,i}}$
**reason**: The AMSGrad predictable-surrogate substitution $\sqrt{v_{t,i}} \to \sqrt{v_{t-1,i}}$ produces a correction term bounded by $|S_t^{(2)}| = O(\sum_i |\nabla_{t,i}\xi_{t,i}|\sqrt{v_{t,i}}/\nu_0)$, which scales as $\sigma\sqrt{T}\cdot G$ and dominates the per-step descent. This correction is harmless in AMSGrad because the $(1-\beta_2)$ EMA factor provides a structural cushion $\hat v_{t,i}^{1/2} \ge (1-\beta_2)^{1/2} v_{t-1,i}^{1/2}$, bounding the denominator shift. Vanilla coordinate-wise AdaGrad has no EMA factor, so the denominator shift $\sqrt{v_{t,i}} - \sqrt{v_{t-1,i}} = g_{t,i}^2/(\sqrt{v_{t,i}}+\sqrt{v_{t-1,i}})$ is an $O(g_{t,i}^2/\sqrt{v_{t,i}})$ term — same magnitude as the self-bounding sum, making cancellation illusory.
**lesson**: Predictable-surrogate substitutions only buy cancellation when the algorithm has a structural cushion absorbing the correction; for vanilla AdaGrad the surrogate is just bookkeeping. Any future attempt to transfer AMSGrad-style surrogates to vanilla AdaGrad must first identify an analogous structural cushion (e.g., affine-noise self-control). Without this, the correction term dominates.
**date**: 2026-04-27

## FP-ADAGRAD-COORDWISE-HYPERCUBE-POLYTOPE-SNR-CANCEL-2026-04-27
**domain**: optimization
**subdomain**: adaptive-methods
**theorem-context**: AdaGrad coordinate-wise complexity LB (COLT 2025 conjecture, refuted)
**technique**: MT5 adversarial coordinate-polytope construction — $d$-separable hard instance $f(x) = \sum_i f_i(x_i)$ with Rademacher noise distributed under $\ell_2$ variance budget $\sum_i \tilde\sigma_i^2 \le \sigma^2$
**step-stuck**: Step DECODE (converting per-coord Bayes test results to gradient norm lower bound): per-coord SNR $\rho_i^2/\tilde\sigma_i^2$ is dimension-independent
**reason**: Under the $\ell_2$ variance budget and $d$-separable construction with equal per-coord signal $\rho_i = \rho = \sqrt{L\Delta_0/d}$ and equal per-coord noise $\tilde\sigma_i = \sigma/\sqrt{d}$, the per-coord SNR is $\rho^2/\tilde\sigma^2 = (L\Delta_0/d)/(\sigma^2/d) = L\Delta_0/\sigma^2$, which is DIMENSION-INDEPENDENT. The $d$-factor from the $d$ independent tests is exactly cancelled by the $1/d$ variance dilution. Any subsequent parameter-tuning step is vacuously insufficient: $\varepsilon^{-1}$ dependence (not $\varepsilon^{-3/2}$) is the best achievable from a single-level separable construction under $\ell_2$ budget.
**lesson**: Under $\ell_2$-bounded oracle and separable constructions, the per-coordinate SNR is ALWAYS dimension-independent. To recover a $d$-factor in the LB, one must use either (a) a non-separable coupled construction (e.g., a single shared needle coordinate among $d-1$ noise coordinates — as in Route 3's approach) or (b) switch to an $\ell_\infty$-bounded oracle model (per-coord noise $\sigma$, total variance $d\sigma^2$). The $d$-factor in the coordinate-wise AdaGrad LB is NOT a free gift from dimensionality; it must be engineered through the oracle model.
**date**: 2026-04-27

## FP-ADAGRAD-COORDWISE-JOINT-LYAPUNOV-DEGENERATE-2026-04-27
**domain**: optimization
**subdomain**: adaptive-methods
**theorem-context**: AdaGrad coordinate-wise complexity UB (COLT 2025 conjecture, refuted)
**technique**: Joint Lyapunov augmentation $\Phi(t) = \mathbb{E}[f(x_t)] + c\cdot\mathbb{E}[\sum_i\sqrt{v_{t,i}}]$ — the accumulator-norm potential is added to track the coordinate-wise adaptive denominator dynamics jointly with the objective descent
**step-stuck**: Step LEVERAGE — the Lyapunov increment $\Delta\Phi_t = \Delta f_t + c\Delta(\sum_i\sqrt{v_{t,i}})$ provides no new analytical leverage over the direct per-coordinate analysis (Route 1)
**reason**: The one-step increment of the accumulator norm is $\sum_i(\sqrt{v_{t,i}+g_{t,i}^2}-\sqrt{v_{t,i}}) \le \sum_i g_{t,i}^2/(2\sqrt{v_{t,i}})$. This is the SAME quantity as the QUAD term in the per-coordinate descent analysis (Route 1). The Lyapunov augmentation therefore just reorganizes Route 1's algebra — it does not produce a new cross-term cancellation, a new rate, or new structural insight. The potential $c\sum_i\sqrt{v_{t,i}}$ cancels the QUAD term from $\Delta f_t$, producing the SAME telescoping sum as Route 1 but through a different bookkeeping path. FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING fired correctly.
**lesson**: For coordinate-wise AdaGrad, the joint Lyapunov augmentation $\Phi = f + c\sum_i\sqrt{v_{t,i}}$ is cosmetically distinct from but mathematically equivalent to the direct Route 1 analysis. The coordinate-wise accumulator norm $\sum_i\sqrt{v_{t,i}}$ is NOT a new Lyapunov object — it is the same self-bounding sum from Route 1 wrapped in a potential. Future attempts to use joint Lyapunov arguments for coordinate-wise adaptive methods should first verify that the augmentation potential's increment is genuinely different from the QUAD term in the descent inequality; if they match, the Lyapunov adds no leverage.
**date**: 2026-04-27

## FP-ADAGRAD-COORDWISE-OFUL-AMGM-EXPONENT-MISMATCH-2026-04-27
**domain**: optimization
**subdomain**: adaptive-methods
**theorem-context**: AdaGrad coordinate-wise complexity UB (COLT 2025 conjecture, refuted)
**technique**: OFUL bandit analogy — treating coordinate-wise AdaGrad as a diagonal-matrix case of OFUL's elliptical potential, then transferring OFUL's AM-GM analysis to produce the non-convex stochastic rate
**step-stuck**: Step AMGM-EXPONENT — the bandit 2-term AM-GM balance gives $T^{-1/2}$; the non-convex smooth 3-term AM-GM balance requires $T^{-2/3}$
**reason**: OFUL's elliptical potential analysis $\sum_t\|a_t\|^2_{V_{t-1}^{-1}} \le d\log\det(V_T/V_0)$ (the "log-det" self-bounding identity) collapses to the per-coordinate self-bounding sum $\sum_t g_{t,i}^2/\sqrt{v_{t,i}} \le 2\sqrt{v_{T,i}}$ when $V_t = \mathrm{diag}(v_{t,i})$. In OFUL, the target functional is linear regret, which leads to a 2-term AM-GM: balance the $1/\eta$ initialization cost against the $\eta\sqrt{T}$ accumulation noise, giving $O(1/\sqrt{T})$. In non-convex smooth optimization, the target is squared gradient norm, which leads to a 3-term AM-GM: balance $\Delta_0/\eta$ (initialization), $\eta\sqrt{T\sigma^2 d}$ (noise), and $\eta^2 LT$ (smoothness penalty). The $T^{-2/3}$ exponent is the solution of this 3-term balance, and the 3rd term $\eta^2 LT$ has no counterpart in bandit regret. No algebraic patch can produce the 3-term structure from the OFUL 2-term skeleton; they reflect fundamentally different target functionals.
**lesson**: Structural analogies from bandit/OCO proofs transfer the self-bounding sum and martingale cancellation components to non-convex stochastic optimization, but DO NOT transfer the AM-GM exponent. The exponent is determined by the number of terms in the AM-GM balance, which depends on the target functional (linear regret: 2 terms → $T^{-1/2}$; squared gradient: 3 terms → $T^{-2/3}$). When importing a bandit structural analogy into non-convex smooth analysis, always check whether the smoothness penalty $\eta^2 LT$ term is accounted for; if not, the analysis is structurally incomplete.
**date**: 2026-04-27
**date**: 2026-04-26

## FP-SHB-PR-KAPPA-ROUTE2-NEGATIVE-LB-2026-04-27
**domain**: optimization
**subdomain**: lower-bounds
**theorem-context**: SHB Polyak-Ruppert κ-blow-up on SC quadratics (companion to I5)
**technique**: Adversarial μ-coordinate isolation with $\kappa^3$ asymptotic via the identity $J_\infty + B_\mu K_\infty = ((1-\beta)^2 - \beta\eta\mu)/(\eta\mu)^2$ as a "lower bound on $|\tilde x_{T,\mu}|$"
**step-stuck**: §3.4 — the proposed lower-bound expression evaluates to **−19.1 < 0** at the user's empirical setting $(\beta=0.9, \kappa=100, \eta L=2.9)$, since $(1-\beta)^2 = 0.01$ but $\beta\eta\mu = 0.026$. A "lower bound" using a negative number is degenerate.
**reason**: The $\kappa^3$ asymptote derived from $J_\infty + B_\mu K_\infty$ kicks in only when $(1-\beta)^2 > \beta\eta\mu$, i.e., $\kappa < (1-\beta)^2/(\beta\eta L) \approx 3.5$ at the test parameters. Above this transition, the second-order term dominates with the opposite sign, and the resulting expression cannot be used as a non-negative lower bound. The user's $\kappa=100$ is two orders of magnitude past the validity threshold.
**lesson**: When deriving an asymptotic LB from $|S_\infty|^2 = (1-z)^{-2}\overline{(1-z)^{-2}}$ on the imaginary part, ALWAYS verify the sign of the resulting expression at the target parameter range. If the dominant term has the wrong sign, the formula is a tightness witness, not a lower bound. In this case the genuine analytic κ-exponent is $c=1$ (as Routes 1, 3, 4, 5, 6 all confirmed), and Route 2's $c=3$ is a counterexample-to-itself.
**date**: 2026-04-27

## FP-EMPIRICAL-KAPPA-EXPONENT-FP-FLOOR-ARTIFACT-2026-04-27
**domain**: optimization
**subdomain**: numerical-verification
**theorem-context**: Generic — distinguishing genuine asymptotic κ-exponents from machine-precision-floor artifacts when $f(x_T)$ decays geometrically
**technique**: Empirical regression of $\log\bigl(f(\tilde x_T)/f(x_T)\bigr)$ vs $\log\kappa$ at fixed $T$, expecting power-law $\Theta(\kappa^c)$
**step-stuck**: For $\beta=0.9$, $f(x_T)$ saturates at IEEE-754 floor $\varepsilon_{\rm mach}\approx 2.2\times 10^{-16}$ around $T \approx 350$. Beyond this threshold, the denominator becomes a constant and the empirical κ-exponent reflects only the numerator $f(\tilde x_T) \asymp \kappa^2/(\eta^2 L T^4)$ on the squared average, giving an apparent $c\approx 2$ regardless of the true analytic $c$. Plus round-off noise contributes another ≈0.5–1.0 to the slope.
**reason**: A regression of $\log(\text{ratio})$ vs $\log\kappa$ at $T \ge T_{\rm FP}(\beta)$ measures $\log(f(\tilde x_T)/\varepsilon_{\rm mach})$, not the analytic ratio. The genuine analytic exponent is recoverable only at $T < T_{\rm FP}(\beta)$ (typically $T \in [50, 200]$ for $\beta=0.9$).
**lesson**: When the Proposer pipeline reports an empirical κ-exponent based on numerics with $\beta < 1$ and large $T$, ALWAYS check whether $T \ge \log\varepsilon_{\rm mach}/\log\beta$ (the FP-floor onset). If so, the empirical exponent is contaminated by the FP floor and must not be trusted. Use higher precision (mpmath, exact symbolic) or restrict $T$ to the analytic regime. The Proposer's A-6 anomaly at $T \approx 350$ is in the FP-floor regime; the genuine analytic exponent is $c=1$, not the empirical $c \approx 2.94$.
**date**: 2026-04-27

## FP-METRIC-MISMATCH-2026-04-29
**domain**: optimization
**subdomain**: convergence
**theorem-context**: OP-2 v5 §4.2.1 — claimed tightness against GFJ2015 deterministic-HB upper bound
**technique**: Quoting an external upper bound as a "matching tightness witness" for the proof's lower bound
**step-stuck**: §4.2.1 — UB and LB attached to *different* metrics: GFJ2015 bounds the Cesàro-averaged iterate $f(\bar x_T)-f^\star$, while OP-2 lower-bounds the last-iterate $f(x_T)-f^\star$. The two quantities differ by a factor that itself scales with $T$, so claiming "UB = LB" is a category error.
**reason**: The agent treated "Cesàro" and "last-iterate" as interchangeable metrics on the basis that both are O(1/T) in the deterministic case. The relationship $f(\bar x_T)-f^\star \le f(x_T)-f^\star$ holds only sometimes, and even when both are O(1/T) the constants differ; in the stochastic setting the gap is unbounded. Tightness witnesses must match the metric exactly, not just the rate exponent.
**lesson**: Before quoting any external UB/LB as a tightness witness, identify the metric explicitly (last iterate / Cesàro average / best iterate / weighted average / minimum gradient / etc.) and verify that the citation's metric *equals* the proof's target metric. Different metrics have different optimal constants and can have different rates in stochastic settings (e.g. last-iterate has noise floor $\sigma^2/T$, Cesàro can achieve $\sigma^2/T$ with smaller constant). Detected by Tightness Pre-Audit T2.
**date**: 2026-04-29

## FP-SIGNED-STRUCTURE-LOST-2026-04-29
**domain**: optimization
**subdomain**: stochastic
**theorem-context**: OP-2 Theorem 3 Step 2–3 — bias-term bound in stochastic-HB lower bound
**technique**: Cauchy–Schwarz applied to a signed inner-product sum $\sum_t \langle b_t, z_t-z^\star\rangle$
**step-stuck**: Step 2–3: bounded $\sum_t \langle b_t, z_t-z^\star\rangle$ by $\big(\sum_t \|b_t\|^2\big)^{1/2}\big(\sum_t \|z_t-z^\star\|^2\big)^{1/2}$, replacing a martingale-difference cancellation with an absolute bound. LHS is $\Theta(T^0)$ in expectation (martingale increments cancel); RHS is $\Theta(T^{0.2})$. End-to-end rate dropped from the target $T^{-1/2}$ to $T^{-0.3}$.
**reason**: Cauchy–Schwarz, triangle inequality, and similar absolute-value bounds discard sign information. When the LHS contains a term whose expected cancellation is *the entire reason* the rate is achievable (martingale-difference noise, alternating series, telescoping with sign change), bounding it absolutely produces a strictly worse rate. The agent applied CS reflexively without checking whether sign cancellation was present.
**lesson**: Whenever a proof step uses Cauchy–Schwarz / triangle / Young / sum-of-absolute-values to bound a sum that contains noise, martingale increments, or alternating signs, FIRST numerically compare $\mathbb{E}[\text{LHS}]$ vs $\mathbb{E}[\text{RHS}]$ at $T \in \{10^2, 10^4, 10^6\}$. If the RHS rate is worse, the cancellation must be preserved by an alternative bookkeeping: telescoping ($\sum_t\langle b_t, z_t-z^\star\rangle = \langle B_T, z_T-z^\star\rangle - \sum_t\langle B_t, z_{t+1}-z_t\rangle$), Doob/Burkholder for martingale increments, Young's inequality with optimally tuned $\lambda$, or Abel summation when one factor is monotone. Detected by Tightness Pre-Audit T1+T4.
**date**: 2026-04-29

## FP-CONSTANT-BLOWUP-2026-04-29
**domain**: optimization
**subdomain**: convergence
**theorem-context**: OP-2 v4 — claimed leading constant κ/10 for the bias-term lower bound
**technique**: Constant tracking through chained inequalities without identifying the bottleneck step
**step-stuck**: Constant claimed as $\kappa/10$, but reverse-tracking through Step 5 (descent-lemma slack at the binding instance $t=4$) revealed an $\approx 23\times$ multiplicative factor at that single step. Actual achievable constant is $\kappa/23$, contradicting the claim.
**reason**: The agent computed the leading constant by composing all upstream factors but never checked individual step contributions against the headline claim. A single bottleneck step with factor $c_i = 23 > 10$ is by itself sufficient to refute a "$\kappa/10$" tightness statement — the rest of the chain is irrelevant. The proof's own claim was therefore self-falsifying.
**lesson**: When a proof asserts a *specific* leading constant $C^\star$ (not just a rate), trace the chain $C^\star = \prod_i c_i$ and check whether $\max_i c_i \le C^\star$. If a single step contributes more than the claimed constant, the claim is wrong regardless of downstream algebra. Bottleneck steps with $c_i > 100$ are warning-level; bottleneck steps with $c_i > C^\star$ are CRITICAL. Detected by Tightness Pre-Audit T3 (rule `tightness-claim-violated`).
**date**: 2026-04-29

## FP-STOCHASTIC-FLOOR-2026-04-29
**domain**: optimization
**subdomain**: stochastic
**theorem-context**: Generic — applying deterministic convergence arguments inside a stochastic proof
**technique**: Reusing a deterministic descent / telescoping / pointwise-convergence step verbatim in a setting with bounded-variance noise $\sigma^2 > 0$
**step-stuck**: Steps that quietly assume $x_T \to x^\star$, $\nabla f(x_T) \to 0$, or $\sum_t \eta_t^2 < \infty$ summability — all of which fail when noise has a non-zero floor. Most commonly: the deterministic AM–GM balance has fewer terms than the stochastic one (deterministic needs to balance bias+smoothness, stochastic needs to balance bias+smoothness+noise), so importing a deterministic AM–GM exponent into a stochastic proof produces the wrong rate.
**reason**: Stochastic settings impose a noise floor $\Omega(\sigma^2/T)$ or $\Omega(\sigma^2)$ on key quantities. Any deterministic argument that drives a quantity to zero is invalid when that quantity has a positive lower bound under noise. The OFUL→non-convex-stochastic AM–GM-exponent failure (FP-ADAGRAD-COORDWISE-OFUL-AMGM-EXPONENT-MISMATCH-2026-04-27) is a special case: bandit regret has a 2-term AM–GM giving $T^{-1/2}$, non-convex stochastic has a 3-term AM–GM giving $T^{-2/3}$, and you cannot recover the third term by algebraic patches.
**lesson**: When porting a deterministic argument into a stochastic proof, audit each step for: (i) does it assume pointwise convergence of $x_T$ or $\nabla f(x_T)$? (ii) does it require summable $\eta_t^2$? (iii) does its AM–GM balance count terms — and is the noise term included? If any answer flags, the deterministic step does not survive transfer; either find a stochastic analogue (Lyapunov potential that absorbs the noise floor, three-term AM–GM with noise) or accept that the rate will be worse. Detected by Tightness Pre-Audit T5.
**date**: 2026-04-29
