# KnotEngine 接口设计

**对应审计**: `audit_snappy.md`（同目录）
**对接 protocol**: `SpatialMind/core/engine.py::GeometricEngine`
**参考实现**: `SpatialMind/domains/surface_topology/engine.py`

本文档只做**接口设计**，不写完整实现。基于 SnapPy 3.3.2 + spherogram 2.4.1 的能力。

---

## 1. 数据对象：`KnotObject`

镜像 `surface_topology.SurfaceCurve` 的设计，但承载 SnapPy `Link` 而不是 curver lamination。

```python
@dataclass
class KnotObject:
    """A knot/link diagram backed by a snappy.Link."""
    _object_id: str
    pd_code: tuple[tuple[int, int, int, int], ...]  # 规范化 PD code（hashable）
    crossing_signs: tuple[int, ...]                  # 每个 crossing 的 ±1
    num_components: int
    _link: Any = field(default=None, repr=False)     # snappy.Link

    @property
    def object_id(self) -> str:
        return self._object_id

    def to_json(self) -> dict:
        return {
            "object_id": self._object_id,
            "pd_code": [list(c) for c in self.pd_code],
            "crossing_signs": list(self.crossing_signs),
            "num_components": self.num_components,
        }
```

**两个不变量**：
- `pd_code` 规范化后是 hashable 的标准 ID（用于 dedup、用作字典键）。
- `crossing_signs` 与 `pd_code` 一一对应，长度相等。

---

## 2. `construct(spec)` → `KnotObject`

支持的 `spec` 形式：

```python
{"name": "3_1"}                        # SnapPy 内置纽结表查询
{"name": "K12n_0001"}                  # SnapPy 12-cross 纽结表
{"pd_code": [[1,5,2,4], …]}            # 直接用 PD code
{"braid_closure": [1,1,1]}             # 用 braid word（trefoil）
{"link": <existing snappy.Link>}       # 直接传 SnapPy Link 对象
{"object_id": "...", ...}              # 显式 object_id（否则用 name 或 pd-hash）
```

**实现要点**：
```python
def construct(self, spec: dict) -> KnotObject:
    if "link" in spec:
        L = spec["link"]
    elif "name" in spec:
        L = snappy.Link(spec["name"])
    elif "pd_code" in spec:
        L = snappy.Link(spec["pd_code"])
    elif "braid_closure" in spec:
        L = snappy.Link(braid_closure=spec["braid_closure"])
    else:
        raise ValueError(f"unrecognised spec {spec!r}")

    pd = tuple(tuple(int(x) for x in c) for c in L.PD_code())
    signs = tuple(int(c.sign) for c in L.crossings)
    obj_id = spec.get("object_id") or spec.get("name") or _pd_hash(pd)
    return KnotObject(
        _object_id=obj_id,
        pd_code=pd,
        crossing_signs=signs,
        num_components=len(L.link_components),
        _link=L,
    )
```

`_pd_hash(pd)` 用 hashlib 算 SHA-1 前 8 位，给纯 PD-code 输入一个稳定的短 ID。

---

## 3. `relate(K_a, K_b, detail_level)` → `RelationData`

| Level | 字段 | 数据来源 |
|-------|------|---------|
| 1 (summary) | `crossing_count_a`, `crossing_count_b`, `writhe_a`, `writhe_b`, `linking_number` | `len(L.crossings)`, `L.writhe()`, `L.linking_number()` |
| 2 (detailed) | + `crossing_signs_a`, `crossing_signs_b`, `pd_code_a`, `pd_code_b`, `signs_match`, `pd_code_match` | KnotObject 自带字段 + 直接比较 |
| 3 (structural) | + `seifert_matrix_a/b`, 派生 `signature_a/b`, `determinant_a/b`, `alexander_polynomial_a/b`, `alexander_match`, `seifert_genus_diagram_a/b` | `seifert_matrix()` + `derived_invariants()` |

```python
def relate(self, K_a, K_b, detail_level=1) -> RelationData:
    L_a, L_b = K_a._link, K_b._link
    rel = RelationData(
        object_a_id=K_a.object_id,
        object_b_id=K_b.object_id,
        summary={
            "crossing_count_a": len(L_a.crossings),
            "crossing_count_b": len(L_b.crossings),
            "writhe_a": int(L_a.writhe()),
            "writhe_b": int(L_b.writhe()),
            "linking_number": float(L_a.linking_number()),  # only meaningful for multi-component
        },
    )
    if detail_level <= 1:
        return rel

    rel.detailed = {
        "crossing_signs_a": list(K_a.crossing_signs),
        "crossing_signs_b": list(K_b.crossing_signs),
        "pd_code_a": [list(c) for c in K_a.pd_code],
        "pd_code_b": [list(c) for c in K_b.pd_code],
        "signs_multiset_match": (
            sorted(K_a.crossing_signs) == sorted(K_b.crossing_signs)
        ),
        "pd_code_match": K_a.pd_code == K_b.pd_code,
    }
    if detail_level <= 2:
        return rel

    inv_a = _derived_invariants(L_a)
    inv_b = _derived_invariants(L_b)
    rel.structural = {
        "seifert_matrix_a": [list(r) for r in L_a.seifert_matrix()],
        "seifert_matrix_b": [list(r) for r in L_b.seifert_matrix()],
        "signature_a": inv_a["signature"],
        "signature_b": inv_b["signature"],
        "determinant_a": inv_a["determinant"],
        "determinant_b": inv_b["determinant"],
        "seifert_genus_diagram_a": inv_a["seifert_genus_diagram"],
        "seifert_genus_diagram_b": inv_b["seifert_genus_diagram"],
        "alexander_polynomial_a": str(inv_a["alexander_polynomial"]),
        "alexander_polynomial_b": str(inv_b["alexander_polynomial"]),
        "alexander_match": (inv_a["alexander_polynomial"]
                            == inv_b["alexander_polynomial"]),
    }
    return rel
```

`_derived_invariants(L)` 见审计 §1（NumPy + SymPy 派生）。

---

## 4. `transform(K, operation)` → `TransformResult`

支持的 `operation["type"]`：

### 4.1 R1 / R2（通过 backtrack 拒绝采样）

```python
{"type": "R1", "sign": +1, "max_attempts": 50}    # +1 kink
{"type": "R2", "signs": [+1, -1], "max_attempts": 50}   # 标准 R2
```

实现：
```python
def _r1_via_backtrack(self, K, target_sign: int, max_attempts: int):
    for _ in range(max_attempts):
        L = K._link.copy()
        labels_before = {c.label for c in L.crossings}
        L.backtrack(steps=1, prob_type_1=1.0, prob_type_2=0.0)
        new = [c for c in L.crossings if c.label not in labels_before]
        if len(new) == 1 and new[0].sign == target_sign:
            return L, new
    raise RuntimeError(f"R1 with sign={target_sign} not produced in {max_attempts} attempts")
```

R2 同理。**Trace** 直接拿"new vs persistent crossings"出来：

```python
trace = TransformTrace(
    operation_name="R1",
    operation_params={"target_sign": target_sign},
    before_state={"pd_code": list(K.pd_code), "crossings": len(K.pd_code)},
    after_state={"pd_code": new_pd, "crossings": len(new_pd)},
    delta={"crossing_count_delta": len(new_pd) - len(K.pd_code),
           "writhe_delta": int(L.writhe()) - K.writhe},  # R1: ±1, R2: 0
    region_affected={
        "added_crossing_labels": [str(c.label) for c in new_crossings],
        "added_crossing_signs": [int(c.sign) for c in new_crossings],
        "persistent_crossing_labels": [c.label for c in L.crossings
                                       if c.label in labels_before],
    },
)
```

### 4.2 R3（手动 PD-code 改写）

无现成 API。第一版可以延后；如需要，实现路径：
```python
{"type": "R3", "triangle_crossings": [c_idx_1, c_idx_2, c_idx_3]}
```
找到三个共面的 crossing 形成 R3 三角形（需要遍历 PD code 找模式 → 重新连线）。**复杂度 ~2 周工程量**，建议第一版跳过。替代：用 `simplify(mode='level')` 拿"做了一些 R3"的结果（黑盒）。

### 4.3 mirror

```python
{"type": "mirror"}
```
直接 `K._link.mirror()`。所有 sign 翻转，writhe 取反。Trace 记录 `signs_before` / `signs_after`。

### 4.4 connected_sum

```python
{"type": "connected_sum", "other": K_b}  # K_b is another KnotObject
```
直接 `K._link.connected_sum(K_b._link)`。Crossing 数等于两边之和；writhe 累加。

### 4.5 simplify（"自然简化"，作为 transform 的特殊情形）

```python
{"type": "simplify", "mode": "global"}
```
直接 `K._link.simplify(mode='global')`。Trace 的 `before_state` / `after_state` 给出 PD code 差异。注意：mode='global' 会做 R1+R2+R3+pickup，是不可逆的"压扁"过程。

---

## 5. `compare(K_a, K_b, transformed_a, transform_result)` → `RelationComparison`

镜像 `surface_topology` 的 4 层 detail：

```python
def compare(self, K_a, K_b, K_a_prime, tr_result, detail_level=4) -> RelationComparison:
    pre = self.relate(K_a, K_b, detail_level=3)
    post = self.relate(K_a_prime, K_b, detail_level=3)
    cmp = RelationComparison(
        object_a_id=K_a.object_id,
        object_b_id=K_b.object_id,
        transformed_a_id=K_a_prime.object_id,
        pre=pre,
        post=post,
        summary_delta=compute_summary_delta(pre, post),
        transform_trace=tr_result.trace.to_json(),
    )
    if detail_level <= 1:
        return cmp

    # detailed: per-crossing sign 变化
    cmp.detailed_comparison = {
        "crossings_a_before": len(K_a.pd_code),
        "crossings_a_after":  len(K_a_prime.pd_code),
        "added_crossing_count": tr_result.trace.delta.get("crossing_count_delta", 0),
        "added_crossing_signs": tr_result.trace.region_affected.get(
            "added_crossing_signs", []),
        "writhe_change_a": int(K_a_prime.writhe() - K_a.writhe()),
    }
    if detail_level <= 2:
        return cmp

    # structural: 拓扑不变量是否守恒
    inv_pre = pre.structural
    inv_post = post.structural
    cmp.structural_comparison = {
        "signature_preserved": inv_pre["signature_a"] == inv_post["signature_a"],
        "determinant_preserved": inv_pre["determinant_a"] == inv_post["determinant_a"],
        "alexander_preserved": inv_pre["alexander_polynomial_a"] == inv_post["alexander_polynomial_a"],
        "writhe_change_a": int(K_a_prime.writhe() - K_a.writhe()),
    }
    return cmp
```

**关键**：`structural_comparison` 直接告诉 LLM——R-move 是否真的保持了拓扑不变量。如果 transform 是合法 R-move，预期 signature/det/Alexander 全 `True`。如果是反事实（伪 R2 同号），预期 signature/det 改变。

---

## 6. `invariants(K)` → `dict`

```python
def invariants(self, K) -> dict:
    L = K._link
    inv = _derived_invariants(L)
    return {
        "crossing_count_diagram": len(L.crossings),
        "num_components": len(L.link_components),
        "writhe": int(L.writhe()),
        "linking_number": float(L.linking_number()),
        "signature": inv["signature"],
        "determinant": inv["determinant"],
        "seifert_genus_diagram": inv["seifert_genus_diagram"],
        "alexander_polynomial": str(inv["alexander_polynomial"]),
        "is_alternating": bool(L.is_alternating()),
        "bridge_upper_bound": int(L.bridge_upper_bound()),
    }
```

---

## 7. Counterfactual 策略

镜像 `core.counterfactual.CFStrategy` 的三种：

### 7.1 `BOUNDARY_RELAXATION` — 伪 R2（同号）

合法 R2 的边界条件：两个新增 crossing 的 sign 必须是 `(+1, -1)`。
反事实：把 sign 条件放宽到 `(+1, +1)` 或 `(-1, -1)`。

实现路径（绕过 backtrack 的随机性，手写 PD code 改写）：
```python
def _build_pseudo_r2(self, K: KnotObject, edge_label: int, signs: tuple[int, int]):
    """Insert a 'fake R2' at the given edge with the given sign pair.

    The standard R2 inserts strands a→c1→c2→b with signs (+1, -1) so that
    writhe is preserved. Setting signs=(+1,+1) breaks the topological
    invariance — the resulting Link has a different signature/determinant
    than K, even though the local picture 'looks like' an R2.
    """
    pd = list(K.pd_code)
    # ... PD-code surgery: split edge, insert two new crossings with
    # specified signs by laying out (in, out) tuples. (~50 LOC)
    new_link = snappy.Link(pd_new)
    return KnotObject(...)
```

预期结果：原 K 经合法 R2 → invariants 全保留；K 经伪 R2 → signature/det 变化。

### 7.2 `CONDITION_REMOVAL` — 强制做"非法 R-move"

去掉某个 R-move 的合法性约束，比如：R1 的 kink 必须发生在"自由弧"上（弧的两端不被其他 crossing 占用）。反事实：在已经被另一个 crossing 占用的弧上插入 kink。这通常会破坏图的可平面性，`snappy.Link()` 构造时就会失败（`check_planarity=True`）。

```python
{"strategy": "CONDITION_REMOVAL", "drop": "planarity_check"}
```
实现：传 `check_planarity=False` 给 `snappy.Link()`，强行构造 *非平面* 图。看下游是否还能算 invariants（大概率 `seifert_matrix` 抛错）。

### 7.3 `OPERATION_PERTURBATION` — Crossing-flip

把一个原 crossing 的 (over, under) 互换 → 翻转该 crossing 的 sign。这不是任何合法 R-move，会改变纽结类型。

```python
{"strategy": "OPERATION_PERTURBATION", "flip_crossing_index": 1}
```
实现：把 `K.pd_code[1]` 从 `(a, b, c, d)` 改成 `(b, c, d, a)`（cyclic rotation 翻转 over/under）。预期：trefoil 的一个 crossing 翻转 → 可能变成 unknot 或 figure-8。

---

## 8. 代码组织

```
SpatialMind/domains/knot_theory/
├── __init__.py             # 已存在
├── engine.py               # KnotEngine + KnotObject + _derived_invariants
├── counterfactual.py       # KnotCounterfactualGenerator (3 策略)
├── prompts.py              # LLM prompt templates（如需要）
├── audit_snappy.md         # ✅ 已写
├── design.md               # ✅ 本文件
└── tests/
    ├── __init__.py         # 已存在
    └── test_engine.py      # 单元测试（construct/relate/transform/invariants）
```

---

## 9. 实现优先级 / 工程估算

| Item | LOC 估计 | 依赖 | 优先级 |
|------|---------|------|--------|
| `KnotObject` dataclass + `_pd_hash` | 30 | hashlib | P0 |
| `construct()` 4 路输入 | 50 | snappy | P0 |
| `_derived_invariants()` (signature/det/Alex) | 25 | numpy, sympy | P0 |
| `relate()` 3 levels | 80 | 上述 | P0 |
| `invariants()` | 20 | 上述 | P0 |
| `transform()` mirror + connected_sum + simplify | 40 | snappy | P0 |
| `transform()` R1 + R2 via backtrack rejection | 60 | snappy | P1 |
| `compare()` 3 levels | 60 | core.comparison | P1 |
| Counterfactual: OPERATION_PERTURBATION (crossing flip) | 40 | snappy | P1 |
| Counterfactual: BOUNDARY_RELAXATION (pseudo R2 PD-rewrite) | 80 | — | P2 |
| Counterfactual: CONDITION_REMOVAL (planarity off) | 20 | snappy | P2 |
| `transform()` R3 (PD-code triangle search) | 200 | — | P3（推迟） |
| Jones polynomial via Kauffman bracket | 120 | sympy | P3（可选） |
| `tests/test_engine.py` | 200 | pytest | P0 |

**P0 总计 ~ 250 LOC** — 一个晚上能写完。
**P0 + P1 ~ 480 LOC** — 含完整 R1/R2 transform + crossing-flip counterfactual。
**P0 + P1 + P2 ~ 580 LOC** — 含全部三种 counterfactual 策略，足以做 SpatialMind benchmark。

---

## 10. Open questions（写代码时确认）

1. **`object_id` 命名规范**：用 SnapPy 名（`"3_1"`）还是 PD-hash？建议有名字时用名字，匿名（PD-only 输入）用 `"pd_<sha8>"`。
2. **Multi-component links**：`linking_number` 只对 ≥ 2 components 有意义。单分量纽结要么返回 0.0，要么从 summary 里隐藏该字段。
3. **Backtrack 的随机性如何在 test 里复现**：spherogram 用全局 `random` 状态。Test 里 `random.seed(42)` 应该够。
4. **PD code 规范化**：SnapPy 的 PD code 起点/方向不唯一，同一纽结可有多个等价 PD code。`pd_code_match` 应该宽松到"diagram 等价"还是严格字符串相等？建议第一版严格相等，未来加 PD-code canonical form。
5. **Sage-fallback 公开接口**：是否暴露 "如果你装了 Sage，我会用 SnapPy 原生方法；否则用派生" 的 dual-path？建议先不做，所有用户走纯 Python 派生路径，等 Sage 用户出现再加。
