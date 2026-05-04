# Cross-Model Ablation Summary: Opus / GPT-5.5 / Gemini 3

**Sample**: 8 domains × 3 cases/domain × 2 conditions (baseline, RTC). For Opus, the 3 cases per domain are the first 3 entries of `design.cases_per_domain`; for GPT-5.5 and Gemini 3 the 3-case ablation set is used as-is. Per-domain means are over 3 cases each.

Sources: `method_comparison_n10_results.json` (Opus, conditions `zero_cot` and `coe_rtc`), `cross_model_gpt_ablation.json`, `cross_model_gemini_ablation.json`.

**Computed**: 2026-05-03.

---

## Table 1: Cross-model ablation by domain (baseline → RTC)

| Domain | Opus base→RTC | GPT-5.5 base→RTC | Gemini 3 base→RTC |
|--------|---------------|------------------|-------------------|
| Symmetry | 4.00 → 4.00 | 4.00 → 4.00 | 4.00 → 4.00 |
| Knot theory | 3.00 → 4.00 | 3.00 → 4.00 | 3.00 → 4.00 |
| Graph connectivity | 3.00 → 4.00 | 2.00 → 4.00 | 2.00 → 4.00 |
| Boundary/interior | 1.67 → 4.00 | 4.00 → 4.00 | 4.00 → 4.00 |
| Discrete curvature | 2.00 → 4.00 | 4.00 → 4.00 | 4.00 → 4.00 |
| Projection | 2.00 → 4.00 | 3.00 → 4.00 | 3.00 → 4.00 |
| Surface topology (S_{1,2}) | 0.00 → 3.00 | 3.00 → 4.00 | 3.00 → 4.00 |
| Surface topology (S_{2,1}) | 0.00 → 3.00 | 3.00 → 4.00 | 3.00 → 4.00 |

---

## Table 2: Overall (mean across 8 domain-means)

| Model | Baseline | RTC | Lift | Wilcoxon p (n=8 domain pairs) | pos / neg / tie |
|-------|----------|-----|------|-------------------------------|------------------|
| Opus | 1.958 | 3.750 | +1.792 | 0.0156 | 7 / 0 / 1 |
| GPT-5.5 | 3.250 | 4.000 | +0.750 | 0.0625 | 5 / 0 / 3 |
| Gemini 3 | 3.250 | 4.000 | +0.750 | 0.0625 | 5 / 0 / 3 |

---

## Table 3: R universality — does RTC ≥ baseline hold in every domain × model cell?

| Domain | Opus | GPT-5.5 | Gemini 3 | All three? |
|--------|------|---------|----------|------------|
| Symmetry | ✓ | ✓ | ✓ | **✓** |
| Knot theory | ✓ | ✓ | ✓ | **✓** |
| Graph connectivity | ✓ | ✓ | ✓ | **✓** |
| Boundary/interior | ✓ | ✓ | ✓ | **✓** |
| Discrete curvature | ✓ | ✓ | ✓ | **✓** |
| Projection | ✓ | ✓ | ✓ | **✓** |
| Surface topology (S_{1,2}) | ✓ | ✓ | ✓ | **✓** |
| Surface topology (S_{2,1}) | ✓ | ✓ | ✓ | **✓** |

**Universality count**: 8/8 domains satisfy RTC ≥ baseline in all three models.

---

## Bottom line — does this address L2?

**Yes.** Across all 24 (model × domain) cells, 17 show strict RTC > baseline, 7 are ties (all at the 4.00 ceiling), and **0 reverse**. The direction is unanimous across the three model families (Anthropic Opus, OpenAI GPT-5.5, Google Gemini 3) and across all 8 domains. This addresses **L2** (cross-model only validated within the Claude family): the RTC effect now has cross-family ablation evidence, not only cross-family rating.

Per-model paired Wilcoxon (n = 8 domain-mean diffs): Opus p = 0.0156 (significant), GPT-5.5 p = 0.0625, Gemini 3 p = 0.0625. The GPT-5.5 and Gemini 3 p-values sit at the floor of what 5-positive / 3-tie / 0-negative permits — they are ceiling-limited, not directionally weak. The four ties per model are exactly the four domains where baseline already saturates at 4.00 (Symmetry, Boundary/interior, Discrete curvature in GPT/Gemini), giving RTC no headroom. A two-sided sign test on the 17 non-tied cells (17 positive, 0 negative) gives p ≈ 1.5 × 10⁻⁵.

Per-model magnitude: Opus lift = 1.79, GPT-5.5 lift = 0.75, Gemini 3 lift = 0.75. Opus's larger lift reflects its lower baseline (1.96 vs 3.25 for GPT/Gemini); GPT-5.5 and Gemini 3 had less room to lift because they already cleared ARGUMENT on most baseline cases. Where headroom existed (Knot, Graph, Projection, both surface-topology cells), all three models lifted strictly.
