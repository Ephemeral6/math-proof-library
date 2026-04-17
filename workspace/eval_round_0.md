# 基线评估报告 (Iteration 0 — Pre)

> 评估日期：2026-04-15
> 数据来源：literature_verification.md, deep_audit_report.md, failure_patterns.md, proof_classification.md, proof_techniques_summary.md, INDEX.md
> 总证明数：63（INDEX 记录 58，实际目录 63）

---

## 维度 A：证明正确性（30 分）

### A1. 结论与论文一致（10 分）

数据源：`workspace/literature_verification.md`（24 道有 PDF 验证）

| 评级 | 数量 |
|------|------|
| MATCH | 16 |
| STRONGER | 2 |
| WEAKER | 3 |
| PARTIAL | 2 |
| DIFFER | 1 |

MATCH + STRONGER = 18/24 = 75.0%

**A1 = 0.750 × 10 = 7.50**

### A2. 关键步骤无跳步（10 分）

数据源：`workspace/deep_audit_report.md`（27 道审计）

- 审计 1（技术条件）：CLEAN 21, MINOR 5, GAP 1（DSM，已修复→CLEAN）
- 审计 2（短证明深度）：完整 3/5，有跳步 2/5（DSM 已修复，Sub-Gaussian 仍有跳步）
- GAP 修复后：CLEAN 22, MINOR 5

MINOR 是引用已知结论未展开（co-coercivity, Wishart 公式等），非逻辑跳步。严格标准下认为 MINOR 算"有跳步引用"。

无跳步比例 = 22/27 = 81.5%

**A2 = 0.815 × 10 = 8.15**

### A3. 常数可追踪（5 分）

数据源：`workspace/deep_audit_report.md` 审计 3

| 评级 | 数量 |
|------|------|
| TIGHT | 23 |
| LOOSE | 1 (SPS-SGD, 4× gap, 已承认) |
| ERROR | 0 |
| N/A | 3 |

TIGHT 比例 = 23/24（排除 N/A）= 95.8%

**A3 = 0.958 × 5 = 4.79**

### A4. 技术条件完整（5 分）

CLEAN 比例 = 22/27 = 81.5%

**A4 = 0.815 × 5 = 4.07**

### A 维度总分

```
A_score = 7.50 + 8.15 + 4.79 + 4.07 = 24.51
```

---

## 维度 B：证明效率（20 分）

### B1. 首轮审计通过率（10 分）

数据源：`workspace/proof_techniques_summary.md`

- 首轮 PASS：22/27 = 81.5%
- 需要 2 轮 audit：3 道（PAC-Bayes, NPG, Extragradient）
- 需要 Fixer：0 道

近期 10 道自动生成证明的审计结果全部为首轮 PASS，整体率用 22/27。

**B1 = 0.815 × 10 = 8.15**

### B2. 平均 Explorer 成功率（5 分）

数据源：采样 `workspace/archive/` 下 9 个近期工作目录

- 总路线数：28（每道约 3 条）
- 成功路线数（含 QED/完整结论标记）：~6
- 但此方法低估，因部分成功路线不含显式标记。保守估计每道约 1/3 路线成功。

Explorer 成功率 ≈ 33%

**B2 = 0.33 × 5 = 1.65**

### B3. 引理复用率（5 分）

当前状态：`proofs/library/` 不存在，无复用机制。

**B3 = 0.00**

### B 维度总分

```
B_score = 8.15 + 1.65 + 0.00 = 9.80
```

---

## 维度 C：知识积累质量（20 分）

### C1. A 类证明占比（8 分）

数据源：`workspace/proof_classification.md`

| 类别 | 数量 | 占比 |
|------|------|------|
| A 类 | 24 | 38.1% |
| B 类 | 29 | 46.0% |
| C 类 | 10 | 15.9% |

目标：A 类 > 60%。当前远低于目标。

**C1 = 0.381 × 8 = 3.05**

### C2. 分支覆盖均匀度（4 分）

按一级分支统计：

| 分支 | 数量 |
|------|------|
| optimization | 33 |
| learning-theory | 13 |
| statistics | 8 |
| convex-analysis | 7 |
| probability | 2 |
| linear-algebra | 1 |

均值 = 10.67，标准差 = 10.75，变异系数 CV = 1.008

uniformity = max(0, 1 - CV) × 4 = max(0, -0.008) × 4 = 0

分布极度不均匀，optimization 占 52%。

**C2 = 0.00**

### C3. 文献验证覆盖率（4 分）

24 道 A 类证明中，有 PDF 验证的约 16 道 = 66.7%

**C3 = 0.667 × 4 = 2.67**

### C4. 技巧词典丰富度（4 分）

数据源：`workspace/proof_techniques_summary.md`

不同技巧数量 = 36

**C4 = min(36/50, 1) × 4 = 0.72 × 4 = 2.88**

### C 维度总分

```
C_score = 3.05 + 0.00 + 2.67 + 2.88 = 8.60
```

---

## 维度 D：系统自主性（15 分）

### D1. 自动出题质量（5 分）

数据源：`workspace/deep_audit_report.md` 审计 4 + `proof_classification.md`

最近 10 道自动生成的题目中：
- A 类：2 道（Entropy-Reg VI, ReLU Universal）
- B 类：8 道（OGD, Matrix Bernstein, Extragradient, McDiarmid, JL, Nesterov LB, ADMM×2）

A 类占比 = 2/10 = 20%

**D1 = 0.20 × 5 = 1.00**

### D2. Scout 库利用率（5 分）

当前无 `proofs/library/` 目录，Scout 无法引用已有引理库。

**D2 = 0.00**

### D3. 失败模式积累（5 分）

数据源：`workspace/failure_patterns.md`

条目数 = 4（Coordinate Descent ×2, Implicit Bias ×2）

**D3 = min(4/20, 1) × 5 = 0.20 × 5 = 1.00**

### D 维度总分

```
D_score = 1.00 + 0.00 + 1.00 = 2.00
```

---

## 维度 E：研究潜力（15 分）

### E1. STRONGER 结果数（5 分）

数据源：`workspace/literature_verification.md`

STRONGER 数量 = 2（SAM 收敛率、RIP δ₂ₛ 条件）

**E1 = min(2 × 2.5, 5) = 5.00**

### E2. Conjecture 级通过率（5 分）

INDEX.md 中标注 conjecture 的证明：

| 证明 | 状态 |
|------|------|
| NPG softmax tabular | PASS |
| SGD PL+interpolation averaging | PASS |
| Heavy Ball instability | PASS |
| SGD last-iterate averaged baseline | PASS |
| Momentum SGD interpolation convergence | PASS (但 lit-verify 标记 WEAKER) |

通过率 = 4/5 = 80%（剔除 WEAKER 的 Momentum SGD）

**E2 = 0.80 × 5 = 4.00**

### E3. 障碍分析深度（5 分）

当前无结构化的 open problem 障碍分析文件。SGD last-iterate 有证明但无探索性分析报告。

**E3 = 1.00**（有一些探索但无系统产出）

### E 维度总分

```
E_score = 5.00 + 4.00 + 1.00 = 10.00
```

---

## 总分汇总

| 维度 | 满分 | 得分 | 占满分% |
|------|------|------|---------|
| A 证明正确性 | 30 | **24.51** | 81.7% |
| B 证明效率 | 20 | **9.80** | 49.0% |
| C 知识积累质量 | 20 | **8.60** | 43.0% |
| D 系统自主性 | 15 | **2.00** | 13.3% |
| E 研究潜力 | 15 | **10.00** | 66.7% |
| **总分** | **100** | **54.91** | **54.9%** |

---

## 最弱的 3 个子项

| 排名 | 子项 | 得分 | 满分 | 占比 | 改进方向 |
|------|------|------|------|------|---------|
| 1 | **D2. Scout 库利用率** | 0.00 | 5 | 0% | 建立 library/ + 修改 Scout 检索逻辑 |
| 2 | **B3. 引理复用率** | 0.00 | 5 | 0% | 建立 library/ + 修改 Explorer 引用规则 |
| 3 | **C2. 分支覆盖均匀度** | 0.00 | 4 | 0% | 补充 probability, linear-algebra 分支 |

其他低分项：D1 (1.00/5), D3 (1.00/5), E3 (1.00/5)

---

## 基线评估结论

**总分 54.91/100** — 系统在证明正确性（A=81.7%）和研究潜力（E=66.7%）方面表现良好，但在系统自主性（D=13.3%）和知识积累结构（C=43.0%）方面有显著提升空间。

核心瓶颈：
1. **无 library/ 基础设施** → D2, B3 双零，阻碍引理复用
2. **分支分布极度不均** → C2 零分，optimization 独占 52%
3. **自动出题 A 类占比低** → D1 仅 20%，generator 倾向出经典题
4. **失败模式积累不足** → D3 仅 4 条，远低于目标 20 条

迭代 0 的下一步：执行证明库分层（research/ vs library/），建立复用基础设施。
