"""Shared palette and styling for CoE paper figures."""

PALETTE = {
    "R": "#1f77b4",  # blue
    "T": "#ff7f0e",  # orange
    "C": "#2ca02c",  # green
    "neutral": "#555555",
    "neutral_bg": "#ECECEC",
    "ink": "#222222",
    "muted": "#888888",
}

# Eight domains; same order as Table 2 in the paper.
DOMAINS = ["Surf$_{1,2}$", "Surf$_{2,1}$", "Knot", "Sym", "Graph", "Curv", "Proj", "Pick"]

# Ablation scores from Table 2 (rows = domains, cols = 8 conditions).
# Order: 000, R00, 0T0, 00C, RT0, R0C, 0TC, RTC
SCORES = {
    "Surf$_{1,2}$": [0, 2, 0, 2, 2, 2, 2, 3],
    "Surf$_{2,1}$": [2, 2, 2, 2, 3, 2, 2, 3],
    "Knot":         [1, 2, 2, 2, 2, 3, 2, 3],
    "Sym":          [2, 4, 3, 2, 4, 4, 3, 4],
    "Graph":        [1, 4, 3, 3, 4, 4, 4, 4],
    "Curv":         [2, 2, 2, 2, 2, 3, 2, 3],
    "Proj":         [2, 3, 3, 2, 4, 4, 3, 4],
    "Pick":         [1, 3, 3, 3, 4, 4, 3, 4],
}

CONDITIONS = ["000", "R00", "0T0", "00C", "RT0", "R0C", "0TC", "RTC"]

# Per-domain colour cycle (categorical, distinct from R/T/C palette).
DOMAIN_COLOURS = [
    "#4C72B0",  # Surf 1,2 - dark blue
    "#55A868",  # Surf 2,1 - green
    "#C44E52",  # Knot - red
    "#8172B2",  # Sym - purple
    "#CCB974",  # Graph - olive
    "#64B5CD",  # Curv - teal
    "#937860",  # Proj - brown
    "#DA8BC3",  # Pick - pink
]

DOMAIN_LINESTYLES = ["-", "-", "-", "-", "--", "--", "--", "--"]


def apply_style():
    import matplotlib as mpl
    mpl.rcParams.update({
        "font.family": "serif",
        "font.serif": ["Times New Roman", "Times", "Liberation Serif", "DejaVu Serif"],
        "font.size": 9,
        "axes.labelsize": 9,
        "axes.titlesize": 10,
        "xtick.labelsize": 8,
        "ytick.labelsize": 8,
        "legend.fontsize": 8,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.linewidth": 0.7,
        "xtick.major.width": 0.7,
        "ytick.major.width": 0.7,
        "lines.linewidth": 1.6,
        "pdf.fonttype": 42,
        "ps.fonttype": 42,
    })
