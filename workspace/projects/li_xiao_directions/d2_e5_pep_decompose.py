"""
Decompose the PEP UB into bias term (sigma=0) and variance term (D=0)
for various T and beta.  Fit the variance term to a constant + decay to
distinguish noise floor from sigma D / sqrt(T).
"""
import json
import numpy as np
from d2_e5_pep_shb import solve_pep_v2

def main():
    rows = []
    L = 1.0
    Ts = [3, 5, 8, 10, 12, 15, 20]
    betas = [0.0, 0.5, 0.9]
    etas = [0.5, 1.0]

    print("# Bias-only PEP (sigma = 0)")
    print(f"{'beta':>5} {'etaL':>5} {'T':>3} {'PEP_bias':>10} {'T*PEP':>10}")
    for beta in betas:
        for etaL in etas:
            for T in Ts:
                eta = etaL / L
                r = solve_pep_v2(T, beta, eta, L=L, D=1.0, sigma=0.0,
                                 mode="expectation", solver="SCS",
                                 max_iters=30000)
                v = r.get("value")
                if v is None:
                    continue
                rows.append({"kind": "bias", **r})
                print(f"{beta:5.2f} {etaL:5.2f} {T:3d} {v:10.4f} "
                      f"{T*v:10.4f}")
    print()
    print("# Variance-only PEP (D = 0, sigma = 1)")
    print(f"{'beta':>5} {'etaL':>5} {'T':>3} {'PEP_var':>10} "
          f"{'sqrt(T)*PEP':>13}")
    for beta in betas:
        for etaL in etas:
            for T in Ts:
                eta = etaL / L
                r = solve_pep_v2(T, beta, eta, L=L, D=0.0, sigma=1.0,
                                 mode="expectation", solver="SCS",
                                 max_iters=30000)
                v = r.get("value")
                if v is None:
                    continue
                rows.append({"kind": "var", **r})
                print(f"{beta:5.2f} {etaL:5.2f} {T:3d} {v:10.4f} "
                      f"{np.sqrt(T)*v:13.4f}")

    with open("d2_e5_pep_decompose.json", "w") as f:
        json.dump(rows, f, indent=2, default=str)


if __name__ == "__main__":
    main()
