"""Bias ratio table at R*_ext_v3 corners (8 corners + center, T=1..20)."""

import sys
from pathlib import Path
import mpmath as mp

sys.path.insert(0, str(Path(__file__).parent))
from gap1_detailed_verify import (
    lam_val, e_vec, goujaud_vertices, shb_step, DPS, T_MAX,
)

EXT3_BETA  = (0.77, 0.82)
EXT3_ETAL  = (3.20, 3.36)
EXT3_KAPPA = (0.37, 0.42)


def main():
    mp.mp.dps = DPS
    L = mp.mpf(1); D = mp.mpf(1); lam = lam_val()

    corners = []
    for i, b in enumerate(EXT3_BETA):
        for j, e in enumerate(EXT3_ETAL):
            for k, kk in enumerate(EXT3_KAPPA):
                corners.append((f"v3c_{i}{j}{k}", b, e, kk))
    bc = sum(EXT3_BETA)/2; ec = sum(EXT3_ETAL)/2; kc = sum(EXT3_KAPPA)/2
    corners.append(("v3c_center", bc, ec, kc))

    print("=" * 72)
    print(f"R*_ext_v3 corner bias ratios, T=1..20, dps={DPS}")
    print(f"Box: {EXT3_BETA} x {EXT3_ETAL} x {EXT3_KAPPA}")
    print("=" * 72)
    print(f"\n{'corner':12s}  {'beta':6s} {'etaL':6s} {'kap':6s}  ", end="")
    for t in range(1, 21):
        print(f"  T={t:2d}    ", end="")
    print()

    binding_summary = []
    table = {}
    for (cid, bs, es, ks) in corners:
        beta = mp.mpf(str(bs)); etaL = mp.mpf(str(es)); kappa = mp.mpf(str(ks))
        eta = etaL / L; mu = kappa * L
        verts = goujaud_vertices(beta, eta, mu, L)

        x_prev = lam * e_vec(0); x_curr = lam * e_vec(0)
        ratios = {}
        for t in range(1, 21):
            x_new = shb_step(x_curr, x_prev, eta, mu, beta, verts, L)
            x_prev = x_curr; x_curr = x_new
            n2 = x_curr[0,0]**2 + x_curr[1,0]**2
            f_floor = (mu / 2) * n2
            ratio = t * f_floor / (kappa * L * D * D)
            ratios[t] = float(ratio)
        table[cid] = {"beta": bs, "etaL": es, "kappa": ks, "ratios": ratios}
        print(f"{cid:12s}  {bs:<6} {es:<6} {ks:<6}  ", end="")
        for t in range(1, 21):
            print(f"{ratios[t]:>8.4f}  ", end="")
        print()

        rs = ratios
        binding_t = min(rs, key=lambda t: rs[t])
        min_r = rs[binding_t]
        binding_summary.append((cid, binding_t, min_r))

    # Per-corner binding T and min ratio
    print(f"\n{'corner':12s}  binding T   min ratio   c (=1/min)")
    for (cid, bt, mr) in binding_summary:
        print(f"{cid:12s}  {bt:>6d}      {mr:>8.4f}    {1/mr:>8.4f}")

    # Worst across all
    worst = min(binding_summary, key=lambda x: x[2])
    print(f"\nWORST CORNER: {worst[0]} with min ratio {worst[2]:.4f} -> uniform c = 1/{1/worst[2]:.2f}")

    # T>=10 analysis
    t10_min = min(table[cid]["ratios"][t] for cid in table for t in range(10, 21))
    print(f"\nMin ratio over t in [10, 20] across all corners+center: {t10_min:.4f}")
    print(f"So c >= 1/10 for T >= 10 (uniform on R*_ext_v3 corners)? {t10_min >= 0.1}")

    import json
    out_path = Path(__file__).parent / "gap1_ext_v3_bias_results.json"
    with open(out_path, "w") as f:
        json.dump({"box": [list(EXT3_BETA), list(EXT3_ETAL), list(EXT3_KAPPA)],
                   "table": table,
                   "binding_summary": [{"id": c, "binding_t": bt, "min_ratio": mr,
                                        "c_recip": 1/mr} for (c, bt, mr) in binding_summary],
                   "min_ratio_t_geq_10": t10_min}, f, indent=2)
    print(f"\nSaved to {out_path}")


if __name__ == "__main__":
    main()
