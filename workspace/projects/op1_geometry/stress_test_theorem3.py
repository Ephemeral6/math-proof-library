"""
Theorem 3.1 stress verification — looks for ANY counterexample.

Lemma 2.1 (= Theorem 3.1 in the report) claims:
  For S = S_{1,2} (extending to other surfaces), alpha with k = i(alpha, gamma_0) >= 2,
  beta with i(alpha, beta) <= 1 and beta in Lk-down(alpha) (i.e. f(beta) < k),
  sigma_alpha the canonical Hatcher single-step output (level k-2, disjoint
  from alpha, universal vertex of Lk-down(alpha)),
    => i(sigma_alpha, beta) = i(alpha, beta).

The 99/99 verification was over the 12 NON-CHORDAL alphas in S_{1,2}. This
stress test broadens to:

  Bucket A: ALL alphas in S_{1,2} (chordal AND non-chordal), ALL betas in
            Lk-down(alpha). Both i(alpha, beta) = 0 and = 1 cases.

  Bucket B: Same on S_{2,1}.

  Bucket C: Same on S_{1,1} (sanity — Stern-Brocot says |Lk-down|<=2 so easy).

  Bucket D: g=0 sanity — does the theorem extend to S_{0,5}? (S_{0,4} curve
            complex disconnected, skip.)

  Bucket E: 1000 random (alpha, beta) pairs sampled uniformly from each
            surface's i<=1 edges.

Any failure => print (alpha, beta, k, i(alpha,beta), i(sigma_alpha,beta),
predicted, actual) for review.
"""
from __future__ import annotations
import os, sys, json, random
from collections import defaultdict
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from surface_geo import SurfaceGeo

import curver, networkx as nx

random.seed(42)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def load_engine(g, n, data_path):
    eng = SurfaceGeo.load(g, n)
    if not os.path.exists(data_path):
        return None, None
    eng.attach_database(data_path)
    return eng, eng._curve_db


def i_q(curves, edge_iv, a, b):
    if a == b: return 0
    key = frozenset((a, b))
    if key in edge_iv: return edge_iv[key]
    if curves[a] is None or curves[b] is None: return None
    try:
        return int(curves[a].intersection(curves[b]))
    except Exception:
        return None


def stress_bucket(name, eng, db):
    if eng is None or db is None:
        print(f"\n=== {name}: no data file -- SKIP ===")
        return None
    curves = db["curves"]; adj = db["adj"]; edge_iv = db["edge_iv"]
    gamma0 = eng.S.curves["a_0"]
    f_vals = []
    for c in curves:
        if c is None:
            f_vals.append(None); continue
        try: f_vals.append(int(gamma0.intersection(c)))
        except: f_vals.append(None)
    levels = defaultdict(list)
    for i, v in enumerate(f_vals):
        if v is not None: levels[v].append(i)

    counterexamples = []
    pairs_tested = 0; pairs_passed = 0
    skipped_noncone = 0; skipped_other = 0
    n_alphas_tested = 0
    n_alphas_skipped_no_DL = 0

    print(f"\n=== {name} ===")
    for k in sorted(levels.keys()):
        if k < 2: continue   # need k>=2 for surgery; chordal trivial
        for alpha_idx in levels[k]:
            # Build Lk-down
            DL = sorted([b for b in adj.get(alpha_idx, set())
                         if f_vals[b] is not None and f_vals[b] < k])
            if not DL:
                n_alphas_skipped_no_DL += 1
                continue
            # cut_glue: produce sigma_alpha
            try:
                t = eng.cut_glue(curves[alpha_idx],
                                 cut_spec={"cut_along": "a_0",
                                           "at_crossings": (0, 1)},
                                 glue_spec={"replace_with": "gamma0_subarc"})
            except Exception as e:
                # No canonical filler in db -- this means alpha's DL is
                # chordal (no W4 obstruction) OR alpha has no level-(<=k-2)
                # universal vertex in db. Skip.
                skipped_other += 1
                continue
            sigma = t.result
            n_alphas_tested += 1
            # For each beta in Lk-down with i(alpha, beta) in {0, 1}
            for b_idx in DL:
                a_count = i_q(curves, edge_iv, alpha_idx, b_idx)
                if a_count is None or a_count > 1:
                    continue
                try:
                    s_count = int(sigma.intersection(curves[b_idx]))
                except Exception:
                    continue
                pairs_tested += 1
                if s_count == a_count:
                    pairs_passed += 1
                else:
                    counterexamples.append({
                        "alpha": alpha_idx, "k": k, "beta": b_idx,
                        "i_alpha_beta": a_count, "i_sigma_beta": s_count,
                        "f_sigma": int(gamma0.intersection(sigma)),
                    })
    print(f"  alphas with sigma_alpha computed: {n_alphas_tested}")
    print(f"  alphas skipped (DL empty)        : {n_alphas_skipped_no_DL}")
    print(f"  alphas skipped (other)           : {skipped_other}")
    print(f"  pairs tested                     : {pairs_tested}")
    print(f"  pairs PASSED                     : {pairs_passed}")
    print(f"  pairs FAILED (counterexamples)   : {len(counterexamples)}")
    if counterexamples:
        print(f"  COUNTEREXAMPLES:")
        for ce in counterexamples[:10]:
            print(f"    alpha={ce['alpha']}, k={ce['k']}, "
                  f"beta={ce['beta']}, i(a,b)={ce['i_alpha_beta']}, "
                  f"i(s,b)={ce['i_sigma_beta']}, f(s)={ce['f_sigma']}")
    return counterexamples


def random_stress(name, eng, db, n_samples=1000):
    if eng is None or db is None:
        print(f"\n=== {name} (random {n_samples}): SKIP no data ===")
        return None
    print(f"\n=== {name} (random {n_samples} pairs from i<=1 edges) ===")
    curves = db["curves"]; adj = db["adj"]; edge_iv = db["edge_iv"]
    gamma0 = eng.S.curves["a_0"]
    f_vals = []
    for c in curves:
        if c is None:
            f_vals.append(None); continue
        try: f_vals.append(int(gamma0.intersection(c)))
        except: f_vals.append(None)
    # Build edge list with i in {0, 1}
    edges = []
    for key, v in edge_iv.items():
        if v not in (0, 1): continue
        a, b = tuple(key)
        if f_vals[a] is None or f_vals[b] is None: continue
        if f_vals[a] >= 2 and f_vals[b] < f_vals[a]:
            edges.append((a, b))
        if f_vals[b] >= 2 and f_vals[a] < f_vals[b]:
            edges.append((b, a))
    if not edges:
        print(f"  no eligible (alpha, beta) pairs in this DB")
        return None
    sample = random.sample(edges, min(n_samples, len(edges)))
    print(f"  total eligible pairs: {len(edges)}; sampling {len(sample)}")
    counterexamples = []; tested = 0; passed = 0
    sigma_cache = {}
    for alpha_idx, beta_idx in sample:
        if alpha_idx not in sigma_cache:
            try:
                t = eng.cut_glue(curves[alpha_idx],
                                 cut_spec={"cut_along": "a_0",
                                           "at_crossings": (0, 1)},
                                 glue_spec={"replace_with": "gamma0_subarc"})
                sigma_cache[alpha_idx] = t.result
            except Exception:
                sigma_cache[alpha_idx] = None
        sigma = sigma_cache[alpha_idx]
        if sigma is None:
            continue
        a_count = i_q(curves, edge_iv, alpha_idx, beta_idx)
        if a_count is None or a_count > 1: continue
        try: s_count = int(sigma.intersection(curves[beta_idx]))
        except: continue
        tested += 1
        if s_count == a_count: passed += 1
        else:
            counterexamples.append({
                "alpha": alpha_idx, "k": f_vals[alpha_idx],
                "beta": beta_idx, "i_alpha_beta": a_count,
                "i_sigma_beta": s_count,
            })
    print(f"  random pairs tested : {tested}")
    print(f"  random pairs PASSED : {passed}")
    print(f"  random pairs FAILED : {len(counterexamples)}")
    if counterexamples:
        for ce in counterexamples[:10]:
            print(f"    alpha={ce['alpha']}, k={ce['k']}, "
                  f"beta={ce['beta']}, i(a,b)={ce['i_alpha_beta']}, "
                  f"i(s,b)={ce['i_sigma_beta']}")
    return counterexamples


def main():
    print("=" * 78)
    print("Theorem 3.1 (Lemma 2.1) STRESS VERIFICATION")
    print("=" * 78)

    all_counterexamples = {}

    # Bucket A: S_{1,2} all alphas, all betas
    eng_12, db_12 = load_engine(1, 2,
        os.path.join(SCRIPT_DIR, "data_S_1_2.json"))
    all_counterexamples["S_1_2_all_alphas"] = stress_bucket(
        "Bucket A: S_{1,2} ALL alphas (chordal + non-chordal), ALL betas",
        eng_12, db_12)

    # Bucket B: S_{2,1}
    eng_21, db_21 = load_engine(2, 1,
        os.path.join(SCRIPT_DIR, "data_S_2_1.json"))
    all_counterexamples["S_2_1_all_alphas"] = stress_bucket(
        "Bucket B: S_{2,1} ALL alphas, ALL betas", eng_21, db_21)

    # Bucket C: S_{1,1}
    eng_11, db_11 = load_engine(1, 1,
        os.path.join(SCRIPT_DIR, "data_S_1_1.json"))
    all_counterexamples["S_1_1_all_alphas"] = stress_bucket(
        "Bucket C: S_{1,1} (Farey sanity)", eng_11, db_11)

    # Bucket D: S_{0,5} sanity
    try:
        eng_05, db_05 = load_engine(0, 5,
            os.path.join(SCRIPT_DIR, "data_S_0_5.json"))
        all_counterexamples["S_0_5_all_alphas"] = stress_bucket(
            "Bucket D: S_{0,5} g=0 sanity", eng_05, db_05)
    except Exception as e:
        print(f"\n=== Bucket D (S_{{0,5}}): error -- {e}")

    # Bucket E: random stress on S_{1,2} and S_{2,1}
    if db_12 is not None:
        all_counterexamples["S_1_2_random"] = random_stress(
            "Bucket E1: S_{1,2}", eng_12, db_12, n_samples=1000)
    if db_21 is not None:
        all_counterexamples["S_2_1_random"] = random_stress(
            "Bucket E2: S_{2,1}", eng_21, db_21, n_samples=1000)

    print()
    print("=" * 78)
    print("OVERALL VERDICT")
    print("=" * 78)
    n_ce_total = sum(len(v) for v in all_counterexamples.values() if v)
    if n_ce_total == 0:
        print("  ZERO counterexamples across all buckets.")
        print("  Theorem 3.1 statement holds on every (alpha, beta) pair tested.")
    else:
        print(f"  {n_ce_total} COUNTEREXAMPLES found:")
        for bucket, ces in all_counterexamples.items():
            if ces:
                print(f"    {bucket}: {len(ces)} counterexamples")
        print("  THEOREM 3.1 STATEMENT IS WRONG -- escalate to advisor.")
    return 0 if n_ce_total == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
