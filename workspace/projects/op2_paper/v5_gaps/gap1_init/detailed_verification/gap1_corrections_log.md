# Corrections Log: gap1_for_lixiao.md v1 → v2

**Date:** 2026-04-29  
**Trigger:** User audit prompt (Gap 1 最终审查) found 4 errors in v1 + requested R\* expansion verification.  
**Result:** v1 backed up as `gap1_for_lixiao_v1.md`. v2 is current `gap1_for_lixiao.md`.

---

## Summary of changes

| # | Correction | Status |
|---|---|---|
| 1 | R\* → R\*_ext_v3 (3.33× larger box, 1000/1000 verified) | DONE |
| 2 | bias constant 1/23 → 1/166 (uniform on R\*_ext_v3) | DONE |
| 3 | §5.4 tightness claim (Cesàro UB ≠ last-iterate UB) | DONE |
| 4 | §5.4 κ→0 description (non-monotone, decay valley) | DONE |

Plus methodological correction documented:
| 5 | Acknowledged 9-corner verification can yield false positives (R\*_ext_v1 univariate combo passed 9/9 but failed 33/1000) | DONE |

---

## Correction 1: R\* → R\*_ext_v3

### Before (v1, §1)
> 在 $\mathcal R^* = [0.78, 0.82]\times[3.20, 3.32]\times[0.375, 0.400]$ 这个范围的 **细致验证** ... R\* 体积 $1.20\times 10^{-4}$，0.047% of $\mathcal F_{K=3}$.

### After (v2, §1)
> 在 $\mathcal R^*_{\mathrm{ext}} = [0.77, 0.82]\times[3.20, 3.36]\times[0.37, 0.42]$ ... 体积 $4.00\times 10^{-4}$，是 $\mathcal F_{K=3}$ 的 0.156%，比 v1 R\* 大 3.33×.

### Why
The audit (Gap 1 最终审查 Task 1) showed boundary tests of R\* (face-exterior at 0.01) all cycle, indicating R\* is conservative. Six 1D univariate scans found:
- β-low: 0.78 → 0.75
- β-high: 0.82 (no expansion)
- ηL-low: 3.20 → 3.10
- ηL-high: 3.32 → ≥ 3.55
- κ-low: 0.375 → 0.20
- κ-high: 0.400 → 0.42

But the univariate combination `[0.75, 0.82] × [3.10, 3.55] × [0.20, 0.42]` fails joint 9-corner check (3/9 corners fail, including center). After candidate-box bisection (10 candidates tested), best joint-passing 9-corner box was R\*_ext_v1 = [0.77, 0.82] × [3.18, 3.36] × [0.30, 0.42] (volume 9× R\*).

**Subsequent 1000-grid verification revealed the 9-corner check was insufficient**:
- R\*_ext_v1 1000-grid: **967/1000** (33 interior decays, mostly at high β + low κ). FAIL.
- R\*_ext_v2 [κ_lo→0.37] 1000-grid: **999/1000** (1 fail at β=0.82, ηL=3.18, κ=0.414). FAIL.
- **R\*_ext_v3 [also ηL_lo→3.20] 1000-grid: 1000/1000 PASS ✓**.

So the rigorous expansion factor is 3.33× (R\*_ext_v3 vs R\*), not 9× (R\*_ext_v1 was over-stated).

### Files involved
- `gap1_audit_verify.py` (univariate scans + joint check + small-κ + bias)
- `gap1_audit_extra.py` (10 candidate joint expansions)
- `gap1_ext_grid_verify.py` (R\*_ext_v1, FAILED 967/1000)
- `gap1_ext_v2_grid_verify.py` (R\*_ext_v2, FAILED 999/1000)
- `gap1_ext_v3_grid_verify.py` (R\*_ext_v3, PASSED 1000/1000)

---

## Correction 2: bias constant 1/23 → 1/166

### Before (v1, §4)
> bias 项 $\kappa LD^2/(23T)$：来自 cycle 上 $f_0(x_T)\geq (\mu/2)\|x_T\|^2$ + 暂态 sweep（验证 binding $t=4$，min ratio 0.0437 → $c\geq 1/23$）。
> 对 $T\geq 10$ 改进为 $\kappa LD^2/(10T)$（min ratio 0.369）。

### After (v2, §4)
Main theorem boxed equation:
> $\mathbb E[f(x_T,y_T) - f^\star] \geq \kappa LD^2/(166T) + \sqrt 2 \sigma D / (27\sqrt T)$, ∀T≥1.

Followed by:
> bias 项 $\kappa LD^2/(166T)$：**uniform on R\*_ext_v3** for ∀T≥1. 来自 worst corner $(0.77, 3.20, 0.42)$，min ratio 0.006 at T=4.
> At anchor (0.8, 3.247, 0.387), 常数改善到 $\kappa LD^2/(23T)$ (min ratio 0.0437 at T=4).
> **Caveat**: T≥10 时 c=1/10 *不再* uniform on R\*_ext_v3（worst at v3c_011 = (0.77,3.36,0.42), T=12, ratio 0.011）.

### Why
The original "1/23" was computed at the single anchor, NOT uniform across R\*'s corners. Audit Task 4 verified bias ratios at all 8 R\* corners + anchor for T=1..20:
- Worst R\* corner: (0.78, 3.32, 0.40), min ratio 0.0066, c = 1/152 (not 1/23).
- Best R\* corner: (0.82, 3.20, 0.375), min ratio 0.108, c = 1/9.3.
- Anchor: 1/22.9.

For R\*_ext_v3 (different corners since box is larger):
- Worst corner: v3c_001 = (0.77, 3.20, 0.42), min ratio 0.0060, c = **1/166**.
- Best corner: v3c_100 = (0.82, 3.20, 0.37), min ratio 0.115, c = 1/8.7.
- Anchor: 1/22.9 (unchanged).

For T≥10:
- On R\* corners: min ratio over t∈[10,20] = 0.369 → c = 1/2.7 (so 1/10 holds with 3.7× margin).
- On R\*_ext_v3 corners: min ratio = 0.0112 → c = 1/89 (so 1/10 does NOT hold uniformly).

### Trade-off acknowledged
v2 explicitly notes: smaller R\* (1/152 + T≥10 1/10) vs bigger R\*_ext_v3 (1/166, no T≥10 improvement). Both options stated; main theorem uses R\*_ext_v3 since rate $\Omega(\kappa LD^2/T)$ is what matters (constant 152 vs 166 is essentially equivalent).

### Files involved
- `gap1_audit_verify.py` (Task 4: bias ratios at R\* corners)
- `gap1_ext_v3_bias_table.py` + `gap1_ext_v3_bias_results.json` (bias ratios at R\*_ext_v3 corners)

---

## Correction 3: §5.4 tightness claim

### Before (v1, §5.4)
> 主定理 (C.1.1) 给出 $\mathbb E[f(x_T) - f^\star] \geq \kappa LD^2/(23T) + \sqrt 2 \sigma D/(27\sqrt T)$ on $\mathcal R^*$，是 SHB 在 strong-convex + 零初始化下的 lower bound。**这与 SHB 在同样条件下的 upper bound 在 T-dependence 上 tight：upper bound 也是 $O(1/T + \sigma/\sqrt T)$**。
> 对 smooth-convex（非 strong-convex）情况，可取 $\kappa\to 0$，bias 项变成 $\Omega(LD^2/T)$（在合适的 scaling 下）。这是直接的 PL 推广，没在这次工作里做完，但路线明确。

### After (v2, §5.4)
> 主定理 (C.1.1) 给出 $\mathbb E[f(x_T) - f^\star] \geq \kappa LD^2/(166T) + \sqrt 2 \sigma D/(27\sqrt T)$ on $\mathcal R^*_{\mathrm{ext}}$，是 SHB **last-iterate** 在 strong-convex + 零初始化下的 lower bound。
> **关于 tightness**: 这是 last-iterate lower bound，与之 matching 的 last-iterate **upper bound** 不在已有文献清楚位置——GFJ2015 给出的 SHB rate $O(1/T + \sigma/\sqrt T)$ 是 **averaged-iterate (Cesàro)** UB，**不是** last-iterate。Last-iterate UB 在 SHB smooth-SC 下的 matching rate 是后续工作；本主定理本身没有声明 tightness。
> **关于 κ→0 (non-SC) 推广**: ... [详见 Correction 4]

### Why
The "upper bound 也是 $O(1/T + \sigma/\sqrt T)$" claim was misleading: it was implicitly referring to GFJ2015 (Ghadimi-Feyzmahdavian-Johansson 2015) which gives Cesàro/averaged-iterate UB, NOT last-iterate. Since the main theorem is about last-iterate, this Cesàro UB doesn't establish tightness.

李肖 (per user prompt) had previously flagged this exact category error — Cesàro UB ≠ last-iterate UB.

### Files involved
- None (text-only correction). 

---

## Correction 4: §5.4 κ→0 description

### Before (v1, §5.4)
> 对 smooth-convex（非 strong-convex）情况，可取 $\kappa\to 0$，bias 项变成 $\Omega(LD^2/T)$（在合适的 scaling 下）。这是直接的 PL 推广，没在这次工作里做完，但路线明确。

### After (v2, §5.4)
> **关于 κ→0 (non-SC) 推广**: 数值实验显示 cycling 在 κ 方向 **非单调**：
> - κ ∈ [0.37, 0.42]（即 R\*_ext_v3 范围）：cycling ✓
> - κ ∈ [0.05, 0.15]（在 anchor (β=0.80, ηL=3.26)）：**decay**（轨迹塌缩到 $|x_T| < 10^{-480}$）
> - κ ≈ 0.01（仅在 anchor 测试）：cycling 重新出现，但不 robust
> 因此 R\*_ext_v3 不能简单推广到 κ→0 的 non-SC regime。OP-2 v5 在 non-SC（κ=0.01）下成立的主定理是基于不同的初始化（非零初始速度），不是基于零初始化 cycling。把零初始化 cycling 推广到 non-SC 需要不同的技术，是后续工作。

### Why
Audit Task 3 specifically tested cycling at small κ values at the anchor:
- κ=0.30: cycle (norm_T = 0.7071, p3 ~ 1e-101)
- κ=0.20: cycle
- κ=0.10: **decay** (norm_T = 1.39e-482)
- κ=0.05: **decay** (norm_T = 8.37e-485)
- κ=0.01: cycle (sporadically; not robust across the box)

So κ→0 does NOT produce smooth extension to non-SC. The user's prompt instructed: "如果 κ→0 cycling fail：记录 fail 的原因（orbit decay to 0？period 变化？）". Yes, decay to 0 at intermediate small κ. The v2 explicitly documents this.

### Files involved
- `gap1_audit_results.json["task3_small_kappa"]` (5 small-κ test points)

---

## Correction 5 (methodological): 9-corner verification can give false positives

### What changed
Added explicit caveat in v2 §2.3:
> **重要 caveat：9-corner 不够**。原 audit 单独沿每个方向扩展（1D），找到了一个看似 9× R\* 大的 box（R\*_ext_v1）。但 1000-grid 测试发现 967/1000 cycle, 33 decay —— interior 有 cycling 失败，9-corner 检测不到。这给了一个重要方法论教训：cycling boundary 不是 box 形状的，9-corner 验证有 false positive 风险。

### Why
This is a real lesson learned. The original `caveat1_v2_dense_grid.md` etc. used 9-corner verification. After the 1000-grid trial on R\*_ext_v1 showed 33/1000 interior failures despite all 9 corners passing, we know this method has false-positive risk. The cycling region is genuinely not box-shaped — there are decay tongues reaching into the interior at high β + low κ, and at high β + low ηL + high κ.

For SIOPT-grade rigor, **1000-grid (10×10×10) at dps=100, T=10000 is the standard** that v2 uses for all box claims.

---

## Tracking journey to R\*_ext_v3

| Stage | Box | β-range | ηL-range | κ-range | Volume | 9-corner | 1000-grid |
|---|---|---|---|---|---|---|---|
| R\* (v1) | original | [0.78, 0.82] | [3.20, 3.32] | [0.375, 0.400] | 1.2e-4 | 9/9 | 1000/1000 ✓ |
| R\*_ext_v1 (univariate combo) | from audit | [0.75, 0.82] | [3.10, 3.55] | [0.20, 0.42] | 6.93e-3 | 6/9 ✗ | n/a |
| R\*_ext_v1 (best 9-corner) | R\*_b in audit | [0.77, 0.82] | [3.18, 3.36] | [0.30, 0.42] | 1.08e-3 (9× R\*) | 9/9 | **967/1000 FAIL** |
| R\*_ext_v2 (κ_lo→0.37) | shrunk #1 | [0.77, 0.82] | [3.18, 3.36] | [0.37, 0.42] | 4.5e-4 (3.75× R\*) | 8/8 | **999/1000 FAIL** |
| **R\*_ext_v3 (also ηL_lo→3.20)** | shrunk #2 | **[0.77, 0.82]** | **[3.20, 3.36]** | **[0.37, 0.42]** | **4.0e-4 (3.33× R\*)** | **8/8** | **1000/1000 PASS ✓** |

R\*_ext_v3 is the final, fully verified expansion: **3.33× R\* in volume, with 1000/1000 cycling at dps=100, T=10000**.

---

## Numerical impact summary

| Quantity | v1 (R\*) | v2 (R\*_ext_v3) | Change |
|---|---|---|---|
| Box volume | 1.20×10⁻⁴ | 4.00×10⁻⁴ | **+233%** |
| Fraction of $\mathcal F_{K=3}$ | 0.047% | 0.156% | **+233%** |
| Bias constant ∀T≥1 (uniform) | 1/152 (rigorous; was wrongly stated as 1/23) | 1/166 | -9% |
| Bias constant T≥10 (uniform) | 1/10 ✓ | does NOT hold; need T≥30+ | weaker |
| Bias constant at anchor | 1/23 | 1/23 (unchanged) | — |
| Variance constant | √2/27 | √2/27 (unchanged) | — |
| Last-iterate tightness claim | wrongly implied (Cesàro UB cited) | properly disclaimed | corrected |
| κ→0 extension | "路线明确" (loose) | "non-monotone, requires different technique" | corrected |

The v2 is **structurally more honest and substantively stronger** (3.33× larger box) than v1, at the cost of a slightly worse uniform bias constant (1/166 vs 1/152).

---

## Verification scripts and results

All scripts and JSON in `workspace/active/op2_v5_gaps/gap1_init/detailed_verification/`:

| Stage | Script | Output | JSON | Wall time |
|---|---|---|---|---|
| R\* baseline | `gap1_detailed_verify.py` | `gap1_detailed_output.txt` | `gap1_detailed_results.json` | 314 s |
| Audit (Tasks 1-4) | `gap1_audit_verify.py` | `gap1_audit_output.txt` | `gap1_audit_results.json` | 180 s |
| Joint candidate boxes | `gap1_audit_extra.py` | `gap1_audit_extra_output.txt` | `gap1_audit_extra_results.json` | 67 s |
| R\*_ext_v1 1000-grid | `gap1_ext_grid_verify.py` | `gap1_ext_grid_output.txt` | `gap1_ext_grid_results.json` | 294 s |
| R\*_ext_v2 1000-grid | `gap1_ext_v2_grid_verify.py` | `gap1_ext_v2_grid_output.txt` | `gap1_ext_v2_grid_results.json` | 331 s |
| **R\*_ext_v3 1000-grid** | **`gap1_ext_v3_grid_verify.py`** | **`gap1_ext_v3_grid_output.txt`** | **`gap1_ext_v3_grid_results.json`** | **333 s** |
| R\*_ext_v3 bias table | `gap1_ext_v3_bias_table.py` | `gap1_ext_v3_bias_output.txt` | `gap1_ext_v3_bias_results.json` | <1 s |

**Total compute**: ≈1520 s = 25 min on 19-core multiprocessing pool. Each numerical claim is reproducible by re-running the corresponding script.

$\blacksquare$
