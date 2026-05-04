"""core/prompt.py — Benchmark prompt template framework.

每个 domain 提供 domain-specific 的 prompt 片段，core 负责组装。
"""

from __future__ import annotations
from dataclasses import dataclass


@dataclass
class BenchmarkPrompt:
    """一个 benchmark level 的完整 prompt。"""

    # 系统 prompt（不变的部分）
    system: str = """你面前有几何变换的数据。你的目标是：
1. 从数据中发现变换为什么保持（或不保持）某个不变量
2. 构造一个对任意输入成立的证明

规则：
- 不要搜索文献，纯粹从数据推理
- 诚实评估你的发现：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL
- 先分析数据，再尝试构造证明"""

    # Domain 描述（由 domain 填）
    domain_description: str = ""

    # Level 描述（由 core 生成）
    level_description: str = ""

    # 数据描述（由 domain 填）
    data_guide: str = ""

    # 任务 prompt（由 core 生成，每层不同）
    task: str = ""

    # 反事实引导（只在 Level 5）
    counterfactual_guide: str = ""

    def render(self) -> str:
        parts = [self.system, "", "## 问题背景", self.domain_description]
        if self.level_description:
            parts.extend(["", "## 数据层级", self.level_description])
        if self.data_guide:
            parts.extend(["", "## 数据字段说明", self.data_guide])
        parts.extend(["", "## 你的任务", self.task])
        if self.counterfactual_guide:
            parts.extend(["", "## 反事实数据", self.counterfactual_guide])
        return "\n".join(parts)


# Level descriptions（core 提供，domain-agnostic）
LEVEL_DESCRIPTIONS = {
    1: "Level 1: 你只有变换前后的数值摘要（summary_delta）。例如交叉数/不变量的变化值。",
    2: "Level 2: 在 Level 1 的基础上，你还有 per-element 的位置数据（detailed_comparison）。例如每个交叉点在哪个三角形、涉及哪些 arc。",
    3: "Level 3: 在 Level 2 的基础上，你还有变换的轨迹（transform_trace）和参照对象与变换区域的重叠关系（reference_in_transform_region）。",
    4: "Level 4: 在 Level 3 的基础上，你还有拓扑结构数据（structural_comparison）。例如 bigon 列表、每个 bigon 是否包含 puncture。",
    5: "Level 5: 在 Level 4 的基础上，你还有反事实 case——条件被放宽后变换的行为变了。对比正例和反事实，找出关键条件。",
}
