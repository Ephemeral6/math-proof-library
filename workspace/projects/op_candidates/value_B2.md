# Value Assessment: B2 — Min-Max Last-Iterate Lower Bound

## Date: 2026-04-28

---

## 1. Impact assessment

### Field impact (if original gap were open)
- Last-iterate convergence in saddle-point optimization is a *hot* fundamental problem: underpins GAN training, robust optimization, reinforcement learning (actor-critic), game theory.
- A tight lower bound for EG/OGDA last-iterate in smooth C-C would have been a top-venue result (NeurIPS/ICML/COLT).
- **But**: this was already done by Golowich 2020 + Cai-Oikonomou 2022. The field impact of RE-DOING this is zero.

### Field impact (for remaining open problems)

**B2a — Stochastic OGDA/EG last-iterate LB**:
- Impact: HIGH if done cleanly. Stochastic saddle-point algorithms are the workhorse of modern ML (GAN training, MAML, RL). A fundamental LB on what noise does to last-iterate is directly relevant to practice.
- Would be publishable at NeurIPS/ICML.
- Benchmark comparison: comparable in impact to OP-2 (stochastic SHB LB), which is the user's current project.

**B2b — All-methods O(1/T) LB for smooth C-C**:
- Impact: VERY HIGH — would be a landmark result establishing O(1/T) as the optimal last-iterate rate for smooth C-C.
- Would be publishable at COLT/STOC/FOCS or top ML venue.
- But: 6-week timeline is unrealistic.

---

## 2. Portfolio coherence

### Fit with OP-2 (SHB stochastic non-SC last-iterate LB)

| Dimension | OP-2 | B2 original | B2a (stochastic EG LB) |
|---|---|---|---|
| Setting | Stochastic minimization (non-SC) | Smooth C-C saddle-point | Stochastic smooth C-C |
| Algorithm | SHB (heavy ball) | EG/OGDA | EG/OGDA stochastic |
| Technique | Le Cam + cycling | Direct cycling / tangent residual | Le Cam + cycling |
| Status | Completed | CLOSED (Cai 2022) | OPEN |
| Pipeline reuse | N/A | ogda-bilinear LB needed | OP-2 oracle model |

**B2a** is a natural "sister paper" to OP-2: same Le Cam framework, same stochastic oracle model, extended to saddle-point. Portfolio coherence: HIGH.

**Original B2** adds nothing new and contradicts OP-2's philosophy of finding genuine gaps.

---

## 3. Endorser match: 文再文 (NJU)

**Assessment of 文再文's research profile**:
- NJU, optimization theory. Works on distributed optimization, primal-dual methods, ADMM, saddle-point problems.
- Papers include: ADMM convergence, stochastic primal-dual, distributed saddle-point methods.
- Last-iterate theory for saddle-point methods is directly in scope.

**Match strength for original B2**: MEDIUM. The topic matches but if the result reproduces Cai 2022, there is nothing to endorse.

**Match strength for B2a (stochastic EG/OGDA LB)**: HIGH.
- Stochastic saddle-point is core to 文再文's work.
- A lower bound result complementing OP-2 (which is minimization) would round out the portfolio.
- The NJU/optimization-theory community respects tight lower bounds with Le Cam methodology.

**Match strength for B2b (all-methods LB)**: MEDIUM-HIGH in theory, but the problem is too speculative for a 6-week project to produce endorsable results.

---

## 4. Comparison to competing directions (portfolio context)

Assuming B1 (SHB with momentum decay), B2 (min-max LB), C1 (some other direction) are the competing candidates:

**B2 original** competes directly with highly established work from the dominant group in the field (Cai/Daskalakis). The risk-adjusted value is LOW.

**B2a** is more targeted. If confirmed open, it represents:
- 1 clear open problem with concrete technique
- Natural OP-2 extension (good for thesis coherence)
- Endorser match with 文再文 and potentially 李肖 (if extended to stochastic optimization)
- 6-week timeline: feasible but risky (30–40% success probability given scoop risk and technical novelty)

---

## 5. Overall value score

| Criterion | Original B2 | B2a (stochastic) | B2b (all-methods) |
|---|---|---|---|
| Gap genuinely open | NO | YES | YES |
| 6-week feasibility | N/A | 35% | <10% |
| Impact if successful | 0 | High (NeurIPS) | Very High (COLT/NeurIPS) |
| Scoop risk | N/A | Very High | High |
| Portfolio coherence | Low | High | Medium |
| Endorser match (文再文) | Medium | High | Medium-High |
| **Recommendation** | **SKIP** | **CONDITIONAL** | **DEFER** |

**CONDITIONAL** for B2a means: only pursue if (1) confirmed open via direct Gorbunov EUROPT 2024 content check, (2) OP-2 Le Cam oracle framework transfers with <2 weeks of adaptation work, (3) willing to accept 35% success probability and prepare contingency.

---

## 6. Summary verdict

**Original B2: SKIP.** Cai-Oikonomou 2022 closed the stated gap. The Daskalakis group owns this space.

**B2a (stochastic OGDA/EG LB): CONDITIONAL PURSUE** — only as a secondary option if B1 or another direction fails. Would require immediate scoop verification before committing.

**Endorser 文再文**: Would be a strong endorser for B2a if the result is clean and extends the stochastic saddle-point LB toolkit. Match is genuine, not forced.
