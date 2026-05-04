# Value Assessment: Direction A2
# SHB Non-Convex Stochastic Lower Bound for ε-Stationary Point
# Generated: 2026-04-28

---

## 1. Impact Score: 6/10

### Rationale

**Upside factors:**
- Smooth non-convex stochastic optimization is the dominant setting in modern ML theory (deep learning theory). A result about SHB in this setting has a large potential audience.
- The ε-stationary complexity of momentum methods is a recognized open problem. Arjevani et al. explicitly do not address algorithm-specific bounds; filling this gap is independently motivated.
- If A2 achieves a separation (SHB strictly worse than SGD at some β), this would be the first result of its kind and would attract citation from the momentum/SGD community.
- The COLT 2025 and ICLR 2025 papers on related topics (Saad et al., Yarotsky-Velikanov) show the community is actively interested in tight bounds for momentum-type methods.

**Downside factors:**
- The result "SHB matches SGD at ε⁻⁴" (worst-case outcome) is confirmatory, not surprising. Most practitioners already assume SHB and SGD have the same non-convex complexity.
- Without a genuine separation (C(β) > C(0)), the result is primarily a "tidying up" of the theory.
- The setting (smooth non-convex, bounded variance) is increasingly viewed as too simple — the field has moved toward heavy-tailed noise, structured noise, and specific function classes. A clean ε⁻⁴ result for bounded variance may be seen as "closing the textbook" rather than opening new directions.
- Relatedly: COLT 2025 (Saad et al.) already tightens bounds for structured function classes. A2's value is higher if it handles one of these structured classes too; otherwise it is a result for the baseline setting.

**Calibration:** Impact score 6/10 reflects: potentially significant if separation is proved (would push to 8/10); confirmatory if only matching LB achieved (stays at 5/10).

---

## 2. Portfolio Increment Score: 5/10

### Rationale

**Positive:**
- A2 extends the SHB lower-bound portfolio from convex to non-convex, completing a natural progression. The existing library has:
  - `shb-no-acceleration-restricted` (OP-2): smooth convex, last iterate, ∀β∃f LB
  - `shb-cycling-critical-momentum`: sharp β* threshold (convex)
  - `shb-coefficient-suboptimality`, `shb-cooling-momentum-lb`: β-dependent suboptimality (convex)
  - `shb-no-acceleration-best-iterate`: best iterate (convex)
  Adding a non-convex result would fill the remaining dimension.

**Negative (incremental concern):**
- A2 is the fourth or fifth SHB lower-bound result in the library. The marginal value of one more SHB LB (in a different setting) is lower than the first (OP-2).
- The technique for A2 (oracle restriction or cycling) is not a new proof technique for the library; it reuses OP-2 machinery. No new proof tools would be added.
- The thesis/portfolio would have a strong SHB cluster but might look like over-specialization: 5+ results all about SHB may signal to readers that the contribution is narrowly focused.
- Compare to alternative directions (e.g., A3: adaptive methods, A4: multi-agent, B-series: different algorithm families) which would add breadth.

**Quantitative:** OP-2 was a "5-star" library addition (new technique + new result + fills canonical gap). A2 is likely a "3-star" addition (extends existing technique to new setting + fills a secondary gap). Portfolio increment 5/10 reflects this.

**The "too incremental" question directly:**
Yes, A2 is somewhat incremental relative to OP-2. The setting changes (convex → non-convex) but:
- The proof technique is expected to be similar (cycling or oracle restriction, both already in the pipeline).
- The statement is analogous (SHB does not accelerate / is suboptimal).
- The hard function construction builds directly on OP-2's construction.

However, "incremental" ≠ "not worth doing." The non-convex setting is arguably *more* relevant for practice than the convex setting. If A2 produces the first SHB-specific LB for non-convex smooth stochastic optimization, it fills a canonical gap. The question is whether this gap is canonical enough to warrant a standalone 6-week project versus being a 2-3 week extension appended to an OP-2 paper.

**Recommendation on incrementality:** If OP-2 is being written as a paper, A2 should be incorporated as a corollary or extension section in that paper rather than a separate project. If OP-2 is already submitted/published, A2 is a natural follow-up worth a standalone 6-week effort.

---

## 3. Endorser Match

### 文再文 (Wenzhen Wen) — Optimization: 8/10

文再文 is the strongest endorser match. A2 is:
- Squarely in deterministic/stochastic optimization theory.
- A follow-on to OP-2, which is already in the SHB lower-bound tradition.
- The non-convex extension is of direct interest to optimization theorists.
- A result at the level of "new LB for a canonical algorithm class" is the kind of result 文再文 publishes.

Score: 8/10 — high alignment, high expertise match, likely to appreciate both the non-convex setting and the algorithm-specific framing.

### 李肖 (Li Xiao) — Optimization: 7/10

Similar alignment to 文再文; Li Xiao's work spans convex and non-convex stochastic optimization. A2 fits. Slightly lower score because Li Xiao's recent work has emphasized adaptive methods and specific applications; A2 is more theoretical/baseline.

Score: 7/10.

### 陈小杨 (Xiaoyang Chen) — AI theory: 5/10

陈小杨 works on AI theory including learning theory and optimization for ML. A2 is relevant but less central to their specific interests. The non-convex setting (as in neural network training) is a connection point, but the paper would need to be framed more toward applications to attract their endorsement.

Score: 5/10.

### 李晨毅 (Chenyi Li) / 董彬 (Dong Bin) — AI4Math: 4/10

A2 is a pure optimization theory result with limited AI4Math connection. Formal verification of the LB proof could create a connection (Lean formalization), but the core result is not AI4Math content.

Score: 4/10 each.

**Best endorser: 文再文 (8/10)**

---

## 4. Comparison to OP-2

| Dimension | OP-2 | A2 |
|---|---|---|
| Setting | Smooth convex non-SC, last iterate | Smooth non-convex, ε-stationary |
| Technique | GTD cycling at μ→0 limit | Oracle restriction + non-convex cycling (new) |
| Novelty | First stochastic SHB LB (convex) | First SHB-specific LB (non-convex) |
| Difficulty | Research / advanced | Research (comparable) |
| Portfolio fit | High (fills canonical convex gap) | Medium (fills secondary non-convex gap) |
| Endorser | 文再文, 李肖 | Same |
| Publication target | ICML/NeurIPS theory track | Same |
| Incremental? | No (new setting + new technique) | Partially (new setting, reused technique) |

**Summary:** A2 is a natural and well-motivated next step, but it is one notch below OP-2 in novelty and impact. Its value is highest if (a) a genuine β-dependent separation from SGD can be proved, or (b) it is included as an extension in the OP-2 paper itself.
