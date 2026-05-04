# Value Assessment: A1 — Adam Last-Iterate Lower Bound

**Date**: 2026-04-28

---

## 1. Academic Impact

**Score: 6/10**

### Positive factors

- **Timeliness**: The Apr 2026 AdaGrad-Norm paper (2604.10728) explicitly lists Adam/RMSProp last-iterate analysis as future work — this is a **hot, named open problem**. First-mover advantage exists.
- **Community interest**: Adam convergence has 10,000+ citations; any LB result for Adam attracts broad attention.
- **Closes a clean gap**: The smooth convex last-iterate LB for Adam is an explicit missing piece that practitioners and theorists have wondered about.
- **Citation potential**: Will be cited by any subsequent Adam theory paper, which is a large and growing class.

### Negative factors

- **Non-convex oracle complexity is already closed** (NeurIPS 2023 + ADOPT NeurIPS 2024). If the result only matches Ω(σD/√T) without a separation, it is the convex analog of an already-known result — incrementally interesting.
- **If result is "Adam last-iterate = SGD last-iterate"**: the theoretical message is "Adam is no worse but also no better than SGD in last-iterate convex smooth." This is positive about Adam but doesn't reveal deep new structure.
- **The high-impact result** (showing Adam's last-iterate is provably slower than its averaged iterate) has 8/10 impact but takes 10–12 weeks, not 6.

---

## 2. Portfolio Increment

**Score: 7/10**

### Differentiation from OP-2

| Dimension | OP-2 (SHB last-iterate LB) | A1 (Adam last-iterate LB) |
|-----------|---------------------------|--------------------------|
| Algorithm class | Fixed momentum (SHB) | Adaptive (Adam/RMSProp) |
| Key tool | Cycling lemma (GTD 2023) | Le Cam + noise-dominated EMA analysis |
| Setting | Stochastic non-SC convex smooth | Stochastic non-SC convex smooth |
| Main novelty | Cycling feasibility threshold β* | v_t concentration in noise-dominated regime |
| Technical difficulty | Research-level (cycling algebra) | Medium-hard (new EMA analysis) |

**Portfolio signal**: Demonstrates breadth across algorithm families (momentum → adaptive), capability to handle EMA-based state, and command of the Le Cam framework without cycling scaffolding.

### New capabilities demonstrated

1. **EMA second-moment analysis**: The v_t concentration lemma is a reusable tool for future adaptive method theory.
2. **Noise-dominated regime reduction**: The insight that $\hat{v}_t \to \sigma^2/(1-\beta_2)$ in the stochastic regime is clean and independently useful.
3. **Algorithm-specific LB vs. oracle LB distinction**: The paper sharpens the community's understanding of what kind of lower bound is possible for adaptive methods.

**Compared to OP-2**: The cycling theorem (SHB) is more technically novel, but the Adam LB is more practically relevant given Adam's dominance in practice. The portfolio benefit is roughly equivalent in depth, higher in breadth.

---

## 3. Endorser Match

### Primary endorser: 李晨毅 (Cheny Li, CityU) — Match: 8/10

**Reasoning**:
- Li Chenyi's group works on adaptive methods theory and bilevel optimization. The Adam last-iterate LB is directly in the adaptive methods convergence lane.
- OP-2 is SHB (a specific first-order method); A1 would demonstrate adaptive methods expertise, which is closer to Li Chenyi's portfolio.
- CityU location means Li Chenyi is likely aware of the AdaGrad-Norm gap paper (ICLR/NeurIPS community) and would recognize the timeliness.
- Connection path: adaptive methods → bilevel optimization (uses Adam as inner solver) → OP-2 lineage shows LB capability.

### Secondary endorser: 文再文 (Zaiwen Wen, NJU) — Match: 6/10

**Reasoning**:
- Wen Zaiwen works on optimization theory including adaptive methods. Less directly focused on last-iterate convergence theory than 李晨毅, but has broad optimization background that encompasses this topic.
- Would appreciate the "closing a gap" framing, but may see it as less novel than bilevel/min-max work.

### Note on 李肖 (current advisor, OP-2 lineage) — Match: 9/10 but excluded from "endorser" pool

- Most natural scientific supporter as the OP-2 lineage continues, but presumably already endorsing as advisor.

---

## 4. Comparison vs Continuing OP-2 Lineage

| Criterion | A1 (Adam LB) | OP-2 continuation (e.g., SHB strongly convex LB, or SHB averaging theory) |
|-----------|-------------|------------|
| Gap openness | Clear, named open problem | Multiple sub-problems, some more open than others |
| Toolbox reuse | HIGH (Le Cam, AdaGrad-Norm LB) | VERY HIGH (cycling lemma, all SHB tools) |
| Technical risk | MEDIUM (EMA analysis is doable) | LOWER (known techniques) |
| Novelty | MEDIUM-HIGH (new algorithm class) | MEDIUM (same algorithm, new setting) |
| Citation leverage | HIGH (Adam is the algorithm) | MEDIUM (SHB is important but less universal) |
| Endorser differentiation | Opens Li Chenyi connection | Stays in 李肖 lineage |
| 6-week feasibility | MEDIUM | HIGH |

**Recommendation on comparison**: OP-2 continuation is safer and faster. A1 is higher-upside but higher-risk. The optimal strategy for a 6-week sprint is:

- **If timeline is firm (6 weeks)**: Do OP-2 continuation for the main result, use A1 as a side exploration that produces at minimum the trivial LB (1 week) and possibly the full Le Cam proof (3 weeks).
- **If timeline is flexible (10–12 weeks)**: A1 is the better investment, targeting both the tight LB and the last-iterate vs average separation.

---

## 5. Overall Scores

| Dimension | Score |
|-----------|-------|
| Academic impact | 6/10 |
| Portfolio increment | 7/10 |
| Gap clarity | 8/10 (open, named) |
| Technical feasibility | 6/10 (Le Cam: doable; cycling: blocked) |
| Endorser match (top-1: 李晨毅) | 8/10 |
| 6-week feasibility | MEDIUM |
