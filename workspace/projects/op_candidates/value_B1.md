# Value Assessment: B1 — Bilevel Optimization Last-Iterate Lower Bound

Date: 2026-04-28

---

## Impact Score: 7.5 / 10

### Rationale

**Positives:**
- Bilevel optimization is one of the hottest areas in ML theory (2021-2026). Application domains: meta-learning (MAML), hyperparameter optimization, NAS, federated learning, RL (actor-critic). NeurIPS 2024 had multiple bilevel papers; ICML 2025 trending similarly.
- Last-iterate convergence is a well-recognized open problem in bilevel. Practitioners universally use the last iterate (no one averages in meta-learning), yet there is zero theoretical last-iterate guarantee for bilevel SGD. A first LB result would directly motivate new algorithmic work.
- The result "last-iterate bilevel SGD is provably suboptimal" would be immediately actionable: it tells practitioners that averaging (e.g., Polyak-Ruppert for bilevel) should be preferred, and it opens a companion UB question.
- Ji 2511.19656 (Nov 2025) just established oracle complexity LBs, which means the community has been primed to receive LB results in bilevel. A last-iterate LB is a natural next step and timely.

**Negatives:**
- The result is inherently "meta" (a LB about what practitioners already do), so uptake depends on whether upper-bound algorithms are developed in parallel.
- Bilevel LB results in general (Ji-Liang 2023, Ji 2025) have been cited but are somewhat niche — the main excitement is on the algorithmic side.
- The convex-SC setting (upper convex, not nonconvex) is even more niche. If targeting NC-SC, the impact is higher but the hardness is also higher.

Score: 7.5 is appropriate — high relevance to hot topic, but narrower audience than a generalization-bound or universal SGD result.

---

## Portfolio Increment: 8 / 10

### Rationale vs. OP-2

OP-2 is a last-iterate LB for stochastic heavy-ball (SHB), single-level, nonconvex/SC. B1 would be:
- Same proof style (Le Cam + cycling), same output type (last-iterate LB).
- Different problem class: **nested** optimization. Entirely different oracle model.
- Different technical challenges: hypergradient bias, nested oracle, two-timescale.

The increment is high because:
1. Demonstrates the research program generalizes: OP-2's techniques are not one-off, they apply to a harder, more applied problem class.
2. Opens a new subfield: "last-iterate theory for bilevel optimization" is currently empty. B1 would be the founding paper.
3. Complements OP-2 in a portfolio narrative: "We study last-iterate convergence across problem complexity levels — from single-level stochastic to bilevel nested optimization."

The increment is NOT 10/10 because: the techniques are genuinely related to OP-2, and a reviewer who knows OP-2 will ask "is this just OP-2 applied to bilevel?" The answer must be: no, because of hypergradient bias (new), nested oracle (new), and reduction theorem (new). This needs to be articulated carefully.

---

## Endorser Match Assessment

### 文再文 (Wen Zaiwen, NJU / PKU)

**Domain match**: Strong. Wen is known for bilevel/min-max in the context of deep learning optimization (see NeurIPS 2024 "First-Order Minimax Bilevel Optimization" and related PKU group output). His group works on bilevel algorithms, not LBs specifically, but he would understand the contribution immediately.

**LB receptiveness**: Medium. Wen's group publishes primarily algorithmic UB results. A LB result is adjacent but not his core output. He would endorse it if convinced the LB is technically solid, but he may not champion it as strongly as an algorithmic result.

**Rating**: MEDIUM-HIGH (would write a supporting letter, not a championing letter).

### 李晨毅 (Li Chenyi, CityU)

**Domain match**: VERY HIGH. Li Chenyi is the author of 2511.22331 "On the Condition Number Dependency in Bilevel Optimization" (Nov 2025, co-authored with Jingzhao Zhang). This paper is directly on bilevel LBs — the same technical space as B1. Li is actively working on bilevel complexity lower bounds, which means:
- He is the closest possible domain match.
- He would immediately understand the contribution and its position in the literature.
- He has co-authored directly relevant LB results, making him a natural collaborator or endorser.
- CityU is the institution that is leading on bilevel LBs right now.

**LB receptiveness**: HIGH. Unlike Wen (primarily algorithmic), Li is producing LB results. He cares about this.

**Rating**: STRONG (highest possible endorser match for B1 specifically).

**Strategic recommendation**: Li Chenyi is the highest-priority endorser for B1. His 2511.22331 paper (oracle complexity κ-dependence LB) is the closest existing work — B1 (last-iterate LB) would complement rather than compete with his result. A collaboration framing ("extending Li-Zhang to the last-iterate dimension") is a natural pitch. This is likely the strongest endorser alignment across all candidate directions, if B1 is chosen.

---

## PhD Advisor Fit (Next Stage)

If the goal is PhD admission with a focus on optimization theory:

- Li Chenyi (CityU): **Direct fit**. B1 is essentially in his current research program. A completed last-iterate LB paper would be a strong application signal. CityU is a top-tier HK institution for optimization.
- Wen Zaiwen (NJU/PKU): **Good fit**. OP-2 + B1 together show breadth in stochastic optimization and bilevel. PKU is a natural target for China-based PhD programs.
- 文再文's group at Peking University has a strong pipeline for theoretical ML; B1 is adjacent to their work on bilevel algorithms. Would likely view a last-iterate LB as a complement to their UB work.

**Strongest single-direction fit for PhD application: Li Chenyi at CityU.**

---

## Summary Table

| Dimension | Score | Notes |
|---|---|---|
| Impact | 7.5 / 10 | Hot topic, first LB of type, actionable for practitioners |
| Portfolio increment | 8 / 10 | Extends OP-2 program to harder problem class |
| 文再文 match | MEDIUM-HIGH | Bilevel-adjacent, primarily algorithmic group |
| 李晨毅 match | STRONG / HIGH | Direct domain, co-author of bilevel κ-LB paper |
| PhD application value | HIGH | B1 + OP-2 = strong bilevel LB research identity |
| Early-exit triggered | NO | Last-iterate LB for bilevel not yet proved |

---

## Recommendation

B1 is the **highest endorser-alignment direction** among the candidates, specifically due to Li Chenyi (CityU). The combination of OP-2 (single-level last-iterate LB) + B1 (bilevel last-iterate LB) creates a coherent research program ("last-iterate complexity across optimization levels") that is both novel and well-positioned for publication at NeurIPS/ICML 2026-2027. The main risk is technical (hypergradient bias Week 4), not strategic. Recommend PROCEED with Week 1 feasibility check.
