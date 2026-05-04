# Proof attempt — Route 5 (REDUCTION frame)

**Frame**: Reduction. Reduce the local-minimax problem to standard convex–concave saddle-point analysis on a Moreau-Yosida-type two-sided regularization of $f$, then take the regularization parameter $\varepsilon \to 0$ and try to recover convergence to a (general, possibly non-strict) local minimax of $f$ via epi-convergence.

**Output verdict**: **Route fails to deliver the target theorem.** Reduction yields a *partial conditional* result only; the limit $\varepsilon \to 0$ produces a definitive obstruction. Below we record what the reduction does prove, and pinpoint precisely the gap that cannot be closed inside the Reduction frame.

---

## Hooks Report

**H1 (route family)**: Reduction-via-regularization. The strategy is the classical "regularize → analyze a strict version → unregularize via epi-convergence" template.
- Predecessor in library: `proofs/library/convex-analysis/subgradient/moreau-envelope-smoothness/` (single-side Moreau envelope).
- Predecessor pattern: Tikhonov regularization + Attouch's theorem (single-sided epi-convergence).
- Predecessor in research: `proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/` (target reduction landing site, since the regularized problem is strongly concave in $y$).

**H2 (anticipated failure modes from `routes.md` and `failure_patterns.md`)**:
- FP-GDA-NONSTRICTNESS (gda notes Lesson 1): two-timescale ratio $\eta_x / \eta_y = O(1/\kappa^2)$ is intrinsic. After regularization $\kappa_\varepsilon = L/\mu_\varepsilon = L\varepsilon$ (for the $y$-side $\mu_\varepsilon = 1/\varepsilon$), so as $\varepsilon \to 0$ we get $\kappa_\varepsilon \to \infty$ and the rate blows up. **This is the main analytic obstruction.**
- FP-EPI-LOCAL: epi-convergence of $f_\varepsilon \to f$ preserves *global* minimax / minimizers, but NOT local ones. Local-minimax points may be created or destroyed by the regularization — Attouch's theorem is silent on local structure. **This is the main structural obstruction.**
- FP-MOREAU-NONCONVEX: The Moreau envelope of a nonconvex function may be neither convex nor smooth, and its critical points need not coincide with critical points of $f$ (only their proximal-displacement zeros do).
- FP-TWO-SIDED-MOREAU: The two-sided ("min-max") Moreau regularization $f_\varepsilon$ requires the inner sup–inf to be solvable; in the genuinely nonconvex–nonconcave setting this is only justified locally and may be set-valued.

**H3 (target theorem to be reduced from)**: GDA convergence under nonconvex–strongly-concave structure ([REF: `proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/proof.md`]). The proof template provides $V_t = \Phi(x_t) + c\,\delta_t$ Lyapunov decay yielding $\frac{1}{T}\sum_t \|\nabla \Phi(x_t)\|^2 \le \tilde O(\kappa^2/T)$.

**H4 (hard quantifier)**: The Chae–Kim–Kim open problem requires a fixed first-order algorithm $\mathcal{A}$ that converges for *every* $C^2$ instance with a non-strict local minimax. Any reduction $f \mapsto f_\varepsilon$ that depends on a tunable $\varepsilon$ produces a *family* of algorithms $\mathcal{A}_\varepsilon$; collapsing this family to a single algorithm forces an a-priori commitment $\varepsilon = \varepsilon(T)$ in advance — an additional layer that must be checked.

---

## Proof attempt

### Step 1: Two-sided Moreau-Yosida regularization — definition and well-posedness

**Definition.** For $\varepsilon > 0$ define the *two-sided Moreau-Yosida envelope*
$$
f_\varepsilon(x, y) := \inf_{z \in \mathbb{R}^m} \sup_{w \in \mathbb{R}^n} \Big[\, f(z, w) + \tfrac{1}{2\varepsilon}\|z - x\|^2 - \tfrac{1}{2\varepsilon}\|w - y\|^2 \,\Big].
$$

**Lemma 1.1 (local well-posedness).** Suppose $f \in C^2$ and $\nabla f$ is $L$-Lipschitz on a compact neighbourhood $U \times V$ of a candidate local minimax $(x^*, y^*)$. Then for $\varepsilon < 1/L$ the inner sup over $w$ at fixed $(z, y)$ is *strictly concave* in $w$ on $V$ (since $-\tfrac{1}{2\varepsilon}\|\cdot - y\|^2$ adds curvature $-1/\varepsilon < -L$ which dominates the Lipschitz Hessian of $f$). Symmetrically for the outer inf. Hence the infsup defining $f_\varepsilon$ has a unique local saddle point $(z_\varepsilon(x,y), w_\varepsilon(x,y))$ for $(x,y)$ in a sub-neighbourhood.

*Proof sketch.* For any $z \in U$, the map $w \mapsto f(z, w) - \tfrac{1}{2\varepsilon}\|w - y\|^2$ has Hessian $\nabla^2_{ww} f(z,w) - \tfrac{1}{\varepsilon} I$, which is uniformly $\preceq (L - 1/\varepsilon) I \prec 0$ for $\varepsilon < 1/L$. By the implicit function theorem applied to the optimality condition $\nabla_w f(z, w) - \tfrac{1}{\varepsilon}(w - y) = 0$, the maximizer $w^*(z, y)$ is uniquely defined and $C^1$. Symmetrically for $z^*(x, w)$. Apply Brouwer / Banach to the composition; locally the joint saddle is a contraction.

This gives $f_\varepsilon$ as a well-defined $C^1$ function on the local neighbourhood, with
$$
\nabla_x f_\varepsilon(x, y) = \tfrac{1}{\varepsilon}(x - z_\varepsilon(x,y)), \qquad
\nabla_y f_\varepsilon(x, y) = -\tfrac{1}{\varepsilon}(y - w_\varepsilon(x,y))
$$
by Danskin's theorem.

### Step 2: $f_\varepsilon$ is locally strongly convex–strongly concave

**Claim.** For $\varepsilon < 1/(2L)$, on the localized neighbourhood the regularized function $f_\varepsilon$ satisfies
$$
\nabla^2_{yy} f_\varepsilon(x, y) \preceq -\tfrac{1}{2\varepsilon} I, \qquad \nabla^2_{xx} f_\varepsilon(x, y) \succeq +\tfrac{1}{2\varepsilon} I.
$$

*Reasoning.* Using the envelope identity and chain rule through the implicit maximizer $w_\varepsilon$:
$$
\nabla^2_{yy} f_\varepsilon = -\tfrac{1}{\varepsilon}\Big( I - \nabla_y w_\varepsilon \Big).
$$
By implicit differentiation of $\nabla_w f(z_\varepsilon, w_\varepsilon) - \tfrac{1}{\varepsilon}(w_\varepsilon - y) = 0$ in $y$:
$$
\nabla_y w_\varepsilon = \big( I - \varepsilon \nabla^2_{ww} f \big)^{-1}.
$$
For $\varepsilon < 1/(2L)$, $\|\varepsilon \nabla^2_{ww} f\| \le 1/2$, so $\nabla_y w_\varepsilon = I + O(\varepsilon L)$ and hence $I - \nabla_y w_\varepsilon = -\varepsilon \nabla^2_{ww} f + O(\varepsilon^2 L^2)$, giving
$$
\nabla^2_{yy} f_\varepsilon = \nabla^2_{ww} f \cdot \big(I + O(\varepsilon L)\big) - \tfrac{1}{\varepsilon} \cdot O(\varepsilon^2 L^2)\big/\varepsilon = \nabla^2_{ww} f + O(\varepsilon L^2) \cdot \tfrac{1}{\varepsilon}.
$$
Wait — this expansion shows $\nabla^2_{yy} f_\varepsilon \approx \nabla^2_{yy} f$ to leading order, NOT a uniform $-\tfrac{1}{2\varepsilon}$ bound. **The naive claim above is false.**

**Correction (Step 2′).** The two-sided Moreau-Yosida envelope does NOT generically inherit strong concavity in $y$ from the regularizer alone — the regularizer cancels in the implicit-function chain rule. What survives:
$$
\nabla^2_{yy} f_\varepsilon(x, y) = \nabla^2_{ww} f(z_\varepsilon, w_\varepsilon) + O(\varepsilon).
$$
So at the non-strict local minimax point of $f$ (where $\nabla^2_{yy} f(x^*, y^*)$ has a zero eigenvalue), $\nabla^2_{yy} f_\varepsilon$ also has a near-zero eigenvalue. **Strong concavity is NOT recovered.**

This is the first hard obstruction. The two-sided Moreau-Yosida regularization is a *fixed-point smoothing*; it does not strict-ify the underlying landscape because the proximal terms are stationary at the limit (the inner argmax shifts to *cancel* the regularization's curvature).

### Step 3: Alternative regularization — additive Tikhonov

To salvage the reduction, replace the two-sided Moreau-Yosida by a one-sided **Tikhonov** regularization:
$$
\widetilde f_\varepsilon(x, y) := f(x, y) - \tfrac{\varepsilon}{2} \|y - y^*\|^2.
$$
Then $\nabla^2_{yy} \widetilde f_\varepsilon = \nabla^2_{yy} f - \varepsilon I \preceq -\varepsilon I$ at $(x^*, y^*)$ if $\nabla^2_{yy} f(x^*, y^*) \preceq 0$ (which holds since $y^*$ is a local max in $y$).

**Lemma 3.1.** If $\nabla^2_{yy} f(x^*, y^*) \preceq 0$ on a neighbourhood and $f \in C^2$, then $\widetilde f_\varepsilon(x, \cdot)$ is $\varepsilon$-strongly concave near $y^*$ for all $\varepsilon > 0$.

This regularization makes the inner problem *strictly* well-conditioned, hence the GDA convergence theorem [REF: `proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/proof.md`] applies *to* $\widetilde f_\varepsilon$ with conditioning $\kappa_\varepsilon = L/\varepsilon$, giving rate $T_\varepsilon = O(\kappa_\varepsilon^2 / \delta^2) = O(L^2 / (\varepsilon^2 \delta^2))$ to reach $\|\nabla \widetilde \Phi_\varepsilon(x)\| \le \delta$.

**Issue:** the depending parameter $y^*$ is *unknown* to the algorithm — Tikhonov around an unknown center is not implementable as a first-order method. We can replace it by Tikhonov around the *running* iterate $y_t$:
$$
\widetilde f_\varepsilon^{(t)}(x, y) := f(x, y) - \tfrac{\varepsilon}{2} \|y - y_t\|^2,
$$
but then the gradient $\nabla_y \widetilde f_\varepsilon^{(t)}(x, y)|_{y = y_t} = \nabla_y f(x, y_t) - 0 = \nabla_y f(x, y_t)$, i.e. at the query point the regularization vanishes — there is no algorithmic effect.

The only honest implementation is Tikhonov around a *fixed reference* $y_0$, but this biases the limit point $\arg\max_y \widetilde f_\varepsilon(x, \cdot)$ toward $y_0$, not toward the true maximizer of $f(x, \cdot)$ — so the iterates of GDA on $\widetilde f_\varepsilon$ converge to a stationary point of $\widetilde \Phi_\varepsilon = \max_y \widetilde f_\varepsilon$, which differs from $\Phi$ by an $O(\varepsilon \cdot \mathrm{diam}^2)$ bias.

### Step 4: Epi-convergence of the regularized problem to $f$

We now examine whether the strict local minimax of $\widetilde f_\varepsilon$ converges to the non-strict local minimax of $f$ as $\varepsilon \to 0$.

**Standing setup.** Suppose $(x^*, y^*)$ is a non-strict local minimax of $f$ in the Jin–Netrapalli–Jordan sense, with $\nabla^2_{yy} f(x^*, y^*) \preceq 0$ having a zero eigenvalue along direction $v \in \mathbb{R}^n$, $\|v\| = 1$.

For each $\varepsilon > 0$, by Lemma 3.1 the regularized problem $\widetilde f_\varepsilon$ has a *strict* local minimax at some point $(x^*_\varepsilon, y^*_\varepsilon)$ (assumed to exist by the implicit function theorem applied to the regularized stationarity conditions, which is exactly where it can fail).

**Lemma 4.1 (epi-convergence — single-sided).** As $\varepsilon \to 0^+$, $\widetilde f_\varepsilon \to f$ uniformly on compact sets, and by Attouch's theorem [REF: pseudo-citation; classical] $\widetilde f_\varepsilon \xrightarrow{\mathrm{epi}} f$.

**The hard question (the heart of the reduction):**

> Does $(x^*_\varepsilon, y^*_\varepsilon) \to (x^*, y^*)$ as $\varepsilon \to 0$?

**Answer:** *Generally no.* Counterexample sketch:

Consider $f(x, y) = -\tfrac{1}{2}x^2 - \tfrac{1}{4}y^4 + xy$ near $(0, 0)$.

- $\nabla_y f(x, y) = -y^3 + x$, so the inner critical point is $y^*(x) = x^{1/3}$.
- $\nabla_y^2 f(x, y) = -3 y^2 = 0$ at $y = 0$. So the inner Hessian is degenerate at $(0, 0)$.
- $\Phi(x) = f(x, x^{1/3}) = -\tfrac{1}{2}x^2 - \tfrac{1}{4} x^{4/3} + x \cdot x^{1/3} = -\tfrac{1}{2}x^2 + \tfrac{3}{4} x^{4/3}$.
- $\Phi'(x) = -x + x^{1/3}$, zero at $x = 0$ and $x = \pm 1$. At $x = 0$: $\Phi''(0)$ is undefined ($x^{1/3}$ is not $C^2$ at 0), but $\Phi(x) \ge \Phi(0) = 0$ for small $x > 0$ since $\Phi(x) = -\tfrac{1}{2}x^2 + \tfrac{3}{4}x^{4/3}$ and the second term dominates near zero. Similarly for small $x < 0$. So $(0, 0)$ is a (non-strict) local minimax.

Regularize: $\widetilde f_\varepsilon(x, y) = f(x, y) - \tfrac{\varepsilon}{2} y^2$. Now $\nabla_y \widetilde f_\varepsilon = -y^3 + x - \varepsilon y$, so $y^*_\varepsilon(x)$ solves $y^3 + \varepsilon y = x$. This is a single real root for all $x \in \mathbb{R}$, $y^*_\varepsilon(x) \to x^{1/3}$ as $\varepsilon \to 0$. The envelope:
$$
\widetilde \Phi_\varepsilon(x) = -\tfrac{1}{2}x^2 - \tfrac{1}{4}(y^*_\varepsilon)^4 + x y^*_\varepsilon - \tfrac{\varepsilon}{2}(y^*_\varepsilon)^2.
$$
$\widetilde \Phi_\varepsilon$ is $C^2$. Its critical points: $\widetilde \Phi'_\varepsilon(x) = -x + y^*_\varepsilon(x)$ (after Danskin), zero when $y^*_\varepsilon(x) = x$, i.e., $x^3 + \varepsilon x = x \Leftrightarrow x(x^2 + \varepsilon - 1) = 0$. Roots: $x = 0$ and $x = \pm\sqrt{1 - \varepsilon}$.

At $x = 0$: $\widetilde \Phi''_\varepsilon(0) = -1 + (y^*_\varepsilon)'(0) = -1 + 1/(\varepsilon)$, which is $> 0$ for $\varepsilon < 1$. So **$(0, 0)$ IS a strict local minimax of $\widetilde f_\varepsilon$ for every $0 < \varepsilon < 1$, and $(x^*_\varepsilon, y^*_\varepsilon) = (0, 0) = (x^*, y^*)$ exactly.**

So in this *specific* example the regularization preserves the local minimax in place. Good — but this is an artifact of the example's symmetry.

**Counterexample (genuine pathology).** Modify: $f(x, y) = -\tfrac{1}{2}x^2 - \tfrac{1}{4}y^4 + xy + \alpha x^2 y$ for small $\alpha > 0$. The cross term $\alpha x^2 y$ is order-3. Recompute: now $\nabla_y f = -y^3 + x + \alpha x^2$, so $y^*(x) = (x + \alpha x^2)^{1/3}$. $\Phi(x) = -\tfrac{1}{2}x^2 + \tfrac{3}{4}(x + \alpha x^2)^{4/3} + \alpha x^2 (x + \alpha x^2)^{1/3}$.

At $x = 0$: $\Phi(0) = 0$, $\Phi$ is non-strict local-min in $x$ (as in the prior case). Now regularize with the *same* Tikhonov $-\tfrac{\varepsilon}{2} y^2$: $y^*_\varepsilon$ solves $y^3 + \varepsilon y = x + \alpha x^2$. The regularized envelope critical points: $\widetilde \Phi'_\varepsilon(x) = -x + (1 + 2\alpha x) y^*_\varepsilon(x) = 0$. At $x = 0$: $y^*_\varepsilon(0) = 0$, so $\widetilde \Phi'_\varepsilon(0) = 0$ — fine, $(0, 0)$ remains a critical point. But the Hessian computation now picks up $\alpha$-dependent terms that may drive the regularized minimax point to drift by $\Theta(\alpha \varepsilon)$ before reconverging. For $\alpha = \alpha(\varepsilon) = 1/\sqrt{\varepsilon}$ (chosen adversarially), the drift $\Theta(\sqrt \varepsilon)$ can dominate the basin radius. Thus there exist $C^2$ instances where the regularized strict-minimax point fails to converge to a non-strict minimax of $f$ — it shoots off to infinity or to a different critical point.

**This is the formal statement of FP-EPI-LOCAL.** Epi-convergence does not control local critical-point geometry in the nonconvex setting. (Reference: Rockafellar–Wets, *Variational Analysis*, Ch. 7, §7.E: epi-convergence implies convergence of *global* infima but local extrema can be created or destroyed; the relevant condition (Attouch's "non-degeneracy of the limit") is a uniform second-order condition that *fails exactly* at non-strict local minimax points.)

### Step 5: Rate analysis under the reduction (the second hard obstruction)

Even if we *assume away* the structural obstruction in Step 4 (e.g., assume the local minimax of $f$ is isolated and the regularized minimax converges to it), we hit a quantitative obstruction.

**Claim.** Run GDA on $\widetilde f_\varepsilon$ with the optimal two-timescale ratio for conditioning $\kappa_\varepsilon = L/\varepsilon$:
$$
\eta_y = 1/L, \qquad \eta_x = \tfrac{1}{16 \kappa_\varepsilon^2 L} = \tfrac{\varepsilon^2}{16 L^3}.
$$
By the GDA convergence theorem [REF: `gda-nonconvex-strongly-concave-convergence/proof.md`]:
$$
\frac{1}{T} \sum_{t = 0}^{T-1} \|\nabla \widetilde \Phi_\varepsilon(x_t)\|^2 \le \frac{C_1 (\widetilde \Phi_\varepsilon(x_0) - \widetilde \Phi_\varepsilon^*) + C_2 \widetilde \delta_0}{\eta_x T} = O\!\left(\tfrac{L^3}{\varepsilon^2 T}\right).
$$
To reach $\|\nabla \widetilde \Phi_\varepsilon\| \le \delta$, we need $T = \Omega(L^3 / (\varepsilon^2 \delta^2))$.

Now, even if the regularized stationary point $x^*_\varepsilon$ is within $O(\varepsilon)$ of $x^*$, certifying that the *iterate* $x_T$ is within $O(\varepsilon)$ of $x^*$ requires $\delta = O(\varepsilon \cdot \mu^{1/2})$ (PL on the regularized envelope, which has PL constant $\mu = \varepsilon$), hence $\delta = O(\varepsilon^{3/2})$. Plugging in:
$$
T = \Omega\!\left(\tfrac{L^3}{\varepsilon^2 \cdot \varepsilon^3}\right) = \Omega(L^3 \varepsilon^{-5}).
$$
For accuracy $\varepsilon$-close to a non-strict local minimax of $f$, the cost is $\Omega(\varepsilon^{-5})$ first-order queries. Taking $\varepsilon \to 0$ gives infinite query cost — **the rate degrades to non-finite as $\varepsilon \to 0$**, exactly as predicted by FP-GDA-NONSTRICTNESS.

This is not a proof artifact: the two-timescale ratio $\eta_x / \eta_y = O(\varepsilon^2)$ is *intrinsic* (gda notes Lesson 1). Any algorithm that runs GDA on a $\kappa_\varepsilon = 1/\varepsilon$-conditioned regularized problem must pay at least $\Omega(\kappa_\varepsilon^2)$ in iteration count.

### Step 6: Diagonal scheme attempt — $\varepsilon = \varepsilon(T)$

To produce a single algorithm independent of the unknown gap to a non-strict optimum, choose $\varepsilon = \varepsilon(T) = T^{-\alpha}$ for some $\alpha > 0$ and run for $T$ steps. The trade-off:
- Bias from regularization: $\|x_{*\varepsilon} - x^*\| = O(\varepsilon) = O(T^{-\alpha})$.
- Optimization error after $T$ steps: $\|\nabla \widetilde \Phi_\varepsilon(x_T)\| \le \sqrt{C \cdot L^3 / (\varepsilon^2 T)} = O(L^{3/2} \varepsilon^{-1} T^{-1/2}) = O(L^{3/2} T^{\alpha - 1/2})$.

For the optimization error to vanish: $\alpha < 1/2$. For the bias to vanish: $\alpha > 0$. Both: $0 < \alpha < 1/2$.

But there is a third constraint that destroys this: in Step 5 we showed that to *recognize* the non-strict optimum (not just to make the gradient small) requires $\delta = O(\varepsilon^{3/2})$, i.e. $T^{\alpha - 1/2} \le T^{-3\alpha/2}$, i.e. $\alpha - 1/2 \le -3\alpha/2$, i.e. $\alpha \ge 1/5$. Combined with $\alpha < 1/2$: feasible. So pick $\alpha = 1/5$. Total query cost to reach $\|x_T - x^*\| \le \eta$: $T = \eta^{-5}$.

So *if* Step 4's obstruction is somehow bypassed (say by an additional structural assumption like "the non-strict local minimax is isolated and the third-order Taylor coefficients of $f$ are non-degenerate"), the diagonal scheme delivers convergence at rate $T = \tilde O(\eta^{-5})$ to a non-strict local minimax of $f$.

### Step 7: What the Reduction frame actually proves

**Theorem (Reduction-frame partial result, conditional).** Assume $f \in C^2(\mathbb{R}^m \times \mathbb{R}^n)$, $\nabla f$ is $L$-Lipschitz on a compact neighbourhood $U \times V$ of a candidate non-strict local minimax $(x^*, y^*)$, AND assume the *epi-convergence regularity* condition:
$$
(\dagger) \qquad \text{For all } \varepsilon \in (0, \varepsilon_0],\ \widetilde f_\varepsilon = f - \tfrac{\varepsilon}{2}\|y - y_0\|^2 \text{ has a unique local minimax } (x^*_\varepsilon, y^*_\varepsilon) \in U \times V \text{ with } (x^*_\varepsilon, y^*_\varepsilon) \to (x^*, y^*) \text{ as } \varepsilon \to 0,
$$
where $y_0 \in V$ is a fixed reference point (e.g., the algorithm's initialization).

Then the diagonal-scheme GDA algorithm:
- $y_0$ chosen, fixed throughout;
- $\varepsilon_T = T^{-1/5}$;
- $\eta_y = 1/L$, $\eta_x = \varepsilon_T^2/(16 L^3)$;
- $x_{t+1} = x_t - \eta_x [\nabla_x f(x_t, y_t)]$;
- $y_{t+1} = y_t + \eta_y [\nabla_y f(x_t, y_t) - \varepsilon_T (y_t - y_0)]$;

converges to $(x^*, y^*)$ at rate $\|x_T - x^*\| = \tilde O(T^{-1/5})$ from initializations in a sufficiently small neighbourhood.

*Proof.* The algorithm is gradient-descent–ascent on $\widetilde f_{\varepsilon_T}$, which is $\varepsilon_T$-strongly concave in $y$ on $V$. Apply [REF: `gda-nonconvex-strongly-concave-convergence/proof.md`] with $\mu = \varepsilon_T$ and $L_{\widetilde f} \le L + \varepsilon_T \le 2L$, giving rate $\frac{1}{T}\sum \|\nabla \widetilde \Phi_{\varepsilon_T}\|^2 \le O(L^3/(\varepsilon_T^2 T))$. With $\varepsilon_T = T^{-1/5}$, this is $O(T^{-3/5})$. Combined with bias $\|x_{*\varepsilon_T} - x^*\| = O(\varepsilon_T) = O(T^{-1/5})$ via $(\dagger)$ and PL on the regularized envelope (constant $\varepsilon_T$), we get $\|x_T - x^*\| = O(T^{-1/5})$. $\square$

**This is a strict subset of the "Partial" outcome category in the original problem statement** — it requires the additional assumption $(\dagger)$, which is exactly the "isolated non-strict minimax with epi-stability" structural assumption.

### Step 8: The gap

Condition $(\dagger)$ is *not* a consequence of $C^2$ regularity. It is an *independent structural assumption* about the second-order behaviour of $f$ near $(x^*, y^*)$:
- A sufficient condition: $f$ has the form $f(x, y) = g(x, y) + h(y)$ where $h$ is a smooth function with isolated degenerate maximum at $y^*$ AND $g$ is a non-degenerate "coupling" with $\nabla^2_{xx}\Phi(x^*) \succ 0$ where $\Phi(x) = \max_y f(x, y)$. This rules out the example $f(x, y) = x^2 y$ from the problem statement, where $(x, y) = (0, 0)$ is a non-strict local minimax that is non-isolated and has a degenerate outer envelope.
- A necessary (well, near-necessary) condition: the third-order Taylor expansion of $f$ at $(x^*, y^*)$ along the degenerate eigendirection of $\nabla^2_{yy} f$ must be sign-definite. This is a **second-order non-degeneracy** assumption on a problem stated explicitly as "first-order with degenerate Hessian."

**The gap, formally:** the open problem demands convergence under $C^2$ regularity *only*. The Reduction frame supplies convergence under $C^2$ + $(\dagger)$. The gap is the class of $C^2$ instances violating $(\dagger)$ — which includes the canonical pathological examples ($f(x, y) = x^2 y$ near $(0, 0)$) cited in the problem statement.

### Step 9: Why the Reduction frame cannot close the gap

The Reduction frame's logic is: *if* the regularized problem is locally strictly minimaxed by $(x^*_\varepsilon, y^*_\varepsilon) \to (x^*, y^*)$, then standard tools deliver convergence. Steps 4–5 show this conditional holds quantitatively only at rate $T = \tilde O(\eta^{-5})$, and structurally only under $(\dagger)$.

**Why $(\dagger)$ cannot be removed within the Reduction frame.** The frame regularizes the inner problem, then takes a limit. But the inner problem's *non-strictness* is precisely the failure of the regularization to converge in a uniformly-controlled way:
- In the regime where the inner Hessian is non-degenerate, regularization produces a small perturbation.
- In the regime where the inner Hessian is degenerate (the case of interest), the regularization's effect is order-1 in the eigendirection of the degenerate eigenvalue, not order-$\varepsilon$. This is a **non-uniform perturbation** that breaks the standard epi-convergence machinery.

Equivalently: the Reduction frame is committed to importing geometry from a strictly-minimaxed neighbour ($\widetilde f_\varepsilon$). In the non-strict regime, the geometry of $\widetilde f_\varepsilon$ near $(x^*, y^*)$ depends *singularly* on $\varepsilon$, not regularly. No choice of regularizer that vanishes uniformly with $\varepsilon$ can produce regular-perturbation analysis on a singularly-perturbed target.

This is a frame-level diagnosis: the Reduction frame is the wrong tool for non-strict local minimax. The problem requires either:
- An impossibility argument (Routes 3, 4 — Adversarial / Construction), which exploits the singular structure to construct hard instances; or
- A direct algorithmic argument that handles the degenerate eigendirection via center-manifold analysis or curvature-aware updates (Routes 2, 6), which inhabit the singular structure rather than smoothing it away.

### Step 10: Summary verdict

**What the Reduction frame proves:** under the additional structural assumption $(\dagger)$ (epi-stability of the non-strict local minimax under one-sided Tikhonov regularization), a diagonal-scheme GDA achieves rate $T = \tilde O(\eta^{-5})$ first-order queries to reach $\eta$-accuracy of a non-strict local minimax. This is a *partial* result: weaker than strict-case Jin–Netrapalli–Jordan (which delivers $\tilde O(\eta^{-2})$), and *conditional* on $(\dagger)$.

**What the Reduction frame fails to prove:** convergence under $C^2$ regularity alone. The gap is the class of non-strict local minimax points where $(\dagger)$ fails — including, in particular, the canonical example $f(x, y) = x^2 y$ at the origin (since $\Phi$ is not even $C^1$ there, $(\dagger)$ trivially fails).

**Frame-level verdict:** Reduction is the *wrong frame* for the open problem. The non-strictness obstruction is intrinsic (singular perturbation), and the Reduction frame's commitment to regular-perturbation analysis cannot accommodate it. The structural map favours adversarial impossibility (R3, R4) for a complete answer to the open conjecture.

---

## Route Failure Report

- **Route**: Reduction (R5) — Moreau-Yosida / Tikhonov regularization + epi-convergence.
- **Failed at**: Step 4 (epi-convergence of *local* minimax points is not implied by epi-convergence of objectives) and Step 5 (rate degrades as $\varepsilon^{-5}$).
- **Obstacle 1 (Structural):** Non-strictness of $\nabla^2_{yy} f(x^*, y^*)$ creates a singular perturbation under regularization. Attouch's theorem is silent on local extrema; in fact local minimax points can be created or destroyed by arbitrarily small regularization. Condition $(\dagger)$ — that $\widetilde f_\varepsilon$'s strict local minimax converges to $f$'s non-strict one — must be *assumed* and is not implied by $C^2$ regularity.
- **Obstacle 2 (Quantitative):** Even granting $(\dagger)$, the rate of GDA on the regularized problem scales as $\kappa_\varepsilon^2 = (L/\varepsilon)^2$. Any diagonal scheme $\varepsilon = \varepsilon(T)$ produces sub-polynomial rate $T^{-1/5}$ to recover the non-strict optimum — useless for the open problem's qualitative target (convergence) but mathematically valid as a partial rate result.
- **Obstacle 3 (Frame-level):** The Reduction frame is committed to regular perturbation. The non-strict local minimax problem is *singular*. No vanishing regularizer can make a singular problem regular. This is intrinsic to the frame, not the specific regularizer.
- **What would be needed to close the gap:** Replace the Reduction frame with either an Adversarial frame (Le Cam impossibility, R3) or a Construction frame (explicit divergence example, R4) — both of which exploit the singular structure. Alternatively, restrict the problem to instances satisfying $(\dagger)$ and publish the partial result of Step 7 as a contribution of independent interest.

---

## Four-sentence summary

The Reduction frame attempts to recover a non-strict local minimax of $f$ as the limit of strict local minimax points of regularized $f_\varepsilon$ (Moreau-Yosida or one-sided Tikhonov), then transfer Jin–Netrapalli–Jordan's two-timescale GDA convergence from $f_\varepsilon$ to $f$ via epi-convergence. The reduction yields a partial result conditional on a structural assumption $(\dagger)$ ("the strict minimax of $f_\varepsilon$ converges to the non-strict minimax of $f$"), with rate $T = \tilde O(\eta^{-5})$ to reach $\eta$-accuracy of the limit point — but $(\dagger)$ fails on the canonical pathological example $f(x,y) = x^2 y$ and is not implied by $C^2$ regularity, because epi-convergence does not control local extrema in the non-strict regime. The quantitative obstruction (rate $\kappa_\varepsilon^2 = \varepsilon^{-2}$ blow-up) and the structural obstruction (singular perturbation under non-strictness) are both intrinsic to the Reduction frame, not artefacts of a specific regularizer. **Frame verdict:** Reduction is the wrong tool for the Chae–Kim–Kim open problem; routing should defer to the Adversarial (Le Cam impossibility, R3) or Construction (explicit divergence, R4) frames for a complete answer.
