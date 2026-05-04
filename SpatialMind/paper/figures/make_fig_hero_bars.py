"""P1: hero-figure bar inset.

A small horizontal bar chart showing the score jump for one
representative domain (Sym) along the path 000 -> R00 -> RT0 -> RTC.
Designed to be embedded next to the abstract-framework panel of Fig 1
to give the reader the headline result before they reach Section 5.
"""

import os
import sys

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyBboxPatch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from _palette import PALETTE, apply_style

apply_style()

# Sym row from Table 2:
# 000=2, R00=4, 0T0=3, 00C=2, RT0=4, R0C=4, 0TC=3, RTC=4
labels = [r"$000$", r"$R00$", r"$RT0$", r"$RTC$"]
scores = [2, 4, 4, 4]

# Each bar's "active primitive set" determines its colour.
# 000 = baseline (neutral); R00 = R only (blue); RT0 = R+T (blue+orange);
# RTC = R+T+C (blue+orange+green).
bar_colors = [
    PALETTE["neutral_bg"],
    PALETTE["R"],
    PALETTE["R"],
    PALETTE["R"],
]
# A small overlay strip on top of each bar to show which primitives are on.
overlays = [
    [],
    [PALETTE["R"]],
    [PALETTE["R"], PALETTE["T"]],
    [PALETTE["R"], PALETTE["T"], PALETTE["C"]],
]

fig, ax = plt.subplots(figsize=(2.6, 2.0))

ys = np.arange(len(labels))[::-1]
ax.barh(ys, scores, color=bar_colors, edgecolor="white", linewidth=0.8,
        height=0.62, zorder=2)

# Score labels at end of bars
for y, s in zip(ys, scores):
    ax.text(s + 0.10, y, str(s), va="center", ha="left",
            fontsize=8.5, weight="bold", color=PALETTE["ink"])

# Overlay primitive markers along the bar
for y, ov in zip(ys, overlays):
    for k, c in enumerate(ov):
        ax.scatter(0.30 + 0.45 * k, y, s=42, color=c,
                   edgecolor="white", linewidth=0.8, zorder=4)

# Threshold line at 3 (ARGUMENT)
ax.axvline(3.0, color=PALETTE["muted"], linestyle="--", linewidth=0.7,
           alpha=0.7, zorder=1)
ax.text(3.0, len(labels) - 0.45, " argument", va="center", ha="left",
        fontsize=7.3, color=PALETTE["muted"], style="italic")

ax.set_yticks(ys)
ax.set_yticklabels(labels, fontsize=8.5)
ax.set_xticks([0, 1, 2, 3, 4])
ax.set_xticklabels(["0", "1", "2", "3", "4"], fontsize=7.5)
ax.set_xlim(0, 4.7)
ax.set_xlabel("score", fontsize=8)
ax.set_title("Sym domain: score jumps with CoE", fontsize=8.5,
             color=PALETTE["ink"], pad=4)

ax.set_axisbelow(True)
for s in ("top", "right"):
    ax.spines[s].set_visible(False)

plt.tight_layout()
out_pdf = os.path.join(HERE, "fig_hero_bars.pdf")
out_png = os.path.join(HERE, "fig_hero_bars.png")
plt.savefig(out_pdf, bbox_inches="tight", pad_inches=0.04)
plt.savefig(out_png, dpi=200, bbox_inches="tight", pad_inches=0.04)
print("wrote", out_pdf)
print("wrote", out_png)
