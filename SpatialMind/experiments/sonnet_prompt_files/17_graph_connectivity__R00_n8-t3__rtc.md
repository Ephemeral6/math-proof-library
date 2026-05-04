你是一个数学推理助手。以下是一个几何/拓扑问题。一个领域引擎已经计算了结构数据 (R)、变换轨迹 (T) 和反事实对比 (C)。请基于这些数据进行推理并给出结论。

### 问题背景
给定一个简单无向图，删除一条指定的边。判断：(1) 该边是否为桥；(2) 删除后图是否仍连通；(3) 删除后桥数与关节点（articulation point）的变化。

### 案例 R00_n8-t3 的引擎结构数据 (R + T)
```json
{
  "case_id": "R00_n8-t3",
  "summary_delta": {
    "n_vertices_b": 0,
    "n_components_b": 0,
    "is_connected_a": {
      "pre": true,
      "post": false
    },
    "n_vertices_a": 0,
    "n_edges_b": 0,
    "is_connected_b": 0,
    "n_edges_a": -1,
    "n_components_a": 1
  },
  "metadata": {
    "graph_idx": 0,
    "n_vertices": 8,
    "n_edges_before": 9,
    "deleted_edge": [
      4,
      7
    ],
    "trial": 3
  },
  "detailed_comparison": {
    "n_edges_pre": 9,
    "n_edges_post": 8,
    "n_bridges_pre": 1,
    "n_bridges_post": 0,
    "deleted_edge_was_bridge": true,
    "connectivity_lost": true,
    "n_components_pre": 1,
    "n_components_post": 2
  },
  "structural_comparison": {
    "components_pre": [
      [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7
      ]
    ],
    "components_post": [
      [
        0,
        1,
        2,
        3,
        5,
        6,
        7
      ],
      [
        4
      ]
    ],
    "articulation_points_pre": [
      7
    ],
    "articulation_points_post": [],
    "is_connected_pre": true,
    "is_connected_post": false,
    "is_connected_preserved": false,
    "n_components_preserved": false
  },
  "transform_trace": {
    "operation_name": "delete_edge",
    "operation_params": {
      "edge": [
        4,
        7
      ]
    },
    "before_state": {
      "n_edges": 9,
      "n_components": 1,
      "is_connected": true
    },
    "after_state": {
      "n_edges": 8,
      "n_components": 2,
      "is_connected": false
    },
    "delta": {
      "n_edges_delta": -1,
      "components_change": 1,
      "is_bridge": true,
      "connectivity_lost": true
    },
    "region_affected": {
      "deleted_edge": [
        4,
        7
      ],
      "endpoint_degrees_before": [
        1,
        3
      ],
      "endpoint_degrees_after": [
        0,
        2
      ]
    },
    "sub_steps": []
  },
  "reference_in_transform_region": {
    "deleted_edge": [
      4,
      7
    ],
    "endpoint_degrees_before": [
      1,
      3
    ],
    "endpoint_degrees_after": [
      0,
      2
    ]
  }
}
```

### 反事实对比 (C)
```json
[
  {
    "strategy": "boundary_relaxation",
    "original_condition": {
      "deleted_edge_is_bridge": false,
      "deleted_edge": [
        1,
        2
      ]
    },
    "modified_condition": {
      "deleted_edge_is_bridge": true,
      "deleted_edge": [
        4,
        5
      ]
    },
    "original_result": {
      "is_connected_after": true,
      "n_components_after": 1
    },
    "counterfactual_result": {
      "is_connected_after": false,
      "n_components_after": 2
    },
    "delta": {
      "n_components_delta_positive": 0,
      "n_components_delta_counterfactual": 1,
      "connectivity_lost_positive": false,
      "connectivity_lost_counterfactual": true
    },
    "condition_is_critical": true,
    "explanation": "Deleting a non-bridge edge keeps the graph connected; deleting a bridge edge disconnects it. The bridge property (no alternative path between endpoints) is what determines whether connectivity is preserved under edge deletion."
  },
  {
    "strategy": "operation_perturbation",
    "original_condition": {
      "operation": "delete_edge",
      "edge": [
        0,
        1
      ]
    },
    "modified_condition": {
      "operation": "add_edge",
      "edge": [
        0,
        5
      ]
    },
    "original_result": {
      "n_components_after": 2,
      "components_change": 1
    },
    "counterfactual_result": {
      "n_components_after": 1,
      "components_change": 0
    },
    "delta": {
      "components_change_positive": 1,
      "components_change_counterfactual": 0,
      "directional_asymmetry": true
    },
    "condition_is_critical": true,
    "explanation": "Edge deletion can only increase or preserve component count; edge addition can only decrease or preserve it. The two operations are not symmetric, and a bridge under deletion has no analogue under addition (every cut vertex is created by deletion, not addition)."
  }
]
```

### 任务
请基于以上 R/T/C 数据回答问题，结合不变量、变换轨迹与反事实给出结论与推理。