# Proof Report: Softmax Policy Gradient $O(1/t)$ Convergence for Finite MDPs

## 1. Problem Statement

**Paper**: J. Mei, C. Xiao, C. Szepesvári, D. Schuurmans, *"On the Global Convergence Rates of Softmax Policy Gradient Methods"*, ICML 2020.

**Setting**. Finite MDP $(\mathcal{S}, \mathcal{A}, P, r, \gamma, \rho)$, $r \in [0,1]$, $\gamma \in [0,1)$, softmax tabular parametrization $\pi_\theta(a|s) = \exp(\theta_{s,a}) / \sum_{a'}\exp(\theta_{s,a'})$, full-support initial distribution ($\rho_{\min} := \min_s \rho(s) > 0$). Vanilla PG:
$$\theta_{t+1} = \theta_t + \eta \nabla_\theta V^{\pi_{\theta_t}}(\rho),\qquad \eta = (1-\gamma)^3/8.$$

**Target (problem.md)**: $V^*(\rho) - V^{\pi_t}(\rho) \le \frac{16|\mathcal{S}|}{c_\infty^2 (1-\gamma)^6 t}$ where $c_\infty := \inf_t \min_s \pi_t(a^*(s)|s) > 0$.

**What is actually proved (honest restatement, faithful to problem.md's definitions)**:
$$\boxed{\;V^*(\rho) - V^{\pi_t}(\rho) \;\le\; \frac{16|\mathcal{S}|}{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5\,t}\;}$$
with $c_\infty$ as defined above (pure policy-level). A Remark in the proof explains that problem.md's target form appears in Mei et al. 2020 under a *different* $c_\infty$ convention absorbing distribution-mismatch; the two bounds are not algebraically equivalent under the problem's literal definition.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed |
| Explorer | Opus | 4 parallel proofs attempted, 3 ELIGIBLE_WITH_GAP, 1 FAIL (Route 3 KL) |
| Judge | Sonnet | Route 1 (NU-Łojasiewicz + Descent) selected, 26/40 |
| Audit R1 | Opus | FAIL — 2 HIGH (Step 9 $\rho_{\min}$ hand-wave, Step 6 $c_\infty>0$ sketch) + MED/LOW |
| Fix R1 | Opus | 6 issues addressed; Step 9 via $c_\infty'$ redefinition |
| Audit R2 | Opus | FAIL — Step 9 $c_\infty'$ algebra off by $(1-\gamma)^2$, plus Step 6 MED |
| Fix R2 | Opus | Option A (honest restatement): box the $(1-\gamma)^5\rho_{\min}^2$ bound, drop $c_\infty'$ games; Step 6 split into self-contained 6A + cited 6B |
| Audit R3 | Opus | **PASS** — 8 VALID, 0 INVALID, SymPy-exact, 400/400 numerical checks |

## 3. Proof Routes Explored

- **Route 1 (winner): NU-Łojasiewicz + Descent Lemma.** Canonical Mei et al. strategy. Steps: (1) setup, (2) PG theorem, (3) Performance Difference Lemma, (4) $\beta$-smoothness with $\beta = 8/(1-\gamma)^3$, (5) non-uniform Łojasiewicz $\|\nabla V\|_2 \ge \frac{c_\infty \rho_{\min}(1-\gamma)}{\sqrt{|\mathcal{S}|}} \delta$, (6) $c_\infty > 0$ (6A self-contained monotonicity + 6B cited hitting-time), (7) descent recursion, (8) $O(1/t)$ via $a_{t+1} \le a_t(1-Ca_t)$, (9) boxed bound.
- **Route 2: PDL + Mean Value.** Claimed to avoid NU-Ł; judge found it reduced to the same inequality. 20/40.
- **Route 3: KL Potential.** Self-declared failure at Step 6 — cannot close the Lyapunov loop for vanilla PG (Pinsker direction wrong, PG/NPG preconditioning gap). INELIGIBLE; kept as a failure analysis.
- **Route 4: Mirror Descent + NPG Comparison.** Hybrid: Fisher-spectral lower bound does not transfer NPG rate to PG, so the route re-derives NU-Ł. 23/40.

## 4. Final Proof

See `best_proof.md` for the full 9-step proof. Key chain:

- **β-smoothness (Step 4):** $V^\pi$ as a function of $\theta$ has bounded Hessian operator norm $\le 8/(1-\gamma)^3$, established via triple decomposition $T_a + T_b + T_c$ with tight $(6 + 2\gamma)/(1-\gamma)^3 \le 8/(1-\gamma)^3$ bookkeeping.
- **Non-uniform Łojasiewicz (Step 5):** Via PG theorem + PDL + sign-robust Cauchy–Schwarz on squares:
  $\|\nabla_\theta V^\pi(\rho)\|_2 \ge \frac{c_\infty \rho_{\min}(1-\gamma)}{\sqrt{|\mathcal{S}|}} \cdot (V^*(\rho) - V^\pi(\rho)).$
- **Descent Lemma → recursion (Step 7):** With $\eta = 1/\beta = (1-\gamma)^3/8$, $\delta_{t+1} \le \delta_t(1 - C\delta_t)$ where $C = c_\infty^2 \rho_{\min}^2 (1-\gamma)^5 / (16|\mathcal{S}|)$.
- **Sublinear rate (Step 8):** Standard $a_{t+1} \le a_t(1-Ca_t)$ recursion (with burn-in case analysis for $\delta_0 > 1/C$) yields $\delta_t \le 1/(Ct)$, which is exactly the boxed bound.

## 5. Audit Result

**PASS** (round 3 of 3). 8 steps VALID, 0 INVALID. Step-9 algebra SymPy-verified: $C = c_\infty^2 \rho_{\min}^2 (1-\gamma)^5 / (16|\mathcal{S}|)$ and $1/(Ct) =$ boxed RHS identically. Numerical sanity: 400/400 passes across 4 MDPs × 100 PG steps × $\gamma \in \{0.5, 0.7, 0.9\}$; observed $\delta_t$ dominated by theoretical bound with $\sim 33\times$ margin on average. Cross-verification vs NPG baseline: consistent — NPG has $O(1/K)$ with $(1-\gamma)^{-2}$ and no $c_\infty$, softmax PG has $O(1/t)$ with $(1-\gamma)^{-5}\rho_{\min}^{-2}c_\infty^{-2}$; the $c_\infty^{-2}$ factor is the expected "price" of vanilla PG vs. natural PG.

**Remaining LOW (cosmetic)**: Lemma 6A one-line proof elides a sign case on $A^{\pi_t}(s,a')$; Remark 9.2's characterization of Mei et al.'s $c_\infty$ convention is not independently reverified against the paper. Neither affects validity.

## 6. Fix History

| Round | Issues addressed | Critical fix |
|-------|-----------------|--------------|
| 1 | 6 (2 HIGH + 2 MED + 2 LOW) | Step 9 via $c_\infty'$ redefinition (turned out to have algebra bug) |
| 2 | 2 (1 HIGH + 1 MED) | Step 9 redone as **honest restatement** (Option A); boxed bound now $(1-\gamma)^5\rho_{\min}^2$ form matching derivation literally. Step 6 split 6A+6B. |

## 7. Interpretive Note

The proof honestly establishes a $O(1/t)$ convergence rate for softmax vanilla PG with an explicit, traceable constant. The boxed bound differs from problem.md's stated target form by the factor $(1-\gamma)/\rho_{\min}^2$, which has indeterminate sign in general — this is not a bug in either, but rather a convention difference: Mei et al.'s $c_\infty$ absorbs distribution-mismatch, while problem.md defines $c_\infty$ as pure policy-level. Under the literal problem.md definition, the boxed form is the strongest rigorous bound the canonical proof chain (β-smoothness + NU-Łojasiewicz + descent) produces.
