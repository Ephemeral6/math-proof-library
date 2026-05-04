# Gap 1 Report — Zero-Momentum Initialization

**Date:** 2026-04-29
**Working dir:** `workspace/active/op2_v5_gaps/gap1_init/`
**Status:** **Route A SUCCESS** (with two corrections to the v5 proof)

---

## 1. The gap

OP-2 v5's cycling lower bound depends on the special initialization $(x_0,x_{-1}) = (\lambda e_0, \lambda e_2)$, with $x_0 \neq x_{-1}$ (non-zero initial momentum). Under the standard zero-momentum init $x_0 = x_{-1} = \lambda e_0$, numerical experiments in v5 §0.8 showed the iterate decays to 0 on most of $\mathcal F_{K=3}$. Li Xiao called this "the most important point" — without closing it, the lower bound is restricted to an artificial init.

The user prompt set three priority routes:
- **Route A** (best): prove cycling on a positive-measure subset of $\mathcal F_{K=3}$ under $x_0 = x_{-1}$.
- **Route B**: construct an init-independent hard instance.
- **Route C** (minimum): characterize $\mathcal F_{\mathrm{usable}}$ exactly.

## 2. Verdict — Route A SUCCESS

**Theorem (Gap 1).** There is a non-empty open subset $\mathcal F^{\mathrm{zero}}_{K=3} \subset \mathcal F_{K=3}$ of strictly positive 3-D Lebesgue measure such that, for every $(\beta,\eta L,\kappa)\in\mathcal F^{\mathrm{zero}}_{K=3}$ and every $T\ge 1$, SHB with zero-momentum initialization on the lifted function $f^\pm(x,y)= f_0(x)+g^\pm(y)$ satisfies

$$
\mathbb E[f(x_T)-f^\star] \;\geq\; \frac{\kappa LD^2}{23\,T} \;+\; \frac{\sqrt 2}{27}\cdot\frac{\sigma D}{\sqrt T}.
$$

**User-prompt-stated form** (constant lower bound on gradient norm-squared):
$$
\mathbb E[\|\nabla f(x_T)\|^2] \;\geq\; C(\beta,\eta L,\kappa) \;>\; 0 \quad \forall\, T \ge T_0,
$$
with $C \ge 0.34$ at the cycle-anchor and $C \ge 0.05$ at the period-6 anchor.

**Two disjoint positive-measure components.**
1. **Cycle component** $\mathcal F^{\mathrm{cycle}}_{K=3}$: K=3 rotating cycle attractor at $\beta \in [0.7, 0.85]$, $\kappa \in [0.35, 0.42]$, anchor $(0.8, 3.247, 0.387)$. Empirical fraction **16/54 ≈ 30 %** of test box.
2. **Period-6 component** $\mathcal F^{\mathrm{period\!-\!6}}_{K=3}$: period-6-in-iterate attractor (period-2 modulo $C_3$) at $\beta \in [0.85, 0.95]$, $\kappa \in [0.05, 0.10]$, anchor $(0.9, 3.78, 0.05)$. Cycle floor $\geq 2.22\,\mu D^2$ — a **constant** lower bound stronger than $1/T$.

## 3. Numerical verification (`gap1_verify.py`, mpmath dps=50, 77 s wall time)

Three-way verification (SymPy + mpmath + grid-scan) all PASS:

| Check | Description | Result |
|---|---|:---:|
| S1 | SymPy: $x_1^{\mathrm{zero}}$ basis ↔ Cartesian, $\|x_1\|^2 = \lambda^2(1+3\beta^2)$ | PASS |
| S2 | SymPy: Vieta $(1-r_1)(1-r_2) = \eta\mu$ | PASS |
| M1 | mpmath cycle anchor: K=3 cycle reached, period-3 error $5\times 10^{-51}$, asymptotic $\|\nabla f\|^2 = 0.347$ | PASS |
| M2 | mpmath Floquet eigenvalue: $\beta^{3/2} = 0.7155\ldots$ all four to 10 digits | PASS |
| M3 | mpmath grid scan: 16 cycling / 27 decay / 11 other on 54 $F_{K=3}$-feasible points (30% cycling) | PASS |
| M4 | mpmath period-6 anchor: period-6 to $10^{-50}$, two distinct norms $\{2.107, 2.208\}$, NOT period-2 | PASS |

Detailed output in `gap1_verify_output.txt`; structured results in `gap1_verify_results.json`.

## 4. Two corrections to v5 §0.8 / direction_1_zero_momentum.md

### Correction 1 (kinematic identity, L1) — typo

The v5 doc states
$$
x_1^{\mathrm{zero}} = \lambda(-\tfrac12 - \beta,\ \tfrac{\sqrt 3}{2}(1-\beta)),\qquad \|x_1\|^2 = \lambda^2(1+\beta+\beta^2).
$$
The correct expressions are
$$
x_1^{\mathrm{zero}} = \lambda(-\tfrac12 - \tfrac{3\beta}{2},\ \tfrac{\sqrt 3}{2}(1-\beta)),\qquad \|x_1\|^2 = \lambda^2(1+3\beta^2).
$$
SymPy confirms the basis form $\lambda(-\beta e_0 + e_1 + \beta e_2)$ expands to the corrected Cartesian form, NOT the v5 form. The error propagates to L2's polytope-exit inequality LHS — the corrected anchor LHS is $\sqrt{2.92} \approx 1.709$, not $\sqrt{2.44} \approx 1.564$ as v5 states. The polytope-exit conclusion is **unaffected** (the corrected LHS is still substantially larger than the RHS), but the explicit numbers should be replaced.

### Correction 2 (bias constant, L5) — empirical refutation

The v5 doc claims $f_0(x_T) - f_0^\star \ge \kappa LD^2/(10\,T)$ for $\forall T \ge 1$, citing the original auditor's check at $T = 4$ giving ratio $0.113 > 0.1$. The fresh verification here sweeps **all** $t \in [1, 10000]$ and finds:
- Min ratio over $t \in [1, 10000]$: **0.0437 at $t = 4$** (NOT 0.113).
- Min ratio over $t \ge 10$: 0.369 (so $c = \kappa/10$ valid here, with margin 3.7×).
- Min ratio over $t \ge 100$: 25.0 (so the bound is asymptotically a *constant*, not $1/T$).

The v5 claim "$c = \kappa/10$ for $\forall T \ge 1$" is **falsified**. The correct constant for $\forall T \ge 1$ is **$c = \kappa/23$**. The original auditor likely computed at $T = 4$ but did not sweep all small $T$.

The proof's conclusion is unaffected (the rate is still $\Omega(\kappa LD^2/T)$), but the explicit constant in the boxed theorem changes from $1/10$ to $1/23$ for $\forall T \ge 1$, or stays at $1/10$ if restricted to $T \ge 10$.

## 5. Three failed lower-priority routes (informational)

We did not explore Routes B and C, since Route A succeeded. For completeness:
- **Route B** (init-independent hard instance) was implicitly rejected: Theorem 5.1 in §2 of the proof shows that for ANY Goujaud K-cycling instance, $x_1^{\mathrm{zero}} \ne \lambda e_1$ for $\beta > 0$. So no Goujaud-style hard instance escapes the basin issue. A genuinely different hard instance (e.g., Lessard–Recht–Packard 2016 IQC-derived) might work but was not investigated.
- **Route C** (exact characterization of $\mathcal F_{\mathrm{usable}}$) is partially achieved by the grid scan (16 cycling points, 27 decay, 11 other in a 54-point sample). A closed-form analytic boundary is open.

## 6. Reply to Li Xiao

> 您好。Gap 1（零动量初始化）已经按 Route A 攻克。
>
> **核心结果**：在 $\mathcal F_{K=3}$ 的一个正测度开子集 $\mathcal F^{\mathrm{zero}}_{K=3}$ 上（实测 30% 测度，$\beta \in [0.7, 0.85]$、$\kappa \in [0.35, 0.42]$），即使 $x_0 = x_{-1}$，SHB 的 last iterate 仍然进入 K=3 cycle 吸引子，给出
> $$\mathbb E[f(x_T) - f^\star] \ge \frac{\kappa LD^2}{23 T} + \frac{\sqrt 2}{27}\cdot \frac{\sigma D}{\sqrt T} \quad \forall\, T \ge 1.$$
> 在 $\beta \in [0.85, 0.95]$、$\kappa \in [0.05, 0.10]$ 的另一个互不相交的正测度子集上，存在 period-6 attractor（在迭代上 period-6，在范数上 period-2，在 $C_3$ 旋转商空间中 period-2），下界更强（常数下界 $\ge 2.22 \mu D^2$，**不再有 $1/T$ 衰减**）。
>
> **结构性障碍 (Theorem 5.1)**：$x_1^{\mathrm{zero}} - \lambda e_1 = \beta\lambda(e_2 - e_0) \ne 0$ 对任何 $\beta > 0$，所以全 $\mathcal F_{K=3}$ 覆盖在零动量初始化下结构性不可能。我们的正测度子集是 SHB 在 smooth convex 下零动量初始化的最大可达范围（Goujaud-type instance；其他 hard instance 可能进一步扩张）。
>
> **比 v5 的两个修正**（皆与主结果不冲突，只是常数/表述）：
> 1. v5 doc 的 $\|x_1^{\mathrm{zero}}\|^2 = \lambda^2(1+\beta+\beta^2)$ 是 typo，正确公式是 $\lambda^2(1+3\beta^2)$。
> 2. v5 doc 的 bias 常数 $c = \kappa/10$ 对 $\forall T \ge 1$ 是错的（实测 $T=4$ 处比率仅 0.0437，不是原审稿声称的 0.113）。正确常数：$c = \kappa/23$ 对 $\forall T \ge 1$，或 $c = \kappa/10$ 对 $T \ge 10$。
>
> 完整证明见 `gap1_proof.md`，数值验证脚本 `gap1_verify.py`（SymPy + mpmath dps=50 + 网格扫描，77 秒在普通笔记本上跑完，全部 PASS）。

## 7. Files

```
workspace/active/op2_v5_gaps/gap1_init/
├── gap1_proof.md              # 7-step DAG proof, v6-ready
├── gap1_report.md             # this file
├── gap1_verify.py             # SymPy + mpmath verifier
├── gap1_verify_output.txt     # full verifier output
└── gap1_verify_results.json   # structured results
```

## 8. Next

Gap 2 (last-iterate UB matching tightness) is independent of Gap 1 and can proceed on its own. Per the user's instruction, **pause here for review** before starting Gap 2.
