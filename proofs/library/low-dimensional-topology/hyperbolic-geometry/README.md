# Library / Low-Dimensional Topology / Hyperbolic Geometry

B- and C-class results on H^2, H^3, and their quotients — tools for LDT.

## What belongs here

- Isometries of H^n, classification (elliptic / parabolic / hyperbolic / loxodromic)
- Horoballs, horocycles, horospheres
- Margulis lemma and thin-thick decomposition
- Gauss–Bonnet for finite-area hyperbolic surfaces
- Volume formulas for ideal tetrahedra (Lobachevsky function)
- Mostow rigidity statement (as black box; proof in research/)
- Gromov–Thurston 2π theorem statement and elementary applications
- Basic quasiconformal-map estimates

## TSV integration

Numerical hyperbolic volume computations can be checked via SnapPy (see `tsv/tsv_knot.py::hyperbolic_volume`). For symbolic identities (trigonometric identities in H^2), rely on SymPy through the standard math-verifier pipeline.
