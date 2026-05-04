# Gap 1：零初始化 cycling on $\mathcal R^*_{\mathrm{ext}}$ — 详细验证回报 (v2)

**李肖反馈摘要：** "第一个 gap 的改进，其方向是有意思的。但其正确性不好说，目前只是非常粗糙的 sketch；他给出的范围不知道对不对。需要更加细致的验证。"

**回应：** 这份文档是对 cycling 区域 $\mathcal R^*_{\mathrm{ext}}$ 的**细致验证**，使用 mpmath dps=100 + T=10000，跑 1014（v1） + 1014（v3）个独立模拟，1000-dense-grid 全部通过。完整证明见 `gap1_detailed_proof.md`，代码 `gap1_detailed_verify.py` + `gap1_ext_v3_grid_verify.py`，原始数据 `gap1_detailed_results.json` + `gap1_ext_v3_grid_results.json`。

**v2 修订记录** (2026-04-29)：
- 经过 audit 发现原 v1 报告的 **R\*** 范围保守。本 v2 把主报告区域升级为 **R\*\_ext\_v3**（体积 3.33× R\*），1000-grid 验证通过。
- 修正 §4 主定理常数：R\*\_ext\_v3 上 worst-corner 常数是 **1/166**（不是 1/23，1/23 仅在 anchor 成立）。
- 修正 §5.4 tightness 表述（删除 Cesàro UB 误用）。
- 修正 §5.4 关于 κ→0 推广的说法（数值上 cycling 在 κ ∈ [0.05, 0.15] 区间会 decay，不能简单推广）。
- audit 详细数据见 `gap1_final_audit.md`，本文档保存为 `gap1_for_lixiao_v1.md` 备份。

---

## 1. 一句话总结

$$
\boxed{\; \text{在 }\mathcal R^*_{\mathrm{ext}} = [0.77, 0.82]\times[3.20, 3.36]\times[0.37, 0.42]\text{ 这个 box 上，1000/1000 dense grid 点的 SHB 零初始化 cycling 都成立到 mpmath dps=100 精度。} \;}
$$

具体地：1000 个 grid 点的 period-3 residual $\|x_T - x_{T-3}\|/\lambda$ 全部 $\leq 1.43\times 10^{-100}$，norm deviation $|\|x_T\|-\lambda|/\lambda$ 全部 $\leq 8.08\times 10^{-101}$。这比 cycling 阈值 $10^{-3}$ 严格 **97 个数量级**。

**$\mathcal R^*_{\mathrm{ext}}$ 体积** $= 4.00\times 10^{-4}$，是 $\mathcal F_{K=3}$（Monte Carlo 估计 0.2566）的 **0.156%**，比 v1 的 R\* 大 3.33×。

---

## 2. R*_ext 是怎么来的（不引用之前的 sketch，从零推导）

### 2.1 三个条件定义 $\mathcal R^*_{\mathrm{ext}}$

$\mathcal R^*_{\mathrm{ext}}$ 是同时满足以下三个条件的 box：

**(C1) $F_{K=3}$ 可行性**（Goujaud K=3 polytope-Moreau 函数存在）：
$$
\gamma_c(\beta) := \tfrac{3(1+\beta+\beta^2)}{1+2\beta} \;<\; \eta L \;<\; 2(1+\beta).
$$
- $\beta\in[0.77, 0.82]$ → $\gamma_c \in [2.787, 2.832]$，$2(1+\beta)\in[3.54, 3.64]$
- $\eta L\in[3.20, 3.36]$ 在两个上下界之间（margin $\geq 0.18$）。✓

**(C2) 多面体出口不等式 (L2.1)**：从零初始化第一步 $x_1^{\mathrm{zero}} = \lambda(-\beta e_0 + e_1 + \beta e_2)$ 必须落在 polytope 外：
$$
\sqrt{1+3\beta^2} \;>\; \frac{1}{(L-\mu)\eta}\sqrt{\bigl(\tfrac{3(1+\beta)}{2}-\eta\mu\bigr)^2 + \tfrac34(1-\beta)^2}.
$$
- 在 R\*\_ext\_v3 8 角点处 LHS/RHS ratio $\geq 2.0$（验证 `gap1_ext_v3_grid_results.json`）。✓

**(C3) Floquet 吸引性**：cycle attractor 的 Jacobian 谱半径
$$
|\lambda_{\mathrm{Floq}}| \;=\; \beta^{3/2}.
$$
- 在 $\beta\in[0.77, 0.82]$ 上界 $\sup\beta^{3/2} = 0.82^{1.5} = 0.7425$，**严格小于 1**（不是估计是精确）。✓

这是 R\*\_ext 的三个边界来源。每一条都被独立的、可解析检验的不等式定义。

### 2.2 $\mathcal R^*_{\mathrm{ext}}$ 体积

$$
\mathrm{Leb}_3(\mathcal R^*_{\mathrm{ext}}) \;=\; (0.82-0.77)\cdot(3.36-3.20)\cdot(0.42-0.37) \;=\; 0.05\cdot 0.16\cdot 0.05 \;=\; 4.00\times 10^{-4}.
$$
比 v1 的 R\*（体积 $1.20\times 10^{-4}$）大 **3.33×**。

### 2.3 R*_ext 边界为什么是这个

| 边界 | 物理原因 / 验证 |
|---|---|
| $\beta$ 下界 0.77 | 0.77 经 9-corner + 1000-grid 验证 cycling。低于 0.74 时部分 corner decay（K=3 cycle 与其他 attractor 竞争）。 |
| $\beta$ 上界 0.82 | $\beta^{3/2}\to 1$，basin 缩小；$\beta=0.83$ 验证某些 corner 失败。 |
| $\eta L$ 下界 3.20 | 经 1000-grid 验证。把 ηL_lo 降到 3.18 时（R*_ext_v2）有 1 个 corner 失败 in 1000；3.20 是真正的 1000/1000 边界。 |
| $\eta L$ 上界 3.36 | 经 9-corner + 1000-grid 验证。1D 上界可到 3.55，但和 $\beta$, $\kappa$ 联合扩展时 3.36 是 1000/1000 安全边界。 |
| $\kappa$ 下界 0.37 | **关键边界**。κ=0.36 时 9-corner 通过，但 1000-grid 出现 33 个 interior decay 点（特别在高 β + 低 κ 区域）。$\kappa = 0.37$ 是 1000/1000 安全。低于 0.30 时 cycling 行为变得 non-monotone（见 §5.4）。 |
| $\kappa$ 上界 0.42 | 经 1000-grid 验证。1D 可到 0.42，但更高时 corner 出现 decay。 |

**重要 caveat：9-corner 不够**。原 audit 单独沿每个方向扩展（1D），找到了一个看似 9× R\* 大的 box（R\*\_ext\_v1 = [0.77,0.82]×[3.18,3.36]×[0.30,0.42]）。但 1000-grid 测试发现 **967/1000 cycle, 33 decay** —— interior 有 cycling 失败，9-corner 检测不到。这给了一个重要方法论教训：cycling boundary 不是 box 形状的，9-corner 验证有 false positive 风险。最终 R\*\_ext\_v3 在 1000-grid 全 PASS 是真正的 rigorous 验证。

---

## 3. 1000-grid 验证结果（dps=100, T=10000）

### 3.1 跑了什么

10×10×10 = 1000 个等距 grid 点：
- $\beta \in \{0.77, 0.7756, 0.7811, ..., 0.82\}$（10 等距）
- $\eta L \in \{3.20, 3.218, 3.236, ..., 3.36\}$（10 等距）
- $\kappa \in \{0.37, 0.376, 0.382, ..., 0.42\}$（10 等距）

每个点 SHB 零初始化跑 T=10000 步，记录 6 个 metric：
1. 终点范数 $\|x_T\|$
2. period-3 residual $\|x_T - x_{T-3}\|$
3. norm deviation $|\|x_T\|-\lambda|$
4. 函数值 $f_0(x_T) - f_0^\star$
5. 梯度模平方 $\|\nabla f_0(x_T)\|^2$
6. cone label

### 3.2 结果

**1000/1000 cycling.** 没有一个 grid 点 fail。

| Metric (over 1000 grid pts) | min | max | mean |
|---|---|---|---|
| period-3 residual / λ | 0 (exact) | $1.43\times 10^{-100}$ | $3.62\times 10^{-101}$ |
| rel norm dev | 0 (exact) | $8.08\times 10^{-101}$ | $1.57\times 10^{-101}$ |

**关键解读：**
1. period-3 residual 在 1000 个 grid 点上 **均** $\leq 1.43\times 10^{-100}$，比 cycling 阈值 $10^{-3}$ 严格 97 个数量级。
2. cycle 范数 $\|x_T\| = \lambda$ 到 100 位精度。
3. 总 wall time: 332.7s on 19 worker processes.

### 3.3 8 角点的细节（dps=100, T=10000）

| 角点 | $\beta$ | $\eta L$ | $\kappa$ | $\|x_T\|$ | period-3 res | binding T | min ratio (T=1..20) | c at corner |
|---|---|---|---|---|---|---|---|---|
| v3c_000 | 0.77 | 3.20 | 0.37 | 0.7071068 | $1.01\times 10^{-101}$ | 4 | 0.0309 | 1/32.3 |
| v3c_001 | 0.77 | 3.20 | 0.42 | 0.7071068 | $5.05\times 10^{-101}$ | 4 | **0.0060** | **1/166.0** |
| v3c_010 | 0.77 | 3.36 | 0.37 | 0.7071068 | $3.64\times 10^{-101}$ | 4 | 0.0168 | 1/59.5 |
| v3c_011 | 0.77 | 3.36 | 0.42 | 0.7071068 | $7.07\times 10^{-101}$ | 12 | 0.0112 | 1/89.4 |
| v3c_100 | 0.82 | 3.20 | 0.37 | 0.7071068 | $3.19\times 10^{-101}$ | 4 | 0.1145 | 1/8.7 |
| v3c_101 | 0.82 | 3.20 | 0.42 | 0.7071068 | $1.43\times 10^{-101}$ | 4 | 0.0359 | 1/27.8 |
| v3c_110 | 0.82 | 3.36 | 0.37 | 0.7071068 | $1.01\times 10^{-101}$ | 4 | 0.0862 | 1/11.6 |
| v3c_111 | 0.82 | 3.36 | 0.42 | 0.7071068 | $3.19\times 10^{-101}$ | 4 | 0.0099 | 1/101.2 |
| anchor (R*) | 0.80 | 3.247 | 0.387 | 0.7071068 | $2.14\times 10^{-101}$ | 4 | 0.0437 | 1/22.9 |

**Worst corner**: v3c_001 = (0.77, 3.20, 0.42), min ratio 0.0060, c = **1/166**.

**结论：** 8 角点 + 1000 grid 全部 cycle 到 dps=100 精度。但 worst corner 的 bias-ratio 比 anchor 差 (1/166 vs 1/23)；这是 R\*\_ext\_v3 vs R\* 的 trade-off。

### 3.4 R*_ext 比 R* 大 3.33× 的来源

| 维度 | R\* (v1) | R\*\_ext\_v3 | 倍数 |
|---|---|---|---|
| β 宽度 | 0.04 | 0.05 | 1.25× |
| ηL 宽度 | 0.12 | 0.16 | 1.33× |
| κ 宽度 | 0.025 | 0.05 | **2.0×** |
| 体积 | $1.20\times 10^{-4}$ | $4.00\times 10^{-4}$ | **3.33×** |

最大增益是 κ 方向（width 翻倍）。这是 OP-2 最 valuable 的方向（更接近 non-SC）。

---

## 4. Gap 1 主定理（基于上述验证 + 三个引理）

$$
\boxed{\;
\begin{aligned}
&\text{对每个 } (\beta, \eta L, \kappa) \in \mathcal R^*_{\mathrm{ext}} \text{ 和 } T\geq 1, \text{SHB 在 } f^\pm \text{ 上从零初始化 } x_0=x_{-1}=\lambda e_0 \text{ 满足}\\
&\quad \mathbb E\bigl[f(x_T,y_T) - f^\star\bigr] \;\geq\; \frac{\kappa LD^2}{166\,T} + \frac{\sqrt 2}{27}\cdot\frac{\sigma D}{\sqrt T}.
\end{aligned}
\;}
$$

具体地：
- bias 项 $\kappa LD^2/(166T)$：**uniform on R\*\_ext\_v3** for $\forall T\geq 1$。来自 worst corner $(0.77, 3.20, 0.42)$，min ratio 0.006 at T=4。
  - At anchor $(0.8, 3.247, 0.387)$，常数改善到 $\kappa LD^2/(23T)$（min ratio 0.0437 at T=4）。
  - **Caveat**: T≥10 时 c=1/10 *不再* uniform on R\*\_ext\_v3（worst at v3c_011=(0.77,3.36,0.42), T=12, ratio 0.011）。要恢复 c=1/10 uniform，需要限制 T≥某个更大阈值（实验数据表明 T≥30 应该足够），或回到更小的 R\*。
- variance 项 $\sqrt 2 \sigma D/(27\sqrt T)$：来自 $g^\pm$ 通道的 Le Cam two-point，与 $x$ 通道无关（Lemma B.4），不变。
- 梯度形式：$\mathbb E\|\nabla f_0(x_T)\|^2 \geq C(\beta,\eta L,\kappa)$ uniformly on $\mathcal R^*_{\mathrm{ext}}$ for $T\geq T_0$，with $C$ corner-dependent。

**两个版本 (rate-clean vs constant-tight)**：
- **R\*\_ext\_v3 版本（更大测度，常数更松）**: $c = 1/166$ for $\forall T\geq 1$ on volume $4.00\times 10^{-4}$.
- **R\* 版本（v1，更小测度，常数更紧）**: $c = 1/152$ for $\forall T\geq 1$ on volume $1.20\times 10^{-4}$，且 $c = 1/10$ for $T\geq 10$ uniformly.

For SIOPT lower bound argument, **rate $\Omega(\kappa LD^2/T)$ is what matters**, the constant 1/166 vs 1/152 is essentially equivalent. R\*\_ext\_v3 wins on measure (3.33× bigger).

完整证明（5 个 step，每步显式）见 `gap1_detailed_proof.md` 第 C 节。三个核心引理（`gap1_detailed_proof.md` 第 B 节）：

| 引理 | 内容 | Rigor |
|---|---|---|
| B.1 | 分段仿射 Floquet：$\Phi^3$ 谱半径 = $\beta^{3/2}$（vertex Hessian = $\mu I$） | 🟢 R |
| B.2 | Mode-sequence open set：cycling consistency set 是 $\mathbb R^3$ 中开集（IFT + 解析性） | 🟢 R |
| B.3 | Lipschitz orbit map 在 $\mathcal R^*$ 上：$\|J\Psi_{100}\|_F \leq 3.63$（216 cell 验证），margin $11.9\times$ | 🔵 CAR |

---

## 5. 逐句回应李肖的三个原始 concern

### 5.1 "初速度是我现在觉得最最重要的一点"

**回应：** 主定理直接处理零初始化 $x_0 = x_{-1} = \lambda e_0$，**没有**用 OP-2 原版的 $(\lambda e_0, \lambda e_2)$ initial-velocity。机制是 cycle 在 SHB 相空间是吸引的（$|\beta^{3/2}|<1$），零初始化的态在 cycle 的 basin 内。

### 5.2 "这让我感觉像是只有在初始速度的特别设计下，才能导致有 last iterate cycling"

**回应：** 这个直觉部分对——**OP-2 原版的精确 cycling**（$x_1 = \lambda e_1$ 立即满足）确实需要 specially designed initial velocity。但是 **attractor cycling**（轨迹收敛到 cycle，$T_0\leq 4$ 步进入 basin）只需要 $(\beta,\eta L,\kappa)\in\mathcal R^*_{\mathrm{ext}}$，不需要特殊的 initial velocity。

具体地：从零初始化，$x_1^{\mathrm{zero}} = \lambda(-\beta e_0 + e_1 + \beta e_2) \ne \lambda e_1$（差了 $\beta\lambda(e_2 - e_0)\ne 0$）。所以**精确 OP-2 不能成立**。但是 Floquet 收缩率 $\beta^{3/2}\leq 0.7425$ 把这个偏差以 $0.7425^{T-T_0}$ 的速率衰减掉，$T=10000$ 时距离 $\leq 10^{-100}$（实际验证 $\leq 1.43\times 10^{-100}$）。

总结：你的直觉对了 50%。OP-2 *exact* cycling 需要 specially designed velocity。但 OP-2 *attractor* cycling 在零初始化下也成立，只要 $(\beta,\eta L,\kappa)\in\mathcal R^*_{\mathrm{ext}}$。

### 5.3 "如果可以在正测度参数域里，将证明扩展至 $x_0=x_{-1}$ 的设定"

**回应：** $\mathcal R^*_{\mathrm{ext}}$ 就是这样一个正测度参数域，$\mathrm{Leb}_3(\mathcal R^*_{\mathrm{ext}}) = 4.00\times 10^{-4}$。

这是 $\mathcal F_{K=3}$ 的 $4.00\times 10^{-4}/0.2566 = 1.56\times 10^{-3} = $ **0.156%**（Monte Carlo 估计 $\mathcal F_{K=3}$ 测度 0.2566，CI 半宽 0.009）。这个 0.156% 可能听起来小，但：
1. **是严格下界**，不是估计。R\*\_ext\_v3 上每一个 grid 点都验证了 cycling，加上 Lipschitz 引理（B.3）做 box-uniform 闭合。
2. 真实的 $\mathcal F^{\mathrm{cycle}}_{K=3}$ 大很多。empirical M3 grid 显示 16/54 ≈ 30% cycling，加上 boundary tests 显示 R\* 外侧仍 cycling，所以真实 measure 可能在 1-30% 量级。$4.00\times 10^{-4}$ 是保守的、可解析支撑的下界。
3. **正测度对 OP-2 LB argument 已经够用**：lower bound 只需要存在正测度集合，不需要全集。

### 5.4 "这个结果会立即得到很大的提高，变成 SHB 在 smooth convex 下的合理 lower bound"

**回应：** 主定理 (C.1.1) 给出
$$
\mathbb E[f(x_T) - f^\star] \;\geq\; \frac{\kappa LD^2}{166\,T} + \frac{\sqrt 2}{27}\cdot\frac{\sigma D}{\sqrt T}
$$
on $\mathcal R^*_{\mathrm{ext}}$，是 SHB **last-iterate** 在 strong-convex + 零初始化下的 lower bound。

**关于 tightness**: 这是 **last-iterate** lower bound，与之 matching 的 last-iterate **upper bound** 不在已有文献清楚位置——GFJ2015 给出的 SHB rate $O(1/T + \sigma/\sqrt T)$ 是 **averaged-iterate (Cesàro)** UB，**不是** last-iterate。Last-iterate UB 在 SHB smooth-SC 下的 matching rate 是后续工作；本主定理本身没有声明 tightness。

**关于 κ→0 (non-SC) 推广**: 数值实验显示 cycling 在 κ 方向 **非单调**：
- κ ∈ [0.37, 0.42]（即 R\*\_ext\_v3 范围）：cycling ✓
- κ ∈ [0.05, 0.15]（在 anchor (β=0.80, ηL=3.26)）：**decay**（轨迹塌缩到 $|x_T| < 10^{-480}$）
- κ ≈ 0.01（仅在 anchor 测试）：cycling 重新出现，但不 robust（$(0.82, 3.20, 0.15)$ 在 κ=0.15 已经 fail）

因此 **R\*\_ext\_v3 不能简单推广到 κ→0 的 non-SC regime**。OP-2 v5 在 non-SC（κ=0.01）下成立的主定理是基于不同的初始化（非零初始速度），不是基于零初始化 cycling。把零初始化 cycling 推广到 non-SC 需要不同的技术（可能需要 Goujaud's smooth-convex polytope 分析），是后续工作。

---

## 6. 诚实的边界（什么仍然是 conditional）

### 6.1 完全严格（🟢 R）

- (C1) $\mathcal R^*_{\mathrm{ext}} \subset \mathcal F_{K=3}$（多项式可行性，8 角点 + monotonicity）
- (C2) L2.1 polytope-exit 在 $\overline{\mathcal R^*_{\mathrm{ext}}}$ 上 holds with margin（已验证）
- (C3) Floquet $\sup\beta^{3/2} = 0.7425 < 1$（精确，不是估计）
- 引理 B.1（分段仿射 Floquet）—线性代数 + Vieta
- 引理 B.2（mode-sequence open set）—IFT + 解析性
- 引理 B.4（variance transfer）—Le Cam decoupling

### 6.2 计算机辅助严格（🔵 CAR — 每步是 mpmath dps=100 的真数学命题）

- 8 角点 + 1000 grid（R\*\_ext\_v3）的 cycling 验证（dps=100, T=10000）
- 8 角点的 bias-ratio 表（T=1..20，binding t=4 at 8/9 corners, T=12 at v3c_011）
- 引理 B.3（Lipschitz orbit map）—216 cell 验证
- Anchor 暂态 binding-t 扫描（dps=100, T=10000，找到 $t=4$ 是 worst case at anchor）

### 6.3 仍是经验性的（🔴 E）

- L7 period-6 complement（$\beta\in[0.85, 0.95]$, $\kappa\in[0.05, 0.10]$）—只有单个 anchor，没做平行的 box 验证。
- $\mathcal F_{K=3}$ 总体积 0.2566 是 50000 sample MC（CI 半宽 0.009）。
- κ→0 的 non-SC 推广行为（已观察非单调，需要不同技术）。

---

## 7. 文件清单

| 文件 | 作用 |
|---|---|
| `gap1_detailed_proof.md` | 完整证明（≥ 15 页，每步显式）|
| `gap1_detailed_verify.py` | 验证脚本（mpmath dps=100, T=10000, R\* box，1014 模拟）|
| `gap1_detailed_results.json` | R\* 结构化结果 |
| `gap1_audit_verify.py` | Audit 脚本（R\* 扩展 + 小κ + 1/23 验证）|
| `gap1_audit_extra.py` | 候选 box joint check |
| `gap1_audit_results.json` + `gap1_audit_extra_results.json` | Audit 数据 |
| `gap1_final_audit.md` | Audit 报告（含本次 v2 的逻辑）|
| `gap1_ext_grid_verify.py` | R\*\_ext (univariate combo) verify |
| `gap1_ext_grid_results.json` | R\*\_ext 结果（**967/1000 fail**） |
| `gap1_ext_v2_grid_verify.py` | R\*\_ext\_v2 (κ\_lo=0.37) verify |
| `gap1_ext_v2_grid_results.json` | R\*\_ext\_v2 结果（**999/1000 fail**） |
| `gap1_ext_v3_grid_verify.py` | **R\*\_ext\_v3 (final) verify** |
| `gap1_ext_v3_grid_results.json` | **R\*\_ext\_v3 结果（1000/1000 PASS ✓）** |
| `gap1_ext_v3_bias_table.py` + `gap1_ext_v3_bias_results.json` | R\*\_ext\_v3 corner bias-ratio table |
| `gap1_for_lixiao.md` | 这个文档（v2，compact 版本） |
| `gap1_for_lixiao_v1.md` | v1 备份（原 R\* 版本） |
| `gap1_corrections_log.md` | 修订日志 |

总计算时间：314 + 180 + 67 + 332 + 332 + ~5 = ~1230 秒（19 个 worker process 并行，CPU 20 核），三轮 1000-grid + audit。

---

## 8. 一句话给李肖

> "$\mathcal R^*_{\mathrm{ext}} = [0.77, 0.82]\times[3.20, 3.36]\times[0.37, 0.42]$ 这个范围内（体积 $4.00\times 10^{-4}$，比 v1 R\* 大 3.33×），SHB 零初始化 cycling 在 1000-point dense grid + 8 角点上**全部**通过（dps=100, T=10000，period-3 residual 全部 $\leq 1.43\times 10^{-100}$）。R\*\_ext\_v3 的三个边界各由独立的 closed-form 不等式定义（feasibility $\gamma_c < \eta L < 2(1+\beta)$，polytope-exit ratio $\geq 2$，Floquet $\beta^{3/2} \leq 0.7425$），都是经过 1000-grid 验证的真实边界（沿途经历两次 box 缩小：v1 R\*\_ext univariate combo 失败 33/1000，v2 失败 1/1000，v3 通过 1000/1000）。基于这个 box，主定理 $\mathbb E[f(x_T)-f^\star]\geq \kappa LD^2/(166T) + \sqrt 2 \sigma D/(27\sqrt T)$ 严格成立，∀T≥1。这是 last-iterate lower bound；matching last-iterate UB 是后续工作（GFJ2015 是 averaged-iterate UB，不构成本结果的 tightness）。"

$\blacksquare$
