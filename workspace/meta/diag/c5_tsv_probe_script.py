"""Probe 5 — 10 diverse TSV calls, log values + tags verbatim."""

import sys
sys.path.insert(0, r"C:\Users\12729\.claude\skills\math-verifier\tsv")

import tsv_knot as K

calls = [
    ("1", "jones_polynomial", ("trefoil",), {},
        "in-table named knot — should succeed high"),
    ("2", "jones_polynomial", ("7_1",), {},
        "not in table named knot — should miss"),
    ("3", "jones_polynomial", ([1]*7,), {},
        "braid word for 7_1 (T(2,7)) — not in table, no generic path"),
    ("4", "jones_polynomial", ([1, -2, 1, -2],), {},
        "braid word of figure-eight — should match table"),
    ("5", "alexander_polynomial", ([1, 1, 1],), {"n": 2},
        "braid word = trefoil, via n=2 path (wrong n for trefoil's B_3)"),
    ("6", "alexander_polynomial", ([1, 1, 1, 1, 1],), {"n": 2},
        "5_1 braid word with forced n=2 (WRONG; 5_1 is B_2 closure but algebra is fragile)"),
    ("7", "kauffman_bracket", ("trefoil",), {},
        "in-table Kauffman bracket derivation"),
    ("8", "kauffman_bracket", ("T(3,5)",), {},
        "torus knot T(3,5) — not in table"),
    ("9", "hyperbolic_volume", ("trefoil",), {},
        "torus knot — non-hyperbolic but IN table (edge case)"),
    ("10", "check_reidemeister_equivalent", ("trefoil", "3_1m"), {},
        "mirror pair — different Jones, same Alexander/determinant"),
]

for idx, func_name, args, kwargs, note in calls:
    func = getattr(K, func_name)
    try:
        result = func(*args, **kwargs)
        value, tag = result
    except Exception as e:
        value, tag = "<EXCEPTION>", {"error": str(e)}
    print(f"=== CALL {idx} === {func_name}{args} {kwargs}")
    print(f"  note:  {note}")
    print(f"  value: {value}")
    print(f"  tag:   {tag}")
    print()
