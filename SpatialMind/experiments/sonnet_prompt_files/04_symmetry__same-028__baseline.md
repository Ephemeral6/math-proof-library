你是一个数学推理助手。以下是一个几何/拓扑问题的数据。请分析这个问题并给出你的推理过程和结论。

### 问题背景
正六边形顶点 3 色着色 a 与 b。考虑循环群 Z_6 在顶点上的作用。判断 a 与 b 是否在同一个 Z_6 轨道下；若同轨道，给出群元素见证；若不同轨道，说明哪个不变量阻断了等价。

### 案例 same-028 的基础数据 (summary_delta + metadata)
```json
{
  "case_id": "same-028",
  "summary_delta": {
    "orbit_size_b": 0,
    "hamming_distance": -5,
    "same_orbit": 0,
    "orbit_size_a": 0
  },
  "metadata": {
    "label": "same",
    "same_orbit": true,
    "g_idx": 5,
    "g_perm": [
      5,
      0,
      1,
      2,
      3,
      4
    ],
    "a_coloring": [
      0,
      1,
      1,
      0,
      2,
      1
    ],
    "b_coloring": [
      1,
      0,
      1,
      1,
      0,
      2
    ],
    "orbit_size_a": 6,
    "orbit_size_b": 6,
    "n_distinct_a": 3,
    "n_distinct_b": 3
  }
}
```

### 任务
请基于以上数据回答上述问题，给出结论与简要推理。