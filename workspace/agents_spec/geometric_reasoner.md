# Geometric Reasoner — Specification

**Status**: design spec + first implementation (`SurfaceGeo`).
**Position**: a domain-pluggable layer between the discovery loop and the underlying numeric / symbolic libraries (curver, SnapPy, Sage, cdd, cvxpy, …). The Reasoner exposes a small set of *atomic spatial operations* that the v2 discovery loop can call when the current representation cannot answer the question alone. The architectural slot is "Capability 1, executable side": the registry says *which* representation to try; the Reasoner says *how to do inference inside it*.
**Related docs**:
- `lean/LeanAgent/registry/representations/SCHEMA.md` — registry schema; the Reasoner is registered via `tools_required` and (new) `transport_to[*].primitive`.
- `workspace/agents_spec/instance_sorter.md` — `verifier_command` is extended to allow structured engine calls.
- `workspace/agents_spec/explain_why_prompt.md` — `actual_evidence` is extended to allow structured JSON returned by the Reasoner.
- `workspace/agents_spec/hypothesis_tracker.md` — the Tracker fires the Discoverer; the Discoverer dispatches to a Reasoner.
- `workspace/reports/architecture/architecture_v2.md` §6 — embeds this spec into the v2 architecture.

---

## 0. Why a Reasoner, why not a tool

The v2 discovery loop already has a Verifier that runs Python scripts and a Diagnoser that classifies counterexamples by axis. Neither performs *spatial inference* — taking a coarse representation (intersection-number table, edge-weight tuple, conic certificate) and lifting it to a finer representation (arc pattern on a cut surface, normal-surface coordinates, primal-dual gap geometry) where the next operation is naturally expressible.

The OP-1 §11.8 stuck point is the canonical example: the agent has 49/49 verified `i(σ_α, β) = i(α, β)` from `direction_b_bigon_analysis.py`, but cannot lift α and σ_α back to arc patterns on `S_{1,2} \ (α ∪ γ_0)` to *prove* the equality. The numeric layer answers "what" but not "why."

A Reasoner is a Protocol with five atomic operations (§A) that close exactly this gap. Per-domain implementations (§C) wrap the existing libraries; the Protocol is what the discovery loop calls.

---

## A. Abstract Protocol

```python
from typing import Protocol, Any
from dataclasses import dataclass

# -- typed result objects --------------------------------------------------

@dataclass(frozen=True)
class Arc:
    """A single arc piece between two edges of a triangulation, possibly
    crossing intermediate triangles."""
    start_edge: int             # edge label where the arc enters
    end_edge: int               # edge label where the arc exits
    triangle_path: tuple[int, ...]   # ordered triangle labels traversed
    weight: int                 # multiplicity (≥ 1)

@dataclass(frozen=True)
class LiftedObject:
    rep_id: str                 # which fine-grained rep (registry id)
    payload: Any                # rep-specific structure (e.g. list[Arc])
    provenance: str             # "lifted from <coarse_rep_id> via <method>"

@dataclass(frozen=True)
class IncidenceData:
    """Intersection count enriched with WHERE."""
    count: int                  # the integer i(α, β)
    locations: tuple[dict, ...] # one dict per crossing: {triangle_id, edge_id, alpha_arc, beta_arc, sign?}

@dataclass(frozen=True)
class TraceData:
    """Tracing one curve through a cut configuration."""
    arcs: tuple[Arc, ...]
    cut_edges: tuple[int, ...]  # which edges were created by cutting
    invariants: dict            # rep-specific invariants preserved by the trace

@dataclass(frozen=True)
class TransformedObject:
    """Output of cut_glue."""
    result: Any                 # in the same coarse rep as the input
    diff: dict                  # what changed: edge_weights_delta, homology_shift, ...
    proof_obligation: str | None # NL description of what still needs proving

@dataclass(frozen=True)
class MatchResult:
    template_name: str
    confidence: float           # 1.0 for exact matches; < 1.0 for fuzzy
    binding: dict               # how the template's variables map onto obj's parts

# -- the Protocol ----------------------------------------------------------

class GeometricReasoner(Protocol):
    domain: str                 # one of registry/representations/ SCHEMA.md §A.1

    def list_reps(self, obj_id: str) -> list[dict]:
        """Query the registry for available representations of obj_id in this domain."""

    def lift(self, obj: Any, src_rep: str, dst_rep: str) -> LiftedObject:
        """Move from coarse rep to fine rep. The fine rep typically has more
        structure but is also more expensive to manipulate. The transport is
        executed via a registry-recorded transport_method (SCHEMA §A:transport_to)."""

    def project(self, obj: LiftedObject, dst_rep: str) -> Any:
        """Inverse of lift. Drops fine-grained structure to recover the coarse
        representation. Should be left-inverse of lift up to canonicalisation."""

    # -- the five atomic spatial operations --------------------------------

    def locate(self, obj: Any, ambient: Any) -> dict:
        """Atomic 1: place obj inside ambient. Returns position data:
        - which substructure of ambient the obj sits in
        - incidence data with named features of ambient
        Example: locate(α, S_{1,2}) returns {peripheral: False,
                  intersects: ['a_0', ...], k_value: 4, ...}"""

    def trace(self, obj: Any, path: Any, ambient: Any) -> TraceData:
        """Atomic 2: follow obj along path through ambient, recording incidence
        with everything path passes through.
        Example: trace(β, cut_along=γ_0, ambient=S_{1,2}) returns the arc
                 list of β on the cut surface S_{0,4}."""

    def cut_glue(self, obj: Any, cut_spec: dict, glue_spec: dict) -> TransformedObject:
        """Atomic 3: local rewriting that preserves ambient global type.
        cut_spec: where to cut (curves, hyperplanes, faces).
        glue_spec: how to re-glue (which sub-arc replaces which).
        Example: cut_glue(α, cut_spec={cut_along: γ_0,
                                       at_crossings: (j, j+1)},
                            glue_spec={replace_with: gamma0_subarc})
                 returns σ_α (Hatcher surgery output)."""

    def recognize(self, obj: Any, template_library: list[dict]) -> list[MatchResult]:
        """Atomic 4: pattern-match obj against named templates.
        Templates live in the registry (e.g. K_4-core, chordal, cone for OP-1;
        A_n-singularity, simplex for other domains).
        Returns 0 or more matches, ranked by confidence."""

    def count_incidence(self, obj1: Any, obj2: Any, ambient: Any) -> IncidenceData:
        """Atomic 5: enriched intersection number — not just i(α,β)=1, but
        WHERE (which triangle, which edge, which arc-segment of each).
        This is what curver's c.intersection(c') does NOT give."""
```

### A.1 Why these five

The cross-domain table in `architecture_v2.md` §6 (and the analytical writeup that produced this spec) shows that *every* spatial-reasoning bottleneck the system has hit decomposes into a sequence of these five operations. **Locate** and **trace** are the ones the system completely lacks today; the existing tools (curver, cvxpy) implement **count_incidence** but only in the unenriched form, and **recognize** lives only inside ad-hoc Python scripts (`analyze_no_universal.py`, etc.).

`cut_glue` is the operation that *generates* a new geometric object from old ones (Hatcher surgery, blow-up, normal-surface decomposition). Without it the agent is restricted to objects that already exist in its data files.

---

## B. Typed I/O — what each op delivers beyond the libraries

This section spells out, per atomic op, what the Reasoner adds on top of the underlying library's raw output.

### B.1 lift / project

| Aspect | Today (no Reasoner) | With Reasoner |
|---|---|---|
| Input | curver lamination | curver lamination + `src_rep="rep_intersection_table"` + `dst_rep="rep_arc_pattern"` |
| Output | edge-weight tuple | `LiftedObject(rep_id="rep_arc_pattern", payload=list[Arc], provenance="Bonahon train-track decomposition on S_{1,2}.triangulation")` |
| Invertibility | n/a | guaranteed: `project(lift(x))` returns the canonical form of `x` |
| Registry effect | none | the lift operation is recorded with the `transport_lemma` field (SCHEMA §A) |

### B.2 locate

| Input | An `obj` and an `ambient` (both rep-aware). |
|---|---|
| Output | `dict` with at least `{positional_features, named_intersections, scalar_invariants}` |
| Beyond library | curver tells you `i(α, β) = 1`; locate tells you "α is at level k=4 with respect to γ_0, has homology class (4, 1, 2) in basis (a_0, b_0, p_1), and is non-peripheral." This is the pre-conditioning data the explain-why prompt's seed phase needs. |

### B.3 trace

The lemma is: given β and a cut configuration `(α, γ_0)`, the trace of β on the cut surface uniquely determines β up to isotopy. This is what curver's `c.intersection` *cannot* express — it returns a count, not a path.

| Input | `(obj=β, path={cut_along: [α, γ_0]}, ambient=S_{1,2})` |
|---|---|
| Output | `TraceData(arcs=(Arc(...), Arc(...), ...), cut_edges=(...), invariants={'genus_post_cut': 0, 'punctures_post_cut': 4})` |
| Beyond library | curver reports a single integer; trace reports the explicit arc decomposition that *justifies* the integer. The agent can then reason about each arc independently (e.g. "this arc cannot acquire new β-intersections under surgery because it lies in a triangle disjoint from the surgery region"). |

### B.4 cut_glue

| Input | `(obj=α, cut_spec={cut_along: γ_0, at_crossings: (j, j+1)}, glue_spec={replace_with: gamma0_subarc, side: 'positive'})` |
|---|---|
| Output | `TransformedObject(result=<curver lamination σ_α>, diff={'edge_weights_delta': (-2, 0, 0, ...), 'homology_shift': (-2, 0, 0)}, proof_obligation="bigon cancellation between σ_α and β is total when i(α, β) ∈ {0, 1}")` |
| Beyond library | curver has no surgery operation; this constructs σ_α from train-track data and returns BOTH a curver lamination (for downstream `c.intersection` checks) AND a structured diff (for the explain-why prompt to consume). |

### B.5 recognize

| Input | `(obj=DL_graph, template_library=[K4_core_template, chordal_template, cone_template])` |
|---|---|
| Output | `list[MatchResult]`, each with `confidence ∈ [0, 1]` |
| Beyond library | networkx tells you "this graph has 8 vertices and 13 edges"; recognize tells you "this is a K_4-core counterexample (confidence 1.0, binding K_4 → vertices [3, 7, 11, 14], leaves → [4, 5, 6, 8])." Templates are stored in the registry; new templates added when new structural patterns emerge. |

### B.6 count_incidence (enriched)

| Input | `(obj1=α, obj2=β, ambient=S_{1,2})` |
|---|---|
| Output | `IncidenceData(count=1, locations=({'triangle_id': 3, 'edge_id': 5, 'alpha_arc': Arc(2, 5, (3,)), 'beta_arc': Arc(5, 8, (3,))},))` |
| Beyond library | curver returns the integer 1; this returns the integer 1 *plus* the location data needed to determine whether the crossing is preserved by a downstream surgery. |

---

## C. Per-domain implementation sketches

Five engines, one Protocol. Each engine is a thin wrapper over its native library plus the bookkeeping needed to deliver typed Reasoner outputs.

### C.1 SurfaceGeo (low-dim topology) — implemented

Status: first implementation. See `workspace/projects/op1_geometry/surface_geo.py`.

Library: `curver 0.5.1` (`S = curver.load(g, n)`, `S.triangulation`, `S.curves`, `S.lamination`).

```python
class SurfaceGeo:
    domain = "geometric_topology"

    def lift(self, lamination, src="rep_intersection_table", dst="rep_arc_pattern"):
        # Bonahon decomposition: for each triangle (a, b, c), passage counts
        #   n_{ab} = max(0, (w_a + w_b - w_c) / 2)
        # are non-negative integers; arcs are obtained by gluing passages
        # across edge identifications.
        ...

    def trace(self, beta, cut_along, ambient):
        # 1. Compute the cut triangulation (Bonahon: cutting along γ adds
        #    boundary edges for each γ-crossing of the original triangulation).
        # 2. Re-decompose β on the cut triangulation.
        # 3. Group arcs by their endpoints on the cut boundary.
        ...

    def cut_glue(self, alpha, cut_spec, glue_spec):
        # Hatcher surgery: replace alpha-subarc between p_j, p_{j+1} (two
        # adjacent γ_0-crossings of α) by the γ_0-subarc connecting them.
        # Implemented by editing the train-track edge weights directly.
        ...

    def recognize(self, dl_graph, template_library):
        # K_4-core, chordal, cone, W4-fillable, ... — graph templates with
        # bindings.
        ...

    def count_incidence(self, alpha, beta, ambient):
        # curver gives the count; we additionally walk the train track to
        # locate each crossing.
        ...
```

### C.2 ThreeManifoldGeo — sketch

Status: not implemented. Phase 3.

Library: `SnapPy` (triangulations, Dehn fillings) + `Regina` (normal surfaces).

```python
class ThreeManifoldGeo:
    domain = "geometric_topology"   # shares the domain bucket with SurfaceGeo

    def lift(self, manifold, src="rep_triangulation", dst="rep_normal_surface_coords"):
        # Tetrahedron-by-tetrahedron quad/triangle coordinates from Regina.
        ...
    def cut_glue(self, manifold, cut_spec, glue_spec):
        # Dehn surgery: cut a tubular nbhd of a knot, glue back with new slope.
        ...
    def recognize(self, M, template_library):
        # Hyperbolic / Seifert / graph manifold; JSJ pieces; named census.
        ...
    # locate / trace / count_incidence: tetrahedron incidence on normal surfaces
```

### C.3 AlgebraicSurfaceGeo — sketch

Status: not implemented. Phase 3.

Library: `SageMath` (`Schemes`, `EllipticCurve`, divisor arithmetic).

```python
class AlgebraicSurfaceGeo:
    domain = "algebraic_geometry"

    def lift(self, divisor_class, src="rep_picard", dst="rep_explicit_curve"):
        # From a class in Pic(X) to an explicit defining equation, when
        # the linear system is non-empty. May fail (returns None) if
        # base-point-free is not satisfied.
        ...
    def cut_glue(self, X, cut_spec, glue_spec):
        # Blow-up at a point: produces X' with exceptional divisor E,
        # E^2 = -1.
        ...
    def count_incidence(self, D1, D2, X):
        # (D_1 . D_2) on Pic(X), with locations = list of intersection points
        # with multiplicities.
        ...
```

### C.4 PolytopeGeo — sketch

Status: not implemented. Phase 3.

Library: `cdd` + `lrs` (V↔H representation), `polytope` Python wrapper.

```python
class PolytopeGeo:
    domain = "combinatorial_geometry"   # new domain — extend SCHEMA §A.1

    def lift(self, P, src="rep_h_polytope", dst="rep_v_polytope"):
        # cdd's H-to-V conversion.
        ...
    def trace(self, vertex, path="edge_walk", ambient=P):
        # Pivot rule: walk along edges of the polytope graph, recording
        # active-set transitions.
        ...
    def cut_glue(self, P, cut_spec, glue_spec):
        # Hyperplane cut + facet identification (used in projection / Schlegel).
        ...
```

### C.5 OptimizationGeo — sketch

Status: not implemented. Phase 3.

Library: `cvxpy` + `scipy.optimize`.

```python
class OptimizationGeo:
    domain = "optimization"

    def lift(self, problem, src="rep_algebraic_KKT", dst="rep_geometric_active_set"):
        # KKT system → cone of feasible directions at current iterate.
        ...
    def trace(self, x0, path="projected_gradient_flow", ambient=problem):
        # Numerical ODE on the projected gradient flow; record active-set
        # transitions.
        ...
    def cut_glue(self, problem, cut_spec, glue_spec):
        # Constraint activation/release; lifts to a different active-set
        # geometry.
        ...
```

---

## D. Integration with the existing v2 system

### D.1 Where the Reasoner is called

The Discoverer (SCHEMA §D) is the dispatcher. The flow:

```
Tracker (hypothesis_tracker.md §C.1) detects "rep too restrictive"
   ↓
Discoverer (SCHEMA.md §D) ranks alternative reps; the top candidate's
   transport_to[*].primitive field names (engine, op, args_template)
   ↓
Orchestrator constructs the actual call:
   engine = registry_to_engine_map[primitive.engine]
   result = getattr(engine, primitive.op)(**bound_args)
   ↓
result is written into State.test_plan[step].actual_evidence as a
   structured JSON (instance_sorter.md §A; new: structured-evidence path)
   ↓
explain_why_prompt.md §A consumes the structured evidence; candidate_property
   features can now reference Arc objects, IncidenceData.locations, etc.
   ↓
Tracker continues normally — WH lifecycle is unchanged.
```

### D.2 What changes in the existing files

Three minimal edits to existing specs (the engine itself is a new, additive layer):

1. **`SCHEMA.md` §A** — add an optional `primitive` sub-object to each `transport_to` edge:

   ```jsonc
   "transport_to": [{
     "target_rep_id": "rep_NEW_arc_pattern_S_{g,n}",
     "transport_method": "Bonahon train-track decomposition + Hatcher surgery",
     "transport_lemma": null,
     "cost": "moderate",
     "bidirectional": true,
     "loss": "lossless",
     "primitive": {                          // NEW (optional)
       "engine": "SurfaceGeo",
       "op": "cut_glue",
       "args_template": {
         "obj": "$alpha", "cut_spec": {"cut_along": "$gamma0", "at_crossings": "$pair"},
         "glue_spec": {"replace_with": "gamma0_subarc"}
       }
     }
   }]
   ```

2. **`instance_sorter.md` §A** — `verifier_command` may now be a structured object:

   ```jsonc
   "verifier_command": {
     "kind": "engine_call",
     "engine": "SurfaceGeo",
     "op": "count_incidence",
     "kwargs": {"obj1": "alpha_curve", "obj2": "beta_curve", "ambient": "S_{1,2}"}
   }
   ```

   Backward-compatible: a string `verifier_command` is still treated as a CLI invocation (current behaviour); a dict triggers the engine dispatch path.

3. **`explain_why_prompt.md` §A.0** — `actual_evidence` may be a JSON object rather than a string. The prompt template renders it as ASCII (per-Arc table, per-MatchResult bullet list) before showing it to the LLM.

`hypothesis_tracker.md` requires no changes — it treats `actual_evidence` as opaque payload (§B.2 line 199).

### D.3 Registry updates required for OP-1

To unblock OP-1 §11.8 stuck point, add three rep entries (hand-written, `discovered_via: human`):

- `rep_NEW1_arc_pattern_S_{g,n}_cut_along_alpha_gamma0` — the cut-surface arc representation.
- `rep_NEW2_hatcher_surgery_output` — σ_α as a TransformedObject.
- `rep_NEW3_enriched_intersection_data` — IncidenceData.locations.

Each declares `tools_required` against `SurfaceGeo` primitives. The Discoverer's filter (SCHEMA §D.3 step 3) now passes them only when SurfaceGeo is registered as an available engine.

---

## E. Routing — which engine does the agent call

Two viable routing strategies. Pick **strategy 2** (registry-driven).

### Strategy 1 — Domain-direct routing

```python
ENGINES_BY_DOMAIN = {
    "geometric_topology": [SurfaceGeo, ThreeManifoldGeo],
    "algebraic_geometry": [AlgebraicSurfaceGeo],
    "combinatorial_geometry": [PolytopeGeo],
    "optimization": [OptimizationGeo],
}

engine = ENGINES_BY_DOMAIN[conjecture.domain][0]
```

- **Pro**: simple, no registry coupling.
- **Con**: ties the agent's tool choice to the conjecture's `domain` field, which is a coarse classification. Several domains have multiple engines (geometric_topology has both SurfaceGeo and ThreeManifoldGeo); this strategy picks the first one and offers no introspection.

### Strategy 2 — Registry-driven routing (recommended)

The rep entry's `tools_required` field already names the primitives the agent needs (e.g. `["surface_geo.cut_glue", "surface_geo.trace"]`). The Discoverer maps each `tools_required` token to an `(engine, op)` tuple via a single `engine_inventory.json`:

```jsonc
// lean/LeanAgent/registry/representations/engine_inventory.json
{
  "SurfaceGeo": {
    "module": "workspace.projects.op1_geometry.surface_geo",
    "ops": ["lift", "project", "locate", "trace", "cut_glue", "recognize", "count_incidence"],
    "tools_required_aliases": ["surface_geo.lift", "surface_geo.cut_glue", ...]
  },
  "ThreeManifoldGeo": { ... },
  ...
}
```

The Discoverer's ranking (SCHEMA §D.3) uses this inventory to drop reps whose `tools_required` is unsatisfiable (`tools_status: missing`). When a rep is ranked at the top, its `transport_to[*].primitive` (§D.2 above) names the exact `(engine, op, kwargs)` to call.

- **Pro**: registry-coherent — the same data drives Discoverer ranking AND engine dispatch. New engines / new ops become available the moment the inventory is updated; no Python changes elsewhere.
- **Pro**: cross-domain calls work naturally. A rep that lifts from `geometric_topology` to `algebraic_geometry` (via, say, a curve's homology class) just lists primitives from both engines; the orchestrator dispatches to each in sequence.
- **Con**: one extra indirection. Mitigated by the fact that the inventory is a small flat JSON.

**Recommendation: Strategy 2.** It makes the engine layer a *pluggable* extension to the registry rather than a parallel routing system.

---

## F. Validation requirements

Each new engine ships with a validation set: a list of `(input, expected_output)` pairs the engine must reproduce. For SurfaceGeo, the validation set is OP-1's existing data:

- `count_incidence` outputs must agree with curver's `c.intersection(c')` on all 49 (α, β) pairs from `direction_b_bigon_analysis.py`.
- `cut_glue` (Hatcher surgery) outputs must reproduce the canonical filler σ_α for each of the 12 non-chordal S_{1,2} cases (matching `direction_b_sigma_intersection_profile.py`).
- `recognize` must classify the 6 S_{2,1} k=2 non-chordal-non-cone DLs as "neither chordal nor cone" with confidence 1.0.

Failure of any validation case blocks the engine from being used by the discovery loop. (The orchestrator reads each engine's `validation_results.json` at startup.)

---

## G. Out of scope

- **Cross-engine planning**: a single proof that needs SurfaceGeo *and* AlgebraicSurfaceGeo (e.g. interpreting a topological surgery as a blow-up). Not supported in v1; would require a planner above the Reasoner layer.
- **Backwards transport from fine to coarse with non-canonical loss**: e.g. forgetting which arcs a lamination decomposes into. The `project` op assumes lossless or canonical loss; non-canonical projections (like collapsing a homotopy class to a free-group element via Stallings folding) need a separate primitive.
- **Symbolic-numeric handoff**: when an engine output is approximate (e.g. SnapPy's hyperbolic structure to 12 decimal places), the Verifier still needs a separate exact check before any conclusion is recorded as `EXACT` qualifier (SCHEMA §A.3). The Reasoner's outputs carry their own `verification_qualifier` field for this.
- **Engine-internal optimization**: MCG-word search inside SurfaceGeo, normal-surface enumeration inside ThreeManifoldGeo, etc., have their own complexity profiles. The Reasoner exposes them as opaque calls; performance tuning is each engine's responsibility.

---

## H. Implementation footprint

| Engine | Status | Primitives implemented | Estimated LOC |
|---|---|---|---|
| SurfaceGeo | first impl | `lift`, `trace`, `cut_glue` (heuristic), `recognize`, `count_incidence` | ~600 |
| ThreeManifoldGeo | sketch | — | ~600–800 |
| AlgebraicSurfaceGeo | sketch | — | ~400–600 |
| PolytopeGeo | sketch | — | ~300–400 |
| OptimizationGeo | sketch | — | ~300 |
| Protocol + dispatcher | this doc | — | ~150 |

**Total to close OP-1 §11.8**: SurfaceGeo + dispatcher = ~750 LOC. **Total for the Phase-3 cross-domain story**: ~3000 LOC over five engines.

The Protocol itself is small. The cost is in the per-domain wrappers, each of which is a 1–2 week project for someone familiar with the underlying library.
