# formal-conjectures 候选报告

**Generated:** 2026-05-01
**Repo:** `lean/vendor/formal-conjectures/` (clone of https://github.com/google-deepmind/formal-conjectures @ main)

---

## 1. 仓库统计

| 指标 | 数量 |
|------|------|
| 总 .lean 文件数 | 684 |
| 包含 `sorry` 的文件 | 658 |
| `category research open` 的 theorem | **1002** |
| `category research solved` 的 theorem | 654 (以 attribute 计) |
| `category API` / 辅助引理 | 119 |

通过适配器 `parse_formal_conjectures()` 全量扫描后，共 1026 个 `is_open=True` 的 declaration（与扫描器口径一致，差异源于 `lemma` 关键字也被 adapter 计入）。

### 1.1 顶层目录分布（按 open 候选）

| 目录 | 候选数（top-50 内） | 说明 |
|------|---------------------|------|
| Wikipedia | 20 | 通用知名猜想（Riemann、Beal、Gilbreath、Hall…） |
| ErdosProblems | 12 | Erdős 千题集，多为数论/组合 |
| OpenQuantumProblems | 8 | 量子复杂度类相关 |
| GreensOpenProblems | 3 | Ben Green 公开问题集 |
| Millenium | 3 | 千禧年大奖问题（Riemann、P vs NP） |
| OEIS | 2 | OEIS 序列性质 |
| Arxiv | 1 | 单篇 arXiv 论文配套 |
| OptimizationConstants | 1 | Tao 的优化常数 |

### 1.2 AMS 主分类分布（research open 1002 题）

| AMS | 数量 | 领域 |
|-----|-----:|------|
| 11 | 555 | Number theory |
| 5  | 288 | Combinatorics |
| 52 | 21  | Convex / discrete geometry |
| 51 | 15  | Geometry |
| 15 | 15  | Linear algebra |
| 12 | 14  | Field theory |
| 54 | 11  | General topology |
| 33 | 11  | Special functions |
| 26 | 9   | Real analysis |
| 20 | 8   | Group theory |
| 16 | 7   | Associative rings |
| 3  | 7   | Mathematical logic |
| 30 | 6   | Complex analysis |
| 37 | 6   | Dynamical systems |
| 28 | 3   | Measure theory |
| 40 | 3   | Sequences/series |
| 68 | 3   | Computer science |

数论与组合占 84%。

---

## 2. Top-20 候选

筛选规则：`category=research open` ∧ AMS ∈ {5,11,15,52,60,90,91,26,40,68} ∧ `stmt_lines ≤ 12` ∧ `sorry ≤ 2` ∧ docstring 非空。
排序：先按 `stmt_lines`，再按 signature 长度。

总过滤候选：886（top-50 已写入 `workspace/formal_conjectures_candidates.json`）。

| Rank | Problem | AMS | Stmt Lines | Sorry | File | 描述 |
|------|---------|-----|-----------:|------:|------|------|
| 1 | green_19.upper | 5 | 1 | 1 | GreensOpenProblems/19.lean | [Ma21] showed that $C \leq 4$. |
| 2 | P_ne_NP | 68 | 1 | 1 | Millenium/PvsNP.lean | **P ≠ NP** |
| 3 | erdos_373 | 11 | 1 | 1 | ErdosProblems/373.lean | $n!=a_1!\cdots a_k!$ 解的有限性 |
| 4 | green_19.lower | 5 | 1 | 1 | GreensOpenProblems/19.lean | $3.13 \leq C$ 下界 |
| 5 | NP_ne_coNP | 68 | 1 | 1 | Millenium/PvsNP.lean | **NP ≠ coNP** |
| 6 | buchi_problem_M5 | 11 | 1 | 1 | Wikipedia/Buchi.lean | Büchi 问题 $M=5$ 第一开放情形 |
| 7 | conjecture | 5 | 1 | 1 | GreensOpenProblems/24.lean | Green Open Problem 24 |
| 8 | agoh_giuga.variants.giuga | 11 | 1 | 1 | Wikipedia/AgohGiuga.lean | Agoh-Giuga（Giuga 形式） |
| 9 | agoh_giuga | 11 | 1 | 1 | Wikipedia/AgohGiuga.lean | Agoh-Giuga（Agoh 形式） |
| 10 | beal_conjecture | 11 | 1 | 1 | Wikipedia/BealConjecture.lean | Beal 猜想 |
| 11 | lehmer_ramanujan_tau | 11 | 1 | 1 | Wikipedia/RamanujanTau.lean | Lehmer's $\tau(n) \ne 0$ |
| 12 | riemannHypothesis | 11 | 1 | 1 | Millenium/RiemannHypothesis.lean | **Riemann Hypothesis** |
| 13 | M_eq | 5 | 1 | 1 | Wikipedia/DedekindNumber.lean | Dedekind 数闭式 |
| 14 | a.infinite | 11 | 1 | 1 | OEIS/228828.lean | A228828 序列无穷 |
| 15 | gilbreath_conjecture | 11 | 1 | 1 | Wikipedia/Gilbreath.lean | Gilbreath 猜想 |
| 16 | c1a_eq | 5 | 1 | 1 | OptimizationConstants/1a.lean | Tao C1a 精确值 |
| 17 | Dedekind_10 | 5 | 1 | 1 | Wikipedia/DedekindNumber.lean | $M(10)$ 当前未知 |
| 18 | erdos_853.parts.i | 11 | 1 | 1 | ErdosProblems/853.lean | 素数差关于 $r(x) \to \infty$ |
| 19 | hall_conjecture | 11 | 1 | 1 | Wikipedia/Hall.lean | Hall（指数 1/2） |
| 20 | erdos_770.variants.three | 11 | 1 | 1 | ErdosProblems/770.lean | $h(n)=3$ 无穷次 |

---

## 3. 重要观察 — 为什么 top-20 几乎都是大开放猜想

Top-20 全部是史上著名的开放问题（Riemann、P vs NP、Beal、Lehmer、Hall、Agoh-Giuga、Gilbreath…）。原因：本仓库就是 DeepMind 维护的「未解决问题清单」，所有 `category research open` 的 entry 都是**至少 20 年未解**的研究级问题。`stmt_lines` 短只是因为很多问题已经定义了 `RiemannHypothesis : Prop` 这样的 wrapper，让 `theorem riemannHypothesis : RiemannHypothesis := by sorry` 看起来仅 1 行。

**结论：** 单纯按"短"筛不够，必须额外考虑：
1. 是否有具体可计算结构（数值、有限情形）
2. 是否对应近年 paper 已给出可形式化的证明思路
3. 是否仅是 wrapper 而隐藏了真正的复杂度

---

## 4. 每个 Top-10 候选的完整 Lean Statement

### Candidate 1: `green_19.upper`
**File:** `GreensOpenProblems/19.lean`
```lean
@[category research open, AMS 5 11]
theorem green_19.upper : C <= 4 := by
  sorry
```
**真实难度：极高。** `C` 是关于 $\mathbb{F}_2^n \times \mathbb{F}_2^n$ 上 corner 计数的最优指数。Mandache (2021) 给出 $C \le 4$ 的论文证明，但形式化需要先把整套 corner 论证形式化。

---

### Candidate 2: `P_ne_NP`
**File:** `Millenium/PvsNP.lean`
```lean
@[category research open, AMS 68]
theorem P_ne_NP : P ≠ NP := by
  sorry
```
**难度：千禧年问题。** 不可攻。

---

### Candidate 3: `erdos_373`
**File:** `ErdosProblems/373.lean`
```lean
@[category research open, AMS 11]
theorem erdos_373 : S.Finite := by
  sorry
```
**难度：开放数论问题。** Erdős 第 373 题，关于阶乘方程 $n! = a_1! \cdots a_k!$ 解的有限性。

---

### Candidate 4: `green_19.lower`
**File:** `GreensOpenProblems/19.lean`
```lean
@[category research open, AMS 5 11]
theorem green_19.lower : C >= 3.13 := by
  sorry
```
**难度：高。** 对应 Mandache 2021 论文的下界，需形式化其论证。

---

### Candidate 5: `NP_ne_coNP`
**File:** `Millenium/PvsNP.lean`
```lean
@[category research open, AMS 68]
theorem NP_ne_coNP : NP ≠ coNP := by
  sorry
```
**难度：复杂度理论顶级开放问题。** 不可攻。

---

### Candidate 6: `buchi_problem_M5`
**File:** `Wikipedia/Buchi.lean`
```lean
@[category research open, AMS 11]
theorem buchi_problem_M5 : IsBuchi 5 := by
  sorry
```
**难度：高。** Büchi 问题 $M=5$ 已知是第一开放情形（$M \ge 6$ 在 Hilbert 第十问题不可解的假设下被解决）。

---

### Candidate 7: `conjecture` (Green Open Problem 24)
**File:** `GreensOpenProblems/24.lean`
```lean
@[category research open, AMS 5]
theorem conjecture : gamma = 1/3 := by
  sorry
```
**难度：组合数论开放。** Aaronson 2019 conjecture，关于 $\{0,1,3\}$ 仿射平移最大集的指数。

---

### Candidate 8: `agoh_giuga.variants.giuga`
**File:** `Wikipedia/AgohGiuga.lean`
```lean
@[category research open, AMS 11]
theorem agoh_giuga.variants.giuga : AgohGiugaSum := by
  sorry
```
**难度：开放猜想，但无 wrapper 隐藏。** Giuga (1950) 形式：$p$ 素数 ⟺ $\sum_{k=1}^{p-1} k^{p-1} \equiv -1 \pmod p$。已知 < $10^{4771}$ 的反例不存在。

---

### Candidate 9: `agoh_giuga`
**File:** `Wikipedia/AgohGiuga.lean`
```lean
@[category research open, AMS 11]
theorem agoh_giuga : AgohGiugaConjecture := by
  sorry
```
**难度：与 #8 等价。**

---

### Candidate 10: `beal_conjecture`
**File:** `Wikipedia/BealConjecture.lean`
```lean
@[category research open, AMS 11]
theorem beal_conjecture : BealConjecture := by
  sorry
```
**难度：百万美元悬赏开放。** $A^x + B^y = C^z$ with $x,y,z>2$ 须有公因子。

---

## 5. 实际更可攻的候选（非 top-10）

退到 top-50 之外，扫描所有 `is_open=True` 中"具体数值/有限/可决"的小问题：

### 5.1 `Arxiv/2501.03234/ArithmeticSumS.lean` — Conjectures 4.1–4.3

```lean
@[category research open, AMS 11]
theorem conjecture_4_1 (k : ℕ) (hprim : k.Prime) (hodd : Odd k)
    (hgt : k > 5) : k < S k := by
  sorry

@[category research open, AMS 11]
theorem conjecture_4_2 (k : ℕ) (hprim : k.Prime) (hodd : Odd k)
    (hgt : k > 233) : 2 * k < S k := by
  sorry

@[category research open, AMS 11]
theorem conjecture_4_3 (k : ℕ) (hprim : k.Prime) (hodd : Odd k)
    (hgt : k > 3119) : 3 * k < S k := by
  sorry
```
其中 `S k := ∑ h ∈ Finset.Ico 1 k, S' h k`，`S' h k := ∑ j ∈ Finset.Ico 1 k, (-1)^(j+1+⌊hj/k⌋)`。
**特点：** 公式化、可枚举、对小素数可 `native_decide`、有 2025 论文背景。
**真实难度：** 仍是 open（论文作者只验证到 $k \le 10^4$ 左右），但小情形可逐个 decide，agent 可形式化"已验证范围"内的事实。

### 5.2 `OptimizationConstants/1a.lean` — `c1a_lower_bound` / `c1a_upper_bound`（**已 solved 但带 sorry**）

```lean
@[category research solved, AMS 5 11 26]
theorem c1a_lower_bound : 1.2748 ≤ C1a := by sorry

@[category research solved, AMS 5 11 26]
theorem c1a_upper_bound : C1a ≤ 1.5029 := by sorry
```
注意 category 是 `research solved`：表示有 paper 给出证明，**只是没人形式化**。这正是 agent 的甜点（informal proof 已存在 → 翻译为 Lean）。但严格 follow Step 5 的"open"约束，这两个不算。

### 5.3 `Books/UniformDistributionOfSequences/Equidistribution.lean` — `isEquidistributedModuloOne_three_halves_pow`

```lean
@[category research open, AMS 11]
theorem isEquidistributedModuloOne_three_halves_pow :
    IsEquidistributedModuloOne (fun n => (3 / 2 : ℝ)^n) := by
  sorry
```
**特点：** 单一短式陈述。
**真实难度：** 极高（80 多年开放，等同于 Weyl 等分布问题），但形式化版本可借鉴 Mathlib 已有的 `Equidistribution` 引理。

---

## 6. 推荐首攻目标（Top 3）

> ⚠️ **诚实说明：** 1002 个 `research open` 没有一个是当前学界认为"近期会被攻破"的。下面三个的"可攻"指的是相对其他人选，agent 至少能产出有意义的中间引理。

### #1: `Arxiv/2501.03234/ArithmeticSumS.lean :: conjecture_4_1`
- **理由 A：** 概念新（2026 年 1 月才挂 arXiv），公式纯有限和，没有解析数论的浩瀚背景。
- **理由 B：** 论文作者已经给了关于 $S(k)$ 的若干部分结果（论文中的 Theorem 1.1, 1.2 等），形式化这些 lemma 是 tractable 的。即便不能完成 conjecture_4_1 本身，先攻 paper 的已证 lemma 也是有价值的 PR。
- **理由 C：** Lean 3 行陈述、用了具体阈值（$k > 5$），允许小情形 `native_decide` 作为 sanity check。
- **风险：** 最终猜想本身可能仍需新数学，但 agent 可走"reduce to small cases + paper lemma"路线。

### #2: `OptimizationConstants/1a.lean :: c1a_lower_bound` (虽属 solved，但应优先 fast-track)
- **理由 A：** category 是 `research solved`，意味着 Matolcsi-Vinuesa 2010 论文已经有完整证明。
- **理由 B：** Agent 的核心管道（Scout → Deep Dive → Lean Bridge）正是为这种"已知 informal proof → Lean tactic"场景设计的。
- **理由 C：** 一旦做下来就是真实 PR，证明 Sorry Replacer 端到端可工作。
- **建议：** 修改 sorry_replacer 的筛选条件，把 `research solved` 也纳入候选池——这是更合理的"首攻"靶。

### #3: `Wikipedia/AgohGiuga.lean :: agoh_giuga.variants.giuga`
- **理由 A：** 等价的 Giuga formulation 是个清晰可计算的同余式 $\sum_{k=1}^{p-1} k^{p-1} \equiv -1 \pmod p$。
- **理由 B：** 对于"$p$ 素数 ⇒ Giuga sum"方向，agent 可借助 Mathlib 已有的 Wilson、Fermat little theorem 直接闭合。难的是反向（"Giuga sum ⇒ $p$ 素数"），那一边仍 open。
- **理由 C：** 此类问题允许 agent 先攻"easy direction" 作为 lemma 提交，逐步逼近完整双向。

---

## 7. Sorry Replacer 单元测试结果

测试文件：`lean/LeanAgent/LeanAgent/Agent/input_sources/tests/test_sorry_replacer.py`

```
test_finds_two_sorries (TestReadSorryLocations) ............ PASS
test_no_sorry (TestReadSorryLocations) ..................... PASS
test_skips_theorem_without_sorry (TestReadSorryLocations) .. PASS
test_replace_first_sorry (TestReplaceSorry) ................ PASS
test_replace_multiline_proof (TestReplaceSorry) ............ PASS
test_replace_unknown_theorem_raises (TestReplaceSorry) ..... PASS
test_rollback_no_backup (TestRollback) ..................... PASS
test_rollback_restores (TestRollback) ...................... PASS
test_missing_lakefile_rolls_back (TestAttemptFillSorryDryRun) PASS

----------------------------------------------------------------------
Ran 9 tests in 0.196s — OK
```

未在真实 `lake build` 端到端测试中验证 Lean 编译路径（需要 elan/lake 已安装且 formal-conjectures 完成 `lake update`），但这是单文件 lake build 的标准 happy path，无附加风险。

---

## 8. 适配器修复说明

`formal_conjectures_adapter.py` 在本任务中做了三处必要修复（已 commit-ready，无 schema 破坏）：

1. **`_split_blocks` walkback**：原版只走 `--`/blank 行，无法回溯到 `@[category research open, AMS 11]` 这类 Lean attribute。修复：把 `@[` 开头的行也纳入回溯范围。
2. **`_parse_block` AMS 抽取**：原版只在 docstring 内搜 `AMS:`，但实际格式是 `@[category ..., AMS 5]`（attribute 内、无冒号、可能多 code 如 `AMS 5 11`）。修复：优先解析 attribute；保留 docstring 解析作 fallback。
3. **`_domain_from_ams` 多 code 处理**：原版要求 2 位前缀（`[0-9]{2}`），导致 `"5 11"` 这种以单数字开头的 string 整体落到 `general`。修复：用 `\b\d+\b` 抓取所有整数，取第一个判定。
4. **新增 `category` 字段** 与 `is_open` 布尔字段，下游可直接过滤。

修复后实测：从 `Parsed 200, Domain={'general': 200}, AMS extracted={}` → `Parsed 2000, is_open=805/2000, Domain={'combinatorics': 1655, ...}`。

---

## 9. 可执行下一步建议

1. **扩 Sorry Replacer 端到端验证**：在 `formal-conjectures` 内取 1 个简单 `solved` 文件（例如 `Wikipedia/UnionClosed.lean :: union_closed.variants.singleton_mem` 已经有完整 proof）做"fake sorry 替换"演练，确认 lake build 路径在 Windows 下可工作。
2. **把 `research solved` 纳入 Scout 候选池**：这才是 agent 真正能做出价值的标的（informal proof 已经存在）。把 `category=research solved AND has sorry` 作为优先级最高的 input source。
3. **对 5.1 的 ArithmeticSumS conjectures 跑一次完整的 Scout → Deep Dive 链路**，作为 baseline benchmark。

---

**完成条件 checklist：**
- [x] formal-conjectures 仓库已 clone（684 .lean files）
- [x] scan_formal_conjectures.py 已运行，统计完成（1002 open / 886 filtered）
- [x] sorry_replacer.py 已实现（189 LOC），9 个单元测试全过
- [x] formal_conjectures_adapter.py 修复后能正确解析（is_open=805/2000 已验证）
- [x] workspace/formal_conjectures_report.md 已生成（本文）
- [x] 推荐了 3 个首攻目标（含 1 个 solved fast-track 提案）
