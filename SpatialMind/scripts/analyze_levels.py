"""Print summary statistics for each benchmark level."""
import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).parent.parent
BD = ROOT / "benchmarks" / "surface_topology"


def lvl(n):
    return json.load(open(BD / f"level_{n}.json"))


def header(s):
    print()
    print("=" * 70)
    print(s)
    print("=" * 70)


# --- Level 1 ---
header("LEVEL 1 — summary_delta only")
d = lvl(1)
print(f"n_cases: {d['n_cases']}")
deltas_i = [c["summary_delta"]["intersection_number"] for c in d["cases"]]
print(f"intersection_number delta distribution: {dict(Counter(deltas_i))}")
weight_a = [c["summary_delta"]["weight_a"] for c in d["cases"]]
print(f"weight_a delta: min={min(weight_a)} max={max(weight_a)} "
      f"(n_zero={sum(1 for w in weight_a if w==0)}/{len(weight_a)})")
weight_b = [c["summary_delta"]["weight_b"] for c in d["cases"]]
print(f"weight_b delta: all zero? {all(w==0 for w in weight_b)} "
      f"(β never modified ✓)")

# --- Level 2 ---
header("LEVEL 2 — + detailed_comparison (per-triangle crossings)")
d = lvl(2)
pre_c = [c["detailed_comparison"]["crossings_pre_count"] for c in d["cases"]]
post_c = [c["detailed_comparison"]["crossings_post_count"] for c in d["cases"]]
pre_cand = [c["detailed_comparison"]["crossings_pre_candidate_total"] for c in d["cases"]]
post_cand = [c["detailed_comparison"]["crossings_post_candidate_total"] for c in d["cases"]]
ir_pre = [c["detailed_comparison"]["crossings_in_transform_region_pre"] for c in d["cases"]]
ir_post = [c["detailed_comparison"]["crossings_in_transform_region_post"] for c in d["cases"]]
out_pre = [c["detailed_comparison"]["crossings_outside_region_pre"] for c in d["cases"]]
out_post = [c["detailed_comparison"]["crossings_outside_region_post"] for c in d["cases"]]
print(f"candidate_total pre  : min={min(pre_cand)} max={max(pre_cand)} mean={sum(pre_cand)/len(pre_cand):.2f}")
print(f"candidate_total post : min={min(post_cand)} max={max(post_cand)} mean={sum(post_cand)/len(post_cand):.2f}")
print(f"in_region_pre  dist: {dict(sorted(Counter(ir_pre).items()))}")
print(f"in_region_post dist: {dict(sorted(Counter(ir_post).items()))}")
print(f"outside_pre   dist: {dict(sorted(Counter(out_pre).items()))}")
print(f"outside_post  dist: {dict(sorted(Counter(out_post).items()))}")
n_out_eq = sum(1 for a, b in zip(out_pre, out_post) if a == b)
print(f"outside_pre == outside_post: {n_out_eq}/{len(d['cases'])}")
n_in_eq = sum(1 for a, b in zip(ir_pre, ir_post) if a == b)
print(f"in_region_pre == in_region_post: {n_in_eq}/{len(d['cases'])}")
n_cand_drop = sum(1 for a, b in zip(pre_cand, post_cand) if b < a)
n_cand_eq = sum(1 for a, b in zip(pre_cand, post_cand) if b == a)
n_cand_up = sum(1 for a, b in zip(pre_cand, post_cand) if b > a)
print(f"candidate_total drops/equal/grows post-surgery: {n_cand_drop}/{n_cand_eq}/{n_cand_up}")

# --- Level 3 ---
header("LEVEL 3 — + transform_trace + reference_in_transform_region")
d = lvl(3)
beta_total = [c["reference_in_transform_region"]["beta_triangles_total"] for c in d["cases"]]
beta_in = [c["reference_in_transform_region"]["beta_triangles_in_region"] for c in d["cases"]]
beta_short = [c["reference_in_transform_region"]["beta_through_short_arc"] for c in d["cases"]]
beta_long = [c["reference_in_transform_region"]["beta_through_long_arc"] for c in d["cases"]]
print(f"beta_triangles_total dist: {dict(sorted(Counter(beta_total).items()))}")
print(f"beta_triangles_in_region dist: {dict(sorted(Counter(beta_in).items()))}")
print(f"beta_through_short_arc dist: {dict(sorted(Counter(beta_short).items()))}")
print(f"beta_through_long_arc  dist: {dict(sorted(Counter(beta_long).items()))}")
# How often does β enter the surgery region?
n_beta_in_pos = sum(1 for x in beta_in if x > 0)
print(f"β enters surgery region: {n_beta_in_pos}/{len(d['cases'])}")
# Region triangle counts
region_size = [len(c["transform_trace"]["region_affected"]["triangles"]) for c in d["cases"]]
print(f"transform region size dist: {dict(sorted(Counter(region_size).items()))}")
short_size = [len(c["transform_trace"]["region_affected"]["short_arc_triangles"]) for c in d["cases"]]
long_size = [len(c["transform_trace"]["region_affected"]["long_arc_triangles"]) for c in d["cases"]]
print(f"short_arc_triangles count dist: {dict(sorted(Counter(short_size).items()))}")
print(f"long_arc_triangles count dist: {dict(sorted(Counter(long_size).items()))}")

# --- Level 4 ---
header("LEVEL 4 — + structural_comparison (bigon puncture)")
d = lvl(4)
bp_pre = [c["structural_comparison"]["bigons_pre"] for c in d["cases"]]
bp_post = [c["structural_comparison"]["bigons_post"] for c in d["cases"]]
bw_pre_p = [c["structural_comparison"]["bigons_with_puncture_pre"] for c in d["cases"]]
bw_post_p = [c["structural_comparison"]["bigons_with_puncture_post"] for c in d["cases"]]
bnone_pre = [c["structural_comparison"]["bigons_without_puncture_pre"] for c in d["cases"]]
bnone_post = [c["structural_comparison"]["bigons_without_puncture_post"] for c in d["cases"]]
all_pre = [c["structural_comparison"]["all_bigons_contain_puncture_pre"] for c in d["cases"]]
all_post = [c["structural_comparison"]["all_bigons_contain_puncture_post"] for c in d["cases"]]
mp_pre = [c["structural_comparison"]["minimal_position_pre"] for c in d["cases"]]
mp_post = [c["structural_comparison"]["minimal_position_post"] for c in d["cases"]]

print(f"bigons_pre  dist: {dict(sorted(Counter(bp_pre).items()))}")
print(f"bigons_post dist: {dict(sorted(Counter(bp_post).items()))}")
print(f"bigons_without_puncture_pre  TOTAL: {sum(bnone_pre)}  (any ever > 0? {any(b>0 for b in bnone_pre)})")
print(f"bigons_without_puncture_post TOTAL: {sum(bnone_post)} (any ever > 0? {any(b>0 for b in bnone_post)})")
print(f"all_bigons_contain_puncture_pre  : True={sum(all_pre)} / False={len(all_pre)-sum(all_pre)}")
print(f"all_bigons_contain_puncture_post : True={sum(all_post)} / False={len(all_post)-sum(all_post)}")
# Decompose the False post values
zero_post = sum(1 for x in bp_post if x == 0)
print(f"  (post has 0 bigons in {zero_post} cases — predicate vacuously False)")
print(f"minimal_position_pre  : True={sum(1 for x in mp_pre if x)} False={sum(1 for x in mp_pre if not x)}")
print(f"minimal_position_post : True={sum(1 for x in mp_post if x)} False={sum(1 for x in mp_post if not x)}")

# Stratify by i(α, β)
metas_i = [c.get("metadata", {}).get("i_alpha_beta") for c in d["cases"]]
# All should be 1 (we filtered)
print(f"i(α,β) distribution: {dict(Counter(metas_i))}")

# --- Level 5 ---
header("LEVEL 5 — + counterfactual cases")
d = lvl(5)
print(f"counterfactual cases: {len(d.get('counterfactual', []))}")
for cf in d.get("counterfactual", []):
    flag = "CRIT" if cf["condition_is_critical"] else "    "
    print(f"  [{flag}] {cf['strategy']}")
    print(f"        original_condition  = {cf['original_condition']}")
    print(f"        modified_condition  = {cf['modified_condition']}")
    print(f"        original_result     = {cf['original_result']}")
    print(f"        counterfactual_result = {cf['counterfactual_result']}")
    print(f"        delta = {cf['delta']}")
