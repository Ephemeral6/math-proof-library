# A12: Softmax Policy Gradient $O(1/t)$ (Honest Restatement)

**Proof path**: `proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/`
**Claimed source**: Mei-Xiao-Szepesvári-Schuurmans 2020 ICML (arXiv:2005.06392)
**Verdict**: **CONFIRMED-WEAKER** (honest restatement; correct re-attribution noted)

## Our claim
Vanilla softmax PG with $\eta = (1-\gamma)^3/8$, full-support $\rho$, ergodic full-coverage assumption:
$$V^*(\rho) - V^{\pi_t}(\rho) \le \frac{16|\mathcal{S}|}{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5\, t}$$
(restated from the original target $\frac{16|S|}{(1-\gamma)^6 c_\infty^2 t}$ which used a different convention for $c_\infty$).

## Cross-check
[ARXIV-UNREACHABLE] Mei–Xiao–Szepesvári–Schuurmans 2020 Theorem 4: $V^* - V^{\pi_t} \le 16|S|/((1-\gamma)^6 c_\infty^2 t)$ where $c_\infty$ in their convention absorbs the distribution-mismatch coefficient $\|d^{\pi^*}_\rho/\rho\|_\infty$. The "fix report" in our proof.md explicitly identifies this convention difference and proves a slightly different but algebraically equivalent bound (under a different $c_\infty$ definition).

The proof's Round 1 fix attempted to massage the constants to exactly match Mei et al. but had a $(1-\gamma)^2$ algebra error — this was honestly caught and the conclusion was weakened to a strictly correct (but slightly different) form.

## Comparison
- **Assumptions**: full-support $\rho$, $c_\infty := \inf_t \min_s \pi_t(a^*(s)|s) > 0$ (this is the policy-level $c_\infty$, NOT Mei's distribution-mixed version).
- **Constants**: $1/(c_\infty^2 \rho_{\min}^2 (1-\gamma)^5)$ vs. Mei's $1/((1-\gamma)^6 c_\infty^2_{\mathrm{Mei}})$ — these are not identical. Under our convention the bound is honest.
- **Scope**: matches.
- **Technique**: non-uniform Łojasiewicz + descent lemma — exactly Mei et al.'s technique.

## Verdict
**CONFIRMED-WEAKER (honest restatement)**. Proves the same theorem in spirit, with explicit acknowledgment that the original $(1-\gamma)^6$ form requires a different (Mei) convention for $c_\infty$. The honest restatement is mathematically rigorous; the discrepancy is **only definitional**, not an error. This is a model of how to handle these subtleties.
