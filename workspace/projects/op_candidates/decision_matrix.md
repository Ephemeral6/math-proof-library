# OP-3 候选方向决策矩阵

**Date**: 2026-04-28
**Method**: 8 个 Sonnet scout 并行评估（literature + technical + risk + value 四阶段）
**Scope**: OP-2 (SHB stochastic non-SC last-iterate LB) 之后的下一研究方向选择
**Constraint**: 6 周内出 publication-quality result

---

## 一、综合评估表

| 方向 | 技术可行性 | 学术价值 | 文献成熟度 | 6 周可行性 | 主背书人 (匹配度) | 综合推荐 |
|---|---|---|---|---|---|---|
| **A1** Adam last-iterate LB | 6/10 | 6/10 | gap clear (Adam 专属未做) | MEDIUM | 李晨毅 (8/10) | **CONSIDER** |
| **A2** SHB non-convex LB | 6/10 | 6/10 | gap partial (Arjevani 已做 minimax，SHB-specific 未做) | MEDIUM | 文再文 (8/10) | **CONSIDER** |
| **B1** Bilevel last-iterate LB | 7/10 | 7.5/10 | gap clear (任何 last-iterate LB 都没有) | MEDIUM (60-65%) | 李晨毅 (9/10, co-author of 2511.22331) | **RECOMMEND** ★ |
| **B2** Min-max last-iterate LB | 6/10 | 4/10 | **closed** (Cai-Oikonomou 2022 + 2604.03782 Apr 2026) | LOW (70% scoop risk) | 文再文 (中等) | **SKIP** |
| **C1** Multi-agent LLM LB | 3/10 | 4/10 | 缺乏 theorem 形式定义 | LOW (定义先行 2-4 周) | 董彬 (8/10) | **SKIP** (6 周内不可达) |
| **C2** Failure mode classification | 5/10 | 7/10 (上限 9) | gap clear（无 classification theorem） | MEDIUM (re-scoped) | 董彬 (9/10) | **CONSIDER** ★ |
| **D1** Counterexample query LB | 7/10 | 7/10 | gap clear（property testing 邻而不同） | MEDIUM (仅限 Boolean) | 陈小杨 (9/10) | **RECOMMEND** ★ |
| **D2** Symbolic regression sample LB | 7.5/10 | 7.5/10 | gap clear (NP-hard 已做但 statistical LB 全开) | MEDIUM-HIGH | 陈小杨 (9/10) | **RECOMMEND** ★ |

---

## 二、Top-3 推荐 + 下一步行动

### 🥇 #1: B1 — Bilevel Optimization Last-Iterate Lower Bound

**为什么 #1**:
- 文献 gap 最干净：2024-2026 没有任何 bilevel last-iterate LB 论文
- 直接复用 OP-2 Le Cam 框架 + 二次降维归约 (φ(x) = f(x, Cx))
- **背书人匹配度最强**：李晨毅是 arxiv 2511.22331 (Nov 2025) 的 co-author，B1 直接补全他正在做的 program；这是潜在 PhD advisor 直接对口
- 主题热度高：bilevel 是 meta-learning / hyperparameter / RL 三个方向共同的工具
- 证明路线已有清晰雏形（quadratic 降维 + 已有 OP-2 cycling 实例）

**主要风险**:
1. quadratic 归约破坏 oscillation 结构（如 C 谱半径太大）→ mitigation: 选择小 norm C
2. hypergradient bias 意外救了 last iterate → mitigation: 正交分解
3. 与 Ji 2511.19656 区分度（reviewer 视角）→ mitigation: 显式写 separation theorem

**下一步行动**:
1. **Week 1 数值前哨实验**：构造 g(x,y) = ½‖y − Cx‖², f(x,y) = OP-2 cycling instance @ y = Cx；NumPy 跑 SGD bilevel iterates 验证 x_T 振荡而平均收敛
2. **Week 1 学术联系**：基于 OP-2 现有进展，给李晨毅写一封简短的 problem statement，征求他对 B1 的看法（同时建立背书关系）
3. 若 Week 1 数值实验通过 → 启动完整 5 阶段 pipeline；若失败 → 直接构造 φ 而不走 composition 归约

---

### 🥈 #2: D2 — Symbolic Regression Sample Complexity Lower Bound

**为什么 #2**:
- 文献 gap 极干净：NP-hard (computational) 2022-2024 已关闭，statistical sample LB 全开
- **技术路线最具体**：Fano packing argument，pipeline 已有 xu-raginsky / ssl-infonce-minimax 模板可复用
- **AI4Math 跨界增益最大**：与 OP-2 完全不同 community，进入陈小杨 / 袁洋 视野
- 6 周可行性 MEDIUM-HIGH（高于 B1）
- **Anchor 选择已就位**: S(d=4, s=20, Σ_Feynman) 既有 community relevance 又保留 separation lemma 可解性

**主要风险**:
1. 结果坍缩到 finite-class PAC（mitigation: 把 (s, log|Σ|) joint dependence 写显式）
2. 选择 S 缺乏动机（mitigation: 锚定 Feynman benchmark，不要 ad hoc）
3. L² separation 在 x ≈ 0 失效（mitigation: P_X = Uniform[1,2]）

**下一步行动**:
1. **Week 1**: 写 problem.md 锁定 S(d=4, s=20, Σ_Feynman)；搜 PySR 文献 verify 这个类的 community 接受度
2. **Week 1-2**: 表达式树 enumeration（Catalan + labeled-tree counting）求 packing 数 M
3. **Week 3**: 定义并证明 separation lemma（sin vs polynomial 用 Uniform[1,2] 距离 lower bound）
4. **Week 4-6**: Fano LB 主线 + 数值 sanity check（PySR/gplearn 反例搜索）

---

### 🥉 #3: D1 — Counterexample Construction Query-Complexity LB (Boolean scope)

**为什么 #3**:
- Novel framing：把 conjecture refutation 形式化为 query complexity 问题，无直接竞争论文
- 与 D2 共享 陈小杨 endorser (9/10)
- 用 Ben-David-Blais 2023 minimax 定理 + planted Boolean instances，路线清晰
- 与 OP-2 的 oracle-complexity 工具直接共用
- **范围严格收紧到 Boolean unstructured 模型**才是 6 周可达；graph/poly 模型 10-12 周

**主要风险**:
1. "conjecture class" 定义的非平凡化（mitigation: parametric double-indexed by instance + parameter；前 1 周专门做这件事）
2. 与 property testing 相邻而易混（mitigation: 显式 decision-vs-output-required 区分）
3. 范围蔓延到非 Boolean 而失控（mitigation: 严格守 Boolean scope，把 graph/poly 留作 follow-up）

**下一步行动**:
1. **Week 1 全周仅做定义工作**：写 conjecture class 的 parametric 形式定义，发邮件给陈小杨/袁洋征求一句反馈
2. **Week 2-3**: planted Boolean hard distribution 构造 + Yao minimax 应用
3. **Week 4-5**: Le Cam 缩减借用 OP-2 工具
4. **Week 6**: 写作 + SymPy decision tree simulation 数值验证

---

## 三、特殊提示：C2 作为后备/并行选项

**C2 (Failure mode classification — re-scoped)** 不进入 Top-3 是因为：
- 6 周可达性是 MEDIUM 而不是 HIGH
- 范围必须严格收紧到 single class (QA quantifier-alternation) + single LB

但 C2 拥有**整套 8 个候选里唯一不可复制的资产**：你的 pipeline 已积累的 failure database。董彬 9/10 endorser 匹配。如果 B1/D2/D1 都因为某种原因不可推进，C2 是最值得作为 fallback 的。

**C2 的最低可行 deliverable**: 一个 specific formula family + tactic-oracle query model + adversary-method LB → 一篇 workshop paper 起步，会议 paper 上限。

---

## 四、被 SKIP 的方向 — 简短说明

- **B2 Min-max**: 文献已基本饱和，Cai-Oikonomou 2022 + Apr 2026 anchored GDA 论文已关闭主要 gap；剩下的 stochastic variant 70%+ 概率被 Cai/Daskalakis/Gorbunov 组在 6 周内 scoop。
- **C1 Multi-agent LLM LB**: 问题尚未 theorem-shaped，仅定义工作就需 2-4 周；6 周内只能产出 workshop position paper，不达 publication-quality LB 标准。建议 OP-2 提交后再回头考虑。

---

## 五、综合判断

如果只能选一个：**B1**（gap 最干净 × 背书人最强匹配 × 6 周可达性 medium-high）。

如果时间允许 **B1 + 1 个并行**：选 **D2**（路线最具体）。这两条线技术工具有重叠（Le Cam + packing），但应用领域截然不同，可以共享文献阅读 / 计算基建 / 写作风格，节省总投入。

如果今后路线想做 PhD advisor pivot 到 AI4Math：选 **D2** 而非 B1（陈小杨/董彬/袁洋 而非 李晨毅）。如果继续 optimization theory: B1 直接对接李晨毅 program。

---

## 六、文件清单

`workspace/active/op_candidates/`:
- `literature_<XX>.md` × 8: 各方向 2023-2026 文献调研
- `technical_<XX>.md` × 8: 技术路线 + pipeline 复用
- `risk_<XX>.md` × 8: gap 真伪验证 + 6 周可行性
- `value_<XX>.md` × 8: impact + portfolio + endorser 评分
- `decision_matrix.md`: 本文件

总计 33 个文件。8 个并行 Sonnet agents 用时约 7 分钟（实际平均 ~5min/agent，最长 396s）。
