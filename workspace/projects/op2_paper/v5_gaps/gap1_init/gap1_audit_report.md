# Gap 1 Self-Audit Report

**Date.** 2026-04-29
**Subject.** Gap 1, Route A: zero-momentum SHB last-iterate cycling on a positive-measure subset of $\mathcal F_{K=3}$.
**Source proof.** `workspace/active/op2_v5_gaps/gap1_init/gap1_proof.md` (verified by `gap1_verify.py`, status PASS).
**Audit script.** `workspace/active/op2_v5_gaps/gap1_init/audit/gap1_audit.py` (results in `gap1_audit_results.json`, raw output in `gap1_audit_output.txt`).

This report does **not** patch results to fit. The audit asked four targeted questions and the answers are reported as found.

---

## Audit 1 — proof vs numerical evidence (PASS with documented partial-rigor)

Static read of the 7-step DAG. Full table in `audit/audit1_analysis.md`. Summary:

| Step | Content | Rigor |
|------|---------|-------|
| L1 | $x_1^{\text{zero}} = \lambda(-\beta e_0+e_1+\beta e_2)$ | **STRICT** (algebra, SymPy-verified) |
| L2 | polytope-exit $\mathcal R_2$ open with $\operatorname{Leb}_3>0$ | **STRICT openness/measure**; only diagnoses *necessary* condition |
| L3 | Vieta $\Rightarrow$ linear analysis predicts decay | **STRICT** (algebra, SymPy-verified). Diagnostic only. |
| L4 | Floquet spectrum $\{\beta^{3/2}e^{\pm 3i\theta_\mu}\}$ at vertex Hessian $\mu I$ | **STRICT** modulo "$P_{\widetilde P}(\lambda e_0)$ on a vertex" (open, anchor-verified) |
| L5 | zero-momentum init $\in$ basin; $f_0(x_T)-f_0^*\ge \kappa LD^2/(23T)$ | **PARTIAL — primarily numerical** (basin membership and constant $1/23$ at anchor only) |
| L6 | non-emptiness witness for $\mathcal F^{\text{cycle}}_{K=3}$ | **PARTIAL** (rigorous existence by continuity; no quantitative bound on size) |
| L7 | period-6 complement | **NUMERICAL** (single anchor, no rigorous existence) |
| L8 | variance term $\sqrt 2\sigma D/(27\sqrt T)$ inherits | **STRICT** (decoupling) |

### Specific gaps flagged by user

**(a) "Cycling on positive-measure $F_{\text{usable}}$" — strict or numerical?**
*PARTIAL.* The polytope-exit set $\mathcal R_2$ has positive measure rigorously (open continuous strict inequality). The basin-inclusion claim "zero-momentum init reaches the cycle" is **numerical** (M1 at anchor; 16/54 in M3 grid). The continuity argument $\Rightarrow$ "some open neighborhood of the anchor lies in the basin" is rigorous in principle but produces no quantitative size — the 30% figure (16/54) is a numerical count, not a measure.

**(b) "Orbit converges to cycle" — convergence proof or numerical only?**
*NUMERICAL.* No quantitative convergence theorem. The closest claim is L5's $\|x_T\|\ge\lambda(1-C\beta^{3T/2})$ with "an explicit $C$ depending continuously on $(\beta,\eta L,\kappa)$"; $C$ is never computed. Support is M1 at anchor + M3 grid.

**(c) Floquet stability — strict or numerical?**
*STRICT.* The eigenvalue derivation $J=M_\mu\otimes I_2$, $\operatorname{spec}(J^3)=\{\beta^{3/2}e^{\pm 3i\theta_\mu}\}$ is closed-form and rigorous. M2 numerically confirms it (sanity check, not extra evidence). The vertex-projection assumption is verified at the anchor.

### Verdict on Audit 1

The proof is honestly described as a clean rigorous skeleton (L1, L2, L3, L4, L8) with a numerically-supported core (L5, L6, L7). It **does not** establish cycling on a positive-measure set by closed proof — it establishes cycling at one anchor by numerical simulation, and uses the qualitative "open continuous" wrapper to extend that to "*some* open positive-measure subset." This is normal for results of this type, but it is not an entirely closed-form theorem.

**Status.** PASS, with the partial-rigor scope explicitly noted. The proof's claims are valid as written, but the quantitative content (1/23 constant, 30% measure fraction) is empirical at the anchor.

---

## Audit 2 — cycling-threshold sensitivity (PASS — cycling is genuine)

### What the original M3 actually checks

`gap1_verify.py` line 446:
```python
rel_diff = abs(final_norm - target_R) / target_R   # |||x_T|| - lam| / lam
if final_norm < mp.mpf("1e-4"):
    n_decay += 1
elif rel_diff < mp.mpf("0.01"):     # threshold = 0.01 (1%)
    n_cycle += 1
```

So the cycling criterion is **relative final-norm deviation $<$ 1 %** — not $\|x_{T+3}-x_T\| <$ threshold.

### Sensitivity sweep (this audit, mpmath dps=50, T=5000)

For each of the 54 grid points we tightened the criterion to require **both** $\frac{|\|x_T\|-\lambda|}{\lambda}<\varepsilon$ **and** $\frac{\|x_T-x_{T-3}\|}{\lambda}<\varepsilon$:

| $\varepsilon$ | both$<\varepsilon$ | rel$<\varepsilon$ only | p3$<\varepsilon$ only |
|---|---|---|---|
| $10^{-2}$ | 15/54 (27.8%) | 16/54 (29.6%) | 42/54 (77.8%) |
| $10^{-6}$ | 15/54 | 15/54 | 42/54 |
| $10^{-8}$ | 15/54 | 15/54 | 42/54 |
| $10^{-10}$ | 15/54 | 15/54 | 42/54 |
| $10^{-20}$ | 15/54 | 15/54 | 42/54 |
| $10^{-30}$ | 15/54 | 15/54 | 42/54 |
| $10^{-40}$ | 15/54 | 15/54 | 42/54 |

The cycling-classified points have residuals $\sim 10^{-51}$ in *both* metrics (well below mpmath dps=50 floor). Sample anchor-region points:

```
beta=0.700 etaL=3.3448 kappa=0.3379:  rel_diff=0.00e+00  p3_err=2.67e-51
beta=0.750 etaL=2.9562 kappa=0.3716:  rel_diff=1.89e-51  p3_err=1.89e-51
beta=0.800 etaL=3.1423 kappa=0.3951:  rel_diff=...        p3_err=...
```

### Verdict

**PASS.** The cycling fraction is robust to numerical threshold across 38 orders of magnitude. The 16/54 (or 15/54 with the stricter combined metric) figure is genuine — these are real cycle-attractor points, not numerical artefacts. One point (the boundary case $\beta=0.85, \eta L=2.9285$, where $\|x_T\|=0.70628$ vs $\lambda=0.70711$) is on the cycle to about 3 digits but does not reach 50-digit precision in T=5000 — a slow-convergence edge. Removing it (15 vs 16) does not change the qualitative conclusion.

> **Note on the 42/54 figure under "p3<eps" alone.** Many points the original classified as "decay" still satisfy $\|x_T-x_{T-3}\|<\varepsilon$ — because if $x_t\to 0$, then $\|x_T - x_{T-3}\|\to 0$ trivially. Period-3 closure alone is NOT a cycling criterion (it confuses cycling with collapse). The relative-norm criterion is the right one; both criteria together are stricter still.

---

## Audit 3 — stochastic robustness (PASS — gradient floor survives)

Anchor $(0.8, 3.247, 0.387)$, additive gradient noise $\xi_t \sim \mathcal N(0,\sigma^2 I_2)$ per step, 200 samples × T=10000.

| $\sigma$ | $\mathbb E[\|x_T\|]$ | $\mathbb E[\|\nabla f_0(x_T)\|^2]$ | $P(\|x_T\|>0.5\lambda)$ | $P(\|x_T\|<0.01)$ |
|---|---|---|---|---|
| 0.01 | 0.656 | $3.18\times 10^{-1}$ | 0.905 (181/200) | 0.000 |
| 0.10 | 0.868 | $3.76\times 10^{-1}$ | 0.865 (173/200) | 0.000 |
| 0.50 | 3.717 | $3.41$ | 0.995 (199/200) | 0.000 |
| 1.00 | 6.989 | $1.10\times 10^{1}$ | 0.990 (198/200) | 0.000 |

Snapshot orbit-norm trajectory $\mathbb E[\|x_t\|]$ at $t=5,10,100,1000,5000,10000$ stays bounded throughout — no systematic decay observed at any noise level.

### Key observations

1. **No decay-to-0 anywhere.** Across 800 sample paths and 4 noise levels, $P(\|x_T\| < 0.01) = 0$ exactly. The orbit does not collapse.
2. **Gradient norm bounded away from 0.** Deterministic limit $\|\nabla f_0\|^2 \approx 0.347$ at the cycle. Stochastic values:
   - $\sigma=0.01$: 0.318 (slightly below — small noise reduces orbit norm slightly)
   - $\sigma=0.10$: 0.376 (slightly above)
   - $\sigma=0.50$, $1.00$: $\gg 0.347$ (noise pushes orbit *outward*, raising $\|\nabla f_0\|^2$).

   In the OP-2 sense, $\mathbb E[\|\nabla f\|^2] \ge C > 0$ holds with margin in *all* tested regimes.

3. **Cycling regime is stable under small noise.** At $\sigma\le 0.1$, $\mathbb E[\|x_T\|]\approx \lambda$ (0.65–0.87 vs $\lambda=0.71$); the cycle attractor remains the dominant feature.
4. **Large-noise regime is even safer.** At $\sigma\ge 0.5$, the orbit is noise-driven and lives well outside the cycle ($\mathbb E[\|x_T\|]=3.7$–7.0). This is *good* for the lower bound: large iterates make $f_0(x_T)-f_0^*$ large.

### Verdict

**PASS.** The cycling lower bound translates to the stochastic setting empirically with margin. The most relevant prediction — $\mathbb E[\|\nabla f(x_T)\|^2] \ge C > 0$ — holds for all tested $\sigma$, with $C$ ranging from $0.32$ (small noise) to $11$ (large noise).

> Caveat: this is empirical, not a stochastic convergence theorem. The proof did not contain one. A rigorous stochastic version would require a Foster–Lyapunov type argument; the empirical evidence is consistent with such an argument existing but does not constitute one.

---

## Audit 4 — transient vulnerability (PASS — does not destabilize)

### Deterministic transient (mpmath dps=50)

| $t$ | $\|x_t\|$ |
|---|---|
| 0 | 0.7071068 ($=\lambda$) |
| 1 | 1.2083046 |
| 2 | 0.7050989 |
| 3 | 1.1000186 |
| **4** | **0.1478347** |
| 5 | 1.0799379 |
| 6 | 0.2400028 |
| 7 | 1.1114897 |
| 8 | 0.3509378 |
| 9 | 0.6516694 |
| 10 | 0.6057238 |

So $\|x_4\| = 0.1478$, $\|x_4\|/\lambda = 0.209$. This matches the $0.0437$ ratio in the proof:
$\frac{4 \cdot \mu/2 \cdot \|x_4\|^2}{\kappa L D^2} = \frac{4 \cdot 0.1935 \cdot 0.02185}{0.387} = 0.0437$ ✓

Transient passes within $0.21\lambda$ of zero at $t=4$. The proof's $1/23$ constant is binding here.

### Stochastic transient (median min $\|x_t\|$ over $t\in[0,100]$)

| $\sigma$ | median min $\|x_t\|$ |
|---|---|
| 0.01 | 0.142 (close to deterministic 0.148) |
| 0.10 | 0.088 (smaller — noise can push closer to 0) |
| 0.50 | 0.357 (larger — noise prevents closeness) |
| 1.00 | 0.621 (much larger) |

### Recovery probability $P(\|x_T\| > 0.5\lambda)$ at $T=10000$

| $\sigma$ | fraction recovered |
|---|---|
| 0.01 | 90.5 % (181/200) |
| 0.10 | 86.5 % (173/200) |
| 0.50 | 99.5 % (199/200) |
| 1.00 | 99.0 % (198/200) |

User's threshold: "如果比例低于 80%，transient vulnerability is real problem."

### Verdict

**PASS.** All four noise levels exceed 80 % above $0.5\lambda$. Even at $\sigma=0.1$ where the median min transient drops to 0.088 (close to zero), the orbit recovers in 86.5 % of samples. No path decays to $\|x_T\|<0.01$.

The transient at $t=4$ is real (orbit briefly visits 21% of $\lambda$) but is **not a vulnerability** — the contraction rate $\beta^{3/2}\approx 0.72$ pulls the orbit back to the cycle within $\sim 1/(1-\beta^{3/2})\approx 4$ cycle-periods, and stochastic noise does not break this recovery.

> Caveat: $\sigma$ values above 1.0 have *not* been tested. The $\sigma\to\infty$ limit makes the cycle attractor irrelevant; for OP-2's purposes ($\sigma\le D$) the tested range covers the relevant regime.

---

## Final judgment

**CONFIRMED, with two scope caveats noted.**

The Gap 1 Route A proof of zero-momentum cycling on a positive-measure subset of $\mathcal F_{K=3}$ holds:

1. **Deterministic verification.** The proof skeleton (L1, L2, L3, L4, L8) is rigorous; the cycling core (L5, L6, L7) is supported by 50-digit mpmath simulations that pass tightened thresholds down to $10^{-40}$. (Audit 2 PASS.)
2. **Stochastic robustness.** Empirically holds for $\sigma\in\{0.01,0.1,0.5,1.0\}$ with $\mathbb E[\|\nabla f\|^2]$ bounded away from 0 in all four regimes. (Audit 3 PASS.)
3. **Transient resilience.** The $t=4$ approach to zero ($0.21\lambda$) does not destabilize the orbit under stochastic perturbation. 86.5 %–99.5 % of paths recover above $0.5\lambda$. (Audit 4 PASS.)

### Scope caveats (not failures, but limits of what was actually proved)

1. **Numerical core, rigorous wrapper.** The "positive-measure $\mathcal F^{\text{cycle}}_{K=3}$" claim relies on (a) Floquet local attractiveness (rigorous) + (b) "zero-momentum init enters basin" (numerical at anchor) + (c) continuity (rigorous existence, no quantitative size). The 30 % figure is a numerical grid count, not a measure-theoretic bound.

2. **Stochastic robustness is empirical only.** The proof's L8 transfers the *variance* term unchanged; it does **not** prove that the cycling bias term survives noise. Audit 3 verifies this empirically; a rigorous stochastic version would require additional work (Foster–Lyapunov / drift conditions). The empirical evidence is strongly suggestive but not a theorem.

### What this means for OP-2

If OP-2 needs:
- a deterministic $\mathbb E[f(x_T)-f^*]\ge \kappa LD^2/(23T)$ on a non-empty open subset → **CONFIRMED**.
- a stochastic gradient-norm lower bound $\mathbb E[\|\nabla f(x_T)\|^2]\ge C>0$ on the same subset → **CONFIRMED EMPIRICALLY** (no proof, but no counter-evidence either; bound holds with margin in all tested regimes).
- a *uniform* positive-measure size estimate (i.e., "the cycling subset has Lebesgue measure $\ge $ explicit constant") → **NOT PROVEN**. The proof produces existence only.

### Recommendation

Proceed with Gap 2 in the form actually established by Gap 1: a positive-measure (size unspecified) cycling region under deterministic SHB, with stochastic robustness asserted empirically. If a downstream step requires a quantitative measure bound or a rigorous stochastic version, that is additional work and should be flagged as such — *not* assumed in place.

---

## Files produced by this audit

- `audit/gap1_audit.py` — audit script
- `audit/gap1_audit_output.txt` — full numerical output (audits 2, 3, 4)
- `audit/gap1_audit_results.json` — structured results
- `audit/audit1_analysis.md` — Audit 1 detailed table
- `gap1_audit_report.md` — this report
