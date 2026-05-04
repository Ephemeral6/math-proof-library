"""P3: factorial-profile (parallel coordinates) plot.

x-axis = 8 ablation conditions in Hasse-diagram order
         (000, then 1-on, then 2-on, then RTC).
y-axis = reasoning-depth score (0..4).
One line per domain, colour-coded; level shading for score thresholds.
"""

import os
import sys

import matplotlib.pyplot as plt
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from _palette import (CONDITIONS, DOMAIN_COLOURS, DOMAIN_LINESTYLES, DOMAINS,
                      PALETTE, SCORES, apply_style)

apply_style()

fig, ax = plt.subplots(figsize=(6.4, 3.5))

# Background bands for score levels
bands = [
    (0, 1, "#F5F5F5", "no/wrong signal"),
    (1, 2, "#EFEFEF", ""),
    (2, 3, "#E6E6E6", "pattern"),
    (3, 4, "#D4D4D4", "argument"),
]
for y0, y1, col, _ in bands:
    ax.axhspan(y0, y1, color=col, alpha=0.35, zorder=0)

# Vertical group separators between Hasse levels
group_breaks = [0.5, 3.5, 6.5, 7.5]
for x in group_breaks:
    ax.axvline(x, color="#CCCCCC", linestyle=":", linewidth=0.7, zorder=1)

# Headers per Hasse level
ax.text(0, 4.45, "baseline", ha="center", va="bottom", fontsize=8,
        color=PALETTE["muted"])
ax.text(2, 4.45, "1-primitive", ha="center", va="bottom", fontsize=8,
        color=PALETTE["muted"])
ax.text(5, 4.45, "2-primitive", ha="center", va="bottom", fontsize=8,
        color=PALETTE["muted"])
ax.text(7, 4.45, "full CoE", ha="center", va="bottom", fontsize=8,
        color=PALETTE["muted"])

xs = np.arange(len(CONDITIONS))

# Slight x-jitter so overlapping lines are distinguishable
np.random.seed(0)
jitter = np.linspace(-0.10, 0.10, len(DOMAINS))

for i, dom in enumerate(DOMAINS):
    ys = np.array(SCORES[dom], dtype=float)
    ax.plot(xs + jitter[i], ys,
            color=DOMAIN_COLOURS[i],
            linestyle=DOMAIN_LINESTYLES[i],
            marker="o", markersize=4.5,
            markeredgecolor="white", markeredgewidth=0.7,
            label=dom, zorder=3, alpha=0.92)

# Argument-threshold line
ax.axhline(3, color=PALETTE["ink"], linestyle="-", linewidth=0.8, alpha=0.6,
           zorder=2)
ax.text(7.45, 3.0, "argument", fontsize=7, color=PALETTE["ink"],
        va="center", ha="left", alpha=0.75)

ax.set_xticks(xs)
ax.set_xticklabels(CONDITIONS, fontsize=8)
ax.set_yticks([0, 1, 2, 3, 4])
ax.set_yticklabels(["0\nno", "1\nwrong", "2\npattern", "3\nargument", "4\nproof"],
                   fontsize=7)
ax.set_xlabel("Ablation condition (Hasse-ordered: $\\emptyset \\to$ 1- $\\to$ 2- $\\to$ RTC)")
ax.set_ylabel("Reasoning-depth score")
ax.set_xlim(-0.6, 7.6)
ax.set_ylim(-0.3, 4.7)

# Two-column legend below the plot
leg = ax.legend(loc="lower center", bbox_to_anchor=(0.5, -0.42),
                ncol=4, frameon=False, handlelength=2.4,
                columnspacing=1.4, handletextpad=0.6)

plt.tight_layout()
out_pdf = os.path.join(HERE, "fig_factorial_profile.pdf")
out_png = os.path.join(HERE, "fig_factorial_profile.png")
plt.savefig(out_pdf, bbox_inches="tight", pad_inches=0.05)
plt.savefig(out_png, dpi=200, bbox_inches="tight", pad_inches=0.05)
print("wrote", out_pdf)
print("wrote", out_png)
