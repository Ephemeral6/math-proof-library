"""Analyse cross_family_scoring_responses.json.

Reads the per-trial Opus / DeepSeek / Qwen scores produced by
cross_family_scoring.py and computes:

  (a) Opus vs DeepSeek   - Cohen's kappa (unweighted + quadratic) and Spearman rho
  (b) Opus vs Qwen       - same
  (c) DeepSeek vs Qwen   - same  (triangulation: how much do the two outsiders agree?)
  (d) per-condition agreement (baseline / RTC) for each pair
  (e) bias-direction: mean Delta = Opus_score - external_score, split by condition.
      If Opus is self-rating-biased on RTC, Delta_RTC > Delta_baseline.

No network calls and stdlib-only. scipy/sklearn are imported only as an optional
sanity cross-check, not as a hard dependency.

Usage:
    python cross_family_scoring_analysis.py
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RESPONSES_PATH = ROOT / "cross_family_scoring_responses.json"
OUT_JSON = ROOT / "cross_family_scoring_analysis.json"
OUT_MD = ROOT / "cross_family_scoring_analysis.md"

RATER_PAIRS = [
    ("opus", "deepseek"),
    ("opus", "qwen"),
    ("deepseek", "qwen"),
]
CONDITIONS = ("zero_cot", "coe_rtc")


def cohen_kappa(a: list[int], b: list[int], weights: str = "none") -> float | None:
    """Cohen's kappa, unweighted or quadratic-weighted.

    weights: 'none' or 'quadratic'.
    Returns None if too few data points or zero variance leaves Pe = 1.
    """
    if len(a) != len(b) or not a:
        return None
    cats = sorted(set(a) | set(b))
    k = len(cats)
    idx = {c: i for i, c in enumerate(cats)}
    n = len(a)

    obs = [[0] * k for _ in range(k)]
    for x, y in zip(a, b):
        obs[idx[x]][idx[y]] += 1

    row_sum = [sum(obs[i]) for i in range(k)]
    col_sum = [sum(obs[i][j] for i in range(k)) for j in range(k)]

    if weights == "none":
        w = [[0.0 if i == j else 1.0 for j in range(k)] for i in range(k)]
    elif weights == "quadratic":
        if k <= 1:
            return 1.0 if a == b else None
        denom = (k - 1) ** 2
        w = [[((cats[i] - cats[j]) ** 2) / denom for j in range(k)] for i in range(k)]
    else:
        raise ValueError(f"unknown weights: {weights!r}")

    po = sum(w[i][j] * obs[i][j] for i in range(k) for j in range(k)) / n
    pe = sum(w[i][j] * row_sum[i] * col_sum[j] / (n * n) for i in range(k) for j in range(k))
    if pe == 0 and po == 0:
        return 1.0  # perfect agreement on a single category
    if pe == 1:
        return None
    # For agreement-as-similarity we want 1 - po/pe scaled. Standard formula uses
    # disagreement weights (0 on diagonal). Convert: kappa = 1 - po/pe.
    return 1.0 - po / pe


def average_ranks(xs: list[float]) -> list[float]:
    """Mid-rank for ties (the rank used by Spearman with ties)."""
    n = len(xs)
    order = sorted(range(n), key=lambda i: xs[i])
    ranks = [0.0] * n
    i = 0
    while i < n:
        j = i
        while j + 1 < n and xs[order[j + 1]] == xs[order[i]]:
            j += 1
        avg = (i + j) / 2.0 + 1.0  # ranks are 1-based
        for m in range(i, j + 1):
            ranks[order[m]] = avg
        i = j + 1
    return ranks


def spearman_rho(a: list[float], b: list[float]) -> float | None:
    if len(a) != len(b) or len(a) < 2:
        return None
    ra = average_ranks(a)
    rb = average_ranks(b)
    n = len(a)
    mean_ra = sum(ra) / n
    mean_rb = sum(rb) / n
    num = sum((ra[i] - mean_ra) * (rb[i] - mean_rb) for i in range(n))
    den_a = math.sqrt(sum((ra[i] - mean_ra) ** 2 for i in range(n)))
    den_b = math.sqrt(sum((rb[i] - mean_rb) ** 2 for i in range(n)))
    if den_a == 0 or den_b == 0:
        return None
    return num / (den_a * den_b)


def mean(xs: list[float]) -> float | None:
    if not xs:
        return None
    return sum(xs) / len(xs)


def stdev(xs: list[float]) -> float | None:
    n = len(xs)
    if n < 2:
        return None
    m = sum(xs) / n
    return math.sqrt(sum((x - m) ** 2 for x in xs) / (n - 1))


def welch_t(a: list[float], b: list[float]) -> tuple[float | None, float | None]:
    """Welch's t and approximate two-sided p-value (normal approx)."""
    if len(a) < 2 or len(b) < 2:
        return None, None
    ma, mb = sum(a) / len(a), sum(b) / len(b)
    va = sum((x - ma) ** 2 for x in a) / (len(a) - 1)
    vb = sum((x - mb) ** 2 for x in b) / (len(b) - 1)
    se = math.sqrt(va / len(a) + vb / len(b))
    if se == 0:
        return None, None
    t = (ma - mb) / se
    # Crude two-sided p via standard normal CDF (n>=20 each side here, fine)
    p = 2.0 * (1.0 - 0.5 * (1.0 + math.erf(abs(t) / math.sqrt(2.0))))
    return t, p


def collect(trials: list[dict]) -> dict[str, list]:
    """Pull aligned score arrays per rater and per condition. Drop trials where any
    of the three scores is missing so every reported pair sees the same sample."""
    aligned: list[dict] = []
    dropped: list[dict] = []
    for t in trials:
        opus = t.get("opus_score")
        ds = t.get("scores", {}).get("deepseek")
        qw = t.get("scores", {}).get("qwen")
        if None in (opus, ds, qw):
            dropped.append(
                {
                    "trial_id": t.get("trial_id"),
                    "domain": t.get("domain"),
                    "case_id": t.get("case_id"),
                    "condition": t.get("condition"),
                    "opus": opus,
                    "deepseek": ds,
                    "qwen": qw,
                }
            )
            continue
        aligned.append(
            {
                "trial_id": t.get("trial_id"),
                "domain": t["domain"],
                "case_id": t["case_id"],
                "condition": t["condition"],
                "opus": opus,
                "deepseek": ds,
                "qwen": qw,
            }
        )
    return {"aligned": aligned, "dropped": dropped}


def pair_stats(aligned: list[dict], a: str, b: str, condition: str | None = None) -> dict:
    rows = aligned if condition is None else [r for r in aligned if r["condition"] == condition]
    sa = [r[a] for r in rows]
    sb = [r[b] for r in rows]
    return {
        "n": len(sa),
        "kappa_unweighted": cohen_kappa(sa, sb, weights="none"),
        "kappa_quadratic": cohen_kappa(sa, sb, weights="quadratic"),
        "spearman_rho": spearman_rho(sa, sb),
        "mean_a": mean(sa),
        "mean_b": mean(sb),
        "mean_diff_a_minus_b": (mean(sa) - mean(sb)) if sa and sb else None,
    }


def bias_table(aligned: list[dict], external: str) -> dict:
    """Bias direction: per condition compute Delta = Opus - external, then test if
    Delta_RTC > Delta_baseline (would indicate self-rating inflation on RTC)."""
    by_cond = {c: [] for c in CONDITIONS}
    for r in aligned:
        by_cond[r["condition"]].append(r["opus"] - r[external])
    base = by_cond["zero_cot"]
    rtc = by_cond["coe_rtc"]
    t, p = welch_t(rtc, base)
    return {
        "delta_baseline": {"n": len(base), "mean": mean(base), "stdev": stdev(base), "values": base},
        "delta_rtc": {"n": len(rtc), "mean": mean(rtc), "stdev": stdev(rtc), "values": rtc},
        "delta_diff_rtc_minus_baseline": (
            (mean(rtc) - mean(base)) if (base and rtc) else None
        ),
        "welch_t": t,
        "welch_p_two_sided": p,
        "interpretation": (
            "Delta_RTC - Delta_baseline > 0 with small p suggests Opus inflates RTC "
            "scores relative to outsiders (self-rating bias on RTC). "
            "If both Deltas are similar, no preferential bias on RTC is evident."
        ),
    }


def per_domain_breakdown(aligned: list[dict], external: str) -> dict[str, dict]:
    out: dict[str, dict] = {}
    for r in aligned:
        d = r["domain"]
        out.setdefault(d, {c: [] for c in CONDITIONS})
        out[d][r["condition"]].append(r["opus"] - r[external])
    flat: dict[str, dict] = {}
    for d, conds in out.items():
        flat[d] = {
            c: {"n": len(vals), "mean_delta": mean(vals)}
            for c, vals in conds.items()
        }
    return flat


def fmt(v, digits: int = 3) -> str:
    if v is None:
        return "n/a"
    if isinstance(v, float) and (v != v):  # NaN
        return "n/a"
    if isinstance(v, float):
        return f"{v:+.{digits}f}" if v < 0 else f"{v:.{digits}f}"
    return str(v)


def render_md(result: dict) -> str:
    lines: list[str] = []
    lines.append("# Cross-Family Scoring Analysis\n")
    lines.append(
        "**Question.** When DeepSeek and Qwen rescore Opus's responses, do they "
        "agree with Opus's self-ratings? And does Opus systematically inflate the "
        "RTC condition relative to the baseline (zero_cot) condition?\n"
    )
    lines.append(f"- Aligned trials (all three scores present): **{result['n_aligned']}**")
    lines.append(f"- Trials dropped (a score was missing): **{result['n_dropped']}**\n")

    lines.append("## Headline table\n")
    lines.append("Δ = Opus_score − External_score, computed per trial then averaged.\n")
    lines.append(
        "| Rater pair | Cohen's κ (unweighted) | Cohen's κ (quadratic) | Spearman ρ | Mean Δ (baseline) | Mean Δ (RTC) | Δ_RTC − Δ_baseline |"
    )
    lines.append(
        "|---|---|---|---|---|---|---|"
    )
    for a, b in RATER_PAIRS:
        overall = result["pairs"][f"{a}_vs_{b}"]["overall"]
        if a == "opus":
            bias = result["bias"][b]
            base = fmt(bias["delta_baseline"]["mean"])
            rtc = fmt(bias["delta_rtc"]["mean"])
            diff = fmt(bias["delta_diff_rtc_minus_baseline"])
        else:
            base = "—"
            rtc = "—"
            diff = "—"
        lines.append(
            f"| {a} vs {b} | {fmt(overall['kappa_unweighted'])} | "
            f"{fmt(overall['kappa_quadratic'])} | {fmt(overall['spearman_rho'])} | "
            f"{base} | {rtc} | {diff} |"
        )

    lines.append("\n## Per-condition agreement\n")
    lines.append("How much do the raters agree separately on the baseline and RTC slices?\n")
    lines.append(
        "| Rater pair | Condition | n | κ (unweighted) | κ (quadratic) | Spearman ρ |"
    )
    lines.append("|---|---|---|---|---|---|")
    for a, b in RATER_PAIRS:
        for cond in CONDITIONS:
            s = result["pairs"][f"{a}_vs_{b}"]["by_condition"][cond]
            lines.append(
                f"| {a} vs {b} | {cond} | {s['n']} | "
                f"{fmt(s['kappa_unweighted'])} | {fmt(s['kappa_quadratic'])} | "
                f"{fmt(s['spearman_rho'])} |"
            )

    lines.append("\n## Bias-direction test (the key question)\n")
    lines.append(
        "If Opus's self-rating bias on RTC is real, **Δ_RTC > Δ_baseline** "
        "(Opus says RTC is better than outsiders think it is, more than it does for "
        "baseline). If the two Δ's are comparable, no preferential RTC inflation is "
        "evident — the apparent RTC lift in the original n10 sweep would survive an "
        "outside grader.\n"
    )
    for ext in ("deepseek", "qwen"):
        bias = result["bias"][ext]
        lines.append(f"### Opus vs {ext}\n")
        lines.append(
            f"- Δ (baseline) = {fmt(bias['delta_baseline']['mean'])} "
            f"(SD {fmt(bias['delta_baseline']['stdev'])}, n={bias['delta_baseline']['n']})"
        )
        lines.append(
            f"- Δ (RTC) = {fmt(bias['delta_rtc']['mean'])} "
            f"(SD {fmt(bias['delta_rtc']['stdev'])}, n={bias['delta_rtc']['n']})"
        )
        lines.append(
            f"- Δ_RTC − Δ_baseline = {fmt(bias['delta_diff_rtc_minus_baseline'])} "
            f"(Welch t = {fmt(bias['welch_t'])}, two-sided p ≈ {fmt(bias['welch_p_two_sided'])})\n"
        )

    lines.append("\n## Per-domain Δ breakdown (Opus vs each external)\n")
    for ext in ("deepseek", "qwen"):
        lines.append(f"### Opus vs {ext}\n")
        lines.append("| Domain | Δ baseline (n) | Δ RTC (n) |")
        lines.append("|---|---|---|")
        domains = sorted(result["per_domain"][ext].keys())
        for d in domains:
            row = result["per_domain"][ext][d]
            base = row["zero_cot"]
            rtc = row["coe_rtc"]
            lines.append(
                f"| {d} | {fmt(base['mean_delta'])} ({base['n']}) | "
                f"{fmt(rtc['mean_delta'])} ({rtc['n']}) |"
            )
        lines.append("")

    if result["dropped_trials"]:
        lines.append("## Dropped trials (missing scores)\n")
        for d in result["dropped_trials"]:
            lines.append(
                f"- trial {d['trial_id']} {d['domain']}/{d['case_id']}/{d['condition']}: "
                f"opus={d['opus']} ds={d['deepseek']} qwen={d['qwen']}"
            )
        lines.append("")

    return "\n".join(lines)


def main() -> int:
    if not RESPONSES_PATH.exists():
        print(
            f"ERROR: {RESPONSES_PATH} not found. "
            "Run cross_family_scoring.py locally first.",
            file=sys.stderr,
        )
        return 2
    with open(RESPONSES_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    collected = collect(data["trials"])
    aligned = collected["aligned"]
    dropped = collected["dropped"]

    pairs: dict[str, dict] = {}
    for a, b in RATER_PAIRS:
        pairs[f"{a}_vs_{b}"] = {
            "overall": pair_stats(aligned, a, b),
            "by_condition": {c: pair_stats(aligned, a, b, condition=c) for c in CONDITIONS},
        }

    bias = {ext: bias_table(aligned, ext) for ext in ("deepseek", "qwen")}
    per_domain = {ext: per_domain_breakdown(aligned, ext) for ext in ("deepseek", "qwen")}

    result = {
        "experiment": "cross_family_scoring_analysis",
        "source": RESPONSES_PATH.name,
        "n_aligned": len(aligned),
        "n_dropped": len(dropped),
        "dropped_trials": dropped,
        "pairs": pairs,
        "bias": bias,
        "per_domain": per_domain,
        "method_notes": {
            "kappa_unweighted": "Standard Cohen's kappa with 0/1 disagreement weights.",
            "kappa_quadratic": "Quadratic-weighted Cohen's kappa (recommended for ordinal scales).",
            "spearman_rho": "Spearman correlation with mid-ranks for ties.",
            "delta": "Per-trial Opus - external; condition means reported.",
            "welch_p": (
                "Two-sided p from Welch's t-test on Δ_RTC vs Δ_baseline using a normal "
                "approximation. With n=24 per side this is rough; treat magnitudes as "
                "primary and p as a sanity check."
            ),
        },
    }

    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    md = render_md(result)
    with open(OUT_MD, "w", encoding="utf-8") as f:
        f.write(md)

    print(f"Wrote {OUT_JSON}")
    print(f"Wrote {OUT_MD}\n")
    print(md)
    return 0


if __name__ == "__main__":
    sys.exit(main())
