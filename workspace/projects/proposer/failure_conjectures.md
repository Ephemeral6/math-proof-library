# Failure-Driven Conjectures — Step A3

> Source: `workspace/failure_triggers.md` + `workspace/failure_analysis/root_cause_analysis.md`,
> cross-checked against `workspace/failure_analysis/retry_results.md`.
>
> 19 of 28 failures already converted on retry — focus on the genuinely-PARTIAL/RETRY-FAIL ones,
> plus interesting historical failures from failure_triggers.md.
>
> Per-failure template: failure → IMPLIES X → candidate problem (counterexample/disproof OR alternative approach).

---

## Section 1 — Genuinely-stuck failures from retry_results.md (6 candidates)

### Candidate: BLLT 2020 bias bound via row-deletion identity (RC5 alternative to Gordon-Slepian)
- **Problem statement**: For min-norm interpolator $\hat\beta = X^\dagger y$ with $\Sigma$-signal model, the bias term $\beta^{*\top}(I-P)\Sigma(I-P)\beta^*$ admits a row-deletion-style decomposition $\sum_{i=1}^n \langle \beta^*, \Sigma e_i\rangle^2 / \lambda_i^2$ that gives the $\sqrt{r_0/n}$ bound WITHOUT Gordon-Slepian, requiring only Hanson-Wright + Sherman-Morrison.
- **Setting**: high-dim linear regression with $\Sigma$-anisotropic features, min-norm interpolator.
- **Why it's a failure-implication**: P2 retry confirmed Gordon-Slepian is "necessary" with current toolbox; the implied claim is that Gordon-Slepian is structurally needed. A row-deletion (à la Mei-Montanari) bypass would refute that and give an alternative path.
- **Suggested proof strategy**: `OTHER:matrix_concentration` + Sherman-Morrison row-deletion identity (Mei-Montanari template).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (structurally similar to Mei-Montanari proxies; not certain to give the sharp constant).

### Candidate: OP-2 sharp on full $\mathcal S$ — Nesterov-chain construction with explicit constant uniformity
- **Problem statement**: There exists a single $L$-smooth convex $f:\mathbb R^T\to\mathbb R$ (Nesterov-chain quadratic) such that for *every* fixed $\beta\in[0,1)$ and every $(\eta_t)$, SHB last-iterate satisfies $f(x_T)-f^\star \ge c(LD^2/T + \sigma D/\sqrt T)$ with constant $c$ uniform across $(\beta,\eta_t)$.
- **Setting**: smooth convex, fixed-momentum SHB, full set $\mathcal S$ of $(\beta,\eta_t)$.
- **Why it's a failure-implication**: A3 (RC2) said "beyond framework"; P3 retry switched to Nesterov-chain and got PARTIAL — the obstruction is now "constant uniformity along boundary $\eta=2(1+\beta)/L$." This is a concrete next attack target.
- **Suggested proof strategy**: `polytope_construction` (Nesterov-chain hard instance, dimension growing with $T$) + `le_cam_testing` (variance) + PEP-SDP verification of constant uniformity at boundary.
- **Difficulty estimate**: research (open since 2015; partial path identified)
- **Plausibility**: MEDIUM (the obstruction is real but identified).

### Candidate: Non-periodic SHB orbit on smooth convex (P14 from retry)
- **Problem statement**: For fixed-momentum SHB on a non-quadratic asymmetric $L$-smooth convex $f:\mathbb R^2\to\mathbb R$, there exists an initialization producing a quasi-periodic 2-torus orbit whose Cesàro-average does NOT collapse to $x^\star$, giving $f(\bar x_T)-f^\star \ge c LD^2/T$.
- **Setting**: smooth convex, fixed-momentum SHB, asymmetric instance.
- **Why it's a failure-implication**: D-OP2-Cesaro (RC1) showed periodic Goujaud orbits collapse on averaging via $K$-th roots of unity. Asymmetry is the only escape: a non-quadratic non-symmetric $f$ could break the symmetry.
- **Suggested proof strategy**: `polytope_construction` (asymmetric perturbation of Goujaud) + Krylov-Bogolyubov invariant measure + first-moment computation.
- **Difficulty estimate**: research
- **Plausibility**: LOW-MEDIUM (symmetry is a strong constraint; the perturbation must maintain $L$-smoothness).

### Candidate: Polyak-vs-Nesterov rate separation under $\beta\to 1, \eta L\to 0$ joint regime
- **Problem statement**: In the joint regime $\beta=1-1/T, \eta L = 1/T$, Polyak HB has rate $\Omega(LD^2/\log T)$ while Nesterov has $O(LD^2/T)$ on the *same* instance — strict $T/\log T$ separation.
- **Setting**: smooth convex, asymptotic momentum regime.
- **Why it's a failure-implication**: P20 retry RETRY-FAIL: definitional ambiguity in $\mathcal F$. The implication is that picking a SPECIFIC asymptotic regime resolves the ambiguity.
- **Suggested proof strategy**: `spectral_eigenvalue` (Lookahead chain) + asymptotic regime analysis + explicit instance.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: AdaGrad-Norm sharper LB $\Omega(\log N/\sqrt N)$ via Chen-Bansal noise
- **Problem statement**: For AdaGrad-Norm last-iterate on smooth non-convex, there exists adversarial noise schedule (Chen-Bansal-style burst noise) such that $\mathbb E\|\nabla f(x_T)\| \ge c\log T/\sqrt T$, matching the $O(\log T/\sqrt T)$ upper bound.
- **Setting**: smooth non-convex, adversarial noise, AdaGrad-Norm.
- **Why it's a failure-implication**: P23 PARTIAL: $\sqrt N$ rate proven, $\log N$ open. The implied path is Chen-Bansal noise.
- **Suggested proof strategy**: `polytope_construction` + Chen-Bansal burst-noise schedule + algorithm-specific Le Cam.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: Coefficient suboptimality — non-quadratic instance where polynomial weights beat exponential weights
- **Problem statement**: For SHB on a *non-quadratic* smooth convex $f$, polynomial-weight Polyak-Ruppert achieves $O(LD^2/T^2)$ while exponential-weight Polyak-Ruppert achieves $\Omega(LD^2/T)$ — strict separation between weight classes that is invisible on quadratics (where Chebyshev coincidence makes them equal).
- **Setting**: smooth convex non-quadratic, SHB with weighted averaging.
- **Why it's a failure-implication**: P26 PARTIAL: on quadratics the two coincide (Chebyshev); a non-quadratic separator instance is needed.
- **Suggested proof strategy**: `polytope_construction` (non-quadratic Goujaud-like) + complexification of weighted sums.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

---

## Section 2 — Failure-trigger-derived counterexample / refutation candidates (4 candidates)

### Candidate: Universal failure of Cesàro-averaging on cycling LBs (FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE)
- **Problem statement**: For ANY first-order optimizer on ANY smooth convex $f$ with periodic-orbit hard instance, the Cesàro average $\bar x_T = (1/T)\sum_{t=0}^{T-1} x_t$ eliminates the LB iff the orbit's symmetry group has barycenter at $x^\star$. Conversely, breaking symmetry via $f \mapsto f + \epsilon h$ for $h$ asymmetric preserves the LB on Cesàro iterate.
- **Setting**: meta-theorem about cycling lower bounds.
- **Why it's a failure-implication**: FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE + FT-OP2-I4-SUFFIX-AVG-RESONANCE both arise from the same root cause: Birkhoff barycenter-at-optimum.
- **Suggested proof strategy**: Group-action geometry on iterate orbits + Birkhoff ergodic theorem + minimal-perturbation argument.
- **Difficulty estimate**: research (meta-theorem)
- **Plausibility**: MEDIUM (the converse direction needs care; symmetry breaking might also break smoothness).

### Candidate: SHB cycling-LB inheritance to Adam variance term (positive direction)
- **Problem statement**: While the OP-2 BIAS LB does not transfer to Adam (FT-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING), the VARIANCE LB $\Omega(\sigma D/\sqrt T)$ DOES transfer to fixed-hyperparameter Adam, with explicit constant $c = c_0 \cdot (1-\beta_1)\epsilon/(\eta L+\epsilon)$ derived from decoupled $y$-coordinate Le Cam.
- **Setting**: fixed-hyperparameter Adam, variance lower bound.
- **Why it's a failure-implication**: FT-OP2-ADAM (RC1) flagged Adam BIAS LB false; P17 retry confirmed VARIANCE LB true. This is a positive consequence of the failure.
- **Suggested proof strategy**: `le_cam_testing` (decoupled $y$-coordinate construction) + Adam-specific test-distinguishability calculation.
- **Difficulty estimate**: research (P17 retry produced PASS sketch)
- **Plausibility**: HIGH.

### Candidate: PEP-SDP closed-form witness for HB-zero-init via Drori-Teboulle template
- **Problem statement**: For HB with zero-momentum init on smooth convex with $\beta \in (0,1), \eta L \in (0,2)$, the PEP-SDP optimal witness function is the explicit piecewise-quadratic $f_{\beta,\eta}^\star(x) = \min_y\{\frac L2(x-y)^2 + \alpha_{\beta,\eta}|y|\}$ with explicit $\alpha_{\beta,\eta}$.
- **Setting**: smooth convex, HB with zero-momentum init, PEP construction.
- **Why it's a failure-implication**: FT-PEP-WITNESS-INEXPLICITNESS (RC2). Inverting this failure pattern: for a SPECIFIC algorithm (zero-init HB) the PEP-SDP MAY admit a clean witness via a Drori-Teboulle-style chain construction.
- **Suggested proof strategy**: PEP-SDP solve at small $T$ + observe the dual-variable structure + reverse-engineer the piecewise-quadratic.
- **Difficulty estimate**: research (substantial; warned by FT)
- **Plausibility**: LOW-MEDIUM.

### Candidate: Dimension-dependent $\sqrt{\log d}$ bound under coupled Le Cam (FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM)
- **Problem statement**: Under $\ell_2$-bounded variance oracle and *coupled* hypothesis class (Nemirovski-Yudin construction), the SHB variance LB scales as $\Omega(\sigma D \sqrt{\log d}/\sqrt T)$ in dim $d$ — recovering the standard Nemirovski-Yudin scaling that naive product Le Cam loses.
- **Setting**: $\ell_2$-bounded oracle, coupled hypothesis class, dim-$d$ SHB variance LB.
- **Why it's a failure-implication**: FT-OP2-CAUCHY-SCHWARZ-CANCELLATION (RC1: $\ell_2$ kills $\sqrt{d-2}$). The implication: coupling DOES recover dimension scaling.
- **Suggested proof strategy**: Nemirovski-Yudin coupled hypothesis (1983) + adaptation to SHB chain.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (the technique is published; the SHB-specific transfer is open).

---

## Section 3 — Auditor-blind-spot derived candidates (3 candidates)

### Candidate: Sweep all UB+LB+tightness proofs in research/ for FT-18 blind spot
- **Problem statement**: Among the 70 research-level proofs, identify all that simultaneously state a UB, an LB, and a tightness claim. Show that exactly $k$ of them have the FT-18 blind spot (UB strictly tighter than LB) and produce the corrected statement for each.
- **Setting**: meta-audit of the proof library.
- **Why it's a failure-implication**: FT-18-AUDITOR-MISSES-UB-LB-CONTRADICTION + E1 (AdaGrad-Norm). The Auditor Step 0.5 was added but old proofs have not been re-checked.
- **Suggested proof strategy**: Automated rate-comparison + manual triage.
- **Difficulty estimate**: standard (audit task, but high-value)
- **Plausibility**: HIGH (this is meta-infrastructure; finding any false-tight claim is a contribution).

### Candidate: Classifier theorem: when does HLL-R last-iterate-vs-average gap apply?
- **Problem statement**: Provide a sharp classifier: a stochastic optimization algorithm has $\Theta(\log T)$ last-vs-average gap iff its noise process satisfies (i) $\mathbb E[\xi_t|\mathcal F_{t-1}] = 0$, (ii) $\sigma^2 = \mathbb E\|\xi_t\|^2$ uniformly bounded away from 0 along the optimal trajectory, (iii) the algorithm's Lyapunov telescopes only after summing.
- **Setting**: meta-theorem about iterate-type asymmetry.
- **Why it's a failure-implication**: SVRG, AdaGrad-Norm (FT-18), and SHB cycling all hit this via different mechanisms. A classifier theorem prevents future blind-spot reuse.
- **Suggested proof strategy**: Reverse-engineering HLL-R 2019 + sufficient/necessary condition extraction.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: Reverse Auditor: from a candidate proof, reconstruct the "wrong inequality" the proof would produce if naively applied to a different iterate type
- **Problem statement**: Given any descent-lemma + telescope + averaging proof, there is a canonical "iterate-type-shift" that produces a wrong inequality differing from the correct one by exactly the HLL-R log factor or by the Goujaud cycling factor. Make this canonical map explicit.
- **Setting**: meta-theorem about proof manipulations.
- **Why it's a failure-implication**: FT-18 + the broader pattern that Auditors can be inverted into Constructors.
- **Suggested proof strategy**: Categorical / functorial framing of proof transformations.
- **Difficulty estimate**: research / conjecture
- **Plausibility**: LOW-MEDIUM.

---

## Section 4 — LDT-derived counterexample candidates (2 candidates)

### Candidate: Spiral-knot S(p,q,ε) signature closed form via Burau (resolves FT-SPIRAL-PRINCIPAL-MINOR-MISFRAMING)
- **Problem statement**: For spiral knots $S(p,q,\epsilon)$ with mixed-sign $\epsilon$, the signature $\sigma(S(p,q,\epsilon))$ has closed form $\sigma = \sum_{i=1}^p \epsilon_i \cdot s_i(p,q)$ where $s_i$ are computable from the Burau representation in $B_{q+1}$ (intrinsic embedding, not principal minor of $B_{p}$).
- **Setting**: low-dimensional topology, knot invariants.
- **Why it's a failure-implication**: FT-SPIRAL-PRINCIPAL-MINOR-MISFRAMING + FT-SPIRAL-PARAMSWAP-MIXED-CASE-LEVEL1-GAP both diagnose the same root cause: wrong induction variable.
- **Suggested proof strategy**: Block Structure Lemma (last-row preservation) + Burau matrix in correct embedding.
- **Difficulty estimate**: research (LDT specialty)
- **Plausibility**: MEDIUM.

### Candidate: Kauffman bracket convention-checker as automated invariant validator
- **Problem statement**: For knot invariants stored in tables, an automatic convention-detector (running 3 worked examples per invariant) catches q-vs-t convention mismatches with $\ge 99\%$ precision and zero false positives.
- **Setting**: knot-invariant computation, library validation.
- **Why it's a failure-implication**: FT-KAUFFMAN-CONVENTION (sign-flip via wrong convention).
- **Suggested proof strategy**: Test-driven library design + 3-example invariants.
- **Difficulty estimate**: standard (engineering with formal guarantees)
- **Plausibility**: HIGH.

---

## Summary

| Section | Source | # Candidates | Plausibility |
|---|---|---|---|
| 1 | Genuinely-stuck retry-results PARTIAL/RETRY-FAIL | 6 | MED |
| 2 | failure_triggers.md (counterexample/refutation) | 4 | MED-HIGH |
| 3 | Auditor blind-spot derivation | 3 | MED-HIGH |
| 4 | LDT failure triggers | 2 | MED-HIGH |
| **Total** | | **15** | |

**Top picks**:
- 1.1 BLLT row-deletion bypass (would CHANGE Gordon-Slepian-needed verdict)
- 1.2 OP-2 sharp via Nesterov-chain (closes 9-year-old open problem if successful)
- 2.4 Coupled Le Cam $\sqrt{\log d}$ (recovers known scaling via clean argument)
- 3.1 Sweep for FT-18 (high-EV meta-task)
- 4.1 Spiral-knot Burau signature (LDT contribution)
