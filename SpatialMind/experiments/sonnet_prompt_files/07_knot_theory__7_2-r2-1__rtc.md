你是一个数学推理助手。以下是一个几何/拓扑问题。一个领域引擎已经计算了结构数据 (R)、变换轨迹 (T) 和反事实对比 (C)。请基于这些数据进行推理并给出结论。

### 问题背景
对一个结的图代码应用 R2（Reidemeister 2）变换：在图上插入一对相消的交叉。判断该 R2 应用是否合法（即结类型与所有标准不变量是否保持），并说明 signature / determinant / Alexander 多项式 / writhe 的变化情况。

### 案例 7_2-r2-1 的引擎结构数据 (R + T)
```json
{
  "case_id": "7_2-r2-1",
  "summary_delta": {
    "writhe_delta": 0,
    "linking_number": 0.0,
    "crossing_count_b": 0,
    "writhe_b": 0,
    "crossing_count_a": 2,
    "writhe_a": 0
  },
  "metadata": {
    "knot": "7_2",
    "move": "R2",
    "trial": 1,
    "writhe_pre": -7,
    "writhe_post": -7,
    "n_crossings_pre": 7,
    "n_crossings_post": 9
  },
  "detailed_comparison": {
    "crossings_a_before": 7,
    "crossings_a_after": 9,
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
    "signs_count_pos_pre": 0,
    "signs_count_neg_pre": 7,
    "signs_count_pos_post": 1,
    "signs_count_neg_post": 8
  },
  "structural_comparison": {
    "signature_pre": -2,
    "signature_post": -2,
    "signature_preserved": true,
    "determinant_pre": 11,
    "determinant_post": 11,
    "determinant_preserved": true,
    "alexander_pre_raw": "3*t**8 - 5*t**7 + 3*t**6",
    "alexander_post_raw": "3*t**14 - 5*t**13 + 3*t**12",
    "alexander_pre_normalized": [
      3,
      -5,
      3
    ],
    "alexander_post_normalized": [
      3,
      -5,
      3
    ],
    "alexander_preserved": true,
    "writhe_pre": -7,
    "writhe_post": -7,
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
          13,
          10,
          0,
          11
        ],
        [
          9,
          0,
          10,
          1
        ],
        [
          1,
          8,
          2,
          9
        ],
        [
          7,
          2,
          8,
          3
        ],
        [
          3,
          6,
          4,
          7
        ],
        [
          11,
          4,
          12,
          5
        ],
        [
          5,
          12,
          6,
          13
        ]
      ],
      "writhe": -7,
      "n_crossings": 7,
      "signs": [
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1
      ]
    },
    "after_state": {
      "pd_code": [
        [
          3,
          6,
          4,
          7
        ],
        [
          9,
          0,
          10,
          1
        ],
        [
          17,
          10,
          0,
          11
        ],
        [
          11,
          16,
          12,
          17
        ],
        [
          15,
          12,
          16,
          13
        ],
        [
          5,
          14,
          6,
          15
        ],
        [
          13,
          4,
          14,
          5
        ],
        [
          2,
          8,
          3,
          7
        ],
        [
          1,
          8,
          2,
          9
        ]
      ],
      "writhe": -7,
      "n_crossings": 9,
      "signs": [
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
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
        "3",
        "4",
        "5",
        "6"
      ],
      "persistent_crossing_count": 7
    },
    "sub_steps": []
  },
  "reference_in_transform_region": {
    "persistent_crossing_count": 7,
    "persistent_crossing_labels": [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6"
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