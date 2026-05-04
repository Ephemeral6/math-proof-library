# Token Budget Analysis

**Question**: Are the score differences across conditions confounded by
prompt length? If longer prompts simply yield higher scores, the apparent
advantage of CoE-R / CoE-RTC could be a length artifact rather than a
structural one.

Total trials analyzed: **464** (lengths in characters).

Sources:
- method_comparison_results.json — 96 trials, 4 conditions
- method_comparison_n10_results.json — 320 trials, 4 conditions
- react_comparison_results.json — 24 trials, 1 condition
- library_hint_results.json — 24 trials, 1 condition

ReAct caveat: the ReAct result file does not store its prompt. We use the
matching zero_cot prompt (same domain+case_id) as a proxy for the baseline
shown to the ReAct agent, and treat trajectory+final_answer as the response.

## Table 1 — Average prompt / response length per condition

| Condition | n | avg prompt len | avg response len | avg score |
|---|---|---|---|---|
| Zero-CoT | 104 | 309 | 322 | 1.90 |
| CoT+Code | 104 | 286 | 457 | 2.42 |
| CoT+Code+Hint | 24 | 771 | 595 | 2.79 |
| ReAct+Engine | 24 | 118 | 283 | 3.62 |
| CoE-R | 104 | 1340 | 453 | 3.75 |
| CoE-RTC | 104 | 2103 | 789 | 3.75 |

## Table 2 — Spearman correlation: prompt length vs score

**Overall (across all 464 trials, conditions pooled)**:
- prompt length vs score: ρ = +0.324
- response length vs score: ρ = +0.387

Pooled correlation mixes the between-condition effect (longer-prompt
conditions also score higher) with the within-condition effect. The
within-condition rows below are the actual confound check.

**Within-condition (the real test)**:

| Condition | n | ρ(prompt_len, score) | ρ(resp_len, score) |
|---|---|---|---|
| Zero-CoT | 104 | +0.243 | +0.212 |
| CoT+Code | 104 | +0.409 | +0.464 |
| CoT+Code+Hint | 24 | +0.456 | +0.220 |
| ReAct+Engine | 24 | +0.218 | +0.137 |
| CoE-R | 104 | -0.308 | -0.314 |
| CoE-RTC | 104 | -0.374 | -0.072 |

## Table 3 — CoE-R vs CoE-RTC head-to-head

Paired by (source, domain, case_id): **104 matched pairs**.

| Metric | CoE-R | CoE-RTC | Δ (RTC − R) |
|---|---|---|---|
| Avg prompt len | 1340 | 2103 | +763 (+56.9%) |
| Avg response len | 453 | 789 | +336 |
| Avg score | 3.75 | 3.75 | +0.00 |

Trial-by-trial agreement: RTC > R in 0 pairs, R > RTC in 0 pairs, equal in 104 pairs.

## Verdict

The pooled correlation (ρ ≈ +0.32) is **between-condition** noise: the high-scoring conditions (CoE-R, CoE-RTC) happen to also have the longest prompts, so any cross-condition pooling will produce a positive rank correlation regardless of whether length actually causes score. The within-condition rows are what matter for the confound check, and they tell two different stories:

- In the **lower-scoring** conditions (Zero-CoT, CoT+Code, CoT+Code+Hint, ReAct+Engine), within-condition ρ is mildly positive (+0.22 to +0.46). This is consistent with "the agent that engages more thoroughly with a given problem also writes a longer chain and sometimes a longer restatement". It is NOT consistent with the cross-condition gap, because those conditions all sit at score ≤ 2.79 — adding length within them does not lift them to CoE territory (3.75).

- In the **high-scoring** CoE conditions, within-condition ρ is **negative** (−0.31 for CoE-R, −0.37 for CoE-RTC). Longer CoE prompts do not score higher; if anything, the harder cases need longer engine output and tend to lose a point. This rules out a "more tokens → more score" explanation for CoE's lead — the direction is wrong.

The CoE-R vs CoE-RTC pair is the cleanest control we have: CoE-RTC's prompt is **56.9% longer** and its response is 74.1% longer, yet **104/104** matched pairs score identically and the mean score delta is exactly +0.00. The T (topology) and C (calculus) primitives that CoE-RTC stacks on top of CoE-R add prompt mass but no measurable score. If length were the lever, RTC should beat R by a clear margin; it does not.

**Conclusion**: the score advantage of CoE-R / CoE-RTC over Zero-CoT, CoT+Code, and CoT+Code+Hint is not explained by prompt length. The within-condition correlations are either weak-positive (in the low-score conditions, where longer prompts still don't reach 3.75) or negative (in CoE itself), and the CoE-R↔CoE-RTC ablation directly disconfirms the length hypothesis at the high end.
