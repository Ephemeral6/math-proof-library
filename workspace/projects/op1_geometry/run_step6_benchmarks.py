"""Step 6: emit 5 progressively richer benchmark JSON files.

Each level adds more geometric data, building toward the full structure
that an agent might use to discover Hatcher's bigon-cancellation invariant.

Output dir: workspace/projects/op1_geometry/benchmark/
  benchmark_1_numbers_only.json       — i(α,β), i(σ,β), labels only
  benchmark_2_crossing_locations.json — + per-crossing triangle locations
  benchmark_3_surgery_region.json     — + surgery region triangles + β-region
                                        intersection
  benchmark_4_bigons.json             — + detected (α,β) bigons before
                                        surgery
  benchmark_5_with_counterfactual.json — + a counterfactual i(α,β)=2 case
                                         where net_change ≠ 0
"""
from __future__ import annotations
import json
import os
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import curver
from rich_geometry import (
    decompose_curve, find_crossings, trace_surgery,
    analyze_surgery_intersection, detect_bigons, triangulation_info,
)
from surface_geo import SurfaceGeo

HERE = Path(__file__).parent
BENCH = HERE / 'benchmark'
BENCH.mkdir(exist_ok=True)


def main():
    S = curver.load(1, 2)
    eng = SurfaceGeo(S)
    eng.attach_database(str(HERE / 'data_S_1_2.json'))
    db = eng._curve_db
    gamma0 = S.curves['a_0']
    f_vals = [int(gamma0.intersection(c)) for c in db['curves']]

    # Reuse the analysis JSON from Step 5
    full = json.loads((HERE / 'audit' / 'surgery_analyses_full.json').read_text())
    results = full['results']

    # Triangulation info (shared, level-1+)
    tri_info_json = [t.to_json() for t in triangulation_info(S)]

    # Pre-cache the bigon detection per α (it depends on alpha+beta+sigma; we
    # do it pair-by-pair below)
    sigma_cache: dict[int, tuple] = {}
    for r in results:
        a_idx = r['alpha_idx']
        if a_idx not in sigma_cache:
            alpha = db['curves'][a_idx]
            res = eng.cut_glue(
                alpha,
                cut_spec={'cut_along': 'a_0', 'at_crossings': (0, 1)},
                glue_spec={'replace_with': 'gamma0_subarc'},
            )
            sigma = res.result
            sigma_cache[a_idx] = (alpha, sigma)

    # ---- Level 1: numbers only -----------------------------------------
    lvl1 = []
    for r in results:
        lvl1.append({
            "pair_id": f"a{r['alpha_idx']}-b{r['beta_idx']}",
            "alpha_idx": r['alpha_idx'],
            "beta_idx": r['beta_idx'],
            "k_alpha": r['k_alpha'],
            "i_alpha_beta": r['pre_intersection'],
            "i_sigma_beta": r['post_intersection'],
            "i_alpha_gamma": r['alpha_gamma_intersection'],
            "i_sigma_gamma": r['sigma_gamma_intersection'],
        })
    (BENCH / 'benchmark_1_numbers_only.json').write_text(
        json.dumps({"surface": "S_{1,2}", "n_pairs": len(lvl1), "pairs": lvl1},
                   indent=2))

    # ---- Level 2: crossing locations -----------------------------------
    lvl2 = []
    for r in results:
        a_idx = r['alpha_idx']
        b_idx = r['beta_idx']
        alpha, sigma = sigma_cache[a_idx]
        beta = db['curves'][b_idx]

        di_pre = find_crossings(S, alpha, beta, f"alpha_{a_idx}", f"beta_{b_idx}")
        di_post = find_crossings(S, sigma, beta, f"sigma_{r['sigma_idx']}",
                                 f"beta_{b_idx}")

        lvl2.append({
            "pair_id": f"a{a_idx}-b{b_idx}",
            **lvl1[len(lvl2)],  # propagate prior fields
            "pre_crossings":
                [c.to_json() for c in di_pre.crossings],
            "post_crossings":
                [c.to_json() for c in di_post.crossings],
            "alpha_decomposition":
                di_pre.curve_a_decomposition.to_json(),
            "beta_decomposition":
                di_pre.curve_b_decomposition.to_json(),
            "sigma_decomposition":
                di_post.curve_a_decomposition.to_json(),
        })
    (BENCH / 'benchmark_2_crossing_locations.json').write_text(
        json.dumps({"surface": "S_{1,2}", "triangulation": tri_info_json,
                    "n_pairs": len(lvl2), "pairs": lvl2},
                   indent=2))

    # ---- Level 3: surgery region & β path ------------------------------
    lvl3 = []
    for r, l2 in zip(results, lvl2):
        lvl3.append({
            **l2,
            "surgery_region_triangles": r['surgery_region_triangles'],
            "surgery_region_punctures": r['surgery_region_punctures'],
            "short_arc_triangles": r['short_arc_triangles'],
            "long_arc_triangles": r['long_arc_triangles'],
            "beta_triangles": r['beta_triangles'],
            "beta_in_surgery_region": r['beta_in_surgery_region'],
            "beta_through_short_arc": r['beta_through_short_arc'],
            "beta_through_long_arc": r['beta_through_long_arc'],
        })
    (BENCH / 'benchmark_3_surgery_region.json').write_text(
        json.dumps({"surface": "S_{1,2}", "triangulation": tri_info_json,
                    "n_pairs": len(lvl3), "pairs": lvl3},
                   indent=2))

    # ---- Level 4: bigons ----------------------------------------------
    lvl4 = []
    for r, l3 in zip(results, lvl3):
        a_idx = r['alpha_idx']
        b_idx = r['beta_idx']
        alpha, sigma = sigma_cache[a_idx]
        beta = db['curves'][b_idx]

        di_pre = find_crossings(S, alpha, beta, f"alpha_{a_idx}", f"beta_{b_idx}")
        di_post = find_crossings(S, sigma, beta, f"sigma_{r['sigma_idx']}",
                                 f"beta_{b_idx}")
        bigons_pre = detect_bigons(S, di_pre)
        bigons_post = detect_bigons(S, di_post)
        lvl4.append({
            **l3,
            "pre_candidate_crossing_total":
                di_pre.candidate_crossings_total,
            "post_candidate_crossing_total":
                di_post.candidate_crossings_total,
            "pre_bigons": [b.to_json() for b in bigons_pre],
            "post_bigons": [b.to_json() for b in bigons_post],
            "pre_bigon_count": len(bigons_pre),
            "post_bigon_count": len(bigons_post),
        })
    (BENCH / 'benchmark_4_bigons.json').write_text(
        json.dumps({"surface": "S_{1,2}", "triangulation": tri_info_json,
                    "n_pairs": len(lvl4), "pairs": lvl4},
                   indent=2))

    # ---- Level 5: with counterfactual ----------------------------------
    # Find a (α, β) pair with i(α, β) = 2: NOT in the descending link.
    # We use one of the non-chordal alphas (alpha=38, k=4) and find a β with
    # i(α, β) = 2.
    counterfact_records = []
    target_alpha = 38
    alpha = db['curves'][target_alpha]
    sigma_alpha = sigma_cache[target_alpha][1]
    sigma_idx = next((r['sigma_idx'] for r in results
                      if r['alpha_idx'] == target_alpha), -1)
    for cand_idx, cand in enumerate(db['curves']):
        if cand_idx == target_alpha:
            continue
        i_ab = int(alpha.intersection(cand))
        if i_ab != 2:
            continue
        # take the first 6 β with i = 2
        i_sb = int(sigma_alpha.intersection(cand))
        di_pre = find_crossings(S, alpha, cand, f"alpha_{target_alpha}",
                                f"beta_{cand_idx}")
        di_post = find_crossings(S, sigma_alpha, cand, f"sigma_{sigma_idx}",
                                 f"beta_{cand_idx}")
        bigons_pre = detect_bigons(S, di_pre)
        bigons_post = detect_bigons(S, di_post)

        st = trace_surgery(
            S, alpha, gamma0, sigma_alpha,
            alpha_id=f"alpha_{target_alpha}",
            gamma0_id="gamma0",
            sigma_id=f"sigma_{sigma_idx}",
        )
        analysis = analyze_surgery_intersection(
            S, st, alpha, sigma_alpha, cand, beta_id=f"beta_{cand_idx}"
        )

        counterfact_records.append({
            "pair_id": f"a{target_alpha}-cf-b{cand_idx}",
            "alpha_idx": target_alpha,
            "beta_idx": cand_idx,
            "i_alpha_beta": i_ab,
            "i_sigma_beta": i_sb,
            "net_change": i_sb - i_ab,
            "pre_crossings": [c.to_json() for c in di_pre.crossings],
            "post_crossings": [c.to_json() for c in di_post.crossings],
            "pre_bigon_count": len(bigons_pre),
            "post_bigon_count": len(bigons_post),
            "pre_bigons": [b.to_json() for b in bigons_pre],
            "post_bigons": [b.to_json() for b in bigons_post],
            "surgery_region_triangles": list(st.surgery_region_triangles),
            "beta_in_surgery_region": analysis.beta_in_surgery_region,
            "alpha_decomposition":
                di_pre.curve_a_decomposition.to_json(),
            "beta_decomposition":
                di_pre.curve_b_decomposition.to_json(),
            "sigma_decomposition":
                di_post.curve_a_decomposition.to_json(),
        })
        if len(counterfact_records) >= 6:
            break

    (BENCH / 'benchmark_5_with_counterfactual.json').write_text(
        json.dumps({
            "surface": "S_{1,2}",
            "triangulation": tri_info_json,
            "regular_pairs": lvl4,
            "n_regular_pairs": len(lvl4),
            "counterfactual_pairs": counterfact_records,
            "n_counterfactual_pairs": len(counterfact_records),
            "note": "Counterfactual pairs have i(α, β) = 2 (β not in α's "
                    "descending link). For these, net_change is generally "
                    "non-zero — illustrating that the bigon-cancellation "
                    "argument only works at i(α, β) ≤ 1. Use this contrast "
                    "to verify an agent's discovery generalises correctly.",
        }, indent=2))

    # Summary
    print("Generated benchmark files:")
    for f in sorted(BENCH.glob("benchmark_*.json")):
        sz = f.stat().st_size
        print(f"  {f.name}: {sz:,} bytes")
    print(f"\nCounterfactual pairs: {len(counterfact_records)}")
    for cf in counterfact_records:
        print(f"  pair {cf['pair_id']}: i(α,β)={cf['i_alpha_beta']}, "
              f"i(σ,β)={cf['i_sigma_beta']}, net={cf['net_change']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
