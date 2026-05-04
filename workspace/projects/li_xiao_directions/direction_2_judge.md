# Direction 2 — Judge Evaluation

**Date:** 2026-04-28
**Judge phase:** Phase 3 of 5
**Question:** Does fixed-momentum SHB (fixed $\beta$, fixed $\eta$) on $L$-smooth convex non-SC admit a last-iterate UB $\mathbb{E}[f(x_T)-f^\star] \leq C(\beta)\frac{LD^2}{T} + C'(\beta)\frac{\sigma D}{\sqrt T}$? If not, what is the correct rate and tightness picture?

**Explorers available:** 1 (Route A, orthodox Lyapunov), 2 (Route F, adversarial refutation), 3 (Route C, Sebbouh), 4 (Route D, online-to-batch), 6 (Route B, compositional). Explorer 5 (Route E, PEP/SDP) did not produce a file.

---

## Per-Explorer Scores

| Explorer | Route | Completeness /10 | Correctness /10 | Elegance /10 | Gaps /10 | Total /40 |
|---|---|---|---|---|---|---|
| **Explorer 1** | A — 3-term Lyapunov | 9 | 9 | 8 | 8 | **34** |
| **Explorer 2** | F — Adversarial refutation | 10 | 10 | 9 | 9 | **38** |
| **Explorer 3** | C — Sebbouh (naive) | 8 | 9 | 7 | 8 | **32** |
| **Explorer 4** | D — Online-to-batch (reduction) | 9 | 9 | 8 | 7 | **33** |
| **Explorer 6** | B — Compositional bias+variance | 8 | 8 | 7 | 7 | **30** |

### Score rationale

**Explorer 2 (38/40):** The adversarial route is the cleanest and most decisive contribution of the five. It derives the closed-form stationary variance
$$\mathrm{Var}_\infty[x] = \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)(2(1+\beta)-\eta L)}$$
via the discrete Lyapunov equation (SymPy + five Monte-Carlo verifications at relative error $< 0.25\%$), identifies the leading-order floor $\sigma^2\eta/(2L(1-\beta))$, corrects the scout's earlier conjecture $\sigma^2\eta/(L(1-\beta^2))$, and proves a clean contradiction theorem against $O(\sigma D/\sqrt T)$ at fixed $(\beta,\eta)$. The resolution section correctly identifies minimax-over-$\eta$ as the regime where OP-2's LB and the noise floor coincide. The one minor gap (Gaps score 9): the closed-form finite-$T$ bias term is quoted as $\rho^{2T}\|z_0\|^2$ without explicit derivation of the spectral radius bound; the Auditor should verify this is consistent with the stated stability region.

**Explorer 1 (34/40):** The orthodox Lyapunov is technically the most thorough of the five. It derives the unique cross-term-killing choice $c_1 = (1-L\eta-\beta^2)/(2\eta)$, $c_2 = \beta^2/(2\eta)$, verifies positivity conditions, telescopes the recursion cleanly to obtain the Cesàro UB with noise prefactor $\eta\sigma^2/2$, then honestly distinguishes fixed-$\eta$ (noise floor) from horizon-tuned $\eta_t \sim 1/\sqrt T$ (Cesàro rate $\sigma D/\sqrt T$). The numerical cross-check (Table in Step 11) corroborates the heuristic $\sigma^2\eta/(2(1-\beta^2))$ floor independently. Gaps (score 8): the Young's inequality step (Step 6, $\delta = \eta c_1$) introduces a residual $\|m_t\|^2$ term whose net sign is claimed non-positive but not carefully verified; the Auditor should check the net $\|m_t\|^2$ coefficient explicitly. Also, the co-coercivity discussion (Step 8) is slightly confused before correcting itself.

**Explorer 4 (33/40):** The online-to-batch route delivers a genuine positive result for projected SHB: $O((LD^2/T + \sigma D/\sqrt T)\log T / (1-\beta)^{1/2})$, conditional on iterate boundedness. The Lemma 1 change-of-variables to $z_t = x_t + \tfrac{\beta}{1-\beta}(x_t - x_{t-1})$ is verified by the math-verifier (4/4 PASS) and gives a clean effective OGD interpretation. The cross-term absorption via Lemma 2 is correct and yields a $1/(1-\beta)^{3/2}$ blowup that is honestly reported. The $\log T$ gap is correctly traced to the Orabona bridge's harmonic-series penalty at suffixes. Gaps (score 7): the Lemma 2 proof sketched has a gap at the boundary $\beta \leq 1/\sqrt 2$ (the $(1 - 2\beta^2)$ denominator changes sign above $\beta = 1/\sqrt 2$, requiring a separate Abel-summation argument for $\beta \in (1/\sqrt 2, 1)$); the Auditor should verify the $1-\beta^2$ denominator claim is valid throughout $[0,1)$. The iterate-diffusion bound $\mathbb{E}\|z_{T-k}-x^\star\|^2 \leq D^2 + k\sigma^2\eta_{\mathrm{eff}}/(1-\beta)$ is stated without proof and should be checked against the route F stationary variance.

**Explorer 3 (32/40):** The Sebbouh check is an honest and careful literature review that correctly identifies the multiple mismatches: varying vs fixed schedule, a.s. vs expectation, $\varepsilon$-loss in rate, and uniform-integrability failure. The conclusion that Sebbouh cannot deliver a fixed-$(\beta,\eta)$ last-iterate $\sigma D/\sqrt T$ rate is well-argued. The score is lower on Completeness than Explorer 2 because the route does not produce a new proof — it is primarily a literature cross-check. Gaps (score 8): the claim that the a.s.-to-$L^1$ conversion "fails without uniform integrability" is asserted correctly but without a counterexample; citing a specific example (e.g., the quadratic with fixed $\eta$ giving $\liminf_T \mathbb E[f(x_T)-f^\star] > 0$) would make this more self-contained.

**Explorer 6 (30/40):** The compositional approach gives a useful mechanistic explanation — the noise-driven correction $z_t$ is a random walk in eigendirections with zero curvature, with variance $\Theta(\eta^2\sigma^2 T/(1-\beta)^2)$ — and identifies the key failure point (Obstacle 1: random walk at $\mu=0$). The derivation of the $T^{-2/3}$ rate for the stop-and-go variant is correct and unexpected. However, the composition step (B3) relies on a linearization that is exact only for quadratic $f$; for non-quadratic $f$ the second-order remainder is controlled only by $O(\|z_t\|^2)$, which is circular when $\|z_t\|^2$ is the quantity being bounded. Gaps (score 7): the cross-term in B3 is bounded via Cauchy-Schwarz as $\sqrt{\mathbb{E}\|\nabla f(\xi_T)\|^2} \cdot \sqrt{\mathbb{E}\|z_T\|^2}$, but $\xi_T$ (the intermediate point) is random and dependent on $z_T$, so the independence assumption for Cauchy-Schwarz needs justification. This is a real gap the Auditor must address.

---

## Winner: Route F (Explorer 2)

**Rationale.** Explorer 2's adversarial route is the most valuable contribution for three reasons:

1. **Definitiveness.** It answers the posed question with a rigorous theorem: no constant $C'$ (independent of $T$) yields $\mathbb{E}[f(x_T)-f^\star] \leq C'\sigma D/\sqrt T$ for fixed $(\beta,\eta)$. The proof is a single clean argument — closed-form stationary variance, exponential convergence to stationarity, contradiction at $T \to \infty$ — requiring no elaborate Lyapunov machinery.

2. **Calibration.** It corrects the scout's variance formula from $\sigma^2\eta/(L(1-\beta^2))$ to the exact $\eta\sigma^2(1+\beta)/(L(1-\beta)(2(1+\beta)-\eta L))$, which matters quantitatively: the finite-$\eta$ correction $(1+\beta)/(2(1+\beta)-\eta L)$ grows toward the stability boundary, matching the divergence in the empirical table from Explorer 1.

3. **Minimax resolution.** It cleanly identifies the correct minimax framing: at horizon-tuned $\eta_T = \Theta(D/(\sigma\sqrt T))$, the noise floor $\sigma^2\eta_T \asymp \sigma D/\sqrt T$ matches the OP-2 LB exactly. This is the first place in the five explorations where the LB-UB duality is stated in a precise, not merely qualitative, form.

Explorer 1 is a close second and is essential as the companion upper bound; together Routes A and F form a complete pair that fully characterizes the fixed-$(\beta,\eta)$ regime.

---

## Unified picture from converging routes

All five routes converge to the same underlying fact, viewed from different angles:

**The noise floor at fixed $(\beta,\eta)$.**
For fixed-momentum SHB on $L$-smooth convex non-SC with bounded-variance oracle, and fixed parameters $(\beta,\eta) \in \mathcal S$:
$$\lim_{T\to\infty} \mathbb{E}[f(x_T)-f^\star] = \frac{\sigma^2\eta(1+\beta)}{4(1-\beta)(2(1+\beta)-\eta L)} = \frac{\sigma^2\eta}{4(1-\beta)} + O(\eta^2).$$
This constant is strictly positive for any $\sigma,\eta > 0$. No $T$-decaying UB of any form exists for a single fixed $f$ at fixed $\eta$.

**What each route adds to the picture:**
- Route F (Explorer 2) gives the closed-form constant and its quadratic-instance proof.
- Route A (Explorer 1) gives the correct companion UB: the Cesàro average of fixed-momentum SHB satisfies $O(LD^2/((1-\beta^2)T)) + O(\sigma^2\eta/(1-\beta^2))$ at fixed $\eta$, i.e., the bias decays to $1/T$ but the variance saturates at the noise floor. At the horizon-tuned step $\eta_t = \Theta(1/\sqrt T)$, the Cesàro rate becomes $O(LD^2/((1-\beta^2)T)) + O(\sigma D/\sqrt{1-\beta^2}\cdot 1/\sqrt T)$, matching OP-2 up to constants and a $\beta$-polynomial.
- Route B (Explorer 6) explains the mechanism via impulse-response: the $\mu=0$ eigendirection of $\nabla^2 f$ yields a characteristic root $r=1$ in the SHB transfer function, giving a random-walk variance accumulation $\Theta(\eta^2\sigma^2 T)$ that can never be offset by fixed stepsize.
- Route C (Explorer 3) confirms the picture via literature: the only existing last-iterate results for SHB (Sebbouh et al.) require time-varying $(\eta_t,\beta_t)$ and give a.s. rates, not $L^1$ rates; they do not extend to fixed $(\beta,\eta)$.
- Route D (Explorer 4) gives a conditional positive: projected SHB with horizon-tuned $\eta = \Theta((1-\beta)/(\sigma\sqrt T/D))$ and the Orabona bridge yields $O((LD^2/T + \sigma D/\sqrt T)\log T / (1-\beta)^{1/2})$ for the last iterate — the closest thing to a matching UB, but with a $\log T$ gap and a bounded-domain assumption.

**The minimax resolution.**
The OP-2 lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$ is a $\forall T, \exists f$ minimax LB: for each horizon $T$, a different wall-function is chosen with radius $R(T) = D/\sqrt 2 - \sigma/(3L\sqrt T)$. This $T$-dependent hardness is not contradicted by the noise floor, which applies to any single fixed $f$.

In the minimax sense $\inf_{\eta}\sup_{f \in \mathcal F}\mathbb{E}[f(x_T)-f^\star]$, the infimum is achieved at $\eta_T = \Theta(D/(\sigma\sqrt T))$ (the route F analysis), and at that $\eta_T$ the noise floor exactly equals $\sigma D/\sqrt T$, matching OP-2's LB. The LB-UB pair is therefore tight in the minimax-over-$\eta$ sense, but there is no single fixed $(\beta,\eta)$ and single fixed $f$ for which $f(x_T)-f^\star = \Theta(\sigma D/\sqrt T)$ uniformly in $T$.

---

## Minor issues to fix

1. **Explorer 1, Step 6 — Young's inequality residual.** The net $\|m_t\|^2$ coefficient after all contributions (descent lemma, velocity recursion, and Young's) is claimed non-positive for $\eta \leq (1-\beta^2)/L$; verify this algebraically — the current text asserts it but does not compute the coefficient explicitly. The $\beta$-range also silently shifts between $(1-\beta^2)/L$ (stability) and $(1-\beta)/L$ (strict sub-region); the two should be reconciled with a clear statement of which constraint is needed for each step.

2. **Explorer 2 — Spectral radius for finite-$T$ bias.** The claim $|\mathbb{E}[x_T^2]-\mathrm{Var}_\infty| \leq C\rho^{2T}\|z_0\|^2$ uses $\rho = \max(|r_1|,|r_2|)$. In the underdamped regime $|r_1|=|r_2|=\sqrt\beta$, so $\rho = \sqrt\beta$ and $\rho^{2T}=\beta^T$, which is correct and fast. In the overdamped regime, $\rho = r_{1,\mathrm{slow}} < 1$; verify the transition formula at the boundary $\eta L = (1-\beta)^2/(1+\beta)$ (the boundary between under/overdamped). Also verify the constant $C$ dependence on $\|z_0\|^2$ does not introduce an uncontrolled $D$-dependence.

3. **Explorer 4, Lemma 2 — $\beta > 1/\sqrt 2$ boundary.** The stated bound $\sum u_t \leq 2\eta^2/(1-\beta^2)\sum v_t$ uses the denominator $1-2\beta^2$, which vanishes at $\beta=1/\sqrt 2$ and is negative above it. The text acknowledges this and mentions "a sharper Abel summation," but this sharper argument is not given. Either provide the Abel-summation argument for $\beta \in (1/\sqrt 2, 1)$ or state the lemma only for $\beta \in [0, 1/\sqrt 2)$ with a remark that the $\beta$-constant changes.

4. **Explorer 4 — Iterate-diffusion bound for bridge suffixes.** The bound $\mathbb{E}\|z_{T-k}-x^\star\|^2 \leq D^2 + k\sigma^2\eta_{\mathrm{eff}}/(1-\beta)$ is stated without proof and is crucial for the log-factor analysis. This should be derived from the Cesàro bound applied to the sub-trajectory starting at $T-k$, or from the stationary-variance bound of Explorer 2.

5. **Explorer 6, Lemma B3 — Cross-term independence.** The Cauchy-Schwarz step $\mathbb{E}[\langle\nabla f(\xi_T), z_T\rangle] \leq \sqrt{\mathbb{E}\|\nabla f(\xi_T)\|^2}\cdot\sqrt{\mathbb{E}\|z_T\|^2}$ treats $\nabla f(\xi_T)$ and $z_T$ as independent; they are not (both depend on the noise history). The correct bound uses $\mathbb{E}[|\langle u,v\rangle|] \leq \sqrt{\mathbb{E}\|u\|^2\cdot\mathbb{E}\|v\|^2}$ only when $u,v$ are uncorrelated, which fails here. Either use the Cauchy-Schwarz on the joint quantity $|\langle\nabla f(\xi_T),z_T\rangle|$ directly, or bound via $L$-smoothness and the triangle inequality: $\|x_T - x^\star\|^2 \leq 2\|y_T-x^\star\|^2 + 2\|z_T\|^2$.

6. **Both Explorers 1 and 4 — $\beta$-constant exponents.** Explorer 1 claims the Cesàro variance constant is $O(1/\sqrt{1-\beta})$ (improving on the $O(1/(1-\beta))$ of the fixed-$\eta$ case). Explorer 4 gives $O(1/(1-\beta)^{1/2})$ for the variance. These agree. But both should be compared against Explorer 2's exact formula for the noise floor, which has $(1-\beta)$ in the denominator (not $(1-\beta)^{1/2}$) for the Cesàro case and $(1-\beta)$ for the last-iterate fixed-$\eta$ case. The Auditor should trace through the exponent from each route and confirm they do not contradict each other in the overlapping regime (Cesàro, horizon-tuned $\eta$).

7. **Missing Route E (PEP/SDP).** Explorer 5's file does not exist. The PEP was identified in the scout as the key numerical diagnostic distinguishing the noise-floor and $\sigma D/\sqrt T$ scenarios. Its absence means the numerical confirmation of the exact noise-floor constant and its $T$-dependence crossover is missing. The Auditor should flag this and either run a minimal PEP check (Route E's core prediction — that $\gamma^\star(T)$ saturates at $\sigma^2\eta/(2(1-\beta^2))$ as $T\to\infty$ — is implied by Explorers 1 and 2, but independent numerical confirmation is desirable) or note the gap explicitly in the final report.

---

## Recommended OP-2 phrasing for tightness claim

**Honest and precise phrasing:**

> "Tight in the minimax-over-stepsize sense: for each horizon $T$, the oracle complexity lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$ for the last iterate is matched by fixed-momentum SHB with horizon-tuned stepsize $\eta_T = \Theta(D/(\sigma\sqrt T))$ (Cesàro average), or by projected SHB (last iterate, up to $\log T$). For unprojected SHB with any single fixed stepsize $\eta > 0$, the last iterate does not converge to $f^\star$; the best achievable rate is the noise floor $\sigma^2\eta/(2(1-\beta^2)) + O(LD^2/T)$."

**Short form options ranked by accuracy:**
1. **Preferred:** "Tight up to $\log T$ for projected SHB with horizon-tuned stepsize, tight exactly in the minimax-over-$\eta$ sense." This is the most accurate and distinguishes the two positive results.
2. **Acceptable for non-projected SHB Cesàro:** "Tight up to $\beta$-polynomial factors in the Cesàro average, at horizon-tuned $\eta_T \sim 1/\sqrt T$." The $\beta$-factors are $O(1/\sqrt{1-\beta})$ for variance, $O(1/(1-\beta))$ for bias — polynomial in $1/(1-\beta)$.
3. **Should avoid:** "Tight" without qualification, or "tight up to constants." The $\log T$ gap and the last-iterate vs Cesàro distinction are not cosmetic.

---

## Recommended next phase

**Phase 4 (Auditor) should:**

1. **Verify Explorer 2's algebraic derivation** of the closed-form stationary variance (equation (5)) by re-solving the $3\times3$ discrete Lyapunov system independently, confirming the leading-order expansion (equation (6)), and cross-checking the $\beta=0$ reduction against the classical SGD-on-quadratic stationary variance $\eta\sigma^2/(L(2-\eta L))$.

2. **Check Explorer 1's Lyapunov coefficient derivation** at Steps 5-6: verify the net $\|m_t\|^2$ coefficient is non-positive throughout the stated range $\eta \leq (1-\beta^2)/L$, and confirm the noise prefactor $\mathcal N = \eta/2$ is correctly computed.

3. **Resolve the Explorer 4 Lemma 2 gap** for $\beta > 1/\sqrt 2$, and verify the $\log T$ bridge result is correctly stated with all assumptions made explicit (boundedness, step choice).

4. **Identify the correct $\beta$-polynomial** for the Cesàro and last-iterate rates (Explorers 1 and 4 claim $O(1/\sqrt{1-\beta})$ for variance; Explorer 2's exact formula gives $O(1/(1-\beta))$ for the last-iterate floor; these should be reconciled by noting they refer to different regimes).

5. **Substitute for missing Route E:** Run a brief numerical sanity check — simulate SHB on $f(x) = Lx^2/2$ at $(\beta,\eta) = (0.5, 0.1/L)$, $T = 10, 100, 1000, 10000$ steps, confirm $\mathbb{E}[f(x_T)-f^\star]$ converges to the predicted floor $\sigma^2\eta(1+\beta)/(4(1-\beta)(2(1+\beta)-\eta L))$.

6. **Draft a one-paragraph "Missing UB" remark** for the OP-2 paper: clarify that OP-2's LB is a $\forall T, \exists f$ statement, that no matching $\exists f, \forall T$ UB exists (noise-floor obstruction), but that the minimax pair is tight at horizon-tuned $\eta_T$.

**Priority:** Minor issues 1, 2, 3, 5 (Auditor); issue 4 is cosmetic for the current paper. Issue 7 (missing Route E) is medium priority — the numerical confirmation is not needed for the negative result to be valid, but it would strengthen the paper.

**Go/No-go:** The negative result (no $\sigma D/\sqrt T$ UB at fixed $\eta$) is firmly established by Explorers 1 and 2 independently and corroborated by 3, 4, 6. The positive result (projected SHB, $\log T$ gap) is established by Explorer 4 with the Lemma 2 caveat. **Recommend proceeding to Auditor** with the five minor issues listed above as the audit checklist.
