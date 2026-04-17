# Five-Phase Report: Clipped SGD Heavy-Tail Convergence

## Phase 1: Scout

**Problem:** Prove $O(T^{-(1-1/p)})$ convergence rate for clipped SGD under $p$-th moment noise ($p \in (1,2]$).

5 routes identified:
1. Descent lemma + bias-variance decomposition (Medium)
2. Direct Lyapunov/moment analysis (Medium)
3. Truncation + martingale / Freedman concentration (Hard)
4. Interpolation via generalized Young's inequality (Hard)
5. Coupling / conditioning reduction to bounded-noise SGD (Hard)

**Selected routes for exploration:** Route 1 (primary), Route 2 (secondary).

## Phase 2: Explorer

### Route 1: Descent + Bias-Variance (PRIMARY — SUCCESS)

The exploration was extremely thorough (1917 lines), involving multiple dead ends and restarts before converging on the correct proof.

**Key challenges encountered:**

1. **Truncated moment lemma (Step 6):** Three failed approaches before finding the correct tail-sum + splitting method.

2. **Recovering $\|\nabla_t\|^2$ from $\phi_t = \min(\|\nabla_t\|^2, \tau\|\nabla_t\|)$:** This was the core difficulty. Multiple circular reasoning attempts:
   - Cauchy-Schwarz at sum level → circular
   - AM-GM decomposition → $\phi_t^2$ uncontrolled
   - Direct $\delta_t^2$ bounds → depends on $\|\nabla_t\|^2$, circular
   - $\eta = 1/(2L)$ choice → wrong-sign term for large gradients

3. **Final breakthrough (Step 10):** The key insight is that for Type B steps ($\|\nabla_t\| > \tau \ge 2\sigma$), the condition $\|\nabla_t\| > \sigma$ makes the remainder term $-\eta\|\nabla_t\|(\|\nabla_t\| - \sigma)$ negative, allowing it to be dropped. This yields a telescopable bound on $\sum \|\nabla_t\|(\|\nabla_t\|-\tau)_+$ of the same order as the $\phi_t$ bound.

### Route 2: Not separately explored (Route 1 succeeded)

## Phase 3: Judge

**Verdict: PASS**

The proof is mathematically correct. Key verification points:
- Descent lemma application: standard, correct
- Inner product decomposition with noise cancellation: correct
- Sub-additivity of $(\cdot)_+$: correct with clean proof
- Jensen's inequality for $\mathbb{E}[\|\xi_t\|]$: correct ($x^{1/p}$ concave for $p \ge 1$)
- Young's inequality constant ($1/4$ giving $3/4$ coefficient): correct
- Case B using $\tau \ge 2\sigma$: correct
- **Step 7 (key step):** The recovery of $\|\nabla_t\|^2$ via the observation that $\|\nabla_t\| > \sigma$ for Type B steps is the novel and correct insight
- Telescoping and parameter substitution: correct
- AM-GM to match stated form: correct

## Phase 4: Auditor

**Verdict: PASS**

Automated verification (6 checks, all passed):

1. **Sub-additivity:** 200K random samples, zero violations
2. **Jensen bound:** Verified for $p \in \{1.2, 1.5, 1.8, 2.0\}$ with 500K Pareto samples each
3. **Young's inequality:** 200K samples, zero violations, tight at $\|\nabla\| = 2\sigma$
4. **Step 10 algebraic identity:** Machine-precision verification of $(τ-σ)\|\nabla\| > 0$ for Type B
5. **Rate parameters:** Exact match for all $p, T$ combinations tested
6. **End-to-end simulation:** Clipped SGD on non-convex $f(x) = x^4/4 - x^2/2$ with Pareto noise ($p = 1.5$):
   - Expected log-log slope: $-0.333$
   - Observed (large $T$): $-0.359$ (within 8% of theory)

## Phase 5: Fixer

No fixes needed — proof passed audit.

## Summary

| Phase | Result |
|-------|--------|
| Scout | 5 routes, Route 1 selected |
| Explorer | Route 1 succeeded after extensive exploration |
| Judge | PASS — all steps verified |
| Auditor | PASS — 6/6 numerical checks passed |
| Fixer | Not needed |
