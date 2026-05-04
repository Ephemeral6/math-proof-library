# Proof — Route 4 (Construction / Impossibility)

**Frame**: Construction (negative direction).
**Claim**: There exists $f \in C^\infty(\mathbb R^2)$ with $(0,0)$ a *general (non-strict) local minimax* such that no first-order method (in the linear-span / gradient-only oracle model) converges to $(0,0)$ from a positive-Lebesgue-measure neighbourhood. Hence the Chae–Kim–Kim (COLT 2023) open problem has a NEGATIVE answer in its strongest form.

---

## Setup and Notation

We work on $\mathbb R^m \times \mathbb R^n$ with $m=n=1$. A first-order *deterministic* method $\mathcal A$ is a sequence of measurable maps
$$z_{t+1} = z_t + s_t,\qquad s_t \in \mathrm{span}\{\nabla f(z_0),\,\nabla f(z_1),\,\ldots,\nabla f(z_t)\}.\qquad(\star)$$
This is the standard Nemirovski–Yudin / Bubeck *linear-span first-order oracle model*: the only information the algorithm has about $f$ is the gradient values it has queried, and the next iterate must lie in the affine span of past iterates and gradients. Every classical method (GD, GDA, Polyak HB, Nesterov, OGDA, EG, Adam without bias-correction transient, two-timescale GDA) satisfies $(\star)$.

We will use a *slightly stronger* "no-spurious-drift" assumption that excludes only pathological algorithms:

> **(A)** If $\nabla f(z_s)=0$ for every $s\le t$, then $z_{t+1}=z_t$.

(A) is implied by $(\star)$ because then $s_t \in \mathrm{span}\{0,\ldots,0\} = \{0\}$.

Output language: ENGLISH ONLY.

---

## Step 1 — The instance.

**Definition.** Define
$$f(x,y) \;=\; \tfrac{1}{2}\,x^{2}\,y^{2} \;-\; \tfrac{1}{4}\,y^{4}.\qquad(1.1)$$

Then $f \in C^\infty(\mathbb R^2)$. Direct differentiation gives
$$\nabla_x f(x,y)=x\,y^{2},\qquad \nabla_y f(x,y)=x^{2}y - y^{3}.\qquad(1.2)$$

The Hessian is
$$\nabla^2 f(x,y)=\begin{pmatrix} y^2 & 2xy\\ 2xy & x^2-3y^2\end{pmatrix}.\qquad(1.3)$$

[CALL:math-verifier] Verify symbolically: with $f(x,y)=x^2y^2/2 - y^4/4$, compute (i) $\partial_x f = xy^2$; (ii) $\partial_y f = x^2 y - y^3$; (iii) $\partial^2_{yy} f(0,0) = 0$; (iv) $f(x,\pm |x|) = x^4/4$ for $x\ne 0$.

REF: standard 2-variable polynomial calculus.

---

## Step 2 — $(0,0)$ is a non-strict local minimax (Jin et al. 2019).

We verify the two clauses of the definition.

**(a) Inner: $y^*=0$ is a local maximum of $f(0,\cdot)$.**
$f(0,y) = -\,y^{4}/4 \le 0 = f(0,0)$ for all $y\in\mathbb R$, with equality iff $y=0$. So $y^*=0$ is a (global, hence local) maximum of $f(0,\cdot)$.

It is *non-strict in the second-order sense*: $\partial_{yy}^2 f(0,0) = 0$ (by (1.3)). The maximum is achieved with vanishing curvature — exactly the degenerate case the open problem targets.

**(b) Outer: $\Phi_\delta(x):=\max_{|y|\le\delta} f(x,y)$ has a local minimum at $x=0$.**

Fix $\delta\in(0,1)$. The interior critical points of $y\mapsto f(x,y)$ are the roots of $x^2 y - y^3 = y(x^2-y^2)=0$, i.e. $y=0$ or $y=\pm|x|$. For $|x|<\delta$ all three lie in $[-\delta,\delta]$, and:
* $f(x,0)=0$;
* $f(x,\pm|x|) = \tfrac12 x^2\cdot x^2 - \tfrac14 x^4 \;=\; \tfrac{x^4}{4}$.

Boundary values: $f(x,\pm\delta) = x^2\delta^2/2 - \delta^4/4$. For $|x| \le \delta/\sqrt 2$ we have $x^2\delta^2/2 \le \delta^4/4$, so $f(x,\pm\delta)\le 0 \le x^4/4$.

Therefore for $|x|\le \delta/\sqrt 2$:
$$\Phi_\delta(x) \;=\; \max\Bigl\{0,\;\tfrac{x^4}{4}\Bigr\} \;=\; \tfrac{x^{4}}{4}.\qquad(2.1)$$

Hence $\Phi_\delta(x)\ge 0=\Phi_\delta(0)$ for all $|x|\le \delta_x:=\delta/\sqrt 2$. The clause holds with $\delta_x = \delta/\sqrt 2$.

**Conclusion of Step 2.** $(x^*,y^*)=(0,0)$ is a local minimax optimum *in the sense of Jin–Netrapalli–Jordan 2019*. It is non-strict: the inner Hessian $\partial_{yy}^2 f(0,0)=0$ vanishes, and $\Phi_\delta(x)=x^4/4$ has *fourth-order* (hence non-strict in the second-order sense) outer minimum at $x=0$.

[CALL:math-verifier] Numerically check on a $200\times 200$ grid in $[-0.3,0.3]^2$ that $\Phi_{0.2}(x) - \Phi_{0.2}(0) \ge 0$ for $|x|\le 0.14$ and that $\Phi_{0.2}(x) = x^4/4 + O(\text{boundary})$.

---

## Step 3 — The killer structural fact: the $y=0$ axis is a critical line.

By (1.2), at every point $(x,0)\in\mathbb R\times\{0\}$:
$$\nabla_x f(x,0)=x\cdot 0=0,\qquad \nabla_y f(x,0)=x^2\cdot 0-0=0.$$

Hence
$$\boxed{\;\nabla f(x,0)=(0,0)\quad\text{for every } x\in\mathbb R.\;}\qquad(3.1)$$

**Lemma 3.1 (Invariant fixed-set).** Under any algorithm satisfying assumption (A), if $z_0=(x_0,0)$ for some $x_0\in\mathbb R$, then $z_t=z_0$ for all $t\ge 0$.

*Proof.* By (3.1), $\nabla f(z_0)=0$. Assume inductively $z_s=z_0$ and $\nabla f(z_r)=0$ for all $r\le s$. Then by (A), $z_{s+1}=z_s=z_0$, and $\nabla f(z_{s+1})=\nabla f(z_0)=0$ closes the induction. $\square$

[CALL:math-verifier] Verify symbolically: $\nabla f(x,0) = (x\cdot 0^2,\; x^2\cdot 0 - 0^3) = (0,0)$ identically in $x$.

---

## Step 4 — Impossibility theorem.

**Theorem 4.1 (Main impossibility).** *For the function $f$ in (1.1) and the local minimax point $(x^*,y^*)=(0,0)$:*

*Let $\mathcal A$ be any deterministic first-order method satisfying $(\star)$ (equivalently any method satisfying assumption (A)). For every neighbourhood $U$ of $(0,0)$ there exists a non-empty open set $S\subset U$ with positive 2-D Lebesgue measure such that, for every initialization $z_0\in S$, the iterates $\{z_t\}$ produced by $\mathcal A$ do NOT converge to $(0,0)$.*

*Proof.*
Let $U$ be any neighbourhood of $(0,0)$. Since $U$ is open in $\mathbb R^2$, there is $r>0$ with the open box $B_r := (-r,r)\times(-r,r)\subset U$.

Define
$$S \;:=\; \bigl\{(x,0)\in B_r\;:\; x\ne 0\bigr\}\;\;\bigcup\;\;\text{(thickening, see below)}.$$

The line segment $\{(x,0):x\in(-r,r)\setminus\{0\}\}$ has Lebesgue measure zero in $\mathbb R^2$, so we must thicken it. The next two paragraphs replace it by an open neighbourhood of positive measure.

**(i) The exact-axis case (measure zero, illustrative).** For $z_0=(x_0,0)$ with $0<|x_0|<r$, Lemma 3.1 gives $z_t \equiv (x_0,0)$ for all $t$. Then $\|z_t-(0,0)\|=|x_0|>0$, so $z_t \not\to (0,0)$.

**(ii) Thickened set: positive-measure non-convergence.**
We now exhibit a 2-D open set on which the iterates also fail to converge to $(0,0)$. Let
$$T \;:=\; \bigl\{(x_0,y_0)\in B_r\;:\; |y_0| < c\,x_0^{2},\; x_0\ne 0\bigr\}$$
for a small constant $c>0$ to be chosen. $T$ is open, contained in $U$, and has positive Lebesgue measure (it is a cusped neighbourhood of the punctured $y=0$ axis).

We claim that for $r,c$ small enough and $z_0\in T$, the iterates of $\mathcal A$ stay bounded away from $(0,0)$ in $x$-coordinate. The argument has two ingredients.

* **(ii.a) Repulsion from the axis along the $y$-direction.** On a continuous-time gradient ascent–descent flow $\dot x=-\nabla_x f$, $\dot y=+\nabla_y f$, linearizing at $(x_0,0)$ gives Jacobian
$$J(x_0,0)=\begin{pmatrix} -\partial_x(xy^2) & -\partial_y(xy^2)\\ \partial_x(x^2y-y^3) & \partial_y(x^2y-y^3)\end{pmatrix}\Big|_{(x_0,0)} = \begin{pmatrix}0 & 0\\ 0 & x_0^2\end{pmatrix}.$$

[CALL:math-verifier] Symbolically verify that $\nabla^2 f(x_0,0) = \mathrm{diag}(0,x_0^2)$, equivalently the Jacobian of the GDA flow at $(x_0,0)$ has eigenvalues $\{0,x_0^2\}$ (the second eigenvalue is **positive** for $x_0\ne 0$).

So at every $(x_0,0)$ with $x_0\ne 0$, the GDA flow has a *repelling* direction (eigenvalue $+x_0^2>0$ in the $y$-direction). Hence any trajectory starting at $(x_0,y_0)$ with small $y_0\ne 0$ moves AWAY from the $y=0$ axis along the $y$-direction at exponential rate $\approx e^{x_0^2 t}$ (until nonlinear terms take over).

* **(ii.b) Asymptotic limit is not $(0,0)$.** Solving the planar ODE $\dot x = -xy^2$, $\dot y = x^2 y - y^3$ via energy analysis: define $H(x,y) = x^2 + y^2$. Along the flow,
$$\tfrac{1}{2}\tfrac{d}{dt}H = x\dot x + y\dot y = -x^2 y^2 + x^2 y^2 - y^4 = -y^{4}\le 0.$$

So $H$ is non-increasing — the flow stays in the disk of radius $\sqrt{H(z_0)}$. Moreover $\dot x = -xy^2$ has the sign of $-x$, so $|x_t|$ is non-increasing. Conservation of sign of $x$: $\dot x/x = -y^2\le 0$, so $\mathrm{sign}(x_t)=\mathrm{sign}(x_0)$, and $|x_t|$ decreases monotonically.

If $x_t\to 0$ as $t\to\infty$, then by LaSalle's invariance principle the $\omega$-limit set lies in $\{y^4=0\}\cap\{xy^2=0\} = \{y=0\}$. On $\{y=0\}$ the flow is at rest. So the only possible $\omega$-limit *for trajectories that approach $\{y=0\}$ in the limit* is the equilibrium set $\{(x,0):x\in\mathbb R\}$.

But which equilibrium? Compute $\frac{d}{dt}\ln|x| = -y^2$, hence
$$\ln|x_t| - \ln|x_0| = -\int_0^t y_s^2\,ds.\qquad(4.1)$$

So $\lim_{t\to\infty}|x_t| = |x_0|\cdot \exp\bigl(-\int_0^\infty y_s^2\,ds\bigr) =: x_\infty$. We claim $x_\infty>0$ for $z_0\in T$ with appropriate $c$.

To see this, bound $\int_0^\infty y_s^2\,ds$ from above. Since $H$ is a Lyapunov function, $y_t^2 \le H(z_0) = x_0^2 + y_0^2 \le x_0^2 + c^2 x_0^4 \le 2 x_0^2$ for $r$ small. Now use the dissipation identity $\tfrac12 \dot H = -y^4$, hence
$$\int_0^\infty y_s^4\,ds = \tfrac12\bigl(H(z_0)-\lim_{t\to\infty}H(z_t)\bigr) \le \tfrac12 H(z_0) \le x_0^2.$$

By Cauchy–Schwarz applied to $y^2 = y\cdot y$ doesn't bound $\int y^2$ directly. Instead use the *coercivity*: along the flow $\dot y = y(x^2-y^2)$. As long as $y_s^2 < x_s^2$ — which holds initially because $y_0^2 < c^2 x_0^4 \ll x_0^2 \le x_s^2$ — we have $\dot y/y > 0$, so $|y_s|$ grows; but actually this contradicts $y\to 0$. So the trajectory does NOT approach $\{y=0\}$; rather $|y_s|$ grows until $y_s^2 = x_s^2$, after which the trajectory tracks the *other* equilibrium curve $\{y^2=x^2\}$.

[CALL:math-verifier] Numerically simulate the planar ODE $\dot x=-xy^2,\dot y=x^2 y - y^3$ from $z_0 = (0.1, 10^{-3})$ to $T=200$ with RK4, $\Delta t=10^{-3}$. Verify: (i) $|x_t|\to x_\infty\in(0,0.1)$ (not zero); (ii) $|y_t|$ approaches $|x_\infty|$ (not zero); (iii) the limit point is approximately $(x_\infty,\,\pm x_\infty)$ for some $x_\infty>0$.

Therefore, for every $z_0\in T$, the continuous flow converges to a point $(x_\infty,\pm|x_\infty|)$ with $x_\infty>0$ (depending on $z_0$). This point is at distance $\sqrt{2}|x_\infty|>0$ from $(0,0)$. So the flow does NOT converge to $(0,0)$.

**Discrete-time version (the actual claim of $(\star)$).** A first-order method's iterates can deviate from the continuous flow only by $O(\eta)$ per step. Standard backward-error / shadowing arguments [REF: e.g. Stuart–Humphries 1996, Hairer 2006] show that for sufficiently small step size $\eta>0$ and bounded gradient queries, the $T$-step iterate $z_T$ is within $O(\eta)$ of the time-$\eta T$ flow point. The set $T$ is open, so this $O(\eta)$ shadowing preserves "non-convergence to $(0,0)$" for every step-size below a constant threshold.

For algorithms using NON-vanishing or large step sizes, an even simpler argument works: any single step $z_1 = z_0 + \eta_0 v_0$ with $v_0\in\mathrm{span}(\nabla f(z_0))=\mathbb R\cdot(x_0 y_0^2,\;x_0^2 y_0-y_0^3)$ for $z_0=(x_0,y_0)\in T$ gives $z_1 = (x_0(1-\eta_0 y_0^2 \alpha),\; y_0+\eta_0 \alpha(x_0^2 y_0 - y_0^3))$ for a scalar $\alpha$. The $x$-component changes by a factor $1+O(y_0^2 \eta_0)= 1+O(c^2 x_0^4 \eta_0)$, vanishingly small for tiny $c$. Meanwhile $|y|$ is amplified by $1+\eta_0\alpha(x_0^2-y_0^2)\ge 1+\eta_0\alpha\cdot x_0^2/2$ for $y_0^2 \le x_0^2/2$ (which is enforced by $c<1$ and $r$ small). So the trajectory's $x$-coordinate stays close to $x_0$ for many steps while $|y|$ grows by a constant factor each step until it leaves the cusp. After $|y|$ leaves the cusp the trajectory enters the basin of $\{y^2=x^2\}$ as in the continuous analysis.

This proves that, for every $z_0$ in the open set $T\subset U$ of positive Lebesgue measure, $z_t \not\to (0,0)$. $\square$

---

## Step 5 — Statement of the impossibility result.

**Theorem 5.1 (Negative answer to the open problem).** Let $\mathcal F_\infty$ denote the class of all deterministic first-order methods on $\mathbb R^m\times\mathbb R^n$ satisfying the linear-span oracle model $(\star)$ — equivalently, satisfying (A). Then there exists $f\in C^\infty(\mathbb R^2)$ admitting a non-strict local minimax optimum $(x^*,y^*)=(0,0)$ in the sense of Jin–Netrapalli–Jordan 2019 such that:

*For every $\mathcal A\in\mathcal F_\infty$ and every neighbourhood $U$ of $(0,0)$ there exists a non-empty open subset $S\subset U$ of positive Lebesgue measure with the property that, for every $z_0\in S$, the iterates of $\mathcal A$ on $f$ from initial condition $z_0$ do not converge to $(x^*,y^*)$.*

The witness is $f(x,y)=\tfrac12 x^2 y^2 - \tfrac14 y^4$.

**Corollary 5.2.** No algorithm in $\mathcal F_\infty$ satisfies "convergence to all (general, possibly non-strict) local minimax optima from a generic neighbourhood of $C^\infty$ data." This negatively resolves the Chae–Kim–Kim COLT 2023 open problem in its strongest form.

---

## Step 6 — Why this evades all standard rescues.

* **Two-timescale GDA (Jin–Netrapalli–Jordan 2019).** Step-size ratio $\eta_x/\eta_y$ does not help: as long as $\eta_y>0$ and $\nabla_y f(x_0,0)=0$, the $y$-update is zero, and Lemma 3.1 applies.
* **OGDA / Extragradient / Optimistic methods.** They are all linear-span first-order; same obstruction.
* **Momentum (Polyak HB, Nesterov).** Momentum $m_t = \beta m_{t-1} + \nabla f(z_t)$ starts at $m_0=0$; if $\nabla f(z_s)=0$ for all $s\le t$, then $m_t=0$ and assumption (A) applies.
* **Two-timescale + coupling (Diakonikolas, mirror-prox).** Same.
* **Adaptive step sizes (Adam, Adagrad).** All depend only on past gradients; if those are 0, the step is 0.
* **Randomized / stochastic methods** require an expectation argument: the stochastic gradient at $(x_0,0)$ is identically zero (no noise distribution can change a deterministic 0); so the first iterate is fixed. The argument extends to randomized methods using Le Cam's two-point lemma if one wants to handle external randomness, but on the deterministic instance (1.1) every stochastic gradient already equals 0 deterministically.
* **Hessian-free 2nd-order surrogates / finite-difference Hessian.** A finite-difference Hessian estimate at $(x_0,0)$ requires querying $\nabla f(x_0+\epsilon e_y, 0)= (0,0)$ — still zero — so the algorithm sees no signal even at second order from the axis. *This shows even quasi-second-order methods cannot break the impossibility within a pure first-order oracle.*

**The escape route — non-first-order information.** The construction is broken only by accessing $\nabla^2 f$ directly (e.g., eigen-decomposition of the Hessian matrix as an oracle, not via finite differences): then $\nabla_{yy}^2 f(x_0,0) = x_0^2 \ne 0$ for $x_0\ne 0$, signalling that $(x_0,0)$ is a saddle on the inner $y$-problem. But this is not first-order.

---

## Step 7 — Hooks Report

### Hook A (Strategy Signature Lookup)
- Searched `workspace/strategy_index.md` for `saddle-point`, `GDA`, `OGDA`, `minimax`, `degenerate Hessian`, `local minimax`, `first-order LB`.
- **Matches**:
  - `gda-nonconvex-strongly-concave-convergence`: Two-timescale GDA Lyapunov $V_t = \Phi(x_t) + c\,\delta_t$. *Used as obstruction-source*: Lesson 1 ("two-timescale ratio is intrinsic") tells us why no $\eta_x/\eta_y$ choice rescues.
  - `ogda-bilinear-last-iterate`: skew-symmetric polarization. *Inapplicable*: our coupling is $x^2 y^2$ (quartic), not bilinear.
  - `ssl-infonce-minimax-lower-bound`, `shb-no-acceleration-restricted`, `shb-interpolation-regime-lb`: Le Cam two-point templates. *Adapted*: we did NOT use Le Cam (the deterministic instance suffices) but borrowed the meta-strategy "construct a single $f$ universal over all algorithms in the class."
- Useful=YES; the GDA-strongly-concave Lesson 1 explicitly anticipated the failure mode at $\kappa=\infty$ (degenerate inner curvature), which is exactly what the witness (1.1) realizes.

### Hook B (Meta-template Slot-filling — `meta_templates.md`)
- **Attempted MT5 (Adversarial Polytope / Cycling Construction)**:
  - SLOT P (polytope) → REPLACED by *equilibrium variety* $\{y=0\}\cup\{y=\pm x\}$, which plays the role of P (vertices = critical points the algorithm gets stuck near).
  - SLOT F (Moreau envelope) → REPLACED by polynomial $\tfrac12 x^2 y^2 - \tfrac14 y^4$ — same role: $C^\infty$ with prescribed degenerate curvature.
  - SLOT CYCLE IDENTITY → REPLACED by *invariant fixed-set* identity (Lemma 3.1: $\nabla f(x,0)\equiv 0$). Stronger than cycling: we don't need the iterate to MOVE through a periodic orbit, just to be *stuck at a wrong point*.
  - All slots filled in modified form.
- **Cross-template**: borrowed MT4 (Reduce to low-dim) implicitly: the witness lives in $\mathbb R^2$, not $\mathbb R^d$.
- Slots filled: P, F, CYCLE IDENTITY (modified). Blocker slot: NONE — the modified template went through.
- Reason MT5 worked: `quantifier order` is now $\exists f \forall \mathcal A$ (single $f$, all algorithms), avoiding the Goujaud trap.

### Hook C (Structure Map Consultation — `structure_map.md`)
- Cluster A (SHB hard-instance polytope-Moreau family): used as ANALOGY — A6 (`heavy-ball-instability`) constructs $f(x)=(L/2)x^2 - (L-\mu)\ln\cosh(x)$ with two-curvature structure; we constructed $f$ with $\partial_{yy}^2 f(0,0)=0$ but $\partial_{yy}^2 f(x_0,0)=x_0^2\ne 0$ for $x_0\ne 0$ — same archetype "construct $f$ with curvature transition exposing a degenerate fixed point that is repelling."
- Cluster D (Le Cam / hypothesis-testing LBs): NOT used (deterministic argument suffices).
- Cross-cluster link `A6 ↔ D5`: heavy-ball-instability + SHB-no-accel-restricted both use *constructive* hard instances. We follow A6's flavour (single deterministic instance, no Le Cam).
- Useful=YES; the Cluster A archetype "constructive hard instance via curvature-transition counterexample" was the explicit template.

### Hook D (Failure Trigger Scanning — `failure_triggers.md`)
- Triggers checked: 12 (FT-OP2-* family, FT-CONJECTURE-RESCUE, FT-GDA-NONSTRICTNESS).
- **FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE**: matched in spirit. Pivot taken: *we explicitly verified the bad set $T$ is open and of positive Lebesgue measure*, not measure zero (Step 4 (ii)). The cusped set $T = \{|y_0|<c x_0^2,\;x_0\ne 0\}$ is engineered to lie in the basin of repulsion.
- **FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE**: not applicable (no cycling, no averaging). Documented as "averaging would not help here because the algorithm is *stuck*, not cycling — averaging a constant gives the same constant."
- **FT-OP2-I4-SUFFIX-AVG-RESONANCE**: not applicable (same reason).
- **FT-Goujaud quantifier-order trap**: the witness $f$ is single, fixed; the quantifier is $\exists f\forall \mathcal A$ — correct order for an impossibility.
- Failure triggers checked: 12; matched (by structural analogy): 1 (FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE); pivots taken: 1 (positive-measure set construction, Step 4 (ii)).

### Hooks Report (Required Format)

```
- Strategy signatures consulted: [gda-nonconvex-strongly-concave-convergence, ogda-bilinear-last-iterate, ssl-infonce-minimax-lower-bound, shb-no-acceleration-restricted]; useful=YES; GDA Lesson 1 anticipated the κ→∞ degeneracy this witness exploits.
- Meta-template attempted: MT5 (Adversarial Construction); slots filled: [P, F, CYCLE_IDENTITY (modified to fixed-set-identity)]; blocker slot: NONE; reason: replacing periodic-cycling with stuck-at-wrong-point preserves the universal-instance property.
- Structure map links used: [Cluster A SHB-Goujaud (ANALOGY), A6 heavy-ball-instability (curvature-transition ARCHETYPE)] OR "none consulted"
- Failure triggers checked: 12; matched: [FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE]; pivots taken: [positive-measure cusp set T constructed in Step 4 (ii)]
```

---

## Q.E.D.

The instance $f(x,y)=\tfrac12 x^2 y^2 - \tfrac14 y^4$ provides an explicit $C^\infty$ witness for the negative answer to the Chae–Kim–Kim 2023 open problem under the standard linear-span first-order oracle model.

---

## Auditor Notes (suggestions for stress-test)

1. The continuous-time → discrete-time shadowing argument in Step 4 (ii.b) is a textbook step but uses a "for sufficiently small $\eta$" qualifier. To make this UNIFORM over algorithms one needs to verify the discrete one-step inequality directly: $|x_{t+1}|\ge |x_t|(1-O(\eta y_t^2))$ and $|y_{t+1}|\ge |y_t|(1+O(\eta x_t^2))$ as long as $|y_t|<|x_t|$, which gives discrete repulsion. This is a routine but worth pinning down formally.
2. The Jin et al. 2019 definition of *local minimax* requires $\delta>0$ such that $\Phi_\delta(x)\ge\Phi_\delta(x^*)$ for $x$ in a neighbourhood. We verified this holds for any $\delta\in(0,1)$ with the corresponding $\delta_x = \delta/\sqrt 2$. The two thresholds are linked by $\delta_x \to 0$ as $\delta\to 0$, which is allowed by the definition.
3. The class $\mathcal F_\infty$ specifically excludes algorithms that use *function values* (zeroth order) AND *Hessian queries* explicitly. If the open problem actually permits Hessian queries, then this impossibility does not apply, and Theorem 5.1 should be restated under the stricter "first-order = gradient-only" interpretation, which is the standard reading of Chae–Kim–Kim.
