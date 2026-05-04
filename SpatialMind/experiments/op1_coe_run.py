"""CoE-framework exploration for OP-1 (descending-link contractibility).

Uses the SurfaceTopologyEngine + a precomputed pairwise-intersection cache
to make the C-axis sweep tractable.

  R) Generate α curves, compute Lk↓(α), test chordal / cone / PEO /
     dismantlability across ALL levels in the curve database.
  T) Run hatcher_surgery on selected α and compare DL(α) vs DL(σ_α).
  C) Per-level full classification {chordal_only, cone_only, both, neither}
     up to a level cap, plus a list of any "neither" α (potential
     counterexamples to a chordal-or-cone dichotomy).

Outputs JSON to SpatialMind/experiments/op1_coe_data.json.
"""

from __future__ import annotations

import json
import os
import sys
import time
from collections import Counter, defaultdict
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.domains.surface_topology.engine import SurfaceEngine


# ============================================================================
# Pairwise intersection cache.
# ============================================================================

class IntersectionCache:
    """Precompute and cache i(c_a, c_b) for all pairs of curves in the
    engine's database. Also caches f(c) = i(γ_0, c).
    """
    def __init__(self, eng):
        self.eng = eng
        curves = eng._db["curves"]
        self.n = len(curves)
        self.f = [int(eng.S.curves["a_0"].intersection(c)) for c in curves]
        # Pairwise: list of dicts; M[i][j] for j > i.
        self.M = [dict() for _ in range(self.n)]

    def i(self, a, b):
        if a == b:
            return 0
        if a > b:
            a, b = b, a
        v = self.M[a].get(b)
        if v is None:
            curves = self.eng._db["curves"]
            v = int(curves[a].intersection(curves[b]))
            self.M[a][b] = v
        return v

    def precompute_all(self):
        curves = self.eng._db["curves"]
        for a in range(self.n):
            for b in range(a + 1, self.n):
                if b not in self.M[a]:
                    self.M[a][b] = int(curves[a].intersection(curves[b]))


# ============================================================================
# DL builder (uses cache).
# ============================================================================

def build_descending_link(cache, alpha_idx):
    f = cache.f
    k = f[alpha_idx]
    DL = []
    for j in range(cache.n):
        if j == alpha_idx:
            continue
        if f[j] >= k:
            continue
        if cache.i(alpha_idx, j) > 1:
            continue
        DL.append(j)
    adj = {j: set() for j in DL}
    for a, b in combinations(DL, 2):
        if cache.i(a, b) <= 1:
            adj[a].add(b)
            adj[b].add(a)
    return DL, adj


# ============================================================================
# Graph predicates.
# ============================================================================

def has_cone_vertex(verts, adj):
    if not verts:
        return None
    n = len(verts)
    for v in verts:
        if len(adj[v]) == n - 1:
            return v
    return None


def is_chordal_peo(verts, adj):
    if not verts:
        return True, []
    weight = {v: 0 for v in verts}
    order = []
    remaining = set(verts)
    while remaining:
        v = max(remaining, key=lambda x: weight[x])
        order.append(v)
        remaining.remove(v)
        for u in adj[v] & remaining:
            weight[u] += 1
    pos = {v: i for i, v in enumerate(order)}
    for i, v in enumerate(order):
        earlier_neighbours = [u for u in adj[v] if pos[u] < i]
        for a, b in combinations(earlier_neighbours, 2):
            if b not in adj[a]:
                return False, None
    return True, list(reversed(order))


def is_dismantlable(verts, adj):
    if not verts:
        return True
    V = set(verts)
    A = {v: set(adj[v]) for v in verts}
    while len(V) > 1:
        progress = False
        for u in list(V):
            Nu = A[u] | {u}
            for v in V:
                if v == u:
                    continue
                Nv = A[v] | {v}
                if Nu <= Nv:
                    V.remove(u)
                    for w in A[u]:
                        A[w].discard(u)
                    A.pop(u)
                    progress = True
                    break
            if progress:
                break
        if not progress:
            return False
    return True


def detect_induced_cycles(verts, adj, max_len=5, max_cycles=2):
    cycles = []
    V = set(verts)
    visit_budget = 4000
    for start in verts:
        if len(cycles) >= max_cycles:
            break
        stack = [(start, [start])]
        budget = visit_budget
        while stack and budget > 0:
            budget -= 1
            cur, path = stack.pop()
            if len(path) > max_len:
                continue
            for nb in adj[cur]:
                if nb == start and len(path) >= 4:
                    induced = True
                    L = len(path)
                    for i in range(L):
                        for j in range(i + 2, L):
                            if (i == 0 and j == L - 1):
                                continue
                            if path[j] in adj[path[i]]:
                                induced = False
                                break
                        if not induced:
                            break
                    if induced:
                        cycles.append(list(path))
                        if len(cycles) >= max_cycles:
                            break
                elif nb not in path and nb in V and nb > start:
                    stack.append((nb, path + [nb]))
            if len(cycles) >= max_cycles:
                break
    return cycles


# ============================================================================
# R-axis: per-level structural sweep on all α (cap-controlled sample).
# ============================================================================

def r_axis_structural_sweep(cache, surface_label, level_cap=None,
                            max_per_level=None):
    f = cache.f
    by_level = defaultdict(list)
    for idx in range(cache.n):
        if f[idx] < 2:
            continue
        if level_cap is not None and f[idx] > level_cap:
            continue
        by_level[f[idx]].append(idx)

    rows = []
    for k in sorted(by_level):
        idxs = by_level[k] if max_per_level is None else by_level[k][:max_per_level]
        for idx in idxs:
            verts, adj = build_descending_link(cache, idx)
            if not verts:
                rows.append({
                    "surface": surface_label, "alpha_idx": idx, "level": k,
                    "DL_size": 0, "empty_DL": True,
                })
                continue
            n = len(verts)
            n_edges = sum(len(adj[v]) for v in verts) // 2
            cone = has_cone_vertex(verts, adj)
            chordal, _ = is_chordal_peo(verts, adj)
            disman = is_dismantlable(verts, adj)
            rows.append({
                "surface": surface_label, "alpha_idx": idx, "level": k,
                "DL_size": n, "DL_edges": n_edges,
                "max_degree": max(len(adj[v]) for v in verts),
                "min_degree": min(len(adj[v]) for v in verts),
                "cone_vertex": cone,
                "chordal": chordal,
                "dismantlable": disman,
            })
    return rows


# ============================================================================
# T-axis: surgery → DL transformation.
# ============================================================================

def t_axis_surgery_dl(eng, cache, surface_label, alpha_indices):
    rows = []
    for idx in alpha_indices:
        if cache.f[idx] < 2:
            continue
        alpha_obj = eng.construct({"surface": [eng.g, eng.n], "curve_index": idx})
        try:
            tr = eng.transform(alpha_obj, {"type": "hatcher_surgery", "gamma0": "a_0"})
        except Exception as e:
            rows.append({
                "surface": surface_label, "alpha_idx": idx, "level": cache.f[idx],
                "surgery_status": f"undefined: {type(e).__name__}",
            })
            continue
        sigma_weights = tuple(tr.trace.after_state["sigma_weights"])
        sigma_idx = None
        for j, h in enumerate(eng._db["hashes"]):
            if h == sigma_weights:
                sigma_idx = j; break
        if sigma_idx is None:
            rows.append({
                "surface": surface_label, "alpha_idx": idx, "level": cache.f[idx],
                "surgery_status": "sigma not in DB",
                "level_sigma": tr.trace.after_state["level_sigma"],
            })
            continue
        verts_a, adj_a = build_descending_link(cache, idx)
        verts_s, adj_s = build_descending_link(cache, sigma_idx)
        rows.append({
            "surface": surface_label, "alpha_idx": idx, "sigma_idx": sigma_idx,
            "level_alpha": cache.f[idx], "level_sigma": cache.f[sigma_idx],
            "DL_alpha_size": len(verts_a), "DL_sigma_size": len(verts_s),
            "DL_alpha_chordal": is_chordal_peo(verts_a, adj_a)[0] if verts_a else True,
            "DL_sigma_chordal": is_chordal_peo(verts_s, adj_s)[0] if verts_s else True,
            "DL_alpha_dismantlable": is_dismantlable(verts_a, adj_a) if verts_a else True,
            "DL_sigma_dismantlable": is_dismantlable(verts_s, adj_s) if verts_s else True,
            "DL_alpha_has_cone": has_cone_vertex(verts_a, adj_a),
            "DL_sigma_has_cone": has_cone_vertex(verts_s, adj_s),
            "alpha_in_DL_sigma": idx in verts_s,
            "sigma_in_DL_alpha": sigma_idx in verts_a,
        })
    return rows


# ============================================================================
# C-axis: full classification per level.
# ============================================================================

def c_axis_full_classify(cache, surface_label, level_cap):
    f = cache.f
    counts = {}
    findings_neither = []
    for idx in range(cache.n):
        if f[idx] < 2 or f[idx] > level_cap:
            continue
        verts, adj = build_descending_link(cache, idx)
        if not verts:
            continue
        chordal, _ = is_chordal_peo(verts, adj)
        cone = has_cone_vertex(verts, adj)
        bucket = counts.setdefault(f[idx], {
            "total": 0, "chordal": 0, "has_cone": 0,
            "chordal_only": 0, "cone_only": 0, "both": 0, "neither": 0,
            "dismantlable": 0,
            "neither_witnesses": [],
            "DL_size_min": None, "DL_size_max": None,
        })
        bucket["total"] += 1
        if chordal: bucket["chordal"] += 1
        if cone is not None: bucket["has_cone"] += 1
        if chordal and cone is None: bucket["chordal_only"] += 1
        elif (not chordal) and cone is not None: bucket["cone_only"] += 1
        elif chordal and cone is not None: bucket["both"] += 1
        else: bucket["neither"] += 1
        if is_dismantlable(verts, adj): bucket["dismantlable"] += 1
        ns = len(verts)
        if bucket["DL_size_min"] is None or ns < bucket["DL_size_min"]:
            bucket["DL_size_min"] = ns
        if bucket["DL_size_max"] is None or ns > bucket["DL_size_max"]:
            bucket["DL_size_max"] = ns
        if (not chordal) and cone is None:
            cycles = detect_induced_cycles(verts, adj, max_len=5, max_cycles=1)
            findings_neither.append({
                "surface": surface_label, "alpha_idx": idx, "level": f[idx],
                "DL_size": ns, "induced_cycle_witness": cycles[0] if cycles else None,
                "dismantlable": is_dismantlable(verts, adj),
            })
            if len(bucket["neither_witnesses"]) < 5:
                bucket["neither_witnesses"].append(idx)
    return {"by_level": counts, "neither_alphas": findings_neither}


# ============================================================================
# Driver.
# ============================================================================

def main():
    out = {"r_axis": {}, "t_axis": {}, "c_axis": {}, "summary": {}}
    db_root = os.path.join(ROOT, "workspace", "projects", "op1_geometry")

    surfaces = [
        ("S_1_2", 1, 2, os.path.join(db_root, "data_S_1_2.json"), 5),
        ("S_1_1", 1, 1, os.path.join(db_root, "data_S_1_1.json"), 5),
        ("S_2_1", 2, 1, os.path.join(db_root, "data_S_2_1.json"), 4),
    ]

    for label, g, n, path, c_cap in surfaces:
        print(f"\n=== {label} (g={g}, n={n}) ===", flush=True)
        eng = SurfaceEngine(g, n, database_path=path)
        cache = IntersectionCache(eng)
        print(f"  cache initialized (lazy), {cache.n} curves", flush=True)

        # R-axis (sample to keep runtime sane; also covers high-level α)
        t0 = time.time()
        rows = r_axis_structural_sweep(cache, label, level_cap=None,
                                        max_per_level=8)
        out["r_axis"][label] = rows
        print(f"  R-axis: {len(rows)} samples in {time.time() - t0:.1f}s", flush=True)

        # Per-level summary
        levels = defaultdict(list)
        for r in rows:
            if r.get("empty_DL"):
                continue
            levels[r["level"]].append(r)
        per_level = {}
        for k, lst in sorted(levels.items()):
            per_level[k] = {
                "count": len(lst),
                "all_chordal": all(r["chordal"] for r in lst),
                "any_chordal": any(r["chordal"] for r in lst),
                "n_chordal": sum(1 for r in lst if r["chordal"]),
                "all_have_cone": all(r["cone_vertex"] is not None for r in lst),
                "n_with_cone": sum(1 for r in lst if r["cone_vertex"] is not None),
                "all_dismantlable": all(r["dismantlable"] for r in lst),
                "n_dismantlable": sum(1 for r in lst if r["dismantlable"]),
                "min_DL_size": min(r["DL_size"] for r in lst),
                "max_DL_size": max(r["DL_size"] for r in lst),
            }
        out["summary"][f"{label}_per_level"] = per_level

        # T-axis: pick a sample per level
        sample_idxs = []
        seen_level = set()
        for idx in range(cache.n):
            if 2 <= cache.f[idx] <= 8 and cache.f[idx] not in seen_level:
                sample_idxs.append(idx); seen_level.add(cache.f[idx])
            if len(sample_idxs) >= 7:
                break
        high_idxs = [i for i, v in enumerate(cache.f) if v >= 10][:3]
        sample_idxs.extend(high_idxs)
        t0 = time.time()
        t_rows = t_axis_surgery_dl(eng, cache, label, sample_idxs)
        out["t_axis"][label] = t_rows
        print(f"  T-axis: {len(t_rows)} surgeries in {time.time() - t0:.1f}s", flush=True)

        # C-axis
        t0 = time.time()
        c_rows = c_axis_full_classify(cache, label, level_cap=c_cap)
        out["c_axis"][label] = c_rows
        n_neither = len(c_rows["neither_alphas"])
        print(f"  C-axis: levels 2..{c_cap}, {n_neither} α with neither chordal nor cone, "
              f"{time.time() - t0:.1f}s", flush=True)

    out_path = os.path.join(os.path.dirname(__file__), "op1_coe_data.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
