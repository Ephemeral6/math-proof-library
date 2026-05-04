# SnapPy API 审计报告

**审计日期**: 2026-05-01
**目的**: 为 SpatialMind 第二个 domain（KnotEngine, 纽结论）评估 SnapPy 提供的数据。

## 环境
- `snappy` version: **3.3.2**
- `spherogram` version: **2.4.1**（提供底层 `Link`/`Crossing` 类，所有 SnapPy `Link` 操作实际上都来自 spherogram）
- Python 3.12，WSL Linux
- **Sage**: 未安装。这是关键约束，详见下文。

## TL;DR

1. **大多数核心多项式不变量需要 Sage**：Jones、Alexander、signature、determinant、knot_group、Goeritz/black/white_graph、knot_floer_homology 全部失败，错误为 `SageNotAvailable`。
2. **Seifert matrix 在 pure Python 下可用**，并能用 NumPy/SymPy 手动派生 signature、determinant、Alexander polynomial（详见 §"派生不变量"）。Jones 多项式需要自己实现 Kauffman bracket，或安装 Sage。
3. **没有显式的 R1/R2/R3 接口**，但 `simplify(mode=...)` 和 `backtrack(steps, prob_type_1, prob_type_2)` 在内部执行 Reidemeister 移动，并暴露了足够的钩子来"造移动"。
4. **per-crossing sign (±1) 完整可用** 通过 `K.crossings[i].sign`。这是反事实变体（伪 R2 = 同号）的关键。
5. **backtrack 保留原 crossing 的 label**，新增的 R-move crossings 用字符串 label（`'new1'`, `'new2'`, …）标记。这意味着我们可以**精确识别哪些 crossing 是 R-move 产物**，无需启发式 diff。

## 支持度矩阵

| 数据 | 直接支持 | 如何获取 | 对应 SpatialMind 字段 |
|------|---------|---------|---------------------|
| 从名字加载（`"3_1"` 等） | ✅ | `snappy.Link("3_1")` | `construct(spec={"name": "3_1"})` |
| 从 PD code 加载 | ✅ | `snappy.Link([[1,5,2,4],…])` | `construct(spec={"pd_code": …})` |
| 从 braid word 加载 | ✅ | `snappy.Link(braid_closure=[1,1,1])` | `construct(spec={"braid": …})` |
| 从 DT code 加载 | ⚠️ | 间接：`snappy.Link("DT: …")` 字符串解析 | 选项 |
| Crossing count | ✅ | `len(K.crossings)` | `invariants["crossing_number_diagram"]` |
| Component count | ✅ | `len(K.link_components)` | `invariants["num_components"]` |
| Writhe | ✅ | `K.writhe()` → `int` | `summary["writhe"]` |
| Linking number | ✅ | `K.linking_number()` → `float` | `summary["linking_number"]` |
| Per-crossing sign (±1) | ✅ | `K.crossings[i].sign` | `detailed["crossings"][i]["sign"]` |
| Crossing 邻接关系 | ✅ | `c.adjacent`（CEP 列表） | `detailed["crossings"][i]["adjacent"]` |
| Crossing label | ✅ | `c.label`（int 或字符串） | `detailed["crossings"][i]["label"]` |
| Crossing 方向 | ✅ | `c.directions` → `set[(in, out)]` | `detailed["crossings"][i]["directions"]` |
| PD code | ✅ | `K.PD_code()` → `list[tuple]` | `detailed["pd_code"]` |
| DT code | ✅ | `K.DT_code()` → `list[tuple]` | `detailed["dt_code"]` |
| Peer code | ✅ | `K.peer_code()` | `detailed["peer_code"]` |
| KLP projection | ✅ | `K.KLPProjection()` | `detailed["klp"]`（仅高级用） |
| Braid word | ✅ | `K.braid_word()` → `list[int]` | `detailed["braid_word"]` |
| Bridge upper bound | ✅ | `K.bridge_upper_bound()` | `structural["bridge_upper_bound"]` |
| Is alternating | ✅ | `K.is_alternating()` → `bool` | `structural["alternating"]` |
| **Jones polynomial** | ❌ | Sage required（手动实现 Kauffman bracket 可绕过） | 见 §"Jones 实现路径" |
| **Alexander polynomial** | ⚠️ | `K.alexander_polynomial()` 需要 Sage；可手动 `det(t·S − S^T)` | `invariants["alexander"]`（手动） |
| **Alexander matrix** | ❌ | Sage required | — |
| **Signature** | ⚠️ | `K.signature()` 需要 Sage；可手动 `sig(S+S^T)` | `invariants["signature"]`（手动） |
| **Determinant** | ⚠️ | `K.determinant()` 需要 Sage；可手动 `\|det(S+S^T)\|` | `invariants["determinant"]`（手动） |
| Seifert matrix | ✅ | `K.seifert_matrix()` → `list[list[int]]` | `structural["seifert_matrix"]` |
| Seifert genus（diagram） | ✅ | `len(seifert_matrix) // 2` | `structural["seifert_genus_diagram"]` ⚠️ |
| Seifert genus（topological min） | ❌ | 需要 Alex poly degree 或专门算法 | 注：`seifert_matrix` 给出的是**当前图所对应** Seifert 曲面的 genus，不是拓扑最小 genus（5_2 的 Seifert-genus-diagram = 3，但拓扑 genus = 1） |
| Knot group | ❌ | Sage required | — |
| Goeritz / black / white graph | ❌ | Sage required | — |
| Knot Floer homology | ❌ | Sage required | — |
| **Reidemeister R1 直接 API** | ❌ | 无；通过 `backtrack(steps, prob_type_1=1.0, prob_type_2=0.0)` 添加 R1 | `transform(operation={"type": "R1"})` 内部用 backtrack |
| **Reidemeister R2 直接 API** | ❌ | 无；通过 `backtrack(steps, prob_type_1=0.0, prob_type_2=1.0)` 添加 R2 | 同上 |
| **Reidemeister R3 直接 API** | ❌ | 无；`simplify(mode='level')` 内部做 R3，但只在简化方向使用 | R3 需 PD-code 手动实现 |
| Reidemeister-style 简化 | ✅ | `simplify(mode='basic'|'level'|'pickup'|'global')` | counterfactual 验证 |
| Mirror image | ✅ | `K.mirror()` → 新 `Link`（所有 sign 翻转，writhe 取反） | `transform(operation={"type": "mirror"})` |
| Connected sum | ✅ | `K1.connected_sum(K2)` | `transform(operation={"type": "connected_sum", "other": …})` |
| Deconnect sum | ✅ | `K.deconnect_sum()` → `list[Link]` | 辅助分析 |
| Copy | ✅ | `K.copy()` | 反事实前必备 |
| Sublink | ✅ | `K.sublink([components])` | 链路分量提取 |
| 手动改 PD code 重建 | ✅ | `snappy.Link(new_pd_code)` 即可 | 反事实关键路径 |
| 直接拼 Crossing 对象 | ✅ | `from spherogram.links.links_base import Crossing` | 反事实终极武器（构造非合法移动） |
| Exterior 3-manifold | ✅ | `K.exterior()` → `snappy.Manifold` | 提供 hyperbolic volume（如适用） |

## 关键发现

### 1. Sage gap（最重要）

SnapPy 在没有 Sage 的环境下，**所有以 Sage 多项式环为返回类型的函数都直接抛错**：
- `jones_polynomial()`, `alexander_polynomial()`, `alexander_poly()`, `alexander_matrix()`
- `signature()`, `determinant()`
- `knot_group()`, `morse_number()`
- `goeritz_matrix()`, `black_graph()`, `white_graph()`
- `knot_floer_homology()`
- `many_diagrams()`, `ribbon_concordant_links()`

错误: `spherogram.sage_helper.SageNotAvailable`。

**应对策略**：
- 优先使用 `K.seifert_matrix()`（pure Python，返回 `list[list[int]]`），手动用 NumPy/SymPy 派生：

```python
import numpy as np
from sympy import Matrix, symbols

def derived_invariants(K):
    S = np.array(K.seifert_matrix())
    if S.size == 0:
        return {"signature": 0, "determinant": 1, "seifert_genus_diagram": 0}
    M = S + S.T
    eig = np.linalg.eigvalsh(M)
    sig = int(np.sum(eig > 1e-9) - np.sum(eig < -1e-9))
    det = abs(int(round(np.linalg.det(M))))
    t = symbols('t')
    Sm = Matrix(S.tolist())
    alex = (t * Sm - Sm.T).det().expand()
    return {
        "signature": sig,
        "determinant": det,
        "seifert_genus_diagram": S.shape[0] // 2,
        "alexander_polynomial": alex,
    }
```

**验证（vs 文献已知值）**：

| 纽结 | 期望 σ | 计算 σ | 期望 det | 计算 det | 期望 g | 计算 g_diagram | 备注 |
|------|--------|--------|----------|----------|--------|----------------|------|
| 3_1 | -2 | -2 | 3 | 3 | 1 | 1 | ✅ 全匹配 |
| 4_1 | 0 | 0 | 5 | 5 | 1 | 1 | ✅ |
| 5_1 | -4 | -4 | 5 | 5 | 2 | 2 | ✅ |
| 5_2 | -2 | **+2** | 7 | 7 | 1 | **3** | ⚠️ sig 符号反转，diagram-genus ≠ topological-genus |
| 8_19 | -6 | **+6** | 3 | 3 | 3 | 3 | ⚠️ sig 符号反转 |

**两个需要在文档里明示的 caveat**：

(a) **Signature 符号约定**：SnapPy 的 `seifert_matrix()` 在某些 diagram 下与文献的 σ 差一个负号。绝对值和奇偶性总是正确，且对一个固定的 SnapPy diagram 是确定的。SpatialMind 应当只承诺"signature(K)" 作为 SnapPy 内部一致性度量，而**不**承诺与教科书完全同号。

(b) **Genus 是 diagram-dependent**：`seifert_matrix` 给出的是从当前 diagram 应用 Seifert 算法得到的曲面的 genus（不是拓扑 minimum genus）。要拿到拓扑 genus 需通过 Alexander polynomial 的 degree（degree(Δ) = 2g 对 fibered knots，是 lower bound 一般）。命名为 `seifert_genus_diagram` 以避免误解。

### 2. Reidemeister moves 的获取路径

**没有** `K.R1()`, `K.R2()`, `K.R3()` 这样的直接 API。但 SnapPy 提供两个相关入口：

#### `simplify(mode='basic'|'level'|'pickup'|'global')`
docstring 直接说明：
> "In the default `basic` mode, it does Reidemeister I and II moves until none are possible."
> "In `level` mode, it does random Reidemeister III moves, reducing the number of crossings via type I and II moves whenever possible."

简化方向使用，原地修改，不可逆（不可"只做一次 R3"）。

#### `backtrack(steps=10, prob_type_1=0.3, prob_type_2=0.3)`
执行 *增加* crossing 数的 R 移动序列：
- `prob_type_1=1.0, prob_type_2=0.0` → 全 R1 kink，每个 ±1 sign 随机
- `prob_type_1=0.0, prob_type_2=1.0` → 全 R2 双交叉 (+1, -1) 对（writhe 守恒）
- 不支持 R3，也不允许指定 sign

**关键观察（experimental）**：backtrack 保留原 crossing 的整数 label (0,1,2,…)，新加的 R-move crossing 标 string label (`'new1'`, `'new2'`, …)。这使得 *trace 生成* 简单：

```python
K = snappy.Link("3_1")
labels_before = {c.label for c in K.crossings}
K.backtrack(steps=2, prob_type_1=1.0, prob_type_2=0.0)
new_labels = [c.label for c in K.crossings if c.label not in labels_before]
# new_labels == ['new1', 'new2']  ←  这就是 R-move 添加的两个 crossing
```

#### 控制 R-move 的 sign（反事实关键）

backtrack 的 sign 是随机的，无法直接控制。但有两个绕路：

(a) **拒绝采样**：循环调用 backtrack 直到出现想要的 sign 模式。对小 steps 数能在几次尝试内成功。

(b) **直接构造 PD code**：对 R2，已知图 PD = `pd_old`，要在 edge `e` 处插入一对 (s1, s2) 的双交叉，可以手算新 PD code 然后 `snappy.Link(new_pd)`：
```
原 edge e 连接 (a, b) → 切开 → 插入两个 crossing c_new1, c_new2
   strand 路径: a → c_new1 → c_new2 → b
   sign(c_new1) = s1, sign(c_new2) = s2
```
对反事实"伪 R2 = 同号 (+1, +1)"特别有用，因为合法 R2 必然是 (+1, -1)，backtrack 不会生成同号对。

### 3. Per-crossing sign 是反事实的核心钩子

`K.crossings[i].sign ∈ {+1, -1}`，这是 spherogram 在加载时根据 PD code 和 directions 计算出来的。Crossing 对象本身有 `.adjacent`、`.directions`、`.strand_labels`、`.entry_points()` 等丰富数据。

**反事实 1（boundary_relaxation）**：合法 R2 要求 sign pair = (+1, -1)。生成"伪 R2" = 同号对，留下 PD-code 合法但拓扑不变性会被破坏的图。这能直接通过手算 PD code 实现。

**反事实 2（operation_perturbation）**：直接修改 PD code，把一个原 crossing 的 (over, under) 互换（即翻转那一个 crossing 的 sign），这不是任何合法 R-move，会改变纽结类型。这能用来制造 *看起来像 R-move 但其实改变了纽结* 的反例。

### 4. Performance（10 ms 量级）

测试 setup：8_1 经 backtrack(20) 后约 28 个 crossing。

| 操作 | 耗时（每次） | 备注 |
|------|-------------|------|
| `simplify('global')` | **1.5 ms** | 含 R1/R2/R3 |
| `backtrack(10)` | **0.8 ms** | 添加 ~10 个 R-move crossing |
| `PD_code()` | **<0.01 ms** | trivial |
| `seifert_matrix()` | **47 ms** | 比想象中慢 |
| `derived_invariants()`（NumPy + SymPy） | **59 ms** | SymPy det 是瓶颈 |

跑 100 个纽结的反事实评测预计 ≤ 10 秒（绝大部分是 derived_invariants）。

### 5. Mirror 验证

```
K = snappy.Link("3_1");  signs = [-1,-1,-1], writhe = -3
M = K.mirror();          signs = [+1,+1,+1], writhe = +3
```
所有 sign 翻转、writhe 取反 — 符合 mirror 的拓扑定义。

## KnotEngine 实现路径建议

| Engine 方法 | 推荐实现 |
|-------------|----------|
| `construct(spec)` | wrap `snappy.Link()` 三种入口（name / pd_code / braid_closure），存 `_link` 引用 |
| `relate(K1, K2, level=1)` | level 1: writhe + crossing-count + linking-number; level 2: + per-crossing sign vector + PD-code 比较; level 3: + seifert-matrix + 派生 (signature, determinant, Alexander) |
| `transform(K, op={"type": "R1", "sign": ±1})` | 拒绝采样 backtrack 直到产生目标 sign（小 steps 时几次内成功）；trace 通过 label diff 拿出新 crossing |
| `transform(K, op={"type": "R2", "signs": [+1,-1]})` | 同上，或对反事实 (+1,+1) 用手写 PD-code 改写 |
| `transform(K, op={"type": "R3"})` | 无现成 API；候选实现：`simplify(mode='level')` 后比较 PD code，或手写 R3 PD-code rewrite |
| `transform(K, op={"type": "mirror"})` | `K.mirror()` 直接调用 |
| `transform(K, op={"type": "connected_sum", "other": K2})` | `K.connected_sum(K2)` |
| `compare(K, K_prime)` | summary_delta: writhe / crossing-number / signature 差; detailed: PD-code 差 + per-crossing sign 差; structural: Alexander/Jones 是否变了（topological invariant 应当 invariant 在 R-move 下） |
| `counterfactual` 策略 1（伪 R2 同号） | 手写 PD-code 在 edge 上插入 (+1, +1) 对，重建 Link |
| `counterfactual` 策略 2（crossing flip） | 直接 PD-code 改写：把某个 crossing 的 (a,b,c,d) 重排成翻转 sign 的形式，重建 Link |

## 关键问题已回答

| 问题 | 答案 |
|------|------|
| R-move 有没有直接 API？ | **没有**。但 `backtrack(prob_type_1, prob_type_2)` 提供 R1/R2 添加，`simplify(mode='level')` 内部做 R3。R3 单步、控制 sign 的 R1/R2 都需要手写 PD-code 改写。 |
| Per-crossing sign 能不能拿到？ | **能**，`K.crossings[i].sign ∈ {+1, -1}`，外加 `.adjacent`, `.directions`, `.strand_labels`, `.label`。 |
| Jones polynomial 的计算效率？ | **不可用**（需 Sage）。替代：手写 Kauffman bracket（O(2^n) 但小纽结快），或派生 Alexander+signature+determinant 作为代理不变量。Alexander 计算 ~ 60ms / knot。 |
| 100 个纽结评测要多久？ | 主要瓶颈是 `derived_invariants()` (~60ms)。100 个 ≈ 6 秒。整套 SpatialMind 流程（construct → relate → transform → compare）估计 ≤ 10 秒，可接受。 |
| 能否区分原 crossing 和 R-move 添加的 crossing？ | **能**，backtrack 给原 crossing 整数 label，新 crossing string label。这让 `transform.trace` 的 region_affected 可以精确指出 R-move 添加了哪些 crossing。 |

## Jones 实现路径（可选 future work）

如果 SpatialMind 需要 Jones polynomial 作为强不变量：

**选项 A**：在 WSL 安装 Sage（`apt install sagemath`，~2 GB），所有 SnapPy Sage-only 接口立刻可用，但增加重型依赖。

**选项 B**：手写 Kauffman bracket。从 PD code 出发，对每个 crossing 选 A 或 B 平滑（2^n 种选法），对每种选法计算 loop count 和 (-A)^(-3·writhe) · A^(#A-#B) · (-A^2 - A^(-2))^(loops-1)。算法直接，复杂度 O(2^n)，对 n ≤ 12 的纽结实用。可以缓存。

**选项 C**：调用 SageMath 的 LinkInfo CLI 工具（如果安装了 SageMath as 独立可执行）—— 不推荐，subprocess 慢。

**推荐**：先用 Alexander + signature + determinant + seifert_genus_diagram 作为 invariant tuple 启动 KnotEngine。Jones polynomial 列为 future enhancement。

## 待办 / 验证 / 风险

1. ⚠️ **Signature 符号** 在 5_2、8_19 等翻转。需在 KnotEngine 文档里明示"我们的 signature 等于 SnapPy seifert_matrix 的 sig(S+S^T)，与某些教科书可能差一负号；但对 *相同* SnapPy diagram 是稳定的"。
2. ⚠️ **Seifert genus** 区分 `seifert_genus_diagram`（diagram-dependent）vs `topological_genus`（最小 genus，需 Alexander degree 计算）。
3. ✅ **Mirror sign 翻转** 已验证（3_1 测试）。
4. ✅ **R2 writhe 守恒** 已验证（backtrack R2-only：writhe 从 -3 到 -3）。
5. ⚠️ **sublink() API**：`K.sublink(components)` 需要参数，无默认。设计时需要从 `K.link_components` 构造参数。
6. 🟡 **R3 的 PD-code 改写** 是工程量最大的部分。建议第一版只支持 R1/R2/mirror/connected_sum，R3 推迟到后续。
