"""
Direction C verification on S_{1,1}: every Lk^↓(α) at level k=f(α)≥1
in the Farey complex has |Lk^↓(α)| ≤ 2 vertices, hence (W4) is
vacuously true.

Method: enumerate all Farey vertices α with denominator b ∈ {1, ..., B}
and for each, list its Farey neighbors with denominator < b.

This is purely number-theoretic — does not need curver. The point is to
*sanity check* the Stern-Brocot argument that |Lk^↓(α)| = 2 for b ≥ 2
and = 1 for b = 1 (the unique neighbor being γ_0 = 1/0 = ∞).
"""
from math import gcd
from collections import defaultdict

def farey_neighbors_below(a, b, max_q=None):
    """Find all p/q with gcd(p,q)=1, q < b, |a*q - b*p| = 1.

    For γ_0 = ∞ = 1/0 acting as a "vertex" with denominator 0, also
    include 1/0 if a = ±1 mod b.

    Returns list of (p, q) tuples.
    """
    if max_q is None:
        max_q = b
    out = []
    # γ_0 = ∞ corresponds to (1, 0): adjacency |a*0 - b*1| = b = 1 ⇔ b=1
    if b == 1:
        out.append((1, 0))  # γ_0
        # α = 0/1 or 1/1; the other neighbor in Lk^↓ — none with q < 1 except (1,0)
        return out
    # b ≥ 2: neighbors with q ∈ [1, b-1]
    for q in range(1, b):
        # need a*q - b*p = ±1, so b*p = a*q ∓ 1, p = (a*q ∓ 1)/b
        for sign in (+1, -1):
            num = a * q - sign  # b*p = a*q - sign  (i.e. a*q - b*p = sign)
            if num % b == 0:
                p = num // b
                if gcd(abs(p), q) == 1 if p != 0 else (q == 1):
                    out.append((p, q))
    # de-dup
    return sorted(set(out))


def fareys_up_to(B):
    """All a/b in [0,1] with gcd(a,b)=1, 1 ≤ b ≤ B. Plus 1/0 (= ∞)."""
    pts = [(1, 0)]  # ∞
    for b in range(1, B + 1):
        for a in range(0, b + 1):
            if gcd(a, b) == 1:
                pts.append((a, b))
    return pts


def main():
    B = 12
    print(f"Enumerating Farey neighbors with smaller denominator, up to b = {B}.")
    print("=" * 72)
    by_denom = defaultdict(list)
    counterexamples = []
    for a, b in fareys_up_to(B):
        if b == 0:  # γ_0 itself; level 0
            continue
        nbrs = farey_neighbors_below(a, b)
        by_denom[b].append((a, nbrs))
        if len(nbrs) > 2:
            counterexamples.append((a, b, nbrs))
        # Sanity: for b ≥ 2 we expect exactly 2 neighbors.
        if b >= 2 and len(nbrs) != 2:
            counterexamples.append((a, b, nbrs))
        if b == 1 and len(nbrs) != 1:
            counterexamples.append((a, b, nbrs))

    print(f"Total Farey vertices with denominator ≤ {B}: "
          f"{sum(len(v) for v in by_denom.values())}")
    print(f"Counterexamples to |Lk^↓| ≤ 2: {len(counterexamples)}")
    if counterexamples:
        print("FIRST 5 COUNTEREXAMPLES:")
        for a, b, n in counterexamples[:5]:
            print(f"  {a}/{b}: |Lk^↓| = {len(n)}, neighbors = {n}")

    print()
    print("Sample Lk^↓(α) per denominator b ∈ {1,...,8}:")
    for b in range(1, 9):
        for a, nbrs in by_denom[b][:3]:
            label = f"{a}/{b}"
            nbr_str = ", ".join(f"{p}/{q}" for p, q in nbrs)
            print(f"  α = {label:>6}: |Lk^↓| = {len(nbrs)}; nbrs = {{{nbr_str}}}")

    # Check the two parents of each α with b ≥ 2 are connected
    print()
    print("Connectivity check: for each α with b ≥ 2, are the two parents")
    print("Farey-adjacent (forming an edge in Lk^↓)?")
    bad = 0
    for b in range(2, B + 1):
        for a, nbrs in by_denom[b]:
            (p1, q1), (p2, q2) = nbrs
            if abs(p1 * q2 - p2 * q1) != 1:
                bad += 1
                if bad <= 3:
                    print(f"  α = {a}/{b}: parents {p1}/{q1}, {p2}/{q2} NOT Farey-adjacent")
    print(f"  Non-edge parents: {bad} / {sum(1 for b in range(2, B+1) for _ in by_denom[b])}")

    print()
    print("CONCLUSION:")
    if not counterexamples and bad == 0:
        print("  Lk^↓(α) is always:")
        print("    - {γ_0} (1 vertex)        if f(α) = 1  → contractible")
        print("    - an edge {p_1, p_2}       if f(α) ≥ 2  → contractible")
        print("  In particular, |Lk^↓(α)| ≤ 2 always; no induced 4-cycle exists;")
        print("  (W4) is VACUOUSLY satisfied on S_{1,1}.")
    else:
        print("  ANOMALY DETECTED — see counterexamples above.")


if __name__ == "__main__":
    main()
