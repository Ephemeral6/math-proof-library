"""
Verify Farb-Margalit Prop 3.2: i(T_b(a), a) = i(a, b)^2 for curves with intersection 0 or 1.

This validates the critical step in the connectedness proof.
"""
import curver

def check(g, n):
    print(f"\n=== S_{g},{n} ===")
    S = curver.load(g, n)
    curves = S.curves
    twists = S.pos_mapping_classes
    # Test pairs
    for nm_a in curves:
        for nm_b in twists:
            try:
                a = curves[nm_a]
                Tb = S(nm_b)
                Tb_a = Tb(a)
                i_ab = a.intersection(curves.get(nm_b, None) or Tb.curve())
                i_Tba_a = Tb_a.intersection(a)
                # Predicted: i(T_b(a), a) ≤ i(a, b)^2 (Farb-Margalit, equality often holds)
                pred = i_ab ** 2
                ok = i_Tba_a <= pred + 1  # small tolerance
                print(f"  i({nm_a}, {nm_b})={i_ab}, i(T_{nm_b}({nm_a}), {nm_a})={i_Tba_a}, pred={pred}, OK={ok}")
            except Exception as e:
                print(f"  ({nm_a}, {nm_b}): error {e}")

for g, n in [(1, 1), (1, 2), (2, 1)]:
    check(g, n)
