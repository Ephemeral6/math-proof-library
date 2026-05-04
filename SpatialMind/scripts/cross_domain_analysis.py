"""Cross-domain ablation analysis.

对比三个 domain（S_{1,2}, S_{2,1}, knot_theory）的 2³ factorial ablation 结果。

输入：每个 domain 的 ablation_results.md（人手写的，含分数表）。
输出：cross_domain_analysis.md（结构化对比 + main effects + interactions + Spearman）。

使用：
    python -m SpatialMind.scripts.cross_domain_analysis
    # or
    python SpatialMind/scripts/cross_domain_analysis.py

S_{2,1} 和 knot_theory 数据缺失时，对应列保持 None，输出标注 [TBD]。
"""
from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

ROOT = Path(__file__).parent.parent
BENCH = ROOT / "benchmarks"

# 8 个 ablation 条件，按 R/T/C 三位字符串命名。
CONDITIONS = ["000", "R00", "0T0", "00C", "RT0", "R0C", "0TC", "RTC"]


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

@dataclass
class DomainResult:
    name: str                         # 例如 "S_{1,2}"
    path: Path                        # ablation_results.md 路径
    scores: dict[str, Optional[float]] = field(default_factory=dict)  # 缺失 = None
    n_cases: Optional[int] = None
    notes: str = ""                   # 自由备注（例如 "T degenerate"）


# 行内匹配 "{condition}: {score} {label}" 的正则。
# 支持 "2(+)" 半级（S_{1,2} 的 R0C 是 PATTERN+，记 2.5）。
SCORE_RE = re.compile(
    r"\b(?P<cond>0{3}|R00|0T0|00C|RT0|R0C|0TC|RTC)"
    r"\s*:\s*(?P<score>\d)(?P<plus>\(\+\)|\+)?\b"
)


def parse_results(path: Path, name: str) -> DomainResult:
    """解析一个 ablation_results.md，提取 8 条件的得分。"""
    result = DomainResult(
        name=name, path=path,
        scores={c: None for c in CONDITIONS},
    )
    if not path.exists():
        result.notes = f"file missing: {path.relative_to(ROOT)}"
        return result

    text = path.read_text(encoding="utf-8")
    for m in SCORE_RE.finditer(text):
        cond = m.group("cond")
        score = int(m.group("score"))
        if m.group("plus"):
            score += 0.5  # PATTERN+ 等半级
        # 同一条件可能被多处 match（结果矩阵 + 主效应公式）；取首次出现的值。
        if result.scores.get(cond) is None:
            result.scores[cond] = float(score)

    # n_cases：寻找 "1,563" 等数字
    nm = re.search(r"(\d{1,3}(?:,\d{3})+|\d+)\s*(?:个 )?case", text)
    if nm:
        result.n_cases = int(nm.group(1).replace(",", ""))

    # 检查 8 条件齐全
    missing = [c for c in CONDITIONS if result.scores[c] is None]
    if missing:
        result.notes = f"missing conditions: {missing}"
    return result


# ---------------------------------------------------------------------------
# Main effects + interactions
# ---------------------------------------------------------------------------

def _avg(vals: list[Optional[float]]) -> Optional[float]:
    """对一组评分求均值，遇到 None 返回 None。"""
    if any(v is None for v in vals):
        return None
    return sum(vals) / len(vals)  # type: ignore[arg-type]


def main_effects(scores: dict[str, Optional[float]]) -> dict[str, Optional[float]]:
    """每个原语 ON 平均 vs OFF 平均的差。"""
    R_on = _avg([scores[c] for c in CONDITIONS if "R" in c])
    R_off = _avg([scores[c] for c in CONDITIONS if "R" not in c])
    T_on = _avg([scores[c] for c in CONDITIONS if "T" in c])
    T_off = _avg([scores[c] for c in CONDITIONS if "T" not in c])
    C_on = _avg([scores[c] for c in CONDITIONS if "C" in c])
    C_off = _avg([scores[c] for c in CONDITIONS if "C" not in c])

    def _diff(a, b):
        if a is None or b is None:
            return None
        return round(a - b, 4)

    return {
        "R": _diff(R_on, R_off),
        "T": _diff(T_on, T_off),
        "C": _diff(C_on, C_off),
    }


def interactions(scores: dict[str, Optional[float]]) -> dict[str, Optional[float]]:
    """二阶 superadditivity（pair − max(单)）+ 三阶 superadditivity（RTC − max(2-way)）。"""
    s = scores

    def _super(combo: str, parts: list[str]) -> Optional[float]:
        if s[combo] is None or any(s[p] is None for p in parts):
            return None
        return round(s[combo] - max(s[p] for p in parts), 4)  # type: ignore[arg-type]

    return {
        "R×C": _super("R0C", ["R00", "00C"]),
        "R×T": _super("RT0", ["R00", "0T0"]),
        "T×C": _super("0TC", ["0T0", "00C"]),
        "R×T×C": _super("RTC", ["RT0", "R0C", "0TC"]),
    }


# ---------------------------------------------------------------------------
# Spearman rank correlation (no scipy dependency — manual implementation)
# ---------------------------------------------------------------------------

def _ranks(xs: list[float]) -> list[float]:
    """Tied ranks (average of tied positions)."""
    sorted_idx = sorted(range(len(xs)), key=lambda i: xs[i])
    ranks = [0.0] * len(xs)
    i = 0
    while i < len(xs):
        j = i
        while j + 1 < len(xs) and xs[sorted_idx[j + 1]] == xs[sorted_idx[i]]:
            j += 1
        avg_rank = (i + j) / 2 + 1  # 1-indexed
        for k in range(i, j + 1):
            ranks[sorted_idx[k]] = avg_rank
        i = j + 1
    return ranks


def spearman(a: list[Optional[float]],
             b: list[Optional[float]]) -> tuple[Optional[float], Optional[float]]:
    """Spearman ρ + two-tailed approx p-value (t-distribution).

    Returns (None, None) if any input is None or n < 3.
    """
    pairs = [(x, y) for x, y in zip(a, b)
             if x is not None and y is not None]
    if len(pairs) < 3:
        return None, None
    xs = [p[0] for p in pairs]
    ys = [p[1] for p in pairs]
    rx, ry = _ranks(xs), _ranks(ys)

    n = len(rx)
    mean_x = sum(rx) / n
    mean_y = sum(ry) / n
    sxx = sum((r - mean_x) ** 2 for r in rx)
    syy = sum((r - mean_y) ** 2 for r in ry)
    sxy = sum((rx[i] - mean_x) * (ry[i] - mean_y) for i in range(n))
    if sxx == 0 or syy == 0:
        return None, None
    rho = sxy / (sxx * syy) ** 0.5

    # Approx p-value: t = ρ √((n−2)/(1−ρ²)) ~ t(n-2). Two-tailed.
    if abs(rho) >= 1.0:
        return round(rho, 4), 0.0
    t = rho * ((n - 2) / (1 - rho ** 2)) ** 0.5
    # Crude two-tailed p via Student t CDF approximation.
    # For small n this is approximate; report a category instead of exact.
    p = _student_t_two_tailed(t, n - 2)
    return round(rho, 4), round(p, 4)


def _student_t_two_tailed(t: float, df: int) -> float:
    """Cheap Student-t two-tailed p-value via beta-incomplete approximation.

    Adequate for n ≤ 8 (which is our case). Don't use for high precision.
    """
    import math
    x = df / (df + t * t)
    # incomplete beta I_x(df/2, 0.5) — implement via continued fraction
    a, b = df / 2, 0.5
    # Use the regularised incomplete beta via math.lgamma and a series.
    # For our small-df use case, lean on math.erfc + asymptotic approximation.
    # Practical shortcut: scipy-style approximation via normal CDF for df ≥ 8.
    if df >= 8:
        z = t * (1 - 1 / (4 * df)) / (1 + t * t / (2 * df)) ** 0.5
        return math.erfc(abs(z) / math.sqrt(2))
    # Series for the incomplete beta is overkill; use direct integration via simpson.
    n_steps = 2000
    h = x / n_steps

    def f(u):
        if u <= 0 or u >= 1:
            return 0
        return u ** (a - 1) * (1 - u) ** (b - 1)

    s = f(0 + 1e-9) + f(x - 1e-9)
    for k in range(1, n_steps):
        u = k * h
        s += (4 if k % 2 else 2) * f(u)
    integral = s * h / 3
    # Beta(a, b) normaliser
    log_beta = math.lgamma(a) + math.lgamma(b) - math.lgamma(a + b)
    return integral / math.exp(log_beta)


# ---------------------------------------------------------------------------
# Cohen's d (effect size for main effects)
# ---------------------------------------------------------------------------

def cohens_d_main(scores: dict[str, Optional[float]]) -> dict[str, Optional[float]]:
    """Cohen's d for each primitive's main effect.

    d = (mean_on − mean_off) / pooled_std.
    n = 4 in each group; pooled_std uses n−1 in denominator.
    """
    import math

    def _d(on_vals, off_vals):
        if any(v is None for v in on_vals + off_vals):
            return None
        m_on = sum(on_vals) / len(on_vals)
        m_off = sum(off_vals) / len(off_vals)
        var_on = sum((v - m_on) ** 2 for v in on_vals) / (len(on_vals) - 1)
        var_off = sum((v - m_off) ** 2 for v in off_vals) / (len(off_vals) - 1)
        pooled = ((var_on + var_off) / 2) ** 0.5
        if pooled == 0:
            return None
        return round((m_on - m_off) / pooled, 3)

    R_on = [scores[c] for c in CONDITIONS if "R" in c]
    R_off = [scores[c] for c in CONDITIONS if "R" not in c]
    T_on = [scores[c] for c in CONDITIONS if "T" in c]
    T_off = [scores[c] for c in CONDITIONS if "T" not in c]
    C_on = [scores[c] for c in CONDITIONS if "C" in c]
    C_off = [scores[c] for c in CONDITIONS if "C" not in c]
    return {"R": _d(R_on, R_off), "T": _d(T_on, T_off), "C": _d(C_on, C_off)}


# ---------------------------------------------------------------------------
# Markdown report
# ---------------------------------------------------------------------------

def _fmt(v: Optional[float], w: int = 6) -> str:
    if v is None:
        return "[TBD]"
    s = f"{v:+.2f}" if isinstance(v, float) else str(v)
    return s


def render_report(domains: list[DomainResult]) -> str:
    """生成 cross_domain_analysis.md 内容。"""
    lines: list[str] = []
    lines.append("# 跨 Domain 分析：空间认知原语的普适性")
    lines.append("")
    lines.append(f"**Generated by**: `scripts/cross_domain_analysis.py`")
    lines.append("**Inputs**: 每个 domain 的 `ablation_results.md`")
    lines.append("**Domains**:")
    for d in domains:
        status = (f"✓ {d.n_cases} cases" if d.n_cases
                  else "[TBD]" if not d.scores or all(v is None for v in d.scores.values())
                  else "partial")
        lines.append(f"- **{d.name}** — {d.path.relative_to(ROOT)} — {status}")
        if d.notes:
            lines.append(f"  - notes: {d.notes}")
    lines.append("")

    # Section 1: 8 conditions × N domains
    lines.append("## 1. 三个 domain 的 ablation 结果")
    lines.append("")
    header_cells = ["条件"] + [d.name for d in domains] + ["平均"]
    lines.append("| " + " | ".join(header_cells) + " |")
    lines.append("|" + "|".join(["------"] * len(header_cells)) + "|")
    for cond in CONDITIONS:
        row = [cond]
        vals = []
        for d in domains:
            v = d.scores.get(cond)
            row.append(_fmt(v))
            vals.append(v)
        if all(v is not None for v in vals):
            avg = sum(vals) / len(vals)  # type: ignore[arg-type]
            row.append(f"{avg:.2f}")
        else:
            row.append("[TBD]")
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")

    # Section 2: 主效应
    lines.append("## 2. 主效应对比（ON 平均 − OFF 平均）")
    lines.append("")
    me_per_domain = {d.name: main_effects(d.scores) for d in domains}
    cd_per_domain = {d.name: cohens_d_main(d.scores) for d in domains}
    header_cells = ["原语"] + [d.name for d in domains] + ["跨 domain 平均"]
    lines.append("| " + " | ".join(header_cells) + " |")
    lines.append("|" + "|".join(["------"] * len(header_cells)) + "|")
    for prim in ["R", "T", "C"]:
        row = [prim]
        vals = []
        for d in domains:
            v = me_per_domain[d.name][prim]
            row.append(_fmt(v))
            vals.append(v)
        if all(v is not None for v in vals):
            row.append(f"{sum(vals) / len(vals):+.2f}")  # type: ignore[arg-type]
        else:
            row.append("[TBD]")
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")

    # Cohen's d
    lines.append("**Cohen's d (effect size)**:")
    lines.append("")
    lines.append("| 原语 | " + " | ".join(d.name for d in domains) + " |")
    lines.append("|" + "------|" * (len(domains) + 1))
    for prim in ["R", "T", "C"]:
        row = [prim]
        for d in domains:
            v = cd_per_domain[d.name][prim]
            row.append("[TBD]" if v is None else f"{v:+.2f}")
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")

    # Section 3: 交互
    lines.append("## 3. 交互效应对比（superadditivity）")
    lines.append("")
    inter_per_domain = {d.name: interactions(d.scores) for d in domains}
    header_cells = ["交互"] + [d.name for d in domains] + ["跨 domain"]
    lines.append("| " + " | ".join(header_cells) + " |")
    lines.append("|" + "|".join(["------"] * len(header_cells)) + "|")
    for inter in ["R×C", "R×T", "T×C", "R×T×C"]:
        row = [inter]
        vals = []
        for d in domains:
            v = inter_per_domain[d.name][inter]
            row.append(_fmt(v))
            vals.append(v)
        if all(v is not None for v in vals):
            row.append(f"{sum(vals) / len(vals):+.2f}")  # type: ignore[arg-type]
        else:
            row.append("[TBD]")
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")
    lines.append("> **关键预测**：R×T×C 三阶超加性应为正且跨 domain 一致。"
                 "R×C / R×T / T×C 二阶交互预测 = 0（任意二元组合不跨 PATTERN→ARGUMENT 阈值）。")
    lines.append("")

    # Section 4: Spearman rank correlation
    lines.append("## 4. Spearman 排序相关")
    lines.append("")
    lines.append("| 对比 | ρ | p-value | 解释 |")
    lines.append("|------|-----|---------|------|")
    for i, da in enumerate(domains):
        for db in domains[i + 1:]:
            a_vals = [da.scores[c] for c in CONDITIONS]
            b_vals = [db.scores[c] for c in CONDITIONS]
            rho, p = spearman(a_vals, b_vals)
            label = (f"{da.name} ↔ {db.name}")
            if rho is None:
                lines.append(f"| {label} | [TBD] | [TBD] | "
                             f"等数据齐 |")
            else:
                lines.append(f"| {label} | {rho:+.3f} | {p:.3f} | "
                             f"{'同 domain' if 'S_' in da.name and 'S_' in db.name else '跨 domain'} |")
    lines.append("")

    # Section 5: 结论占位
    lines.append("## 5. 关键结论")
    lines.append("")
    lines.append("1. **主效应排序跨 domain 一致？**  ")
    if all(d.scores[CONDITIONS[0]] is not None for d in domains):
        # 排序 R/T/C 的 main effects
        ranks_per_d = {}
        for d in domains:
            me = me_per_domain[d.name]
            if all(v is not None for v in me.values()):
                ranks_per_d[d.name] = sorted(me.items(), key=lambda kv: -kv[1])  # type: ignore
        for name, r in ranks_per_d.items():
            order = " > ".join(f"{k} ({v:+.2f})" for k, v in r)
            lines.append(f"   - {name}: {order}")
    else:
        lines.append("   - [等所有 domain 数据填齐后填写]")
    lines.append("")
    lines.append("2. **三阶超加性（R×T×C）跨 domain 复现？**  ")
    rtc_vals = []
    for d in domains:
        v = inter_per_domain[d.name].get("R×T×C")
        if v is not None:
            rtc_vals.append((d.name, v))
    if rtc_vals:
        for name, v in rtc_vals:
            lines.append(f"   - {name}: R×T×C = {v:+.2f}"
                         f" ({'positive — replicated' if v > 0 else 'flat / negative'})")
    else:
        lines.append("   - [等数据]")
    lines.append("")
    lines.append("3. **T 在不退化的曲面上是否增大？**")
    s12 = next((d for d in domains if "1,2" in d.name), None)
    s21 = next((d for d in domains if "2,1" in d.name), None)
    if s12 and s21:
        t_12 = me_per_domain[s12.name]["T"]
        t_21 = me_per_domain[s21.name]["T"]
        if t_12 is not None and t_21 is not None:
            grew = t_21 > t_12
            lines.append(f"   - S_{{1,2}} T effect = {t_12:+.2f}")
            lines.append(f"   - S_{{2,1}} T effect = {t_21:+.2f}")
            lines.append(f"   - {'✓ T 增大，确认 surface-specific 退化' if grew else '✗ T 未增大，需重设计 T 数据'}")
        else:
            lines.append("   - [等 S_{2,1} 数据]")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def collect_domains() -> list[DomainResult]:
    """从约定路径读三个 domain 的结果。"""
    return [
        parse_results(
            BENCH / "surface_topology" / "ablation" / "ablation_results.md",
            "S_{1,2}",
        ),
        parse_results(
            BENCH / "surface_topology_s21" / "ablation" / "ablation_results.md",
            "S_{2,1}",
        ),
        parse_results(
            BENCH / "knot_theory" / "ablation" / "ablation_results.md",
            "Knot",
        ),
    ]


def main(argv: list[str] | None = None) -> int:
    domains = collect_domains()
    report = render_report(domains)
    # 写到 stats_auto.md（自动生成、可被重跑覆盖）。
    # 人手写的 narrative 在 cross_domain_analysis.md，由人工合并 / 引用。
    out_path = BENCH / "cross_domain_stats_auto.md"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(report, encoding="utf-8")
    print(f"Wrote {out_path.relative_to(ROOT)}")
    print(f"(narrative document is at {(BENCH / 'cross_domain_analysis.md').relative_to(ROOT)})")
    print()
    print("Domain status:")
    for d in domains:
        n_present = sum(1 for v in d.scores.values() if v is not None)
        status = "✓" if n_present == 8 else "partial" if n_present > 0 else "[TBD]"
        print(f"  {d.name}: {status} ({n_present}/8 conditions)")
        if d.notes:
            print(f"    note: {d.notes}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
