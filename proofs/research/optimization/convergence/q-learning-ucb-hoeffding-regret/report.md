# Proof Report: UCB-Hoeffding Q-Learning Regret

## 1. Problem Statement

Prove that UCB-Hoeffding Q-learning (Jin–Allen Zhu–Bubeck–Jordan 2018 NeurIPS) on an episodic tabular MDP with $S$ states, $A$ actions, horizon $H$, and $K$ episodes ($T=KH$), with learning rate $\alpha_t = (H+1)/(H+t)$ and Hoeffding bonus $b_t = c\sqrt{H^3\iota/t}$ (where $\iota = \log(8SAHK^2/\delta)$), satisfies with probability $\ge 1-\delta$:
$$\mathrm{Regret}(K) = \sum_{k=1}^K [V_1^*(s_1^k) - V_1^{\pi_k}(s_1^k)] \le 70\,\sqrt{H^4 SAT\,\iota^2}.$$

See `problem.md` for the full setup.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed (book / martingale-first / advantage / expert-reduction) |
| Explorer | Opus × 4 | Route A ✓ ($\sqrt{H^4}$); B suboptimal ($\sqrt{H^6}$); C suboptimal ($\sqrt{H^5}$); D fails structurally for $H\ge 2$ |
| Judge | Sonnet | Route A selected (27/40), others ELIGIBLE_WITH_GAP or INELIGIBLE |
| Audit R1 | Opus | PASS with 1 MEDIUM + 4 LOW |
| Fix R1 | Opus | All 5 issues addressed, $C=70$ unchanged |
| Audit R2 | Opus | PASS, no HIGH/MEDIUM issues, no new errors |

## 3. Proof Routes Explored

- **Route A (JABJ book proof)**: Backward induction on $h$ with interleaved Azuma concentration; visit-count exchange via (L4) to get $(1+1/H)^H \le e$ horizon accumulation. **Winner, 27/40.**
- **Route B (Martingale-first)**: Global Azuma event up front, then pathwise analysis. Cleaner separation but forces a $\sum_h$ recursion that loses a factor of $H$. Achieves $\sqrt{H^6 SAT}$. 20/40.
- **Route C (Advantage decomposition)**: Work with $\delta_h^k = V_h^k - V_h^{\pi_k}$ directly. Reduces to Route A modulo renaming but loses $\sqrt H$ at the per-step recursion step. Achieves $\sqrt{H^5 SAT}$. 20/40.
- **Route D (Online learning / expert reduction)**: Reduce to OCO over cells. Fails for $H \ge 2$ because Bellman's nested $\max$ is non-convex; partial positive for $H=1$ (bandits). 19/40, ineligible.

**Convergent finding**: Routes B and C independently flagged that the original problem.md bonus $cH\sqrt{\iota/t}$ was too small by a factor of $\sqrt H$. Problem amended mid-workflow to match JABJ 2018.

## 4. Final Proof

See `proof.md`.

## 5. Audit Result

**PASS** after 1 Fix round. Round 1 found 1 MEDIUM (union-bound arithmetic) + 4 LOW issues; all fixed in round 1 Fix. Round 2 audit confirmed fixes with no new errors. Empirical simulation ($S=A=2, H=3, K=100$) gave regret $\sim 10^{-4}$ below theoretical bound.

## 6. Fix History

Round 1 fixes:
- Redefined $\iota := \log(8SAHK^2/\delta)$ so the union bound is sound for every $K \ge 1$ without a side condition.
- Made explicit the algebraic chain $\sqrt\iota \le \iota$ (since $\iota \ge \log 8 > 1$).
- Added the $L2$-case algebra line $4\sqrt 2 \le 6 \iff 32 \le 36$ at $H=1$.
- Labeled the index claim $n_h^{e_{j'}}(s,a) = j'-1$ in the visit-exchange step.
- Made explicit the convention $\beta_0 := \beta_1$ and the edge-term accounting in Step 7.

Final constant $C = 24e + 4 \approx 69.24 \le 70$, unchanged by fixes.
