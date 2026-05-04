你是一个数学推理助手。以下是一个几何/拓扑问题。一个领域引擎已经计算了结构数据 (R)、变换轨迹 (T) 和反事实对比 (C)。请基于这些数据进行推理并给出结论。

### 问题背景
对一个结的图代码应用 R2（Reidemeister 2）变换：在图上插入一对相消的交叉。判断该 R2 应用是否合法（即结类型与所有标准不变量是否保持），并说明 signature / determinant / Alexander 多项式 / writhe 的变化情况。

### 案例 4_1-r2-4 的引擎结构数据 (R + T)
```json
{
  "case_id": "4_1-r2-4",
  "summary_delta": {
    "writhe_delta": 0,
    "linking_number": 0.0,
    "crossing_count_b": 0,
    "writhe_b": 0,
    "crossing_count_a": 2,
    "writhe_a": 0
  },
  "metadata": {
    "knot": "4_1",
    "move": "R2",
    "trial": 4,
    "writhe_pre": 0,
    "writhe_post": 0,
    "n_crossings_pre": 4,
    "n_crossings_post": 6
  },
  "detailed_comparison": {
    "crossings_a_before": 4,
    "crossings_a_after": 6,
    "added_crossing_count": 2,
    "added_crossing_signs": [
      1,
      -1
    ],
    "added_crossing_signs_pair": [
      -1,
      1
    ],
    "writhe_change_a": 0,
    "signs_count_pos_pre": 2,
    "signs_count_neg_pre": 2,
    "signs_count_pos_post": 3,
    "signs_count_neg_post": 3
  },
  "structural_comparison": {
    "signature_pre": 0,
    "signature_post": 0,
    "signature_preserved": true,
    "determinant_pre": 5,
    "determinant_post": 5,
    "determinant_preserved": true,
    "alexander_pre_raw": "-t**2 + 3*t - 1",
    "alexander_post_raw": "-t**5 + 3*t**4 - t**3",
    "alexander_pre_normalized": [
      1,
      -3,
      1
    ],
    "alexander_post_normalized": [
      1,
      -3,
      1
    ],
    "alexander_preserved": true,
    "writhe_pre": 0,
    "writhe_post": 0,
    "writhe_preserved": true,
    "all_topological_invariants_preserved": true
  },
  "transform_trace": {
    "operation_name": "R2",
    "operation_params": {
      "target_signs": [
        1,
        -1
      ]
    },
    "before_state": {
      "pd_code": [
        [
          7,
          4,
          0,
          5
        ],
        [
          3,
          0,
          4,
          1
        ],
        [
          1,
          7,
          2,
          6
        ],
        [
          5,
          3,
          6,
          2
        ]
      ],
      "writhe": 0,
      "n_crossings": 4,
      "signs": [
        -1,
        -1,
        1,
        1
      ]
    },
    "after_state": {
      "pd_code": [
        [
          1,
          6,
          2,
          7
        ],
        [
          7,
          0,
          8,
          1
        ],
        [
          11,
          3,
          0,
          2
        ],
        [
          5,
          9,
          6,
          8
        ],
        [
          9,
          5,
          10,
          4
        ],
        [
          10,
          3,
          11,
          4
        ]
      ],
      "writhe": 0,
      "n_crossings": 6,
      "signs": [
        -1,
        -1,
        1,
        1,
        1,
        -1
      ]
    },
    "delta": {
      "crossing_count_delta": 2,
      "writhe_delta": 0
    },
    "region_affected": {
      "added_crossing_labels": [
        "new2",
        "new3"
      ],
      "added_crossing_signs": [
        1,
        -1
      ],
      "added_crossing_signs_pair": [
        -1,
        1
      ],
      "added_crossing_count": 2,
      "persistent_crossing_labels": [
        "0",
        "1",
        "2",
        "3"
      ],
      "persistent_crossing_count": 4
    },
    "sub_steps": []
  },
  "reference_in_transform_region": {
    "persistent_crossing_count": 4,
    "persistent_crossing_labels": [
      "0",
      "1",
      "2",
      "3"
    ],
    "added_crossing_labels": [
      "new2",
      "new3"
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
      "r2_added_signs_pair": [
        -1,
        1
      ],
      "writhe_change_required": 0
    },
    "modified_condition": {
      "r2_added_signs_pair": [
        -1,
        -1
      ],
      "writhe_change_observed": -2
    },
    "original_result": {
      "signature": -2,
      "determinant": 3,
      "alexander_normalized": [
        1,
        -1,
        1
      ]
    },
    "counterfactual_result": {
      "signature": -2,
      "determinant": 7,
      "alexander_normalized": [
        2,
        -3,
        2
      ]
    },
    "delta": {
      "signature_delta": 0,
      "determinant_delta": 4,
      "writhe_delta": -2,
      "alexander_changed": true
    },
    "condition_is_critical": true,
    "explanation": "Real R2 inserts a (+1, -1) crossing pair so writhe is preserved. Forcing same-sign pair gives a 'pseudo R2' that changes writhe by ±2 and breaks topological invariants."
  },
  {
    "strategy": "operation_perturbation",
    "original_condition": {
      "flipped_crossing_index": null
    },
    "modified_condition": {
      "flipped_crossing_index": 0
    },
    "original_result": {
      "signature": -2,
      "determinant": 3,
      "alexander_normalized": [
        1,
        -1,
        1
      ]
    },
    "counterfactual_result": {
      "signature": 0,
      "determinant": 1,
      "alexander_normalized": [
        1
      ]
    },
    "delta": {
      "signature_delta": 2,
      "determinant_delta": -2,
      "writhe_delta": 2,
      "alexander_changed": true
    },
    "condition_is_critical": true,
    "explanation": "Flipping one crossing's over/under is not a Reidemeister move; it changes the knot type, so signature / determinant / Alexander all generally change."
  },
  {
    "strategy": "condition_removal",
    "original_condition": {
      "planarity_check": true
    },
    "modified_condition": {
      "planarity_check": false,
      "swap_strands": [
        0,
        1
      ]
    },
    "original_result": {
      "valid_diagram": true
    },
    "counterfactual_result": {
      "valid_diagram": true,
      "signature": -1,
      "determinant": 2
    },
    "delta": {
      "signature_delta": 1
    },
    "condition_is_critical": true,
    "explanation": "Dropping planarity (swapping strand labels at random) yields an inconsistent diagram. This shows the planarity constraint is structurally required for any topological reasoning."
  }
]
```

### 任务
请基于以上 R/T/C 数据回答问题，结合不变量、变换轨迹与反事实给出结论与推理。