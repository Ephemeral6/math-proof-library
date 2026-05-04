# Five-Phase Report — Problem 4.1

**Problem.** Error Propagation Bounds for Multi-Agent Verification Systems (Cumulative Reasoning style chain over $T$ steps with single-shot vs. $k$-retry verification).

---

## Phase 1 — Scout

Three modeling questions identified up front:
1. **What counts as a "verifier error"?** Resolved by collapsing both false-accept and false-reject into a single Bernoulli$(\varepsilon)$ event (model assumption M2).
2. **Why is the lower bound in (a) not automatically tight?** Because verifier errors can in principle cancel (false-accept of a wrong proposition followed by false-reject of a corrected one). Tightness therefore requires a construction that prevents cancellation.
3. **What does "k-retry" mean?** The cleanest model: each round runs up to $k$ independent verifier judgments; the round succeeds if any one is correct. This model maps directly to our Auditor–Fixer loop.

The math is elementary (independence + product of probabilities); the value is in the careful modeling. Estimated effort: <1h.

## Phase 2 — Explorer

Two route candidates explored:
- **Route A (used).** State (M1)–(M3) up front, derive both bounds via inclusion of "no error in any judgment" inside "chain correct." Tightness in (a) via honest-Proposer construction.
- **Route B (rejected).** Model verifier as a binary symmetric channel with separate false-accept rate $\varepsilon_{\mathrm{fa}}$ and false-reject rate $\varepsilon_{\mathrm{fr}}$. Cleaner phenomenology but (i) the problem statement only gives a single $\varepsilon$, (ii) introduces dependence on the Proposer's truth-rate, complicating the bound. Discarded — Route A subsumes Route B by setting $\varepsilon = \varepsilon_{\mathrm{fa}} + \varepsilon_{\mathrm{fr}}$ as a worst-case combined error.

Tightness in (a) was the only delicate step. Construction: honest Proposer never gives the Verifier a false proposition to err on, so the only way the Verifier can err is via false-reject. Each round contributes an independent multiplicative factor of $(1-\varepsilon)$, and the chain is correct iff none of these false-rejects fire. Equality is exact.

## Phase 3 — Judge

Selected Route A. The proof has three parts:
- (a) lower bound: 1 line via independence and inclusion.
- (a) tightness: explicit honest-Proposer instance, equality verified directly.
- (b) lower bound: 2 lines via independence inside-round and across-rounds.
- (c) arithmetic: SymPy exact + Monte Carlo cross-check.

## Phase 4 — Auditor

Five audit criteria checked (see `audit.md`):
1. Independence assumptions — explicit in (M2). PASS.
2. Tightness construction — fully specified, equality verified. PASS.
3. No over-claim in (b) — only inequality used; correlated-error caveat flagged. PASS.
4. (c) numerics — SymPy exact rationals + Monte Carlo $5{\times}10^5$ trials. PASS.
5. Both error modes (false-accept and false-reject) handled — combined into $\varepsilon$ in (M2); tightness instance uses false-reject only. PASS.

**Verdict: PASS, 0 fixer rounds required.**

## Phase 5 — Fixer

Not invoked.

---

## Final theorem statements

**Theorem 4.1(a).** Under model (M1)–(M3), with no retries,
$$
\Pr[\text{chain correct}] \ge (1-\varepsilon)^T,
$$
and the bound is tight: an honest Proposer paired with an i.i.d. Bernoulli$(\varepsilon)$ false-reject Verifier attains equality.

**Theorem 4.1(b).** Under model (M1)–(M3), with up to $k$ independent retries per round,
$$
\Pr[\text{chain correct}] \ge (1-\varepsilon^k)^T.
$$

**Corollary (numerical, $\varepsilon=0.14$, $k=3$, $T=10$).** Per-step error drops from $14\%$ to $0.27\%$; chain-level reliability rises from $22.1\%$ to $97.3\%$ (a $4.40\times$ lift), with at least a $0.752$ gap in success probability between Auditor–Fixer and single-shot CR verification.

---

## Files in this working directory

- `problem.md` — clean problem statement
- `proof.md` — final verified proof
- `scout_notes.md` — Phase-1 modeling notes
- `audit.md` — Phase-4 auditor report
- `sympy_check.py` — exact + Monte-Carlo verification of (c)
- `final_report.md` — this document
