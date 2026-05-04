"""P2: visual case study figure for the Knot R2-invariance example.

Two-column layout:
  Left  (Baseline 000): trefoil rendered in muted grey, no annotations.
                        Text box below with LLM response and score.
  Right (CoE-RTC):      trefoil rendered in ink, with R/T/C call boxes
                        in palette colours pointing at the relevant
                        regions. Text box below with LLM response and
                        score.
"""

import os
import sys

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from _palette import PALETTE, apply_style

apply_style()


# -------- Trefoil (knot 3_1) parametric curve ---------------------------------
def trefoil(num=600):
    t = np.linspace(0, 2 * np.pi, num)
    x = np.sin(t) + 2 * np.sin(2 * t)
    y = np.cos(t) - 2 * np.cos(2 * t)
    z = -np.sin(3 * t)
    return x, y, z


def draw_trefoil(ax, color="#444444", lw=2.4, gap_color="white", gap_lw=5.0):
    """Draw a trefoil with simulated over/under crossings."""
    x, y, z = trefoil()
    ax.plot(x, y, color=color, linewidth=lw, solid_capstyle="round", zorder=2)

    over = z > 0
    edges = np.where(np.diff(over.astype(int)) != 0)[0]
    runs = []
    cur = 0
    for e in edges:
        runs.append((cur, e + 1))
        cur = e + 1
    runs.append((cur, len(over)))

    for s, e in runs:
        if not over[s]:
            continue
        ax.plot(x[s:e], y[s:e], color=gap_color, linewidth=gap_lw,
                solid_capstyle="round", zorder=3)
        ax.plot(x[s:e], y[s:e], color=color, linewidth=lw,
                solid_capstyle="round", zorder=4)


def textbox(ax, x, y, w, h, title, body, score, score_color,
            face="#F4F4F4", edge="#BBBBBB"):
    box = FancyBboxPatch(
        (x, y), w, h,
        boxstyle="round,pad=0.02,rounding_size=0.05",
        linewidth=0.9, edgecolor=edge, facecolor=face, zorder=2,
    )
    ax.add_patch(box)
    ax.text(x + 0.04, y + h - 0.06, title, ha="left", va="top",
            fontsize=8.5, weight="bold", color=PALETTE["ink"], zorder=3)

    badge_w = 0.62
    badge = FancyBboxPatch(
        (x + w - badge_w - 0.04, y + h - 0.13), badge_w, 0.10,
        boxstyle="round,pad=0.005,rounding_size=0.04",
        linewidth=0.0, facecolor=score_color, alpha=0.92, zorder=3,
    )
    ax.add_patch(badge)
    ax.text(x + w - badge_w / 2 - 0.04, y + h - 0.08, score,
            ha="center", va="center",
            fontsize=7.5, color="white", weight="bold", zorder=4)

    ax.text(x + 0.04, y + h - 0.20, body, ha="left", va="top",
            fontsize=7.6, color=PALETTE["ink"], zorder=3,
            family="serif", linespacing=1.30)


# -------- Build figure --------------------------------------------------------
# Figure layout (figure-coordinate y, top→bottom):
#   y in [0.92, 0.99]  panel titles
#   y in [0.86, 0.91]  panel subtitles
#   y in [0.78, 0.84]  R badge (top of right panel; visual headroom on left)
#   y in [0.50, 0.80]  knot panels
#   y in [0.42, 0.48]  C badge (right) / knot caption (left)
#   y in [0.04, 0.40]  response text boxes
fig = plt.figure(figsize=(7.2, 5.2))

left_ax = fig.add_axes([0.02, 0.04, 0.46, 0.94])
right_ax = fig.add_axes([0.52, 0.04, 0.46, 0.94])
for ax in (left_ax, right_ax):
    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_aspect("auto")
    for s in ax.spines.values():
        s.set_visible(False)

# ---- Titles ------------------------------------------------------------------
fig.text(0.25, 0.965, "Baseline ($000$)", ha="center", va="center",
         fontsize=11, weight="bold", color=PALETTE["ink"])
fig.text(0.25, 0.925, "PD code only; no R / T / C signals",
         ha="center", va="center", fontsize=8.2, color=PALETTE["muted"],
         style="italic")

fig.text(0.75, 0.965, "CoE-RTC", ha="center", va="center",
         fontsize=11, weight="bold", color=PALETTE["ink"])
fig.text(0.75, 0.925, "engine supplies R / T / C streams",
         ha="center", va="center", fontsize=8.2, color=PALETTE["muted"],
         style="italic")

# ---- Knot panels --------------------------------------------------------------
left_knot = fig.add_axes([0.10, 0.50, 0.30, 0.36])
left_knot.set_xlim(-3.6, 3.6)
left_knot.set_ylim(-3.6, 3.6)
left_knot.set_xticks([]); left_knot.set_yticks([])
left_knot.set_aspect("equal")
for s in left_knot.spines.values():
    s.set_visible(False)
draw_trefoil(left_knot, color=PALETTE["muted"], lw=2.0, gap_lw=5.0)

fig.text(0.25, 0.470, "knot $3_1$", ha="center", va="center",
         fontsize=8.2, color=PALETTE["muted"], style="italic")

right_knot = fig.add_axes([0.60, 0.50, 0.30, 0.36])
right_knot.set_xlim(-3.6, 3.6)
right_knot.set_ylim(-3.6, 3.6)
right_knot.set_xticks([]); right_knot.set_yticks([])
right_knot.set_aspect("equal")
for s in right_knot.spines.values():
    s.set_visible(False)
draw_trefoil(right_knot, color=PALETTE["ink"], lw=2.0, gap_lw=5.0)


# ---- Annotation badges (figure coordinates) ----------------------------------
def fig_badge(x, y, label, color, w=0.20, h=0.040):
    """Place a coloured pill at (x, y) with width w, height h (figure coords)."""
    p = FancyBboxPatch(
        (x, y), w, h,
        boxstyle="round,pad=0.0,rounding_size=0.012",
        linewidth=0.0, facecolor=color, alpha=0.95,
        transform=fig.transFigure, figure=fig, zorder=6, clip_on=False,
    )
    fig.patches.append(p)
    fig.text(x + w / 2, y + h / 2, label, ha="center", va="center",
             color="white", fontsize=7.5, weight="bold", zorder=7)


def fig_arrow(xy_from, xy_to, color):
    a = FancyArrowPatch(
        xy_from, xy_to,
        transform=fig.transFigure,
        arrowstyle="-",
        color=color, alpha=0.65, lw=0.9,
        zorder=5, clip_on=False,
    )
    fig.patches.append(a)


# R badge: top, slightly left
fig_badge(0.555, 0.870, r"R: $\sigma=-2$, det = 3",
          color=PALETTE["R"], w=0.215, h=0.040)
fig_arrow((0.660, 0.870), (0.700, 0.770), color=PALETTE["R"])

# T badge: right side
fig_badge(0.880, 0.660, r"T: 2 new crossings",
          color=PALETTE["T"], w=0.180, h=0.040)
fig_arrow((0.880, 0.680), (0.835, 0.680), color=PALETTE["T"])

# C badge: just below knot, above textbox
fig_badge(0.620, 0.435, r"C: same-sign $\Rightarrow$ det $3 \to 7$",
          color=PALETTE["C"], w=0.260, h=0.040)


# ---- Response text boxes (bottom of each panel) ------------------------------
# Re-scale right_ax/left_ax y so textbox uses [-1, 1] but with smaller height.
# We'll position the box manually in figure coordinates via a sub-axes.
def add_response_box(left_x, body, score, score_color, face, edge):
    """Draw a response box across figure coords."""
    # Use a dedicated axes [left_x, 0.04, 0.46, 0.36]
    ax = fig.add_axes([left_x, 0.06, 0.46, 0.32])
    ax.set_xlim(0, 1); ax.set_ylim(0, 1)
    ax.set_xticks([]); ax.set_yticks([])
    for s in ax.spines.values():
        s.set_visible(False)

    box = FancyBboxPatch(
        (0.03, 0.05), 0.94, 0.92,
        boxstyle="round,pad=0.0,rounding_size=0.04",
        linewidth=0.9, edgecolor=edge, facecolor=face, zorder=2,
    )
    ax.add_patch(box)
    ax.text(0.06, 0.86, "LLM response", ha="left", va="center",
            fontsize=9.0, weight="bold", color=PALETTE["ink"], zorder=3)

    # Score badge on the right
    badge_w = 0.32
    badge = FancyBboxPatch(
        (0.96 - badge_w, 0.81), badge_w, 0.10,
        boxstyle="round,pad=0.002,rounding_size=0.025",
        linewidth=0.0, facecolor=score_color, alpha=0.92, zorder=3,
    )
    ax.add_patch(badge)
    ax.text(0.96 - badge_w / 2, 0.86, score, ha="center", va="center",
            fontsize=7.8, weight="bold", color="white", zorder=4)

    ax.text(0.06, 0.74, body, ha="left", va="top",
            fontsize=7.8, color=PALETTE["ink"], zorder=3, linespacing=1.32)


add_response_box(
    left_x=0.02,
    body=("“R2 moves add crossings, but I cannot determine\n"
          "which invariants change without more information.”\n\n"
          "Recall fails on this specific instance; the model\n"
          "contradicts the textbook fact that R2 preserves\n"
          "invariants."),
    score="score 1  WRONG",
    score_color="#9E9E9E",
    face="#F4F4F4",
    edge="#BBBBBB",
)

add_response_box(
    left_x=0.52,
    body=("“The cancelling sign pair $(+1,-1)$ ensures writhe\n"
          "invariance; the Seifert matrix gains a rank-2 block of\n"
          "determinant 1, preserving the original determinant.\n"
          "The counterfactual confirms: same-sign pairs break\n"
          "this cancellation.”"),
    score="score 3  ARGUMENT",
    score_color="#3E8E41",
    face="#F2F8F2",
    edge="#9DC8A0",
)

# Vertical divider between panels
fig.lines.append(plt.Line2D([0.50, 0.50], [0.04, 0.96],
                            transform=fig.transFigure,
                            color="#DDDDDD", linewidth=0.8))

out_pdf = os.path.join(HERE, "fig_case_study_visual.pdf")
out_png = os.path.join(HERE, "fig_case_study_visual.png")
fig.savefig(out_pdf, bbox_inches="tight", pad_inches=0.04)
fig.savefig(out_png, dpi=200, bbox_inches="tight", pad_inches=0.04)
print("wrote", out_pdf)
print("wrote", out_png)
