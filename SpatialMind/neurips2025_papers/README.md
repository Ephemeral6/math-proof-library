# NeurIPS 2025 经典论文清单

下载日期：2026-05-01
位置：`SpatialMind/neurips2025_papers/`
共 10 篇 PDF，全部下载成功并通过 `%PDF` 头校验。

---

## A. NeurIPS 2025 Best Paper & Runner-up（4 篇，了解顶会审美）

### 1. Artificial Hivemind
- **arXiv**: [2510.22954](https://arxiv.org/abs/2510.22954)
- **文件**: `01_artificial_hivemind.pdf`
- **简介**: LM 输出多样性 benchmark，Best Paper
- **和我的关系**: benchmark 设计范例，看他们怎么做大规模评估

### 2. Gated Attention for LLMs
- **arXiv**: [2502.14837](https://arxiv.org/abs/2502.14837)
- **文件**: `02_gated_attention.pdf`
- **简介**: 注意力机制改进，Best Paper
- **和我的关系**: 架构层面的改进思路，和"架构而非训练"的 claim 呼应

### 3. 1000 Layer Networks for Self-Supervised RL
- **arXiv**: [2503.02138](https://arxiv.org/abs/2503.02138)
- **文件**: `03_1000layer_ssrl.pdf`
- **简介**: 深度网络 + RL，Best Paper
- **和我的关系**: "scaling depth enables new capabilities" 的 claim 结构值得学习

### 4. Eliciting Reasoning with Cognitive Tools
- **arXiv**: [2506.12115](https://arxiv.org/abs/2506.12115)
- **文件**: `04_cognitive_tools.pdf`
- **简介**: 认知工具增强 LLM 推理
- **和我的关系**: **最直接相关**——他们也从认知架构（ACT-R）出发给 LLM 接认知工具，必须在 related work 里和这篇对比

---

## B. 和我工作直接相关的论文（6 篇，定位 contribution）

### 5. World2Mind: Cognition Toolkit for Allocentric Spatial Reasoning
- **arXiv**: [2603.09774](https://arxiv.org/abs/2603.09774)
- **文件**: `05_world2mind.pdf`
- **简介**: training-free spatial cognition toolkit，用 3D 重建构造 spatial cognitive map 给 LLM 用
- **和我的关系**: **极度相关**——和 CoE 思路高度相似但 domain 不同（他们做 3D 场景，我做数学拓扑）

### 6. SpatialMath: Spatial Comprehension-Infused Symbolic Reasoning
- **arXiv**: [2601.17489](https://arxiv.org/abs/2601.17489)
- **文件**: `06_spatialmath.pdf`
- **简介**: 几何数学 benchmark + 空间理解
- **和我的关系**: 需要在论文里讨论

### 7. GCA: Geometrically-Constrained Agent for Spatial Reasoning
- **arXiv**: [2511.22659](https://arxiv.org/abs/2511.22659)
- **文件**: `07_gca_geometric_agent.pdf`
- **简介**: 用几何约束引导 VLM 做空间推理，tool-integrated reasoning
- **和我的关系**: 和 GeometricEngine 思路有交叉

### 8. SOLIDGEO: Measuring Spatial Math Reasoning in Solid Geometry
- **arXiv**: [2505.21177](https://arxiv.org/abs/2505.21177)
- **文件**: `08_solidgeo.pdf`
- **简介**: 立体几何空间推理 benchmark
- **和我的关系**: 评估 LLM 的空间认知能力

### 9. Geoint-R1: Multimodal Geometric Reasoning with Dynamic Auxiliary Constructions
- **arXiv**: [2508.03173](https://arxiv.org/abs/2508.03173)
- **文件**: `09_geoint_r1.pdf`
- **简介**: 几何推理 + 辅助构造，agent-based 方法
- **和我的关系**: 类似 Construct 原语

### 10. AgentMath: Tool-Augmented Agent for Mathematical Reasoning
- **arXiv**: [2512.20745](https://arxiv.org/abs/2512.20745)
- **文件**: `10_agentmath.pdf`
- **简介**: tool-augmented 数学推理的 SOTA，RL 训练路线
- **和我的关系**: 和我的 zero-training 路线形成对比

---

## 下载汇总

| # | 文件 | arXiv ID | 大小 |
|---|------|----------|------|
| 1 | 01_artificial_hivemind.pdf | 2510.22954 | 47 MB |
| 2 | 02_gated_attention.pdf | 2502.14837 | 2.3 MB |
| 3 | 03_1000layer_ssrl.pdf | 2503.02138 | 3.1 MB |
| 4 | 04_cognitive_tools.pdf | 2506.12115 | 732 KB |
| 5 | 05_world2mind.pdf | 2603.09774 | 817 KB |
| 6 | 06_spatialmath.pdf | 2601.17489 | 1.3 MB |
| 7 | 07_gca_geometric_agent.pdf | 2511.22659 | 13 MB |
| 8 | 08_solidgeo.pdf | 2505.21177 | 8.6 MB |
| 9 | 09_geoint_r1.pdf | 2508.03173 | 1.6 MB |
| 10 | 10_agentmath.pdf | 2512.20745 | 1.9 MB |
