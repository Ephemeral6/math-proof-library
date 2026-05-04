# B1.2 Phenomena observed

Codes:
- ACCEL_PR / ACCEL_CES : averaged iterate at least 10x better than last iterate
- CYCLING : best iterate at least 20x better than last iterate (= bouncing past optimum)

- ACCEL_PR  Goujaud2D Adam T=100: PR_gap/last_gap=8.62e-05
- CYCLING   Goujaud2D Adam T=100: best/last=4.48e-08
- ACCEL_PR  Goujaud2D Adam T=10000: PR_gap/last_gap=6.75e-07
- CYCLING   Goujaud2D Adam T=10000: best/last=2.09e-81
- ACCEL_PR  SCQuad10 SHB_0.9 T=100: PR_gap/last_gap=2.91e-02
- ACCEL_PR  SCQuad10 Adam T=100: PR_gap/last_gap=1.42e-02
- ACCEL_PR  SCQuad10 Adam T=1000: PR_gap/last_gap=8.52e-03
- CYCLING   SCQuad10 Adam T=1000: best/last=1.12e-17
- ACCEL_PR  SCQuad10 Adam T=10000: PR_gap/last_gap=1.03e-08
- ACCEL_CES SCQuad10 Adam T=10000: Ces_gap/last_gap=1.33e-05
- CYCLING   SCQuad10 Adam T=10000: best/last=7.32e-23
