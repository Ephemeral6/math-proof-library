"""Compute trefoil polyline points for fig5 SVG.

Parametric trefoil:
  x(t) = sin(t) + 2 sin(2t)
  y(t) = cos(t) - 2 cos(2t)
  z(t) = sin(3t)   (over/under)

Self-intersections:
  C1 = (0,    1.5)  at t = 104.5deg (under) and 255.5deg (over)
  C2 = (-1.299, -0.75) at t = 135.5deg (over) and 344.5deg (under)
  C3 = ( 1.299, -0.75) at t =  15.5deg (over) and 224.5deg (under)
"""
import math


def xy(t_deg):
    t = math.radians(t_deg)
    return math.sin(t) + 2*math.sin(2*t), math.cos(t) - 2*math.cos(2*t)


def transform(u, v, cx, cy, scale):
    # SVG y down, center bbox vertical midpoint at cy
    # bbox y in [-3, 2.06], midpoint -0.47
    sx = cx + u * scale
    sy = cy - (v + 0.47) * scale
    return sx, sy


def build_path(cx, cy, scale=5.0):
    # Three sub-paths separated by tiny gaps at under-crossings (t = 104.5, 224.5, 344.5)
    # Use 12deg base sampling, plus fine points at +/-0.5deg around each under-crossing.
    base = list(range(0, 360, 12))  # 0,12,...,348
    fine_before = {104, 224, 344}   # one degree before crossing
    fine_after  = {105, 225, 345}   # one degree after crossing
    # ordering of all sample t-values:
    all_t = sorted(set(base) | fine_before | fine_after)

    # Build 3 sub-paths separated at the under-crossings.
    # Gaps live between (104, 105), (224, 225), (344, 345).
    paths = []
    cur = []
    for t in all_t:
        cur.append(t)
        if t in fine_before:
            paths.append(cur)
            cur = []
    if cur:
        paths.append(cur)

    # Wrap last path with first path (since the curve is closed, the path that ends at t=348 actually continues to t=0..104).
    # Sub-paths now (after the loop):
    #  P0 = [0,12,...,96,104]
    #  P1 = [105,108,120,...,216,224]
    #  P2 = [225,228,240,...,336,344]
    #  P3 = [345,348]
    # Merge P3 + P0 since they're continuous (no gap between t=348 and t=0=360, only between 344-345 -- which we already handled).
    if len(paths) == 4:
        merged = paths[3] + paths[0]   # 345,348,0,12,...,96,104
        paths = [merged, paths[1], paths[2]]

    # Convert each path to SVG path string.
    out = []
    for p in paths:
        coords = [transform(*xy(t), cx, cy, scale) for t in p]
        d = "M " + " L ".join(f"{x:.2f},{y:.2f}" for (x, y) in coords)
        out.append(d)
    return out


def crossings(cx, cy, scale=5.0):
    return {
        "C1": transform(0.0, 1.5, cx, cy, scale),
        "C2": transform(-1.299, -0.75, cx, cy, scale),
        "C3": transform(1.299, -0.75, cx, cy, scale),
    }


if __name__ == "__main__":
    print("=== LEFT KNOT (Cx=37, Cy=30, scale=5) ===")
    for d in build_path(37, 30, 5.0):
        print(d)
    print("crossings:", crossings(37, 30, 5.0))

    print()
    print("=== RIGHT KNOT (Cx=100, Cy=30, scale=5) ===")
    for d in build_path(100, 30, 5.0):
        print(d)
    print("crossings:", crossings(100, 30, 5.0))

    print()
    print("=== MINI KNOT (Cx=140, Cy=47, scale=1.3) ===")
    for d in build_path(140, 47, 1.3):
        print(d)
    print("crossings:", crossings(140, 47, 1.3))

    # Wavy underline path generator
    def wavy(x0, y0, length_mm, period=1.6, amp=0.35):
        n = int(round(length_mm / period))
        d = [f"M {x0:.2f},{y0:.2f}"]
        d.append(f"q {period/2:.2f},{-amp:.2f} {period:.2f},0")
        for _ in range(n - 1):
            d.append(f"t {period:.2f},0")
        return " ".join(d)

    print()
    print("=== WAVY (left underline, red) ===")
    print(wavy(8.0, 67.7, 56.0))
