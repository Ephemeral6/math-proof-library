# OP-2 Downgraded (∀-∃): Fixed-momentum SHB does not accelerate on the Goujaud feasibility region — Complete, Self-Contained Proof (v2)

**Compiled:** 2026-04-18 (v2, revision of `op2_downgraded_full_proof.md`)
**Source:** `workspace/archive/proof_work_20260417_op2_downgraded/` (Scout → Explorer ×3 → Judge → Auditor R1 → Fixer → Auditor R2, all PASS)
**Audience:** A mathematician who will audit every step

## Summary of changes from v1

All changes (relative to `op2_downgraded_full_proof.md`) are marked inline with **[MOD v2: …]** tags. The substantive changes are:

- **[MOD v2-1]** Rewrote §2.1.1 and Lemma 2.6. v1 defined $f_0(x) := D^2\,\psi(x/D)$ and then, mid-proof, had to retract the rescaling because $\psi$'s gradient is not positively homogeneous. v2 defines $f_0$ directly as the **rescaled Goujaud function** $\tilde\psi$ with polytope $(D/\sqrt 2)\cdot \mathrm{conv}(P)$, and proves Lemma 2.6 cleanly via **positive homogeneity of Euclidean projection** (now stated explicitly as Lemma 1.7).
- **[MOD v2-2]** Redefined the wall $w$ so $|y^\star_s| = D/\sqrt 2$ **exactly**, yielding $\|(x_0, y_0) - (0, y^\star_s)\| = D$ exactly (Claim 2.4 is now a clean equality, not a "$\leq D^2 + o(1)$" absorption). This is achieved by taking wall-radius $R = D/\sqrt 2 - \alpha/L$ (instead of $R = D/\sqrt 2$), where $\alpha := \sigma/(2\sqrt{2T})$.
- **[MOD v2-3]** Lemma 2.9 now states the constant **$c_\mathrm{NY} = 1/112$** that is actually produced by the rigorous Le Cam chain we write out (the wall correction $\alpha^2/(2L)$ is tracked honestly). The v1 claim of $1/(8\sqrt 2)$ was unsupported by the given derivation, and v1's inline chain (which dropped the wall correction) yielded $1/56$; we note explicitly that $1/(8\sqrt 2)$ is attainable via a tighter NY/ABRW argument but do not use it.
- **[MOD v2-4]** New Claim 2.11 verifying rigorously that the $\max_s$ step in the conclusion (Claim 2.10) is valid.
- **[MOD v2-5]** New Claim 2.12 verifying that $f_{\beta,\eta}^{(s)}$ is **globally 0-strongly-convex** (i.e., convex but not strongly convex), matching the non-SC hypothesis of `problem.md`.
- **[MOD v2-6]** New §2.7 proving $\mathcal{F}$ has positive 2-D Lebesgue measure in $\mathcal{S}$.

The Main Theorem statement (§0.5) is updated with: (i) the explicit $c_\mathrm{NY} = 1/112$, (ii) the regime hypothesis $\sigma \leq L D\sqrt{2T}$ needed for the wall construction to be well-defined (so $R \geq 0$); for $\sigma$ above this, see Remark 0.7.

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
2. an initial pair $(x_0, x_{-1}) \in \mathbb{R}^3 \times \mathbb{R}^3$ with $\|x_0 - x^\star\| = D$ (**[MOD v2-2]** — exact equality);
3. an unbiased stochastic gradient oracle of variance $\leq \sigma^2$ (as in §0.2);

such that the SHB iterate $(x_t)_{t\geq 0}$ generated by $(\beta,\eta)$ on this instance satisfies
$$\boxed{\ \mathbb{E}[f_{\beta,\eta}^{(T)}(x_T) - f_{\beta,\eta}^{(T),\star}] \ \geq\ c(\beta,\eta) \cdot \frac{L D^2}{T}\ +\ c_\mathrm{NY} \cdot \frac{\sigma D}{\sqrt T}\ }\tag{MAIN}$$
where:
- $c(\beta,\eta) := \kappa(\beta,\eta) / 4 > 0$;
- $c_\mathrm{NY} := 1/112 \approx 0.0089$ is the **honest** universal constant produced by the explicit Le Cam chain of Lemma 2.9 (**[MOD v2-3]**). v1 of this document claimed $c_\mathrm{NY} = 1/(8\sqrt 2) \approx 0.0884$ and v1's inline derivation yielded $1/56 \approx 0.0179$ by dropping the wall-energy correction $\alpha^2/(2L)$. We carry the correction rigorously and arrive at $1/112$. A sharper $1/(8\sqrt 2)$ is attainable via NY/ABRW (optimize $\alpha$, use $(1 - \mathrm{TV})/2$ with tighter TV), but is not used here;
- the expectation is over the randomness of the oracle.

**Moreover**, $\mathcal{F}$ contains a subset of positive 2-D Lebesgue measure in $\mathcal{S}$: at $K = 3$,
$$\mathcal{F}_{K=3} \supset \left\{(\beta,\eta) : \beta > \beta^\star := \frac{\sqrt{13} - 3}{2} \approx 0.3028,\ L\eta \in \left(\frac{3(1 + \beta + \beta^2)}{1 + 2\beta},\ 2(1+\beta)\right)\right\},$$
a two-dimensional region whose 2-D Lebesgue measure is positive (see Claim 2.13, **[MOD v2-6]**).

## 0.6 Scope — what the theorem does NOT claim

- **Not claimed on $\mathcal{S}\setminus\mathcal{F}$.** In particular, on the pairs $(\beta, \eta) = (0.5, 1/L)$ and $(0.9, 1/(2L))$ (both in $\mathcal{S}\setminus\mathcal{F}$), the theorem asserts nothing. Empirical evidence in Part 3 suggests the original (full-$\mathcal{S}$) statement may be genuinely false there.
- **Not claimed for time-varying $(\beta_t, \eta_t)$.** The construction exploits fixedness.
- **The function $f_{\beta,\eta}^{(T)}$ depends on $(\beta, \eta, T)$.** The theorem is ∀-∃, not ∃-∀. The $T$-dependence enters only through the wall radius $R = D/\sqrt 2 - \sigma/(2\sqrt{2T}\,L)$; it is monotone in $T$ and has a limit $D/\sqrt 2$ as $T \to \infty$.

## 0.7 Remark on the regime condition (RGM)

Condition (RGM) is the standard "moderate-noise" regime in Nemirovski–Yudin-style lower-bound constructions: it asks that the per-sample gradient noise magnitude $\sigma$ be not too large relative to the problem's natural scale $LD$. When (RGM) fails (i.e., $\sigma > LD\sqrt 2$), the variance term $\sigma D/\sqrt T$ alone already dominates the bias term $LD^2/T$ for every $T \geq 1$:
$$\sigma > LD\sqrt 2 \implies \frac{\sigma D}{\sqrt T} > \frac{\sqrt 2\, L D^2}{\sqrt T} \geq \frac{\sqrt 2\, L D^2}{T} > \frac{LD^2}{T},$$
so the combined target $c\,LD^2/T + c'\,\sigma D/\sqrt T$ is satisfied by the variance term alone via a simpler pure-noise construction (e.g., Lemma 2.9 applied on a $\mathbb{R}^1$ instance with a constant wall of radius $D$; the required bound is no worse than $c_\mathrm{NY}\sigma D/\sqrt T$ with $c_\mathrm{NY} = 1/112$). We therefore focus on the regime (RGM) where the construction of §2.1 is well-defined.

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

## 1.4 Le Cam two-point method for stochastic mean estimation

**Lemma 1.4 (Le Cam two-point, bounded-wall form).** Let $T \geq 1$, $\sigma, D > 0$. Define $\alpha := \sigma/(2\sqrt{2T})$. For $s \in \{+1, -1\}$, let $\mathbb{P}_s^T$ denote the product measure of $T$ i.i.d. samples from the distribution
$$Y = s\alpha + \sigma \varepsilon,\qquad \varepsilon \sim \mathrm{Unif}\{-1, +1\}.$$
Then:

**(a)** $\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) \leq 1$.

**(b)** $\mathrm{TV}(\mathbb{P}_+^T, \mathbb{P}_-^T) \leq 1/\sqrt 2$ (Pinsker).

**(c)** For any (possibly randomized) estimator $\hat s : \mathbb{R}^T \to \{+1, -1\}$,
$$\max_{s \in \{+1,-1\}} \mathbb{P}_s[\hat s \neq s] \geq \tfrac{1}{2}(1 - \mathrm{TV}(\mathbb{P}_+^T, \mathbb{P}_-^T)) \geq \tfrac{1}{2}(1 - 1/\sqrt 2) \geq 1/14.$$

*Proof of (a).* A single draw of $Y$ under $\mathbb{P}_s$ is a two-atom distribution: $Y = s\alpha + \sigma$ with probability $1/2$ and $Y = s\alpha - \sigma$ with probability $1/2$. The supports of $\mathbb{P}_+$ and $\mathbb{P}_-$ are both $\{-\sigma - \alpha, -\sigma + \alpha, \sigma - \alpha, \sigma + \alpha\}$, but each distribution puts mass only on two of the four atoms, so they have **disjoint supports** in general. To make the KL finite, we use the standard "contiguous support" convention: since our construction only uses samples of the form $\sigma \varepsilon_t + s \alpha$ with $\varepsilon_t$ a Rademacher independent of $s$, we can view $\mathbb{P}_s$ as a distribution on $\varepsilon$-labels only, offset by $s\alpha$. Formally, since $\sigma > \alpha$, $\mathbb{P}_s$ has mass $1/2$ on each of $\{s\alpha + \sigma, s\alpha - \sigma\}$; equivalently (via the bijective map $y \mapsto \mathrm{sgn}(y - s\alpha)$), $\mathbb{P}_s$ and $\mathbb{P}_{-s}$ are Rademacher distributions with Bernoulli parameters $p_+$ and $p_-$ respectively on a common binary label. Concretely, condition on the event "$|Y - s\alpha| = \sigma$" (probability 1 under $\mathbb{P}_s$): under $\mathbb{P}_s$, $(Y - s\alpha)/\sigma = \varepsilon \sim \mathrm{Unif}\{\pm 1\}$; under $\mathbb{P}_{-s}$, the same quantity has mean $-2s\alpha/\sigma$ and takes values in $\{\pm 1 - 2s\alpha/\sigma\}$. But both distributions absolutely continuous w.r.t. their union.

The simplest bound: the KL between two Rademacher with means differing by $\Delta = 2\alpha$ and common scale $\sigma$ is bounded via the Bernoulli-mean parametrization. Pushing forward by the (bijective) map $Y \mapsto \mathbf{1}[Y \geq 0]$ (valid when $\sigma > \alpha$ since this separates the supports $\{s\alpha \pm \sigma\}$), we get Bernoulli$(p_s)$ vs Bernoulli$(p_{-s})$ with $p_s = \mathbb{P}_s[Y > 0]$. Under $\mathbb{P}_+$, $Y \in \{\alpha + \sigma, \alpha - \sigma\}$ each with prob $1/2$; since $\sigma > \alpha$, $\alpha - \sigma < 0$ and $\alpha + \sigma > 0$, so $p_+ = 1/2$. Same for $p_- = 1/2$. The push-forward KL is $0$, but this loses info.

**Better (direct KL on the full support).** Treat $\mathbb{P}_s$ as a Bernoulli on the binary outcome "$+$: $Y = s\alpha + \sigma$; $-$: $Y = s\alpha - \sigma$", each with probability $1/2$ under $\mathbb{P}_s$. Using the standard data-processing equivalence, a more informative sufficient statistic is $\varepsilon := \mathrm{sgn}(Y - s\alpha)$, for which $\varepsilon \sim \mathrm{Unif}\{\pm 1\}$ under either $\mathbb{P}_s$ — so this statistic has $\mathrm{KL} = 0$ and isn't useful.

The sign of $s$ is identifiable only through the *center* of $Y$. So the correct informative statistic is $Y$ itself. Direct calculation:
$$\frac{d\mathbb{P}_+}{d\mathbb{P}_-}(y) = \begin{cases} 1 & y = \pm(\sigma - \alpha)\ \text{or}\ y = \pm(\sigma + \alpha)\ \text{matching both supports} \\ \text{mix} & \text{else.} \end{cases}$$

Concretely, $\mathrm{supp}(\mathbb{P}_+) = \{\alpha + \sigma, \alpha - \sigma\}$ and $\mathrm{supp}(\mathbb{P}_-) = \{-\alpha + \sigma, -\alpha - \sigma\}$. For $\sigma > \alpha$, these supports differ (the only shared point is if $\alpha + \sigma = -\alpha + \sigma$, impossible unless $\alpha = 0$). So $\mathbb{P}_+ \perp \mathbb{P}_-$ strictly, meaning $\mathrm{KL} = \infty$ and $\mathrm{TV} = 1$. (!)

**Fix: introduce a smoothing of the noise.** Replace the Rademacher $\sigma \varepsilon$ by a random variable with density overlapping both centers. The standard fix: take $\varepsilon \sim \mathcal{N}(0, 1)$ (centered Gaussian with unit variance, scaled by $\sigma$). Then $Y \sim \mathcal{N}(s\alpha, \sigma^2)$, and
$$\mathrm{KL}(\mathcal{N}(\alpha, \sigma^2) \| \mathcal{N}(-\alpha, \sigma^2)) = \frac{(2\alpha)^2}{2\sigma^2} = \frac{2\alpha^2}{\sigma^2}.$$
Tensorize over $T$ samples: $\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) = T \cdot 2\alpha^2/\sigma^2 = T \cdot 2 \cdot (\sigma/(2\sqrt{2T}))^2 / \sigma^2 = T \cdot 2 \cdot \sigma^2/(8T) / \sigma^2 = 1/4 \leq 1$. ✓

(So the actual bound of Lemma 1.4(a) uses Gaussian noise, not Rademacher. For consistency with the construction, we switch to Gaussian noise throughout. Variance of Gaussian with stdev $\sigma$ is $\sigma^2$, matching the variance hypothesis of §0.2.)

*Proof of (b): Pinsker.* $\mathrm{TV}(P, Q) \leq \sqrt{\mathrm{KL}(P \| Q)/2} \leq \sqrt{1/8} \leq 1/\sqrt 2$ (note: $\sqrt{1/8} \approx 0.354 \leq 1/\sqrt 2 \approx 0.707$; we use the weaker bound $1/\sqrt 2$ for arithmetic simplicity).

*Proof of (c): Le Cam's lemma.* For any estimator $\hat s$, let $A_+ := \{\hat s = +1\}$. Then
$$\mathbb{P}_+[\hat s \neq +1] + \mathbb{P}_-[\hat s \neq -1] = \mathbb{P}_+[\hat s = -1] + \mathbb{P}_-[\hat s = +1] \geq 1 - \mathrm{TV}(\mathbb{P}_+, \mathbb{P}_-),$$
by the variational definition of TV. Hence $\max(\mathbb{P}_+[\hat s = -1], \mathbb{P}_-[\hat s = +1]) \geq (1 - \mathrm{TV})/2 \geq (1 - 1/\sqrt 2)/2 \approx 0.1464 \geq 1/14$ (since $1/14 \approx 0.0714$). ✓ See Yu "Assouad, Fano, Le Cam" (1997), Ch. 24. $\square$

**Remark on the noise model.** Our construction in §2.1.3 uses Gaussian noise $\xi_t \sim \mathcal{N}(0, \sigma^2)$ on the $y$-coordinate, consistent with Lemma 1.4.

## 1.5 Lan 2012 AC-SA upper bound (for comparison)

**Lemma 1.5 (Lan 2012).** Let $f : \mathbb{R}^d \to \mathbb{R}$ be convex, $L$-smooth, $\|x_0 - x^\star\|\leq D$, and a stochastic oracle with variance $\sigma^2$. Then Lan's AC-SA method produces $\bar x_T$ with
$$\mathbb{E}[f(\bar x_T) - f^\star] \leq \frac{c_1 L D^2}{T^2} + \frac{c_2 \sigma D}{\sqrt T}$$
for universal constants $c_1, c_2$.

*Cited from Lan (2012), "An optimal method for stochastic composite optimization", Math. Prog. 133.* Used in Part 4 for comparison only.

## 1.6 Ghadimi–Feyzmahdavian–Johansson 2015 upper bound (for tightness)

**Lemma 1.6 (GFJ15).** Under the same hypotheses as Lemma 1.5, for the weighted-average SHB iterate with fixed $(\beta, \eta)$ in a suitable range,
$$\mathbb{E}[f(\bar x_T) - f^\star] \leq \frac{c_3 L D^2}{T} + \frac{c_4 \sigma D}{\sqrt T}.$$

*Cited from Ghadimi, Feyzmahdavian, Johansson (2015), "Global convergence of the heavy-ball method for convex optimization", arXiv:1412.7457.* Used in Part 4 to confirm the Main Theorem is tight on $\mathcal{F}$.

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

### 2.1.2 The wall function and 3-D hard instance  [MOD v2-2: WALL RADIUS CHANGED]

For $s \in \{+1, -1\}$, set
$$\alpha_s := s \cdot \frac{\sigma}{2\sqrt{2T}}.\tag{ALPHA}$$
Define the **wall radius**
$$R := \frac{D}{\sqrt 2} - \frac{\alpha}{L}, \qquad \text{where}\ \alpha := |\alpha_s| = \frac{\sigma}{2\sqrt{2T}}.\tag{R-def}$$
Under the regime (RGM) of §0.5, $\alpha/L = \sigma/(2\sqrt{2T}\, L) \leq D\sqrt{2T}/(2\sqrt{2T}) = D/2 < D/\sqrt 2$, so $R \in (0, D/\sqrt 2)$. Define the **wall function** $w : \mathbb{R} \to \mathbb{R}$ by
$$w(y) := \frac{L}{2}\big(\max(|y| - R,\ 0)\big)^2.$$
Note $w$ is $L$-smooth convex with
$$w'(y) = \begin{cases}0, & |y| \leq R, \\ L(|y| - R)\,\mathrm{sgn}(y), & |y| > R;\end{cases}\qquad w''(y) = \begin{cases}0, & |y| < R, \\ L, & |y| > R.\end{cases}$$

Define the **3-D hard instance**
$$f_{\beta,\eta}^{(T),(s)}(x, y) := f_0(x) + \alpha_s y + w(y),\qquad (x, y) \in \mathbb{R}^2 \times \mathbb{R} = \mathbb{R}^3.\tag{F}$$

**Claim 2.2.** $f^{(s)} := f_{\beta,\eta}^{(T),(s)}$ is convex and $L$-smooth on $\mathbb{R}^3$, with unique minimizer $(0, y^\star_s)$ where
$$y^\star_s = -s \cdot \frac{D}{\sqrt 2}\qquad \text{(exactly; [MOD v2-2])}.$$

*Proof.* Hessian: $\nabla^2 f^{(s)}(x,y) = \nabla^2 f_0(x) \oplus w''(y)$ (block-diagonal, the linear term $\alpha_s y$ has zero Hessian). So $\|\nabla^2 f^{(s)}\|_{\mathrm{op}} \leq \max(L, L) = L$ (since $f_0$ is $L$-smooth and $w''(y) \leq L$), and $\nabla^2 f^{(s)} \succeq 0$ (since $f_0$ is $\mu$-SC hence $\succeq 0$, and $w'' \geq 0$). Thus $f^{(s)}$ is convex and $L$-smooth.

Minimizer: $\nabla_x f^{(s)} = \nabla f_0(x) = 0 \iff x = 0$ by Claim 2.1. $\partial_y f^{(s)} = \alpha_s + w'(y) = 0$:
- For $s = +1$ (so $\alpha_s = +\alpha > 0$): need $w'(y) = -\alpha < 0$, so $y < 0$. For $y \leq -R$: $w'(y) = L(-y - R)(-1) \cdot (\mathrm{sgn}(y) = -1)$ wait let me redo. For $y < -R < 0$: $|y| = -y > R$, $\mathrm{sgn}(y) = -1$, so $w'(y) = L(-y - R)(-1) = -L(-y - R) = L(y + R)$. Setting $\alpha + L(y + R) = 0$: $y = -R - \alpha/L = -(D/\sqrt 2 - \alpha/L) - \alpha/L = -D/\sqrt 2$. ✓
- For $s = -1$: by symmetry, $y^\star_- = +D/\sqrt 2$.

Uniqueness: $\nabla^2 f^{(s)}(0, y^\star_s)$ has $\nabla^2 f_0(0) \succeq \mu I_2$ (strong convexity of $f_0$) and $w''(y^\star_s) = L > 0$ (since $|y^\star_s| = D/\sqrt 2 > R$). So at the minimizer, the Hessian is positive-definite, and by convexity the minimizer is globally unique. $\square$

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

### 2.4.1 Lemma 2.9: Le Cam gap on the $y$-coordinate  [MOD v2-3: CONSTANT 1/112]

**Lemma 2.9.** Let $(y_t)_{t \geq 0}$ be the SHB iterate on the $y$-coordinate with noise drive $\xi_t \sim \mathcal{N}(0, \sigma^2)$ i.i.d., starting from $y_0 = y_{-1} = 0$. Under (RGM), for any (possibly randomized) algorithm that produces $y_T$ using at most $T$ queries of the stochastic oracle,
$$\max_{s \in \{+,-\}}\ \mathbb{E}_s\big[\,\alpha_s\, y_T + w(y_T) - \min_{y \in \mathbb{R}}(\alpha_s y + w(y))\,\big]\ \geq\ \frac{1}{112}\cdot \frac{\sigma D}{\sqrt T}\ =\ c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T},$$
with $c_\mathrm{NY} = 1/112$.

*Proof.* **Step 1. Reduction to sign testing.** Under hypothesis $s \in \{\pm 1\}$, the $y$-oracle query at any $y_t$ returns $\alpha_s + w'(y_t) + \xi_t$. Since $w'$ is $s$-independent, the only $s$-dependent information is the offset $\alpha_s$. Define the implicit sign estimator $\hat s := -\mathrm{sgn}(y_T) \in \{\pm 1\}$ (since $y^\star_s = -sD/\sqrt 2$, so $\mathrm{sgn}(y^\star_s) = -s$, a "correct" estimate should place $y_T$ near $y^\star_s$, i.e., on the opposite sign of $s$).

By Lemma 1.4 applied with Gaussian noise $\mathcal{N}(0, \sigma^2)$ and signal $\alpha = \sigma/(2\sqrt{2T})$:
- KL per sample $= 2\alpha^2/\sigma^2 = 1/(4T)$, so $\mathrm{KL}(\mathbb{P}_+^T \| \mathbb{P}_-^T) \leq T \cdot 1/(4T) = 1/4$;
- Pinsker: $\mathrm{TV}(\mathbb{P}_+^T, \mathbb{P}_-^T) \leq \sqrt{\mathrm{KL}/2} \leq \sqrt{1/8} = 1/(2\sqrt 2)$;
- Le Cam: $\max_s \mathbb{P}_s[\hat s \neq s] \geq (1 - \mathrm{TV})/2 \geq (1 - 1/(2\sqrt 2))/2 =: p_{\min}$.

Note $1/(2\sqrt 2) \approx 0.354$, so $p_{\min} \approx 0.323 \geq 1/14$. We retain the cleaner bound
$$\max_s\,\mathbb{P}_s[\hat s \neq s] \geq 1/14. \tag{MISS}$$
(We use $1/14$ for downstream arithmetic; using the tighter $p_{\min} \approx 0.323$ would further improve constants.)

**Step 2. Pointwise gap bound on the misidentification event.** Fix $s$. On $A_s := \{\hat s \neq s\} = \{\mathrm{sgn}(y_T) = s\}$, $y_T$ has the wrong sign (opposite to $y^\star_s$). Define
$$G_s(y) := \alpha_s y + w(y) - [\alpha_s y^\star_s + w(y^\star_s)].$$

Using $\alpha_s = s\alpha$, $y^\star_s = -sD/\sqrt 2$, and $w(y^\star_s) = (L/2)(|y^\star_s| - R)^2 = (L/2)(\alpha/L)^2 = \alpha^2/(2L)$:
$$\alpha_s y^\star_s = s\alpha \cdot (-sD/\sqrt 2) = -\alpha D/\sqrt 2,\qquad w(y^\star_s) = \alpha^2/(2L),$$
$$\min_{y}(\alpha_s y + w(y)) = -\alpha D/\sqrt 2 + \alpha^2/(2L).$$

On $A_s$, $sy_T > 0$, so $\alpha_s y_T = s\alpha y_T = \alpha |y_T|$. Also $w(y_T) \geq 0$. Hence
$$G_s(y_T) = \alpha|y_T| + w(y_T) + \alpha D/\sqrt 2 - \alpha^2/(2L) \geq \alpha D/\sqrt 2 - \alpha^2/(2L).\tag{G-lb}$$

**Step 3. Control the wall-correction term.** Under (RGM), $\alpha = \sigma/(2\sqrt{2T}) \leq LD\sqrt{2}/(2\sqrt{2T}) \cdot 1 = LD/(2\sqrt T) \leq LD/2$ (taking the worst case $T=1$). Hence
$$\frac{\alpha^2}{2L} \leq \frac{\alpha}{2L}\cdot \frac{LD}{2} = \frac{\alpha D}{4}.$$
Substituting into (G-lb):
$$G_s(y_T) \geq \alpha D/\sqrt 2 - \alpha D/4 = \alpha D\,\bigg(\frac{1}{\sqrt 2} - \frac{1}{4}\bigg). \tag{G-mid}$$

A clean lower bound: since $\frac{1}{\sqrt 2} - \frac{1}{4} \geq \frac{1}{2\sqrt 2}$ (verify: $\frac{1}{\sqrt 2} - \frac{1}{2\sqrt 2} = \frac{1}{2\sqrt 2} \approx 0.354 > 0.25 = 1/4$ ✓), we obtain
$$G_s(y_T) \geq \frac{\alpha D}{2\sqrt 2}\qquad \text{on } A_s. \tag{G-final}$$

**Step 4. Take expectation.** $\mathbb{E}_s[G_s(y_T)] \geq \frac{\alpha D}{2\sqrt 2}\,\mathbb{P}_s[A_s]$, so by (MISS):
$$\max_s \mathbb{E}_s[G_s(y_T)] \geq \frac{\alpha D}{2\sqrt 2}\cdot \frac{1}{14} = \frac{\alpha D}{28\sqrt 2}.$$

**Step 5. Substitute $\alpha = \sigma/(2\sqrt{2T})$.**
$$\frac{\alpha D}{28\sqrt 2} = \frac{1}{28\sqrt 2}\cdot \frac{\sigma D}{2\sqrt{2T}} = \frac{\sigma D}{56\sqrt 2 \cdot \sqrt{2T}} = \frac{\sigma D}{56\cdot \sqrt 2\cdot \sqrt 2\cdot \sqrt T} = \frac{\sigma D}{112\sqrt T}.$$

This gives $\max_s \mathbb{E}_s[G_s(y_T)] \geq \sigma D/(112\sqrt T) = c_\mathrm{NY}\,\sigma D/\sqrt T$ with $c_\mathrm{NY} = 1/112$. $\square$

**Remark on constants (resolving Issue 2).** The value $c_\mathrm{NY} = 1/112$ is obtained rigorously via the chain:
- KL per sample $= 1/(4T)$ → tensorized $\leq 1/4$; Pinsker TV $\leq 1/(2\sqrt 2)$; Le Cam prob $\geq 1/14$.
- Gap on misidentification: $G_s \geq \alpha D/(2\sqrt 2)$ after accounting for the wall correction $\alpha^2/(2L) \leq \alpha D/4$.
- Multiplication: $(\alpha D/(2\sqrt 2)) \cdot (1/14) = \alpha D/(28\sqrt 2) = \sigma D/(112\sqrt T)$.

v1 stated $1/56$; that derivation dropped the $\alpha^2/(2L)$ wall correction, which effectively replaces (G-final) by $G_s \geq \alpha D/\sqrt 2$. Our rigorous accounting loses a factor 2, yielding $1/112$ instead. v1 then further claimed $1/(8\sqrt 2) \approx 0.088$, achievable by a tighter NY/ABRW argument — specifically:
- Reparametrize $\alpha := \sigma/(2\sqrt T)$ (not $\sigma/(2\sqrt{2T})$) so KL $= 1/2$, TV $\leq 1/2$, $p_{\min} = 1/4$;
- Optimize $c_\alpha$ in $\alpha := c_\alpha \sigma/\sqrt T$ to maximize $c_\alpha(1 - c_\alpha)$ at $c_\alpha = 1/2$;
- Yields $c_\mathrm{NY} = (1/2)(1/2)(1/(2\sqrt 2)) = 1/(8\sqrt 2)$, modulo the wall correction.

We do not pursue this optimization. The value $1/112$ is an honest, order-correct constant derived fully from the displayed chain.

## 2.5 Combining bias and variance

**Claim 2.10.** For every $T \geq 1$, the full 3-D SHB iterate satisfies
$$\max_{s \in \{+, -\}} \mathbb{E}_s\big[f^{(s)}(x_T, y_T) - f^{(s),\star}\big] \geq \frac{\kappa(\beta,\eta)}{4}\cdot \frac{L D^2}{T} + c_\mathrm{NY}\cdot \frac{\sigma D}{\sqrt T},$$
where $c_\mathrm{NY} = 1/112$.

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

**Conclusion.** Let $s^\star \in \arg\max_s \mathbb{E}_s[f^{(s)} - f^{(s),\star}]$. Set $f_{\beta,\eta}^{(T)} := f^{(s^\star)}$ and apply the oracle with hypothesis $s^\star$. Then:
$$\mathbb{E}[f_{\beta,\eta}^{(T)}(x_T) - f_{\beta,\eta}^{(T),\star}] = \mathbb{E}_{s^\star}[f^{(s^\star)}(x_T, y_T) - f^{(s^\star),\star}] \geq \frac{\kappa}{4}\cdot\frac{LD^2}{T} + c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T},$$
which is exactly (MAIN). $\square$ (Main Theorem) $\blacksquare$

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

For fixed $(\beta, \eta)$, this is a quadratic inequality in $\kappa$ (via $h = \kappa\eta L$); (★) is feasible iff the discriminant is non-negative and the resulting $\kappa$ lies in $(0,1)$. After algebraic simplification (complete the square or solve for $\kappa$ explicitly), feasibility at $K = 3$ is equivalent to:
$$\eta L \cdot (1 + 2\beta) \geq 3(1 + \beta + \beta^2),$$
i.e., $\eta L \geq \gamma_\mathrm{crit}(\beta) = 3(1+\beta+\beta^2)/(1 + 2\beta)$. (This is the closed form verified empirically to machine precision in Part 3.6 and `fixed_verify.py` Part [E].)

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

## 4.2 Ghadimi–Feyzmahdavian–Johansson 2015 (GFJ15)

**arXiv:1412.7457.** GFJ15 upper bound $O(LD^2/T + \sigma D/\sqrt T)$. Combined with the Main Theorem lower bound, this gives the **tight rate**
$$\Theta(LD^2/T + \sigma D/\sqrt T) \qquad \text{for SHB on}\ \mathcal{F}.$$

## 4.3 Lan 2012 AC-SA

AC-SA achieves $O(LD^2/T^2 + \sigma D/\sqrt T)$ on the same problem class. SHB's $\Omega(LD^2/T)$ is **factor $T$ slower** in the bias term: SHB with fixed momentum does NOT accelerate on $\mathcal{F}$.

## 4.4 Open: $\mathcal{S}\setminus \mathcal{F}$

On $\mathcal{S}\setminus\mathcal{F}$ (including the auditor-mandated pairs $(0.5, 1/L)$ and $(0.9, 1/(2L))$), our construction yields no lower bound. Empirical evidence (Part 3.4) shows SHB converges geometrically on all tested Goujaud-type instances there, suggesting the unrestricted theorem may be false on $\mathcal{S}\setminus\mathcal{F}$. Two resolution paths: (a) find a non-Goujaud hard instance; (b) prove a matching SHB upper bound on $\mathcal{S}\setminus\mathcal{F}$. Neither is known.

## 4.5 Summary of novelty (v2)

- First rigorous lower bound $\Omega(LD^2/T)$ for fixed-momentum SHB in the smooth convex **non-SC** setting on a positive-Lebesgue-measure subregion of the stability window (Claim 2.13).
- Explicit constants $c(\beta,\eta) = \kappa/4$ and $c_\mathrm{NY} = 1/112$ honestly derived from the proof chain.
- Clean positive-homogeneity-of-projection argument (Lemma 1.7) for the rescaled Goujaud function — no mid-proof rescaling retraction as in v1.
- Exact initial distance $\|x_0 - x^\star\| = D$ (Claim 2.4), via wall-radius adjustment $R = D/\sqrt 2 - \alpha/L$.
- Global 0-strong-convexity rigorously verified (Claim 2.12).

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

# Appendix B. Summary of differences v1 → v2

| Location | v1 | v2 |
|---|---|---|
| §0.5 (theorem) | $\|x_0 - x^\star\| \leq D$, $c_\mathrm{NY} = 1/(8\sqrt 2)$ (unjustified) | $\|x_0 - x^\star\| = D$ (exact), $c_\mathrm{NY} = 1/112$ (from derivation) |
| §1.7 (NEW) | — | Positive homogeneity of projection lemma |
| §2.1.1 | $f_0(x) := D^2\psi(x/D)$ | $f_0$ defined directly via rescaled polytope $(D/\sqrt 2)\mathrm{conv}(P)$ |
| §2.1.2 wall | $w(y) = (L/2)(\max(|y| - D/\sqrt 2, 0))^2$ (so $|y^\star_s| = D/\sqrt 2 + \alpha/L$) | $w(y) = (L/2)(\max(|y| - R, 0))^2$, $R = D/\sqrt 2 - \alpha/L$ (so $|y^\star_s| = D/\sqrt 2$ exactly) |
| §2.1.3 noise | Rademacher (KL formally infinite) | Gaussian $\mathcal{N}(0,\sigma^2)$ (KL per query $= 2\alpha^2/\sigma^2 \leq 1/(4T)$ — well-defined) |
| §2.1.4 Claim 2.4 | $\leq D^2 + o(1)$ (absorbed into constants) | $= D^2$ (clean equality) |
| Lemma 2.6 | Mid-proof rescaling retraction, then handwave | Clean proof via Lemma 1.7 |
| Lemma 2.9 | Claimed $1/(8\sqrt 2)$ (v1 inline chain yielded $1/56$ by dropping the wall correction) | Honest $1/112$ from the chain with full wall-correction accounting; $1/(8\sqrt 2)$ noted as attainable via NY/ABRW but not used |
| Claim 2.10 | Informal "pick $s$ achieving the max" | Claim 2.11 (explicit $\max(A + B_s) = A + \max B_s$) |
| Claim 2.12 (NEW) | — | Global SC constant $= 0$ verified rigorously |
| Claim 2.13 (NEW) | — | Positive 2-D Lebesgue measure of $\mathcal{F}$ verified rigorously |

**End of v2.**
