"""Generate all paper figures and tables from ablation data.

Outputs:
  SpatialMind/paper/figures/{fig1..fig5}.{pdf,png}
  SpatialMind/paper/tables/{table1,table2}.tex
"""
from __future__ import annotations

import os
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch
from tabulate import tabulate

# ---------------------------------------------------------------------------
# Paths & global style
# ---------------------------------------------------------------------------
ROOT = Path(__file__).resolve().parents[1] / "paper"
FIG_DIR = ROOT / "figures"
TAB_DIR = ROOT / "tables"
FIG_DIR.mkdir(parents=True, exist_ok=True)
TAB_DIR.mkdir(parents=True, exist_ok=True)

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["DejaVu Serif", "Times New Roman", "Times"],
    "mathtext.fontset": "stix",
    "axes.labelsize": 11,
    "axes.titlesize": 12,
    "xtick.labelsize": 10,
    "ytick.labelsize": 10,
    "legend.fontsize": 9,
    "axes.linewidth": 0.8,
    "axes.edgecolor": "#333333",
    "figure.dpi": 150,
})

# Nature/Science cool palette (8 domains)
COOL_PALETTE = [
    "#08306b",  # deep navy
    "#1f5fa8",  # blue
    "#3787c0",  # mid blue
    "#6baed6",  # light blue
    "#2c7e7b",  # teal-dark
    "#41ae76",  # teal-green
    "#74c476",  # mint
    "#9e9ac8",  # cool violet
]

# ---------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------
CONDITIONS = ["000", "R00", "0T0", "00C", "RT0", "R0C", "0TC", "RTC"]
DOMAINS = [
    "Surf$_{1,2}$",
    "Surf$_{2,1}$",
    "Knot",
    "Sym",
    "Graph",
    "Curv",
    "Proj",
    "Pick",
]
DOMAINS_PLAIN = ["Surf_{1,2}", "Surf_{2,1}", "Knot", "Sym", "Graph", "Curv", "Proj", "Pick"]

# Score matrix: rows=domains, cols=conditions
# Order of conditions matches CONDITIONS list above.
# Source of truth: per-domain ablation_results.md (re-synced 2026-05-01).
# Convention: integer rubric values 0..4. PATTERN+/PATTERN− are textual
# qualifiers in the MDs but quantitatively round to PATTERN=2 / WRONG=1
# respectively, matching how each per-domain MD computes its main effects.
# (Earlier versions of this script encoded PATTERN+ as 2.5 for two surface
# rows, which produced figures that disagreed with the per-domain MDs by
# ±0.125 per main effect; that fractional encoding has been removed.)
SCORES = np.array([
    [0,   2,   0,   2,   2,   2,   2,   3],   # Surf_{1,2}  (R0C 2.5→2 to match MD)
    [2,   2,   2,   2,   3,   2,   2,   3],   # Surf_{2,1}  (R0C 2.5→2 to match MD)
    [1,   2,   2,   2,   2,   3,   2,   3],   # Knot
    [2,   4,   3,   2,   4,   4,   3,   4],   # Sym         (resynced 2026-05-01)
    [1,   4,   3,   3,   4,   4,   4,   4],   # Graph
    [2,   2,   2,   2,   2,   3,   2,   3],   # Curv
    [2,   3,   3,   2,   4,   4,   3,   4],   # Proj        (resynced 2026-05-01)
    [1,   3,   3,   3,   4,   4,   3,   4],   # Pick
])

def _compute_main_effects():
    """Standard 2^3 main effects: mean over levels where the primitive is ON
    minus mean over levels where it is OFF, for each domain row."""
    on_idx = {
        "R": [COND_IDX[c] for c in ("R00", "RT0", "R0C", "RTC")],
        "T": [COND_IDX[c] for c in ("0T0", "RT0", "0TC", "RTC")],
        "C": [COND_IDX[c] for c in ("00C", "R0C", "0TC", "RTC")],
    }
    off_idx = {
        "R": [COND_IDX[c] for c in ("000", "0T0", "00C", "0TC")],
        "T": [COND_IDX[c] for c in ("000", "R00", "00C", "R0C")],
        "C": [COND_IDX[c] for c in ("000", "R00", "0T0", "RT0")],
    }
    return {p: (SCORES[:, on_idx[p]].mean(axis=1)
                - SCORES[:, off_idx[p]].mean(axis=1)).tolist()
            for p in ("R", "T", "C")}


# Index helpers (defined before MAIN_EFFECTS so the helper above can use them)
COND_IDX = {c: i for i, c in enumerate(CONDITIONS)}
MAIN_EFFECTS = _compute_main_effects()

ARGUMENT_MIN = {
    "Surf$_{1,2}$": "RTC",
    "Surf$_{2,1}$": "RT",
    "Knot":         "RC",
    "Sym":          "R or T",        # resynced: 0T0=3 now reaches ARGUMENT
    "Graph":        "R or T or C",   # all single primitives suffice (R00=4, 0T0=3, 00C=3)
    "Curv":         "RC",
    "Proj":         "R or T",        # resynced: R00=3, 0T0=3 both reach ARGUMENT
    "Pick":         "R or T or C",   # all single primitives suffice (R00=3, 0T0=3, 00C=3)
}


def s(domain_idx: int, cond: str) -> float:
    return SCORES[domain_idx, COND_IDX[cond]]


# ---------------------------------------------------------------------------
# Figure 1 — CoE framework
# ---------------------------------------------------------------------------
def figure1():
    fig, ax = plt.subplots(figsize=(10, 5.2))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5.2)
    ax.axis("off")

    # LLM box (left)
    llm_box = FancyBboxPatch(
        (0.4, 1.6), 2.6, 2.0,
        boxstyle="round,pad=0.08,rounding_size=0.18",
        linewidth=1.5, edgecolor="#1f5fa8", facecolor="#e8f1fb",
    )
    ax.add_patch(llm_box)
    ax.text(1.7, 2.85, "LLM", ha="center", va="center",
            fontsize=14, fontweight="bold", color="#08306b")
    ax.text(1.7, 2.35, "Language Reasoning",
            ha="center", va="center", fontsize=10, color="#08306b", style="italic")

    # Engine box (right)
    eng_box = FancyBboxPatch(
        (7.0, 1.6), 2.6, 2.0,
        boxstyle="round,pad=0.08,rounding_size=0.18",
        linewidth=1.5, edgecolor="#2c7e7b", facecolor="#e6f4f1",
    )
    ax.add_patch(eng_box)
    ax.text(8.3, 2.85, "Domain Engine", ha="center", va="center",
            fontsize=14, fontweight="bold", color="#0f3a37")
    ax.text(8.3, 2.35, "Geometric Simulator",
            ha="center", va="center", fontsize=10, color="#0f3a37", style="italic")

    # Three left-going arrows (Engine -> LLM)
    flows = [
        (4.05, "R  (Relation)",
         "structural data: intersections, orbits, distances", "#1f5fa8"),
        (3.10, "T  (Transform)",
         "operation traces: surgery steps, group actions",   "#41ae76"),
        (2.15, "C  (Contrastive)",
         "counterfactuals: boundary cases, violations",      "#9e9ac8"),
    ]
    for y, label, sub, color in flows:
        arrow = FancyArrowPatch(
            (7.0, y), (3.0, y),
            arrowstyle="-|>", mutation_scale=18,
            linewidth=1.6, color=color,
        )
        ax.add_patch(arrow)
        ax.text(5.0, y + 0.18, label, ha="center", va="bottom",
                fontsize=10.5, fontweight="bold", color=color)
        ax.text(5.0, y - 0.18, sub, ha="center", va="top",
                fontsize=8.6, color="#444444", style="italic")

    # Feedback arrow (LLM -> Engine), curved below
    fb = FancyArrowPatch(
        (3.0, 1.40), (7.0, 1.40),
        connectionstyle="arc3,rad=-0.32",
        arrowstyle="-|>", mutation_scale=16,
        linewidth=1.3, color="#666666", linestyle="--",
    )
    ax.add_patch(fb)
    ax.text(5.0, 0.55, "queries",
            ha="center", va="center", fontsize=9.5,
            color="#444444", style="italic")

    # CTR caption box (dashed, bottom)
    ctr = FancyBboxPatch(
        (0.4, 0.04), 9.2, 0.42,
        boxstyle="round,pad=0.02,rounding_size=0.06",
        linewidth=1.0, edgecolor="#333333", facecolor="#fafafa",
        linestyle="--",
    )
    ax.add_patch(ctr)
    ax.text(5.0, 0.25,
            "CTR: Construct–Transform–Reason   (geometric instantiation of CoE)",
            ha="center", va="center", fontsize=9.5, color="#333333")

    # Title
    ax.text(5.0, 4.85, "Cognition-on-Engine (CoE) framework",
            ha="center", va="center", fontsize=13, fontweight="bold",
            color="#222222")

    fig.tight_layout()
    _save(fig, "fig1_coe_framework")


# ---------------------------------------------------------------------------
# Figure 2 — 2^3 ablation heatmap
# ---------------------------------------------------------------------------
def figure2():
    short_names = [r"Surf$_{1,2}$", r"Surf$_{2,1}$", "Knot", "Sym",
                   "Graph", "Curv", "Proj", "Pick"]

    cmap = LinearSegmentedColormap.from_list(
        "coe_blues", ["#ffffff", "#deebf7", "#9ecae1", "#3787c0", "#08306b"]
    )

    # Plot rows = conditions (8), cols = domains (8)
    M = SCORES.T  # (8 conds, 8 doms)

    fig, ax = plt.subplots(figsize=(7.2, 6.4))
    im = ax.imshow(M, cmap=cmap, vmin=0, vmax=4, aspect="equal")

    ax.set_xticks(np.arange(len(short_names)))
    ax.set_xticklabels(short_names, rotation=30, ha="right")
    ax.set_yticks(np.arange(len(CONDITIONS)))
    ax.set_yticklabels(CONDITIONS, fontfamily="monospace")

    ax.set_xlabel("Domain")
    ax.set_ylabel("Condition (R T C bitmask)")
    ax.set_title("$2^3$ ablation score matrix")

    # cell annotations
    for i in range(M.shape[0]):
        for j in range(M.shape[1]):
            val = M[i, j]
            color = "white" if val >= 2.5 else "#222222"
            txt = f"{val:g}"
            ax.text(j, i, txt, ha="center", va="center",
                    fontsize=10, color=color)

    # Tidy borders
    ax.set_xticks(np.arange(M.shape[1] + 1) - 0.5, minor=True)
    ax.set_yticks(np.arange(M.shape[0] + 1) - 0.5, minor=True)
    ax.grid(which="minor", color="#cccccc", linewidth=0.4)
    ax.tick_params(which="minor", bottom=False, left=False)

    cb = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cb.set_label("Score (0 = ground truth fail, 4 = full proof)")
    cb.set_ticks([0, 1, 2, 3, 4])

    fig.tight_layout()
    _save(fig, "fig2_ablation_heatmap")


# ---------------------------------------------------------------------------
# Figure 3 — Main effects grouped bars
# ---------------------------------------------------------------------------
def figure3():
    primitives = ["R", "T", "C"]
    n_dom = len(DOMAINS)
    n_prim = len(primitives)
    width = 0.10
    offsets = (np.arange(n_dom) - (n_dom - 1) / 2) * width
    x = np.arange(n_prim)

    fig, ax = plt.subplots(figsize=(9.2, 5.0))
    for d_idx, dom in enumerate(DOMAINS):
        vals = [MAIN_EFFECTS[p][d_idx] for p in primitives]
        ax.bar(x + offsets[d_idx], vals, width=width,
               color=COOL_PALETTE[d_idx], edgecolor="white",
               linewidth=0.4, label=dom)

    ax.set_xticks(x)
    ax.set_xticklabels(primitives, fontsize=12, fontweight="bold")
    ax.set_xlabel("Primitive")
    ax.set_ylabel("Main effect (avg score gain)")
    ax.set_title("Main effects of R, T, C primitives across domains")
    ax.axhline(0, color="#666666", linewidth=0.6)
    ax.set_ylim(0, max(max(MAIN_EFFECTS[p]) for p in primitives) + 0.4)
    ax.grid(axis="y", linestyle="--", linewidth=0.4, color="#cccccc", alpha=0.7)
    ax.set_axisbelow(True)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.12),
              ncol=4, frameon=False)
    fig.tight_layout()
    _save(fig, "fig3_main_effects")


# ---------------------------------------------------------------------------
# Figure 4 — Two-way interactions
# ---------------------------------------------------------------------------
def _interactions():
    """Compute R*T, R*C, T*C interaction per domain."""
    inter = {"R$\\times$T": [], "R$\\times$C": [], "T$\\times$C": []}
    for d in range(len(DOMAINS)):
        rt = s(d, "RT0") - s(d, "R00") - s(d, "0T0") + s(d, "000")
        rc = s(d, "R0C") - s(d, "R00") - s(d, "00C") + s(d, "000")
        tc = s(d, "0TC") - s(d, "0T0") - s(d, "00C") + s(d, "000")
        inter["R$\\times$T"].append(rt)
        inter["R$\\times$C"].append(rc)
        inter["T$\\times$C"].append(tc)
    return inter


def figure4():
    inter = _interactions()
    keys = list(inter.keys())
    n_dom = len(DOMAINS)
    width = 0.10
    offsets = (np.arange(n_dom) - (n_dom - 1) / 2) * width
    x = np.arange(len(keys))

    fig, ax = plt.subplots(figsize=(9.2, 5.0))
    for d_idx, dom in enumerate(DOMAINS):
        vals = [inter[k][d_idx] for k in keys]
        ax.bar(x + offsets[d_idx], vals, width=width,
               color=COOL_PALETTE[d_idx], edgecolor="white",
               linewidth=0.4, label=dom)

    ax.set_xticks(x)
    ax.set_xticklabels(keys, fontsize=12, fontweight="bold")
    ax.set_xlabel("Two-way interaction")
    ax.set_ylabel("Interaction effect")
    ax.set_title("Second-order interactions of R, T, C primitives")
    ax.axhline(0, color="#333333", linewidth=0.7)
    ax.grid(axis="y", linestyle="--", linewidth=0.4, color="#cccccc", alpha=0.7)
    ax.set_axisbelow(True)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.12),
              ncol=4, frameon=False)
    fig.tight_layout()
    _save(fig, "fig4_interactions")
    return inter


# ---------------------------------------------------------------------------
# Figure 5 — ARGUMENT minimum-condition grid
# ---------------------------------------------------------------------------
def figure5():
    primitives = ["R", "T", "C"]

    def membership(combo: str) -> list[int]:
        # combo is like "RTC" / "RT" / "RC" / "R" or "RT or RC"
        # For "or" combos we colour the union (any primitive that appears
        # in either combo is shown), but record both labels at the right.
        pieces = [c.strip() for c in combo.split("or")]
        union = set("".join(pieces))
        return [1 if p in union else 0 for p in primitives]

    grid = np.array([membership(ARGUMENT_MIN[d]) for d in DOMAINS])

    fig, ax = plt.subplots(figsize=(7.4, 5.4))

    for i in range(grid.shape[0]):
        for j in range(grid.shape[1]):
            in_set = grid[i, j] == 1
            color = "#1f5fa8" if in_set else "#eef3f7"
            edge = "#08306b" if in_set else "#bcccdc"
            rect = mpatches.Rectangle(
                (j - 0.45, i - 0.45), 0.9, 0.9,
                facecolor=color, edgecolor=edge, linewidth=1.0,
            )
            ax.add_patch(rect)
            mark = primitives[j]
            ax.text(j, i, mark,
                    ha="center", va="center",
                    fontsize=12, fontweight="bold",
                    color="white" if in_set else "#88a0b3")

    ax.set_xlim(-0.6, len(primitives) - 0.4 + 1.6)  # space for label column
    ax.set_ylim(len(DOMAINS) - 0.5, -0.5)  # invert y
    ax.set_xticks(range(len(primitives)))
    ax.set_xticklabels(primitives, fontsize=12, fontweight="bold")
    ax.set_yticks(range(len(DOMAINS)))
    ax.set_yticklabels(DOMAINS)
    ax.set_xlabel("Primitive")
    ax.set_title("Minimal primitive set for ARGUMENT$\\geq$3")

    # Right-side label: written minimal combination
    for i, dom in enumerate(DOMAINS):
        ax.text(len(primitives) + 0.1, i,
                ARGUMENT_MIN[dom],
                ha="left", va="center",
                fontsize=10, color="#222222", fontfamily="monospace")

    # Hide top/right spines
    for spine in ("top", "right"):
        ax.spines[spine].set_visible(False)
    ax.tick_params(axis="x", which="both", length=0)
    ax.tick_params(axis="y", which="both", length=0)
    ax.set_aspect("equal", adjustable="box")

    fig.tight_layout()
    _save(fig, "fig5_argument_minset")


# ---------------------------------------------------------------------------
# Table 1 — full results
# ---------------------------------------------------------------------------
def table1(inter):
    # Build a comprehensive table: each domain x (8 cond scores | R, T, C main | RxT, RxC, TxC)
    headers = (
        ["Domain"]
        + CONDITIONS
        + ["R", "T", "C", r"R$\times$T", r"R$\times$C", r"T$\times$C", "Min. set"]
    )
    rows = []
    for i, dom in enumerate(DOMAINS_PLAIN):
        row = [f"$\\mathrm{{{dom}}}$"]
        row += [f"{SCORES[i, j]:g}" for j in range(SCORES.shape[1])]
        row += [f"{MAIN_EFFECTS['R'][i]:+.3f}",
                f"{MAIN_EFFECTS['T'][i]:+.3f}",
                f"{MAIN_EFFECTS['C'][i]:+.3f}"]
        row += [f"{inter['R$\\times$T'][i]:+.2f}",
                f"{inter['R$\\times$C'][i]:+.2f}",
                f"{inter['T$\\times$C'][i]:+.2f}"]
        row += [ARGUMENT_MIN[DOMAINS[i]].replace("$_{1,2}$", "")
                                       .replace("$_{2,1}$", "")]
        rows.append(row)

    colalign = ["left"] + ["center"] * (len(headers) - 2) + ["left"]
    body = tabulate(rows, headers=headers, tablefmt="latex_raw",
                    colalign=colalign, disable_numparse=True)
    # Wrap for paper: change to a small table*; add caption + label
    tex = (
        "% Auto-generated by SpatialMind/scripts/generate_paper_figures.py\n"
        "\\begin{table*}[t]\n"
        "\\centering\n"
        "\\caption{Full $2^3$ ablation results across eight low-dimensional\n"
        "  topology / discrete-geometry domains. Columns 2--9 give raw scores\n"
        "  (0--4) for each condition (\\texttt{000}=baseline,\n"
        "  \\texttt{RTC}=full CoE). The next three columns are main effects of\n"
        "  the R, T, C primitives, followed by the three two-way interactions\n"
        "  $R{\\times}T$, $R{\\times}C$, $T{\\times}C$. The last column lists\n"
        "  the minimal primitive subset needed to reach an ARGUMENT-level\n"
        "  proof ($\\ge 3$).}\n"
        "\\label{tab:full-results}\n"
        "\\small\n"
        f"{body}\n"
        "\\end{table*}\n"
    )
    (TAB_DIR / "table1_full_results.tex").write_text(tex, encoding="utf-8")


# ---------------------------------------------------------------------------
# Table 2 — comparison with related work
# ---------------------------------------------------------------------------
def table2():
    headers = ["Method", "External Engine", "Domain-Specific",
               "Training-Free", "Factorial Ablation", "Multi-Domain"]
    chk = r"\checkmark"
    cross = r"$\times$"
    rows = [
        ["CoE (Ours)",       chk, chk,   chk,   chk,   chk],
        ["CoT",              cross, cross, chk, cross, chk],
        ["ToRA",             f"{chk} (generic)", cross, cross, cross, chk],
        ["AlphaGeometry",    chk, chk,   cross, cross, cross],
        ["Cognitive Tools",  f"{cross} (internal)", cross, chk, cross, chk],
        ["Embodied-LM",      chk, cross, chk,   cross, cross],
    ]
    body = tabulate(rows, headers=headers, tablefmt="latex_raw",
                    stralign="center", numalign="center")
    tex = (
        "% Auto-generated by SpatialMind/scripts/generate_paper_figures.py\n"
        "\\begin{table}[t]\n"
        "\\centering\n"
        "\\caption{Comparison with related neuro-symbolic / tool-augmented\n"
        "  reasoning frameworks. CoE is the only framework that simultaneously\n"
        "  uses a domain-specific external engine, requires no fine-tuning,\n"
        "  is studied via a full factorial ablation, and is evaluated across\n"
        "  multiple low-dimensional geometry domains.}\n"
        "\\label{tab:related-work}\n"
        "\\small\n"
        f"{body}\n"
        "\\end{table}\n"
    )
    (TAB_DIR / "table2_related_work.tex").write_text(tex, encoding="utf-8")


# ---------------------------------------------------------------------------
# Figure 6 — domain example sketches (2x4 grid)
# ---------------------------------------------------------------------------
DOMAIN_INTUITION = {
    "Surf$_{1,2}$": "topology / invariant",
    "Surf$_{2,1}$": "topology / invariant",
    "Knot":         "topology / invariant",
    "Sym":          "symmetry",
    "Graph":        "deformation",
    "Curv":         "local $\\to$ global",
    "Proj":         "dimension",
    "Pick":         "boundary",
}


def _draw_punctured_torus(ax, genus: int, n_punctures: int):
    """Schematic of a genus-g surface with n punctures."""
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.0, 1.0)
    ax.set_ylim(-0.6, 0.6)

    if genus == 1:
        # one torus: outer ellipse + inner hole
        outer = mpatches.Ellipse((0, 0), 1.6, 0.95,
                                 fill=True, facecolor="#dde7f2",
                                 edgecolor="#08306b", linewidth=1.2)
        inner = mpatches.Ellipse((0, -0.05), 0.55, 0.18,
                                 fill=True, facecolor="white",
                                 edgecolor="#08306b", linewidth=1.0)
        ax.add_patch(outer)
        ax.add_patch(inner)
        # puncture as red x
        for k in range(n_punctures):
            x = 0.55 - 0.1 * k
            ax.plot([x - 0.06, x + 0.06], [0.22, 0.34],
                    color="#d62728", linewidth=1.4)
            ax.plot([x - 0.06, x + 0.06], [0.34, 0.22],
                    color="#d62728", linewidth=1.4)
    elif genus == 2:
        # two-torus: two overlapping ellipses, two holes
        for cx in (-0.42, 0.42):
            outer = mpatches.Ellipse((cx, 0), 1.05, 0.85,
                                     fill=True, facecolor="#dde7f2",
                                     edgecolor="#08306b", linewidth=1.2)
            ax.add_patch(outer)
        # join (re-fill the centre)
        join = mpatches.Rectangle((-0.18, -0.35), 0.36, 0.7,
                                   fill=True, facecolor="#dde7f2",
                                   edgecolor="none")
        ax.add_patch(join)
        # outline pass for the join area (top + bottom curves)
        from matplotlib.patches import Arc
        ax.add_patch(Arc((0, 0.06), 0.7, 0.55, theta1=200, theta2=340,
                         color="#08306b", linewidth=1.2))
        ax.add_patch(Arc((0, -0.06), 0.7, 0.55, theta1=20, theta2=160,
                         color="#08306b", linewidth=1.2))
        for cx in (-0.42, 0.42):
            inner = mpatches.Ellipse((cx, -0.05), 0.4, 0.16,
                                     fill=True, facecolor="white",
                                     edgecolor="#08306b", linewidth=1.0)
            ax.add_patch(inner)
        for k in range(n_punctures):
            x = -0.78 + 0.18 * k
            ax.plot([x - 0.05, x + 0.05], [0.18, 0.30],
                    color="#d62728", linewidth=1.4)
            ax.plot([x - 0.05, x + 0.05], [0.30, 0.18],
                    color="#d62728", linewidth=1.4)


def _draw_trefoil(ax):
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-3.6, 3.6)
    ax.set_ylim(-3.6, 3.6)
    t = np.linspace(0, 2 * np.pi, 600)
    x = np.sin(t) + 2 * np.sin(2 * t)
    y = np.cos(t) - 2 * np.cos(2 * t)
    z = -np.sin(3 * t)
    # Plot in segments coloured darker when "behind" to fake over/under crossings
    for i in range(len(t) - 1):
        c = "#1f5fa8" if z[i] >= 0 else "#9ecae1"
        ax.plot(x[i:i+2], y[i:i+2], color=c, linewidth=2.0,
                solid_capstyle="round")


def _draw_hex_coloured(ax):
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-1.3, 1.3)
    angles = np.deg2rad([90 + 60 * i for i in range(6)])
    pts = np.column_stack([np.cos(angles), np.sin(angles)])
    poly = mpatches.Polygon(pts, closed=True, fill=False,
                            edgecolor="#222222", linewidth=1.2)
    ax.add_patch(poly)
    cols = ["#d62728", "#2ca02c", "#1f77b4",
            "#d62728", "#2ca02c", "#1f77b4"]
    for (x, y), c in zip(pts, cols):
        ax.scatter(x, y, s=120, color=c, edgecolor="#222222",
                   linewidth=0.6, zorder=3)


def _draw_graph_with_bridge(ax):
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.0, 1.0)
    # Two clumps joined by one bridge edge
    left = np.array([(-1.05, 0.55), (-1.0, -0.35), (-0.55, 0.15),
                     (-0.85, -0.75), (-0.45, -0.45)])
    right = np.array([(0.55, 0.45), (1.05, 0.0), (0.55, -0.55),
                      (1.0, -0.7), (0.35, -0.05)])
    # left clique-ish: connect everyone within left
    for i in range(len(left)):
        for j in range(i + 1, len(left)):
            ax.plot([left[i, 0], left[j, 0]], [left[i, 1], left[j, 1]],
                    color="#888888", linewidth=0.8, zorder=1)
    for i in range(len(right)):
        for j in range(i + 1, len(right)):
            ax.plot([right[i, 0], right[j, 0]],
                    [right[i, 1], right[j, 1]],
                    color="#888888", linewidth=0.8, zorder=1)
    # Bridge edge
    bx, by = (-0.45, -0.45), (0.35, -0.05)
    ax.plot([bx[0], by[0]], [bx[1], by[1]],
            color="#d62728", linewidth=2.0, zorder=2,
            label="bridge")
    # Vertices
    pts = np.vstack([left, right])
    ax.scatter(pts[:, 0], pts[:, 1], s=70, color="#1f5fa8",
               edgecolor="#222222", linewidth=0.6, zorder=3)
    ax.text(-0.05, -0.78, "bridge", color="#d62728",
            fontsize=8, ha="center", style="italic")


def _draw_tetrahedron(ax):
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.2, 1.2)
    ax.set_ylim(-1.0, 1.4)
    # 4 vertices in 3D, project orthographically
    V = np.array([
        [0,           0,          1],          # top
        [-0.95,      -0.55,      -0.35],
        [0.95,       -0.55,      -0.35],
        [0,           1.10,      -0.35],
    ])
    # simple oblique projection
    proj = np.array([[1, 0, 0.30], [0, 1, 0.20]])
    P = V @ proj.T
    edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    # back edge dashed (1-3 hidden behind the front face 0-1-2)
    hidden = {(1, 3)}
    for (a, b) in edges:
        style = "--" if (a, b) in hidden else "-"
        ax.plot([P[a, 0], P[b, 0]], [P[a, 1], P[b, 1]],
                color="#08306b", linestyle=style, linewidth=1.4)
    ax.scatter(P[:, 0], P[:, 1], s=35, color="#08306b", zorder=3)


def _draw_cube_with_projection(ax):
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.6, 2.0)
    ax.set_ylim(-1.4, 1.6)
    # cube vertices
    s = 0.85
    V = np.array([
        [0, 0, 0], [s, 0, 0], [s, s, 0], [0, s, 0],
        [0, 0, s], [s, 0, s], [s, s, s], [0, s, s],
    ])
    # oblique projection (xy + a bit of z)
    dx, dy = 0.40, 0.32
    P = np.column_stack([V[:, 0] + dx * V[:, 2],
                         V[:, 1] + dy * V[:, 2]])
    edges_solid = [(0, 1), (1, 2), (2, 3), (3, 0),
                   (4, 5), (5, 6), (6, 7), (7, 4),
                   (0, 4), (1, 5), (2, 6), (3, 7)]
    for (a, b) in edges_solid:
        ax.plot([P[a, 0], P[b, 0]], [P[a, 1], P[b, 1]],
                color="#08306b", linewidth=1.2)
    # xy shadow: drop z to 0, shift down for clarity
    shadow = V.copy()
    shadow[:, 2] = 0
    Sh = np.column_stack([shadow[:, 0], shadow[:, 1] - 1.05])
    bottom_idx = [0, 1, 2, 3]
    poly = mpatches.Polygon(Sh[bottom_idx], closed=True,
                            fill=True, facecolor="#dde7f2",
                            edgecolor="#1f5fa8", linewidth=1.2,
                            linestyle="--")
    ax.add_patch(poly)
    # vertical projection lines (dashed)
    for i in range(4):
        ax.plot([P[i, 0], Sh[i, 0]], [P[i, 1], Sh[i, 1]],
                color="#888888", linestyle=":", linewidth=0.8)
    ax.text(0.45, -1.25, "$xy$ projection", color="#1f5fa8",
            fontsize=8, ha="center", style="italic")


def _draw_pick_polygon(ax):
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-0.5, 5.5)
    ax.set_ylim(-0.5, 4.5)
    # lattice
    for x in range(6):
        for y in range(5):
            ax.plot(x, y, marker=".", color="#cccccc",
                    markersize=3, zorder=1)
    # polygon vertices (all lattice)
    poly_pts = np.array([(0, 0), (4, 0), (5, 2), (3, 4), (0, 3)])
    poly = mpatches.Polygon(poly_pts, closed=True, fill=True,
                            facecolor="#eef3f7", edgecolor="#08306b",
                            linewidth=1.4, zorder=2)
    ax.add_patch(poly)

    # Determine boundary vs interior lattice points
    from matplotlib.path import Path as MplPath
    path = MplPath(poly_pts)
    boundary, interior = [], []
    # boundary lattice points: walk each edge and emit gcd-step lattice pts
    from math import gcd
    n = len(poly_pts)
    bset = set()
    for i in range(n):
        a = poly_pts[i]
        b = poly_pts[(i + 1) % n]
        dx, dy = int(b[0] - a[0]), int(b[1] - a[1])
        steps = gcd(abs(dx), abs(dy))
        for k in range(steps):
            bset.add((a[0] + dx * k // steps, a[1] + dy * k // steps))
    # iterate lattice
    for x in range(6):
        for y in range(5):
            if (x, y) in bset:
                boundary.append((x, y))
            elif path.contains_point((x, y), radius=-1e-9):
                interior.append((x, y))
    boundary = np.array(boundary)
    interior = np.array(interior) if interior else np.empty((0, 2))
    if len(boundary):
        ax.scatter(boundary[:, 0], boundary[:, 1], s=55,
                   color="#1f5fa8", edgecolor="#222222",
                   linewidth=0.5, zorder=3, label="boundary")
    if len(interior):
        ax.scatter(interior[:, 0], interior[:, 1], s=55,
                   color="#d62728", edgecolor="#222222",
                   linewidth=0.5, zorder=3, label="interior")


def figure6():
    fig, axes = plt.subplots(2, 4, figsize=(11.4, 5.6))
    plotters = [
        (axes[0, 0], "Surf$_{1,2}$",
         lambda a: _draw_punctured_torus(a, genus=1, n_punctures=2)),
        (axes[0, 1], "Surf$_{2,1}$",
         lambda a: _draw_punctured_torus(a, genus=2, n_punctures=1)),
        (axes[0, 2], "Knot",  _draw_trefoil),
        (axes[0, 3], "Sym",   _draw_hex_coloured),
        (axes[1, 0], "Graph", _draw_graph_with_bridge),
        (axes[1, 1], "Curv",  _draw_tetrahedron),
        (axes[1, 2], "Proj",  _draw_cube_with_projection),
        (axes[1, 3], "Pick",  _draw_pick_polygon),
    ]
    for ax, name, fn in plotters:
        fn(ax)
        intuition = DOMAIN_INTUITION[name]
        ax.set_title(f"{name}\n\\textit{{({intuition})}}",
                     fontsize=10, pad=4) if False else \
            ax.set_title(f"{name}\n({intuition})",
                         fontsize=10, pad=4)
    fig.suptitle("Eight low-dimensional geometry domains: example objects",
                 fontsize=12, y=1.005)
    fig.tight_layout()
    _save(fig, "fig6_domain_examples")


# ---------------------------------------------------------------------------
# Figure 7 — radar (spider) chart of R / T / C main effects
# ---------------------------------------------------------------------------
def figure7():
    primitives = ["R", "T", "C"]
    n = len(primitives)
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False).tolist()
    angles += angles[:1]  # close polygon

    fig = plt.figure(figsize=(7.6, 6.8))
    ax = fig.add_subplot(111, projection="polar")
    ax.set_theta_offset(np.pi / 2)
    ax.set_theta_direction(-1)

    # axes config
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels([f"$\\bf {p}$" for p in primitives],
                       fontsize=12)
    ax.set_rlabel_position(110)
    ax.set_yticks([0.5, 1.0, 1.5, 2.0])
    ax.set_yticklabels(["0.5", "1.0", "1.5", "2.0"], fontsize=8,
                        color="#666666")
    ax.set_ylim(0, 2.0)
    ax.grid(True, color="#cccccc", linewidth=0.5, alpha=0.7)

    for d_idx, dom in enumerate(DOMAINS):
        vals = [MAIN_EFFECTS[p][d_idx] for p in primitives]
        vals += vals[:1]
        ax.plot(angles, vals,
                color=COOL_PALETTE[d_idx], linewidth=1.6,
                marker="o", markersize=4, label=dom, zorder=3)
        ax.fill(angles, vals, color=COOL_PALETTE[d_idx],
                alpha=0.06, zorder=2)

    ax.set_title("Main effects of R, T, C across domains (radar view)",
                 fontsize=12, y=1.10)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.06),
              ncol=4, frameon=False, fontsize=9)
    fig.tight_layout()
    _save(fig, "fig7_main_effects_radar")


# ---------------------------------------------------------------------------
# Table 3 — domain summary
# ---------------------------------------------------------------------------
def table3():
    headers = ["Domain", "Dimension", "Cases",
               "Object type", "Transform", "CF strategies"]
    rows = [
        ["$\\mathrm{Surf_{1,2}}$", "Invariant",       "1563",
         "Curves on $S_{1,2}$",   "Surgery",         "$i{=}2$ boundary"],
        ["$\\mathrm{Surf_{2,1}}$", "Invariant",       "128",
         "Curves on $S_{2,1}$",   "Surgery",         "$i{=}2$ boundary"],
        ["Knot",                   "Invariant",       "100",
         "Prime knots",            "R2 move",
         "Pseudo-R2, flip"],
        ["Sym",                    "Symmetry",        "200",
         "Hex 3-colourings",       "$\\mathbb{Z}_6$ action",
         "$\\mathbb{Z}_6\\!\\to\\! D_6$, $\\mathbb{Z}_6\\!\\to\\!\\{e\\}$"],
        ["Graph",                  "Deformation",     "100",
         "Random graphs",          "Edge deletion",
         "Bridge vs.\\ non-bridge"],
        ["Curv",
         "Local\\,$\\to$\\,Global",                   "100",
         "Polyhedra",              "Stellar subdiv.",
         "Incomplete subdiv."],
        ["Proj",                   "Dimension",       "66",
         "3D polyhedra",           "Projection",
         "No-proj, squash"],
        ["Pick",                   "Boundary",        "87",
         "Lattice polygons",       "Shear / translate",
         "Non-lattice, scale"],
    ]
    colalign = ["left", "left", "center", "left", "left", "left"]
    body = tabulate(rows, headers=headers, tablefmt="latex_raw",
                    colalign=colalign, disable_numparse=True)
    tex = (
        "% Auto-generated by SpatialMind/scripts/generate_paper_figures.py\n"
        "\\begin{table*}[t]\n"
        "\\centering\n"
        "\\caption{Summary of the eight evaluation domains. ``Dimension''\n"
        "  names the geometric direction probed by the domain (topological\n"
        "  invariant, symmetry, deformation, local-to-global aggregation,\n"
        "  dimension reduction, or boundary structure). ``Cases'' gives the\n"
        "  number of distinct instances proved per condition. ``CF strategies''\n"
        "  lists the counterfactual variants used in the C primitive.}\n"
        "\\label{tab:domain-summary}\n"
        "\\small\n"
        f"{body}\n"
        "\\end{table*}\n"
    )
    (TAB_DIR / "table3_domain_summary.tex").write_text(tex, encoding="utf-8")


# ---------------------------------------------------------------------------
# Save helper
# ---------------------------------------------------------------------------
def _save(fig, stem: str):
    pdf = FIG_DIR / f"{stem}.pdf"
    png = FIG_DIR / f"{stem}.png"
    fig.savefig(pdf, bbox_inches="tight")
    fig.savefig(png, bbox_inches="tight", dpi=300)
    plt.close(fig)
    print(f"  wrote {pdf.name} + {png.name}")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
def main():
    print(f"Output figures -> {FIG_DIR}")
    print(f"Output tables  -> {TAB_DIR}")
    figure1()
    figure2()
    figure3()
    inter = figure4()
    figure5()
    figure6()
    figure7()
    table1(inter)
    table2()
    table3()
    print("done.")


if __name__ == "__main__":
    main()
