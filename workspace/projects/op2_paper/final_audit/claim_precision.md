# OP-2 Final Audit: Claim Precision Audit

**Date:** 2026-04-28
**Auditor:** Claim Precision Auditor (pre-peer-review pass)
**Scope:** OP-2 v4 (`workspace/op2_downgraded_proof_v4.md`), Li–Xiao directions (`summary.md`, `direction_1_zero_momentum.md`, `direction_2_last_iterate_ub.md`), and `proofs/research/optimization/lower-bounds/shb-*` (cross-reference only).

This document audits every "Theorem / Lemma / Proposition / Claim / Corollary / Remark" with mathematical content for: quantifier order, full hypotheses, conclusion precision, and implicit assumptions. Each entry tags `VALID` or `NEEDS_CORRECTION`. The five known re-audit issues (A–E) are explicitly checked at the bottom.

---

## Part 1. OP-2 v4 (`op2_downgraded_proof_v4.md`)

### Theorem (Main), §0.5
- **Statement (paraphrase):** Under (RGM): $\sigma \le LD\sqrt 2$, for every $(\beta,\eta)\in\mathcal F$ and every integer $T\ge 1$, there exist $f^{(T)}_{\beta,\eta}:\mathbb R^3\to\mathbb R$ (convex, $L$-smooth, globally 0-SC), $(x_0,x_{-1})$ with $\|x_0-x^\star\|=D$ exactly, and an unbiased variance-$\sigma^2$ oracle, such that $\mathbb E[f(x_T)-f^\star]\ge (\kappa/4)LD^2/T+(\sqrt 2/27)\sigma D/\sqrt T$.
- **Quantifiers:** $\forall(\beta,\eta)\in\mathcal F,\ \forall T\ge 1,\ \exists f^{(T)}_{\beta,\eta},\exists(x_0,x_{-1}),\exists\,\text{oracle}$. Order is $\forall T\,\exists f^{(T)}$, correctly stated in §0.6.
- **Hypotheses:** (RGM), $(\beta,\eta)\in\mathcal F$ (positive-measure subset of $\mathcal S$), $T\ge 1$, $\kappa=\kappa(\beta,\eta)$. All listed.
- **Conclusion precision:** $\ge$, with explicit constants $\kappa/4$ and $\sqrt 2/27\approx 0.0524$. The footnote correctly notes $1/(8\sqrt 2)$ is only the asymptotic limit as $r\to 0$, not a finite-$T$ deliverable under saturated (RGM).
- **Status:** **VALID.** The quantifier structure is unambiguously $\forall T\,\exists f^{(T)}$, the regime hypothesis (RGM) is stated, the variance-constant footnote is precise.

### Lemma 1.1 (Moreau decomposition), §1.1
- **Statement:** $C\subset\mathbb R^d$ closed convex non-empty $\Rightarrow\Phi_C$ is convex, $C^{1,1}$, $\nabla\Phi_C=P_C$ (1-Lipschitz).
- **Quantifiers:** $\forall C$ closed convex non-empty, three properties hold.
- **Hypotheses:** non-emptiness of $C$ (essential, since $P_C$ undefined otherwise) — listed.
- **Conclusion precision:** equalities $\nabla\Phi_C=P_C$, plus 1-Lipschitz/firmly nonexpansive.
- **Status:** **VALID.** Standard textbook result correctly cited.

### Lemma 1.2 (SC gap identity), §1.2
- **Statement:** $f$ $\mu$-SC with min $x^\star$ $\Rightarrow f(x)-f^\star\ge(\mu/2)\|x-x^\star\|^2$.
- **Quantifiers:** $\forall x\in\mathbb R^d$.
- **Hypotheses:** $f$ $\mu$-SC, minimizer $x^\star$ exists. Listed.
- **Conclusion precision:** $\ge$.
- **Status:** **VALID.**

### Lemma 1.3 (GPT23 cycling), §1.3
- **Statement:** For $L>0,\mu\in(0,L),\beta\in[0,1),\eta>0,K\ge 3$ with (★) at $\kappa=\mu/L$, the Goujaud function $\psi$ is $L$-smooth, $\mu$-SC, min at 0, with projection-cycle identity $P_{\mathrm{conv}(P)}(e_t)=Me_t$ and the cycling property $x_t=e_{t\bmod K}$ from $(x_0,x_{-1})=(e_0,e_{K-1})$.
- **Quantifiers:** Fix $(L,\mu,\beta,\eta,K,\kappa)$ satisfying (★); then four conclusions.
- **Hypotheses:** $\mu\in(0,L)$ strict (needed for non-degenerate cycle), $K\ge 3$ integer (not $K\ge 2$), (★) feasible. All listed.
- **Conclusion precision:** equalities + Loewner bound $[\mu I_2,LI_2]$ a.e.
- **Status:** **VALID.** Note: implicit assumption that the under-damped condition $(1+\beta-\eta\mu)^2<4\beta$ gives complex roots is needed for the *spectral* analysis, but Lemma 1.3 itself only states cycling, which holds under (★) without invoking the under-damped roots; it is an algebraic identity.

### Lemma 1.4 (Le Cam Gaussian), §1.4
- **Statement:** With $\alpha=\sigma/(3\sqrt T)$ (i.e., $c_\alpha=1/3$), $\mathbb P^T_\pm$ product Gaussians: (a) KL$=2/9$, (b) TV$\le 1/3$, (c) Le Cam $p_{\min}\ge 1/3$.
- **Quantifiers:** $\forall T\ge 1,\forall\sigma,D>0$.
- **Hypotheses:** $T\ge 1$, $\sigma,D>0$; $\alpha:=\sigma/(3\sqrt T)$ (definition, not hypothesis). Listed.
- **Conclusion precision:** equality (a), $\le$ (b), $\ge$ (c).
- **Status:** **VALID.** The values KL$=2/9$, TV$\le 1/3$, $p_{\min}\ge 1/3$ are computed correctly: $T\cdot 2(\sigma/(3\sqrt T))^2/\sigma^2=2/9$. Pinsker $\sqrt{(2/9)/2}=\sqrt{1/9}=1/3$.

### Lemma 1.6 (GFJ15 deterministic), §1.6
- **Statement:** Convex $L$-smooth $f$, deterministic HB (zero-noise) with fixed $(\beta,\eta)$ in suitable range, Cesàro avg $\bar x_T$: $f(\bar x_T)-f^\star\le c_3\,LD^2/T$.
- **Quantifiers:** $\forall f\in\mathcal F_L,\forall T,\exists c_3$ universal.
- **Hypotheses:** $f$ convex $L$-smooth, $\|x_0-x^\star\|\le D$, $\sigma=0$ (deterministic), $(\beta,\eta)$ in suitable range, **Cesàro average** target (not last iterate). All listed and the deterministic-only caveat is explicit.
- **Conclusion precision:** $\le$ on $\bar x_T$ (Cesàro), not on $x_T$.
- **Status:** **VALID.** v3 correctly removed the prior false stochastic claim.

### Lemma 1.7 (positive homogeneity of projection), §1.7
- **Statement:** $C$ closed convex non-empty, $\lambda>0$ $\Rightarrow P_{\lambda C}(\lambda x)=\lambda P_C(x)$.
- **Quantifiers:** $\forall x\in\mathbb R^d$.
- **Hypotheses:** $\lambda>0$ strict (essential for positive homogeneity), non-emptiness of $C$. Listed.
- **Conclusion precision:** equality.
- **Status:** **VALID.**

### Claim 2.1 ($f_0$ regularity), §2.1.1
- **Statement:** $f_0$ defined via rescaled polytope is convex, $L$-smooth, $\mu$-SC on $\mathbb R^2$, unique min $f_0(0)=0$.
- **Quantifiers:** under fixed $(\beta,\eta)\in\mathcal F$ and $K,\kappa$ from feasibility.
- **Hypotheses:** $(\beta,\eta)\in\mathcal F$, $\mu=\kappa L\in(0,L)$, $D>0$. All listed.
- **Conclusion precision:** equalities (regularity, gradient formula, min value).
- **Status:** **VALID.**

### Claim 2.2 ($f^{(s)}$ regularity), §2.1.2
- **Statement:** $f^{(s)}=f_0(x)+\alpha_sy+w(y)$ is convex $L$-smooth on $\mathbb R^3$ with unique minimizer $(0,y^\star_s)$, $y^\star_s=-sD/\sqrt 2$ exactly.
- **Quantifiers:** $\forall s\in\{\pm 1\}$, given $T\ge 1$ and (RGM).
- **Hypotheses:** (RGM) (so $R\ge 0$ via $\alpha/L\le D\sqrt 2/3<D/\sqrt 2$), $T\ge 1$, $\sigma>0$. All listed.
- **Conclusion precision:** "exact equality" $|y^\star_s|=D/\sqrt 2$ (Hessian PD at minimizer + globally convex $\Rightarrow$ unique). v3 cleaned the piecewise computation.
- **Status:** **VALID.**

### Claim 2.3 (oracle), §2.1.3
- **Status:** **VALID.** Standard.

### Claim 2.4 (initial distance), §2.1.4
- **Statement:** $\|(x_0,y_0)-(0,y^\star_s)\|=D$ exactly.
- **Status:** **VALID.** Direct algebra, $D^2/2+D^2/2=D^2$.

### Claim 2.5 (decoupling), §2.2
- **Status:** **VALID.** Block-diagonal Hessian + linear $y$-term decouples.

### Lemma 2.6 (amplitude preservation), §2.3.1
- **Statement:** Deterministic HB on $f_0$ from $(x_0,x_{-1})=((D/\sqrt 2)e_0,(D/\sqrt 2)e_{K-1})$ satisfies $x_t=(D/\sqrt 2)e_{t\bmod K}$ $\forall t\ge 0$, hence $\|x_t\|=D/\sqrt 2$.
- **Quantifiers:** $\forall t\ge 0$.
- **Hypotheses:** OP-2 cycle init $x_0\ne x_{-1}$ (non-zero momentum); $(\beta,\eta)\in\mathcal F$.
- **Conclusion precision:** equality.
- **Status:** **VALID.** This is the lemma that fails for zero-momentum init — a fact correctly captured by Theorem 5.1 in `direction_1_zero_momentum.md` (see Issue A below).

### Lemma 2.7 (bias gap $\ge\mu D^2/4$), §2.3.2
- **Statement:** $f_0(x_T)-f_0^\star\ge\mu D^2/4=\kappa LD^2/4$ for every $T\ge 0$.
- **Quantifiers:** $\forall T\ge 0$.
- **Hypotheses:** OP-2 cycle init, $(\beta,\eta)\in\mathcal F$.
- **Conclusion precision:** $\ge$.
- **Status:** **VALID.** Note: this constant $\kappa/4$ is the OP-2 (non-zero momentum) constant; Direction 1 (zero momentum) degrades it.

### Lemma 2.9 (Le Cam variance gap), §2.4.1
- **Statement:** Under (RGM), $\max_s\mathbb E_s[\alpha_sy_T+w(y_T)-\min(\alpha_sy+w(y))]\ge(\sqrt 2/27)\sigma D/\sqrt T$.
- **Quantifiers:** $\forall T\ge 1$, $\forall$ algorithm (possibly randomized) using $\le T$ oracle queries.
- **Hypotheses:** (RGM) (so $\alpha\le LD\sqrt 2/3$ and wall well-defined), $T\ge 1$, $\xi_t\sim\mathcal N(0,\sigma^2)$ i.i.d., $y_0=y_{-1}=0$, the saturated worst case $r=\sqrt 2$ (otherwise constant is even better, $\rho(r)\ge\sqrt 2/3$). All listed.
- **Conclusion precision:** $\ge$ via exact identity at saturation.
- **Status:** **VALID.** v4's Step 3 replaces the v3 loose inequality with the **exact identity** $\rho(\sqrt 2)=\sqrt 2/3$, sharpening from $1/112$ to $\sqrt 2/27$. The decomposition $\alpha D/\sqrt 2-\alpha^2/(2L)=\alpha D\rho(r)$ is algebraically correct.

### Claim 2.10 (combining), §2.5
- **Statement:** $\max_s\mathbb E_s[f^{(s)}(x_T,y_T)-f^{(s),\star}]\ge(\kappa/4)LD^2/T+c_{NY}\sigma D/\sqrt T$.
- **Hypotheses:** Conjunction of Claim 2.5 (decoupling), Lemma 2.7 (bias), Lemma 2.9 (variance), Claim 2.11 (max-split).
- **Conclusion precision:** $\ge$, with explicit $c_{NY}=\sqrt 2/27$. The $s^\star$ is a deterministic function of $(\beta,\eta,T)$ (made explicit in v3-MOD-8).
- **Status:** **VALID.**

### Claim 2.11 (max-over-$s$ split), §2.5
- **Status:** **VALID.** Trivial: $\max_s(A+B_s)=A+\max_s B_s$ when $A$ is $s$-independent.

### Claim 2.12 (global 0-SC), §2.6
- **Statement:** $f^{(s)}$ has global SC constant 0; i.e., convex but not $\mu'$-SC for any $\mu'>0$.
- **Hypotheses:** $f^{(s)}$ as constructed; tests at $(0,0)$ where $w''(0)=0$.
- **Conclusion precision:** equality (global SC constant $=0$ exactly). Witness vector $v=(0,0,1)$ at $(0,0)$ where $\nabla^2f^{(s)}(0,0)=\mathrm{diag}(L,L,0)$.
- **Status:** **VALID.** The remark that $f$ is locally strongly convex on $|y|>R$ is correct and clarifying.

### Claim 2.13 (positive measure), §2.7
- **Statement:** $\mathcal F^\circ_{K=3}=\{(\beta,\eta):\beta>\beta^\star,\,L\eta\in(\gamma_{\mathrm{crit}}(\beta),2(1+\beta))\}$ is non-empty open with positive 2-D Lebesgue measure, and $\mathcal F\supset\mathcal F^\circ_{K=3}$.
- **Hypotheses:** $\beta^\star=(\sqrt{13}-3)/2$, $\gamma_{\mathrm{crit}}(\beta)=3(1+\beta+\beta^2)/(1+2\beta)$.
- **Conclusion precision:** equalities (closed-form measure $\int(\beta^2+3\beta-1)/(1+2\beta)\,d\beta$); strict positivity $\ell(\beta)>0$ for $\beta>\beta^\star$. Sufficiency-only (necessity empirical) cleanly separated in v3.
- **Status:** **VALID.** Sufficiency direction is the one used; the separation of necessity (empirical) is correct hygiene.

### Remark 4.1.1 (Nesterov cycling), §4.1
- **Statement:** Explicit $M^{\mathrm{Nes}}$, NAG-feasibility region $\mathcal F^{\mathrm{Nes}}$ non-empty for $\mu/L\lesssim 0.25$ at $K=3$, generally disjoint from $\mathcal F^{\mathrm{HB}}$, transfers $\Omega(\mu D^2)$ non-acceleration.
- **Hypotheses:** KKT-projection identity for $M^{\mathrm{Nes}}$ holds (a NAG analogue of (★)); $K\ge 3$; $\mu/L\le 0.25$ (numerical regime).
- **Conclusion precision:** $\Omega(\mu D^2)$ on the NAG polytope, "method-specific cycling, method-agnostic non-acceleration" — explicitly framed as parallel results, not a HB-vs-NAG separation.
- **Status:** **VALID.** Caveat: "generally disjoint" is supported only by a $60\times 60$ scan, not proved analytically; the framing already acknowledges this is numerical evidence.

---

## Part 2. `summary.md`

The summary's WARNING block lists CORRECTIONs 1–5. We verify each is correctly flagged.

### Direction 1 boxed Theorem (line 89)
- **Statement (paraphrase):** $\exists\mathcal F^{\mathrm{zero}}_{K=3}\subset\mathcal F_{K=3}$ open, positive measure, such that $\forall(\beta,\eta)\in\mathcal F^{\mathrm{zero}}_{K=3},\,\mathbb E[f(x_T)-f^\star]\ge\kappa LD^2/(8T)+(\sqrt 2/27)\sigma D/\sqrt T,\,\forall T\ge T_0(\beta,\eta)\approx 10$.
- **Quantifiers:** $\exists\mathcal F^{\mathrm{zero}},\forall(\beta,\eta)\in\mathcal F^{\mathrm{zero}},\forall T\ge T_0$. Order is correct: the LB is uniform in $(\beta,\eta)$ over the subset, valid for $T$ large enough.
- **RE-AUDIT marker (line 91):** correctly flags that "$\forall T\ge 1$ with $\kappa/8$" FAILS at $T=4$ (ratio $0.113<0.125$), and offers the alternatives (κ/9 with all $T\ge 1$, or κ/8 with $T\ge T_0\approx 10$).
- **Status:** **VALID** — the summary correctly documents Issue A. **However, a precision tightening is recommended:** the boxed bound shows only the $T\ge T_0$ option, while the WARNING block describes both. The boxed statement is not internally inconsistent, but readers may miss the WARNING. Recommendation: add an inline note next to the box, "see WARNING above for κ/8-vs-κ/9 trade-off".

### Direction 2 minimax-η claim (line 149, table row)
- **Statement:** "$\eta_T=D/(\sigma\sqrt T)$ gives noise floor in **rate** $\Theta(\sigma D/\sqrt T)$".
- **RE-AUDIT marker:** the original "exactly" was corrected to "in rate $\Theta$"; the constants $1/[4(1-\beta)]$ vs $\sqrt 2/27$ differ by $\beta$-polynomial factor 4.77× ($\beta=0$) to 47.7× ($\beta=0.9$).
- **Status:** **VALID** — Issue B correctly propagated.

### CORRECTION 3 — "0.37 µD²" → "~2.22 µD²"
- The summary's line 28 explicitly notes: with $\|x^a\|\approx 2.107$ (in $D=1$ units), floor $(\mu/2)(2.107)^2\approx 2.22\mu D^2$.
- **Status:** **VALID** — Issue D correctly flagged.

### CORRECTION 4 — "19% measure" mis-attribution
- The summary's line 32 explicitly notes: 17/19 are PERIOD-4 (not period-2/-6).
- **Status:** **VALID** — Issue E correctly flagged.

### CORRECTION 2 — period-2 → period-6 / period-2 mod $C_3$
- Lines 22–24, 105 in the summary correctly disambiguate: "period-6 in iterate / period-2 in norm modulo $C_3$".
- **Status:** **VALID** — Issue C correctly flagged.

---

## Part 3. `direction_1_zero_momentum.md`

### Theorem (Direction 1, §0)
- **Statement:** $\exists\mathcal F^{\mathrm{zero}}_{K=3}\subset\mathcal F_{K=3}$ open positive measure, $\forall(\beta,\eta L,\kappa)\in\mathcal F^{\mathrm{zero}}_{K=3}$, $\forall T\ge 1$: $\mathbb E[f(x_T)-f^\star]\ge(\kappa/8)LD^2/T+(\sqrt 2/27)\sigma D/\sqrt T$.
- **Quantifiers:** $\exists\mathcal F^{\mathrm{zero}},\forall(\beta,\eta,\kappa),\forall T\ge 1$.
- **RE-AUDIT verdict:** THIS DOCUMENT'S Theorem statement (line 16-19) and final boxed statement (§9, line 266) **both write "$\forall T\ge 1$"**, which conflicts with summary CORRECTION 1.
- **Status:** **NEEDS_CORRECTION (HIGH).** Issue A is **only partially propagated.** The summary correctly flags the "$\forall T\ge 1$" failure, but `direction_1_zero_momentum.md` itself still has the original "$\forall T\ge 1$" with $\kappa/8$ in §0.0 and §9 boxed. Required fix: either (i) replace "$\forall T\ge 1$" with "$\forall T\ge T_0(\beta,\eta)\approx 10$" in both places, or (ii) downgrade $\kappa/8$ to $\kappa/9$ (or smaller — the verifier reports ratio settles near 0.95 at large $T$, so $\kappa/9$ comfortably accommodates the worst ratio 0.113 at $T=4$ with margin: $0.113<1/9\approx 0.111$ — actually $0.113>0.111$, so $\kappa/9$ may also fail at $T=4$; recommend $\kappa/10$ to be safe, or restate as $T\ge T_0$).
- The L5 transient discussion (line 176-185) explicitly uses "$\forall T\ge 1$" with the absorption "$\kappa/8$ to absorb the $(1-O(\beta^{3T/2}))^2$ factor uniformly in $T\ge 1$" — this is the **exact step** that the re-audit refuted. The proof argument is therefore inconsistent with the verifier output and must be revised.

### Theorem 5.1 (zero-momentum incompatibility), §1
- **Statement:** $x_1^{\mathrm{zero}}=\lambda(-\beta e_0+e_1+\beta e_2)$, with residual $x_1^{\mathrm{zero}}-\lambda e_1=\beta\lambda(e_2-e_0)\ne 0$ for any $\beta>0$. Hence no zero-momentum init can produce literal OP-2 cycling for $\beta>0$.
- **Quantifiers:** $\forall\beta>0$ (residual non-zero).
- **Hypotheses:** zero-momentum init $x_0=x_{-1}=\lambda e_0$ on Goujaud $f_0$.
- **Conclusion precision:** equality of residual; biconditional ($\beta=0\iff$ residual zero).
- **Status:** **VALID.** SymPy + mpmath verified per re-audit.

### Lemma L1 (kinematic), §1
- **Statement:** explicit Cartesian formulas (L1.1), (L1.2).
- **Status:** **VALID.** Symbolic identity $(1/2+\beta)^2+(3/4)(1-\beta)^2=1+\beta+\beta^2$ verified.

### Lemma L2 (polytope-exit), §2
- **Statement:** Open subset $\mathcal R_2$ where (L2.1) holds has positive 3-D Lebesgue measure (37% of test box).
- **Quantifiers:** $\exists\mathcal R_2$ open, positive measure.
- **Status:** **VALID** by 5932/12000 grid scan.

### Lemma L3 (Vieta amplitude), §3
- **Statement:** Scalar SHB amplitude $|A^{\mathrm{zero}}_\mu|^2=v^2\eta\mu/(4\beta\sin^2\theta_\mu)$.
- **Hypotheses:** **under-damped condition** $(1+\beta-\eta\mu)^2<4\beta$ implicit in roots being complex conjugates $r_2=\bar r_1$. Stated implicitly via "under-damped roots $r_{1,2}=\sqrt\beta e^{\pm i\theta_\mu}$" but not as an explicit hypothesis.
- **Status:** **NEEDS_CORRECTION (LOW).** The under-damped condition $(1+\beta-\eta\mu)^2<4\beta$ should be stated as an explicit hypothesis in L3, not assumed by language. Recommendation: add a sentence "Assume the under-damped regime $(1+\beta-\eta\mu)^2<4\beta$, equivalent to $\eta\mu\in(\,(1-\sqrt\beta)^2,(1+\sqrt\beta)^2\,)$, so $r_2=\bar r_1=\sqrt\beta e^{-i\theta_\mu}$." Otherwise the formula $|1-r_1|^2=(1-r_1)(1-\bar r_1)=\eta\mu$ is invalid (in the over-damped regime, $r_1,r_2\in\mathbb R$ and the formula reads $|1-r_1||1-r_2|=\eta\mu$, not the squared modulus).

### Lemma L4 (Floquet), §4
- **Statement:** All four Floquet multipliers at modulus exactly $\beta^{3/2}<1$, multiplicity 2.
- **Hypotheses:** vertex-projection regime (cycle vertex projects to a vertex of $\widetilde P$, not edge interior); $(\beta,\eta L,\kappa)$ in the open set $\mathcal R_4$ where this holds.
- **Conclusion precision:** equality of moduli to 50 digits.
- **Status:** **VALID.** The corrected Hessian regime (vertex, not edge-interior) is the right one at the anchor.

### Lemma L5 (basin) — ALREADY FLAGGED IN ISSUE A.
- **Status:** **NEEDS_CORRECTION (HIGH).** See Theorem (Direction 1) above. The transient absorption "uniformly in $T\ge 1$" is empirically false at $T\le 9$.

### Lemma L6 (witness), §6
- **Statement:** Anchor $(0.8,3.247,0.387)$ with zero-momentum init reaches K=3 rotating cycle to 12+ digits at $T=2010$.
- **Status:** **VALID** (E3 misinterpretation of "stationary fixed point" corrected).

### Lemma L7 (period-2 complement), §7
- **Statement (line 213-217):** Period-2 attractors at $(0.9,3.78,0.05)$ and $(0.95,3.85,0.10)$.
- **RE-AUDIT verdict:** Issue C says these are "**period-6 in iterate** / period-2 mod $C_3$". The summary correctly disambiguates this. **However**, line 215, "**Period-2**" in the table header, and line 211, "period-2 attractor at higher $\beta$", **still uses the imprecise term in this document**.
- **Status:** **NEEDS_CORRECTION (MEDIUM).** Issue C is **partially propagated.** Required fix: replace "Period-2" (line 215, 218) with "Period-6 in iterate (period-2 modulo $C_3$ rotation)" in the table heading and the main statement; lines 222-225 also need to be retitled. The L7 §7 statement (line 211) "a separate **period-2 attractor**" must read "period-6 attractor (period-2 mod $C_3$)".
- **Statement (line 224):** floor "$\geq 2\mu \approx 0.37\mu D^2$ (since $D^2=2\lambda^2=1$, rescaled)".
- **RE-AUDIT verdict (Issue D):** Actual floor is $(\mu/2)(2.107)^2\approx 2.22\mu D^2$ (units error: the "0.37 µD²" came from $D=1/\sqrt 2$ confusion; with $D=1$ the floor is $\sim 2.22$).
- **Status:** **NEEDS_CORRECTION (MEDIUM).** Issue D is NOT propagated. Line 224 states "$\geq 2\mu \approx 0.37\mu D^2$" — this is the units-error formula. Required fix: replace with "$\geq 2.22\mu D^2$ at anchor 1, $\geq 3.44\mu D^2$ at anchor 2" (per summary line 28); the unit-conversion remark "$D^2=2\lambda^2=1$, rescaled" introduced the confusion and should be removed or expanded explicitly.

### Lemma L8 (variance transfer), §8
- **Statement:** $y$-coordinate Le Cam bound is decoupled from $x$-init; $c'=\sqrt 2/27$ inherits.
- **Status:** **VALID.**

### Final boxed Theorem §9 (line 266)
- **Status:** **NEEDS_CORRECTION (HIGH).** Same issue as the §0 statement: "$\forall T\ge 1$ with $\kappa/8$" is false at $T\le 9$. Must be revised.

### "Honest scope" §9 (lines 271, 273)
- Line 271 says "stronger floor $\ge 0.37\mu D^2$" — same units error as L7. **NEEDS_CORRECTION (MEDIUM).** Issue D again.

---

## Part 4. `direction_2_last_iterate_ub.md`

### Theorem A.1 (closed-form noise floor), §1
- **Statement:** Under stability ($|\beta|<1$, $\eta L<2(1+\beta)$), $\mathrm{Var}_\infty[x]=\eta\sigma^2(1+\beta)/[L(1-\beta)(2(1+\beta)-\eta L)]$.
- **Quantifiers:** $\forall(\beta,\eta)$ in stability region, on $f(x)=(L/2)x^2$ with i.i.d. Gaussian noise.
- **Hypotheses:** Schur stability $|\beta|<1$, $\eta L<2(1+\beta)$; quadratic objective; i.i.d. Gaussian noise.
- **Conclusion precision:** equality.
- **Status:** **VALID.** SymPy + Monte Carlo verified to <0.1% relative error.

### Theorem A.2 (minimax-η), §2
- **Statement:** With $\eta_T=D/(\sigma\sqrt T)$ (well-defined for $T$ large), $(L/2)\mathrm{Var}_\infty|_{\eta_T}=(1/(4(1-\beta)))\sigma D/\sqrt T(1+O(\eta_T L))$. Hence $\mathbb E[f(x_T)-f^\star]=\Theta(LD^2/T)+\Theta(\sigma D/(\sqrt T(1-\beta)))$.
- **Quantifiers:** $\forall T$ large (so $\eta_T L<2(1+\beta)$), at the specific stepsize $\eta=\eta_T$.
- **Hypotheses:** $T$ large enough that $\eta_T L<2(1+\beta)$, i.e., $T>(\sigma/(D\cdot 2(1+\beta)L))^2\cdot L^2 =\sigma^2/(4D^2(1+\beta)^2)$. Listed implicitly ("well-defined for $T$ large enough").
- **Conclusion precision:** $\Theta$ on both terms; matches OP-2 LB **up to $\beta$-polynomial** $1/(1-\beta)$, as the summary correctly notes via Issue B.
- **Status:** **VALID.** The text correctly distinguishes "matches in rate" from "matches exactly" — Issue B is fully propagated within this document.

### Theorem A.3 (compatibility with OP-2), §3
- **Statement:** OP-2 LB and noise-floor refutation are complementary. The OP-2 witness $f^{(T)}$ is $T$-dependent ($\forall T\,\exists f^{(T)}$); Route F's quadratic refutation is $T$-independent ($\exists f\,\forall(\beta,\eta)$).
- **Quantifiers:** Carefully distinguished: OP-2 is $\forall T\,\exists f^{(T)}$; Route F is $\exists f\,\forall(\beta,\eta)$.
- **Hypotheses:** stability for Route F.
- **Conclusion precision:** $\sup\{\text{OP-2 LB at }T,\ c_F\}$.
- **Status:** **VALID.** The quantifier discussion is precise and important.

### Theorem D (online-to-batch projected SHB), §5
- **Statement:** $\mathbb E[f(\Pi(x_T))-f^\star]\le O\bigl(LD^2\log T/(T(1-\beta))+\sigma D\sqrt{\log T}/\sqrt{T(1-\beta)}\bigr)$.
- **Quantifiers:** $\forall T$, given horizon-tuned $\eta=\tilde\Theta((1-\beta)/\sqrt T)$, projection $\Pi$ onto bounded domain of diameter $D$.
- **Hypotheses:** $f$ $L$-smooth convex, projection $\Pi$, horizon-tuned $\eta$, $\beta\in[0,1)$. The Abel-summation argument for $\beta\ge 1/\sqrt 2$ is provided explicitly.
- **Conclusion precision:** $O$.
- **Status:** **VALID.** The Abel-summation step (lines 161-165) closes the previously-flagged Lemma 2 gap.

### Theorem (final consolidated), §8
- **Status:** **VALID.** Three-part theorem (negative + projected positive + minimax tightness), each correctly stated.

### Lemma 2 (cross-term sum bound), §5
- **Status:** **VALID** with explicit Abel summation now provided.

---

## Part 5. Specific known issues (A–E) — verification table

| # | Issue | OP-2 v4 | summary.md | direction_1 | direction_2 |
|---|-------|---------|------------|-------------|-------------|
| **A** | $\forall T\ge 1$ with $\kappa/8$ fails at $T\in\{1..9\}$ | n/a (OP-2 uses $\kappa/4$, not zero-momentum) | **CORRECTLY FLAGGED** in WARNING + boxed shows "$\forall T\ge T_0\approx 10$" | **NOT propagated** — §0 (line 17), L5 (line 184), §9 boxed (line 266) all still write "$\forall T\ge 1$" with $\kappa/8$ | n/a |
| **B** | minimax-$\eta$ matches in rate, not constant | n/a | **CORRECTLY FLAGGED** | n/a | **VALID** — Theorem A.2 explicitly notes "up to $\beta$-polynomial constant $1/(1-\beta)$" |
| **C** | period-2 → period-6 / period-2 mod $C_3$ | n/a | **CORRECTLY FLAGGED** | **NOT propagated** — §7 still uses "Period-2" in table (line 215, 218), header (line 209, 211) | n/a |
| **D** | bias floor 0.37 µD² → ~2.22 µD² (units error) | n/a | **CORRECTLY FLAGGED** | **NOT propagated** — §7 line 224 still has "$\geq 2\mu\approx 0.37\mu D^2$"; §9 line 271 "$\ge 0.37\mu D^2$" | n/a |
| **E** | "19% measure" → 17/19 are period-4 (not period-2/-6) | n/a | **CORRECTLY FLAGGED** | Implicit (line 213-218 only lists 2 anchors) — but the §7 wording "providing a positive-measure complementary region" relies on the 19% measure that has been refuted; the **claim that L7's anchors $(0.9,3.78,0.05)$ and $(0.95,3.85,0.10)$ extend by continuity to a positive-measure subset** is still asserted (line 230-231) but no quantitative measure is given. **PARTIAL propagation** — qualitative claim survives, quantitative "19%" claim must not be re-introduced. | n/a |

---

## Part 6. Summary issue table and verdict

| Claim | File | Status | Severity | Required fix |
|---|---|---|---|---|
| Theorem (Main) §0.5 | OP-2 v4 | VALID | — | — |
| Lemmas 1.1–1.7 | OP-2 v4 | VALID | — | — |
| Claims 2.1–2.13, Lemmas 2.6/2.7/2.9 | OP-2 v4 | VALID | — | — |
| Remark 4.1.1 (NAG) | OP-2 v4 | VALID | — | — |
| Direction 1 main Theorem (§0, §9 boxed) | direction_1 | NEEDS_CORRECTION | HIGH | Replace "$\forall T\ge 1$" → "$\forall T\ge T_0(\beta,\eta)\approx 10$" OR downgrade $\kappa/8\to\kappa/10$ (κ/9 marginal at $T=4$). Update L5 §5 absorption argument accordingly |
| Theorem 5.1 §1 | direction_1 | VALID | — | — |
| Lemma L1 §1 | direction_1 | VALID | — | — |
| Lemma L2 §2 | direction_1 | VALID | — | — |
| Lemma L3 §3 | direction_1 | NEEDS_CORRECTION | LOW | Add explicit hypothesis: under-damped regime $(1+\beta-\eta\mu)^2<4\beta$ |
| Lemma L4 §4 | direction_1 | VALID | — | — |
| Lemma L5 §5 | direction_1 | NEEDS_CORRECTION | HIGH | See main theorem fix above |
| Lemma L6 §6 | direction_1 | VALID | — | — |
| Lemma L7 §7 | direction_1 | NEEDS_CORRECTION | MEDIUM ×2 | Replace "Period-2" → "Period-6 in iterate (period-2 mod $C_3$)" throughout (Issue C); replace floor "$\ge 0.37\mu D^2$" → "$\ge 2.22\mu D^2$ (anchor 1), $\ge 3.44\mu D^2$ (anchor 2)" (Issue D) |
| Lemma L8 §8 | direction_1 | VALID | — | — |
| §9 "Honest scope" | direction_1 | NEEDS_CORRECTION | MEDIUM | Same as L7 — replace "$\ge 0.37\mu D^2$" |
| Theorem A.1 §1 | direction_2 | VALID | — | — |
| Theorem A.2 §2 | direction_2 | VALID | — | — |
| Theorem A.3 §3 | direction_2 | VALID | — | — |
| Theorem D §5 | direction_2 | VALID | — | — |
| Theorem (final) §8 | direction_2 | VALID | — | — |
| Direction 1 boxed claim | summary.md | VALID | — | (already correctly flagged in WARNING) |
| Issues A–E flags | summary.md | VALID | — | — |

---

## Final verdict

**OP-2 v4 (`op2_downgraded_proof_v4.md`):** All 16 audited claims pass. The constants ($\kappa/4$, $\sqrt 2/27$), the regime hypothesis (RGM), and the under-damped-style hypotheses where used are all explicitly stated. The $\forall T\,\exists f^{(T)}$ quantifier order is correct and explicitly defended in §0.6 and §3 (Theorem A.3 of `direction_2`). **READY FOR PEER REVIEW.**

**`summary.md`:** WARNING block correctly flags all five known issues. Recommendation: add a one-line note next to the Direction 1 boxed bound that the WARNING applies. **READY FOR PEER REVIEW** (with the note suggestion).

**`direction_1_zero_momentum.md`:** **NOT READY** — three propagation failures:
1. **Issue A (HIGH):** The boxed bound at §0 and §9 still claims "$\forall T\ge 1$" with $\kappa/8$, despite the re-audit's refutation at $T=4$. Required fix: revise to either "$T\ge T_0\approx 10$" or downgrade to $\kappa/10$ (note: $\kappa/9$ is marginal at $T=4$ since $0.113$ vs $1/9\approx 0.111$, so $\kappa/10$ is the safer downgrade). The L5 transient argument (§5) must be revised to match.
2. **Issue C (MEDIUM):** §7 L7 still uses "Period-2" terminology; must be replaced with "Period-6 in iterate (period-2 modulo $C_3$ rotation)".
3. **Issue D (MEDIUM):** §7 line 224 and §9 line 271 still report floor "$\ge 0.37\mu D^2$"; must be updated to the correct $\ge 2.22\mu D^2$ (anchor 1) / $\ge 3.44\mu D^2$ (anchor 2). Plus a low-severity Issue: L3 should make the under-damped hypothesis explicit.

**`direction_2_last_iterate_ub.md`:** All 6 audited claims pass. Issue B is correctly propagated within this document (Theorem A.2 explicitly states the $\beta$-polynomial gap). **READY FOR PEER REVIEW.**

**Aggregate:** OP-2 v4 + summary.md + direction_2 are peer-review-ready. **direction_1_zero_momentum.md requires three corrections (1 HIGH, 2 MEDIUM, 1 LOW)** before submission. The corrections are localized text edits — no proof rewriting required, except for the L5 transient argument (Issue A) which must either tighten its $T_0$ claim or downgrade the constant in a way consistent with the re-audit's $T=4$ counterexample.

**Word count:** ~2700 words.
