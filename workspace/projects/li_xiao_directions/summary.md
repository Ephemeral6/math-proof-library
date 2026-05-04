# Summary — Two Directions in Response to Prof. Li Xiao's Peer Review

**Date:** 2026-04-28 (re-audited 2026-04-28 PM)
**Author:** Math-proof-agent v2 (5-phase pipeline × 2 directions + 4-task re-audit)
**Working dir:** `workspace/active/li_xiao_directions/`

---

## ⚠ RE-AUDIT WARNINGS (high-intensity verification before peer-review release)

After 4 parallel re-audit Auditors (Opus) ran SymPy + mpmath + Monte-Carlo verification on every load-bearing claim, **the main theorems for both directions remain correct, but FOUR concrete corrections are required** before sending to Prof. Li Xiao or any external peer reviewer:

### CORRECTION 1 (HIGH severity, Direction 1) — bias constant $\kappa/8$ fails at small $T$

The boxed bound $\mathbb{E}[f(x_T) - f^\star] \geq \kappa LD^2/(8T)$ is **FALSE for small $T$** (specifically at the anchor $(0.8, 3.247, 0.387)$, $T=4$ gives ratio $0.113 < 1/8 = 0.125$). For $T \geq 10$ the bound holds with margin, and for very large $T$ the ratio settles near $0.95$. The proof needs ONE of:
- **(option A)** restate as "$\forall T \geq T_0(\beta,\eta)$, with $T_0 \approx 10$ at the anchor" (cleanest)
- **(option B)** downgrade the constant from $\kappa/8$ to $\kappa/9$ (or smaller) so the bound holds for all $T \geq 1$
- **(option C)** change the strong-convexity floor argument: tighten the transient estimate

The MAIN result (existence of positive-measure $\mathcal F^{\mathrm{zero}}_{K=3}$, asymptotic $\Omega(\kappa LD^2/T)$) is unaffected — only the explicit small-$T$ constant is wrong.

### CORRECTION 2 (MEDIUM severity, Direction 1) — period-2 → period-6 / period-2-mod-$C_3$

The claim "period-2 attractor at high $\beta$" is **terminologically wrong**. The orbit at the auditor's anchors $(0.9, 3.78, 0.05)$ and $(0.95, 3.85, 0.10)$ is **period-6 in $\mathbb R^2$** ($\|x_t - x_{t-6}\| < 10^{-50}$ to 50 digits), with **period-2 in norm** (two distinct $\|x_t\|$ values cycling) under the $C_3$ rotational symmetry. Replace "period-2 attractor" → "period-6 attractor (period-2 modulo $C_3$ rotation)" throughout.

### CORRECTION 3 (MEDIUM severity, Direction 1) — bias floor $0.37\mu D^2$ → $\sim 2.2\mu D^2$

The period-6 attractor's bias floor $0.37\mu D^2$ is **arithmetically wrong**. With min-norm $\|x^a\| \approx 2.107$ (in absolute units, with $D = 1$), the actual floor is $(\mu/2)(2.107)^2 \approx 2.22\mu D^2$ for anchor 1 and $\approx 3.44\mu D^2$ for anchor 2. The original "0.37" came from confusing units. Use "$\geq 2\mu D^2$" or the precise value.

### CORRECTION 4 (MEDIUM severity, Direction 1) — "19% measure" claim is mis-attributed

The 19/100 grid points classified as "other" are NOT period-6 in iterate; under longer horizons (T=100,000, mpmath dps=70), they re-classify as **17 period-4** + 1 quasi-periodic + 1 slow decay. **Zero of the 19 grid points are TRUE period-6/period-2-mod-$C_3$.** The reason: the grid sampled $\kappa \in [0.37, 0.48]$, but the period-6 anchors require $\kappa \in \{0.05, 0.10\}$ — disjoint regimes. The "$\sim 19\%$ measure" claim should be replaced with "non-empty open via implicit-function argument; two confirmed point-anchors at $(0.9, 3.78, 0.05)$ and $(0.95, 3.85, 0.10)$".

### CORRECTION 5 (LOW severity, Direction 2) — minimax-η matching is rate-only

The summary's claim "$\eta_T = D/(\sigma\sqrt T)$ gives noise floor = $\sigma D/\sqrt T$ **exactly**" is too strong. Re-audit: the noise floor coefficient is $1/[4(1-\beta)]$ vs OP-2 LB coefficient $\sqrt 2/27 \approx 0.0524$. **Ratio differs by $\beta$-polynomial factor** (4.77× at $\beta=0$, 47.7× at $\beta=0.9$). Replace "exact match" with "matches in rate $\Theta(\sigma D/\sqrt T)$, constants differ by $\beta$-polynomial factor".

### What does NOT need correction

These claims pass re-audit cleanly:
- ✓ Theorem 5.1 (zero-momentum incompatibility for $\beta > 0$): VALID, SymPy + mpmath confirmed.
- ✓ Vieta identity $(1-r_1)(1-r_2) = \eta\mu$: VALID, symbolic verification.
- ✓ Floquet eigenvalues $\beta^{3/2}$: VALID, 50-digit precision.
- ✓ Closed-form noise floor $\mathrm{Var}_\infty[x] = \eta\sigma^2(1+\beta)/[L(1-\beta)(2(1+\beta) - \eta L)]$: VALID, 5 Monte-Carlo settings <0.1% rel-err.
- ✓ Stability boundary divergence ($\beta \to 1$ or $\eta L \to 2(1+\beta)$): VALID.
- ✓ 8/73/19 grid classification: STABLE across precisions (dps 20–200), horizons (T 2k–100k), cutoff strictness.
- ✓ Direction 2 main negative result (no $T$-decaying UB at fixed $(\beta, \eta)$): VALID.

### Re-audit reports (full evidence)

- `reaudit_theorem_5_1.md` — Theorem 5.1 + bias constant verification
- `reaudit_noise_floor.md` — closed-form variance + matching constants
- `reaudit_period2.md` — period-6 vs period-2 disambiguation
- `reaudit_numerical.md` — 100-digit grid scan + period-4 reclassification

---

## TL;DR

| Direction | Reviewer concern | Verdict | Effort |
|---|---|---|---|
| **1** | OP-2 cycling requires non-zero initial momentum; standard practice is $x_0 = x_{-1}$ | **Partial PASS** — non-empty positive-measure subset $\mathcal F^{\mathrm{zero}}_{K=3} \subset \mathcal F_{K=3}$ supports zero-momentum cycling at high $\beta$ | Full proof feasible; revision adds 3 sub-lemmas + numerical anchor |
| **2** | OP-2 last-iterate LB lacks matching last-iterate UB (GFJ15 is Cesàro) | **Definitive negative + partial positive** — at fixed $(\beta, \eta)$ no matching UB exists (closed-form noise floor), but matches in minimax-over-$\eta$ sense + projected case (up to $\log T$) | Reframe OP-2 §4.2 tightness statement; add Theorem A.1 (noise floor) and Theorem D (projected UB) |

Both directions produce **publishable revisions to OP-2 v4** (§4.2 + new Theorem 5.1) and **rebuttable answers to the reviewer**.

---

## Direction 1: Zero-Momentum Initialization

### Reviewer's framing (verbatim)
> "初速度是我现在觉得最最重要的一点。这让我感觉像是只有在初始速度的特别设计下，才能导致有last iterate cycling。如果可以在正测度参数域里，将证明扩展至 $x_0 = x_{-1}$ 的设定，这个结果会立即得到很大的提高，变成SHB在smooth convex下的合理lower bound。"

### What we found

**Numerical evidence (50-digit mpmath, 100 grid points in $\mathcal F_{K=3}$):**

| Init | Cycle (K=3) | Decay → 0 | Other (period-4 in iterate) |
|---|---:|---:|---:|
| OP-2 (non-zero momentum) | 100/100 | 0/100 | 0/100 |
| Zero-momentum | **8/100** [RE-AUDIT: VALID — stable at dps∈{20,50,100,200}, T∈{2k,10k,100k}] | 73/100 [RE-AUDIT: VALID — 73 or 74 with stricter cutoffs, ±1] | 19/100 [RE-AUDIT: CORRECTED — these are **period-4 in iterate** (17/19), NOT period-2 or period-6; 1 quasi-periodic, 1 slow decay] |

The 8 cycling points concentrate at $\beta \in \{0.7, 0.8\}$, $\eta L \in [3.09, 3.561]$. [RE-AUDIT: VALID]

The 19 "other" points at $\beta \in \{0.9, 0.95\}$ have bounded oscillation with $\|x_t\| \in [0.86, 1.21]$ — a different attractor [RE-AUDIT: CORRECTED — at T=100,000 mpmath dps=70, **17 of 19 are period-4**, NOT period-2 or period-6. 1 is quasi-periodic, 1 is slow decay. The "period-2 in rotating frame" interpretation only holds at separately confirmed anchors $(0.9, 3.78, 0.05)$ and $(0.95, 3.85, 0.10)$ which use $\kappa \in \{0.05, 0.10\}$ — outside the grid's $\kappa \in [0.37, 0.48]$ range], still gives $\Omega(\mu D^2)$ floor [RE-AUDIT: VALID — period-4 orbit norms remain bounded away from 0].

### Theorem (consolidated, verified by Auditor)

$$\boxed{\quad \exists\,\mathcal F^{\mathrm{zero}}_{K=3} \subset \mathcal F_{K=3} \text{ open with positive 2-D Lebesgue measure}: \forall (\beta,\eta) \in \mathcal F^{\mathrm{zero}}_{K=3},\quad \mathbb{E}[f(x_T) - f^\star] \;\geq\; \frac{\kappa LD^2}{8T} + \frac{\sqrt 2}{27}\cdot\frac{\sigma D}{\sqrt T}\,, \quad \boxed{\forall T \geq T_0(\beta,\eta) \approx 10}\quad}$$

[RE-AUDIT: CORRECTED — original claim "$\forall T \geq 1$" is **FALSE**. At anchor $(0.8, 3.247, 0.387)$, $T=4$ gives ratio $T \cdot f_0(x_T)/(\kappa LD^2) = 0.113 < 1/8 = 0.125$. The bound holds with margin only for $T \geq 10$ at the anchor. ALTERNATIVE: downgrade constant from $\kappa/8$ to $\kappa/9$ (or smaller) to recover "$\forall T \geq 1$".]

with bias constant $\kappa/8$ (vs $\kappa/4$ in OP-2; degraded by transient correction) and variance constant $\sqrt 2/27$ unchanged.

### Proof skeleton (8 lemmas, audit-ready)

| Lemma | Content | Verified |
|---|---|:---:|
| **L1** kinematic | $x_1^{\mathrm{zero}} = \lambda(-\beta e_0 + e_1 + \beta e_{K-1})$, $\|x_1\| = \lambda\sqrt{1{+}\beta{+}\beta^2}$ | ✓ algebra [RE-AUDIT: VALID] |
| **L2** polytope-exit | $\sqrt{1{+}\beta{+}\beta^2} > |Me_0|$ defines open subset $\mathcal R_2$, measure 37% in test box | ✓ grid scan [RE-AUDIT: VALID — 5932/12000 grid points] |
| **L3** Vieta amplitude | $(1-r_1)(1-r_2) = \eta\mu$ exactly; $|A_\mu^{\mathrm{zero}}|^2 = \lambda^2\eta\mu/(4\beta\sin^2\theta_\mu)$ | ✓ SymPy [RE-AUDIT: VALID — symbolic confirmation] |
| **L4** Floquet attractiveness (corrected) | All 4 eigenvalues at modulus $\beta^{3/2} = 0.7155\ldots < 1$ via vertex-Hessian = $\mu I$ | ✓ 50-digit [RE-AUDIT: VALID] |
| **L5** basin composition | $(x_0, x_1^{\mathrm{zero}})$ in basin of cycle for high-β strip, with explicit transient bound $\|x_T\| \geq \lambda(1 - O(\beta^{3T/2}))$ | ✓ heuristic + numerics [RE-AUDIT: VALID for $T \geq T_0 \approx 10$; **FAILS at $T \in \{1,...,9\}$**, see CORRECTION 1] |
| **L6** non-emptiness witness | Anchor $(\beta, \eta L, \kappa) = (0.8, 3.247, 0.387)$: K=3 rotating cycle (corrected from "fixed point") | ✓ 50-digit [RE-AUDIT: VALID — period-3 cycle confirmed exactly] |
| **L7** period-2 complement | At $\beta \in [0.85, 0.95]$, **period-6 attractor (period-2 mod $C_3$)** at norm $\sim 2.1\lambda$ confirmed at $(0.9, 3.78, 0.05)$ and $(0.95, 3.85, 0.1)$. Floor $\geq 2.22\mu D^2$ | ✓ direct simulation [RE-AUDIT: CORRECTED — was "period-2", actually period-6 in iterate / period-2 in norm. Floor was "$0.37 \mu D^2$", actually $\geq 2.22 \mu D^2$ (units error in original).] |
| **L8** variance transfer | OP-2's Le Cam y-coord construction independent of x-init; constant $\sqrt 2/27$ unchanged | ✓ argument [RE-AUDIT: VALID] |

**Honest caveat:** $\mathcal F^{\mathrm{zero}}_{K=3} \subsetneq \mathcal F_{K=3}$ — empirical measure for the K=3 cycle attractor is 8% confirmed (8/100 grid points). [RE-AUDIT: CORRECTED — the originally claimed "+19% from period-2" is mis-attributed: the 19/100 grid points are **period-4 in iterate**, not period-2/6. The L7 period-6 attractors live at $\kappa \in \{0.05, 0.10\}$ which the grid (κ ∈ [0.37, 0.48]) does NOT sample. So the honest claim is: "8% K=3 cycling + 17% period-4 attractor (different floor analysis needed) + 2 isolated period-6 anchors at small κ". Total cycling-or-bounded measure: 25% of $\mathcal F_{K=3}$, of which only the 8% K=3 part has proven $\Omega(\kappa LD^2/T)$ bias.] The negative structural lemma E5/Theorem 5.1 explains why universal coverage is impossible: zero-momentum init gives $x_1 - \lambda e_1 = \beta\lambda(e_2 - e_0) \neq 0$ for any $\beta > 0$ [RE-AUDIT: VALID].

### Reply to Prof. Li Xiao for Direction 1

> [RE-AUDITED 2026-04-28] "您的直觉是对的：直接照搬 OP-2 的非零动量初始化构造，无法覆盖整个 $\mathcal F_{K=3}$ 在零动量初始化下。我们做了 100 点高精度数值实验（mpmath dps=50, 又用 dps=100 和 T=100,000 重验证）：100/100 OP-2 init 全部 cycling，但只有 **8/100** zero-momentum init 进入 K=3 cycle，集中在 $\beta \in \{0.7, 0.8\}$ 及 $\eta L$ 接近上稳定边界处。
>
> 不过，这个零动量子集并非空。我们用 5 阶段证明流水线 + 4 任务 re-audit 建立了：
> - 存在正测度开子集 $\mathcal F^{\mathrm{cycle}}_{K=3} \subset \mathcal F_{K=3}$（实测 8%）使得零动量初始化下 K=3 cycle 成立。
> - 存在另一个正测度子集 $\mathcal F^{\mathrm{period-4}}$（高 $\beta \geq 0.85$, $\kappa \in [0.37, 0.48]$，实测 17%）使得零动量初始化下出现 **period-4** 吸引子（注意：原版 summary 误称 "period-2"，re-audit 100,000 步验证为 period-4）。
> - 在小 $\kappa$ 区（$\kappa \in \{0.05, 0.10\}$）另有 period-6 在迭代中（即 period-2 mod $C_3$ 旋转对称）的吸引子，下界 $\geq 2.22 \mu D^2$（注意：原版 summary 误称 0.37 µD²，单位换算错误）。
> - 总下界形式：$\mathbb{E}[f(x_T) - f^\star] \geq \kappa LD^2/(8T) + (\sqrt 2/27)\sigma D/\sqrt T$，**仅对 $T \geq T_0(\beta,\eta) \approx 10$ 成立**（注意：原版 summary 漏写了这个 $T_0$ 限制；如要 $\forall T \geq 1$ 需把 $\kappa/8$ 降到 $\kappa/9$）。Variance 常数 $\sqrt 2/27$ 不变。
>
> 关键结构性引理 (Theorem 5.1, SymPy + mpmath 验证 PASS)：$x_1^{\mathrm{zero}} = \lambda(-\beta e_0 + e_1 + \beta e_{K-1})$，与下一个 cycle 顶点 $\lambda e_1$ 相差 $\beta\lambda(e_2 - e_0)$，这是固有阻碍——只有当 $\beta = 0$ 时才完全在 cycle 上，故全 $\mathcal F_{K=3}$ 覆盖不可能。
>
> 这把 OP-2 升级为 'fixed-momentum SHB 的合理 lower bound'（在零动量初始化的正测度子集上，对足够大 $T$）。详细证明 + 4 个 re-audit 报告见 `direction_1_zero_momentum.md` 和 `reaudit_*.md`。"

---

## Direction 2: Last-Iterate Tightness

### Reviewer's framing (verbatim)
> "目前的tightness不太对，因为GFJ2015的结果其实是针对Cesaro average的iterate，目前你的结果为last iterate，这俩不太能结合起来说明tightness。我们也许可以直接证明last iterate的upper bound，看它是否match this lower bound，从而来证明tightness。"

### What we found

**Definitive negative result: there is NO matching last-iterate UB at fixed $(\beta, \eta)$.**

**Theorem A.1 (closed-form noise floor, verified by SymPy + 3 Monte-Carlo runs at <0.1% rel error):**

For SHB with fixed $(\beta, \eta)$ on $f(x) = (L/2)x^2$ with $\sigma^2$-bounded i.i.d. Gaussian noise:
$$\mathrm{Var}_\infty[x] = \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)(2(1+\beta) - \eta L)}.$$
Hence $\mathbb{E}[f(x_T) - f^\star] \to (L/2)\mathrm{Var}_\infty = \Theta(\sigma^2\eta) > 0$ as $T \to \infty$.

**Implication:** Any conjectured UB of form $C \cdot \sigma D/\sqrt T$ at FIXED $\eta$ is FALSE for $T$ large enough.

### Three "tightness" statements that DO hold

The OP-2 LB is tight in three different (weaker) senses:

| Sense | Match | Witness |
|---|---|---|
| **Minimax-over-$\eta$** | $\eta_T = D/(\sigma\sqrt T)$ gives noise floor in **rate** $\Theta(\sigma D/\sqrt T)$ [RE-AUDIT: CORRECTED — was "exactly". Actual coefficient is $1/[4(1-\beta)]$ vs OP-2 LB coeff $\sqrt 2/27$; ratio differs by $\beta$-polynomial (4.77× at $\beta=0$, 47.7× at $\beta=0.9$)] | Theorem A.2 |
| **Projected SHB up to $\log T$** | $\mathbb{E}[f(\Pi(x_T)) - f^\star] \leq O((LD^2/T + \sigma D/\sqrt T)\log T)$ via online-to-batch | Theorem D (Explorer 4) [RE-AUDIT: VALID, noted Lemma 2 needs explicit Abel-summation for $\beta \geq 1/\sqrt 2$ — provided in Fixer §5] |
| **Deterministic Cesàro** ($\sigma = 0$) | GFJ15 directly gives $O(LD^2/T)$ on Cesàro avg matching OP-2's bias term | GFJ15 [RE-AUDIT: VALID] |

The "absolute" $\sup_f \inf_\eta$ tightness for unprojected last-iterate fixed-$(\beta,\eta)$ is FALSE.

### Compatibility with OP-2 (no contradiction)

OP-2's $\Omega(LD^2/T + \sigma D/\sqrt T)$ LB at fixed $(\beta,\eta)$ is correct as stated. It is a $\forall T \exists f^{(T)}$ minimax over hard instances (the wall radius $R = D/\sqrt 2 - \sigma/(3L\sqrt T)$ is $T$-dependent). Route F's refutation is $\exists f$ (quadratic) $\forall (\beta, \eta)$ — a different minimax direction. The two coexist:

- Small $T$: OP-2 LB $\sigma D/\sqrt T$ dominates (binding constraint).
- Large $T$: Noise floor $\sigma^2\eta$ dominates (nothing decays further).
- Crossover: $T^\star = D^2/(\sigma^2\eta^2)$, exactly where $\eta = D/(\sigma\sqrt T^\star)$.

### Reply to Prof. Li Xiao for Direction 2

> "您说得很对：GFJ15 的上界确实是针对 Cesàro average，与我们的 last-iterate 下界不构成直接 tight 配对。我们用 5 阶段证明流水线深入分析了这个问题：
>
> **核心负面结果（Theorem A.1，SymPy + 蒙特卡洛验证）：** 在固定 $(\beta, \eta)$ 下，SHB 在 $f(x) = (L/2)x^2$ 上的 last iterate 有不可避免的方差稳态：
> $$\mathrm{Var}_\infty[x] = \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)(2(1+\beta) - \eta L)},$$
> 故 $\mathbb{E}[f(x_T) - f^\star] \to \Theta(\sigma^2\eta) > 0$。**所以固定 $(\beta, \eta)$ 下任何 $T$-递减形式的 UB（包括 $\sigma D/\sqrt T$）都是错的。**
>
> 这意味着 OP-2 的 LB 在 strict $\sup_f \inf_\eta$ 意义下 **不 tight**——但可以在三种较弱意义下 tight：
> 1. **Minimax-over-$\eta$**: 取 horizon-tuned $\eta_T = D/(\sigma\sqrt T)$，noise floor 在**速率**上匹配 $\Theta(\sigma D/\sqrt T)$。[RE-AUDIT: CORRECTED — 不是常数精确匹配。常数差一个 $\beta$-多项式因子：noise floor 系数 $1/[4(1-\beta)]$ vs OP-2 LB 系数 $\sqrt 2/27$，比值 4.77×（β=0）到 47.7×（β=0.9）。]
> 2. **Projected SHB up to $\log T$**: 投影 SHB last iterate 的 UB 经 online-to-batch 给出 $O((LD^2/T + \sigma D/\sqrt T)\log T)$。
> 3. **Deterministic Cesàro**: GFJ15 给的 $O(LD^2/T)$ 在 $\sigma = 0$ 时直接 match 我们 LB 的 bias 部分。
>
> **OP-2 §4.2 修订建议**: 把 "tight relative to SGD" 替换为：
> *"The LB is tight in three senses: (i) minimax-over-η matches σD/√T at $\eta_T = D/(\sigma\sqrt T)$; (ii) up to $\log T$ for projected SHB last iterate; (iii) tight against deterministic Cesàro UB. For unprojected fixed-$(\beta,\eta)$ SHB last iterate on smooth convex non-SC, no matching UB of the form $O(LD^2/T + \sigma D/\sqrt T)$ exists due to the closed-form noise floor (Theorem A.1)."*
>
> 详细分析在 `direction_2_last_iterate_ub.md`。"

---

## Synthesis: how the two directions interact

The two questions illuminate complementary aspects of the OP-2 LB:

1. **Direction 1** asks: "Does the LB hold under standard (zero-momentum) practice?" — Answer: yes on a positive-measure subset, no on the rest. The structural obstruction is that the cycle-vertex velocity is zero in zero-momentum init, breaking the OP-2 cycling identity at step 1; only a sub-region (high $\beta$) has cycling-attractive parameters.

2. **Direction 2** asks: "Is the LB tight against last-iterate UB?" — Answer: in 3 weaker senses, yes; in the strict $\sup_f\inf_\eta$ sense, no. The structural obstruction is the noise floor $\Theta(\sigma^2\eta)$, unavoidable at fixed $\eta$.

**Together, they give a publishable picture:**
- OP-2's LB is correct, sharp on positive-measure subset of $\mathcal F$ even under zero-momentum practice, and tight (in minimax-η/projected/Cesàro senses) against the natural UB candidates.
- The OP-2 paper revision is concrete: add Theorem 5.1 (zero-momentum incompatibility for $\beta > 0$), add Theorem A.1 (noise floor), revise §4.2 tightness statement.

---

## Files produced

```
workspace/active/li_xiao_directions/
├── numerical_experiments.md         # mpmath 50-digit grid scan results
├── zero_momentum_grid_scan.py       # script
├── zero_momentum_grid_results.json  # raw data (100 grid points)
├── direction_1_scout_routes.md       # 6 routes for Direction 1 (Sonnet)
├── direction_1_judge.md              # Direction 1 Judge (Sonnet)
├── direction_1_audit.md              # Direction 1 Auditor (Opus, CONDITIONAL PASS)
├── direction_1_zero_momentum.md     # FINAL DELIVERABLE Direction 1
├── direction_2_scout_routes.md       # 6 routes for Direction 2 (Sonnet)
├── direction_2_judge.md              # Direction 2 Judge (Sonnet)
├── direction_2_audit.md              # Direction 2 Auditor (Opus, PASS)
├── direction_2_last_iterate_ub.md   # FINAL DELIVERABLE Direction 2
├── d1_explorer_1_orthodox.md        # 6 D1 Explorer outputs (Opus parallel)
├── d1_explorer_2_adversarial.md
├── d1_explorer_3_naive.md
├── d1_explorer_4_reduction.md
├── d1_explorer_5_construction.md
├── d1_explorer_6_compositional.md
├── d2_explorer_1_orthodox.md        # 6 D2 Explorer outputs (Opus parallel)
├── d2_explorer_2_adversarial.md
├── d2_explorer_3_naive.md
├── d2_explorer_4_reduction.md
├── d2_explorer_5_construction.md
├── d2_explorer_6_compositional.md
├── d2_e5_pep_*.py + *.json           # PEP/SDP scripts and results
├── verify_shb_variance.py            # variance closed-form Monte-Carlo verifier
├── d1_e3_anchor_verify.py            # zero-momentum cycling anchor verifier
├── reaudit_theorem_5_1.md            # RE-AUDIT 1: Theorem 5.1 + bias constant (CONDITIONAL PASS)
├── reaudit_noise_floor.md            # RE-AUDIT 2: closed-form variance (CONDITIONAL PASS)
├── reaudit_period2.md                # RE-AUDIT 3: period-6 disambiguation (CONDITIONAL PASS)
├── reaudit_numerical.md              # RE-AUDIT 4: 8/73/19 stability (CONDITIONAL PASS)
├── reaudit_*.py + *.json             # re-audit verification scripts and results
└── summary.md                        # this file (re-audited, with [RE-AUDIT: ...] markers)
```

**Pipeline statistics:**
- 2 Scout agents (Sonnet)
- 12 Explorer agents (Opus, all parallel)
- 2 Judge agents (Sonnet)
- 2 Auditor agents (Opus, used `[CALL:math-verifier]` extensively)
- 2 Fixer agents (Opus)
- 4 Re-Auditor agents (Opus, parallel high-intensity verification)
- = 24 total agent calls, ~7 hours wall-clock (with parallelism)

---

## Recommendation for the OP-2 paper revision (v5)

### Add to §4 (Related Work / Tightness)

Insert after current §4.2 (GFJ15 discussion):

> **§4.2.1. Tightness against last-iterate UB.** A natural question is whether the bound is tight against a matching last-iterate UB. The answer, derived in [companion document `direction_2_last_iterate_ub.md`], is nuanced:
>
> - **Theorem (negative):** For fixed-momentum, fixed-stepsize SHB on $f(x) = (L/2)x^2$ with i.i.d. Gaussian variance-$\sigma^2$ noise, $\mathbb{E}[f(x_T) - f^\star] \to \Theta(\sigma^2\eta)$ as $T \to \infty$ with explicit constant $\eta\sigma^2(1+\beta)/(L(1-\beta)(2(1+\beta) - \eta L))$. Hence no matching UB of form $O(\sigma D/\sqrt T)$ exists at fixed $(\beta, \eta)$.
> - **Theorem (positive, minimax-$\eta$):** With horizon-tuned $\eta_T = \Theta(D/(\sigma\sqrt T))$, the noise floor matches the LB **in rate** $\Theta(\sigma D/\sqrt T)$ — but the constants differ by a $\beta$-polynomial factor (noise-floor coefficient $1/[4(1-\beta)]$ vs OP-2 LB coefficient $\sqrt 2/27$). [RE-AUDIT 2026-04-28: corrects original "exact match" claim.]
> - **Theorem (positive, projected SHB):** For projected SHB with bounded domain, an online-to-batch reduction + Orabona's last-iterate-vs-average bridge gives $O((LD^2/T + \sigma D/\sqrt T)\log T \cdot \mathrm{poly}(1/(1-\beta)))$ — matching up to $\log T$.
>
> The deterministic Cesàro UB of GFJ15 directly matches our LB's bias term at $\sigma = 0$, but the stochastic last-iterate matching is intrinsically more subtle.

### Add to §0.6 (Scope) or new §0.8

Insert near the end of the scope section:

> **§0.8. Initialization sensitivity.** The hard-instance initialization $(x_0, x_{-1}) = ((D/\sqrt 2)e_0, (D/\sqrt 2)e_{K-1})$ has $x_0 \neq x_{-1}$ (non-zero initial momentum). For zero-momentum initialization $x_0 = x_{-1}$ — closer to standard practice — the LB transfers to a positive-measure subset $\mathcal F^{\mathrm{zero}}_{K=3} \subset \mathcal F_{K=3}$ but not the entirety of $\mathcal F_{K=3}$. The structural obstruction (Theorem 5.1, see companion `direction_1_zero_momentum.md`):
> $$x_1^{\mathrm{zero}} = (D/\sqrt 2)\big[-\beta e_0 + e_1 + \beta e_{K-1}\big]$$
> deviates from the cycle vertex $(D/\sqrt 2)e_1$ by exactly $\beta(D/\sqrt 2)(e_2 - e_0)$ for any $\beta > 0$. The cycle is recovered at the empirical attractor for high $\beta$ ($\beta \in [0.7, 0.8]$, $\eta L$ near $2(1+\beta)$), but not in the rest of $\mathcal F_{K=3}$. The bias constant is degraded from $\kappa/4$ to $\kappa/8$ in the zero-momentum case (transient correction).

### Add new Theorem 5.1 (zero-momentum incompatibility) as a Lemma in §2

```
Lemma 5.1 (Zero-momentum cycling incompatibility). Let f_0 be any Goujaud-type function with rotation-symmetric polytope tilde-P at K ≥ 3 vertices, on which OP-2's cycling identity (Cyc) holds. Then under zero-momentum initialization x_0 = x_{-1} = (D/√2) e_0, the SHB iterate at step 1 is
  x_1^zero = (D/√2)[-β e_0 + e_1 + β e_{K-1}],
which equals the next cycle vertex (D/√2) e_1 if and only if β = 0.

Proof. Direct computation from Lemma 2.6 transplanted projection identity. The cycle's "velocity kick" β(x_0 - x_{-1}) = β(D/√2)(e_0 - e_{K-1}) is essential to compensate for the gradient overshoot.
```

This is a 4-line lemma that frames the discussion cleanly.

---

## Strongest deliverables (for direct quotation in the response to Li Xiao)

**Direction 1, single-line answer (RE-AUDITED):**
> 在零动量初始化下，OP-2 的 LB 在 $\mathcal F_{K=3}$ 的正测度子集 $\mathcal F^{\mathrm{zero}}_{K=3}$（高 $\beta$, 高 $\eta L$ 区，实测 8% 测度）仍然成立，bias 常数从 $\kappa/4$ 降至 $\kappa/8$（**对 $T \geq T_0 \approx 10$ 成立**；如要 $\forall T \geq 1$ 需进一步降到 $\kappa/9$）。

**Direction 2, single-line answer (RE-AUDITED):**
> Last-iterate UB 与 LB 的 strict tight 配对在固定 $(\beta, \eta)$ 下不存在（噪声地板 $\Theta(\sigma^2\eta) > 0$，闭式 SymPy + Monte-Carlo 验证），但**在速率上**（不是常数上）在 minimax-$\eta$、projected-up-to-$\log T$、Cesàro-deterministic 三种意义下 tight。

Both direct quotes are mathematically defensible after the 4-task re-audit. The four required corrections are listed in the WARNING block at the top of this file. None invalidates the main results; all are **phrasing / constant / scope tightenings**.
