# Cross-Rater Analysis: Opus vs GPT vs Gemini

**Sample**: 48 trials = 8 domains × 3 cases/domain × 2 conditions (zero_cot, coe_rtc).
**Source**: `responses.json` + `scores_{opus,gpt,gemini}.json`.
**Computed**: 2026-05-03 (GPT scores rerun on GPT-5.5).

---

## 1. Pairwise agreement (overall, n = 48)

| Pair             | Cohen's κ (unweighted) | Spearman ρ | ρ p-value     |
|------------------|------------------------|------------|---------------|
| Opus vs GPT      | **0.430**              | 0.772      | 1.4 × 10⁻¹⁰   |
| Opus vs Gemini   | **0.791**              | 0.916      | 7.0 × 10⁻²⁰   |
| GPT vs Gemini    | **0.634**              | 0.865      | 2.2 × 10⁻¹⁵   |

Interpretation (Landis–Koch): Opus–Gemini = substantial; GPT–Gemini = substantial; Opus–GPT = moderate.
All three pairs now sit in the moderate-to-substantial band; the previous Opus–GPT outlier (κ = 0.25 under the original GPT) is gone.

---

## 2. Pairwise agreement, split by condition

### zero_cot (n = 24)

| Pair             | κ      | ρ      | ρ p     |
|------------------|--------|--------|---------|
| Opus vs GPT      | 0.163  | 0.875  | 2.3e-8  |
| Opus vs Gemini   | 0.667  | 0.920  | 2.1e-10 |
| GPT vs Gemini    | 0.498  | 0.913  | 4.8e-10 |

### coe_rtc (n = 24)

| Pair             | κ      | ρ      | ρ p     |
|------------------|--------|--------|---------|
| Opus vs GPT      | 0.644  | 0.626  | 1.1e-3  |
| Opus vs Gemini   | 0.897  | 0.841  | 2.7e-7  |
| GPT vs Gemini    | 0.746  | 0.786  | 5.4e-6  |

The Opus–GPT split now has a clear shape: ranks agree everywhere (ρ ≥ 0.63 in both conditions), and exact-label agreement is also high on coe_rtc (κ = 0.64). On zero_cot the κ is still low (0.16) despite strong ρ — meaning GPT and Opus rank baseline responses the same way but offset their cutoffs by about a level. This is a calibration mismatch on baseline, not a structural disagreement.

---

## 3. Mean score by rater × condition

|                | Opus    | GPT     | Gemini  |
|----------------|---------|---------|---------|
| zero_cot       | 1.958   | 2.833   | 2.208   |
| coe_rtc        | 3.750   | 3.500   | 3.625   |
| **RTC lift**   | **+1.792** | **+0.667** | **+1.417** |

Per-case paired test (coe_rtc − zero_cot, 24 matched pairs):

| Rater  | Mean lift | pos / neg / tie | Wilcoxon p | Sign-test p (pos > neg) |
|--------|-----------|------------------|------------|--------------------------|
| Opus   | +1.792    | 21 / 0 / 3       | 4.7e-5     | 4.8e-7                   |
| GPT    | +0.667    | 16 / 1 / 7       | 2.9e-3     | 1.4e-4                   |
| Gemini | +1.417    | 21 / 1 / 2       | 3.7e-4     | 5.5e-6                   |

All three raters now register a statistically significant RTC lift. GPT's lift is the smallest in magnitude but the direction is unambiguous: 16 positive vs 1 negative across 24 paired cases.

GPT's zero_cot mean (2.833) is still higher than Opus's (1.958) and Gemini's (2.208), so GPT has less room to lift on coe_rtc. The ceiling effect explains why GPT's lift is the smallest of the three rather than why it might be zero.

---

## 4. Differential bias: Δ = Opus − External

| External rater | Δ on baseline (zero_cot) | Δ on RTC (coe_rtc) | **Differential (Δ_rtc − Δ_baseline)** |
|----------------|--------------------------|---------------------|----------------------------------------|
| GPT            | **−0.875**               | **+0.250**          | **+1.125**                             |
| Gemini         | −0.250                   | +0.125              | +0.375                                 |

**Both differentials remain positive — Opus is more generous on RTC than on baseline, relative to the external raters.**

- vs GPT: a 1.125-point swing on a 0–4 scale is still substantial. On baseline, Opus rates ~0.9 point *below* GPT; on RTC, Opus rates ~0.25 point *above* GPT. This remains the strongest single piece of evidence for self-rating bias, though smaller than under the original GPT scoring (+1.625).
- vs Gemini: smaller (+0.375). Gemini largely tracks Opus's lift, so the differential is modest and unchanged.

---

## 5. Three-way verdict on "RTC > baseline"

| Rater  | Lift     | Significant? | Verdict       |
|--------|----------|--------------|---------------|
| Opus   | +1.792   | yes (p < 1e-4) | strong YES  |
| Gemini | +1.417   | yes (p < 1e-3) | strong YES  |
| GPT    | +0.667   | yes (p ≈ 3e-3) | YES         |

**All three raters confirm RTC > baseline.** The claim is now unanimous. GPT's lift is the smallest in magnitude (a function of its higher baseline ceiling) but the sign and significance are both clear.

---

## Bottom line

1. **Self-rating bias is real but bounded, and smaller than first reported.** Opus's lift (+1.79) is still bigger than either external rater's. Vs Gemini the differential is small (+0.375); vs GPT it has dropped from +1.625 (original scoring) to +1.125 — still the largest of the two but no longer extreme.

2. **The "RTC > baseline" finding survives external review fully.** Under the GPT-5.5 rerun, Gemini reproduces it strongly (+1.42, p < 1e-3) and GPT also reproduces it (+0.67, p ≈ 3e-3). Three-of-three rather than two-of-three.

3. **The Opus–GPT divergence is now a baseline-only calibration mismatch, not a structural disagreement.** Their full-set κ is 0.43 (moderate) and ρ is 0.77. The remaining gap concentrates on zero_cot (κ = 0.16, ρ = 0.88) — GPT applies a more permissive ARGUMENT/PROOF bar in baseline, but on RTC the two raters track each other (κ = 0.64).

4. **Recommend**: report all three rater lifts side-by-side. The headline number is now the cross-rater confirmation itself rather than any one rater's lift. Continue to disclose the Opus self-rating differential (+1.125 vs GPT, +0.375 vs Gemini) as the residual self-rating bias estimate.
