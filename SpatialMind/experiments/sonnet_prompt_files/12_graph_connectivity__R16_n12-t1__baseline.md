你是一个数学推理助手。以下是一个几何/拓扑问题的数据。请分析这个问题并给出你的推理过程和结论。

### 问题背景
给定一个简单无向图，删除一条指定的边。判断：(1) 该边是否为桥；(2) 删除后图是否仍连通；(3) 删除后桥数与关节点（articulation point）的变化。

### 案例 R16_n12-t1 的基础数据 (summary_delta + metadata)
```json
{
  "case_id": "R16_n12-t1",
  "summary_delta": {
    "n_vertices_b": 0,
    "n_components_b": 0,
    "is_connected_a": 0,
    "n_vertices_a": 0,
    "n_edges_b": 0,
    "is_connected_b": 0,
    "n_edges_a": -1,
    "n_components_a": 0
  },
  "metadata": {
    "graph_idx": 16,
    "n_vertices": 12,
    "n_edges_before": 17,
    "deleted_edge": [
      2,
      11
    ],
    "trial": 1
  }
}
```

### 任务
请基于以上数据回答上述问题，给出结论与简要推理。