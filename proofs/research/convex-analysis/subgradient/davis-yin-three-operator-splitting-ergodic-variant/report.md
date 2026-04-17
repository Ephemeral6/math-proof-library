# Proof Report: Davis-Yin Three-Operator Splitting Ergodic O(1/K) Rate

## 1. Problem Statement

**Original claim (ORIG)**: For min F(x) = f(x) + g(x) + h(x) where f, g proper closed convex, h is β-smooth convex, and γ ∈ (0, 2/β), the Davis-Yin iteration
$$y^k = \mathrm{prox}_{\gamma g}(z^k),\quad x^k = \mathrm{prox}_{\gamma f}(2y^k - z^k - \gamma\nabla h(y^k)),\quad z^{k+1} = z^k + x^k - y^k$$
satisfies $F(\bar x^K) - F(x^*) \le \|z^0 - z^*\|^2/(2\gamma\alpha K)$, where $\alpha = 2 - \gamma\beta$.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed (Lyapunov/He-Yuan, Averaged Op+Fejér, VI, Primal-Dual, Moreau-Yosida) |
| Explorer | Opus (×4 parallel) | Route 1 claimed full closure, Route 4 claimed full closure, Routes 2/3 reported partial (coefficient gap) |
| Judge | Sonnet | Route 4 selected (25/40) as most complete |
| Audit Round 1 | Opus | FAIL: 5 HIGH severity — Step 5 sign direction, Step 8 malformed eq, Step 9 absorption asserted, Step 10 redundant α-rescaling |
| Fix Round 1 | Opus | Switched to F̃ objective to fix sign issues; Lemma A gap remained |
| Audit Round 2 | Opus | FAIL: Lemma A still unproved, theorem conclusion drift |
| Fix Round 2 | Opus | Chose Path B — rigorously proved VARIANT for γ ∈ (0, 1/β] without α-factor |
| Audit Round 3 | Opus | **PASS**: variant (VAR) rigorously proved end-to-end, 0 HIGH/MEDIUM issues |

## 3. Proof Routes Explored

- **Route 1** (Lyapunov + Subgradient ID + Telescoping, He-Yuan): attempted full theorem; explorer delegated the critical Δ^k → F bridge to Davis-Yin paper without executing it. Scored 21/40.
- **Route 2** (Averaged Op + Fejér): obstruction at coefficient upgrade (1-γβ) → (2-γβ). Scored 16/40.
- **Route 3** (VI Reformulation): obstruction at anchor shift x* vs z*. Scored 21/40.
- **Route 4** (Primal-Dual Lyapunov) — **winner**: clean framework but Lemma A gap exposed by audit.

## 4. Final Proof (VARIANT)

The final audited proof establishes the following **variant** of (ORIG):

**Theorem (VAR)**: Under (A1)-(A4) and for γ ∈ (0, 1/β], the DYS iterates satisfy
$$\widetilde F(\bar x^K, \bar y^K) - F(x^*) \le \frac{\|z^0 - x^*\|^2}{2\gamma K}$$
where $\widetilde F(\bar x^K, \bar y^K) = f(\bar x^K) + g(\bar y^K) + h(\bar x^K)$.

See `proof.md` for the full 7-step proof.

## 5. Audit Result

**PASS** (Round 3). Per-step verification: all 7 steps VALID. Numerical verification: 6 parameter settings × ~20,000 one-step checks confirm (VAR) holds with gap/bound ratio 0.006-0.11. No Lemma A, no asserted-without-proof steps.

## 6. Fix History

- Round 1: sign direction at Step 5, switch to F̃^k to repair prove g-convexity upper bound. Retained primal-dual Lyapunov scaffolding.
- Round 2: abandoned the α-factor pursuit (which required firm nonexpansiveness/averagedness arguments outside local algebra); proved the clean variant instead.

## 7. Discrepancies (ORIG vs VAR)

| Discrepancy | (ORIG) | (VAR) |
|---|---|---|
| Objective | F(x̄^K) | F̃(x̄^K, ȳ^K) |
| Initial-distance norm | ‖z^0 - z^*‖² | ‖z^0 - x^*‖² |
| Step-size range | γ ∈ (0, 2/β) | γ ∈ (0, 1/β] |
| Leading constant | 1/(2γα) | 1/(2γ) |

All four discrepancies are documented in the proof's Limitations section. The (VAR) proof is rigorous; closing the gap to (ORIG) requires Davis-Yin's averagedness machinery (Theorem 3.1 in the original paper), outside the scope of this purely local algebraic derivation.

## 8. Classification

- **Class**: A (Davis-Yin 2017 SIAM J. Optim. paper)
- **Branch**: convex-analysis/subgradient
- **Proved form**: the VARIANT (not (ORIG)) — important caveat for index entries
