# Gap 2 Report — Last-Iterate UB Matching Tightness

**Date:** 2026-04-29
**Working dir:** `workspace/active/op2_v5_gaps/gap2_ub/`
**Status:** **Resolved.** Negative result + three positive matching senses, all verified.

---

## 1. The gap

OP-2 v5 §4.2 cites Ghadimi-Feyzmahdavian-Johansson 2015 (GFJ15) to claim tightness of the lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$. But:
- **OP-2's LB is for the last iterate.**
- **GFJ15's UB is for the Cesàro average.**

These don't match directly. Li Xiao identified this as a real gap, suggested deriving a true last-iterate UB.

The user's prompt set four steps: (1) read Orabona 2020 + Li 2022 references; (2) extract their Lyapunov technique and adapt to SHB; (3) compare LB vs UB; (4) numerically verify.

## 2. Verdict — Resolved (3-way conclusion)

**(I) NEGATIVE result.** For fixed $(\beta, \eta)$ on the unprojected setting and the worst-case $f$ being the quadratic $f(x) = (L/2)x^2$, the closed-form noise floor
$$
\mathrm{Var}_\infty[x] \;=\; \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)(2(1+\beta) - \eta L)}
$$
is **strictly positive and independent of $T$**. Hence $\liminf_T \mathbb E[f(x_T) - f^\star] \geq c_F > 0$, ruling out any $T$-decaying matching UB at fixed $(\beta, \eta)$.

**(II) POSITIVE — minimax-$\eta$.** With horizon-tuned $\eta_T = D/(\sigma\sqrt T)$, the noise floor matches LB **in rate** $\Theta(\sigma D/\sqrt T)$ (constants differ by $\beta$-polynomial: noise-floor coeff $1/[4(1-\beta)]$ vs. OP-2 LB coeff $\sqrt 2/27$, ratio $\approx 4.77\times$ at $\beta=0$, $47.7\times$ at $\beta=0.9$).

**(III) POSITIVE — projected.** With projection and horizon-tuning,
$$
\mathbb E[f(\Pi(x_T)) - f^\star] \;\le\; O\!\left(\frac{LD^2 \log T}{T(1-\beta)} + \frac{\sigma D \sqrt{\log T}}{\sqrt{T(1-\beta)}}\right),
$$
matching LB up to $\sqrt{\log T}$ factor.

**(IV) POSITIVE — Cesàro.** $\frac{1}{T}\sum \mathbb E[f(x_t) - f^\star] \le D^2/(2\eta T) + \eta\sigma^2/(1-\beta^2)$; horizon-tuned gives $\Theta(\sigma D/\sqrt T)$.

## 3. References (`gap2_references.md`)

Both references Li Xiao cited were found and read via `WebFetch`/`WebSearch` (no Pedregosa hallucinations):

1. **Orabona 2020 blog** (Francesco Orabona, parameterfree.com, Aug 7 2020). Plain SGD on **Lipschitz convex** with $\eta_t = \alpha/\sqrt t$ → last-iterate $O(\log T/\sqrt T)$ via the one-step potential inequality. **Suboptimal** by $\log T$ vs. average-iterate $O(1/\sqrt T)$.

2. **Li-Liu-Orabona 2022** (Xiaoyu Li, Mingrui Liu, Francesco Orabona, **ALT 2022**, PMLR v167:699-717, arXiv:2102.07002). Constant-momentum SGDM on **Lipschitz convex** has Ω(log T/√T) lower bound on last iterate; FTRL with increasing $\beta_t$ + shrinking updates achieves $O(1/\sqrt T)$. **Citation correction**: Li Xiao said "COLT" but the paper is in **ALT** (PMLR v167 = ALT 2022; PMLR v178 = COLT 2022).

**Why Lyapunov adaption from Orabona/Li doesn't directly give us a fixed-$(\beta,\eta)$ UB.** Both papers operate in the **Lipschitz convex** regime, with **time-varying** $\eta_t$ (and Li uses time-varying $\beta_t$). Our setting is fixed $(\beta, \eta)$ on **L-smooth convex non-SC**. The smoothness regime introduces a stronger obstruction: the closed-form noise floor of Theorem A.1 gives a **constant** (T-independent) lower bound, strictly stronger than the Lipschitz-regime $\Omega(\log T/\sqrt T)$ obstacle.

So we cannot just "adapt the Lyapunov" — there is no Lyapunov function that proves a fixed-$(\beta, \eta)$ matching UB on $L$-smooth convex non-SC, because **the actual quantity being bounded does not decay**.

## 4. Numerical verification (`gap2_verify.py`, 8 checks, all PASS, 12 s wall time)

| Check | Description | Result |
|---|---|:---:|
| S1 | SymPy: closed-form Lyapunov variance matches boxed formula (5) | PASS |
| S2 | SymPy: leading $\eta\to 0$ gives $\sigma^2/[2L(1-\beta)]$; $\beta=0$ collapse to AR(1) | PASS |
| S3 | SymPy: 3-term Lyapunov drift cross-terms cancel with chosen $c_1, c_2$ | PASS |
| S4 | SymPy: change-of-variables $z_t = x_t + a(x_t - x_{t-1})$ gives exact OGD | PASS |
| M1 | mpmath dps=50 independent Lyapunov solve at anchor: rel_err $1.87 \times 10^{-51}$ | PASS |
| MC1 | Monte Carlo at 4 $(\beta, \eta L)$ settings: max rel_err 0.42% < 1% | PASS |
| MC2 | MC log-log fit at horizon-tuned $\eta_T$: empirical slope $T^{-0.501}$ | PASS |
| MC3 | MC at fixed $(\beta, \eta) = (0.5, 0.1)$ over $T \in \{10^2, ..., 5\times 10^4\}$: $\mathbb E[f(x_T)]$ saturates at noise floor 0.052 — no T-decay | PASS |

Three-way (SymPy + mpmath + Monte Carlo) agreement on the closed-form variance.

## 5. Two corrections to direction_2 v5

### Correction 1 (S2 leading-order coefficient)

Direction_2 v5 §0.4 says the leading order of Var$_\infty$ as $\eta\to 0$ is $\sigma^2/[L(1-\beta^2)]$. The correct leading order is **$\sigma^2/[2L(1-\beta)]$** (off by factor $(1+\beta)/2$). The form $\sigma^2 \eta/(1-\beta^2)$ that appears in the Cesàro UB constant (direction_2 §4) is an *upper bound coefficient*, not the noise-floor leading term. Cleanly:
$$
\mathrm{Var}_\infty[x] = \underbrace{\frac{\sigma^2}{2L(1-\beta)}}_{\text{leading}}\,\eta + O(\eta^2).
$$

### Correction 2 (Li-Liu-Orabona venue)

Direction_2 v5 references "Li 2022 COLT" — the actual venue is **ALT 2022** (PMLR v167). Li Xiao's review used the wrong abbreviation; OP-2 v6 should cite "Li, Liu, Orabona, *On the Last Iterate Convergence of Momentum Methods*, ALT 2022 (PMLR v167:699–717), arXiv:2102.07002".

## 6. Reply to Li Xiao

> 您好。Gap 2（last-iterate UB matching tightness）已经按 Step 1-4 完成。
>
> **核心结论**：固定 $(\beta, \eta)$ 下 unprojected SHB 在 L-smooth convex non-SC 上的 last-iterate **没有匹配的 $T$-递减 UB**——因为存在闭式噪声地板（Theorem A.1）：
> $$\mathrm{Var}_\infty[x] = \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)(2(1+\beta) - \eta L)} > 0,$$
> $T$-无关。这个负面结果通过 SymPy + mpmath dps=50 + Monte Carlo 三方验证（rel_err < 0.5%）。
>
> **您建议的 Orabona 2020 + Li 2022 技术不能直接 adapt 到固定 $(\beta,\eta)$**：
> 1. **Orabona 2020 blog**（确认作者 Francesco Orabona, 2020/8/7）针对 Lipschitz convex SGD with $\eta_t = \alpha/\sqrt t$（time-varying）给出 $O(\log T/\sqrt T)$ last iterate。固定 $\eta$ 条件下 Lyapunov 失效。
> 2. **Li-Liu-Orabona 2022**（注：实际是 **ALT 2022**, PMLR v167:699-717, 不是 COLT；arXiv:2102.07002）在 Lipschitz convex 上证明 constant-$\beta$ SGDM 有 $\Omega(\log T/\sqrt T)$ 的 last-iterate lower bound。这与我们的 noise-floor 结论方向一致——两者都说固定 momentum 不足以达到 last-iterate optimality——但 Li 2022 在 Lipschitz 设定下还允许 $\log T/\sqrt T$ 缓慢衰减；我们在 L-smooth 设定下的障碍是常数下界（更强）。
>
> **三种可达的 tightness（OP-2 §4.2 推荐重写）：**
> 1. **Minimax-over-$\eta$**（Theorem A.2）：$\eta_T = D/(\sigma\sqrt T)$，noise floor 在**速率**上匹配 $\Theta(\sigma D/\sqrt T)$（常数差 $\beta$-多项式）。
> 2. **Projected up to $\sqrt{\log T}$**（Theorem D）：$\mathbb E[f(\Pi(x_T)) - f^*] \le O(LD^2\log T/[T(1-\beta)] + \sigma D \sqrt{\log T}/\sqrt{T(1-\beta)})$。
> 3. **Cesàro / GFJ15-style**（Theorem B）：$\sigma=0$ 时直接匹配 LB 的 bias 部分。
>
> **直接 adapt 失败的原因**：Lyapunov drift inequality 要求残差项可控；在 fixed $(\beta, \eta)$ 下噪声引起的 $\eta^2 \sigma^2$ 累积每步是常数，无法用 telescope 消掉。Li 2022 的 FTRL 解法本质上需要 $\beta_t \uparrow 1$ 和 $\eta_t \downarrow 0$——time-varying schedule。固定 $(\beta, \eta)$ 没有救。
>
> **OP-2 v6 §4.2 修订建议**：见 `gap2_proof.md` §6。
>
> 完整证明 + 4 篇引用核验 + 数值验证脚本：`gap2_proof.md`, `gap2_references.md`, `gap2_verify.py`。

## 7. Files

```
workspace/active/op2_v5_gaps/gap2_ub/
├── gap2_proof.md              # Main proof: Theorem A.1 (negative) + A.2/B/D (positive)
├── gap2_report.md             # this file
├── gap2_references.md         # Orabona 2020 + Li-Liu-Orabona 2022 + Sebbouh 2021 + GFJ15 summaries (verified URLs)
├── gap2_verify.py             # 8-check three-way verifier (SymPy + mpmath dps=50 + MC)
├── gap2_verify_output.txt     # Full verifier output
└── gap2_verify_results.json   # Structured results
```

## 8. Bottom-line answer to Li Xiao's two-line question

| Li Xiao asked | Answer |
|---|---|
| "Can we directly prove last-iterate UB matching the LB?" | **No** at fixed $(\beta, \eta)$ on unprojected SHB, due to closed-form noise floor (Theorem A.1). |
| "If not, what slower rate? Compare to LB." | None — the rate is **constant** (independent of $T$), strictly worse than $1/T$ or $1/\sqrt T$. The LB-UB gap at fixed $(\beta, \eta)$ is **infinite as $T\to \infty$**. |
| "What's the right tightness statement?" | **Three matching senses**: minimax-$\eta$ (Theorem A.2, in rate), projected-up-to-$\sqrt{\log T}$ (Theorem D), Cesàro-deterministic (Theorem B). The strict $\sup_f \inf_\eta$ pointwise tightness for unprojected fixed-$(\beta,\eta)$ SHB on smooth convex non-SC **does not exist**. |
| "Adapt Orabona/Li Lyapunov technique?" | **Cannot** — both their settings are Lipschitz convex with time-varying schedule, fundamentally incompatible with fixed-$(\beta,\eta)$ on L-smooth. Their negative results (constant-momentum suboptimality) corroborate ours; their positive results (FTRL with increasing $\beta_t$) require the schedule we don't have. |

This is the honest, peer-review-defensible answer to the gap.

## 9. Next

Both Gap 1 and Gap 2 are now resolved with clean deliverables. **Pause for review.**

If both are accepted, suggested next step would be merging the v5 §0.8 and §4.2 into a v6 paper with the corrected statements (κ/23 instead of κ/10 in §0.8; the four-fold tightness picture in §4.2; the kinematic-identity typo $1+3\beta^2$).
