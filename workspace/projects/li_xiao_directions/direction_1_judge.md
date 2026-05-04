# Direction 1 — Judge Evaluation

**Phase:** 3 of 5 (Judge)
**Date:** 2026-04-28
**Theorem under evaluation:** Existence of a positive-measure subset $\mathcal F^{\mathrm{zero}}_{K=3} \subset \mathcal F_{K=3}$ on which fixed-momentum SHB with zero-momentum init $(x_0 = x_{-1})$ satisfies $\mathbb{E}[f(x_T) - f^\star] \geq c\kappa LD^2/T + c'\sigma D/\sqrt{T}$ for all $T \geq 1$.

---

## Per-Explorer Scores

| Explorer | Frame | Completeness (/10) | Correctness (/10) | Elegance (/10) | Gaps (/10) | Total (/40) |
|---|---|---:|---:|---:|---:|---:|
| E1 (Orthodox) | Route D, transient+basin | 7 | 8 | 7 | 9 | **31** |
| E2 (Adversarial) | Disproof attempts + dichotomy | 6 | 8 | 7 | 9 | **30** |
| E3 (Naive) | Anchor certificate + Lipschitz | 6 | 7 | 6 | 10 | **29** |
| E4 (Reduction) | Period-2 fixed-point reduction | 7 | 7 | 8 | 8 | **30** |
| E5 (Construction) | Structural no-go + Theorem 5.1 | 5 | 9 | 8 | 9 | **31** |
| E6 (Compositional) | L1–L6 DAG proof | 9 | 8 | 9 | 8 | **34** |

---

## Score Rationale

**Explorer 1 (Orthodox, 31/40).** Completeness 7: correctly identifies the exact failure of the "literal" $\delta \to 0$ perturbation argument and pivots to a transient+basin strategy that delivers the theorem statement on the empirical cycling region. The LB transfer (bias term via strong-convexity floor; variance term verbatim from OP-2) is complete. Loses a point because the basin argument (Lemmas 1–2) is clearly stated as a sketch requiring numerical certification rather than an analytic proof, and the transient correction $\varepsilon(T) = O(\rho^{T-T_0})$ is not quantified. Correctness 8: the one-step formula, Lipschitz blowup explanation, and Floquet contraction argument are all right; the claim $|r_\mu|^3 = \beta^{3/2} < 1$ is correct and gives local attractiveness. The "Orthodox SAVE" is logically valid. Elegance 7: the reorganization from "failed literal route D" to "save via transient" is clean in structure, though the argument requires case-splitting and numerical anchors. Gaps 9: unusually explicit about every failure, including the $6^T$ blowup on the naive Lipschitz bound and the non-uniform basin at the edges of $\mathcal F_{K=3}$; highly trustworthy.

**Explorer 2 (Adversarial, 30/40).** Completeness 6: the document does not directly prove the theorem but provides strong negative evidence that no strategy disproves it. The "dichotomy proof" (cycling union period-2) is outlined but not executed. This is a clean supporting document, not a standalone proof. Correctness 8: the three failed disproof attempts are each correctly argued; in particular, the forward-invariance of $\mathrm{int}(\mathrm{conv}(\widetilde P))$ under stable-regime SHB is a crucial and correct insight. The careful calculation of $\|x_1^{\mathrm{zero}}\|^2 = \lambda^2(\beta^2+\beta+1)$ matches E6/L1 exactly. Elegance 7: well-organized adversarial structure. Gaps 9: Strategy 3's "leakage" concern (velocity term could kick iterate into polytope) is honestly flagged as the one residual soft spot.

**Explorer 3 (Naive, 29/40).** Completeness 6: the open-ball certificate exists and is mathematically sound, but the open-ball radius $r \approx 10^{-46}$ is acknowledged as meaningless in practice. The important reinterpretation — that the anchor orbit converges to a **stationary fixed point** (period-1 attractor at norm $\lambda$), not to the K=3 rotating cycle — is a key correction to the numerical experiments document. Correctness 7: the Lipschitz bound computation is correct; the fixed-point attractor finding at the anchor is presented with high-precision support; the open-ball argument is formally valid. A minor issue: the "transient minimum 0.209λ" claim conflicts with "0.148λ" in two different lines (Section 1 vs. Section 2), suggesting an internal inconsistency that the Auditor should resolve. Elegance 6: the naive frame is honest about its own limitations, but the argument is fragmented between the two regimes with no clean synthesis. Gaps 10: the most transparently honest explorer; every failure mode is explicitly documented.

**Explorer 4 (Reduction, 30/40).** Completeness 7: the reduction to period-2 fixed points of $\Phi^2$ is fully executed, with the clean period-2 system (P2$''$) derived in closed form. The affine characterization ($\star$) — that $P_{\widetilde C}$ acts on the period-2 pair as a linear map — is novel and clean. The lower-bound transfer (strong-convexity floor on the period-2 attractor gives $0.37\mu D^2 > $ OP-2 floor of $0.25\mu D^2$) is complete. Basin condition and period-2 vs. period-6 ambiguity are left open. Correctness 7: the fixed-point algebra is careful; the attractiveness argument ($\rho(D\Phi^2) = \beta$ in the under-damped regime) is plausible but the claim that the Jacobian decouples into two uncoupled scalar SHB problems needs careful verification — the edge-locking condition (both $x_0^*,x_1^*$ projecting to the same edge) is non-trivial and should be explicitly confirmed. The symmetry-based dismissal of the "antisymmetric ansatz" (Step 2) is correct. Elegance 8: the midpoint-chord decomposition and the $(\star)$ formula are the cleanest algebraic results in any Explorer; the reduction to piecewise-affine map theory is conceptually sharp. Gaps 8: basin condition and edge-coincidence assumption clearly flagged; the period-2 vs. period-6 ambiguity is a real open point.

**Explorer 5 (Construction, 31/40).** Completeness 5: as intended, this Explorer delivers a *negative* result (Theorem 5.1 — zero-momentum incompatibility for all Goujaud-type functions) rather than a proof of the theorem. Its completeness score is accordingly lower, but this is by design. The theorem is fully proved (1-line computation from the GPT cycling identity, valid for all $K \geq 3$, all shifts and phase rotations). The reduction lemma (Routes B and E ultimately reduce to D or C) is a genuine theoretical contribution. Correctness 9: Theorem 5.1's proof is rigorous and immediate; the construction attempts (A–G) are systematically executed with explicit failure diagnoses; no incorrect claims. Elegance 8: the universality of the obstruction is stated cleanly; the geometric interpretation ("momentum cancels the gradient overshoot") is illuminating and likely publishable as a remark. Gaps 9: all failures are explicit; the recommendation to use Theorem 5.1 as a "contributing structural lemma" rather than the main proof is appropriately modest.

**Explorer 6 (Compositional, 34/40).** Completeness 9: the most complete attempted proof. L1 (first-step formula) is fully proved with 1-line algebra. L2 (polytope-exit condition) is derived in closed form as an explicit algebraic inequality (L2.1) and verified at the anchor. L3 (Vieta amplitude formula) correctly produces $|A_\mu^{\mathrm{zero}}|^2 = \lambda^2\eta\mu/(4\beta\sin^2\theta_\mu)$ and catches the Scout's Vieta error ($|1-r_1|^2 = \eta\mu$, not $(\eta\mu)^2$). L4 (Floquet multipliers) gives $|\lambda_{\mathrm{Floq}}| = \beta^{3/2} < 1$ via a rotation-factorization argument. L5 (composition) correctly identifies the logic chain: L2 activates nonlinearity, L4 gives attractiveness, Floquet stable-manifold theorem closes the argument. L6 numerically witnesses non-emptiness. The only gap is L5's basin radius: the distance from $(x_0, x_1^{\mathrm{zero}})$ to the cycle state $(\lambda e_0, \lambda e_1)$ is $\beta\lambda\sqrt{3}$, and whether this lies within the Floquet basin (radius $\sim \beta^{3/2}/(1-\beta^{3/2})$ in the linearized norm) needs explicit verification at each $\beta$ value. Correctness 8: near-rigorous throughout; the rotation-factorization (L4) needs a $4\times4$ explicit calculation to be fully rigorous. Elegance 9: the DAG structure makes the proof maximally auditable; each lemma is independently checkable; the final Theorem follows directly from the DAG. Gaps 8: the L4 rotation-factorization and L5 basin-radius are honestly flagged as needing verifier confirmation.

---

## Winner: Explorer 6 (Compositional Frame)

Explorer 6 achieves the highest total (34/40) and is the clear winner. It is the only Explorer to provide a *complete attempted proof* of the theorem as stated — all other routes either partially succeed (E1, E2) or deliver structural fragments (E4, E5) or honest failure analyses (E3). The DAG organization (L1–L6) is the single biggest advantage: each lemma is independently auditable, and the chain L1 → L2 → L5, L4 → L5, L5+L6 → Theorem is logically tight. The key results — the closed-form norm formula $\|x_1^{\mathrm{zero}}\| = \lambda\sqrt{1+\beta+\beta^2}$, the polytope-exit condition (L2.1) as an explicit algebraic inequality, the Floquet-multiplier modulus $\beta^{3/2}$, and the Vieta correction ($|1-r_1|^2 = \eta\mu$) — are each individually confirmable by a math-verifier call. The variance term ($c'\sigma D/\sqrt{T}$) inherits from OP-2 unchanged (independent of x-init, as E1 correctly argues for the Le Cam two-point bound); E6 gestures at this but could be more explicit.

The remaining gap (L5 basin radius vs. initial displacement $\beta\lambda\sqrt{3}$) is non-trivial at small $\beta$ but is consistent with the numerics (cycling fails for $\beta \leq 0.6$, exactly where the displacement exceeds the estimated basin radius).

---

## Minor Issues for the Auditor to Check

1. **L4 rotation-factorization (E6).** The claim that $J_{\mathrm{cyc}}$ has all Floquet multipliers of modulus $\beta^{3/2}$ uses the K=3 rotational symmetry to decouple the $4\times4$ Floquet matrix into scalar SHB factors. This needs to be verified by an explicit $4\times4$ characteristic polynomial computation at $(\beta, \eta L, \kappa) = (0.8, 3.247, 0.387)$. In particular, confirm that the rotation by $R_{2\pi/3}$ between consecutive cycle steps does not introduce cross-terms that alter the eigenvalue moduli.

2. **L5 basin radius vs. displacement (E6).** At $\beta = 0.8$, the distance from $(x_0, x_1^{\mathrm{zero}})$ to the cycle state $(\lambda e_0, \lambda e_1)$ is $\beta\lambda\sqrt{3} \approx 0.8 \cdot 0.707D \cdot 1.732 \approx 0.98D$. The Floquet basin radius in the linearization regime is $\Theta(\beta^{3/2}/(1-\beta^{3/2})) \approx 0.716/0.284 \approx 2.52$ (dimensionless). The comparison needs units pinned down: the displacement of $0.98D$ may or may not lie inside the basin depending on the exact norm used in the Floquet estimate. The Auditor should resolve this by either: (a) computing the basin radius explicitly in the Euclidean norm, or (b) using Route G's interval-arithmetic witness to certify the specific $(\beta, \eta L) = (0.8, 3.247)$ point without relying on the basin estimate.

3. **E3 transient minimum inconsistency.** Explorer 3 states the transient minimum as $0.14783\lambda$ in Section 1 (table) and $0.209\lambda$ in Section 2. This is likely a distinction between the minimum of $\|x_t\|$ vs. $\|x_t\| - 0.5\lambda$, but the numbers are inconsistent enough to require clarification. The Auditor should re-run the anchor simulation and report the single-source minimum.

4. **Variance term transfer.** The theorem statement includes $c'\sigma D/\sqrt{T}$. Explorers 1 and 2 address this (Le Cam two-point bound from OP-2 transfers because it depends only on the $y$-coordinate wall function, independent of x-init). Explorer 6 does not address the variance term. The Auditor should verify that the OP-2 $y$-coordinate construction is compatible with zero-momentum init in the $x$-coordinates, and that the joint distribution argument remains valid.

5. **E4 edge-coincidence assumption.** The period-2 fixed-point characterization (Step 4 of E4) assumes both $x_0^*$ and $x_1^*$ project to the *same* edge of $\widetilde C$. The existence of such pairs (same-edge coincidence) is claimed for each edge of the K=3 triangle but not verified. The Auditor should check whether numerical solutions to the system at $(\beta, \eta L) = (0.9, 3.7, 0.1)$ do indeed have both projection feet on the same edge, or whether cross-edge solutions are required.

6. **Fixed-point vs. rotating cycle (E3 discovery).** Explorer 3 reports that at the anchor, zero-momentum SHB converges to a *stationary fixed point* at norm $\lambda$, not to the K=3 rotating 3-cycle. This is an important reinterpretation: it means the "cycling" classification in the numerical experiments is actually a norm-preserving fixed-point phenomenon. The Auditor must reconcile this with E6's claim that the K=3 cycle is the attractor (L4, L5), or confirm that the true attractor is a fixed point in the rotating frame (which is equivalent, since the Floquet analysis in the rotating frame has a fixed-point interpretation). Both are compatible with the strong-convexity floor argument, but the Auditor should be explicit.

---

## Best Assembly Strategy

The recommended final proof combines the strengths of Explorer 6 (main structure), Explorer 1 (bias term LB and variance term transfer), Explorer 5 (structural no-go lemma as a contextualizing contribution), and Explorer 4 (period-2 attractor as the complementary claim covering high $\beta$):

**Step 1 — Kinematic lemma (E6/L1 = E5/Thm 5.1 Proof Step 1).** State and prove the first-iterate formula $x_1^{\mathrm{zero}} = \lambda(-\beta e_0 + e_1 + \beta e_2)$ and its K=3 coordinate form $x_1^{\mathrm{zero}} = \lambda(-1/2-\beta, (1-\beta)\sqrt{3}/2)$, with norm $\|x_1^{\mathrm{zero}}\| = \lambda\sqrt{1+\beta+\beta^2}$. Absorb E5/Theorem 5.1 as a corollary: the residual $\beta\lambda(e_2 - e_0)$ is the exact obstruction to literal OP-2 cycling under zero-momentum.

**Step 2 — Polytope-exit condition (E6/L2).** State the closed-form exit inequality (L2.1) and verify it defines an open positive-measure subset $\mathcal{R}_2 \subset \mathcal{F}_{K=3}$. Cite the anchor verification at $(0.8, 3.247, 0.387)$.

**Step 3 — Floquet attractiveness (E6/L4 + E1/§3).** Prove all four Floquet multipliers of the K=3 cycle have modulus $\beta^{3/2} < 1$. Use E1's linearization sketch as motivation, then resolve by explicit $4\times4$ Jacobian computation (math-verifier call at the anchor). Confirm the locally attracting cycle on an open set $\mathcal{R}_4 \subset \mathcal{F}_{K=3}$.

**Step 4 — Composition and basin (E6/L5 + E1/SAVE).** On $\mathcal{R}_2 \cap \mathcal{R}_4$, argue by the Floquet stable-manifold theorem that the initial state $(x_0, x_1^{\mathrm{zero}})$ lies in the basin of the K=3 cycle, since $\|x_1^{\mathrm{zero}} - \lambda e_1\| = \beta\lambda\sqrt{3}$ and the basin radius (in Euclidean norm) is bounded below by an explicit $r(\beta) > 0$ for $\beta \in [0.7, 0.95)$. Use E1's transient correction argument to handle the transient: $\|x_t\| \geq \lambda(1 - O(\beta^{3t/2}))$, so the strong-convexity floor applies for all $T \geq 1$ with constant $c = \kappa(\beta,\eta)/8$ (degraded by 2 from the transient).

**Step 5 — Non-emptiness and positive measure (E6/L6).** Cite the $T=2000$, 50-digit numerical certificate at the anchor. Use continuity of the SHB map in parameters (Lemma 3.1 of E3 — joint Lipschitz dependence) to extend to an open ball of radius $r^* > 0$ around the anchor. Provide the explicit measure lower bound: the $\beta = 0.8$ strip $\eta L \in [3.09, 3.561]$ contributes area $\geq 0.047$ to the 2-D parameter region.

**Step 6 — Period-2 attractor complement (E4/§5–§6).** As a remark, include E4's period-2 fixed-point analysis for $\beta \in [0.85, 1)$: the affine characterization ($\star$), local attractiveness ($\rho(D\Phi^2) = \beta < 1$), and the stronger floor ($\geq 0.37\mu D^2$). This extends $\mathcal{F}^{\mathrm{zero}}_{K=3}$ to the "other attractor" region and gives a unified dichotomy (cycling OR period-2) covering the full high-$\beta$ strip.

**Step 7 — Variance term (E1/Lemma 4).** The $c'\sigma D/\sqrt{T}$ term inherits from OP-2's Le Cam two-point bound on the $y$-coordinate wall function, which is independent of the x-initialization. State this as a direct transfer with explicit constant $c' = \sqrt{2}/27$.

**Structural lemma to package separately (E5/Theorem 5.1).** Theorem 5.1 (zero-momentum incompatibility for all Goujaud-type functions at $\beta > 0$) belongs in a remark or companion lemma section, explaining why the main result requires the cycling subset $\mathcal{F}^{\mathrm{zero}}_{K=3} \subsetneq \mathcal{F}_{K=3}$ and why full coverage of $\mathcal{F}_{K=3}$ is unachievable via a Goujaud-type construction.

---

## Recommended Next Phase

**Pass to Auditor** with the following specific verification tasks:

1. **Verify L4 Floquet computation.** Numerically compute the $4\times4$ Floquet matrix $J_{\mathrm{cyc}} = D\Phi|_{(\lambda e_2, \lambda e_1)} \cdot D\Phi|_{(\lambda e_1, \lambda e_0)} \cdot D\Phi|_{(\lambda e_0, \lambda e_2)}$ at $(\beta, \eta L, \kappa) = (0.8, 3.247, 0.387)$ and confirm all four eigenvalues have modulus $\leq \beta^{3/2} + 10^{-3} = 0.716 + 10^{-3}$. Also compute the basin radius in Euclidean norm.

2. **Resolve E3's anchor attractor type.** Re-run the anchor simulation to high precision and determine whether the limiting orbit is: (a) the K=3 rotating 3-cycle, (b) a stationary fixed point in $\mathbb{R}^2$, or (c) a fixed point in the rotating-frame representation. Confirm the fixed-point interpretation is consistent with L4's Floquet claim.

3. **Confirm the polytope-exit inequality (L2.1) holds on a positive-measure open set.** Numerically scan $(\beta, \eta L, \kappa) \in [0.6, 0.95] \times [3.0, 2(1+\beta)] \times [0.1, 0.5]$ and verify that the locus of (L2.1) is non-empty, open, and has 2-D measure $\geq 0.04$.

4. **Check Vieta identity.** Verify symbolically that $(1-r_1)(1-r_2) = \eta\mu$ for the characteristic polynomial $z^2 - (1+\beta-\eta\mu)z + \beta = 0$, confirming E6/L3's correction over the Scout's sub-claim A1 formula.

5. **Variance term compatibility.** Confirm that the OP-2 $y$-coordinate Le Cam construction (wall function $w(y)$, two functions $f^+$ and $f^-$ differing only in the $y$-coordinate) remains compatible with zero-momentum init on the $x$-coordinates. In particular, verify that the x-init choice $(x_0 = x_{-1} = (D/\sqrt2)e_0)$ does not interfere with the oracle's indistinguishability argument in the $y$-direction.

6. **E4 period-2 fixed-point numerics.** Run the SHB orbit from zero-momentum init at $(\beta, \eta L, \kappa) = (0.9, 3.7, 0.1)$ for $T = 10^4$ steps and determine whether: (a) the orbit is truly period-2 (exactly 2 distinct limiting $\|x_t\|$ values), (b) period-6 (6 values cycling), or (c) quasi-periodic. This resolves the ambiguity in E4/§9.

The Auditor is NOT asked to re-verify the following (already confirmed to sufficient precision): the first-step formula L1 (algebraic identity), the anchor cycling classification (50-digit, $T=2000$), and the Scout's Lemma D1 computation.
