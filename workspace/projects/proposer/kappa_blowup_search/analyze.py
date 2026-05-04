"""Analyze raw_data.csv: fit kappa-exponents, identify genuine separations.

For each (function, beta, etaL, init, T, iterate_type), fit log10(f) vs log10(kappa).
Report:
  - kappa-exponent c, R^2
  - Pairwise iterate-type comparisons: log10(f_A/f_B) vs log10(kappa)
  - Genuine if R^2 > 0.99 across all kappa AND consistent across T.

Outputs:
  - exponents.csv: one row per (setting, iterate_type) with (c, R2)
  - separations.csv: one row per (setting, A, B) with c_A - c_B and R2 of ratio
  - genuine_phenomena.md: filtered separations
  - top_conjecture.md: strongest single conjecture
"""
import csv
import math
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))


def parse_fval(s):
    s = s.strip().lower()
    if s in ("inf", "+inf", "infinity"):
        return math.inf
    if s == "-inf":
        return -math.inf
    if s == "nan":
        return float("nan")
    try:
        return float(s)
    except ValueError:
        try:
            # mpmath nstr can produce scientific notation
            return float(s.replace(" ", ""))
        except Exception:
            return float("nan")


def load_csv(path):
    rows = []
    with open(path, newline="", encoding="utf-8") as fp:
        for r in csv.DictReader(fp):
            rows.append({
                "function": r["function"],
                "beta": float(r["beta"]),
                "etaL": float(r["etaL"]),
                "kappa": int(r["kappa"]),
                "init": r["init"],
                "T": int(r["T"]),
                "iterate_type": r["iterate_type"],
                "fvalue": parse_fval(r["fvalue"]),
            })
    return rows


def linear_regression(xs, ys):
    """Fit y = c x + b. Return (c, b, R2). Assume len(xs) >= 2."""
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    sxy = sum((xs[i] - mx) * (ys[i] - my) for i in range(n))
    syy = sum((y - my) ** 2 for y in ys)
    if sxx == 0:
        return 0.0, my, 0.0
    c = sxy / sxx
    b = my - c * mx
    if syy == 0:
        return c, b, 1.0
    ss_res = sum((ys[i] - c * xs[i] - b) ** 2 for i in range(n))
    r2 = 1.0 - ss_res / syy
    return c, b, r2


def group_data(rows):
    """Group by (function, beta, etaL, init, T, iterate_type) -> {kappa: fval}."""
    groups = defaultdict(dict)
    for r in rows:
        key = (r["function"], r["beta"], r["etaL"], r["init"],
               r["T"], r["iterate_type"])
        groups[key][r["kappa"]] = r["fvalue"]
    return groups


def fit_exponents(groups):
    """For each group, fit log10(f) vs log10(kappa). Skip if any value is non-finite or <=0."""
    results = []
    for key, kvmap in groups.items():
        kappas = sorted(kvmap.keys())
        xs = []
        ys = []
        skip = False
        for k in kappas:
            v = kvmap[k]
            if not math.isfinite(v) or v <= 0:
                skip = True
                break
            xs.append(math.log10(k))
            ys.append(math.log10(v))
        if skip or len(xs) < 2:
            results.append((key, None, None, None, kvmap))
            continue
        c, b, r2 = linear_regression(xs, ys)
        results.append((key, c, b, r2, kvmap))
    return results


def fit_separations(groups, min_fval=1e-30):
    """For each (function, beta, etaL, init, T) and pair of iterate types,
    fit log10(f_A / f_B) vs log10(kappa). Skip if any f-value is < min_fval (numerically zero)."""
    setting_groups = defaultdict(dict)  # (func,beta,etaL,init,T) -> {iter_type: {kappa: f}}
    for key, kvmap in groups.items():
        func, beta, etaL, init, T, it = key
        setting = (func, beta, etaL, init, T)
        setting_groups[setting][it] = kvmap

    iter_types = ["last", "cesaro", "pr", "suffix", "best"]
    results = []
    for setting, by_it in setting_groups.items():
        for i, A in enumerate(iter_types):
            for B in iter_types[i + 1:]:
                if A not in by_it or B not in by_it:
                    continue
                kvA = by_it[A]
                kvB = by_it[B]
                kappas = sorted(set(kvA.keys()) & set(kvB.keys()))
                xs, ys = [], []
                ratio_data = {}
                fval_data = {}
                skip = False
                for k in kappas:
                    a, b = kvA[k], kvB[k]
                    if not (math.isfinite(a) and math.isfinite(b)) or a <= 0 or b <= 0:
                        skip = True
                        break
                    if a < min_fval or b < min_fval:
                        skip = True  # one or both have converged to numerical zero
                        break
                    xs.append(math.log10(k))
                    ys.append(math.log10(a / b))
                    ratio_data[k] = a / b
                    fval_data[k] = (a, b)
                if skip or len(xs) < 3:
                    continue
                c, intercept, r2 = linear_regression(xs, ys)
                # log-range of ratios: how much do ratios actually vary?
                log_ratios = [math.log10(r) for r in ratio_data.values()]
                ratio_range = max(log_ratios) - min(log_ratios)
                results.append({
                    "setting": setting,
                    "A": A,
                    "B": B,
                    "exp_diff": c,
                    "R2": r2,
                    "ratio_at_kappa": ratio_data,
                    "fval_at_kappa": fval_data,
                    "log_ratio_range": ratio_range,
                })
    return results


def write_exponents(results, path):
    with open(path, "w", newline="", encoding="utf-8") as fp:
        w = csv.writer(fp)
        w.writerow(["function", "beta", "etaL", "init", "T", "iterate_type",
                    "kappa_exp", "R2", "f_at_k10", "f_at_k100",
                    "f_at_k1000", "f_at_k10000"])
        for key, c, b, r2, kvmap in results:
            func, beta, etaL, init, T, it = key
            row = [func, beta, etaL, init, T, it,
                   f"{c:.4f}" if c is not None else "",
                   f"{r2:.4f}" if r2 is not None else "",
                   kvmap.get(10, ""), kvmap.get(100, ""),
                   kvmap.get(1000, ""), kvmap.get(10000, "")]
            w.writerow(row)


def write_separations(seps, path, only_significant=False):
    with open(path, "w", newline="", encoding="utf-8") as fp:
        w = csv.writer(fp)
        w.writerow(["function", "beta", "etaL", "init", "T", "A", "B",
                    "exp_diff", "R2",
                    "ratio_k10", "ratio_k100", "ratio_k1000", "ratio_k10000"])
        for s in seps:
            func, beta, etaL, init, T = s["setting"]
            if only_significant and (abs(s["exp_diff"]) < 0.5 or s["R2"] < 0.99):
                continue
            r = s["ratio_at_kappa"]
            w.writerow([func, beta, etaL, init, T, s["A"], s["B"],
                        f"{s['exp_diff']:.4f}", f"{s['R2']:.4f}",
                        f"{r.get(10, 0):.6e}", f"{r.get(100, 0):.6e}",
                        f"{r.get(1000, 0):.6e}", f"{r.get(10000, 0):.6e}"])


def find_genuine(seps, exp_thresh=0.5, r2_thresh=0.99, min_log_range=1.0):
    """Genuine: |exp_diff| > thresh, R^2 > r2_thresh, ratios actually span at least min_log_range orders."""
    return [s for s in seps
            if abs(s["exp_diff"]) > exp_thresh
            and s["R2"] > r2_thresh
            and s["log_ratio_range"] > min_log_range]


def find_T_stable(seps_genuine, tol=0.15):
    """Group by (func, beta, etaL, init, A, B) across T values; require all T to give similar exp_diff."""
    by_key = defaultdict(dict)  # key -> {T: (exp_diff, R2)}
    for s in seps_genuine:
        func, beta, etaL, init, T = s["setting"]
        k = (func, beta, etaL, init, s["A"], s["B"])
        by_key[k][T] = (s["exp_diff"], s["R2"])
    stable = []
    for k, by_T in by_key.items():
        if len(by_T) < 2:
            continue
        diffs = [v[0] for v in by_T.values()]
        if max(diffs) - min(diffs) < tol:
            stable.append({
                "key": k,
                "by_T": by_T,
                "mean_exp": sum(diffs) / len(diffs),
                "spread": max(diffs) - min(diffs),
            })
    return stable


def main(csv_path):
    print(f"Loading {csv_path}...")
    rows = load_csv(csv_path)
    print(f"  {len(rows)} rows")
    groups = group_data(rows)
    print(f"  {len(groups)} (setting, iterate_type) groups")

    expr = fit_exponents(groups)
    write_exponents(expr, os.path.join(HERE, "exponents.csv"))
    valid_exp = [r for r in expr if r[1] is not None]
    print(f"  {len(valid_exp)} valid exponent fits (positive, finite at all kappa)")

    seps = fit_separations(groups)
    write_separations(seps, os.path.join(HERE, "separations_all.csv"))
    print(f"  {len(seps)} separation fits")

    genuine = find_genuine(seps, exp_thresh=0.5, r2_thresh=0.99)
    write_separations(genuine, os.path.join(HERE, "separations_genuine.csv"))
    print(f"  {len(genuine)} genuine (|exp_diff|>0.5, R^2>0.99)")

    stable = find_T_stable(genuine, tol=0.15)
    print(f"  {len(stable)} T-stable (across at least 2 T values, spread<0.15)")

    # Sort by |mean_exp| descending
    stable.sort(key=lambda s: -abs(s["mean_exp"]))
    return expr, seps, genuine, stable


if __name__ == "__main__":
    import sys
    csv_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "raw_data.csv")
    expr, seps, genuine, stable = main(csv_path)
    print("\nTop 30 stable separations by |exp_diff|:")
    for s in stable[:30]:
        func, beta, etaL, init, A, B = s["key"]
        print(f"  {func} b={beta} eL={etaL} {init} | f({A})/f({B}) ~ kappa^{s['mean_exp']:+.3f} "
              f"(spread {s['spread']:.3f}, T-values: {sorted(s['by_T'].keys())})")
