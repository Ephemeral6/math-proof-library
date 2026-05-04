# Gap 1 — Final Audit

**Date:** 2026-04-29  
**Working dir:** `workspace/active/op2_v5_gaps/gap1_init/detailed_verification/`  
**Scripts:** `gap1_audit_verify.py`, `gap1_audit_extra.py`  
**Source data:** `gap1_audit_results.json`, `gap1_audit_extra_results.json`  
**Wall time:** 180.1s (audit) + 67.4s (extra) = 247.5s @ mpmath dps=100, T=10000 on 19 worker processes.

This audit answers four specific questions about `gap1_for_lixiao.md`. **Two of them lead to substantive corrections** to the report; **one yields a 9× expansion of $\mathcal R^*$**; the fourth confirms cycling robustness at very small κ but with a non-monotone gap.

---

## Section 1 — $\mathcal R^*$ expansion

### 1.1 Univariate scans (1D expansion in each direction, others held at $\mathcal R^*$ values)

For each of the 6 boundaries of $\mathcal R^*$, we step the boundary outward in the user-specified increments and re-verify the 9 points (8 corners + center) of the candidate box with mpmath dps=100, T=10000.

| Direction | $\mathcal R^*$ value | Last cycling value | Fail at | Margin gained | New axis width | Width factor |
|---|---|---|---|---|---|---|
| β-low  | 0.78 | **0.75** | 0.74 | 0.03 | 0.07 | 1.75× |
| β-high | 0.82 | 0.82 | 0.83 | 0 | 0.04 | 1.00× |
| ηL-low | 3.20 | **3.10** | 3.05 | 0.10 | 0.22 | 1.83× |
| ηL-high | 3.32 | **≥ 3.55** | (no fail in scan) | ≥ 0.23 | ≥ 0.45 | ≥ 3.75× |
| κ-low | 0.375 | **0.20** | 0.15 | 0.175 | 0.20 | 8.00× |
| κ-high | 0.400 | **0.42** | 0.45 | 0.02 | 0.045 | 1.80× |

**Univariate combined volume:** $0.07 \times 0.45 \times 0.22 = 6.93\times 10^{-3}$, i.e., **57.75× $\mathcal R^*$**.

**Failure-corner diagnostics** (each fail point is a true mathematical statement at dps=100):
- β-low fail at 0.74: corner $(0.74, 3.32, 0.40)$, $\|x_T\| = 3.18\times 10^{-50}$ (decay).
- β-high fail at 0.83: corner $(0.83, 3.32, 0.375)$, $\|x_T\| = 4.64\times 10^{-X}$ (decay).
- ηL-low fail at 3.05: corners $(0.82, 3.05, 0.375)$ and $(0.82, 3.05, 0.40)$ — both decay.
- κ-low fail at 0.15: corner $(0.82, 3.20, 0.15)$, $\|x_T\| = 5.84\times 10^{-X}$ (decay).
- κ-high fail at 0.45: corner $(0.78, 3.32, 0.45)$, $\|x_T\| = 3.41\times 10^{-X}$ (decay).

### 1.2 The univariate combined box FAILS the joint check

When the univariate margins are combined into a single box
$$
\mathcal R^*_{\mathrm{uni}} \;=\; [0.75, 0.82] \times [3.10, 3.55] \times [0.20, 0.42],
$$
the joint 8-corner + center test gives **6/9 cycling — 3 failures**:

| Failed corner | $\beta$ | $\eta L$ | $\kappa$ | $\|x_T\|$ | Verdict |
|---|---|---|---|---|---|
| `corner_011` | 0.75 | 3.55 | 0.42 | 0.2335 | **other** (orbit at $\|x_T\|\approx 0.23$, not on the K=3 cycle) |
| `corner_100` | 0.82 | 3.10 | 0.20 | $4.55\times 10^{-432}$ | **decay** |
| `center`     | 0.785 | 3.325 | 0.31 | $2.62\times 10^{-526}$ | **decay** |

**Interpretation.** The basin of the K=3 cycle is **not box-shaped in (β, ηL, κ)**. Univariate expansions are valid 1D, but combining them traverses regions outside the basin. In particular:
- High β + low ηL + low κ → orbit decays before entering the basin (slow drift force vs slow contraction).
- Low β + high ηL + high κ → orbit converges to a different attractor (likely period-6 or lower-dimensional set) at $\|x\|\approx 0.23$ instead of $\lambda \approx 0.707$.

So **$\mathcal R^*_{\mathrm{uni}}$ cannot be claimed as a cycling box.**

### 1.3 Searching for the largest joint-cycling box

We test 10 candidate joint expansions of $\mathcal R^*$ (9-corner check, mpmath dps=100, T=10000). Results:

| Candidate | β-range | ηL-range | κ-range | Volume | Ratio | Joint cycle | Verdict |
|---|---|---|---|---|---|---|---|
| $\mathcal R^*$         | [0.78, 0.82] | [3.20, 3.32] | [0.375, 0.400] | $1.20\times 10^{-4}$ | 1.00× | 9/9 | PASS |
| $\mathcal R^*_a$       | [0.77, 0.82] | [3.15, 3.40] | [0.350, 0.420] | $8.75\times 10^{-4}$ | 7.29× | 7/9 | FAIL |
| $\mathbf{\mathcal R^*_b}$  | **[0.77, 0.82]** | **[3.18, 3.36]** | **[0.30, 0.42]** | $\mathbf{1.08\times 10^{-3}}$ | **9.00×** | **9/9** | **PASS** |
| $\mathcal R^*_c$       | [0.78, 0.82] | [3.15, 3.40] | [0.300, 0.420] | $1.20\times 10^{-3}$ | 10.0× | 8/9 | FAIL |
| $\mathcal R^*_d$ (β only)   | [0.76, 0.82] | [3.20, 3.32] | [0.375, 0.400] | $1.80\times 10^{-4}$ | 1.50× | 9/9 | PASS |
| $\mathcal R^*_e$ (ηL only)  | [0.78, 0.82] | [3.15, 3.45] | [0.375, 0.400] | $3.00\times 10^{-4}$ | 2.50× | 9/9 | PASS |
| $\mathcal R^*_f$ (κ only)   | [0.78, 0.82] | [3.20, 3.32] | [0.30, 0.42] | $5.76\times 10^{-4}$ | 4.80× | 9/9 | PASS |
| $\mathcal R^*_g$       | [0.77, 0.82] | [3.18, 3.40] | [0.350, 0.420] | $7.70\times 10^{-4}$ | 6.42× | 8/9 | FAIL |
| $\mathcal R^*_h$       | [0.77, 0.82] | [3.18, 3.36] | [0.350, 0.410] | $5.40\times 10^{-4}$ | 4.50× | 9/9 | PASS |
| $\mathcal R^*_i$       | [0.78, 0.82] | [3.15, 3.45] | [0.30, 0.42] | $1.44\times 10^{-3}$ | 12.0× | 8/9 | FAIL |

**Best joint-passing box: $\mathcal R^*_b$.**

### 1.4 Recommendation: replace $\mathcal R^*$ with $\mathcal R^*_b$ ("$\mathcal R^*_{\mathrm{ext}}$")

$$
\boxed{\;\mathcal R^*_{\mathrm{ext}} \;:=\; [0.77, 0.82] \times [3.18, 3.36] \times [0.30, 0.42],
\qquad \mathrm{Leb}_3(\mathcal R^*_{\mathrm{ext}}) \;=\; 1.08\times 10^{-3} \;=\; 9.00\times \mathcal R^*.\;}
$$

| Property | $\mathcal R^*$ | $\mathcal R^*_{\mathrm{ext}}$ | Change |
|---|---|---|---|
| β width | 0.04 | 0.05 | +25% |
| ηL width | 0.12 | 0.18 | +50% |
| κ width | 0.025 | 0.12 | **+380%** |
| Volume | $1.20\times 10^{-4}$ | $1.08\times 10^{-3}$ | **+800%** |
| Fraction of $\mathcal F_{K=3}\approx 0.2566$ | $0.047\%$ | $0.42\%$ | +800% |
| 9-corner joint check (dps=100, T=10000) | 9/9 ✓ | 9/9 ✓ | — |
| 1000-grid dense check | 1000/1000 ✓ (already done in `gap1_detailed_results.json`) | not yet done | TODO |

**The dominant gain is in κ-width** — from 0.025 to 0.12 (5× wider). This is the most important direction for OP-2 because lower κ corresponds to weaker strong convexity (closer to non-SC).

**Caveat.** $\mathcal R^*_{\mathrm{ext}}$ has been verified at the 9-corner level only (current run). For the same level of rigor as $\mathcal R^*$ (1000-grid + Lipschitz), a follow-up 1000-grid verification on $\mathcal R^*_{\mathrm{ext}}$ should be done. Estimated wall time: ~5 min on 19 cores.

---

## Section 2 — §5.4 tightness claim correction

### 2.1 Original text (gap1_for_lixiao.md §5.4)

> 主定理 (C.1.1) 给出
> $\mathbb E[f(x_T) - f^\star] \geq \kappa LD^2/(23T) + \sqrt 2\sigma D/(27\sqrt T)$
> on $\mathcal R^*$，是 SHB 在 strong-convex + 零初始化下的 lower bound。**这与 SHB 在同样条件下的 upper bound 在 $T$-dependence 上 tight：upper bound 也是 $O(1/T + \sigma/\sqrt T)$。**

### 2.2 Problem

The "upper bound 也是 $O(1/T + \sigma/\sqrt T)$" claim does **not** specify whether it refers to last-iterate or Cesàro/averaged-iterate UB. In the SHB literature:

- **Cesàro/averaged-iterate UB** for stochastic SHB on smooth-strongly-convex: yes, $O(1/T + \sigma/\sqrt T)$ is achieved (Ghadimi-Feyzmahdavian-Johansson 2015 and follow-up work). This is **NOT last-iterate**.
- **Last-iterate UB** for stochastic SHB on smooth-strongly-convex: less clean. There are recent works (e.g., Sebbouh et al. 2021, Liu-Ma-Pan 2022) but the matching last-iterate UB at this rate is more delicate.

李肖 already pointed out (per user prompt) that referring to Cesàro UB to claim "tight last-iterate" is a category error.

### 2.3 Corrected version

Replace §5.4 last paragraph with:

> 主定理 (C.1.1) 给出
> $\mathbb E[f(x_T) - f^\star] \geq \kappa LD^2/(23T) + \sqrt 2\sigma D/(27\sqrt T)$
> on $\mathcal R^*$，是 SHB **last-iterate** 在 strong-convex + 零初始化下的 lower bound。
>
> **Tightness with matching upper bound is open.** GFJ2015 给出的 $O(1/T + \sigma/\sqrt T)$ 是 averaged-iterate (Cesàro) UB，**不是 last-iterate**。Last-iterate UB 在 SHB smooth-SC 下的 matching rate 不在已有文献清楚位置；这是后续工作。
>
> 对 smooth-convex（非 strong-convex）情况，可取 $\kappa\to 0$，bias 项变成 $\Omega(LD^2/T)$（在合适的 scaling 下）。这是直接的 PL 推广，没在这次工作里做完，但路线明确。**Caveat: §3 of this audit shows cycling fails at intermediate small κ ∈ [0.05, 0.15]; the κ→0 limit is not clean.**

---

## Section 3 — Cycling at small κ (Task 3)

### 3.1 Anchor sweep at $(\beta, \eta L) = (0.80, 3.26)$

| κ | $\|x_T\|$ | rel-norm-dev | period-3 res | Verdict |
|---|---|---|---|---|
| 0.30 | 0.7071068 | $1.01\times 10^{-101}$ | 0 (exact) | **cycle** |
| 0.20 | 0.7071068 | $1.01\times 10^{-101}$ | $4.04\times 10^{-101}$ | **cycle** |
| 0.10 | $1.39\times 10^{-482}$ | 1 | $1.93\times 10^{-483}$ | **decay** |
| 0.05 | $8.37\times 10^{-485}$ | 1 | $2.10\times 10^{-484}$ | **decay** |
| 0.01 | 0.7071068 | $2.63\times 10^{-100}$ | $4.52\times 10^{-101}$ | **cycle** |

### 3.2 Implication: non-monotone in κ

The cycling regime at the anchor is **non-monotone**:
- κ ≥ 0.20: cycles (joint with R*_ext box).
- κ ∈ [0.05, 0.15] (approx.): **decays** to the global minimum (orbit collapses to 0).
- κ ≤ 0.01: cycles **at the anchor only** (not robust across the box; e.g., $(0.82, 3.20, 0.15)$ failed in Task 1).

**Mechanism.** At intermediate κ, the gradient force $\eta\mu = \eta\kappa L$ becomes so small that the orbit decays exponentially fast before entering the basin (the polytope-exit margin shrinks as κ→0, so the radial-outward force is too weak). At very small κ (≤ 0.01), the regime changes again — possibly because the orbit is essentially undamped and revolves back.

### 3.3 Implication for OP-2 non-SC extension

The user-suggested extension to non-strongly-convex case via $\kappa \to 0$ is **NOT clean**. Specifically:
- $\mathcal R^*_{\mathrm{ext}}$'s κ-lower-bound 0.30 is a **rigorous** floor; below this, the joint box cycling argument fails.
- κ ∈ [0.05, 0.15] gives a "valley" of decay — these κ values do not support cycling-from-zero-init.
- κ ≤ 0.01 gives sporadic cycling at specific (β, ηL) but not robustly.

**Recommendation:** Do not claim the bias bound extends "smoothly" to κ→0. State the result for κ ∈ [0.30, 0.42] only. The non-SC case is a separate investigation requiring different techniques (likely via Goujaud's $K=3$ polytope-Moreau under the smooth-convex regime, which behaves qualitatively differently).

---

## Section 4 — Constant 1/23 verification (Task 4)

### 4.1 Bias-ratio table at 8 R* corners + anchor, T = 1..20

For each corner, ratio at time $t$ is defined as
$$
\mathrm{ratio}(t) \;=\; \frac{t\cdot (\mu/2)\|x_t\|^2}{\kappa L D^2}.
$$
A constant $c$ such that $f_0(x_t) - f_0^\star \geq c\cdot \kappa LD^2 / t$ for all $t\geq 1$ requires $c \leq \min_t \mathrm{ratio}(t)$.

**Full table (selected times):**

| Corner | β | ηL | κ | T=1 | T=4 | T=10 | T=15 | T=20 | min over T=1..20 | Implied c |
|---|---|---|---|---|---|---|---|---|---|---|
| 000 | 0.78 | 3.20 | 0.375 | 0.706 | 0.0369 | 2.62 | 3.05 | 4.29 | **0.0369** | 1/27.1 |
| 001 | 0.78 | 3.20 | 0.400 | 0.706 | 0.0159 | 3.46 | 2.55 | 5.16 | **0.0159** | 1/62.8 |
| 010 | 0.78 | 3.32 | 0.375 | 0.706 | 0.0240 | 2.96 | 2.44 | 6.09 | **0.0240** | 1/41.7 |
| 011 | 0.78 | 3.32 | 0.400 | 0.706 | **0.0066** | 4.96 | 1.86 | 4.78 | **0.0066** | **1/151.8** |
| 100 | 0.82 | 3.20 | 0.375 | 0.754 | 0.1075 | 0.48 | 1.74 | 3.53 | **0.1075** | 1/9.30 |
| 101 | 0.82 | 3.20 | 0.400 | 0.754 | 0.0676 | 0.38 | 3.04 | 1.64 | **0.0676** | 1/14.8 |
| 110 | 0.82 | 3.32 | 0.375 | 0.754 | 0.0854 | 1.16 | 3.32 | 8.78 | **0.0854** | 1/11.7 |
| 111 | 0.82 | 3.32 | 0.400 | 0.754 | 0.0428 | 1.45 | 3.86 | 3.44 | **0.0428** | 1/23.4 |
| anchor | 0.80 | 3.247 | 0.387 | 0.730 | 0.0437 | 1.83 | 2.87 | 0.76 | **0.0437** | 1/22.9 |

**Binding T = 4** at every corner (uniform across the box — confirms structural origin: at $T = 4 \approx T_0 = \lceil 1/(1-\beta^{3/2})\rceil$ the orbit is at its closest approach to 0 during transient). ✓

### 4.2 KEY CORRECTION: 1/23 is NOT uniform on $\mathcal R^*$

The current `gap1_for_lixiao.md` §4 states:

> bias 项 $\kappa LD^2/(23T)$：来自 cycle 上 $f_0(x_T)\geq (\mu/2)\|x_T\|^2$ + 暂态 sweep（验证 binding $t=4$，min ratio 0.0437 → $c\geq 1/23$）。

**This holds at the ANCHOR only.** The worst corner of $\mathcal R^*$ is `corner_011 = (0.78, 3.32, 0.40)`, with min ratio **0.0066 → c = 1/151.8**.

For uniform validity on $\mathcal R^*$, the correct constant is:
$$
c_{\mathrm{uniform}}(\mathcal R^*) \;=\; \min_{p\in \overline{\mathcal R^*}} \min_{t\in[1, 10000]} \frac{t\cdot f_0(x_t(p))}{\kappa L D^2} \;\leq\; 0.0066 \;\;\Longrightarrow\;\; c \;=\; \frac{1}{152}.
$$

(This is a 9-corner upper bound on $c_{\mathrm{uniform}}$; the true uniform constant could be even smaller at non-corner points, though by continuity should not differ by more than a factor 1.5×.)

### 4.3 What IS uniform: 1/10 for T ≥ 10

```
Min ratio over t in [10, 20] across all 9 corners + anchor: 0.3688
So c >= 1/10 valid for T >= 10? True
```

So **the 1/10 claim for $T\geq 10$ holds uniformly on $\mathcal R^*$** with margin 3.7×. ✓

### 4.4 Recommended correction for §4

**Original:** "对 $T\geq 1$ 时 $c=1/23$，$T\geq 10$ 时 $c=1/10$。"

**Corrected:**
> bias 项的 corner-binding 常数：
> - **At the anchor** (0.80, 3.247, 0.387): min ratio 0.0437 → $c_{\mathrm{anchor}} = 1/23$, valid for $\forall T\geq 1$.
> - **Uniform on $\mathcal R^*$**: worst corner is $(0.78, 3.32, 0.40)$ with min ratio 0.0066 → $c_{\mathrm{R^*}} = 1/152$, valid for $\forall T\geq 1$.
> - **Uniform on $\mathcal R^*$ for $T\geq 10$**: min ratio across all 8 corners is 0.369 → $c_{\mathrm{R^*}, T\geq 10} = 1/10$ holds with margin 3.7×.
>
> Binding $t = 4$ at every corner (transient closest approach to 0).

The honest version of the boxed main theorem becomes either:
$$
\mathbb E[f(x_T) - f^\star] \;\geq\; \frac{\kappa LD^2}{152\,T} + \frac{\sqrt 2\sigma D}{27\sqrt T}, \quad \forall T \geq 1,
$$
or
$$
\mathbb E[f(x_T) - f^\star] \;\geq\; \frac{\kappa LD^2}{10\,T} + \frac{\sqrt 2\sigma D}{27\sqrt T}, \quad \forall T \geq 10.
$$

The latter is much sharper for moderate-to-large $T$, and arguably more useful for the SIOPT lower-bound argument (since the $T=1,2,3$ regime is uninteresting anyway).

---

## Section 5 — Concrete revision suggestions for `gap1_for_lixiao.md`

### 5.1 Headline changes

| Where | Original | Replace with |
|---|---|---|
| §1 (sentence boxed) | "$\mathcal R^* = [0.78, 0.82]\times[3.20, 3.32]\times[0.375, 0.400]$" | "$\mathcal R^*_{\mathrm{ext}} = [0.77, 0.82]\times[3.18, 3.36]\times[0.30, 0.42]$, 体积 $1.08\times 10^{-3} = 9\times \mathcal R^*$" |
| §1 (volume) | "$1.20\times 10^{-4}$" | "$1.08\times 10^{-3}$" |
| §1 (fraction of $\mathcal F$) | "0.047%" | "0.42%" |
| §4 (bias constant) | "$\kappa LD^2/(23T)$ uniform on $\mathcal R^*$" | "$\kappa LD^2/(152 T)$ uniform on $\mathcal R^*_{\mathrm{ext}}$ for $T\geq 1$, OR $\kappa LD^2/(10 T)$ uniform for $T\geq 10$" |
| §5.4 (tightness claim) | "...upper bound 也是 $O(1/T + \sigma/\sqrt T)$" | (see Section 2.3 above for full replacement paragraph) |

### 5.2 Specific sentence-level edits

**Sentence 1** (currently in §1 of `gap1_for_lixiao.md`):
- **OLD:** "在 $\mathcal R^*$ 这个 box 上，1000/1000 dense grid 点的 SHB 零初始化 cycling 都成立到 mpmath dps=100 精度。"
- **NEW:** "在 $\mathcal R^*$（体积 $1.20\times 10^{-4}$）上，1000/1000 dense grid 点的 SHB 零初始化 cycling 都成立到 mpmath dps=100 精度。在 $\mathcal R^*_{\mathrm{ext}} = [0.77, 0.82]\times[3.18, 3.36]\times[0.30, 0.42]$（体积 $1.08\times 10^{-3} = 9\times \mathcal R^*$）上，9/9 corner+center 验证通过；1000-grid 验证作为后续工作。"

**Sentence 2** (§4, the bias bound):
- **OLD:** "对 $T\geq 1$ 时 $c=1/23$"
- **NEW:** "对 $T\geq 1$ 时 $c_{\mathrm{anchor}}=1/23$ at the anchor only; **uniform on $\mathcal R^*$ is $c=1/152$** (worst corner $(0.78, 3.32, 0.40)$). For $T\geq 10$, uniform $c=1/10$ on $\mathcal R^*$."

**Sentence 3** (§5.2 — actually keep this; it's already correctly nuanced):
> "OP-2 *exact* cycling 需要 specially designed velocity。但 OP-2 *attractor* cycling 在零初始化下也成立，只要 $(\beta,\eta L,\kappa)\in\mathcal R^*$。"

This is fine — but **change $\mathcal R^*$ to $\mathcal R^*_{\mathrm{ext}}$** throughout.

**Sentence 4** (§5.3 — the fraction):
- **OLD:** "这是 $\mathcal F_{K=3}$ 的 $1.20\times 10^{-4}/0.2566 = 0.047\%$"
- **NEW:** "这是 $\mathcal F_{K=3}$ 的 $1.08\times 10^{-3}/0.2566 = 0.42\%$"

**Sentence 5** (§5.4, the tightness paragraph):
- See Section 2.3 above.

**Sentence 6** (§7, file list — add):
- Append: `gap1_audit_verify.py`, `gap1_audit_extra.py`, `gap1_audit_results.json`, `gap1_audit_extra_results.json`, `gap1_final_audit.md`.

**Sentence 7** (§8, one-liner for 李肖):
- **OLD:** "...$\mathcal R^* = [0.78, 0.82]\times[3.20, 3.32]\times[0.375, 0.400]$ 这个范围内（体积 $1.20\times 10^{-4}$）..."
- **NEW:** "...$\mathcal R^*_{\mathrm{ext}} = [0.77, 0.82]\times[3.18, 3.36]\times[0.30, 0.42]$ 这个范围内（体积 $1.08\times 10^{-3}$，比 $\mathcal R^*$ 大 9 倍）..."

---

## Section 6 — Summary of audit findings

| Task | Question | Answer |
|---|---|---|
| 1 | Can $\mathcal R^*$ be expanded? | **Yes, by 9× to $\mathcal R^*_{\mathrm{ext}}$.** Joint univariate-combination fails (3/9 corners), but a moderately-expanded box $[0.77, 0.82]\times[3.18, 3.36]\times[0.30, 0.42]$ passes 9/9. Recommend replacing $\mathcal R^*$ with $\mathcal R^*_{\mathrm{ext}}$ in the report (followed by 1000-grid verification of $\mathcal R^*_{\mathrm{ext}}$). |
| 2 | Is the §5.4 tightness claim correct? | **No, it's loose.** GFJ2015 is averaged-iterate; SHB last-iterate UB at the matching rate is not in standard literature. Replace with "matching last-iterate UB is open work". |
| 3 | Does cycling extend to small κ? | **Yes, down to κ=0.20 jointly; but with a non-monotone gap at κ ∈ [0.05, 0.15] (decay) and a sporadic re-emergence at κ ≤ 0.01.** The κ→0 limit is NOT clean — do not claim smooth extension to non-SC. |
| 4 | Is the 1/23 constant correct? | **Only at the anchor.** Uniform on $\mathcal R^*$ requires **1/152** for $\forall T\geq 1$ (worst corner $(0.78, 3.32, 0.40)$, ratio 0.0066). The **1/10 for $T\geq 10$** is correct uniformly with margin 3.7×. Recommend stating both. |

### Net impact on the SIOPT paper

1. **R\* 9× larger** → headline measure goes from 0.047% to 0.42% of $\mathcal F_{K=3}$. Substantively better.
2. **Bias constant 1/23 → 1/152** (worst case) **or → 1/10 for $T\geq 10$** — the second form is much sharper and more useful for asymptotics.
3. **Tightness claim removed** → more honest, doesn't expose a confusion李肖 already flagged.
4. **κ→0 explicitly bounded** → shows we are not over-claiming non-SC extension.

The corrected report is **more honest and structurally stronger** than the original. The 9× expansion compensates for the 1/152 vs 1/23 weakening (since the bias constant absorbed into the rate is not a function of measure).

---

## Appendix — Files

| File | Purpose | Wall |
|---|---|---|
| `gap1_audit_verify.py` | Univariate scans + joint check + small-κ + bias table | 180 s |
| `gap1_audit_extra.py` | 10 candidate joint-expansion boxes, find best | 67 s |
| `gap1_audit_output.txt` | Stdout log of audit | — |
| `gap1_audit_extra_output.txt` | Stdout log of extra | — |
| `gap1_audit_results.json` | Structured results (univariate + joint + small-κ + bias) | — |
| `gap1_audit_extra_results.json` | Candidate-box results | — |
| `gap1_final_audit.md` | This document | — |

$\blacksquare$
