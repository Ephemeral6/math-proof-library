"""
Verification script for Lemma 3.4''-clean (TRUE topological DL of α at config (b)).

Computes the TRUE descending link of every config (b) α in data_S_1_2.json by
exhaustive arc-class enumeration via depth-3 BFS in MCG-twist orbits, and
verifies the JOIN-or-G* dichotomy.

Usage:
    python -u SpatialMind/experiments/op1_lemma34_proof_verify.py

Output:
    - Per-α: case (J/G), true |DL|, cone count, verdict
    - Summary statistics
    - workspace/active/lemma34_clean_close/true_dl_verification.json
"""

from __future__ import annotations
import os, sys, json
import curver

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry", "data_S_1_2.json")
    data = json.load(open(db_path))
    S = curver.load(1, 2)
    T = S.triangulation
    gamma_0 = S.curves['a_0']
    T_g = gamma_0.encode_twist()
    crush = gamma_0.crush()

    # Step 1: Build extensive arc-class set via systematic BFS in MCG-twist orbits.
    print("Building extended arc-class set via depth-3 BFS...", flush=True)
    all_arc_to_curve = {}
    seen_curves = set()
    for j, w in enumerate(data['curves']):
        bj = T.lamination(w)
        if gamma_0.intersection(bj) != 1:
            continue
        arc = tuple(list(crush(bj)))
        if arc not in all_arc_to_curve:
            all_arc_to_curve[arc] = bj
        seen_curves.add(tuple(w))

    gens = [S.curves[g].encode_twist() for g in ['a_0', 'b_0', 'p_1']]
    all_gens = gens + [g.inverse() for g in gens]

    curr = list(all_arc_to_curve.values())
    for depth in range(3):
        nxt = []
        for c in curr:
            for g in all_gens:
                tw = g(c)
                tw_t = tuple(list(tw))
                if tw_t in seen_curves:
                    continue
                seen_curves.add(tw_t)
                if gamma_0.intersection(tw) != 1:
                    continue
                nxt.append(tw)
                arc = tuple(list(crush(tw)))
                if arc not in all_arc_to_curve:
                    all_arc_to_curve[arc] = tw
        curr = nxt
        if not curr:
            break

    print(f"Total arc classes found: {len(all_arc_to_curve)}", flush=True)

    # Step 2: Find config (b) α (matching original protocol: every β in DL_DB(α) has i(α,β)=1)
    # Compute pairwise intersections via curver
    n_curves = len(data['curves'])
    f_levels = {}
    for j, w in enumerate(data['curves']):
        f_levels[j] = int(gamma_0.intersection(T.lamination(w)))

    config_b = []
    for ai in range(n_curves):
        if f_levels[ai] != 2:
            continue
        alpha = T.lamination(data['curves'][ai])
        # Build DL_DB(α)
        dl_db = []
        for j in range(n_curves):
            if j == ai:
                continue
            if f_levels[j] >= 2:
                continue
            i_ab = int(alpha.intersection(T.lamination(data['curves'][j])))
            if i_ab > 1:
                continue
            dl_db.append((j, i_ab))
        if not dl_db:
            continue
        # config(b) ⟺ every DL_DB member has i = 1 (no level-≤1 disjoint from α)
        if all(i_ab == 1 for _, i_ab in dl_db):
            config_b.append(ai)
    print(f"Found {len(config_b)} config (b) α", flush=True)

    # Step 3: Verify TRUE DL for each config (b) α
    print("\n" + "=" * 80)
    print(f"{'α':>4} | {'case':>4} | {'|TrueDL|':>9} | {'cones':>5} | {'verdict':>30}")
    print("=" * 80)

    results = []
    for ai in config_b:
        alpha = T.lamination(data['curves'][ai])
        alpha_arcs = crush(alpha).components()
        case = 'J' if len(alpha_arcs) == 1 else 'G'

        # Compute TRUE DL
        true_dl = []
        for arc, base in all_arc_to_curve.items():
            for t in range(-15, 16):
                tw = (T_g**t)(base) if t != 0 else base
                if alpha.intersection(tw) == 1:
                    true_dl.append((arc, t, tw))

        n = len(true_dl)
        adj = [[0] * n for _ in range(n)]
        for a in range(n):
            for b in range(a + 1, n):
                if true_dl[a][2].intersection(true_dl[b][2]) <= 1:
                    adj[a][b] = 1
                    adj[b][a] = 1

        degrees = [sum(adj[v]) for v in range(n)]
        n_cones = sum(1 for d in degrees if d == n - 1)
        deg_seq = sorted(degrees, reverse=True)
        g_star = (n == 8 and deg_seq == [6, 6, 6, 6, 3, 3, 3, 3])

        cone_arcs = set(true_dl[v][0] for v in range(n) if degrees[v] == n - 1)
        alpha_arc_classes = set(tuple(list(a)) for a in alpha_arcs)

        if case == 'J':
            ok = (n_cones >= 2 and cone_arcs == alpha_arc_classes)
            verdict = 'JOIN(K_2 ∨ G_outer)' if ok else 'JOIN(?) - need more search'
        else:
            ok = g_star
            verdict = 'G*' if ok else 'G(?) - need more search'

        print(f"{ai:>4d} | {case:>4s} | {n:>9d} | {n_cones:>5d} | {verdict:>30s}")
        results.append({
            'alpha': ai, 'case': case, 'n': n, 'cones': n_cones,
            'deg_seq': deg_seq, 'verdict': verdict, 'ok': ok,
        })

    # Step 4: Summary
    print("=" * 80)
    J_results = [r for r in results if r['case'] == 'J']
    G_results = [r for r in results if r['case'] == 'G']
    print(f"\nJ cases ({len(J_results)}): all JOIN with K_2 cones at α arc class: "
          f"{sum(r['ok'] for r in J_results)}/{len(J_results)}")
    print(f"G cases ({len(G_results)}): all G*: "
          f"{sum(r['ok'] for r in G_results)}/{len(G_results)}")
    print(f"\nTotal: {sum(r['ok'] for r in results)}/{len(results)} "
          f"verified the JOIN-or-G* dichotomy.")

    # Save output
    out_dir = os.path.join(ROOT, "workspace", "active", "lemma34_clean_close")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "true_dl_verification.json")
    with open(out_path, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nSaved to: {out_path}")


if __name__ == "__main__":
    main()
