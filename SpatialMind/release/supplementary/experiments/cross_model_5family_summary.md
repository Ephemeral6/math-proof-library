# Cross-model 5-family R-universality summary

Scoring done inline by Claude Opus 4.7 (no API call) using the same 0-4 rubric as prior cross-model studies in this project. Two new model families (DeepSeek, Qwen-Max) ran the full 8-domain × 3-case × 2-condition protocol (48 trials each, with 5 empty Qwen responses from API failures). Prior models (Haiku 4.5, Sonnet 4.6, Opus 4.7) report on the 3-domain matched subset (symmetry + knot_theory + graph_connectivity) used in the original cross_model_results.json so the comparison is apples-to-apples.

### Full 8-domain (new models)

| Model      | Baseline | +RTC  | RTC lift | n_base / n_rtc |
|------------|----------|-------|----------|----------------|
| DeepSeek   | 2.583    | 3.833 | +1.250   | 24 / 24            |
| Qwen-Max   | 2.409    | 3.714 | +1.305   | 22 / 21            |

### 3-domain matched subset (symmetry + knot_theory + graph_connectivity)

| Model      | Baseline | +RTC  | RTC lift |
|------------|----------|-------|----------|
| DeepSeek   | 2.556    | 3.778 | +1.222   |
| Qwen-Max   | 3.000    | 3.500 | +0.500   |
| Haiku 4.5  | 3.000    | 3.667 | +0.667   |
| Sonnet 4.6 | 3.111    | 3.889 | +0.778   |
| Opus 4.7   | 3.333    | 4.000 | +0.667   |
