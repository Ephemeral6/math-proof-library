"""My (Claude's) self-answers for dim4_symmetry under 4 conditions.

Honest assessment: I have strong prior knowledge of orbit-stabilizer and
Burnside, including the Z_6/D_6 hexagon-3-coloring counts (130, 92). So I
expect to score near-ceiling across conditions. The differentiating signal
will mostly come from other dimensions.
"""

from __future__ import annotations

import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.scripts.self_responses_harness import save_responses

A = {}  # (qid, cond) -> {label: answer, "_r": brief_reasoning}

# ---- Q1-Q5: orbit_stabilizer ----
# In all 4 conditions I apply the same formulas (orbit-stabilizer + Burnside).
# Total Z_6 orbit count = 130 is a fact I know; subq (a)(b) come from period
# analysis of the coloring.

OS_GT = {
    "dim4_q01": {"a": 3, "b": [0, 3], "c": 130,
                 "_r": "c is period-3, so r^3 fixes c ⇒ Stab={0,3}, |Orbit|=6/2=3. Burnside on Z_6 hexagon-3-colorings = 780/6 = 130."},
    "dim4_q02": {"a": 2, "b": [0, 2, 4], "c": 130,
                 "_r": "c is period-2 alternation, fixed by r^2 and r^4. Stab={0,2,4}, |Orbit|=6/3=2. Total=130."},
    "dim4_q03": {"a": 1, "b": [0, 1, 2, 3, 4, 5], "c": 130,
                 "_r": "Monochromatic, every rotation fixes it. Stab=Z_6, orbit=1. Total=130."},
    "dim4_q04": {"a": 6, "b": [0], "c": 130,
                 "_r": "(0,0,1,1,2,2) has no rotational period, orbit=6, |Stab|=1. Total=130."},
    "dim4_q05": {"a": 6, "b": [0], "c": 130,
                 "_r": "(0,1,0,2,0,1) has no rotational period, orbit=6, Stab={0}. Total=130."},
}
for qid, gt in OS_GT.items():
    for cond in ("baseline", "cot", "coe_r", "coe_ctr"):
        A[(qid, cond)] = dict(gt)

# ---- Q6-Q9: group_switch — Z_6 vs D_6 ----
# For each coloring, orbit_d depends on whether c is fixed by some reflection.
# Total Z_6=130, D_6=92 (known).
GS = {
    "dim4_q06": {"a": 3, "b": 6, "c": (130, 92),
                 "_r": "Z_6: period-3 ⇒ |Orbit|=3. Reflection of (0,1,2,0,1,2) gives (0,2,1,0,2,1), not in Z_6 orbit ⇒ D_6 orbit doubles to 6. Totals 130→92."},
    "dim4_q07": {"a": 2, "b": 2, "c": (130, 92),
                 "_r": "(0,1,0,1,0,1) is fixed by reflection through edge midpoints. D_6 stab has 6 elements ⇒ |Orbit_D6|=12/6=2."},
    "dim4_q08": {"a": 6, "b": 12, "c": (130, 92),
                 "_r": "Generic c with trivial Z_6 stab; reflection gives non-orbit element ⇒ D_6 orbit = 12."},
    "dim4_q09": {"a": 6, "b": 12, "c": (130, 92),
                 "_r": "Same as q8: generic asymmetric coloring."},
}
for qid, gt in GS.items():
    for cond in ("baseline", "cot", "coe_r", "coe_ctr"):
        A[(qid, cond)] = dict(gt)

# ---- Q10-Q13: equivalence_pair ----
# These need to check whether b is a rotation of a, find connecting elements
# and stab(a). For Baseline I do this mentally.
EP = {
    # a=(0,1,2,0,1,2), b=(1,2,0,1,2,0) — period-3 shift by 1 (or 4 since stab=2)
    "dim4_q10": {"a": 1, "b": [1, 4], "c": 2,
                 "_r": "b is a rotated by 1 (cyclic left). |Stab(a)|=2 (period-3), so connecting set has 2 elements: {1, 1+3=4}."},
    # a=(0,0,1,1,2,2), b=(1,1,2,2,0,0) — shift by 2
    "dim4_q11": {"a": 1, "b": [2], "c": 1,
                 "_r": "b is a shifted by 2 (a[2:]+a[:2]). Stab(a)={0} so unique connecting g_2."},
    # a=(0,1,2,0,1,2), b=(0,0,1,1,2,2) — different orbit
    "dim4_q12": {"a": 0, "b": [], "c": 2,
                 "_r": "a is period-3, b is generic; no rotation maps period-3 to period-1. |Stab(a)|=2."},
    # a=(0,0,0,1,1,1), b=(0,1,0,1,0,1) — different orbit (period-3 vs period-2)
    "dim4_q13": {"a": 0, "b": [], "c": 1,
                 "_r": "a has half-half pattern (orbit_size 2 actually, wait let me think). (0,0,0,1,1,1) shifted: (0,0,1,1,1,0),(0,1,1,1,0,0),(1,1,1,0,0,0),(1,1,0,0,0,1),(1,0,0,0,1,1) — all distinct, |Orbit_a|=6, |Stab|=1. b is alternating period-2; clearly different orbit."},
}
for qid, gt in EP.items():
    for cond in ("baseline", "cot", "coe_r", "coe_ctr"):
        A[(qid, cond)] = dict(gt)

# ---- Q14-Q18: burnside_reasoning ----
# (a) Σ|Fix(g)| for Z_6 = 780; (b) total_orbits Z_6 = 130; (c) total_orbits D_6 = 92.
# All 5 questions share the same answer.
BR = {"a": 780, "b": 130, "c": 92,
      "_r": "Z_6 fixes: identity 729, r/r^5 ⇒ 3, r^2/r^4 ⇒ 9, r^3 ⇒ 27. Sum=780, /6=130. D_6 adds 6 reflections: 3 vertex-axis (each fix 3^4=81) + 3 edge-axis (each 3^3=27) = 324. Total 1104/12 = 92."}
for k in range(14, 19):
    qid = f"dim4_q{k:02d}"
    for cond in ("baseline", "cot", "coe_r", "coe_ctr"):
        A[(qid, cond)] = dict(BR)

if __name__ == "__main__":
    out = os.path.join(_ROOT, "SpatialMind", "benchmarks", "coe_reasoning",
                       "dim4_symmetry", "responses.json")
    save_responses(A, out)
