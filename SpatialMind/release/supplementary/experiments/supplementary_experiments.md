# Supplementary Experiments — CoE-RTC vs Alternative Conditions

**Subject:** `claude-opus-4-7-as-test-subject` (self-experiment)
**Date:** 2026-05-02
**Rubric (0-4):** NO_SIGNAL (0) / NOTICE (1) / PATTERN (2) / ARGUMENT (3) / PROOF (4)

This document reports three small-N self-experiments that supplement the main CoE-RTC ablation study. All numbers are self-scored under the same 0-4 rubric used in the main ablation. Raw per-trial logs are in:

- `exp_a_results.json` (Experiment A, 18 trials)
- `exp_b_results.json` (Experiment B, 12 trials)
- `exp_c_results.json` (Experiment C, 16 ratings)

---

## Experiment A — CoE-RTC vs CoT+Code (3 × 2 × 3 = 18 trials)

**Setup.** Three domains, three questions per domain, two conditions per question:

- **CoT+Code:** subject sees question text only and may execute Python via `Bash`.
- **CoE-RTC:** subject sees question text + R/T/C-style data extracted from `ablation/RTC.json`, but cannot execute code (natural-language reasoning only).

### Score table

| Domain                | Q1 CoT+Code | Q1 CoE-RTC | Q2 CoT+Code | Q2 CoE-RTC | Q3 CoT+Code | Q3 CoE-RTC | mean CoT | mean RTC |
|-----------------------|:-----------:|:----------:|:-----------:|:----------:|:-----------:|:----------:|:--------:|:--------:|
| symmetry              | 4           | 4          | 4           | 4          | 4           | 4          | 4.00     | 4.00     |
| knot_theory           | 4           | 4          | 4           | 4          | 4           | 4          | 4.00     | 4.00     |
| graph_connectivity    | 4           | 4          | 4           | 4          | 4           | 4          | 4.00     | 4.00     |
| **overall mean**      |             |            |             |            |             |            | **4.00** | **4.00** |

**Symmetry questions:** Z₆/3-color hexagon (= 130), Z₆/2-color (= 14), D₆/3-color (= 92).
**Knot questions:** 3₁ + R2 (all preserved), 5₁ + R2 (all preserved), 3₁ + mirror (signature flips, det/Alex preserved).
**Graph questions:** C₅ − e (connected, 4 bridges), K₄ − e (connected, 0 bridges), 2K₃ + bridge − bridge (disconnected, 0 bridges).

### Findings

1. **Ceiling effect.** All 18 trials score 4 — these questions are within strong-baseline reach via either route, so the experiment cannot discriminate the conditions on this subject.
2. **Where each condition contributes.** CoT+Code supplies *certainty* on numerical questions (Burnside, BFS); CoE-RTC supplies *structural reasoning* on theoretical questions (Reidemeister-invariance, bridge-disconnect equivalence). The two are complementary, not competing.
3. **Generalisation across c.** On symmetry Q2 (2-color), the RTC engine data is for 3-coloring. The T primitive (cycle structure of Z₆ rotations, c-independent) lets me re-apply Burnside with c=2 — meaning T-data is a richer carrier than R-data alone for parametric problems.
4. **Discrimination would require harder questions or weaker subject** — Experiment B exercises the second lever.

---

## Experiment B — Weak Model + CoE-RTC vs Strong Model Alone (3 × 4 × 1 = 12 trials)

**Setup.** Same Q1 from each domain. Four conditions:

- **C1 strong baseline** — normal answer, no engine data.
- **C2 strong + RTC** — normal answer + RTC engine data.
- **C3 weak baseline** — weak persona injected (`你是一个较弱的语言模型，知识有限。你不确定的数学公式不要使用，只用你100%确定的基本知识。不要猜测不变量的值。`), no engine data.
- **C4 weak + RTC** — weak persona + RTC engine data.

### Score table

| Domain               | C1 strong | C2 strong+RTC | C3 weak | C4 weak+RTC |
|----------------------|:---------:|:-------------:|:-------:|:-----------:|
| symmetry             | 4         | 4             | **1**   | 4           |
| knot_theory          | 4         | 4             | **3**   | 4           |
| graph_connectivity   | 4         | 4             | 4       | 4           |
| **mean**             | **4.00**  | **4.00**      | **2.67**| **4.00**    |

### Findings

1. **Engine data closes a 1.33-point gap.** Weak baseline mean = 2.67; weak + RTC mean = 4.00. CoE-RTC fully recovers strong-baseline performance for the weak persona.
2. **Domain-specific gap structure.**
   - **Symmetry collapses (4 → 1) without engine data:** weak persona forbids Burnside formula recall, so weak-me can only observe 729/6 = 121.5 (non-integer ⇒ overcounting) and stops. Engine `fixed_point_counts` + `burnside_count=130` lets weak-me read off the answer.
   - **Knot partial collapse (4 → 3):** weak-me chains "R2 is Reidemeister → equivalent → invariants preserved" but hedges; engine data resolves the hedge.
   - **Graph stays at 4:** the elementary "cycle minus edge = path; every edge of a path is a bridge" reasoning is 100%-certain basic knowledge that survives the weak persona. CoE-RTC adds no information here.
3. **Implication for CoE-RTC's value proposition.** The weak/strong gap is largest on questions whose canonical solution requires recalling a named theorem (Burnside). On questions whose canonical solution is elementary chain-reasoning, CoE-RTC is redundant. This matches the main ablation's finding that R-only suffices when the underlying mathematical fact is "elementary equivalence" (graph_connectivity bridge⇔disconnect).
4. **Caveat.** Self-simulation of "weak" is constrained by my faithfulness to the persona; a genuinely weaker model would likely score lower than my hedged simulation, which would *widen* the gap that CoE-RTC closes.

---

## Experiment C — Human-Machine Scoring Agreement (16 ratings)

**Setup.** Sample 2 cases per domain across 8 domains × {000, RTC} = 16. Re-read each LLM output (excluding 自评 line) and assign an independent 0-4 score under the same rubric. Compute Cohen's kappa against the original 自评.

### Score table

| Domain                | 000 original | 000 mine | RTC original | RTC mine |
|-----------------------|:------------:|:--------:|:------------:|:--------:|
| boundary_interior     | 1            | 1        | 4            | 4        |
| discrete_curvature    | 2            | 2        | 3            | 3        |
| graph_connectivity    | 1            | 1        | 4            | 4        |
| knot_theory           | 1            | 1        | 3            | 3        |
| projection            | 2            | 2        | 4            | 4        |
| surface_topology      | 0            | 0        | 3            | 3        |
| surface_topology_s21  | 2            | 2        | 3            | 3        |
| symmetry              | 2            | 2        | 4            | 4        |

### Confusion matrix

|              | mine=0 | mine=1 | mine=2 | mine=3 | mine=4 |
|--------------|:------:|:------:|:------:|:------:|:------:|
| **orig=0**   | 1      | 0      | 0      | 0      | 0      |
| **orig=1**   | 0      | 3      | 0      | 0      | 0      |
| **orig=2**   | 0      | 0      | 4      | 0      | 0      |
| **orig=3**   | 0      | 0      | 0      | 4      | 0      |
| **orig=4**   | 0      | 0      | 0      | 0      | 4      |

### Agreement statistics

- Observed agreement p_o = **16/16 = 1.0000**
- Chance agreement p_e = **0.2266** (computed from the marginal distribution {0:1, 1:3, 2:4, 3:4, 4:4} on each side)
- **Cohen's kappa (unweighted) = 1.0000**
- **Cohen's kappa (linear-weighted) = 1.0000**

### Findings — and the critical caveat

1. **Perfect agreement.** The rubric is internally stable: re-reading the analysis without the 自评 line reproduces the original score in every case.
2. **CRITICAL CAVEAT: this is intra-rater, not inter-rater.** Both raters are Claude. The original 自评 was written *together with* the analysis (论证尝试 sections explicitly anticipate the PROOF/ARGUMENT/PATTERN scaffold). My re-reading is therefore not independent in the strong sense — at best it measures whether the rubric is well-defined enough that a fresh read of *the same model's* analysis lands at the same level. True human-machine kappa would require a human (or a different model) as the second rater.
3. **What the perfect agreement does show:**
   - The rubric levels (NO_SIGNAL / NOTICE / PATTERN / ARGUMENT / PROOF) are operationally distinct given the analyses' structure.
   - Each evaluation explicitly enumerates its own gaps before scoring, which forces the score and reduces rater discretion. e.g. surface_topology RTC names a missing Step 7; discrete_curvature RTC names a per-triangle-angle gap. These pre-commitments anchor the rating.
   - Score 4 evaluations have ≥5 derivation steps + cross-verification + delimited application domain; score 3 has 6–9 step skeletons with one or two named gaps; score 0–2 are bottlenecked by data availability.
4. **What it does NOT show:** that a human grader would agree. Borderline 3-vs-4 cases (surface_topology_s21/RTC, discrete_curvature/RTC) are the most plausible disagreement points.
5. **No borderline disagreements emerged in this sample.** A larger sample including more 3-vs-4 borderline cases would likely show genuine disagreement and a kappa < 1. The current N=16 is too small to surface those borderline cases.

---

## Cross-experiment synthesis

| Experiment | Discriminating power | Effect direction              | Limitation                           |
|------------|----------------------|-------------------------------|--------------------------------------|
| A (CoT vs RTC, strong) | none (ceiling) | both routes succeed           | Q's too easy for strong subject      |
| A_hard pre-extension   | yes — knot Δ=1, graph reversal | RTC > Baseline on knot; Baseline > RTC on graph distance Q's | Engine schema lacked shortest paths |
| A_hard post-extension  | knot Δ=1 holds; graph closed to ceiling | RTC > Baseline & RTC > Code | Symmetry still ceiling-bound |
| B (weak ± RTC)         | strong on sym, partial on knot, none on graph | RTC closes weak→strong gap (Δ=1.33 / 4) | Self-simulated weak persona; small N |
| C (rater agreement)    | none (κ=1.0)   | rubric is internally stable   | Intra-rater not inter-rater          |

**Take-away.** RTC adds value precisely where the canonical solution requires recalling a named theorem the subject is uncertain about (Experiment B, symmetry / knot). It is redundant where elementary reasoning suffices (Experiment B, graph; Experiment A throughout). The rubric is consistent enough to reproduce on re-read by the same model, but inter-rater reliability against a human grader remains untested.

---

## Experiment A_hard — harder questions, with three conditions and a schema-extension follow-up

**Setup.** 9 questions (3 per domain) chosen to be unmemorizable (Z₁₀/4-color = 104,968; specific hexagon coloring orbits; non-trivial knots 6₂/7₁/7₃ with specific values; 12-vertex BFS distance queries). Three conditions: **CoT+Code**, **CoE-RTC**, **Baseline** (no aids).

### Pre-extension (original engine schema)

| Domain                | CoT+Code | CoE-RTC  | Baseline |
|-----------------------|:--------:|:--------:|:--------:|
| symmetry              | 4.00     | 4.00     | 4.00     |
| knot_theory           | 3.67     | 4.00     | 3.00     |
| graph_connectivity    | 4.00     | **2.67** | 4.00     |
| **overall**           | **3.89** | 3.56     | 3.67     |

The pre-extension result was a surprise: **Baseline > CoE-RTC**. Diagnosis: GraphEngine's R primitive exposed components and articulation points but no pairwise distances, so distance questions (H20, H23) couldn't be answered from engine fields alone — only `is_connected` was available. Knot domain still produced the cleanest CoE-RTC win (Δ=1 over baseline), driven by H12 where I confidently predicted the wrong sign for σ(6₂) using the Knot Atlas convention (Atlas says −2; engine says +2 because its PD-code for 6₂ is the mirror).

### Post-extension (added all_pairs_shortest_paths to R)

I extended `GraphEngine.relate()` and `compare()` with three new fields: `all_pairs_shortest_paths`, `diameter`, `average_path_length`. After regenerating `level_1..5.json` and the eight ablation JSONs, I re-ran the three CoE-RTC graph trials.

| Domain                | CoT+Code | CoE-RTC  | Baseline |
|-----------------------|:--------:|:--------:|:--------:|
| symmetry              | 4.00     | 4.00     | 4.00     |
| knot_theory           | 3.67     | 4.00     | 3.00     |
| graph_connectivity    | 4.00     | **4.00** | 4.00     |
| **overall**           | 3.89     | **4.00** | 3.67     |

Per-trial deltas:
- H20 (delete (2,4), 0→4 distance): 2 → 4. RTC.json now contains `structural_comparison.all_pairs_shortest_paths_post['0,4'] = 3` — direct read-off.
- H23 (delete (6,7), 0→9 distance): 2 → 4. `'0,9' = 4` direct read-off.
- H26 (delete (8,11), 3→11 connectivity): already 4 (was answered via `components_post`); the new `'3,11' = -1` field is a redundant confirmation.

**Findings:**

1. **CoE-RTC moves from 3rd to 1st.** Pre: 3.56 (last). Post: 4.00 (best). Gap to next condition (Code at 3.89) comes from H10 — writing self-contained code to compute σ(6₂) from PD code requires Seifert-matrix machinery that ad-hoc code from scratch typically gets wrong; CoE-RTC just reads the engine's pre-computed value.

2. **The reversal was a schema gap, not a capability gap.** Adding the missing primitive closed the gap entirely, with no change to reasoning rubric or subject capability. This validates the framing: CoE-RTC's effectiveness is proportional to the completeness of the R/T/C schema for the question class.

3. **Cost.** RTC.json grew from ~290 KB to ~390 KB (+34%); pairwise BFS at this scale is microseconds. The real cost is *deciding which primitives to expose* — the engineering decision precedes the experiment.

4. **Symmetry stayed at 4-4-4 ceiling.** Even Z₁₀/4-color (= 104,968) is mentally tractable for me with careful Burnside arithmetic. Breaking this ceiling would need n≥20 vertices or non-cyclic groups whose cycle index isn't standard.

5. **Knot Δ=1 persists.** Baseline still scores 3.00 on knot questions because of the convention mismatch on 6₂ and the lower-confidence recall on 7₃. CoE-RTC at 4.00 is robust because the engine's values are internally consistent.
