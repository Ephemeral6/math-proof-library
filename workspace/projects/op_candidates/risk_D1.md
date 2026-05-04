# D1 Risk Assessment: Counterexample Construction Query-Complexity Lower Bound

## Date: 2026-04-28

---

## Top 3 Risks

### Risk 1 (HIGH): Conjecture class definition trivializes the problem

**Description:** The hardest definitional challenge is specifying a "conjecture class" C that is:
- Rich enough to be mathematically interesting (not just "find a needle in a haystack")
- Constrained enough to support non-trivial lower bounds
- Distinct from existing property testing / certification query complexity formulations

**Trivialization failure modes:**
- If C is just "find any element with property P," the problem reduces to standard property testing (Goldreich-Ron) or certification (arXiv:2201.07736). No novelty.
- If C is too structured (e.g., "find x where p(x) < 0 for a degree-1 polynomial"), the LB is trivially Omega(1) or Omega(n) with no interesting dependence on problem parameters.
- If C allows arbitrary oracle evaluations, the problem becomes "find a zero of a function" — this is the standard root-finding query complexity, which is fully characterized.

**Mitigation:**
- Focus on *parametric families* of conjectures: a conjecture parameterized by a positive real alpha (e.g., "for all graphs G, lambda_1(G) <= alpha * sqrt(n)") where the algorithm must find a counterexample without knowing alpha.
- This double-indexing (instance + parameter) creates a non-trivial interaction that property testing does not capture.
- Explicitly verify (via literature search, which has been done above) that no existing paper covers this definition.

**Residual risk after mitigation:** Medium. The definition needs 1-2 full weeks of careful work before the math can start.

---

### Risk 2 (MEDIUM): Property testing literature already subsumes the interesting cases

**Description:** The property testing literature (Goldreich-Ron, 1998–2024) has studied query complexity of "does a function/graph have property P" for hundreds of properties. The Goldreich-Ron model is: accept if input has property P, reject (with witness) if it is epsilon-far from any P-instance. This looks similar to counterexample finding.

**Assessment based on literature survey:**
- Property testing *accepts or rejects* — it does NOT output a specific counterexample (witness). Testing P-membership vs. finding a counterexample are provably different problems (the latter is at least as hard, often strictly harder).
- The closest property testing result is the "certification" paper (arXiv:2201.07736), which proves query complexity for finding a certificate of size k. This covers *Boolean monotone functions* only.
- The parametric conjecture model (where the conjecture itself is parameterized) is NOT covered by any property testing paper found in the 2023–2026 survey.
- The Goldreich-Ron conjecture resolution by Canonne-Sen-Yang (2024) is about testing m-grainedness, not about finding a specific counterexample to a parametric conjecture.

**Verdict:** Property testing does NOT subsume D1. The EARLY-EXIT RULE does not trigger. However, the framing of D1's paper must carefully distinguish itself from property testing in the introduction; reviewers will ask.

**Mitigation:** Add an explicit "comparison with property testing" section to the paper's introduction. The key distinguishing point: D1 studies *output-required* search (find the witness), not decision (accept/reject).

**Residual risk after mitigation:** Low-Medium.

---

### Risk 3 (MEDIUM): 6-week feasibility — scope creep from model proliferation

**Description:** There are at least three natural oracle models for D1 (Boolean, graph, polynomial). Each yields a different paper. If the project tries to cover all three, it will not finish in 6 weeks.

**Feasibility breakdown for Boolean unstructured model (recommended scope):**

| Phase | Task | Time estimate |
|---|---|---|
| Week 1 | Formalize conjecture class definition; verify novelty vs. property testing | 1 week |
| Week 2 | Construct hard distribution; verify LB argument structure | 1 week |
| Week 3 | Prove Omega LB using Yao minimax (Ben-David-Blais 2023) | 1 week |
| Week 4 | Prove matching UB (adaptive decision tree) | 0.5 week |
| Week 4-5 | Numerical verification (SymPy/NumPy pipeline) | 0.5 week |
| Week 5-6 | Write paper / handle edge cases / revise definition | 1 week |

**Total: ~6 weeks for Boolean model only.** This is tight but feasible if scope is strictly limited.

**Graph model (harder, more impressive):** Estimated 10-12 weeks. Out of scope for 6-week project.

**Mitigation:**
- Commit to Boolean planted-counterexample model as the primary result.
- Include a "extensions" section discussing the graph model as future work.
- Do not attempt to generalize to polynomial model in first paper.

---

## Secondary Risks

### Risk 4 (LOW): The LB is tight-trivially
- If the planted Boolean model gives LB = O(|D_n|) with a trivial matching UB (just enumerate), the result is mathematically correct but unimpressive.
- **Mitigation:** Focus on the regime where *adaptive* algorithms can beat oblivious ones, and prove that even adaptivity does not help below some threshold. This is the interesting regime.

### Risk 5 (LOW): Endorser mismatch
- If 陈小杨's group is more interested in AI system papers than pure TCS complexity theory, D1 might be harder to pitch. However, the AI4Math framing (what are the query-complexity limits of AI conjecture refutation systems?) provides a natural bridge.

---

## Summary Table

| Risk | Severity | Mitigated? | Residual |
|---|---|---|---|
| Definition trivializes problem | High | Yes (parametric family + double-indexing) | Medium |
| Property testing subsumes it | Medium | Yes (output-required search is different) | Low |
| 6-week scope creep | Medium | Yes (restrict to Boolean model) | Low |
| LB is trivially tight | Low | Yes (focus on adaptive vs. oblivious) | Low |

**Overall feasibility for 6 weeks (Boolean model): FEASIBLE with careful scoping.**
