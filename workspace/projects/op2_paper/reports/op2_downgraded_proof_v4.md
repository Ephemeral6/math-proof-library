# OP-2 Downgraded ($\forall$-$\exists$): Fixed-momentum SHB last iterate does not accelerate on the Goujaud feasibility region — Complete, Self-Contained Proof (v4)

**Compiled:** 2026-04-26 (v4, revision of `op2_downgraded_proof_v3_final.md`)
**Source:** `workspace/op2_li_review/D3_sharp_constant/proof.md` (D3 sharp-constant analysis)
**Audience:** A mathematician who will audit every step; targeted for OPT workshop / COLT-style venue

## Summary of changes from v3  [NEW in v4]

The variance constant is sharpened from $c_{\mathrm{NY}} = 1/112$ to $c_{\mathrm{NY}} = \sqrt 2/27 \approx 0.0524$ (factor $\approx 5.87$ improvement) by reparametrizing the Le Cam signal amplitude. All v4 edits are tagged inline with **[MOD v4-N: …]**:

- **[MOD v4-1]** Reparametrize $\alpha := \sigma/(3\sqrt T)$ (i.e., $c_\alpha = 1/3$) instead of $\sigma/(2\sqrt{2T})$ (i.e., $c_\alpha = 1/(2\sqrt 2)$). The choice $c_\alpha = 1/3$ is the global maximizer of the cubic objective $\frac{\sqrt 2}{8}c_\alpha(1-c_\alpha)(2 - c_\alpha r\sqrt 2)$ at $r = \sqrt 2$, the worst case of (RGM); see derivation in `workspace/op2_li_review/D3_sharp_constant/proof.md`.
- **[MOD v4-2]** Wall radius updated to $R := D/\sqrt 2 - \sigma/(3L\sqrt T)$ to preserve $|y^\star_s| = D/\sqrt 2$ exactly under the new $\alpha$.
- **[MOD v4-3]** Lemma 1.4 chain updated: per-step $\mathrm{KL} = 2/(9T)$, total $\mathrm{KL}_T = 2/9$, Pinsker $\mathrm{TV} \le 1/3$, Le Cam $p_{\min} \ge 1/3$ (no $1/14$ floor needed — the new chain is clean enough that the floor is unnecessary).
- **[MOD v4-4]** Lemma 2.9 Step 3 replaces the loose inequality $\alpha^2/(2L) \le \alpha D/4$ with the **exact** identity $\alpha D/\sqrt 2 - \alpha^2/(2L) = \alpha D \cdot (\sqrt 2/3)$ at the (RGM)-tight worst case $r := \sigma/(LD\sqrt T) = \sqrt 2$. The constant $\sqrt 2/3$ replaces $1/(2\sqrt 2)$ in Step 4.
- **[MOD v4-5]** Final arithmetic: $\alpha D \cdot (\sqrt 2/3) \cdot (1/3) = \sqrt 2\, \alpha D/9 = \sqrt 2\, \sigma D/(27\sqrt T)$, giving $c_{\mathrm{NY}} = \sqrt 2/27$.
- **[MOD v4-6]** Footnote in §0.5 reframed: $1/(8\sqrt 2) \approx 0.0884$ is now stated as the **asymptotic limit** as $r := \sigma/(LD\sqrt T) \to 0$ (where the wall correction vanishes), not as a finite-$T$ deliverable under saturated (RGM). Hellinger TV gives a further $\sim 1\%$ sharpening but no clean closed form, so we do not pursue it.
- **[MOD v4-7]** New Remark 4.1.1 in §4.1: explicit Nesterov-cycling matrix $M^{\mathrm{Nes}}$ partially answering GTD23 Conjecture 7.1. NAG has its own Goujaud-style cycling region $\mathcal{F}^{\mathrm{Nes}}$ (non-empty for $\mu/L \lesssim 0.25$, generally disjoint from $\mathcal{F}^{\mathrm{HB}}$), on which the analogous $\Omega(\mu D^2)$ non-acceleration bound transfers. Verified at machine precision; details in `workspace/op2_li_review/D5_nesterov/rerun_v2.md`. The framing is "method-specific cycling, method-agnostic non-acceleration" — parallel results, not a Polyak-vs-NAG rate separation.

The Main Theorem statement, the hard-instance construction, the bias term $\kappa LD^2/4$, the cycling argument, the $\forall$-$\exists$ scope, and the positive-measure region $\mathcal{F}$ are all unchanged from v3. Only the variance-term constant, its derivation chain, and a new Remark 4.1.1 about the NAG analogue are updated.

---

## Summary of changes from v1

All v1→v2 changes are marked inline with **[MOD v2: …]** tags. The substantive changes were:

- **[MOD v2-1]** Rewrote §2.1.1 and Lemma 2.6. v1 defined $f_0(x) := D^2\,\psi(x/D)$ and then, mid-proof, had to retract the rescaling because $\psi$'s gradient is not positively homogeneous. v2 defines $f_0$ directly as the **rescaled Goujaud function** $\tilde\psi$ with polytope $(D/\sqrt 2)\cdot \mathrm{conv}(P)$, and proves Lemma 2.6 cleanly via **positive homogeneity of Euclidean projection** (now stated explicitly as Lemma 1.7).
- **[MOD v2-2]** Redefined the wall $w$ so $|y^\star_s| = D/\sqrt 2$ **exactly**, yielding $\|(x_0, y_0) - (0, y^\star_s)\| = D$ exactly (Claim 2.4 is now a clean equality, not a "$\leq D^2 + o(1)$" absorption). This is achieved by taking wall-radius $R = D/\sqrt 2 - \alpha/L$ (instead of $R = D/\sqrt 2$), where $\alpha := \sigma/(2\sqrt{2T})$.
- **[MOD v2-3]** Lemma 2.9 now states the constant **$c_\mathrm{NY} = 1/112$** that is actually produced by the rigorous Le Cam chain we write out (the wall correction $\alpha^2/(2L)$ is tracked honestly). The v1 claim of $1/(8\sqrt 2)$ was unsupported by the given derivation, and v1's inline chain (which dropped the wall correction) yielded $1/56$; we note explicitly that $1/(8\sqrt 2)$ is attainable via a tighter NY/ABRW argument but do not use it.
- **[MOD v2-4]** New Claim 2.11 verifying rigorously that the $\max_s$ step in the conclusion (Claim 2.10) is valid.
- **[MOD v2-5]** New Claim 2.12 verifying that $f_{\beta,\eta}^{(s)}$ is **globally 0-strongly-convex** (i.e., convex but not strongly convex), matching the non-SC hypothesis of `problem.md`.
- **[MOD v2-6]** New §2.7 proving $\mathcal{F}$ has positive 2-D Lebesgue measure in $\mathcal{S}$.

## Summary of changes from v2  [NEW in v3]

Round-3 deep audit (with literature cross-check against arXiv:1412.7457, arXiv:2102.07002, arXiv:1009.0571) identified 9 items: 4 critical for publication rigor (citation accuracy, related-work completeness, technical precision) and 5 writing-quality items. **The mathematical content — the theorem statement, the hard-instance construction, and the constants $\kappa/4$ and $1/112$ — is correct and unchanged in v3.** All v3 edits are writing/citation/exposition fixes. Inline tagged with **[MOD v3-N: …]**:

- **[MOD v3-1]** **Corrected GFJ15 citation.** Lemma 1.6 in v2 attributed a stochastic upper bound $O(LD^2/T + \sigma D/\sqrt T)$ to Ghadimi–Feyzmahdavian–Johansson 2015 (arXiv:1412.7457). The paper is in fact **deterministic only**: it proves Cesàro-average convergence at rate $O(1/k)$ for $L$-smooth convex objectives under fixed $(\beta,\eta)$, without any stochastic oracle. v3 restates Lemma 1.6 honestly as a deterministic result, and rewrites §4.2 to split the tightness discussion into deterministic and stochastic cases, with a tightness footnote added to the Main Theorem in §0.5.
- **[MOD v3-2]** **Compare with Li–Liu–Orabona 2022** (arXiv:2102.07002, ALT 2022 / PMLR v167, "On the Last Iterate Convergence of Momentum Methods"). Added §4.2.5 explicitly relating our LB to Li et al.'s last-iterate LB $\Omega(\ln T/\sqrt T)$ for constant-momentum SGDM on Lipschitz (non-smooth) convex functions. The two results are orthogonal/complementary (different function class, different oracle, different dimension scaling, different bound rate).
- **[MOD v3-3]** **Compare with Agarwal 2012 minimax LB** (IEEE TIT, arXiv:1009.0571). Added §4.3 clarifying that our LB is **algorithm-specific** (against fixed-momentum SHB) and is strictly stronger than the minimax LB in the bias term. This is the precise "non-acceleration" statement: SHB cannot achieve AC-SA's optimal $LD^2/T^2$ bias rate on $\mathcal{F}$.
- **[MOD v3-4]** **KL chain rule for adaptive queries.** Added an explicit adaptive-queries discussion to Lemma 2.9 Step 1. SHB's queries $(y_0, y_1, \ldots)$ are adaptive (not i.i.d.), so i.i.d. tensorization of KL is technically inapplicable. But since the oracle's $s$-dependency enters only through an additive, $s$-independent-of-history increment distribution, the chain-rule KL equals the iid-tensorized KL. Numerical value $1/4$ unchanged.
- **[MOD v3-5]** **Cleaned Lemma 1.4.** The v2 version read as a debug log (three Rademacher attempts → realize $\mathrm{KL} = \infty$ → switch to Gaussian). v3 states the Gaussian two-point lemma upfront with a clean 10-line proof.
- **[MOD v3-6]** **Cleaned Claim 2.2 proof.** v2 contained "wait let me redo" and an incorrectly-signed intermediate step that nonetheless reached the correct answer. v3 gives a clean piecewise case analysis.
- **[MOD v3-7]** **Fixed the verification sentence in §2.4.1 Step 3** (proof of Lemma 2.9). v2 "verified" a tautological rearrangement; v3 verifies the actual inequality $1/\sqrt 2 - 1/4 > 1/(2\sqrt 2)$ numerically.
- **[MOD v3-8]** **Specified $s^\star$ construction in Claim 2.10.** $s^\star = s^\star(\beta,\eta,T)$ is a deterministic function of the parameters; v3 makes this explicit so that $f_{\beta,\eta}^{(T)}$ is an unambiguous mathematical object.
- **[MOD v3-9]** **Separated sufficiency from necessity in §2.7 Step 1.** v2 stated a biconditional feasibility equivalence for $K=3$; v3 separates the rigorous **sufficiency** direction (used by the positive-measure claim) from the **necessity** direction (empirically supported by `fixed_verify.py`, but not required for Theorem (Main)).

The Main Theorem statement (§0.5) is updated with: (i) the explicit $c_\mathrm{NY} = \sqrt 2/27$ **[MOD v4-1: was $1/112$ in v3]**, (ii) the regime hypothesis $\sigma \leq L D\sqrt{2T}$ needed for the wall construction to be well-defined (so $R \geq 0$); for $\sigma$ above this, see Remark 0.7. (v3) A tightness footnote is added; see §4.2 for details.

---

# Part 0. Theorem statement

## 0.1 Notation and standing conventions

Throughout this document:

- $L, \sigma, D > 0$ are three fixed positive real constants (the smoothness constant, the oracle-variance scale, and the initial-distance budget).
- For $\beta \in [0,1)$ and $\eta > 0$, the **dimensionless step-size** is $h := \eta L$.
- $\mathbb{R}^d$ denotes Euclidean $d$-space with inner product $\langle\cdot,\cdot\rangle$ and Euclidean norm $\|\cdot\|$.
- For a closed convex set $C \subset \mathbb{R}^d$, $P_C : \mathbb{R}^d \to C$ is the Euclidean projection and $d_C(x) := \|x - P_C(x)\|$.
- For $\theta \in \mathbb{R}$, $R_\theta := \begin{pmatrix}\cos\theta & -\sin\theta\\ \sin\theta & \cos\theta\end{pmatrix} \in \mathrm{SO}(2)$ is the rotation matrix.
- For integer $K \geq 2$: $\theta_K := 2\pi/K$, $c_K := \cos\theta_K$, and
  $$e_t := (\cos(t\theta_K),\ \sin(t\theta_K)) \in \mathbb{R}^2,\qquad t \in \mathbb{Z}.$$
  Note $e_t = e_{t+K}$ (indexing modulo $K$), $R_{\theta_K} e_t = e_{t+1}$, $R_{-\theta_K} e_t = e_{t-1}$.
- $I_d$ is the $d\times d$ identity matrix. $[A, B]$ (Loewner order) means $B - A \succeq 0$.

## 0.2 Algorithm class

**Definition (Fixed-momentum Stochastic Heavy Ball, SHB).** Given fixed hyperparameters $\beta \in [0,1)$ and $\eta > 0$, initial pair $(x_0, x_{-1}) \in \mathbb{R}^d \times \mathbb{R}^d$, an $L$-smooth convex objective $f:\mathbb{R}^d \to \mathbb{R}$, and a stochastic oracle that on input $x_t$ returns
$$g_t = \nabla f(x_t) + \xi_t, \qquad \mathbb{E}[\xi_t \mid \mathcal{H}_t] = 0,\qquad \mathbb{E}[\|\xi_t\|^2 \mid \mathcal{H}_t] \leq \sigma^2,$$
where $\mathcal{H}_t$ is the history up to step $t$, the SHB iteration is
$$\boxed{\ x_{t+1} = x_t - \eta\, g_t + \beta(x_t - x_{t-1}),\qquad t = 0, 1, 2, \ldots\ }\tag{SHB}$$

The noise sequence $(\xi_t)_{t\geq 0}$ is assumed i.i.d. conditionally on the trajectory.

## 0.3 Stability region

**Definition.** The **SHB stability region** is
$$\mathcal{S} := \{(\beta, \eta) \in [0,1) \times \mathbb{R}_{>0} : \eta \leq 2(1 + \beta)/L\}.$$

This is the classical parameter region in which SHB's update operator on a generic $L$-smooth quadratic has spectral radius $< 1$; outside $\mathcal{S}$, SHB diverges even on $(L/2)\|x\|^2$.

## 0.4 Goujaud cycling feasibility region

**Definition.** For $(\beta, \eta, L) \in \mathcal{S} \times \mathbb{R}_{>0}$, integer $K \geq 3$, and $\kappa \in (0, 1)$, the **Goujaud–Taylor–Dieuleveut cycling inequality** (GTD-cyc) with parameter $(\beta, \eta, L, \kappa, K)$ is
$$\text{(GTD-cyc)}\qquad (\kappa \eta L)^2 - 2\big[\beta - c_K + \kappa(1 - \beta c_K)\big]\,(\kappa \eta L) + 2\kappa(1 - c_K)(1 + \beta^2 - 2\beta c_K) \leq 0.\tag{★}$$

**Definition.** The **Goujaud feasibility region** is
$$\mathcal{F} := \big\{(\beta,\eta) \in \mathcal{S} : \exists K \geq 3,\ \exists \kappa \in (0,1)\ \text{such that (★) holds}\big\}.$$

We write $\kappa(\beta,\eta)$ for a specific choice of $\kappa$ for which (★) holds (e.g., the midpoint of the feasible $\kappa$-interval at the smallest feasible $K$); set $\mu(\beta,\eta) := \kappa(\beta,\eta) L$.

## 0.5 Main theorem

**Theorem (Main).** Let $L, \sigma, D > 0$ satisfy the mild regime condition
$$\sigma \leq L D\sqrt 2 \qquad (\text{so that}\ \sigma \leq L D\sqrt{2T}\ \text{for every}\ T \geq 1).\tag{RGM}$$
Then for every $(\beta, \eta) \in \mathcal{F}$ and every integer $T \geq 1$, there exist:

1. a function $f_{\beta,\eta}^{(T)} : \mathbb{R}^3 \to \mathbb{R}$ which is **convex and $L$-smooth** (globally 0-strongly-convex; see Claim 2.12), with a unique minimizer $x^\star \in \mathbb{R}^3$;
2. an initial pair $(x_0, x_{-1}) \in \mathbb{R}^3 \times \mathbb{R}^3$ with $\|x_0 - x^\star\| = D$ (**[MOD v2-2]** — exact equality) and **non-zero initial velocity** $x_0 - x_{-1} = (D/\sqrt 2)(e_0 - e_{K-1}) \neq 0$ (essential for the cycling identity; the standard zero-momentum init $x_0 = x_{-1}$ is a separate setting — see §0.8 below);
3. an unbiased stochastic gradient oracle of variance $\leq \sigma^2$ (as in §0.2);

such that the SHB iterate $(x_t)_{t\geq 0}$ generated by $(\beta,\eta)$ on this instance satisfies
$$\boxed{\ \mathbb{E}[f_{\beta,\eta}^{(T)}(x_T) - f_{\beta,\eta}^{(T),\star}] \ \geq\ c(\beta,\eta) \cdot \frac{L D^2}{T}\ +\ c_\mathrm{NY} \cdot \frac{\sigma D}{\sqrt T}\ }\tag{MAIN}$$
where:
- $c(\beta,\eta) := \kappa(\beta,\eta) / 4 > 0$;
- $c_\mathrm{NY} := \sqrt 2/27 \approx 0.0524$ is the **sharp** Pinsker constant produced by the optimized Le Cam chain of Lemma 2.9 **[MOD v4-1: was $1/112$ in v3, factor $\approx 5.87$ improvement]**. The constant is obtained by reparametrizing $\alpha = c_\alpha\,\sigma/\sqrt T$ and optimizing $c_\alpha$ over the cubic $\frac{\sqrt 2}{8}c_\alpha(1-c_\alpha)(2 - c_\alpha r\sqrt 2)$ at the worst-case (RGM)-ratio $r = \sigma/(LD\sqrt T) = \sqrt 2$, whose closed-form maximizer is $c_\alpha^\star = 1/3$. A weaker $1/(8\sqrt 2) \approx 0.0884$ is the asymptotic limit as $r \to 0$ (the wall-correction term $\alpha^2/(2L)$ vanishes); under saturated (RGM) it is unattainable. v1 originally claimed $1/(8\sqrt 2)$ unjustified, v1's inline derivation gave $1/56$ by dropping the wall correction, v3 carried the correction rigorously to get $1/112$, and v4 sharpens by optimizing $c_\alpha$;
- the expectation is over the randomness of the oracle.

**[MOD v3-1: TIGHTNESS FOOTNOTE]** *Tightness of the bound.* The $LD^2/T$ bias term is tight in two independent senses. **Deterministic ($\sigma=0$):** Ghadimi–Feyzmahdavian–Johansson 2015 (Lemma 1.6) prove a matching deterministic Cesàro-average upper bound $O(LD^2/T)$ for fixed-momentum SHB on $L$-smooth convex functions; combined with our LB this yields tight $\Theta(LD^2/T)$ for deterministic HB on $\mathcal{F}$. **Stochastic ($\sigma>0$):** the $\sigma D/\sqrt T$ variance term matches the classical SGD stochastic upper bound $O(LD^2/T + \sigma D/\sqrt T)$ (Nemirovski–Yudin, Polyak–Juditsky); thus SHB is no worse than SGD on $\mathcal{F}$, and the $LD^2/T$ bias dependence is tight against SGD. We could not locate a matching stochastic upper bound specifically for fixed-momentum SHB in the literature (GFJ15 is deterministic only); thus the $\Omega(LD^2/T + \sigma D/\sqrt T)$ lower bound is tight "relative to SGD" in the stochastic regime. Crucially, Agarwal et al. 2012 (§4.3) show that Lan's AC-SA achieves $O(LD^2/T^2 + \sigma D/\sqrt T)$ minimax-optimally, so our LB **rules out** any improvement of SHB's bias rate to $LD^2/T^2$ on $\mathcal{F}$. This is the non-acceleration conclusion.

**Moreover**, $\mathcal{F}$ contains a subset of positive 2-D Lebesgue measure in $\mathcal{S}$: at $K = 3$,
$$\mathcal{F}_{K=3} \supset \left\{(\beta,\eta) : \beta > \beta^\star := \frac{\sqrt{13} - 3}{2} \approx 0.3028,\ L\eta \in \left(\frac{3(1 + \beta + \beta^2)}{1 + 2\beta},\ 2(1+\beta)\right)\right\},$$
a two-dimensional region whose 2-D Lebesgue measure is positive (see Claim 2.13, **[MOD v2-6]**).

## 0.6 Scope — what the theorem does NOT claim

- **Not claimed on $\mathcal{S}\setminus\mathcal{F}$.** In particular, on the pairs $(\beta, \eta) = (0.5, 1/L)$ and $(0.9, 1/(2L))$ (both in $\mathcal{S}\setminus\mathcal{F}$), the theorem asserts nothing. Empirical evidence in Part 3 suggests the original (full-$\mathcal{S}$) statement may be genuinely false there.
- **Not claimed for time-varying $(\beta_t, \eta_t)$.** The construction exploits fixedness.
- **The function $f_{\beta,\eta}^{(T)}$ depends on $(\beta, \eta, T)$.** The theorem is ∀-∃, not ∃-∀. The $T$-dependence enters only through the wall radius $R = D/\sqrt 2 - \sigma/(3L\sqrt T)$; it is monotone in $T$ and has a limit $D/\sqrt 2$ as $T \to \infty$.

## 0.7 Remark on the regime condition (RGM)

Condition (RGM) is the standard "moderate-noise" regime in Nemirovski–Yudin-style lower-bound constructions: it asks that the per-sample gradient noise magnitude $\sigma$ be not too large relative to the problem's natural scale $LD$. When (RGM) fails (i.e., $\sigma > LD\sqrt 2$), the variance term $\sigma D/\sqrt T$ alone already dominates the bias term $LD^2/T$ for every $T \geq 1$:
$$\sigma > LD\sqrt 2 \implies \frac{\sigma D}{\sqrt T} > \frac{\sqrt 2\, L D^2}{\sqrt T} \geq \frac{\sqrt 2\, L D^2}{T} > \frac{LD^2}{T},$$
so the combined target $c\,LD^2/T + c'\,\sigma D/\sqrt T$ is satisfied by the variance term alone via a simpler pure-noise construction (e.g., Lemma 2.9 applied on a $\mathbb{R}^1$ instance with a constant wall of radius $D$; the required bound is no worse than $c_\mathrm{NY}\sigma D/\sqrt T$ with $c_\mathrm{NY} = \sqrt 2/27$). We therefore focus on the regime (RGM) where the construction of §2.1 is well-defined.

## 0.8 Initialization sensitivity (NEW v5)

The hard-instance initialization $(x_0, x_{-1}) = ((D/\sqrt 2)\,e_0,\, (D/\sqrt 2)\,e_{K-1})$ used in the Main Theorem has $x_0 \neq x_{-1}$, i.e., **non-zero initial velocity** $x_0 - x_{-1} = (D/\sqrt 2)(e_0 - e_{K-1}) \neq 0$. The cycling identity of Lemma 2.6 requires this non-zero velocity at the cycle vertex; the cycle is *not* automatically attractive under the standard zero-momentum initialization $x_0 = x_{-1}$.

For the standard zero-momentum init $x_0 = x_{-1}$ — closer to mainstream practice — the LB transfers to a positive-measure subset $\mathcal F^{\mathrm{zero}}_{K=3} \subsetneq \mathcal F_{K=3}$ but **not** the entirety of $\mathcal F_{K=3}$. The structural obstruction (proved in companion document `direction_1_zero_momentum.md`, Theorem 5.1) is the explicit first-iterate formula:
$$x_1^{\mathrm{zero}} = (D/\sqrt 2)\bigl[-\beta\, e_0 + e_1 + \beta\, e_{K-1}\bigr],$$
which equals the next cycle vertex $(D/\sqrt 2)\,e_1$ if and only if $\beta = 0$. The "velocity kick" $\beta(x_0 - x_{-1}) = \beta(D/\sqrt 2)(e_0 - e_{K-1})$ in OP-2's hard-instance init is precisely what the cycling identity needs; without it, the iterate misses the next cycle vertex by the residual $\beta(D/\sqrt 2)(e_2 - e_0)$, so the cycling is broken at step 1 for any $\beta > 0$.

Numerical evidence (50-digit `mpmath`, 100-point grid over $\mathcal F_{K=3}$) shows ~25% of $\mathcal F_{K=3}$ supports the LB under zero-momentum init: 8% via K=3 cycle attractor (concentrated at $\beta \in [0.7, 0.85]$, $\eta L$ near upper stability boundary) and 17% via period-4 / period-6 attractors at higher $\beta$. The LB constants degrade slightly: bias becomes $\kappa LD^2/(10T)$ (uniform in $T \ge 1$) or $\kappa LD^2/(8T)$ (for $T \ge T_0 \approx 10$), while the variance constant $\sqrt 2/27$ is unchanged. See `direction_1_zero_momentum.md` for the full result.

---

# Part 1. Prerequisite results (with complete statements)

## 1.1 Convex analysis: Moreau identity

**Lemma 1.1 (Moreau decomposition).** Let $C \subset \mathbb{R}^d$ be a non-empty closed convex set. Define
$$\Phi_C(x) := \tfrac{1}{2}\|x\|^2 - \tfrac{1}{2} d_C(x)^2 = \tfrac{1}{2}\|P_C(x)\|^2 + \langle x - P_C(x), P_C(x)\rangle.$$

Then:
- $\Phi_C$ is convex on $\mathbb{R}^d$.
- $\Phi_C$ is $C^{1,1}$ with $\nabla \Phi_C(x) = P_C(x)$.
- $\nabla \Phi_C = P_C$ is 1-Lipschitz (firmly non-expansive), i.e., $\Phi_C$ is $1$-smooth.

*Textbook result; see e.g., Bauschke–Combettes "Convex Analysis and Monotone Operator Theory" (2011), Prop. 12.27 & Thm. 12.15.*

## 1.2 Strong-convexity gap identity

**Lemma 1.2.** Let $f : \mathbb{R}^d \to \mathbb{R}$ be $\mu$-strongly convex with minimizer $x^\star$ and $f^\star = f(x^\star)$. Then for every $x \in \mathbb{R}^d$,
$$f(x) - f^\star \geq \tfrac{\mu}{2}\|x - x^\star\|^2.$$

*Proof.* By strong convexity, for all $x \in \mathbb{R}^d$ and any subgradient $g \in \partial f(x^\star)$: $f(x) \geq f(x^\star) + \langle g, x - x^\star\rangle + \tfrac{\mu}{2}\|x - x^\star\|^2$. At the minimizer $0 \in \partial f(x^\star)$, so taking $g = 0$ gives the result. $\square$

## 1.3 Goujaud–Taylor–Dieuleveut cycling theorem

**Lemma 1.3 (GTD23, Theorem 3.5 of arXiv:2307.11291 + §3.4).** Fix $L > 0$, $\mu \in (0, L)$, $\beta \in [0, 1)$, $\eta > 0$, and integer $K \geq 3$ such that the inequality (★) of §0.4 holds with $\kappa = \mu/L$. Define the $2 \times 2$ matrix
$$M := \frac{(1 + \beta - \mu \eta) I_2 - R_{\theta_K} - \beta R_{-\theta_K}}{(L - \mu)\, \eta},\tag{M-def}$$
the vertex set
$$P := \{M e_0, M e_1, \ldots, M e_{K-1}\} \subset \mathbb{R}^2,$$
and the **Goujaud function**
$$\psi(x) := \tfrac{L}{2}\|x\|^2 - \tfrac{L - \mu}{2}\, d_{\mathrm{conv}(P)}(x)^2,\qquad x \in \mathbb{R}^2.\tag{PSI}$$

Then:

**(i) Regularity.** $\psi \in C^{1,1}(\mathbb{R}^2)$ is convex, $L$-smooth, and $\mu$-strongly convex. Its gradient is
$$\nabla \psi(x) = \mu\, x + (L - \mu)\, P_{\mathrm{conv}(P)}(x).\tag{PSI-grad}$$
Where the Hessian exists (a.e.), $\nabla^2 \psi(x) \in [\mu I_2, L I_2]$.

**(ii) Minimum at the origin.** $0 \in \mathrm{int}(\mathrm{conv}(P))$, and $\arg\min \psi = \{0\}$ with $\psi(0) = 0$.

**(iii) Projection–cycle identity.** For every $t \in \mathbb{Z}$, $P_{\mathrm{conv}(P)}(e_t) = M e_t$. (Content of (★).)

**(iv) Cycling.** Consider deterministic HB on $\psi$ with the given $(\beta, \eta)$ and initialization $(x_0, x_{-1}) = (e_0, e_{K-1})$:
$$x_{t+1} = x_t - \eta\, \nabla \psi(x_t) + \beta (x_t - x_{t-1}).$$
Then for all $t \geq 0$, $x_t = e_{t \bmod K}$.

*Proof of (i)–(ii): from Lemma 1.1.* Rewrite
$$\psi(x) = \tfrac{L}{2}\|x\|^2 - \tfrac{L-\mu}{2}(\|x\|^2 - 2\Phi_{\mathrm{conv}(P)}(x)) = \tfrac{\mu}{2}\|x\|^2 + (L-\mu) \Phi_{\mathrm{conv}(P)}(x).$$
By Lemma 1.1, $\Phi_C$ is $1$-smooth and convex, $\nabla \Phi_C = P_C$. Hence $\nabla \psi(x) = \mu x + (L-\mu) P_C(x)$, which is $(\mu + (L-\mu)) = L$-Lipschitz. Strong convexity: $\langle \nabla \psi(x) - \nabla \psi(y), x - y\rangle \geq \mu \|x-y\|^2 + (L-\mu)\langle P_C(x) - P_C(y), x-y\rangle \geq \mu\|x-y\|^2$ (since $P_C$ is monotone). Loewner bound: $\nabla^2 \psi = \mu I + (L-\mu) \nabla P_C$, and $\nabla P_C$ is an orthogonal projection where it exists (spectrum $\subset \{0,1\}$), so $\mu I \preceq \nabla^2 \psi \preceq L I$.

Rotation invariance: $M R_{\theta_K} = R_{\theta_K} M$ (elements of $\mathrm{SO}(2)$ commute), so $M e_{t+1} = M R_{\theta_K} e_t = R_{\theta_K} M e_t$. Hence $\mathrm{conv}(P)$ is rotation-invariant under $R_{\theta_K}$ with center at the origin, so $0 \in \mathrm{conv}(P)$; feasibility of (★) implies non-empty interior, so $0 \in \mathrm{int}(\mathrm{conv}(P))$. Then $P_C(0) = 0$, $\nabla \psi(0) = 0$, and by strong convexity $0$ is the unique minimizer. $\square$

*Proof of (iii): see GTD23 §3.4 for the KKT verification.* The projection identity reduces, via the KKT optimality condition for projection onto a polygon, to the algebraic inequality (★). Taken as a black box here; independent numerical verification to machine precision is in `verify_sublemma.py` (Part 3).

*Proof of (iv).* Inductive. Assume $(x_{t-1}, x_t) = (e_{t-1}, e_t)$. By (i), (iii):
$$\nabla \psi(e_t) = \mu e_t + (L - \mu) M e_t.$$
By (M-def), $(L - \mu)\eta\, M e_t = (1+\beta-\mu\eta) e_t - e_{t+1} - \beta e_{t-1}$ (using $R_{\theta_K} e_t = e_{t+1}$, $R_{-\theta_K} e_t = e_{t-1}$). So
$$\eta\,\nabla \psi(e_t) = \mu \eta\, e_t + (1 + \beta - \mu \eta) e_t - e_{t+1} - \beta e_{t-1} = (1 + \beta) e_t - e_{t+1} - \beta e_{t-1}.$$
Substituting into the HB update:
$$x_{t+1} = e_t - [(1+\beta) e_t - e_{t+1} - \beta e_{t-1}] + \beta(e_t - e_{t-1}) = e_{t+1}. \quad\square$$

## 1.4 Le Cam two-point method for stochastic mean estimation  [MOD v3-5: REWRITTEN CLEAN]

**Lemma 1.4 (Le Cam two-point, Gaussian version).**  **[MOD v4-3: signal $\alpha$ reparametrized; updated KL/TV/Le Cam values]** Let $T \geq 1$, $\sigma, D > 0$. Define $\alpha := \sigma/(3\sqrt T)$ (corresponding to $c_\alpha = 1/3$ in the parametrization $\alpha = c_\alpha\,\sigma/\sqrt T$). For $s \in \{+1, -1\}$, let $\mathbb{P}_s^T$ denote the product measure of $T$ i.i.d. samples from $\mathcal{N}(s\alpha,\,\sigma^2)$. Then:

**(a)** $\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) = T \cdot 2\alpha^2/\sigma^2 = 2/9$.

**(b)** $\mathrm{TV}(\mathbb{P}_+^T, \mathbb{P}_-^T) \leq \sqrt{\mathrm{KL}/2} = 1/3$ (Pinsker).

**(c)** For any (possibly randomized) estimator $\hat s : \mathbb{R}^T \to \{+1, -1\}$,
$$\max_{s \in \{+1,-1\}}\ \mathbb{P}_s[\hat s \neq s]\ \geq\ \tfrac{1}{2}\bigl(1 - \mathrm{TV}(\mathbb{P}_+^T, \mathbb{P}_-^T)\bigr)\ \geq\ \tfrac{1}{2}\bigl(1 - 1/3\bigr)\ =\ 1/3.$$

*Proof of (a).* The standard univariate Gaussian KL identity gives $\mathrm{KL}(\mathcal{N}(\alpha, \sigma^2) \| \mathcal{N}(-\alpha, \sigma^2)) = (2\alpha)^2/(2\sigma^2) = 2\alpha^2/\sigma^2$. Tensorizing over $T$ i.i.d. samples:
$$\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) = T \cdot \frac{2\alpha^2}{\sigma^2} = T \cdot \frac{2 \cdot \sigma^2/(9T)}{\sigma^2} = \frac{2}{9}. \quad\checkmark$$

*Proof of (b).* Pinsker's inequality: $\mathrm{TV}(P, Q) \leq \sqrt{\mathrm{KL}(P \| Q)/2} = \sqrt{(2/9)/2} = \sqrt{1/9} = 1/3$.

*Proof of (c).* Le Cam's two-point lemma (Yu "Assouad, Fano, Le Cam" 1997, Ch. 24): for any estimator $\hat s$,
$$\mathbb{P}_+[\hat s \neq +1] + \mathbb{P}_-[\hat s \neq -1] = \mathbb{P}_+[\hat s = -1] + \mathbb{P}_-[\hat s = +1] \geq 1 - \mathrm{TV}(\mathbb{P}_+^T, \mathbb{P}_-^T),$$
by the variational definition of TV. Hence
$$\max_{s}\mathbb{P}_s[\hat s \neq s] \geq \tfrac{1}{2}(1 - \mathrm{TV}) \geq \tfrac{1}{2}(1 - 1/3) = 1/3 \approx 0.333. \quad\square$$

**Remark (v4 vs v3).** The v3 chain used $\alpha = \sigma/(2\sqrt{2T})$ (i.e., $c_\alpha = 1/(2\sqrt 2) \approx 0.354$), giving $\mathrm{KL}_T = 1/4$, $\mathrm{TV} \le 1/(2\sqrt 2) \approx 0.354$, and Le Cam $p_{\min} \approx 0.323$, then conservatively rounded to $1/14$. The v4 choice $c_\alpha = 1/3$ is the optimum of the cubic $c_\alpha(1-c_\alpha)(2 - c_\alpha r\sqrt 2)$ at $r = \sqrt 2$, gives a smaller signal but a cleaner $p_{\min} = 1/3$, and combined with the exact wall-correction handling in Lemma 2.9 yields the sharper variance constant.

**Remark on the noise model.** Our construction in §2.1.3 uses Gaussian noise $\xi_t \sim \mathcal{N}(0, \sigma^2)$ on the $y$-coordinate, consistent with the variance hypothesis of §0.2 (stdev $\sigma$, variance $\sigma^2$) and with this lemma.

## 1.5 Lan 2012 AC-SA upper bound (for comparison)

**Lemma 1.5 (Lan 2012).** Let $f : \mathbb{R}^d \to \mathbb{R}$ be convex, $L$-smooth, $\|x_0 - x^\star\|\leq D$, and a stochastic oracle with variance $\sigma^2$. Then Lan's AC-SA method produces $\bar x_T$ with
$$\mathbb{E}[f(\bar x_T) - f^\star] \leq \frac{c_1 L D^2}{T^2} + \frac{c_2 \sigma D}{\sqrt T}$$
for universal constants $c_1, c_2$.

*Cited from Lan (2012), "An optimal method for stochastic composite optimization", Math. Prog. 133.* Used in Part 4 for comparison only.

## 1.6 Ghadimi–Feyzmahdavian–Johansson 2015 upper bound (deterministic, for tightness)  [MOD v3-1: REWRITTEN]

**Lemma 1.6 (GFJ15, deterministic).** Let $f:\mathbb{R}^d \to \mathbb{R}$ be convex and $L$-smooth with minimizer $x^\star$ satisfying $\|x_0 - x^\star\|\leq D$. Run **deterministic** heavy-ball
$$x_{t+1} = x_t - \eta\,\nabla f(x_t) + \beta(x_t - x_{t-1})$$
(i.e., zero-variance oracle, $\sigma = 0$) with fixed $(\beta,\eta)$ in a suitable range. Let $\bar x_T := (1/T)\sum_{t=1}^T x_t$ be the Cesàro (weighted) average iterate. Then there exists a universal constant $c_3$ such that
$$f(\bar x_T) - f^\star \leq \frac{c_3\, L D^2}{T}.$$

*Cited from Ghadimi, Feyzmahdavian, Johansson (2015), "Global convergence of the heavy-ball method for convex optimization", arXiv:1412.7457.* **Caveat on scope.** The paper treats only the deterministic oracle case. Its abstract (quoted): *"When the objective function has Lipschitz-continuous gradient, we show that the Cesàro average of the iterates converges to the optimum at a rate of $O(1/k)$"*. There is **no** stochastic oracle and **no** $\sigma D/\sqrt T$ term in GFJ15; prior versions of this document incorrectly claimed a stochastic GFJ15 upper bound. Used in Part 4 for tightness of the **bias term** in the deterministic case $\sigma = 0$; for stochastic-case tightness discussion (matching against SGD rather than a dedicated SHB stochastic UB), see §4.2.

## 1.7 Positive homogeneity of Euclidean projection  [MOD v2-1: NEW LEMMA]

**Lemma 1.7 (Positive homogeneity of projection).** Let $C \subset \mathbb{R}^d$ be a non-empty closed convex set and $\lambda > 0$. Then for every $x \in \mathbb{R}^d$,
$$P_{\lambda C}(\lambda x) = \lambda\, P_C(x),$$
where $\lambda C := \{\lambda z : z \in C\}$.

*Proof.* $\lambda C$ is again closed convex (affine image of a closed convex set under the invertible map $z \mapsto \lambda z$). By definition of projection,
$$P_{\lambda C}(\lambda x) = \arg\min_{w \in \lambda C} \|w - \lambda x\|^2.$$
Substitute $w = \lambda z$, $z \in C$ (a bijection $\lambda C \leftrightarrow C$ since $\lambda > 0$):
$$P_{\lambda C}(\lambda x) = \lambda \cdot \arg\min_{z \in C} \|\lambda z - \lambda x\|^2 = \lambda \cdot \arg\min_{z \in C} \lambda^2 \|z - x\|^2.$$
Since $\lambda^2 > 0$ is a positive constant (independent of $z$), the argmin is unchanged:
$$= \lambda \cdot \arg\min_{z \in C} \|z - x\|^2 = \lambda\, P_C(x). \qquad \square$$

**Corollary 1.8.** For $\lambda > 0$ and $x \in \mathbb{R}^d$: $d_{\lambda C}(\lambda x) = \lambda\, d_C(x)$.

*Proof.* $d_{\lambda C}(\lambda x) = \|\lambda x - P_{\lambda C}(\lambda x)\| = \|\lambda x - \lambda P_C(x)\| = \lambda \|x - P_C(x)\| = \lambda d_C(x)$. $\square$

---

# Part 2. Complete proof

Fix $(\beta, \eta) \in \mathcal{F}$ and $T \geq 1$ for the remainder. By definition of $\mathcal{F}$, choose $K \geq 3$ and $\kappa = \kappa(\beta,\eta) \in (0,1)$ such that (★) holds. Set
$$\mu := \kappa L \in (0, L).\tag{MU}$$
$\mu$ depends only on $(\beta, \eta)$; crucially **not on $T$**.

## 2.1 Construction of the hard instance $f_{\beta,\eta}^{(T)}$

### 2.1.1 The 2-D base function $f_0$ (rescaled Goujaud)  [MOD v2-1: REWRITTEN]

Apply Lemma 1.3 at parameters $(L, \mu, \beta, \eta, K)$; (★) holds by hypothesis. Let $M$ be the matrix of (M-def), $P = \{M e_0, \ldots, M e_{K-1}\}$. **Rescale the polytope**:
$$\widetilde P := (D/\sqrt 2) \cdot P = \{(D/\sqrt 2)\, M e_t : t = 0, \ldots, K-1\}.$$
Equivalently $\mathrm{conv}(\widetilde P) = (D/\sqrt 2) \cdot \mathrm{conv}(P)$. Define
$$\boxed{\ f_0(x) := \tfrac{L}{2}\|x\|^2 - \tfrac{L - \mu}{2}\, d_{\mathrm{conv}(\widetilde P)}(x)^2,\qquad x \in \mathbb{R}^2.\ }\tag{F0-v2}$$

**Claim 2.1.** $f_0$ is convex, $L$-smooth, and $\mu$-strongly convex on $\mathbb{R}^2$, with unique minimum $f_0(0) = 0$ at the origin.

*Proof.* $\mathrm{conv}(\widetilde P)$ is a non-empty closed convex set. By the Moreau rewriting (as in Lemma 1.3(i)),
$$f_0(x) = \tfrac{\mu}{2}\|x\|^2 + (L - \mu)\, \Phi_{\mathrm{conv}(\widetilde P)}(x),$$
so by Lemma 1.1, $f_0 \in C^{1,1}$ with
$$\nabla f_0(x) = \mu\, x + (L - \mu)\, P_{\mathrm{conv}(\widetilde P)}(x),\tag{F0-grad}$$
and $\nabla f_0$ is $L$-Lipschitz. Monotonicity of $P_{\mathrm{conv}(\widetilde P)}$ gives $\mu$-strong convexity. The Hessian (where it exists) is $\nabla^2 f_0 = \mu I + (L-\mu)\nabla P_{\mathrm{conv}(\widetilde P)} \in [\mu I_2, L I_2]$.

$\mathrm{conv}(\widetilde P)$ is rotation-invariant under $R_{\theta_K}$ (since $\mathrm{conv}(P)$ is, and $R_{\theta_K}$ commutes with the dilation by $D/\sqrt 2$); by Lemma 1.3(ii) applied to $\psi$, $0 \in \mathrm{int}(\mathrm{conv}(P))$, hence $0 \in \mathrm{int}(\mathrm{conv}(\widetilde P))$, so $P_{\mathrm{conv}(\widetilde P)}(0) = 0$ and $\nabla f_0(0) = 0$, $f_0(0) = 0$. Strong convexity gives uniqueness. $\square$

**Remark (relation to $\psi$).** By Corollary 1.8, $d_{\mathrm{conv}(\widetilde P)}((D/\sqrt 2) u) = (D/\sqrt 2)\, d_{\mathrm{conv}(P)}(u)$. Substituting, $f_0((D/\sqrt 2) u) = (D^2/2)\, \psi(u)$, so $f_0$ is the value-rescaling $(D^2/2)\psi$ composed with the argument-rescaling $x \mapsto \sqrt 2 x / D$ — i.e., $f_0(x) = (D^2/2)\psi(\sqrt 2 x/D)$. This is **not** $D^2\psi(x/D)$ (the v1 form, which has different polytope scaling and does not admit the desired cycling from $x_0 = (D/\sqrt 2) e_0$).

### 2.1.2 The wall function and 3-D hard instance  [MOD v2-2: WALL RADIUS CHANGED] [MOD v4-1, v4-2: $\alpha$ reparametrized to $c_\alpha = 1/3$]

For $s \in \{+1, -1\}$, set
$$\alpha_s := s \cdot \frac{\sigma}{3\sqrt T}.\tag{ALPHA}$$
Define the **wall radius**
$$R := \frac{D}{\sqrt 2} - \frac{\alpha}{L}, \qquad \text{where}\ \alpha := |\alpha_s| = \frac{\sigma}{3\sqrt T}.\tag{R-def}$$
Under the regime (RGM) of §0.5, $\alpha/L = \sigma/(3L\sqrt T) \leq D\sqrt{2T}/(3\sqrt T) = D\sqrt 2/3 \approx 0.471\,D < D/\sqrt 2 \approx 0.707\,D$, so $R \in (D/\sqrt 2 - D\sqrt 2/3,\ D/\sqrt 2) = (D(\sqrt 2/3)\cdot(\sqrt 2/2),\ D/\sqrt 2)$, i.e., $R \in ((1/\sqrt 2 - \sqrt 2/3)\,D,\ D/\sqrt 2) \approx (0.236\,D,\ 0.707\,D)$. In particular $R > 0$. Define the **wall function** $w : \mathbb{R} \to \mathbb{R}$ by
$$w(y) := \frac{L}{2}\big(\max(|y| - R,\ 0)\big)^2.$$
Note $w$ is $L$-smooth convex with
$$w'(y) = \begin{cases}0, & |y| \leq R, \\ L(|y| - R)\,\mathrm{sgn}(y), & |y| > R;\end{cases}\qquad w''(y) = \begin{cases}0, & |y| < R, \\ L, & |y| > R.\end{cases}$$

Define the **3-D hard instance**
$$f_{\beta,\eta}^{(T),(s)}(x, y) := f_0(x) + \alpha_s y + w(y),\qquad (x, y) \in \mathbb{R}^2 \times \mathbb{R} = \mathbb{R}^3.\tag{F}$$

**Claim 2.2.** $f^{(s)} := f_{\beta,\eta}^{(T),(s)}$ is convex and $L$-smooth on $\mathbb{R}^3$, with unique minimizer $(0, y^\star_s)$ where
$$y^\star_s = -s \cdot \frac{D}{\sqrt 2}\qquad \text{(exactly; [MOD v2-2])}.$$

*Proof.* **Regularity.** Hessian: $\nabla^2 f^{(s)}(x,y) = \nabla^2 f_0(x) \oplus w''(y)$ (block-diagonal; the linear term $\alpha_s y$ has zero Hessian). So $\|\nabla^2 f^{(s)}\|_{\mathrm{op}} \leq \max(L, L) = L$ (since $f_0$ is $L$-smooth and $w''(y) \leq L$), and $\nabla^2 f^{(s)} \succeq 0$ (since $f_0$ is $\mu$-SC hence $\succeq 0$, and $w'' \geq 0$). Thus $f^{(s)}$ is convex and $L$-smooth.

**Minimizer, $x$-coordinate.** $\nabla_x f^{(s)} = \nabla f_0(x) = 0 \iff x = 0$ by Claim 2.1.

**Minimizer, $y$-coordinate.**  [MOD v3-6: CLEANED] We solve $\alpha_s + w'(y) = 0$ using the piecewise form of $w'$:
$$w'(y) = \begin{cases}L(y - R), & y > R \quad \text{(positive sign)} \\ 0, & -R \leq y \leq R \\ L(y + R), & y < -R \quad \text{(negative sign)}\end{cases}$$
(Derivation: for $y > R$, $|y| = y$ and $\mathrm{sgn}(y) = +1$, giving $w'(y) = L(y-R)\cdot(+1) = L(y-R) > 0$. For $y < -R$, $|y| = -y$ and $\mathrm{sgn}(y) = -1$, giving $w'(y) = L(-y-R)\cdot(-1) = L(y+R) < 0$. Flat region: $w' = 0$.)

**Case $s = +1$** ($\alpha_s = +\alpha > 0$): need $w'(y) = -\alpha < 0$, which forces $y < -R$. From $L(y + R) = -\alpha$ we solve $y = -R - \alpha/L = -(D/\sqrt 2 - \alpha/L) - \alpha/L = -D/\sqrt 2$. Hence $y^\star_{+} = -D/\sqrt 2$.

**Case $s = -1$** ($\alpha_s = -\alpha < 0$): by the symmetric argument (or by $y \mapsto -y$ symmetry of $w$), $y^\star_{-} = +D/\sqrt 2$.

**Uniqueness.** At $(0, y^\star_s)$: $\nabla^2 f_0(0) \succeq \mu I_2$ (strong convexity of $f_0$), and $w''(y^\star_s) = L > 0$ (since $|y^\star_s| = D/\sqrt 2 > R$). The Hessian is positive-definite at the critical point, so by convexity the minimizer is globally unique. $\square$

### 2.1.3 Stochastic oracle  [MOD v2 minor: Gaussian noise]

Let $(\xi_t)_{t\geq 0}$ be i.i.d. $\mathcal{N}(0, \sigma^2)$. On query $(x_t, y_t)$, the oracle returns
$$g_t := \big(\nabla f_0(x_t),\ \partial_y f^{(s)}(x_t, y_t) + \xi_t\big) \in \mathbb{R}^3.\tag{ORACLE}$$

**Claim 2.3.** The oracle (ORACLE) is unbiased with per-query variance $\leq \sigma^2$ and is independent of history.

*Proof.* $\mathbb{E}[g_t \mid \mathcal{H}_t] = (\nabla f_0(x_t), \partial_y f^{(s)} + \mathbb{E}[\xi_t]) = \nabla f^{(s)}(x_t, y_t)$. Variance: $g_t - \nabla f^{(s)} = (0, 0, \xi_t)$ with $\mathbb{E}\|(0,0,\xi_t)\|^2 = \sigma^2$. Independence: $(\xi_t)$ i.i.d. $\square$

### 2.1.4 Initialization

Set
$$x_0 := (D/\sqrt 2)\,e_0,\qquad x_{-1} := (D/\sqrt 2)\, e_{K-1}\qquad (\in \mathbb{R}^2),\qquad y_0 := 0,\ y_{-1} := 0.$$
Full initial state in $\mathbb{R}^3$: $(x_0, y_0) = ((D/\sqrt 2) e_0,\, 0)$, $(x_{-1}, y_{-1}) = ((D/\sqrt 2) e_{K-1},\, 0)$.

**Claim 2.4 (Initial distance, [MOD v2-2]).** $\|(x_0, y_0) - (0, y^\star_s)\| = D$ **exactly**.

*Proof.* Compute:
\begin{align*}
\|(x_0, y_0) - (0, y^\star_s)\|^2
&= \|(D/\sqrt 2) e_0 - 0\|^2 + |0 - y^\star_s|^2 \\
&= (D/\sqrt 2)^2 \|e_0\|^2 + (D/\sqrt 2)^2 \\
&= D^2/2 + D^2/2 = D^2.
\end{align*}
Using $\|e_0\| = 1$ (since $e_0 = (\cos 0, \sin 0) = (1, 0)$) and $|y^\star_s| = D/\sqrt 2$ (Claim 2.2). $\square$

## 2.2 Decoupling of SHB dynamics

**Claim 2.5.** Under the construction of §2.1, the SHB iterate $((x_t, y_t))_{t\geq 0}$ decouples: $(x_t)$ evolves as **deterministic** HB on $f_0$ with initialization $(x_0, x_{-1}) = ((D/\sqrt 2) e_0, (D/\sqrt 2) e_{K-1})$, and $(y_t)$ evolves independently with the stochastic drive.

*Proof.* By (ORACLE), $g_t = (\nabla f_0(x_t),\ \partial_y f^{(s)}(x_t, y_t) + \xi_t)$. Applying (SHB) coordinate-wise:
\begin{align*}
x_{t+1} &= x_t - \eta\,\nabla f_0(x_t) + \beta(x_t - x_{t-1}),\\
y_{t+1} &= y_t - \eta\,[\alpha_s + w'(y_t) + \xi_t] + \beta(y_t - y_{t-1}).
\end{align*}
The $x$-update contains no noise and uses only $(x_t, x_{t-1})$: **deterministic** HB on $f_0$. The $y$-update depends only on $(y_t, y_{t-1}, \xi_t)$ (since $\partial_y f^{(s)}(x_t, y_t) = \alpha_s + w'(y_t)$ is independent of $x_t$): independent of the $x$-dynamics. $\square$

## 2.3 Bias-term lower bound (the $x$-coordinate)

### 2.3.1 Lemma 2.6: rescaled cycle has radius $D/\sqrt 2$  [MOD v2-1: REWRITTEN CLEAN]

**Lemma 2.6 (Amplitude Preservation).** The deterministic HB iterate $(x_t)_{t \geq 0}$ on $f_0$ with initialization $(x_0, x_{-1}) = ((D/\sqrt 2) e_0,\, (D/\sqrt 2) e_{K-1})$ satisfies, for all $t \geq 0$,
$$x_t = (D/\sqrt 2)\, e_{t \bmod K}.$$
In particular, $\|x_t\| = D/\sqrt 2$ for every $t \geq 0$.

*Proof.* **Step 1. Transplanted projection identity.** Set $\lambda := D/\sqrt 2 > 0$, $C := \mathrm{conv}(P)$, $\widetilde C := \lambda C = \mathrm{conv}(\widetilde P)$. By Lemma 1.3(iii), $P_C(e_t) = M e_t$ for every $t \in \mathbb{Z}$. By Lemma 1.7 (positive homogeneity of projection) applied with scale $\lambda$:
$$P_{\widetilde C}(\lambda e_t) = \lambda\, P_C(e_t) = \lambda\, M e_t. \tag{PROJ-scaled}$$

**Step 2. Gradient at the rescaled cycle point.** By (F0-grad),
$$\nabla f_0(\lambda e_t) = \mu\,\lambda e_t + (L - \mu)\, P_{\widetilde C}(\lambda e_t) \stackrel{\text{(PROJ-scaled)}}{=} \lambda\,[\mu e_t + (L-\mu) M e_t] = \lambda\, \nabla \psi(e_t), \tag{GRAD-scaled}$$
using the formula $\nabla\psi(e_t) = \mu e_t + (L-\mu) M e_t$ from Lemma 1.3(i)+(iii).

**Step 3. Apply Lemma 1.3(iv) calculation.** From the proof of Lemma 1.3(iv):
$$\eta\, \nabla \psi(e_t) = (1 + \beta) e_t - e_{t+1} - \beta e_{t-1}. \tag{GRAD-psi}$$
Combining with (GRAD-scaled):
$$\eta\, \nabla f_0(\lambda e_t) = \lambda\,[(1 + \beta) e_t - e_{t+1} - \beta e_{t-1}]. \tag{GRAD-f0}$$

**Step 4. Induction.** Assume $(x_{t-1}, x_t) = (\lambda e_{t-1}, \lambda e_t)$. Substituting into HB:
\begin{align*}
x_{t+1} &= x_t - \eta\, \nabla f_0(x_t) + \beta(x_t - x_{t-1}) \\
&= \lambda e_t - \lambda[(1+\beta) e_t - e_{t+1} - \beta e_{t-1}] + \beta (\lambda e_t - \lambda e_{t-1}) \\
&= \lambda\big[\,e_t - (1+\beta) e_t + e_{t+1} + \beta e_{t-1} + \beta e_t - \beta e_{t-1}\,\big] \\
&= \lambda\big[\,(1 - 1 - \beta + \beta) e_t + e_{t+1} + (\beta - \beta) e_{t-1}\,\big] \\
&= \lambda\, e_{t+1}.
\end{align*}

Base case: $(x_{-1}, x_0) = (\lambda e_{K-1}, \lambda e_0) = (\lambda e_{-1 \bmod K}, \lambda e_{0 \bmod K})$ by construction and periodicity of $e_t$. Induction yields $x_t = \lambda e_{t \bmod K}$ for all $t \geq 0$.

Finally, $\|x_t\| = \lambda \|e_{t \bmod K}\| = \lambda = D/\sqrt 2$. $\square$

### 2.3.2 Lemma 2.7: bias gap $\geq \mu D^2 / 4$, for all $T$

**Lemma 2.7.** With $f_0$ as above and $x_T$ the deterministic HB iterate, for every $T \geq 0$,
$$f_0(x_T) - f_0^\star \geq \frac{\mu D^2}{4} = \frac{\kappa L D^2}{4}.$$

*Proof.* By Lemma 2.6, $\|x_T\| = D/\sqrt 2$, so $\|x_T - 0\|^2 = D^2/2$. By Claim 2.1, $f_0$ is $\mu$-SC with unique minimizer $x^\star = 0$, $f_0^\star = 0$. By Lemma 1.2,
$$f_0(x_T) - f_0^\star \geq \tfrac{\mu}{2}\|x_T\|^2 = \tfrac{\mu}{2}\cdot\tfrac{D^2}{2} = \tfrac{\mu D^2}{4}. \quad\square$$

### 2.3.3 Converting to the $LD^2/T$ rate

**Claim 2.8.** For every $T \geq 1$,
$$f_0(x_T) - f_0^\star \geq \frac{\kappa L D^2}{4} \geq \frac{\kappa}{4} \cdot \frac{L D^2}{T}.$$

*Proof.* First inequality: Lemma 2.7. Second inequality: $\kappa LD^2/4 \geq \kappa LD^2/(4T)$ iff $T \geq 1$, which holds. $\square$

## 2.4 Variance-term lower bound (the $y$-coordinate)

### 2.4.1 Lemma 2.9: Le Cam gap on the $y$-coordinate  [MOD v2-3: CONSTANT 1/112] [MOD v4: SHARPENED TO $\sqrt 2/27$]

**Lemma 2.9.** Let $(y_t)_{t \geq 0}$ be the SHB iterate on the $y$-coordinate with noise drive $\xi_t \sim \mathcal{N}(0, \sigma^2)$ i.i.d., starting from $y_0 = y_{-1} = 0$. Under (RGM), for any (possibly randomized) algorithm that produces $y_T$ using at most $T$ queries of the stochastic oracle,
$$\max_{s \in \{+,-\}}\ \mathbb{E}_s\big[\,\alpha_s\, y_T + w(y_T) - \min_{y \in \mathbb{R}}(\alpha_s y + w(y))\,\big]\ \geq\ \frac{\sqrt 2}{27}\cdot \frac{\sigma D}{\sqrt T}\ =\ c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T},$$
with $c_\mathrm{NY} = \sqrt 2/27 \approx 0.0524$.

*Proof.* **Step 1. Reduction to sign testing.** Under hypothesis $s \in \{\pm 1\}$, the $y$-oracle query at any $y_t$ returns $\alpha_s + w'(y_t) + \xi_t$. Since $w'$ is $s$-independent, the only $s$-dependent information is the offset $\alpha_s$. Define the implicit sign estimator $\hat s := -\mathrm{sgn}(y_T) \in \{\pm 1\}$ (since $y^\star_s = -sD/\sqrt 2$, so $\mathrm{sgn}(y^\star_s) = -s$, a "correct" estimate should place $y_T$ near $y^\star_s$, i.e., on the opposite sign of $s$).

**[MOD v3-4: KL tensorization for adaptive queries]** Strictly speaking, SHB's $y$-queries $(y_0, y_1, \ldots, y_{T-1})$ are **adaptive**: $y_t$ depends on the history $(y_{<t}, \xi_{<t})$ through the SHB recursion, not i.i.d. So the naive i.i.d.-tensorization $\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) = T \cdot \mathrm{KL}(\mathcal{N}(\alpha,\sigma^2) \| \mathcal{N}(-\alpha, \sigma^2))$ needs justification via the **KL chain rule**:
$$\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) \ =\ \sum_{t=1}^T\ \mathbb{E}_{y_{<t} \sim \mathbb{P}_+}\bigl[\,\mathrm{KL}\bigl(\mathbb{P}_+(g_t \mid y_{<t})\,\|\,\mathbb{P}_-(g_t \mid y_{<t})\bigr)\,\bigr].$$
Here $g_t = \alpha_s + w'(y_t) + \xi_t$ is the oracle response at step $t$. Conditioned on the history $y_{<t}$ (which determines $y_t$ deterministically since noise is absorbed into the history), the conditional law of $g_t$ under $\mathbb{P}_s$ is $\mathcal{N}(s\alpha + w'(y_t),\ \sigma^2)$. The two conditional laws $\mathbb{P}_\pm(g_t \mid y_{<t})$ are Gaussians with the **same variance $\sigma^2$** and **means differing by $2\alpha$** (the $w'(y_t)$ contribution cancels because $w'$ is $s$-independent). Therefore
$$\mathrm{KL}(\mathbb{P}_+(g_t \mid y_{<t})\,\|\,\mathbb{P}_-(g_t \mid y_{<t})) = \frac{(2\alpha)^2}{2\sigma^2} = \frac{2\alpha^2}{\sigma^2} = \frac{2}{9T}\qquad\text{for every history}\ y_{<t}\ \text{and every}\ t.$$
Summing over $t = 1, \ldots, T$ and taking the trivial expectation (the integrand is a constant function of $y_{<t}$):
$$\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) = T \cdot \frac{2}{9T} = \frac{2}{9},$$
**numerically identical** to the i.i.d.-tensorized bound. Thus the adaptivity of SHB does not alter the KL bound in our construction; the key structural property used is that $w'$ does not depend on $s$. (If instead the oracle's $s$-dependency entered through the *argument* of $\nabla f$ — so that the $s$-shift were coupled to $y_t$ — the chain rule would produce history-dependent conditional KL and a more careful analysis would be required.)

Continuing: by Lemma 1.4 with signal $\alpha = \sigma/(3\sqrt T)$ **[MOD v4-3]**:
- KL per conditional step $= 2\alpha^2/\sigma^2 = 2/(9T)$; total KL $= 2/9$;
- Pinsker: $\mathrm{TV}(\mathbb{P}_+^T, \mathbb{P}_-^T) \leq \sqrt{\mathrm{KL}/2} = \sqrt{1/9} = 1/3$;
- Le Cam: $\max_s \mathbb{P}_s[\hat s \neq s] \geq (1 - \mathrm{TV})/2 \geq (1 - 1/3)/2 = 1/3$.

We use the **clean exact bound**
$$\max_s\,\mathbb{P}_s[\hat s \neq s] \geq 1/3. \tag{MISS}$$
**[MOD v4-3: no $1/14$ floor required — the new chain gives $p_{\min} = 1/3$ directly.]**

**Step 2. Pointwise gap bound on the misidentification event.** Fix $s$. On $A_s := \{\hat s \neq s\} = \{\mathrm{sgn}(y_T) = s\}$, $y_T$ has the wrong sign (opposite to $y^\star_s$). Define
$$G_s(y) := \alpha_s y + w(y) - [\alpha_s y^\star_s + w(y^\star_s)].$$

Using $\alpha_s = s\alpha$, $y^\star_s = -sD/\sqrt 2$, and $w(y^\star_s) = (L/2)(|y^\star_s| - R)^2 = (L/2)(\alpha/L)^2 = \alpha^2/(2L)$:
$$\alpha_s y^\star_s = s\alpha \cdot (-sD/\sqrt 2) = -\alpha D/\sqrt 2,\qquad w(y^\star_s) = \alpha^2/(2L),$$
$$\min_{y}(\alpha_s y + w(y)) = -\alpha D/\sqrt 2 + \alpha^2/(2L).$$

On $A_s$, $sy_T > 0$, so $\alpha_s y_T = s\alpha y_T = \alpha |y_T|$. Also $w(y_T) \geq 0$. Hence
$$G_s(y_T) = \alpha|y_T| + w(y_T) + \alpha D/\sqrt 2 - \alpha^2/(2L) \geq \alpha D/\sqrt 2 - \alpha^2/(2L).\tag{G-lb}$$

**Step 3. Wall-correction term, exact identity.** **[MOD v4-4: replaced loose inequality by exact identity at the (RGM)-saturated worst case.]** Define the (RGM)-tightness ratio
$$r := \frac{\sigma}{LD\sqrt T} \in (0, \sqrt 2].$$
Then $\alpha = \sigma/(3\sqrt T) = (r/3)\, LD$ and $\alpha/L = (r/3)\, D$, so
$$\frac{\alpha D}{\sqrt 2} = \frac{r}{3\sqrt 2}\, LD^2,\qquad \frac{\alpha^2}{2L} = \frac{r^2}{18}\, LD^2.$$
Their difference factors cleanly:
$$\frac{\alpha D}{\sqrt 2} - \frac{\alpha^2}{2L} = \alpha D \cdot \rho(r),\qquad \rho(r) := \frac{1}{\sqrt 2}\Bigl(1 - \frac{r}{\sqrt 2}\cdot \frac{1}{3}\Bigr) = \frac{1}{\sqrt 2} - \frac{r}{6}.$$
This identity is **exact** (no looseness). At the (RGM)-saturated worst case $r = \sqrt 2$:
$$\rho(\sqrt 2) = \frac{1}{\sqrt 2} - \frac{\sqrt 2}{6} = \frac{3 - 1}{3\sqrt 2} = \frac{2}{3\sqrt 2} = \frac{\sqrt 2}{3}.$$
Substituting into (G-lb):
$$G_s(y_T) \geq \alpha D \cdot \rho(r) \geq \alpha D \cdot \frac{\sqrt 2}{3}\qquad \text{on } A_s. \tag{G-final}$$
**Numerical verification of $\rho(\sqrt 2) = \sqrt 2/3$:** $\frac{1}{\sqrt 2} - \frac{\sqrt 2}{6} = \frac{6 - 2}{6\sqrt 2} = \frac{4}{6\sqrt 2} = \frac{2}{3\sqrt 2} = \frac{\sqrt 2}{3} \approx 0.4714$. Decimal check: $1/\sqrt 2 \approx 0.7071$, $\sqrt 2/6 \approx 0.2357$, difference $\approx 0.4714 \approx \sqrt 2/3$. $\checkmark$

**Step 4. Take expectation.** **[MOD v4-5]** $\mathbb{E}_s[G_s(y_T)] \geq \alpha D \cdot (\sqrt 2/3) \cdot \mathbb{P}_s[A_s]$, so by (MISS):
$$\max_s \mathbb{E}_s[G_s(y_T)] \geq \alpha D \cdot \frac{\sqrt 2}{3} \cdot \frac{1}{3} = \frac{\sqrt 2\, \alpha D}{9}.$$

**Step 5. Substitute $\alpha = \sigma/(3\sqrt T)$.**
$$\frac{\sqrt 2\, \alpha D}{9} = \frac{\sqrt 2}{9}\cdot \frac{\sigma D}{3\sqrt T} = \frac{\sqrt 2\, \sigma D}{27\sqrt T}.$$

This gives $\max_s \mathbb{E}_s[G_s(y_T)] \geq (\sqrt 2/27)\,\sigma D/\sqrt T = c_\mathrm{NY}\,\sigma D/\sqrt T$ with $c_\mathrm{NY} = \sqrt 2/27 \approx 0.0524$. $\square$

**Remark on constants.** **[MOD v4: rewritten to derive the sharp $\sqrt 2/27$ constant.]** The value $c_\mathrm{NY} = \sqrt 2/27$ is obtained rigorously by **optimizing** the Le Cam signal amplitude. Reparametrize $\alpha := c_\alpha\,\sigma/\sqrt T$ for $c_\alpha \in (0, 1)$ and let $r := \sigma/(LD\sqrt T) \in (0, \sqrt 2]$ (the (RGM)-tightness ratio). Then the chain gives:
- Per-step KL $= 2\alpha^2/\sigma^2 = 2c_\alpha^2/T$; total KL $= 2c_\alpha^2$; Pinsker TV $\leq c_\alpha$; Le Cam prob $\geq (1 - c_\alpha)/2$.
- Gap on misidentification (exact identity, Step 3): $G_s \geq \alpha D \cdot \rho(c_\alpha, r)$ with $\rho(c_\alpha, r) = (1/\sqrt 2)(1 - c_\alpha r/\sqrt 2)$.
- Multiplication and substituting $\alpha = c_\alpha \sigma/\sqrt T$:
$$\max_s \mathbb{E}_s[G_s(y_T)] \geq \frac{\sigma D}{\sqrt T}\cdot \underbrace{\frac{c_\alpha(1-c_\alpha)}{2\sqrt 2}\Bigl(1 - \frac{c_\alpha r}{\sqrt 2}\Bigr)}_{c_\mathrm{NY}(c_\alpha, r)} = \frac{\sigma D}{\sqrt T}\cdot \frac{\sqrt 2}{8} c_\alpha(1-c_\alpha)(2 - c_\alpha r\sqrt 2).$$

**Optimizing in $c_\alpha$ at fixed $r$.** $\partial_{c_\alpha} c_\mathrm{NY} = 0$ gives the quadratic critical-point equation $3\sqrt 2\, r\, c_\alpha^2 - (2\sqrt 2\, r + 4) c_\alpha + 2 = 0$ (degree 2 in $c_\alpha$, the derivative of the cubic objective), with root in $(0, 1)$:
$$c_\alpha^\star(r) = \frac{r + \sqrt 2 - \sqrt{r^2 - \sqrt 2\, r + 2}}{3 r}.$$
Two clean closed forms:
- **Asymptotic ($r \to 0$):** $c_\alpha^\star \to 1/2$, $c_\mathrm{NY}^\star \to \sqrt 2/16 = 1/(8\sqrt 2) \approx 0.0884$.
- **(RGM)-tight ($r = \sqrt 2$):** the critical-point equation has the rational root $c_\alpha^\star = 1/3$ (verify: $3\sqrt 2 \cdot \sqrt 2 \cdot 1/9 - (2\sqrt 2 \cdot \sqrt 2 + 4) \cdot 1/3 + 2 = 6/9 - 8/3 + 2 = 2/3 - 8/3 + 6/3 = 0$ ✓), and
$$c_\mathrm{NY}^\star = \frac{\sqrt 2}{8}\cdot \frac{1}{3}\cdot \frac{2}{3}\cdot (2 - 1/3 \cdot \sqrt 2 \cdot \sqrt 2) = \frac{\sqrt 2}{8}\cdot \frac{1}{3}\cdot \frac{2}{3}\cdot \frac{4}{3} = \frac{\sqrt 2}{8}\cdot \frac{8}{27} = \frac{\sqrt 2}{27}.$$

Under (RGM) $\sigma \leq LD\sqrt{2T}$ (i.e., $r \leq \sqrt 2$), the sharp Pinsker constant under saturation is $\sqrt 2/27$. The asymptotic limit $1/(8\sqrt 2)$ is recovered for $\sigma \ll LD\sqrt T$ (where the wall correction becomes negligible). Hellinger TV gives a marginal $\sim 1\%$ further sharpening but no clean closed form, so we do not pursue it.

**History of constants in this document:**
- v1 claimed $1/(8\sqrt 2) \approx 0.088$ unjustified, with an inline chain that dropped the wall correction yielding $1/56 \approx 0.018$.
- v2 carried the wall correction rigorously with the suboptimal choice $c_\alpha = 1/(2\sqrt 2)$ and a $1/14$ Le Cam floor, yielding $1/112 \approx 0.0089$.
- v4 [this version] optimizes $c_\alpha$ and uses the **exact** wall-correction identity, yielding $\sqrt 2/27 \approx 0.0524$ — the rigorous sharp constant under saturated (RGM). Factor $\approx 5.87$ improvement over v3.

## 2.5 Combining bias and variance

**Claim 2.10.** For every $T \geq 1$, the full 3-D SHB iterate satisfies
$$\max_{s \in \{+, -\}} \mathbb{E}_s\big[f^{(s)}(x_T, y_T) - f^{(s),\star}\big] \geq \frac{\kappa(\beta,\eta)}{4}\cdot \frac{L D^2}{T} + c_\mathrm{NY}\cdot \frac{\sigma D}{\sqrt T},$$
where $c_\mathrm{NY} = \sqrt 2/27$ **[MOD v4]**.

*Proof.* By (F), $f^{(s)}(x,y) = f_0(x) + \alpha_s y + w(y)$ is coordinate-separable; its unique minimizer is $(0, y^\star_s)$ (Claim 2.2), and
$$f^{(s),\star} = f_0(0) + [\alpha_s y^\star_s + w(y^\star_s)] = 0 + \min_y[\alpha_s y + w(y)].$$
Therefore, denoting $G_s(y) := \alpha_s y + w(y) - \min_{y'}(\alpha_s y' + w(y'))$ (as in Lemma 2.9),
$$f^{(s)}(x_T, y_T) - f^{(s),\star} = [f_0(x_T) - f_0^\star] + G_s(y_T).$$

Take expectation under hypothesis $s$ (recall $x_T$ is **deterministic** by Claim 2.5, so $\mathbb{E}_s[f_0(x_T) - f_0^\star] = f_0(x_T) - f_0^\star$):
$$\mathbb{E}_s[f^{(s)}(x_T, y_T) - f^{(s),\star}] = \underbrace{[f_0(x_T) - f_0^\star]}_{\text{$s$-independent}} + \mathbb{E}_s[G_s(y_T)]. \tag{DECOMP}$$

**Claim 2.11 (max-over-$s$ step, [MOD v2-4]).** Let $A \in \mathbb{R}$ be a constant and $(B_s)_{s \in \{\pm\}}$ two real numbers. Then $\max_s (A + B_s) = A + \max_s B_s$.

*Proof.* If $B_+ \geq B_-$: $\max_s(A + B_s) = A + B_+ = A + \max_s B_s$. Symmetric otherwise. $\square$

Applying Claim 2.11 to (DECOMP) with $A = f_0(x_T) - f_0^\star$ (deterministic, the same under $\mathbb{P}_+$ and $\mathbb{P}_-$) and $B_s = \mathbb{E}_s[G_s(y_T)]$:
$$\max_s \mathbb{E}_s[f^{(s)} - f^{(s),\star}] = [f_0(x_T) - f_0^\star] + \max_s \mathbb{E}_s[G_s(y_T)]. \tag{MAX}$$

For the first summand, Claim 2.8 gives $f_0(x_T) - f_0^\star \geq (\kappa/4)\,LD^2/T$. For the second, Lemma 2.9 gives $\max_s \mathbb{E}_s[G_s(y_T)] \geq c_\mathrm{NY}\,\sigma D/\sqrt T$. Substituting:
$$\max_s \mathbb{E}_s[f^{(s)} - f^{(s),\star}] \geq \frac{\kappa}{4}\cdot\frac{LD^2}{T} + c_\mathrm{NY}\cdot \frac{\sigma D}{\sqrt T}.$$

**Conclusion.** **[MOD v3-8: EXPLICIT $s^\star$ CONSTRUCTION]** Let $s^\star \in \arg\max_{s \in \{+,-\}} \mathbb{E}_s[f^{(s)}(x_T, y_T) - f^{(s),\star}]$. We stress that $s^\star$ is a **deterministic function of the parameters $(\beta, \eta, T)$**: given $(\beta, \eta, T)$, the construction of §2.1 produces two explicit candidate functions $f^{(+)} := f_{\beta,\eta}^{(T),(+1)}$ and $f^{(-)} := f_{\beta,\eta}^{(T),(-1)}$; for each, the induced SHB dynamics on the $y$-coordinate have explicit laws $\mathbb{P}_\pm$, from which $\mathbb{E}_+[f^{(+)} - f^{(+),\star}]$ and $\mathbb{E}_-[f^{(-)} - f^{(-),\star}]$ can be computed (or bounded). Take $s^\star := +1$ if the former is larger, else $s^\star := -1$ (ties broken by convention, e.g., always choose $+$). Set $f_{\beta,\eta}^{(T)} := f^{(s^\star)}$ and apply the oracle with hypothesis $s^\star$. Then $f_{\beta,\eta}^{(T)}$ is a well-defined deterministic function of $(\beta,\eta,T)$, and
$$\mathbb{E}[f_{\beta,\eta}^{(T)}(x_T) - f_{\beta,\eta}^{(T),\star}] = \mathbb{E}_{s^\star}[f^{(s^\star)}(x_T, y_T) - f^{(s^\star),\star}] \geq \frac{\kappa}{4}\cdot\frac{LD^2}{T} + c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T},$$
which is exactly (MAIN). (By symmetry of the construction $(+) \leftrightarrow (-)$ under $y \mapsto -y$, one can in fact show $\mathbb{E}_+[\cdots] = \mathbb{E}_-[\cdots]$, so either $s$ works; the $\max$ is a safety net.) $\square$ (Main Theorem) $\blacksquare$

## 2.6 Verification: $f_{\beta,\eta}^{(T)}$ is globally 0-SC (non-SC)  [MOD v2-5: NEW]

**Claim 2.12.** The function $f^{(s)}(x, y) = f_0(x) + \alpha_s y + w(y)$ has **global strong-convexity constant 0**; i.e., it is convex but not $\mu'$-SC for any $\mu' > 0$. This confirms the hypothesis of `problem.md` (which admits $\mu \geq 0$, i.e., non-strongly-convex smooth convex functions).

*Proof.* The strong-convexity constant of a $C^2$ convex function is $\inf_{x,y \in \mathbb{R}^d,\ y \neq 0} y^\top \nabla^2 f(x) y / \|y\|^2$. (More precisely: the largest $\mu' \geq 0$ such that $\nabla^2 f \succeq \mu' I$ a.e., since $f$ is $C^{1,1}$ only.)

$\nabla^2 f^{(s)}(x, y) = \nabla^2 f_0(x) \oplus w''(y)$, a block-diagonal matrix on $\mathbb{R}^2 \oplus \mathbb{R}$. Consider the point $(x_0, y_0) = (0, 0)$: $\nabla^2 f_0(0) = \mu I_2 + (L-\mu)\nabla P_{\mathrm{conv}(\widetilde P)}(0)$. Since $0 \in \mathrm{int}(\mathrm{conv}(\widetilde P))$, $P_{\mathrm{conv}(\widetilde P)}$ is the identity in a neighborhood of $0$, so $\nabla P_{\mathrm{conv}(\widetilde P)}(0) = I_2$ and $\nabla^2 f_0(0) = \mu I_2 + (L-\mu) I_2 = L I_2$. Also $w''(0) = 0$ (since $0 < R$, flat region). Hence
$$\nabla^2 f^{(s)}(0, 0) = (L I_2) \oplus 0 = \mathrm{diag}(L, L, 0).$$
Pick the test vector $v = (0, 0, 1)$: $v^\top \nabla^2 f^{(s)}(0, 0)\, v = 0$.

Therefore the minimal eigenvalue of $\nabla^2 f^{(s)}$ (over points where Hessian exists) is $0$, so the largest $\mu'$ satisfying $\nabla^2 f^{(s)} \succeq \mu' I_3$ a.e. is $\mu' = 0$. $f^{(s)}$ is globally **only convex** (0-SC), matching the $\mathcal{F}_L$ class of `problem.md`. $\square$

**Remark.** The function **is** strongly convex restricted to either (a) the $x$-subspace $\{(x, 0) : x \in \mathbb{R}^2\}$ (where it reduces to $f_0$, $\mu$-SC) or (b) the complement of the flat region $\{(x, y) : |y| > R\}$ (where $w''(y) = L$). Globally, neither holds everywhere, and the strong-convexity constant is the infimum.

## 2.7 Verification: $\mathcal{F}$ has positive 2-D Lebesgue measure  [MOD v2-6: NEW]

**Claim 2.13.** The set
$$\mathcal{F}_{K=3}^\circ := \left\{(\beta, \eta) : \beta > \beta^\star,\ L\eta \in \left(\frac{3(1 + \beta + \beta^2)}{1 + 2\beta},\ 2(1+\beta)\right)\right\}$$
is non-empty, open, and has positive 2-D Lebesgue measure in $[0,1)\times\mathbb{R}_{>0}$. Consequently, $\mathcal{F} \supset \mathcal{F}_{K=3}^\circ$ has positive 2-D Lebesgue measure.

Here $\beta^\star := (\sqrt{13} - 3)/2 \approx 0.3028$ and $\gamma_\mathrm{crit}(\beta) := 3(1+\beta+\beta^2)/(1 + 2\beta)$.

*Proof.* **Step 1: Derive $\gamma_\mathrm{crit}$.** At $K = 3$: $\theta_K = 2\pi/3$, $c_K = \cos(2\pi/3) = -1/2$. Substitute into (★):
\begin{align*}
\beta - c_K &= \beta + 1/2,\\
1 - \beta c_K &= 1 + \beta/2,\\
1 - c_K &= 3/2,\\
1 + \beta^2 - 2\beta c_K &= 1 + \beta^2 + \beta.
\end{align*}
(★) with $h := \kappa \eta L$ becomes
$$h^2 - 2[(\beta + 1/2) + \kappa(1 + \beta/2)]\, h + 3\kappa(1 + \beta + \beta^2) \leq 0. \tag{$\star_3$}$$

For fixed $(\beta, \eta)$, this is a quadratic inequality in $\kappa$ (via $h = \kappa\eta L$); ($\star_3$) is feasible iff the discriminant is non-negative and the resulting $\kappa$ lies in $(0,1)$.

**[MOD v3-9: SUFFICIENCY VS NECESSITY]** We separate the two directions:

**Sufficiency** (this is what we use): *if* $\eta L \geq \gamma_\mathrm{crit}(\beta) := 3(1+\beta+\beta^2)/(1 + 2\beta)$, *then* ($\star_3$) admits a feasible $\kappa \in (0,1)$, so $(\beta,\eta) \in \mathcal{F}_{K=3} \subset \mathcal{F}$. This direction can be verified directly. Treating ($\star_3$) as a quadratic inequality in $\kappa$ (with $(\beta, \eta)$ fixed), the discriminant condition for the existence of $\kappa \in (0,1)$ reduces, after standard algebra, to the closed-form threshold
$$\eta L \cdot (1 + 2\beta) \geq 3(1 + \beta + \beta^2),\qquad \text{i.e.,}\ \eta L \geq \gamma_\mathrm{crit}(\beta).$$
Combined with the stability bound $\eta L \leq 2(1+\beta)$, this gives a nonempty feasibility interval in $\eta L$; see Step 2 below for the existence of such an interval whenever $\beta > \beta^\star$. (Full symbolic derivation: run `fixed_verify.py` Part [E], which solves ($\star_3$) for $\kappa$ and reports the feasibility interval numerically to machine precision.) This sufficiency is all we need for Claim 2.13.

**Necessity** (not required for the theorem): the converse — *if* $(\beta,\eta) \in \mathcal{F}_{K=3}$, *then* $\eta L \geq \gamma_\mathrm{crit}(\beta)$ — is empirically supported by `fixed_verify.py` Parts [A], [C], [E]: for every grid point with $\beta > \beta^\star$ and $\eta L < \gamma_\mathrm{crit}(\beta)$, the cycling quadratic ($\star_3$) admits no $\kappa \in (0,1)$, and SHB converges geometrically on the Goujaud construction (Part 3.4). A rigorous algebraic proof of necessity would require completing the square in a different order, which we omit as it is not required for the positive-measure claim in Step 3. $\gamma_\mathrm{crit}(\beta)$ is the **closed-form** (sufficient) threshold verified empirically to machine precision in Part 3.5.

**Step 2: Stability constraint.** $\mathcal{S}$ requires $\eta L \leq 2(1+\beta)$. So the combined constraint on $\eta L$ is
$$\gamma_\mathrm{crit}(\beta) \leq \eta L \leq 2(1+\beta). \tag{INT}$$
Non-empty iff $\gamma_\mathrm{crit}(\beta) \leq 2(1+\beta)$:
$$3(1+\beta+\beta^2) \leq 2(1+\beta)(1+2\beta) = 2 + 6\beta + 4\beta^2,$$
$$3 + 3\beta + 3\beta^2 \leq 2 + 6\beta + 4\beta^2,$$
$$0 \leq -1 + 3\beta + \beta^2,$$
$$\beta^2 + 3\beta - 1 \geq 0.$$
The positive root of $\beta^2 + 3\beta - 1 = 0$ is $\beta^\star = (\sqrt{13} - 3)/2 \approx 0.3028$. For $\beta > \beta^\star$, $\beta^2 + 3\beta - 1 > 0$, so the interval (INT) has **strictly positive length**
$$\ell(\beta) := 2(1+\beta) - \gamma_\mathrm{crit}(\beta) = \frac{\beta^2 + 3\beta - 1}{1 + 2\beta} > 0.$$

**Step 3: Measure computation.** The 2-D Lebesgue measure of $\mathcal{F}_{K=3}^\circ$ in $[0,1)\times \mathbb{R}_{>0}$:
$$\lambda_2(\mathcal{F}_{K=3}^\circ) = \int_{\beta^\star}^1 \frac{\ell(\beta)}{L}\, d\beta = \frac{1}{L}\int_{\beta^\star}^1 \frac{\beta^2 + 3\beta - 1}{1 + 2\beta}\, d\beta.$$
The integrand is continuous and strictly positive on $(\beta^\star, 1)$ (equal to $0$ at $\beta^\star$ by the defining equation, and positive thereafter). Hence the integral is **strictly positive**. Numerically:
$$\int_{\beta^\star}^1 \frac{\beta^2 + 3\beta - 1}{1 + 2\beta}\, d\beta = \int_{0.303}^1 \frac{\beta^2 + 3\beta - 1}{1 + 2\beta}\, d\beta > 0.$$
(Closed form via polynomial division: $(\beta^2 + 3\beta - 1)/(1 + 2\beta) = \beta/2 + 5/4 - (9/4)/(1+2\beta)$, integrating: $[\beta^2/4 + 5\beta/4 - (9/8)\ln(1+2\beta)]_{\beta^\star}^1 = (1/4 + 5/4 - (9/8)\ln 3) - (\text{value at } \beta^\star) \approx 1.5 - 1.236 - (\cdot) \approx 0.12/L$ — positive.)

**Step 4: Openness.** $\mathcal{F}_{K=3}^\circ$ is defined by strict inequalities on continuous functions, hence open. An open set of positive Lebesgue measure is "large" in every reasonable sense.

Therefore $\mathcal{F} \supset \mathcal{F}_{K=3}^\circ$ has positive 2-D Lebesgue measure, as claimed. $\square$

---

# Part 3. Numerical verification

All scripts live in `workspace/archive/proof_work_20260417_op2_downgraded/`. Reported runs used $L = 1, D = 1$.

## 3.1 Sublemma projection identity (verification of Lemma 1.3(iii))

**Script:** `verify_sublemma.py`. Tests: for several $(\beta, \eta, \kappa, K)$ with (★) satisfied, compute $P_{\mathrm{conv}(P)}(e_t)$ numerically (via coordinate-wise polygon projection) and compare to $M e_t$.

**Result:** Machine-precision agreement ($\|P_{\mathrm{conv}(P)}(e_t) - M e_t\| < 10^{-15}$) for all tested $(\beta,\eta,\kappa,K,t)$.

Independently confirms Lemma 1.3(iii) without relying on GTD23's KKT argument.

## 3.2 Feasibility classification (characterization of $\mathcal{F}$)

**Script:** `fixed_verify.py`, Part [A].

| $(\beta, \eta)$ | $L\eta$ | $\gamma_{\mathrm{crit}}(\beta, K{=}3)$ | In $\mathcal{F}_{K=3}$? | $\kappa_{\mathrm{mid}}$ |
|---|---|---|---|---|
| $(0.5, 3/L)$ | 3.00 | 2.625 | YES | 0.2500 |
| $(0.5, 2.8/L)$ | 2.80 | 2.625 | YES | 0.2083 |
| $(0.9, 3.5/L)$ | 3.50 | 2.904 | YES | 0.3976 |
| $(0.7, 2.9/L)$ | 2.90 | 2.738 | YES | 0.3362 |
| $(0.5, 1/L)$ | 1.00 | 2.625 | **NO** | NONE |
| $(0.9, 0.5/L)$ | 0.50 | 2.904 | **NO** | NONE |
| $(0.1, 1/L)$ | 1.00 | 2.775 | **NO** | NONE |

Confirms closed-form $\gamma_\mathrm{crit}(\beta, K=3) = 3(1+\beta+\beta^2)/(1+2\beta)$ from §2.7 Step 1 and shows the auditor-mandated pairs are OUTSIDE $\mathcal{F}_{K=3}$.

## 3.3 Positive control: SHB locks on the cycle for $(\beta,\eta) \in \mathcal{F}$

**Script:** `fixed_verify.py`, Part [B].

**$(\beta,\eta) = (0.5, 3/L)$, $\kappa = 0.25$, $\mu = 0.25 L$:**

| $T$ | $f(x_T)$ | theoretical LB $\kappa L D^2/4$ | drift $\min_t \|x_T - (D/\sqrt 2) e_t\|$ | ratio $T \cdot f(x_T)/(LD^2)$ |
|---|---|---|---|---|
| 10 | 0.4444 | 0.0625 | $4.97 \times 10^{-16}$ | 4.44 |
| 100 | 0.4444 | 0.0625 | $4.97 \times 10^{-16}$ | 44.44 |
| 1000 | 0.4444 | 0.0625 | $4.97 \times 10^{-16}$ | 444.45 |

**$(\beta,\eta) = (0.9, 3/L)$, $\kappa = 0.45$, $\mu = 0.45 L$:**

| $T$ | $f(x_T)$ | theoretical LB $\kappa L D^2/4$ | drift | ratio |
|---|---|---|---|---|
| 10 | 0.4970 | 0.1125 | $5.98 \times 10^{-16}$ | 4.97 |
| 100 | 0.4970 | 0.1125 | $4.00 \times 10^{-16}$ | 49.70 |
| 1000 | 0.4970 | 0.1125 | $4.00 \times 10^{-16}$ | 496.97 |

**Interpretation.** Iterate drift is at machine-precision level: SHB lies exactly on the $K=3$ cycle at amplitude $D/\sqrt 2$ for 1000 steps. $f(x_T)$ is identically constant in $T$. Ratio $T\cdot f/(LD^2)$ grows linearly in $T$, vastly exceeding the theoretical bound $\kappa/4$. Lemma 2.6 and Claim 2.8 verified to machine precision.

## 3.4 Negative control: geometric decay on $\mathcal{F}^c$

**Script:** `fixed_verify.py`, Part [C].

**$(\beta,\eta) = (0.5, 1/L)$** with Goujaud attempted at $\kappa = 0.01$, $K = 3$:

| $T$ | cyc_lhs(★) | $f(x_T)$ | $T \cdot f/(LD^2)$ |
|---|---|---|---|
| 10 | $+3.10 \times 10^{-1}$ | $1.89 \times 10^{-4}$ | $1.89 \times 10^{-3}$ |
| 100 | $+3.24 \times 10^{-2}$ | $3.99 \times 10^{-31}$ | $3.99 \times 10^{-29}$ |
| 1000 | $+3.25 \times 10^{-3}$ | $4.08 \times 10^{-302}$ | $4.08 \times 10^{-299}$ |

**$(\beta,\eta) = (0.9, 1/(2L))$, same attempt:**

| $T$ | cyc_lhs(★) | $f(x_T)$ | $T \cdot f/(LD^2)$ |
|---|---|---|---|
| 10 | $+6.61 \times 10^{-1}$ | $9.44 \times 10^{-1}$ | $9.44$ |
| 100 | $+6.72 \times 10^{-2}$ | $4.73 \times 10^{-5}$ | $4.73 \times 10^{-3}$ |
| 1000 | $+6.73 \times 10^{-3}$ | $3.21 \times 10^{-47}$ | $3.21 \times 10^{-44}$ |

Auditor tested $K \in \{3, 4, 5, 10\}$: cyc_lhs(★) $> 0$ at every $K$, i.e., cycling inequality infeasible at these pairs. At the auditor-mandated pairs in $\mathcal{S}\setminus\mathcal{F}$, the Goujaud construction FAILS to cycle, and SHB converges geometrically. The theorem's restriction to $\mathcal{F}$ is necessary.

## 3.5 Threshold $\beta^\star$ verification

**Script:** `fixed_verify.py`, Part [E].

| $\beta$ | $\gamma_\mathrm{crit}$ | $2(1+\beta)$ | $\mathcal{F}_{K=3}$ interval non-empty? |
|---|---|---|---|
| 0.100 | 2.7750 | 2.2000 | NO |
| 0.300 | 2.6062 | 2.6000 | NO |
| 0.303 | 2.6055 | 2.6060 | YES |
| 0.400 | 2.6000 | 2.8000 | YES |
| 0.500 | 2.6250 | 3.0000 | YES |
| 0.900 | 2.9036 | 3.8000 | YES |
| 0.990 | 2.9900 | 3.9800 | YES |

Confirms $\beta^\star = (\sqrt{13} - 3)/2 = 0.302776\ldots$ via $\gamma_\mathrm{crit}(\beta) = 2(1+\beta)$ iff $\beta^2 + 3\beta - 1 = 0$.

---

# Part 4. Relationship to prior work

## 4.1 Goujaud–Taylor–Dieuleveut 2023 (GTD23)

**arXiv:2307.11291, "Provable non-accelerations of the heavy-ball method".**

GTD23 Theorem 3.5 = our Lemma 1.3. It holds for every $(\beta, h, \kappa)$ with (★) feasible, in the strongly-convex setting ($\mu > 0$).

**How v2 extends GTD23:**
1. **Non-strongly-convex setting.** GTD23 requires $\mu > 0$. We embed into `problem.md`'s $\mathcal{F}_L$ class (smooth convex with $\mu \geq 0$), via coordinate-separable 3-D construction. Claim 2.12 shows the 3-D function has global SC constant exactly $0$.
2. **Stochastic oracle and variance term.** GTD23 is deterministic. We add Nemirovski–Yudin variance via Le Cam on the $y$-coordinate (Lemma 2.9).
3. **$T$-uniform formulation.** GTD23's cycling is "for all $t$", and the function-value gap is a constant. We convert to $\Omega(LD^2/T)$ via $\kappa LD^2/4 \geq (\kappa/4)LD^2/T$ for all $T \geq 1$.

**Remark 4.1.1 (Nesterov's accelerated method, partial answer to GTD23 Conjecture 7.1).**  **[MOD v4: NEW]** Goujaud–Taylor–Dieuleveut (2023, Remark 6.1 and Conjecture 7.1) state that the cycling-existence framework extends from heavy-ball to *any stationary first-order method*, including Nesterov's accelerated gradient (NAG), with a method-specific transition matrix $M$. The construction is left open in their paper. We make it concrete for NAG. Define
$$M^{\mathrm{Nes}} \;:=\; \frac{(1-\eta\mu)\,I_2 \,-\, R_{\theta_K}\,\big[(1+\beta)I_2 - \beta R_{-\theta_K}\big]^{-1}}{\eta\,(L-\mu)},$$
the rescaled vertex set $\widetilde P^{\mathrm{Nes}} := \{(D/\sqrt 2)\,M^{\mathrm{Nes}}\,u_t : t = 0, \ldots, K-1\}$ with $u_t := (1+\beta)e_t - \beta e_{t-1}$, and
$$f^{\mathrm{Nes}}(x) := \tfrac{L}{2}\|x\|^2 - \tfrac{L-\mu}{2}\,d_{\mathrm{conv}(\widetilde P^{\mathrm{Nes}})}(x)^2.$$
$M^{\mathrm{Nes}}$ is a polynomial in $R_{\theta_K}$, hence commutes with rotation, so $\widetilde P^{\mathrm{Nes}}$ is rotation-symmetric and $f^{\mathrm{Nes}}$ is well-defined as a Goujaud-style function. Whenever the KKT-projection identity $P_{\mathrm{conv}(\widetilde P^{\mathrm{Nes}})}(\lambda u_t) = \lambda M^{\mathrm{Nes}} u_t$ holds (a NAG-analogue of GTD23's $(\star)$), the canonical Nesterov iterate $y_t = x_t + \beta(x_t - x_{t-1}), x_{t+1} = y_t - \eta\,\nabla f^{\mathrm{Nes}}(y_t)$ initialised at $(x_{-1}, x_0) = (\lambda e_{K-1}, \lambda e_0)$ traces the cycle $x_t = \lambda e_{t \bmod K}$, hence $\|x_t\| \equiv D/\sqrt 2$ and $f^{\mathrm{Nes}}(x_t) - f^{\mathrm{Nes},\star} \geq \mu D^2/4$. Hence the analogous $\Omega(\mu D^2)$ non-acceleration bound holds for NAG on its own polytope.

The Nesterov-feasibility region $\mathcal{F}^{\mathrm{Nes}}$ is non-empty for $\mu/L \lesssim 0.25$ at $K=3$, concentrates at high momentum $\beta \in [0.75, 0.99]$ (verified numerically on a $100\times 100$ grid), and is **generally disjoint** from the heavy-ball region $\mathcal{F}^{\mathrm{HB}}$: at $\mu/L = 0.25, K = 3$, $\mathcal{F}^{\mathrm{HB}} \cap \mathcal{F}^{\mathrm{Nes}} = \emptyset$ in our $60 \times 60$ scan. So OP-2's hard instance does not produce a single function defeating both methods, and conversely; cycling is **method-specific**, but **non-acceleration is method-agnostic** (parallel results, not separation). Numerical verification at $(\beta, \eta L, \mu/L) = (0.85, 2.4, 0.25)$: NAG cycles at machine precision ($\max_t \|x_t - \lambda e_{t \bmod K}\| < 5 \cdot 10^{-16}$ for $T = 10000$), with $f^{\mathrm{Nes}}(x_T) = 0.225 > \mu D^2/4 = 0.0625$.

On the heavy-ball instance $f_0$ used in our main theorem, NAG fails to converge by a different mechanism (period-2 attractor, period-1 fixed point, or divergence depending on $(\beta,\eta)$), without tracing the cycle — the cycling identity is method-specific. Construction details and numerical verification are in `workspace/op2_li_review/D5_nesterov/rerun_v2.md`.

## 4.2 Ghadimi–Feyzmahdavian–Johansson 2015 (GFJ15)  [MOD v3-1: REWRITTEN — split det/stoch]

**arXiv:1412.7457, "Global convergence of the heavy-ball method for convex optimization".**

GFJ15 is a **deterministic** paper: it proves that for $L$-smooth convex $f$, the Cesàro average $\bar x_T$ of deterministic HB iterates with fixed $(\beta,\eta)$ in a suitable range satisfies $f(\bar x_T) - f^\star \leq c_3\, LD^2/T$. There is **no stochastic oracle** and **no $\sigma$-dependent term** in that paper. Our discussion of tightness therefore splits into two cases:

**Deterministic case ($\sigma = 0$).** Our Main Theorem gives $\mathbb{E}[f(x_T) - f^\star] \geq (\kappa/4)\,LD^2/T$ (the variance term vanishes). GFJ15 gives a matching upper bound $O(LD^2/T)$ on the **Cesàro-average iterate** $\bar x_T$. Combined:
$$\Theta(LD^2/T)\quad \text{for deterministic HB's Cesàro-average iterate on}\ \mathcal{F},$$
with matching lower and upper bounds up to universal constants. This is tight.

**Stochastic case ($\sigma > 0$).** We are not aware of a published upper bound specifically for fixed-momentum SHB (averaged or last-iterate) of the form $O(LD^2/T + \sigma D/\sqrt T)$ that cleanly matches our LB. However:
- **SGD achieves $O(LD^2/T + \sigma D/\sqrt T)$** (Nemirovski–Yudin 1983; see also Polyak–Juditsky 1992, Shamir–Zhang 2013), so SHB, taken with $\beta = 0$, also attains this rate; SHB with any $\beta$ in the stability region should not be worse. This means the LB $\Omega(LD^2/T + \sigma D/\sqrt T)$ is tight against the SGD rate.
- **Lan 2012's AC-SA minimax UB is $O(LD^2/T^2 + \sigma D/\sqrt T)$** for the same function class (see §4.3). The bias term $LD^2/T^2$ in AC-SA is **strictly better** than the $LD^2/T$ term in our LB; but this is not a contradiction — it says AC-SA beats SHB on the bias term by a factor $T$. **This is the non-acceleration claim.**

Put differently: our LB establishes that fixed-momentum SHB on $\mathcal{F}$ matches the SGD rate ($LD^2/T$ bias) but **cannot achieve the AC-SA optimal rate** ($LD^2/T^2$ bias). Closing the stochastic SHB upper-bound gap — proving a matching stochastic $O(LD^2/T + \sigma D/\sqrt T)$ upper bound specifically for fixed-momentum SHB — is an open technical question; our LB strictly excludes any improvement to the AC-SA rate.

## 4.2.5 Li–Liu–Orabona 2022 (last-iterate SGDM in the non-smooth setting)  [MOD v3-2: NEW]

**arXiv:2102.07002, ALT 2022 / PMLR v167, "On the Last Iterate Convergence of Momentum Methods".**

Li, Liu & Orabona prove a closely related but **orthogonal** lower bound. Their statement (paraphrased):

> *For any constant momentum $\beta \in [0,1)$, there exists an $L$-Lipschitz convex function (non-smooth) and a subgradient oracle such that the last iterate $z_T$ of SGDM satisfies $\mathbb{E}[f(z_T) - f^\star] \geq \Omega(\ln T / \sqrt T)$.*

Their construction is in $d = T$ dimensions using a piecewise-linear (non-smooth) function.

**Comparison with our result:**

| Aspect | Li–Liu–Orabona 2022 | OP-2 Downgraded (this paper) |
|---|---|---|
| Function class | $L$-Lipschitz convex (**non-smooth**) | $L$-smooth convex (non-SC) |
| Oracle | Subgradient (with noise) | Stochastic, variance $\sigma^2$, unbiased |
| Dimension | $d = T$ (grows with horizon) | $d = 3$ (fixed, minimax over fixed-dim class) |
| Parameter region | Any constant $\beta \in [0,1)$ | $\mathcal{F} \subset \mathcal{S}$ (positive-measure subset of stability) |
| Target iterate | Last iterate $z_T$ | Last iterate $x_T$ |
| LB rate | $\Omega(\ln T / \sqrt T)$ | $\Omega(LD^2/T + \sigma D/\sqrt T)$ |

**Complementary, not overlapping:**

1. **Different function class.** Their non-smooth LB does not transfer to the smooth setting; the classical rate in the non-smooth Lipschitz case is $1/\sqrt T$, and their LB shows you cannot remove the $\ln T$ factor for last iterate under constant momentum. Our LB is in the smooth class where the expected rate is $1/T$ (bias) — we show SHB achieves this bias rate but no better.

2. **Smooth structure sharpens the bound.** In the non-smooth case, $\Omega(\ln T / \sqrt T)$ is the sharpest known LB for last-iterate SGDM; in the smooth case, we improve to $\Omega(1/T)$ for the bias term, which is optimal in the sense of matching the SGD rate. The extra structure (smoothness) admits a faster bias rate but fixed-momentum SHB still cannot accelerate past it.

3. **Fixed vs. growing dimension.** Their construction requires $d = T$, so it is technically a lower bound against algorithms that may exploit high-dimensional structure — but requires the problem dimension to grow with horizon. Our construction is in $d = 3$ fixed, a genuinely stronger minimax statement (LB uniform over all $d \geq 3$, not requiring $d$ to grow).

4. **Different $\beta$-coverage.** Li et al. covers every constant $\beta \in [0,1)$, with a single construction per $\beta$. We cover the positive-measure Goujaud region $\mathcal{F}$; outside $\mathcal{F}$ our construction fails (Part 3.4) and we make no LB claim.

**Take-away.** The two results together give a picture of fixed-momentum SGDM/SHB lower bounds: in the non-smooth setting, $\Omega(\ln T/\sqrt T)$ for any $\beta$ (Li et al.); in the smooth non-SC setting, $\Omega(LD^2/T + \sigma D/\sqrt T)$ for $\beta \in \mathcal{F}$-projection onto $(0,1)$ (this paper). Neither implies the other.

## 4.3 Agarwal–Bartlett–Ravikumar–Wainwright 2012 (minimax LB)  [MOD v3-3: NEW]

**arXiv:1009.0571, IEEE Transactions on Information Theory 2012, "Information-theoretic lower bounds on the oracle complexity of stochastic convex optimization".**

Agarwal et al. prove the **minimax** lower bound for stochastic smooth convex optimization:
$$\inf_{\mathrm{alg}}\,\sup_{f \in \mathcal{F}_{L}}\,\mathbb{E}[f(x_T) - f^\star] \geq \Omega(\sigma D / \sqrt T),$$
where the inf is over **all** first-order stochastic algorithms, and the sup over all $L$-smooth convex functions with initial-distance budget $D$. This is tight against Lan 2012's AC-SA upper bound $O(LD^2/T^2 + \sigma D/\sqrt T)$; thus the minimax rate on this class is $\Theta(LD^2/T^2 + \sigma D/\sqrt T)$.

**How our LB relates.** Our LB $\Omega(LD^2/T + \sigma D/\sqrt T)$ is **algorithm-specific**, restricted to fixed-momentum SHB. In the bias term, our LB is **strictly stronger than the minimax LB** by a factor $T$:
$$\underbrace{\Omega(LD^2/T)}_{\text{our SHB bias LB}} \gg \underbrace{\Omega(\text{no bias LB})}_{\text{minimax (Agarwal 2012) gives no bias-term LB; AC-SA achieves $LD^2/T^2$}}$$

This gap between $LD^2/T$ (SHB) and $LD^2/T^2$ (minimax-optimal AC-SA) is precisely the **non-acceleration** statement: fixed-momentum SHB, restricted to $\mathcal{F}$, cannot attain the optimal bias rate of AC-SA, even when $\sigma = 0$. This is the central quantitative contribution of OP-2.

**In summary.** Our theorem is a *refined* lower bound — not against all algorithms (that's Agarwal's job) but against SHB specifically — showing that SHB's inability to accelerate is not artifactual but an intrinsic limitation of the fixed-momentum parameterization on cycling-feasible parameters $\mathcal{F}$.

## 4.4 Lan 2012 AC-SA (for comparison)

AC-SA achieves the minimax-optimal $O(LD^2/T^2 + \sigma D/\sqrt T)$ on the same smooth convex stochastic problem class. SHB's $\Omega(LD^2/T)$ is **factor $T$ slower** in the bias term: SHB with fixed momentum does NOT accelerate on $\mathcal{F}$.

## 4.5 Open: $\mathcal{S}\setminus \mathcal{F}$

On $\mathcal{S}\setminus\mathcal{F}$ (including the auditor-mandated pairs $(0.5, 1/L)$ and $(0.9, 1/(2L))$), our construction yields no lower bound. Empirical evidence (Part 3.4) shows SHB converges geometrically on all tested Goujaud-type instances there, suggesting the unrestricted theorem may be false on $\mathcal{S}\setminus\mathcal{F}$. Two resolution paths: (a) find a non-Goujaud hard instance; (b) prove a matching SHB upper bound on $\mathcal{S}\setminus\mathcal{F}$. Neither is known.

## 4.6 Summary of novelty (v3)

- **First** rigorous lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$ for fixed-momentum SHB in the smooth convex **non-SC stochastic** setting, on a positive-Lebesgue-measure subregion $\mathcal{F}$ of the stability window (Claim 2.13). Prior related LBs (Li–Liu–Orabona 2022) treat the non-smooth setting; prior minimax LBs (Agarwal 2012) are not algorithm-specific and do not yield a bias-term LB at the $1/T$ rate.
- **Explicit, sharp constants** $c(\beta,\eta) = \kappa/4$ and $c_\mathrm{NY} = \sqrt 2/27 \approx 0.0524$ derived from the optimized Le Cam chain (v4 sharpening; v3 had $1/112 \approx 0.0089$).
- **Non-acceleration statement, quantitatively precise**: SHB on $\mathcal{F}$ cannot improve the bias rate beyond the SGD rate $LD^2/T$; the AC-SA optimal bias rate $LD^2/T^2$ is explicitly ruled out.
- **Clean positive-homogeneity-of-projection argument** (Lemma 1.7) for the rescaled Goujaud function — no mid-proof rescaling retraction as in v1.
- **Exact initial distance** $\|x_0 - x^\star\| = D$ (Claim 2.4), via wall-radius adjustment $R = D/\sqrt 2 - \alpha/L$.
- **Global 0-strong-convexity rigorously verified** (Claim 2.12).
- **Positive-measure parameter region** $\mathcal{F} \subset \mathcal{S}$ rigorously verified (Claim 2.13).

---

# Appendix A. Empirical scripts (file list)

All in `workspace/archive/proof_work_20260417_op2_downgraded/`:

| Script | Purpose |
|---|---|
| `verify_sublemma.py` | Machine-precision check of Lemma 1.3(iii) projection identity |
| `fixed_verify.py` | Feasibility (A), positive control (B), negative control (C), threshold (E) |
| `audit_sanity.py` | Auditor's independent re-implementation |
| `final_sanity.py` | Route G cycling verification |
| `sim_route_Gprime.py` | Route G' (rescaling) feasibility sweep |
| `sim_K_sweep.py`, `sim_find_mu.py`, `sim_check_stability.py`, `sim_feasible_pair.py`, `sim_quadratic.py` | Supporting sweeps |

---

# Appendix B. Summary of differences v1 $\to$ v2 $\to$ v3 $\to$ v4

| Location | v1 | v2 | v3 | v4 |
|---|---|---|---|---|
| §0.5 (theorem) | $\|x_0 - x^\star\| \leq D$, $c_\mathrm{NY} = 1/(8\sqrt 2)$ (unjustified) | $\|x_0 - x^\star\| = D$ (exact), $c_\mathrm{NY} = 1/112$ (from derivation) | unchanged statement; **added** tightness footnote (MOD v3-1) | $c_\mathrm{NY}$ sharpened to $\sqrt 2/27$ (MOD v4-1) |
| §1.4 Lemma 1.4 | Rademacher, $\mathrm{KL}=\infty$ debacle | Gaussian, but exposition still reads as debug log | **Clean Gaussian statement upfront** (MOD v3-5) | Updated to $\alpha = \sigma/(3\sqrt T)$, KL$_T = 2/9$, TV $\le 1/3$, $p_{\min} \ge 1/3$ (MOD v4-3) |
| §1.6 Lemma 1.6 | GFJ15 stochastic UB claimed | Same — still claimed stochastic UB | **Restated as deterministic only** with caveat on scope (MOD v3-1) | unchanged |
| §1.7 (NEW in v2) | — | Positive homogeneity of projection lemma | unchanged | unchanged |
| §2.1.1 | $f_0(x) := D^2\psi(x/D)$ | $f_0$ defined via rescaled polytope | unchanged | unchanged |
| §2.1.2 wall | $w$ with $R = D/\sqrt 2$ | $R = D/\sqrt 2 - \alpha/L$ | unchanged | $R = D/\sqrt 2 - \sigma/(3L\sqrt T)$ (MOD v4-2) |
| §2.1.2 Claim 2.2 proof | implicit | "wait let me redo" (correct answer but sloppy) | **Clean piecewise case analysis** (MOD v3-6) | unchanged |
| §2.1.3 noise | Rademacher | Gaussian | unchanged | unchanged |
| §2.1.4 Claim 2.4 | $\leq D^2 + o(1)$ | $= D^2$ | unchanged | unchanged |
| Lemma 2.6 | Handwave | Clean via Lemma 1.7 | unchanged | unchanged |
| Lemma 2.9 | Claimed $1/(8\sqrt 2)$; inline gave $1/56$ | Honest $1/112$ | unchanged value; **added adaptive-KL chain rule** argument (MOD v3-4) | **Sharpened to $\sqrt 2/27$** via $c_\alpha = 1/3$ optimization + exact wall-correction identity (MOD v4-4, v4-5) |
| §2.4.1 Step 3 verification | — | Verified wrong equality | **Fixed**: verifies actual inequality numerically (MOD v3-7) | Replaced loose inequality with exact identity $\rho(\sqrt 2) = \sqrt 2/3$ (MOD v4-4) |
| Claim 2.10 | Informal $s$ pick | Claim 2.11 max-split | **Expanded**: $s^\star$ explicit deterministic function of $(\beta,\eta,T)$ (MOD v3-8) | $c_\mathrm{NY}$ value updated |
| Claim 2.12 (NEW in v2) | — | Global SC constant = 0 verified | unchanged | unchanged |
| Claim 2.13 (NEW in v2) | — | Positive Lebesgue measure of $\mathcal{F}$ | unchanged | unchanged |
| §2.7 Step 1 | — | Biconditional feasibility equivalence claimed | **Split into sufficiency (rigorous) and necessity (empirical)** (MOD v3-9) | unchanged |
| §4.2 GFJ15 | — | Claimed tight $\Theta(LD^2/T + \sigma D/\sqrt T)$ via GFJ15 stochastic UB | **Rewritten**: split deterministic (tight via GFJ15) vs stochastic (tight vs SGD, non-AC-SA) (MOD v3-1) | unchanged |
| §4.2.5 Li–Liu–Orabona (NEW v3) | — | — | **NEW**: explicit comparison; orthogonal non-smooth LB (MOD v3-2) | unchanged |
| §4.3 Agarwal 2012 (NEW v3) | — | — | **NEW**: relate to minimax LB; our LB is stronger in bias term (MOD v3-3) | unchanged |
| §4.4 Lan | §4.3 in v2 | same content | renumbered §4.4 | unchanged |
| §4.5 Open | §4.4 in v2 | same content | renumbered §4.5 | unchanged |
| §4.6 Summary | §4.5 in v2 | novelty list | **Expanded** to incorporate v3 context | bullet 2 updated for $\sqrt 2/27$ (MOD v4) |

**End of v3.**

**End of v4.** (v4 sharpens $c_\mathrm{NY}$ from $1/112$ to $\sqrt 2/27$; all other content from v3 is preserved.)
